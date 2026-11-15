-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Hợp đồng đăng ký gói tập và nhật ký thanh toán.
-- Toàn bộ mốc thời gian được TÍNH TƯƠNG ĐỐI theo CURRENT_DATE tại thời điểm nạp dữ liệu, nên buổi demo
-- luôn có hợp đồng còn hạn, hợp đồng sắp hết hạn trong 7 ngày tới, hợp đồng đã hết hạn và doanh thu của
-- tháng/quý hiện tại. Cú pháp "CURRENT_DATE - 41 + TIME '08:00'" = 08:00 của ngày cách hôm nay 41 ngày.
-- Đảm bảo (CONTRACT): hợp đồng PT 1, 3, 6, 8, 10, 11, 12, 18 có hiệu lực từ <= hôm nay - 30 ngày đến >= hôm nay + 45 ngày.

-- 9. HỢP ĐỒNG ĐĂNG KÝ GÓI TẬP (member_subscription)
-- Rải đều trạng thái: Active, Expired, Suspended; có gói PT và gói thời gian
-- Có 3 gói sắp hết hạn trong 7 ngày tới (hợp đồng 4, 7, 15) phục vụ Query 4
-- ----------------------------------------------------------------------------
INSERT INTO member_subscription (subscription_id, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_by_user_id) VALUES
-- Hội viên 11 (Lê Hoàng Tiến): Gói PT 20 buổi đang Active
(1, 11, 6, 8000000.00, 16, CURRENT_DATE - 41 + TIME '08:00', CURRENT_DATE + 49 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 12 (Lê Hòa Thuận): Gói VIP 12 tháng đang Active
(2, 12, 4, 7200000.00, 0, CURRENT_DATE - 150 + TIME '08:00', CURRENT_DATE + 215 + TIME '22:00', 'Active', TRUE, 3),
-- Hội viên 13 (Trần Minh Tiến): Gói PT 10 buổi đang Active (còn 2 buổi)
(3, 13, 5, 4500000.00, 2, CURRENT_DATE - 35 + TIME '08:00', CURRENT_DATE + 55 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 14 (Võ Thị Mai Lan): Gói Semi-Annual 6 tháng sắp hết hạn trong vòng 3 ngày tới!
(4, 14, 3, 3900000.00, 0, CURRENT_DATE - 177 + TIME '08:00', CURRENT_DATE + 3 + TIME '22:00', 'Active', TRUE, 3),
-- Hội viên 15 (Nguyễn Thanh Tùng): Gói VIP 1 năm đang Active
(5, 15, 4, 7200000.00, 0, CURRENT_DATE - 198 + TIME '08:00', CURRENT_DATE + 167 + TIME '22:00', 'Active', TRUE, 3),
-- Hội viên 16 (Phạm Quỳnh Anh): Gói PT 20 buổi đang Active
(6, 16, 6, 8000000.00, 12, CURRENT_DATE - 40 + TIME '08:00', CURRENT_DATE + 50 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 17 (Đặng Thái Sơn): Gói Quarterly 3 tháng sắp hết hạn trong vòng 6 ngày tới!
(7, 17, 2, 2100000.00, 0, CURRENT_DATE - 84 + TIME '08:00', CURRENT_DATE + 6 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 18 (Trịnh Thăng Bình): Gói PT Elite 50 buổi đang Active
(8, 18, 7, 18500000.00, 42, CURRENT_DATE - 100 + TIME '08:00', CURRENT_DATE + 80 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 19 (Hồ Ngọc Hà): Gói VIP 1 năm đang Active
(9, 19, 4, 7200000.00, 0, CURRENT_DATE - 260 + TIME '08:00', CURRENT_DATE + 105 + TIME '22:00', 'Active', TRUE, 3),
-- Hội viên 20 (Dương Khắc Linh): Gói PT 10 buổi đã đăng ký nhưng CHƯA TỪNG ĐẶT LỊCH (phục vụ Query 7)
(10, 20, 5, 4500000.00, 10, CURRENT_DATE - 33 + TIME '08:00', CURRENT_DATE + 57 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 21 (Nguyễn Hoàng Đức): Gói PT 20 buổi đang Active
(11, 21, 6, 8000000.00, 15, CURRENT_DATE - 42 + TIME '08:00', CURRENT_DATE + 48 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 22 (Đoàn Văn Hậu): Gói PT 50 buổi đang Active
(12, 22, 7, 18500000.00, 38, CURRENT_DATE - 130 + TIME '08:00', CURRENT_DATE + 50 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 23 (Nguyễn Quang Hải): Gói Quarterly 3 tháng đang Active
(13, 23, 2, 2100000.00, 0, CURRENT_DATE - 60 + TIME '08:00', CURRENT_DATE + 30 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 24 (Châu Bùi): Gói VIP 1 năm đang Active
(14, 24, 4, 7200000.00, 0, CURRENT_DATE - 273 + TIME '08:00', CURRENT_DATE + 92 + TIME '22:00', 'Active', TRUE, 3),
-- Hội viên 25 (Khánh Vy): Gói Sinh viên 1 tháng sắp hết hạn trong vòng 2 ngày tới!
(15, 25, 8, 500000.00, 0, CURRENT_DATE - 28 + TIME '08:00', CURRENT_DATE + 2 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 26 (Nguyễn Trọng Hoàng): Gói cũ đã Expired
(16, 26, 2, 2100000.00, 0, CURRENT_DATE - 530 + TIME '08:00', CURRENT_DATE - 440 + TIME '22:00', 'Expired', FALSE, 3),
-- Hội viên 27 (Lê Công Vinh): Gói bị tạm đình chỉ Suspended
(17, 27, 3, 3900000.00, 0, CURRENT_DATE - 320 + TIME '08:00', CURRENT_DATE - 140 + TIME '22:00', 'Suspended', FALSE, 3),
-- Hội viên 28 (Trần Đình Trọng): Gói PT 10 buổi đang Active
(18, 28, 5, 4500000.00, 5, CURRENT_DATE - 32 + TIME '08:00', CURRENT_DATE + 58 + TIME '22:00', 'Active', FALSE, 3),
-- Hội viên 29 (Phan Tuấn Tài): Gói Sinh viên 1 tháng, bắt đầu từ đầu THÁNG HIỆN TẠI (hóa đơn nằm trong tháng/quý hiện tại)
(19, 29, 8, 500000.00, 0, DATE_TRUNC('month', CURRENT_DATE)::DATE + TIME '08:00', (DATE_TRUNC('month', CURRENT_DATE)::DATE + INTERVAL '1 month')::DATE + TIME '22:00', 'Active', TRUE, 3),
-- Hội viên 30 (Khuất Văn Khang): Gói Sinh viên 1 tháng, bắt đầu đầu tháng hiện tại (không muộn hơn hôm nay)
(20, 30, 8, 500000.00, 0, LEAST(CURRENT_DATE, DATE_TRUNC('month', CURRENT_DATE)::DATE + 4) + TIME '08:00', LEAST(CURRENT_DATE, DATE_TRUNC('month', CURRENT_DATE)::DATE + 4) + 30 + TIME '22:00', 'Active', TRUE, 3),
-- Thêm các hợp đồng cũ trong quá khứ để có dữ liệu doanh thu rải đều trong ~14 tháng gần nhất
(21, 11, 1, 800000.00, 0, CURRENT_DATE - 300 + TIME '08:00', CURRENT_DATE - 270 + TIME '22:00', 'Expired', FALSE, 3),
(22, 12, 2, 2100000.00, 0, CURRENT_DATE - 430 + TIME '08:00', CURRENT_DATE - 340 + TIME '22:00', 'Expired', FALSE, 3),
(23, 13, 1, 800000.00, 0, CURRENT_DATE - 225 + TIME '08:00', CURRENT_DATE - 195 + TIME '22:00', 'Expired', FALSE, 3),
(24, 15, 6, 8000000.00, 0, CURRENT_DATE - 410 + TIME '08:00', CURRENT_DATE - 320 + TIME '22:00', 'Expired', FALSE, 3),
(25, 18, 5, 4500000.00, 0, CURRENT_DATE - 280 + TIME '08:00', CURRENT_DATE - 235 + TIME '22:00', 'Expired', FALSE, 3),
(26, 19, 3, 3900000.00, 0, CURRENT_DATE - 440 + TIME '08:00', CURRENT_DATE - 260 + TIME '22:00', 'Expired', FALSE, 3),
(27, 21, 2, 2100000.00, 0, CURRENT_DATE - 250 + TIME '08:00', CURRENT_DATE - 160 + TIME '22:00', 'Expired', FALSE, 3),
(28, 22, 1, 800000.00, 0, CURRENT_DATE - 215 + TIME '08:00', CURRENT_DATE - 185 + TIME '22:00', 'Expired', FALSE, 3),
(29, 23, 1, 800000.00, 0, CURRENT_DATE - 180 + TIME '08:00', CURRENT_DATE - 150 + TIME '22:00', 'Expired', FALSE, 3),
(30, 24, 6, 8000000.00, 0, CURRENT_DATE - 420 + TIME '08:00', CURRENT_DATE - 330 + TIME '22:00', 'Expired', FALSE, 3);

ALTER SEQUENCE member_subscription_subscription_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
-- 10. NHẬT KÝ THANH TOÁN (billing_log)
-- Rải đều trong ~14 tháng gần nhất, gồm cả hóa đơn của THÁNG/QUÝ HIỆN TẠI (hợp đồng 19, 20) cho Query 1
-- ----------------------------------------------------------------------------
-- billing_period_start (BR-08) và payment_date = ngày bắt đầu hợp đồng tương ứng (hóa đơn của chu kỳ đầu tiên,
-- thanh toán ngay khi đăng ký); created_by_user_id (BR-23) = lễ tân (user_id = 3) lập hóa đơn. Cả hai được tính ngay
-- trong câu INSERT vì trigger tự điền chỉ được tạo ở 04_triggers_views.sql (nạp SAU dữ liệu mẫu).
-- invoice_no = INV-<yyyymmdd ngày thanh toán>-<billing_id> nên luôn duy nhất dù nạp vào ngày nào.
INSERT INTO billing_log (billing_id, subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status, created_by_user_id)
SELECT
    v.billing_id,
    v.subscription_id,
    ms.start_time::DATE,
    'INV-' || TO_CHAR(ms.start_time::DATE, 'YYYYMMDD') || '-' || LPAD(v.billing_id::TEXT, 3, '0'),
    v.amount,
    ms.start_time::DATE,
    v.payment_method,
    v.payment_status,
    3
FROM (VALUES
(1, 1, 8000000.00, 'Banking', 'Completed'),
(2, 2, 7200000.00, 'Credit_Card', 'Completed'),
(3, 3, 4500000.00, 'Credit_Card', 'Completed'),
(4, 4, 3900000.00, 'Banking', 'Completed'),
(5, 5, 7200000.00, 'Credit_Card', 'Completed'),
(6, 6, 8000000.00, 'Banking', 'Completed'),
(7, 7, 2100000.00, 'Cash', 'Completed'),
(8, 8, 18500000.00, 'Banking', 'Completed'),
(9, 9, 7200000.00, 'Credit_Card', 'Completed'),
(10, 10, 4500000.00, 'Credit_Card', 'Completed'),
(11, 11, 8000000.00, 'Banking', 'Completed'),
(12, 12, 18500000.00, 'Banking', 'Completed'),
(13, 13, 2100000.00, 'E_Wallet', 'Completed'),
(14, 14, 7200000.00, 'Credit_Card', 'Completed'),
(15, 15, 500000.00, 'E_Wallet', 'Completed'),
(16, 16, 2100000.00, 'Cash', 'Completed'),
(17, 17, 3900000.00, 'Banking', 'Completed'),
(18, 18, 4500000.00, 'Banking', 'Completed'),
(19, 19, 500000.00, 'E_Wallet', 'Completed'),
(20, 20, 500000.00, 'Cash', 'Completed'),
(21, 21, 800000.00, 'Cash', 'Completed'),
(22, 22, 2100000.00, 'Banking', 'Completed'),
(23, 23, 800000.00, 'E_Wallet', 'Completed'),
(24, 24, 8000000.00, 'Credit_Card', 'Completed'),
(25, 25, 4500000.00, 'Banking', 'Completed'),
(26, 26, 3900000.00, 'Credit_Card', 'Completed'),
(27, 27, 2100000.00, 'Banking', 'Completed'),
(28, 28, 800000.00, 'Cash', 'Completed'),
(29, 29, 800000.00, 'E_Wallet', 'Completed'),
(30, 30, 8000000.00, 'Credit_Card', 'Completed')
) AS v (billing_id, subscription_id, amount, payment_method, payment_status)
JOIN member_subscription AS ms ON ms.subscription_id = v.subscription_id;

ALTER SEQUENCE billing_log_billing_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
