-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 08_rbac_security.sql - PHÂN QUYỀN TRUY CẬP CẤP CSDL (MỤC 5.2, GRANT/REVOKE)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell)
-- ----------------------------------------------------------------------------
-- ĐIỀU KIỆN CHẠY: đã nạp 01_schema_ddl.sql -> 02_mock_data/*.sql -> 04_triggers_views.sql
-- CÁCH CHẠY:      psql -U <superuser> -d <db> -v ON_ERROR_STOP=1 -f "Phase 3/08_rbac_security.sql"
--
-- NGUYÊN TẮC THIẾT KẾ:
--   * Role trong PostgreSQL là đối tượng toàn cụm (cluster-wide) nên script dọn
--     sạch các role cũ trước khi tạo lại => chạy lại nhiều lần vẫn an toàn (idempotent).
--   * Nguyên tắc đặc quyền tối thiểu: thu hồi mọi quyền của PUBLIC, sau đó chỉ
--     cấp đúng những gì ma trận quyền của ứng dụng (role_permission) yêu cầu.
--   * 5 role nhóm (NOLOGIN) mô phỏng 5 vai trò ứng dụng: Admin, Receptionist,
--     Trainer, Technician, Member. 5 tài khoản đăng nhập mẫu thừa hưởng (INHERIT)
--     quyền từ role nhóm tương ứng.
--   * Cột nhạy cảm (user_account.password_hash) được bảo vệ bằng GRANT mức cột.
--   * BR-10 (hóa đơn bất biến) được bảo vệ 4 lớp: (1) trigger trg_billing_immutable_update/
--     _delete/_truncate (04_triggers_views.sql) áp dụng cho MỌI role kể cả chủ sở hữu/superuser;
--     (2) phân quyền: billing_log chỉ cấp SELECT, INSERT cho mọi role, kể cả Admin (lỗi 42501);
--     (3) mọi đối tượng ứng dụng thuộc role NOLOGIN gym_owner; không tài khoản đăng nhập nào
--     (gym_u_*) là chủ sở hữu hay thành viên của gym_owner => không ai ALTER/DROP được billing_log;
--     (4) EVENT TRIGGER evt_protect_billing_log chặn ALTER TABLE / DROP TABLE / DROP|ALTER TRIGGER
--     trên billing_log và sửa/xóa các hàm trigger bất biến, kể cả với superuser.
--     Superuser là gốc tin cậy (trust root) của mọi DBMS: muốn bảo trì hợp lệ phải CHỦ ĐỘNG
--     tắt event trigger hoặc đặt app.allow_billing_maintenance = 'on' (xem PHẦN 7).
-- ============================================================================
-- PHẦN 1: DỌN DẸP ROLE CŨ (IDEMPOTENT)
-- ============================================================================
-- Xóa tài khoản đăng nhập trước, role nhóm sau. DROP OWNED BY thu hồi mọi quyền
-- đã cấp cho role trong CSDL hiện tại để DROP ROLE không bị từ chối.
DO $$
DECLARE
    v_role TEXT;
BEGIN
    FOREACH v_role IN ARRAY ARRAY[
        'gym_u_admin', 'gym_u_reception', 'gym_u_trainer', 'gym_u_tech', 'gym_u_member',
        'gym_role_admin', 'gym_role_receptionist', 'gym_role_trainer',
        'gym_role_technician', 'gym_role_member'
    ] LOOP
        IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = v_role) THEN
            EXECUTE format('DROP OWNED BY %I', v_role);
            EXECUTE format('DROP ROLE %I', v_role);
        END IF;
    END LOOP;
END;
$$;

-- ============================================================================
-- PHẦN 1B: DỠ EVENT TRIGGER CŨ + CHỦ SỞ HỮU DUY NHẤT gym_owner (IDEMPOTENT)
-- ============================================================================
-- Phải gỡ event trigger TRƯỚC khi đổi chủ sở hữu/cấp quyền (nó chặn ALTER TABLE ... OWNER);
-- chúng được tạo lại ở cuối tập tin (PHẦN 7).
DROP EVENT TRIGGER IF EXISTS evt_protect_billing_log;
DROP EVENT TRIGGER IF EXISTS evt_protect_billing_log_drop;

-- gym_owner: role NOLOGIN, KHÔNG phải superuser, không là thành viên của role nào và không role
-- đăng nhập nào là thành viên của nó. Chỉ superuser (gốc tin cậy) mới SET ROLE/ALTER OWNER được.
-- Không bao giờ DROP gym_owner khi chạy lại vì làm vậy sẽ kéo theo xóa đối tượng ứng dụng.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gym_owner') THEN
        CREATE ROLE gym_owner NOLOGIN;
    END IF;
END;
$$;

GRANT USAGE, CREATE ON SCHEMA public TO gym_owner;

-- Chuyển chủ sở hữu mọi bảng, view, sequence, hàm, thủ tục (trừ đối tượng của extension btree_gist
-- và sequence gắn với cột serial/identity - chúng tự đi theo bảng).
DO $$
DECLARE
    v_rec RECORD;
BEGIN
    FOR v_rec IN
        SELECT c.relkind, c.oid::REGCLASS::TEXT AS obj
        FROM pg_class AS c
        JOIN pg_namespace AS n ON n.oid = c.relnamespace
        WHERE n.nspname = 'public'
          AND c.relkind IN ('r', 'p', 'v', 'm', 'S')
          AND NOT EXISTS (SELECT 1 FROM pg_depend AS d
                          WHERE d.objid = c.oid AND d.classid = 'pg_class'::REGCLASS
                            AND d.deptype IN ('e', 'a', 'i'))
        ORDER BY c.relkind, c.relname
    LOOP
        EXECUTE format('ALTER %s %s OWNER TO gym_owner',
                       CASE v_rec.relkind WHEN 'v' THEN 'VIEW' WHEN 'm' THEN 'MATERIALIZED VIEW'
                                          WHEN 'S' THEN 'SEQUENCE' ELSE 'TABLE' END,
                       v_rec.obj);
    END LOOP;

    FOR v_rec IN
        SELECT p.prokind, p.oid::REGPROCEDURE::TEXT AS obj
        FROM pg_proc AS p
        JOIN pg_namespace AS n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
          AND p.prokind IN ('f', 'p')
          AND p.proname <> 'fn_evt_protect_billing_log'
          AND NOT EXISTS (SELECT 1 FROM pg_depend AS d
                          WHERE d.objid = p.oid AND d.classid = 'pg_proc'::REGCLASS
                            AND d.deptype = 'e')
        ORDER BY p.proname
    LOOP
        EXECUTE format('ALTER %s %s OWNER TO gym_owner',
                       CASE v_rec.prokind WHEN 'p' THEN 'PROCEDURE' ELSE 'FUNCTION' END,
                       v_rec.obj);
    END LOOP;
END;
$$;

-- ============================================================================
-- PHẦN 2: CỦNG CỐ BẢO MẬT MẶC ĐỊNH (HARDENING)
-- ============================================================================
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

-- ============================================================================
-- PHẦN 3: TẠO CÁC ROLE NHÓM (NOLOGIN)
-- ============================================================================
CREATE ROLE gym_role_admin        NOLOGIN;
CREATE ROLE gym_role_receptionist NOLOGIN;
CREATE ROLE gym_role_trainer      NOLOGIN;
CREATE ROLE gym_role_technician   NOLOGIN;
CREATE ROLE gym_role_member       NOLOGIN;

GRANT USAGE ON SCHEMA public TO gym_role_admin, gym_role_receptionist,
                                gym_role_trainer, gym_role_technician, gym_role_member;

-- ----------------------------------------------------------------------------
-- 3.1. gym_role_admin (quyền ứng dụng 1-10): toàn quyền DML, TRỪ các hạn chế sau
--   * billing_log chỉ SELECT, INSERT (BR-10: hóa đơn bất biến, Admin cũng không sửa/xóa).
--   * user_account.password_hash không được SELECT (vẫn được INSERT/UPDATE để đặt mật khẩu).
-- Không cấp TRUNCATE/TRIGGER/REFERENCES vì TRUNCATE sẽ vượt qua mọi giới hạn DELETE.
-- ----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gym_role_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO gym_role_admin;

REVOKE UPDATE, DELETE ON billing_log FROM gym_role_admin;

-- Hai view là truy vấn tổng hợp (JOIN/UNION), không cập nhật được nên chỉ cần SELECT.
REVOKE INSERT, UPDATE, DELETE ON vw_active_member_subscriptions, vw_trainer_schedule_overview
    FROM gym_role_admin;

REVOKE SELECT ON user_account FROM gym_role_admin;
GRANT SELECT (user_id, full_name, email, phone, dob, emergency_contact, status, created_at)
    ON user_account TO gym_role_admin;

-- ----------------------------------------------------------------------------
-- 3.2. gym_role_receptionist (quyền ứng dụng 1, 2, 3, 5, 6, 7): không có DELETE ở bất kỳ bảng nào
-- ----------------------------------------------------------------------------
GRANT SELECT (user_id, full_name, email, phone, dob, emergency_contact, status, created_at)
    ON user_account TO gym_role_receptionist;
GRANT INSERT ON user_account TO gym_role_receptionist;
-- UPDATE mức cột, loại trừ password_hash để lễ tân không thể ghi đè mật khẩu người khác.
GRANT UPDATE (full_name, email, phone, dob, emergency_contact, status)
    ON user_account TO gym_role_receptionist;

GRANT SELECT, INSERT, UPDATE ON member_profile TO gym_role_receptionist;
GRANT INSERT ON user_role TO gym_role_receptionist;
GRANT SELECT ON role TO gym_role_receptionist;
GRANT SELECT ON membership_plan TO gym_role_receptionist;
GRANT SELECT, INSERT, UPDATE ON member_subscription TO gym_role_receptionist;
GRANT SELECT, INSERT ON billing_log TO gym_role_receptionist;
GRANT SELECT, INSERT, UPDATE ON class_schedule TO gym_role_receptionist;
GRANT SELECT, INSERT, UPDATE ON class_enrollment TO gym_role_receptionist;
GRANT SELECT, INSERT, UPDATE ON pt_booking TO gym_role_receptionist;
GRANT SELECT ON trainer_profile TO gym_role_receptionist;
GRANT SELECT ON facilities_room TO gym_role_receptionist;
GRANT SELECT ON vw_active_member_subscriptions TO gym_role_receptionist;
GRANT SELECT ON vw_trainer_schedule_overview TO gym_role_receptionist;

GRANT USAGE ON SEQUENCE user_account_user_id_seq,
                        member_subscription_subscription_id_seq,
                        billing_log_billing_id_seq,
                        class_schedule_class_id_seq,
                        class_enrollment_enrollment_id_seq,
                        pt_booking_booking_id_seq
    TO gym_role_receptionist;

-- ----------------------------------------------------------------------------
-- 3.3. gym_role_trainer (quyền ứng dụng 1, 6, 7): chủ yếu chỉ đọc, được điểm danh/hoàn thành ca
-- ----------------------------------------------------------------------------
GRANT SELECT (user_id, full_name, phone, emergency_contact)
    ON user_account TO gym_role_trainer;
GRANT SELECT ON member_profile, trainer_profile, class_schedule, class_enrollment,
                pt_booking, facilities_room, membership_plan
    TO gym_role_trainer;
GRANT SELECT (subscription_id, member_user_id, plan_id, remaining_sessions,
              start_time, end_time, sub_status)
    ON member_subscription TO gym_role_trainer;

-- Chỉ được đổi trạng thái (điểm danh, Completed, No_Show), không được đổi HLV/hội viên/giờ.
GRANT UPDATE (status) ON pt_booking TO gym_role_trainer;
GRANT UPDATE (status) ON class_enrollment TO gym_role_trainer;
GRANT SELECT ON vw_trainer_schedule_overview TO gym_role_trainer;

-- ----------------------------------------------------------------------------
-- 3.4. gym_role_technician (quyền ứng dụng 8, 9): chỉ thao tác trên phân hệ thiết bị
-- ----------------------------------------------------------------------------
GRANT SELECT, INSERT, UPDATE ON equipment, maintenance_log TO gym_role_technician;
GRANT SELECT ON facilities_room TO gym_role_technician;
GRANT UPDATE (status) ON facilities_room TO gym_role_technician;
GRANT SELECT ON equipment_reservation TO gym_role_technician;
GRANT SELECT ON staff_profile TO gym_role_technician;

GRANT USAGE ON SEQUENCE equipment_equipment_id_seq,
                        maintenance_log_maintenance_id_seq
    TO gym_role_technician;

-- ----------------------------------------------------------------------------
-- 3.5. gym_role_member (quyền ứng dụng 1): chỉ xem danh mục công khai
-- ----------------------------------------------------------------------------
GRANT SELECT ON membership_plan, facilities_room TO gym_role_member;
-- class_schedule: không cấp created_by_user_id (BR-23: vết người thực hiện là dữ liệu nội bộ của nhân viên).
GRANT SELECT (class_id, trainer_user_id, room_id, class_name, start_time, end_time,
              max_capacity, current_enrolled)
    ON class_schedule TO gym_role_member;

-- ============================================================================
-- PHẦN 4: TÀI KHOẢN ĐĂNG NHẬP MẪU (DEMO)
-- ============================================================================
-- Mật khẩu 'demo_2026' chỉ dùng cho mục đích trình diễn, phải đổi khi triển khai thật.
CREATE ROLE gym_u_admin     LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_admin;
CREATE ROLE gym_u_reception LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_receptionist;
CREATE ROLE gym_u_trainer   LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_trainer;
CREATE ROLE gym_u_tech      LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_technician;
CREATE ROLE gym_u_member    LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_member;

-- ============================================================================
-- PHẦN 5: HÀM TRIGGER CHẠY VỚI QUYỀN CHỦ SỞ HỮU (SECURITY DEFINER)
-- ============================================================================
-- Hàm trigger mặc định chạy với quyền của NGƯỜI KÍCH HOẠT. Ví dụ HLV đổi
-- pt_booking.status = 'Completed' sẽ kích hoạt trigger SELECT ... FOR UPDATE và
-- UPDATE member_subscription - bảng mà HLV không (và không được) có quyền ghi;
-- lễ tân thêm class_enrollment sẽ kích hoạt UPDATE class_schedule.current_enrolled.
-- Nếu không có SECURITY DEFINER, các thao tác hợp lệ này sẽ bị từ chối (42501).
-- Giải pháp: hàm trigger chạy bằng quyền chủ sở hữu hàm (gym_owner, chủ mọi bảng nên đủ quyền
-- SELECT ... FOR UPDATE, UPDATE chéo bảng...), nên quyền trực tiếp của
-- role gọi vẫn được giữ tối thiểu. SET search_path cố định để chống tấn công
-- chiếm quyền qua search_path (pg_temp đặt cuối để không bị che khuất đối tượng thật).
-- Danh sách hàm trigger được liệt kê động từ pg_proc (mọi hàm trả về TRIGGER trong schema
-- public: các hàm của 01_schema_ddl.sql lẫn 04_triggers_views.sql) nên hàm trigger thêm mới
-- về sau cũng tự được áp dụng khi chạy lại tập tin này; ALTER FUNCTION chạy lại nhiều lần vẫn an toàn.
DO $$
DECLARE
    v_function REGPROCEDURE;
BEGIN
    FOR v_function IN
        SELECT p.oid::REGPROCEDURE
        FROM pg_proc AS p
        JOIN pg_namespace AS n ON n.oid = p.pronamespace
        WHERE n.nspname = 'public'
          AND p.prorettype = 'trigger'::REGTYPE
        ORDER BY p.proname
    LOOP
        EXECUTE format('ALTER FUNCTION %s SECURITY DEFINER SET search_path = public, pg_temp', v_function);
    END LOOP;
END;
$$;

-- ----------------------------------------------------------------------------
-- 5.1. Quyền thực thi thủ tục gia hạn hợp đồng (BR-24)
-- ----------------------------------------------------------------------------
-- Thủ tục chạy với quyền người gọi (SECURITY INVOKER): chỉ Admin và Lễ tân (hai role có quyền
-- UPDATE member_subscription và INSERT billing_log) được gọi; các role còn lại nhận 42501.
-- Chuỗi trigger phát sinh (kích hoạt/gia hạn hợp đồng) đã là SECURITY DEFINER nên chạy được.
REVOKE EXECUTE ON PROCEDURE sp_process_subscription_renewals(DATE, INT) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE sp_process_subscription_renewals(DATE, INT)
    TO gym_role_admin, gym_role_receptionist;

-- ============================================================================
-- PHẦN 6: MA TRẬN QUYỀN (ROLE x TABLE x PRIVILEGES)
-- ============================================================================
-- Ký hiệu: S=SELECT, I=INSERT, U=UPDATE, D=DELETE, (...)=chỉ trên các cột nêu trong ngoặc
--
-- Bảng / View                | admin | receptionist  | trainer            | technician | member
-- ---------------------------+-------+---------------+--------------------+------------+-------
-- user_account               | S*,I,U,D | S*,I,U(*)  | S(user_id,full_name,phone,emergency_contact) | - | -
-- role                       | SIUD  | S             | -                  | -          | -
-- user_role                  | SIUD  | I             | -                  | -          | -
-- permission, role_permission| SIUD  | -             | -                  | -          | -
-- member_profile             | SIUD  | S,I,U         | S                  | -          | -
-- trainer_profile            | SIUD  | S             | S                  | -          | -
-- staff_profile              | SIUD  | -             | -                  | S          | -
-- membership_plan            | SIUD  | S             | S                  | -          | S
-- member_subscription        | SIUD  | S,I,U         | S(7 cột, không giá) | -         | -
-- billing_log                | S,I   | S,I           | -                  | -          | -
-- facilities_room            | SIUD  | S             | S                  | S,U(status)| S
-- equipment                  | SIUD  | -             | -                  | S,I,U      | -
-- maintenance_log            | SIUD  | -             | -                  | S,I,U      | -
-- equipment_reservation      | SIUD  | -             | -                  | S          | -
-- class_schedule             | SIUD  | S,I,U         | S                  | -          | S(8 cột, không created_by_user_id)
-- class_enrollment           | SIUD  | S,I,U         | S, U(status)       | -          | -
-- pt_booking                 | SIUD  | S,I,U         | S, U(status)       | -          | -
-- vw_active_member_subscriptions | S   | S           | -                  | -          | -
-- vw_trainer_schedule_overview   | S   | S             | S                  | -          | -
--
-- (*) user_account: SELECT mức cột, KHÔNG gồm password_hash. Lễ tân UPDATE mức cột,
--     không gồm password_hash. Admin được INSERT/UPDATE password_hash.
-- (*) View: thuộc chủ sở hữu nên SELECT qua view chạy với quyền chủ sở hữu; HLV đọc được
--     lịch tổng hợp dù không có quyền trực tiếp trên user_account/billing_log.
-- (*) created_by_user_id (BR-23) trên member_subscription, billing_log, class_schedule, pt_booking,
--     maintenance_log: role có quyền INSERT mức bảng (admin, lễ tân, KTV với maintenance_log) tự được
--     ghi cột này (hoặc để trigger trg_fill_created_by điền); HLV chỉ UPDATE(status) nên không đụng tới;
--     HLV không thấy cột này ở member_subscription (SELECT mức cột), hội viên không thấy ở class_schedule.
-- (*) billing_log.billing_period_start (BR-08): lễ tân/admin INSERT bình thường; để trống thì trigger điền.
-- (*) Thủ tục sp_process_subscription_renewals (BR-24): EXECUTE chỉ cho admin và lễ tân (đã REVOKE khỏi PUBLIC).
-- (*) Mọi hàm trigger là SECURITY DEFINER SET search_path = public, pg_temp (Phần 5), nên chuỗi trigger
--     (trừ buổi PT, đồng bộ sĩ số lớp, kích hoạt hợp đồng sau thanh toán, đổi Late_Cancelled) chạy được
--     dưới role bị hạn chế.
-- Ghi chú: không role nào có TRUNCATE; không role ứng dụng nào UPDATE/DELETE billing_log.

-- ----------------------------------------------------------------------------
-- Truy vấn kiểm tra: hàm trigger SECURITY DEFINER và quyền EXECUTE thủ tục gia hạn
-- ----------------------------------------------------------------------------
SELECT
    p.proname AS routine_name,
    CASE p.prokind WHEN 'p' THEN 'PROCEDURE' ELSE 'TRIGGER FUNCTION' END AS routine_kind,
    p.prosecdef AS is_security_definer,
    p.proconfig AS fixed_config,
    CASE WHEN p.prokind = 'p'
         THEN (SELECT STRING_AGG(DISTINCT r.rolname, ', ' ORDER BY r.rolname)
               FROM pg_roles AS r
               WHERE r.rolname LIKE 'gym_role_%'
                 AND HAS_FUNCTION_PRIVILEGE(r.oid, p.oid, 'EXECUTE'))
    END AS roles_can_execute
FROM
    pg_proc AS p
    JOIN pg_namespace AS n ON n.oid = p.pronamespace
WHERE
    n.nspname = 'public'
    AND (p.prorettype = 'trigger'::REGTYPE OR p.prokind = 'p')
ORDER BY
    routine_kind, p.proname;

-- ----------------------------------------------------------------------------
-- Truy vấn kiểm tra: quyền mức bảng của các role nhóm
-- ----------------------------------------------------------------------------
SELECT
    grantee,
    table_name,
    STRING_AGG(privilege_type, ', ' ORDER BY privilege_type) AS table_privileges
FROM
    information_schema.role_table_grants
WHERE
    grantee LIKE 'gym_role_%'
    AND table_schema = 'public'
GROUP BY
    grantee, table_name
ORDER BY
    grantee, table_name;

-- Truy vấn kiểm tra: quyền mức cột (chỉ liệt kê quyền được cấp RIÊNG cho cột, không có ở mức bảng)
SELECT
    cg.grantee,
    cg.table_name,
    cg.privilege_type,
    STRING_AGG(cg.column_name, ', ' ORDER BY cg.column_name) AS columns
FROM
    information_schema.role_column_grants AS cg
WHERE
    cg.grantee LIKE 'gym_role_%'
    AND cg.table_schema = 'public'
    AND NOT EXISTS (
        SELECT 1
        FROM information_schema.role_table_grants AS tg
        WHERE tg.grantee = cg.grantee
          AND tg.table_schema = cg.table_schema
          AND tg.table_name = cg.table_name
          AND tg.privilege_type = cg.privilege_type
    )
GROUP BY
    cg.grantee, cg.table_name, cg.privilege_type
ORDER BY
    cg.grantee, cg.table_name, cg.privilege_type;

-- ============================================================================
-- PHẦN 7: EVENT TRIGGER BẢO VỆ billing_log (BR-10) - TẠO Ở CUỐI TẬP TIN
-- ============================================================================
-- Vì sao cần: trigger trg_billing_immutable_* có thể bị vô hiệu bởi chủ sở hữu bảng bằng
-- ALTER TABLE billing_log DISABLE TRIGGER ... hoặc DROP TRIGGER. Lớp (3) đã tước quyền đó của mọi
-- role đăng nhập (chủ sở hữu là gym_owner NOLOGIN); event trigger là lớp (4) chặn nốt cả superuser
-- thao tác NHẦM hoặc thiếu chủ đích. Event trigger KHÔNG thể ngăn superuser cố tình (superuser là
-- gốc tin cậy của mọi DBMS: có thể ALTER EVENT TRIGGER ... DISABLE, SET session_replication_role =
-- replica, sửa danh mục hệ thống...). Mục tiêu: mọi thay đổi phải là hành vi CÓ CHỦ ĐÍCH, để lại dấu vết.
--
-- Hai cách bảo trì hợp lệ (chỉ superuser):
--   a) ALTER EVENT TRIGGER evt_protect_billing_log DISABLE;  (và ..._drop)  ... làm việc ... ENABLE;
--   b) trong CÙNG giao dịch/phiên:  SET LOCAL app.allow_billing_maintenance = 'on';
--      (bị bỏ qua nếu người chạy không phải superuser.) 06_performance_test_cases.sql dùng cách b).
--
-- Chặn (kiểm tra ở ddl_command_end bằng pg_event_trigger_ddl_commands, và ở sql_drop bằng
-- pg_event_trigger_dropped_objects; RAISE EXCEPTION làm lệnh DDL bị hoàn tác):
--   * ALTER TABLE billing_log ... (DISABLE/ENABLE TRIGGER, OWNER, RENAME, SET SCHEMA...)
--   * ALTER TRIGGER ... ON billing_log (đổi tên); CREATE OR REPLACE / ALTER FUNCTION
--     trg_fn_billing_immutable_* (thay ruột hàm cũng vô hiệu hóa BR-10)
--   * DROP TABLE billing_log; DROP TRIGGER bất kỳ trigger nào trên billing_log;
--     DROP FUNCTION trg_fn_billing_immutable_*
-- Lưu ý: vì vậy chạy lại 04_triggers_views.sql trên CSDL đã có event trigger sẽ bị chặn
-- (nó DROP/CREATE trigger và hàm bất biến); phải dùng lối thoát a) hoặc b) cho lần chạy đó.
CREATE OR REPLACE FUNCTION fn_evt_protect_billing_log()
RETURNS EVENT_TRIGGER AS $$
DECLARE
    v_rec RECORD;
BEGIN
    -- Lối thoát có chủ đích: chỉ superuser đã đặt app.allow_billing_maintenance = 'on'.
    IF COALESCE(CURRENT_SETTING('app.allow_billing_maintenance', TRUE), '') = 'on'
       AND CURRENT_SETTING('is_superuser') = 'on' THEN
        RETURN;
    END IF;

    IF TG_EVENT = 'sql_drop' THEN
        FOR v_rec IN SELECT * FROM pg_event_trigger_dropped_objects() LOOP
            IF (v_rec.object_type = 'table' AND v_rec.object_identity = 'public.billing_log')
               OR (v_rec.object_type = 'trigger' AND v_rec.object_identity LIKE '% on public.billing_log')
               OR (v_rec.object_type = 'function'
                   AND v_rec.object_identity LIKE 'public.trg_fn_billing_immutable_%') THEN
                RAISE EXCEPTION USING ERRCODE = 'P0001',
                    MESSAGE = FORMAT('Lỗi nghiệp vụ BR-10: Không được xóa %s %s (nhật ký thanh toán bất biến)',
                                     v_rec.object_type, v_rec.object_identity),
                    HINT = 'Bảo trì hợp lệ: superuser chạy ALTER EVENT TRIGGER evt_protect_billing_log DISABLE (và evt_protect_billing_log_drop) hoặc SET LOCAL app.allow_billing_maintenance = "on"';
            END IF;
        END LOOP;
    ELSE
        FOR v_rec IN SELECT * FROM pg_event_trigger_ddl_commands() LOOP
            IF (v_rec.object_identity = 'public.billing_log')
               OR (v_rec.object_type = 'trigger' AND v_rec.object_identity LIKE '% on public.billing_log')
               OR (v_rec.object_type = 'function'
                   AND v_rec.object_identity LIKE 'public.trg_fn_billing_immutable_%') THEN
                RAISE EXCEPTION USING ERRCODE = 'P0001',
                    MESSAGE = FORMAT('Lỗi nghiệp vụ BR-10: Không được thay đổi (%s) %s (nhật ký thanh toán bất biến)',
                                     v_rec.command_tag, v_rec.object_identity),
                    HINT = 'Bảo trì hợp lệ: superuser chạy ALTER EVENT TRIGGER evt_protect_billing_log DISABLE (và evt_protect_billing_log_drop) hoặc SET LOCAL app.allow_billing_maintenance = "on"';
            END IF;
        END LOOP;
    END IF;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER evt_protect_billing_log ON ddl_command_end
    WHEN TAG IN ('ALTER TABLE', 'ALTER TRIGGER', 'ALTER FUNCTION', 'CREATE FUNCTION')
    EXECUTE FUNCTION fn_evt_protect_billing_log();

-- Sự kiện sql_drop cần event trigger riêng cho các lệnh DROP.
CREATE EVENT TRIGGER evt_protect_billing_log_drop ON sql_drop
    WHEN TAG IN ('DROP TABLE', 'DROP TRIGGER', 'DROP FUNCTION')
    EXECUTE FUNCTION fn_evt_protect_billing_log();
