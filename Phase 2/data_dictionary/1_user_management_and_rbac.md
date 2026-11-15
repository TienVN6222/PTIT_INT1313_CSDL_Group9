# PHẦN 1: QUẢN LÝ NGƯỜI DÙNG & PHÂN QUYỀN RBAC

Quản lý thông tin định danh tài khoản, hệ thống phân quyền đa vai trò động (Role-Based Access Control) và phân cấp quyền hạn chi tiết.

> **Quy ước chung (ISO/IEC 11179):** kiểu dữ liệu theo PostgreSQL 16 và khớp 100% với [`01_schema_ddl.sql`](../../Phase%203/01_schema_ddl.sql) (đã đối chiếu tự động với `information_schema.columns`). `SERIAL` = `INTEGER` + sequence, giá trị mặc định là `nextval(...)`. Cột *Key*: `PK` khóa chính, `FK` khóa ngoại, `UK` khóa duy nhất (UNIQUE), `None` không có. Tên ràng buộc ghi trong dấu `` ` ` `` là tên thật trong DDL.

## Bảng 3.1.1: USER_ACCOUNT

**Mô tả:** Bảng trung tâm lưu trữ thông tin tài khoản người dùng dùng chung toàn hệ thống (Hội viên, HLV, Nhân viên, Quản trị).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | SERIAL | PK | No | SERIAL (nextval) | Mã người dùng duy nhất toàn hệ thống (BR-01). `pk_user_account` |
| full_name | VARCHAR(100) | None | No | None | Họ và tên đầy đủ của người dùng |
| email | VARCHAR(100) | UK | No | None | Email đăng nhập duy nhất. `uq_user_account_email` (BR-02) |
| phone | VARCHAR(20) | UK | No | None | Số điện thoại duy nhất. `uq_user_account_phone` (BR-02) |
| dob | DATE | None | No | None | Ngày sinh. BR-03: hội viên phải đủ 12 tuổi, thực thi bởi trigger `trg_check_member_dob` (BEFORE INSERT/UPDATE OF user_id ON member_profile) và `trg_check_user_dob_for_member` (BEFORE UPDATE OF dob ON user_account); không áp dụng cho vai trò khác |
| emergency_contact | VARCHAR(100) | None | Yes | NULL | Thông tin liên hệ khẩn cấp (SĐT/Họ tên) |
| password_hash | VARCHAR(255) | None | No | None | Chuỗi mật khẩu đã băm bảo mật, không lưu mật khẩu thô |
| status | VARCHAR(20) | None | No | 'Active' | Trạng thái tài khoản. `chk_user_account_status`: `IN ('Active', 'Inactive', 'Suspended')` |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo tài khoản |

**Chỉ mục:** `idx_user_account_status (status)`.

## Bảng 3.1.2: ROLE

**Mô tả:** Danh mục các vai trò hệ thống quy định nhóm thẩm quyền sử dụng.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh vai trò hệ thống. `pk_role` |
| role_name | VARCHAR(50) | UK | No | None | Tên vai trò duy nhất: Member, Trainer, Receptionist, Technician, Admin. `uq_role_name` (BR-22) |
| description | VARCHAR(255) | None | Yes | NULL | Mô tả chi tiết thẩm quyền và trách nhiệm của vai trò |

## Bảng 3.1.3: USER_ROLE

**Mô tả:** Bảng trung gian gán vai trò cho người dùng (quan hệ M:N, hỗ trợ một người giữ nhiều vai trò).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép `pk_user_role (user_id, role_id)`. `fk_user_role_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE** (BR-22) |
| role_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép. `fk_user_role_role` → ROLE(role_id) **ON DELETE CASCADE** (BR-22) |

## Bảng 3.1.4: PERMISSION

**Mô tả:** Danh mục các quyền thao tác chi tiết theo từng phân hệ chức năng.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| permission_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh quyền thao tác. `pk_permission` |
| permission_code | VARCHAR(50) | UK | No | None | Mã quyền duy nhất (VD: MEMBER_CREATE, EQUIP_EDIT). `uq_permission_code` |
| module_name | VARCHAR(50) | None | No | None | Phân hệ nghiệp vụ tương ứng (VD: Billing, Booking) |
| description | VARCHAR(255) | None | Yes | NULL | Diễn giải chi tiết thao tác được phép thực hiện |

## Bảng 3.1.5: ROLE_PERMISSION

**Mô tả:** Bảng trung gian phân bổ các quyền chi tiết cho từng vai trò hệ thống (quan hệ M:N).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép `pk_role_permission (role_id, permission_id)`. `fk_role_permission_role` → ROLE(role_id) **ON DELETE CASCADE** (BR-22) |
| permission_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép. `fk_role_permission_permission` → PERMISSION(permission_id) **ON DELETE CASCADE** (BR-22) |
