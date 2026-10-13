-- ============================================================================
-- ĐỀ TÀI: GYM MEMBERSHIP & PERSONAL TRAINING PLANNER
-- MÃ ĐỀ TÀI: 09 | NHÓM: G9 | LỚP: INT1313 - HỆ QUẢN TRỊ CSDL
-- TẬP TIN: 02_mock_data.sql - CHÈN DỮ LIỆU MẪU CHUẨN XÁC (DML MOCK DATA)
-- HỆ QUẢN TRỊ CSDL: PostgreSQL 16+
-- THỨ TỰ: Bảng Danh mục -> Thực thể độc lập -> Thực thể kế thừa -> Bảng giao dịch
-- ============================================================================

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
(10, 'REPORTS_VIEW', 'Analytics', 'Xem báo cáo doanh thu, hiệu suất PT và tỷ lệ lấp đầy lớp');

ALTER SEQUENCE permission_permission_id_seq RESTART WITH 11;

-- ----------------------------------------------------------------------------
-- 2. GÁN QUYỀN CHO VAI TRÒ (role_permission)
-- ----------------------------------------------------------------------------
INSERT INTO role_permission (role_id, permission_id) VALUES
-- Admin sở hữu toàn bộ quyền (1-10)
(1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6), (1, 7), (1, 8), (1, 9), (1, 10),
-- Trainer có quyền xem hội viên, xem lịch lớp, quản lý PT
(2, 1), (2, 6), (2, 7),
-- Member có quyền xem thông tin cơ bản
(3, 1),
-- Receptionist có quyền tạo/xem hội viên, kích hoạt gói, hỗ trợ book lịch
(4, 1), (4, 2), (4, 3), (4, 5), (4, 6), (4, 7),
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
-- 5. TÀI KHOẢN NGƯỜI DÙNG (user_account)
-- Gồm: 2 Admin (1-2), 2 Staff (3-4), 6 Trainers (5-10), 20 Members (11-30)
-- ----------------------------------------------------------------------------
INSERT INTO user_account (user_id, full_name, email, phone, dob, emergency_contact, password_hash, status) VALUES
-- Admin
(1, 'Nguyễn Văn Quản Trị', 'admin.master@fitzone.vn', '0901000001', '1985-04-12', 'Vợ: 0901000002', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(2, 'Lê Thị Điều Hành', 'manager.le@fitzone.vn', '0901000003', '1990-08-25', 'Chồng: 0901000004', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
-- Staff (Lễ tân & Kỹ thuật)
(3, 'Trần Minh Lễ Tân', 'reception.tran@fitzone.vn', '0902000001', '1998-11-14', 'Mẹ: 0902000002', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(4, 'Phạm Quốc Kỹ Thuật', 'tech.pham@fitzone.vn', '0902000003', '1992-06-03', 'Anh trai: 0902000004', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
-- Trainers
(5, 'Đỗ Hùng Dũng (PT Gym)', 'trainer.dung@fitzone.vn', '0903000001', '1993-02-18', 'Chị: 0903000002', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(6, 'Hoàng Kim Ngân (Yoga)', 'trainer.ngan@fitzone.vn', '0903000003', '1995-09-09', 'Bố: 0903000004', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(7, 'Vũ Đình Trọng (CrossFit)', 'trainer.trong@fitzone.vn', '0903000005', '1991-12-30', 'Mẹ: 0903000006', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(8, 'Mai Thùy Chi (Pilates)', 'trainer.chi@fitzone.vn', '0903000007', '1997-04-05', 'Em: 0903000008', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(9, 'Bùi Tấn Trường (Boxing)', 'trainer.truong@fitzone.vn', '0903000009', '1990-01-22', 'Vợ: 0903000010', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(10, 'Phan Văn Đức (Fitness)', 'trainer.duc@fitzone.vn', '0903000011', '1996-07-19', 'Mẹ: 0903000012', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
-- Members
(11, 'Lê Hoàng Tiến', 'tien.le@gmail.com', '0911000001', '2004-05-15', 'Mẹ: 0911000002', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(12, 'Lê Hòa Thuận', 'thuan.le@gmail.com', '0911000003', '2004-08-20', 'Bố: 0911000004', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(13, 'Trần Minh Tiến', 'tien.tran@gmail.com', '0911000005', '2004-12-10', 'Chị: 0911000006', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(14, 'Võ Thị Mai Lan', 'lan.vo@yahoo.com', '0911000007', '1999-03-22', 'Chồng: 0911000008', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(15, 'Nguyễn Thanh Tùng', 'tung.nguyen@son-tung.com', '0911000009', '1994-07-05', 'Em trai: 0911000010', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(16, 'Phạm Quỳnh Anh', 'quynhanh.pham@outlook.com', '0911000011', '1987-10-18', 'Mẹ: 0911000012', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(17, 'Đặng Thái Sơn', 'son.dang@gmail.com', '0911000013', '1980-01-14', 'Vợ: 0911000014', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(18, 'Trịnh Thăng Bình', 'binh.trinh@gmail.com', '0911000015', '1989-04-30', 'Bạn: 0911000016', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(19, 'Hồ Ngọc Hà', 'ha.ho@ent.vn', '0911000017', '1984-11-25', 'Trợ lý: 0911000018', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(20, 'Dương Khắc Linh', 'linh.duong@music.vn', '0911000019', '1982-03-20', 'Vợ: 0911000020', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(21, 'Nguyễn Hoàng Đức', 'duc.nh@vt.vn', '0911000021', '1998-01-11', 'Bố: 0911000022', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(22, 'Đoàn Văn Hậu', 'hau.dv@hanoi.vn', '0911000023', '1999-04-19', 'Vợ: 0911000024', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(23, 'Nguyễn Quang Hải', 'hai.nq@cahn.vn', '0911000025', '1997-04-12', 'Mẹ: 0911000026', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(24, 'Châu Bùi', 'chau.bui@fashion.vn', '0911000027', '1997-11-13', 'Quản lý: 0911000028', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(25, 'Khánh Vy', 'khanhvy.vtv@vtv.vn', '0911000029', '1999-08-21', 'Mẹ: 0911000030', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(26, 'Nguyễn Trọng Hoàng', 'hoang.nt@slna.vn', '0911000031', '1989-04-14', 'Vợ: 0911000032', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Inactive'),
(27, 'Lê Công Vinh', 'vinh.lc@football.vn', '0911000033', '1985-12-10', 'Vợ: 0911000034', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Suspended'),
(28, 'Trần Đình Trọng', 'trong.td@binhdinh.vn', '0911000035', '1997-04-25', 'Bố: 0911000036', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(29, 'Phan Tuấn Tài', 'tai.pt@viettel.vn', '0911000037', '2001-01-07', 'Mẹ: 0911000038', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active'),
(30, 'Khuất Văn Khang', 'khang.kv@viettel.vn', '0911000039', '2003-05-11', 'Bố: 0911000040', '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g', 'Active');

ALTER SEQUENCE user_account_user_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
-- 6. GÁN VAI TRÒ CHO NGƯỜI DÙNG (user_role)
-- ----------------------------------------------------------------------------
INSERT INTO user_role (user_id, role_id) VALUES
(1, 1), -- Admin
(2, 1), -- Admin
(3, 4), -- Receptionist
(4, 5), -- Technician
(5, 2), -- PT Dũng
(6, 2), -- PT Ngân
(7, 2), -- PT Trọng
(8, 2), -- PT Chi
(9, 2), -- PT Trường
(10, 2); -- PT Đức

-- Gán vai trò Member cho các user từ 11 đến 30
INSERT INTO user_role (user_id, role_id)
SELECT id, 3 FROM generate_series(11, 30) AS id;

-- ----------------------------------------------------------------------------
-- 7. THỰC THỂ CON KẾ THỪA (Profiles)
-- ----------------------------------------------------------------------------
-- Hồ sơ huấn luyện viên (trainer_profile)
INSERT INTO trainer_profile (user_id, specialization, bio, current_rating) VALUES
(5, 'Thể hình cổ điển & Tăng cơ chuyên sâu', 'Cựu vận động viên thể hình cấp quốc gia, 8 năm kinh nghiệm huấn luyện thi đấu', 4.95),
(6, 'Hatha Yoga & Vinyasa Flow', 'Chứng chỉ Yoga quốc tế RYT-500 từ Rishikesh Ấn Độ, phục hồi cột sống', 4.90),
(7, 'CrossFit & Calisthenics', 'HLV cấp độ 2 CrossFit, chuyên rèn luyện thể lực và sức bền quân đội', 4.82),
(8, 'Pilates Reformer & Posture Correction', 'Chứng chỉ Master Pilates Quốc tế, trị liệu đau mỏi lưng cổ vai gáy', 4.88),
(9, 'Boxing & Muay Thai Kickboxing', 'Huy chương vàng đại hội Boxing toàn quốc 2018, chuyên boxing đối kháng', 4.75),
(10, 'Fat Loss & Functional Fitness', 'Chuyên gia thiết kế lộ trình siết cân nhanh cho người bận rộn', 4.65);

-- Hồ sơ nhân viên (staff_profile)
INSERT INTO staff_profile (user_id, job_title, department) VALUES
(3, 'Chief Receptionist', 'Customer Service & Front Desk'),
(4, 'Senior Facility Technician', 'Engineering & Maintenance');

-- Hồ sơ hội viên (member_profile)
INSERT INTO member_profile (user_id, health_notes) VALUES
(11, 'Thể lực tốt, mục tiêu tăng 5kg cơ nạc trong 3 tháng'),
(12, 'Tiền sử huyết áp thấp, cần bổ sung điện giải trong lúc tập'),
(13, 'Hơi thừa cân, muốn cải thiện sức bền tim mạch và giảm mỡ bụng'),
(14, 'Dị ứng phấn hoa, đau mỏi thắt lưng sau sinh, tập Yoga phục hồi'),
(15, 'Mục tiêu duy trì vóc dáng biểu diễn, tập luyện cường độ cao'),
(16, 'Tiền sử thoát vị đĩa đệm nhẹ đốt L4-L5, cần theo sát kỹ thuật'),
(17, 'Huyết áp cao nhẹ, tránh các bài tập nín thở gắng sức quá mức'),
(18, 'Cần tăng cơ bắp tay và ngực, lịch trình làm việc bận rộn'),
(19, 'Tập luyện duy trì độ dẻo dai cơ thể và săn chắc vòng eo'),
(20, 'Tập Pilates cải thiện tư thế gù lưng văn phòng'),
(21, 'Cầu thủ chuyên nghiệp, tập luyện duy trì thể lực trong kỳ nghỉ'),
(22, 'Phục hồi sau phẫu thuật dây chằng chéo trước gối phải'),
(23, 'Rèn luyện tốc độ bứt phá và độ linh hoạt cổ chân'),
(24, 'Muốn có thân hình săn chắc thon gọn, kết hợp ăn kiêng'),
(25, 'Người mới bắt đầu, cần hướng dẫn máy móc từ căn bản'),
(26, 'Từng chấn thương sụn chêm, cần chế độ tập ít áp lực lên gối'),
(27, 'Tập duy trì sức khỏe tổng quát, thích chạy bộ và bơi lội'),
(28, 'Phục hồi chấn thương cơ khép háng sau thi đấu'),
(29, 'Tăng cường sức mạnh cơ thân trên và cơ lõi Core'),
(30, 'Cần tăng khối lượng cơ toàn thân và tập tăng sức bật');

-- ----------------------------------------------------------------------------
-- 8. THIẾT BỊ PHÒNG TẬP (equipment)
-- ----------------------------------------------------------------------------
INSERT INTO equipment (equipment_id, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status) VALUES
(1, 2, 'Máy chạy bộ Technogym Skillrun 7000', 'TG-RUN-2023-001', '2023-01-15', 36, 'Operational'),
(2, 2, 'Máy chạy bộ Technogym Skillrun 7000', 'TG-RUN-2023-002', '2023-01-15', 36, 'Operational'),
(3, 2, 'Máy chạy bộ Technogym Skillrun 7000', 'TG-RUN-2023-003', '2023-01-15', 36, 'Under_Maintenance'), -- Đang hỏng màn hình cảm ứng
(4, 2, 'Xe đạp trượt tuyết Concept2 BikeErg', 'C2-BIKE-2023-010', '2023-03-10', 48, 'Operational'),
(5, 3, 'Khung gánh tạ trợ lực Smith Machine Matrix', 'MT-SMTH-2022-005', '2022-06-20', 60, 'Operational'),
(6, 3, 'Máy đạp đùi 45 độ Linear Leg Press Rogue', 'RG-LEGP-2022-008', '2022-07-01', 60, 'Operational'),
(7, 3, 'Dàn kéo cáp đa năng 8 trụ Life Fitness Cable', 'LF-CABL-2021-001', '2021-09-15', 72, 'Operational'),
(8, 3, 'Ghế đẩy ngực dốc ngang Olympic Flat Bench', 'OL-FBEN-2022-014', '2022-08-11', 60, 'Operational'),
(9, 4, 'Máy chèo thuyền Concept2 RowErg Model D', 'C2-ROWE-2023-022', '2023-02-18', 48, 'Operational'),
(10, 4, 'Bộ tạ chuông Kettlebell Rogue 8kg-32kg', 'RG-KETT-2023-009', '2023-04-05', 48, 'Operational'),
(11, 1, 'Bộ thảm Yoga định tuyến Liforme cao cấp (20 chiếc)', 'LF-YOGA-2024-001', '2024-01-10', 24, 'Operational'),
(12, 5, 'Giường tập Pilates Reformer gỗ sồi Merrithew', 'MR-PILR-2023-004', '2023-05-12', 60, 'Operational'),
(13, 5, 'Giường tập Pilates Reformer gỗ sồi Merrithew', 'MR-PILR-2023-005', '2023-05-12', 60, 'Under_Maintenance'), -- Đang đứt lò xo kháng lực
(14, 6, 'Bao cát đấm bốc hạng nặng Fairtex 1m8', 'FT-SBAG-2022-003', '2022-11-20', 36, 'Operational'),
(15, 6, 'Sàn đài boxing tiêu chuẩn dây đai thép 6m', 'BX-RING-2022-001', '2022-10-15', 84, 'Under_Maintenance'); -- Thuộc phòng 6 đang bảo trì

ALTER SEQUENCE equipment_equipment_id_seq RESTART WITH 16;

-- ----------------------------------------------------------------------------
-- 9. HỢP ĐỒNG ĐĂNG KÝ GÓI TẬP (member_subscription)
-- Rải đều trạng thái: Active, Expired, Suspended, Pending; có gói PT và gói thời gian
-- Thời gian rải từ 2025 đến 2026, bao gồm các gói sắp hết hạn trong 7 ngày tới
-- ----------------------------------------------------------------------------
INSERT INTO member_subscription (subscription_id, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring) VALUES
-- Hội viên 11 (Lê Hoàng Tiến): Gói PT 20 buổi đang Active
(1, 11, 6, 8000000.00, 16, '2026-09-01 08:00:00', '2026-11-30 22:00:00', 'Active', FALSE),
-- Hội viên 12 (Lê Hòa Thuận): Gói VIP 12 tháng đang Active
(2, 12, 4, 7200000.00, 0, '2026-01-01 06:00:00', '2026-12-31 22:00:00', 'Active', TRUE),
-- Hội viên 13 (Trần Minh Tiến): Gói PT 10 buổi sắp hết hạn trong vòng 5 ngày tới!
(3, 13, 5, 4500000.00, 2, '2026-09-01 08:00:00', CURRENT_TIMESTAMP + INTERVAL '5 days', 'Active', FALSE),
-- Hội viên 14 (Võ Thị Mai Lan): Gói Semi-Annual 6 tháng sắp hết hạn trong vòng 3 ngày tới!
(4, 14, 3, 3900000.00, 0, '2026-04-15 08:00:00', CURRENT_TIMESTAMP + INTERVAL '3 days', 'Active', TRUE),
-- Hội viên 15 (Nguyễn Thanh Tùng): Gói VIP 1 năm đang Active
(5, 15, 4, 7200000.00, 0, '2026-05-01 00:00:00', '2027-05-01 00:00:00', 'Active', TRUE),
-- Hội viên 16 (Phạm Quỳnh Anh): Gói PT 20 buổi đang Active
(6, 16, 6, 8000000.00, 12, '2026-08-15 08:00:00', '2026-11-15 22:00:00', 'Active', FALSE),
-- Hội viên 17 (Đặng Thái Sơn): Gói Quarterly 3 tháng đang Active
(7, 17, 2, 2100000.00, 0, '2026-08-01 08:00:00', '2026-11-01 22:00:00', 'Active', FALSE),
-- Hội viên 18 (Trịnh Thăng Bình): Gói PT Elite 50 buổi đang Active
(8, 18, 7, 18500000.00, 42, '2026-07-01 08:00:00', '2026-12-31 22:00:00', 'Active', FALSE),
-- Hội viên 19 (Hồ Ngọc Hà): Gói VIP 1 năm đang Active
(9, 19, 4, 7200000.00, 0, '2026-03-01 08:00:00', '2027-03-01 22:00:00', 'Active', TRUE),
-- Hội viên 20 (Dương Khắc Linh): Gói PT 10 buổi đã đăng ký nhưng CHƯA TỪNG ĐẶT LỊCH (phục vụ Query 7)
(10, 20, 5, 4500000.00, 10, '2026-09-20 08:00:00', '2026-11-05 22:00:00', 'Active', FALSE),
-- Hội viên 21 (Nguyễn Hoàng Đức): Gói PT 20 buổi đang Active
(11, 21, 6, 8000000.00, 15, '2026-08-20 08:00:00', '2026-11-20 22:00:00', 'Active', FALSE),
-- Hội viên 22 (Đoàn Văn Hậu): Gói PT 50 buổi đang Active
(12, 22, 7, 18500000.00, 38, '2026-06-01 08:00:00', '2026-12-01 22:00:00', 'Active', FALSE),
-- Hội viên 23 (Nguyễn Quang Hải): Gói Quarterly 3 tháng đang Active
(13, 23, 2, 2100000.00, 0, '2026-08-15 08:00:00', '2026-11-15 22:00:00', 'Active', FALSE),
-- Hội viên 24 (Châu Bùi): Gói VIP 1 năm đang Active
(14, 24, 4, 7200000.00, 0, '2026-02-15 08:00:00', '2027-02-15 22:00:00', 'Active', TRUE),
-- Hội viên 25 (Khánh Vy): Gói Sinh viên 1 tháng sắp hết hạn trong vòng 2 ngày tới!
(15, 25, 8, 500000.00, 0, '2026-09-15 08:00:00', CURRENT_TIMESTAMP + INTERVAL '2 days', 'Active', FALSE),
-- Hội viên 26 (Nguyễn Trọng Hoàng): Gói cũ đã Expired
(16, 26, 2, 2100000.00, 0, '2025-06-01 08:00:00', '2025-09-01 22:00:00', 'Expired', FALSE),
-- Hội viên 27 (Lê Công Vinh): Gói bị tạm đình chỉ Suspended
(17, 27, 3, 3900000.00, 0, '2026-01-01 08:00:00', '2026-07-01 22:00:00', 'Suspended', FALSE),
-- Hội viên 28 (Trần Đình Trọng): Gói PT 10 buổi đang Active
(18, 28, 5, 4500000.00, 5, '2026-09-10 08:00:00', '2026-10-25 22:00:00', 'Active', FALSE),
-- Hội viên 29 (Phan Tuấn Tài): Gói Sinh viên 1 tháng đang Active
(19, 29, 8, 500000.00, 0, '2026-10-01 08:00:00', '2026-10-31 22:00:00', 'Active', TRUE),
-- Hội viên 30 (Khuất Văn Khang): Gói Sinh viên 1 tháng đang Active
(20, 30, 8, 500000.00, 0, '2026-10-05 08:00:00', '2026-11-05 22:00:00', 'Active', TRUE),
-- Thêm các hợp đồng cũ trong quá khứ để có dữ liệu doanh thu đa dạng theo các quý
(21, 11, 1, 800000.00, 0, '2026-01-10 08:00:00', '2026-02-10 22:00:00', 'Expired', FALSE),
(22, 12, 2, 2100000.00, 0, '2025-09-01 08:00:00', '2025-12-01 22:00:00', 'Expired', FALSE),
(23, 13, 1, 800000.00, 0, '2026-04-01 08:00:00', '2026-05-01 22:00:00', 'Expired', FALSE),
(24, 15, 6, 8000000.00, 0, '2025-10-01 08:00:00', '2026-01-01 22:00:00', 'Expired', FALSE),
(25, 18, 5, 4500000.00, 0, '2026-02-01 08:00:00', '2026-03-20 22:00:00', 'Expired', FALSE),
(26, 19, 3, 3900000.00, 0, '2025-08-01 08:00:00', '2026-02-01 22:00:00', 'Expired', FALSE),
(27, 21, 2, 2100000.00, 0, '2026-03-10 08:00:00', '2026-06-10 22:00:00', 'Expired', FALSE),
(28, 22, 1, 800000.00, 0, '2026-04-10 08:00:00', '2026-05-10 22:00:00', 'Expired', FALSE),
(29, 23, 1, 800000.00, 0, '2026-05-15 08:00:00', '2026-06-15 22:00:00', 'Expired', FALSE),
(30, 24, 6, 8000000.00, 0, '2025-11-01 08:00:00', '2026-02-01 22:00:00', 'Expired', FALSE);

ALTER SEQUENCE member_subscription_subscription_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
-- 10. NHẬT KÝ THANH TOÁN (billing_log)
-- Rải đều khắp các quý (Q1, Q2, Q3, Q4) năm 2025 và 2026
-- ----------------------------------------------------------------------------
INSERT INTO billing_log (billing_id, subscription_id, invoice_no, amount, payment_date, payment_method, payment_status) VALUES
(1, 1, 'INV-2026-0901', 8000000.00, '2026-09-01', 'Banking', 'Completed'),
(2, 2, 'INV-2026-0101', 7200000.00, '2026-01-01', 'Credit_Card', 'Completed'),
(3, 3, 'INV-2026-0902', 4500000.00, '2026-09-01', 'Credit_Card', 'Completed'),
(4, 4, 'INV-2026-0415', 3900000.00, '2026-04-15', 'Banking', 'Completed'),
(5, 5, 'INV-2026-0501', 7200000.00, '2026-05-01', 'Credit_Card', 'Completed'),
(6, 6, 'INV-2026-0815', 8000000.00, '2026-08-15', 'Banking', 'Completed'),
(7, 7, 'INV-2026-0801', 2100000.00, '2026-08-01', 'Cash', 'Completed'),
(8, 8, 'INV-2026-0701', 18500000.00, '2026-07-01', 'Banking', 'Completed'),
(9, 9, 'INV-2026-0301', 7200000.00, '2026-03-01', 'Credit_Card', 'Completed'),
(10, 10, 'INV-2026-0920', 4500000.00, '2026-09-20', 'Credit_Card', 'Completed'),
(11, 11, 'INV-2026-0820', 8000000.00, '2026-08-20', 'Banking', 'Completed'),
(12, 12, 'INV-2026-0601', 18500000.00, '2026-06-01', 'Banking', 'Completed'),
(13, 13, 'INV-2026-0816', 2100000.00, '2026-08-15', 'E_Wallet', 'Completed'),
(14, 14, 'INV-2026-0215', 7200000.00, '2026-02-15', 'Credit_Card', 'Completed'),
(15, 15, 'INV-2026-0915', 500000.00, '2026-09-15', 'E_Wallet', 'Completed'),
(16, 16, 'INV-2025-0601', 2100000.00, '2025-06-01', 'Cash', 'Completed'),
(17, 17, 'INV-2026-0102', 3900000.00, '2026-01-01', 'Banking', 'Completed'),
(18, 18, 'INV-2026-0910', 4500000.00, '2026-09-10', 'Banking', 'Completed'),
(19, 19, 'INV-2026-1001', 500000.00, '2026-10-01', 'E_Wallet', 'Completed'),
(20, 20, 'INV-2026-1005', 500000.00, '2026-10-05', 'Cash', 'Completed'),
(21, 21, 'INV-2026-0110', 800000.00, '2026-01-10', 'Cash', 'Completed'),
(22, 22, 'INV-2025-0901', 2100000.00, '2025-09-01', 'Banking', 'Completed'),
(23, 23, 'INV-2026-0401', 800000.00, '2026-04-01', 'E_Wallet', 'Completed'),
(24, 24, 'INV-2025-1001', 8000000.00, '2025-10-01', 'Credit_Card', 'Completed'),
(25, 25, 'INV-2026-0201', 4500000.00, '2026-02-01', 'Banking', 'Completed'),
(26, 26, 'INV-2025-0801', 3900000.00, '2025-08-01', 'Credit_Card', 'Completed'),
(27, 27, 'INV-2026-0310', 2100000.00, '2026-03-10', 'Banking', 'Completed'),
(28, 28, 'INV-2026-0410', 800000.00, '2026-04-10', 'Cash', 'Completed'),
(29, 29, 'INV-2026-0515', 800000.00, '2026-05-15', 'E_Wallet', 'Completed'),
(30, 30, 'INV-2025-1101', 8000000.00, '2025-11-01', 'Credit_Card', 'Completed');

ALTER SEQUENCE billing_log_billing_id_seq RESTART WITH 31;

-- ----------------------------------------------------------------------------
-- 11. LỊCH LỚP HỌC NHÓM (class_schedule)
-- 20 lớp học nhóm với tỷ lệ đăng ký từ 0% đến 100% để kiểm thử Fill Rate (Query 5)
-- ----------------------------------------------------------------------------
INSERT INTO class_schedule (class_id, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled) VALUES
(1, 6, 1, 'Morning Awakening Yoga', '2026-10-10 06:00:00', '2026-10-10 07:15:00', 20, 20), -- 100% full
(2, 6, 1, 'Sunset Yin Yoga', '2026-10-10 18:00:00', '2026-10-10 19:15:00', 20, 16),
(3, 8, 5, 'Pilates Core Flow Reformer', '2026-10-11 08:30:00', '2026-10-11 09:30:00', 8, 8), -- 100% full
(4, 8, 5, 'Pilates Spine Relief', '2026-10-11 17:30:00', '2026-10-11 18:30:00', 8, 6),
(5, 7, 4, 'CrossFit WOD Metcon', '2026-10-12 07:00:00', '2026-10-12 08:00:00', 16, 12),
(6, 7, 4, 'CrossFit Hero WOD Murph', '2026-10-12 18:00:00', '2026-10-12 19:30:00', 16, 14),
(7, 5, 3, 'Powerlifting Deadlift Clinic', '2026-10-13 09:00:00', '2026-10-13 10:30:00', 12, 10),
(8, 10, 2, 'HIIT Cardio Burn Express', '2026-10-13 18:30:00', '2026-10-13 19:15:00', 25, 22),
(9, 6, 1, 'Vinyasa Flow Advanced', '2026-10-14 06:00:00', '2026-10-14 07:15:00', 20, 15),
(10, 8, 5, 'Pilates Posture Master', '2026-10-14 09:00:00', '2026-10-14 10:00:00', 8, 4),
(11, 7, 4, 'Functional Mobility & Core', '2026-10-15 07:00:00', '2026-10-15 08:00:00', 15, 5), -- 33% (Low)
(12, 10, 2, 'Tabata Extreme Fat Blast', '2026-10-15 18:00:00', '2026-10-15 19:00:00', 25, 18),
(13, 6, 1, 'Candlelight Restorative Yoga', '2026-10-16 19:30:00', '2026-10-16 20:45:00', 20, 20), -- 100% full
(14, 5, 3, 'Hypertrophy Upper Body', '2026-10-17 08:00:00', '2026-10-17 09:30:00', 15, 12),
(15, 7, 4, 'Olympic Weightlifting Snatch', '2026-10-17 10:00:00', '2026-10-17 11:30:00', 10, 8),
(16, 10, 2, 'Step & Aerobics Dance', '2026-10-18 09:00:00', '2026-10-18 10:00:00', 20, 6), -- 30% (Low)
(17, 6, 1, 'Meditation & Breathwork', '2026-10-19 06:30:00', '2026-10-19 07:30:00', 20, 2), -- 10% (Very Low)
(18, 8, 5, 'Pilates Jumpboard Cardio', '2026-10-19 16:00:00', '2026-10-19 17:00:00', 8, 8), -- 100% full
(19, 7, 4, 'Kettlebell Strength & Power', '2026-10-20 07:00:00', '2026-10-20 08:00:00', 15, 0), -- 0% (Empty)
(20, 10, 2, 'Circuit Bootcamp Warriors', '2026-10-20 18:00:00', '2026-10-20 19:15:00', 25, 24);

ALTER SEQUENCE class_schedule_class_id_seq RESTART WITH 21;

-- ----------------------------------------------------------------------------
-- 12. ĐĂNG KÝ LỚP HỌC (class_enrollment)
-- ----------------------------------------------------------------------------
INSERT INTO class_enrollment (enrollment_id, subscription_id, class_id, enrollment_date, status) VALUES
(1, 4, 1, '2026-10-08 09:00:00', 'Attended'),
(2, 9, 1, '2026-10-08 09:30:00', 'Attended'),
(3, 14, 1, '2026-10-08 10:00:00', 'Attended'),
(4, 4, 2, '2026-10-09 11:00:00', 'Attended'),
(5, 9, 2, '2026-10-09 11:30:00', 'Attended'),
(6, 14, 3, '2026-10-09 14:00:00', 'Attended'),
(7, 2, 5, '2026-10-10 15:00:00', 'Attended'),
(8, 5, 5, '2026-10-10 15:30:00', 'Attended'),
(9, 7, 5, '2026-10-10 16:00:00', 'Attended'),
(10, 2, 6, '2026-10-11 08:00:00', 'Attended'),
(11, 5, 6, '2026-10-11 08:30:00', 'Attended'),
(12, 13, 7, '2026-10-11 09:00:00', 'Attended'),
(13, 15, 8, '2026-10-12 10:00:00', 'Attended'),
(14, 19, 8, '2026-10-12 10:30:00', 'Attended'),
(15, 20, 8, '2026-10-12 11:00:00', 'Attended'),
(16, 4, 9, '2026-10-13 14:00:00', 'Enrolled'),
(17, 9, 9, '2026-10-13 14:30:00', 'Enrolled'),
(18, 14, 10, '2026-10-13 15:00:00', 'Enrolled'),
(19, 2, 11, '2026-10-14 08:00:00', 'Enrolled'),
(20, 5, 12, '2026-10-14 09:00:00', 'Enrolled'),
(21, 7, 12, '2026-10-14 10:00:00', 'Enrolled'),
(22, 13, 12, '2026-10-14 11:00:00', 'Enrolled'),
(23, 4, 13, '2026-10-15 16:00:00', 'Enrolled'),
(24, 9, 13, '2026-10-15 16:30:00', 'Enrolled'),
(25, 14, 13, '2026-10-15 17:00:00', 'Enrolled'),
(26, 2, 14, '2026-10-16 08:00:00', 'Enrolled'),
(27, 5, 15, '2026-10-16 09:00:00', 'Enrolled'),
(28, 15, 16, '2026-10-17 10:00:00', 'Enrolled'),
(29, 19, 16, '2026-10-17 10:30:00', 'Enrolled'),
(30, 4, 17, '2026-10-18 11:00:00', 'Enrolled'),
(31, 14, 18, '2026-10-18 14:00:00', 'Enrolled'),
(32, 2, 20, '2026-10-19 09:00:00', 'Enrolled'),
(33, 5, 20, '2026-10-19 10:00:00', 'Enrolled'),
(34, 7, 20, '2026-10-19 11:00:00', 'Cancelled'),
(35, 13, 20, '2026-10-19 12:00:00', 'Enrolled');

ALTER SEQUENCE class_enrollment_enrollment_id_seq RESTART WITH 36;

-- ----------------------------------------------------------------------------
-- 13. CA TẬP HUẤN LUYỆN VIÊN CÁ NHÂN 1-1 (pt_booking)
-- 35 ca tập, bao gồm: Completed, Scheduled, Cancelled, No_Show
-- HLV Dũng (id=5), HLV Trọng (id=7), HLV Chi (id=8) dạy nhiều giờ nhất
-- Chú ý: Hội viên 20 (id=20) KHÔNG CÓ TRONG BẢNG NÀY (phục vụ Query 7)
-- ----------------------------------------------------------------------------
INSERT INTO pt_booking (booking_id, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status) VALUES
-- HLV Đỗ Hùng Dũng (user_id = 5) - Nhiều ca Completed
(1, 11, 5, 1, '2026-10-01', '2026-10-01 08:00:00', '2026-10-01 09:30:00', 'Completed'),
(2, 11, 5, 1, '2026-10-03', '2026-10-03 08:00:00', '2026-10-03 09:30:00', 'Completed'),
(3, 11, 5, 1, '2026-10-05', '2026-10-05 08:00:00', '2026-10-05 09:30:00', 'Completed'),
(4, 11, 5, 1, '2026-10-07', '2026-10-07 08:00:00', '2026-10-07 09:30:00', 'Completed'),
(5, 18, 5, 8, '2026-10-02', '2026-10-02 10:00:00', '2026-10-02 11:30:00', 'Completed'),
(6, 18, 5, 8, '2026-10-04', '2026-10-04 10:00:00', '2026-10-04 11:30:00', 'Completed'),
(7, 18, 5, 8, '2026-10-06', '2026-10-06 10:00:00', '2026-10-06 11:30:00', 'Completed'),
(8, 21, 5, 11, '2026-10-02', '2026-10-02 14:00:00', '2026-10-02 15:30:00', 'Completed'),
(9, 21, 5, 11, '2026-10-04', '2026-10-04 14:00:00', '2026-10-04 15:30:00', 'Completed'),
(10, 21, 5, 11, '2026-10-06', '2026-10-06 14:00:00', '2026-10-06 15:30:00', 'Completed'),

-- HLV Vũ Đình Trọng (user_id = 7)
(11, 22, 7, 12, '2026-10-01', '2026-10-01 09:00:00', '2026-10-01 10:30:00', 'Completed'),
(12, 22, 7, 12, '2026-10-03', '2026-10-03 09:00:00', '2026-10-03 10:30:00', 'Completed'),
(13, 22, 7, 12, '2026-10-05', '2026-10-05 09:00:00', '2026-10-05 10:30:00', 'Completed'),
(14, 22, 7, 12, '2026-10-07', '2026-10-07 09:00:00', '2026-10-07 10:30:00', 'Completed'),
(15, 28, 7, 18, '2026-10-02', '2026-10-02 15:00:00', '2026-10-02 16:30:00', 'Completed'),
(16, 28, 7, 18, '2026-10-04', '2026-10-04 15:00:00', '2026-10-04 16:30:00', 'Completed'),
(17, 28, 7, 18, '2026-10-06', '2026-10-06 15:00:00', '2026-10-06 16:30:00', 'Completed'),

-- HLV Mai Thùy Chi (user_id = 8)
(18, 16, 8, 6, '2026-10-01', '2026-10-01 14:00:00', '2026-10-01 15:00:00', 'Completed'),
(19, 16, 8, 6, '2026-10-03', '2026-10-03 14:00:00', '2026-10-03 15:00:00', 'Completed'),
(20, 16, 8, 6, '2026-10-05', '2026-10-05 14:00:00', '2026-10-05 15:00:00', 'Completed'),
(21, 16, 8, 6, '2026-10-07', '2026-10-07 14:00:00', '2026-10-07 15:00:00', 'Completed'),

-- Ca tập bị Hủy hoặc Bỏ tập No-Show (phục vụ Query 6)
(22, 13, 5, 3, '2026-10-02', '2026-10-02 17:00:00', '2026-10-02 18:00:00', 'No_Show'),
(23, 13, 5, 3, '2026-10-05', '2026-10-05 17:00:00', '2026-10-05 18:00:00', 'Cancelled'),
(24, 16, 8, 6, '2026-10-08', '2026-10-08 14:00:00', '2026-10-08 15:00:00', 'Cancelled'),
(25, 21, 5, 11, '2026-10-08', '2026-10-08 14:00:00', '2026-10-08 15:30:00', 'No_Show'),

-- Ca tập Scheduled sắp tới trong tuần
(26, 11, 5, 1, '2026-10-14', '2026-10-14 08:00:00', '2026-10-14 09:30:00', 'Scheduled'),
(27, 18, 5, 8, '2026-10-14', '2026-10-14 10:00:00', '2026-10-14 11:30:00', 'Scheduled'),
(28, 21, 5, 11, '2026-10-14', '2026-10-14 14:00:00', '2026-10-14 15:30:00', 'Scheduled'),
(29, 22, 7, 12, '2026-10-15', '2026-10-15 09:00:00', '2026-10-15 10:30:00', 'Scheduled'),
(30, 28, 7, 18, '2026-10-15', '2026-10-15 15:00:00', '2026-10-15 16:30:00', 'Scheduled'),
(31, 16, 8, 6, '2026-10-16', '2026-10-16 14:00:00', '2026-10-16 15:00:00', 'Scheduled'),
(32, 13, 5, 3, '2026-10-16', '2026-10-16 17:00:00', '2026-10-16 18:00:00', 'Scheduled'),
(33, 11, 5, 1, '2026-10-17', '2026-10-17 08:00:00', '2026-10-17 09:30:00', 'Scheduled'),
(34, 18, 5, 8, '2026-10-17', '2026-10-17 10:00:00', '2026-10-17 11:30:00', 'Scheduled'),
(35, 22, 7, 12, '2026-10-18', '2026-10-18 09:00:00', '2026-10-18 10:30:00', 'Scheduled');

ALTER SEQUENCE pt_booking_booking_id_seq RESTART WITH 36;

-- ----------------------------------------------------------------------------
-- 14. GIỮ CHỖ THIẾT BỊ (equipment_reservation)
-- ----------------------------------------------------------------------------
INSERT INTO equipment_reservation (reservation_id, equipment_id, booking_id, class_id, start_time, end_time, status) VALUES
(1, 5, 1, NULL, '2026-10-01 08:00:00', '2026-10-01 09:30:00', 'Completed'),
(2, 6, 2, NULL, '2026-10-03 08:00:00', '2026-10-03 09:30:00', 'Completed'),
(3, 7, 3, NULL, '2026-10-05 08:00:00', '2026-10-05 09:30:00', 'Completed'),
(4, 5, 4, NULL, '2026-10-07 08:00:00', '2026-10-07 09:30:00', 'Completed'),
(5, 7, 5, NULL, '2026-10-02 10:00:00', '2026-10-02 11:30:00', 'Completed'),
(6, 6, 6, NULL, '2026-10-04 10:00:00', '2026-10-04 11:30:00', 'Completed'),
(7, 5, 7, NULL, '2026-10-06 10:00:00', '2026-10-06 11:30:00', 'Completed'),
(8, 9, 11, NULL, '2026-10-01 09:00:00', '2026-10-01 10:30:00', 'Completed'),
(9, 10, 12, NULL, '2026-10-03 09:00:00', '2026-10-03 10:30:00', 'Completed'),
(10, 9, 13, NULL, '2026-10-05 09:00:00', '2026-10-05 10:30:00', 'Completed'),
(11, 10, 14, NULL, '2026-10-07 09:00:00', '2026-10-07 10:30:00', 'Completed'),
(12, 12, 18, NULL, '2026-10-01 14:00:00', '2026-10-01 15:00:00', 'Completed'),
(13, 12, 19, NULL, '2026-10-03 14:00:00', '2026-10-03 15:00:00', 'Completed'),
(14, 12, 20, NULL, '2026-10-05 14:00:00', '2026-10-05 15:00:00', 'Completed'),
(15, 12, 21, NULL, '2026-10-07 14:00:00', '2026-10-07 15:00:00', 'Completed'),
(16, 11, NULL, 1, '2026-10-10 06:00:00', '2026-10-10 07:15:00', 'Completed'),
(17, 11, NULL, 2, '2026-10-10 18:00:00', '2026-10-10 19:15:00', 'Completed'),
(18, 12, NULL, 3, '2026-10-11 08:30:00', '2026-10-11 09:30:00', 'Completed'),
(19, 9, NULL, 5, '2026-10-12 07:00:00', '2026-10-12 08:00:00', 'Completed'),
(20, 10, NULL, 6, '2026-10-12 18:00:00', '2026-10-12 19:30:00', 'Completed'),
(21, 5, 26, NULL, '2026-10-14 08:00:00', '2026-10-14 09:30:00', 'Reserved'),
(22, 7, 27, NULL, '2026-10-14 10:00:00', '2026-10-14 11:30:00', 'Reserved'),
(23, 6, 28, NULL, '2026-10-14 14:00:00', '2026-10-14 15:30:00', 'Reserved'),
(24, 9, 29, NULL, '2026-10-15 09:00:00', '2026-10-15 10:30:00', 'Reserved'),
(25, 12, 31, NULL, '2026-10-16 14:00:00', '2026-10-16 15:00:00', 'Reserved');

ALTER SEQUENCE equipment_reservation_reservation_id_seq RESTART WITH 26;

-- ----------------------------------------------------------------------------
-- 15. NHẬT KÝ BẢO TRÌ SỬA CHỮA THIẾT BỊ (maintenance_log)
-- Bao gồm các ca đang sửa In_Progress (phục vụ Query 4) và ca đã sửa Completed
-- ----------------------------------------------------------------------------
INSERT INTO maintenance_log (maintenance_id, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status) VALUES
-- Ca 1: Máy chạy bộ 3 hỏng cảm ứng - Đang sửa In_Progress (Kỹ thuật viên Phạm Quốc - id=4)
(1, 3, 4, 'Màn hình cảm ứng Skillrun bị đơ cảm ứng và lỗi motor nâng độ dốc', '2026-10-05 08:00:00', NULL, 3500000.00, 'In_Progress'),
-- Ca 2: Giường Pilates 13 đứt lò xo kháng lực - Đang sửa In_Progress
(2, 13, 4, 'Đứt 2 dây lò xo đỏ cường lực và rách đệm kê đầu vai', '2026-10-08 09:30:00', NULL, 1200000.00, 'In_Progress'),
-- Ca 3: Sàn đài boxing 15 bị lỏng cáp thép - Đang sửa In_Progress
(3, 15, 4, 'Căng lại hệ thống dây đai võ đài và thay mút bọc 4 góc bảo hộ', '2026-10-09 13:00:00', NULL, 4800000.00, 'In_Progress'),
-- Các ca đã hoàn thành trong quá khứ
(4, 1, 4, 'Bảo dưỡng tra dầu băng tải định kỳ và hiệu chuẩn cảm biến nhịp tim', '2026-08-10 08:00:00', '2026-08-10 11:30:00', 450000.00, 'Completed'),
(5, 2, 4, 'Thay thế thảm chạy bộ ma sát cao Technogym chính hãng', '2026-07-15 09:00:00', '2026-07-15 15:00:00', 2800000.00, 'Completed'),
(6, 4, 4, 'Cân chỉnh dây curoa truyền động và vệ sinh bánh đà kháng lực gió', '2026-06-20 14:00:00', '2026-06-20 16:30:00', 300000.00, 'Completed'),
(7, 5, 4, 'Thay chốt hãm an toàn trục ray trượt Smith Machine', '2026-05-12 10:00:00', '2026-05-12 11:30:00', 850000.00, 'Completed'),
(8, 7, 4, 'Thay 2 sợi cáp chịu lực 6mm bọc nylon bọc dàn ròng rọc', '2026-04-18 08:30:00', '2026-04-18 12:00:00', 1600000.00, 'Completed'),
(9, 9, 4, 'Thay dây xích kéo máy chèo và vệ sinh cảm biến vòng tua PM5', '2026-03-25 15:00:00', '2026-03-25 17:00:00', 650000.00, 'Completed'),
(10, 12, 4, 'Bôi trơn bánh xe trượt rãnh nhôm và cân chỉnh thanh chân đế', '2026-02-14 09:00:00', '2026-02-14 10:30:00', 250000.00, 'Completed'),
(11, 14, 4, 'Gia cố lại móc treo xích trần bê tông chống rung lắc bao cát', '2026-01-20 13:30:00', '2026-01-20 15:00:00', 400000.00, 'Completed'),
(12, 3, 4, 'Sửa lỗi board mạch nguồn biến tần đợt 1', '2026-06-05 08:00:00', '2026-06-05 16:00:00', 1500000.00, 'Completed');

ALTER SEQUENCE maintenance_log_maintenance_id_seq RESTART WITH 13;
