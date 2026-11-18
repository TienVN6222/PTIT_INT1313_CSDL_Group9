# Ghi chú thuyết trình (Speaker Notes)

> File này được sinh tự động bởi `build_deck.py` cùng với `deck.pptx` (ghi chú cũng nằm trong phần Notes của từng slide).
> Ghi chú viết dạng LỜI NÓI: có thể đọc gần nguyên văn. Dòng 'NẾU BỊ HỎI' là câu trả lời chuẩn bị sẵn, không đọc khi trình bày.

## Slide 1 - Tiêu đề và nhóm
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.3 phút

Em chào thầy cô. Chúng em là nhóm G9, đề tài số 09: hệ thống quản lý phòng tập và huấn luyện viên cá nhân. Nhóm gồm ba bạn: Lê Hoàng Tiến, Lê Hòa Thuận và Trần Minh Tiến. Phần đầu em sẽ trình bày bài toán và cách nhóm thiết kế dữ liệu; phần sau bạn Hoàng Tiến trình bày truy vấn, kiểm thử, phân quyền và demo.

## Slide 2 - Bài toán
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.6 phút

Một phòng tập ngoài đời hay gặp năm chuyện ở bên trái: huấn luyện viên bị xếp trùng giờ, khách chưa trả tiền đã được tập, hóa đơn bị sửa sau khi thu tiền, khách hủy buổi sát giờ mà vẫn không mất buổi, và nhân viên xem được những thứ không phải việc của mình. Cách nhóm giải quyết là đặt các luật đó ngay trong cơ sở dữ liệu, tức là chỗ cất dữ liệu, chứ không chỉ kiểm trong trang web. Vì vậy dù ai vào bằng trang web hay gõ lệnh thẳng vào cơ sở dữ liệu thì dữ liệu sai vẫn bị từ chối. Hệ thống có 18 bảng, 26 quy tắc, có bộ kiểm thử tự động và một trang web để demo.

NẾU BỊ HỎI 'vì sao không kiểm trong code web?': vì code web có thể bị bỏ qua, ví dụ người quản trị gõ lệnh trực tiếp; luật trong CSDL thì luôn chạy.

## Slide 3 - Quy tắc nghiệp vụ
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.6 phút

BR là viết tắt của Business Rule, nghĩa là quy tắc nghiệp vụ, hiểu đơn giản là luật của phòng tập. Nhóm có 26 luật, em chọn 8 luật tiêu biểu. Ví dụ BR-05: mỗi hội viên chỉ có một gói đang dùng. BR-07: chưa trả tiền thì gói chưa chạy, trả tiền xong thì gói tự bật. BR-10: hóa đơn đã ghi là không sửa, không xóa được. BR-12, 15, 16: huấn luyện viên, phòng và hội viên không bị trùng giờ. BR-25: hủy buổi tập khi còn dưới 24 giờ thì vẫn bị trừ buổi. Cột bên phải là việc cơ sở dữ liệu tự làm để giữ luật đó. Slide sau em nói CSDL dùng công cụ gì.

## Slide 4 - Giữ luật chỉ bằng DBMS
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

DBMS là phần mềm quản lý cơ sở dữ liệu, ở đây là PostgreSQL. Có thể hình dung nó như người gác cổng kho dữ liệu, và mỗi công cụ là một kiểu luật gác cổng. Khóa chính giống số căn cước: mỗi dòng một mã, không trùng. UNIQUE cấm hai dòng giống nhau, ví dụ hai tài khoản cùng email. NOT NULL là ô bắt buộc điền. CHECK là điều kiện đúng thì mới cho lưu, ví dụ giá không được âm. Khóa ngoại bắt dữ liệu phải trỏ tới thứ có thật, ví dụ một buổi PT phải thuộc một hợp đồng có thật. EXCLUDE cấm hai khoảng thời gian đè lên nhau, dùng để chống trùng lịch. Trigger giống cảm biến, tự chạy khi dữ liệu thay đổi. GRANT, REVOKE là phát và thu chìa khóa theo chức vụ. Nguyên tắc chọn ở dải dưới cùng: luật nào khai báo được thì khai báo, luật phải nhìn sang bảng khác mới dùng trigger.

NẾU BỊ HỎI 'sao ưu tiên khai báo hơn trigger?': khai báo thì PostgreSQL tự kiểm, nhanh, không thể quên; trigger là code mình tự viết nên dễ sai hơn.

## Slide 5 - Mô hình EER
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.5 phút

EER là sơ đồ thực thể - liên kết mở rộng. Nói đơn giản đây là bản vẽ thiết kế, giống bản vẽ ngôi nhà trước khi xây. Mỗi hộp là một loại đối tượng như hội viên, huấn luyện viên, gói tập; mỗi đường nối là một quan hệ. Trung tâm của mô hình là hợp đồng: một hội viên mua một gói thì sinh ra hợp đồng, rồi từ hợp đồng mới có hóa đơn và các buổi PT.

## Slide 6 - EER chi tiết
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

Mô hình có ba điểm đặc biệt. Thứ nhất là quan hệ cha - con, gọi là chuyên biệt hóa: ai dùng hệ thống cũng có một tài khoản chung, còn hội viên, huấn luyện viên, nhân viên thì có thêm một hồ sơ riêng. Thứ hai, một người có thể vừa là huấn luyện viên vừa là hội viên, gọi là chồng lấn; còn Admin chỉ có tài khoản, không cần hồ sơ, gọi là riêng phần. Thứ ba là chọn một trong hai: một lượt giữ máy tập phải thuộc một buổi PT hoặc một lớp học, không bao giờ cả hai, cơ sở dữ liệu kiểm điều này bằng một điều kiện CHECK. Bên phải là cách chuyển bản vẽ thành bảng: 12 đối tượng chính thành 12 bảng; 3 quan hệ nhiều - nhiều thành 3 bảng nối, giống sổ đăng ký giữa học sinh và môn học; 3 hồ sơ con thành 3 bảng dùng chung mã với tài khoản. Cộng lại là 18 bảng.

## Slide 7 - Chuẩn hóa
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~1 phút

Chuẩn hóa là sắp xếp bảng để mỗi thông tin chỉ nằm ở một chỗ. Ví dụ nếu tên gói tập được chép vào một nghìn hợp đồng, thì đổi tên gói phải sửa một nghìn chỗ, sót một chỗ là sai. Cần hai khái niệm. Phụ thuộc hàm, viết X mũi tên Y, nghĩa là biết X thì biết chắc Y, ví dụ biết email thì biết đó là tài khoản nào. Khóa là thông tin đủ để chỉ ra đúng một dòng, như số căn cước. Các mức chuẩn ở bảng bên phải, càng xuống càng gọn; mức cao nhất là BCNF: mọi phụ thuộc đều phải bắt đầu từ một khóa. Cách nhóm kiểm từng bảng: liệt kê các phụ thuộc, hỏi vế trái có phải khóa không. Ví dụ bảng tài khoản: chỉ có user_id, email và số điện thoại suy ra thông tin khác, mà ba cột này đều không trùng, tức đều là khóa, nên bảng đạt BCNF.

NẾU BỊ HỎI '3NF khác BCNF chỗ nào?': 3NF còn cho phép vế trái không phải khóa nếu vế phải là một phần của khóa; BCNF thì không cho ngoại lệ đó.

## Slide 8 - Vì sao 17/18 BCNF
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.8 phút

17 bảng em kiểm theo cách ở slide trước và đều đạt BCNF, tức mỗi thông tin chỉ nằm ở một chỗ. Ví dụ hóa đơn chỉ lưu mã hợp đồng; muốn biết hội viên nào thì tra qua hợp đồng. Có đúng một bảng nhóm cố ý để ở mức 2NF là bảng buổi PT. Bảng này lưu thêm cột hội viên, dù biết hợp đồng là đã biết hội viên rồi, tức là suy bắc cầu. Nhóm giữ cột này vì luật chống trùng giờ của hội viên dùng EXCLUDE, mà EXCLUDE chỉ đọc được cột nằm trong cùng một bảng. Để cột dư này không bao giờ sai, nhóm thêm khóa ngoại kép: cặp hợp đồng và hội viên phải khớp đúng như trong bảng hợp đồng. Tương tự, cột ngày tập suy ra được từ giờ bắt đầu, nên có điều kiện CHECK bắt hai cột phải khớp. Tóm lại là lưu dư có kiểm soát để đổi lấy chống trùng lịch chắc chắn.

## Slide 9 - EXCLUDE
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.8 phút

Để chống trùng lịch, nhóm dùng EXCLUDE. Hình dung như sổ đặt phòng họp: không cho ghi hai cuộc họp cùng phòng mà giờ đè lên nhau. Đọc đoạn lệnh bên trái: cấm hai dòng có cùng huấn luyện viên, dấu bằng, và khoảng giờ đè lên nhau, dấu hai chữ và. Ký hiệu ngoặc vuông mở, ngoặc tròn đóng nghĩa là tính giờ bắt đầu nhưng không tính giờ kết thúc, nên ca 8 đến 9 giờ và ca 9 đến 10 giờ nối tiếp nhau không bị coi là trùng. Dòng WHERE nghĩa là ca đã hủy thì không giữ chỗ nữa. Nếu ai cố xếp trùng, PostgreSQL trả lỗi mã 23P01. UNIQUE không làm được vì UNIQUE chỉ so bằng nhau, còn CHECK chỉ nhìn được một dòng.

NẾU BỊ HỎI 'gist là gì?': là một loại chỉ mục giúp tìm nhanh các khoảng giờ đè nhau; cần thêm extension btree_gist để kết hợp được với phép so sánh bằng.

## Slide 10 - Chống trùng lịch theo luật
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.6 phút

Bảng này trả lời câu hỏi chống trùng lịch cho luật nào. Lớp học và buổi PT nằm ở hai bảng khác nhau. Nếu hai lịch cùng loại, ví dụ hai buổi PT của cùng huấn luyện viên, thì nằm trong cùng một bảng, EXCLUDE tự chặn. Nếu một bên là lớp, một bên là buổi PT, thì nằm ở hai bảng, EXCLUDE không nhìn sang được, nên nhóm viết trigger để kiểm. Còn một tình huống khó: hai người bấm đặt cùng một lúc, cả hai cùng thấy còn trống rồi cùng lưu. Trigger của nhóm bắt họ xếp hàng theo huấn luyện viên hoặc hội viên: người sau phải đợi người trước lưu xong mới được kiểm, nên không bị lọt.

## Slide 11 - Trigger là gì
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.6 phút

Trigger giống cửa tự động có cảm biến: có người đi qua thì cửa tự mở, không ai phải bấm nút. Trigger là đoạn lệnh lưu trong cơ sở dữ liệu, tự chạy khi có ai thêm, sửa hoặc xóa dữ liệu. Có hai loại: BEFORE chạy trước khi lưu, nên có thể sửa dữ liệu hoặc chặn hẳn; AFTER chạy sau khi lưu, thường để cập nhật bảng khác. Ví dụ bên phải là luật hủy muộn: lễ tân bấm hủy một buổi PT khi chỉ còn 10 giờ nữa là tới giờ tập. Trigger BEFORE thấy còn dưới 24 giờ nên tự đổi trạng thái thành hủy muộn. Sau khi lưu, trigger AFTER trừ một buổi trong hợp đồng. Trang web chỉ gửi lệnh hủy bình thường, không cần biết luật 24 giờ.

## Slide 12 - Các trigger tiêu biểu
**Người trình bày:** Lê Hòa Thuận  |  **Thời lượng:** ~0.8 phút

Đây là các trigger tiêu biểu. Hóa đơn bất biến được bảo vệ nhiều lớp: trigger chặn sửa và xóa; không ai được cấp quyền sửa; không tài khoản đăng nhập nào là chủ của bảng; và có một trigger đặc biệt chặn cả lệnh xóa hoặc đổi cấu trúc bảng hóa đơn. Tự kích hoạt: khi hóa đơn chuyển sang đã thanh toán thì hợp đồng tự chuyển Active. Hủy muộn như slide trước. Hội viên dưới 12 tuổi bị từ chối. Lưu vết: tự ghi ai tạo, ai sửa và lúc nào. Riêng gia hạn là một thủ tục chạy mỗi ngày, vì PostgreSQL không tự hẹn giờ được; chạy hai lần cũng không sinh hóa đơn trùng. Phần của em đến đây là hết, em xin mời bạn Hoàng Tiến trình bày phần tiếp theo.

## Slide 13 - PostgreSQL chạy truy vấn
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Em xin trình bày phần hai. Khi nhận một câu truy vấn, PostgreSQL làm giống Google Maps: cùng một điểm đến có nhiều đường đi, nó ước tính và chọn đường nhanh nhất. Cụ thể có bốn bước: đọc hiểu câu SQL, mở các view thành câu gốc, lập kế hoạch, rồi chạy theo kế hoạch. Kế hoạch gồm các cách đi: Seq Scan là đọc cả bảng, như lật cả cuốn sách; Index Scan là tra mục lục rồi đi thẳng tới dòng cần; Hash Join là lập danh bạ một bảng rồi dò bảng kia. Bên phải là kế hoạch thật của truy vấn 1, doanh thu theo gói: đọc hóa đơn và giữ hóa đơn đã thanh toán trong quý, ghép với hợp đồng, tra tên gói bằng mục lục, rồi gom nhóm và sắp xếp. Muốn xem kế hoạch này thì dùng lệnh EXPLAIN ANALYZE.

NẾU BỊ HỎI 'sao Q1 lại đọc cả bảng?': vì dữ liệu mẫu nhỏ, đọc hết còn nhanh hơn tra mục lục; khi dữ liệu lớn PostgreSQL tự chuyển sang dùng chỉ mục.

## Slide 14 - Truy vấn 1/2
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.8 phút

Nhóm viết 10 truy vấn nâng cao; em giới thiệu bốn câu. Câu 2 trả lời: ba huấn luyện viên nào dạy nhiều giờ nhất tháng này? Cách làm: lấy giờ dạy PT và giờ dạy lớp, nối thành một danh sách bằng UNION ALL, cộng theo từng người, rồi lấy ba người cao nhất. WITH, hay CTE, là đặt tên cho một bước trung gian, giống viết nháp từng bước khi giải toán. Câu 8 trả lời: mỗi nhóm tuổi thích gói nào nhất? Chia hội viên theo tuổi bằng CASE, đếm số người theo gói, rồi xếp hạng riêng trong từng nhóm tuổi bằng DENSE_RANK với PARTITION BY, và lấy hạng 1.

NẾU BỊ HỎI 'UNION ALL khác UNION?': UNION bỏ các dòng giống nhau, UNION ALL giữ hết; ở đây hai buổi dài bằng nhau vẫn phải cộng cả hai nên dùng UNION ALL.

## Slide 15 - Truy vấn 2/2
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.8 phút

Câu 9 xếp hạng hội viên theo tổng tiền đã chi: cộng các hóa đơn đã thanh toán của từng người, xếp hạng, rồi chia thành hạng Kim Cương, Bạch Kim, Tiêu chuẩn. DENSE_RANK nghĩa là hai người bằng tiền thì cùng hạng, và người tiếp theo không bị nhảy hạng. Câu 10 là truy vấn kiểm tra: có huấn luyện viên nào bị trùng lịch không? Nó ghép danh sách lịch với chính nó để tìm hai lịch cùng người mà giờ đè nhau. Kết quả đúng là không có dòng nào, vì cơ sở dữ liệu đã chặn trùng ngay từ lúc lưu, như bạn Thuận đã trình bày. Cả 10 câu đều chạy được trên trang web.

## Slide 16 - Test case
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Kiểm thử giống thử ổ khóa. Test âm là thử bằng chìa sai: cố tình làm sai, ví dụ tạo tài khoản trùng email, và cửa phải không mở, tức cơ sở dữ liệu phải từ chối. Test dương là thử bằng chìa đúng: làm đúng thì phải thành công. Nhóm có 78 test âm và 36 test dương. Điểm quan trọng: test âm không chỉ cần có lỗi, mà phải đúng mã lỗi. Mỗi loại lỗi có một mã gọi là SQLSTATE, bảng bên phải là các mã nhóm dùng: 23505 là trùng giá trị, 23P01 là trùng lịch, P0001 là trigger chặn, v.v. Ví dụ test TC-01: thêm tài khoản trùng email, cơ sở dữ liệu báo 23505, khớp mã mong đợi nên đạt. Mỗi test chạy riêng nên test này hỏng không ảnh hưởng test kia, và cuối file hoàn tác hết nên dữ liệu mẫu không bị bẩn. Kết quả 114 trên 114 đạt.

NẾU BỊ HỎI 'sao test chạy ngày nào cũng ra cùng kết quả?': giờ trong test tính theo ngày hôm nay và đặt vào khung 21 giờ đến 24 giờ, khung mà dữ liệu mẫu cố ý để trống.

## Slide 17 - Đo hiệu năng
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Dữ liệu mẫu chỉ khoảng mười nghìn dòng, quá ít để thấy khác biệt. Nên script tự sinh tạm khoảng bốn trăm hai mươi nghìn dòng giả, đo xong thì hoàn tác. Mỗi truy vấn chạy hai lần: một lần có chỉ mục, một lần tắt chỉ mục, đo thời gian bằng EXPLAIN ANALYZE. Chỉ mục giống mục lục của cuốn sách: có mục lục thì mở thẳng trang cần tìm, không có thì phải lật từng trang. Kết quả: tìm tài khoản theo email chỉ mất 0,037 mili giây so với 14 mili giây, nhanh hơn khoảng 380 lần. Truy vấn nặng nhất là truy vấn 1 nối ba bảng, 13,7 mili giây, vẫn dưới xa giới hạn 200. Tám trên tám truy vấn đạt yêu cầu.

NẾU BỊ HỎI 'sao không để luôn 420 nghìn dòng trong dữ liệu mẫu?': dữ liệu mẫu cần đúng nghiệp vụ và nạp nhanh để demo; dữ liệu lớn chỉ cần cho lúc đo nên sinh tạm rồi xóa.

## Slide 18 - Tổng hợp kiểm thử
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.4 phút

Tổng hợp lại: 114 trên 114 test ràng buộc đạt; 66 trên 66 test phân quyền đạt, em sẽ nói ở slide sau; 8 trên 8 truy vấn đo hiệu năng đều dưới 200 mili giây. Dữ liệu mẫu gần mười nghìn dòng, ngày tháng tính theo ngày nạp nên các truy vấn kiểu tháng này, quý này lúc nào cũng có dữ liệu.

## Slide 19 - RBAC 1/2
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.9 phút

RBAC là phân quyền theo vai trò. Giống thẻ phòng khách sạn: lễ tân, lao công, khách mỗi người một loại thẻ, chỉ mở được đúng cửa của mình. Nhóm có 5 vai trò. Mặc định không ai có quyền gì, rồi cấp đúng phần cần thiết, gọi là quyền tối thiểu. Quyền cấp tới từng cột, nên không ai đọc được cột mật khẩu. Hóa đơn chỉ được đọc và thêm, kể cả Admin cũng không sửa được. Trang web cũng đăng nhập bằng một tài khoản bị giới hạn như vậy. Có một vấn đề: huấn luyện viên chỉ được sửa trạng thái buổi PT, không được đụng vào hợp đồng. Nhưng khi huấn luyện viên bấm hoàn thành, trigger phải trừ buổi trong hợp đồng. Cách giải là cho trigger chạy bằng quyền của chủ hàm, gọi là SECURITY DEFINER, giống được ủy quyền làm đúng một việc. Kèm theo đó cố định search_path để không ai lừa được nó gọi nhầm hàm giả.

NẾU BỊ HỎI 'role NOLOGIN là gì?': là vai trò không đăng nhập được, chỉ để gom quyền; tài khoản đăng nhập thật thì thừa hưởng quyền từ vai trò đó.

## Slide 20 - RBAC 2/2
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~0.7 phút

Đây là bảng quyền rút gọn. Điểm đáng chú ý: không ai đọc được cột mật khẩu; hóa đơn chỉ đọc và thêm, kể cả Admin; huấn luyện viên chỉ sửa được cột trạng thái của buổi PT, không đổi được giờ hay hội viên; kỹ thuật viên chỉ đụng tới thiết bị. Kiểm thử phân quyền dùng lệnh SET ROLE để đóng vai từng người. Ví dụ đóng vai lễ tân thử đọc mật khẩu thì phải nhận lỗi 42501, nghĩa là không đủ quyền. Đóng vai huấn luyện viên đánh dấu buổi hoàn thành thì phải thành công và buổi bị trừ. Năm test SY tự so bảng phân quyền mà trang web dùng với quyền thật trong cơ sở dữ liệu, ai sửa một bên mà quên bên kia thì test báo ngay. Kết quả 66 trên 66 đạt.

## Slide 21 - Demo web
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~2.5 phút

Trước giờ demo đã bật hệ thống bằng docker compose up và mở sẵn trang web. Đi theo đúng thứ tự trong bảng, mỗi bước nói câu ở cột phải. Bước 1: chọn người thao tác ở thanh bên, hệ thống sẽ ghi lại ai làm. Bước 2: xem số liệu tổng quan. Bước 3: đăng ký một hội viên sinh sau năm 2014, cơ sở dữ liệu từ chối vì dưới 12 tuổi. Bước 4: đăng ký gói và thanh toán, chỉ cho thầy cô thấy gói tự chuyển Active. Bước 5: đặt một buổi PT rồi hủy; nếu còn dưới 24 giờ thì thành hủy muộn và số buổi giảm 1. Bước 6: chạy truy vấn 2. Bước 7: dùng trang kiểm thử trigger, mọi phép thử đều tự hoàn tác. Nếu web có sự cố, chuyển ngay sang slide sau.

## Slide 22 - Demo dòng lệnh
**Người trình bày:** Lê Hoàng Tiến  |  **Thời lượng:** ~1 phút

Phần này chạy trên cửa sổ dòng lệnh, mở sẵn ở thư mục dự án. Lệnh đầu bật toàn bộ hệ thống. Hai lệnh tiếp theo chạy hai bộ kiểm thử, cuối mỗi bộ có bảng tổng hợp đạt hay không đạt, chỉ cho thầy cô dòng tổng. Lệnh cuối đăng nhập bằng tài khoản lễ tân rồi thử đọc cột mật khẩu, cơ sở dữ liệu trả lỗi permission denied, tức không đủ quyền. Nếu có sự cố thì mở phụ lục C ở slide 27 để tra lệnh xử lý.

## Slide 23 - Phân công
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~0.3 phút

Slide này chỉ để thầy cô biết ai trình bày phần nào. Không cần đọc, chuyển sang hỏi đáp.

## Slide 24 - Hỏi đáp
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~3 phút

Em xin cảm ơn thầy cô đã lắng nghe, nhóm em xin nhận câu hỏi.

MẸO TRẢ LỜI: câu hỏi về thuật ngữ thì mở phụ lục A. Nếu không chắc, nói thật: 'Phần này em chưa nắm chắc, em xin phép ghi nhận và tìm hiểu thêm'. Không đoán bừa. Câu hỏi mẫu và đáp án: Phase 4/sql_defense_guide.md.

CÂU HAY BỊ HỎI:
- Trigger khác CHECK thế nào? CHECK chỉ nhìn 1 dòng; trigger nhìn được bảng khác và làm thêm việc (trừ buổi, đổi trạng thái).
- Vì sao pt_booking chỉ 2NF? Lưu thêm cột hội viên để EXCLUDE chống trùng giờ hội viên; khóa ngoại kép giữ cho cột đó luôn đúng.
- Hai người đặt cùng lúc? Trigger bắt xếp hàng (advisory lock), người sau đợi người trước xong mới kiểm.
- SECURITY DEFINER là gì? Hàm chạy bằng quyền của chủ hàm, để HLV bấm hoàn thành vẫn trừ được buổi trong hợp đồng.

## Slide 25 - Phụ lục thuật ngữ
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~0 phút

Slide dự phòng: khi thầy cô hỏi nghĩa của một thuật ngữ thì mở slide này. Không trình bày trong thời gian chính.

## Slide 26 - Phụ lục bảo mật vận hành
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~0 phút

Slide dự phòng khi được hỏi về mã hóa và sao lưu. TLS là mã hóa đường truyền giữa ứng dụng và cơ sở dữ liệu, giống https của trang web. Bản sao lưu được mã hóa và có kiểm tra khôi phục tự động. WAL là nhật ký mọi thay đổi; lưu liên tục WAL cộng với bản sao lưu nền cho phép khôi phục về đúng thời điểm trước sự cố.

## Slide 27 - Phụ lục xử lý sự cố
**Người trình bày:** Cả nhóm  |  **Thời lượng:** ~0 phút

Slide dự phòng cho phần demo: tra nhanh lệnh theo tình huống. Mở sẵn một cửa sổ dòng lệnh ở thư mục dự án trước giờ demo.
