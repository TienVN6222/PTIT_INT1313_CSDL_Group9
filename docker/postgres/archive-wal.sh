#!/bin/sh
# ============================================================================
# archive_command của PostgreSQL (NFR-AVL-01: sao lưu liên tục WAL, NFR-SEC-03: mã hóa khi lưu trữ).
# Gọi bởi máy chủ: archive-wal.sh %p %f  (%p = đường dẫn tệp WAL, %f = tên tệp)
# Mã hóa AES-256 rồi ghi nguyên tử vào /wal_archive/<tên>.enc. Trả mã khác 0 khi lỗi để PostgreSQL
# giữ lại tệp WAL và thử lại (không bao giờ mất WAL).
# ============================================================================
set -eu
src="$1"
name="$2"
dest="/wal_archive/$name.enc"

# Đã lưu trước đó (ví dụ PostgreSQL thử lại sau khi lỗi giữa chừng): coi như thành công.
[ -f "$dest" ] && exit 0

openssl enc -aes-256-cbc -pbkdf2 -iter 200000 -salt \
    -pass env:BACKUP_PASSPHRASE -in "$src" -out "$dest.part"
mv "$dest.part" "$dest"
