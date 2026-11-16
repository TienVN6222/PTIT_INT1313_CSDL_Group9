# Phụ lục: Ánh xạ EER → Lược đồ quan hệ theo thuật toán Elmasri & Navathe

Phụ lục này chứng minh từng cấu trúc trong sơ đồ EER ([2_conceptual.md](1_conceptual_er_eer_model/2_conceptual.md)) được chuyển thành quan hệ, khóa chính (PK), khóa ngoại (FK) và ràng buộc DDL trong `Phase 3/01_schema_ddl.sql` như thế nào, theo 9 bước của thuật toán.

## Bước 1. Ánh xạ kiểu thực thể thông thường (regular entity)

Mỗi thực thể mạnh thành một quan hệ chứa mọi thuộc tính đơn; chọn một khóa làm PK.

| Cấu trúc EER | Quan hệ / thuộc tính | PK | Ràng buộc DDL |
|---|---|---|---|
| USER_ACCOUNT | user_account(user_id, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at) | user_id | `pk_user_account`; `uq_user_account_email`, `uq_user_account_phone`; `chk_user_account_status` |
| ROLE | role(role_id, role_name, description) | role_id | `pk_role`, `uq_role_name` |
| PERMISSION | permission(permission_id, permission_code, module_name, description) | permission_id | `pk_permission`, `uq_permission_code` |
| MEMBERSHIP_PLAN | membership_plan(plan_id, plan_name, duration_days, total_sessions, price, description) | plan_id | `pk_membership_plan`; `chk_membership_plan_duration/_sessions/_price` |
| MEMBER_SUBSCRIPTION | member_subscription(subscription_id, …) | subscription_id | `pk_member_subscription`; `uq_subscription_member`; `chk_subscription_*` |
| BILLING_LOG | billing_log(billing_id, invoice_no, billing_period_start, amount, …) | billing_id | `pk_billing_log`; `uq_billing_invoice_no`; `uq_billing_subscription_period` (unique một phần); `chk_billing_*` |
| FACILITIES_ROOM | facilities_room(room_id, room_name, room_type, max_capacity, status) | room_id | `pk_facilities_room`; `chk_facilities_*` |
| EQUIPMENT | equipment(equipment_id, equipment_name, serial_number, purchase_date, depreciation_months, status) | equipment_id | `pk_equipment`; `uq_equipment_serial`; `chk_equipment_depreciation/_status` |
| CLASS_SCHEDULE | class_schedule(class_id, class_name, start_time, end_time, max_capacity, current_enrolled) | class_id | `pk_class_schedule`; `chk_class_time/_capacity/_enrolled/_enrollment_limit` (current_enrolled là thuộc tính dẫn xuất được lưu) |
| PT_BOOKING | pt_booking(booking_id, booking_date, start_time, end_time, status, created_at) | booking_id | `pk_pt_booking`; `chk_pt_booking_time/_date/_status` |
| EQUIPMENT_RESERVATION | equipment_reservation(reservation_id, start_time, end_time, status) | reservation_id | `pk_equipment_reservation`; `chk_reservation_time/_status` |
| MAINTENANCE_LOG | maintenance_log(maintenance_id, issue_description, start_time, end_time, cost, status, created_at) | maintenance_id | `pk_maintenance_log`; `chk_maintenance_*` |

## Bước 2. Ánh xạ thực thể yếu (weak entity)

Mô hình không có thực thể yếu đúng nghĩa: mọi thực thể đều có khóa thay thế riêng (`*_id` kiểu `SERIAL`). Hai trường hợp gần nhất được xử lý như sau để chứng minh đã xem xét:

| Cấu trúc EER | Cách xử lý | Ràng buộc DDL |
|---|---|---|
| CLASS_ENROLLMENT (liên kết yếu giữa subscription và class) | Là quan hệ M:N có thuộc tính (Bước 5), dùng khóa thay thế `enrollment_id` và ràng buộc duy nhất trên cặp khóa ngoại | `pk_class_enrollment`, `uq_enrollment_subscription_class` |
| Các lớp con MEMBER/TRAINER/STAFF (phụ thuộc tồn tại vào USER_ACCOUNT) | Khóa chính chia sẻ + `ON DELETE CASCADE` (Bước 8A) | `fk_*_profile_user` |

## Bước 3. Ánh xạ quan hệ 1:1

Không có quan hệ 1:1 độc lập. Quan hệ 1:1 duy nhất là "is-a" giữa siêu lớp và lớp con, được xử lý ở Bước 8 bằng khóa chính chia sẻ (shared PK): `member_profile.user_id`, `trainer_profile.user_id`, `staff_profile.user_id` vừa là PK vừa là FK tới `user_account(user_id)`.

## Bước 4. Ánh xạ quan hệ 1:N (thêm khóa ngoại về phía N)

| Quan hệ EER | Quan hệ phía N | FK | Tham gia (NOT NULL?) | Constraint DDL |
|---|---|---|---|---|
| SUBSCRIBES | member_subscription | member_user_id → member_profile(user_id) | toàn phần, NOT NULL | `fk_subscription_member` (RESTRICT) |
| OF_PLAN | member_subscription | plan_id → membership_plan | toàn phần, NOT NULL | `fk_subscription_plan` |
| GENERATES | billing_log | subscription_id → member_subscription | toàn phần, NOT NULL | `fk_billing_subscription` |
| BOOKS | pt_booking | member_user_id → member_profile | toàn phần | `fk_booking_member` |
| CONDUCTS | pt_booking | trainer_user_id → trainer_profile | toàn phần | `fk_booking_trainer` |
| CONSUMES | pt_booking | subscription_id → member_subscription | toàn phần | `fk_booking_subscription`; `fk_booking_subscription_member` (khóa ngoại ghép (subscription_id, member_user_id) → `uq_subscription_member`, đảm bảo booking thuộc đúng hội viên chủ hợp đồng) |
| TEACHES | class_schedule | trainer_user_id → trainer_profile | toàn phần | `fk_class_trainer` |
| HOSTS | class_schedule | room_id → facilities_room | toàn phần | `fk_class_room` |
| CONTAINS | equipment | room_id → facilities_room | toàn phần | `fk_equipment_room` |
| REPAIRED_IN | maintenance_log | equipment_id → equipment | toàn phần | `fk_maintenance_equipment` |
| PERFORMS | maintenance_log | staff_user_id → staff_profile | toàn phần | `fk_maintenance_staff` |
| RESERVED_FOR | equipment_reservation | equipment_id → equipment | toàn phần | `fk_reservation_equipment` (CASCADE) |
| FOR_BOOKING (XOR) | equipment_reservation | booking_id → pt_booking (NULL được) | riêng phần | `fk_reservation_booking`, `chk_reservation_source` |
| FOR_CLASS (XOR) | equipment_reservation | class_id → class_schedule (NULL được) | riêng phần | `fk_reservation_class`, `chk_reservation_source` |
| CREATED_BY / UPDATED_BY ×5 (BR-23) | member_subscription, billing_log, class_schedule, pt_booking, maintenance_log | created_by_user_id → user_account(user_id) NOT NULL (toàn phần); updated_by_user_id → user_account(user_id) NULL được (riêng phần, kèm updated_at) | toàn phần (created) / riêng phần (updated) | `fk_subscription_created_by`, `fk_billing_created_by`, `fk_class_created_by`, `fk_booking_created_by`, `fk_maintenance_created_by` và 5 khóa `fk_*_updated_by` (đều RESTRICT) |

Cung loại trừ XOR của EQUIPMENT_RESERVATION được ánh xạ bằng hai FK nullable cộng `chk_reservation_source` (đúng một trong hai khác NULL); tránh trùng lịch thiết bị bằng `ex_reservation_equipment_no_overlap`.

## Bước 5. Ánh xạ quan hệ M:N (quan hệ riêng / bảng trung gian)

| Quan hệ EER | Quan hệ mới | Thuộc tính | PK | FK | Constraint DDL |
|---|---|---|---|---|---|
| HAS_ROLE | user_role | – | (user_id, role_id) | user_id → user_account; role_id → role | `pk_user_role`, `fk_user_role_user`, `fk_user_role_role` (CASCADE) |
| GRANTS | role_permission | – | (role_id, permission_id) | role_id → role; permission_id → permission | `pk_role_permission`, `fk_role_permission_role`, `fk_role_permission_permission` |
| ENROLLS_IN | class_enrollment | enrollment_date, status | enrollment_id (khóa thay thế) | subscription_id → member_subscription; class_id → class_schedule | `pk_class_enrollment`, `fk_enrollment_subscription`, `fk_enrollment_class`, `uq_enrollment_subscription_class`, `chk_enrollment_status` |

## Bước 6. Ánh xạ thuộc tính đa trị (multivalued)

Mô hình không có thuộc tính đa trị: mọi thuộc tính đều đơn trị và nguyên tố (1NF, xem `3_normalization_verification.md`). Vai trò đa trị của người dùng được mô hình hóa là quan hệ M:N HAS_ROLE chứ không phải thuộc tính đa trị (Bước 5). Thuộc tính dẫn xuất `current_enrolled` được lưu vật lý, đồng bộ bằng trigger.

## Bước 7. Ánh xạ quan hệ n-ngôi (n > 2)

Không có quan hệ n-ngôi thật sự. Ba thực thể liên quan trong một ca PT (hội viên, huấn luyện viên, hợp đồng) được biểu diễn bằng ba quan hệ nhị phân 1:N (BOOKS, CONDUCTS, CONSUMES) trên cùng `pt_booking`, cộng khóa ngoại ghép `fk_booking_subscription_member` để giữ tính nhất quán giữa chúng. Quan hệ EQUIPMENT_RESERVATION với booking/class là cung XOR (Bước 4), không phải n-ngôi.

## Bước 8. Ánh xạ chuyên biệt hóa / tổng quát hóa

**Phương án dùng: 8A — một quan hệ cho siêu lớp và một quan hệ cho mỗi lớp con, khóa chính của lớp con chính là khóa của siêu lớp.**

| Lớp | Quan hệ | Thuộc tính riêng | PK = FK | Constraint DDL |
|---|---|---|---|---|
| USER_ACCOUNT (siêu lớp) | user_account | toàn bộ thuộc tính chung | user_id | `pk_user_account` |
| MEMBER | member_profile | health_notes | user_id → user_account | PK không đặt tên (`member_profile_pkey`), `fk_member_profile_user` (CASCADE) |
| TRAINER | trainer_profile | specialization, bio, current_rating | user_id → user_account | `trainer_profile_pkey`, `fk_trainer_profile_user`, `chk_trainer_rating` |
| STAFF | staff_profile | job_title, department | user_id → user_account | `staff_profile_pkey`, `fk_staff_profile_user` |

**Vì sao chọn 8A, không chọn 8B/8C/8D:**
- Chuyên biệt hóa là **chồng lấn và riêng phần** (BR-22): 8B (chỉ các quan hệ con, lặp thuộc tính chung) yêu cầu mọi thực thể phải thuộc lớp con và gây dư thừa/không nhất quán khi một người giữ nhiều vai trò; Admin không có hồ sơ cũng không biểu diễn được.
- 8C (một quan hệ đơn với cột loại) đòi hỏi nhiều cột NULL (health_notes, specialization, job_title…) và cột loại đơn trị không biểu diễn được chồng lấn; 8D (cờ boolean) khả thi nhưng vẫn nhiều NULL và không cho FK chính xác.
- 8A cho phép khóa ngoại trỏ đúng lớp con (ví dụ `pt_booking.trainer_user_id → trainer_profile`, `maintenance_log.staff_user_id → staff_profile`), loại bỏ các giá trị NULL và cho phép một `user_id` có đồng thời nhiều hồ sơ (chồng lấn). Tài khoản không có hồ sơ (Admin) hợp lệ (riêng phần).

## Bước 9. Ánh xạ phạm trù / hợp (category, union type)

Mô hình không có category (không có lớp con có nhiều siêu lớp khác nhau). Gần nhất là cung XOR của EQUIPMENT_RESERVATION (chủ sở hữu là PT_BOOKING hoặc CLASS_SCHEDULE): Elmasri xử lý category bằng khóa thay thế, nhưng ở đây dùng hai FK nullable cùng `chk_reservation_source`, vì khóa thay thế sẽ làm mất kiểm tra tham chiếu khai báo và PostgreSQL không có FK đa hình.

## Checklist: đủ 18 bảng vật lý

| # | Bảng | Đến từ | Bước |
|---|---|---|---|
| 1 | user_account | USER_ACCOUNT | 1 |
| 2 | role | ROLE | 1 |
| 3 | user_role | HAS_ROLE (M:N) | 5 |
| 4 | permission | PERMISSION | 1 |
| 5 | role_permission | GRANTS (M:N) | 5 |
| 6 | member_profile | MEMBER (lớp con) | 8A |
| 7 | trainer_profile | TRAINER (lớp con) | 8A |
| 8 | staff_profile | STAFF (lớp con) | 8A |
| 9 | membership_plan | MEMBERSHIP_PLAN | 1 |
| 10 | member_subscription | MEMBER_SUBSCRIPTION + SUBSCRIBES + OF_PLAN | 1, 4 |
| 11 | billing_log | BILLING_LOG + GENERATES | 1, 4 |
| 12 | facilities_room | FACILITIES_ROOM | 1 |
| 13 | equipment | EQUIPMENT + CONTAINS | 1, 4 |
| 14 | class_schedule | CLASS_SCHEDULE + TEACHES + HOSTS | 1, 4 |
| 15 | class_enrollment | ENROLLS_IN (M:N) | 5 |
| 16 | pt_booking | PT_BOOKING + BOOKS + CONDUCTS + CONSUMES | 1, 4, 7 |
| 17 | equipment_reservation | EQUIPMENT_RESERVATION + RESERVED_FOR + XOR | 1, 4, 9 |
| 18 | maintenance_log | MAINTENANCE_LOG + REPAIRED_IN + PERFORMS | 1, 4 |

Khóa ngoại `created_by_user_id` và `updated_by_user_id` (BR-23): 10/10 đã tính — `member_subscription` (`fk_subscription_created_by`), `billing_log` (`fk_billing_created_by`), `class_schedule` (`fk_class_created_by`), `pt_booking` (`fk_booking_created_by`), `maintenance_log` (`fk_maintenance_created_by`); cùng 5 bảng có thêm `fk_subscription_updated_by`, `fk_billing_updated_by`, `fk_class_updated_by`, `fk_booking_updated_by`, `fk_maintenance_updated_by`.
