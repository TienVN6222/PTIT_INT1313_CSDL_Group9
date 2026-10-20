# 2.2. Ánh xạ Lược đồ Logic (Logical Schema Mapping)

## Phân hệ Tài khoản & Phân quyền RBAC

- `USER_ACCOUNT (user_id, full_name, email, phone, dob, emergency_contact, password_hash, status)`
- `ROLE (role_id, role_name, description)`
- `USER_ROLE (user_id, role_id)`
  - FK: `user_id --> USER_ACCOUNT(user_id)`
  - FK: `role_id --> ROLE(role_id)`
- `PERMISSION (permission_id, permission_code, module_name, description)`
- `ROLE_PERMISSION (role_id, permission_id)`
  - FK: `role_id --> ROLE(role_id)`
  - FK: `permission_id --> PERMISSION(permission_id)`

## Phân hệ Hồ sơ Chuyên biệt (Shared Primary Key)

- `MEMBER_PROFILE (user_id, health_notes)`
  - FK: `user_id --> USER_ACCOUNT(user_id)`
- `TRAINER_PROFILE (user_id, specialization, bio, current_rating)`
  - FK: `user_id --> USER_ACCOUNT(user_id)`
- `STAFF_PROFILE (user_id, job_title, department)`
  - FK: `user_id --> USER_ACCOUNT(user_id)`

## Phân hệ Gói tập & Thanh toán

- `MEMBERSHIP_PLAN (plan_id, plan_name, duration_days, total_sessions, price, description)`
- `MEMBER_SUBSCRIPTION (subscription_id, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring)`
  - FK: `member_user_id --> USER_ACCOUNT(user_id)`
  - FK: `plan_id --> MEMBERSHIP_PLAN(plan_id)`
- `BILLING_LOG (billing_id, subscription_id, invoice_no, amount, payment_date, payment_method, payment_status)`
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)`

## Phân hệ Lịch tập & Đặt chỗ

- `FACILITIES_ROOM (room_id, room_name, max_capacity, room_type, status)`
- `CLASS_SCHEDULE (class_id, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled)`
  - FK: `trainer_user_id --> USER_ACCOUNT(user_id)`
  - FK: `room_id --> FACILITIES_ROOM(room_id)`
- `CLASS_ENROLLMENT (enrollment_id, subscription_id, class_id, enrollment_date, status)`
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)`
  - FK: `class_id --> CLASS_SCHEDULE(class_id)`
- `PT_BOOKING (booking_id, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)`
  - FK: `member_user_id --> USER_ACCOUNT(user_id)`
  - FK: `trainer_user_id --> USER_ACCOUNT(user_id)`
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)`

## Phân hệ Thiết bị & Bảo trì

- `EQUIPMENT (equipment_id, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status)`
  - FK: `room_id --> FACILITIES_ROOM(room_id)`
- `EQUIPMENT_RESERVATION (reservation_id, equipment_id, booking_id, class_id, start_time, end_time, status)`
  - FK: `equipment_id --> EQUIPMENT(equipment_id)`
  - FK: `booking_id --> PT_BOOKING(booking_id)`
  - FK: `class_id --> CLASS_SCHEDULE(class_id)`
- `MAINTENANCE_LOG (maintenance_id, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status)`
  - FK: `equipment_id --> EQUIPMENT(equipment_id)`
  - FK: `staff_user_id --> USER_ACCOUNT(user_id)`
