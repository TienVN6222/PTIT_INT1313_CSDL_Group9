# 🏋️‍♂️ Hệ Thống Quản Lý Phòng Tập & Huấn Luyện Viên Cá Nhân (Gym Membership & PT Planner)

[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2016-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Container-Docker%20Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Streamlit](https://img.shields.io/badge/Frontend-Streamlit%201.35-FF4B4B?logo=streamlit&logoColor=white)](https://streamlit.io/)
[![Standard](https://img.shields.io/badge/Standard-SQLStyle.guide-10b981)](https://www.sqlstyle.guide/)

> **Học phần:** Cơ sở dữ liệu (INT1313) — Học kỳ 1 (2026 - 2027)  
> **Mã Đề Tài (Project ID):** `09` | **Tên Nhóm (Team Name):** `G9`  
> **Hệ quản trị CSDL mục tiêu:** `PostgreSQL 16+`

---

## 👥 Danh Sách Nhóm Thực Hiện (Members)

| STT | Họ và Tên | Mã Sinh Viên | Email Sinh Viên | Tài Khoản GitHub |
| :---: | :--- | :---: | :--- | :--- |
| 1 | **Lê Hoàng Tiến** | N25DCAT050 | [n25dcat050@student.ptithcm.edu.vn](mailto:n25dcat050@student.ptithcm.edu.vn) | [TienVN6222](https://github.com/TienVN6222) |
| 2 | **Lê Hòa Thuận** | N25DCAT110 | [n25dcat110@student.ptithcm.edu.vn](mailto:n25dcat110@student.ptithcm.edu.vn) | [conphencoll115-bot](https://github.com/conphencoll115-bot) |
| 3 | **Trần Minh Tiến** | N25DCAT111 | [n25dcat111@student.ptithcm.edu.vn](mailto:n25dcat111@student.ptithcm.edu.vn) | [mtgin2312](https://github.com/mtgin2312) |

---

## 🚀 Hướng Dẫn Chạy Nhanh (1-Click Disposable Deployment)

Dự án được cấu hình đóng gói **100% trong môi trường dùng một lần (Disposable Container)** thông qua Docker Compose. Người dùng **không cần cài đặt PostgreSQL hay bất kỳ phần mềm quản trị CSDL nào lên máy tính cá nhân**.

### 1. Khởi động toàn bộ Hệ thống (CSDL + Mock Data + Views/Triggers + Web App)
Chỉ cần mở Terminal tại thư mục gốc của repository và chạy duy nhất 1 lệnh:

```bash
docker compose up --build
```

- Container `fitzone_postgres_db` tự động khởi chạy và nạp tuần tự các file script trong `/docker-entrypoint-initdb.d/` (mỗi file trong `Phase 3/` được mount riêng với tên đích sắp xếp đúng thứ tự):
  1. `01_schema_ddl.sql` (Khởi tạo 18 bảng, PK, FK, CHECK, Trigger tuổi BR-03, Indexes).
  2. `02_01_…` đến `02_08_…` ← `Phase 3/02_mock_data/01_reference_data.sql` … `08_maintenance_logs.sql` (8 file dữ liệu mẫu, tổng 9.928 bản ghi trên 18 bảng, đa dạng trạng thái). Người dùng 31–3000 và thiết bị 201–500 được sinh tất định bằng `generate_series()` để đạt mức tối thiểu của giảng viên (≥ 3.000 người dùng, ≥ 500 thiết bị).
  3. `04_triggers_views.sql` (Khởi tạo 2 Views, các Triggers nghiệp vụ BR-07 → BR-25, thủ tục gia hạn `sp_process_subscription_renewals` và khối kiểm toán dữ liệu mẫu).
  4. `08_rbac_security.sql` (Tạo các role phân quyền và tài khoản đăng nhập demo `gym_u_*`).
- Container `fitzone_renewal_scheduler` (cùng image `postgres:16-alpine`) chờ CSDL sẵn sàng rồi gọi `CALL sp_process_subscription_renewals();` (BR-24) bằng tài khoản lễ tân `gym_u_reception` ngay khi khởi động và lặp lại mỗi `RENEWAL_INTERVAL_SECONDS` giây (mặc định 86400 = 1 ngày; đặt biến này trong `.env` để đổi, ví dụ `20` khi trình diễn). Xem log: `docker logs fitzone_renewal_scheduler`.
- Container `fitzone_postgres_db` dùng image `fitzone-postgres:16` (build từ `docker/postgres/`): **mọi kết nối mạng đến CSDL bắt buộc dùng TLS** (`ssl=on`, TLS ≥ 1.2, `pg_hba.conf` chỉ cho `hostssl` + `scram-sha-256`, kết nối không mã hóa bị từ chối). Chứng chỉ được tạo tự ký khi khởi động (chỉ để demo; production gắn chứng chỉ của CA vào `/etc/postgresql/tls`). Web dùng `DB_SSLMODE=require`, scheduler dùng `PGSSLMODE=require`.
- Container `fitzone_db_backup` (service `backup`) chạy `pg_dump -Fc` ngay khi khởi động rồi mỗi `BACKUP_INTERVAL_SECONDS` giây (mặc định 86400), mã hóa AES-256-CBC bằng `BACKUP_PASSPHRASE`, ghi vào `./backups/<db>_<UTC>.dump.enc` và giữ `BACKUP_RETENTION` (mặc định 7) bản mới nhất. Thư mục `backups/` đã được `.gitignore`.
  ```bash
  docker compose exec backup backup.sh --once     # sao lưu ngay một bản
  docker compose exec backup verify-restore.sh    # giải mã bản mới nhất, khôi phục vào CSDL tạm, so số dòng 18 bảng (exit 0 = ĐẠT)
docker compose exec backup verify-pitr.sh       # PITR: bản nền pg_basebackup + phát lại WAL đã lưu trữ trên máy chủ tạm (exit 0 = ĐẠT)
  ```
  > **Cảnh báo:** phải đổi `BACKUP_PASSPHRASE` trong `.env` khi triển khai thật; mất mật khẩu này thì không thể khôi phục các bản sao lưu. CSDL lưu trữ WAL liên tục (mã hóa) vào `./backups/wal`; cùng bản nền `pg_basebackup` cho phép khôi phục theo thời điểm (PITR). Chưa bao gồm mã hóa tệp dữ liệu trên đĩa máy chủ (hạ tầng: LUKS/mã hóa đĩa).
- Container `fitzone_web_app` tự động kết nối CSDL và khởi động ứng dụng Web UI. **Ứng dụng đăng nhập bằng tài khoản `gym_u_admin` / `demo_2026` (không phải superuser, thuộc nhóm quyền `gym_role_admin`)** thông qua biến `DB_USER`/`DB_PASSWORD`; `POSTGRES_USER=gym_admin` chỉ dùng để khởi tạo CSDL và chạy các script kiểm thử. Do đó ứng dụng không đọc được `user_account.password_hash`, không sửa/xóa được `billing_log` và không có quyền `TRUNCATE`.

### 2. Truy cập Ứng dụng
Mở trình duyệt web và truy cập vào địa chỉ:
👉 **[http://localhost:8501](http://localhost:8501)**

### 3. Dọn dẹp sạch sẽ 100% (Disposable Teardown)
Khi hoàn tất kiểm thử hoặc chấm đồ án, bạn chỉ cần chạy lệnh sau để xóa sạch container, mạng và volume dữ liệu mà không để lại bất kỳ rác nào trên máy:

```bash
docker compose down -v
```


### 4. Chạy các Script Kiểm Thử & Tài Khoản RBAC Demo
Thư mục `Phase 3/` được mount chỉ-đọc vào `/sql/` trong container CSDL (các script này **không** chạy tự động lúc khởi tạo). Chạy thủ công khi hệ thống đang hoạt động:

```bash
# 05 - Kiểm thử ràng buộc & trigger (109 test case)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/05_constraint_test_cases.sql

# 06 - Kiểm thử hiệu năng (mất khoảng 1 phút)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/06_performance_test_cases.sql

# 09 - Kiểm thử phân quyền RBAC (66 test case)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/09_rbac_test_cases.sql
```

> **Nạp lại CSDL đã có (BR-10):** Bản nạp lại (01 `DROP` `billing_log`, 04 `DROP`/`CREATE` trigger và hàm bất biến) bị event trigger BR-10 chặn, kể cả với superuser. Cách đơn giản nhất là tạo CSDL mới (`docker compose down -v` rồi `docker compose up --build`). Nếu muốn nạp lại tại chỗ, superuser đặt lối thoát trong cùng phiên `psql` (`SET app.allow_billing_maintenance = 'on';` trước khi `\i` các tập tin) hoặc tắt event trigger bằng hai lệnh riêng `ALTER EVENT TRIGGER evt_protect_billing_log DISABLE;` và `ALTER EVENT TRIGGER evt_protect_billing_log_drop DISABLE;`, sau đó nạp lại 08 để tạo lại chúng.

> **Lưu ý BR-23:** mọi thao tác ghi vào 5 bảng giao dịch phải có người thực hiện. Khi chạy SQL thủ công, hãy đặt trước `SET app.current_user_id = '<user_id>';` (ví dụ `'3'` là lễ tân mẫu), nếu không CSDL sẽ từ chối (lỗi `BR-23`). Các script test tự đặt biến này ở đầu tập tin; ứng dụng đặt trong từng giao dịch; service `scheduler` lấy người thực hiện từ biến môi trường `SCHEDULER_ACTOR_USER_ID` (mặc định `3`, qua `PGOPTIONS`).

Script `08_rbac_security.sql` tạo sẵn các tài khoản đăng nhập demo (mật khẩu chung: `demo_2026`):

| Tài khoản | Vai trò |
| :--- | :--- |
| `gym_u_admin` | Quản trị viên |
| `gym_u_reception` | Lễ tân |
| `gym_u_trainer` | Huấn luyện viên |
| `gym_u_tech` | Kỹ thuật viên |
| `gym_u_member` | Hội viên |

Ví dụ: `docker exec -it fitzone_postgres_db psql -U gym_u_reception -d gym_management`

---

## 📁 Cấu Trúc Thư Mục Repository

```text
PTIT_INT1313_CSDL_Group9/
├── Phase 1/                                 # PHÂN TÍCH YÊU CẦU
│   ├── project_scope.md                    # Phạm vi đồ án
│   └── business_rules.md                   # Các quy tắc nghiệp vụ (BR-xx)
├── Phase 2/                                 # THIẾT KẾ CSDL
│   ├── data_dictionary/                    # Từ điển dữ liệu theo 5 phân hệ (ISO/IEC 11179)
│   └── database_design/                    # Mô hình ER/EER, ánh xạ lược đồ logic, kiểm tra chuẩn hóa
├── Phase 3/                                 # KHO SCRIPT CSDL
│   ├── 01_schema_ddl.sql                   # DDL: 18 bảng, khóa chính, khóa ngoại, ràng buộc CHECK
│   ├── 02_mock_data/                       # DML: 8 file dữ liệu mẫu (01_reference_data ... 08_maintenance_logs)
│   ├── 03_complex_queries.sql              # 10 câu truy vấn SQL phức tạp có chú thích nghiệp vụ
│   ├── 04_triggers_views.sql               # Views tổng hợp và Triggers bảo vệ dữ liệu
│   ├── 05_constraint_test_cases.sql        # Bộ test ràng buộc/trigger (chạy thủ công)
│   ├── 06_performance_test_cases.sql       # Bộ test hiệu năng (chạy thủ công, ~1 phút)
│   ├── 07_test_results.md                  # Kết quả kiểm thử
│   ├── 08_rbac_security.sql                # Role, phân quyền và tài khoản demo (RBAC)
│   └── 09_rbac_test_cases.sql              # Bộ test phân quyền (chạy thủ công)
├── app/                                     # ỨNG DỤNG WEB GIAO DIỆN (PHASE 4)
│   ├── app.py                              # Streamlit Dashboard, CRUD, Queries runner, Test Bench
│   ├── requirements.txt                    # Thư viện Python phụ thuộc
│   └── Dockerfile                          # Build image độc lập cho Web UI
├── docker/postgres/                         # Image CSDL fitzone-postgres:16 (TLS bắt buộc, pg_hba), backup.sh, verify-restore.sh, archive-wal.sh, verify-pitr.sh
├── backups/                                 # Bản sao lưu mã hóa (.dump.enc), tự tạo, không đưa lên Git
├── Gym_Membership_PT_Planner_Report_ISO_Standards.docx  # Báo cáo kỹ thuật chi tiết
├── Gym_Membership_PT_Planner_Report_ISO_Standards.md    # Bản chuyển đổi Markdown của báo cáo
├── docker-compose.yml                       # Điều phối khởi chạy toàn bộ hệ thống
├── .env.example                             # File mẫu cấu hình tham số môi trường
└── README.md                                # Hướng dẫn tổng quan đồ án
```

---

## 🏛️ Lược Đồ Cơ Sở Dữ Liệu 18 Bảng (ISO/IEC 11179 Data Dictionary)

Hệ thống bao gồm **18 bảng quan hệ chuẩn hóa BCNF**, chia thành 5 phân hệ cốt lõi:

| STT | Tên Bảng (`snake_case`) | Khóa Chính (PK) | Mục Đích Nghiệp Vụ | Ràng Buộc Nổi Bật |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `user_account` | `user_id` | Định danh tài khoản người dùng dùng chung | `UNIQUE(email, phone)`, Trigger `dob <= CURRENT_DATE - 12y` |
| 2 | `role` | `role_id` | Danh mục vai trò trong hệ thống (RBAC) | `UNIQUE(role_name)` |
| 3 | `user_role` | `(user_id, role_id)` | Bảng trung gian phân quyền đa vai trò (M:N) | `FK ON DELETE CASCADE` |
| 4 | `permission` | `permission_id` | Danh mục các quyền thao tác chức năng | `UNIQUE(permission_code)` |
| 5 | `role_permission` | `(role_id, permission_id)` | Phân bổ quyền cho vai trò (M:N) | `FK ON DELETE CASCADE` |
| 6 | `member_profile` | `user_id` (Shared PK) | Hồ sơ mở rộng lưu tiền sử sức khỏe hội viên | `FK user_account ON DELETE CASCADE` |
| 7 | `trainer_profile` | `user_id` (Shared PK) | Hồ sơ chuyên môn và xếp hạng HLV | `CHECK (current_rating BETWEEN 0.00 AND 5.00)` |
| 8 | `staff_profile` | `user_id` (Shared PK) | Hồ sơ nhân viên tiếp tân / kỹ thuật | `FK user_account ON DELETE CASCADE` |
| 9 | `membership_plan` | `plan_id` | Danh mục các gói tập (thời gian / PT) | `CHECK (duration_days > 0, price >= 0)` |
| 10 | `member_subscription` | `subscription_id` | Hợp đồng đăng ký gói tập của hội viên | `CHECK (end_time >= start_time, remaining_sessions >= 0)` |
| 11 | `billing_log` | `billing_id` | Nhật ký hóa đơn thanh toán bất biến | `UNIQUE(invoice_no)`, `CHECK (amount > 0)` |
| 12 | `facilities_room` | `room_id` | Danh mục phòng tập và khu vực tiện ích | `CHECK (max_capacity > 0)` |
| 13 | `equipment` | `equipment_id` | Danh mục máy móc thiết bị tập luyện | `UNIQUE(serial_number)`, `CHECK (depreciation_months > 0)` |
| 14 | `class_schedule` | `class_id` | Lịch xếp các lớp học nhóm | `CHECK (end_time > start_time, current_enrolled <= max_capacity)` |
| 15 | `class_enrollment` | `enrollment_id` | Danh sách hội viên đăng ký lớp học nhóm | `UNIQUE(subscription_id, class_id)` |
| 16 | `pt_booking` | `booking_id` | Lịch hẹn ca tập HLV cá nhân 1-1 | `CHECK (end_time > start_time)` |
| 17 | `equipment_reservation`| `reservation_id` | Đăng ký giữ chỗ máy móc trước giờ tập | `CHECK (end_time > start_time, 1 trong 2 nguồn FK)` |
| 18 | `maintenance_log` | `maintenance_id` | Nhật ký sửa chữa, bảo dưỡng thiết bị | `CHECK (cost >= 0, end_time >= start_time)` |

---

## 🔍 Danh Sách 10 Truy Vấn Nâng Cao (Complex Queries)

Tất cả các truy vấn đều được kiểm thử trên PostgreSQL 16 và tích hợp trực quan hóa trên giao diện Web:

1. **Thống kê doanh thu theo từng gói tập trong quý:** Sử dụng `JOIN 3 bảng`, `GROUP BY`, `SUM` và hàm `date_trunc('quarter', payment_date)`.
2. **Top 3 HLV có tổng số giờ dạy nhiều nhất trong tháng:** Hợp nhất giờ dạy lớp nhóm và PT 1-1 qua `UNION ALL` trong CTE, `EXTRACT(EPOCH)`, `HAVING`, `ORDER BY LIMIT 3`.
3. **Danh sách hội viên có gói tập sắp hết hạn trong 7 ngày tới:** Ứng dụng `WHERE`, `CURRENT_TIMESTAMP + INTERVAL '7 days'` phục vụ chiến dịch chăm sóc khách hàng.
4. **Thiết bị đang bảo trì kèm Kỹ thuật viên & Tổng chi phí:** `JOIN 4 bảng`, kết hợp Scalar Subquery tính tổng chi phí bảo trì lịch sử.
5. **Tỷ lệ lấp đầy (Fill Rate) của các Lớp học nhóm:** Tính toán `(current_enrolled / max_capacity) * 100%` và phân loại tình trạng bằng `CASE WHEN`.
6. **Danh sách ca tập PT 1-1 bị hủy muộn hoặc bỏ tập (No-show):** Lọc theo `status IN ('Cancelled', 'Late_Cancelled', 'No_Show')` để áp dụng chế tài trừ buổi theo BR-25 (hủy muộn dưới 24 giờ và vắng mặt bị trừ buổi, hủy sớm thì không).
7. **Hội viên đã mua gói PT nhưng chưa từng đặt lịch buổi nào:** Kỹ thuật `LEFT JOIN ... WHERE pb.booking_id IS NULL` tìm khách hàng "ngủ đông".
8. **Phân nhóm hội viên theo độ tuổi & Gói tập ưa chuộng nhất:** Phân khúc nhân khẩu học qua `CASE WHEN`, xếp hạng gói tập bằng Window Function `DENSE_RANK() OVER (PARTITION BY age_bracket)`.
9. **Xếp hạng doanh thu đóng góp của Hội viên:** Xếp hạng khách hàng VIP qua Window Function `DENSE_RANK() OVER (ORDER BY SUM(amount) DESC)`.
10. **Phát hiện xung đột lịch tập (Overlapping Intervals) của HLV:** Tự kết nối (Self-Join) khoảng thời gian trong CTE để kiểm toán vi phạm trùng lịch (BR-12/BR-15). Vì các quy tắc này nay đã được CSDL cưỡng chế nên truy vấn được kỳ vọng trả về **0 dòng**.

---

## ⚡ Khung Nhìn (Views) & Bộ Kích Hoạt (Triggers)

### 1. Khung Nhìn (Views)
- **`vw_active_member_subscriptions`**: Cung cấp cái nhìn tức thời về các hội viên đang có hợp đồng Active, số buổi PT còn lại và số ngày hết hạn.
- **`vw_trainer_schedule_overview`**: Hợp nhất toàn bộ lịch trình công tác của HLV (Lớp nhóm + Ca PT cá nhân) theo trình tự thời gian.

### 2. Bộ Kích Hoạt (Triggers)
- **`trg_check_member_dob` (BR-03):** `BEFORE INSERT/UPDATE OF user_id` trên `member_profile` (hàm `trg_fn_check_user_age`): chặn tạo hồ sơ hội viên nếu tài khoản có ngày sinh chưa đủ 12 tuổi.
- **`trg_check_user_dob_for_member` (BR-03):** `BEFORE UPDATE OF dob` trên `user_account` (hàm `trg_fn_check_member_dob_update`): chặn sửa ngày sinh của một hội viên khiến họ xuống dưới 12 tuổi.
- **`trg_sync_class_enrollment_count` (BR-14):** `AFTER INSERT/UPDATE/DELETE` trên `class_enrollment` (hàm `fn_sync_class_enrollment_count`): tự động đồng bộ `class_schedule.current_enrolled` bằng số lượt đăng ký `Enrolled`/`Attended`.
- **`trg_update_remaining_pt_sessions` (BR-18, BR-25):** Tự động trừ 1 buổi tập trong `member_subscription` khi ca `pt_booking` chuyển sang `'Completed'`, `'No_Show'` hoặc `'Late_Cancelled'`. Nếu số buổi còn lại `<= 0`, trigger `RAISE EXCEPTION` chặn giao dịch.
- **`trg_check_pt_booking_creation` (BR-18):** `BEFORE INSERT` trên `pt_booking`: hợp đồng phải `Active`, giờ tập nằm trong thời hạn hợp đồng và số buổi còn lại phải lớn hơn số ca `Scheduled` đang chờ.
- **`trg_late_cancel_pt_booking` (BR-25):** `BEFORE UPDATE OF status` trên `pt_booking`: hủy ca `Scheduled` khi còn dưới 24 giờ được tự đổi thành `Late_Cancelled` (bị trừ 1 buổi); hủy sớm giữ `Cancelled`.
- **`trg_prevent_class_in_maintenance_room` (BR-19):** `BEFORE INSERT/UPDATE OF room_id` trên `class_schedule`: chặn xếp lịch lớp học vào Phòng tập đang `Under_Maintenance`.
- **`trg_prevent_room_maintenance_with_future_classes` / `trg_prevent_equipment_maintenance_with_future_reservations` (BR-19, chiều ngược):** `BEFORE UPDATE OF status` trên `facilities_room` / `equipment`: không cho chuyển phòng hay thiết bị sang `Under_Maintenance` khi còn lớp học sắp diễn ra hoặc lượt giữ chỗ `Reserved` trong tương lai (thông báo cho biết còn bao nhiêu lịch; nhân viên phải dời/hủy trước).
- **`trg_start_equipment_maintenance_insert/_update` và `trg_finish_equipment_maintenance` (BR-19):** `AFTER` trên `maintenance_log`: mở ca bảo trì `In_Progress` thì thiết bị tự chuyển `Under_Maintenance` (bị chặn nếu còn giữ chỗ tương lai); ca `Completed`/`Cancelled` và không còn ca đang sửa nào khác thì thiết bị tự về `Operational` (trừ `Decommissioned`). Nhờ đó trạng thái thiết bị luôn khớp nhật ký bảo trì.
- **`trg_prevent_equipment_reservation_under_maintenance` (BR-19, BR-21):** chặn giữ chỗ Máy tập đang `Under_Maintenance`; **`trg_check_reservation_window` (BR-21)** kiểm tra khung giờ giữ chỗ máy.
- **`trg_require_payment_before_active` / `trg_activate_on_payment_insert` / `_update` (BR-07):** hợp đồng chỉ được `Active` khi có hóa đơn `Completed`; ghi hóa đơn `Completed` sẽ tự chuyển hợp đồng `Pending` → `Active` (và xử lý gia hạn BR-24). Mỗi hội viên chỉ có 1 hợp đồng `Active` (BR-05, ràng buộc `uq_member_one_active_subscription`).
- **`trg_fill_billing_period_start` (BR-08)** và **`trg_billing_immutable_update/_delete/_truncate` (BR-10):** chu kỳ tính phí duy nhất cho mỗi hóa đơn; `billing_log` là sổ cái bất biến (cấm sửa/xóa/TRUNCATE). BR-10 có bốn lớp: trigger bất biến; chỉ cấp `SELECT, INSERT` (kể cả Admin); mọi đối tượng thuộc role `NOLOGIN` `gym_owner` (không tài khoản đăng nhập nào là chủ sở hữu); event trigger `evt_protect_billing_log`/`evt_protect_billing_log_drop` chặn `ALTER`/`DROP` `billing_log`, trigger và hàm bất biến, kể cả với superuser. Superuser vẫn bảo trì có chủ đích được bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'` (nạp lại `01`/`04` trên CSDL đã có event trigger cũng cần lối thoát này, xem mục chạy script bên dưới).
- **`trg_check_class_schedule_conflicts`, `trg_check_pt_booking_conflicts`, `trg_check_class_enrollment_conflicts` (BR-12, BR-15, BR-16):** chặn trùng lịch giữa lớp nhóm, ca PT và đăng ký lớp của cùng HLV/hội viên (bổ trợ cho các `EXCLUDE` constraint trong DDL).
- **`trg_fill_created_by` / `trg_set_updated_by` (BR-23):** trên 5 bảng giao dịch (`member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log`): `BEFORE INSERT` điền `created_by_user_id` (`NOT NULL`) từ biến phiên `app.current_user_id` và **từ chối** nếu biến chưa đặt; `BEFORE UPDATE` luôn ghi `updated_by_user_id`/`updated_at` và cấm đổi `created_by_user_id`. Ứng dụng đặt biến bằng `SET LOCAL` trong từng giao dịch.

### 3. Thủ tục gia hạn tự động (BR-24)
PostgreSQL không có bộ lập lịch tích hợp nên quy tắc theo thời gian được cài thành thủ tục `sp_process_subscription_renewals(p_as_of, p_grace_days)` (idempotent): hợp đồng không tự gia hạn quá hạn → `Expired`; hợp đồng tự gia hạn quá hạn → phát hành hóa đơn `Pending` cho chu kỳ kế tiếp; quá thời gian ân hạn (mặc định 3 ngày) mà chưa thanh toán → `Suspended`. Khi hóa đơn được thanh toán, trigger BR-07 gia hạn `end_time` và kích hoạt lại hợp đồng. Chạy hằng ngày bằng cron (hoặc `pg_cron`):

Trong Docker demo, service `scheduler` (container `fitzone_renewal_scheduler`) tự gọi thủ tục này khi khởi động và mỗi `RENEWAL_INTERVAL_SECONDS` giây. Với production, dùng `pg_cron` hoặc cron của hệ điều hành:

```bash
# crontab (00:05 mỗi ngày)
5 0 * * * docker exec fitzone_postgres_db psql -U gym_u_admin -d gym_management -c "CALL sp_process_subscription_renewals();"
# hoặc: SELECT cron.schedule('gym-renewals', '5 0 * * *', 'CALL sp_process_subscription_renewals()');
```

> Các hàm trigger đều được khai báo `SECURITY DEFINER` (trong `Phase 3/08_rbac_security.sql`) để trigger vẫn chạy đúng khi thao tác được thực hiện bởi các role bị hạn chế quyền.

---

## 🖥️ Tính Năng Ứng Dụng Web (Streamlit UI - Phase 4)

1. **Dashboard & KPIs:** Giám sát thời gian thực tổng hội viên, hợp đồng active, doanh thu và thiết bị bảo trì; tra cứu tương tác trên 2 Views.
2. **Quản Lý Hội Viên & Gói Tập (CRUD):** Tiếp nhận hội viên mới (kiểm tra tuổi tự động), quản lý hồ sơ bệnh án; ký hợp đồng tạo ở trạng thái `Pending`, ghi hóa đơn `Completed` để trigger BR-07 tự kích hoạt thành `Active` và hiển thị trạng thái kết quả; nút **Gia hạn tự động (BR-24)** gọi `sp_process_subscription_renewals()` và hiển thị số liệu trước/sau (có chế độ chạy thử ROLLBACK).
3. **Lập Lịch Thông Minh:** Đặt ca tập PT 1-1 (báo lỗi rõ ràng theo BR-18: hợp đồng không Active, ngoài thời hạn, hết buổi), nút **Hủy ca** cho ca `Scheduled` (≥ 24 giờ → `Cancelled`; < 24 giờ → `Late_Cancelled` và trừ 1 buổi, BR-25) và xếp lịch lớp nhóm có kiểm tra phòng bảo trì/trùng lịch.
4. **Complex Queries Playground:** Chọn và thực thi từng câu truy vấn trong số 10 câu nâng cao, hiển thị mã SQL, bảng dữ liệu và biểu đồ Plotly tương tác.
5. **Trigger Test Bench:** Môi trường thử nghiệm trực quan tương tác cho phép giảng viên/hội đồng kiểm tra trực tiếp phản ứng tự vệ của CSDL khi kích hoạt các Triggers.
6. **Người thao tác (BR-23):** Ô chọn *Người thao tác* ở thanh bên (nhân viên/quản trị từ `user_account` ⨝ `user_role`); mỗi giao dịch ghi dữ liệu chạy `SET LOCAL app.current_user_id` để cột `created_by_user_id` được điền tự động. Mọi phép thử/demo không cần lưu đều `ROLLBACK`.

