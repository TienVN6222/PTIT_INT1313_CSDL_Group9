# Gym Membership & Personal Training Planner — Mock Data chia nhỏ

## Thứ tự chạy

1. `01_schema_ddl_fixed.sql` — chạy trước để tạo cấu trúc CSDL. File này nằm ngoài thư mục mock data trong gói ZIP tổng.
2. `01_reference_data.sql` — role, permission, phòng tập, gói tập.
3. `02_users_and_profiles.sql` — tài khoản, vai trò, hồ sơ hội viên/HLV/nhân viên.
4. `03_equipment.sql` — thiết bị.
5. `04_subscriptions_and_billing.sql` — hợp đồng và thanh toán.
6. `05_classes_and_enrollments.sql` — lịch lớp và đăng ký lớp. File này giữ nguyên logic tạo thêm đăng ký để `current_enrolled` khớp số lượng mục tiêu.
7. `06_pt_bookings.sql` — lịch tập PT 1-1.
8. `07_equipment_reservations.sql` — giữ chỗ thiết bị.
9. `08_maintenance_logs.sql` — nhật ký bảo trì.

## Chạy tự động bằng psql

Có thể chạy `00_run_all_mock_data.sql` bằng `psql` sau khi đã tạo schema. Ví dụ, đứng trong thư mục này và chạy:

```bash
psql -U postgres -d ten_database -f 00_run_all_mock_data.sql
```

`00_run_all_mock_data.sql` dùng lệnh `\i` của psql; lệnh này không phải SQL thuần và không chạy trực tiếp trong mọi giao diện như pgAdmin Query Tool. Nếu dùng pgAdmin/GUI khác, mở và chạy lần lượt 8 file theo thứ tự ở trên.

## Lưu ý

- Các file giữ nguyên dữ liệu và thứ tự phụ thuộc từ `02_mock_data_fixed.sql`; chỉ tách theo nhóm chức năng.
- Chạy trên CSDL thử nghiệm hoặc sao lưu trước. Không chạy lại trên CSDL đã có dữ liệu vì các bản ghi dùng ID cố định và có thể trùng khóa chính.
- Nếu một file báo lỗi, dừng lại và sửa lỗi trước khi chạy file tiếp theo.
