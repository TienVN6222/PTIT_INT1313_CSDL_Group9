-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Danh sách thiết bị phòng tập.

-- 8. THIẾT BỊ PHÒNG TẬP (equipment)
-- ----------------------------------------------------------------------------
INSERT INTO equipment (equipment_id, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status) VALUES
(1, 2, 'Máy chạy bộ Technogym Skillrun 7000', 'TG-RUN-2023-001', '2023-01-15', 36, 'Operational'),
(2, 2, 'Máy chạy bộ Technogym Skillrun 7000', 'TG-RUN-2023-002', '2023-01-15', 36, 'Operational'),
(3, 2, 'Máy chạy bộ Technogym Skillrun 7000', 'TG-RUN-2023-003', '2023-01-15', 36, 'Under_Maintenance'), -- Đang hỏng màn hình cảm ứng
(4, 2, 'Xe đạp trượt tuyết Concept2 BikeErg', 'C2-BIKE-2023-010', '2023-03-10', 48, 'Operational'),
(5, 3, 'Khung gánh tạ trợ lực Smith Machine Matrix', 'MT-SMTH-2022-005', '2022-06-20', 60, 'Operational'),
(6, 3, 'Máy đạp đùi 45 độ Linear Leg Press Rogue', 'RG-LEGP-2022-008', '2022-07-01', 60, 'Operational'),
(7, 3, 'Dàn kéo cáp đa năng 8 trụ Life Fitness Cable', 'LF-CABL-2021-001', '2021-09-15', 72, 'Operational'),
(8, 3, 'Ghế đẩy ngực dốc ngang Olympic Flat Bench', 'OL-FBEN-2022-014', '2022-08-11', 60, 'Operational'),
(9, 4, 'Máy chèo thuyền Concept2 RowErg Model D', 'C2-ROWE-2023-022', '2023-02-18', 48, 'Operational'),
(10, 4, 'Bộ tạ chuông Kettlebell Rogue 8kg-32kg', 'RG-KETT-2023-009', '2023-04-05', 48, 'Operational'),
(11, 1, 'Bộ thảm Yoga định tuyến Liforme cao cấp (20 chiếc)', 'LF-YOGA-2024-001', '2024-01-10', 24, 'Operational'),
(12, 5, 'Giường tập Pilates Reformer gỗ sồi Merrithew', 'MR-PILR-2023-004', '2023-05-12', 60, 'Operational'),
(13, 5, 'Giường tập Pilates Reformer gỗ sồi Merrithew', 'MR-PILR-2023-005', '2023-05-12', 60, 'Under_Maintenance'), -- Đang đứt lò xo kháng lực
(14, 6, 'Bao cát đấm bốc hạng nặng Fairtex 1m8', 'FT-SBAG-2022-003', '2022-11-20', 36, 'Operational'),
(15, 6, 'Sàn đài boxing tiêu chuẩn dây đai thép 6m', 'BX-RING-2022-001', '2022-10-15', 84, 'Under_Maintenance'); -- Thuộc phòng 6 đang bảo trì

ALTER SEQUENCE equipment_equipment_id_seq RESTART WITH 16;

-- ----------------------------------------------------------------------------
