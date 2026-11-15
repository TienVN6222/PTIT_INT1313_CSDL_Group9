# PHẦN 2: HỒ SƠ CHUYÊN BIỆT (EER SUBCLASSES)

Mở rộng thông tin chuyên môn riêng cho từng nhóm người dùng (Hội viên, PT, Nhân viên) theo cơ chế Shared Primary Key: khóa chính của lớp con đồng thời là khóa ngoại trỏ về `user_account`.

## Bảng 3.2.1: MEMBER_PROFILE

**Mô tả:** Hồ sơ thông tin bổ sung dành riêng cho nhóm hội viên tập luyện. Các bảng `member_subscription` và `pt_booking` tham chiếu **trực tiếp bảng này** (không tham chiếu `user_account`) để bảo đảm chủ hợp đồng/ca tập chắc chắn là hội viên.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_member_profile_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE**. Trigger `trg_check_member_dob` kiểm tra đủ 12 tuổi khi thêm hồ sơ (BR-03) |
| health_notes | TEXT | None | Yes | NULL | Ghi chú tình trạng sức khỏe, tiền sử bệnh lý hoặc dị ứng |

## Bảng 3.2.2: TRAINER_PROFILE

**Mô tả:** Hồ sơ thông tin chuyên môn dành cho huấn luyện viên cá nhân (PT). Được `class_schedule` và `pt_booking` tham chiếu trực tiếp.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_trainer_profile_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE** |
| specialization | VARCHAR(100) | None | Yes | NULL | Lĩnh vực chuyên môn giảng dạy (Gym, Yoga, Pilates, Boxing...) |
| bio | TEXT | None | Yes | NULL | Tiểu sử cá nhân, kinh nghiệm công tác và bằng cấp chứng chỉ |
| current_rating | DECIMAL(3,2) | None | No | 5.00 | Điểm đánh giá trung bình từ hội viên. `chk_trainer_rating`: `current_rating >= 0.00 AND current_rating <= 5.00` (BR-11) |

## Bảng 3.2.3: STAFF_PROFILE

**Mô tả:** Hồ sơ công tác dành cho nhóm nhân viên vận hành (lễ tân, kỹ thuật viên). Được `maintenance_log` tham chiếu trực tiếp.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_staff_profile_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE** |
| job_title | VARCHAR(50) | None | No | None | Chức danh công việc (Receptionist, Technician, Manager) |
| department | VARCHAR(50) | None | No | None | Phòng ban công tác trực thuộc |
