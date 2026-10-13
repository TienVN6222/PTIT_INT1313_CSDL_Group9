-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 04_triggers_views.sql - KHỞI TẠO CÁC KHUNG NHÌN (VIEWS) VÀ BỘ KÍCH HOẠT (TRIGGERS)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell) / PL/pgSQL Procedural Standard
-- ============================================================================

-- ============================================================================
-- PHẦN 1: CÁC KHUNG NHÌN (VIEWS)
-- ============================================================================

-- VIEW 1: vw_active_member_subscriptions
-- Mục đích nghiệp vụ: Tổng hợp thông tin hợp đồng đang còn hiệu lực (Active)
-- của từng hội viên, bao gồm tên gói, ngày bắt đầu, ngày hết hạn, số buổi PT còn lại,
-- số ngày hiệu lực còn lại và tình trạng gia hạn định kỳ.
DROP VIEW IF EXISTS vw_active_member_subscriptions CASCADE;
CREATE VIEW vw_active_member_subscriptions AS
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.email,
    u.phone,
    u.dob,
    mp.plan_id,
    mp.plan_name,
    mp.total_sessions AS package_initial_sessions,
    ms.subscription_id,
    ms.actual_price,
    ms.remaining_sessions AS current_remaining_pt_sessions,
    ms.start_time AS subscription_start,
    ms.end_time   AS subscription_end,
    ms.is_recurring,
    ROUND(EXTRACT(EPOCH FROM (ms.end_time - CURRENT_TIMESTAMP)) / 86400.0, 1) AS days_until_expiration,
    CASE
        WHEN ms.end_time < CURRENT_TIMESTAMP THEN 'Đã Quá Hạn'
        WHEN ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days' THEN 'Sắp Hết Hạn (<= 7 ngày)'
        ELSE 'Đang Hiệu Lực'
    END AS validity_status
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active';


-- VIEW 2: vw_trainer_schedule_overview
-- Mục đích nghiệp vụ: Cung cấp góc nhìn toàn diện hợp nhất cho Ban Quản lý và HLV,
-- bao quát toàn bộ các ca làm việc của HLV bao gồm cả đứng lớp nhóm (Group Class)
-- và dạy kèm cá nhân (PT 1-1) theo trình tự thời gian.
DROP VIEW IF EXISTS vw_trainer_schedule_overview CASCADE;
CREATE VIEW vw_trainer_schedule_overview AS
-- Nhóm 1: Lịch dạy lớp học nhóm
SELECT
    cs.class_id AS schedule_id,
    'Group Class' AS session_type,
    cs.trainer_user_id AS trainer_id,
    t.full_name AS trainer_name,
    cs.class_name AS activity_title,
    fr.room_id,
    fr.room_name AS location_name,
    NULL::INT AS member_id,
    NULL::VARCHAR AS member_name,
    cs.start_time,
    cs.end_time,
    ROUND((EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600.0)::NUMERIC, 2) AS duration_hours,
    CONCAT(cs.current_enrolled, '/', cs.max_capacity, ' học viên') AS attendance_info,
    'Scheduled' AS status
FROM
    class_schedule cs
JOIN
    user_account t ON cs.trainer_user_id = t.user_id
JOIN
    facilities_room fr ON cs.room_id = fr.room_id

UNION ALL

-- Nhóm 2: Lịch dạy kèm cá nhân PT 1-1
SELECT
    pb.booking_id AS schedule_id,
    'PT 1-on-1' AS session_type,
    pb.trainer_user_id AS trainer_id,
    t.full_name AS trainer_name,
    'Ca tập Huấn luyện viên 1-1' AS activity_title,
    NULL::INT AS room_id,
    'Khu vực tập tự do (Gym Floor)' AS location_name,
    m.user_id AS member_id,
    m.full_name AS member_name,
    pb.start_time,
    pb.end_time,
    ROUND((EXTRACT(EPOCH FROM (pb.end_time - pb.start_time)) / 3600.0)::NUMERIC, 2) AS duration_hours,
    '1-on-1 Coaching' AS attendance_info,
    pb.status
FROM
    pt_booking pb
JOIN
    user_account t ON pb.trainer_user_id = t.user_id
JOIN
    user_account m ON pb.member_user_id = m.user_id;


-- ============================================================================
-- PHẦN 2: BỘ KÍCH HOẠT (TRIGGERS)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRIGGER 1: trg_update_remaining_pt_sessions (BR-18, BR-25)
-- Nghiệp vụ: Khi một ca tập PT 1-1 (pt_booking) được cập nhật trạng thái sang 'Completed',
-- hệ thống tự động trừ 1 buổi trong trường remaining_sessions của bảng member_subscription.
-- Nếu số buổi còn lại <= 0, hệ thống ngăn chặn và báo lỗi ngoại lệ (Raise Exception).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_update_remaining_pt_sessions()
RETURNS TRIGGER AS $$
DECLARE
    v_current_remaining INT;
    v_sub_status VARCHAR(20);
BEGIN
    -- Chỉ kích hoạt khi trạng thái chuyển thành 'Completed' từ một trạng thái khác
    IF (NEW.status = 'Completed' AND (OLD.status IS NULL OR OLD.status <> 'Completed')) THEN
        -- Khóa bản ghi hợp đồng để kiểm tra tránh tranh chấp đồng thời (Concurrency Control)
        SELECT remaining_sessions, sub_status
        INTO v_current_remaining, v_sub_status
        FROM member_subscription
        WHERE subscription_id = NEW.subscription_id
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Không tìm thấy hợp đồng đăng ký ID: % tương ứng', NEW.subscription_id;
        END IF;

        IF v_current_remaining <= 0 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Hợp đồng ID: % đã hết số buổi tập PT khả dụng (Còn lại: % buổi)', 
                NEW.subscription_id, v_current_remaining;
        END IF;

        -- Trừ 1 buổi tập còn lại
        UPDATE member_subscription
        SET remaining_sessions = remaining_sessions - 1
        WHERE subscription_id = NEW.subscription_id;
        
        RAISE NOTICE 'Đã tự động trừ 1 buổi PT cho hợp đồng ID: %. Số buổi còn lại: %', 
            NEW.subscription_id, (v_current_remaining - 1);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_remaining_pt_sessions ON pt_booking;
CREATE TRIGGER trg_update_remaining_pt_sessions
AFTER UPDATE OF status ON pt_booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_update_remaining_pt_sessions();


-- ----------------------------------------------------------------------------
-- TRIGGER 2: trg_prevent_booking_under_maintenance (BR-19, BR-21)
-- Nghiệp vụ: Tự động ngăn chặn mọi thao tác tạo hoặc cập nhật lịch lớp học (class_schedule)
-- nếu Phòng tập đang ở trạng thái 'Under_Maintenance'; đồng thời ngăn chặn việc tạo lượt giữ chỗ
-- thiết bị (equipment_reservation) nếu Thiết bị đang ở trạng thái 'Under_Maintenance'.
-- ----------------------------------------------------------------------------

-- 2.1 Kiểm tra phòng tập cho Lớp học nhóm
CREATE OR REPLACE FUNCTION trg_fn_prevent_room_under_maintenance()
RETURNS TRIGGER AS $$
DECLARE
    v_room_status VARCHAR(20);
    v_room_name   VARCHAR(100);
BEGIN
    SELECT status, room_name
    INTO v_room_status, v_room_name
    FROM facilities_room
    WHERE room_id = NEW.room_id;

    IF (v_room_status = 'Under_Maintenance') THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-19: Phòng tập "%" (ID: %) hiện đang ở trạng thái BẢO TRÌ (Under_Maintenance). Không thể xếp lịch!',
            v_room_name, NEW.room_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_class_in_maintenance_room ON class_schedule;
CREATE TRIGGER trg_prevent_class_in_maintenance_room
BEFORE INSERT OR UPDATE OF room_id ON class_schedule
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_room_under_maintenance();


-- 2.2 Kiểm tra thiết bị cho Lượt giữ chỗ
CREATE OR REPLACE FUNCTION trg_fn_prevent_equipment_under_maintenance()
RETURNS TRIGGER AS $$
DECLARE
    v_equip_status VARCHAR(20);
    v_equip_name   VARCHAR(100);
BEGIN
    SELECT status, equipment_name
    INTO v_equip_status, v_equip_name
    FROM equipment
    WHERE equipment_id = NEW.equipment_id;

    IF (v_equip_status = 'Under_Maintenance') THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-19: Thiết bị "%" (ID: %) hiện đang BẢO TRÌ (Under_Maintenance). Không thể tạo lịch giữ chỗ!',
            v_equip_name, NEW.equipment_id;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_equipment_reservation_under_maintenance ON equipment_reservation;
CREATE TRIGGER trg_prevent_equipment_reservation_under_maintenance
BEFORE INSERT OR UPDATE OF equipment_id ON equipment_reservation
FOR EACH ROW
EXECUTE FUNCTION trg_fn_prevent_equipment_under_maintenance();
