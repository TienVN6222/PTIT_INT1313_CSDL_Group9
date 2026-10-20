# PHẦN 3: GÓI TẬP & THANH TOÁN (SUBSCRIPTIONS & BILLING)

Quản lý gói dịch vụ phòng tập, hợp đồng đăng ký hội viên và nhật ký hóa đơn gia hạn tự động bất biến.

## Bảng 3.3.1: MEMBERSHIP_PLAN

**Mô tả:** Danh mục các gói tập tiêu chuẩn được phòng tập kinh doanh.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| plan_id | INT | PK | No | AUTO_INCREMENT | Mã định danh gói tập |
| plan_name | VARCHAR(100) | None | No | None | Tên hiển thị gói tập (VD: Gói VIP 12 Tháng, Gói PT 20 Buổi) |
| duration_days | INT | None | No | None | Thời hạn có hiệu lực tính theo ngày (CHECK: duration_days > 0) (BR-04) |
| total_sessions | INT | None | No | 0 | Tổng số buổi tập PT được cấp (gán = 0 nếu là gói thời gian) |
| price | DECIMAL(10,2) | None | No | None | Đơn giá niêm yết của gói tập (CHECK: price >= 0) (BR-04) |
| description | TEXT | None | Yes | NULL | Mô tả chi tiết các đặc quyền và điều khoản gói tập |

## Bảng 3.3.2: MEMBER_SUBSCRIPTION

**Mô tả:** Hợp đồng đăng ký gói tập cụ thể của hội viên.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| subscription_id | INT | PK | No | AUTO_INCREMENT | Mã định danh hợp đồng đăng ký |
| member_user_id | INT | FK | No | None | Ref USER_ACCOUNT(user_id) (Hội viên đứng tên hợp đồng) (BR-05) |
| plan_id | INT | FK | No | None | Ref MEMBERSHIP_PLAN(plan_id) (Gói tập đã chọn) |
| actual_price | DECIMAL(10,2) | None | No | None | Giá bán thực tế lưu tại thời điểm ký (độc lập với giá niêm yết) |
| remaining_sessions | INT | None | No | 0 | Số buổi PT còn lại trong gói (CHECK: remaining_sessions >= 0) (BR-18) |
| start_time | DATETIME | None | No | None | Thời điểm hợp đồng bắt đầu tính hiệu lực |
| end_time | DATETIME | None | No | None | Thời điểm hợp đồng hết hiệu lực; CHECK (end_time >= start_time) (BR-06) |
| sub_status | VARCHAR(20) | None | No | 'Pending' | Trạng thái hợp đồng: 'Active', 'Expired', 'Suspended' (BR-07) |
| is_recurring | BOOLEAN | None | No | FALSE | Cấu hình tự động tạo hóa đơn gia hạn lặp đi lặp lại (BR-24) |

## Bảng 3.3.3: BILLING_LOG

**Mô tả:** Nhật ký lưu vết giao dịch thanh toán hóa đơn bất biến (Immutable Billing Log).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| billing_id | INT | PK | No | AUTO_INCREMENT | Mã nhật ký giao dịch thanh toán |
| subscription_id | INT | FK | No | None | Ref MEMBER_SUBSCRIPTION(subscription_id) (BR-08) |
| invoice_no | VARCHAR(50) | None | No | None | Số hóa đơn duy nhất toàn hệ thống (UNIQUE) (BR-09) |
| amount | DECIMAL(10,2) | None | No | None | Số tiền thanh toán thực tế (CHECK: amount > 0) (BR-09) |
| payment_date | DATE | None | No | None | Ngày phát sinh giao dịch thanh toán thành công |
| payment_method | VARCHAR(50) | None | No | None | Phương thức thanh toán ('Cash', 'Credit_Card', 'Banking') |
| payment_status | VARCHAR(20) | None | No | 'Completed' | Trạng thái hóa đơn (Bản ghi bất biến tuyệt đối không sửa/xóa) (BR-10) |
