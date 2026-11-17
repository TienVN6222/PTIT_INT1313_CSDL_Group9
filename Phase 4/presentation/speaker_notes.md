# Ghi chú thuyết trình (Speaker Notes)

> File này được sinh tự động bởi `build_deck.py` cùng với `deck.pptx` (ghi chú cũng nằm trong phần Notes của từng slide).
> Thời lượng mục tiêu: 15 phút trình bày + hỏi đáp. Tên người trình bày là chỗ trống để nhóm tự gán.

## Slide 1 - Tiêu đề và nhóm
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.5 phút

Chào hội đồng, chúng em là nhóm G9, đề tài 09: Hệ thống quản lý phòng tập và huấn luyện viên cá nhân. Nhóm gồm ba thành viên (đọc tên và mã sinh viên). Trong 15 phút tới nhóm sẽ trình bày: bài toán, thiết kế dữ liệu, các cơ chế bảo vệ dữ liệu ở tầng CSDL, kết quả kiểm thử, và demo trực tiếp. Phần cuối dành cho hỏi đáp.

## Slide 2 - Bài toán và phạm vi
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Vấn đề thực tế: lịch tập rất dễ trùng, hóa đơn cần bất biến, gói PT phải trừ buổi đúng. Nhóm không giải quyết bằng code ứng dụng mà đặt các quy tắc này vào chính cơ sở dữ liệu. Hệ thống có 18 bảng, 26 quy tắc nghiệp vụ, kèm bộ kiểm thử và giao diện web. Phần mô tả đầy đủ theo ISO/IEC/IEEE 29148 nằm trong báo cáo, mục 1.

## Slide 3 - Quy tắc nghiệp vụ
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Đây là tám quy tắc tiêu biểu. Nguyên tắc của nhóm: quy tắc trong một bảng thì dùng ràng buộc khai báo (UNIQUE, CHECK, EXCLUDE), quy tắc liên quan nhiều bảng mới dùng trigger. Ví dụ BR-07 cần nhìn sang bảng hóa đơn nên phải dùng trigger.

## Slide 4 - Mô hình EER
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.5 phút

Sơ đồ EER nằm trong báo cáo mục 2.1. Điểm quan trọng là chuyên biệt hóa: mọi người dùng là user_account, sau đó có hồ sơ riêng cho hội viên, HLV, nhân viên với khóa chính dùng chung. Các quan hệ nhiều-nhiều dùng bảng liên kết. Hợp đồng là trung tâm: nối hội viên, gói tập, hóa đơn, ca PT và đăng ký lớp.

## Slide 5 - Lược đồ logic và chuẩn hóa
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

18 bảng chia thành 5 phân hệ. Về chuẩn hóa, 17 trên 18 bảng đạt BCNF. Bảng pt_booking chỉ đạt 2NF vì có hai phụ thuộc bắc cầu: subscription_id xác định member_user_id, và start_time xác định booking_date. Nhóm giữ có chủ đích: member_user_id cần có trong bảng để khai báo ràng buộc EXCLUDE chống trùng lịch theo hội viên, vì EXCLUDE chỉ tham chiếu cột cùng bảng. Dữ liệu không thể mâu thuẫn nhờ khóa ngoại ghép (subscription_id, member_user_id). Còn actual_price không phải phụ thuộc bắc cầu vì là giá chốt lúc ký, hai hợp đồng cùng gói có thể khác giá. Chứng minh đầy đủ ở mục 2.3.

## Slide 6 - EXCLUDE gist
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

UNIQUE chỉ so sánh bằng, CHECK chỉ nhìn một dòng, nên không diễn đạt được hai khoảng thời gian chồng nhau. EXCLUDE làm được: không tồn tại hai dòng cùng trainer_user_id mà khoảng thời gian giao nhau, toán tử && là overlap của kiểu range. Dùng nửa mở [) nên hai ca nối tiếp không bị báo trùng oan. Phần ca PT có điều kiện WHERE để ca đã hủy không chiếm giờ. Với trùng giữa hai bảng khác nhau, EXCLUDE không làm được nên nhóm dùng trigger có khóa tư vấn để hai giao dịch đồng thời không cùng lọt qua.

## Slide 7 - Trigger nghiệp vụ
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

Năm cơ chế tiêu biểu. Hóa đơn bất biến có bốn lớp: trigger áp dụng cho mọi tài khoản; chỉ cấp SELECT, INSERT; mọi đối tượng thuộc role NOLOGIN gym_owner nên không tài khoản đăng nhập nào là chủ sở hữu; event trigger chặn ALTER, DROP bảng, trigger và hàm bất biến kể cả với superuser (superuser là gốc tin cậy nên vẫn bảo trì được nếu cố ý tắt event trigger). Vết thao tác BR-23: tạo thì bắt buộc có người thực hiện, sửa thì tự ghi người sửa và thời điểm sửa. Tự kích hoạt: tạo hợp đồng Pending, ghi hóa đơn Completed, trigger tự chuyển Active. Hủy muộn: ứng dụng chỉ gửi trạng thái Cancelled, trigger BEFORE tự đổi thành Late_Cancelled nếu còn dưới 24 giờ, rồi trigger AFTER trừ một buổi. Gia hạn tự động là thủ tục vì PostgreSQL không có bộ lập lịch, cron gọi mỗi ngày; thủ tục idempotent. Cuối cùng created_by lưu vết người thao tác.

## Slide 8 - Truy vấn phức hợp 1
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Truy vấn 2 gộp giờ dạy kèm 1-1 và giờ đứng lớp nhóm bằng UNION ALL trong CTE rồi lấy top 3. UNION ALL giữ mọi dòng, không khử trùng lặp, đúng nghiệp vụ vì hai ca cùng độ dài vẫn phải cộng. Truy vấn 8 phân nhóm tuổi bằng CASE rồi dùng DENSE_RANK theo từng nhóm tuổi; đồng hạng cùng thứ hạng và hạng sau không nhảy cóc. Vì window function tính sau WHERE nên muốn lọc hạng 1 phải bọc trong CTE. Cả mười truy vấn có trong file 03 và trong giao diện web.

## Slide 9 - Truy vấn phức hợp 2
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Truy vấn 9 xếp hạng hội viên theo tổng tiền thực chi bằng DENSE_RANK không phân vùng. Truy vấn 10 là self-join tìm hai sự kiện của cùng HLV chồng giờ, điều kiện chồng lấn là start1 nhỏ hơn end2 và end1 lớn hơn start2, dùng dấu nghiêm ngặt để hai ca nối tiếp không bị tính. Kết quả kỳ vọng là 0 dòng, vì CSDL đã chặn dữ liệu trùng ngay lúc ghi; đây là công cụ kiểm toán. Nhóm đã sửa một lỗi tinh vi: mã của lớp và mã của ca PT có thể trùng số nên phải so sánh cặp (loại, mã).

## Slide 10 - Kết quả kiểm thử
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

Ba bộ kiểm thử. Mục 5.1: một trăm linh chín test ràng buộc đạt cả, gồm 74 test âm tính và 35 test dương tính; mỗi test kiểm đúng mã lỗi SQLSTATE và chạy trong savepoint nên độc lập. Mục 5.2: sáu mươi mốt test phân quyền đạt cả, gồm cả các test event trigger bảo vệ hóa đơn. Mục 4.2: tám phép đo hiệu năng đều dưới 200 mili giây trên một trăm nghìn người dùng, hai trăm nghìn hóa đơn và 120 nghìn ca PT; tra cứu theo chỉ mục chỉ 0,04 đến 0,2 mili giây so với 10 đến 30 mili giây khi quét tuần tự. Dữ liệu mẫu 9.925 dòng (3.000 người dùng, 500 thiết bị, sinh bằng generate_series), ngày tháng tính tương đối. Số liệu lấy từ lần chạy cuối ngày 16/11/2026; nếu sửa lại CSDL thì chạy lại ba script rồi cập nhật các số này.

## Slide 11 - RBAC
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.5 phút

Phân quyền ở tầng CSDL nên dù ai kết nối thẳng bằng psql vẫn bị giới hạn. Năm role nhóm không đăng nhập được, năm tài khoản demo thừa hưởng. Mật khẩu hội viên không ai đọc được nhờ quyền mức cột. Hóa đơn chỉ được đọc và thêm, kể cả Admin. Vì quyền tối thiểu nên HLV không ghi được bảng hợp đồng, nhưng khi HLV đánh dấu ca hoàn thành thì trigger phải trừ buổi trong bảng hợp đồng; giải pháp là hàm trigger chạy SECURITY DEFINER, kèm search_path cố định để chống tấn công. Ứng dụng web cũng kết nối bằng tài khoản bị hạn chế này.

## Slide 12 - Demo giao diện
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~3 phút

Kịch bản demo 3 phút, đi theo đúng thứ tự trong bảng. Trước giờ demo đã chạy docker compose up --build và mở sẵn trang. Bước 1 chọn người thao tác ở thanh bên. Bước 3: nhập hội viên sinh sau năm 2014 để cho thấy trigger tuổi chặn. Bước 4: ký hợp đồng và xuất hóa đơn, chỉ ra hợp đồng tự lên Active nhờ trigger. Bước 5: đặt một ca PT rồi hủy; nếu ca còn trên 24 giờ trạng thái là Cancelled, ngược lại là Late_Cancelled và số buổi giảm 1. Bước 6 chạy truy vấn 2. Bước 7 dùng phòng kiểm thử trigger, mọi phép thử đều ROLLBACK nên không làm bẩn dữ liệu. Lưu ý: tên menu có biểu tượng; nếu giao diện đổi chữ thì điều chỉnh theo.

## Slide 13 - Demo dòng lệnh
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1.5 phút

Bốn lệnh chính lấy từ README. Hệ thống khởi động bằng một lệnh docker compose up --build. Sau đó chạy script kiểm thử ràng buộc, kết thúc bằng bảng tổng hợp đạt/không đạt. Phần phân quyền: đăng nhập bằng gym_u_reception rồi thử SELECT password_hash để cho thấy bị từ chối. Script hiệu năng 06 mất khoảng một phút nên chỉ chạy nếu còn thời gian, hoặc chiếu kết quả đã chạy sẵn. Dọn dẹp bằng docker compose down -v.

## Slide 14 - Phân công
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~0.5 phút

Slide này chỉ để hội đồng biết ai trình bày phần nào. Đây là phân công đề xuất; nhóm có thể đổi trong PRESENTERS rồi chạy lại build_deck.py. Mỗi thành viên nên chuẩn bị trả lời câu hỏi SQL ở bất kỳ phần nào, vì phần bảo vệ SQL cá nhân hỏi từng người.

## Slide 15 - Hỏi đáp
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~3 phút

Mời hội đồng đặt câu hỏi. Người nào được hỏi trả lời, người khác bổ sung nếu cần. Câu hỏi thường gặp và đáp án mẫu nằm trong Phase 4/sql_defense_guide.md. Nếu bị hỏi một việc nhóm chưa làm, nói thẳng là chưa làm và nêu hướng cải tiến.
