-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Lịch lớp và đăng ký lớp (ngày giờ tương đối theo CURRENT_DATE); gồm logic đồng bộ số lượng đăng ký và sequence.

-- 11. LỊCH LỚP HỌC NHÓM (class_schedule)
-- 20 lớp học nhóm với tỷ lệ đăng ký từ 0% đến 100% để kiểm thử Fill Rate (Query 5)
-- Ngày giờ lớp được tính TƯƠNG ĐỐI theo CURRENT_DATE: cột day_offset là số ngày so với ngày nạp dữ liệu
-- (âm = đã diễn ra: lớp 3-8; dương = sắp diễn ra trong 9 ngày tới: các lớp còn lại).
-- Mọi lớp đều nằm trong khung 06:00-08:30 hoặc 17:00-20:45 và không lớp nào chồng giờ nhau; còn ca PT (06_pt_bookings.sql)
-- chỉ nằm trong khung 09:30-16:30 nên không bao giờ vi phạm BR-12/BR-16 và không có sự kiện nào rơi vào 21:00-23:59 (CONTRACT).
-- Lưu ý BR-16: một hội viên chỉ được đăng ký một lần cho mỗi lớp (kể cả khi có 2 hợp đồng) và chỉ có
-- 20 hội viên (ID 11-30) nên số đăng ký tối đa của một lớp là 20; lớp 8 và lớp 20 vì thế được hạ
-- xuống 20/25 và 19/25. created_by_user_id = 1 (Admin xếp lịch lớp, BR-23).
-- Các lớp 1 (20/20) và 2 (16/20) là lớp sắp diễn ra (ngày mai); ghi chú 100%/30%/10%/0% là mức fill rate mục tiêu.
-- ----------------------------------------------------------------------------
INSERT INTO class_schedule (class_id, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled, created_by_user_id)
SELECT
    v.class_id,
    v.trainer_user_id,
    v.room_id,
    v.class_name,
    CURRENT_DATE + v.day_offset + v.start_at,
    CURRENT_DATE + v.day_offset + v.end_at,
    v.max_capacity,
    v.current_enrolled,
    1
FROM (VALUES
(1, 6, 1, 'Morning Awakening Yoga', 1, TIME '06:00', TIME '07:15', 20, 20),
(2, 6, 1, 'Sunset Yin Yoga', 1, TIME '18:00', TIME '19:15', 20, 16),
(3, 8, 5, 'Pilates Core Flow Reformer', -3, TIME '07:30', TIME '08:30', 8, 8),
(4, 8, 5, 'Pilates Spine Relief', -3, TIME '17:30', TIME '18:30', 8, 6),
(5, 7, 4, 'CrossFit WOD Metcon', -5, TIME '07:00', TIME '08:00', 16, 12),
(6, 7, 4, 'CrossFit Hero WOD Murph', -5, TIME '18:00', TIME '19:30', 16, 14),
(7, 5, 3, 'Powerlifting Deadlift Clinic', -7, TIME '06:30', TIME '08:00', 12, 10),
(8, 10, 2, 'HIIT Cardio Burn Express', -7, TIME '18:30', TIME '19:15', 25, 20),
(9, 6, 1, 'Vinyasa Flow Advanced', 2, TIME '06:00', TIME '07:15', 20, 15),
(10, 8, 5, 'Pilates Posture Master', 2, TIME '07:30', TIME '08:30', 8, 4),
(11, 7, 4, 'Functional Mobility & Core', 3, TIME '07:00', TIME '08:00', 15, 5),
(12, 10, 2, 'Tabata Extreme Fat Blast', 3, TIME '18:00', TIME '19:00', 25, 18),
(13, 6, 1, 'Candlelight Restorative Yoga', 4, TIME '19:30', TIME '20:45', 20, 20),
(14, 5, 3, 'Hypertrophy Upper Body', 5, TIME '06:30', TIME '08:00', 15, 12),
(15, 7, 4, 'Olympic Weightlifting Snatch', 5, TIME '17:30', TIME '19:00', 10, 8),
(16, 10, 2, 'Step & Aerobics Dance', 6, TIME '07:00', TIME '08:00', 20, 6),
(17, 6, 1, 'Meditation & Breathwork', 7, TIME '06:30', TIME '07:30', 20, 2),
(18, 8, 5, 'Pilates Jumpboard Cardio', 4, TIME '17:00', TIME '18:00', 8, 8),
(19, 7, 4, 'Kettlebell Strength & Power', 8, TIME '07:00', TIME '08:00', 15, 0),
(20, 10, 2, 'Circuit Bootcamp Warriors', 9, TIME '18:00', TIME '19:15', 25, 19)
) AS v (class_id, trainer_user_id, room_id, class_name, day_offset, start_at, end_at, max_capacity, current_enrolled);

ALTER SEQUENCE class_schedule_class_id_seq RESTART WITH 21;

-- Lưu số lượng mục tiêu để tạo đủ bản ghi đăng ký thực tế bên dưới.
-- Nhờ đó current_enrolled vẫn phản ánh đúng các mức fill rate dùng kiểm thử.
DROP TABLE IF EXISTS pg_temp.class_fill_targets;
CREATE TEMP TABLE class_fill_targets AS
SELECT class_id, current_enrolled AS target_count
FROM class_schedule;

-- ----------------------------------------------------------------------------
-- 12. ĐĂNG KÝ LỚP HỌC (class_enrollment)
-- Trạng thái tính theo thời gian: lớp đã diễn ra -> 'Attended', lớp sắp diễn ra -> 'Enrolled'
-- (riêng đăng ký 34 là 'Cancelled'); enrollment_date = 1 ngày trước giờ bắt đầu lớp.
-- ----------------------------------------------------------------------------
INSERT INTO class_enrollment (enrollment_id, subscription_id, class_id, enrollment_date, status)
SELECT
    v.enrollment_id,
    v.subscription_id,
    v.class_id,
    cs.start_time - INTERVAL '1 day',
    COALESCE(v.forced_status, CASE WHEN cs.start_time < CURRENT_TIMESTAMP THEN 'Attended' ELSE 'Enrolled' END)
FROM (VALUES
(1, 4, 1, NULL),
(2, 9, 1, NULL),
(3, 14, 1, NULL),
(4, 4, 2, NULL),
(5, 9, 2, NULL),
(6, 14, 3, NULL),
(7, 2, 5, NULL),
(8, 5, 5, NULL),
(9, 7, 5, NULL),
(10, 2, 6, NULL),
(11, 5, 6, NULL),
(12, 13, 7, NULL),
(13, 15, 8, NULL),
(14, 19, 8, NULL),
(15, 20, 8, NULL),
(16, 4, 9, NULL),
(17, 9, 9, NULL),
(18, 14, 10, NULL),
(19, 2, 11, NULL),
(20, 5, 12, NULL),
(21, 7, 12, NULL),
(22, 13, 12, NULL),
(23, 4, 13, NULL),
(24, 9, 13, NULL),
(25, 14, 13, NULL),
(26, 2, 14, NULL),
(27, 5, 15, NULL),
(28, 15, 16, NULL),
(29, 19, 16, NULL),
(30, 4, 17, NULL),
(31, 14, 18, NULL),
(32, 2, 20, NULL),
(33, 5, 20, NULL),
(34, 7, 20, 'Cancelled'),
(35, 13, 20, NULL)
) AS v (enrollment_id, subscription_id, class_id, forced_status)
JOIN class_schedule AS cs ON cs.class_id = v.class_id;

-- Bổ sung bản ghi đăng ký để số liệu khớp với current_enrolled đã thiết kế.
WITH target_gaps AS (
    SELECT
        t.class_id,
        t.target_count,
        GREATEST(
            t.target_count - COUNT(ce.enrollment_id) FILTER (
                WHERE ce.status IN ('Enrolled', 'Attended')
            ),
            0
        ) AS needed
    FROM class_fill_targets AS t
    LEFT JOIN class_enrollment AS ce ON ce.class_id = t.class_id
    GROUP BY t.class_id, t.target_count
), member_pick AS (
    -- Mỗi hội viên chỉ được chọn 1 hợp đồng cho mỗi lớp, và bỏ qua hội viên đã đăng ký lớp đó (BR-16).
    SELECT DISTINCT ON (g.class_id, ms.member_user_id)
        g.class_id,
        g.needed,
        ms.member_user_id,
        ms.subscription_id
    FROM target_gaps AS g
    JOIN member_subscription AS ms ON g.needed > 0
    WHERE NOT EXISTS (
        SELECT 1
        FROM class_enrollment AS ce
        WHERE ce.class_id = g.class_id
          AND ce.subscription_id = ms.subscription_id
    )
      AND NOT EXISTS (
        SELECT 1
        FROM class_enrollment AS ce
        JOIN member_subscription AS ms2 ON ms2.subscription_id = ce.subscription_id
        WHERE ce.class_id = g.class_id
          AND ce.status IN ('Enrolled', 'Attended')
          AND ms2.member_user_id = ms.member_user_id
    )
    ORDER BY g.class_id, ms.member_user_id, ms.subscription_id
), candidates AS (
    SELECT
        class_id,
        needed,
        subscription_id,
        ROW_NUMBER() OVER (
            PARTITION BY class_id ORDER BY subscription_id
        ) AS class_row
    FROM member_pick
), to_insert AS (
    SELECT
        class_id,
        subscription_id,
        ROW_NUMBER() OVER (ORDER BY class_id, subscription_id) + 35 AS enrollment_id
    FROM candidates
    WHERE class_row <= needed
)
INSERT INTO class_enrollment
    (enrollment_id, subscription_id, class_id, enrollment_date, status)
SELECT
    ti.enrollment_id,
    ti.subscription_id,
    ti.class_id,
    cs.start_time - INTERVAL '1 day',
    CASE WHEN cs.start_time < CURRENT_TIMESTAMP THEN 'Attended' ELSE 'Enrolled' END
FROM to_insert AS ti
JOIN class_schedule AS cs ON cs.class_id = ti.class_id;

SELECT setval(
    'class_enrollment_enrollment_id_seq',
    (SELECT COALESCE(MAX(enrollment_id), 1) FROM class_enrollment)
);

-- ----------------------------------------------------------------------------
