# PHẦN 5: QUẢN LÝ THIẾT BỊ & BẢO TRÌ (FACILITIES & MAINTENANCE)

Quản lý thiết bị máy tập, theo dõi khấu hao, lịch sử giữ chỗ máy cho buổi tập và nhật ký sửa chữa, bảo trì.

## Bảng 3.5.1: EQUIPMENT

**Mô tả:** Danh mục thiết bị và máy móc thể hình trang bị tại phòng tập.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| equipment_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh thiết bị / máy tập. `pk_equipment` |
| room_id | INT | FK | No | None | Vị trí phòng đặt máy. `fk_equipment_room` → FACILITIES_ROOM(room_id) **ON DELETE RESTRICT** |
| equipment_name | VARCHAR(100) | None | No | None | Tên thiết bị (VD: Máy chạy bộ Technogym Run 1000) |
| serial_number | VARCHAR(100) | UK | No | None | Mã series thiết bị duy nhất. `uq_equipment_serial` |
| purchase_date | DATE | None | No | None | Ngày nhập mua đưa vào sử dụng (BR-26) |
| depreciation_months | INT | None | No | None | Số tháng khấu hao dự kiến. `chk_equipment_depreciation`: `depreciation_months > 0` (BR-26) |
| status | VARCHAR(20) | None | No | 'Operational' | Trạng thái máy. `chk_equipment_status`: `IN ('Operational', 'Under_Maintenance', 'Decommissioned')`. Trigger `trg_prevent_equipment_reservation_under_maintenance` cấm giữ chỗ máy không 'Operational' (BR-19) |

**Chỉ mục:** `idx_equipment_status (status)`.

## Bảng 3.5.2: EQUIPMENT_RESERVATION

**Mô tả:** Lịch giữ chỗ trước máy tập cho ca PT hoặc lớp học, nhằm tránh trùng thiết bị.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| reservation_id | SERIAL | PK | No | SERIAL (nextval) | Mã lượt giữ chỗ máy. `pk_equipment_reservation` |
| equipment_id | INT | FK | No | None | Thiết bị được đặt trước. `fk_reservation_equipment` → EQUIPMENT(equipment_id) **ON DELETE CASCADE** |
| booking_id | INT | FK | Yes | NULL | Ca PT 1-1 nếu giữ cho PT. `fk_reservation_booking` → PT_BOOKING(booking_id) **ON DELETE CASCADE** (BR-21) |
| class_id | INT | FK | Yes | NULL | Lớp nhóm nếu giữ cho lớp. `fk_reservation_class` → CLASS_SCHEDULE(class_id) **ON DELETE CASCADE** (BR-21) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu giữ chỗ |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc giữ chỗ. `chk_reservation_time`: `end_time > start_time` |
| status | VARCHAR(20) | None | No | 'Reserved' | Trạng thái. `chk_reservation_status`: `IN ('Reserved', 'Completed', 'Cancelled')` |

**Ràng buộc cấp bảng:**

- `chk_reservation_source`: đúng một trong `booking_id`, `class_id` khác NULL (exclusive arc).
- `ex_reservation_equipment_no_overlap`: EXCLUDE USING gist `(equipment_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status <> 'Cancelled')`, một thiết bị không bị giữ trùng giờ (BR-21).
- Trigger: `trg_check_reservation_window` (khung giờ giữ chỗ nằm trong buổi tập và không rơi vào lịch bảo trì: BR-21), `trg_prevent_equipment_reservation_under_maintenance` (BR-19).

## Bảng 3.5.3: MAINTENANCE_LOG

**Mô tả:** Nhật ký ghi nhận sự cố hư hỏng và tiến độ bảo trì thiết bị.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| maintenance_id | SERIAL | PK | No | SERIAL (nextval) | Mã nhật ký bảo trì. `pk_maintenance_log` |
| equipment_id | INT | FK | No | None | Máy tập cần sửa chữa. `fk_maintenance_equipment` → EQUIPMENT(equipment_id) **ON DELETE RESTRICT** |
| staff_user_id | INT | FK | No | None | Kỹ thuật viên xử lý. `fk_maintenance_staff` → **STAFF_PROFILE**(user_id) **ON DELETE RESTRICT** |
| issue_description | TEXT | None | No | None | Mô tả sự cố hoặc lý do bảo trì |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu bảo trì |
| end_time | TIMESTAMP | None | Yes | NULL | Thời điểm hoàn thành (NULL khi đang xử lý). `chk_maintenance_time`: `end_time IS NULL OR end_time >= start_time` (BR-20) |
| cost | DECIMAL(10,2) | None | No | 0.00 | Chi phí sửa chữa. `chk_maintenance_cost`: `cost >= 0` (BR-20) |
| status | VARCHAR(20) | None | No | 'In_Progress' | Trạng thái xử lý. `chk_maintenance_status`: `IN ('In_Progress', 'Completed', 'Cancelled')` |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo bản ghi |
| created_by_user_id | INT | FK | Yes | NULL | Người ghi nhận. `fk_maintenance_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; điền bởi `trg_fill_created_by` (BR-23) |

**Chỉ mục:** `idx_maintenance_log_equipment (equipment_id)`.
