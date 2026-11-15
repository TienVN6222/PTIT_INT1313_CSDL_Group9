-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 05_constraint_test_cases.sql - KIỂM THỬ RÀNG BUỘC TOÀN VẸN (MỤC 5.1)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell)
-- ----------------------------------------------------------------------------
-- ĐIỀU KIỆN CHẠY: đã nạp 01_schema_ddl.sql -> 02_mock_data/*.sql -> 04_triggers_views.sql
-- CÁCH CHẠY:      psql -U <user> -d <db> -f "Phase 3/05_constraint_test_cases.sql"
--
-- NGUYÊN TẮC:
--   * Nhóm TC (Negative test): cố tình chèn/sửa/xóa dữ liệu SAI. Test ĐẠT (PASS)
--     khi CSDL từ chối thao tác với đúng mã lỗi SQLSTATE mong đợi.
--   * Nhóm TP (Positive test): thao tác HỢP LỆ phải được chấp nhận và
--     trigger phải cập nhật dữ liệu dẫn xuất đúng.
--   * Mỗi test chạy trong một savepoint riêng và LUÔN bị hoàn tác (rollback),
--     toàn bộ tập tin cũng được bọc trong BEGIN ... ROLLBACK => dữ liệu mẫu
--     không bị thay đổi sau khi chạy.
--   * Lịch tập dùng năm 2030 để không đụng lịch có sẵn trong dữ liệu mẫu.
--
-- MÃ SQLSTATE THAM CHIẾU:
--   23502 not_null_violation    | 23503 foreign_key_violation
--   23505 unique_violation      | 23514 check_violation
--   23P01 exclusion_violation   | P0001 raise_exception (lỗi do trigger chủ động ném)
-- ============================================================================

BEGIN;

SET client_min_messages = WARNING;

-- ----------------------------------------------------------------------------
-- BẢNG KẾT QUẢ & HÀM HỖ TRỢ (chỉ tồn tại trong phiên làm việc hiện tại)
-- ----------------------------------------------------------------------------
CREATE TEMP TABLE test_result (
    run_order          SERIAL,
    tc_id              VARCHAR(10)  NOT NULL,
    business_rule      VARCHAR(20)  NOT NULL,
    description        VARCHAR(200) NOT NULL,
    expected_sqlstate  VARCHAR(5)   NOT NULL,
    actual_sqlstate    VARCHAR(5),
    result             VARCHAR(4)   NOT NULL,
    db_message         TEXT
);

-- Negative test: các câu lệnh phải bị CSDL chặn với đúng SQLSTATE mong đợi.
CREATE FUNCTION pg_temp.expect_error(
    p_tc_id             VARCHAR,
    p_business_rule     VARCHAR,
    p_description       VARCHAR,
    p_expected_sqlstate VARCHAR,
    p_statements        TEXT[]
)
RETURNS VOID AS $$
DECLARE
    v_statement TEXT;
BEGIN
    FOREACH v_statement IN ARRAY p_statements LOOP
        EXECUTE v_statement;
    END LOOP;

    -- Không có lỗi nào => ràng buộc KHÔNG hoạt động. Ném lỗi để hoàn tác thao tác.
    RAISE EXCEPTION USING ERRCODE = 'TF001', MESSAGE = 'Thao tác sai KHÔNG bị chặn';
EXCEPTION
    WHEN OTHERS THEN
        INSERT INTO test_result (tc_id, business_rule, description, expected_sqlstate,
                                 actual_sqlstate, result, db_message)
        VALUES (p_tc_id, p_business_rule, p_description, p_expected_sqlstate,
                SQLSTATE,
                CASE WHEN SQLSTATE = p_expected_sqlstate THEN 'PASS' ELSE 'FAIL' END,
                SQLERRM);
END;
$$ LANGUAGE plpgsql;

-- Positive test: các câu lệnh phải thành công và câu kiểm tra phải trả về TRUE.
CREATE FUNCTION pg_temp.expect_success(
    p_tc_id         VARCHAR,
    p_business_rule VARCHAR,
    p_description   VARCHAR,
    p_statements    TEXT[],
    p_check_sql     TEXT
)
RETURNS VOID AS $$
DECLARE
    v_statement TEXT;
    v_is_ok     BOOLEAN := FALSE;
BEGIN
    FOREACH v_statement IN ARRAY p_statements LOOP
        EXECUTE v_statement;
    END LOOP;

    EXECUTE p_check_sql INTO v_is_ok;

    -- Luôn ném lỗi kỹ thuật để hoàn tác dữ liệu thử nghiệm.
    RAISE EXCEPTION USING ERRCODE = 'TS000', MESSAGE = 'rollback';
EXCEPTION
    WHEN SQLSTATE 'TS000' THEN
        INSERT INTO test_result (tc_id, business_rule, description, expected_sqlstate,
                                 actual_sqlstate, result, db_message)
        VALUES (p_tc_id, p_business_rule, p_description, '00000', '00000',
                CASE WHEN v_is_ok THEN 'PASS' ELSE 'FAIL' END,
                CASE WHEN v_is_ok THEN 'Thao tác hợp lệ được chấp nhận, kết quả đúng'
                     ELSE 'Thao tác chạy được nhưng kết quả kiểm tra sai' END);
    WHEN OTHERS THEN
        INSERT INTO test_result (tc_id, business_rule, description, expected_sqlstate,
                                 actual_sqlstate, result, db_message)
        VALUES (p_tc_id, p_business_rule, p_description, '00000', SQLSTATE, 'FAIL', SQLERRM);
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- PHẦN 1: TÀI KHOẢN NGƯỜI DÙNG & HỒ SƠ (BR-02, BR-03, BR-11)
-- ============================================================================

SELECT pg_temp.expect_error('TC-01', 'BR-02', 'Tạo tài khoản trùng email đã tồn tại', '23505', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       SELECT 'Test Trung Email', email, '0999000001', DATE '2000-01-01', 'x'
       FROM user_account
       WHERE user_id = 11$q$
]);

SELECT pg_temp.expect_error('TC-02', 'BR-02', 'Tạo tài khoản trùng số điện thoại đã tồn tại', '23505', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       SELECT 'Test Trung SDT', 'tc02@test.vn', phone, DATE '2000-01-01', 'x'
       FROM user_account
       WHERE user_id = 11$q$
]);

SELECT pg_temp.expect_error('TC-03', 'BR-02', 'Tạo tài khoản thiếu email (NOT NULL)', '23502', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Test Thieu Email', NULL, '0999000003', DATE '2000-01-01', 'x')$q$
]);

SELECT pg_temp.expect_error('TC-04', 'BR-03', 'Đăng ký hồ sơ hội viên cho người dưới 12 tuổi', 'P0001', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Be Duoi 12 Tuoi', 'tc04@test.vn', '0999000004', DATE '2020-01-01', 'x')$q$,
    $q$INSERT INTO member_profile (user_id)
       SELECT user_id
       FROM user_account
       WHERE email = 'tc04@test.vn'$q$
]);

SELECT pg_temp.expect_error('TC-05', 'BR-03', 'Sửa ngày sinh của hội viên hiện có thành dưới 12 tuổi', 'P0001', ARRAY[
    $q$UPDATE user_account
       SET dob = DATE '2020-01-01'
       WHERE user_id = 11$q$
]);

SELECT pg_temp.expect_error('TC-06', 'BR-22', 'Gán trạng thái tài khoản ngoài miền giá trị', '23514', ARRAY[
    $q$UPDATE user_account
       SET status = 'Deleted'
       WHERE user_id = 1$q$
]);

SELECT pg_temp.expect_error('TC-07', 'BR-11', 'Điểm đánh giá HLV vượt quá 5.00', '23514', ARRAY[
    $q$UPDATE trainer_profile
       SET current_rating = 5.50
       WHERE user_id = 5$q$
]);

SELECT pg_temp.expect_error('TC-08', 'BR-22', 'Gán cùng một vai trò hai lần cho một người dùng', '23505', ARRAY[
    $q$INSERT INTO user_role (user_id, role_id)
       SELECT user_id, role_id
       FROM user_role
       LIMIT 1$q$
]);


-- ============================================================================
-- PHẦN 2: GÓI TẬP, HỢP ĐỒNG & THANH TOÁN (BR-04, BR-06, BR-09)
-- ============================================================================

SELECT pg_temp.expect_error('TC-09', 'BR-04', 'Tạo gói tập có thời hạn 0 ngày', '23514', ARRAY[
    $q$INSERT INTO membership_plan (plan_name, duration_days, price)
       VALUES ('Goi Loi Thoi Han', 0, 500000)$q$
]);

SELECT pg_temp.expect_error('TC-10', 'BR-04', 'Tạo gói tập có giá âm', '23514', ARRAY[
    $q$INSERT INTO membership_plan (plan_name, duration_days, price)
       VALUES ('Goi Loi Gia', 30, -1)$q$
]);

SELECT pg_temp.expect_error('TC-11', 'BR-06', 'Hợp đồng có ngày kết thúc trước ngày bắt đầu', '23514', ARRAY[
    $q$INSERT INTO member_subscription (member_user_id, plan_id, actual_price, start_time, end_time)
       VALUES (11, 1, 500000, TIMESTAMP '2030-02-01', TIMESTAMP '2030-01-01')$q$
]);

SELECT pg_temp.expect_error('TC-12', 'BR-01', 'Ký hợp đồng cho người không có hồ sơ hội viên (HLV ID 5)', '23503', ARRAY[
    $q$INSERT INTO member_subscription (member_user_id, plan_id, actual_price, start_time, end_time)
       VALUES (5, 1, 500000, TIMESTAMP '2030-01-01', TIMESTAMP '2030-02-01')$q$
]);

SELECT pg_temp.expect_error('TC-13', 'BR-18', 'Số buổi PT còn lại bị âm', '23514', ARRAY[
    $q$UPDATE member_subscription
       SET remaining_sessions = -1
       WHERE subscription_id = 1$q$
]);

SELECT pg_temp.expect_error('TC-14', 'BR-09', 'Phát hành hóa đơn trùng số invoice_no', '23505', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method)
       SELECT 1, invoice_no, 100000, DATE '2030-01-01', 'Cash'
       FROM billing_log
       LIMIT 1$q$
]);

SELECT pg_temp.expect_error('TC-15', 'BR-09', 'Hóa đơn có số tiền bằng 0', '23514', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method)
       VALUES (1, 'INV-TC15', 0, DATE '2030-01-01', 'Cash')$q$
]);

SELECT pg_temp.expect_error('TC-16', 'BR-09', 'Phương thức thanh toán không hợp lệ', '23514', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method)
       VALUES (1, 'INV-TC16', 100000, DATE '2030-01-01', 'Bitcoin')$q$
]);

SELECT pg_temp.expect_error('TC-17', 'BR-10', 'Xóa hợp đồng đã phát sinh hóa đơn (ON DELETE RESTRICT)', '23503', ARRAY[
    $q$DELETE FROM member_subscription
       WHERE subscription_id = (SELECT MIN(subscription_id) FROM billing_log)$q$
]);

SELECT pg_temp.expect_error('TC-18', 'BR-04', 'Xóa gói tập đang được hợp đồng sử dụng', '23503', ARRAY[
    $q$DELETE FROM membership_plan
       WHERE plan_id = 1$q$
]);


-- ============================================================================
-- PHẦN 3: PHÒNG TẬP & LỚP HỌC NHÓM (BR-12, BR-13, BR-14, BR-15, BR-17, BR-19)
-- ============================================================================

SELECT pg_temp.expect_error('TC-19', 'BR-13', 'Phòng tập có sức chứa bằng 0', '23514', ARRAY[
    $q$INSERT INTO facilities_room (room_name, max_capacity, room_type)
       VALUES ('Phong Loi', 0, 'Studio')$q$
]);

SELECT pg_temp.expect_error('TC-20', 'BR-17', 'Lớp học có giờ kết thúc trước giờ bắt đầu', '23514', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (6, 1, 'Lop Loi Gio', TIMESTAMP '2030-01-01 10:00', TIMESTAMP '2030-01-01 09:00', 10)$q$
]);

SELECT pg_temp.expect_error('TC-21', 'BR-15', 'Xếp 2 lớp trùng giờ trong cùng một phòng', '23P01', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (7, 2, 'Lop A', TIMESTAMP '2030-01-01 06:00', TIMESTAMP '2030-01-01 07:00', 10)$q$,
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (8, 2, 'Lop B', TIMESTAMP '2030-01-01 06:30', TIMESTAMP '2030-01-01 07:30', 10)$q$
]);

SELECT pg_temp.expect_error('TC-22', 'BR-12', 'Một HLV dạy 2 lớp trùng giờ ở 2 phòng khác nhau', '23P01', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (6, 1, 'Lop C', TIMESTAMP '2030-01-01 06:00', TIMESTAMP '2030-01-01 07:00', 10)$q$,
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (6, 3, 'Lop D', TIMESTAMP '2030-01-01 06:30', TIMESTAMP '2030-01-01 07:30', 10)$q$
]);

SELECT pg_temp.expect_error('TC-23', 'BR-19', 'Xếp lớp vào phòng đang bảo trì (phòng ID 6)', 'P0001', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (9, 6, 'Lop Boxing', TIMESTAMP '2030-01-01 06:00', TIMESTAMP '2030-01-01 07:00', 10)$q$
]);

SELECT pg_temp.expect_error('TC-24', 'BR-14', 'Đăng ký thêm hội viên vào lớp đã đầy (lớp ID 1: 20/20)', '23514', ARRAY[
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT MIN(ms.subscription_id), 1
       FROM member_subscription AS ms
       WHERE NOT EXISTS (
           SELECT 1
           FROM class_enrollment AS ce
           WHERE ce.class_id = 1
             AND ce.subscription_id = ms.subscription_id
       )$q$
]);

SELECT pg_temp.expect_error('TC-25', 'BR-14', 'Một hợp đồng đăng ký cùng một lớp 2 lần', '23505', ARRAY[
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT subscription_id, class_id
       FROM class_enrollment
       ORDER BY enrollment_id
       LIMIT 1$q$
]);


-- ============================================================================
-- PHẦN 4: LỊCH PT 1-1 (BR-12, BR-16, BR-17, BR-18)
-- ============================================================================

SELECT pg_temp.expect_error('TC-26', 'BR-17', 'Ca PT có giờ kết thúc bằng giờ bắt đầu', '23514', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 08:00')$q$
]);

SELECT pg_temp.expect_error('TC-27', 'BR-12', 'Một HLV nhận 2 ca PT trùng giờ với 2 hội viên', '23P01', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (18, 5, 8, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:30', TIMESTAMP '2030-01-02 09:30')$q$
]);

SELECT pg_temp.expect_error('TC-28', 'BR-16', 'Một hội viên đặt 2 ca PT trùng giờ với 2 HLV', '23P01', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 9, 1, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:30', TIMESTAMP '2030-01-02 09:30')$q$
]);

SELECT pg_temp.expect_error('TC-29', 'BR-18', 'Đặt ca PT bằng hợp đồng của hội viên khác (FK ghép)', '23503', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 8, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$
]);

SELECT pg_temp.expect_error('TC-30', 'BR-18', 'Hoàn thành ca PT khi hợp đồng đã hết buổi (hợp đồng ID 2: 0 buổi)', 'P0001', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (12, 5, 2, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$,
    $q$UPDATE pt_booking
       SET status = 'Completed'
       WHERE subscription_id = 2
         AND start_time = TIMESTAMP '2030-01-02 08:00'$q$
]);

SELECT pg_temp.expect_error('TC-31', 'BR-25', 'Trạng thái ca PT ngoài miền giá trị', '23514', ARRAY[
    $q$UPDATE pt_booking
       SET status = 'Postponed'
       WHERE booking_id = 1$q$
]);


-- ============================================================================
-- PHẦN 5: THIẾT BỊ, GIỮ CHỖ & BẢO TRÌ (BR-19, BR-20, BR-21, BR-26)
-- ============================================================================

SELECT pg_temp.expect_error('TC-32', 'BR-26', 'Thiết bị có thời gian khấu hao 0 tháng', '23514', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (2, 'May Chay Loi', 'SN-TC32', DATE '2026-01-01', 0)$q$
]);

SELECT pg_temp.expect_error('TC-33', 'BR-26', 'Thiết bị trùng số serial', '23505', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       SELECT 2, 'May Trung Serial', serial_number, DATE '2026-01-01', 60
       FROM equipment
       WHERE equipment_id = 1$q$
]);

SELECT pg_temp.expect_error('TC-34', 'BR-19', 'Giữ chỗ thiết bị đang bảo trì (thiết bị ID 3)', 'P0001', ARRAY[
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       VALUES (3, 1, TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$
]);

SELECT pg_temp.expect_error('TC-35', 'BR-21', 'Lượt giữ chỗ gắn đồng thời cả ca PT và lớp học', '23514', ARRAY[
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, class_id, start_time, end_time)
       VALUES (1, 1, 1, TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$
]);

SELECT pg_temp.expect_error('TC-36', 'BR-21', 'Lượt giữ chỗ không gắn với ca PT hay lớp học nào', '23514', ARRAY[
    $q$INSERT INTO equipment_reservation (equipment_id, start_time, end_time)
       VALUES (1, TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$
]);

SELECT pg_temp.expect_error('TC-37', 'BR-20', 'Nhật ký bảo trì có chi phí âm', '23514', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time, cost)
       VALUES (1, 4, 'Test chi phi am', TIMESTAMP '2030-01-01 08:00', -100)$q$
]);

SELECT pg_temp.expect_error('TC-38', 'BR-20', 'Nhật ký bảo trì hoàn thành trước khi bắt đầu', '23514', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time, end_time)
       VALUES (1, 4, 'Test thoi gian', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-01 08:00')$q$
]);

SELECT pg_temp.expect_error('TC-39', 'BR-20', 'Giao việc bảo trì cho người không phải nhân viên (HLV ID 5)', '23503', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       VALUES (1, 5, 'Sai nguoi xu ly', TIMESTAMP '2030-01-01 08:00')$q$
]);


-- ============================================================================
-- PHẦN 6: POSITIVE TEST - DỮ LIỆU HỢP LỆ ĐƯỢC CHẤP NHẬN, TRIGGER CẬP NHẬT ĐÚNG
-- ============================================================================

SELECT pg_temp.expect_success('TP-01', 'BR-03', 'Hội viên đủ 18 tuổi được tạo hồ sơ thành công', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Hoi Vien Hop Le', 'tp01@test.vn', '0999100001', DATE '2008-01-01', 'x')$q$,
    $q$INSERT INTO member_profile (user_id)
       SELECT user_id
       FROM user_account
       WHERE email = 'tp01@test.vn'$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM member_profile AS mp
          JOIN user_account AS ua
              ON ua.user_id = mp.user_id
          WHERE ua.email = 'tp01@test.vn'
      )$q$);

SELECT pg_temp.expect_success('TP-02', 'BR-18', 'Hoàn thành ca PT tự động trừ 1 buổi (hợp đồng ID 1: 16 -> 15)', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, DATE '2030-01-02', TIMESTAMP '2030-01-02 08:00', TIMESTAMP '2030-01-02 09:00')$q$,
    $q$UPDATE pt_booking
       SET status = 'Completed'
       WHERE subscription_id = 1
         AND start_time = TIMESTAMP '2030-01-02 08:00'$q$
], $q$SELECT remaining_sessions = 15
      FROM member_subscription
      WHERE subscription_id = 1$q$);

SELECT pg_temp.expect_success('TP-03', 'BR-14', 'Đăng ký lớp tự động tăng current_enrolled (lớp ID 2: 16 -> 17)', ARRAY[
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

SELECT pg_temp.expect_success('TP-04', 'BR-14', 'Hủy đăng ký lớp tự động giảm current_enrolled (lớp ID 1: 20 -> 19)', ARRAY[
    $q$UPDATE class_enrollment
       SET status = 'Cancelled'
       WHERE enrollment_id = (
           SELECT MIN(enrollment_id)
           FROM class_enrollment
           WHERE class_id = 1
             AND status IN ('Enrolled', 'Attended')
       )$q$
], $q$SELECT current_enrolled = 19
      FROM class_schedule
      WHERE class_id = 1$q$);

SELECT pg_temp.expect_success('TP-05', 'BR-12', 'Ca PT đã hủy không chặn ca mới cùng khung giờ (exclusion có điều kiện)', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
       VALUES (11, 5, 1, DATE '2030-01-03', TIMESTAMP '2030-01-03 08:00', TIMESTAMP '2030-01-03 09:00', 'Cancelled')$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (18, 5, 8, DATE '2030-01-03', TIMESTAMP '2030-01-03 08:00', TIMESTAMP '2030-01-03 09:00')$q$
], $q$SELECT COUNT(*) = 2
      FROM pt_booking
      WHERE trainer_user_id = 5
        AND start_time = TIMESTAMP '2030-01-03 08:00'$q$);

SELECT pg_temp.expect_success('TP-06', 'BR-15', 'Hai lớp nối tiếp nhau (07:00 kết thúc, 07:00 bắt đầu) không bị coi là trùng', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (7, 2, 'Lop Sang 1', TIMESTAMP '2030-01-01 06:00', TIMESTAMP '2030-01-01 07:00', 10)$q$,
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (7, 2, 'Lop Sang 2', TIMESTAMP '2030-01-01 07:00', TIMESTAMP '2030-01-01 08:00', 10)$q$
], $q$SELECT COUNT(*) = 2
      FROM class_schedule
      WHERE room_id = 2
        AND start_time::DATE = DATE '2030-01-01'$q$);

SELECT pg_temp.expect_success('TP-07', 'BR-09', 'Hóa đơn hợp lệ được ghi nhận', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method)
       VALUES (1, 'INV-TP07', 1500000, DATE '2030-01-01', 'Banking')$q$
], $q$SELECT EXISTS (SELECT 1 FROM billing_log WHERE invoice_no = 'INV-TP07')$q$);


-- ============================================================================
-- BÁO CÁO KẾT QUẢ
-- ============================================================================
SELECT
    tc_id,
    business_rule,
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

ROLLBACK;
