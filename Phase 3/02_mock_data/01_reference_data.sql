-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Dữ liệu danh mục: role, permission, role_permission, facilities_room, membership_plan.

-- ----------------------------------------------------------------------------
-- 1. BẢNG DANH MỤC VAI TRÒ (role) & QUYỀN HẠN (permission)
-- ----------------------------------------------------------------------------
INSERT INTO role (role_id, role_name, description) VALUES
(1, 'Admin', 'Toàn quyền quản trị hệ thống, tài chính và cấu hình phân quyền'),
(2, 'Trainer', 'Huấn luyện viên thể hình cá nhân (PT) và đứng lớp nhóm'),
(3, 'Member', 'Hội viên tham gia tập luyện và sử dụng dịch vụ của câu lạc bộ'),
(4, 'Receptionist', 'Lễ tân tiếp đón, hỗ trợ tạo tài khoản và tư vấn gói tập'),
(5, 'Technician', 'Nhân viên kỹ thuật quản lý bảo trì và kiểm định cơ sở vật chất');

ALTER SEQUENCE role_role_id_seq RESTART WITH 6;

INSERT INTO permission (permission_id, permission_code, module_name, description) VALUES
(1, 'MEMBER_VIEW', 'Member', 'Xem danh sách và thông tin chi tiết hội viên'),
(2, 'MEMBER_CREATE', 'Member', 'Tạo mới hồ sơ tài khoản hội viên'),
(3, 'MEMBER_EDIT', 'Member', 'Cập nhật thông tin liên hệ và tình trạng sức khỏe hội viên'),
(4, 'PLAN_MANAGE', 'Subscription', 'Tạo mới và điều chỉnh biểu phí các gói tập'),
(5, 'SUB_ACTIVATE', 'Subscription', 'Kích hoạt hợp đồng và ghi nhận thanh toán'),
(6, 'CLASS_SCHEDULE', 'Schedule', 'Tạo và phân công lịch lớp học nhóm'),
(7, 'PT_BOOKING_MANAGE', 'Schedule', 'Xem và phê duyệt lịch tập PT 1-1'),
(8, 'EQUIP_MANAGE', 'Facility', 'Quản lý thông tin và trạng thái thiết bị phòng tập'),
(9, 'MAINTENANCE_LOG', 'Facility', 'Ghi nhật ký sửa chữa và chi phí bảo trì máy móc'),
(10, 'REPORTS_VIEW', 'Analytics', 'Xem báo cáo doanh thu, hiệu suất PT và tỷ lệ lấp đầy lớp'),
(11, 'CLASS_VIEW', 'Schedule', 'Xem lịch lớp học nhóm (chỉ đọc)');

ALTER SEQUENCE permission_permission_id_seq RESTART WITH 12;

-- ----------------------------------------------------------------------------
-- 2. GÁN QUYỀN CHO VAI TRÒ (role_permission)
-- ----------------------------------------------------------------------------
INSERT INTO role_permission (role_id, permission_id) VALUES
-- Ma trận này phải khớp với GRANT trong 08_rbac_security.sql (BR-22); các test SY-01..SY-05
-- của 09_rbac_test_cases.sql tự động phát hiện mọi chỗ lệch giữa hai nơi.
-- Admin sở hữu toàn bộ quyền (1-11)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10), (1, 11),
-- Trainer: xem hội viên, xem lịch lớp (chỉ đọc), xem/xác nhận ca PT
(2, 1), (2, 7), (2, 11),
-- Member: chỉ xem lịch lớp (không được xem hồ sơ hội viên khác)
(3, 11),
-- Receptionist: tạo/xem/sửa hội viên, kích hoạt gói, xếp lịch lớp, đặt lịch PT
(4, 1), (4, 2), (4, 3), (4, 5), (4, 6), (4, 7), (4, 11),
-- Technician có quyền quản lý thiết bị và bảo trì
(5, 8), (5, 9);

-- ----------------------------------------------------------------------------
-- 3. PHÒNG TẬP / KHU VỰC TIỆN ÍCH (facilities_room)
-- ----------------------------------------------------------------------------
INSERT INTO facilities_room (room_id, room_name, max_capacity, room_type, status) VALUES
(1, 'Lotus Yoga & Mindfulness Studio', 25, 'Yoga_Studio', 'Active'),
(2, 'Sky Cardio Zone Floor 2', 40, 'Gym_Floor', 'Active'),
(3, 'Free Weight & Powerlifting Arena', 35, 'Gym_Floor', 'Active'),
(4, 'CrossFit & Functional Box', 20, 'Functional_Zone', 'Active'),
(5, 'Pilates Reformer Deluxe Suite', 10, 'Pilates_Studio', 'Active'),
(6, 'Octagon Combat & Boxing Ring', 15, 'Boxing_Ring', 'Under_Maintenance'); -- Phòng đang bảo trì phục vụ test BR-19

ALTER SEQUENCE facilities_room_room_id_seq RESTART WITH 7;

-- ----------------------------------------------------------------------------
-- 4. DANH MỤC GÓI TẬP (membership_plan)
-- ----------------------------------------------------------------------------
INSERT INTO membership_plan (plan_id, plan_name, duration_days, total_sessions, price, description) VALUES
(1, 'Silver Monthly Access', 30, 0, 800000.00, 'Tự do sử dụng trang thiết bị tập luyện toàn khu Gym trong 30 ngày'),
(2, 'Gold Quarterly Pass', 90, 0, 2100000.00, 'Gói tập Gym không giới hạn 3 tháng kèm 3 buổi xông hơi thảo dược'),
(3, 'Platinum Semi-Annual Pass', 180, 0, 3900000.00, 'Gói tập Gym 6 tháng, tặng kèm bình nước cao cấp và áo thun CLB'),
(4, 'Diamond Annual VIP Pass', 365, 0, 7200000.00, 'Thẻ hội viên VIP 1 năm toàn quyền sử dụng bể bơi, khăn tập và phòng Sauna'),
(5, 'PT Kickstart 10 Sessions', 45, 10, 4500000.00, 'Gói 10 buổi tập 1-1 với HLV cá nhân chuyên nghiệp, thời hạn 45 ngày'),
(6, 'PT Transformation 20 Sessions', 90, 20, 8000000.00, 'Gói 20 buổi tập PT 1-1 thiết kế thực đơn dinh dưỡng và theo dõi chỉ số InBody'),
(7, 'PT Elite Athlete 50 Sessions', 180, 50, 18500000.00, 'Gói 50 buổi tập PT chuyên sâu cho người chuẩn bị thi đấu hoặc ép cân cấp tốc'),
(8, 'Student Flex Monthly', 30, 0, 500000.00, 'Gói ưu đãi đặc biệt dành riêng cho học sinh - sinh viên (khung giờ 09:00 - 16:00)');

ALTER SEQUENCE membership_plan_plan_id_seq RESTART WITH 9;

-- ----------------------------------------------------------------------------
