#!/bin/sh
# ============================================================================
# Khởi động PostgreSQL với TLS (NFR-SEC-03).
# Bản demo tự sinh chứng chỉ tự ký (self-signed) mỗi lần container khởi động nếu chưa có;
# khi triển khai thật, mount chứng chỉ do CA cấp vào /etc/postgresql/tls (server.crt, server.key).
# ============================================================================
set -eu

TLS_DIR=/etc/postgresql/tls
mkdir -p "$TLS_DIR"
if [ ! -s "$TLS_DIR/server.crt" ] || [ ! -s "$TLS_DIR/server.key" ]; then
    openssl req -new -x509 -days 825 -nodes -newkey rsa:2048 \
        -subj "/CN=${TLS_COMMON_NAME:-db}" \
        -keyout "$TLS_DIR/server.key" -out "$TLS_DIR/server.crt" >/dev/null 2>&1
    echo "[start-postgres] đã sinh chứng chỉ TLS tự ký cho CN=${TLS_COMMON_NAME:-db}"
fi
# PostgreSQL từ chối khóa riêng có quyền đọc cho nhóm/người khác.
chown postgres:postgres "$TLS_DIR/server.key" "$TLS_DIR/server.crt"
chmod 0600 "$TLS_DIR/server.key"

# NFR-AVL-01: sao lưu liên tục WAL (mã hóa) vào /wal_archive khi có BACKUP_PASSPHRASE;
# kết hợp bản sao lưu nền (pg_basebackup) của service backup cho phép khôi phục theo thời điểm (PITR).
set --
if [ -n "${BACKUP_PASSPHRASE:-}" ]; then
    mkdir -p /wal_archive
    chown postgres:postgres /wal_archive
    chmod 0700 /wal_archive
    set -- -c archive_mode=on \
           -c archive_command='/usr/local/bin/archive-wal.sh %p %f' \
           -c archive_timeout="${WAL_ARCHIVE_TIMEOUT:-300}"
fi

exec docker-entrypoint.sh postgres \
    -c ssl=on \
    -c ssl_cert_file="$TLS_DIR/server.crt" \
    -c ssl_key_file="$TLS_DIR/server.key" \
    -c ssl_min_protocol_version=TLSv1.2 \
    -c hba_file=/etc/postgresql/pg_hba.conf \
    "$@"
