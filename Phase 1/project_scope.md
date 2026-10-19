# 1. Giới thiệu và phạm vi dự án

**Gym Membership & Personal Training Planner** là dự án cơ sở dữ liệu quan hệ nhằm quản lý hoạt động của phòng tập thể hình trên một nền tảng thống nhất.

Hệ thống tập trung vào quản lý tài khoản và hồ sơ hội viên, gói tập và đăng ký hội viên, lịch lớp học nhóm, lịch huấn luyện cá nhân (Personal Training – PT), thiết bị phòng tập, bảo trì thiết bị, hóa đơn và thanh toán. Hệ thống cũng hướng đến việc bảo đảm tính toàn vẹn dữ liệu và phân quyền truy cập theo vai trò.

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

Mô hình dữ liệu logic của dự án xoay quanh các nhóm thực thể sau. Tên bảng dưới đây là tên tham chiếu theo mô hình dự án; khi triển khai, cần đối chiếu với tệp DDL hiện hành để bảo đảm tên và cấu trúc bảng khớp chính xác.

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
| Bảng hóa đơn/thanh toán | Lưu khoản phải thu, trạng thái thanh toán và lịch sử giao dịch; tên bảng thực tế cần theo DDL hiện hành |

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
- Hỗ trợ kiểm tra trạng thái đăng ký khi xử lý các nghiệp vụ liên quan, nếu quy tắc này được triển khai trong hệ thống.

### Quản lý lịch lớp học nhóm

- Lưu lịch lớp, thời gian tổ chức và các thông tin cần thiết của lớp.
- Ghi nhận việc hội viên đăng ký tham gia lớp.
- Kiểm soát số lượng đăng ký theo sức chứa lớp nếu trường sức chứa và quy tắc này có trong lược đồ.
- Ngăn đăng ký trùng lặp của cùng một hội viên cho cùng một lớp khi phù hợp với quy tắc nghiệp vụ.
- Quản lý trạng thái lịch học và đăng ký theo các giá trị được quy định trong DDL.

### Quản lý lịch huấn luyện cá nhân (PT)

- Lưu thông tin đặt buổi tập giữa hội viên và huấn luyện viên.
- Ghi nhận ngày tập, giờ bắt đầu, giờ kết thúc và trạng thái buổi tập theo cấu trúc dữ liệu.
- Kiểm tra tính hợp lệ của khoảng thời gian đặt lịch.
- Ngăn các lịch PT đang có hiệu lực bị chồng lấn đối với cùng một huấn luyện viên.
- Nếu quy tắc nghiệp vụ yêu cầu, ngăn một hội viên có nhiều buổi PT bị chồng lấn.
- Theo dõi trạng thái buổi tập theo các giá trị được định nghĩa trong hệ thống.

### Quản lý thiết bị và bảo trì

- Quản lý danh mục thiết bị, thông tin nhận dạng và trạng thái sử dụng.
- Ghi nhận việc đặt hoặc sử dụng thiết bị nếu được hỗ trợ trong mô hình dữ liệu.
- Lưu lịch sử bảo trì, sửa chữa, thời gian thực hiện và chi phí nếu có các thuộc tính tương ứng.
- Hạn chế đặt hoặc sử dụng thiết bị trong thời gian thiết bị đang bảo trì hoặc không khả dụng.
- Duy trì liên kết giữa hồ sơ thiết bị và các bản ghi bảo trì để phục vụ tra cứu lịch sử.

### Quản lý hóa đơn và thanh toán

- Lưu thông tin khoản phí phát sinh từ việc đăng ký gói hoặc sử dụng dịch vụ theo phạm vi của cơ sở dữ liệu.
- Ghi nhận số tiền, thời điểm thanh toán, phương thức và trạng thái giao dịch nếu các trường này có trong lược đồ.
- Liên kết giao dịch với tài khoản hội viên hoặc hóa đơn tương ứng bằng khóa ngoại.
- Kiểm tra các giá trị tiền tệ hợp lệ, chẳng hạn không cho phép số tiền âm khi nghiệp vụ không hỗ trợ trường hợp đó.
- Bảo đảm trạng thái thanh toán phản ánh nhất quán dữ liệu giao dịch theo quy tắc đã triển khai.

### Bảo mật và phân quyền truy cập

- Xác định vai trò người dùng theo thiết kế cơ sở dữ liệu, chẳng hạn quản trị viên, nhân viên, huấn luyện viên và hội viên.
- Gán quyền thao tác theo vai trò, nếu các bảng vai trò và quyền được triển khai trong lược đồ.
- Chỉ cấp quyền đọc hoặc ghi cần thiết cho từng nhóm người dùng.
- Hạn chế quyền chỉnh sửa dữ liệu quan trọng đối với những vai trò không có trách nhiệm nghiệp vụ tương ứng.
- Duy trì khả năng kiểm tra dữ liệu và lịch sử nghiệp vụ trong phạm vi mà hệ thống hỗ trợ.

## 1.4. Quy tắc nghiệp vụ và yêu cầu toàn vẹn dữ liệu

Các quy tắc dưới đây là yêu cầu thiết kế cần được đối chiếu với DDL, dữ liệu mẫu và các truy vấn hoặc thủ tục đã triển khai trước khi xem là đã hoàn tất:

- **Khóa và quan hệ:** Mỗi bảng cần có khóa chính phù hợp; các quan hệ giữa tài khoản, hồ sơ, gói dịch vụ, lịch tập, thiết bị và giao dịch cần được bảo vệ bằng khóa ngoại.
- **Tính duy nhất:** Những dữ liệu cần duy nhất, chẳng hạn email tài khoản hoặc cặp hội viên–lớp học, cần có ràng buộc duy nhất nếu phù hợp với nghiệp vụ.
- **Thời gian:** Thời điểm kết thúc của một buổi tập phải sau thời điểm bắt đầu.
- **Lịch PT:** Các buổi đặt lịch đang có hiệu lực không được chồng lấn đối với cùng một huấn luyện viên; các quy tắc tương tự cho hội viên cần được áp dụng nếu thuộc yêu cầu dự án.
- **Sức chứa lớp:** Số lượng hội viên đăng ký không vượt quá sức chứa được cấu hình, nếu hệ thống có quản lý sức chứa.
- **Trạng thái:** Trạng thái tài khoản, đăng ký, lớp học, đặt lịch và thanh toán chỉ nhận các giá trị hợp lệ đã quy định.
- **Thiết bị:** Thiết bị đang bảo trì hoặc không khả dụng không nên được đặt hay sử dụng trong khoảng thời gian tương ứng.
- **Giá trị số:** Giá, số tiền thanh toán, thời lượng và số lượng cần tuân theo miền giá trị hợp lệ của nghiệp vụ.
- **Lịch sử dữ liệu:** Không xóa hoặc sửa dữ liệu theo cách làm mất liên kết với các giao dịch đã phát sinh, trừ khi quy tắc lưu trữ cho phép.
- **Phân quyền:** Người dùng chỉ được thực hiện các thao tác phù hợp với vai trò và quyền đã cấp.

Các quy tắc cần được thực thi bằng các cơ chế phù hợp như `PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `NOT NULL`, chỉ mục, trigger hoặc giao dịch. Không nên ghi nhận một quy tắc là đã được bảo đảm nếu chưa có ràng buộc hoặc logic thực thi tương ứng.

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
- Kết quả kiểm thử các ràng buộc quan trọng, đặc biệt là khóa ngoại, tính duy nhất, trạng thái và xung đột lịch.
- Hướng dẫn triển khai và chạy các tệp SQL theo đúng thứ tự phụ thuộc.

---