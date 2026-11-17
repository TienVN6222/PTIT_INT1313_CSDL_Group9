# ============================================================================
# Image CSDL dùng chung cho service db và backup (NFR-SEC-03, NFR-AVL-01)
#   * postgres:16-alpine + openssl: sinh chứng chỉ TLS và mã hóa bản sao lưu (AES-256)
#   * start-postgres.sh : bật TLS (ssl=on) + pg_hba bắt buộc TLS cho kết nối qua mạng
#   * backup.sh         : pg_dump định kỳ, mã hóa, giữ N bản gần nhất
#   * verify-restore.sh : giải mã bản mới nhất, khôi phục vào CSDL tạm, so số dòng 18 bảng
#   * archive-wal.sh / restore-wal.sh : lưu trữ WAL liên tục (mã hóa) và phát lại WAL khi khôi phục
#   * verify-pitr.sh    : khôi phục bản sao lưu nền + phát lại WAL trên máy chủ tạm, so số dòng 18 bảng
# ============================================================================
FROM postgres:16-alpine

RUN apk add --no-cache openssl

COPY pg_hba.conf /etc/postgresql/pg_hba.conf
COPY start-postgres.sh backup.sh verify-restore.sh archive-wal.sh restore-wal.sh verify-pitr.sh /usr/local/bin/
RUN chmod 0755 /usr/local/bin/start-postgres.sh /usr/local/bin/backup.sh /usr/local/bin/verify-restore.sh \
               /usr/local/bin/archive-wal.sh /usr/local/bin/restore-wal.sh /usr/local/bin/verify-pitr.sh \
    && chmod 0644 /etc/postgresql/pg_hba.conf
