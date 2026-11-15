-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Các lượt giữ chỗ thiết bị gắn với PT hoặc lớp học (giờ lấy đúng theo ca/lớp nên luôn tương đối theo CURRENT_DATE).

-- 14. GIỮ CHỖ THIẾT BỊ (equipment_reservation)
-- Khung giờ giữ chỗ = khung giờ của ca PT / lớp học gắn kèm (BR-21: nằm trong khung giờ ca/lớp);
-- trạng thái: ca/lớp đã bắt đầu -> 'Completed', chưa bắt đầu -> 'Reserved'.
-- Chỉ giữ chỗ thiết bị đang Operational (5, 6, 7, 9, 10, 11, 12) nên không vướng ca bảo trì In_Progress (thiết bị 3, 13, 15).
-- ----------------------------------------------------------------------------
INSERT INTO equipment_reservation (reservation_id, equipment_id, booking_id, class_id, start_time, end_time, status)
SELECT
    v.reservation_id,
    v.equipment_id,
    v.booking_id,
    v.class_id,
    COALESCE(pb.start_time, cs.start_time),
    COALESCE(pb.end_time, cs.end_time),
    CASE WHEN COALESCE(pb.start_time, cs.start_time) < CURRENT_TIMESTAMP THEN 'Completed' ELSE 'Reserved' END
FROM (VALUES
(1, 5, 1, NULL),
(2, 6, 2, NULL),
(3, 7, 3, NULL),
(4, 5, 4, NULL),
(5, 7, 5, NULL),
(6, 6, 6, NULL),
(7, 5, 7, NULL),
(8, 9, 11, NULL),
(9, 10, 12, NULL),
(10, 9, 13, NULL),
(11, 10, 14, NULL),
(12, 12, 18, NULL),
(13, 12, 19, NULL),
(14, 12, 20, NULL),
(15, 12, 21, NULL),
(16, 11, NULL, 1),
(17, 11, NULL, 2),
(18, 12, NULL, 3),
(19, 9, NULL, 5),
(20, 10, NULL, 6),
(21, 5, 26, NULL),
(22, 7, 27, NULL),
(23, 6, 28, NULL),
(24, 9, 29, NULL),
(25, 12, 31, NULL)
) AS v (reservation_id, equipment_id, booking_id, class_id)
LEFT JOIN pt_booking AS pb ON pb.booking_id = v.booking_id
LEFT JOIN class_schedule AS cs ON cs.class_id = v.class_id;

ALTER SEQUENCE equipment_reservation_reservation_id_seq RESTART WITH 26;

-- ----------------------------------------------------------------------------
