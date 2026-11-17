-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 06_performance_test_cases.sql - KIỂM THỬ HIỆU NĂNG & CHỈ MỤC (MỤC 4.2)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell)
-- ----------------------------------------------------------------------------
-- ĐIỀU KIỆN CHẠY: đã nạp 01_schema_ddl.sql -> 02_mock_data/*.sql -> 04_triggers_views.sql
-- CÁCH CHẠY:      psql -U <user> -d <db> -f "Phase 3/06_performance_test_cases.sql"
--
-- YÊU CẦU PHI CHỨC NĂNG (NFR) ĐƯỢC KIỂM CHỨNG:
--   NFR-PERF-01: Các truy vấn tra cứu/tìm kiếm phải trả kết quả dưới 200 ms
--                với khối lượng dữ liệu cỡ 100.000+ bản ghi mỗi bảng nghiệp vụ.
--
-- PHƯƠNG PHÁP:
--   1. Dữ liệu mẫu chỉ có ~9.900 bản ghi (3.000 user, 500 thiết bị) => bộ tối ưu hóa luôn chọn Seq Scan,
--      không phản ánh thực tế. Vì vậy script sinh tạm ~420.000 bản ghi
--      (100k tài khoản, 200k hóa đơn, 120k ca PT) bằng generate_series().
--   2. Mỗi test case chạy EXPLAIN (ANALYZE) 2 lần:
--        (a) bình thường - bộ tối ưu hóa được dùng chỉ mục;
--        (b) tắt Index Scan / Bitmap Scan - mô phỏng bảng KHÔNG có chỉ mục.
--      So sánh thời gian thực thi (Execution Time) của (a) và (b).
--   3. Các trigger nghiệp vụ trong 04_triggers_views.sql (BR-08, BR-18, kiểm tra
--      chồng lấn chéo bảng, điền created_by...) sẽ từ chối dữ liệu tổng hợp vì
--      dữ liệu sinh ra không gắn với hợp đồng/hội viên thực. Bài kiểm thử này chỉ
--      đo hiệu năng ĐỌC, nên trigger của người dùng trên billing_log và
--      pt_booking được tạm tắt CHỈ trong lúc nạp dữ liệu hàng loạt và được bật
--      lại trước khi đo. Mọi ràng buộc CHECK/UNIQUE/EXCLUDE/FK vẫn luôn có hiệu lực.
--   4. Toàn bộ tập tin nằm trong BEGIN ... ROLLBACK => dữ liệu sinh tạm
--      bị hủy sau khi chạy, CSDL trở về nguyên trạng.
--   Lưu ý: số mili-giây phụ thuộc cấu hình máy; điều cần quan sát là loại
--   phép quét (Index Scan vs Seq Scan) và tỉ lệ chênh lệch giữa (a) và (b).
-- ============================================================================

BEGIN;

SET client_min_messages = WARNING;

-- ============================================================================
-- BƯỚC 1: SINH DỮ LIỆU KHỐI LƯỢNG LỚN (TẠM THỜI)
-- ============================================================================

-- Tạm tắt trigger người dùng (BR-08, BR-18, chồng lấn chéo bảng, BR-23 điền created_by...) để nạp
-- nhanh 320.000 dòng tổng hợp (created_by_user_id = 3 được nêu tường minh vì cột NOT NULL vẫn có hiệu lực). Chỉ ảnh hưởng tới việc NẠP; các ràng buộc CHECK/UNIQUE/
-- EXCLUDE/FK vẫn hoạt động. Trigger được bật lại ngay trước khi đo (cuối BƯỚC 1).
-- Event trigger bảo vệ billing_log (08_rbac_security.sql PHẦN 7) chặn ALTER TABLE; superuser dùng lối thoát có chủ đích
-- (chỉ hiệu lực trong giao dịch này) để tắt/bật trigger lúc nạp dữ liệu hàng loạt.
SET LOCAL app.allow_billing_maintenance = 'on';
ALTER TABLE billing_log DISABLE TRIGGER USER;
ALTER TABLE pt_booking DISABLE TRIGGER USER;

-- 100.000 tài khoản người dùng
INSERT INTO user_account (full_name, email, phone, dob, password_hash)
SELECT
    'Perf User ' || g,
    'perf_user_' || g || '@perf.test',
    'P' || LPAD(g::TEXT, 9, '0'),
    DATE '1990-01-01' + (g % 7000),
    'perf_hash'
FROM
    generate_series(1, 100000) AS g;

-- 200.000 hóa đơn trải đều 3 năm (2024 - 2026) cho 30 hợp đồng có sẵn
-- billing_period_start khác nhau cho từng dòng => thỏa chỉ mục duy nhất uq_billing_subscription_period (BR-08)
-- (trigger tự điền cột này đã bị tắt nên phải cung cấp tường minh; lùi về năm 1000 để không đụng dữ liệu mẫu)
INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method, payment_status, billing_period_start, created_by_user_id)
SELECT
    1 + (g % 30),
    'PERF-INV-' || LPAD(g::TEXT, 7, '0'),
    100000 + (g % 50) * 10000,
    DATE '2024-01-01' + (g % 1095),
    (ARRAY['Cash', 'Credit_Card', 'Banking', 'E_Wallet'])[1 + g % 4],
    CASE WHEN g % 20 = 0 THEN 'Refunded' ELSE 'Completed' END,
    DATE '1000-01-01' + g,
    3
FROM
    generate_series(1, 200000) AS g;

-- 120.000 ca PT: mỗi HLV (ID 5..10) ghép cố định với một hợp đồng PT còn buổi,
-- mỗi ca 1 giờ nối tiếp nhau từ năm 2031 => không vi phạm ràng buộc EXCLUDE chống trùng lịch.
-- (trigger BR-18 kiểm tra hợp đồng còn hiệu lực/còn buổi bị tắt vì ca PT ở tương lai xa)
INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_by_user_id)
SELECT
    pair.member_user_id,
    pair.trainer_user_id,
    pair.subscription_id,
    (TIMESTAMP '2031-01-01 00:00' + g * INTERVAL '1 hour')::DATE,
    TIMESTAMP '2031-01-01 00:00' + g * INTERVAL '1 hour',
    TIMESTAMP '2031-01-01 00:00' + (g + 1) * INTERVAL '1 hour',
    'Scheduled',
    3
FROM
    (VALUES (5, 11, 1), (6, 13, 3), (7, 16, 6), (8, 18, 8), (9, 20, 10), (10, 21, 11))
        AS pair (trainer_user_id, member_user_id, subscription_id)
CROSS JOIN
    generate_series(0, 19999) AS g;

-- Bật lại trigger trước khi đo: từ đây CSDL ở trạng thái bình thường
ALTER TABLE billing_log ENABLE TRIGGER USER;
ALTER TABLE pt_booking ENABLE TRIGGER USER;

ANALYZE user_account;
ANALYZE billing_log;
ANALYZE pt_booking;
ANALYZE member_subscription;
ANALYZE membership_plan;

SELECT 'user_account' AS table_name, COUNT(*) AS row_count FROM user_account
UNION ALL
SELECT 'billing_log', COUNT(*) FROM billing_log
UNION ALL
SELECT 'pt_booking', COUNT(*) FROM pt_booking;


-- ============================================================================
-- BƯỚC 2: HÀM ĐO HIỆU NĂNG
-- ============================================================================
CREATE TEMP TABLE perf_result (
    run_order          SERIAL,
    tc_id              VARCHAR(10)  NOT NULL,
    description        VARCHAR(200) NOT NULL,
    plan_with_index    TEXT,
    ms_with_index      NUMERIC(10, 3),
    plan_without_index TEXT,
    ms_without_index   NUMERIC(10, 3)
);

CREATE FUNCTION pg_temp.scan_summary(p_plan JSONB)
RETURNS TEXT AS $$
    SELECT COALESCE(
        (jsonb_path_query_first(p_plan, '$.** ? (exists(@."Index Name"))."Node Type"') #>> '{}')
            || ' (' || (jsonb_path_query_first(p_plan, '$.**."Index Name"') #>> '{}') || ')',
        (jsonb_path_query_first(p_plan, '$.** ? (exists(@."Relation Name"))."Node Type"') #>> '{}')
            || ' (' || (jsonb_path_query_first(p_plan, '$.**."Relation Name"') #>> '{}') || ')'
    );
$$ LANGUAGE sql;

CREATE FUNCTION pg_temp.measure(
    p_tc_id          VARCHAR,
    p_description VARCHAR,
    p_query       TEXT
)
RETURNS VOID AS $$
DECLARE
    v_plan_on  JSONB;
    v_plan_off JSONB;
BEGIN
    -- Chạy làm nóng bộ đệm (warm-up) để phép đo không bị ảnh hưởng bởi đọc đĩa lần đầu
    EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || p_query;

    -- (a) Có chỉ mục
    PERFORM set_config('enable_indexscan', 'on', TRUE);
    PERFORM set_config('enable_bitmapscan', 'on', TRUE);
    PERFORM set_config('enable_indexonlyscan', 'on', TRUE);
    EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || p_query INTO v_plan_on;

    -- (b) Không dùng chỉ mục
    PERFORM set_config('enable_indexscan', 'off', TRUE);
    PERFORM set_config('enable_bitmapscan', 'off', TRUE);
    PERFORM set_config('enable_indexonlyscan', 'off', TRUE);
    EXECUTE 'EXPLAIN (ANALYZE, FORMAT JSON) ' || p_query INTO v_plan_off;

    PERFORM set_config('enable_indexscan', 'on', TRUE);
    PERFORM set_config('enable_bitmapscan', 'on', TRUE);
    PERFORM set_config('enable_indexonlyscan', 'on', TRUE);

    INSERT INTO perf_result (tc_id, description,
                             plan_with_index, ms_with_index,
                             plan_without_index, ms_without_index)
    VALUES (p_tc_id, p_description,
            pg_temp.scan_summary(v_plan_on -> 0 -> 'Plan'),
            (v_plan_on -> 0 ->> 'Execution Time')::NUMERIC,
            pg_temp.scan_summary(v_plan_off -> 0 -> 'Plan'),
            (v_plan_off -> 0 ->> 'Execution Time')::NUMERIC);
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- BƯỚC 3: CÁC TEST CASE HIỆU NĂNG
-- ============================================================================

-- PT-01: Đăng nhập - tra cứu tài khoản theo email (FR: xác thực người dùng)
SELECT pg_temp.measure('PT-01',
    'Tra cứu tài khoản theo email khi đăng nhập',
    $q$SELECT user_id, full_name, status
       FROM user_account
       WHERE email = 'perf_user_77777@perf.test'$q$);

-- PT-02: Lễ tân tra cứu hội viên theo số điện thoại
SELECT pg_temp.measure('PT-02',
    'Tra cứu tài khoản theo số điện thoại',
    $q$SELECT user_id, full_name, email
       FROM user_account
       WHERE phone = 'P000054321'$q$);

-- PT-03: Doanh thu theo khoảng ngày (1 tuần) - báo cáo nhanh cho quản lý
SELECT pg_temp.measure('PT-03',
    'Tổng doanh thu theo phương thức thanh toán trong 1 tuần',
    $q$SELECT payment_method, COUNT(*) AS total_transactions, SUM(amount) AS total_revenue
       FROM billing_log
       WHERE payment_status = 'Completed'
         AND payment_date >= DATE '2026-03-01'
         AND payment_date <  DATE '2026-03-08'
       GROUP BY payment_method$q$);

-- PT-04: Lịch sử thanh toán của 1 hợp đồng (màn hình chi tiết hội viên)
-- Kỳ vọng: dùng chỉ mục ghép idx_billing_log_subscription_date (subscription_id, payment_date DESC),
-- vừa lọc theo hợp đồng vừa trả sẵn thứ tự giảm dần nên không cần bước Sort.
SELECT pg_temp.measure('PT-04',
    'Lịch sử 20 hóa đơn gần nhất của một hợp đồng',
    $q$SELECT invoice_no, amount, payment_date, payment_status
       FROM billing_log
       WHERE subscription_id = 7
       ORDER BY payment_date DESC
       LIMIT 20$q$);

-- PT-05: Tra cứu hóa đơn theo số hóa đơn (đối soát)
SELECT pg_temp.measure('PT-05',
    'Tra cứu một hóa đơn theo invoice_no',
    $q$SELECT billing_id, subscription_id, amount, payment_status
       FROM billing_log
       WHERE invoice_no = 'PERF-INV-0123456'$q$);

-- PT-06: Lịch dạy PT trong 1 ngày của 1 HLV (màn hình lịch HLV)
SELECT pg_temp.measure('PT-06',
    'Lịch ca PT trong một ngày của một HLV',
    $q$SELECT booking_id, member_user_id, start_time, end_time, status
       FROM pt_booking
       WHERE trainer_user_id = 7
         AND start_time >= TIMESTAMP '2032-06-01 00:00'
         AND start_time <  TIMESTAMP '2032-06-02 00:00'
       ORDER BY start_time$q$);

-- PT-07: Kiểm tra HLV có rảnh trong khung giờ trước khi đặt lịch (BR-12)
-- Lưu ý: điều kiện status phải khớp vị từ của chỉ mục từng phần ex_pt_trainer_no_overlap thì bộ tối ưu hóa mới dùng được chỉ mục.
SELECT pg_temp.measure('PT-07',
    'Kiểm tra trùng lịch HLV bằng toán tử chồng lấn khoảng thời gian (&&)',
    $q$SELECT EXISTS (
           SELECT 1
           FROM pt_booking
           WHERE trainer_user_id = 8
             AND status NOT IN ('Cancelled', 'Late_Cancelled')
             AND tsrange(start_time, end_time, '[)')
                 && tsrange(TIMESTAMP '2032-03-15 10:30', TIMESTAMP '2032-03-15 11:30', '[)')
       ) AS is_conflicted$q$);

-- PT-08: Truy vấn phức hợp số 1 (doanh thu theo gói trong một quý) trên dữ liệu lớn
SELECT pg_temp.measure('PT-08',
    'Truy vấn phức hợp Q1: doanh thu từng gói tập trong một quý (JOIN 3 bảng)',
    $q$SELECT mp.plan_id, mp.plan_name, COUNT(bl.billing_id) AS total_transactions, SUM(bl.amount) AS total_revenue
       FROM membership_plan AS mp
       JOIN member_subscription AS ms
           ON mp.plan_id = ms.plan_id
       JOIN billing_log AS bl
           ON ms.subscription_id = bl.subscription_id
       WHERE bl.payment_status = 'Completed'
         AND bl.payment_date >= DATE '2026-07-01'
         AND bl.payment_date <  DATE '2026-10-01'
       GROUP BY mp.plan_id, mp.plan_name
       ORDER BY total_revenue DESC$q$);


-- ============================================================================
-- BƯỚC 4: KẾ HOẠCH THỰC THI CHI TIẾT (MINH HỌA CHO BÁO CÁO)
-- ============================================================================
EXPLAIN (ANALYZE, COSTS OFF)
SELECT
    user_id,
    full_name,
    status
FROM
    user_account
WHERE
    email = 'perf_user_77777@perf.test';

EXPLAIN (ANALYZE, COSTS OFF)
SELECT
    EXISTS (
        SELECT 1
        FROM pt_booking
        WHERE trainer_user_id = 8
          AND status NOT IN ('Cancelled', 'Late_Cancelled')
          AND tsrange(start_time, end_time, '[)')
              && tsrange(TIMESTAMP '2032-03-15 10:30', TIMESTAMP '2032-03-15 11:30', '[)')
    ) AS is_conflicted;


-- ============================================================================
-- BƯỚC 5: BÁO CÁO TỔNG HỢP
-- ============================================================================
SELECT
    tc_id,
    description,
    plan_with_index,
    ms_with_index,
    plan_without_index,
    ms_without_index,
    ROUND(ms_without_index / NULLIF(ms_with_index, 0), 1) AS speedup_x,
    CASE WHEN ms_with_index < 200 THEN 'PASS' ELSE 'FAIL' END AS nfr_under_200ms
FROM
    perf_result
ORDER BY
    run_order;

ROLLBACK;
