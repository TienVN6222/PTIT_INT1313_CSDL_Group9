# PHẦN 3: GÓI TẬP & THANH TOÁN (SUBSCRIPTIONS & BILLING)

Quản lý gói dịch vụ phòng tập, hợp đồng đăng ký hội viên và nhật ký hóa đơn gia hạn tự động bất biến.

## Bảng 3.3.1: MEMBERSHIP_PLAN

**Mô tả:** Danh mục các gói tập tiêu chuẩn được phòng tập kinh doanh.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| plan_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh gói tập. `pk_membership_plan` |
| plan_name | VARCHAR(100) | None | No | None | Tên hiển thị gói tập (VD: Gói VIP 12 Tháng, Gói PT 20 Buổi) |
| duration_days | INT | None | No | None | Thời hạn hiệu lực tính theo ngày. `chk_membership_plan_duration`: `duration_days > 0` (BR-04) |
| total_sessions | INT | None | No | 0 | Tổng số buổi PT được cấp (0 nếu là gói thời gian). `chk_membership_plan_sessions`: `total_sessions >= 0` |
| price | DECIMAL(10,2) | None | No | None | Đơn giá niêm yết của gói tập. `chk_membership_plan_price`: `price >= 0` (BR-04) |
| description | TEXT | None | Yes | NULL | Mô tả chi tiết các đặc quyền và điều khoản gói tập |

## Bảng 3.3.2: MEMBER_SUBSCRIPTION

**Mô tả:** Hợp đồng đăng ký gói tập cụ thể của hội viên.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| subscription_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh hợp đồng đăng ký. `pk_member_subscription` |
| member_user_id | INT | FK | No | None | Hội viên đứng tên hợp đồng. `fk_subscription_member` → **MEMBER_PROFILE**(user_id) **ON DELETE RESTRICT** (BR-05). Cùng `subscription_id` tạo thành `uq_subscription_member (subscription_id, member_user_id)` làm đích cho khóa ngoại ghép của PT_BOOKING |
| plan_id | INT | FK | No | None | Gói tập đã chọn. `fk_subscription_plan` → MEMBERSHIP_PLAN(plan_id) **ON DELETE RESTRICT** |
| actual_price | DECIMAL(10,2) | None | No | None | Giá bán thực tế chốt tại thời điểm ký (độc lập với giá niêm yết). `chk_subscription_price`: `actual_price >= 0` |
| remaining_sessions | INT | None | No | 0 | Số buổi PT còn lại. `chk_subscription_remaining`: `remaining_sessions >= 0`. Trigger `trg_update_remaining_pt_sessions` trừ buổi khi ca PT chuyển sang Completed / Late_Cancelled / No_Show (BR-18, BR-25) |
| start_time | TIMESTAMP | None | No | None | Thời điểm hợp đồng bắt đầu có hiệu lực |
| end_time | TIMESTAMP | None | No | None | Thời điểm hết hiệu lực. `chk_subscription_dates`: `end_time >= start_time` (BR-06) |
| sub_status | VARCHAR(20) | None | No | 'Pending' | Trạng thái hợp đồng. `chk_subscription_status`: `IN ('Pending', 'Active', 'Expired', 'Suspended', 'Cancelled')`. Trigger `trg_require_payment_before_active` chỉ cho 'Active' khi đã có hóa đơn Completed; `trg_activate_on_payment_insert/_update` tự kích hoạt khi thanh toán (BR-07) |
| is_recurring | BOOLEAN | None | No | FALSE | Cấu hình tự động gia hạn định kỳ; thủ tục `sp_process_subscription_renewals(p_as_of, p_grace_days)` phát hành hóa đơn gia hạn / chuyển Expired / Suspended (BR-24) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo hợp đồng |
| created_by_user_id | INT | FK | No | None | Người thực hiện thao tác tạo hợp đồng, bắt buộc (BR-23). `fk_subscription_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa hợp đồng lần gần nhất (BR-23). `fk_subscription_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `uq_member_one_active_subscription`: UNIQUE INDEX một phần trên `(member_user_id) WHERE sub_status = 'Active'`, mỗi hội viên có tối đa 1 hợp đồng Active tại một thời điểm (BR-05).
- Chỉ mục: `idx_member_subscription_member (member_user_id)`, `idx_member_subscription_status (sub_status)`, `idx_member_subscription_dates (start_time, end_time)`.

## Bảng 3.3.3: BILLING_LOG

**Mô tả:** Nhật ký lưu vết giao dịch thanh toán hóa đơn bất biến (Immutable Billing Log).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| billing_id | SERIAL | PK | No | SERIAL (nextval) | Mã nhật ký giao dịch thanh toán. `pk_billing_log` |
| subscription_id | INT | FK | No | None | Hợp đồng được thanh toán. `fk_billing_subscription` → MEMBER_SUBSCRIPTION(subscription_id) **ON DELETE RESTRICT** (BR-08) |
| billing_period_start | DATE | None | No | None | Ngày bắt đầu chu kỳ tính phí mà hóa đơn chi trả. Nếu INSERT bỏ trống, trigger `trg_fill_billing_period_start` điền `start_time::DATE` của hợp đồng. Thành phần của chỉ mục duy nhất một phần `uq_billing_subscription_period` (BR-08) |
| invoice_no | VARCHAR(50) | UK | No | None | Số hóa đơn duy nhất toàn hệ thống. `uq_billing_invoice_no` (BR-09) |
| amount | DECIMAL(10,2) | None | No | None | Số tiền thanh toán thực tế. `chk_billing_amount`: `amount > 0` (BR-09) |
| payment_date | DATE | None | No | None | Ngày phát sinh giao dịch thanh toán |
| payment_method | VARCHAR(50) | None | No | None | Phương thức thanh toán. `chk_billing_method`: `IN ('Cash', 'Credit_Card', 'Banking', 'E_Wallet')` |
| payment_status | VARCHAR(20) | None | No | 'Completed' | Trạng thái hóa đơn. `chk_billing_status`: `IN ('Pending', 'Completed', 'Failed', 'Refunded')`. Bản ghi bất biến: trigger `trg_billing_immutable_update/_delete/_truncate` chặn sửa/xóa/TRUNCATE (BR-10) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm ghi nhận hóa đơn |
| created_by_user_id | INT | FK | No | None | Người lập hóa đơn, bắt buộc (BR-23). `fk_billing_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa hóa đơn lần gần nhất (chỉ Completed→Refunded hoặc Pending→Completed/Failed, BR-10) (BR-23). `fk_billing_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `uq_billing_subscription_period`: UNIQUE INDEX một phần `(subscription_id, billing_period_start) WHERE payment_status IN ('Pending', 'Completed')`. Mỗi chu kỳ của một hợp đồng chỉ có tối đa 1 hóa đơn còn hiệu lực; hóa đơn Failed/Refunded không chiếm chu kỳ nên được phát hành lại (BR-08).
- Chỉ mục: `idx_billing_log_subscription_date (subscription_id, payment_date DESC)`, `idx_billing_log_payment_date (payment_date)`.
- Trigger kích hoạt hợp đồng khi thanh toán: `trg_activate_on_payment_insert` (AFTER INSERT), `trg_activate_on_payment_update` (AFTER UPDATE OF payment_status) (BR-07, BR-24).
