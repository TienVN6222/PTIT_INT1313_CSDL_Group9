-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 01_schema_ddl.sql - KHỞI TẠO CẤU TRÚC LƯỢC ĐỒ QUAN HỆ (DDL)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- TIÊU CHUẨN: SQLStyle.guide (Simon Holywell) / ISO/IEC 11179 Metadata Registry
-- ============================================================================

-- Xóa các bảng cũ theo thứ tự phụ thuộc khóa ngoại nếu đã tồn tại
DROP TABLE IF EXISTS maintenance_log CASCADE;
DROP TABLE IF EXISTS equipment_reservation CASCADE;
DROP TABLE IF EXISTS equipment CASCADE;
DROP TABLE IF EXISTS pt_booking CASCADE;
DROP TABLE IF EXISTS class_enrollment CASCADE;
DROP TABLE IF EXISTS class_schedule CASCADE;
DROP TABLE IF EXISTS facilities_room CASCADE;
DROP TABLE IF EXISTS billing_log CASCADE;
DROP TABLE IF EXISTS member_subscription CASCADE;
DROP TABLE IF EXISTS membership_plan CASCADE;
DROP TABLE IF EXISTS staff_profile CASCADE;
DROP TABLE IF EXISTS trainer_profile CASCADE;
DROP TABLE IF EXISTS member_profile CASCADE;
DROP TABLE IF EXISTS role_permission CASCADE;
DROP TABLE IF EXISTS permission CASCADE;
DROP TABLE IF EXISTS user_role CASCADE;
DROP TABLE IF EXISTS role CASCADE;
DROP TABLE IF EXISTS user_account CASCADE;

-- ============================================================================
-- PHẦN 1: PHÂN HỆ XÁC THỰC & PHÂN QUYỀN TRUY CẬP (RBAC - BR-22)
-- ============================================================================

-- Bảng 1: user_account (Tài khoản người dùng toàn hệ thống - BR-01, BR-02, BR-03)
CREATE TABLE user_account (
    user_id           SERIAL,
    full_name         VARCHAR(100) NOT NULL,
    email             VARCHAR(100) NOT NULL,
    phone             VARCHAR(20)  NOT NULL,
    dob               DATE         NOT NULL,
    emergency_contact VARCHAR(100),
    password_hash     VARCHAR(255) NOT NULL,
    status            VARCHAR(20)  NOT NULL DEFAULT 'Active',
    created_at        TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_user_account PRIMARY KEY (user_id),
    CONSTRAINT uq_user_account_email UNIQUE (email),
    CONSTRAINT uq_user_account_phone UNIQUE (phone),
    CONSTRAINT chk_user_account_status CHECK (status IN ('Active', 'Inactive', 'Suspended'))
);

-- Ràng buộc BR-03: Độ tuổi hội viên khi đăng ký hồ sơ phải từ 12 tuổi trở lên
CREATE OR REPLACE FUNCTION trg_fn_check_user_age()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.dob > (CURRENT_DATE - INTERVAL '12 years') THEN
        RAISE EXCEPTION 'Lỗi nghiệp vụ BR-03: Người dùng phải đủ từ 12 tuổi trở lên (Ngày sinh cung cấp: %)', NEW.dob;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_user_dob
BEFORE INSERT OR UPDATE OF dob ON user_account
FOR EACH ROW
EXECUTE FUNCTION trg_fn_check_user_age();

-- Bảng 2: role (Danh mục các vai trò trong hệ thống - BR-22)
CREATE TABLE role (
    role_id     SERIAL,
    role_name   VARCHAR(50)  NOT NULL,
    description VARCHAR(255),
    CONSTRAINT pk_role PRIMARY KEY (role_id),
    CONSTRAINT uq_role_name UNIQUE (role_name)
);

-- Bảng 3: user_role (Bảng trung gian phân vai trò người dùng M:N - BR-22)
CREATE TABLE user_role (
    user_id INT NOT NULL,
    role_id INT NOT NULL,
    CONSTRAINT pk_user_role PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_user_role_user FOREIGN KEY (user_id)
        REFERENCES user_account (user_id) ON DELETE CASCADE,
    CONSTRAINT fk_user_role_role FOREIGN KEY (role_id)
        REFERENCES role (role_id) ON DELETE CASCADE
);

-- Bảng 4: permission (Danh mục quyền hạn thao tác chi tiết)
CREATE TABLE permission (
    permission_id   SERIAL,
    permission_code VARCHAR(50)  NOT NULL,
    module_name     VARCHAR(50)  NOT NULL,
    description     VARCHAR(255),
    CONSTRAINT pk_permission PRIMARY KEY (permission_id),
    CONSTRAINT uq_permission_code UNIQUE (permission_code)
);

-- Bảng 5: role_permission (Bảng trung gian gán quyền cho vai trò M:N)
CREATE TABLE role_permission (
    role_id       INT NOT NULL,
    permission_id INT NOT NULL,
    CONSTRAINT pk_role_permission PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_role_permission_role FOREIGN KEY (role_id)
        REFERENCES role (role_id) ON DELETE CASCADE,
    CONSTRAINT fk_role_permission_permission FOREIGN KEY (permission_id)
        REFERENCES permission (permission_id) ON DELETE CASCADE
);

-- ============================================================================
-- PHẦN 2: CÁC THỰC THỂ CON KẾ THỪA TỪ USER_ACCOUNT (1:1 SHARED PRIMARY KEY)
-- ============================================================================

-- Bảng 6: member_profile (Hồ sơ mở rộng cho Hội viên)
CREATE TABLE member_profile (
    user_id      INT PRIMARY KEY,
    health_notes TEXT,
    CONSTRAINT fk_member_profile_user FOREIGN KEY (user_id)
        REFERENCES user_account (user_id) ON DELETE CASCADE
);

-- Bảng 7: trainer_profile (Hồ sơ Huấn luyện viên thể hình - BR-11)
CREATE TABLE trainer_profile (
    user_id        INT PRIMARY KEY,
    specialization VARCHAR(100),
    bio            TEXT,
    current_rating DECIMAL(3, 2) NOT NULL DEFAULT 5.00,
    CONSTRAINT fk_trainer_profile_user FOREIGN KEY (user_id)
        REFERENCES user_account (user_id) ON DELETE CASCADE,
    CONSTRAINT chk_trainer_rating CHECK (current_rating >= 0.00 AND current_rating <= 5.00)
);

-- Bảng 8: staff_profile (Hồ sơ Nhân viên hành chính / kỹ thuật)
CREATE TABLE staff_profile (
    user_id    INT PRIMARY KEY,
    job_title  VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    CONSTRAINT fk_staff_profile_user FOREIGN KEY (user_id)
        REFERENCES user_account (user_id) ON DELETE CASCADE
);

-- ============================================================================
-- PHẦN 3: PHÂN HỆ GÓI TẬP & THANH TOÁN (SUBSCRIPTION & BILLING)
-- ============================================================================

-- Bảng 9: membership_plan (Danh mục gói tập - BR-04)
CREATE TABLE membership_plan (
    plan_id        SERIAL,
    plan_name      VARCHAR(100)   NOT NULL,
    duration_days  INT            NOT NULL,
    total_sessions INT            NOT NULL DEFAULT 0,
    price          DECIMAL(10, 2) NOT NULL,
    description    TEXT,
    CONSTRAINT pk_membership_plan PRIMARY KEY (plan_id),
    CONSTRAINT chk_membership_plan_duration CHECK (duration_days > 0),
    CONSTRAINT chk_membership_plan_sessions CHECK (total_sessions >= 0),
    CONSTRAINT chk_membership_plan_price CHECK (price >= 0)
);

-- Bảng 10: member_subscription (Hợp đồng đăng ký gói tập của hội viên - BR-05, BR-06, BR-07, BR-24)
CREATE TABLE member_subscription (
    subscription_id    SERIAL,
    member_user_id     INT            NOT NULL,
    plan_id            INT            NOT NULL,
    actual_price       DECIMAL(10, 2) NOT NULL,
    remaining_sessions INT            NOT NULL DEFAULT 0,
    start_time         TIMESTAMP      NOT NULL,
    end_time           TIMESTAMP      NOT NULL,
    sub_status         VARCHAR(20)    NOT NULL DEFAULT 'Pending',
    is_recurring       BOOLEAN        NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_member_subscription PRIMARY KEY (subscription_id),
    CONSTRAINT fk_subscription_member FOREIGN KEY (member_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_subscription_plan FOREIGN KEY (plan_id)
        REFERENCES membership_plan (plan_id) ON DELETE RESTRICT,
    CONSTRAINT chk_subscription_price CHECK (actual_price >= 0),
    CONSTRAINT chk_subscription_remaining CHECK (remaining_sessions >= 0),
    CONSTRAINT chk_subscription_dates CHECK (end_time >= start_time),
    CONSTRAINT chk_subscription_status CHECK (sub_status IN ('Pending', 'Active', 'Expired', 'Suspended', 'Cancelled'))
);

-- Bảng 11: billing_log (Nhật ký hóa đơn thanh toán bất biến - BR-08, BR-09, BR-10)
CREATE TABLE billing_log (
    billing_id      SERIAL,
    subscription_id INT            NOT NULL,
    invoice_no      VARCHAR(50)    NOT NULL,
    amount          DECIMAL(10, 2) NOT NULL,
    payment_date    DATE           NOT NULL,
    payment_method  VARCHAR(50)    NOT NULL,
    payment_status  VARCHAR(20)    NOT NULL DEFAULT 'Completed',
    created_at      TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_billing_log PRIMARY KEY (billing_id),
    CONSTRAINT uq_billing_invoice_no UNIQUE (invoice_no),
    CONSTRAINT fk_billing_subscription FOREIGN KEY (subscription_id)
        REFERENCES member_subscription (subscription_id) ON DELETE RESTRICT,
    CONSTRAINT chk_billing_amount CHECK (amount > 0),
    CONSTRAINT chk_billing_method CHECK (payment_method IN ('Cash', 'Credit_Card', 'Banking', 'E_Wallet')),
    CONSTRAINT chk_billing_status CHECK (payment_status IN ('Pending', 'Completed', 'Failed', 'Refunded'))
);

-- ============================================================================
-- PHẦN 4: PHÂN HỆ CƠ SỞ VẬT CHẤT & THIẾT BỊ (FACILITIES & EQUIPMENT)
-- ============================================================================

-- Bảng 12: facilities_room (Phòng tập và khu vực tiện ích - BR-13, BR-19)
CREATE TABLE facilities_room (
    room_id      SERIAL,
    room_name    VARCHAR(100) NOT NULL,
    max_capacity INT          NOT NULL,
    room_type    VARCHAR(50)  NOT NULL,
    status       VARCHAR(20)  NOT NULL DEFAULT 'Active',
    CONSTRAINT pk_facilities_room PRIMARY KEY (room_id),
    CONSTRAINT chk_facilities_capacity CHECK (max_capacity > 0),
    CONSTRAINT chk_facilities_status CHECK (status IN ('Active', 'Under_Maintenance', 'Inactive'))
);

-- Bảng 13: equipment (Thiết bị / máy móc tập luyện - BR-19, BR-26)
CREATE TABLE equipment (
    equipment_id        SERIAL,
    room_id             INT          NOT NULL,
    equipment_name      VARCHAR(100) NOT NULL,
    serial_number       VARCHAR(100) NOT NULL,
    purchase_date       DATE         NOT NULL,
    depreciation_months INT          NOT NULL,
    status              VARCHAR(20)  NOT NULL DEFAULT 'Operational',
    CONSTRAINT pk_equipment PRIMARY KEY (equipment_id),
    CONSTRAINT uq_equipment_serial UNIQUE (serial_number),
    CONSTRAINT fk_equipment_room FOREIGN KEY (room_id)
        REFERENCES facilities_room (room_id) ON DELETE RESTRICT,
    CONSTRAINT chk_equipment_depreciation CHECK (depreciation_months > 0),
    CONSTRAINT chk_equipment_status CHECK (status IN ('Operational', 'Under_Maintenance', 'Decommissioned'))
);

-- ============================================================================
-- PHẦN 5: PHÂN HỆ LẬP LỊCH & ĐẶT CHỖ (SCHEDULING & ENROLLMENT)
-- ============================================================================

-- Bảng 14: class_schedule (Lịch lớp học nhóm - BR-14, BR-17)
CREATE TABLE class_schedule (
    class_id         SERIAL,
    trainer_user_id  INT          NOT NULL,
    room_id          INT          NOT NULL,
    class_name       VARCHAR(100) NOT NULL,
    start_time       TIMESTAMP    NOT NULL,
    end_time         TIMESTAMP    NOT NULL,
    max_capacity     INT          NOT NULL,
    current_enrolled INT          NOT NULL DEFAULT 0,
    CONSTRAINT pk_class_schedule PRIMARY KEY (class_id),
    CONSTRAINT fk_class_trainer FOREIGN KEY (trainer_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_class_room FOREIGN KEY (room_id)
        REFERENCES facilities_room (room_id) ON DELETE RESTRICT,
    CONSTRAINT chk_class_time CHECK (end_time > start_time),
    CONSTRAINT chk_class_capacity CHECK (max_capacity > 0),
    CONSTRAINT chk_class_enrolled CHECK (current_enrolled >= 0),
    CONSTRAINT chk_class_enrollment_limit CHECK (current_enrolled <= max_capacity)
);

-- Bảng 15: class_enrollment (Đăng ký lớp học nhóm của hội viên)
CREATE TABLE class_enrollment (
    enrollment_id   SERIAL,
    subscription_id INT         NOT NULL,
    class_id        INT         NOT NULL,
    enrollment_date TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(20) NOT NULL DEFAULT 'Enrolled',
    CONSTRAINT pk_class_enrollment PRIMARY KEY (enrollment_id),
    CONSTRAINT fk_enrollment_subscription FOREIGN KEY (subscription_id)
        REFERENCES member_subscription (subscription_id) ON DELETE CASCADE,
    CONSTRAINT fk_enrollment_class FOREIGN KEY (class_id)
        REFERENCES class_schedule (class_id) ON DELETE CASCADE,
    CONSTRAINT uq_enrollment_subscription_class UNIQUE (subscription_id, class_id),
    CONSTRAINT chk_enrollment_status CHECK (status IN ('Enrolled', 'Cancelled', 'Attended'))
);

-- Bảng 16: pt_booking (Lịch hẹn ca tập huấn luyện viên cá nhân 1-1 - BR-12, BR-17, BR-18, BR-25)
CREATE TABLE pt_booking (
    booking_id      SERIAL,
    member_user_id  INT         NOT NULL,
    trainer_user_id INT         NOT NULL,
    subscription_id INT         NOT NULL,
    booking_date    DATE        NOT NULL,
    start_time      TIMESTAMP   NOT NULL,
    end_time        TIMESTAMP   NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    created_at      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_pt_booking PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_member FOREIGN KEY (member_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_trainer FOREIGN KEY (trainer_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_subscription FOREIGN KEY (subscription_id)
        REFERENCES member_subscription (subscription_id) ON DELETE RESTRICT,
    CONSTRAINT chk_pt_booking_time CHECK (end_time > start_time),
    CONSTRAINT chk_pt_booking_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'No_Show'))
);

-- Bảng 17: equipment_reservation (Giữ chỗ máy móc trước giờ tập - BR-21)
CREATE TABLE equipment_reservation (
    reservation_id SERIAL,
    equipment_id   INT         NOT NULL,
    booking_id     INT,
    class_id       INT,
    start_time     TIMESTAMP   NOT NULL,
    end_time       TIMESTAMP   NOT NULL,
    status         VARCHAR(20) NOT NULL DEFAULT 'Reserved',
    CONSTRAINT pk_equipment_reservation PRIMARY KEY (reservation_id),
    CONSTRAINT fk_reservation_equipment FOREIGN KEY (equipment_id)
        REFERENCES equipment (equipment_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_booking FOREIGN KEY (booking_id)
        REFERENCES pt_booking (booking_id) ON DELETE CASCADE,
    CONSTRAINT fk_reservation_class FOREIGN KEY (class_id)
        REFERENCES class_schedule (class_id) ON DELETE CASCADE,
    CONSTRAINT chk_reservation_time CHECK (end_time > start_time),
    CONSTRAINT chk_reservation_status CHECK (status IN ('Reserved', 'Completed', 'Cancelled')),
    CONSTRAINT chk_reservation_source CHECK (
        (booking_id IS NOT NULL AND class_id IS NULL) OR
        (booking_id IS NULL AND class_id IS NOT NULL)
    )
);

-- Bảng 18: maintenance_log (Nhật ký sửa chữa và bảo dưỡng thiết bị - BR-20)
CREATE TABLE maintenance_log (
    maintenance_id    SERIAL,
    equipment_id      INT            NOT NULL,
    staff_user_id     INT            NOT NULL,
    issue_description TEXT           NOT NULL,
    start_time        TIMESTAMP      NOT NULL,
    end_time          TIMESTAMP,
    cost              DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    status            VARCHAR(20)    NOT NULL DEFAULT 'In_Progress',
    created_at        TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT pk_maintenance_log PRIMARY KEY (maintenance_id),
    CONSTRAINT fk_maintenance_equipment FOREIGN KEY (equipment_id)
        REFERENCES equipment (equipment_id) ON DELETE RESTRICT,
    CONSTRAINT fk_maintenance_staff FOREIGN KEY (staff_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_maintenance_cost CHECK (cost >= 0),
    CONSTRAINT chk_maintenance_status CHECK (status IN ('In_Progress', 'Completed', 'Cancelled')),
    CONSTRAINT chk_maintenance_time CHECK (end_time IS NULL OR end_time >= start_time)
);

-- ============================================================================
-- PHẦN 6: CHỈ MỤC TỐI ƯU HÓA HIỆU NĂNG (INDEXING)
-- ============================================================================

CREATE INDEX idx_user_account_status ON user_account (status);
CREATE INDEX idx_member_subscription_member ON member_subscription (member_user_id);
CREATE INDEX idx_member_subscription_status ON member_subscription (sub_status);
CREATE INDEX idx_member_subscription_dates ON member_subscription (start_time, end_time);
CREATE INDEX idx_billing_log_subscription ON billing_log (subscription_id);
CREATE INDEX idx_billing_log_payment_date ON billing_log (payment_date);
CREATE INDEX idx_pt_booking_trainer ON pt_booking (trainer_user_id);
CREATE INDEX idx_pt_booking_member ON pt_booking (member_user_id);
CREATE INDEX idx_pt_booking_dates ON pt_booking (start_time, end_time);
CREATE INDEX idx_class_schedule_trainer ON class_schedule (trainer_user_id);
CREATE INDEX idx_class_schedule_room ON class_schedule (room_id);
CREATE INDEX idx_class_schedule_dates ON class_schedule (start_time, end_time);
CREATE INDEX idx_equipment_status ON equipment (status);
CREATE INDEX idx_maintenance_log_equipment ON maintenance_log (equipment_id);
