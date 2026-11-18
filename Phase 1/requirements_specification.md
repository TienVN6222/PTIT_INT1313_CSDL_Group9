# Đặc tả Yêu cầu Phần mềm (Software Requirements Specification)

**Dự án:** Gym Membership & Personal Training Planner (Nhóm G9, INT1313)
**Chuẩn tham chiếu:** ISO/IEC/IEEE 29148 (Systems and software engineering — Life cycle processes — Requirements engineering), được điều chỉnh cho phạm vi một dự án cơ sở dữ liệu.
**Nguồn sự thật triển khai:** `Phase 3/01_schema_ddl.sql`, `Phase 3/04_triggers_views.sql`, `Phase 3/08_rbac_security.sql`.

Quy ước: mọi yêu cầu dùng động từ **"phải"** và có thể kiểm chứng (testable). Mã `UR-xx` là yêu cầu người dùng (viết bằng ngôn ngữ nghiệp vụ); `FR-xx` / `NFR-xx` là yêu cầu hệ thống (viết theo dữ liệu và hành vi của hệ thống); `BR-xx` xem [business_rules.md](business_rules.md).

---

## 1. Giới thiệu

### 1.1. Mục đích

Tài liệu này xác định yêu cầu cho hệ thống cơ sở dữ liệu quản lý phòng tập thể hình, tách biệt rõ **nhu cầu của người dùng** (mục 3) với **năng lực mà hệ thống phải cung cấp** (mục 4), và nối hai phần bằng ma trận truy vết (mục 6). Đối tượng đọc: giảng viên, nhóm phát triển, người kiểm thử.

### 1.2. Phạm vi

Hệ thống gồm cơ sở dữ liệu PostgreSQL 16 (18 bảng, 2 view, trigger và 1 thủ tục), kèm ứng dụng Streamlit minh họa. Phạm vi nghiệp vụ gồm: tài khoản và phân quyền, gói tập và hợp đồng, hóa đơn, lớp nhóm, ca PT 1-1, thiết bị và bảo trì, báo cáo. Nội dung ngoài phạm vi xem [project_scope.md](project_scope.md), mục 1.5.

### 1.3. Định nghĩa và thuật ngữ

| Thuật ngữ | Ý nghĩa |
| :--- | :--- |
| PT (Personal Training) | Buổi huấn luyện cá nhân 1-1 giữa hội viên và huấn luyện viên, diễn ra ở khu tập tự do (không gắn phòng) |
| Hợp đồng (`member_subscription`) | Việc hội viên đăng ký một gói tập trong một khoảng thời gian |
| Hóa đơn (`billing_log`) | Bản ghi thanh toán, bất biến sau khi hoàn tất |
| Ân hạn (grace period) | Số ngày (mặc định 3) sau hạn hợp đồng tự gia hạn mà chưa thanh toán thì hợp đồng bị tạm ngưng |
| RBAC | Role-Based Access Control — phân quyền theo vai trò |
| Least privilege | Chỉ cấp quyền tối thiểu cần cho nhiệm vụ |
| BR | Business Rule — quy tắc nghiệp vụ, xem `business_rules.md` |
| UR / FR / NFR | Yêu cầu người dùng / chức năng hệ thống / phi chức năng |

---

## 2. Bên liên quan và nhóm người dùng

| Nhóm | Vai trò CSDL | Mục tiêu chính |
| :--- | :--- | :--- |
| Admin (quản trị) | `gym_role_admin` | Quản lý toàn bộ danh mục, tài khoản, phân quyền, xem báo cáo doanh thu và hiệu suất; không được sửa dữ liệu thanh toán |
| Receptionist (lễ tân) | `gym_role_receptionist` | Tiếp đón, tạo hồ sơ hội viên, bán gói, thu tiền, xếp lớp, đặt ca PT cho hội viên |
| Trainer (HLV) | `gym_role_trainer` | Xem lịch dạy lớp và ca PT của mình, điểm danh, đánh dấu hoàn thành/bỏ tập |
| Technician (kỹ thuật viên) | `gym_role_technician` | Quản lý thiết bị, ghi nhật ký bảo trì, đặt trạng thái bảo trì phòng/thiết bị |
| Member (hội viên) | `gym_role_member` | Xem gói tập, lịch lớp, tình trạng phòng; theo dõi quyền lợi của mình |
| Giảng viên / người chấm | — | Kiểm chứng thiết kế, ràng buộc, hiệu năng và phân quyền |

---

## 3. Yêu cầu người dùng (User Requirements)

Các yêu cầu dưới đây mô tả điều người dùng cần, không nêu cách cài đặt.

| Mã | Người dùng | Yêu cầu người dùng |
| :--- | :--- | :--- |
| UR-01 | Admin, Lễ tân | Tôi phải tạo và quản lý được tài khoản của hội viên, HLV, nhân viên với thông tin liên hệ không bị trùng. |
| UR-02 | Admin | Tôi phải gán được vai trò cho từng người dùng để mỗi người chỉ làm đúng việc của mình. |
| UR-03 | Lễ tân | Tôi phải đăng ký được gói tập cho hội viên và biết hợp đồng nào đang có hiệu lực. |
| UR-04 | Lễ tân | Tôi phải ghi nhận được thanh toán, và hợp đồng chỉ có hiệu lực khi đã thanh toán. |
| UR-05 | Admin, Lễ tân | Tôi phải được bảo đảm hóa đơn đã ghi nhận không bị sửa hoặc xóa tùy ý, để việc đối soát luôn đáng tin cậy. |
| UR-06 | Hội viên, Lễ tân | Hợp đồng dài hạn phải tự gia hạn đúng hạn, và hội viên không trả tiền phải bị tạm ngưng sau thời gian ân hạn. |
| UR-07 | Lễ tân, HLV | Tôi phải lập được lịch lớp nhóm mà không bị trùng giờ HLV hay trùng phòng. |
| UR-08 | Lễ tân, Hội viên | Hội viên phải đăng ký được lớp, nhưng không vượt quá sức chứa và không bị trùng với lịch khác của họ. |
| UR-09 | Lễ tân, Hội viên | Tôi phải đặt được ca PT khi hội viên còn buổi, và buổi tập phải được trừ chính xác. |
| UR-10 | Hội viên, HLV | Chính sách hủy ca PT phải rõ ràng: hủy sớm không mất buổi, hủy muộn hoặc bỏ tập thì mất buổi. |
| UR-11 | HLV | Tôi phải xem được lịch dạy tổng hợp (lớp và PT) và điểm danh được buổi của mình. |
| UR-12 | Kỹ thuật viên | Tôi phải quản lý được danh mục thiết bị, ngày mua, khấu hao và lịch sử bảo trì kèm chi phí. |
| UR-13 | Lễ tân, HLV | Thiết bị hoặc phòng đang bảo trì không được xếp vào lịch mới, và một máy không bị hai ca giữ cùng lúc. |
| UR-14 | Admin | Tôi phải xem được báo cáo doanh thu, tỷ lệ lấp đầy lớp, hiệu suất HLV, và các hợp đồng sắp hết hạn. |
| UR-15 | Admin | Tôi phải truy vết được ai đã tạo hoặc sửa mỗi giao dịch quan trọng (hợp đồng, hóa đơn, lịch lớp, ca PT, bảo trì). |
| UR-16 | Mọi người dùng | Mật khẩu và thông tin nhạy cảm của tôi phải được bảo vệ. |
| UR-17 | Mọi người dùng | Tra cứu thông tin phải phản hồi nhanh, không phải chờ đáng kể khi dữ liệu lớn. |
| UR-18 | Admin | Dữ liệu phải được sao lưu để khôi phục được khi có sự cố. |

---

## 4. Yêu cầu hệ thống (System Requirements)

### 4.1. Yêu cầu chức năng (Functional Requirements)

#### Nhóm A — Tài khoản và phân quyền (RBAC)

| Mã | Yêu cầu | BR |
| :--- | :--- | :--- |
| FR-01 | Hệ thống phải cho phép tạo tài khoản `user_account` với email và số điện thoại duy nhất, ngày sinh bắt buộc, trạng thái thuộc `Active`/`Inactive`/`Suspended`. | BR-02 |
| FR-02 | Hệ thống phải từ chối tạo hoặc sửa hồ sơ hội viên có ngày sinh dưới 12 tuổi. | BR-03 |
| FR-03 | Hệ thống phải lưu hồ sơ chuyên biệt 1:1 theo khóa chính dùng chung: `member_profile`, `trainer_profile` (điểm đánh giá 0–5), `staff_profile`. | BR-01, BR-11 |
| FR-04 | Hệ thống phải cho phép gán một hoặc nhiều vai trò cho tài khoản qua `user_role`, không cho gán trùng một vai trò hai lần, và lưu ma trận quyền trong `role_permission`. | BR-22 |
| FR-05 | Hệ thống phải cung cấp 5 role CSDL (`gym_role_admin`, `gym_role_receptionist`, `gym_role_trainer`, `gym_role_technician`, `gym_role_member`) với quyền `GRANT` đúng ma trận quyền trong `08_rbac_security.sql`. | BR-22 |

#### Nhóm B — Gói tập, hợp đồng và thanh toán

| Mã | Yêu cầu | BR |
| :--- | :--- | :--- |
| FR-06 | Hệ thống phải cho phép quản lý gói tập (`membership_plan`) với thời hạn `duration_days > 0`, `total_sessions >= 0`, `price >= 0`, và phải từ chối xóa gói đang được hợp đồng sử dụng. | BR-04 |
| FR-07 | Hệ thống phải cho phép Lễ tân tạo hợp đồng (`member_subscription`) ở trạng thái `Pending`, với `end_time >= start_time` và `remaining_sessions >= 0`. | BR-06 |
| FR-08 | Hệ thống phải bảo đảm mỗi hội viên có tối đa một hợp đồng `Active` tại một thời điểm. | BR-05 |
| FR-09 | Hệ thống phải từ chối chuyển hợp đồng sang `Active` khi chưa có hóa đơn `Completed`, và phải tự chuyển hợp đồng `Pending` sang `Active` khi hóa đơn của nó được ghi nhận `Completed`. | BR-07 |
| FR-10 | Hệ thống phải cho phép ghi hóa đơn (`billing_log`) với `invoice_no` duy nhất, `amount > 0`, phương thức và trạng thái thuộc miền giá trị quy định. | BR-09 |
| FR-11 | Hệ thống phải bảo đảm mỗi chu kỳ tính phí (`billing_period_start`) của một hợp đồng chỉ có tối đa một hóa đơn `Pending` hoặc `Completed`. | BR-08 |
| FR-12 | Hệ thống phải từ chối xóa và `TRUNCATE` hóa đơn; hóa đơn `Completed` chỉ được chuyển sang `Refunded` và không được đổi cột nào khác; hóa đơn `Failed`/`Refunded` không được sửa; việc `ALTER`/`DROP` bảng `billing_log`, trigger bất biến và các hàm trigger bất biến cũng bị chặn (kể cả với superuser, trừ khi bảo trì có chủ đích). | BR-10 |
| FR-13 | Hệ thống phải cung cấp thủ tục `sp_process_subscription_renewals(p_as_of, p_grace_days)` để: chuyển hợp đồng không tự gia hạn quá hạn sang `Expired`; phát hành hóa đơn `Pending` cho hợp đồng tự gia hạn quá hạn; chuyển hợp đồng tự gia hạn sang `Suspended` khi quá hạn ân hạn mà chưa thanh toán; thủ tục phải idempotent. | BR-24 |
| FR-14 | Hệ thống phải gia hạn hợp đồng (cộng `duration_days`, đặt lại `remaining_sessions`, chuyển `Active`) khi hóa đơn gia hạn được thanh toán. | BR-24, BR-07 |

#### Nhóm C — Lớp học nhóm

| Mã | Yêu cầu | BR |
| :--- | :--- | :--- |
| FR-15 | Hệ thống phải cho phép tạo lịch lớp (`class_schedule`) với `end_time > start_time`, `max_capacity > 0`, và phải từ chối lịch chồng giờ của cùng HLV hoặc cùng phòng. | BR-12, BR-15, BR-17 |
| FR-16 | Hệ thống phải từ chối xếp lớp vào phòng không ở trạng thái `Active` (`Under_Maintenance` hoặc `Inactive`), và từ chối chuyển phòng sang `Under_Maintenance` hoặc `Inactive` khi phòng còn lớp học sắp diễn ra. | BR-19 |
| FR-17 | Hệ thống phải cho phép đăng ký lớp (`class_enrollment`), mỗi hợp đồng một lần cho mỗi lớp, và phải tự cập nhật `current_enrolled` khi đăng ký, hủy hoặc xóa. | BR-14 |
| FR-18 | Hệ thống phải từ chối đăng ký khi lớp đã đủ `max_capacity`. | BR-14 |
| FR-19 | Hệ thống phải từ chối đăng ký lớp trùng giờ với ca PT hoặc lớp khác của cùng hội viên, và từ chối xếp lớp trùng ca PT của HLV. | BR-12, BR-16 |
| FR-20 | Hệ thống phải lưu phòng tập (`facilities_room`) với `max_capacity > 0` và trạng thái `Active`/`Under_Maintenance`/`Inactive`. | BR-13 |

#### Nhóm D — Huấn luyện cá nhân (PT)

| Mã | Yêu cầu | BR |
| :--- | :--- | :--- |
| FR-21 | Hệ thống phải cho phép Lễ tân tạo ca PT (`pt_booking`) chỉ khi hợp đồng thuộc đúng hội viên, đang `Active`, giờ tập nằm trong thời hạn hợp đồng, và số buổi còn lại lớn hơn số ca `Scheduled` đang chờ. | BR-18 |
| FR-22 | Hệ thống phải từ chối ca PT chồng giờ của cùng HLV hoặc cùng hội viên (bỏ qua ca đã hủy), và chồng với lớp nhóm tương ứng. | BR-12, BR-16 |
| FR-23 | Hệ thống phải bảo đảm `end_time > start_time` và `booking_date` trùng ngày của `start_time` cho mọi ca PT. | BR-17 |
| FR-24 | Hệ thống phải tự trừ 1 buổi `remaining_sessions` khi ca PT chuyển sang `Completed`, `No_Show` hoặc `Late_Cancelled`, và không trừ lần hai khi chuyển giữa các trạng thái tính phí; phải từ chối khi `remaining_sessions` bằng 0. | BR-18, BR-25 |
| FR-25 | Hệ thống phải xử lý hủy ca PT: hủy khi còn từ 24 giờ trở lên giữ trạng thái `Cancelled` (không trừ buổi); hủy khi còn dưới 24 giờ tự đổi thành `Late_Cancelled` (trừ 1 buổi). | BR-25 |

#### Nhóm E — Thiết bị và bảo trì

| Mã | Yêu cầu | BR |
| :--- | :--- | :--- |
| FR-26 | Hệ thống phải lưu thiết bị (`equipment`) với `serial_number` duy nhất, `purchase_date` bắt buộc, `depreciation_months > 0`. | BR-26 |
| FR-27 | Hệ thống phải cho phép giữ chỗ thiết bị (`equipment_reservation`) gắn đúng một nguồn (ca PT hoặc lớp), và từ chối giữ chỗ trùng giờ trên cùng thiết bị. | BR-21 |
| FR-28 | Hệ thống phải từ chối giữ chỗ thiết bị không ở trạng thái `Operational` (`Under_Maintenance` hoặc `Decommissioned`), hoặc trùng khung giờ ca bảo trì `In_Progress`, hoặc vượt ngoài khung giờ của ca/lớp gắn kèm; từ chối chuyển thiết bị sang `Under_Maintenance` hoặc `Decommissioned` khi còn lượt giữ chỗ `Reserved` trong tương lai; và tự đồng bộ trạng thái thiết bị theo nhật ký bảo trì (mở ca `In_Progress` → `Under_Maintenance`; ca kết thúc và không còn ca đang sửa → `Operational`). | BR-19, BR-21 |
| FR-29 | Hệ thống phải cho phép Kỹ thuật viên ghi nhật ký bảo trì (`maintenance_log`) với `cost >= 0`, `end_time >= start_time` (nếu có) và người thực hiện là nhân viên. | BR-20 |
| FR-30 | Hệ thống phải bắt buộc ghi `created_by_user_id` (NOT NULL) từ biến phiên `app.current_user_id` khi tạo hợp đồng, hóa đơn, lịch lớp, ca PT và nhật ký bảo trì, từ chối thao tác nếu chưa đặt biến phiên; và phải ghi `updated_by_user_id`, `updated_at` ở mỗi `UPDATE` đồng thời cấm đổi `created_by_user_id`. | BR-23 |

#### Nhóm F — Báo cáo và truy vấn

| Mã | Yêu cầu | BR |
| :--- | :--- | :--- |
| FR-31 | Hệ thống phải cung cấp view `vw_active_member_subscriptions` liệt kê hợp đồng đang hiệu lực. | BR-05 |
| FR-32 | Hệ thống phải cung cấp view `vw_trainer_schedule_overview` hợp nhất lịch lớp và ca PT của HLV. | BR-12 |
| FR-33 | Hệ thống phải cung cấp các truy vấn báo cáo trong `03_complex_queries.sql` (doanh thu theo kỳ, tỷ lệ lấp đầy lớp, hiệu suất HLV, hợp đồng sắp hết hạn, chi phí bảo trì). | — |

### 4.2. Yêu cầu phi chức năng (Non-functional Requirements)

#### Bảo mật (Security)

| Mã | Yêu cầu |
| :--- | :--- |
| NFR-SEC-01 | Hệ thống phải áp dụng đặc quyền tối thiểu: `REVOKE ALL` trên mọi bảng và sequence của schema `public` khỏi `PUBLIC`, sau đó chỉ `GRANT` cho 5 role nhóm đúng quyền theo ma trận trong `08_rbac_security.sql`; không role nào có `TRUNCATE`; Lễ tân không có `DELETE` ở bất kỳ bảng nào. |
| NFR-SEC-02 | Mật khẩu phải chỉ được lưu dưới dạng băm trong `user_account.password_hash` (không lưu bản rõ), và cột này phải không đọc được (`SELECT` mức cột không gồm `password_hash`) bởi mọi role ứng dụng; Lễ tân không được `UPDATE` cột này. |
| NFR-SEC-03 | Dữ liệu phải được mã hóa khi lưu trữ (encryption at rest). **Đã thực thi trong bản demo:** kết nối mạng đến CSDL bắt buộc dùng TLS (`ssl=on`, TLS tối thiểu 1.2, `pg_hba.conf` chỉ cho `hostssl` với `scram-sha-256`, từ chối `hostnossl`) và bản sao lưu được mã hóa AES-256-CBC. **Còn thuộc hạ tầng:** mã hóa tệp dữ liệu trên đĩa máy chủ (Docker volume; LUKS hoặc mã hóa đĩa của nhà cung cấp đám mây); chứng chỉ demo tự ký, khi triển khai thật dùng chứng chỉ của CA; mật khẩu mẫu `demo_2026` của các tài khoản `gym_u_*` phải được đổi. |
| NFR-SEC-04 | Hóa đơn phải bất biến theo bốn lớp: (1) trigger `trg_billing_immutable_*` chặn `UPDATE`/`DELETE`/`TRUNCATE` sai quy định; (2) mọi role ứng dụng (kể cả Admin) chỉ có `SELECT, INSERT` trên `billing_log`; (3) mọi đối tượng ứng dụng thuộc role `NOLOGIN` `gym_owner`, không tài khoản đăng nhập nào là chủ sở hữu; (4) event trigger `evt_protect_billing_log`/`_drop` chặn `ALTER`/`DROP` `billing_log`, trigger và hàm bất biến, kể cả với superuser (superuser chỉ bảo trì được bằng thao tác tường minh `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`). |
| NFR-SEC-05 | Hàm trigger cần ghi vào bảng mà role gọi không có quyền phải chạy `SECURITY DEFINER` với `search_path` cố định (`public, pg_temp`) để không phải cấp thêm quyền ghi cho role. |

#### Hiệu năng (Performance)

| Mã | Yêu cầu |
| :--- | :--- |
| NFR-PERF-01 | Các truy vấn tra cứu/tìm kiếm chính phải trả kết quả dưới 200 ms với khối lượng 100.000 – 200.000 bản ghi mỗi bảng nghiệp vụ; chứng minh bằng `Phase 3/06_performance_test_cases.sql` (so sánh có và không có chỉ mục). |
| NFR-PERF-02 | Hệ thống phải có chỉ mục hỗ trợ truy vấn thường dùng, ví dụ `idx_member_subscription_member`, `idx_billing_log_subscription_date`, `idx_pt_booking_trainer`, `idx_pt_booking_dates`, `idx_class_schedule_dates`. |

#### Toàn vẹn dữ liệu (Integrity)

| Mã | Yêu cầu |
| :--- | :--- |
| NFR-INT-01 | Mọi quan hệ phải được bảo vệ bằng khóa ngoại với hành động tham chiếu rõ ràng (`ON DELETE RESTRICT` cho dữ liệu giao dịch; `CASCADE` chỉ cho hồ sơ 1:1 và lượt giữ chỗ phụ thuộc). |
| NFR-INT-02 | Miền giá trị (trạng thái, phương thức thanh toán, số lượng, tiền, thời gian) phải được thực thi bằng `CHECK`, `NOT NULL`, `UNIQUE` ở mức CSDL, không chỉ ở ứng dụng. |
| NFR-INT-03 | Xung đột lịch phải được chặn bằng ràng buộc `EXCLUDE USING gist` (cùng bảng) và trigger (xuyên bảng) để không phụ thuộc kiểm tra phía ứng dụng. |
| NFR-INT-04 | Cập nhật số buổi PT và sĩ số lớp phải an toàn khi truy cập đồng thời (khóa hàng `FOR UPDATE`, khóa tư vấn theo hợp đồng). |
| NFR-INT-05 | Dữ liệu mẫu phải thỏa mọi quy tắc; khối kiểm toán dữ liệu (`DO` cuối `04_triggers_views.sql`) phải báo lỗi nếu có dòng vi phạm. |

#### Sẵn sàng và sao lưu (Availability / Backup)

| Mã | Yêu cầu |
| :--- | :--- |
| NFR-AVL-01 | Khi triển khai thật, quản trị phải sao lưu định kỳ (khuyến nghị `pg_dump` hằng ngày kèm sao lưu liên tục WAL) và kiểm tra khôi phục. **Đã thực thi trong bản demo:** service `backup` chạy `pg_dump -Fc` khi khởi động và mỗi `BACKUP_INTERVAL_SECONDS` (mặc định 86400), mã hóa AES-256-CBC bằng `BACKUP_PASSPHRASE`, giữ `BACKUP_RETENTION` bản mới nhất; `verify-restore.sh` kiểm tra khôi phục; CSDL lưu trữ WAL liên tục (mã hóa, `archive-wal.sh`) và `pg_basebackup` định kỳ cho phép khôi phục theo thời điểm (PITR), kiểm tra bằng `verify-pitr.sh`. |
| NFR-AVL-02 | Thủ tục `sp_process_subscription_renewals` phải được bộ lập lịch bên ngoài gọi định kỳ (mặc định mỗi ngày) và an toàn khi gọi lặp. Docker demo có service `scheduler` (`fitzone_renewal_scheduler`, chu kỳ `RENEWAL_INTERVAL_SECONDS`, người thực hiện ghi vết BR-23 lấy từ `SCHEDULER_ACTOR_USER_ID`, mặc định 3); production dùng `pg_cron` hoặc cron và phải đặt `app.current_user_id` cho phiên gọi. |

#### Khả bảo trì (Maintainability)

| Mã | Yêu cầu |
| :--- | :--- |
| NFR-MNT-01 | Mã SQL phải tuân thủ SQLStyle.guide (từ khóa viết HOA, định danh `snake_case` chữ thường, thụt lề nhất quán). |
| NFR-MNT-02 | Ràng buộc phải được đặt tên theo tiền tố (`pk_`, `fk_`, `uq_`, `chk_`, `ex_`, `idx_`, `trg_`, `sp_`) để truy vết tới BR. |
| NFR-MNT-03 | Các tập tin SQL phải nạp đúng thứ tự: `01_schema_ddl` → `02_mock_data/01..08` → `04_triggers_views` → `08_rbac_security`; nạp lại 04 thì phải nạp lại 08. |
| NFR-MNT-04 | Phải có bộ kiểm thử tự động cho ràng buộc (`05_constraint_test_cases.sql`), phân quyền (`09_rbac_test_cases.sql`) và hiệu năng (`06_performance_test_cases.sql`) chạy trong giao dịch rồi `ROLLBACK`. |

#### Khả dụng cho người dùng (Usability)

| Mã | Yêu cầu |
| :--- | :--- |
| NFR-USE-01 | Thông báo lỗi nghiệp vụ của trigger phải nêu mã quy tắc (`BR-xx`) và đối tượng liên quan bằng tiếng Việt để người dùng hiểu nguyên nhân. |
| NFR-USE-02 | Ứng dụng minh họa phải kết nối CSDL bằng tài khoản không phải superuser (`gym_u_*`, thuộc nhóm quyền `gym_role_*`) để quyền của CSDL luôn được áp dụng, và phải cho chọn người thực hiện thao tác để ghi vết `created_by_user_id`. |

### 4.3. Quy tắc nghiệp vụ

26 quy tắc BR-01 đến BR-26 và cơ chế thực thi cụ thể (tên ràng buộc, chỉ mục, trigger, thủ tục) được định nghĩa trong [business_rules.md](business_rules.md). Các FR ở mục 4.1 tham chiếu BR tương ứng.

---

## 5. Ràng buộc và giả định

**Ràng buộc**

- Hệ quản trị: PostgreSQL 16 với extension `btree_gist`; ứng dụng minh họa dùng Streamlit, chạy qua Docker Compose.
- Một cơ sở (một phòng tập); không đa chi nhánh.
- Mã SQL theo SQLStyle.guide; tài liệu bằng tiếng Việt.
- Không tích hợp cổng thanh toán thật; thanh toán chỉ ghi nhận kết quả.
- PostgreSQL không có bộ lập lịch tích hợp; quy tắc theo thời gian (BR-24) cần bộ lập lịch ngoài (container `scheduler` trong demo, `pg_cron`/cron trong production).

**Giả định**

- Ca PT diễn ra ở khu tập tự do, không gắn với phòng cụ thể; BR-15 chỉ áp dụng cho lớp nhóm.
- Ứng dụng đặt `app.current_user_id` cho mỗi phiên làm việc để truy vết người thực hiện (BR-23); nếu không đặt thì thao tác ghi bị CSDL từ chối (người dùng thủ công chạy `SET app.current_user_id = '<id>'`; bộ lập lịch dùng biến `SCHEDULER_ACTOR_USER_ID`, mặc định 3).
- Nhân viên kỹ thuật cập nhật trạng thái `Under_Maintenance`/`Inactive` của phòng bằng tay; trạng thái thiết bị được hệ thống tự đồng bộ theo nhật ký bảo trì (mở ca `In_Progress` → `Under_Maintenance`, ca cuối kết thúc → `Operational`), riêng `Decommissioned` do kỹ thuật viên đặt.
- Mỗi hội viên có hợp đồng đang dùng tối đa một gói tại một thời điểm.
- Chỉ mã hóa tệp dữ liệu trên đĩa máy chủ (volume) do hạ tầng triển khai đảm nhận; TLS và sao lưu mã hóa đã có trong bản demo.

---

## 6. Ma trận truy vết (Traceability Matrix)

Cột "Kiểm chứng" dẫn đến mã test cụ thể trong: **05** = `05_constraint_test_cases.sql` (114 test: TC-01..TC-78, TP-01..TP-36), **09** = `09_rbac_test_cases.sql` (66 test: RA/RD/TA/TD/EA/ED/MA/MD/AA/AD/LA/LD, EV-01..EV-13 và SY-01..SY-05), **06** = `06_performance_test_cases.sql` (PT-01..PT-08). Mã test được kiểm tra khớp với tập tin SQL tại thời điểm cập nhật.

| UR | FR / NFR | BR | Bảng | Đối tượng thực thi | Kiểm chứng |
| :--- | :--- | :--- | :--- | :--- | :--- |
| UR-01 | FR-01, FR-02, FR-03 | BR-01, BR-02, BR-03, BR-11 | `user_account`, `member_profile`, `trainer_profile`, `staff_profile` | `uq_user_account_email`, `uq_user_account_phone`, `chk_user_account_status`, `trg_check_member_dob`, `trg_check_user_dob_for_member`, `chk_trainer_rating` | 05: BR-02: TC-01..TC-03; BR-03: TC-04, TC-05, TP-01; BR-11: TC-07 |
| UR-02 | FR-04, FR-05 | BR-22 | `role`, `user_role`, `permission`, `role_permission` | `pk_user_role`, `uq_role_name`, 5 role `gym_role_*` | 05: BR-22: TC-06, TC-08; 09: RD-06, AA-01, LD-01, LA-01 (role nhóm và tài khoản thừa hưởng), SY-01..SY-05 (ma trận `role_permission` khớp `GRANT`) |
| UR-03 | FR-06, FR-07, FR-08, FR-31 | BR-04, BR-05, BR-06 | `membership_plan`, `member_subscription` | `chk_membership_plan_*`, `chk_subscription_dates`, `uq_member_one_active_subscription`, `vw_active_member_subscriptions` | 05: BR-04: TC-09, TC-10, TC-18; BR-05: TC-40, TP-09; BR-06: TC-11 |
| UR-04 | FR-09, FR-10, FR-11 | BR-07, BR-08, BR-09 | `billing_log`, `member_subscription` | `trg_require_payment_before_active`, `trg_activate_on_payment_*`, `uq_billing_invoice_no`, `chk_billing_amount`, `uq_billing_subscription_period` | 05: BR-07: TC-41, TC-42, TP-08; BR-08: TC-43, TP-10, TP-11; BR-09: TC-14..TC-16, TP-07 |
| UR-05 | FR-12, NFR-SEC-04 | BR-10 | `billing_log` | `trg_billing_immutable_update/_delete/_truncate`; `GRANT SELECT, INSERT` | 05: BR-10: TC-17, TC-44..TC-49, TP-12..TP-14; 09: RD-03, RD-04, AD-01, AD-02, AD-03 (billing_log bị từ chối UPDATE/DELETE/TRUNCATE) |
| UR-06 | FR-13, FR-14, NFR-AVL-02 | BR-24, BR-07 | `member_subscription`, `billing_log` | `sp_process_subscription_renewals`, `trg_activate_on_payment_*` | 05: BR-24: TC-66, TP-23..TP-26 |
| UR-07 | FR-15, FR-16, FR-19, FR-20 | BR-12, BR-13, BR-15, BR-17, BR-19 | `class_schedule`, `facilities_room` | `ex_class_trainer_no_overlap`, `ex_class_room_no_overlap`, `chk_class_time`, `chk_facilities_capacity`, `trg_prevent_class_in_maintenance_room`, `trg_prevent_room_maintenance_with_future_classes`, `trg_check_class_schedule_conflicts` | 05: BR-12: TC-22, TC-27, TC-50, TC-51, TP-05; BR-13: TC-19; BR-15: TC-21, TP-06; BR-17: TC-20, TC-26; BR-19: TC-23, TC-34, TC-69, TC-75, TC-77, TP-31 |
| UR-08 | FR-17, FR-18, FR-19 | BR-14, BR-16 | `class_enrollment`, `class_schedule` | `trg_sync_class_enrollment_count`, `chk_class_enrollment_limit`, `uq_enrollment_subscription_class`, `trg_check_class_enrollment_conflicts` | 05: BR-14: TC-24, TC-25, TP-03, TP-04; BR-16: TC-28, TC-52..TC-55, TC-68, TP-15 |
| UR-09 | FR-21, FR-22, FR-23, FR-24 | BR-12, BR-16, BR-17, BR-18 | `pt_booking`, `member_subscription` | `trg_check_pt_booking_creation`, `trg_update_remaining_pt_sessions`, `fk_booking_subscription_member`, `ex_pt_trainer_no_overlap`, `ex_pt_member_no_overlap`, `chk_pt_booking_time`, `chk_pt_booking_date`, `chk_subscription_remaining` | 05: BR-12: TC-22, TC-27, TC-50, TC-51, TP-05; BR-16: TC-28, TC-52..TC-55, TC-68, TP-15; BR-17: TC-20, TC-26; BR-18: TC-13, TC-29, TC-30, TC-56..TC-60, TP-02, TP-16 |
| UR-10 | FR-24, FR-25 | BR-25 | `pt_booking`, `member_subscription` | `trg_late_cancel_pt_booking`, `trg_update_remaining_pt_sessions`, `chk_pt_booking_status` | 05: BR-25: TC-31, TC-67, TP-27..TP-30 |
| UR-11 | FR-32, FR-05 | BR-22 | `pt_booking`, `class_enrollment` | `vw_trainer_schedule_overview`; `GRANT UPDATE (status)` cho `gym_role_trainer` | 09: TA-01..TA-05, TD-01, TD-05 (quyền HLV) |
| UR-12 | FR-26, FR-29 | BR-20, BR-26 | `equipment`, `maintenance_log` | `chk_equipment_depreciation`, `uq_equipment_serial`, `chk_maintenance_cost`, `chk_maintenance_time`, `fk_maintenance_staff` | 05: BR-20: TC-37..TC-39; BR-26: TC-32, TC-33; 09: EA-01, EA-02, ED-01..ED-05 (quyền kỹ thuật viên) |
| UR-13 | FR-16, FR-27, FR-28 | BR-19, BR-21 | `equipment_reservation`, `equipment`, `facilities_room`, `maintenance_log` | `ex_reservation_equipment_no_overlap`, `chk_reservation_source`, `trg_prevent_equipment_reservation_under_maintenance`, `trg_prevent_equipment_maintenance_with_future_reservations`, `trg_start_equipment_maintenance_*`, `trg_finish_equipment_maintenance`, `trg_check_reservation_window` | 05: BR-19: TC-23, TC-34, TC-69..TC-71, TC-75..TC-78, TP-31..TP-34, TP-36; 09: EA-03; BR-21: TC-35, TC-36, TC-61..TC-64, TP-17..TP-19 |
| UR-14 | FR-33, FR-31, FR-32 | — | các bảng nghiệp vụ | truy vấn trong `03_complex_queries.sql`, 2 view | 06: PT-03, PT-08 (truy vấn phức hợp); chạy thử trên Streamlit |
| UR-15 | FR-30 | BR-23 | `member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log` | cột `created_by_user_id` + `fk_*_created_by`, `trg_fill_created_by` | 05: BR-23: TC-65, TP-20..TP-22 |
| UR-16 | NFR-SEC-01, NFR-SEC-02, NFR-SEC-03, NFR-SEC-05 | BR-22 | `user_account` | `REVOKE ... FROM PUBLIC`, `GRANT SELECT (cột)` không gồm `password_hash`, `SECURITY DEFINER`, `pg_hba.conf` `hostssl` (TLS bắt buộc) | 09: RD-01, RD-02, AD-04 (ẩn password_hash), RD-03..RD-06, TD-01..TD-07, ED-01..ED-05, MD-01..MD-05 (từ chối quyền ngoài ma trận), TA-01, RA-03 (SECURITY DEFINER), SY-01..SY-05 (ma trận quyền ứng dụng khớp GRANT) |
| UR-17 | NFR-PERF-01, NFR-PERF-02 | — | `user_account`, `billing_log`, `pt_booking` | các chỉ mục `idx_*` | 06: PT-01..PT-08 |
| UR-18 | NFR-AVL-01 | — | toàn CSDL | service `backup` (`backup.sh`, `verify-restore.sh`, `verify-pitr.sh`), `archive_command` (`archive-wal.sh`) | `verify-restore.sh` ĐẠT và `verify-pitr.sh` ĐẠT (18 bảng khớp số dòng) |
| UR-01..UR-13 | NFR-INT-01..NFR-INT-05 | BR-01..BR-26 | toàn CSDL | khóa ngoại, `CHECK`, `EXCLUDE`, khối kiểm toán dữ liệu | 05: TC-01..TC-78, TP-01..TP-36 (toàn bộ 114 test); khối DATA AUDIT của `04_triggers_views.sql` |
| — | NFR-MNT-01..NFR-MNT-04, NFR-USE-01, NFR-USE-02 | — | — | SQLStyle.guide, đặt tên ràng buộc, thứ tự nạp tập tin, thông báo `RAISE EXCEPTION` | Rà soát tài liệu; 05/09/06 chạy được từ đầu đến cuối |

**Mức độ thực thi và lưu ý còn lại:** NFR-SEC-03 và NFR-AVL-01 đã thực thi trong bản demo (TLS bắt buộc, sao lưu mã hóa tự động kèm kiểm tra khôi phục); phần còn lại thuộc hạ tầng: mã hóa tệp dữ liệu trên đĩa máy chủ (LUKS/mã hóa đĩa đám mây) (WAL liên tục/PITR đã cấu hình); BR-10 và BR-23 được thực thi đầy đủ ở CSDL, lưu ý còn lại là superuser vốn là gốc tin cậy (bảo trì `billing_log` phải tường minh) và mọi chương trình ghi dữ liệu phải đặt `app.current_user_id`; `role_permission` và `GRANT` vẫn duy trì thủ công ở hai nơi nhưng sai lệch được phát hiện tự động bởi SY-01..SY-05; FR-13/BR-24 cần bộ lập lịch ngoài (đã có container `scheduler` trong demo; production dùng `pg_cron`/cron). Chi tiết xem [business_rules.md](business_rules.md), mục "Tổng hợp mức độ thực thi".
