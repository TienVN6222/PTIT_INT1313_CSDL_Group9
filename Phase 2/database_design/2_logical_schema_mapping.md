# 2.2. Ánh xạ Lược đồ Logic (Logical Schema Mapping)

Mục này trình bày 18 lược đồ quan hệ thu được sau khi ánh xạ mô hình EER sang mô hình quan hệ, khớp với [`01_schema_ddl.sql`](../../Phase%203/01_schema_ddl.sql). Quy ước ký hiệu:

- <u>gạch chân</u> = khóa chính (PK); khóa chính ghép liệt kê đủ các thuộc tính cùng gạch chân.
- `FK` = khóa ngoại, ghi dạng `thuộc_tính --> BẢNG(thuộc_tính)` kèm hành động `ON DELETE`.
- `AK` = khóa phụ / khóa dự tuyển (UNIQUE). Chỉ mục duy nhất **một phần** (partial UNIQUE) được ghi riêng là `UNIQUE (…) WHERE …` vì không phải khóa dự tuyển trên toàn bộ bản ghi.
- `EXCLUDE` = ràng buộc loại trừ chồng lấn khoảng thời gian (GiST, cần extension `btree_gist`); `CHECK` = ràng buộc miền / liên thuộc tính.
- Các khóa ngoại `created_by_user_id` (BR-23) là thuộc tính vết kiểm toán, cho phép `NULL`, trỏ về `USER_ACCOUNT` (người thực hiện thao tác bất kỳ vai trò nào).

## Phân hệ Tài khoản & Phân quyền RBAC

- **USER_ACCOUNT** (<u>user_id</u>, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at)
  - AK: `email` (`uq_user_account_email`), `phone` (`uq_user_account_phone`)
  - CHECK: `status IN ('Active','Inactive','Suspended')`
- **ROLE** (<u>role_id</u>, role_name, description)
  - AK: `role_name` (`uq_role_name`)
- **USER_ROLE** (<u>user_id, role_id</u>)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE
  - FK: `role_id --> ROLE(role_id)` ON DELETE CASCADE
- **PERMISSION** (<u>permission_id</u>, permission_code, module_name, description)
  - AK: `permission_code` (`uq_permission_code`)
- **ROLE_PERMISSION** (<u>role_id, permission_id</u>)
  - FK: `role_id --> ROLE(role_id)` ON DELETE CASCADE
  - FK: `permission_id --> PERMISSION(permission_id)` ON DELETE CASCADE

## Phân hệ Hồ sơ Chuyên biệt (Shared Primary Key)

- **MEMBER_PROFILE** (<u>user_id</u>, health_notes)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE
- **TRAINER_PROFILE** (<u>user_id</u>, specialization, bio, current_rating)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE
  - CHECK: `0.00 <= current_rating <= 5.00`
- **STAFF_PROFILE** (<u>user_id</u>, job_title, department)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE

## Phân hệ Gói tập & Thanh toán

- **MEMBERSHIP_PLAN** (<u>plan_id</u>, plan_name, duration_days, total_sessions, price, description)
  - CHECK: `duration_days > 0`, `total_sessions >= 0`, `price >= 0`
- **MEMBER_SUBSCRIPTION** (<u>subscription_id</u>, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, created_by_user_id)
  - FK: `member_user_id --> MEMBER_PROFILE(user_id)` ON DELETE RESTRICT (`fk_subscription_member`)
  - FK: `plan_id --> MEMBERSHIP_PLAN(plan_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_subscription_created_by`)
  - AK (siêu khóa phục vụ khóa ngoại ghép): `(subscription_id, member_user_id)` (`uq_subscription_member`)
  - UNIQUE một phần: `(member_user_id) WHERE sub_status = 'Active'` (`uq_member_one_active_subscription`, BR-05)
  - CHECK: `actual_price >= 0`, `remaining_sessions >= 0`, `end_time >= start_time`, `sub_status IN ('Pending','Active','Expired','Suspended','Cancelled')`
- **BILLING_LOG** (<u>billing_id</u>, subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status, created_at, created_by_user_id)
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_billing_created_by`)
  - AK: `invoice_no` (`uq_billing_invoice_no`)
  - UNIQUE một phần: `(subscription_id, billing_period_start) WHERE payment_status IN ('Pending','Completed')` (`uq_billing_subscription_period`, BR-08). **Không** phải khóa dự tuyển vì hóa đơn `Failed`/`Refunded` được phép lặp chu kỳ.
  - CHECK: `amount > 0`, `payment_method IN ('Cash','Credit_Card','Banking','E_Wallet')`, `payment_status IN ('Pending','Completed','Failed','Refunded')`

## Phân hệ Lịch tập & Đặt chỗ

- **FACILITIES_ROOM** (<u>room_id</u>, room_name, max_capacity, room_type, status)
  - CHECK: `max_capacity > 0`, `status IN ('Active','Under_Maintenance','Inactive')`
- **CLASS_SCHEDULE** (<u>class_id</u>, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled, created_by_user_id)
  - FK: `trainer_user_id --> TRAINER_PROFILE(user_id)` ON DELETE RESTRICT
  - FK: `room_id --> FACILITIES_ROOM(room_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_class_created_by`)
  - EXCLUDE: `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` (`ex_class_trainer_no_overlap`)
  - EXCLUDE: `(room_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` (`ex_class_room_no_overlap`)
  - CHECK: `end_time > start_time`, `max_capacity > 0`, `current_enrolled >= 0`, `current_enrolled <= max_capacity`
- **CLASS_ENROLLMENT** (<u>enrollment_id</u>, subscription_id, class_id, enrollment_date, status)
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)` ON DELETE CASCADE
  - FK: `class_id --> CLASS_SCHEDULE(class_id)` ON DELETE CASCADE
  - AK: `(subscription_id, class_id)` (`uq_enrollment_subscription_class`)
  - CHECK: `status IN ('Enrolled','Cancelled','Attended')`
- **PT_BOOKING** (<u>booking_id</u>, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at, created_by_user_id)
  - FK: `member_user_id --> MEMBER_PROFILE(user_id)` ON DELETE RESTRICT (`fk_booking_member`)
  - FK: `trainer_user_id --> TRAINER_PROFILE(user_id)` ON DELETE RESTRICT (`fk_booking_trainer`)
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)` ON DELETE RESTRICT (`fk_booking_subscription`)
  - FK ghép: `(subscription_id, member_user_id) --> MEMBER_SUBSCRIPTION(subscription_id, member_user_id)` ON DELETE RESTRICT (`fk_booking_subscription_member`), bảo đảm ca PT luôn ghi đúng chủ hợp đồng
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_booking_created_by`)
  - EXCLUDE: `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled','Late_Cancelled'))` (`ex_pt_trainer_no_overlap`)
  - EXCLUDE: `(member_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled','Late_Cancelled'))` (`ex_pt_member_no_overlap`)
  - CHECK: `end_time > start_time`, `booking_date = start_time::DATE` (`chk_pt_booking_date`), `status IN ('Scheduled','Completed','Cancelled','Late_Cancelled','No_Show')`

## Phân hệ Thiết bị & Bảo trì

- **EQUIPMENT** (<u>equipment_id</u>, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status)
  - FK: `room_id --> FACILITIES_ROOM(room_id)` ON DELETE RESTRICT
  - AK: `serial_number` (`uq_equipment_serial`)
  - CHECK: `depreciation_months > 0`, `status IN ('Operational','Under_Maintenance','Decommissioned')`
- **EQUIPMENT_RESERVATION** (<u>reservation_id</u>, equipment_id, booking_id, class_id, start_time, end_time, status)
  - FK: `equipment_id --> EQUIPMENT(equipment_id)` ON DELETE CASCADE
  - FK: `booking_id --> PT_BOOKING(booking_id)` ON DELETE CASCADE (cho phép NULL)
  - FK: `class_id --> CLASS_SCHEDULE(class_id)` ON DELETE CASCADE (cho phép NULL)
  - EXCLUDE: `(equipment_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status <> 'Cancelled')` (`ex_reservation_equipment_no_overlap`)
  - CHECK: `end_time > start_time`, `status IN ('Reserved','Completed','Cancelled')`, đúng một trong `booking_id`, `class_id` khác NULL (`chk_reservation_source`)
- **MAINTENANCE_LOG** (<u>maintenance_id</u>, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status, created_at, created_by_user_id)
  - FK: `equipment_id --> EQUIPMENT(equipment_id)` ON DELETE RESTRICT
  - FK: `staff_user_id --> STAFF_PROFILE(user_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_maintenance_created_by`)
  - CHECK: `cost >= 0`, `status IN ('In_Progress','Completed','Cancelled')`, `end_time IS NULL OR end_time >= start_time`
