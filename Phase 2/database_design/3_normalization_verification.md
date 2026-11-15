# 2.3. Chứng minh Chuẩn hóa Dữ liệu (Normalization Verification: 1NF -> 3NF/BCNF)

Mục này chứng minh hình thức (formal proof) dạng chuẩn của **từng lược đồ quan hệ** trong số 18 bảng của [`01_schema_ddl.sql`](../../Phase%203/01_schema_ddl.sql). Với mỗi bảng, nhóm liệt kê tập phụ thuộc hàm (Functional Dependencies – FD), xác định các khóa dự tuyển bằng phép tính bao đóng, rồi kiểm tra lần lượt các điều kiện 1NF → 2NF → 3NF → BCNF theo định nghĩa của Elmasri & Navathe (*Fundamentals of Database Systems*, Chương 14).

---

## 2.3.1. Định nghĩa và phương pháp

### Ký hiệu

| Ký hiệu | Ý nghĩa |
|---|---|
| `X → Y` | Phụ thuộc hàm: hai bộ bất kỳ trùng giá trị trên `X` thì trùng giá trị trên `Y` |
| `X⁺` | Bao đóng của `X`: tập mọi thuộc tính suy ra được từ `X` theo hệ tiên đề Armstrong |
| <u>gạch chân</u> | Khóa chính (Primary Key) |
| Thuộc tính khóa (prime) | Thuộc tính thuộc ít nhất một khóa dự tuyển |
| Thuộc tính không khóa (non-prime) | Thuộc tính không thuộc khóa dự tuyển nào |

### Định nghĩa các dạng chuẩn

| Dạng chuẩn | Điều kiện (Elmasri) |
|---|---|
| **1NF** | Miền giá trị của mọi thuộc tính là nguyên tố; không có thuộc tính đa trị, thuộc tính phức hợp hay quan hệ lồng nhau. |
| **2NF** | Đạt 1NF, và mọi thuộc tính không khóa phụ thuộc hàm **đầy đủ** vào mọi khóa dự tuyển (không phụ thuộc vào một tập con thực sự của khóa). |
| **3NF** | Với mọi FD không tầm thường `X → A`: hoặc `X` là siêu khóa, hoặc `A` là thuộc tính khóa. Tương đương: không có thuộc tính không khóa nào phụ thuộc **bắc cầu** vào khóa. |
| **BCNF** | Với mọi FD không tầm thường `X → A`: `X` là siêu khóa. |

### Quy trình áp dụng cho mỗi bảng

1. **Xác định tập FD `F`** từ ngữ nghĩa nghiệp vụ (Phase 1) và các ràng buộc `PRIMARY KEY`, `UNIQUE`, `EXCLUDE` trong DDL.
2. **Tìm khóa dự tuyển:** với mỗi ứng viên `K`, tính `K⁺`. Nếu `K⁺` = toàn bộ thuộc tính và không tập con thực sự nào của `K` có tính chất này, thì `K` là khóa dự tuyển.
3. **Kiểm tra 1NF** dựa trên kiểu dữ liệu của cột.
4. **Kiểm tra 2NF:** chỉ cần xét khi có khóa dự tuyển gồm từ 2 thuộc tính trở lên. Bảng mà mọi khóa dự tuyển chỉ có 1 thuộc tính thì đạt 2NF ngay khi đạt 1NF.
5. **Kiểm tra BCNF** (từ đó suy ra 3NF): duyệt mọi FD trong `F` và kiểm tra vế trái có phải siêu khóa hay không.

### Bổ đề dùng chung

> **Bổ đề 1.** Nếu mọi FD không tầm thường của `R` đều có dạng `K → A` với `K` là một khóa dự tuyển, thì `R` đạt BCNF (và do đó đạt 3NF, 2NF).
>
> *Chứng minh:* Theo định nghĩa, khóa dự tuyển là siêu khóa, nên mọi FD đều thỏa điều kiện BCNF. Theo Elmasri, BCNF ⇒ 3NF ⇒ 2NF. ∎

> **Bổ đề 2.** Mọi bảng đều đạt 1NF.
>
> *Chứng minh:* Theo DDL, toàn bộ cột có kiểu vô hướng (`SERIAL`, `INT`, `VARCHAR`, `TEXT`, `DATE`, `TIMESTAMP`, `DECIMAL`, `BOOLEAN`). Không có cột kiểu mảng (`ARRAY`), `JSON` hay kiểu phức hợp. Các thuộc tính đa trị trong mô hình khái niệm đã được tách thành bảng riêng khi ánh xạ:
> - vai trò của người dùng → `user_role`;
> - quyền của vai trò → `role_permission`;
> - danh sách lớp hội viên đăng ký → `class_enrollment`;
> - danh sách thiết bị giữ chỗ cho một buổi tập → `equipment_reservation`.
>
> Các cột chứa văn bản tự do (`health_notes`, `bio`, `description`, `issue_description`) được hệ thống xử lý như **một giá trị duy nhất**, không bao giờ tách ra để truy vấn từng phần, nên vẫn là nguyên tố. Cột `password_hash` lưu một chuỗi băm duy nhất. ∎

---

## 2.3.2. Bảng tổng hợp kết quả

| # | Bảng | Khóa dự tuyển | 1NF | 2NF | 3NF | BCNF |
|---:|---|---|:---:|:---:|:---:|:---:|
| 1 | `user_account` | `{user_id}`, `{email}`, `{phone}` | ✔ | ✔ | ✔ | ✔ |
| 2 | `role` | `{role_id}`, `{role_name}` | ✔ | ✔ | ✔ | ✔ |
| 3 | `user_role` | `{user_id, role_id}` | ✔ | ✔ | ✔ | ✔ |
| 4 | `permission` | `{permission_id}`, `{permission_code}` | ✔ | ✔ | ✔ | ✔ |
| 5 | `role_permission` | `{role_id, permission_id}` | ✔ | ✔ | ✔ | ✔ |
| 6 | `member_profile` | `{user_id}` | ✔ | ✔ | ✔ | ✔ |
| 7 | `trainer_profile` | `{user_id}` | ✔ | ✔ | ✔ | ✔ |
| 8 | `staff_profile` | `{user_id}` | ✔ | ✔ | ✔ | ✔ |
| 9 | `membership_plan` | `{plan_id}` | ✔ | ✔ | ✔ | ✔ |
| 10 | `member_subscription` | `{subscription_id}` | ✔ | ✔ | ✔ | ✔ |
| 11 | `billing_log` | `{billing_id}`, `{invoice_no}` | ✔ | ✔ | ✔ | ✔ |
| 12 | `facilities_room` | `{room_id}` | ✔ | ✔ | ✔ | ✔ |
| 13 | `equipment` | `{equipment_id}`, `{serial_number}` | ✔ | ✔ | ✔ | ✔ |
| 14 | `class_schedule` | `{class_id}`, `{trainer_user_id, start_time}`, `{room_id, start_time}` | ✔ | ✔ | ✔ | ✔ |
| 15 | `class_enrollment` | `{enrollment_id}`, `{subscription_id, class_id}` | ✔ | ✔ | ✔ | ✔ |
| 16 | `pt_booking` | `{booking_id}` | ✔ | ✔ | ✘ | ✘ |
| 17 | `equipment_reservation` | `{reservation_id}` | ✔ | ✔ | ✔ | ✔ |
| 18 | `maintenance_log` | `{maintenance_id}` | ✔ | ✔ | ✔ | ✔ |

**Kết luận tổng quát:** 17/18 bảng đạt **BCNF**. Bảng `pt_booking` chỉ đạt **2NF** do có 2 phụ thuộc bắc cầu:

- `subscription_id → member_user_id` là một **phi chuẩn hóa có kiểm soát**: cần thiết để thực thi BR-16 bằng ràng buộc `EXCLUDE`, và tính nhất quán được bảo đảm bằng khóa ngoại ghép;
- `start_time → booking_date` là **dư thừa nên loại bỏ**.

Phân tích chi tiết và phương án tách về BCNF ở mục 2.3.4.

---

## 2.3.3. Chứng minh chi tiết từng bảng

> Ở các bảng dưới đây, sau khi áp dụng Bổ đề 2 (1NF), nhóm chỉ trình bày tập FD, khóa dự tuyển và lập luận BCNF. Mục **"FD bị loại trừ"** ghi lại các phụ thuộc có vẻ hợp lý nhưng **không** đúng với nghiệp vụ, kèm lý do. Đây là cơ sở để khẳng định bảng không có phụ thuộc bắc cầu ẩn.

### A. Phân hệ Tài khoản & Phân quyền (RBAC)

#### (1) USER_ACCOUNT(<u>user_id</u>, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at)

- **FD:**
  - F1: `user_id → full_name, email, phone, dob, emergency_contact, password_hash, status, created_at` (PK)
  - F2: `email → user_id` (`UNIQUE uq_user_account_email`, BR-02)
  - F3: `phone → user_id` (`UNIQUE uq_user_account_phone`, BR-02)
- **Khóa dự tuyển:**
  - `{user_id}⁺` = toàn bộ thuộc tính (F1).
  - `{email}⁺`: từ F2 có `user_id`, từ F1 suy ra mọi thuộc tính còn lại ⇒ `email` là khóa dự tuyển.
  - `{phone}⁺`: tương tự ⇒ `phone` là khóa dự tuyển.
  - Ba khóa đều chỉ có 1 thuộc tính nên hiển nhiên tối thiểu.
- **FD bị loại trừ:** `full_name ↛ *` (có thể trùng tên); `dob ↛ *`.
- **BCNF:** vế trái của F1, F2, F3 đều là khóa dự tuyển ⇒ **BCNF** (Bổ đề 1). ∎

#### (2) ROLE(<u>role_id</u>, role_name, description)

- **FD:** `role_id → role_name, description`; `role_name → role_id` (`UNIQUE uq_role_name`).
- **Khóa dự tuyển:** `{role_id}`, `{role_name}`.
- **BCNF:** mọi vế trái đều là khóa ⇒ **BCNF**. ∎

#### (3) USER_ROLE(<u>user_id, role_id</u>)

- **FD:** chỉ có FD tầm thường. Bảng không có thuộc tính không khóa (*all-key relation*).
- **Khóa dự tuyển:** `{user_id, role_id}`. Tối thiểu vì một người dùng có thể giữ nhiều vai trò (BR-22) và một vai trò có nhiều người dùng, nên không thuộc tính đơn lẻ nào xác định thuộc tính còn lại.
- **2NF:** không có thuộc tính không khóa ⇒ không thể có phụ thuộc bộ phận.
- **BCNF:** không có FD không tầm thường ⇒ **BCNF**. ∎

#### (4) PERMISSION(<u>permission_id</u>, permission_code, module_name, description)

- **FD:** `permission_id → permission_code, module_name, description`; `permission_code → permission_id` (`UNIQUE uq_permission_code`).
- **Khóa dự tuyển:** `{permission_id}`, `{permission_code}`.
- **FD bị loại trừ:** `module_name ↛ permission_code`. Một phân hệ có nhiều quyền; ví dụ phân hệ `Member` có 3 quyền `MEMBER_VIEW`, `MEMBER_CREATE`, `MEMBER_EDIT`.
- **BCNF:** mọi vế trái đều là khóa ⇒ **BCNF**. ∎

#### (5) ROLE_PERMISSION(<u>role_id, permission_id</u>)

- Bảng all-key, lập luận giống (3) ⇒ **BCNF**. ∎

### B. Phân hệ Hồ sơ chuyên biệt (lớp con EER, ánh xạ dùng chung khóa chính)

Ba bảng dưới đây là kết quả ánh xạ quan hệ chuyên biệt hóa `USER_ACCOUNT ⊃ {MEMBER, TRAINER, STAFF}` theo phương án **8A của Elmasri**: mỗi lớp con là một quan hệ riêng, dùng khóa chính của lớp cha làm khóa chính, đồng thời làm khóa ngoại. Các thuộc tính chung (họ tên, email, ngày sinh…) chỉ nằm ở `user_account`, nên không có dư thừa giữa lớp cha và lớp con.

#### (6) MEMBER_PROFILE(<u>user_id</u>, health_notes)

- **FD:** `user_id → health_notes`. **Khóa dự tuyển:** `{user_id}` ⇒ **BCNF**. ∎

#### (7) TRAINER_PROFILE(<u>user_id</u>, specialization, bio, current_rating)

- **FD:** `user_id → specialization, bio, current_rating`.
- **FD bị loại trừ:** `specialization ↛ current_rating`. Hai HLV cùng chuyên môn có điểm đánh giá khác nhau.
- **Khóa dự tuyển:** `{user_id}` ⇒ **BCNF**. ∎

#### (8) STAFF_PROFILE(<u>user_id</u>, job_title, department)

- **FD:** `user_id → job_title, department`.
- **FD bị loại trừ:** `job_title ↛ department`. Đây là điểm dễ gây nhầm là phụ thuộc bắc cầu. Nhóm quy ước nghiệp vụ: cùng một chức danh (ví dụ *Manager*, *Supervisor*) có thể tồn tại ở nhiều phòng ban, và một phòng ban có nhiều chức danh. Vì vậy `job_title` không xác định `department` và ngược lại.
  - *Nếu* phòng tập quy định mỗi chức danh chỉ thuộc một phòng ban, thì `user_id → job_title → department` là phụ thuộc bắc cầu. Khi đó phải tách thành `JOB_TITLE(job_title, department)` để đạt 3NF.
- **Khóa dự tuyển:** `{user_id}` ⇒ **BCNF** (theo quy ước trên). ∎

### C. Phân hệ Gói tập & Thanh toán

#### (9) MEMBERSHIP_PLAN(<u>plan_id</u>, plan_name, duration_days, total_sessions, price, description)

- **FD:** `plan_id → plan_name, duration_days, total_sessions, price, description`.
- **FD bị loại trừ:** `duration_days ↛ price` (gói 30 ngày thường và gói 30 ngày dành cho sinh viên có giá khác nhau); `total_sessions ↛ price`.
- **Khóa dự tuyển:** `{plan_id}` ⇒ **BCNF**. ∎

#### (10) MEMBER_SUBSCRIPTION(<u>subscription_id</u>, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at)

- **FD:** `subscription_id → member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at`.
- **FD bị loại trừ:** đây là bảng dễ bị nghi ngờ có phụ thuộc bắc cầu qua `plan_id` nhất, nên nhóm xét từng trường hợp:

  | FD giả định | Vì sao KHÔNG đúng |
  |---|---|
  | `plan_id → actual_price` | `actual_price` là giá **chốt tại thời điểm ký hợp đồng** (ảnh chụp lịch sử). Khi `membership_plan.price` thay đổi hoặc có khuyến mãi, các hợp đồng cũ vẫn giữ giá cũ. Hai hợp đồng cùng `plan_id` có thể có `actual_price` khác nhau. |
  | `plan_id → remaining_sessions` | Đây là trạng thái thay đổi theo từng hợp đồng (giảm dần khi trigger trừ buổi). Chỉ có giá trị khởi tạo bằng `total_sessions`. |
  | `{plan_id, start_time} → end_time` | Ngày kết thúc có thể được gia hạn, bảo lưu hoặc điều chỉnh thủ công. **Kiểm chứng trên dữ liệu mẫu: 29/30 hợp đồng có `end_time ≠ start_time + duration_days`.** |
  | `member_user_id → plan_id` | Một hội viên có nhiều hợp đồng theo thời gian (BR-05). |

- `uq_subscription_member UNIQUE (subscription_id, member_user_id)` là một **siêu khóa** (chứa khóa chính), không phải khóa dự tuyển. Ràng buộc này chỉ tồn tại để làm đích tham chiếu cho khóa ngoại ghép từ `pt_booking`.
- **Khóa dự tuyển:** `{subscription_id}` ⇒ **BCNF**. ∎

#### (11) BILLING_LOG(<u>billing_id</u>, subscription_id, invoice_no, amount, payment_date, payment_method, payment_status, created_at)

- **FD:** `billing_id → *`; `invoice_no → billing_id` (`UNIQUE uq_billing_invoice_no`, BR-09).
- **FD bị loại trừ:** `subscription_id ↛ amount` (một hợp đồng có nhiều kỳ thanh toán với số tiền khác nhau).
- **Khóa dự tuyển:** `{billing_id}`, `{invoice_no}`. Mọi vế trái đều là khóa ⇒ **BCNF**. ∎

### D. Phân hệ Cơ sở vật chất & Lịch tập

#### (12) FACILITIES_ROOM(<u>room_id</u>, room_name, max_capacity, room_type, status)

- **FD:** `room_id → room_name, max_capacity, room_type, status`.
- **FD bị loại trừ:** `room_type ↛ max_capacity`. **Phản ví dụ trong dữ liệu mẫu:** có 2 phòng loại `Gym_Floor` với sức chứa khác nhau (40 và 35). `room_name` không có ràng buộc `UNIQUE` nên không phải khóa.
- **Khóa dự tuyển:** `{room_id}` ⇒ **BCNF**. ∎

#### (13) EQUIPMENT(<u>equipment_id</u>, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status)

- **FD:** `equipment_id → *`; `serial_number → equipment_id` (`UNIQUE uq_equipment_serial`).
- **FD bị loại trừ:** `equipment_name ↛ depreciation_months` (cùng model máy, mua ở các thời điểm khác nhau có thể áp dụng chính sách khấu hao khác nhau).
- **Khóa dự tuyển:** `{equipment_id}`, `{serial_number}` ⇒ **BCNF**. ∎

#### (14) CLASS_SCHEDULE(<u>class_id</u>, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled)

- **FD:**
  - F1: `class_id → *` (PK)
  - F2: `{trainer_user_id, start_time} → class_id`
  - F3: `{room_id, start_time} → class_id`
- **Chứng minh F2, F3 là FD:** ràng buộc `ex_class_trainer_no_overlap` cấm hai lớp của cùng một HLV có khoảng `[start_time, end_time)` giao nhau. Giả sử tồn tại hai bộ khác nhau `t1`, `t2` có `t1.trainer_user_id = t2.trainer_user_id` và `t1.start_time = t2.start_time`. Do `chk_class_time` bảo đảm `end_time > start_time`, cả hai khoảng đều chứa thời điểm `start_time`, nên hai khoảng giao nhau. Điều này mâu thuẫn với ràng buộc `EXCLUDE`. Vậy F2 đúng. F3 chứng minh tương tự với `ex_class_room_no_overlap`. ∎
- **Khóa dự tuyển:** `{class_id}`, `{trainer_user_id, start_time}`, `{room_id, start_time}`. Hai khóa ghép là tối thiểu vì một HLV dạy nhiều lớp ở các thời điểm khác nhau, và nhiều HLV có lớp bắt đầu cùng giờ.
- **2NF (có khóa ghép):** không thuộc tính không khóa nào phụ thuộc vào một phần của khóa ghép. `trainer_user_id` một mình không xác định `class_name` (HLV dạy nhiều lớp), và `start_time` một mình không xác định `room_id` (nhiều lớp cùng giờ ở các phòng khác nhau).
- **BCNF:** vế trái của F1–F3 đều là khóa ⇒ **BCNF**.
- **Ghi chú về `current_enrolled`:** cột này bằng `COUNT(*)` các bản ghi `class_enrollment` có trạng thái `Enrolled` hoặc `Attended`. Đây là **dữ liệu dẫn xuất giữa các bảng**, không phải FD bên trong `class_schedule`, nên không ảnh hưởng đến dạng chuẩn. Nhóm giữ cột này để có thể khai báo `CHECK (current_enrolled <= max_capacity)` (BR-14). Tính nhất quán được trigger `trg_sync_class_enrollment_count` bảo đảm, đã kiểm chứng ở test **TP-03** và **TP-04** (`Phase 3/07_test_results.md`). ∎

#### (15) CLASS_ENROLLMENT(<u>enrollment_id</u>, subscription_id, class_id, enrollment_date, status)

- **FD:** `enrollment_id → *`; `{subscription_id, class_id} → enrollment_id` (`UNIQUE uq_enrollment_subscription_class`).
- **Khóa dự tuyển:** `{enrollment_id}`, `{subscription_id, class_id}`.
- **2NF:** xét khóa ghép `{subscription_id, class_id}`:
  - `subscription_id ↛ status`: cùng một hợp đồng có thể `Attended` lớp này nhưng `Cancelled` lớp khác.
  - `class_id ↛ enrollment_date`: các hội viên đăng ký cùng một lớp vào các ngày khác nhau.

  ⇒ Không có phụ thuộc bộ phận.
- **BCNF:** mọi vế trái đều là khóa ⇒ **BCNF**. ∎

#### (16) PT_BOOKING – xem phân tích riêng ở mục 2.3.4.

#### (17) EQUIPMENT_RESERVATION(<u>reservation_id</u>, equipment_id, booking_id, class_id, start_time, end_time, status)

- **FD:** `reservation_id → *`.
- **FD bị loại trừ:** `booking_id ↛ start_time` và `class_id ↛ start_time`. Một buổi tập có thể giữ nhiều máy, mỗi máy cho một khung giờ con khác nhau trong buổi (ví dụ 15 phút máy chạy đầu buổi, 30 phút giàn tạ cuối buổi). Vì vậy thời gian giữ chỗ là thuộc tính riêng của lượt giữ chỗ, không suy ra được từ buổi tập.
- **1NF với cặp khóa ngoại loại trừ nhau:** `booking_id` và `class_id` là hai thuộc tính đơn trị có thể `NULL` (*exclusive arc*). `CHECK chk_reservation_source` bảo đảm đúng một trong hai có giá trị. `NULL` không phải giá trị đa trị nên không vi phạm 1NF.
- **Khóa dự tuyển:** `{reservation_id}` ⇒ **BCNF**. ∎

#### (18) MAINTENANCE_LOG(<u>maintenance_id</u>, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status, created_at)

- **FD:** `maintenance_id → *`.
- **FD bị loại trừ:** `equipment_id ↛ staff_user_id` (mỗi lần bảo trì có thể do kỹ thuật viên khác xử lý); `{equipment_id, start_time}` không được khai báo `UNIQUE` nên không phải khóa.
- **Khóa dự tuyển:** `{maintenance_id}` ⇒ **BCNF**. ∎

---

## 2.3.4. Phân tích bảng PT_BOOKING (chỉ đạt 2NF) và phương án chuẩn hóa

**PT_BOOKING**(<u>booking_id</u>, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at)

### Tập phụ thuộc hàm

| FD | Nguồn gốc |
|---|---|
| F1: `booking_id → member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at` | Khóa chính |
| F2: `subscription_id → member_user_id` | Mỗi hợp đồng thuộc đúng một hội viên. FD này được kéo theo từ `member_subscription`, nơi `subscription_id` là khóa. |
| F3: `start_time → booking_date` | `booking_date` luôn bằng `start_time::DATE`. **Kiểm chứng: 35/35 bản ghi mẫu thỏa mãn.** |

### Khóa dự tuyển

`{booking_id}⁺` = toàn bộ thuộc tính. Các ứng viên khác đều không phải khóa:

- `{subscription_id}`: một hợp đồng có nhiều ca PT;
- `{start_time}`: nhiều ca PT bắt đầu cùng giờ;
- `{trainer_user_id, start_time}`: ràng buộc `ex_pt_trainer_no_overlap` chỉ áp dụng cho bản ghi có `status <> 'Cancelled'`, nên một ca đã hủy và một ca mới có thể trùng cặp giá trị này (đã kiểm chứng ở test **TP-05**).

⇒ **Khóa dự tuyển duy nhất là `{booking_id}`.**

### Kiểm tra từng dạng chuẩn

- **1NF:** đạt (Bổ đề 2).
- **2NF:** khóa dự tuyển duy nhất có 1 thuộc tính ⇒ không thể có phụ thuộc bộ phận ⇒ **đạt 2NF**.
- **3NF:** xét F2 `subscription_id → member_user_id`: `subscription_id` không phải siêu khóa, và `member_user_id` là thuộc tính không khóa. Tồn tại chuỗi bắc cầu `booking_id → subscription_id → member_user_id` ⇒ **vi phạm 3NF**. F3 vi phạm tương tự qua `booking_id → start_time → booking_date`.
- **BCNF:** vi phạm (vì không đạt 3NF).

### Bất thường dữ liệu tiềm ẩn

| Loại bất thường | Ví dụ |
|---|---|
| Cập nhật (F2) | Nếu chuyển hợp đồng sang hội viên khác mà chỉ sửa `member_subscription`, các ca PT cũ sẽ ghi sai hội viên. |
| Cập nhật (F3) | Đổi giờ ca PT sang ngày hôm sau nhưng quên sửa `booking_date` khiến hai cột mâu thuẫn. Truy vấn phức hợp số 2 lọc theo `booking_date` sẽ thống kê sai giờ dạy. |
| Chèn (F2) | Có thể chèn một ca PT có `member_user_id` khác với chủ của `subscription_id`. |

### Đánh giá và quyết định thiết kế

**(a) `member_user_id`: giữ lại, phi chuẩn hóa có kiểm soát.**

- *Lý do giữ:* BR-16 yêu cầu một hội viên không có 2 ca PT chồng giờ. Trong PostgreSQL, ràng buộc `EXCLUDE USING gist` chỉ tham chiếu được các cột **cùng bảng**. Nếu bỏ `member_user_id`, ràng buộc `ex_pt_member_no_overlap` không thể khai báo được, và BR-16 phải chuyển sang trigger, vốn chậm hơn và dễ sai khi có giao dịch đồng thời.
- *Cơ chế loại trừ bất thường:* khóa ngoại ghép

  ```sql
  CONSTRAINT fk_booking_subscription_member FOREIGN KEY (subscription_id, member_user_id)
      REFERENCES member_subscription (subscription_id, member_user_id) ON DELETE RESTRICT
  ```

  bảo đảm cặp `(subscription_id, member_user_id)` trong `pt_booking` **luôn trùng khớp** với `member_subscription`. Bất thường chèn ở bảng trên đã được kiểm chứng là bị chặn (test **TC-29**, lỗi `23503`). Bất thường cập nhật cũng bị chặn, vì sửa `member_user_id` ở bảng cha khi đã có ca PT tham chiếu sẽ vi phạm khóa ngoại (`ON UPDATE` mặc định là `NO ACTION`).
- ⇒ Dư thừa vẫn tồn tại về mặt lưu trữ, nhưng **không thể dẫn đến dữ liệu mâu thuẫn**.

**(b) `booking_date`: dư thừa, đề xuất loại bỏ.**

Thuộc tính này không phục vụ ràng buộc nào và hiện **không có cơ chế nào bảo đảm nhất quán** với `start_time`. Đề xuất chọn một trong ba cách (dữ liệu mẫu hiện tại tương thích với cả ba):

```sql
-- Cách 1 (chuẩn hóa triệt để): xóa cột, dùng start_time::DATE khi cần
ALTER TABLE pt_booking DROP COLUMN booking_date;

-- Cách 2: giữ cột nhưng để CSDL tự tính (cột sinh, không thể sai lệch)
ALTER TABLE pt_booking DROP COLUMN booking_date;
ALTER TABLE pt_booking ADD COLUMN booking_date DATE GENERATED ALWAYS AS (start_time::DATE) STORED;

-- Cách 3 (thay đổi tối thiểu): thêm ràng buộc kiểm tra
ALTER TABLE pt_booking ADD CONSTRAINT chk_pt_booking_date CHECK (booking_date = start_time::DATE);
```

> Cách 1 và 2 cần cập nhật lệnh `INSERT` trong dữ liệu mẫu và ứng dụng (không chèn giá trị cho `booking_date` nữa). Truy vấn phức hợp số 2 và số 6 (đang dùng `pb.booking_date`) vẫn chạy được với Cách 2 và 3; với Cách 1 cần thay `pb.booking_date` bằng `pb.start_time::DATE`.

### Phân rã về BCNF (phương án đối chiếu)

Nếu áp dụng chuẩn hóa tuyệt đối, phân rã `PT_BOOKING` theo F2 và F3:

- **PT_BOOKING_BCNF**(<u>booking_id</u>, trainer_user_id, subscription_id, start_time, end_time, status, created_at)
- `member_user_id` lấy qua phép nối với **MEMBER_SUBSCRIPTION**(<u>subscription_id</u>, member_user_id, …), vốn đã đạt BCNF;
- `booking_date` tính bằng biểu thức `start_time::DATE`.

**Chứng minh phân rã bảo toàn thông tin (lossless join):** theo Elmasri (Tính chất NJB), phân rã `R` thành `{R1, R2}` là không mất mát nếu `(R1 ∩ R2) → (R1 − R2)` hoặc `(R1 ∩ R2) → (R2 − R1)` thuộc `F⁺`. Ở đây `R1 ∩ R2 = {subscription_id}`, và `subscription_id` là khóa của `MEMBER_SUBSCRIPTION` nên `subscription_id → (R2 − R1)`. Vậy phân rã là **lossless**. ∎

**Bảo toàn phụ thuộc:** F1 (bỏ 2 thuộc tính đã tách) nằm trong `PT_BOOKING_BCNF`, F2 nằm trong `MEMBER_SUBSCRIPTION`, còn F3 trở thành biểu thức tính toán ⇒ phân rã **bảo toàn phụ thuộc**.

**Cái giá phải trả:** mất khả năng thực thi BR-16 bằng `EXCLUDE`, như đã phân tích ở mục (a). Vì vậy nhóm chọn giữ lược đồ hiện tại cho `member_user_id` và đề xuất xử lý `booking_date`.

---

## 2.3.5. Kết luận

1. **17/18 bảng đạt BCNF.** Mọi phụ thuộc hàm không tầm thường đều có vế trái là khóa dự tuyển. Các phụ thuộc "có vẻ hợp lý" đã được xét và loại trừ bằng lập luận nghiệp vụ, hoặc bằng phản ví dụ từ dữ liệu mẫu.
2. **`pt_booking` đạt 2NF.** Vi phạm 3NF do `subscription_id → member_user_id` là phi chuẩn hóa có chủ đích, phục vụ ràng buộc `EXCLUDE` (BR-16); tính nhất quán được khóa ngoại ghép bảo đảm tuyệt đối. Vi phạm do `start_time → booking_date` là dư thừa cần xử lý theo một trong ba cách ở mục 2.3.4.
3. Các thuộc tính **ảnh chụp lịch sử** (`actual_price`, `end_time`, `remaining_sessions` trong `member_subscription`) và **dữ liệu dẫn xuất được trigger đồng bộ** (`current_enrolled`) không tạo ra phụ thuộc bắc cầu. Chúng được giữ có chủ đích để bảo toàn lịch sử giao dịch và để thực thi ràng buộc ở mức CSDL.
