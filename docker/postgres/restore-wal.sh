#!/bin/sh
# ============================================================================
# restore_command khi khôi phục theo thời điểm (PITR): giải mã một tệp WAL đã lưu trữ.
# Gọi bởi máy chủ đang khôi phục: restore-wal.sh %f %p
# Trả mã khác 0 khi tệp không có trong kho lưu trữ (PostgreSQL hiểu là đã hết WAL để phát lại).
# ============================================================================
set -eu
name="$1"
dest="$2"
src="${WAL_ARCHIVE_DIR:-/wal_archive}/$name.enc"

[ -f "$src" ] || exit 1
openssl enc -d -aes-256-cbc -pbkdf2 -iter 200000 \
    -pass env:BACKUP_PASSPHRASE -in "$src" -out "$dest"
