-- ============================================================================
-- GYM MEMBERSHIP & PERSONAL TRAINING PLANNER | NHÓM G9 | INT1313
-- Dữ liệu mẫu đã tách từ 02_mock_data_fixed.sql
-- Hệ quản trị: PostgreSQL 16+
-- Chạy 01_schema_ddl_fixed.sql trước, sau đó chạy các file mock data theo thứ tự
-- số thứ tự trong tên file (01 -> 08). Không chạy lại từng file trên DB đã có
-- dữ liệu nếu chưa dọn dữ liệu cũ, vì các INSERT dùng ID cố định.
-- ============================================================================

-- Nội dung: Tài khoản, vai trò người dùng và hồ sơ member/trainer/staff.

-- 5. TÀI KHOẢN NGƯỜI DÙNG (user_account)
-- Gồm: 2 Admin (1-2), 2 Staff (3-4), 6 Trainers (5-10), 20 Members thủ công (11-30)
-- và 2.970 Members sinh tự động (31-3000) => tổng cộng 3.000 tài khoản (xem khối 5b ở cuối file).
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
-- 5b. SINH TỰ ĐỘNG 2.970 HỘI VIÊN (user_id 31..3000) - đáp ứng yêu cầu >= 3000 user
-- ----------------------------------------------------------------------------
-- Dữ liệu hoàn toàn XÁC ĐỊNH (không dùng random()): mọi thuộc tính suy ra từ id bằng
-- phép chia lấy dư trên các mảng họ / tên đệm / tên Việt Nam, nên nạp lại luôn ra cùng kết quả.
--  * email : slug ASCII (tên.họ) + id, luân phiên @gmail.com / @yahoo.com / @outlook.com
--  * phone : '0921' + id 6 chữ số  (duy nhất, tiền tố 0921 chưa dùng ở dữ liệu thủ công/test)
--  * dob   : 1970-01-01 + (id*37 mod 11000) ngày => sinh trước ~2000-01 nên luôn >= 18 tuổi (BR-03 cần >= 12)
--  * status: id chia hết 50 -> 'Suspended', chia hết 25 -> 'Inactive', còn lại 'Active'
--  * emergency_contact: "<quan hệ>: <sđt 0922xxxxxx>" giống định dạng các dòng thủ công
INSERT INTO user_account (user_id, full_name, email, phone, dob, emergency_contact, password_hash, status)
SELECT
    g.id,
    g.family || ' ' || g.middle || ' ' || g.given,
    -- slug ASCII: bỏ dấu tiếng Việt bằng translate(), ghép tên + họ + id
    translate(lower(g.given || '.' || g.family), 'àáảãạăằắẳẵặâầấẩẫậèéẻẽẹêềếểễệìíỉĩịòóỏõọôồốổỗộơờớởỡợùúủũụưừứửữựỳýỷỹỵđ',
                                                  'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd')
        || g.id || (ARRAY['@gmail.com', '@yahoo.com', '@outlook.com'])[g.id % 3 + 1],
    '0921' || lpad(g.id::text, 6, '0'),
    DATE '1970-01-01' + ((g.id * 37) % 11000),
    (ARRAY['Mẹ', 'Bố', 'Vợ', 'Chồng', 'Anh trai', 'Chị', 'Em', 'Bạn'])[g.id % 8 + 1]
        || ': 0922' || lpad(g.id::text, 6, '0'),
    '$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g',
    CASE WHEN g.id % 50 = 0 THEN 'Suspended'
         WHEN g.id % 25 = 0 THEN 'Inactive'
         ELSE 'Active' END
FROM (
    SELECT
        id,
        (ARRAY['Nguyễn', 'Trần', 'Lê', 'Phạm', 'Hoàng', 'Huỳnh', 'Phan', 'Vũ', 'Võ', 'Đặng',
               'Bùi', 'Đỗ', 'Hồ', 'Ngô', 'Dương', 'Lý', 'Đinh', 'Trịnh', 'Mai', 'Tạ'])[(id * 7) % 20 + 1] AS family,
        (ARRAY['Văn', 'Thị', 'Minh', 'Quốc', 'Hữu', 'Ngọc', 'Thanh', 'Đức', 'Thu', 'Hoài',
               'Gia', 'Xuân', 'Kim', 'Bảo', 'Tuấn'])[(id * 3) % 15 + 1] AS middle,
        (ARRAY['An', 'Bình', 'Cường', 'Dũng', 'Hà', 'Hải', 'Hạnh', 'Hiếu', 'Hùng', 'Hương',
               'Khoa', 'Lan', 'Linh', 'Long', 'Mai', 'Nam', 'Nga', 'Phong', 'Phúc', 'Quân',
               'Quỳnh', 'Sơn', 'Thảo', 'Thịnh', 'Trang', 'Trung', 'Tú', 'Vy', 'Yến', 'Đạt'])[(id + id / 30) % 30 + 1] AS given
    FROM generate_series(31, 3000) AS id
) AS g;

-- Gán vai trò Member (role_id = 3) cho 2.970 hội viên sinh tự động
INSERT INTO user_role (user_id, role_id)
SELECT id, 3 FROM generate_series(31, 3000) AS id;

-- Hồ sơ hội viên (member_profile) cho 2.970 hội viên sinh tự động - ghi chú sức khỏe lấy theo id mod 8
INSERT INTO member_profile (user_id, health_notes)
SELECT id,
       (ARRAY['Thể lực bình thường, muốn duy trì sức khỏe tổng quát',
              'Muốn giảm mỡ và cải thiện sức bền tim mạch',
              'Người mới bắt đầu, cần hướng dẫn kỹ thuật cơ bản',
              'Tiền sử đau lưng nhẹ, tránh các bài tập tạ nặng',
              'Mục tiêu tăng cơ, lịch tập 4 buổi mỗi tuần',
              'Huyết áp hơi cao, cần theo dõi cường độ tập',
              'Tập Yoga/Pilates để cải thiện độ dẻo dai và tư thế',
              'Từng chấn thương đầu gối, cần chế độ tập ít áp lực'])[id % 8 + 1]
FROM generate_series(31, 3000) AS id;

-- Đặt lại sequence sau TẤT CẢ các INSERT user_id cố định / sinh tự động ở trên
ALTER SEQUENCE user_account_user_id_seq RESTART WITH 3001;
