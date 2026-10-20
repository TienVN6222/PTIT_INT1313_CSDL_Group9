# PHẦN 1: QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN RBAC

Quản lý thông tin định danh tài khoản, hệ thống phân quyền đa vai trò động (Role-Based Access Control) và phân cấp quyền hạn chi tiết.

## Bảng 3.1.1: USER_ACCOUNT

**Mô tả:** Bảng trung tâm lưu trữ thông tin tài khoản người dùng dùng chung toàn hệ thống.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK | No | AUTO_INCREMENT | Mã người dùng duy nhất toàn hệ thống (BR-01) |
| full_name | VARCHAR(100) | None | No | None | Họ và tên đầy đủ của người dùng |
| email | VARCHAR(100) | None | No | None | Email đăng nhập duy nhất (UNIQUE) (BR-02) |
| phone | VARCHAR(20) | None | No | None | Số điện thoại duy nhất (UNIQUE) (BR-02) |
| dob | DATE | None | No | None | Ngày sinh; CHECK (dob <= CURRENT_DATE - 12 năm) (BR-03) |
| emergency_contact | VARCHAR(100) | None | Yes | NULL | Thông tin liên hệ khẩn cấp (SĐT/Họ tên) |
| password_hash | VARCHAR(255) | None | No | None | Chuỗi mật khẩu đã được mã hóa băm bảo mật |
| status | VARCHAR(20) | None | No | 'Active' | Trạng thái: 'Active', 'Inactive', 'Suspended' |

## Bảng 3.1.2: ROLE

**Mô tả:** Danh mục các vai trò hệ thống quy định nhóm thẩm quyền sử dụng.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | INT | PK | No | AUTO_INCREMENT | Mã định danh vai trò hệ thống |
| role_name | VARCHAR(50) | None | No | None | Tên vai trò (UNIQUE): Member, Trainer, Receptionist, Tech, Admin (BR-22) |
| description | VARCHAR(255) | None | Yes | NULL | Mô tả chi tiết thẩm quyền và trách nhiệm của vai trò |

## Bảng 3.1.3: USER_ROLE

**Mô tả:** Bảng trung gian gán vai trò cho người dùng (hỗ trợ một người giữ nhiều vai trò).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Ref USER_ACCOUNT(user_id) ON DELETE CASCADE (BR-22) |
| role_id | INT | PK, FK | No | None | Ref ROLE(role_id) ON DELETE CASCADE (BR-22) |

## Bảng 3.1.4: PERMISSION

**Mô tả:** Danh mục các quyền thao tác chi tiết theo từng phân hệ chức năng.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| permission_id | INT | PK | No | AUTO_INCREMENT | Mã định danh quyền thao tác |
| permission_code | VARCHAR(50) | None | No | None | Mã quyền duy nhất (UNIQUE) (VD: MEMBER_CREATE, EQUIP_EDIT) |
| module_name | VARCHAR(50) | None | No | None | Phân hệ nghiệp vụ tương ứng (VD: Billing, Booking) |
| description | VARCHAR(255) | None | Yes | NULL | Diễn giải chi tiết thao tác được phép thực hiện |

## Bảng 3.1.5: ROLE_PERMISSION

**Mô tả:** Bảng trung gian phân bổ các quyền chi tiết cho từng vai trò hệ thống.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | INT | PK, FK | No | None | Ref ROLE(role_id) ON DELETE CASCADE |
| permission_id | INT | PK, FK | No | None | Ref PERMISSION(permission_id) ON DELETE CASCADE |
