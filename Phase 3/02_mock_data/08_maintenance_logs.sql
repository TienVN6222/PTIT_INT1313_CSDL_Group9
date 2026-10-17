-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Nhật ký bảo trì thiết bị.

-- 15. NHẬT KÝ BẢO TRÌ SỬA CHỮA THIẾT BỊ (maintenance_log)
-- Bao gồm các ca đang sửa In_Progress (phục vụ Query 4) và ca đã sửa Completed
-- ----------------------------------------------------------------------------
INSERT INTO maintenance_log (maintenance_id, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status) VALUES
-- Ca 1: Máy chạy bộ 3 hỏng cảm ứng - Đang sửa In_Progress (Kỹ thuật viên Phạm Quốc - id=4)
(1, 3, 4, 'Màn hình cảm ứng Skillrun bị đơ cảm ứng và lỗi motor nâng độ dốc', '2026-10-05 08:00:00', NULL, 3500000.00, 'In_Progress'),
-- Ca 2: Giường Pilates 13 đứt lò xo kháng lực - Đang sửa In_Progress
(2, 13, 4, 'Đứt 2 dây lò xo đỏ cường lực và rách đệm kê đầu vai', '2026-10-08 09:30:00', NULL, 1200000.00, 'In_Progress'),
-- Ca 3: Sàn đài boxing 15 bị lỏng cáp thép - Đang sửa In_Progress
(3, 15, 4, 'Căng lại hệ thống dây đai võ đài và thay mút bọc 4 góc bảo hộ', '2026-10-09 13:00:00', NULL, 4800000.00, 'In_Progress'),
-- Các ca đã hoàn thành trong quá khứ
(4, 1, 4, 'Bảo dưỡng tra dầu băng tải định kỳ và hiệu chuẩn cảm biến nhịp tim', '2026-08-10 08:00:00', '2026-08-10 11:30:00', 450000.00, 'Completed'),
(5, 2, 4, 'Thay thế thảm chạy bộ ma sát cao Technogym chính hãng', '2026-07-15 09:00:00', '2026-07-15 15:00:00', 2800000.00, 'Completed'),
(6, 4, 4, 'Cân chỉnh dây curoa truyền động và vệ sinh bánh đà kháng lực gió', '2026-06-20 14:00:00', '2026-06-20 16:30:00', 300000.00, 'Completed'),
(7, 5, 4, 'Thay chốt hãm an toàn trục ray trượt Smith Machine', '2026-05-12 10:00:00', '2026-05-12 11:30:00', 850000.00, 'Completed'),
(8, 7, 4, 'Thay 2 sợi cáp chịu lực 6mm bọc nylon bọc dàn ròng rọc', '2026-04-18 08:30:00', '2026-04-18 12:00:00', 1600000.00, 'Completed'),
(9, 9, 4, 'Thay dây xích kéo máy chèo và vệ sinh cảm biến vòng tua PM5', '2026-03-25 15:00:00', '2026-03-25 17:00:00', 650000.00, 'Completed'),
(10, 12, 4, 'Bôi trơn bánh xe trượt rãnh nhôm và cân chỉnh thanh chân đế', '2026-02-14 09:00:00', '2026-02-14 10:30:00', 250000.00, 'Completed'),
(11, 14, 4, 'Gia cố lại móc treo xích trần bê tông chống rung lắc bao cát', '2026-01-20 13:30:00', '2026-01-20 15:00:00', 400000.00, 'Completed'),
(12, 3, 4, 'Sửa lỗi board mạch nguồn biến tần đợt 1', '2026-06-05 08:00:00', '2026-06-05 16:00:00', 1500000.00, 'Completed');

ALTER SEQUENCE maintenance_log_maintenance_id_seq RESTART WITH 13;
