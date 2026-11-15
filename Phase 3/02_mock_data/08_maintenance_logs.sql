-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Nhật ký bảo trì thiết bị (ngày giờ tương đối theo CURRENT_DATE).

-- 15. NHẬT KÝ BẢO TRÌ SỬA CHỮA THIẾT BỊ (maintenance_log)
-- Bao gồm các ca đang sửa In_Progress (phục vụ Query 4; bắt đầu 6-10 ngày trước, chưa có end_time) và ca đã sửa Completed
-- (mỗi ca bắt đầu và kết thúc trong cùng một ngày, trong khung 08:00-17:00; không ca nào rơi vào 21:00-23:59).
-- ----------------------------------------------------------------------------
INSERT INTO maintenance_log (maintenance_id, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status, created_by_user_id) VALUES
-- Ca 1: Máy chạy bộ 3 hỏng cảm ứng - Đang sửa In_Progress (Kỹ thuật viên Phạm Quốc - id=4)
(1, 3, 4, 'Màn hình cảm ứng Skillrun bị đơ cảm ứng và lỗi motor nâng độ dốc', CURRENT_DATE - 10 + TIME '08:00', NULL, 3500000.00, 'In_Progress', 4),
-- Ca 2: Giường Pilates 13 đứt lò xo kháng lực - Đang sửa In_Progress
(2, 13, 4, 'Đứt 2 dây lò xo đỏ cường lực và rách đệm kê đầu vai', CURRENT_DATE - 7 + TIME '09:30', NULL, 1200000.00, 'In_Progress', 4),
-- Ca 3: Sàn đài boxing 15 bị lỏng cáp thép - Đang sửa In_Progress
(3, 15, 4, 'Căng lại hệ thống dây đai võ đài và thay mút bọc 4 góc bảo hộ', CURRENT_DATE - 6 + TIME '13:00', NULL, 4800000.00, 'In_Progress', 4),
-- Các ca đã hoàn thành trong quá khứ (4-11 rải trong ~10 tháng gần nhất)
(4, 1, 4, 'Bảo dưỡng tra dầu băng tải định kỳ và hiệu chuẩn cảm biến nhịp tim', CURRENT_DATE - 97 + TIME '08:00', CURRENT_DATE - 97 + TIME '11:30', 450000.00, 'Completed', 4),
(5, 2, 4, 'Thay thế thảm chạy bộ ma sát cao Technogym chính hãng', CURRENT_DATE - 123 + TIME '09:00', CURRENT_DATE - 123 + TIME '15:00', 2800000.00, 'Completed', 4),
(6, 4, 4, 'Cân chỉnh dây curoa truyền động và vệ sinh bánh đà kháng lực gió', CURRENT_DATE - 148 + TIME '14:00', CURRENT_DATE - 148 + TIME '16:30', 300000.00, 'Completed', 4),
(7, 5, 4, 'Thay chốt hãm an toàn trục ray trượt Smith Machine', CURRENT_DATE - 187 + TIME '10:00', CURRENT_DATE - 187 + TIME '11:30', 850000.00, 'Completed', 4),
(8, 7, 4, 'Thay 2 sợi cáp chịu lực 6mm bọc nylon bọc dàn ròng rọc', CURRENT_DATE - 211 + TIME '08:30', CURRENT_DATE - 211 + TIME '12:00', 1600000.00, 'Completed', 4),
(9, 9, 4, 'Thay dây xích kéo máy chèo và vệ sinh cảm biến vòng tua PM5', CURRENT_DATE - 234 + TIME '15:00', CURRENT_DATE - 234 + TIME '17:00', 650000.00, 'Completed', 4),
(10, 12, 4, 'Bôi trơn bánh xe trượt rãnh nhôm và cân chỉnh thanh chân đế', CURRENT_DATE - 274 + TIME '09:00', CURRENT_DATE - 274 + TIME '10:30', 250000.00, 'Completed', 4),
(11, 14, 4, 'Gia cố lại móc treo xích trần bê tông chống rung lắc bao cát', CURRENT_DATE - 299 + TIME '13:30', CURRENT_DATE - 299 + TIME '15:00', 400000.00, 'Completed', 4),
(12, 3, 4, 'Sửa lỗi board mạch nguồn biến tần đợt 1', CURRENT_DATE - 163 + TIME '08:00', CURRENT_DATE - 163 + TIME '16:00', 1500000.00, 'Completed', 4);

ALTER SEQUENCE maintenance_log_maintenance_id_seq RESTART WITH 13;

-- ----------------------------------------------------------------------------
