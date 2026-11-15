# 1. Giới thiệu và phạm vi dự án

**Gym Membership & Personal Training Planner** là dự án cơ sở dữ liệu quan hệ nhằm quản lý hoạt động của phòng tập thể hình trên một nền tảng thống nhất.

Hệ thống tập trung vào quản lý tài khoản và hồ sơ hội viên, gói tập và đăng ký hội viên, lịch lớp học nhóm, lịch huấn luyện cá nhân (Personal Training – PT), thiết bị phòng tập, bảo trì thiết bị, hóa đơn và thanh toán. Hệ thống bảo đảm tính toàn vẹn dữ liệu bằng ràng buộc, trigger và thủ tục ở mức CSDL, và phân quyền truy cập theo vai trò bằng 5 role PostgreSQL (`gym_role_*`).

Yêu cầu chi tiết xem [requirements_specification.md](requirements_specification.md) (yêu cầu người dùng UR, yêu cầu chức năng FR, phi chức năng NFR, ma trận truy vết); quy tắc nghiệp vụ và cơ chế thực thi xem [business_rules.md](business_rules.md).

Dự án được thiết kế để hỗ trợ lưu trữ và quản lý dữ liệu có cấu trúc, hạn chế xung đột lịch, theo dõi trạng thái giao dịch và giữ lại lịch sử cần thiết cho việc kiểm tra, đối soát.

## 1.1. Mục tiêu hệ thống

Dự án hướng đến các mục tiêu sau:

1. Quản lý tập trung tài khoản người dùng và hồ sơ tương ứng với các vai trò trong phòng tập.
2. Quản lý gói hội viên, thời hạn đăng ký và trạng thái sử dụng dịch vụ.
3. Theo dõi thông tin thanh toán và lịch sử giao dịch liên quan đến dịch vụ phòng tập.
4. Quản lý lịch lớp học nhóm và việc đăng ký tham gia của hội viên.
5. Hạn chế việc một huấn luyện viên cá nhân bị đặt lịch trùng trong cùng khoảng thời gian.
6. Quản lý danh mục thiết bị, lịch đặt hoặc sử dụng thiết bị và thông tin bảo trì.
7. Hạn chế việc đặt lịch vào thời gian tài nguyên không sẵn sàng.
8. Áp dụng khóa chính, khóa ngoại, ràng buộc duy nhất, ràng buộc kiểm tra và cơ chế kiểm soát ở cơ sở dữ liệu khi phù hợp.
9. Phân quyền theo vai trò và nguyên tắc chỉ cấp quyền tối thiểu cần thiết.
10. Duy trì tính nhất quán của dữ liệu và lưu giữ lịch sử nghiệp vụ cần thiết.

## 1.2. Mô hình dữ liệu cốt lõi

Mô hình dữ liệu logic của dự án gồm 18 bảng, được định nghĩa trong `Phase 3/01_schema_ddl.sql`, xoay quanh các nhóm thực thể sau.

| Thực thể | Trách nhiệm |
|---|---|
| `USER_ACCOUNT` | Lưu thông tin tài khoản người dùng |
| `ROLE` | Danh mục vai trò trong hệ thống |
| `USER_ROLE` | Liên kết tài khoản với vai trò |
| `PERMISSION` | Danh mục quyền thao tác |
| `ROLE_PERMISSION` | Liên kết vai trò với quyền |
| `MEMBER_PROFILE` | Lưu hồ sơ hội viên |
| `TRAINER_PROFILE` | Lưu hồ sơ và chuyên môn huấn luyện viên |
| `STAFF_PROFILE` | Lưu hồ sơ nhân viên |
| `MEMBERSHIP_PLAN` | Danh mục gói hội viên hoặc gói dịch vụ |
| `MEMBER_SUBSCRIPTION` | Thông tin đăng ký gói và thời hạn sử dụng |
| `CLASS_SCHEDULE` | Lịch tổ chức lớp tập nhóm |
| `CLASS_ENROLLMENT` | Đăng ký tham gia lớp của hội viên |
| `PT_BOOKING` | Lịch đặt buổi huấn luyện cá nhân |
| `EQUIPMENT` | Danh mục thiết bị phòng tập |
| `EQUIPMENT_RESERVATION` | Thông tin đặt hoặc sử dụng thiết bị |
| `MAINTENANCE_LOG` | Lịch sử bảo trì, sửa chữa thiết bị |
| `BILLING_LOG` | Hóa đơn/thanh toán bất biến: khoản phải thu, trạng thái thanh toán, chu kỳ tính phí |
| `FACILITIES_ROOM` | Danh mục phòng tập / khu vực |

## 1.3. Phạm vi thực hiện

### Quản lý tài khoản và hồ sơ người dùng

- Lưu thông tin tài khoản, thông tin liên hệ và trạng thái tài khoản.
- Hỗ trợ các nhóm người dùng như quản trị viên, nhân viên, huấn luyện viên và hội viên theo thiết kế dữ liệu.
- Liên kết tài khoản với vai trò và hồ sơ chuyên biệt tương ứng.
- Kiểm soát quyền truy cập theo vai trò và nhiệm vụ.
- Hạn chế xóa dữ liệu có liên quan đến giao dịch hoặc lịch sử nghiệp vụ khi việc xóa có thể làm mất tính toàn vẹn dữ liệu.

### Quản lý gói hội viên và đăng ký dịch vụ

- Quản lý danh mục gói tập, thông tin thời hạn, giá và quyền lợi được mô tả trong dữ liệu dự án.
- Ghi nhận hội viên đăng ký gói, ngày bắt đầu, ngày kết thúc và trạng thái đăng ký.
- Liên kết đăng ký dịch vụ với hội viên và gói tương ứng bằng các khóa quan hệ.
- Kiểm tra trạng thái đăng ký khi xử lý nghiệp vụ liên quan: hợp đồng chỉ `Active` sau khi thanh toán (BR-07), mỗi hội viên tối đa một hợp đồng `Active` (BR-05), tự gia hạn và tạm ngưng sau ân hạn (BR-24, thủ tục `sp_process_subscription_renewals`).

### Quản lý lịch lớp học nhóm

- Lưu lịch lớp, thời gian tổ chức và các thông tin cần thiết của lớp.
- Ghi nhận việc hội viên đăng ký tham gia lớp.
- Kiểm soát số lượng đăng ký theo sức chứa lớp (`max_capacity`, `current_enrolled`, BR-14).
- Ngăn đăng ký trùng lặp của cùng một hợp đồng cho cùng một lớp (`uq_enrollment_subscription_class`).
- Quản lý trạng thái lịch học và đăng ký theo các giá trị được quy định trong DDL.

### Quản lý lịch huấn luyện cá nhân (PT)

- Lưu thông tin đặt buổi tập giữa hội viên và huấn luyện viên.
- Ghi nhận ngày tập, giờ bắt đầu, giờ kết thúc và trạng thái buổi tập theo cấu trúc dữ liệu.
- Kiểm tra tính hợp lệ của khoảng thời gian đặt lịch.
- Ngăn các lịch PT đang có hiệu lực bị chồng lấn đối với cùng một huấn luyện viên.
- Ngăn một hội viên có nhiều buổi PT hoặc lớp bị chồng lấn (BR-16).
- Ca PT diễn ra ở khu tập tự do, không gắn phòng; chỉ ca đặt khi hợp đồng `Active` còn buổi (BR-18); buổi tập bị trừ khi hoàn thành, bỏ tập hoặc hủy muộn dưới 24 giờ (BR-25).
- Theo dõi trạng thái buổi tập theo các giá trị được định nghĩa trong hệ thống.

### Quản lý thiết bị và bảo trì

- Quản lý danh mục thiết bị, thông tin nhận dạng và trạng thái sử dụng.
- Ghi nhận việc giữ chỗ thiết bị cho ca PT hoặc lớp (`equipment_reservation`), không cho trùng giờ (BR-21).
- Lưu lịch sử bảo trì, sửa chữa, thời gian thực hiện và chi phí (BR-20).
- Hạn chế đặt hoặc sử dụng thiết bị trong thời gian thiết bị đang bảo trì hoặc không khả dụng.
- Duy trì liên kết giữa hồ sơ thiết bị và các bản ghi bảo trì để phục vụ tra cứu lịch sử.

### Quản lý hóa đơn và thanh toán

- Lưu thông tin khoản phí phát sinh từ việc đăng ký gói hoặc sử dụng dịch vụ theo phạm vi của cơ sở dữ liệu.
- Ghi nhận số tiền, ngày thanh toán, phương thức, trạng thái và chu kỳ tính phí của hóa đơn (BR-08, BR-09); hóa đơn bất biến (BR-10).
- Liên kết hóa đơn với hợp đồng bằng khóa ngoại `fk_billing_subscription`.
- Kiểm tra giá trị tiền tệ hợp lệ (`amount > 0`).
- Bảo đảm trạng thái thanh toán nhất quán với trạng thái hợp đồng bằng trigger `trg_activate_on_payment_*`.

### Bảo mật và phân quyền truy cập

- Xác định 5 vai trò: Admin, Receptionist, Trainer, Technician, Member.
- Gán quyền thao tác theo vai trò qua các bảng `role`, `user_role`, `permission`, `role_permission` và `GRANT`/`REVOKE` trong `Phase 3/08_rbac_security.sql`.
- Chỉ cấp quyền đọc hoặc ghi cần thiết cho từng nhóm người dùng; cột `password_hash` không đọc được bởi role ứng dụng.
- Hạn chế quyền chỉnh sửa dữ liệu quan trọng đối với những vai trò không có trách nhiệm nghiệp vụ tương ứng.
- Truy vết người thực hiện giao dịch qua `created_by_user_id` (BR-23, phụ thuộc ứng dụng đặt `app.current_user_id`).
- Mã hóa dữ liệu lưu trữ và sao lưu là yêu cầu triển khai, chưa có trong bản Docker demo (NFR-SEC-03, NFR-AVL-01).

## 1.4. Quy tắc nghiệp vụ và yêu cầu toàn vẹn dữ liệu

Các quy tắc dưới đây đã được triển khai trong DDL, trigger và thủ tục; danh sách đầy đủ 26 quy tắc kèm tên đối tượng thực thi nằm trong [business_rules.md](business_rules.md):

- **Khóa và quan hệ:** Mỗi bảng có khóa chính; các quan hệ giữa tài khoản, hồ sơ, gói dịch vụ, lịch tập, thiết bị và giao dịch được bảo vệ bằng khóa ngoại.
- **Tính duy nhất:** Những dữ liệu cần duy nhất, chẳng hạn email tài khoản hoặc cặp hợp đồng–lớp học, đều có ràng buộc `UNIQUE`.
- **Thời gian:** Thời điểm kết thúc của một buổi tập phải sau thời điểm bắt đầu.
- **Lịch PT:** Các buổi đặt lịch đang có hiệu lực không được chồng lấn đối với cùng một huấn luyện viên hoặc cùng một hội viên (`EXCLUDE USING gist` và trigger).
- **Sức chứa lớp:** Số lượng hội viên đăng ký không vượt quá sức chứa được cấu hình (`chk_class_enrollment_limit`).
- **Trạng thái:** Trạng thái tài khoản, đăng ký, lớp học, đặt lịch và thanh toán chỉ nhận các giá trị hợp lệ đã quy định.
- **Thiết bị:** Thiết bị đang bảo trì hoặc không khả dụng không được xếp lịch hay giữ chỗ trong khoảng thời gian tương ứng (trigger BR-19, BR-21).
- **Giá trị số:** Giá, số tiền thanh toán, thời lượng và số lượng cần tuân theo miền giá trị hợp lệ của nghiệp vụ.
- **Lịch sử dữ liệu:** Không xóa hoặc sửa dữ liệu theo cách làm mất liên kết với các giao dịch đã phát sinh, trừ khi quy tắc lưu trữ cho phép.
- **Phân quyền:** Người dùng chỉ được thực hiện các thao tác phù hợp với vai trò và quyền đã cấp.

Các quy tắc được thực thi bằng `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`, `EXCLUDE`, chỉ mục duy nhất từng phần, trigger và thủ tục. Hai quy tắc chỉ thực thi một phần (BR-10, BR-23) được nêu rõ giới hạn trong `business_rules.md`.

## 1.5. Ngoài phạm vi dự án

Trừ khi được bổ sung rõ ràng vào yêu cầu hoặc mô hình dữ liệu, các nội dung sau không được xem là phạm vi cốt lõi:

- Phát triển ứng dụng di động hoàn chỉnh hoặc giao diện người dùng thương mại.
- Tích hợp trực tiếp với cổng thanh toán bên thứ ba hoặc ngân hàng thật.
- Kết nối với thiết bị đeo, máy quét hoặc phần cứng phòng tập theo thời gian thực.
- Xây dựng hệ thống kế toán, thuế hoặc quản trị doanh nghiệp toàn diện.
- Tư vấn y tế, chẩn đoán bệnh hoặc xây dựng hệ thống hồ sơ y tế.
- Triển khai hạ tầng nhiều chi nhánh hoặc nhiều phòng tập nếu chưa có trong yêu cầu.
- Các báo cáo phân tích nâng cao hoặc mô hình dự đoán không thuộc yêu cầu cơ sở dữ liệu hiện tại.

## 1.6. Sản phẩm bàn giao dự kiến

- Lược đồ cơ sở dữ liệu và các tệp DDL tạo bảng, khóa và ràng buộc.
- Các tệp SQL dữ liệu mẫu phục vụ kiểm thử.
- Các truy vấn hoặc thao tác SQL minh họa những nghiệp vụ chính.
- Mô hình dữ liệu ER/EER hoặc sơ đồ quan hệ theo yêu cầu môn học.
- Tài liệu mô tả phạm vi, thực thể, quan hệ và các quy tắc nghiệp vụ.
- Kết quả kiểm thử ràng buộc (`05_constraint_test_cases.sql`), phân quyền (`09_rbac_test_cases.sql`) và hiệu năng (`06_performance_test_cases.sql`).
- Hướng dẫn triển khai và chạy các tệp SQL theo đúng thứ tự phụ thuộc: `01_schema_ddl` → `02_mock_data/01..08` → `04_triggers_views` → `08_rbac_security`.
- Đặc tả yêu cầu phần mềm: [requirements_specification.md](requirements_specification.md).

---