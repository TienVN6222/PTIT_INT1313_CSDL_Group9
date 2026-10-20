# PHẦN 4: LỊCH TẬP & ĐẶT CHỖ (SCHEDULING & ENROLLMENT)

Quản lý phòng tập, lịch lớp học nhóm, đăng ký lớp học và đặt ca tập PT 1-1 chống đụng lịch.

## Bảng 3.4.1: FACILITIES_ROOM

**Mô tả:** Danh mục phòng tập và các khu vực chức năng trong trung tâm.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| room_id | INT | PK | No | AUTO_INCREMENT | Mã định danh phòng tập / khu vực |
| room_name | VARCHAR(100) | None | No | None | Tên hiển thị của phòng (VD: Phòng Yoga A1, Khu Máy Lưng) |
| max_capacity | INT | None | No | None | Sức chứa người tối đa cùng lúc (CHECK: max_capacity > 0) (BR-13) |
| room_type | VARCHAR(50) | None | No | None | Loại phòng ('Yoga_Studio', 'Gym_Floor', 'Boxing_Ring') |
| status | VARCHAR(20) | None | No | 'Active' | Trạng thái: 'Active', 'Under_Maintenance' (BR-19) |

## Bảng 3.4.2: CLASS_SCHEDULE

**Mô tả:** Lịch vận hành các lớp học thể thao nhóm cố định.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| class_id | INT | PK | No | AUTO_INCREMENT | Mã định danh lớp học nhóm |
| trainer_user_id | INT | FK | No | None | Ref USER_ACCOUNT(user_id) (Huấn luyện viên phụ trách lớp) |
| room_id | INT | FK | No | None | Ref FACILITIES_ROOM(room_id) (Phòng tập tổ chức lớp) |
| class_name | VARCHAR(100) | None | No | None | Tên lớp học nhóm (VD: Power Yoga K12, BodyPump Morning) |
| start_time | DATETIME | None | No | None | Thời điểm bắt đầu lớp học |
| end_time | DATETIME | None | No | None | Thời điểm kết thúc lớp học; CHECK (end_time > start_time) (BR-17) |
| max_capacity | INT | None | No | None | Số lượng hội viên tối đa cho phép đăng ký tham gia lớp |
| current_enrolled | INT | None | No | 0 | Số lượng học viên đã đăng ký; CHECK (current_enrolled <= max_capacity) (BR-14) |

## Bảng 3.4.3: CLASS_ENROLLMENT

**Mô tả:** Bảng trung gian ghi nhận hội viên đăng ký tham gia lớp học nhóm.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| enrollment_id | INT | PK | No | AUTO_INCREMENT | Mã lượt đăng ký lớp học |
| subscription_id | INT | FK | No | None | Ref MEMBER_SUBSCRIPTION(subscription_id) (Hợp đồng gói tập hợp lệ) |
| class_id | INT | FK | No | None | Ref CLASS_SCHEDULE(class_id) (Mã lớp học nhóm đăng ký) |
| enrollment_date | DATETIME | None | No | CURRENT_TIMESTAMP | Thời điểm thao tác đăng ký thành công |
| status | VARCHAR(20) | None | No | 'Enrolled' | Trạng thái đăng ký: 'Enrolled', 'Cancelled', 'Attended' |

## Bảng 3.4.4: PT_BOOKING

**Mô tả:** Quản lý ca tập cá nhân 1-1 giữa hội viên và huấn luyện viên.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| booking_id | INT | PK | No | AUTO_INCREMENT | Mã định danh ca tập PT 1-1 |
| member_user_id | INT | FK | No | None | Ref USER_ACCOUNT(user_id) (Hội viên đặt ca tập) |
| trainer_user_id | INT | FK | No | None | Ref USER_ACCOUNT(user_id) (PT chịu trách nhiệm dạy) (BR-12) |
| subscription_id | INT | FK | No | None | Ref MEMBER_SUBSCRIPTION(subscription_id) (Gói PT dùng trừ buổi) (BR-18) |
| booking_date | DATE | None | No | None | Ngày diễn ra ca tập |
| start_time | DATETIME | None | No | None | Thời điểm bắt đầu ca tập 1-1 |
| end_time | DATETIME | None | No | None | Thời điểm kết thúc ca tập 1-1; CHECK (end_time > start_time) (BR-17) |
| status | VARCHAR(20) | None | No | 'Scheduled' | Trạng thái: 'Scheduled', 'Completed', 'Cancelled' (BR-25) |
