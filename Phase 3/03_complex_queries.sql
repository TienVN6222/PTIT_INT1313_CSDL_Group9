-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 03_complex_queries.sql - TẬP TRUY VẤN NÂNG CAO (10 PHỨC HỢP)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell) / Google SQL Style Guide
-- ============================================================================

-- ============================================================================
-- CÂU TRUY VẤN 1: THỐNG KÊ DOANH THU THEO TỪNG GÓI TẬP TRONG QUÝ HIỆN TẠI
-- Mục đích nghiệp vụ: Giúp Ban Giám đốc đánh giá hiệu quả kinh doanh của từng dòng
-- gói dịch vụ (Gói tháng, VIP, PT) trong quý đang vận hành để điều chỉnh chính sách giá.
-- Kỹ thuật SQL: JOIN 3 bảng, GROUP BY, SUM, date_trunc('quarter', payment_date)
-- ============================================================================
SELECT
    mp.plan_id,
    mp.plan_name,
    COUNT(bl.billing_id) AS total_transactions,
    SUM(bl.amount)       AS total_revenue,
    ROUND(AVG(bl.amount), 2) AS average_order_value
FROM
    membership_plan mp
JOIN
    member_subscription ms ON mp.plan_id = ms.plan_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
    AND bl.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)
    AND bl.payment_date <  DATE_TRUNC('quarter', CURRENT_DATE) + INTERVAL '3 months'
GROUP BY
    mp.plan_id,
    mp.plan_name
ORDER BY
    total_revenue DESC;


-- ============================================================================
-- CÂU TRUY VẤN 2: TOP 3 HUẤN LUYỆN VIÊN CÓ TỔNG SỐ GIỜ DẠY NHIỀU NHẤT TRONG THÁNG
-- Mục đích nghiệp vụ: Tổng hợp giờ giảng dạy cả hai hình thức: Dạy lớp nhóm (Class)
-- và Dạy kèm cá nhân (PT 1-1) trong tháng hiện tại để tính thưởng KPI cho HLV xuất sắc.
-- Kỹ thuật SQL: UNION ALL, CTE, EXTRACT(EPOCH), GROUP BY, HAVING, ORDER BY LIMIT 3
-- ============================================================================
WITH trainer_teaching_hours AS (
    -- Nguồn 1: Giờ dạy kèm 1-1 (PT_BOOKING) trạng thái Completed
    SELECT
        pb.trainer_user_id AS trainer_id,
        ROUND((EXTRACT(EPOCH FROM (pb.end_time - pb.start_time)) / 3600.0)::NUMERIC, 2) AS hours_taught,
        'PT_1_ON_1' AS teaching_type
    FROM
        pt_booking pb
    WHERE
        pb.status = 'Completed'
        AND pb.booking_date >= DATE_TRUNC('month', CURRENT_DATE)
        AND pb.booking_date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'

    UNION ALL

    -- Nguồn 2: Giờ đứng lớp học nhóm (CLASS_SCHEDULE)
    SELECT
        cs.trainer_user_id AS trainer_id,
        ROUND((EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600.0)::NUMERIC, 2) AS hours_taught,
        'GROUP_CLASS' AS teaching_type
    FROM
        class_schedule cs
    WHERE
        cs.start_time >= DATE_TRUNC('month', CURRENT_DATE)
        AND cs.start_time <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
)
SELECT
    u.user_id AS trainer_id,
    u.full_name AS trainer_name,
    tp.specialization,
    tp.current_rating,
    COUNT(tth.hours_taught) AS total_sessions_conducted,
    SUM(tth.hours_taught)   AS total_hours_taught
FROM
    trainer_teaching_hours tth
JOIN
    user_account u ON tth.trainer_id = u.user_id
JOIN
    trainer_profile tp ON u.user_id = tp.user_id
GROUP BY
    u.user_id,
    u.full_name,
    tp.specialization,
    tp.current_rating
HAVING
    SUM(tth.hours_taught) > 0
ORDER BY
    total_hours_taught DESC
LIMIT 3;


-- ============================================================================
-- CÂU TRUY VẤN 3: DANH SÁCH HỘI VIÊN CÓ GÓI TẬP SẮP HẾT HẠN TRONG 7 NGÀY TỚI
-- Mục đích nghiệp vụ: Hỗ trợ bộ phận Lễ tân / Chăm sóc khách hàng chủ động liên hệ
-- nhắc nhở gia hạn hợp đồng và tư vấn các gói ưu đãi trung thành (Retention Campaign).
-- Kỹ thuật SQL: WHERE, CURRENT_TIMESTAMP, INTERVAL, DATE PART
-- ============================================================================
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.phone,
    u.email,
    mp.plan_name,
    ms.subscription_id,
    ms.end_time AS expiration_date,
    ROUND(EXTRACT(EPOCH FROM (ms.end_time - CURRENT_TIMESTAMP)) / 86400.0, 1) AS days_remaining,
    ms.remaining_sessions AS pt_sessions_left,
    ms.is_recurring
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active'
    AND ms.end_time >= CURRENT_TIMESTAMP
    AND ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days'
ORDER BY
    ms.end_time ASC;


-- ============================================================================
-- CÂU TRUY VẤN 4: THIẾT BỊ ĐANG BẢO TRÌ KÈM KỸ THUẬT VIÊN VÀ TỔNG CHI PHÍ
-- Mục đích nghiệp vụ: Kiểm soát trạng thái vận hành của trang thiết bị (BR-19),
-- theo dõi các thiết bị đang ngừng hoạt động, người chịu trách nhiệm và lũy kế chi phí.
-- Kỹ thuật SQL: JOIN 4 bảng, WHERE, GROUP BY, SUM
-- ============================================================================
SELECT
    e.equipment_id,
    e.equipment_name,
    e.serial_number,
    fr.room_name AS location_room,
    e.status AS equipment_status,
    u.full_name AS technician_in_charge,
    ml.issue_description AS current_issue,
    ml.start_time AS maintenance_started_at,
    ml.cost AS current_ticket_cost,
    (
        SELECT COALESCE(SUM(all_ml.cost), 0)
        FROM maintenance_log all_ml
        WHERE all_ml.equipment_id = e.equipment_id
    ) AS total_historical_repair_cost
FROM
    equipment e
JOIN
    facilities_room fr ON e.room_id = fr.room_id
JOIN
    maintenance_log ml ON e.equipment_id = ml.equipment_id
JOIN
    user_account u ON ml.staff_user_id = u.user_id
WHERE
    e.status = 'Under_Maintenance'
    AND ml.status = 'In_Progress'
ORDER BY
    ml.start_time ASC;


-- ============================================================================
-- CÂU TRUY VẤN 5: TỶ LỆ LẤP ĐẦY (FILL RATE) CỦA CÁC LỚP HỌC NHÓM
-- Mục đích nghiệp vụ: Đánh giá sức hút của từng lớp học nhóm (Yoga, Pilates, CrossFit),
-- phát hiện các lớp bị ế ẩm (Low fill rate) để tối ưu hóa việc phân bổ phòng học.
-- Kỹ thuật SQL: CASE WHEN, ROUND, JOIN, Arithmetic Expression, ORDER BY
-- ============================================================================
SELECT
    cs.class_id,
    cs.class_name,
    u.full_name AS instructor_name,
    fr.room_name,
    cs.start_time,
    cs.max_capacity,
    cs.current_enrolled,
    ROUND((cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) * 100.0, 2) AS fill_rate_percentage,
    CASE
        WHEN (cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) >= 1.00 THEN 'Đầy Chỗ (Full 100%)'
        WHEN (cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) >= 0.70 THEN 'Tốt (High Demand)'
        WHEN (cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) >= 0.40 THEN 'Trung Bình (Moderate)'
        ELSE 'Thấp (Low Attendance - Cần Khuyến Mãi)'
    END AS occupancy_category
FROM
    class_schedule cs
JOIN
    user_account u ON cs.trainer_user_id = u.user_id
JOIN
    facilities_room fr ON cs.room_id = fr.room_id
ORDER BY
    fill_rate_percentage DESC,
    cs.start_time ASC;


-- ============================================================================
-- CÂU TRUY VẤN 6: DANH SÁCH CA TẬP PT 1-1 BỊ HỦY MUỘN HOẶC BỎ TẬP (NO-SHOW)
-- Mục đích nghiệp vụ: Kiểm soát quy định hủy lịch (BR-25), thống kê các hội viên
-- hay vắng mặt không lý do gây lãng phí thời gian biểu của Huấn luyện viên.
-- Kỹ thuật SQL: JOIN 3 bảng, WHERE status IN (...), ORDER BY
-- Ghi chú: 'Late_Cancelled' là ca hủy khi còn dưới 24 giờ (trigger trg_late_cancel_pt_booking
-- tự đổi trạng thái và trừ 1 buổi); 'Cancelled' là hủy sớm, không bị trừ buổi.
-- ============================================================================
SELECT
    pb.booking_id,
    pb.booking_date,
    pb.start_time,
    m.user_id AS member_id,
    m.full_name AS member_name,
    m.phone AS member_phone,
    t.full_name AS trainer_name,
    pb.status AS incident_status,
    CASE pb.status
        WHEN 'No_Show'        THEN 'Hội viên không đến và không báo trước (Trừ 1 buổi theo BR-25)'
        WHEN 'Late_Cancelled' THEN 'Hủy muộn khi còn dưới 24 giờ (Trừ 1 buổi theo BR-25)'
        WHEN 'Cancelled'      THEN 'Hủy sớm trước 24 giờ (Không trừ buổi theo BR-25)'
        ELSE pb.status
    END AS rule_penalty_note
FROM
    pt_booking pb
JOIN
    user_account m ON pb.member_user_id = m.user_id
JOIN
    user_account t ON pb.trainer_user_id = t.user_id
WHERE
    pb.status IN ('Cancelled', 'Late_Cancelled', 'No_Show')
ORDER BY
    pb.booking_date DESC,
    pb.start_time DESC;


-- ============================================================================
-- CÂU TRUY VẤN 7: HỘI VIÊN ĐÃ MUA GÓI PT NHƯNG CHƯA TỪNG ĐẶT LỊCH BUỔI TẬP NÀO
-- Mục đích nghiệp vụ: Xác định nhóm hội viên "ngủ đông" (Inactive/Unengaged) để
-- phân bổ cho Trưởng bộ phận Huấn luyện viên gọi điện thăm hỏi, hướng dẫn lên lịch.
-- Kỹ thuật SQL: LEFT JOIN, IS NULL, WHERE total_sessions > 0
-- ============================================================================
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.phone,
    u.email,
    mp.plan_name,
    ms.subscription_id,
    ms.remaining_sessions,
    ms.start_time AS package_started_at,
    ms.end_time   AS package_expires_at
FROM
    member_subscription ms
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
JOIN
    user_account u ON ms.member_user_id = u.user_id
LEFT JOIN
    pt_booking pb ON ms.subscription_id = pb.subscription_id
WHERE
    mp.total_sessions > 0
    AND ms.sub_status = 'Active'
    AND pb.booking_id IS NULL
ORDER BY
    ms.start_time ASC;


-- ============================================================================
-- CÂU TRUY VẤN 8: PHÂN NHÓM HỘI VIÊN THEO ĐỘ TUỔI VÀ GÓI TẬP ĐƯỢC ƯA CHUỘNG NHẤT
-- Mục đích nghiệp vụ: Phân khúc khách hàng nhân khẩu học (Demographics) để bộ phận
-- Marketing định hướng gói tập phù hợp cho Gen Z, Dân văn phòng và Người trung niên.
-- Kỹ thuật SQL: CASE WHEN, EXTRACT(YEAR), CTE, DENSE_RANK() OVER (PARTITION BY)
-- ============================================================================
WITH member_age_groups AS (
    SELECT
        u.user_id,
        u.dob,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) AS age,
        CASE
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) < 25 THEN 'Nhóm 1: Dưới 25 tuổi (Học sinh - Sinh viên)'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 25 AND 35 THEN 'Nhóm 2: 25 - 35 tuổi (Người trẻ đi làm)'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 36 AND 50 THEN 'Nhóm 3: 36 - 50 tuổi (Trung niên - Gia đình)'
            ELSE 'Nhóm 4: Trên 50 tuổi (Cao niên - Phục hồi sức khỏe)'
        END AS age_bracket,
        mp.plan_name
    FROM
        user_account u
    JOIN
        member_subscription ms ON u.user_id = ms.member_user_id
    JOIN
        membership_plan mp ON ms.plan_id = mp.plan_id
),
plan_popularity AS (
    SELECT
        age_bracket,
        plan_name,
        COUNT(*) AS total_subscriptions,
        DENSE_RANK() OVER (PARTITION BY age_bracket ORDER BY COUNT(*) DESC) AS rank_in_bracket
    FROM
        member_age_groups
    GROUP BY
        age_bracket,
        plan_name
)
SELECT
    age_bracket,
    plan_name AS top_preferred_plan,
    total_subscriptions
FROM
    plan_popularity
WHERE
    rank_in_bracket = 1
ORDER BY
    age_bracket ASC,
    plan_name ASC;


-- ============================================================================
-- CÂU TRUY VẤN 9: XẾP HẠNG DOANH THU ĐÓNG GÓP CỦA TỪNG HỘI VIÊN (WINDOW FUNCTION)
-- Mục đích nghiệp vụ: Xây dựng bảng xếp hạng Hội viên VIP (Loyalty Tier: Vàng, Kim Cương)
-- dựa trên tổng số tiền thực tế đã chi trả qua hóa đơn thanh toán thành công.
-- Kỹ thuật SQL: Window Function DENSE_RANK() OVER (ORDER BY SUM(amount) DESC)
-- ============================================================================
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.phone,
    u.email,
    COUNT(bl.billing_id) AS total_bills_paid,
    SUM(bl.amount)       AS total_money_spent,
    DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) AS spending_rank,
    CASE
        WHEN DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) <= 3 THEN 'Hội Viên Kim Cương (VIP Tier 1)'
        WHEN DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) <= 8 THEN 'Hội Viên Bạch Kim (VIP Tier 2)'
        ELSE 'Hội Viên Tiêu Chuẩn (Standard)'
    END AS loyalty_tier
FROM
    user_account u
JOIN
    member_subscription ms ON u.user_id = ms.member_user_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
GROUP BY
    u.user_id,
    u.full_name,
    u.phone,
    u.email
ORDER BY
    spending_rank ASC,
    total_money_spent DESC;


-- ============================================================================
-- CÂU TRUY VẤN 10: PHÁT HIỆN XUNG ĐỘT TRÙNG LỊCH CỦA HUẤN LUYỆN VIÊN HOẶC PHÒNG TẬP
-- Mục đích nghiệp vụ: Kiểm toán tính toàn vẹn (Integrity Audit) nhằm phát hiện
-- bất kỳ sự kiện nào bị đụng giờ (Overlapping Time Intervals - BR-12, BR-15) giữa
-- các lớp học nhóm và ca tập PT 1-1 của cùng Huấn luyện viên.
-- Kỹ thuật SQL: CTE (WITH), Self-Join khoảng thời gian (start_a < end_b AND end_a > start_b)
-- Ghi chú: do các quy tắc BR-12/BR-15/BR-16 nay đã được CSDL cưỡng chế (EXCLUDE constraint và
-- trigger), truy vấn này là truy vấn KIỂM TOÁN và được kỳ vọng trả về 0 dòng; nếu xuất hiện
-- dòng nào thì dữ liệu đã bị nạp/sửa vượt qua cơ chế bảo vệ.
-- ============================================================================
WITH all_trainer_events AS (
    -- Tập hợp tất cả sự kiện có sự tham gia của HLV (Lớp nhóm)
    SELECT
        cs.class_id AS event_id,
        'GROUP_CLASS' AS event_type,
        cs.trainer_user_id AS trainer_id,
        cs.class_name AS event_title,
        cs.start_time,
        cs.end_time
    FROM
        class_schedule cs

    UNION ALL

    -- Tập hợp tất cả ca dạy PT 1-1 chưa bị hủy
    SELECT
        pb.booking_id AS event_id,
        'PT_BOOKING' AS event_type,
        pb.trainer_user_id AS trainer_id,
        CONCAT('Ca tập PT với Hội viên ID: ', pb.member_user_id) AS event_title,
        pb.start_time,
        pb.end_time
    FROM
        pt_booking pb
    WHERE
        pb.status IN ('Scheduled', 'Completed')
)
SELECT
    e1.trainer_id,
    u.full_name AS trainer_name,
    e1.event_type  AS first_event_type,
    e1.event_title AS first_event_title,
    e1.start_time  AS first_start_time,
    e1.end_time    AS first_end_time,
    e2.event_type  AS conflict_event_type,
    e2.event_title AS conflict_event_title,
    e2.start_time  AS conflict_start_time,
    e2.end_time    AS conflict_end_time,
    'CẢNH BÁO: TRÙNG LỊCH HLV (BR-12)' AS conflict_alert
FROM
    all_trainer_events e1
JOIN
    all_trainer_events e2 ON e1.trainer_id = e2.trainer_id
                         -- Điều kiện chồng lấn thời gian (Overlapping intervals)
                         AND e1.start_time < e2.end_time
                         AND e1.end_time > e2.start_time
JOIN
    user_account u ON e1.trainer_id = u.user_id
WHERE
    (e1.event_type, e1.event_id) < (e2.event_type, e2.event_id) -- Tránh lặp lại kết quả theo thứ tự hoán vị
ORDER BY
    e1.start_time ASC;
