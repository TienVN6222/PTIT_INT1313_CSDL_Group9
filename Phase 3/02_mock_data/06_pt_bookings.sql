-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Các ca tập huấn luyện viên cá nhân 1-1 (ngày giờ tương đối theo CURRENT_DATE).

-- 13. CA TẬP HUẤN LUYỆN VIÊN CÁ NHÂN 1-1 (pt_booking)
-- 35 ca tập, bao gồm: Completed, Scheduled, Cancelled, Late_Cancelled, No_Show
-- Ngày ca tập = CURRENT_DATE + day_offset: ca 1-25 là lịch sử 7-14 ngày trước (Completed/No_Show/Cancelled/Late_Cancelled);
-- ca 26-35 là ca Scheduled trong 1-5 ngày tới (luôn nằm trong thời hạn hợp đồng PT và <= số buổi còn lại, BR-18).
-- Ca 18 neo vào NGÀY ĐẦU THÁNG HIỆN TẠI để Query 2/3 (tháng hiện tại) luôn có ca PT; nếu nạp dữ liệu đúng ngày mùng 1
-- trước 10:00 thì ca này tự chuyển thành 'Scheduled' (không có ca Completed ở tương lai).
-- Mọi ca PT nằm trong khung 09:30-16:30, tách hẳn khung giờ lớp nhóm (06:00-08:30 và 17:00-20:45) nên không vi phạm
-- BR-12 (HLV vừa đứng lớp vừa dạy PT) và BR-16 (hội viên trùng lớp đã đăng ký); không ca nào rơi vào 21:00-23:59 (CONTRACT).
-- Ca 24 là ca hủy muộn (Late_Cancelled, BR-25); created_by_user_id = 3 (lễ tân đặt lịch, BR-23).
-- HLV Dũng (id=5), HLV Trọng (id=7), HLV Chi (id=8) dạy nhiều giờ nhất
-- Chú ý: Hội viên 20 (id=20) KHÔNG CÓ TRONG BẢNG NÀY (phục vụ Query 7)
-- ----------------------------------------------------------------------------
INSERT INTO pt_booking (booking_id, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_by_user_id)
SELECT
    v.booking_id,
    v.member_user_id,
    v.trainer_user_id,
    v.subscription_id,
    v.session_day,
    v.session_day + v.start_at,
    v.session_day + v.end_at,
    v.status,
    3
FROM (VALUES
(1, 11, 5, 1, CURRENT_DATE - 14, TIME '10:00', TIME '11:30', 'Completed'),
(2, 11, 5, 1, CURRENT_DATE - 12, TIME '10:00', TIME '11:30', 'Completed'),
(3, 11, 5, 1, CURRENT_DATE - 10, TIME '10:00', TIME '11:30', 'Completed'),
(4, 11, 5, 1, CURRENT_DATE - 8, TIME '10:00', TIME '11:30', 'Completed'),
(5, 18, 5, 8, CURRENT_DATE - 13, TIME '10:00', TIME '11:30', 'Completed'),
(6, 18, 5, 8, CURRENT_DATE - 11, TIME '10:00', TIME '11:30', 'Completed'),
(7, 18, 5, 8, CURRENT_DATE - 9, TIME '10:00', TIME '11:30', 'Completed'),
(8, 21, 5, 11, CURRENT_DATE - 13, TIME '14:00', TIME '15:30', 'Completed'),
(9, 21, 5, 11, CURRENT_DATE - 11, TIME '14:00', TIME '15:30', 'Completed'),
(10, 21, 5, 11, CURRENT_DATE - 9, TIME '14:00', TIME '15:30', 'Completed'),
(11, 22, 7, 12, CURRENT_DATE - 14, TIME '09:30', TIME '11:00', 'Completed'),
(12, 22, 7, 12, CURRENT_DATE - 12, TIME '09:30', TIME '11:00', 'Completed'),
(13, 22, 7, 12, CURRENT_DATE - 10, TIME '09:30', TIME '11:00', 'Completed'),
(14, 22, 7, 12, CURRENT_DATE - 8, TIME '09:30', TIME '11:00', 'Completed'),
(15, 28, 7, 18, CURRENT_DATE - 13, TIME '15:00', TIME '16:30', 'Completed'),
(16, 28, 7, 18, CURRENT_DATE - 11, TIME '15:00', TIME '16:30', 'Completed'),
(17, 28, 7, 18, CURRENT_DATE - 9, TIME '15:00', TIME '16:30', 'Completed'),
(18, 16, 8, 6, DATE_TRUNC('month', CURRENT_DATE)::DATE, TIME '10:00', TIME '11:00', CASE WHEN DATE_TRUNC('month', CURRENT_DATE)::DATE + TIME '10:00' <= CURRENT_TIMESTAMP THEN 'Completed' ELSE 'Scheduled' END),
(19, 16, 8, 6, CURRENT_DATE - 12, TIME '14:00', TIME '15:00', 'Completed'),
(20, 16, 8, 6, CURRENT_DATE - 10, TIME '14:00', TIME '15:00', 'Completed'),
(21, 16, 8, 6, CURRENT_DATE - 8, TIME '14:00', TIME '15:00', 'Completed'),
(22, 13, 5, 3, CURRENT_DATE - 13, TIME '12:00', TIME '13:00', 'No_Show'),
(23, 13, 5, 3, CURRENT_DATE - 10, TIME '12:00', TIME '13:00', 'Cancelled'),
(24, 16, 8, 6, CURRENT_DATE - 7, TIME '14:00', TIME '15:00', 'Late_Cancelled'),
(25, 21, 5, 11, CURRENT_DATE - 7, TIME '14:00', TIME '15:30', 'No_Show'),
(26, 11, 5, 1, CURRENT_DATE + 1, TIME '12:00', TIME '13:30', 'Scheduled'),
(27, 18, 5, 8, CURRENT_DATE + 1, TIME '10:00', TIME '11:30', 'Scheduled'),
(28, 21, 5, 11, CURRENT_DATE + 1, TIME '14:00', TIME '15:30', 'Scheduled'),
(29, 22, 7, 12, CURRENT_DATE + 2, TIME '09:30', TIME '11:00', 'Scheduled'),
(30, 28, 7, 18, CURRENT_DATE + 2, TIME '15:00', TIME '16:30', 'Scheduled'),
(31, 16, 8, 6, CURRENT_DATE + 3, TIME '14:00', TIME '15:00', 'Scheduled'),
(32, 13, 5, 3, CURRENT_DATE + 3, TIME '12:00', TIME '13:00', 'Scheduled'),
(33, 11, 5, 1, CURRENT_DATE + 4, TIME '13:00', TIME '14:30', 'Scheduled'),
(34, 18, 5, 8, CURRENT_DATE + 4, TIME '15:00', TIME '16:30', 'Scheduled'),
(35, 22, 7, 12, CURRENT_DATE + 5, TIME '11:00', TIME '12:30', 'Scheduled')
) AS v (booking_id, member_user_id, trainer_user_id, subscription_id, session_day, start_at, end_at, status);

ALTER SEQUENCE pt_booking_booking_id_seq RESTART WITH 36;

-- ----------------------------------------------------------------------------
