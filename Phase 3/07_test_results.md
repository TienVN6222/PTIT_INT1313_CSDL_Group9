# Kết quả Kiểm thử Cơ sở Dữ liệu (Mục 4.2, 5.1 & 5.2 của Báo cáo)

> **Môi trường kiểm thử:** PostgreSQL 16 (image `postgres:16-alpine`), nạp lần lượt `01_schema_ddl.sql` → `02_mock_data/01..08` → `04_triggers_views.sql` → `08_rbac_security.sql` (khi kiểm thử phân quyền).
> **Ngày chạy:** 16/11/2026.
> **Script:** [`05_constraint_test_cases.sql`](05_constraint_test_cases.sql) (mục 5.1, 109 test), [`06_performance_test_cases.sql`](06_performance_test_cases.sql) (mục 4.2, 8 test) và [`09_rbac_test_cases.sql`](09_rbac_test_cases.sql) (mục 5.2, 66 test). Cả ba script đều được bọc trong `BEGIN ... ROLLBACK` nên **không làm thay đổi dữ liệu mẫu**.
> **Người thực hiện (BR-23):** mọi thao tác ghi vào 5 bảng giao dịch cần `app.current_user_id`; các script test tự đặt biến này ở đầu tập tin. Khi chạy SQL thủ công, hãy `SET app.current_user_id = '<user_id>';` trước, nếu không CSDL từ chối (lỗi `P0001`, `BR-23`) theo thiết kế.
> **Nạp lại trên CSDL đã có (BR-10):** Bản nạp lại (01 `DROP` `billing_log`, 04 `DROP`/`CREATE` trigger và hàm bất biến) bị event trigger BR-10 chặn, kể cả với superuser. Cách đơn giản nhất là tạo CSDL mới (`docker compose down -v` rồi `docker compose up --build`). Nếu muốn nạp lại tại chỗ, superuser đặt lối thoát trong cùng phiên `psql` (`SET app.allow_billing_maintenance = 'on';` trước khi `\i` các tập tin) hoặc tắt event trigger bằng hai lệnh riêng `ALTER EVENT TRIGGER evt_protect_billing_log DISABLE;` và `ALTER EVENT TRIGGER evt_protect_billing_log_drop DISABLE;`, sau đó nạp lại 08 để tạo lại chúng. Script 06 tự đặt lối thoát này cho bước nạp dữ liệu hàng loạt.
> **Dữ liệu mẫu tương đối theo ngày nạp:** các mốc thời gian trong `02_mock_data` được tính từ `CURRENT_DATE`/`CURRENT_TIMESTAMP` lúc nạp, nên các truy vấn "tháng này/quý này" luôn có dữ liệu. Các bảng kết quả dưới đây được sinh trực tiếp từ đầu ra `psql` thực tế; giá trị tuyệt đối của ngày giờ trong thông báo lỗi sẽ thay đổi theo ngày chạy, còn mã test, SQLSTATE và kết quả thì không.

Cách chạy lại (sau khi CSDL đã được khởi tạo bằng các tập tin nạp ở trên):

```bash
# Cách 1: psql trực tiếp (chạy bằng superuser để thử cả các quy tắc bất biến, ví dụ BR-10)
psql -U gym_admin -d gym_management -f "Phase 3/05_constraint_test_cases.sql"
psql -U gym_admin -d gym_management -f "Phase 3/06_performance_test_cases.sql"
psql -U gym_admin -d gym_management -f "Phase 3/09_rbac_test_cases.sql"

# Cách 2: qua Docker Compose (thư mục Phase 3 được gắn chỉ-đọc tại /sql trong container)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/05_constraint_test_cases.sql
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/06_performance_test_cases.sql
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/09_rbac_test_cases.sql
```

---

## 5.1. Kiểm thử ràng buộc ngăn chặn dữ liệu sai (Constraint Test Cases)

### Phương pháp

- **Negative test (TC-xx):** cố tình thực hiện thao tác vi phạm quy tắc nghiệp vụ. Test **PASS** khi CSDL từ chối thao tác với **đúng mã lỗi SQLSTATE** mong đợi **và** thông báo lỗi chứa đúng đoạn văn bản mong đợi (thường là tên ràng buộc/trigger hoặc mã `BR-xx`). Nhờ kiểm tra thêm thông báo, một test không thể "đạt nhầm" vì bị chặn bởi một quy tắc khác có cùng SQLSTATE.
- **Positive test (TP-xx):** thao tác hợp lệ phải được chấp nhận và các trigger phải cập nhật dữ liệu dẫn xuất chính xác (câu kiểm tra kết quả chạy sau thao tác).
- Mỗi test chạy trong một savepoint riêng (khối `BEGIN ... EXCEPTION` của PL/pgSQL) và luôn được hoàn tác, nên các test độc lập với nhau.
- **Không viết cứng ngày lịch:** mọi sự kiện thử nghiệm (lớp, ca PT, giữ chỗ, bảo trì) được tạo trong "khung giờ ban đêm" 21:00–23:59 của N ngày tới, tính từ `CURRENT_TIMESTAMP` (`DATE_TRUNC('day', CURRENT_TIMESTAMP) + N ngày + giờ`). Dữ liệu mẫu cam kết không có sự kiện nào trong khung giờ này nên test không đụng lịch có sẵn. Kịch bản hủy muộn (< 24 giờ, BR-25) dùng khung 21:00 kế tiếp cách hiện tại hơn 1 giờ, tính bằng SQL. Quy tắc thời gian BR-24 được kiểm thử bằng cách truyền ngày giả `p_as_of` vào thủ tục `sp_process_subscription_renewals`.

| SQLSTATE | Ý nghĩa | Cơ chế thực thi |
|---|---|---|
| `23502` | not_null_violation | `NOT NULL` |
| `23503` | foreign_key_violation | `FOREIGN KEY ... ON DELETE RESTRICT` |
| `23505` | unique_violation | `PRIMARY KEY`, `UNIQUE` (kể cả chỉ mục duy nhất có điều kiện) |
| `23514` | check_violation | `CHECK` |
| `23P01` | exclusion_violation | `EXCLUDE USING gist` (chống trùng khoảng thời gian) |
| `P0001` | raise_exception | Trigger PL/pgSQL chủ động `RAISE EXCEPTION` |

### Kết quả: 109/109 test PASS (74 negative TC + 35 positive TP)

| Mã | Quy tắc | Kịch bản | SQLSTATE mong đợi | SQLSTATE thực tế | Kết quả | Thông báo của CSDL |
|---|---|---|---|---|---|---|
| TC-01 | BR-02 | Tạo tài khoản trùng email đã tồn tại (uq_user_account_email) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_user_account_email" |
| TC-02 | BR-02 | Tạo tài khoản trùng số điện thoại đã tồn tại (uq_user_account_phone) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_user_account_phone" |
| TC-03 | BR-02 | Tạo tài khoản thiếu email (NOT NULL) | 23502 | 23502 | PASS | null value in column "email" of relation "user_account" violates not-null constraint |
| TC-04 | BR-03 | Đăng ký hồ sơ hội viên cho người dưới 12 tuổi (trg_check_member_dob) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-03: Hội viên phải đủ 12 tuổi trở lên (Ngày sinh: 2021-11-16) |
| TC-05 | BR-03 | Sửa ngày sinh của hội viên hiện có thành dưới 12 tuổi (trg_check_user_dob_for_member) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-03: Hội viên phải đủ 12 tuổi trở lên (Ngày sinh: 2021-11-16) |
| TC-06 | BR-22 | Gán trạng thái tài khoản ngoài miền giá trị (chk_user_account_status) | 23514 | 23514 | PASS | new row for relation "user_account" violates check constraint "chk_user_account_status" |
| TC-07 | BR-11 | Điểm đánh giá HLV vượt quá 5.00 (chk_trainer_rating) | 23514 | 23514 | PASS | new row for relation "trainer_profile" violates check constraint "chk_trainer_rating" |
| TC-08 | BR-22 | Gán cùng một vai trò hai lần cho một người dùng (pk_user_role) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "pk_user_role" |
| TC-09 | BR-04 | Tạo gói tập có thời hạn 0 ngày (chk_membership_plan_duration) | 23514 | 23514 | PASS | new row for relation "membership_plan" violates check constraint "chk_membership_plan_duration" |
| TC-10 | BR-04 | Tạo gói tập có giá âm (chk_membership_plan_price) | 23514 | 23514 | PASS | new row for relation "membership_plan" violates check constraint "chk_membership_plan_price" |
| TC-11 | BR-06 | Hợp đồng có ngày kết thúc trước ngày bắt đầu (chk_subscription_dates) | 23514 | 23514 | PASS | new row for relation "member_subscription" violates check constraint "chk_subscription_dates" |
| TC-12 | BR-01 | Ký hợp đồng cho người không có hồ sơ hội viên (HLV ID 5) (fk_subscription_member) | 23503 | 23503 | PASS | insert or update on table "member_subscription" violates foreign key constraint "fk_subscription_member" |
| TC-13 | BR-18 | Số buổi PT còn lại bị âm (chk_subscription_remaining) | 23514 | 23514 | PASS | new row for relation "member_subscription" violates check constraint "chk_subscription_remaining" |
| TC-14 | BR-09 | Phát hành hóa đơn trùng số invoice_no (uq_billing_invoice_no) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_billing_invoice_no" |
| TC-15 | BR-09 | Hóa đơn có số tiền bằng 0 (chk_billing_amount) | 23514 | 23514 | PASS | new row for relation "billing_log" violates check constraint "chk_billing_amount" |
| TC-16 | BR-09 | Phương thức thanh toán không hợp lệ (chk_billing_method) | 23514 | 23514 | PASS | new row for relation "billing_log" violates check constraint "chk_billing_method" |
| TC-17 | BR-10 | Xóa hợp đồng đã phát sinh hóa đơn (fk_billing_subscription, ON DELETE RESTRICT) | 23503 | 23503 | PASS | update or delete on table "member_subscription" violates foreign key constraint "fk_billing_subscription" on table "billing_log" |
| TC-18 | BR-04 | Xóa gói tập đang được hợp đồng sử dụng (fk_subscription_plan) | 23503 | 23503 | PASS | update or delete on table "membership_plan" violates foreign key constraint "fk_subscription_plan" on table "member_subscription" |
| TC-19 | BR-13 | Phòng tập có sức chứa bằng 0 (chk_facilities_capacity) | 23514 | 23514 | PASS | new row for relation "facilities_room" violates check constraint "chk_facilities_capacity" |
| TC-20 | BR-17 | Lớp học có giờ kết thúc bằng giờ bắt đầu (chk_class_time) | 23514 | 23514 | PASS | new row for relation "class_schedule" violates check constraint "chk_class_time" |
| TC-21 | BR-15 | Xếp 2 lớp trùng giờ trong cùng một phòng (ex_class_room_no_overlap) | 23P01 | 23P01 | PASS | conflicting key value violates exclusion constraint "ex_class_room_no_overlap" |
| TC-22 | BR-12 | Một HLV dạy 2 lớp trùng giờ ở 2 phòng khác nhau (ex_class_trainer_no_overlap) | 23P01 | 23P01 | PASS | conflicting key value violates exclusion constraint "ex_class_trainer_no_overlap" |
| TC-23 | BR-19 | Xếp lớp vào phòng đang bảo trì, phòng ID 6 (trg_prevent_class_in_maintenance_room) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-19: Phòng tập "Octagon Combat & Boxing Ring" (ID: 6) hiện đang ở trạng thái BẢO TRÌ (Under_Maintenance). Không thể xếp lịch |
| TC-24 | BR-14 | Đăng ký thêm hội viên vào lớp đã đầy, lớp ID 1: 20/20 (chk_class_enrollment_limit) | 23514 | 23514 | PASS | new row for relation "class_schedule" violates check constraint "chk_class_enrollment_limit" |
| TC-25 | BR-14 | Một hợp đồng đăng ký lại cùng một lớp sau khi hủy (uq_enrollment_subscription_class) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_enrollment_subscription_class" |
| TC-26 | BR-17 | Ca PT có giờ kết thúc bằng giờ bắt đầu (chk_pt_booking_time) | 23514 | 23514 | PASS | new row for relation "pt_booking" violates check constraint "chk_pt_booking_time" |
| TC-27 | BR-12 | Một HLV nhận 2 ca PT trùng giờ với 2 hội viên (ex_pt_trainer_no_overlap) | 23P01 | 23P01 | PASS | conflicting key value violates exclusion constraint "ex_pt_trainer_no_overlap" |
| TC-28 | BR-16 | Một hội viên đặt 2 ca PT trùng giờ với 2 HLV (ex_pt_member_no_overlap) | 23P01 | 23P01 | PASS | conflicting key value violates exclusion constraint "ex_pt_member_no_overlap" |
| TC-29 | BR-18 | Đặt ca PT bằng hợp đồng của hội viên khác (fk_booking_subscription_member) | 23503 | 23503 | PASS | insert or update on table "pt_booking" violates foreign key constraint "fk_booking_subscription_member" |
| TC-30 | BR-18 | Hoàn thành ca PT khi hợp đồng đã hết buổi (trg_update_remaining_pt_sessions) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-18: Hợp đồng ID: 1 đã hết số buổi tập PT khả dụng (Còn lại: 0 buổi) |
| TC-31 | BR-25 | Trạng thái ca PT ngoài miền giá trị (chk_pt_booking_status) | 23514 | 23514 | PASS | new row for relation "pt_booking" violates check constraint "chk_pt_booking_status" |
| TC-32 | BR-26 | Thiết bị có thời gian khấu hao 0 tháng (chk_equipment_depreciation) | 23514 | 23514 | PASS | new row for relation "equipment" violates check constraint "chk_equipment_depreciation" |
| TC-33 | BR-26 | Thiết bị trùng số serial (uq_equipment_serial) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_equipment_serial" |
| TC-34 | BR-19 | Giữ chỗ thiết bị đang bảo trì - cột status (trg_prevent_equipment_reservation_under_maintenance) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-19: Thiết bị "Máy chạy bộ Technogym Skillrun 7000" (ID: 1) hiện đang BẢO TRÌ (Under_Maintenance). Không thể tạo lịch giữ ch |
| TC-35 | BR-21 | Lượt giữ chỗ gắn đồng thời cả ca PT và lớp học (chk_reservation_source) | 23514 | 23514 | PASS | new row for relation "equipment_reservation" violates check constraint "chk_reservation_source" |
| TC-36 | BR-21 | Lượt giữ chỗ không gắn với ca PT hay lớp học nào (chk_reservation_source) | 23514 | 23514 | PASS | new row for relation "equipment_reservation" violates check constraint "chk_reservation_source" |
| TC-37 | BR-20 | Nhật ký bảo trì có chi phí âm (chk_maintenance_cost) | 23514 | 23514 | PASS | new row for relation "maintenance_log" violates check constraint "chk_maintenance_cost" |
| TC-38 | BR-20 | Nhật ký bảo trì hoàn thành trước khi bắt đầu (chk_maintenance_time) | 23514 | 23514 | PASS | new row for relation "maintenance_log" violates check constraint "chk_maintenance_time" |
| TC-39 | BR-20 | Giao việc bảo trì cho người không phải nhân viên, HLV ID 5 (fk_maintenance_staff) | 23503 | 23503 | PASS | insert or update on table "maintenance_log" violates foreign key constraint "fk_maintenance_staff" |
| TP-01 | BR-03 | Hội viên đủ 18 tuổi được tạo hồ sơ thành công | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-02 | BR-18 | Hoàn thành ca PT tự động trừ đúng 1 buổi (hợp đồng ID 1: n -> n-1) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-03 | BR-14 | Đăng ký lớp tự động tăng current_enrolled (lớp ID 2: 16 -> 17) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-04 | BR-14 | Hủy đăng ký lớp tự động giảm current_enrolled (lớp ID 1: 20 -> 19) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-05 | BR-12 | Ca PT đã hủy không chặn ca mới cùng khung giờ (exclusion có điều kiện) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-06 | BR-15 | Hai lớp nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) không bị coi là trùng | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-07 | BR-09 | Hóa đơn hợp lệ ở chu kỳ tính phí mới được ghi nhận | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-40 | BR-05 | Hội viên đang Active có thêm hợp đồng Active thứ hai (uq_member_one_active_subscription) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_member_one_active_subscription" |
| TC-41 | BR-07 | Tạo hợp đồng Active trực tiếp khi chưa có hóa đơn Completed (trg_require_payment_before_active) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-07: Hợp đồng ID: 36 chưa có hóa đơn thanh toán Completed nên chưa thể chuyển sang Active |
| TC-42 | BR-07 | Chuyển hợp đồng sang Active khi mới có hóa đơn Pending, chưa Completed (trg_require_payment_before_active) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-07: Hợp đồng ID: 37 chưa có hóa đơn thanh toán Completed nên chưa thể chuyển sang Active |
| TC-43 | BR-08 | Hai hóa đơn còn hiệu lực cho cùng một chu kỳ của một hợp đồng (uq_billing_subscription_period) | 23505 | 23505 | PASS | duplicate key value violates unique constraint "uq_billing_subscription_period" |
| TP-08 | BR-07 | Hợp đồng Pending + hóa đơn Completed -> tự động Active (trg_activate_on_payment_insert) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-09 | BR-05 | Hợp đồng cũ chuyển Expired thì hội viên được kích hoạt hợp đồng mới (chỉ còn 1 Active) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-10 | BR-08 | Hóa đơn Failed không chiếm chu kỳ: thanh toán lại (Completed) cùng chu kỳ được chấp nhận | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-11 | BR-08 | INSERT hóa đơn không nêu chu kỳ: trg_fill_billing_period_start điền ngày bắt đầu hợp đồng | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-44 | BR-10 | Sửa số tiền hóa đơn Completed có sẵn (trg_billing_immutable_update) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Hóa đơn INV-20261006-001 đã Completed là dữ liệu bất biến; chỉ được chuyển sang Refunded và không được đổi cột nào khác |
| TC-45 | BR-10 | Xóa hóa đơn Completed có sẵn (trg_billing_immutable_delete) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được xóa hóa đơn INV-20261006-001 (nhật ký thanh toán bất biến); hãy chuyển sang Refunded nếu cần hoàn tiền |
| TC-46 | BR-10 | TRUNCATE bảng billing_log (trg_billing_immutable_truncate) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được TRUNCATE bảng billing_log (nhật ký thanh toán bất biến) |
| TC-47 | BR-10 | Đổi hóa đơn Completed sang Failed - chỉ được sang Refunded (trg_billing_immutable_update) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Hóa đơn INV-T05-43-11 đã Completed là dữ liệu bất biến; chỉ được chuyển sang Refunded và không được đổi cột nào khác |
| TC-48 | BR-10 | Hóa đơn Pending bị đổi mã invoice_no (trg_billing_immutable_update) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Hóa đơn INV-T05-44-12 đang Pending chỉ được chuyển sang Completed/Failed và không được đổi mã hóa đơn, hợp đồng, chu kỳ |
| TC-49 | BR-10 | Sửa hóa đơn đã ở trạng thái cuối Refunded (trg_billing_immutable_update) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Hóa đơn INV-T05-45-13 ở trạng thái cuối (Refunded) không được phép sửa đổi |
| TP-12 | BR-10 | Phiên kiểm thử chạy bằng superuser (chứng minh BR-10 không dựa vào phân quyền) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-13 | BR-10 | Hóa đơn Completed chuyển sang Refunded được phép (hoàn tiền) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-14 | BR-10 | Hóa đơn Pending chuyển sang Completed được phép và kích hoạt hợp đồng Pending | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-50 | BR-12 | HLV đã có ca PT, xếp thêm lớp nhóm trùng giờ cho chính HLV đó (trg_check_class_schedule_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-12: HLV ID: 5 đã có ca PT #49 trùng khung giờ 2026-11-27 21:30:00 -> 2026-11-27 22:30:00 của lớp "T05-HLV-TRUNG-PT" |
| TC-51 | BR-12 | HLV đang đứng lớp nhóm, nhận thêm ca PT trùng giờ (trg_check_pt_booking_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-12: HLV ID: 5 đã đứng lớp ID: 31 trùng khung giờ 2026-11-28 21:30:00 -> 2026-11-28 22:30:00 của ca PT |
| TC-52 | BR-16 | Hội viên đã đăng ký lớp nhóm, đặt thêm ca PT trùng giờ lớp đó (trg_check_pt_booking_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-16: Hội viên ID: 11 đã đăng ký lớp ID: 32 trùng khung giờ 2026-11-29 21:30:00 -> 2026-11-29 22:30:00 của ca PT |
| TC-53 | BR-16 | Hội viên đã có ca PT, đăng ký lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-16: Hội viên ID: 11 đã có ca PT #52 trùng khung giờ lớp ID: 33 (2026-11-30 21:30:00 -> 2026-11-30 22:30:00) |
| TC-54 | BR-16 | Hội viên đăng ký 2 lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-16: Hội viên ID: 11 đã đăng ký lớp ID: 34 trùng khung giờ lớp ID: 35 (2026-12-01 21:30:00 -> 2026-12-01 22:30:00) |
| TC-55 | BR-16 | Đổi giờ lớp đã có người đăng ký sang giờ trùng ca PT của hội viên đó (trg_check_class_schedule_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-16: Đổi giờ lớp ID: 36 làm hội viên ID: 11 bị trùng lịch với ca PT/lớp khác của họ |
| TC-68 | BR-16 | Đăng ký lần 2 cùng lớp khi đang Enrolled bị chặn bởi trigger BR-16 (trg_check_class_enrollment_conflicts) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-16: Hội viên ID: 11 đã đăng ký lớp ID: 37 trùng khung giờ lớp ID: 37 (2026-12-03 21:00:00 -> 2026-12-03 22:00:00) |
| TP-15 | BR-16 | Lớp nhóm và ca PT nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) của cùng hội viên được chấp nhận | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-56 | BR-18 | Đặt ca PT bằng hợp đồng chưa Active (Pending) (trg_check_pt_booking_creation) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-18: Hợp đồng ID: 48 đang ở trạng thái Pending (không phải Active) nên không thể đặt ca PT |
| TC-57 | BR-18 | Đặt ca PT sau ngày hết hạn hợp đồng (trg_check_pt_booking_creation) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-18: Giờ tập 2027-06-04 21:00:00 nằm ngoài thời hạn hợp đồng ID: 1 (2026-10-06 08:00:00 -> 2027-01-04 22:00:00) |
| TC-58 | BR-18 | Đặt ca PT trước ngày bắt đầu hợp đồng (trg_check_pt_booking_creation) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-18: Giờ tập 2025-10-12 21:00:00 nằm ngoài thời hạn hợp đồng ID: 1 (2026-10-06 08:00:00 -> 2027-01-04 22:00:00) |
| TC-59 | BR-18 | Số ca PT Scheduled vượt số buổi còn lại của hợp đồng (trg_check_pt_booking_creation) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-18: Hợp đồng ID: 1 còn 3 buổi PT nhưng đã có 3 ca đang chờ; không thể đặt thêm |
| TC-60 | BR-18 | Đặt ca PT bằng hợp đồng gói không có buổi PT (hợp đồng ID 2, 0 buổi) (trg_check_pt_booking_creation) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-18: Hợp đồng ID: 2 còn 0 buổi PT nhưng đã có 0 ca đang chờ; không thể đặt thêm |
| TP-16 | BR-18 | Còn đúng 1 buổi chưa đặt thì được đặt thêm 1 ca Scheduled | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-61 | BR-21 | Một thiết bị bị giữ chỗ trùng giờ cho 2 ca PT khác nhau (ex_reservation_equipment_no_overlap) | 23P01 | 23P01 | PASS | conflicting key value violates exclusion constraint "ex_reservation_equipment_no_overlap" |
| TC-62 | BR-21 | Giữ chỗ thiết bị trong lúc có ca bảo trì In_Progress chưa kết thúc (trg_check_reservation_window) | 23P01 | 23P01 | PASS | Lỗi nghiệp vụ BR-21: Thiết bị ID: 2 đang trong ca bảo trì #16 (In_Progress) trùng khung giờ giữ chỗ 2026-12-08 21:00:00 -> 2026-12-08 22:00: |
| TC-63 | BR-21 | Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của ca PT gắn kèm (trg_check_reservation_window) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-21: Giờ giữ chỗ thiết bị 2026-12-09 20:30:00 -> 2026-12-09 22:00:00 vượt ra ngoài khung giờ của ca/lớp gắn kèm (2026-12-09  |
| TC-64 | BR-21 | Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của lớp học gắn kèm (trg_check_reservation_window) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-21: Giờ giữ chỗ thiết bị 2026-12-10 21:00:00 -> 2026-12-10 22:30:00 vượt ra ngoài khung giờ của ca/lớp gắn kèm (2026-12-10  |
| TP-17 | BR-21 | Giữ chỗ thiết bị nằm trọn trong khung giờ ca PT được chấp nhận | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-18 | BR-21 | Lượt giữ chỗ đã Cancelled không chiếm thiết bị: giữ chỗ mới cùng giờ được chấp nhận | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-19 | BR-21 | Ca bảo trì đã Completed không chặn giữ chỗ thiết bị | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-65 | BR-23 | Người thực hiện không tồn tại trong user_account (fk_booking_created_by) | 23503 | 23503 | PASS | insert or update on table "pt_booking" violates foreign key constraint "fk_booking_created_by" |
| TP-20 | BR-23 | created_by_user_id tự điền từ SET LOCAL app.current_user_id cho 5 bảng giao dịch | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-21 | BR-23 | Giá trị created_by_user_id nêu rõ trong INSERT không bị trigger ghi đè | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-72 | BR-23 | INSERT khi chưa đặt app.current_user_id (và không nêu created_by_user_id) bị chặn | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-23: Thao tác tạo dữ liệu trên pt_booking phải gắn với người dùng thực hiện (đặt app.current_user_id hoặc nêu created_by_use |
| TC-73 | BR-23 | UPDATE khi chưa đặt app.current_user_id bị chặn (không có người sửa để ghi updated_by_user_id) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-23: Thao tác sửa dữ liệu trên class_schedule phải gắn với người dùng thực hiện (chưa đặt app.current_user_id) |
| TC-74 | BR-23 | Không được đổi created_by_user_id sau khi đã ghi (vết người tạo bất biến) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-23: Không được đổi created_by_user_id của class_schedule |
| TP-22 | BR-23 | UPDATE tự ghi updated_by_user_id (từ biến phiên, không tin giá trị truyền vào) và updated_at | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-35 | BR-23 | UPDATE nội bộ do trigger (BR-07 tự kích hoạt hợp đồng khi thanh toán) ghi người thao tác hiện tại vào updated_by_user_id | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-66 | BR-24 | Gọi thủ tục với số ngày ân hạn âm (sp_process_subscription_renewals) | P0001 | P0001 | PASS | p_grace_days phải >= 0 (nhận được: -1) |
| TP-23 | BR-24 | Quá hạn: HĐ không tự gia hạn -> Expired; HĐ tự gia hạn -> hóa đơn Pending kỳ kế tiếp, vẫn Active trong ân hạn | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-24 | BR-24 | Gọi thủ tục nhiều lần trong ngày không phát sinh thêm hóa đơn gia hạn (idempotent) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-25 | BR-24 | Quá thời gian ân hạn (3 ngày) mà chưa thanh toán -> hợp đồng tự gia hạn chuyển Suspended | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-26 | BR-24 | Thanh toán hóa đơn gia hạn: hợp đồng Suspended -> Active, end_time + duration_days, đặt lại số buổi PT | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-67 | BR-25 | Ngày đặt lịch booking_date khác ngày của start_time (chk_pt_booking_date) | 23514 | 23514 | PASS | new row for relation "pt_booking" violates check constraint "chk_pt_booking_date" |
| TP-27 | BR-25 | Hủy sớm (> 24 giờ): ca giữ trạng thái Cancelled và KHÔNG trừ buổi (trg_late_cancel_pt_booking) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-28 | BR-25 | Hủy muộn (< 24 giờ): trigger đổi thành Late_Cancelled và trừ đúng 1 buổi | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-29 | BR-25 | Bỏ tập (No_Show) bị trừ đúng 1 buổi (trg_update_remaining_pt_sessions) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-30 | BR-25 | Đổi Completed -> No_Show không bị trừ buổi lần thứ hai | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TC-69 | BR-19 | Chuyển phòng sang bảo trì khi còn lớp học tương lai (trg_prevent_room_maintenance_with_future_classes) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-19: Phòng tập "T05 phong BR19" (ID: 8) còn 1 lớp học sắp diễn ra; hãy dời hoặc hủy các lớp này trước khi chuyển sang BẢO TR |
| TC-70 | BR-19 | Chuyển thiết bị sang bảo trì khi còn lượt giữ chỗ Reserved tương lai (trg_prevent_equipment_maintenance_with_future_reservations) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-19: Thiết bị "T05 thiet bi BR19" (ID: 203) còn 1 lượt giữ chỗ (Reserved) trong tương lai; hãy hủy hoặc chuyển các lượt này  |
| TC-71 | BR-19 | Mở ca bảo trì In_Progress cho thiết bị còn lượt giữ chỗ tương lai bị chặn (chuỗi trg_start_equipment_maintenance_insert -> BR-19) | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-19: Thiết bị "T05 thiet bi BR19" (ID: 204) còn 1 lượt giữ chỗ (Reserved) trong tương lai; hãy hủy hoặc chuyển các lượt này  |
| TP-31 | BR-19 | Phòng không còn lớp tương lai được chuyển sang bảo trì | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-32 | BR-19 | Chèn nhật ký bảo trì In_Progress tự chuyển thiết bị sang Under_Maintenance (trg_start_equipment_maintenance_insert) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-33 | BR-19 | Hoàn tất ca bảo trì duy nhất tự đưa thiết bị về Operational (trg_finish_equipment_maintenance) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-34 | BR-19 | Còn ca In_Progress khác thì hoàn tất 1 ca chưa đưa thiết bị về Operational; hoàn tất nốt mới về Operational | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |

Tổng: 109 test, đạt 109, không đạt 0.

### Mức độ thực thi các quy tắc nghiệp vụ

Bộ test ở trên bao phủ BR-01 … BR-26. Bảng dưới đối chiếu với mục "Tổng hợp mức độ thực thi" trong `Phase 1/business_rules.md`; tất cả quy tắc đều được thực thi ở CSDL; các lưu ý còn lại nêu ở cột cuối.

| Quy tắc | Mức độ | Giới hạn / điều kiện còn lại |
|---|---|---|
| BR-01 … BR-09, BR-11 … BR-21, BR-25, BR-26 | Đầy đủ ở CSDL | Thực thi bằng `CHECK`/`UNIQUE`/`EXCLUDE`/`FOREIGN KEY` và trigger; có test TC/TP tương ứng ở bảng trên. |
| BR-10 (hóa đơn bất biến) | Đầy đủ ở CSDL (bốn lớp) | (1) Trigger `trg_billing_immutable_update/_delete/_truncate` chặn mọi role (TC-44..TC-49, TP-12..TP-14); (2) chỉ cấp `SELECT, INSERT` trên `billing_log` (AD-01..AD-03); (3) mọi đối tượng thuộc role `NOLOGIN` `gym_owner` nên không tài khoản đăng nhập nào `ALTER`/`DROP` được (EV-07..EV-12); (4) event trigger `evt_protect_billing_log`/`_drop` chặn cả superuser (EV-01..EV-05, EV-13). Giới hạn cố hữu: superuser là gốc tin cậy, vẫn bảo trì có chủ đích được bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'` (EV-06); thao tác phải tường minh. |
| BR-19 (chặn khóa bảo trì) | Đầy đủ ở CSDL | Hai chiều: chặn xếp lịch mới vào phòng/thiết bị `Under_Maintenance` (TC-23, TC-34) và chặn chuyển phòng/thiết bị sang `Under_Maintenance` khi còn lớp / giữ chỗ `Reserved` tương lai (TC-69..TC-71); trạng thái thiết bị tự đồng bộ với `maintenance_log` (TP-31..TP-34; kỹ thuật viên chạy được trọn quy trình dưới role hạn chế, EA-03). |
| BR-22 (RBAC) | Đầy đủ ở mức CSDL | Bảng `role_permission` (ma trận quyền ứng dụng) và các lệnh `GRANT` trong `08_rbac_security.sql` vẫn được duy trì thủ công ở hai nơi, nhưng mọi sai lệch được phát hiện tự động bởi SY-01..SY-05 (chạy lại `09_rbac_test_cases.sql` sau khi đổi một trong hai nơi). |
| BR-23 (vết người thực hiện) | Đầy đủ ở CSDL | `created_by_user_id NOT NULL`, `updated_by_user_id`, `updated_at` và khóa ngoại trên 5 bảng; `trg_fill_created_by` từ chối `INSERT` khi chưa đặt `app.current_user_id` (TC-72), `trg_set_updated_by` ghi người sửa (TP-22, TP-35), từ chối `UPDATE` khi chưa đặt biến (TC-73) và cấm đổi `created_by_user_id` (TC-74). Mọi chương trình ghi dữ liệu phải đặt `app.current_user_id` (ứng dụng, bộ lập lịch qua `SCHEDULER_ACTOR_USER_ID`, script test); thủ công cần `SET app.current_user_id = '<id>'`. |
| BR-24 (tự động gia hạn/ân hạn) | Đầy đủ khi có bộ lập lịch ngoài | Logic nằm trong thủ tục `sp_process_subscription_renewals` (kiểm thử với ngày giả, TC-66, TP-23..TP-26). Docker demo có service `scheduler` (`fitzone_renewal_scheduler`) gọi thủ tục khi khởi động và mỗi `RENEWAL_INTERVAL_SECONDS` giây; production dùng `pg_cron`/cron. Nếu không có bộ lập lịch nào chạy thì quy tắc theo thời gian không tự kích hoạt. |

---

## 4.2. Kiểm thử hiệu năng & chỉ mục (Performance Test Cases)

### Yêu cầu phi chức năng được kiểm chứng

> **NFR-PERF-01:** Các truy vấn tra cứu/tìm kiếm phải trả kết quả dưới **200 ms** khi mỗi bảng nghiệp vụ có cỡ 100.000+ bản ghi.

### Phương pháp

1. Dữ liệu mẫu (khoảng 9.900 bản ghi, gồm 3.000 người dùng và 500 thiết bị) vẫn quá nhỏ để bộ tối ưu hóa chọn dùng chỉ mục. Script sinh tạm **100.000 tài khoản, 200.000 hóa đơn và 120.000 ca PT** bằng `generate_series()`, sau đó chạy `ANALYZE`.
2. Các trigger nghiệp vụ của người dùng trên `billing_log` và `pt_booking` (BR-08, BR-18, kiểm tra chồng lấn chéo bảng, điền `created_by_user_id`...) sẽ từ chối dữ liệu tổng hợp vì không gắn với hợp đồng/hội viên thực. Bài kiểm thử chỉ đo hiệu năng **đọc**, nên `ALTER TABLE ... DISABLE TRIGGER USER` chỉ được dùng **trong lúc nạp hàng loạt, bên trong giao dịch sẽ bị `ROLLBACK`**, và trigger được bật lại trước khi đo. Vì event trigger BR-10 chặn `ALTER TABLE ... billing_log`, script (chạy bằng superuser) trước đó đặt lối thoát bảo trì `SET LOCAL app.allow_billing_maintenance = 'on'` (chỉ hiệu lực trong giao dịch này); các bản ghi tổng hợp nêu rõ `created_by_user_id` vì cột `NOT NULL` vẫn có hiệu lực. Mọi ràng buộc `CHECK`/`UNIQUE`/`EXCLUDE`/`FOREIGN KEY` vẫn có hiệu lực suốt quá trình nạp.
3. Mỗi truy vấn được chạy `EXPLAIN (ANALYZE)` hai lần:
   - **(a) Có chỉ mục:** bộ tối ưu hóa chọn kế hoạch thực thi bình thường.
   - **(b) Không chỉ mục:** tắt `enable_indexscan`, `enable_bitmapscan`, `enable_indexonlyscan` để mô phỏng bảng không có chỉ mục (buộc phải `Seq Scan`).
4. Mỗi truy vấn được chạy làm nóng (warm-up) một lần trước khi đo. Toàn bộ dữ liệu sinh tạm bị `ROLLBACK` sau khi đo.
5. **PT-07:** điều kiện lọc trong truy vấn kiểm tra trùng lịch phải **khớp đúng** với điều kiện của chỉ mục GiST có điều kiện (`status NOT IN ('Cancelled', 'Late_Cancelled')`); nếu không khớp, bộ tối ưu hóa không thể dùng chỉ mục `ex_pt_trainer_no_overlap`.

> Thời gian tuyệt đối phụ thuộc cấu hình máy; điều cần quan sát là **loại phép quét** và **tỉ lệ chênh lệch** giữa (a) và (b).

### Kết quả: 8/8 test đạt NFR-PERF-01

| Mã | Truy vấn | Kế hoạch (a) có chỉ mục | (a) ms | Kế hoạch (b) không chỉ mục | (b) ms | Nhanh hơn | < 200 ms |
|---|---|---|---|---|---|---|---|
| PT-01 | Tra cứu tài khoản theo email khi đăng nhập | Index Scan (uq_user_account_email) | 0.037 | Seq Scan (user_account) | 14.119 | 381.6x | PASS |
| PT-02 | Tra cứu tài khoản theo số điện thoại | Index Scan (uq_user_account_phone) | 0.041 | Seq Scan (user_account) | 14.055 | 342.8x | PASS |
| PT-03 | Tổng doanh thu theo phương thức thanh toán trong 1 tuần | Bitmap Index Scan (idx_billing_log_payment_date) | 0.842 | Seq Scan (billing_log) | 33.374 | 39.6x | PASS |
| PT-04 | Lịch sử 20 hóa đơn gần nhất của một hợp đồng | Index Scan (idx_billing_log_subscription_date) | 0.058 | Seq Scan (billing_log) | 18.321 | 315.9x | PASS |
| PT-05 | Tra cứu một hóa đơn theo invoice_no | Index Scan (uq_billing_invoice_no) | 0.041 | Seq Scan (billing_log) | 26.713 | 651.5x | PASS |
| PT-06 | Lịch ca PT trong một ngày của một HLV | Index Scan (idx_pt_booking_dates) | 0.058 | Seq Scan (pt_booking) | 12.300 | 212.1x | PASS |
| PT-07 | Kiểm tra trùng lịch HLV bằng toán tử chồng lấn khoảng thời gian (&&) | Index Scan (ex_pt_trainer_no_overlap) | 0.055 | Seq Scan (pt_booking) | 13.619 | 247.6x | PASS |
| PT-08 | Truy vấn phức hợp Q1: doanh thu từng gói tập trong một quý (JOIN 3 bảng) | Bitmap Index Scan (idx_billing_log_payment_date) | 13.652 | Seq Scan (billing_log) | 41.440 | 3.0x | PASS |

### Kế hoạch thực thi minh họa

Kế hoạch chi tiết PT-01:
```
 Index Scan using uq_user_account_email on user_account (actual time=0.047..0.049 rows=1 loops=1)
   Index Cond: ((email)::text = 'perf_user_77777@perf.test'::text)
 Planning Time: 0.075 ms
 Execution Time: 0.073 ms
```
Kế hoạch chi tiết PT-07:
```
 Result (actual time=0.070..0.071 rows=1 loops=1)
   InitPlan 1 (returns $0)
     ->  Index Scan using ex_pt_trainer_no_overlap on pt_booking (actual time=0.069..0.069 rows=1 loops=1)
           Index Cond: ((trainer_user_id = 8) AND (tsrange(start_time, end_time, '[)'::text) && '["2032-03-15 10:30:00","2032-03-15 11:30:00")'::tsrange))
 Planning Time: 0.139 ms
 Execution Time: 0.091 ms
```

### Nhận xét

- Các truy vấn tra cứu điểm (PT-01, 02, 04, 05, 06, 07) đều dùng `Index Scan` và chạy dưới **0,1 ms**, nhanh hơn quét toàn bảng từ 212 đến 652 lần (xem cột "Nhanh hơn").
- **PT-04:** chỉ mục ghép `idx_billing_log_subscription_date (subscription_id, payment_date DESC)` đã được tạo trong `01_schema_ddl.sql`; bộ tối ưu hóa dùng đúng chỉ mục này, thay cho cách quét ngược `idx_billing_log_payment_date` rồi lọc như khi chưa có chỉ mục ghép.
- **PT-07:** chỉ mục GiST của ràng buộc `EXCLUDE` vừa bảo đảm toàn vẹn (BR-12) vừa tăng tốc truy vấn tìm khoảng thời gian chồng lấn.
- **PT-03 và PT-08:** mức cải thiện thấp hơn (40× và 3,0×) vì điều kiện lọc theo thời gian chọn ra một phần lớn của `billing_log`, nên phần lớn thời gian của PT-08 nằm ở phép `JOIN` và `GROUP BY` chứ không ở bước lọc.
- Bước sinh 120.000 ca PT chiếm phần lớn thời gian chạy script vì mỗi dòng phải qua 2 ràng buộc `EXCLUDE`; đây cũng là chi phí ghi của cơ chế chống trùng lịch.

---

## 5.2. Phân quyền truy cập theo vai trò (RBAC – GRANT/REVOKE)

> **Script:** [`08_rbac_security.sql`](08_rbac_security.sql) (tạo role, `GRANT`/`REVOKE`) và [`09_rbac_test_cases.sql`](09_rbac_test_cases.sql) (kiểm thử). Script 09 cũng được bọc trong `BEGIN ... ROLLBACK` nên không làm thay đổi dữ liệu.

Cách chạy (sau khi đã nạp `01` → `02_mock_data/01..08` → `04`):

```bash
psql -U <superuser> -d gym_management -v ON_ERROR_STOP=1 -f "Phase 3/08_rbac_security.sql"
psql -U <superuser> -d gym_management -f "Phase 3/09_rbac_test_cases.sql"

# hoặc qua Docker Compose
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -v ON_ERROR_STOP=1 -f /sql/08_rbac_security.sql
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/09_rbac_test_cases.sql
```

Script 08 chạy lại nhiều lần vẫn an toàn (idempotent): role là đối tượng toàn cụm nên đầu script dùng khối `DO` để `DROP OWNED BY` rồi `DROP ROLE` các role cũ trước khi tạo lại.

### Thiết kế

- Thu hồi mọi quyền của `PUBLIC` trên bảng, sequence và quyền `CREATE` trên schema `public` (nguyên tắc đặc quyền tối thiểu).
- Mọi đối tượng ứng dụng (bảng, view, sequence, hàm, thủ tục) thuộc role `NOLOGIN` `gym_owner`: không phải superuser, không tài khoản đăng nhập nào là chủ sở hữu hay thành viên của role này (BR-10, lớp 3).
- Event trigger `evt_protect_billing_log` (`ddl_command_end`) và `evt_protect_billing_log_drop` (`sql_drop`) chặn `ALTER TABLE`, `DROP TABLE`, `DROP`/`ALTER TRIGGER` trên `billing_log` và việc sửa/xóa các hàm trigger bất biến, kể cả với superuser (BR-10, lớp 4).
- 5 **role nhóm** (`NOLOGIN`) mô phỏng 5 vai trò ứng dụng; 5 **tài khoản đăng nhập mẫu** (mật khẩu `demo_2026`, chỉ dùng trình diễn) thừa hưởng `INHERIT` từ role nhóm. Ứng dụng Streamlit đăng nhập bằng `gym_u_admin` (không phải superuser), nên phân quyền có hiệu lực thật với ứng dụng.
- Cột nhạy cảm `user_account.password_hash` được bảo vệ bằng `GRANT` mức cột: không role nào được `SELECT`.
- Quyền `USAGE` trên sequence chỉ cấp cho role có quyền `INSERT` vào bảng tương ứng.
- Không cấp `TRUNCATE`/`TRIGGER`/`REFERENCES`; thủ tục `sp_process_subscription_renewals` (BR-24) đã `REVOKE EXECUTE ... FROM PUBLIC` và chỉ cấp cho Admin và Receptionist.

| Vai trò ứng dụng | Quyền ứng dụng (`role_permission`) | Role nhóm CSDL | Tài khoản mẫu |
|---|---|---|---|
| Admin | 1–10 (toàn bộ) | `gym_role_admin` | `gym_u_admin` |
| Receptionist | 1, 2, 3, 5, 6, 7 | `gym_role_receptionist` | `gym_u_reception` |
| Trainer | 1, 6, 7 | `gym_role_trainer` | `gym_u_trainer` |
| Technician | 8, 9 | `gym_role_technician` | `gym_u_tech` |
| Member | 1 (chỉ xem danh mục) | `gym_role_member` | `gym_u_member` |

### Ma trận quyền (role × bảng)

Bảng được sinh tự động từ `has_table_privilege` / `has_column_privilege` sau khi nạp `08_rbac_security.sql`. Ký hiệu: **S** = SELECT, **I** = INSERT, **U** = UPDATE, **D** = DELETE; `(...)` = chỉ áp dụng cho các cột nêu trong ngoặc; `-` = không có quyền; `x` = có quyền `EXECUTE`.

| Bảng / View | Admin | Receptionist | Trainer | Technician | Member |
|---|---|---|---|---|---|
| billing_log | S, I | S, I | - | - | - |
| class_enrollment | S, I, U, D | S, I, U | S, U(status) | - | - |
| class_schedule | S, I, U, D | S, I, U | S | - | S(class_id, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled) |
| equipment | S, I, U, D | - | - | S, I, U | - |
| equipment_reservation | S, I, U, D | - | - | S | - |
| facilities_room | S, I, U, D | S | S | S, U(status) | S |
| maintenance_log | S, I, U, D | - | - | S, I, U | - |
| member_profile | S, I, U, D | S, I, U | S | - | - |
| member_subscription | S, I, U, D | S, I, U | S(subscription_id, member_user_id, plan_id, remaining_sessions, start_time, end_time, sub_status) | - | - |
| membership_plan | S, I, U, D | S | S | - | S |
| permission | S, I, U, D | - | - | - | - |
| pt_booking | S, I, U, D | S, I, U | S, U(status) | - | - |
| role | S, I, U, D | S | - | - | - |
| role_permission | S, I, U, D | - | - | - | - |
| staff_profile | S, I, U, D | - | - | S | - |
| trainer_profile | S, I, U, D | S | S | - | - |
| user_account | S(user_id, full_name, email, phone, dob, emergency_contact, status, created_at), I, U, D | S(user_id, full_name, email, phone, dob, emergency_contact, status, created_at), I, U(full_name, email, phone, dob, emergency_contact, status) | S(user_id, full_name, phone, emergency_contact) | - | - |
| user_role | S, I, U, D | I | - | - | - |
| vw_active_member_subscriptions | S | S | - | - | - |
| vw_trainer_schedule_overview | S | S | S | - | - |
| EXECUTE sp_process_subscription_renewals | x | x | - | - | - |

Không role nào được `TRUNCATE`; không role nào có `DELETE` hay `UPDATE` trên `billing_log` (BR-10, kể cả Admin); lễ tân không có `DELETE` ở bất kỳ bảng nào. HLV chỉ được đổi `status` của ca PT/đăng ký lớp (điểm danh, `Completed`, `No_Show`), không được đổi HLV, hội viên hay giờ tập.

### Vì sao hàm trigger phải là `SECURITY DEFINER`

Mặc định hàm trigger chạy với quyền của **người kích hoạt**. Hai tình huống hợp lệ sẽ thất bại (`42501`) nếu không xử lý:

- HLV đổi `pt_booking.status = 'Completed'` kích hoạt `trg_fn_update_remaining_pt_sessions`, hàm này `SELECT ... FOR UPDATE` rồi `UPDATE member_subscription`, mà HLV không (và không được) có quyền ghi bảng này.
- Lễ tân thêm `class_enrollment` kích hoạt `fn_sync_class_enrollment_count`, hàm này `UPDATE class_schedule.current_enrolled`.

Giải pháp: `ALTER FUNCTION ... SECURITY DEFINER SET search_path = public, pg_temp` cho mọi hàm trigger trong schema `public` (liệt kê động từ `pg_proc`), để hàm chạy bằng quyền chủ sở hữu hàm. Nhờ đó quyền trực tiếp của từng role vẫn giữ tối thiểu mà nghiệp vụ tự động (trừ buổi PT, đồng bộ sĩ số lớp) vẫn hoạt động; `search_path` cố định để chống tấn công chiếm quyền qua `search_path`. Kiểm chứng: khi tạm chuyển `trg_fn_update_remaining_pt_sessions` về `SECURITY INVOKER`, test TA-01 chuyển sang FAIL với `42501`.

### Phương pháp kiểm thử

- **Nhóm RD/TD/ED/MD/AD/LD (Denied):** role thực hiện thao tác trái quyền; test **PASS** khi CSDL trả đúng SQLSTATE `42501` (`insufficient_privilege`).
- **Nhóm RA/TA/EA/MA/AA/LA (Allowed):** thao tác hợp lệ phải được chấp nhận và dữ liệu dẫn xuất do trigger tạo ra phải đúng (câu kiểm tra chạy bằng superuser sau `RESET ROLE`).
- Hàm hỗ trợ `pg_temp.expect_denied` / `pg_temp.expect_allowed` nhận tên role, chạy `SET LOCAL ROLE`; savepoint của khối `EXCEPTION` tự hoàn tác `SET LOCAL ROLE` nên bảng kết quả luôn được ghi bằng quyền ban đầu.
- Mốc thời gian không viết cứng: dùng `pg_temp.night_slot(n)` (21:00 của hôm nay + n ngày) và `pg_temp.next_late_slot()` (khung đêm kế tiếp cách hiện tại hơn 30 phút và dưới 24 giờ, dùng cho kịch bản hủy muộn BR-25).
- BR-10 có bốn lớp bảo vệ. Các test AD-01..AD-03 kiểm tra lớp phân quyền (lỗi `42501` xảy ra trước khi trigger được kích hoạt); nhóm **EV-01..EV-13** kiểm tra lớp sở hữu và event trigger: superuser bị chặn `P0001`, role ứng dụng bị chặn `42501`, lối thoát bảo trì có chủ đích hoạt động, mọi đối tượng thuộc `gym_owner` và event trigger đang bật.

### Kết quả: 66/66 test PASS

| Mã | Vai trò | Kịch bản | SQLSTATE mong đợi | SQLSTATE thực tế | Kết quả | Thông báo |
|---|---|---|---|---|---|---|
| RA-01 | gym_role_receptionist | Tạo tài khoản hội viên mới kèm hồ sơ member_profile | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| RA-02 | gym_role_receptionist | Đọc thông tin hội viên (không gồm password_hash) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| RD-01 | gym_role_receptionist | Đọc cột password_hash của user_account | 42501 | 42501 | PASS | permission denied for table user_account |
| RD-02 | gym_role_receptionist | SELECT * trên user_account (bao gồm password_hash) | 42501 | 42501 | PASS | permission denied for table user_account |
| RD-03 | gym_role_receptionist | UPDATE hóa đơn billing_log (BR-10) | 42501 | 42501 | PASS | permission denied for table billing_log |
| RD-04 | gym_role_receptionist | DELETE hóa đơn billing_log (BR-10) | 42501 | 42501 | PASS | permission denied for table billing_log |
| RD-05 | gym_role_receptionist | DELETE hợp đồng member_subscription | 42501 | 42501 | PASS | permission denied for table member_subscription |
| RD-06 | gym_role_receptionist | UPDATE giá gói tập membership_plan (thuộc quyền Admin) | 42501 | 42501 | PASS | permission denied for table membership_plan |
| RA-03 | gym_role_receptionist | Thêm đăng ký lớp: trigger SECURITY DEFINER cập nhật current_enrolled (lớp ID 2: 16 -> 17) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| RA-04 | gym_role_receptionist | Ghi nhận hóa đơn thanh toán mới vào billing_log | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| RA-05 | gym_role_receptionist | Gọi thủ tục sp_process_subscription_renewals (BR-24): phát hành hóa đơn gia hạn Pending | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| RA-06 | gym_role_receptionist | Tạo hợp đồng Pending + hóa đơn Completed: chuỗi trigger tự kích hoạt Active (BR-07) và điền created_by_user_id (BR-23) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| RD-07 | gym_role_receptionist | Ghi đè billing_log.created_by_user_id (BR-10: UPDATE hóa đơn bị cấm) | 42501 | 42501 | PASS | permission denied for table billing_log |
| TA-01 | gym_role_trainer | Đánh dấu ca PT Completed: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TA-02 | gym_role_trainer | Đánh dấu ca PT No_Show: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TA-03 | gym_role_trainer | Hủy ca PT < 24h: trigger đổi Cancelled thành Late_Cancelled và trừ 1 buổi (BR-25) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TA-04 | gym_role_trainer | Điểm danh lớp học: đổi class_enrollment.status sang Attended | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TA-05 | gym_role_trainer | Đọc khung nhìn vw_trainer_schedule_overview | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TD-01 | gym_role_trainer | Đổi HLV phụ trách pt_booking.trainer_user_id | 42501 | 42501 | PASS | permission denied for table pt_booking |
| TD-02 | gym_role_trainer | Đọc billing_log | 42501 | 42501 | PASS | permission denied for table billing_log |
| TD-03 | gym_role_trainer | Đọc user_account.email của hội viên | 42501 | 42501 | PASS | permission denied for table user_account |
| TD-04 | gym_role_trainer | Đọc member_subscription.actual_price (cột giá tiền) | 42501 | 42501 | PASS | permission denied for table member_subscription |
| TD-05 | gym_role_trainer | Sửa trực tiếp số buổi member_subscription.remaining_sessions | 42501 | 42501 | PASS | permission denied for table member_subscription |
| TD-06 | gym_role_trainer | Tạo lịch lớp học mới (INSERT class_schedule) | 42501 | 42501 | PASS | permission denied for table class_schedule |
| TD-07 | gym_role_trainer | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | 42501 | 42501 | PASS | permission denied for procedure sp_process_subscription_renewals |
| EA-01 | gym_role_technician | Ghi nhật ký bảo trì mới vào maintenance_log | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| EA-02 | gym_role_technician | Cập nhật equipment.status sang Under_Maintenance | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| EA-03 | gym_role_technician | Quy trình BR-19: mở ca bảo trì In_Progress rồi hoàn tất, trigger tự đổi trạng thái thiết bị (Under_Maintenance -> Operational) dù role chỉ có UPDATE(status) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| ED-01 | gym_role_technician | Đọc billing_log | 42501 | 42501 | PASS | permission denied for table billing_log |
| ED-02 | gym_role_technician | Đọc user_account | 42501 | 42501 | PASS | permission denied for table user_account |
| ED-03 | gym_role_technician | Đọc member_subscription | 42501 | 42501 | PASS | permission denied for table member_subscription |
| ED-04 | gym_role_technician | Xóa thiết bị (DELETE equipment) | 42501 | 42501 | PASS | permission denied for table equipment |
| ED-05 | gym_role_technician | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | 42501 | 42501 | PASS | permission denied for procedure sp_process_subscription_renewals |
| MA-01 | gym_role_member | Xem lịch lớp học nhóm class_schedule | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| MD-01 | gym_role_member | Đọc user_account | 42501 | 42501 | PASS | permission denied for table user_account |
| MD-02 | gym_role_member | Tự đặt ca PT (INSERT pt_booking) | 42501 | 42501 | PASS | permission denied for table pt_booking |
| MD-03 | gym_role_member | Đọc billing_log | 42501 | 42501 | PASS | permission denied for table billing_log |
| MD-04 | gym_role_member | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | 42501 | 42501 | PASS | permission denied for procedure sp_process_subscription_renewals |
| MD-05 | gym_role_member | Đọc class_schedule.created_by_user_id (cột nội bộ, BR-23) | 42501 | 42501 | PASS | permission denied for table class_schedule |
| AA-01 | gym_role_admin | Điều chỉnh giá gói tập membership_plan | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| AA-02 | gym_role_admin | Tạo tài khoản mới và đặt password_hash (INSERT cột nhạy cảm) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| AA-03 | gym_role_admin | Gọi thủ tục sp_process_subscription_renewals (BR-24) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| AD-01 | gym_role_admin | UPDATE hóa đơn billing_log (BR-10, kể cả Admin) | 42501 | 42501 | PASS | permission denied for table billing_log |
| AD-02 | gym_role_admin | DELETE hóa đơn billing_log (BR-10, kể cả Admin) | 42501 | 42501 | PASS | permission denied for table billing_log |
| AD-03 | gym_role_admin | TRUNCATE billing_log (không thể vượt rào DELETE) | 42501 | 42501 | PASS | permission denied for table billing_log |
| AD-04 | gym_role_admin | Đọc cột password_hash của user_account | 42501 | 42501 | PASS | permission denied for table user_account |
| LD-01 | gym_u_trainer | Tài khoản gym_u_trainer thừa hưởng: không đọc được billing_log | 42501 | 42501 | PASS | permission denied for table billing_log |
| LA-01 | gym_u_tech | Tài khoản gym_u_tech thừa hưởng: đọc được equipment | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| EV-01 | superuser | Superuser ALTER TABLE billing_log DISABLE TRIGGER USER bị event trigger chặn | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được thay đổi (ALTER TABLE) public.billing_log (nhật ký thanh toán bất biến) |
| EV-02 | superuser | Superuser DROP TRIGGER trg_billing_immutable_delete ON billing_log bị chặn | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được xóa trigger trg_billing_immutable_delete on public.billing_log (nhật ký thanh  |
| EV-03 | superuser | Superuser DROP TABLE billing_log CASCADE bị chặn | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được xóa table public.billing_log (nhật ký thanh toán bất biến) |
| EV-04 | superuser | Superuser thay ruột hàm trigger bất biến (CREATE OR REPLACE FUNCTION) bị chặn | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được thay đổi (CREATE FUNCTION) public.trg_fn_billing_immutable_delete() (nhật ký t |
| EV-05 | superuser | Superuser đổi tên trigger bất biến (ALTER TRIGGER ... RENAME) bị chặn | P0001 | P0001 | PASS | Lỗi nghiệp vụ BR-10: Không được thay đổi (ALTER TRIGGER) trg_off on public.billing_log (nhật ký thanh toán bất |
| EV-06 | superuser | Lối thoát bảo trì: superuser đặt app.allow_billing_maintenance = on rồi DISABLE/DROP TRIGGER được phép | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| EV-07 | gym_u_admin | gym_u_admin ALTER TABLE billing_log (kể cả khi đặt lối thoát) -> 42501 không phải chủ sở hữu | 42501 | 42501 | PASS | must be owner of table billing_log |
| EV-08 | gym_role_admin | gym_role_admin DROP TRIGGER trg_billing_immutable_update ON billing_log -> 42501 | 42501 | 42501 | PASS | must be owner of relation billing_log |
| EV-09 | gym_role_admin | gym_role_admin DROP TABLE billing_log -> 42501 | 42501 | 42501 | PASS | must be owner of table billing_log |
| EV-10 | gym_role_admin | gym_role_admin ALTER TABLE billing_log DISABLE TRIGGER ALL -> 42501 | 42501 | 42501 | PASS | must be owner of table billing_log |
| EV-11 | superuser | Mọi bảng, view, sequence, hàm, thủ tục trong schema public đều thuộc gym_owner | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| EV-12 | superuser | gym_owner NOLOGIN, không phải superuser; không gym_u_*/gym_role_* nào là thành viên của gym_owner | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| EV-13 | superuser | Event trigger evt_protect_billing_log (ddl_command_end) và _drop (sql_drop) đang bật | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| SY-01 | superuser | Ma trận quyền ứng dụng của Admin khớp GRANT của gym_role_admin (BR-22) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| SY-02 | superuser | Ma trận quyền ứng dụng của Receptionist khớp GRANT của gym_role_receptionist (BR-22) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| SY-03 | superuser | Ma trận quyền ứng dụng của Trainer khớp GRANT của gym_role_trainer (BR-22) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| SY-04 | superuser | Ma trận quyền ứng dụng của Technician khớp GRANT của gym_role_technician (BR-22) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| SY-05 | superuser | Ma trận quyền ứng dụng của Member khớp GRANT của gym_role_member (BR-22) | 00000 | 00000 | PASS | Thao tác hợp lệ được chấp nhận, kết quả đúng |

Tổng: 66 test, 66 PASS, 0 FAIL.

### Lưu ý triển khai

- Chủ sở hữu bảng và superuser luôn vượt qua `GRANT`/`REVOKE`; vì vậy BR-10 còn có lớp trigger, lớp sở hữu bằng role `NOLOGIN` `gym_owner` và lớp event trigger. Giới hạn cố hữu duy nhất: superuser là gốc tin cậy của mọi DBMS nên vẫn có thể bảo trì có chủ đích bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`. Chạy lại `04_triggers_views.sql` khi event trigger đã tồn tại cũng cần lối thoát này.
- Quyền chỉ áp dụng cho các bảng hiện có; bảng tạo mới sau này cần `GRANT` bổ sung (hoặc dùng `ALTER DEFAULT PRIVILEGES`).
- Bảng `role_permission` (ma trận quyền ứng dụng) và các lệnh `GRANT` của `08_rbac_security.sql` vẫn được duy trì thủ công ở hai nơi, nhưng sai lệch được phát hiện tự động bởi SY-01..SY-05 (BR-22); khi đổi một nơi, chạy lại `09_rbac_test_cases.sql`.

## 5.3. Kiểm tra sao lưu và khôi phục (NFR-AVL-01, NFR-SEC-03)

Kiểm tra thủ công ngày 17/11/2026 trên bản Docker demo (image `fitzone-postgres:16`):

| Kiểm tra | Kết quả |
|---|---|
| Khởi tạo CSDL mới với TLS | Đạt |
| Kết nối `sslmode=disable` | Bị từ chối (`pg_hba.conf rejects connection ... no encryption`) |
| Kết nối `sslmode=require` | Thành công, TLSv1.3 |
| Kết nối của ứng dụng web | TLSv1.3 |
| 3 lần sao lưu với `BACKUP_RETENTION=2` | Chỉ giữ 2 bản mới nhất |
| Nội dung tệp sao lưu | Bắt đầu bằng `Salted__` (đã mã hóa), không lộ tên bảng dạng văn bản |
| `verify-restore.sh` | ĐẠT: khôi phục vào `<db>_restore_check`, 18 bảng khớp số dòng với CSDL đang chạy; sai mật khẩu thì thoát mã 1 |
| Bộ test ràng buộc trên máy chủ TLS | 109/109 PASS |
| Bộ test RBAC trên máy chủ TLS | 66/66 PASS |
| Tạo lại stack demo, giữ volume | Dữ liệu nguyên vẹn |
| `verify-pitr.sh` (PITR) | ĐẠT: bản nền `pg_basebackup` + phát lại WAL đã lưu trữ trên máy chủ tạm; 24 dòng ghi SAU bản nền đều được khôi phục; xoay vòng giữ 2 bản nền và dọn WAL cũ (`pg_archivecleanup`) vẫn ĐẠT; thiếu kho WAL thì thoát mã 1 |

Chưa bao gồm: mã hóa tệp dữ liệu trên đĩa máy chủ (hạ tầng).
