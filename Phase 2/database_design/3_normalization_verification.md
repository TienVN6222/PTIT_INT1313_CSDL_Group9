# 2.3. Chứng minh Chuẩn hóa Dữ liệu (Normalization Verification: 1NF -> 3NF/BCNF)

Toàn bộ các bảng trong thiết kế CSDL đã được kiểm chứng đạt Dạng chuẩn Boyce-Codd (BCNF):

- **Dạng chuẩn 1 (1NF):** Mọi thuộc tính đều chứa giá trị đơn nguyên tố (Atomic Values). Các danh sách đa trị (vai trò người dùng, lịch đăng ký lớp, danh sách giữ chỗ thiết bị) đều đã tách thành các bảng trung gian.
- **Dạng chuẩn 2 (2NF):** Đạt 1NF và tất cả các thuộc tính không khóa đều phụ thuộc hàm toàn phần vào khóa chính. Các bảng khóa ghép như USER_ROLE và ROLE_PERMISSION không chứa thuộc tính không khóa nào phụ thuộc một phần.
- **Dạng chuẩn 3 (3NF):** Đạt 2NF và không tồn tại phụ thuộc bắc cầu X --> Y --> Z. Ví dụ: Giá bán thực tế actual_price trong MEMBER_SUBSCRIPTION được lưu riêng biệt để tránh biến động giá gói tập ở MEMBERSHIP_PLAN làm sai lệch lịch sử giao dịch6.
- **Dạng chuẩn Boyce-Codd (BCNF):** Đạt 3NF và mọi phụ thuộc hàm không tầm thường X --> A đều có vế trái X là một Siêu khóa (Superkey).

CSDL hoàn toàn loại bỏ các nguy cơ bất thường dữ liệu khi Thêm, Xóa, Cập nhật.
