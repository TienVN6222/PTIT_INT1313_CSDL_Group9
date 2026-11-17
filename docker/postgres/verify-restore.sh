#!/bin/sh
# ============================================================================
# Kiểm tra khôi phục (NFR-AVL-01): giải mã bản sao lưu mới nhất, khôi phục vào CSDL tạm
# <db>_restore_check trên cùng máy chủ, so số dòng của 18 bảng với CSDL đang chạy, rồi xóa CSDL tạm.
# Chạy: docker compose exec backup verify-restore.sh      (exit 0 = ĐẠT)
# Lưu ý: dữ liệu có thể thay đổi giữa lúc sao lưu và lúc kiểm tra (vd. scheduler gia hạn hợp đồng);
# khi đó hãy sao lưu lại (backup.sh --once) rồi kiểm tra ngay.
# ============================================================================
set -eu

: "${BACKUP_PASSPHRASE:?Thiếu BACKUP_PASSPHRASE}"
BACKUP_DIR=${BACKUP_DIR:-/backups}
CHECK_DB="${PGDATABASE}_restore_check"
export PGOPTIONS="${PGOPTIONS:-} -c client_min_messages=warning"
WORK=$(mktemp -d)
trap 'rm -rf "$WORK"' EXIT

latest=$(ls -1 "$BACKUP_DIR"/"${PGDATABASE}"_*.dump.enc 2>/dev/null | sort -r | head -n 1 || true)
[ -n "$latest" ] || { echo "[verify] không tìm thấy bản sao lưu nào trong $BACKUP_DIR"; exit 1; }
echo "[verify] bản sao lưu: $(basename "$latest")"

openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 -pass env:BACKUP_PASSPHRASE \
    -in "$latest" -out "$WORK/db.dump"

psql -X -q -v ON_ERROR_STOP=1 -d postgres -c "DROP DATABASE IF EXISTS \"$CHECK_DB\""
psql -X -q -v ON_ERROR_STOP=1 -d postgres -c "CREATE DATABASE \"$CHECK_DB\""
pg_restore --exit-on-error --no-password -d "$CHECK_DB" "$WORK/db.dump"

COUNT_SQL="SELECT tablename || '=' || (xpath('/row/c/text()', query_to_xml(format('SELECT COUNT(*) AS c FROM %I', tablename), FALSE, TRUE, '')))[1]::TEXT
           FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename"
psql -X -At -d "$PGDATABASE" -c "$COUNT_SQL" > "$WORK/live.txt"
psql -X -At -d "$CHECK_DB"   -c "$COUNT_SQL" > "$WORK/restored.txt"

psql -X -q -d postgres -c "DROP DATABASE IF EXISTS \"$CHECK_DB\""

tables=$(wc -l < "$WORK/restored.txt")
if diff "$WORK/live.txt" "$WORK/restored.txt" >/dev/null; then
    echo "[verify] ĐẠT: khôi phục $tables bảng, số dòng khớp CSDL đang chạy"
    exit 0
fi
echo "[verify] KHÔNG ĐẠT: số dòng lệch (trái = đang chạy, phải = khôi phục):"
diff "$WORK/live.txt" "$WORK/restored.txt" || true
exit 1
