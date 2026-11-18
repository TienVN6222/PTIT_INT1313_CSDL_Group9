# PHẦN 4: LỊCH TẬP & ĐẶT CHỖ (SCHEDULING & ENROLLMENT)

Quản lý phòng tập, lịch lớp học nhóm, đăng ký lớp học và đặt ca tập PT 1-1 chống đụng lịch.

## Bảng 3.4.1: FACILITIES_ROOM

**Mô tả:** Danh mục phòng tập và các khu vực chức năng trong trung tâm.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| room_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh phòng tập / khu vực. `pk_facilities_room` |
| room_name | VARCHAR(100) | None | No | None | Tên hiển thị của phòng (VD: Phòng Yoga A1, Khu Máy Lưng) |
| max_capacity | INT | None | No | None | Sức chứa tối đa cùng lúc. `chk_facilities_capacity`: `max_capacity > 0` (BR-13) |
| room_type | VARCHAR(50) | None | No | None | Loại phòng (VD: 'Yoga_Studio', 'Gym_Floor', 'Boxing_Ring'); không có CHECK miền giá trị |
| status | VARCHAR(20) | None | No | 'Active' | Trạng thái phòng. `chk_facilities_status`: `IN ('Active', 'Under_Maintenance', 'Inactive')`. Trigger `trg_prevent_class_in_maintenance_room` cấm xếp lớp vào phòng không 'Active'; trigger `trg_prevent_room_maintenance_with_future_classes` cấm chuyển sang `Under_Maintenance`/`Inactive` khi còn lớp tương lai (BR-19) |

## Bảng 3.4.2: CLASS_SCHEDULE

**Mô tả:** Lịch vận hành các lớp học thể thao nhóm cố định.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| class_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh lớp học nhóm. `pk_class_schedule` |
| trainer_user_id | INT | FK | No | None | HLV phụ trách lớp. `fk_class_trainer` → **TRAINER_PROFILE**(user_id) **ON DELETE RESTRICT** (BR-12) |
| room_id | INT | FK | No | None | Phòng tổ chức lớp. `fk_class_room` → FACILITIES_ROOM(room_id) **ON DELETE RESTRICT** (BR-15) |
| class_name | VARCHAR(100) | None | No | None | Tên lớp học nhóm (VD: Power Yoga K12, BodyPump Morning) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu lớp học |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_class_time`: `end_time > start_time` (BR-17) |
| max_capacity | INT | None | No | None | Số hội viên tối đa được đăng ký. `chk_class_capacity`: `max_capacity > 0` |
| current_enrolled | INT | None | No | 0 | Số hội viên đã đăng ký (dữ liệu dẫn xuất, đồng bộ bởi `trg_sync_class_enrollment_count`). `chk_class_enrolled`: `>= 0`; `chk_class_enrollment_limit`: `current_enrolled <= max_capacity` (BR-14) |
| created_by_user_id | INT | FK | No | None | Người tạo lịch, bắt buộc (BR-23). `fk_class_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa lịch lớp lần gần nhất (BR-23). `fk_class_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `ex_class_trainer_no_overlap`: EXCLUDE USING gist `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)`, một HLV không dạy 2 lớp chồng giờ (BR-12).
- `ex_class_room_no_overlap`: EXCLUDE USING gist `(room_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)`, một phòng không tổ chức 2 lớp chồng giờ (BR-15).
- Trigger: `trg_check_class_schedule_conflicts` (BR-12, BR-16), `trg_prevent_class_in_maintenance_room` (BR-19).
- Chỉ mục: `idx_class_schedule_trainer`, `idx_class_schedule_room`, `idx_class_schedule_dates (start_time, end_time)`.

## Bảng 3.4.3: CLASS_ENROLLMENT

**Mô tả:** Bảng trung gian ghi nhận hội viên đăng ký tham gia lớp học nhóm.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| enrollment_id | SERIAL | PK | No | SERIAL (nextval) | Mã lượt đăng ký lớp học. `pk_class_enrollment` |
| subscription_id | INT | FK | No | None | Hợp đồng gói tập dùng để đăng ký. `fk_enrollment_subscription` → MEMBER_SUBSCRIPTION(subscription_id) **ON DELETE CASCADE** |
| class_id | INT | FK | No | None | Lớp học nhóm đăng ký. `fk_enrollment_class` → CLASS_SCHEDULE(class_id) **ON DELETE CASCADE** |
| enrollment_date | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm đăng ký thành công |
| status | VARCHAR(20) | None | No | 'Enrolled' | Trạng thái đăng ký. `chk_enrollment_status`: `IN ('Enrolled', 'Cancelled', 'Attended')` |

**Ràng buộc cấp bảng:** `uq_enrollment_subscription_class UNIQUE (subscription_id, class_id)`, một hợp đồng không đăng ký trùng một lớp. Trigger `trg_check_class_enrollment_conflicts` (BR-16) chống đăng ký các lớp chồng giờ; `trg_sync_class_enrollment_count` (AFTER INSERT/UPDATE/DELETE) đồng bộ `class_schedule.current_enrolled` (BR-14).

## Bảng 3.4.4: PT_BOOKING

**Mô tả:** Quản lý ca tập cá nhân 1-1 giữa hội viên và huấn luyện viên. Ca PT diễn ra ở khu tập tự do nên không gắn với phòng tập (BR-15 chỉ áp dụng cho lớp nhóm).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| booking_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh ca tập PT 1-1. `pk_pt_booking` |
| member_user_id | INT | FK | No | None | Hội viên đặt ca tập. `fk_booking_member` → **MEMBER_PROFILE**(user_id) **ON DELETE RESTRICT**. Cặp `(subscription_id, member_user_id)` được bảo vệ bởi khóa ngoại ghép `fk_booking_subscription_member` |
| trainer_user_id | INT | FK | No | None | PT chịu trách nhiệm. `fk_booking_trainer` → **TRAINER_PROFILE**(user_id) **ON DELETE RESTRICT** (BR-12) |
| subscription_id | INT | FK | No | None | Gói PT dùng để trừ buổi. `fk_booking_subscription` → MEMBER_SUBSCRIPTION(subscription_id) **ON DELETE RESTRICT**; khóa ngoại ghép `fk_booking_subscription_member` (subscription_id, member_user_id) → MEMBER_SUBSCRIPTION(subscription_id, member_user_id) **ON DELETE RESTRICT** (BR-18) |
| booking_date | DATE | None | No | None | Ngày diễn ra ca tập. `chk_pt_booking_date`: `booking_date = start_time::DATE` (đã áp dụng, loại bỏ nguy cơ lệch với `start_time`) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu ca tập 1-1 |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_pt_booking_time`: `end_time > start_time` (BR-17) |
| status | VARCHAR(20) | None | No | 'Scheduled' | Trạng thái ca tập. `chk_pt_booking_status`: `IN ('Scheduled', 'Completed', 'Cancelled', 'Late_Cancelled', 'No_Show')`. `Late_Cancelled` = hủy muộn < 24h, vẫn trừ 1 buổi (BR-25); do trigger `trg_late_cancel_pt_booking` tự chuyển từ Cancelled |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo ca tập |
| created_by_user_id | INT | FK | No | None | Người đặt lịch (lễ tân/hội viên), bắt buộc (BR-23). `fk_booking_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa ca PT lần gần nhất (đổi trạng thái, hủy) (BR-23). `fk_booking_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `ex_pt_trainer_no_overlap`: EXCLUDE USING gist `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled'))` (BR-12, BR-16).
- `ex_pt_member_no_overlap`: EXCLUDE USING gist `(member_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled'))`, lý do phải lưu `member_user_id` trong bảng này (BR-16).
- Trigger: `trg_check_pt_booking_creation` (BEFORE INSERT: hợp đồng Active, giờ nằm trong thời hạn, còn buổi: BR-18), `trg_check_pt_booking_conflicts` (BR-12, BR-16), `trg_late_cancel_pt_booking` (BR-25), `trg_update_remaining_pt_sessions` (AFTER UPDATE OF status: BR-18, BR-25).
- Chỉ mục: `idx_pt_booking_trainer`, `idx_pt_booking_member`, `idx_pt_booking_subscription (subscription_id)`, `idx_pt_booking_dates (start_time, end_time)`.
