-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 05_constraint_test_cases.sql - KIỂM THỬ RÀNG BUỘC TOÀN VẸN (MỤC 5.1)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell)
-- ----------------------------------------------------------------------------
-- ĐIỀU KIỆN CHẠY: đã nạp 01_schema_ddl.sql -> 02_mock_data/*.sql -> 04_triggers_views.sql
--                 (-> 08_rbac_security.sql nếu muốn kiểm thử cả phân quyền; không bắt buộc).
-- CÁCH CHẠY:      psql -U <user> -d <db> -f "Phase 3/05_constraint_test_cases.sql"
--                 Chạy bằng SUPERUSER (postgres) để chứng minh các quy tắc bất biến (BR-10)
--                 không chỉ dựa vào phân quyền GRANT/REVOKE.
--
-- NGUYÊN TẮC:
--   * Nhóm TC (Negative test): cố tình chèn/sửa/xóa dữ liệu SAI. Test ĐẠT (PASS)
--     khi CSDL từ chối thao tác với đúng mã lỗi SQLSTATE mong đợi VÀ đúng ràng buộc / trigger
--     mong đợi (đối chiếu tên ràng buộc hoặc mã BR trong thông báo lỗi). Nhờ vậy một test
--     không thể "đạt nhầm" vì bị chặn bởi một quy tắc khác.
--   * Nhóm TP (Positive test): thao tác HỢP LỆ phải được chấp nhận và
--     trigger phải cập nhật dữ liệu dẫn xuất đúng.
--   * Mỗi test chạy trong một savepoint riêng và LUÔN bị hoàn tác (rollback),
--     toàn bộ tập tin cũng được bọc trong BEGIN ... ROLLBACK => dữ liệu mẫu
--     không bị thay đổi sau khi chạy.
--
-- QUY ƯỚC THỜI GIAN (không hard-code ngày lịch):
--   * Mọi sự kiện thử nghiệm (lớp, ca PT, giữ chỗ, bảo trì) được đặt vào "khung giờ ban đêm"
--     21:00 - 23:59 của N ngày tới, tính bằng pg_temp.slot(N, giờ) = 00:00 hôm nay + N ngày + giờ.
--     Dữ liệu mẫu cam kết KHÔNG có sự kiện nào trong khung giờ này nên test không đụng lịch có sẵn.
--   * Các hợp đồng PT Active ID 1, 3, 6, 8, 10, 11, 12, 18 có hiệu lực từ <= hôm nay - 30 ngày
--     đến >= hôm nay + 45 ngày, nên mọi ca PT thử nghiệm nằm trong thời hạn (BR-18) với N <= 40.
--   * Quy tắc thời gian BR-24 được kiểm thử bằng cách truyền ngày giả p_as_of vào thủ tục.
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

CREATE TEMP SEQUENCE t05_invoice_seq;

-- Negative test: các câu lệnh phải bị CSDL chặn với đúng SQLSTATE mong đợi.
-- p_message_like (tùy chọn): đoạn văn bản phải xuất hiện trong thông báo lỗi - thường là tên
-- ràng buộc (ví dụ 'ex_pt_trainer_no_overlap') hoặc mã quy tắc (ví dụ 'BR-12') do trigger nêu.
CREATE FUNCTION pg_temp.expect_error(
    p_tc_id             VARCHAR,
    p_business_rule     VARCHAR,
    p_description       VARCHAR,
    p_expected_sqlstate VARCHAR,
    p_statements        TEXT[],
    p_message_like      TEXT DEFAULT NULL
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
                CASE WHEN SQLSTATE = p_expected_sqlstate
                          AND (p_message_like IS NULL OR POSITION(p_message_like IN SQLERRM) > 0)
                     THEN 'PASS' ELSE 'FAIL' END,
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

-- ----------------------------------------------------------------------------
-- HÀM DỰNG DỮ LIỆU THỬ NGHIỆM (đi qua đầy đủ trigger, giống thao tác thật của ứng dụng)
-- ----------------------------------------------------------------------------

-- Mốc thời gian: 00:00 hôm nay + p_day ngày + p_hour giờ (p_hour có thể lẻ, ví dụ 21.5 = 21:30).
CREATE FUNCTION pg_temp.slot(p_day INT, p_hour DOUBLE PRECISION DEFAULT 21)
RETURNS TIMESTAMP AS $$
    SELECT DATE_TRUNC('day', CURRENT_TIMESTAMP)::TIMESTAMP
           + p_day * INTERVAL '1 day'
           + p_hour * INTERVAL '1 hour';
$$ LANGUAGE sql STABLE;

-- Mốc "hủy muộn": khung giờ ban đêm gần nhất cách hiện tại hơn 30 phút (luôn < 24 giờ tới).
CREATE FUNCTION pg_temp.late_slot()
RETURNS TIMESTAMP AS $$
    SELECT MIN(c.slot_time)
    FROM (
        SELECT pg_temp.slot(0, 21) AS slot_time
        UNION ALL SELECT pg_temp.slot(0, 22)
        UNION ALL SELECT pg_temp.slot(0, 23)
        UNION ALL SELECT pg_temp.slot(1, 21)
    ) AS c
    WHERE c.slot_time > CURRENT_TIMESTAMP::TIMESTAMP + INTERVAL '30 minutes';
$$ LANGUAGE sql STABLE;

-- Tạo hợp đồng (mặc định Pending); trả về subscription_id.
CREATE FUNCTION pg_temp.new_sub(
    p_member    INT,
    p_plan      INT,
    p_price     NUMERIC,
    p_start     TIMESTAMP,
    p_end       TIMESTAMP,
    p_recurring BOOLEAN DEFAULT FALSE,
    p_status    VARCHAR DEFAULT 'Pending'
)
RETURNS INT AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO member_subscription (member_user_id, plan_id, actual_price, start_time, end_time,
                                     is_recurring, sub_status)
    VALUES (p_member, p_plan, p_price, p_start, p_end, p_recurring, p_status)
    RETURNING subscription_id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Ghi hóa đơn cho hợp đồng; p_period = NULL để trigger tự điền chu kỳ (ngày bắt đầu hợp đồng).
CREATE FUNCTION pg_temp.pay_sub(
    p_sub    INT,
    p_status VARCHAR DEFAULT 'Completed',
    p_period DATE DEFAULT NULL
)
RETURNS INT AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount,
                             payment_date, payment_method, payment_status)
    SELECT ms.subscription_id, p_period,
           'INV-T05-' || ms.subscription_id || '-' || NEXTVAL('t05_invoice_seq'),
           ms.actual_price, CURRENT_DATE, 'Banking', p_status
    FROM member_subscription AS ms
    WHERE ms.subscription_id = p_sub
    RETURNING billing_id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Hợp đồng mới nhất của một hội viên.
CREATE FUNCTION pg_temp.last_sub(p_member INT)
RETURNS INT AS $$
    SELECT MAX(subscription_id) FROM member_subscription WHERE member_user_id = p_member;
$$ LANGUAGE sql STABLE;

-- Tạo ca PT (booking_date lấy theo start_time); trả về booking_id.
CREATE FUNCTION pg_temp.mk_pt(
    p_member  INT,
    p_trainer INT,
    p_sub     INT,
    p_start   TIMESTAMP,
    p_end     TIMESTAMP,
    p_status  VARCHAR DEFAULT 'Scheduled'
)
RETURNS INT AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date,
                            start_time, end_time, status)
    VALUES (p_member, p_trainer, p_sub, p_start::DATE, p_start, p_end, p_status)
    RETURNING booking_id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Tạo lớp học nhóm; trả về class_id.
CREATE FUNCTION pg_temp.mk_class(
    p_name    VARCHAR,
    p_trainer INT,
    p_room    INT,
    p_start   TIMESTAMP,
    p_end     TIMESTAMP,
    p_cap     INT DEFAULT 10
)
RETURNS INT AS $$
DECLARE
    v_id INT;
BEGIN
    INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
    VALUES (p_trainer, p_room, p_name, p_start, p_end, p_cap)
    RETURNING class_id INTO v_id;
    RETURN v_id;
END;
$$ LANGUAGE plpgsql;

-- Chọn một hợp đồng chưa đăng ký lớp p_class và có hội viên KHÔNG bị trùng lịch với lớp đó
-- (để test chỉ chạm đúng ràng buộc cần kiểm tra, không vướng kiểm tra trùng lịch BR-16).
-- Trả về NULL nếu mọi hội viên đều đã vướng lớp đó (ví dụ lớp ID 1 đã đầy 20/20 hội viên mẫu).
CREATE FUNCTION pg_temp.free_sub(p_class INT)
RETURNS INT AS $$
    SELECT ms.subscription_id
    FROM member_subscription AS ms
    CROSS JOIN class_schedule AS cs
    WHERE cs.class_id = p_class
      AND NOT EXISTS (
          SELECT 1
          FROM class_enrollment AS ce
          WHERE ce.class_id = cs.class_id
            AND ce.subscription_id = ms.subscription_id
      )
      AND NOT EXISTS (
          SELECT 1
          FROM pt_booking AS pb
          WHERE pb.member_user_id = ms.member_user_id
            AND pb.status NOT IN ('Cancelled', 'Late_Cancelled')
            AND tsrange(pb.start_time, pb.end_time, '[)') && tsrange(cs.start_time, cs.end_time, '[)')
      )
      AND NOT EXISTS (
          SELECT 1
          FROM class_enrollment AS ce2
          JOIN member_subscription AS ms2
              ON ms2.subscription_id = ce2.subscription_id
          JOIN class_schedule AS cs2
              ON cs2.class_id = ce2.class_id
          WHERE ms2.member_user_id = ms.member_user_id
            AND ce2.status IN ('Enrolled', 'Attended')
            AND tsrange(cs2.start_time, cs2.end_time, '[)') && tsrange(cs.start_time, cs.end_time, '[)')
      )
    ORDER BY ms.subscription_id
    LIMIT 1;
$$ LANGUAGE sql STABLE;


-- ============================================================================
-- PHẦN 1: TÀI KHOẢN NGƯỜI DÙNG & HỒ SƠ (BR-02, BR-03, BR-11)
-- ============================================================================

SELECT pg_temp.expect_error('TC-01', 'BR-02', 'Tạo tài khoản trùng email đã tồn tại (uq_user_account_email)', '23505', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       SELECT 'Test Trung Email', email, '0999000001', DATE '2000-01-01', 'x'
       FROM user_account
       WHERE user_id = 11$q$
], 'uq_user_account_email');

SELECT pg_temp.expect_error('TC-02', 'BR-02', 'Tạo tài khoản trùng số điện thoại đã tồn tại (uq_user_account_phone)', '23505', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       SELECT 'Test Trung SDT', 'tc02@test.vn', phone, DATE '2000-01-01', 'x'
       FROM user_account
       WHERE user_id = 11$q$
], 'uq_user_account_phone');

SELECT pg_temp.expect_error('TC-03', 'BR-02', 'Tạo tài khoản thiếu email (NOT NULL)', '23502', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Test Thieu Email', NULL, '0999000003', DATE '2000-01-01', 'x')$q$
], 'email');

SELECT pg_temp.expect_error('TC-04', 'BR-03', 'Đăng ký hồ sơ hội viên cho người dưới 12 tuổi (trg_check_member_dob)', 'P0001', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Be Duoi 12 Tuoi', 'tc04@test.vn', '0999000004', CURRENT_DATE - INTERVAL '5 years', 'x')$q$,
    $q$INSERT INTO member_profile (user_id)
       SELECT user_id
       FROM user_account
       WHERE email = 'tc04@test.vn'$q$
], 'BR-03');

SELECT pg_temp.expect_error('TC-05', 'BR-03', 'Sửa ngày sinh của hội viên hiện có thành dưới 12 tuổi (trg_check_user_dob_for_member)', 'P0001', ARRAY[
    $q$UPDATE user_account
       SET dob = CURRENT_DATE - INTERVAL '5 years'
       WHERE user_id = 11$q$
], 'BR-03');

SELECT pg_temp.expect_error('TC-06', 'BR-22', 'Gán trạng thái tài khoản ngoài miền giá trị (chk_user_account_status)', '23514', ARRAY[
    $q$UPDATE user_account
       SET status = 'Deleted'
       WHERE user_id = 1$q$
], 'chk_user_account_status');

SELECT pg_temp.expect_error('TC-07', 'BR-11', 'Điểm đánh giá HLV vượt quá 5.00 (chk_trainer_rating)', '23514', ARRAY[
    $q$UPDATE trainer_profile
       SET current_rating = 5.50
       WHERE user_id = 5$q$
], 'chk_trainer_rating');

SELECT pg_temp.expect_error('TC-08', 'BR-22', 'Gán cùng một vai trò hai lần cho một người dùng (pk_user_role)', '23505', ARRAY[
    $q$INSERT INTO user_role (user_id, role_id)
       SELECT user_id, role_id
       FROM user_role
       LIMIT 1$q$
], 'pk_user_role');


-- ============================================================================
-- PHẦN 2: GÓI TẬP, HỢP ĐỒNG & THANH TOÁN (BR-04, BR-06, BR-09)
-- ============================================================================

SELECT pg_temp.expect_error('TC-09', 'BR-04', 'Tạo gói tập có thời hạn 0 ngày (chk_membership_plan_duration)', '23514', ARRAY[
    $q$INSERT INTO membership_plan (plan_name, duration_days, price)
       VALUES ('Goi Loi Thoi Han', 0, 500000)$q$
], 'chk_membership_plan_duration');

SELECT pg_temp.expect_error('TC-10', 'BR-04', 'Tạo gói tập có giá âm (chk_membership_plan_price)', '23514', ARRAY[
    $q$INSERT INTO membership_plan (plan_name, duration_days, price)
       VALUES ('Goi Loi Gia', 30, -1)$q$
], 'chk_membership_plan_price');

SELECT pg_temp.expect_error('TC-11', 'BR-06', 'Hợp đồng có ngày kết thúc trước ngày bắt đầu (chk_subscription_dates)', '23514', ARRAY[
    $q$INSERT INTO member_subscription (member_user_id, plan_id, actual_price, start_time, end_time)
       VALUES (11, 1, 500000, pg_temp.slot(40, 0), pg_temp.slot(1, 0))$q$
], 'chk_subscription_dates');

SELECT pg_temp.expect_error('TC-12', 'BR-01', 'Ký hợp đồng cho người không có hồ sơ hội viên (HLV ID 5) (fk_subscription_member)', '23503', ARRAY[
    $q$INSERT INTO member_subscription (member_user_id, plan_id, actual_price, start_time, end_time)
       VALUES (5, 1, 500000, pg_temp.slot(1, 0), pg_temp.slot(31, 0))$q$
], 'fk_subscription_member');

SELECT pg_temp.expect_error('TC-13', 'BR-18', 'Số buổi PT còn lại bị âm (chk_subscription_remaining)', '23514', ARRAY[
    $q$UPDATE member_subscription
       SET remaining_sessions = -1
       WHERE subscription_id = 1$q$
], 'chk_subscription_remaining');

-- Dùng chu kỳ tính phí chưa từng dùng để KHÔNG vướng uq_billing_subscription_period (BR-08):
-- chỉ còn duy nhất uq_billing_invoice_no bị vi phạm.
SELECT pg_temp.expect_error('TC-14', 'BR-09', 'Phát hành hóa đơn trùng số invoice_no (uq_billing_invoice_no)', '23505', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method)
       SELECT 1, CURRENT_DATE + 2000, invoice_no, 100000, CURRENT_DATE, 'Cash'
       FROM billing_log
       LIMIT 1$q$
], 'uq_billing_invoice_no');

SELECT pg_temp.expect_error('TC-15', 'BR-09', 'Hóa đơn có số tiền bằng 0 (chk_billing_amount)', '23514', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method)
       VALUES (1, CURRENT_DATE + 2000, 'INV-TC15', 0, CURRENT_DATE, 'Cash')$q$
], 'chk_billing_amount');

SELECT pg_temp.expect_error('TC-16', 'BR-09', 'Phương thức thanh toán không hợp lệ (chk_billing_method)', '23514', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method)
       VALUES (1, CURRENT_DATE + 2000, 'INV-TC16', 100000, CURRENT_DATE, 'Bitcoin')$q$
], 'chk_billing_method');

-- Hợp đồng tạo riêng trong test chỉ có đúng 1 hóa đơn => chỉ fk_billing_subscription chặn việc xóa.
SELECT pg_temp.expect_error('TC-17', 'BR-10', 'Xóa hợp đồng đã phát sinh hóa đơn (fk_billing_subscription, ON DELETE RESTRICT)', '23503', ARRAY[
    $q$SELECT pg_temp.pay_sub(pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22)))$q$,
    $q$DELETE FROM member_subscription
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], 'fk_billing_subscription');

SELECT pg_temp.expect_error('TC-18', 'BR-04', 'Xóa gói tập đang được hợp đồng sử dụng (fk_subscription_plan)', '23503', ARRAY[
    $q$DELETE FROM membership_plan
       WHERE plan_id = 1$q$
], 'fk_subscription_plan');


-- ============================================================================
-- PHẦN 3: PHÒNG TẬP & LỚP HỌC NHÓM (BR-12, BR-13, BR-14, BR-15, BR-17, BR-19)
-- ============================================================================

SELECT pg_temp.expect_error('TC-19', 'BR-13', 'Phòng tập có sức chứa bằng 0 (chk_facilities_capacity)', '23514', ARRAY[
    $q$INSERT INTO facilities_room (room_name, max_capacity, room_type)
       VALUES ('Phong Loi', 0, 'Studio')$q$
], 'chk_facilities_capacity');

-- Lưu ý: nếu end_time < start_time thì trigger trg_check_class_schedule_conflicts (chạy BEFORE INSERT,
-- trước khi PostgreSQL kiểm tra CHECK) gọi tsrange(start, end) và dừng sớm với SQLSTATE 22000
-- ("range lower bound must be less than or equal to range upper bound"), CHECK không bao giờ được chạm tới.
-- Vì vậy dùng end_time = start_time: tsrange rỗng hợp lệ, trigger đi qua, CHECK chk_class_time (end > start) mới chặn.
SELECT pg_temp.expect_error('TC-20', 'BR-17', 'Lớp học có giờ kết thúc bằng giờ bắt đầu (chk_class_time)', '23514', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (6, 1, 'Lop Loi Gio', pg_temp.slot(2, 21), pg_temp.slot(2, 21), 10)$q$
], 'chk_class_time');

SELECT pg_temp.expect_error('TC-21', 'BR-15', 'Xếp 2 lớp trùng giờ trong cùng một phòng (ex_class_room_no_overlap)', '23P01', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (7, 2, 'Lop A', pg_temp.slot(3, 21), pg_temp.slot(3, 22), 10)$q$,
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (8, 2, 'Lop B', pg_temp.slot(3, 21.5), pg_temp.slot(3, 22.5), 10)$q$
], 'ex_class_room_no_overlap');

SELECT pg_temp.expect_error('TC-22', 'BR-12', 'Một HLV dạy 2 lớp trùng giờ ở 2 phòng khác nhau (ex_class_trainer_no_overlap)', '23P01', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (6, 1, 'Lop C', pg_temp.slot(4, 21), pg_temp.slot(4, 22), 10)$q$,
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (6, 3, 'Lop D', pg_temp.slot(4, 21.5), pg_temp.slot(4, 22.5), 10)$q$
], 'ex_class_trainer_no_overlap');

SELECT pg_temp.expect_error('TC-23', 'BR-19', 'Xếp lớp vào phòng đang bảo trì, phòng ID 6 (trg_prevent_class_in_maintenance_room)', 'P0001', ARRAY[
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (9, 6, 'Lop Boxing', pg_temp.slot(5, 21), pg_temp.slot(5, 22), 10)$q$
], 'BR-19');

-- Lớp ID 1 đã đầy 20/20 và mọi hội viên mẫu đều đã có mặt trong lớp, nên test tạo một hội viên mới
-- (không vướng kiểm tra trùng lịch BR-16); lỗi đến từ trigger đồng bộ làm current_enrolled = 21
-- vi phạm chk_class_enrollment_limit.
SELECT pg_temp.expect_error('TC-24', 'BR-14', 'Đăng ký thêm hội viên vào lớp đã đầy, lớp ID 1: 20/20 (chk_class_enrollment_limit)', '23514', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Hoi Vien Moi TC24', 'tc24@test.vn', '0999000024', CURRENT_DATE - INTERVAL '20 years', 'x')$q$,
    $q$INSERT INTO member_profile (user_id)
       SELECT user_id FROM user_account WHERE email = 'tc24@test.vn'$q$,
    $q$SELECT pg_temp.new_sub((SELECT user_id FROM user_account WHERE email = 'tc24@test.vn'), 1, 800000,
                              pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       VALUES (pg_temp.last_sub((SELECT user_id FROM user_account WHERE email = 'tc24@test.vn')), 1)$q$
], 'chk_class_enrollment_limit');

-- Đăng ký -> hủy -> đăng ký lại cùng lớp: dòng cũ ('Cancelled') không bị kiểm tra trùng lịch BR-16 nhưng
-- vẫn chiếm cặp (subscription_id, class_id) nên uq_enrollment_subscription_class chặn.
-- (Đăng ký lần 2 khi dòng cũ còn 'Enrolled' bị trigger BR-16 chặn trước: xem TC-68.)
SELECT pg_temp.expect_error('TC-25', 'BR-14', 'Một hợp đồng đăng ký lại cùng một lớp sau khi hủy (uq_enrollment_subscription_class)', '23505', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-DUP', 6, 1, pg_temp.slot(6, 21), pg_temp.slot(6, 22))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-DUP'$q$,
    $q$UPDATE class_enrollment
       SET status = 'Cancelled'
       WHERE class_id = (SELECT class_id FROM class_schedule WHERE class_name = 'T05-DUP')$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-DUP'$q$
], 'uq_enrollment_subscription_class');


-- ============================================================================
-- PHẦN 4: LỊCH PT 1-1 (BR-12, BR-16, BR-17, BR-18)
-- ============================================================================

SELECT pg_temp.expect_error('TC-26', 'BR-17', 'Ca PT có giờ kết thúc bằng giờ bắt đầu (chk_pt_booking_time)', '23514', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(2, 21)::DATE, pg_temp.slot(2, 21), pg_temp.slot(2, 21))$q$
], 'chk_pt_booking_time');

SELECT pg_temp.expect_error('TC-27', 'BR-12', 'Một HLV nhận 2 ca PT trùng giờ với 2 hội viên (ex_pt_trainer_no_overlap)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(2, 21), pg_temp.slot(2, 22))$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (18, 5, 8, pg_temp.slot(2, 21.5)::DATE, pg_temp.slot(2, 21.5), pg_temp.slot(2, 22.5))$q$
], 'ex_pt_trainer_no_overlap');

SELECT pg_temp.expect_error('TC-28', 'BR-16', 'Một hội viên đặt 2 ca PT trùng giờ với 2 HLV (ex_pt_member_no_overlap)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(3, 21), pg_temp.slot(3, 22))$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 9, 1, pg_temp.slot(3, 21.5)::DATE, pg_temp.slot(3, 21.5), pg_temp.slot(3, 22.5))$q$
], 'ex_pt_member_no_overlap');

SELECT pg_temp.expect_error('TC-29', 'BR-18', 'Đặt ca PT bằng hợp đồng của hội viên khác (fk_booking_subscription_member)', '23503', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 8, pg_temp.slot(4, 21)::DATE, pg_temp.slot(4, 21), pg_temp.slot(4, 22))$q$
], 'fk_booking_subscription_member');

-- Ca PT được đặt khi hợp đồng còn buổi; sau đó số buổi về 0 (ví dụ bị điều chỉnh) thì không thể Completed.
SELECT pg_temp.expect_error('TC-30', 'BR-18', 'Hoàn thành ca PT khi hợp đồng đã hết buổi (trg_update_remaining_pt_sessions)', 'P0001', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(5, 21), pg_temp.slot(5, 22))$q$,
    $q$UPDATE member_subscription
       SET remaining_sessions = 0
       WHERE subscription_id = 1$q$,
    $q$UPDATE pt_booking
       SET status = 'Completed'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(5, 21)$q$
], 'hết số buổi');

SELECT pg_temp.expect_error('TC-31', 'BR-25', 'Trạng thái ca PT ngoài miền giá trị (chk_pt_booking_status)', '23514', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(6, 21), pg_temp.slot(6, 22))$q$,
    $q$UPDATE pt_booking
       SET status = 'Postponed'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(6, 21)$q$
], 'chk_pt_booking_status');


-- ============================================================================
-- PHẦN 5: THIẾT BỊ, GIỮ CHỖ & BẢO TRÌ (BR-19, BR-20, BR-21, BR-26)
-- ============================================================================

SELECT pg_temp.expect_error('TC-32', 'BR-26', 'Thiết bị có thời gian khấu hao 0 tháng (chk_equipment_depreciation)', '23514', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (2, 'May Chay Loi', 'SN-TC32', CURRENT_DATE, 0)$q$
], 'chk_equipment_depreciation');

SELECT pg_temp.expect_error('TC-33', 'BR-26', 'Thiết bị trùng số serial (uq_equipment_serial)', '23505', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       SELECT 2, 'May Trung Serial', serial_number, CURRENT_DATE, 60
       FROM equipment
       WHERE equipment_id = 1$q$
], 'uq_equipment_serial');

-- Thiết bị thật ID 3 vừa 'Under_Maintenance' vừa có ca bảo trì In_Progress nên bị trigger BR-21 chặn trước
-- (xem TC-62). Để cô lập đúng trigger trg_prevent_equipment_reservation_under_maintenance (BR-19, kiểm tra
-- cột equipment.status), test chuyển thiết bị ID 1 sang Under_Maintenance mà KHÔNG có ca bảo trì đang sửa.
SELECT pg_temp.expect_error('TC-34', 'BR-19', 'Giữ chỗ thiết bị đang bảo trì - cột status (trg_prevent_equipment_reservation_under_maintenance)', 'P0001', ARRAY[
    $q$UPDATE equipment
       SET status = 'Under_Maintenance'
       WHERE equipment_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(7, 21), pg_temp.slot(7, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 1, booking_id, start_time, end_time
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(7, 21)$q$
], 'BR-19');

-- Giờ giữ chỗ nằm trọn trong ca PT gắn kèm để trigger BR-21 (cửa sổ) đi qua; CHECK mới là chốt chặn.
SELECT pg_temp.expect_error('TC-35', 'BR-21', 'Lượt giữ chỗ gắn đồng thời cả ca PT và lớp học (chk_reservation_source)', '23514', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(8, 21), pg_temp.slot(8, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, class_id, start_time, end_time)
       SELECT 1, pb.booking_id, (SELECT MIN(class_id) FROM class_schedule), pb.start_time, pb.end_time
       FROM pt_booking AS pb
       WHERE pb.subscription_id = 1
         AND pb.start_time = pg_temp.slot(8, 21)$q$
], 'chk_reservation_source');

SELECT pg_temp.expect_error('TC-36', 'BR-21', 'Lượt giữ chỗ không gắn với ca PT hay lớp học nào (chk_reservation_source)', '23514', ARRAY[
    $q$INSERT INTO equipment_reservation (equipment_id, start_time, end_time)
       VALUES (1, pg_temp.slot(9, 21), pg_temp.slot(9, 22))$q$
], 'chk_reservation_source');

SELECT pg_temp.expect_error('TC-37', 'BR-20', 'Nhật ký bảo trì có chi phí âm (chk_maintenance_cost)', '23514', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time, cost)
       VALUES (1, 4, 'Test chi phi am', pg_temp.slot(1, 8), -100)$q$
], 'chk_maintenance_cost');

SELECT pg_temp.expect_error('TC-38', 'BR-20', 'Nhật ký bảo trì hoàn thành trước khi bắt đầu (chk_maintenance_time)', '23514', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time, end_time)
       VALUES (1, 4, 'Test thoi gian', pg_temp.slot(2, 8), pg_temp.slot(1, 8))$q$
], 'chk_maintenance_time');

SELECT pg_temp.expect_error('TC-39', 'BR-20', 'Giao việc bảo trì cho người không phải nhân viên, HLV ID 5 (fk_maintenance_staff)', '23503', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       VALUES (1, 5, 'Sai nguoi xu ly', pg_temp.slot(1, 8))$q$
], 'fk_maintenance_staff');


-- ============================================================================
-- PHẦN 6: POSITIVE TEST - DỮ LIỆU HỢP LỆ ĐƯỢC CHẤP NHẬN, TRIGGER CẬP NHẬT ĐÚNG
-- ============================================================================

SELECT pg_temp.expect_success('TP-01', 'BR-03', 'Hội viên đủ 18 tuổi được tạo hồ sơ thành công', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       VALUES ('Hoi Vien Hop Le', 'tp01@test.vn', '0999100001', CURRENT_DATE - INTERVAL '18 years', 'x')$q$,
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

-- Số buổi gốc được ghi vào biến phiên cục bộ t05.rem để so sánh (không phụ thuộc số buổi cụ thể trong dữ liệu mẫu).
SELECT pg_temp.expect_success('TP-02', 'BR-18', 'Hoàn thành ca PT tự động trừ đúng 1 buổi (hợp đồng ID 1: n -> n-1)', ARRAY[
    $q$SELECT SET_CONFIG('t05.rem', remaining_sessions::TEXT, TRUE)
       FROM member_subscription
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(2, 21), pg_temp.slot(2, 22))$q$,
    $q$UPDATE pt_booking
       SET status = 'Completed'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(2, 21)$q$
], $q$SELECT remaining_sessions = CURRENT_SETTING('t05.rem')::INT - 1
      FROM member_subscription
      WHERE subscription_id = 1$q$);

SELECT pg_temp.expect_success('TP-03', 'BR-14', 'Đăng ký lớp tự động tăng current_enrolled (lớp ID 2: 16 -> 17)', ARRAY[
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       VALUES (pg_temp.free_sub(2), 2)$q$
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
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(3, 21), pg_temp.slot(3, 22), 'Cancelled')$q$,
    $q$SELECT pg_temp.mk_pt(18, 5, 8, pg_temp.slot(3, 21), pg_temp.slot(3, 22))$q$
], $q$SELECT COUNT(*) = 2
      FROM pt_booking
      WHERE trainer_user_id = 5
        AND start_time = pg_temp.slot(3, 21)$q$);

SELECT pg_temp.expect_success('TP-06', 'BR-15', 'Hai lớp nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) không bị coi là trùng', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-NOITIEP-1', 7, 2, pg_temp.slot(1, 21), pg_temp.slot(1, 22))$q$,
    $q$SELECT pg_temp.mk_class('T05-NOITIEP-2', 7, 2, pg_temp.slot(1, 22), pg_temp.slot(1, 23))$q$
], $q$SELECT COUNT(*) = 2
      FROM class_schedule
      WHERE class_name LIKE 'T05-NOITIEP-%'$q$);

-- Dùng chu kỳ tính phí mới (BR-08) để hóa đơn không trùng chu kỳ nào của hợp đồng ID 1.
SELECT pg_temp.expect_success('TP-07', 'BR-09', 'Hóa đơn hợp lệ ở chu kỳ tính phí mới được ghi nhận', ARRAY[
    $q$INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method)
       VALUES (1, CURRENT_DATE + 400, 'INV-TP07', 1500000, CURRENT_DATE, 'Banking')$q$
], $q$SELECT EXISTS (SELECT 1 FROM billing_log WHERE invoice_no = 'INV-TP07')$q$);


-- ============================================================================
-- PHẦN 7: BR-05, BR-07, BR-08 - MỘT HỢP ĐỒNG ACTIVE, KÍCH HOẠT SAU THANH TOÁN, DUY NHẤT HÓA ĐƠN CHU KỲ
-- Hội viên ID 26 và 27 không có hợp đồng Active nào trong dữ liệu mẫu nên dùng làm "hội viên sạch".
-- ============================================================================

-- Hội viên 11 đang có hợp đồng ID 1 Active. Hợp đồng mới Pending được thanh toán sẽ bị trigger
-- trg_activate_on_payment_insert chuyển Active => vi phạm chỉ mục một phần uq_member_one_active_subscription.
SELECT pg_temp.expect_error('TC-40', 'BR-05', 'Hội viên đang Active có thêm hợp đồng Active thứ hai (uq_member_one_active_subscription)', '23505', ARRAY[
    $q$SELECT pg_temp.new_sub(11, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(11))$q$
], 'uq_member_one_active_subscription');

SELECT pg_temp.expect_error('TC-41', 'BR-07', 'Tạo hợp đồng Active trực tiếp khi chưa có hóa đơn Completed (trg_require_payment_before_active)', 'P0001', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22), FALSE, 'Active')$q$
], 'BR-07');

SELECT pg_temp.expect_error('TC-42', 'BR-07', 'Chuyển hợp đồng sang Active khi mới có hóa đơn Pending, chưa Completed (trg_require_payment_before_active)', 'P0001', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Pending')$q$,
    $q$UPDATE member_subscription
       SET sub_status = 'Active'
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], 'BR-07');

SELECT pg_temp.expect_error('TC-43', 'BR-08', 'Hai hóa đơn còn hiệu lực cho cùng một chu kỳ của một hợp đồng (uq_billing_subscription_period)', '23505', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Pending')$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Pending')$q$
], 'uq_billing_subscription_period');

SELECT pg_temp.expect_success('TP-08', 'BR-07', 'Hợp đồng Pending + hóa đơn Completed -> tự động Active (trg_activate_on_payment_insert)', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26))$q$
], $q$SELECT sub_status = 'Active'
      FROM member_subscription
      WHERE subscription_id = pg_temp.last_sub(26)$q$);

SELECT pg_temp.expect_success('TP-09', 'BR-05', 'Hợp đồng cũ chuyển Expired thì hội viên được kích hoạt hợp đồng mới (chỉ còn 1 Active)', ARRAY[
    $q$UPDATE member_subscription
       SET sub_status = 'Expired'
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.new_sub(11, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(11))$q$
], $q$SELECT COUNT(*) = 1
          AND BOOL_AND(subscription_id = pg_temp.last_sub(11))
      FROM member_subscription
      WHERE member_user_id = 11
        AND sub_status = 'Active'$q$);

SELECT pg_temp.expect_success('TP-10', 'BR-08', 'Hóa đơn Failed không chiếm chu kỳ: thanh toán lại (Completed) cùng chu kỳ được chấp nhận', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Failed')$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Completed')$q$
], $q$SELECT (SELECT COUNT(*) FROM billing_log WHERE subscription_id = pg_temp.last_sub(26)) = 2
          AND (SELECT sub_status FROM member_subscription WHERE subscription_id = pg_temp.last_sub(26)) = 'Active'$q$);

SELECT pg_temp.expect_success('TP-11', 'BR-08', 'INSERT hóa đơn không nêu chu kỳ: trg_fill_billing_period_start điền ngày bắt đầu hợp đồng', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Pending')$q$
], $q$SELECT b.billing_period_start = ms.start_time::DATE
      FROM billing_log AS b
      JOIN member_subscription AS ms
          ON ms.subscription_id = b.subscription_id
      WHERE b.subscription_id = pg_temp.last_sub(26)$q$);


-- ============================================================================
-- PHẦN 8: BR-10 - NHẬT KÝ THANH TOÁN BẤT BIẾN
-- Toàn bộ tập tin chạy bằng superuser (xem TP-12): trigger chặn cả chủ sở hữu/superuser,
-- không chỉ người dùng bị thu hồi quyền.
-- ============================================================================

SELECT pg_temp.expect_error('TC-44', 'BR-10', 'Sửa số tiền hóa đơn Completed có sẵn (trg_billing_immutable_update)', 'P0001', ARRAY[
    $q$UPDATE billing_log
       SET amount = amount + 1
       WHERE billing_id = (SELECT MIN(billing_id) FROM billing_log WHERE payment_status = 'Completed')$q$
], 'BR-10');

SELECT pg_temp.expect_error('TC-45', 'BR-10', 'Xóa hóa đơn Completed có sẵn (trg_billing_immutable_delete)', 'P0001', ARRAY[
    $q$DELETE FROM billing_log
       WHERE billing_id = (SELECT MIN(billing_id) FROM billing_log WHERE payment_status = 'Completed')$q$
], 'BR-10');

SELECT pg_temp.expect_error('TC-46', 'BR-10', 'TRUNCATE bảng billing_log (trg_billing_immutable_truncate)', 'P0001', ARRAY[
    $q$TRUNCATE TABLE billing_log$q$
], 'BR-10');

SELECT pg_temp.expect_error('TC-47', 'BR-10', 'Đổi hóa đơn Completed sang Failed - chỉ được sang Refunded (trg_billing_immutable_update)', 'P0001', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26))$q$,
    $q$UPDATE billing_log
       SET payment_status = 'Failed'
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], 'BR-10');

SELECT pg_temp.expect_error('TC-48', 'BR-10', 'Hóa đơn Pending bị đổi mã invoice_no (trg_billing_immutable_update)', 'P0001', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Pending')$q$,
    $q$UPDATE billing_log
       SET invoice_no = 'INV-DOI-MA'
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], 'BR-10');

SELECT pg_temp.expect_error('TC-49', 'BR-10', 'Sửa hóa đơn đã ở trạng thái cuối Refunded (trg_billing_immutable_update)', 'P0001', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26))$q$,
    $q$UPDATE billing_log
       SET payment_status = 'Refunded'
       WHERE subscription_id = pg_temp.last_sub(26)$q$,
    $q$UPDATE billing_log
       SET amount = 1
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], 'trạng thái cuối');

SELECT pg_temp.expect_success('TP-12', 'BR-10', 'Phiên kiểm thử chạy bằng superuser (chứng minh BR-10 không dựa vào phân quyền)', ARRAY[
    $q$SELECT 1$q$
], $q$SELECT rolsuper
      FROM pg_roles
      WHERE rolname = CURRENT_USER$q$);

SELECT pg_temp.expect_success('TP-13', 'BR-10', 'Hóa đơn Completed chuyển sang Refunded được phép (hoàn tiền)', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26))$q$,
    $q$UPDATE billing_log
       SET payment_status = 'Refunded'
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], $q$SELECT payment_status = 'Refunded'
      FROM billing_log
      WHERE subscription_id = pg_temp.last_sub(26)$q$);

SELECT pg_temp.expect_success('TP-14', 'BR-10', 'Hóa đơn Pending chuyển sang Completed được phép và kích hoạt hợp đồng Pending', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26), 'Pending')$q$,
    $q$UPDATE billing_log
       SET payment_status = 'Completed',
           payment_date = CURRENT_DATE
       WHERE subscription_id = pg_temp.last_sub(26)$q$
], $q$SELECT (SELECT payment_status FROM billing_log WHERE subscription_id = pg_temp.last_sub(26)) = 'Completed'
          AND (SELECT sub_status FROM member_subscription WHERE subscription_id = pg_temp.last_sub(26)) = 'Active'$q$);


-- ============================================================================
-- PHẦN 9: BR-12, BR-16 XUYÊN BẢNG - HLV / HỘI VIÊN KHÔNG TRÙNG GIỮA LỚP NHÓM VÀ CA PT
-- (EXCLUDE chỉ so sánh trong CÙNG một bảng nên phải có trigger; lỗi trả SQLSTATE 23P01)
-- ============================================================================

SELECT pg_temp.expect_error('TC-50', 'BR-12', 'HLV đã có ca PT, xếp thêm lớp nhóm trùng giờ cho chính HLV đó (trg_check_class_schedule_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(11, 21), pg_temp.slot(11, 22))$q$,
    $q$INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
       VALUES (5, 1, 'T05-HLV-TRUNG-PT', pg_temp.slot(11, 21.5), pg_temp.slot(11, 22.5), 10)$q$
], 'BR-12');

SELECT pg_temp.expect_error('TC-51', 'BR-12', 'HLV đang đứng lớp nhóm, nhận thêm ca PT trùng giờ (trg_check_pt_booking_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-HLV-DUNG-LOP', 5, 1, pg_temp.slot(12, 21), pg_temp.slot(12, 22))$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(12, 21.5)::DATE, pg_temp.slot(12, 21.5), pg_temp.slot(12, 22.5))$q$
], 'BR-12');

SELECT pg_temp.expect_error('TC-52', 'BR-16', 'Hội viên đã đăng ký lớp nhóm, đặt thêm ca PT trùng giờ lớp đó (trg_check_pt_booking_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-LOP-16A', 6, 1, pg_temp.slot(13, 21), pg_temp.slot(13, 22))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-16A'$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(13, 21.5)::DATE, pg_temp.slot(13, 21.5), pg_temp.slot(13, 22.5))$q$
], 'BR-16');

SELECT pg_temp.expect_error('TC-53', 'BR-16', 'Hội viên đã có ca PT, đăng ký lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(14, 21), pg_temp.slot(14, 22))$q$,
    $q$SELECT pg_temp.mk_class('T05-LOP-16B', 6, 1, pg_temp.slot(14, 21.5), pg_temp.slot(14, 22.5))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-16B'$q$
], 'BR-16');

SELECT pg_temp.expect_error('TC-54', 'BR-16', 'Hội viên đăng ký 2 lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-LOP-16C', 6, 1, pg_temp.slot(15, 21), pg_temp.slot(15, 22))$q$,
    $q$SELECT pg_temp.mk_class('T05-LOP-16D', 7, 2, pg_temp.slot(15, 21.5), pg_temp.slot(15, 22.5))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-16C'$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-16D'$q$
], 'BR-16');

SELECT pg_temp.expect_error('TC-55', 'BR-16', 'Đổi giờ lớp đã có người đăng ký sang giờ trùng ca PT của hội viên đó (trg_check_class_schedule_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-LOP-16E', 6, 1, pg_temp.slot(16, 21), pg_temp.slot(16, 22))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-16E'$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(16, 22.5), pg_temp.slot(16, 23.5))$q$,
    $q$UPDATE class_schedule
       SET start_time = pg_temp.slot(16, 22.5),
           end_time   = pg_temp.slot(16, 23.5)
       WHERE class_name = 'T05-LOP-16E'$q$
], 'BR-16');

-- Đăng ký lần 2 khi dòng đăng ký cũ còn 'Enrolled': trigger BR-16 phát hiện lớp trùng với chính nó
-- trước khi UNIQUE được kiểm tra (xem TC-25 cho trường hợp đăng ký lại sau khi hủy).
SELECT pg_temp.expect_error('TC-68', 'BR-16', 'Đăng ký lần 2 cùng lớp khi đang Enrolled bị chặn bởi trigger BR-16 (trg_check_class_enrollment_conflicts)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-LOP-DUP2', 6, 1, pg_temp.slot(17, 21), pg_temp.slot(17, 22))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-DUP2'$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-DUP2'$q$
], 'BR-16');

SELECT pg_temp.expect_success('TP-15', 'BR-16', 'Lớp nhóm và ca PT nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) của cùng hội viên được chấp nhận', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-LOP-NOITIEP', 6, 1, pg_temp.slot(18, 21), pg_temp.slot(18, 22))$q$,
    $q$INSERT INTO class_enrollment (subscription_id, class_id)
       SELECT 1, class_id FROM class_schedule WHERE class_name = 'T05-LOP-NOITIEP'$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(18, 22), pg_temp.slot(18, 23))$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM pt_booking
          WHERE member_user_id = 11
            AND start_time = pg_temp.slot(18, 22)
      )$q$);


-- ============================================================================
-- PHẦN 10: BR-18 LÚC TẠO CA PT (trg_check_pt_booking_creation)
-- ============================================================================

SELECT pg_temp.expect_error('TC-56', 'BR-18', 'Đặt ca PT bằng hợp đồng chưa Active (Pending) (trg_check_pt_booking_creation)', 'P0001', ARRAY[
    $q$SELECT pg_temp.new_sub(26, 5, 4500000, pg_temp.slot(-1, 8), pg_temp.slot(44, 22))$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (26, 5, pg_temp.last_sub(26), pg_temp.slot(3, 21)::DATE, pg_temp.slot(3, 21), pg_temp.slot(3, 22))$q$
], 'không phải Active');

SELECT pg_temp.expect_error('TC-57', 'BR-18', 'Đặt ca PT sau ngày hết hạn hợp đồng (trg_check_pt_booking_creation)', 'P0001', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(200, 21)::DATE, pg_temp.slot(200, 21), pg_temp.slot(200, 22))$q$
], 'ngoài thời hạn');

SELECT pg_temp.expect_error('TC-58', 'BR-18', 'Đặt ca PT trước ngày bắt đầu hợp đồng (trg_check_pt_booking_creation)', 'P0001', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(-400, 21)::DATE, pg_temp.slot(-400, 21), pg_temp.slot(-400, 22))$q$
], 'ngoài thời hạn');

-- Đặt số buổi còn lại = (số ca Scheduled hiện có + 1): ca Scheduled đầu tiên được nhận, ca thứ hai vượt quá.
SELECT pg_temp.expect_error('TC-59', 'BR-18', 'Số ca PT Scheduled vượt số buổi còn lại của hợp đồng (trg_check_pt_booking_creation)', 'P0001', ARRAY[
    $q$UPDATE member_subscription
       SET remaining_sessions = (SELECT COUNT(*) + 1 FROM pt_booking WHERE subscription_id = 1 AND status = 'Scheduled')
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(19, 21), pg_temp.slot(19, 22))$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(20, 21)::DATE, pg_temp.slot(20, 21), pg_temp.slot(20, 22))$q$
], 'ca đang chờ');

SELECT pg_temp.expect_error('TC-60', 'BR-18', 'Đặt ca PT bằng hợp đồng gói không có buổi PT (hợp đồng ID 2, 0 buổi) (trg_check_pt_booking_creation)', 'P0001', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (12, 5, 2, pg_temp.slot(2, 21)::DATE, pg_temp.slot(2, 21), pg_temp.slot(2, 22))$q$
], 'BR-18');

SELECT pg_temp.expect_success('TP-16', 'BR-18', 'Còn đúng 1 buổi chưa đặt thì được đặt thêm 1 ca Scheduled', ARRAY[
    $q$UPDATE member_subscription
       SET remaining_sessions = (SELECT COUNT(*) + 1 FROM pt_booking WHERE subscription_id = 1 AND status = 'Scheduled')
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(19, 21), pg_temp.slot(19, 22))$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM pt_booking
          WHERE subscription_id = 1
            AND start_time = pg_temp.slot(19, 21)
      )$q$);


-- ============================================================================
-- PHẦN 11: BR-21 - CHỐNG ĐỤNG MÁY TẬP (trg_check_reservation_window + ex_reservation_equipment_no_overlap)
-- ============================================================================

SELECT pg_temp.expect_error('TC-61', 'BR-21', 'Một thiết bị bị giữ chỗ trùng giờ cho 2 ca PT khác nhau (ex_reservation_equipment_no_overlap)', '23P01', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(21, 21), pg_temp.slot(21, 22))$q$,
    $q$SELECT pg_temp.mk_pt(18, 6, 8, pg_temp.slot(21, 21.5), pg_temp.slot(21, 22.5))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 1, booking_id, start_time, end_time
       FROM pt_booking
       WHERE trainer_user_id = 5
         AND start_time = pg_temp.slot(21, 21)$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 1, booking_id, start_time, end_time - INTERVAL '30 minutes'
       FROM pt_booking
       WHERE trainer_user_id = 6
         AND start_time = pg_temp.slot(21, 21.5)$q$
], 'ex_reservation_equipment_no_overlap');

-- Ca bảo trì In_Progress tạo ngay trong test cho thiết bị ID 2 (status vẫn Operational) để cô lập trigger BR-21.
SELECT pg_temp.expect_error('TC-62', 'BR-21', 'Giữ chỗ thiết bị trong lúc có ca bảo trì In_Progress chưa kết thúc (trg_check_reservation_window)', '23P01', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       VALUES (2, 4, 'T05 bao tri dang sua', CURRENT_TIMESTAMP::TIMESTAMP - INTERVAL '1 hour')$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(22, 21), pg_temp.slot(22, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 2, booking_id, start_time, end_time
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(22, 21)$q$
], 'ca bảo trì');

SELECT pg_temp.expect_error('TC-63', 'BR-21', 'Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của ca PT gắn kèm (trg_check_reservation_window)', 'P0001', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(23, 21), pg_temp.slot(23, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 1, booking_id, start_time - INTERVAL '30 minutes', end_time
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(23, 21)$q$
], 'vượt ra ngoài');

SELECT pg_temp.expect_error('TC-64', 'BR-21', 'Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của lớp học gắn kèm (trg_check_reservation_window)', 'P0001', ARRAY[
    $q$SELECT pg_temp.mk_class('T05-LOP-GIUCHO', 6, 1, pg_temp.slot(24, 21), pg_temp.slot(24, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, class_id, start_time, end_time)
       SELECT 1, class_id, start_time, end_time + INTERVAL '30 minutes'
       FROM class_schedule
       WHERE class_name = 'T05-LOP-GIUCHO'$q$
], 'vượt ra ngoài');

SELECT pg_temp.expect_success('TP-17', 'BR-21', 'Giữ chỗ thiết bị nằm trọn trong khung giờ ca PT được chấp nhận', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(25, 21), pg_temp.slot(25, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 1, booking_id, start_time + INTERVAL '15 minutes', end_time - INTERVAL '15 minutes'
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(25, 21)$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM equipment_reservation
          WHERE equipment_id = 1
            AND start_time = pg_temp.slot(25, 21.25)
      )$q$);

SELECT pg_temp.expect_success('TP-18', 'BR-21', 'Lượt giữ chỗ đã Cancelled không chiếm thiết bị: giữ chỗ mới cùng giờ được chấp nhận', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(26, 21), pg_temp.slot(26, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time, status)
       SELECT 1, booking_id, start_time, end_time, 'Cancelled'
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(26, 21)$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 1, booking_id, start_time, end_time
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(26, 21)$q$
], $q$SELECT COUNT(*) = 2
      FROM equipment_reservation
      WHERE equipment_id = 1
        AND start_time = pg_temp.slot(26, 21)$q$);

SELECT pg_temp.expect_success('TP-19', 'BR-21', 'Ca bảo trì đã Completed không chặn giữ chỗ thiết bị', ARRAY[
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time, end_time, status)
       VALUES (2, 4, 'T05 bao tri da xong', CURRENT_TIMESTAMP::TIMESTAMP - INTERVAL '2 hours',
               CURRENT_TIMESTAMP::TIMESTAMP - INTERVAL '1 hour', 'Completed')$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(27, 21), pg_temp.slot(27, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT 2, booking_id, start_time, end_time
       FROM pt_booking
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(27, 21)$q$
], $q$SELECT EXISTS (
          SELECT 1
          FROM equipment_reservation
          WHERE equipment_id = 2
            AND start_time = pg_temp.slot(27, 21)
      )$q$);


-- ============================================================================
-- PHẦN 12: BR-23 - VẾT TRUY XUẤT NGƯỜI THỰC HIỆN (trg_fill_created_by)
-- Ứng dụng đặt SET LOCAL app.current_user_id = '<user_id>' đầu giao dịch; trigger điền created_by_user_id.
-- ============================================================================

SELECT pg_temp.expect_error('TC-65', 'BR-23', 'Người thực hiện không tồn tại trong user_account (fk_booking_created_by)', '23503', ARRAY[
    $q$SET LOCAL app.current_user_id = '999999'$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(2, 21), pg_temp.slot(2, 22))$q$
], 'fk_booking_created_by');

SELECT pg_temp.expect_success('TP-20', 'BR-23', 'created_by_user_id tự điền từ SET LOCAL app.current_user_id cho 5 bảng giao dịch', ARRAY[
    $q$SET LOCAL app.current_user_id = '3'$q$,
    $q$SELECT pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-1, 8), pg_temp.slot(29, 22))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.last_sub(26))$q$,
    $q$SELECT pg_temp.mk_class('T05-CREATED-BY', 6, 1, pg_temp.slot(28, 21), pg_temp.slot(28, 22))$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(28, 21), pg_temp.slot(28, 22))$q$,
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       VALUES (2, 4, 'T05 created_by', pg_temp.slot(28, 21))$q$
], $q$SELECT (SELECT created_by_user_id FROM member_subscription WHERE subscription_id = pg_temp.last_sub(26)) = 3
          AND (SELECT created_by_user_id FROM billing_log WHERE subscription_id = pg_temp.last_sub(26)) = 3
          AND (SELECT created_by_user_id FROM class_schedule WHERE class_name = 'T05-CREATED-BY') = 3
          AND (SELECT created_by_user_id FROM pt_booking WHERE subscription_id = 1 AND start_time = pg_temp.slot(28, 21)) = 3
          AND (SELECT created_by_user_id FROM maintenance_log WHERE issue_description = 'T05 created_by') = 3$q$);

SELECT pg_temp.expect_success('TP-21', 'BR-23', 'Giá trị created_by_user_id nêu rõ trong INSERT không bị trigger ghi đè', ARRAY[
    $q$SET LOCAL app.current_user_id = '3'$q$,
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, created_by_user_id)
       VALUES (11, 5, 1, pg_temp.slot(2, 21)::DATE, pg_temp.slot(2, 21), pg_temp.slot(2, 22), 4)$q$
], $q$SELECT created_by_user_id = 4
      FROM pt_booking
      WHERE subscription_id = 1
        AND start_time = pg_temp.slot(2, 21)$q$);

SELECT pg_temp.expect_success('TP-22', 'BR-23', 'Chưa đặt app.current_user_id (tác vụ hệ thống/cron) thì created_by_user_id giữ NULL', ARRAY[
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(2, 21), pg_temp.slot(2, 22))$q$
], $q$SELECT created_by_user_id IS NULL
      FROM pt_booking
      WHERE subscription_id = 1
        AND start_time = pg_temp.slot(2, 21)$q$);


-- ============================================================================
-- PHẦN 13: BR-24 - TỰ ĐỘNG GIA HẠN & ÂN HẠN (sp_process_subscription_renewals)
-- Thủ tục nhận ngày giả p_as_of để kiểm thử theo thời gian. Hợp đồng thử nghiệm: bắt đầu hôm nay - 25 ngày,
-- hết hạn hôm nay + 5 ngày lúc 22:00; hội viên 26 (không tự gia hạn) và 27 (tự gia hạn).
-- ============================================================================

SELECT pg_temp.expect_error('TC-66', 'BR-24', 'Gọi thủ tục với số ngày ân hạn âm (sp_process_subscription_renewals)', 'P0001', ARRAY[
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE, -1)$q$
], 'p_grace_days');

SELECT pg_temp.expect_success('TP-23', 'BR-24', 'Quá hạn: HĐ không tự gia hạn -> Expired; HĐ tự gia hạn -> hóa đơn Pending kỳ kế tiếp, vẫn Active trong ân hạn', ARRAY[
    $q$SELECT pg_temp.pay_sub(pg_temp.new_sub(26, 1, 800000, pg_temp.slot(-25, 8), pg_temp.slot(5, 22), FALSE))$q$,
    $q$SELECT pg_temp.pay_sub(pg_temp.new_sub(27, 1, 800000, pg_temp.slot(-25, 8), pg_temp.slot(5, 22), TRUE))$q$,
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 6)$q$
], $q$SELECT (SELECT sub_status FROM member_subscription WHERE subscription_id = pg_temp.last_sub(26)) = 'Expired'
          AND (SELECT sub_status FROM member_subscription WHERE subscription_id = pg_temp.last_sub(27)) = 'Active'
          AND (SELECT COUNT(*)
               FROM billing_log
               WHERE subscription_id = pg_temp.last_sub(27)
                 AND payment_status = 'Pending'
                 AND billing_period_start = pg_temp.slot(5, 22)::DATE
                 AND amount = 800000) = 1$q$);

SELECT pg_temp.expect_success('TP-24', 'BR-24', 'Gọi thủ tục nhiều lần trong ngày không phát sinh thêm hóa đơn gia hạn (idempotent)', ARRAY[
    $q$SELECT pg_temp.pay_sub(pg_temp.new_sub(27, 1, 800000, pg_temp.slot(-25, 8), pg_temp.slot(5, 22), TRUE))$q$,
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 6)$q$,
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 6)$q$
], $q$SELECT COUNT(*) = 1
      FROM billing_log
      WHERE subscription_id = pg_temp.last_sub(27)
        AND payment_status = 'Pending'$q$);

SELECT pg_temp.expect_success('TP-25', 'BR-24', 'Quá thời gian ân hạn (3 ngày) mà chưa thanh toán -> hợp đồng tự gia hạn chuyển Suspended', ARRAY[
    $q$SELECT pg_temp.pay_sub(pg_temp.new_sub(27, 1, 800000, pg_temp.slot(-25, 8), pg_temp.slot(5, 22), TRUE))$q$,
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 9)$q$
], $q$SELECT sub_status = 'Suspended'
      FROM member_subscription
      WHERE subscription_id = pg_temp.last_sub(27)$q$);

SELECT pg_temp.expect_success('TP-26', 'BR-24', 'Thanh toán hóa đơn gia hạn: hợp đồng Suspended -> Active, end_time + duration_days, đặt lại số buổi PT', ARRAY[
    $q$SELECT pg_temp.pay_sub(pg_temp.new_sub(27, 5, 4500000, pg_temp.slot(-25, 8), pg_temp.slot(5, 22), TRUE))$q$,
    $q$CALL sp_process_subscription_renewals(CURRENT_DATE + 9)$q$,
    $q$UPDATE billing_log
       SET payment_status = 'Completed',
           payment_date = CURRENT_DATE + 9
       WHERE subscription_id = pg_temp.last_sub(27)
         AND payment_status = 'Pending'$q$
], $q$SELECT sub_status = 'Active'
          AND end_time = pg_temp.slot(5, 22) + INTERVAL '45 days'
          AND remaining_sessions = 10
      FROM member_subscription
      WHERE subscription_id = pg_temp.last_sub(27)$q$);


-- ============================================================================
-- PHẦN 14: BR-25 CHÍNH SÁCH HỦY CA PT & chk_pt_booking_date
-- Số buổi gốc của hợp đồng ID 1 được ghi vào biến phiên cục bộ t05.rem rồi so sánh sau thao tác.
-- ============================================================================

SELECT pg_temp.expect_error('TC-67', 'BR-25', 'Ngày đặt lịch booking_date khác ngày của start_time (chk_pt_booking_date)', '23514', ARRAY[
    $q$INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time)
       VALUES (11, 5, 1, pg_temp.slot(3, 21)::DATE + 1, pg_temp.slot(3, 21), pg_temp.slot(3, 22))$q$
], 'chk_pt_booking_date');

SELECT pg_temp.expect_success('TP-27', 'BR-25', 'Hủy sớm (> 24 giờ): ca giữ trạng thái Cancelled và KHÔNG trừ buổi (trg_late_cancel_pt_booking)', ARRAY[
    $q$SELECT SET_CONFIG('t05.rem', remaining_sessions::TEXT, TRUE)
       FROM member_subscription
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(3, 21), pg_temp.slot(3, 22))$q$,
    $q$UPDATE pt_booking
       SET status = 'Cancelled'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(3, 21)$q$
], $q$SELECT (SELECT status FROM pt_booking WHERE subscription_id = 1 AND start_time = pg_temp.slot(3, 21)) = 'Cancelled'
          AND (SELECT remaining_sessions FROM member_subscription WHERE subscription_id = 1) = CURRENT_SETTING('t05.rem')::INT$q$);

SELECT pg_temp.expect_success('TP-28', 'BR-25', 'Hủy muộn (< 24 giờ): trigger đổi thành Late_Cancelled và trừ đúng 1 buổi', ARRAY[
    $q$SELECT SET_CONFIG('t05.rem', remaining_sessions::TEXT, TRUE)
       FROM member_subscription
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.late_slot(), pg_temp.late_slot() + INTERVAL '45 minutes')$q$,
    $q$UPDATE pt_booking
       SET status = 'Cancelled'
       WHERE subscription_id = 1
         AND start_time = pg_temp.late_slot()$q$
], $q$SELECT (SELECT status FROM pt_booking WHERE subscription_id = 1 AND start_time = pg_temp.late_slot()) = 'Late_Cancelled'
          AND (SELECT remaining_sessions FROM member_subscription WHERE subscription_id = 1) = CURRENT_SETTING('t05.rem')::INT - 1$q$);

SELECT pg_temp.expect_success('TP-29', 'BR-25', 'Bỏ tập (No_Show) bị trừ đúng 1 buổi (trg_update_remaining_pt_sessions)', ARRAY[
    $q$SELECT SET_CONFIG('t05.rem', remaining_sessions::TEXT, TRUE)
       FROM member_subscription
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(4, 21), pg_temp.slot(4, 22))$q$,
    $q$UPDATE pt_booking
       SET status = 'No_Show'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(4, 21)$q$
], $q$SELECT remaining_sessions = CURRENT_SETTING('t05.rem')::INT - 1
      FROM member_subscription
      WHERE subscription_id = 1$q$);

SELECT pg_temp.expect_success('TP-30', 'BR-25', 'Đổi Completed -> No_Show không bị trừ buổi lần thứ hai', ARRAY[
    $q$SELECT SET_CONFIG('t05.rem', remaining_sessions::TEXT, TRUE)
       FROM member_subscription
       WHERE subscription_id = 1$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(5, 21), pg_temp.slot(5, 22))$q$,
    $q$UPDATE pt_booking
       SET status = 'Completed'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(5, 21)$q$,
    $q$UPDATE pt_booking
       SET status = 'No_Show'
       WHERE subscription_id = 1
         AND start_time = pg_temp.slot(5, 21)$q$
], $q$SELECT remaining_sessions = CURRENT_SETTING('t05.rem')::INT - 1
      FROM member_subscription
      WHERE subscription_id = 1$q$);


-- ============================================================================
-- PHẦN 15: BR-19 CHIỀU NGƯỢC - CHUYỂN SANG BẢO TRÌ KHI CÒN LỊCH TƯƠNG LAI & VÒNG ĐỜI CA BẢO TRÌ
--          (trg_prevent_room_maintenance_with_future_classes, trg_prevent_equipment_maintenance_with_future_reservations,
--           trg_start_equipment_maintenance_*, trg_finish_equipment_maintenance)
-- Mỗi test tạo phòng / thiết bị riêng (INSERT trong test, bị hoàn tác) để không phụ thuộc dữ liệu mẫu.
-- ============================================================================
SELECT pg_temp.expect_error('TC-69', 'BR-19', 'Chuyển phòng sang bảo trì khi còn lớp học tương lai (trg_prevent_room_maintenance_with_future_classes)', 'P0001', ARRAY[
    $q$INSERT INTO facilities_room (room_name, max_capacity, room_type) VALUES ('T05 phong BR19', 10, 'Gym_Floor')$q$,
    $q$SELECT pg_temp.mk_class('T05-LOP-BR19', 6, (SELECT room_id FROM facilities_room WHERE room_name = 'T05 phong BR19'),
                              pg_temp.slot(30, 21), pg_temp.slot(30, 22))$q$,
    $q$UPDATE facilities_room
       SET status = 'Under_Maintenance'
       WHERE room_name = 'T05 phong BR19'$q$
], 'dời hoặc hủy các lớp này');

SELECT pg_temp.expect_error('TC-70', 'BR-19', 'Chuyển thiết bị sang bảo trì khi còn lượt giữ chỗ Reserved tương lai (trg_prevent_equipment_maintenance_with_future_reservations)', 'P0001', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (1, 'T05 thiet bi BR19', 'T05-BR19-A', CURRENT_DATE, 60)$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(31, 21), pg_temp.slot(31, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT e.equipment_id, pb.booking_id, pb.start_time, pb.end_time
       FROM equipment AS e, pt_booking AS pb
       WHERE e.serial_number = 'T05-BR19-A'
         AND pb.subscription_id = 1
         AND pb.start_time = pg_temp.slot(31, 21)$q$,
    $q$UPDATE equipment
       SET status = 'Under_Maintenance'
       WHERE serial_number = 'T05-BR19-A'$q$
], 'hủy hoặc chuyển các lượt này');

SELECT pg_temp.expect_error('TC-71', 'BR-19', 'Mở ca bảo trì In_Progress cho thiết bị còn lượt giữ chỗ tương lai bị chặn (chuỗi trg_start_equipment_maintenance_insert -> BR-19)', 'P0001', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (1, 'T05 thiet bi BR19', 'T05-BR19-B', CURRENT_DATE, 60)$q$,
    $q$SELECT pg_temp.mk_pt(11, 5, 1, pg_temp.slot(32, 21), pg_temp.slot(32, 22))$q$,
    $q$INSERT INTO equipment_reservation (equipment_id, booking_id, start_time, end_time)
       SELECT e.equipment_id, pb.booking_id, pb.start_time, pb.end_time
       FROM equipment AS e, pt_booking AS pb
       WHERE e.serial_number = 'T05-BR19-B'
         AND pb.subscription_id = 1
         AND pb.start_time = pg_temp.slot(32, 21)$q$,
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       SELECT equipment_id, 4, 'T05 bao tri BR19', CURRENT_TIMESTAMP::TIMESTAMP
       FROM equipment
       WHERE serial_number = 'T05-BR19-B'$q$
], 'hủy hoặc chuyển các lượt này');

SELECT pg_temp.expect_success('TP-31', 'BR-19', 'Phòng không còn lớp tương lai được chuyển sang bảo trì', ARRAY[
    $q$INSERT INTO facilities_room (room_name, max_capacity, room_type) VALUES ('T05 phong BR19', 10, 'Gym_Floor')$q$,
    $q$UPDATE facilities_room
       SET status = 'Under_Maintenance'
       WHERE room_name = 'T05 phong BR19'$q$
], $q$SELECT status = 'Under_Maintenance' FROM facilities_room WHERE room_name = 'T05 phong BR19'$q$);

SELECT pg_temp.expect_success('TP-32', 'BR-19', 'Chèn nhật ký bảo trì In_Progress tự chuyển thiết bị sang Under_Maintenance (trg_start_equipment_maintenance_insert)', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (1, 'T05 thiet bi BR19', 'T05-BR19-C', CURRENT_DATE, 60)$q$,
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       SELECT equipment_id, 4, 'T05 bao tri BR19', CURRENT_TIMESTAMP::TIMESTAMP
       FROM equipment
       WHERE serial_number = 'T05-BR19-C'$q$
], $q$SELECT status = 'Under_Maintenance' FROM equipment WHERE serial_number = 'T05-BR19-C'$q$);

SELECT pg_temp.expect_success('TP-33', 'BR-19', 'Hoàn tất ca bảo trì duy nhất tự đưa thiết bị về Operational (trg_finish_equipment_maintenance)', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (1, 'T05 thiet bi BR19', 'T05-BR19-D', CURRENT_DATE, 60)$q$,
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       SELECT equipment_id, 4, 'T05 bao tri BR19', CURRENT_TIMESTAMP::TIMESTAMP
       FROM equipment
       WHERE serial_number = 'T05-BR19-D'$q$,
    $q$UPDATE maintenance_log
       SET status = 'Completed', end_time = CURRENT_TIMESTAMP::TIMESTAMP
       WHERE issue_description = 'T05 bao tri BR19'$q$
], $q$SELECT status = 'Operational' FROM equipment WHERE serial_number = 'T05-BR19-D'$q$);

SELECT pg_temp.expect_success('TP-34', 'BR-19', 'Còn ca In_Progress khác thì hoàn tất 1 ca chưa đưa thiết bị về Operational; hoàn tất nốt mới về Operational', ARRAY[
    $q$INSERT INTO equipment (room_id, equipment_name, serial_number, purchase_date, depreciation_months)
       VALUES (1, 'T05 thiet bi BR19', 'T05-BR19-E', CURRENT_DATE, 60)$q$,
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       SELECT equipment_id, 4, 'T05 bao tri BR19 ca 1', CURRENT_TIMESTAMP::TIMESTAMP
       FROM equipment
       WHERE serial_number = 'T05-BR19-E'$q$,
    $q$INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
       SELECT equipment_id, 4, 'T05 bao tri BR19 ca 2', CURRENT_TIMESTAMP::TIMESTAMP
       FROM equipment
       WHERE serial_number = 'T05-BR19-E'$q$,
    $q$UPDATE maintenance_log
       SET status = 'Completed', end_time = CURRENT_TIMESTAMP::TIMESTAMP
       WHERE issue_description = 'T05 bao tri BR19 ca 1'$q$,
    $q$SELECT SET_CONFIG('t05.mid_status', (SELECT status FROM equipment WHERE serial_number = 'T05-BR19-E'), TRUE)$q$,
    $q$UPDATE maintenance_log
       SET status = 'Completed', end_time = CURRENT_TIMESTAMP::TIMESTAMP
       WHERE issue_description = 'T05 bao tri BR19 ca 2'$q$
], $q$SELECT CURRENT_SETTING('t05.mid_status') = 'Under_Maintenance'
          AND (SELECT status FROM equipment WHERE serial_number = 'T05-BR19-E') = 'Operational'$q$);


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
    LEFT(db_message, 140) AS db_message
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
