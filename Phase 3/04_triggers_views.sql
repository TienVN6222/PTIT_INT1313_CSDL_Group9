-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 04_triggers_views.sql - KHỞI TẠO CÁC KHUNG NHÌN (VIEWS) VÀ BỘ KÍCH HOẠT (TRIGGERS)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell) / PL/pgSQL Procedural Standard
-- ----------------------------------------------------------------------------
-- ĐIỀU KIỆN CHẠY: đã nạp 01_schema_ddl.sql -> 02_mock_data/*.sql (tập tin này chạy SAU dữ liệu
--                 mẫu để cuối tập tin có thể kiểm toán lại dữ liệu mẫu theo các quy tắc mới).
-- LƯU Ý:          các hàm trigger được tạo ở đây là SECURITY INVOKER; 08_rbac_security.sql đổi
--                 chúng sang SECURITY DEFINER. Nạp lại tập tin này thì phải nạp lại 08.
--
-- DANH MỤC TRIGGER / HÀM / THỦ TỤC (PHẦN 2 trở đi)
--   BR-18, BR-25  trg_update_remaining_pt_sessions   AFTER UPDATE OF status ON pt_booking
--   BR-19         trg_prevent_class_in_maintenance_room, trg_prevent_equipment_reservation_under_maintenance
--                 trg_prevent_room_maintenance_with_future_classes          BEFORE UPDATE OF status ON facilities_room
--                 trg_prevent_equipment_maintenance_with_future_reservations BEFORE UPDATE OF status ON equipment
--                 trg_start_equipment_maintenance_insert / _update, trg_finish_equipment_maintenance ON maintenance_log
--   BR-07         trg_require_payment_before_active  BEFORE INSERT/UPDATE OF sub_status ON member_subscription
--                 trg_activate_on_payment_insert / _update  AFTER INSERT/UPDATE ON billing_log
--   BR-08         trg_fill_billing_period_start      BEFORE INSERT ON billing_log
--   BR-10         trg_billing_immutable_update / _delete / _truncate ON billing_log
--   BR-12, BR-16  trg_check_class_schedule_conflicts, trg_check_pt_booking_conflicts,
--                 trg_check_class_enrollment_conflicts
--   BR-18         trg_check_pt_booking_creation      BEFORE INSERT ON pt_booking
--   BR-21         trg_check_reservation_window       BEFORE INSERT/UPDATE ON equipment_reservation
--   BR-23         trg_fill_created_by                BEFORE INSERT ON 5 bảng giao dịch
--   BR-24         sp_process_subscription_renewals(p_as_of, p_grace_days)  (PROCEDURE, chạy hằng ngày)
--   BR-25         trg_late_cancel_pt_booking         BEFORE UPDATE OF status ON pt_booking
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
-- 'No_Show' hoặc 'Late_Cancelled', hệ thống tự động trừ 1 buổi trong trường remaining_sessions
-- của bảng member_subscription.
-- Nếu số buổi còn lại <= 0, hệ thống ngăn chặn và báo lỗi ngoại lệ (Raise Exception).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_update_remaining_pt_sessions()
RETURNS TRIGGER AS $$
DECLARE
    v_current_remaining INT;
    -- Các trạng thái làm phát sinh việc trừ buổi (BR-25): đã tập xong, bỏ tập, hủy muộn.
    v_deducting CONSTANT TEXT[] := ARRAY['Completed', 'No_Show', 'Late_Cancelled'];
BEGIN
    -- Chỉ trừ buổi khi chuyển SANG nhóm trạng thái tính phí từ một trạng thái không thuộc nhóm đó
    -- (tránh trừ hai lần khi đổi Completed -> No_Show...). Hủy sớm (Cancelled) không bị trừ vì
    -- buổi tập chỉ bị trừ khi hoàn thành, không trừ lúc đặt lịch.
    IF (NEW.status = ANY (v_deducting) AND NOT (OLD.status = ANY (v_deducting))) THEN
        -- Khóa bản ghi hợp đồng để kiểm tra tránh tranh chấp đồng thời (Concurrency Control)
        SELECT remaining_sessions
        INTO v_current_remaining
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

        RAISE NOTICE 'Đã tự động trừ 1 buổi PT (ca chuyển sang %) cho hợp đồng ID: %. Số buổi còn lại: %',
            NEW.status, NEW.subscription_id, (v_current_remaining - 1);
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
-- Chiều ngược lại (2.3 - 2.6): không cho chuyển phòng/thiết bị sang bảo trì khi còn lịch tương lai,
-- và đồng bộ trạng thái thiết bị theo vòng đời ca bảo trì (maintenance_log).
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


-- 2.3 Chuyển phòng tập sang bảo trì: không được còn lớp học sắp diễn ra trong phòng (BR-19)
-- Nhân viên phải dời/hủy các lớp tương lai trước, nếu không việc đổi trạng thái bị từ chối.
CREATE OR REPLACE FUNCTION trg_fn_prevent_room_maintenance_with_future_classes()
RETURNS TRIGGER AS $$
DECLARE
    v_future_classes INT;
BEGIN
    SELECT COUNT(*)
    INTO v_future_classes
    FROM class_schedule
    WHERE room_id = NEW.room_id
      AND start_time > CURRENT_TIMESTAMP;

    IF (v_future_classes > 0) THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-19: Phòng tập "%" (ID: %) còn % lớp học sắp diễn ra; hãy dời hoặc hủy các lớp này trước khi chuyển sang BẢO TRÌ',
            NEW.room_name, NEW.room_id, v_future_classes;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_room_maintenance_with_future_classes ON facilities_room;
CREATE TRIGGER trg_prevent_room_maintenance_with_future_classes
BEFORE UPDATE OF status ON facilities_room
FOR EACH ROW
WHEN (NEW.status = 'Under_Maintenance' AND OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION trg_fn_prevent_room_maintenance_with_future_classes();


-- 2.4 Chuyển thiết bị sang bảo trì: không được còn lượt giữ chỗ 'Reserved' trong tương lai (BR-19)
CREATE OR REPLACE FUNCTION trg_fn_prevent_equipment_maintenance_with_future_reservations()
RETURNS TRIGGER AS $$
DECLARE
    v_future_reservations INT;
BEGIN
    SELECT COUNT(*)
    INTO v_future_reservations
    FROM equipment_reservation
    WHERE equipment_id = NEW.equipment_id
      AND status = 'Reserved'
      AND start_time > CURRENT_TIMESTAMP;

    IF (v_future_reservations > 0) THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-19: Thiết bị "%" (ID: %) còn % lượt giữ chỗ (Reserved) trong tương lai; hãy hủy hoặc chuyển các lượt này trước khi chuyển sang BẢO TRÌ',
            NEW.equipment_name, NEW.equipment_id, v_future_reservations;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_prevent_equipment_maintenance_with_future_reservations ON equipment;
CREATE TRIGGER trg_prevent_equipment_maintenance_with_future_reservations
BEFORE UPDATE OF status ON equipment
FOR EACH ROW
WHEN (NEW.status = 'Under_Maintenance' AND OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION trg_fn_prevent_equipment_maintenance_with_future_reservations();


-- 2.5 Mở ca bảo trì In_Progress => thiết bị tự chuyển sang 'Under_Maintenance' (BR-19)
-- Việc cập nhật equipment đi qua trigger 2.4 nên nếu thiết bị còn lượt giữ chỗ tương lai thì
-- cả INSERT nhật ký bảo trì cũng bị từ chối. Thiết bị đã Decommissioned được giữ nguyên.
CREATE OR REPLACE FUNCTION trg_fn_start_equipment_maintenance()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE equipment
    SET status = 'Under_Maintenance'
    WHERE equipment_id = NEW.equipment_id
      AND status = 'Operational';

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_start_equipment_maintenance_insert ON maintenance_log;
CREATE TRIGGER trg_start_equipment_maintenance_insert
AFTER INSERT ON maintenance_log
FOR EACH ROW
WHEN (NEW.status = 'In_Progress')
EXECUTE FUNCTION trg_fn_start_equipment_maintenance();

DROP TRIGGER IF EXISTS trg_start_equipment_maintenance_update ON maintenance_log;
CREATE TRIGGER trg_start_equipment_maintenance_update
AFTER UPDATE OF status ON maintenance_log
FOR EACH ROW
WHEN (NEW.status = 'In_Progress' AND OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION trg_fn_start_equipment_maintenance();


-- 2.6 Ca bảo trì kết thúc (Completed/Cancelled) và thiết bị không còn ca In_Progress nào khác
--     => thiết bị trở lại 'Operational' (trừ khi đã Decommissioned) (BR-19)
CREATE OR REPLACE FUNCTION trg_fn_finish_equipment_maintenance()
RETURNS TRIGGER AS $$
BEGIN
    IF NOT EXISTS (
        SELECT 1
        FROM maintenance_log
        WHERE equipment_id = NEW.equipment_id
          AND status = 'In_Progress'
          AND maintenance_id <> NEW.maintenance_id
    ) THEN
        UPDATE equipment
        SET status = 'Operational'
        WHERE equipment_id = NEW.equipment_id
          AND status = 'Under_Maintenance';
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_finish_equipment_maintenance ON maintenance_log;
CREATE TRIGGER trg_finish_equipment_maintenance
AFTER UPDATE OF status ON maintenance_log
FOR EACH ROW
WHEN (OLD.status = 'In_Progress' AND NEW.status IN ('Completed', 'Cancelled'))
EXECUTE FUNCTION trg_fn_finish_equipment_maintenance();


-- ============================================================================
-- PHẦN 3: ĐỒNG BỘ THỰC THI CÁC QUY TẮC NGHIỆP VỤ CÒN LẠI (BR-05 -> BR-25)
-- ============================================================================
-- Quy ước chung của PHẦN 3:
--   * Quy tắc "một giá trị / một khoảng thời gian" trong MỘT bảng được thực thi bằng ràng buộc
--     khai báo trong 01_schema_ddl.sql (UNIQUE INDEX một phần, EXCLUDE USING gist).
--   * Quy tắc liên quan NHIỀU bảng (không thể khai báo bằng ràng buộc) được thực thi bằng trigger.
--   * Các trigger kiểm tra chồng lịch dùng pg_advisory_xact_lock: kiểm tra "chưa có lịch trùng"
--     rồi mới INSERT là thao tác 2 bước; nếu không khóa, 2 giao dịch đồng thời cùng thấy "chưa trùng"
--     và cùng ghi thành công (race condition). Khóa tư vấn theo khóa nghiệp vụ (HLV / hội viên / hợp
--     đồng) buộc các giao dịch cùng đối tượng phải chạy tuần tự; khóa tự giải phóng khi COMMIT/ROLLBACK.
--     Truy vấn kiểm tra chạy SAU khi giành được khóa nên thấy dữ liệu đã COMMIT của giao dịch trước
--     (READ COMMITTED lấy snapshot mới cho mỗi câu lệnh trong hàm VOLATILE).
--     Không gian khóa: (1, trainer_id) HLV | (2, member_id) hội viên | (3, subscription_id) hợp đồng.
--     Thứ tự giành khóa luôn là HLV -> hội viên (-> hợp đồng) để tránh deadlock.
--   * Lỗi chồng lịch xuyên bảng trả SQLSTATE 23P01 (exclusion_violation) cho đồng nhất với EXCLUDE.
-- ============================================================================

-- ----------------------------------------------------------------------------
-- TRIGGER 3: trg_fill_created_by (BR-23) - Vết truy xuất người thực hiện
-- Cách dùng: phiên làm việc của ứng dụng chạy lệnh
--     SET app.current_user_id = '<user_id người đăng nhập>';      -- (hoặc SET LOCAL trong giao dịch)
-- Khi INSERT mà created_by_user_id còn NULL, trigger điền giá trị từ biến phiên đó. Nếu biến chưa
-- được đặt thì cột giữ NULL (cột cho phép NULL để dữ liệu cũ / tác vụ hệ thống như cron vẫn hợp lệ).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_fill_created_by()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.created_by_user_id IS NULL THEN
        NEW.created_by_user_id := NULLIF(current_setting('app.current_user_id', TRUE), '')::INT;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_fill_created_by ON member_subscription;
CREATE TRIGGER trg_fill_created_by BEFORE INSERT ON member_subscription
FOR EACH ROW EXECUTE FUNCTION trg_fn_fill_created_by();

DROP TRIGGER IF EXISTS trg_fill_created_by ON billing_log;
CREATE TRIGGER trg_fill_created_by BEFORE INSERT ON billing_log
FOR EACH ROW EXECUTE FUNCTION trg_fn_fill_created_by();

DROP TRIGGER IF EXISTS trg_fill_created_by ON class_schedule;
CREATE TRIGGER trg_fill_created_by BEFORE INSERT ON class_schedule
FOR EACH ROW EXECUTE FUNCTION trg_fn_fill_created_by();

DROP TRIGGER IF EXISTS trg_fill_created_by ON pt_booking;
CREATE TRIGGER trg_fill_created_by BEFORE INSERT ON pt_booking
FOR EACH ROW EXECUTE FUNCTION trg_fn_fill_created_by();

DROP TRIGGER IF EXISTS trg_fill_created_by ON maintenance_log;
CREATE TRIGGER trg_fill_created_by BEFORE INSERT ON maintenance_log
FOR EACH ROW EXECUTE FUNCTION trg_fn_fill_created_by();


-- ----------------------------------------------------------------------------
-- TRIGGER 4: trg_fill_billing_period_start (BR-08)
-- Nghiệp vụ: nếu INSERT hóa đơn không nêu chu kỳ tính phí, mặc định là ngày bắt đầu hợp đồng
-- (hóa đơn chu kỳ đầu tiên). Nhờ vậy câu INSERT cũ của ứng dụng vẫn chạy; hóa đơn gia hạn do
-- sp_process_subscription_renewals phát hành luôn nêu rõ chu kỳ. Trùng chu kỳ bị chặn bởi chỉ mục
-- uq_billing_subscription_period (01_schema_ddl.sql).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_fill_billing_period_start()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.billing_period_start IS NULL THEN
        SELECT ms.start_time::DATE
        INTO NEW.billing_period_start
        FROM member_subscription AS ms
        WHERE ms.subscription_id = NEW.subscription_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_fill_billing_period_start ON billing_log;
CREATE TRIGGER trg_fill_billing_period_start
BEFORE INSERT ON billing_log
FOR EACH ROW
EXECUTE FUNCTION trg_fn_fill_billing_period_start();


-- ----------------------------------------------------------------------------
-- TRIGGER 5: trg_billing_immutable_* (BR-10) - Hóa đơn bất biến, áp dụng cả cho chủ sở hữu/superuser
-- Nghiệp vụ:
--   * DELETE: luôn bị chặn.   * TRUNCATE: luôn bị chặn.
--   * UPDATE hóa đơn 'Completed': chỉ được đổi payment_status sang 'Refunded', mọi cột khác giữ nguyên.
--   * UPDATE hóa đơn 'Pending': được chuyển sang 'Completed'/'Failed' (và chỉnh amount, payment_date,
--     payment_method khi ghi nhận thanh toán); billing_id, subscription_id, billing_period_start,
--     invoice_no, created_at, created_by_user_id không đổi.
--   * Hóa đơn 'Failed'/'Refunded' là trạng thái cuối: không được sửa.
-- Muốn sửa dữ liệu hóa đơn, phải DISABLE TRIGGER có chủ đích (thao tác DDL của chủ sở hữu, để lại dấu vết).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_billing_immutable_update()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.* IS NOT DISTINCT FROM OLD.* THEN
        RETURN NEW;
    END IF;

    IF OLD.payment_status = 'Completed' THEN
        IF NEW.payment_status = 'Refunded'
           AND (NEW.billing_id, NEW.subscription_id, NEW.billing_period_start, NEW.invoice_no, NEW.amount,
                NEW.payment_date, NEW.payment_method, NEW.created_at, NEW.created_by_user_id)
               IS NOT DISTINCT FROM
               (OLD.billing_id, OLD.subscription_id, OLD.billing_period_start, OLD.invoice_no, OLD.amount,
                OLD.payment_date, OLD.payment_method, OLD.created_at, OLD.created_by_user_id) THEN
            RETURN NEW;
        END IF;
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-10: Hóa đơn % đã Completed là dữ liệu bất biến; chỉ được chuyển sang Refunded và không được đổi cột nào khác',
            OLD.invoice_no;
    ELSIF OLD.payment_status = 'Pending' THEN
        IF NEW.payment_status IN ('Pending', 'Completed', 'Failed')
           AND (NEW.billing_id, NEW.subscription_id, NEW.billing_period_start, NEW.invoice_no,
                NEW.created_at, NEW.created_by_user_id)
               IS NOT DISTINCT FROM
               (OLD.billing_id, OLD.subscription_id, OLD.billing_period_start, OLD.invoice_no,
                OLD.created_at, OLD.created_by_user_id) THEN
            RETURN NEW;
        END IF;
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-10: Hóa đơn % đang Pending chỉ được chuyển sang Completed/Failed và không được đổi mã hóa đơn, hợp đồng, chu kỳ',
            OLD.invoice_no;
    END IF;

    RAISE EXCEPTION 'Lỗi nghiệp vụ BR-10: Hóa đơn % ở trạng thái cuối (%) không được phép sửa đổi',
        OLD.invoice_no, OLD.payment_status;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_fn_billing_immutable_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Lỗi nghiệp vụ BR-10: Không được xóa hóa đơn % (nhật ký thanh toán bất biến); hãy chuyển sang Refunded nếu cần hoàn tiền',
        OLD.invoice_no;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION trg_fn_billing_immutable_truncate()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Lỗi nghiệp vụ BR-10: Không được TRUNCATE bảng billing_log (nhật ký thanh toán bất biến)';
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_billing_immutable_update ON billing_log;
CREATE TRIGGER trg_billing_immutable_update
BEFORE UPDATE ON billing_log
FOR EACH ROW
EXECUTE FUNCTION trg_fn_billing_immutable_update();

DROP TRIGGER IF EXISTS trg_billing_immutable_delete ON billing_log;
CREATE TRIGGER trg_billing_immutable_delete
BEFORE DELETE ON billing_log
FOR EACH ROW
EXECUTE FUNCTION trg_fn_billing_immutable_delete();

DROP TRIGGER IF EXISTS trg_billing_immutable_truncate ON billing_log;
CREATE TRIGGER trg_billing_immutable_truncate
BEFORE TRUNCATE ON billing_log
FOR EACH STATEMENT
EXECUTE FUNCTION trg_fn_billing_immutable_truncate();


-- ----------------------------------------------------------------------------
-- TRIGGER 6: trg_require_payment_before_active (BR-07)
-- Nghiệp vụ: hợp đồng chỉ được INSERT/UPDATE sang sub_status = 'Active' khi đã có ít nhất một hóa đơn
-- 'Completed' của chính hợp đồng đó. Luồng đúng: tạo hợp đồng 'Pending' -> ghi hóa đơn 'Completed'
-- -> trigger 7 (bên dưới) tự chuyển hợp đồng sang 'Active'.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_require_payment_before_active()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.sub_status = 'Active'
       AND (TG_OP = 'INSERT' OR OLD.sub_status IS DISTINCT FROM 'Active') THEN
        IF NOT EXISTS (
            SELECT 1
            FROM billing_log
            WHERE subscription_id = NEW.subscription_id
              AND payment_status = 'Completed'
        ) THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ BR-07: Hợp đồng ID: % chưa có hóa đơn thanh toán Completed nên chưa thể chuyển sang Active',
                NEW.subscription_id;
        END IF;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_require_payment_before_active ON member_subscription;
CREATE TRIGGER trg_require_payment_before_active
BEFORE INSERT OR UPDATE OF sub_status ON member_subscription
FOR EACH ROW
WHEN (NEW.sub_status = 'Active')
EXECUTE FUNCTION trg_fn_require_payment_before_active();


-- ----------------------------------------------------------------------------
-- TRIGGER 7: trg_activate_on_payment_insert / trg_activate_on_payment_update (BR-07, BR-24)
-- Nghiệp vụ: khi một hóa đơn trở thành 'Completed':
--   (a) hợp đồng đang 'Pending'  -> tự chuyển 'Active' (kích hoạt sau thanh toán);
--   (b) hóa đơn là hóa đơn GIA HẠN (hợp đồng tự gia hạn, chu kỳ tính phí bắt đầu từ ngày hết hạn
--       hiện tại trở đi) -> cộng thêm duration_days của gói vào end_time, đặt lại remaining_sessions
--       bằng total_sessions của gói và đưa hợp đồng (đang Active hoặc Suspended) về 'Active'.
-- Nếu hội viên đang có hợp đồng Active khác, UPDATE sang Active vi phạm uq_member_one_active_subscription
-- (BR-05) và toàn bộ lệnh ghi hóa đơn bị hủy.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_activate_on_payment()
RETURNS TRIGGER AS $$
DECLARE
    v_sub  member_subscription%ROWTYPE;
    v_days INT;
    v_sessions INT;
BEGIN
    SELECT ms.*
    INTO v_sub
    FROM member_subscription AS ms
    WHERE ms.subscription_id = NEW.subscription_id
    FOR UPDATE;

    IF NOT FOUND THEN
        RETURN NULL;
    END IF;

    IF v_sub.sub_status = 'Pending' THEN
        UPDATE member_subscription
        SET sub_status = 'Active'
        WHERE subscription_id = v_sub.subscription_id;

        RAISE NOTICE 'BR-07: Hợp đồng ID: % đã thanh toán (hóa đơn %) nên tự động chuyển Pending -> Active',
            v_sub.subscription_id, NEW.invoice_no;

    ELSIF v_sub.is_recurring
          AND v_sub.sub_status IN ('Active', 'Suspended')
          AND NEW.billing_period_start > v_sub.start_time::DATE
          AND NEW.billing_period_start >= v_sub.end_time::DATE THEN
        SELECT mp.duration_days, mp.total_sessions
        INTO v_days, v_sessions
        FROM membership_plan AS mp
        WHERE mp.plan_id = v_sub.plan_id;

        UPDATE member_subscription
        SET end_time           = end_time + (v_days * INTERVAL '1 day'),
            remaining_sessions = v_sessions,
            sub_status         = 'Active'
        WHERE subscription_id = v_sub.subscription_id;

        RAISE NOTICE 'BR-24: Hợp đồng ID: % được gia hạn thêm % ngày sau khi hóa đơn % thanh toán',
            v_sub.subscription_id, v_days, NEW.invoice_no;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_activate_on_payment_insert ON billing_log;
CREATE TRIGGER trg_activate_on_payment_insert
AFTER INSERT ON billing_log
FOR EACH ROW
WHEN (NEW.payment_status = 'Completed')
EXECUTE FUNCTION trg_fn_activate_on_payment();

DROP TRIGGER IF EXISTS trg_activate_on_payment_update ON billing_log;
CREATE TRIGGER trg_activate_on_payment_update
AFTER UPDATE OF payment_status ON billing_log
FOR EACH ROW
WHEN (NEW.payment_status = 'Completed' AND OLD.payment_status IS DISTINCT FROM 'Completed')
EXECUTE FUNCTION trg_fn_activate_on_payment();


-- ----------------------------------------------------------------------------
-- TRIGGER 8: trg_check_pt_booking_creation (BR-18 lúc TẠO ca PT)
-- Nghiệp vụ: ca PT (chưa hủy) chỉ được tạo khi hợp đồng đang 'Active' và giờ bắt đầu nằm trong
-- [start_time, end_time] của hợp đồng; riêng ca 'Scheduled' còn yêu cầu số buổi còn lại phải LỚN HƠN
-- số ca 'Scheduled' đã đặt (mỗi ca đang chờ sẽ tiêu thụ 1 buổi khi hoàn thành). Khóa tư vấn theo hợp
-- đồng để 2 lễ tân đặt đồng thời không cùng giành buổi cuối cùng.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_check_pt_booking_creation()
RETURNS TRIGGER AS $$
DECLARE
    v_sub_status VARCHAR(20);
    v_start      TIMESTAMP;
    v_end        TIMESTAMP;
    v_remaining  INT;
    v_scheduled  INT;
BEGIN
    IF NEW.status IN ('Cancelled', 'Late_Cancelled') THEN
        RETURN NEW;
    END IF;

    PERFORM pg_advisory_xact_lock(3, NEW.subscription_id);

    SELECT sub_status, start_time, end_time, remaining_sessions
    INTO v_sub_status, v_start, v_end, v_remaining
    FROM member_subscription
    WHERE subscription_id = NEW.subscription_id;

    IF NOT FOUND THEN
        RETURN NEW; -- để khóa ngoại fk_booking_subscription báo lỗi chuẩn
    END IF;

    IF v_sub_status <> 'Active' THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Hợp đồng ID: % đang ở trạng thái % (không phải Active) nên không thể đặt ca PT',
            NEW.subscription_id, v_sub_status;
    END IF;

    IF NEW.start_time < v_start OR NEW.start_time > v_end THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Giờ tập % nằm ngoài thời hạn hợp đồng ID: % (% -> %)',
            NEW.start_time, NEW.subscription_id, v_start, v_end;
    END IF;

    IF NEW.status = 'Scheduled' THEN
        SELECT COUNT(*)
        INTO v_scheduled
        FROM pt_booking
        WHERE subscription_id = NEW.subscription_id
          AND status = 'Scheduled';

        IF v_remaining <= v_scheduled THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Hợp đồng ID: % còn % buổi PT nhưng đã có % ca đang chờ; không thể đặt thêm',
                NEW.subscription_id, v_remaining, v_scheduled;
        END IF;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_pt_booking_creation ON pt_booking;
CREATE TRIGGER trg_check_pt_booking_creation
BEFORE INSERT ON pt_booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_check_pt_booking_creation();


-- ----------------------------------------------------------------------------
-- TRIGGER 9: trg_late_cancel_pt_booking (BR-25)
-- Nghiệp vụ: buổi tập chỉ bị trừ khi hoàn thành (không trừ lúc đặt) nên hủy sớm không cần hoàn buổi.
-- Hủy ca 'Scheduled' khi còn < 24 giờ tới giờ bắt đầu bị trigger đổi thành 'Late_Cancelled'
-- (trigger 1 sẽ trừ 1 buổi); hủy trước đó giữ 'Cancelled' (không trừ).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_late_cancel_pt_booking()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'Cancelled' AND OLD.status = 'Scheduled'
       AND NEW.start_time < CURRENT_TIMESTAMP::TIMESTAMP + INTERVAL '24 hours' THEN
        NEW.status := 'Late_Cancelled';
        RAISE NOTICE 'BR-25: Ca PT #% hủy khi còn dưới 24 giờ tới giờ tập nên được ghi nhận Late_Cancelled (trừ 1 buổi)',
            NEW.booking_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_late_cancel_pt_booking ON pt_booking;
CREATE TRIGGER trg_late_cancel_pt_booking
BEFORE UPDATE OF status ON pt_booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_late_cancel_pt_booking();


-- ----------------------------------------------------------------------------
-- TRIGGER 10: trg_check_class_schedule_conflicts (BR-12, BR-16)
-- Nghiệp vụ (xuyên bảng, bổ sung cho EXCLUDE ex_class_trainer_no_overlap trong cùng bảng):
--   (a) BR-12: HLV không được có lớp nhóm trùng giờ với ca PT chưa hủy của chính mình;
--   (b) BR-16: khi ĐỔI giờ một lớp đã có người đăng ký, không hội viên nào đang đăng ký lớp đó được
--       trùng với ca PT hoặc lớp khác của chính họ.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_check_class_schedule_conflicts()
RETURNS TRIGGER AS $$
DECLARE
    v_conflict_id INT;
    v_member_id   INT;
BEGIN
    PERFORM pg_advisory_xact_lock(1, NEW.trainer_user_id);

    SELECT pb.booking_id
    INTO v_conflict_id
    FROM pt_booking AS pb
    WHERE pb.trainer_user_id = NEW.trainer_user_id
      AND pb.status NOT IN ('Cancelled', 'Late_Cancelled')
      AND tsrange(pb.start_time, pb.end_time, '[)') && tsrange(NEW.start_time, NEW.end_time, '[)')
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-12: HLV ID: % đã có ca PT #% trùng khung giờ % -> % của lớp "%"',
            NEW.trainer_user_id, v_conflict_id, NEW.start_time, NEW.end_time, NEW.class_name
            USING ERRCODE = 'exclusion_violation';
    END IF;

    IF TG_OP = 'UPDATE' AND (OLD.start_time, OLD.end_time) IS DISTINCT FROM (NEW.start_time, NEW.end_time) THEN
        FOR v_member_id IN
            SELECT DISTINCT ms.member_user_id
            FROM class_enrollment AS ce
            JOIN member_subscription AS ms ON ms.subscription_id = ce.subscription_id
            WHERE ce.class_id = NEW.class_id
              AND ce.status IN ('Enrolled', 'Attended')
            ORDER BY ms.member_user_id
        LOOP
            PERFORM pg_advisory_xact_lock(2, v_member_id);

            IF EXISTS (
                SELECT 1
                FROM pt_booking AS pb
                WHERE pb.member_user_id = v_member_id
                  AND pb.status NOT IN ('Cancelled', 'Late_Cancelled')
                  AND tsrange(pb.start_time, pb.end_time, '[)') && tsrange(NEW.start_time, NEW.end_time, '[)')
            ) OR EXISTS (
                SELECT 1
                FROM class_enrollment AS ce2
                JOIN member_subscription AS ms2 ON ms2.subscription_id = ce2.subscription_id
                JOIN class_schedule AS cs2 ON cs2.class_id = ce2.class_id
                WHERE ms2.member_user_id = v_member_id
                  AND ce2.status IN ('Enrolled', 'Attended')
                  AND cs2.class_id <> NEW.class_id
                  AND tsrange(cs2.start_time, cs2.end_time, '[)') && tsrange(NEW.start_time, NEW.end_time, '[)')
            ) THEN
                RAISE EXCEPTION 'Lỗi nghiệp vụ BR-16: Đổi giờ lớp ID: % làm hội viên ID: % bị trùng lịch với ca PT/lớp khác của họ',
                    NEW.class_id, v_member_id
                    USING ERRCODE = 'exclusion_violation';
            END IF;
        END LOOP;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_class_schedule_conflicts ON class_schedule;
CREATE TRIGGER trg_check_class_schedule_conflicts
BEFORE INSERT OR UPDATE OF trainer_user_id, start_time, end_time ON class_schedule
FOR EACH ROW
EXECUTE FUNCTION trg_fn_check_class_schedule_conflicts();


-- ----------------------------------------------------------------------------
-- TRIGGER 11: trg_check_pt_booking_conflicts (BR-12, BR-16)
-- Nghiệp vụ (xuyên bảng): ca PT chưa hủy không được trùng giờ với
--   (a) lớp nhóm mà chính HLV đó đứng lớp (BR-12);
--   (b) lớp nhóm mà hội viên đang đăng ký (Enrolled/Attended) (BR-16).
-- Trùng giữa 2 ca PT với nhau đã do EXCLUDE ex_pt_trainer_no_overlap / ex_pt_member_no_overlap chặn.
-- Chỉ kiểm tra lại khi đổi HLV/hội viên/giờ hoặc khi "sống lại" từ trạng thái đã hủy.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_check_pt_booking_conflicts()
RETURNS TRIGGER AS $$
DECLARE
    v_conflict_id INT;
BEGIN
    IF NEW.status IN ('Cancelled', 'Late_Cancelled') THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE'
       AND OLD.status NOT IN ('Cancelled', 'Late_Cancelled')
       AND (OLD.trainer_user_id, OLD.member_user_id, OLD.start_time, OLD.end_time)
           IS NOT DISTINCT FROM
           (NEW.trainer_user_id, NEW.member_user_id, NEW.start_time, NEW.end_time) THEN
        RETURN NEW;
    END IF;

    PERFORM pg_advisory_xact_lock(1, NEW.trainer_user_id);
    PERFORM pg_advisory_xact_lock(2, NEW.member_user_id);

    SELECT cs.class_id
    INTO v_conflict_id
    FROM class_schedule AS cs
    WHERE cs.trainer_user_id = NEW.trainer_user_id
      AND tsrange(cs.start_time, cs.end_time, '[)') && tsrange(NEW.start_time, NEW.end_time, '[)')
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-12: HLV ID: % đã đứng lớp ID: % trùng khung giờ % -> % của ca PT',
            NEW.trainer_user_id, v_conflict_id, NEW.start_time, NEW.end_time
            USING ERRCODE = 'exclusion_violation';
    END IF;

    SELECT cs.class_id
    INTO v_conflict_id
    FROM class_enrollment AS ce
    JOIN member_subscription AS ms ON ms.subscription_id = ce.subscription_id
    JOIN class_schedule AS cs ON cs.class_id = ce.class_id
    WHERE ms.member_user_id = NEW.member_user_id
      AND ce.status IN ('Enrolled', 'Attended')
      AND tsrange(cs.start_time, cs.end_time, '[)') && tsrange(NEW.start_time, NEW.end_time, '[)')
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-16: Hội viên ID: % đã đăng ký lớp ID: % trùng khung giờ % -> % của ca PT',
            NEW.member_user_id, v_conflict_id, NEW.start_time, NEW.end_time
            USING ERRCODE = 'exclusion_violation';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_pt_booking_conflicts ON pt_booking;
CREATE TRIGGER trg_check_pt_booking_conflicts
BEFORE INSERT OR UPDATE OF trainer_user_id, member_user_id, start_time, end_time, status ON pt_booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_check_pt_booking_conflicts();


-- ----------------------------------------------------------------------------
-- TRIGGER 12: trg_check_class_enrollment_conflicts (BR-16)
-- Nghiệp vụ: hội viên (xác định qua hợp đồng) không được đăng ký (Enrolled/Attended) một lớp trùng giờ
-- với ca PT chưa hủy hoặc với một đăng ký lớp khác của chính mình - kể cả khi dùng 2 hợp đồng khác nhau.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_check_class_enrollment_conflicts()
RETURNS TRIGGER AS $$
DECLARE
    v_member_id   INT;
    v_start       TIMESTAMP;
    v_end         TIMESTAMP;
    v_conflict_id INT;
BEGIN
    IF NEW.status NOT IN ('Enrolled', 'Attended') THEN
        RETURN NEW;
    END IF;

    IF TG_OP = 'UPDATE'
       AND OLD.status IN ('Enrolled', 'Attended')
       AND OLD.class_id = NEW.class_id
       AND OLD.subscription_id = NEW.subscription_id THEN
        RETURN NEW; -- chỉ chuyển Enrolled <-> Attended (điểm danh), không đổi lịch
    END IF;

    SELECT ms.member_user_id
    INTO v_member_id
    FROM member_subscription AS ms
    WHERE ms.subscription_id = NEW.subscription_id;

    SELECT cs.start_time, cs.end_time
    INTO v_start, v_end
    FROM class_schedule AS cs
    WHERE cs.class_id = NEW.class_id;

    IF v_member_id IS NULL OR v_start IS NULL THEN
        RETURN NEW; -- để khóa ngoại báo lỗi chuẩn
    END IF;

    PERFORM pg_advisory_xact_lock(2, v_member_id);

    SELECT pb.booking_id
    INTO v_conflict_id
    FROM pt_booking AS pb
    WHERE pb.member_user_id = v_member_id
      AND pb.status NOT IN ('Cancelled', 'Late_Cancelled')
      AND tsrange(pb.start_time, pb.end_time, '[)') && tsrange(v_start, v_end, '[)');

    IF FOUND THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-16: Hội viên ID: % đã có ca PT #% trùng khung giờ lớp ID: % (% -> %)',
            v_member_id, v_conflict_id, NEW.class_id, v_start, v_end
            USING ERRCODE = 'exclusion_violation';
    END IF;

    SELECT cs.class_id
    INTO v_conflict_id
    FROM class_enrollment AS ce
    JOIN member_subscription AS ms ON ms.subscription_id = ce.subscription_id
    JOIN class_schedule AS cs ON cs.class_id = ce.class_id
    WHERE ms.member_user_id = v_member_id
      AND ce.status IN ('Enrolled', 'Attended')
      AND ce.enrollment_id <> NEW.enrollment_id
      AND tsrange(cs.start_time, cs.end_time, '[)') && tsrange(v_start, v_end, '[)')
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-16: Hội viên ID: % đã đăng ký lớp ID: % trùng khung giờ lớp ID: % (% -> %)',
            v_member_id, v_conflict_id, NEW.class_id, v_start, v_end
            USING ERRCODE = 'exclusion_violation';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_class_enrollment_conflicts ON class_enrollment;
CREATE TRIGGER trg_check_class_enrollment_conflicts
BEFORE INSERT OR UPDATE OF subscription_id, class_id, status ON class_enrollment
FOR EACH ROW
EXECUTE FUNCTION trg_fn_check_class_enrollment_conflicts();


-- ----------------------------------------------------------------------------
-- TRIGGER 13: trg_check_reservation_window (BR-21)
-- Nghiệp vụ (bổ sung cho EXCLUDE ex_reservation_equipment_no_overlap chặn 1 thiết bị bị giữ trùng giờ):
--   (a) lượt giữ chỗ chưa hủy không được chồng lấn cửa sổ bảo trì 'In_Progress' của thiết bị đó
--       [start_time, COALESCE(end_time, 'infinity')) - ca bảo trì chưa có end_time coi như kéo dài vô hạn;
--   (b) lượt giữ chỗ phải nằm trọn trong khung giờ của ca PT hoặc lớp học mà nó gắn vào.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION trg_fn_check_reservation_window()
RETURNS TRIGGER AS $$
DECLARE
    v_maintenance_id INT;
    v_parent_start   TIMESTAMP;
    v_parent_end     TIMESTAMP;
BEGIN
    IF NEW.status = 'Cancelled' THEN
        RETURN NEW;
    END IF;

    SELECT ml.maintenance_id
    INTO v_maintenance_id
    FROM maintenance_log AS ml
    WHERE ml.equipment_id = NEW.equipment_id
      AND ml.status = 'In_Progress'
      AND tsrange(ml.start_time, COALESCE(ml.end_time, 'infinity'::TIMESTAMP), '[)')
          && tsrange(NEW.start_time, NEW.end_time, '[)')
    LIMIT 1;

    IF FOUND THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-21: Thiết bị ID: % đang trong ca bảo trì #% (In_Progress) trùng khung giờ giữ chỗ % -> %',
            NEW.equipment_id, v_maintenance_id, NEW.start_time, NEW.end_time
            USING ERRCODE = 'exclusion_violation';
    END IF;

    IF NEW.booking_id IS NOT NULL THEN
        SELECT pb.start_time, pb.end_time INTO v_parent_start, v_parent_end
        FROM pt_booking AS pb
        WHERE pb.booking_id = NEW.booking_id;
    ELSE
        SELECT cs.start_time, cs.end_time INTO v_parent_start, v_parent_end
        FROM class_schedule AS cs
        WHERE cs.class_id = NEW.class_id;
    END IF;

    IF v_parent_start IS NOT NULL
       AND (NEW.start_time < v_parent_start OR NEW.end_time > v_parent_end) THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-21: Giờ giữ chỗ thiết bị % -> % vượt ra ngoài khung giờ của ca/lớp gắn kèm (% -> %)',
            NEW.start_time, NEW.end_time, v_parent_start, v_parent_end;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_check_reservation_window ON equipment_reservation;
CREATE TRIGGER trg_check_reservation_window
BEFORE INSERT OR UPDATE OF equipment_id, booking_id, class_id, start_time, end_time, status ON equipment_reservation
FOR EACH ROW
EXECUTE FUNCTION trg_fn_check_reservation_window();


-- ----------------------------------------------------------------------------
-- THỦ TỤC: sp_process_subscription_renewals (BR-24) - Tự động gia hạn & ân hạn
-- PostgreSQL KHÔNG có bộ lập lịch tích hợp, nên quy tắc theo thời gian được cài thành một thủ tục
-- để cron hoặc pg_cron gọi MỖI NGÀY, ví dụ:
--     CALL sp_process_subscription_renewals();                       -- crontab: psql -c "CALL ..."
--     SELECT cron.schedule('gym-renewals', '5 0 * * *', 'CALL sp_process_subscription_renewals()');
-- Tham số: p_as_of = ngày xét (mặc định hôm nay; truyền ngày giả để kiểm thử), p_grace_days = số ngày
-- ân hạn (mặc định 3). Một hợp đồng được coi là "quá hạn" khi end_time < 00:00 của p_as_of.
-- Các bước (đều idempotent - gọi lại nhiều lần trong ngày không phát sinh thêm):
--   1. Hợp đồng Active KHÔNG tự gia hạn, quá hạn                 -> 'Expired'.
--   2. Hợp đồng Active tự gia hạn (is_recurring), quá hạn        -> phát hành 1 hóa đơn 'Pending' cho chu kỳ
--      kế tiếp (billing_period_start = ngày end_time cũ, amount = actual_price) nếu chưa có.
--   3. Hợp đồng Active tự gia hạn mà quá end_time + p_grace_days ngày vẫn chưa thanh toán -> 'Suspended'.
--   Khi hóa đơn gia hạn được thanh toán (Completed) trigger trg_activate_on_payment_* gia hạn end_time
--   thêm duration_days của gói, đặt lại remaining_sessions và kích hoạt lại hợp đồng.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE sp_process_subscription_renewals(
    p_as_of      DATE DEFAULT CURRENT_DATE,
    p_grace_days INT  DEFAULT 3
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff    TIMESTAMP := p_as_of::TIMESTAMP;
    v_expired   INT;
    v_invoiced  INT;
    v_suspended INT;
BEGIN
    IF p_grace_days < 0 THEN
        RAISE EXCEPTION 'p_grace_days phải >= 0 (nhận được: %)', p_grace_days;
    END IF;

    -- Bước 1: hợp đồng không tự gia hạn hết hạn
    UPDATE member_subscription
    SET sub_status = 'Expired'
    WHERE sub_status = 'Active'
      AND NOT is_recurring
      AND end_time < v_cutoff;
    GET DIAGNOSTICS v_expired = ROW_COUNT;

    -- Bước 2: phát hành hóa đơn gia hạn Pending cho chu kỳ kế tiếp (chưa có hóa đơn Pending/Completed)
    INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount,
                             payment_date, payment_method, payment_status)
    SELECT
        ms.subscription_id,
        ms.end_time::DATE,
        'INV-RNW-' || ms.subscription_id || '-' || TO_CHAR(ms.end_time, 'YYYYMMDD') || '-' || (
            SELECT COUNT(*) + 1
            FROM billing_log AS b2
            WHERE b2.subscription_id = ms.subscription_id
              AND b2.billing_period_start = ms.end_time::DATE
        ),
        ms.actual_price,
        p_as_of,
        COALESCE((
            SELECT b3.payment_method
            FROM billing_log AS b3
            WHERE b3.subscription_id = ms.subscription_id
              AND b3.payment_status = 'Completed'
            ORDER BY b3.payment_date DESC, b3.billing_id DESC
            LIMIT 1
        ), 'Banking'),
        'Pending'
    FROM member_subscription AS ms
    WHERE ms.sub_status = 'Active'
      AND ms.is_recurring
      AND ms.actual_price > 0
      AND ms.end_time < v_cutoff
      AND NOT EXISTS (
          SELECT 1
          FROM billing_log AS b
          WHERE b.subscription_id = ms.subscription_id
            AND b.billing_period_start = ms.end_time::DATE
            AND b.payment_status IN ('Pending', 'Completed')
      );
    GET DIAGNOSTICS v_invoiced = ROW_COUNT;

    -- Bước 3: hết thời gian ân hạn mà chưa thanh toán -> tạm ngưng
    UPDATE member_subscription
    SET sub_status = 'Suspended'
    WHERE sub_status = 'Active'
      AND is_recurring
      AND end_time + make_interval(days => p_grace_days) < v_cutoff;
    GET DIAGNOSTICS v_suspended = ROW_COUNT;

    RAISE NOTICE 'BR-24 (ngày xét %, ân hạn % ngày): % hợp đồng Expired, % hóa đơn gia hạn mới, % hợp đồng Suspended',
        p_as_of, p_grace_days, v_expired, v_invoiced, v_suspended;
END;
$$;


-- ============================================================================
-- PHẦN 4: KIỂM TOÁN DỮ LIỆU MẪU THEO CÁC QUY TẮC MỚI (DATA AUDIT)
-- ============================================================================
-- Tập tin này chạy SAU dữ liệu mẫu nên dữ liệu mẫu được nạp khi chưa có trigger. Khối DO dưới đây
-- kiểm tra lại từng quy tắc trên dữ liệu hiện có và RAISE EXCEPTION nếu còn dòng nào vi phạm,
-- bảo đảm dữ liệu mẫu tuân thủ đầy đủ các quy tắc (BR-23 cho phép NULL nên không có điều kiện kiểm toán).
DO $$
DECLARE
    v_violations TEXT[] := ARRAY[]::TEXT[];
    v_count      INT;
BEGIN
    -- BR-05: mỗi hội viên tối đa 1 hợp đồng Active
    SELECT COUNT(*) INTO v_count FROM (
        SELECT member_user_id FROM member_subscription WHERE sub_status = 'Active'
        GROUP BY member_user_id HAVING COUNT(*) > 1) AS t;
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-05: %s hội viên có nhiều hợp đồng Active', v_count); END IF;

    -- BR-07: hợp đồng Active phải có hóa đơn Completed
    SELECT COUNT(*) INTO v_count FROM member_subscription AS ms
    WHERE ms.sub_status = 'Active'
      AND NOT EXISTS (SELECT 1 FROM billing_log AS b WHERE b.subscription_id = ms.subscription_id AND b.payment_status = 'Completed');
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-07: %s hợp đồng Active chưa có hóa đơn Completed', v_count); END IF;

    -- BR-08: mỗi chu kỳ chỉ có 1 hóa đơn Pending/Completed
    SELECT COUNT(*) INTO v_count FROM (
        SELECT 1 FROM billing_log WHERE payment_status IN ('Pending', 'Completed')
        GROUP BY subscription_id, billing_period_start HAVING COUNT(*) > 1) AS t;
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-08: %s chu kỳ có nhiều hơn 1 hóa đơn', v_count); END IF;

    -- BR-12: HLV không có lớp nhóm trùng ca PT chưa hủy
    SELECT COUNT(*) INTO v_count
    FROM class_schedule AS cs
    JOIN pt_booking AS pb ON pb.trainer_user_id = cs.trainer_user_id
     AND pb.status NOT IN ('Cancelled', 'Late_Cancelled')
     AND tsrange(pb.start_time, pb.end_time, '[)') && tsrange(cs.start_time, cs.end_time, '[)');
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-12: %s cặp lớp/ca PT của HLV bị trùng giờ', v_count); END IF;

    -- BR-16: hội viên không có ca PT trùng lớp đã đăng ký, và không có 2 đăng ký lớp trùng giờ
    SELECT COUNT(*) INTO v_count
    FROM pt_booking AS pb
    JOIN member_subscription AS ms ON ms.member_user_id = pb.member_user_id
    JOIN class_enrollment AS ce ON ce.subscription_id = ms.subscription_id AND ce.status IN ('Enrolled', 'Attended')
    JOIN class_schedule AS cs ON cs.class_id = ce.class_id
    WHERE pb.status NOT IN ('Cancelled', 'Late_Cancelled')
      AND tsrange(pb.start_time, pb.end_time, '[)') && tsrange(cs.start_time, cs.end_time, '[)');
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-16: %s cặp ca PT/lớp của hội viên bị trùng giờ', v_count); END IF;

    SELECT COUNT(*) INTO v_count
    FROM class_enrollment AS ce1
    JOIN member_subscription AS ms1 ON ms1.subscription_id = ce1.subscription_id
    JOIN class_schedule AS cs1 ON cs1.class_id = ce1.class_id
    JOIN member_subscription AS ms2 ON ms2.member_user_id = ms1.member_user_id
    JOIN class_enrollment AS ce2 ON ce2.subscription_id = ms2.subscription_id AND ce2.enrollment_id > ce1.enrollment_id
    JOIN class_schedule AS cs2 ON cs2.class_id = ce2.class_id
    WHERE ce1.status IN ('Enrolled', 'Attended') AND ce2.status IN ('Enrolled', 'Attended')
      AND tsrange(cs1.start_time, cs1.end_time, '[)') && tsrange(cs2.start_time, cs2.end_time, '[)');
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-16: %s cặp đăng ký lớp của hội viên bị trùng giờ', v_count); END IF;

    -- BR-18: ca PT chưa hủy thuộc hợp đồng Active, giờ tập trong hạn hợp đồng; số ca Scheduled <= số buổi còn lại
    SELECT COUNT(*) INTO v_count
    FROM pt_booking AS pb
    JOIN member_subscription AS ms ON ms.subscription_id = pb.subscription_id
    WHERE pb.status NOT IN ('Cancelled', 'Late_Cancelled')
      AND (ms.sub_status <> 'Active' OR pb.start_time < ms.start_time OR pb.start_time > ms.end_time);
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-18: %s ca PT thuộc hợp đồng không Active hoặc ngoài thời hạn', v_count); END IF;

    SELECT COUNT(*) INTO v_count FROM (
        SELECT pb.subscription_id
        FROM pt_booking AS pb
        JOIN member_subscription AS ms ON ms.subscription_id = pb.subscription_id
        WHERE pb.status = 'Scheduled'
        GROUP BY pb.subscription_id, ms.remaining_sessions
        HAVING COUNT(*) > ms.remaining_sessions) AS t;
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-18: %s hợp đồng có số ca Scheduled vượt số buổi còn lại', v_count); END IF;

    -- BR-21: giữ chỗ chưa hủy không chồng lấn ca bảo trì In_Progress và nằm trong khung giờ ca/lớp
    SELECT COUNT(*) INTO v_count
    FROM equipment_reservation AS er
    JOIN maintenance_log AS ml ON ml.equipment_id = er.equipment_id AND ml.status = 'In_Progress'
    WHERE er.status <> 'Cancelled'
      AND tsrange(ml.start_time, COALESCE(ml.end_time, 'infinity'::TIMESTAMP), '[)') && tsrange(er.start_time, er.end_time, '[)');
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-21: %s lượt giữ chỗ trùng ca bảo trì đang sửa', v_count); END IF;

    SELECT COUNT(*) INTO v_count
    FROM equipment_reservation AS er
    LEFT JOIN pt_booking AS pb ON pb.booking_id = er.booking_id
    LEFT JOIN class_schedule AS cs ON cs.class_id = er.class_id
    WHERE er.status <> 'Cancelled'
      AND (er.start_time < COALESCE(pb.start_time, cs.start_time) OR er.end_time > COALESCE(pb.end_time, cs.end_time));
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-21: %s lượt giữ chỗ nằm ngoài khung giờ ca/lớp', v_count); END IF;

    -- BR-19: phòng/thiết bị đang bảo trì không còn lịch tương lai; thiết bị có ca In_Progress phải Under_Maintenance
    SELECT COUNT(*) INTO v_count
    FROM class_schedule AS cs
    JOIN facilities_room AS r ON r.room_id = cs.room_id
    WHERE r.status = 'Under_Maintenance' AND cs.start_time > CURRENT_TIMESTAMP;
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-19: %s lớp tương lai nằm trong phòng đang bảo trì', v_count); END IF;

    SELECT COUNT(*) INTO v_count
    FROM equipment_reservation AS er
    JOIN equipment AS e ON e.equipment_id = er.equipment_id
    WHERE e.status = 'Under_Maintenance' AND er.status = 'Reserved' AND er.start_time > CURRENT_TIMESTAMP;
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-19: %s lượt giữ chỗ tương lai của thiết bị đang bảo trì', v_count); END IF;

    SELECT COUNT(*) INTO v_count
    FROM equipment AS e
    WHERE e.status <> 'Under_Maintenance'
      AND EXISTS (SELECT 1 FROM maintenance_log AS ml WHERE ml.equipment_id = e.equipment_id AND ml.status = 'In_Progress');
    IF v_count > 0 THEN v_violations := v_violations || FORMAT('BR-19: %s thiết bị có ca In_Progress nhưng không ở trạng thái Under_Maintenance', v_count); END IF;

    IF array_length(v_violations, 1) > 0 THEN
        RAISE EXCEPTION 'KIỂM TOÁN DỮ LIỆU MẪU THẤT BẠI: %', array_to_string(v_violations, '; ');
    END IF;

    RAISE NOTICE 'Kiểm toán dữ liệu mẫu: tất cả quy tắc BR-05, 07, 08, 12, 16, 18, 19, 21 đều thỏa mãn';
END;
$$;
