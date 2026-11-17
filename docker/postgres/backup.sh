#!/bin/sh
# ============================================================================
# Sao lưu định kỳ (NFR-AVL-01) + mã hóa bản sao lưu khi lưu trữ (NFR-SEC-03).
#   backup.sh         : chạy vòng lặp, sao lưu ngay rồi lặp lại mỗi BACKUP_INTERVAL_SECONDS
#   backup.sh --once  : sao lưu đúng một lần (dùng thủ công: docker compose exec backup backup.sh --once)
# Mỗi chu kỳ tạo 2 loại: bản logic pg_dump (khôi phục nhanh toàn CSDL) và bản nền pg_basebackup
# (cùng WAL lưu trữ liên tục => khôi phục theo thời điểm, PITR).
# Mỗi bản = pg_dump định dạng custom (-Fc, đã nén) mã hóa AES-256-CBC (PBKDF2) bằng BACKUP_PASSPHRASE,
# lưu ở /backups/<db>_<UTC>.dump.enc; chỉ giữ BACKUP_RETENTION bản mới nhất.
# Kết nối tới CSDL qua TLS (PGSSLMODE=require).
# ============================================================================
set -eu

: "${BACKUP_PASSPHRASE:?Thiếu BACKUP_PASSPHRASE}"
BACKUP_DIR=${BACKUP_DIR:-/backups}
BACKUP_INTERVAL_SECONDS=${BACKUP_INTERVAL_SECONDS:-86400}
BACKUP_RETENTION=${BACKUP_RETENTION:-7}

log() { echo "$(date -u '+%Y-%m-%d %H:%M:%S') [backup] $*"; }

backup_once() {
    stamp=$(date -u '+%Y%m%dT%H%M%SZ')
    target="$BACKUP_DIR/${PGDATABASE}_${stamp}.dump.enc"
    tmp="$target.part"
    # pipefail không có trong sh của alpine: kiểm tra riêng từng bước qua tập tin tạm.
    if pg_dump -Fc --no-password > "$tmp.raw" \
        && openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt \
               -pass env:BACKUP_PASSPHRASE -in "$tmp.raw" -out "$tmp"; then
        rm -f "$tmp.raw"
        mv "$tmp" "$target"
        chmod 0600 "$target"
        log "OK: $(basename "$target") ($(wc -c < "$target") byte)"
    else
        rm -f "$tmp" "$tmp.raw"
        log "LỖI: sao lưu thất bại, thử lại ở chu kỳ sau"
        return 1
    fi
    # Giữ BACKUP_RETENTION bản mới nhất (tên có dấu thời gian nên sắp xếp theo tên = theo thời gian).
    ls -1 "$BACKUP_DIR"/"${PGDATABASE}"_*.dump.enc 2>/dev/null | sort -r \
        | tail -n +"$((BACKUP_RETENTION + 1))" | while read -r old; do
            rm -f "$old"
            log "xóa bản cũ $(basename "$old")"
        done
}

# Sao lưu nền (pg_basebackup) cho PITR: cùng WAL được db lưu trữ liên tục vào $WAL_ARCHIVE_DIR,
# cho phép khôi phục tới bất kỳ thời điểm nào sau bản nền. Mã hóa AES-256 giống bản pg_dump.
WAL_ARCHIVE_DIR=${WAL_ARCHIVE_DIR:-/wal_archive}
base_backup_once() {
    stamp=$(date -u '+%Y%m%dT%H%M%SZ')
    target="$BACKUP_DIR/base_${stamp}.tar.enc"
    work=$(mktemp -d)
    if pg_basebackup -D "$work/base" -Ft -z -X none --checkpoint=fast --no-password \
        && tar -C "$work/base" -cf "$work/base.tar" . \
        && openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt \
               -pass env:BACKUP_PASSPHRASE -in "$work/base.tar" -out "$target.part"; then
        # Tệp WAL đầu tiên mà bản nền này cần, dùng để dọn WAL cũ khi bản nền bị xoay vòng.
        tar -xzOf "$work/base/base.tar.gz" backup_label 2>/dev/null \
            | sed -n 's/^START WAL LOCATION: .*(file \([0-9A-F]*\))$/\1/p' > "$BACKUP_DIR/base_${stamp}.walstart"
        mv "$target.part" "$target"
        chmod 0600 "$target"
        log "OK: $(basename "$target") (bắt đầu từ WAL $(cat "$BACKUP_DIR/base_${stamp}.walstart"))"
    else
        rm -f "$target.part"
        log "LỖI: sao lưu nền thất bại, thử lại ở chu kỳ sau"
        rm -rf "$work"
        return 1
    fi
    rm -rf "$work"
    ls -1 "$BACKUP_DIR"/base_*.tar.enc 2>/dev/null | sort -r | tail -n +"$((BACKUP_RETENTION + 1))" \
        | while read -r old; do
            rm -f "$old" "${old%.tar.enc}.walstart"
            log "xóa bản nền cũ $(basename "$old")"
        done
    # Xóa WAL đã lưu trữ cũ hơn bản nền lâu đời nhất còn giữ (không bản nào cần tới nữa).
    oldest=$(ls -1 "$BACKUP_DIR"/base_*.walstart 2>/dev/null | sort | head -n 1 || true)
    if [ -n "$oldest" ] && [ -s "$oldest" ] && [ -d "$WAL_ARCHIVE_DIR" ]; then
        pg_archivecleanup -x .enc "$WAL_ARCHIVE_DIR" "$(cat "$oldest")"
    fi
}

mkdir -p "$BACKUP_DIR"
until pg_isready -q; do sleep 2; done

if [ "${1:-}" = "--once" ]; then
    backup_once && base_backup_once
    exit $?
fi

log "khởi động, chu kỳ ${BACKUP_INTERVAL_SECONDS}s, giữ ${BACKUP_RETENTION} bản"
while true; do
    backup_once || true
    base_backup_once || true
    sleep "$BACKUP_INTERVAL_SECONDS"
done
