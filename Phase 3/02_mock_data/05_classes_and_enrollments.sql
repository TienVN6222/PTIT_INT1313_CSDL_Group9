-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Lịch lớp và đăng ký lớp; gồm logic đồng bộ số lượng đăng ký và sequence.

-- 11. LỊCH LỚP HỌC NHÓM (class_schedule)
-- 20 lớp học nhóm với tỷ lệ đăng ký từ 0% đến 100% để kiểm thử Fill Rate (Query 5)
-- ----------------------------------------------------------------------------
INSERT INTO class_schedule (class_id, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled) VALUES
(1, 6, 1, 'Morning Awakening Yoga', '2026-10-10 06:00:00', '2026-10-10 07:15:00', 20, 20), -- 100% full
(2, 6, 1, 'Sunset Yin Yoga', '2026-10-10 18:00:00', '2026-10-10 19:15:00', 20, 16),
(3, 8, 5, 'Pilates Core Flow Reformer', '2026-10-11 08:30:00', '2026-10-11 09:30:00', 8, 8), -- 100% full
(4, 8, 5, 'Pilates Spine Relief', '2026-10-11 17:30:00', '2026-10-11 18:30:00', 8, 6),
(5, 7, 4, 'CrossFit WOD Metcon', '2026-10-12 07:00:00', '2026-10-12 08:00:00', 16, 12),
(6, 7, 4, 'CrossFit Hero WOD Murph', '2026-10-12 18:00:00', '2026-10-12 19:30:00', 16, 14),
(7, 5, 3, 'Powerlifting Deadlift Clinic', '2026-10-13 09:00:00', '2026-10-13 10:30:00', 12, 10),
(8, 10, 2, 'HIIT Cardio Burn Express', '2026-10-13 18:30:00', '2026-10-13 19:15:00', 25, 22),
(9, 6, 1, 'Vinyasa Flow Advanced', '2026-10-14 06:00:00', '2026-10-14 07:15:00', 20, 15),
(10, 8, 5, 'Pilates Posture Master', '2026-10-14 09:00:00', '2026-10-14 10:00:00', 8, 4),
(11, 7, 4, 'Functional Mobility & Core', '2026-10-15 07:00:00', '2026-10-15 08:00:00', 15, 5), -- 33% (Low)
(12, 10, 2, 'Tabata Extreme Fat Blast', '2026-10-15 18:00:00', '2026-10-15 19:00:00', 25, 18),
(13, 6, 1, 'Candlelight Restorative Yoga', '2026-10-16 19:30:00', '2026-10-16 20:45:00', 20, 20), -- 100% full
(14, 5, 3, 'Hypertrophy Upper Body', '2026-10-17 08:00:00', '2026-10-17 09:30:00', 15, 12),
(15, 7, 4, 'Olympic Weightlifting Snatch', '2026-10-17 10:00:00', '2026-10-17 11:30:00', 10, 8),
(16, 10, 2, 'Step & Aerobics Dance', '2026-10-18 09:00:00', '2026-10-18 10:00:00', 20, 6), -- 30% (Low)
(17, 6, 1, 'Meditation & Breathwork', '2026-10-19 06:30:00', '2026-10-19 07:30:00', 20, 2), -- 10% (Very Low)
(18, 8, 5, 'Pilates Jumpboard Cardio', '2026-10-19 16:00:00', '2026-10-19 17:00:00', 8, 8), -- 100% full
(19, 7, 4, 'Kettlebell Strength & Power', '2026-10-20 07:00:00', '2026-10-20 08:00:00', 15, 0), -- 0% (Empty)
(20, 10, 2, 'Circuit Bootcamp Warriors', '2026-10-20 18:00:00', '2026-10-20 19:15:00', 25, 24);

ALTER SEQUENCE class_schedule_class_id_seq RESTART WITH 21;

-- Lưu số lượng mục tiêu để tạo đủ bản ghi đăng ký thực tế bên dưới.
-- Nhờ đó current_enrolled vẫn phản ánh đúng các mức fill rate dùng kiểm thử.
DROP TABLE IF EXISTS pg_temp.class_fill_targets;
CREATE TEMP TABLE class_fill_targets AS
SELECT class_id, current_enrolled AS target_count
FROM class_schedule;

-- ----------------------------------------------------------------------------
-- 12. ĐĂNG KÝ LỚP HỌC (class_enrollment)
-- ----------------------------------------------------------------------------
INSERT INTO class_enrollment (enrollment_id, subscription_id, class_id, enrollment_date, status) VALUES
(1, 4, 1, '2026-10-08 09:00:00', 'Attended'),
(2, 9, 1, '2026-10-08 09:30:00', 'Attended'),
(3, 14, 1, '2026-10-08 10:00:00', 'Attended'),
(4, 4, 2, '2026-10-09 11:00:00', 'Attended'),
(5, 9, 2, '2026-10-09 11:30:00', 'Attended'),
(6, 14, 3, '2026-10-09 14:00:00', 'Attended'),
(7, 2, 5, '2026-10-10 15:00:00', 'Attended'),
(8, 5, 5, '2026-10-10 15:30:00', 'Attended'),
(9, 7, 5, '2026-10-10 16:00:00', 'Attended'),
(10, 2, 6, '2026-10-11 08:00:00', 'Attended'),
(11, 5, 6, '2026-10-11 08:30:00', 'Attended'),
(12, 13, 7, '2026-10-11 09:00:00', 'Attended'),
(13, 15, 8, '2026-10-12 10:00:00', 'Attended'),
(14, 19, 8, '2026-10-12 10:30:00', 'Attended'),
(15, 20, 8, '2026-10-12 11:00:00', 'Attended'),
(16, 4, 9, '2026-10-13 14:00:00', 'Enrolled'),
(17, 9, 9, '2026-10-13 14:30:00', 'Enrolled'),
(18, 14, 10, '2026-10-13 15:00:00', 'Enrolled'),
(19, 2, 11, '2026-10-14 08:00:00', 'Enrolled'),
(20, 5, 12, '2026-10-14 09:00:00', 'Enrolled'),
(21, 7, 12, '2026-10-14 10:00:00', 'Enrolled'),
(22, 13, 12, '2026-10-14 11:00:00', 'Enrolled'),
(23, 4, 13, '2026-10-15 16:00:00', 'Enrolled'),
(24, 9, 13, '2026-10-15 16:30:00', 'Enrolled'),
(25, 14, 13, '2026-10-15 17:00:00', 'Enrolled'),
(26, 2, 14, '2026-10-16 08:00:00', 'Enrolled'),
(27, 5, 15, '2026-10-16 09:00:00', 'Enrolled'),
(28, 15, 16, '2026-10-17 10:00:00', 'Enrolled'),
(29, 19, 16, '2026-10-17 10:30:00', 'Enrolled'),
(30, 4, 17, '2026-10-18 11:00:00', 'Enrolled'),
(31, 14, 18, '2026-10-18 14:00:00', 'Enrolled'),
(32, 2, 20, '2026-10-19 09:00:00', 'Enrolled'),
(33, 5, 20, '2026-10-19 10:00:00', 'Enrolled'),
(34, 7, 20, '2026-10-19 11:00:00', 'Cancelled'),
(35, 13, 20, '2026-10-19 12:00:00', 'Enrolled');

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
), candidates AS (
    SELECT
        g.class_id,
        g.needed,
        ms.subscription_id,
        ROW_NUMBER() OVER (
            PARTITION BY g.class_id ORDER BY ms.subscription_id
        ) AS class_row
    FROM target_gaps AS g
    JOIN member_subscription AS ms ON g.needed > 0
    WHERE NOT EXISTS (
        SELECT 1
        FROM class_enrollment AS ce
        WHERE ce.class_id = g.class_id
          AND ce.subscription_id = ms.subscription_id
    )
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
