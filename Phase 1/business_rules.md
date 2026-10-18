# Business Rules & Constraints (Quy tắc Nghiệp vụ & Ràng buộc)

Để duy trì tính nhất quán của cơ sở dữ liệu và loại bỏ các trạng thái dữ liệu sai lệch, hệ thống áp dụng 26 quy tắc nghiệp vụ khai báo và thủ tục (BR-01 đến BR-26) được phân loại theo các cấp độ toàn vẹn cấu trúc:

## Bảng Tóm tắt Quy tắc Nghiệp vụ (Business Rules Summary Matrix)

| Mã Quy tắc | Tên Quy tắc | Mô tả Chi tiết Nghiệp vụ | Cơ chế Thực thi |
| :--- | :--- | :--- | :--- |
| **BR-01** | Mã Hội viên Duy nhất | Mỗi `HỘI VIÊN` (`MEMBER`) phải có một mã định danh `member_id` duy nhất trên toàn hệ thống. | `PRIMARY KEY` |
| **BR-02** | Liên hệ Duy nhất | Email và Số điện thoại (`email`, `phone`) của `HỘI VIÊN` là thông tin duy nhất, không được phép trùng lặp. | Ràng buộc `UNIQUE` |
| **BR-03** | Độ tuổi Tối thiểu | Độ tuổi của `HỘI VIÊN` khi đăng ký hồ sơ phải từ 12 tuổi trở lên (`dob <= CURRENT_DATE - 12 năm`). | Ràng buộc `CHECK` |
| **BR-04** | Tính Hợp lệ Gói tập | Mỗi `GÓI TẬP` (`MEMBERSHIP_PLAN`) phải có thời hạn tính theo tháng (`duration_months > 0`) và đơn giá gói (`price >= 0`). | Ràng buộc `CHECK` |
| **BR-05** | Một Hợp đồng Kích hoạt | Một `HỘI VIÊN` có thể đăng ký nhiều `HỢP ĐỒNG ĐĂNG KÝ` (`MEMBER_SUBSCRIPTION`) theo thời gian, nhưng tại một thời điểm chỉ có tối đa 1 hợp đồng ở trạng thái `Active`. | DB Trigger / Partial Index |
| **BR-06** | Thứ tự Thời gian Hợp đồng | Trong một `HỢP ĐỒNG ĐĂNG KÝ`, ngày kết thúc hợp đồng phải lớn hơn hoặc bằng ngày bắt đầu (`end_date >= start_date`). | Ràng buộc `CHECK` |
| **BR-07** | Kích hoạt Hợp đồng | Trạng thái hợp đồng đăng ký gói (`sub_status`) chỉ được kích hoạt sang `Active` khi hóa đơn thanh toán tương ứng đã hoàn tất. | DB Trigger |
| **BR-08** | Duy nhất Hóa đơn Chu kỳ | Mỗi chu kỳ gia hạn hợp đồng chỉ được phép phát sinh duy nhất 1 `HÓA ĐƠN THANH TOÁN` (`BILLING_LOG`) (ràng buộc duy nhất trên cặp `subscription_id` + chu kỳ tính phí). | Ràng buộc `UNIQUE` / Index |
| **BR-09** | Hóa đơn Thanh toán Hợp lệ | Mỗi `HÓA ĐƠN THANH TOÁN` phải có mã hóa đơn (`invoice_no`) duy nhất và số tiền thanh toán lớn hơn 0 (`amount > 0`). | Ràng buộc `UNIQUE` & `CHECK` |
| **BR-10** | Dữ liệu Thanh toán Bất biến | Các bản ghi thanh toán thành công là dữ liệu bất biến (Immutable Log), hệ thống tuyệt đối không cho phép sửa đổi hoặc xóa. | Trigger `BEFORE UPDATE/DELETE` |
| **BR-11** | Định danh Huấn luyện viên | Mỗi `HUẤN LUYỆN VIÊN` (`TRAINER`) có mã định danh `trainer_id`, `phone` và `email` duy nhất. | `PRIMARY KEY` & `UNIQUE` |
| **BR-12** | Không Trùng lịch HLV | Một `HUẤN LUYỆN VIÊN` không được phép có 2 lịch hẹn (lớp học nhóm `CLASS_SCHEDULE` hoặc ca PT `PT_BOOKING`) trùng hoặc chồng chéo khoảng thời gian (Overlapping Time Intervals). | DB Trigger / `EXCLUDE USING gist` |
| **BR-13** | Giới hạn Sức chứa Phòng | Mỗi `PHÒNG TẬP / KHU VỰC` (`FACILITIES_ROOMS`) có sức chứa tối đa quy định (`max_capacity > 0`). | Ràng buộc `CHECK` |
| **BR-14** | Giới hạn Đăng ký Lớp | Số lượng `HỘI VIÊN` đăng ký tham gia một lớp học nhóm (`current_enrolled`) không được vượt quá sức chứa tối đa (`max_capacity`) của lớp/phòng đó. | DB Trigger & Ràng buộc `CHECK` |
| **BR-15** | Không Trùng lịch Phòng tập | Một `PHÒNG TẬP / KHU VỰC` không được đồng thời xếp 2 sự kiện (lớp học nhóm hoặc ca PT 1-1) tại cùng một thời điểm. | DB Trigger / `EXCLUDE USING gist` |
| **BR-16** | Không Trùng lịch Hội viên | Một `HỘI VIÊN` không thể đăng ký tham gia 2 lịch tập (lớp học nhóm hoặc ca PT 1-1) trong cùng một thời điểm. | DB Trigger / `EXCLUDE USING gist` |
| **BR-17** | Thời gian Sự kiện Hợp lệ | Thời gian kết thúc của ca tập PT 1-1 hoặc lớp học nhóm phải xảy ra sau thời gian bắt đầu (`end_time > start_time`). | Ràng buộc `CHECK` |
| **BR-18** | Trừ Buổi tập PT | Ca tập PT 1-1 (`PT_BOOKING`) chỉ được tạo khi số buổi PT còn lại của hội viên lớn hơn 0 (`remaining_pt_sessions > 0`) và tự động trừ 1 sau khi ca tập hoàn thành. | DB Trigger & Ràng buộc `CHECK` |
| **BR-19** | Chặn Khóa Bảo trì | `PHÒNG TẬP` hoặc `THIẾT BỊ` đang ở trạng thái bảo trì (`Under_Maintenance` / `In_Progress`) sẽ bị hệ thống tự động vô hiệu hóa và chặn mọi thao tác xếp lịch mới. | DB Trigger & Lookup Filter |
| **BR-20** | Nhật ký Bảo trì Hợp lệ | Mỗi `NHẬT KÝ BẢO TRÌ` (`MAINTENANCE_LOG`) phải có chi phí bảo trì không âm (`cost >= 0`) và thời gian hoàn thành phải lớn hơn hoặc bằng thời gian bắt đầu (`end_time >= start_time`). | Ràng buộc `CHECK` |
| **BR-21** | Chống Đụng Máy tập | Mỗi ca tập PT hoặc lớp học có thể đăng ký giữ chỗ trước các thiết bị tương ứng; hệ thống phải chặn không cho phép 1 thiết bị bị đặt trùng khoảng thời gian giữa 2 ca tập hoặc rơi vào lịch bảo trì. | DB Trigger / `EXCLUDE USING gist` |
| **BR-22** | Phân quyền RBAC | Hệ thống quản lý truy cập theo vai trò (RBAC). Một tài khoản người dùng (`USER_ACCOUNT`) có thể sở hữu một hoặc nhiều vai trò (`ROLE`: Khách hàng, PT, Tiếp tân, Admin, Kỹ thuật viên). | Bảng trung gian `USER_ROLE` |
| **BR-23** | Vết Truy xuất Giao dịch | Mọi giao dịch tạo mới hoặc thay đổi dữ liệu (đăng ký gói, xếp lịch, nhật ký bảo trì) đều phải gắn liền với mã định danh người thực hiện (`created_by_user_id`). | Khóa ngoại & Trigger Audit Log |
| **BR-24** | Tự động Gia hạn & Ân hạn | Hợp đồng đăng ký có cấu hình tự động gia hạn (`is_recurring = TRUE`) sẽ tự động phát sinh hóa đơn mới khi đến ngày hết hạn. Nếu sau thời gian ân hạn (`grace_period`, ví dụ 3 ngày) chưa được thanh toán thành công, trạng thái hợp đồng tự động chuyển sang `Expired` hoặc `Suspended`. | Scheduled Job / DB Trigger |
| **BR-25** | Chính sách Hủy Ca PT | Ca tập PT 1-1 chỉ được hủy và hoàn lại số buổi tập (`remaining_pt_sessions = remaining_pt_sessions + 1`) nếu thao tác hủy diễn ra trước thời điểm bắt đầu tối thiểu X giờ (ví dụ: 24h). Trường hợp hủy muộn hoặc bỏ tập (No-show), ca tập vẫn tính là đã hoàn thành và trừ 1 buổi. | DB Trigger / Business Logic |
| **BR-26** | Theo dõi Khấu hao Thiết bị | Mỗi thiết bị phòng tập phải ghi nhận ngày bắt đầu đưa vào sử dụng (`purchase_date`) và thời gian khấu hao dự kiến tính theo tháng (`depreciation_months > 0`). | Ràng buộc `CHECK` |

---
```

Tôi đã khởi tạo xong tệp `business_rules.md` hoàn toàn bằng tiếng Việt dựa trên toàn bộ 26 quy tắc nghiệp vụ trong tài liệu đồ án của bạn. Bạn có thể kiểm tra trực tiếp trong cửa sổ hiển thị file ở góc phải màn hình!