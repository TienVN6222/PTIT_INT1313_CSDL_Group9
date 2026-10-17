-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Hợp đồng đăng ký gói tập và nhật ký thanh toán.

-- 9. HỢP ĐỒNG ĐĂNG KÝ GÓI TẬP (member_subscription)
-- Rải đều trạng thái: Active, Expired, Suspended, Pending; có gói PT và gói thời gian
-- Thời gian rải từ 2025 đến 2026, bao gồm các gói sắp hết hạn trong 7 ngày tới
-- ----------------------------------------------------------------------------
INSERT INTO member_subscription (subscription_id, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring) VALUES
-- Hội viên 11 (Lê Hoàng Tiến): Gói PT 20 buổi đang Active
(1, 11, 6, 8000000.00, 16, '2026-09-01 08:00:00', '2026-11-30 22:00:00', 'Active', FALSE),
-- Hội viên 12 (Lê Hòa Thuận): Gói VIP 12 tháng đang Active
(2, 12, 4, 7200000.00, 0, '2026-01-01 06:00:00', '2026-12-31 22:00:00', 'Active', TRUE),
-- Hội viên 13 (Trần Minh Tiến): Gói PT 10 buổi sắp hết hạn trong vòng 5 ngày tới!
(3, 13, 5, 4500000.00, 2, '2026-09-01 08:00:00', CURRENT_TIMESTAMP + INTERVAL '5 days', 'Active', FALSE),
-- Hội viên 14 (Võ Thị Mai Lan): Gói Semi-Annual 6 tháng sắp hết hạn trong vòng 3 ngày tới!
(4, 14, 3, 3900000.00, 0, '2026-04-15 08:00:00', CURRENT_TIMESTAMP + INTERVAL '3 days', 'Active', TRUE),
-- Hội viên 15 (Nguyễn Thanh Tùng): Gói VIP 1 năm đang Active
(5, 15, 4, 7200000.00, 0, '2026-05-01 00:00:00', '2027-05-01 00:00:00', 'Active', TRUE),
-- Hội viên 16 (Phạm Quỳnh Anh): Gói PT 20 buổi đang Active
(6, 16, 6, 8000000.00, 12, '2026-08-15 08:00:00', '2026-11-15 22:00:00', 'Active', FALSE),
-- Hội viên 17 (Đặng Thái Sơn): Gói Quarterly 3 tháng đang Active
(7, 17, 2, 2100000.00, 0, '2026-08-01 08:00:00', '2026-11-01 22:00:00', 'Active', FALSE),
-- Hội viên 18 (Trịnh Thăng Bình): Gói PT Elite 50 buổi đang Active
(8, 18, 7, 18500000.00, 42, '2026-07-01 08:00:00', '2026-12-31 22:00:00', 'Active', FALSE),
-- Hội viên 19 (Hồ Ngọc Hà): Gói VIP 1 năm đang Active
(9, 19, 4, 7200000.00, 0, '2026-03-01 08:00:00', '2027-03-01 22:00:00', 'Active', TRUE),
-- Hội viên 20 (Dương Khắc Linh): Gói PT 10 buổi đã đăng ký nhưng CHƯA TỪNG ĐẶT LỊCH (phục vụ Query 7)
(10, 20, 5, 4500000.00, 10, '2026-09-20 08:00:00', '2026-11-05 22:00:00', 'Active', FALSE),
-- Hội viên 21 (Nguyễn Hoàng Đức): Gói PT 20 buổi đang Active
(11, 21, 6, 8000000.00, 15, '2026-08-20 08:00:00', '2026-11-20 22:00:00', 'Active', FALSE),
-- Hội viên 22 (Đoàn Văn Hậu): Gói PT 50 buổi đang Active
(12, 22, 7, 18500000.00, 38, '2026-06-01 08:00:00', '2026-12-01 22:00:00', 'Active', FALSE),
-- Hội viên 23 (Nguyễn Quang Hải): Gói Quarterly 3 tháng đang Active
(13, 23, 2, 2100000.00, 0, '2026-08-15 08:00:00', '2026-11-15 22:00:00', 'Active', FALSE),
-- Hội viên 24 (Châu Bùi): Gói VIP 1 năm đang Active
(14, 24, 4, 7200000.00, 0, '2026-02-15 08:00:00', '2027-02-15 22:00:00', 'Active', TRUE),
-- Hội viên 25 (Khánh Vy): Gói Sinh viên 1 tháng sắp hết hạn trong vòng 2 ngày tới!
(15, 25, 8, 500000.00, 0, '2026-09-15 08:00:00', CURRENT_TIMESTAMP + INTERVAL '2 days', 'Active', FALSE),
-- Hội viên 26 (Nguyễn Trọng Hoàng): Gói cũ đã Expired
(16, 26, 2, 2100000.00, 0, '2025-06-01 08:00:00', '2025-09-01 22:00:00', 'Expired', FALSE),
-- Hội viên 27 (Lê Công Vinh): Gói bị tạm đình chỉ Suspended
(17, 27, 3, 3900000.00, 0, '2026-01-01 08:00:00', '2026-07-01 22:00:00', 'Suspended', FALSE),
-- Hội viên 28 (Trần Đình Trọng): Gói PT 10 buổi đang Active
(18, 28, 5, 4500000.00, 5, '2026-09-10 08:00:00', '2026-10-25 22:00:00', 'Active', FALSE),
-- Hội viên 29 (Phan Tuấn Tài): Gói Sinh viên 1 tháng đang Active
(19, 29, 8, 500000.00, 0, '2026-10-01 08:00:00', '2026-10-31 22:00:00', 'Active', TRUE),
-- Hội viên 30 (Khuất Văn Khang): Gói Sinh viên 1 tháng đang Active
(20, 30, 8, 500000.00, 0, '2026-10-05 08:00:00', '2026-11-05 22:00:00', 'Active', TRUE),
-- Thêm các hợp đồng cũ trong quá khứ để có dữ liệu doanh thu đa dạng theo các quý
(21, 11, 1, 800000.00, 0, '2026-01-10 08:00:00', '2026-02-10 22:00:00', 'Expired', FALSE),
(22, 12, 2, 2100000.00, 0, '2025-09-01 08:00:00', '2025-12-01 22:00:00', 'Expired', FALSE),
(23, 13, 1, 800000.00, 0, '2026-04-01 08:00:00', '2026-05-01 22:00:00', 'Expired', FALSE),
(24, 15, 6, 8000000.00, 0, '2025-10-01 08:00:00', '2026-01-01 22:00:00', 'Expired', FALSE),
(25, 18, 5, 4500000.00, 0, '2026-02-01 08:00:00', '2026-03-20 22:00:00', 'Expired', FALSE),
(26, 19, 3, 3900000.00, 0, '2025-08-01 08:00:00', '2026-02-01 22:00:00', 'Expired', FALSE),
(27, 21, 2, 2100000.00, 0, '2026-03-10 08:00:00', '2026-06-10 22:00:00', 'Expired', FALSE),
(28, 22, 1, 800000.00, 0, '2026-04-10 08:00:00', '2026-05-10 22:00:00', 'Expired', FALSE),
(29, 23, 1, 800000.00, 0, '2026-05-15 08:00:00', '2026-06-15 22:00:00', 'Expired', FALSE),
(30, 24, 6, 8000000.00, 0, '2025-11-01 08:00:00', '2026-02-01 22:00:00', 'Expired', FALSE);

ALTER SEQUENCE member_subscription_subscription_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
-- 10. NHẬT KÝ THANH TOÁN (billing_log)
-- Rải đều khắp các quý (Q1, Q2, Q3, Q4) năm 2025 và 2026
-- ----------------------------------------------------------------------------
INSERT INTO billing_log (billing_id, subscription_id, invoice_no, amount, payment_date, payment_method, payment_status) VALUES
(1, 1, 'INV-2026-0901', 8000000.00, '2026-09-01', 'Banking', 'Completed'),
(2, 2, 'INV-2026-0101', 7200000.00, '2026-01-01', 'Credit_Card', 'Completed'),
(3, 3, 'INV-2026-0902', 4500000.00, '2026-09-01', 'Credit_Card', 'Completed'),
(4, 4, 'INV-2026-0415', 3900000.00, '2026-04-15', 'Banking', 'Completed'),
(5, 5, 'INV-2026-0501', 7200000.00, '2026-05-01', 'Credit_Card', 'Completed'),
(6, 6, 'INV-2026-0815', 8000000.00, '2026-08-15', 'Banking', 'Completed'),
(7, 7, 'INV-2026-0801', 2100000.00, '2026-08-01', 'Cash', 'Completed'),
(8, 8, 'INV-2026-0701', 18500000.00, '2026-07-01', 'Banking', 'Completed'),
(9, 9, 'INV-2026-0301', 7200000.00, '2026-03-01', 'Credit_Card', 'Completed'),
(10, 10, 'INV-2026-0920', 4500000.00, '2026-09-20', 'Credit_Card', 'Completed'),
(11, 11, 'INV-2026-0820', 8000000.00, '2026-08-20', 'Banking', 'Completed'),
(12, 12, 'INV-2026-0601', 18500000.00, '2026-06-01', 'Banking', 'Completed'),
(13, 13, 'INV-2026-0816', 2100000.00, '2026-08-15', 'E_Wallet', 'Completed'),
(14, 14, 'INV-2026-0215', 7200000.00, '2026-02-15', 'Credit_Card', 'Completed'),
(15, 15, 'INV-2026-0915', 500000.00, '2026-09-15', 'E_Wallet', 'Completed'),
(16, 16, 'INV-2025-0601', 2100000.00, '2025-06-01', 'Cash', 'Completed'),
(17, 17, 'INV-2026-0102', 3900000.00, '2026-01-01', 'Banking', 'Completed'),
(18, 18, 'INV-2026-0910', 4500000.00, '2026-09-10', 'Banking', 'Completed'),
(19, 19, 'INV-2026-1001', 500000.00, '2026-10-01', 'E_Wallet', 'Completed'),
(20, 20, 'INV-2026-1005', 500000.00, '2026-10-05', 'Cash', 'Completed'),
(21, 21, 'INV-2026-0110', 800000.00, '2026-01-10', 'Cash', 'Completed'),
(22, 22, 'INV-2025-0901', 2100000.00, '2025-09-01', 'Banking', 'Completed'),
(23, 23, 'INV-2026-0401', 800000.00, '2026-04-01', 'E_Wallet', 'Completed'),
(24, 24, 'INV-2025-1001', 8000000.00, '2025-10-01', 'Credit_Card', 'Completed'),
(25, 25, 'INV-2026-0201', 4500000.00, '2026-02-01', 'Banking', 'Completed'),
(26, 26, 'INV-2025-0801', 3900000.00, '2025-08-01', 'Credit_Card', 'Completed'),
(27, 27, 'INV-2026-0310', 2100000.00, '2026-03-10', 'Banking', 'Completed'),
(28, 28, 'INV-2026-0410', 800000.00, '2026-04-10', 'Cash', 'Completed'),
(29, 29, 'INV-2026-0515', 800000.00, '2026-05-15', 'E_Wallet', 'Completed'),
(30, 30, 'INV-2025-1101', 8000000.00, '2025-11-01', 'Credit_Card', 'Completed');

ALTER SEQUENCE billing_log_billing_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
