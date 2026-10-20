# 2.1. Mô hình Quan niệm – Sơ đồ ER/EER (Conceptual Model – ER/EER Diagram)

## Phân hệ Phân quyền & Quản lý Tài khoản (RBAC)

- **USER_ACCOUNT:** Lưu trữ thông tin định danh và đăng nhập dùng chung.
- **ROLE, PERMISSION, USER_ROLE, ROLE_PERMISSION:** Quản lý phân quyền đa vai trò động theo chuẩn RBAC.
- **MEMBER_PROFILE, TRAINER_PROFILE, STAFF_PROFILE:** Các thực thể con (Subclasses) mở rộng thông tin chi tiết cho từng nhóm người dùng.

## Phân hệ Gói tập & Thanh toán (Subscription & Billing)

- **MEMBERSHIP_PLAN:** Định nghĩa các gói tập (theo thời gian hoặc theo số buổi PT).
- **MEMBER_SUBSCRIPTION:** Lưu trữ các hợp đồng đăng ký gói tập của hội viên.
- **BILLING_LOG:** Nhật ký hóa đơn thanh toán/gia hạn bất biến (Immutable Billing Log).

## Phân hệ Lịch tập & Đặt chỗ (Scheduling & Enrollment)

- **CLASS_SCHEDULE:** Quản lý danh mục và lịch thi đấu/học của các lớp nhóm.
- **CLASS_ENROLLMENT:** Bảng trung gian giải quyết quan hệ M:N giữa hợp đồng hội viên và lớp học nhóm.
- **PT_BOOKING:** Quản lý các ca tập 1-1 giữa Hội viên và Huấn luyện viên cá nhân.

## Phân hệ Cơ sở vật chất & Bảo trì (Facilities & Equipment)

- **FACILITIES_ROOM:** Quản lý danh mục phòng tập/khu vực chức năng và sức chứa.
- **EQUIPMENT:** Quản lý danh mục thiết bị, máy tập và thông tin khấu hao.
- **EQUIPMENT_RESERVATION:** Đăng ký giữ chỗ máy tập cho ca tập PT 1-1 hoặc lớp học nhóm để chống đụng/hết máy.
- **MAINTENANCE_LOG:** Nhật ký ghi nhận sự cố và tiến độ bảo trì thiết bị do nhân viên kỹ thuật (STAFF_PROFILE) đảm nhận.
