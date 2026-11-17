#!/bin/sh
# ============================================================================
# Kiểm tra khôi phục theo thời điểm - PITR (NFR-AVL-01).
#   1. Chụp số dòng 18 bảng của CSDL đang chạy, rồi pg_switch_wal() để đẩy đoạn WAL hiện tại
#      vào kho lưu trữ (mọi thay đổi tới thời điểm chụp đều nằm trong WAL đã lưu trữ).
#   2. Giải mã bản sao lưu nền mới nhất, giải nén vào thư mục tạm.
#   3. Khởi động một máy chủ PostgreSQL TẠM (cổng 5433, chỉ socket nội bộ) ở chế độ khôi phục,
#      restore_command = restore-wal.sh (giải mã từng tệp WAL), phát lại tới hết WAL đã lưu trữ.
#   4. So số dòng 18 bảng của bản khôi phục với ảnh chụp ở bước 1, dừng máy chủ tạm, xóa thư mục tạm.
# Chạy: docker compose exec backup verify-pitr.sh      (exit 0 = ĐẠT)
# ============================================================================
set -eu

: "${BACKUP_PASSPHRASE:?Thiếu BACKUP_PASSPHRASE}"
BACKUP_DIR=${BACKUP_DIR:-/backups}
export WAL_ARCHIVE_DIR=${WAL_ARCHIVE_DIR:-/wal_archive}
export PGOPTIONS="${PGOPTIONS:-} -c client_min_messages=warning"
WORK=$(mktemp -d)
PGTMP="$WORK/data"
cleanup() {
    if [ -f "$PGTMP/postmaster.pid" ]; then
        su-exec postgres pg_ctl -D "$PGTMP" -m immediate -w stop >/dev/null 2>&1 || true
    fi
    rm -rf "$WORK"
}
trap cleanup EXIT

latest=$(ls -1 "$BACKUP_DIR"/base_*.tar.enc 2>/dev/null | sort -r | head -n 1 || true)
[ -n "$latest" ] || { echo "[pitr] không tìm thấy bản sao lưu nền nào trong $BACKUP_DIR"; exit 1; }
echo "[pitr] bản sao lưu nền: $(basename "$latest")"

COUNT_SQL="SELECT tablename || '=' || (xpath('/row/c/text()', query_to_xml(format('SELECT COUNT(*) AS c FROM %I', tablename), FALSE, TRUE, '')))[1]::TEXT
           FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"

# Bước 1: ảnh chụp số dòng, rồi đóng đoạn WAL hiện tại và chờ nó được lưu trữ.
psql -X -At -d "$PGDATABASE" -c "$COUNT_SQL" > "$WORK/live.txt"
seg=$(psql -X -At -d "$PGDATABASE" -c "SELECT pg_walfile_name(pg_switch_wal())")
i=0
until [ -f "$WAL_ARCHIVE_DIR/$seg.enc" ]; do
    i=$((i + 1))
    [ "$i" -le 60 ] || { echo "[pitr] WAL $seg chưa được lưu trữ sau 60 giây"; exit 1; }
    sleep 1
done
echo "[pitr] đã lưu trữ WAL tới $seg"

# Bước 2: giải mã và giải nén bản nền.
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -pass env:BACKUP_PASSPHRASE -in "$latest" -out "$WORK/base.tar"
mkdir -p "$WORK/base" "$PGTMP"
tar -C "$WORK/base" -xf "$WORK/base.tar"
tar -C "$PGTMP" -xzf "$WORK/base/base.tar.gz"
chown -R postgres:postgres "$WORK"
chmod 0700 "$PGTMP"

# Bước 3: khôi phục trên máy chủ tạm (không mở cổng mạng, không lưu trữ WAL của chính nó).
touch "$PGTMP/recovery.signal"
cat >> "$PGTMP/postgresql.auto.conf" <<EOF
restore_command = '/usr/local/bin/restore-wal.sh %f %p'
recovery_target_timeline = 'latest'
EOF
chown postgres:postgres "$PGTMP/recovery.signal" "$PGTMP/postgresql.auto.conf"
su-exec postgres pg_ctl -D "$PGTMP" -w -t 300 -l "$WORK/server.log" \
    -o "-c port=5433 -c listen_addresses='' -c unix_socket_directories=$WORK -c archive_mode=off -c hba_file=$PGTMP/pg_hba.conf" \
    start >/dev/null
i=0
until [ "$(psql -X -At -h "$WORK" -p 5433 -U "$PGUSER" -d "$PGDATABASE" -c 'SELECT NOT pg_is_in_recovery()' 2>/dev/null)" = "t" ]; do
    i=$((i + 1))
    [ "$i" -le 300 ] || { echo "[pitr] máy chủ tạm chưa khôi phục xong sau 300 giây"; tail -20 "$WORK/server.log"; exit 1; }
    sleep 1
done
replayed=$(grep -c 'restored log file' "$WORK/server.log" || true)
echo "[pitr] khôi phục xong, đã phát lại $replayed tệp WAL"

# Bước 4: so sánh.
psql -X -At -h "$WORK" -p 5433 -U "$PGUSER" -d "$PGDATABASE" -c "$COUNT_SQL" > "$WORK/restored.txt"
tables=$(wc -l < "$WORK/restored.txt")
if diff "$WORK/live.txt" "$WORK/restored.txt" >/dev/null; then
    echo "[pitr] ĐẠT: khôi phục $tables bảng bằng bản nền + WAL, số dòng khớp CSDL đang chạy"
    exit 0
fi
echo "[pitr] KHÔNG ĐẠT: số dòng lệch (trái = đang chạy, phải = khôi phục):"
diff "$WORK/live.txt" "$WORK/restored.txt" || true
exit 1
