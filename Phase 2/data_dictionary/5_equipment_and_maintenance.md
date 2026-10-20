# PHẦN 5: QUẢN LÝ THIẾT BỊ & BẢO TRÌ (FACILITIES & MAINTENANCE)

Quản lý thiết bị máy tập, theo dõi khấu hao, lịch sử giữ chỗ máy cho buổi tập và nhật ký sửa chữa, bảo trì.

## Bảng 3.5.1: EQUIPMENT

**Mô tả:** Danh mục thiết bị và máy móc thể hình trang bị tại phòng tập.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| equipment_id | INT | PK | No | AUTO_INCREMENT | Mã định danh thiết bị / máy tập |
| room_id | INT | FK | No | None | Ref FACILITIES_ROOM(room_id) (Vị trí phòng đặt máy) |
| equipment_name | VARCHAR(100) | None | No | None | Tên thiết bị (VD: Máy chạy bộ Technogym Run 1000) |
| serial_number | VARCHAR(100) | None | No | None | Mã series thiết bị duy nhất (UNIQUE) |
| purchase_date | DATE | None | No | None | Ngày nhập mua đưa vào sử dụng (BR-26) |
| depreciation_months | INT | None | No | None | Số tháng dự kiến khấu hao tài sản (CHECK: depreciation_months > 0) (BR-26) |
| status | VARCHAR(20) | None | No | 'Operational' | Trạng thái máy: 'Operational', 'Under_Maintenance' (BR-19) |

## Bảng 3.5.2: EQUIPMENT_RESERVATION

**Mô tả:** Lịch đăng ký giữ chỗ trước máy tập cho ca PT hoặc lớp học, nhằm tránh trùng thiết bị.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| reservation_id | INT | PK | No | AUTO_INCREMENT | Mã lượt đăng ký giữ chỗ máy |
| equipment_id | INT | FK | No | None | Ref EQUIPMENT(equipment_id) (Thiết bị được đặt trước) |
| booking_id | INT | FK | Yes | NULL | Ref PT_BOOKING(booking_id) (Nối với ca PT 1-1 nếu giữ cho PT) (BR-21) |
| class_id | INT | FK | Yes | NULL | Ref CLASS_SCHEDULE(class_id) (Nối với lớp nhóm nếu giữ cho lớp) (BR-21) |
| start_time | DATETIME | None | No | None | Thời điểm bắt đầu giữ chỗ sử dụng máy |
| end_time | DATETIME | None | No | None | Thời điểm kết thúc giữ chỗ sử dụng máy |
| status | VARCHAR(20) | None | No | 'Reserved' | Trạng thái: 'Reserved', 'Completed', 'Cancelled' |

## Bảng 3.5.3: MAINTENANCE_LOG

**Mô tả:** Nhật ký ghi nhận sự cố hư hỏng và tiến độ bảo trì thiết bị.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| maintenance_id | INT | PK | No | AUTO_INCREMENT | Mã nhật ký bảo trì thiết bị |
| equipment_id | INT | FK | No | None | Ref EQUIPMENT(equipment_id) (Mã máy tập cần sửa chữa) |
| staff_user_id | INT | FK | No | None | Ref USER_ACCOUNT(user_id) (Kỹ thuật viên chịu trách nhiệm xử lý) |
| issue_description | TEXT | None | No | None | Mô tả chi tiết sự cố hư hỏng hoặc lý do bảo trì |
| start_time | DATETIME | None | No | None | Thời điểm bắt đầu tiến hành bảo trì |
| end_time | DATETIME | None | Yes | NULL | Thời điểm hoàn thành sửa chữa; CHECK (end_time >= start_time) (BR-20) |
| cost | DECIMAL(10,2) | None | No | 0.00 | Chi phí sửa chữa thay thế linh kiện (CHECK: cost >= 0) (BR-20) |
| status | VARCHAR(20) | None | No | 'In_Progress' | Trạng thái xử lý: 'In_Progress', 'Completed' |
