-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 09_rbac_test_cases.sql - KIỂM THỬ PHÂN QUYỀN THEO VAI TRÒ (MỤC 5.2)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell)
-- ----------------------------------------------------------------------------
-- ĐIỀU KIỆN CHẠY: đã nạp 01_schema_ddl.sql -> 02_mock_data/*.sql -> 04_triggers_views.sql
--                 -> 08_rbac_security.sql. Chạy bằng superuser (để SET ROLE sang các role nhóm).
-- CÁCH CHẠY:      psql -U <superuser> -d <db> -f "Phase 3/09_rbac_test_cases.sql"
--
-- NGUYÊN TẮC:
--   * BR-10 có 2 lớp: trigger bất biến (mọi role, kể cả chủ sở hữu) và GRANT/REVOKE; các test
--     AD-01..03 kiểm tra lớp phân quyền (42501 xảy ra trước khi trigger được kích hoạt).
--   * Nhóm RD (Denied): role bị từ chối thao tác trái quyền. Test ĐẠT (PASS) khi
--     CSDL trả đúng SQLSTATE 42501 (insufficient_privilege).
--   * Nhóm RA (Allowed): thao tác hợp lệ của role phải được chấp nhận, và dữ liệu
--     dẫn xuất (do trigger SECURITY DEFINER) phải đúng. Câu kiểm tra kết quả được
--     chạy bằng quyền superuser sau khi đã RESET ROLE.
--   * Mỗi test chạy trong một savepoint riêng (khối BEGIN ... EXCEPTION); lệnh
--     SET LOCAL ROLE tự được hoàn tác cùng savepoint. Toàn bộ tập tin được bọc
--     trong BEGIN ... ROLLBACK => dữ liệu mẫu và role không bị thay đổi.
--   * Mốc thời gian của test KHÔNG viết cứng: dùng hàm pg_temp.night_slot(n) = 21:00 của
--     ngày hôm nay + n ngày (khung đêm 21:00-23:59 không có lịch mẫu nào) và
--     pg_temp.next_late_slot() = khung đêm kế tiếp cách bây giờ > 30 phút và < 24 giờ
--     (dùng cho kịch bản hủy muộn BR-25), nên test luôn nằm trong thời hạn hợp đồng mẫu.
-- ============================================================================

BEGIN;

SET client_min_messages = WARNING;

-- ----------------------------------------------------------------------------
-- BẢNG KẾT QUẢ & HÀM HỖ TRỢ (chỉ tồn tại trong phiên làm việc hiện tại)
-- ----------------------------------------------------------------------------
CREATE TEMP TABLE test_result (
    run_order          SERIAL,
    tc_id              VARCHAR(10)  NOT NULL,
    role_name          VARCHAR(30)  NOT NULL,
    description        VARCHAR(200) NOT NULL,
    expected_sqlstate  VARCHAR(5)   NOT NULL,
    actual_sqlstate    VARCHAR(5),
    result             VARCHAR(4)   NOT NULL,
    db_message         TEXT
);

-- Negative test: role bị cấm phải nhận lỗi đúng SQLSTATE (mặc định 42501).
-- p_setup_statements chạy bằng quyền superuser TRƯỚC khi chuyển sang role cần thử.
CREATE FUNCTION pg_temp.expect_denied(
    p_tc_id             VARCHAR,
    p_role              VARCHAR,
    p_description       VARCHAR,
    p_statements        TEXT[],
    p_expected_sqlstate VARCHAR DEFAULT '42501',
    p_setup_statements  TEXT[]  DEFAULT ARRAY[]::TEXT[]
)
RETURNS VOID AS $$
DECLARE
    v_statement TEXT;
BEGIN
    FOREACH v_statement IN ARRAY p_setup_statements LOOP
        EXECUTE v_statement;
    END LOOP;

    EXECUTE format('SET LOCAL ROLE %I', p_role);

    FOREACH v_statement IN ARRAY p_statements LOOP
        EXECUTE v_statement;
    END LOOP;

    -- Không có lỗi nào => quyền KHÔNG bị chặn. Ném lỗi để hoàn tác thao tác.
    RAISE EXCEPTION USING ERRCODE = 'TF001', MESSAGE = 'Thao tác trái quyền KHÔNG bị chặn';
EXCEPTION
    WHEN OTHERS THEN
        -- Savepoint của khối EXCEPTION đã hoàn tác SET LOCAL ROLE => đang là superuser.
        INSERT INTO test_result (tc_id, role_name, description, expected_sqlstate,
                                 actual_sqlstate, result, db_message)
        VALUES (p_tc_id, p_role, p_description, p_expected_sqlstate,
                SQLSTATE,
                CASE WHEN SQLSTATE = p_expected_sqlstate THEN 'PASS' ELSE 'FAIL' END,
                SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- Positive test: role được phép phải thực hiện thành công; câu kiểm tra (chạy bằng
-- quyền superuser sau khi RESET ROLE) phải trả về TRUE.
CREATE FUNCTION pg_temp.expect_allowed(
    p_tc_id            VARCHAR,
    p_role             VARCHAR,
    p_description      VARCHAR,
    p_statements       TEXT[],
    p_check_sql        TEXT,
    p_setup_statements TEXT[] DEFAULT ARRAY[]::TEXT[]
)
RETURNS VOID AS $$
DECLARE
    v_statement TEXT;
    v_is_ok     BOOLEAN := FALSE;
BEGIN
    FOREACH v_statement IN ARRAY p_setup_statements LOOP
        EXECUTE v_statement;
    END LOOP;

    EXECUTE format('SET LOCAL ROLE %I', p_role);

    FOREACH v_statement IN ARRAY p_statements LOOP
        EXECUTE v_statement;
    END LOOP;

    RESET ROLE;
    EXECUTE p_check_sql INTO v_is_ok;

    -- Luôn ném lỗi kỹ thuật để hoàn tác dữ liệu thử nghiệm.
    RAISE EXCEPTION USING ERRCODE = 'TS000', MESSAGE = 'rollback';
EXCEPTION
    WHEN SQLSTATE 'TS000' THEN
        INSERT INTO test_result (tc_id, role_name, description, expected_sqlstate,
                                 actual_sqlstate, result, db_message)
        VALUES (p_tc_id, p_role, p_description, '00000', '00000',
                CASE WHEN v_is_ok THEN 'PASS' ELSE 'FAIL' END,
                CASE WHEN v_is_ok THEN 'Thao tác hợp lệ được chấp nhận, kết quả đúng'
                     ELSE 'Thao tác chạy được nhưng kết quả kiểm tra sai' END);
    WHEN OTHERS THEN
        INSERT INTO test_result (tc_id, role_name, description, expected_sqlstate,
                                 actual_sqlstate, result, db_message)
        VALUES (p_tc_id, p_role, p_description, '00000', SQLSTATE, 'FAIL', SQLERRM);
END;
$$ LANGUAGE plpgsql;


-- Mốc đêm: 21:00 của ngày (hôm nay + p_days). Không lịch mẫu nào rơi vào khung 21:00-23:59.
CREATE FUNCTION pg_temp.night_slot(p_days INT)
RETURNS TIMESTAMP AS $$
    SELECT DATE_TRUNC('day', LOCALTIMESTAMP) + make_interval(days => p_days, hours => 21);
$$ LANGUAGE sql STABLE;

-- Mốc đêm kế tiếp cách hiện tại > 30 phút và luôn < 24 giờ (hủy trong vòng 24h => Late_Cancelled).
-- Ứng viên: 21:00 hôm nay, 22:30 hôm nay, 21:00 ngày mai.
CREATE FUNCTION pg_temp.next_late_slot()
RETURNS TIMESTAMP AS $$
    SELECT MIN(c.slot)
    FROM (VALUES
        (DATE_TRUNC('day', LOCALTIMESTAMP) + INTERVAL '21 hours'),
        (DATE_TRUNC('day', LOCALTIMESTAMP) + INTERVAL '22 hours 30 minutes'),
        (DATE_TRUNC('day', LOCALTIMESTAMP) + INTERVAL '1 day 21 hours')
    ) AS c (slot)
    WHERE c.slot > LOCALTIMESTAMP + INTERVAL '30 minutes';
$$ LANGUAGE sql STABLE;


-- ============================================================================
-- PHẦN 1: LỄ TÂN (gym_role_receptionist - quyền 1, 2, 3, 5, 6, 7)
-- ============================================================================

SELECT pg_temp.expect_allowed('RA-01', 'gym_role_receptionist', 'Tạo tài khoản hội viên mới kèm hồ sơ member_profile', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Hoi Vien Le Tan', 'ra01@test.vn', '0999100001', DATE '2000-01-01', 'hash')$q$,
    $q$INSERT INTO member_profile (user_id)
       SELECT user_id
       FROM user_account
       WHERE email = 'ra01@test.vn'$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM member_profile AS mp
          JOIN user_account AS ua ON ua.user_id = mp.user_id
          WHERE ua.email = 'ra01@test.vn')$q$);

SELECT pg_temp.expect_allowed('RA-02', 'gym_role_receptionist', 'Đọc thông tin hội viên (không gồm password_hash)', ARRAY[
    $q$SELECT user_id, full_name, email, phone, dob FROM user_account WHERE user_id = 11$q$
], $q$SELECT TRUE$q$);

SELECT pg_temp.expect_denied('RD-01', 'gym_role_receptionist', 'Đọc cột password_hash của user_account', ARRAY[
    $q$SELECT password_hash FROM user_account$q$
]);

SELECT pg_temp.expect_denied('RD-02', 'gym_role_receptionist', 'SELECT * trên user_account (bao gồm password_hash)', ARRAY[
    $q$SELECT * FROM user_account$q$
]);

SELECT pg_temp.expect_denied('RD-03', 'gym_role_receptionist', 'UPDATE hóa đơn billing_log (BR-10)', ARRAY[
    $q$UPDATE billing_log SET amount = 1 WHERE billing_id = 1$q$
]);

SELECT pg_temp.expect_denied('RD-04', 'gym_role_receptionist', 'DELETE hóa đơn billing_log (BR-10)', ARRAY[
    $q$DELETE FROM billing_log WHERE billing_id = 1$q$
]);

SELECT pg_temp.expect_denied('RD-05', 'gym_role_receptionist', 'DELETE hợp đồng member_subscription', ARRAY[
    $q$DELETE FROM member_subscription WHERE subscription_id = 1$q$
]);

SELECT pg_temp.expect_denied('RD-06', 'gym_role_receptionist', 'UPDATE giá gói tập membership_plan (thuộc quyền Admin)', ARRAY[
    $q$UPDATE membership_plan SET price = 1 WHERE plan_id = 1$q$
]);

SELECT pg_temp.expect_allowed('RA-03', 'gym_role_receptionist', 'Thêm đăng ký lớp: trigger SECURITY DEFINER cập nhật current_enrolled (lớp ID 2: 16 -> 17)', ARRAY[
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT MIN(ms.subscription_id), 2
       FROM member_subscription AS ms
       WHERE NOT EXISTS (
           SELECT 1
           FROM class_enrollment AS ce
           WHERE ce.class_id = 2
             AND ce.subscription_id = ms.subscription_id
       )$q$
], $q$SELECT current_enrolled = 17
      FROM class_schedule
      WHERE class_id = 2$q$);

SELECT pg_temp.expect_allowed('RA-04', 'gym_role_receptionist', 'Ghi nhận hóa đơn thanh toán mới vào billing_log', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method)
       VALUES (1, CURRENT_DATE + 1, 'INV-RA04', 1500000, CURRENT_DATE, 'Cash')$q$
], $q$SELECT EXISTS (SELECT 1 FROM billing_log WHERE invoice_no = 'INV-RA04')$q$);

SELECT pg_temp.expect_allowed('RA-05', 'gym_role_receptionist', 'Gọi thủ tục sp_process_subscription_renewals (BR-24): phát hành hóa đơn gia hạn Pending', ARRAY[
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 400, 3)$q$
], $q$SELECT EXISTS (SELECT 1 FROM billing_log WHERE invoice_no LIKE 'INV-RNW-%' AND payment_status = 'Pending')$q$);

SELECT pg_temp.expect_allowed('RA-06', 'gym_role_receptionist', 'Tạo hợp đồng Pending + hóa đơn Completed: chuỗi trigger tự kích hoạt Active (BR-07) và điền created_by_user_id (BR-23)', ARRAY[
    $q$INSERT INTO member_subscription (member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time)
       SELECT MIN(mp.user_id), 5, 4500000, 10, LOCALTIMESTAMP, LOCALTIMESTAMP + INTERVAL '45 days'
       FROM member_profile AS mp
       WHERE NOT EXISTS (
           SELECT 1
           FROM member_subscription AS ms
           WHERE ms.member_user_id = mp.user_id
             AND ms.sub_status = 'Active')$q$,
    $q$INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method)
       SELECT MAX(subscription_id), 'INV-RA06', 4500000, CURRENT_DATE, 'Banking'
       FROM member_subscription$q$
], $q$SELECT ms.sub_status = 'Active'
         AND ms.created_by_user_id = 3
         AND bl.created_by_user_id = 3
         AND bl.billing_period_start = ms.start_time::DATE
      FROM billing_log AS bl
      JOIN member_subscription AS ms ON ms.subscription_id = bl.subscription_id
      WHERE bl.invoice_no = 'INV-RA06'$q$, ARRAY[
    $q$SET LOCAL app.current_user_id = '3'$q$
]);

SELECT pg_temp.expect_denied('RD-07', 'gym_role_receptionist', 'Ghi đè billing_log.created_by_user_id (BR-10: UPDATE hóa đơn bị cấm)', ARRAY[
    $q$UPDATE billing_log SET created_by_user_id = 3 WHERE billing_id = 1$q$
]);


-- ============================================================================
-- PHẦN 2: HUẤN LUYỆN VIÊN (gym_role_trainer - quyền 1, 6, 7)
-- ============================================================================

SELECT pg_temp.expect_allowed('TA-01', 'gym_role_trainer', 'Đánh dấu ca PT Completed: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15)', ARRAY[
    $q$UPDATE pt_booking
       SET status = 'Completed'
       WHERE subscription_id = 1
         AND start_time = pg_temp.night_slot(3)$q$
], $q$SELECT remaining_sessions = 15
      FROM member_subscription
      WHERE subscription_id = 1$q$, ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.night_slot(3)::DATE, pg_temp.night_slot(3), pg_temp.night_slot(3) + INTERVAL '1 hour')$q$
]);

SELECT pg_temp.expect_allowed('TA-02', 'gym_role_trainer', 'Đánh dấu ca PT No_Show: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15)', ARRAY[
    $q$UPDATE pt_booking
       SET status = 'No_Show'
       WHERE subscription_id = 1
         AND start_time = pg_temp.night_slot(4)$q$
], $q$SELECT ms.remaining_sessions = 15
         AND pb.status = 'No_Show'
      FROM member_subscription AS ms
      JOIN pt_booking AS pb ON pb.subscription_id = ms.subscription_id
      WHERE ms.subscription_id = 1
        AND pb.start_time = pg_temp.night_slot(4)$q$, ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.night_slot(4)::DATE, pg_temp.night_slot(4), pg_temp.night_slot(4) + INTERVAL '1 hour')$q$
]);

SELECT pg_temp.expect_allowed('TA-03', 'gym_role_trainer', 'Hủy ca PT < 24h: trigger đổi Cancelled thành Late_Cancelled và trừ 1 buổi (BR-25)', ARRAY[
    $q$UPDATE pt_booking
       SET status = 'Cancelled'
       WHERE subscription_id = 1
         AND start_time = pg_temp.next_late_slot()$q$
], $q$SELECT ms.remaining_sessions = 15
         AND pb.status = 'Late_Cancelled'
      FROM member_subscription AS ms
      JOIN pt_booking AS pb ON pb.subscription_id = ms.subscription_id
      WHERE ms.subscription_id = 1
        AND pb.start_time = pg_temp.next_late_slot()$q$, ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.next_late_slot()::DATE, pg_temp.next_late_slot(), pg_temp.next_late_slot() + INTERVAL '1 hour')$q$
]);

SELECT pg_temp.expect_allowed('TA-04', 'gym_role_trainer', 'Điểm danh lớp học: đổi class_enrollment.status sang Attended', ARRAY[
    $q$UPDATE class_enrollment SET status = 'Attended' WHERE enrollment_id = 1$q$
], $q$SELECT status = 'Attended'
      FROM class_enrollment
      WHERE enrollment_id = 1$q$, ARRAY[
    $q$UPDATE class_enrollment SET status = 'Enrolled' WHERE enrollment_id = 1$q$
]);

SELECT pg_temp.expect_allowed('TA-05', 'gym_role_trainer', 'Đọc khung nhìn vw_trainer_schedule_overview', ARRAY[
    $q$SELECT * FROM vw_trainer_schedule_overview$q$
], $q$SELECT COUNT(*) > 0
      FROM vw_trainer_schedule_overview$q$);

SELECT pg_temp.expect_denied('TD-01', 'gym_role_trainer', 'Đổi HLV phụ trách pt_booking.trainer_user_id', ARRAY[
    $q$UPDATE pt_booking SET trainer_user_id = 6 WHERE booking_id = 1$q$
]);

SELECT pg_temp.expect_denied('TD-02', 'gym_role_trainer', 'Đọc billing_log', ARRAY[
    $q$SELECT * FROM billing_log$q$
]);

SELECT pg_temp.expect_denied('TD-03', 'gym_role_trainer', 'Đọc user_account.email của hội viên', ARRAY[
    $q$SELECT email FROM user_account$q$
]);

SELECT pg_temp.expect_denied('TD-04', 'gym_role_trainer', 'Đọc member_subscription.actual_price (cột giá tiền)', ARRAY[
    $q$SELECT actual_price FROM member_subscription$q$
]);

SELECT pg_temp.expect_denied('TD-05', 'gym_role_trainer', 'Sửa trực tiếp số buổi member_subscription.remaining_sessions', ARRAY[
    $q$UPDATE member_subscription SET remaining_sessions = 99 WHERE subscription_id = 1$q$
]);

SELECT pg_temp.expect_denied('TD-06', 'gym_role_trainer', 'Tạo lịch lớp học mới (INSERT class_schedule)', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (5, 2, 'Lop Trai Quyen', pg_temp.night_slot(5), pg_temp.night_slot(5) + INTERVAL '1 hour', 10)$q$
]);

SELECT pg_temp.expect_denied('TD-07', 'gym_role_trainer', 'Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân)', ARRAY[
    $q$CALL sp_process_subscription_renewals()$q$
]);


-- ============================================================================
-- PHẦN 3: KỸ THUẬT VIÊN (gym_role_technician - quyền 8, 9)
-- ============================================================================

SELECT pg_temp.expect_allowed('EA-01', 'gym_role_technician', 'Ghi nhật ký bảo trì mới vào maintenance_log', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       VALUES (1, 3, 'Thay day curoa may chay bo', pg_temp.night_slot(6))$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM maintenance_log
          WHERE issue_description = 'Thay day curoa may chay bo')$q$);

SELECT pg_temp.expect_allowed('EA-02', 'gym_role_technician', 'Cập nhật equipment.status sang Under_Maintenance', ARRAY[
    $q$UPDATE equipment SET status = 'Under_Maintenance' WHERE equipment_id = 1$q$
], $q$SELECT status = 'Under_Maintenance'
      FROM equipment
      WHERE equipment_id = 1$q$);

SELECT pg_temp.expect_allowed('EA-03', 'gym_role_technician', 'Quy trình BR-19: mở ca bảo trì In_Progress rồi hoàn tất, trigger tự đổi trạng thái thiết bị (Under_Maintenance -> Operational) dù role chỉ có UPDATE(status)', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       VALUES (8, 4, 'Thay chot hang an toan RBAC BR19', pg_temp.night_slot(6))$q$,
    $q$SELECT SET_CONFIG('t09.mid_status', (SELECT status FROM equipment WHERE equipment_id = 8), TRUE)$q$,
    $q$UPDATE maintenance_log
       SET status = 'Completed', end_time = pg_temp.night_slot(6) + INTERVAL '1 hour'
       WHERE issue_description = 'Thay chot hang an toan RBAC BR19'$q$
], $q$SELECT CURRENT_SETTING('t09.mid_status') = 'Under_Maintenance'
          AND (SELECT status FROM equipment WHERE equipment_id = 8) = 'Operational'$q$);

SELECT pg_temp.expect_denied('ED-01', 'gym_role_technician', 'Đọc billing_log', ARRAY[
    $q$SELECT * FROM billing_log$q$
]);

SELECT pg_temp.expect_denied('ED-02', 'gym_role_technician', 'Đọc user_account', ARRAY[
    $q$SELECT user_id FROM user_account$q$
]);

SELECT pg_temp.expect_denied('ED-03', 'gym_role_technician', 'Đọc member_subscription', ARRAY[
    $q$SELECT subscription_id FROM member_subscription$q$
]);

SELECT pg_temp.expect_denied('ED-04', 'gym_role_technician', 'Xóa thiết bị (DELETE equipment)', ARRAY[
    $q$DELETE FROM equipment WHERE equipment_id = 2$q$
]);

SELECT pg_temp.expect_denied('ED-05', 'gym_role_technician', 'Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân)', ARRAY[
    $q$CALL sp_process_subscription_renewals()$q$
]);


-- ============================================================================
-- PHẦN 4: HỘI VIÊN (gym_role_member - chỉ đọc danh mục công khai)
-- ============================================================================

SELECT pg_temp.expect_allowed('MA-01', 'gym_role_member', 'Xem lịch lớp học nhóm class_schedule', ARRAY[
    $q$SELECT class_name, start_time, current_enrolled FROM class_schedule$q$
], $q$SELECT COUNT(*) > 0
      FROM class_schedule$q$);

SELECT pg_temp.expect_denied('MD-01', 'gym_role_member', 'Đọc user_account', ARRAY[
    $q$SELECT full_name FROM user_account$q$
]);

SELECT pg_temp.expect_denied('MD-02', 'gym_role_member', 'Tự đặt ca PT (INSERT pt_booking)', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.night_slot(7)::DATE, pg_temp.night_slot(7), pg_temp.night_slot(7) + INTERVAL '1 hour')$q$
]);

SELECT pg_temp.expect_denied('MD-03', 'gym_role_member', 'Đọc billing_log', ARRAY[
    $q$SELECT * FROM billing_log$q$
]);

SELECT pg_temp.expect_denied('MD-04', 'gym_role_member', 'Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân)', ARRAY[
    $q$CALL sp_process_subscription_renewals()$q$
]);

SELECT pg_temp.expect_denied('MD-05', 'gym_role_member', 'Đọc class_schedule.created_by_user_id (cột nội bộ, BR-23)', ARRAY[
    $q$SELECT created_by_user_id FROM class_schedule$q$
]);


-- ============================================================================
-- PHẦN 5: QUẢN TRỊ VIÊN (gym_role_admin - quyền 1-10)
-- ============================================================================

SELECT pg_temp.expect_allowed('AA-01', 'gym_role_admin', 'Điều chỉnh giá gói tập membership_plan', ARRAY[
    $q$UPDATE membership_plan SET price = 900000 WHERE plan_id = 1$q$
], $q$SELECT price = 900000
      FROM membership_plan
      WHERE plan_id = 1$q$);

SELECT pg_temp.expect_allowed('AA-02', 'gym_role_admin', 'Tạo tài khoản mới và đặt password_hash (INSERT cột nhạy cảm)', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Admin Tao TK', 'aa02@test.vn', '0999100002', DATE '1990-01-01', 'hash')$q$
], $q$SELECT EXISTS (SELECT 1 FROM user_account WHERE email = 'aa02@test.vn')$q$);

SELECT pg_temp.expect_allowed('AA-03', 'gym_role_admin', 'Gọi thủ tục sp_process_subscription_renewals (BR-24)', ARRAY[
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 400, 3)$q$
], $q$SELECT EXISTS (SELECT 1 FROM billing_log WHERE invoice_no LIKE 'INV-RNW-%' AND payment_status = 'Pending')$q$);

SELECT pg_temp.expect_denied('AD-01', 'gym_role_admin', 'UPDATE hóa đơn billing_log (BR-10, kể cả Admin)', ARRAY[
    $q$UPDATE billing_log SET amount = 1 WHERE billing_id = 1$q$
]);

SELECT pg_temp.expect_denied('AD-02', 'gym_role_admin', 'DELETE hóa đơn billing_log (BR-10, kể cả Admin)', ARRAY[
    $q$DELETE FROM billing_log WHERE billing_id = 1$q$
]);

SELECT pg_temp.expect_denied('AD-03', 'gym_role_admin', 'TRUNCATE billing_log (không thể vượt rào DELETE)', ARRAY[
    $q$TRUNCATE billing_log CASCADE$q$
]);

SELECT pg_temp.expect_denied('AD-04', 'gym_role_admin', 'Đọc cột password_hash của user_account', ARRAY[
    $q$SELECT password_hash FROM user_account$q$
]);


-- ============================================================================
-- PHẦN 6: TÀI KHOẢN ĐĂNG NHẬP MẪU THỪA HƯỞNG QUYỀN TỪ ROLE NHÓM (INHERIT)
-- ============================================================================

SELECT pg_temp.expect_denied('LD-01', 'gym_u_trainer', 'Tài khoản gym_u_trainer thừa hưởng: không đọc được billing_log', ARRAY[
    $q$SELECT * FROM billing_log$q$
]);

SELECT pg_temp.expect_allowed('LA-01', 'gym_u_tech', 'Tài khoản gym_u_tech thừa hưởng: đọc được equipment', ARRAY[
    $q$SELECT * FROM equipment$q$
], $q$SELECT COUNT(*) > 0
      FROM equipment$q$);


-- ============================================================================
-- BÁO CÁO KẾT QUẢ
-- ============================================================================
SELECT
    tc_id,
    role_name,
    description,
    expected_sqlstate,
    actual_sqlstate,
    result,
    LEFT(db_message, 110) AS db_message
FROM
    test_result
ORDER BY
    run_order;

SELECT
    COUNT(*)                                  AS total_tests,
    COUNT(*) FILTER (WHERE result = 'PASS')   AS passed,
    COUNT(*) FILTER (WHERE result = 'FAIL')   AS failed
FROM
    test_result;

SELECT current_user AS session_user_after_tests;

ROLLBACK;
