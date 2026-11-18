HỌC VIỆN CÔNG NGHỆ BƯU CHÍNH VIỄN THÔNG – CƠ SỞ TP. HỒ CHÍ MINH

# BÁO CÁO ĐỒ ÁN MÔN HỌC: CƠ SỞ DỮ LIỆU (INT1313)

Hệ thống Quản lý Hội viên & Lập kế hoạch Huấn luyện viên cá nhân

(Gym Membership & Personal Training Planner)

Học kỳ 1, năm học 2026 – 2027  |  Đề tài số 09  |  Nhóm G9  |  PostgreSQL 16

**Hạn nộp (Due Date):** 17/11/2026 – Tuần 13, Học kỳ 1, năm học 2026 – 2027

**Mã & tên đề tài (Project ID & Title):** #09: Gym Membership & Personal Training Planner

## A. Thông tin đề tài (Project Identity)

| Hạng mục | Nội dung |
| --- | --- |
| **Tên nhóm (Team Name)** | G9 |
| **Thành viên (Team Members)** | 1. Lê Hoàng Tiến (n25dcat050@student.ptithcm.edu.vn)<br>2. Lê Hòa Thuận (n25dcat110@student.ptithcm.edu.vn)<br>3. Trần Minh Tiến (n25dcat111@student.ptithcm.edu.vn) |
| **Tên đồ án (Project Title)** | Hệ thống Quản lý Hội viên & Lập kế hoạch Huấn luyện viên cá nhân trên PostgreSQL 16 (Gym Membership & PT Planner) |

## B. Cấu trúc báo cáo (Report Structure)

1. **Giới thiệu & Phạm vi dự án** (Introduction & Project Scope – ISO/IEC/IEEE 29148)
   - 1.1. Mục tiêu hệ thống (System Objective)
   - 1.2. Quy tắc nghiệp vụ & ràng buộc (Business Rules & Constraints)
2. **Thiết kế cơ sở dữ liệu** (Database Design – ISO/IEC 19505 / IE Standards)
   - 2.1. Mô hình khái niệm – Sơ đồ ER/EER (Conceptual Model – ER/EER Diagram)
   - 2.2. Ánh xạ lược đồ logic (Logical Schema Mapping)
   - 2.3. Kiểm chứng chuẩn hóa (Normalization Verification – 1NF → 3NF/BCNF)
3. **Từ điển dữ liệu** (Data Dictionary – ISO/IEC 11179): bảng và metadata thuộc tính của 18 bảng
4. **Triển khai cơ sở dữ liệu** (Database Implementation – SQL Style Guide Compliant)
   - 4.1. Script DDL (Tables, Views, Indexes, Triggers)
   - 4.2. Truy vấn nâng cao & kiểm thử hiệu năng (Advanced Queries & Performance Test Cases)
5. **Kiểm thử & bảo mật** (Verification & Security)
   - 5.1. Test case chứng minh ràng buộc ngăn dữ liệu sai (Constraint Test Cases)
   - 5.2. Định nghĩa phân quyền theo vai trò – RBAC (GRANT/REVOKE)
## Mục lục

- [1. Giới thiệu & Phạm vi dự án (Introduction & Project Scope – ISO/IEC/IEEE 29148)](#1-giới-thiệu--phạm-vi-dự-án-introduction--project-scope--isoiecieee-29148)
  - [1.1. Mục tiêu hệ thống (System Objective)](#11-mục-tiêu-hệ-thống-system-objective)
  - [1.2. Quy tắc nghiệp vụ & ràng buộc (Business Rules & Constraints)](#12-quy-tắc-nghiệp-vụ--ràng-buộc-business-rules--constraints)
- [2. Thiết kế cơ sở dữ liệu (Database Design – ISO/IEC 19505 / IE Standards)](#2-thiết-kế-cơ-sở-dữ-liệu-database-design--isoiec-19505--ie-standards)
  - [2.1. Mô hình khái niệm – Sơ đồ ER/EER (Conceptual Model – ER/EER Diagram)](#21-mô-hình-khái-niệm--sơ-đồ-ereer-conceptual-model--ereer-diagram)
  - [2.2. Ánh xạ lược đồ logic (Logical Schema Mapping)](#22-ánh-xạ-lược-đồ-logic-logical-schema-mapping)
  - [2.3. Kiểm chứng chuẩn hóa (Normalization Verification – 1NF → 3NF/BCNF)](#23-kiểm-chứng-chuẩn-hóa-normalization-verification--1nf--3nfbcnf)
- [3. Từ điển dữ liệu (Data Dictionary – ISO/IEC 11179)](#3-từ-điển-dữ-liệu-data-dictionary--isoiec-11179)
  - [3.1. Phân hệ 1: Quản lý người dùng & phân quyền RBAC (5 bảng)](#31-phân-hệ-1-quản-lý-người-dùng--phân-quyền-rbac-5-bảng)
  - [3.2. Phân hệ 2: Hồ sơ chuyên biệt – các lớp con EER (3 bảng)](#32-phân-hệ-2-hồ-sơ-chuyên-biệt--các-lớp-con-eer-3-bảng)
  - [3.3. Phân hệ 3: Gói tập & thanh toán (3 bảng)](#33-phân-hệ-3-gói-tập--thanh-toán-3-bảng)
  - [3.4. Phân hệ 4: Lịch tập & đặt chỗ (4 bảng)](#34-phân-hệ-4-lịch-tập--đặt-chỗ-4-bảng)
  - [3.5. Phân hệ 5: Thiết bị & bảo trì (3 bảng)](#35-phân-hệ-5-thiết-bị--bảo-trì-3-bảng)
- [4. Triển khai cơ sở dữ liệu (Database Implementation – SQL Style Guide Compliant)](#4-triển-khai-cơ-sở-dữ-liệu-database-implementation--sql-style-guide-compliant)
  - [4.1. Script DDL (Tables, Views, Indexes, Triggers)](#41-script-ddl-tables-views-indexes-triggers)
  - [4.2. Truy vấn nâng cao & kiểm thử hiệu năng (Advanced Queries & Performance Test Cases)](#42-truy-vấn-nâng-cao--kiểm-thử-hiệu-năng-advanced-queries--performance-test-cases)
- [5. Kiểm thử & bảo mật (Verification & Security)](#5-kiểm-thử--bảo-mật-verification--security)
  - [5.1. Test case chứng minh ràng buộc ngăn dữ liệu sai (Constraint Test Cases)](#51-test-case-chứng-minh-ràng-buộc-ngăn-dữ-liệu-sai-constraint-test-cases)
  - [5.2. Định nghĩa phân quyền theo vai trò – RBAC (GRANT/REVOKE)](#52-định-nghĩa-phân-quyền-theo-vai-trò--rbac-grantrevoke)

## 1. Giới thiệu & Phạm vi dự án (Introduction & Project Scope – ISO/IEC/IEEE 29148)

Chương này trình bày mục tiêu, phạm vi, yêu cầu và quy tắc nghiệp vụ theo cấu trúc đặc tả yêu cầu phần mềm ISO/IEC/IEEE 29148, điều chỉnh cho phạm vi một dự án cơ sở dữ liệu. **Yêu cầu người dùng** (UR, nhu cầu bằng ngôn ngữ nghiệp vụ) được tách khỏi **yêu cầu hệ thống** (FR/NFR, dữ liệu và hành vi của hệ thống); **quy tắc nghiệp vụ** (BR) được liệt kê tường minh kèm cơ chế thực thi.

### 1.1. Mục tiêu hệ thống (System Objective)

#### 1.1.1. Tổng quan và mục tiêu

**Gym Membership & Personal Training Planner** là dự án cơ sở dữ liệu quan hệ (PostgreSQL) quản lý hoạt động của một phòng tập thể hình trên một nền tảng thống nhất: tài khoản và hồ sơ, gói tập và hợp đồng hội viên, lớp học nhóm, huấn luyện cá nhân (Personal Training – PT), thiết bị và bảo trì, hóa đơn và thanh toán. Tính toàn vẹn được bảo đảm ngay ở mức CSDL bằng ràng buộc, trigger và thủ tục; quyền truy cập được phân theo vai trò bằng 5 role `gym_role_*`.

Các mục tiêu chính:

1. Quản lý tập trung tài khoản và hồ sơ theo vai trò (hội viên, huấn luyện viên, nhân viên), với phân quyền tối thiểu (RBAC).
2. Quản lý gói hội viên, hợp đồng, thời hạn và trạng thái sử dụng; theo dõi thanh toán dưới dạng nhật ký hóa đơn bất biến.
3. Quản lý lớp học nhóm và ca PT, hạn chế đặt trùng lịch của huấn luyện viên, hội viên và phòng, đồng thời kiểm soát sức chứa và số buổi còn lại.
4. Quản lý danh mục thiết bị, lượt giữ chỗ và bảo trì; chặn xếp lịch vào tài nguyên đang bảo trì.
5. Thực thi quy tắc nghiệp vụ bằng khóa, `UNIQUE`, `CHECK`, `EXCLUDE`, trigger và thủ tục thay vì chỉ dựa vào ứng dụng.
6. Truy vết người thực hiện giao dịch và lưu giữ lịch sử nghiệp vụ phục vụ đối soát.

#### 1.1.2. Phạm vi hệ thống

Mô hình dữ liệu gồm 18 bảng, chia theo 5 phân hệ như sau.

*Bảng 1-1. Phân hệ, chức năng chính và 18 bảng dữ liệu của hệ thống*

| Phân hệ | Chức năng chính | Bảng dữ liệu |
| --- | --- | --- |
| Tài khoản và phân quyền | Quản lý tài khoản, thông tin liên hệ, trạng thái; gán vai trò; ma trận quyền; 5 role CSDL, `GRANT`/`REVOKE` theo đặc quyền tối thiểu (ẩn `password_hash`); truy vết người thực hiện (BR-23) | `user_account`, `role`, `user_role`, `permission`, `role_permission` |
| Hồ sơ chuyên biệt | Hồ sơ 1:1 của hội viên (kiểm tra tuổi tối thiểu), huấn luyện viên (chuyên môn, điểm đánh giá 0–5), nhân viên | `member_profile`, `trainer_profile`, `staff_profile` |
| Gói tập và thanh toán | Danh mục gói, hợp đồng (kích hoạt sau thanh toán, tối đa một hợp đồng `Active`, tự gia hạn và ân hạn), hóa đơn theo chu kỳ tính phí và bất biến | `membership_plan`, `member_subscription`, `billing_log` |
| Lịch tập và đặt chỗ | Phòng/khu vực; lịch lớp nhóm, đăng ký lớp theo sức chứa; đặt ca PT (khu tập tự do, không gắn phòng), trừ buổi và chính sách hủy; chống trùng lịch | `facilities_room`, `class_schedule`, `class_enrollment`, `pt_booking` |
| Thiết bị và bảo trì | Danh mục thiết bị (khấu hao), giữ chỗ thiết bị cho ca PT hoặc lớp, nhật ký bảo trì và chi phí, chặn xếp lịch vào thiết bị/phòng đang bảo trì | `equipment`, `equipment_reservation`, `maintenance_log` |

**Ngoài phạm vi** (trừ khi được bổ sung vào yêu cầu):

- Ứng dụng di động hoặc giao diện thương mại hoàn chỉnh.
- Tích hợp cổng thanh toán, ngân hàng thật; kế toán, thuế hoặc quản trị doanh nghiệp toàn diện.
- Kết nối thiết bị đeo, máy quét hoặc phần cứng phòng tập theo thời gian thực.
- Tư vấn y tế, hồ sơ y tế; báo cáo phân tích nâng cao hoặc mô hình dự đoán.
- Nhiều chi nhánh (hệ thống chỉ phục vụ một phòng tập).

#### 1.1.3. Nhóm người dùng và thuật ngữ

*Bảng 1-2. Nhóm người dùng, vai trò CSDL tương ứng và mục tiêu chính*

| Nhóm | Vai trò CSDL | Mục tiêu chính |
| --- | --- | --- |
| Admin (quản trị) | `gym_role_admin` | Quản lý danh mục, tài khoản, phân quyền; xem báo cáo doanh thu, hiệu suất; không được sửa dữ liệu thanh toán |
| Receptionist (lễ tân) | `gym_role_receptionist` | Tạo hồ sơ hội viên, bán gói, thu tiền, xếp lớp, đặt ca PT |
| Trainer (huấn luyện viên) | `gym_role_trainer` | Xem lịch dạy (lớp, PT), điểm danh, đánh dấu hoàn thành/bỏ tập |
| Technician (kỹ thuật viên) | `gym_role_technician` | Quản lý thiết bị, ghi nhật ký bảo trì, đặt trạng thái bảo trì |
| Member (hội viên) | `gym_role_member` | Xem gói tập, lịch lớp, tình trạng phòng |

*Bảng 1-3. Thuật ngữ chính*

| Thuật ngữ | Ý nghĩa |
| --- | --- |
| PT (Personal Training) | Buổi huấn luyện 1-1 giữa hội viên và huấn luyện viên, diễn ra ở khu tập tự do (không gắn phòng) |
| Hợp đồng (`member_subscription`) | Việc hội viên đăng ký một gói tập trong một khoảng thời gian |
| Hóa đơn (`billing_log`) | Bản ghi thanh toán, bất biến sau khi hoàn tất |
| Ân hạn (grace period) | Số ngày (mặc định 3) sau hạn hợp đồng tự gia hạn; quá hạn này mà chưa thanh toán thì hợp đồng bị tạm ngưng |
| RBAC / Least privilege | Phân quyền theo vai trò / chỉ cấp quyền tối thiểu cần cho nhiệm vụ |
| UR / FR / NFR / BR | Yêu cầu người dùng / chức năng / phi chức năng / quy tắc nghiệp vụ |

#### 1.1.4. Yêu cầu người dùng (User Requirements)

Các yêu cầu dưới đây mô tả điều người dùng cần, không nêu cách cài đặt.

*Bảng 1-4. Yêu cầu người dùng UR-01 … UR-18*

| Mã | Người dùng | Yêu cầu người dùng |
| --- | --- | --- |
| UR-01 | Admin, Lễ tân | Tạo và quản lý tài khoản hội viên, HLV, nhân viên với thông tin liên hệ không trùng. |
| UR-02 | Admin | Gán vai trò cho từng người dùng để mỗi người chỉ làm đúng việc của mình. |
| UR-03 | Lễ tân | Đăng ký gói tập cho hội viên và biết hợp đồng nào đang có hiệu lực. |
| UR-04 | Lễ tân | Ghi nhận thanh toán; hợp đồng chỉ có hiệu lực khi đã thanh toán. |
| UR-05 | Admin, Lễ tân | Hóa đơn đã ghi nhận không được sửa hoặc xóa tùy ý, để bảo đảm đối soát đáng tin cậy. |
| UR-06 | Hội viên, Lễ tân | Hợp đồng dài hạn tự gia hạn đúng hạn; hội viên không trả tiền bị tạm ngưng sau thời gian ân hạn. |
| UR-07 | Lễ tân, HLV | Lập lịch lớp nhóm không trùng giờ HLV hay trùng phòng. |
| UR-08 | Lễ tân, Hội viên | Đăng ký lớp không vượt sức chứa và không trùng với lịch khác của hội viên. |
| UR-09 | Lễ tân, Hội viên | Đặt ca PT khi hội viên còn buổi; buổi tập được trừ chính xác. |
| UR-10 | Hội viên, HLV | Chính sách hủy ca PT rõ ràng: hủy sớm không mất buổi, hủy muộn hoặc bỏ tập thì mất buổi. |
| UR-11 | HLV | Xem lịch dạy tổng hợp (lớp và PT) và điểm danh buổi của mình. |
| UR-12 | Kỹ thuật viên | Quản lý danh mục thiết bị, ngày mua, khấu hao và lịch sử bảo trì kèm chi phí. |
| UR-13 | Lễ tân, HLV | Thiết bị hoặc phòng đang bảo trì không được xếp vào lịch mới; một máy không bị hai ca giữ cùng lúc. |
| UR-14 | Admin | Xem báo cáo doanh thu, tỷ lệ lấp đầy lớp, hiệu suất HLV và hợp đồng sắp hết hạn. |
| UR-15 | Admin | Mọi giao dịch quan trọng phải truy vết được người thực hiện. |
| UR-16 | Mọi người dùng | Mật khẩu và thông tin nhạy cảm được bảo vệ. |
| UR-17 | Mọi người dùng | Tra cứu phản hồi nhanh, không chờ đáng kể khi dữ liệu lớn. |
| UR-18 | Admin | Dữ liệu được sao lưu để khôi phục khi có sự cố. |

#### 1.1.5. Yêu cầu chức năng (Functional Requirements)

Các yêu cầu chức năng chia thành 6 nhóm: A – Tài khoản và phân quyền; B – Gói tập, hợp đồng và thanh toán; C – Lớp học nhóm; D – Huấn luyện cá nhân (PT); E – Thiết bị và bảo trì; F – Báo cáo và truy vấn. Cột BR cho biết quy tắc nghiệp vụ liên quan (mục 1.2).

*Bảng 1-5. Yêu cầu chức năng FR-01 … FR-33*

| Mã | Nhóm | Yêu cầu | BR |
| --- | --- | --- | --- |
| FR-01 | A | Tạo tài khoản `user_account` với email và số điện thoại duy nhất, ngày sinh bắt buộc, trạng thái `Active`/`Inactive`/`Suspended`. | BR-02 |
| FR-02 | A | Từ chối tạo hoặc sửa hồ sơ hội viên có ngày sinh dưới 12 tuổi. | BR-03 |
| FR-03 | A | Lưu hồ sơ chuyên biệt 1:1 theo khóa chính dùng chung: `member_profile`, `trainer_profile` (điểm 0–5), `staff_profile`. | BR-01, BR-11 |
| FR-04 | A | Gán một hoặc nhiều vai trò cho tài khoản qua `user_role` (không gán trùng) và lưu ma trận quyền trong `role_permission`. | BR-22 |
| FR-05 | A | Cung cấp 5 role CSDL `gym_role_*` với quyền `GRANT` đúng ma trận quyền. | BR-22 |
| FR-06 | B | Quản lý `membership_plan` với `duration_days > 0`, `total_sessions >= 0`, `price >= 0`; từ chối xóa gói đang được hợp đồng sử dụng. | BR-04 |
| FR-07 | B | Cho phép Lễ tân tạo hợp đồng ở trạng thái `Pending`, với `end_time >= start_time` và `remaining_sessions >= 0`. | BR-06 |
| FR-08 | B | Mỗi hội viên có tối đa một hợp đồng `Active` tại một thời điểm. | BR-05 |
| FR-09 | B | Từ chối chuyển hợp đồng sang `Active` khi chưa có hóa đơn `Completed`; tự chuyển `Pending` sang `Active` khi hóa đơn được ghi nhận `Completed`. | BR-07 |
| FR-10 | B | Ghi hóa đơn `billing_log` với `invoice_no` duy nhất, `amount > 0`, phương thức và trạng thái thuộc miền giá trị quy định. | BR-09 |
| FR-11 | B | Mỗi chu kỳ tính phí (`billing_period_start`) của một hợp đồng có tối đa một hóa đơn `Pending` hoặc `Completed`. | BR-08 |
| FR-12 | B | Từ chối xóa và `TRUNCATE` hóa đơn; hóa đơn `Completed` chỉ được chuyển sang `Refunded`; `Failed`/`Refunded` không được sửa; chặn `ALTER`/`DROP` `billing_log` và trigger bất biến (kể cả superuser, trừ bảo trì có chủ đích). | BR-10 |
| FR-13 | B | Thủ tục idempotent `sp_process_subscription_renewals(p_as_of, p_grace_days)`: chuyển hợp đồng không tự gia hạn quá hạn sang `Expired`; phát hành hóa đơn `Pending` cho hợp đồng tự gia hạn quá hạn; chuyển `Suspended` khi quá ân hạn chưa thanh toán. | BR-24 |
| FR-14 | B | Gia hạn hợp đồng (cộng `duration_days`, đặt lại `remaining_sessions`, chuyển `Active`) khi hóa đơn gia hạn được thanh toán. | BR-24, BR-07 |
| FR-15 | C | Tạo `class_schedule` với `end_time > start_time`, `max_capacity > 0`; từ chối lịch chồng giờ của cùng HLV hoặc cùng phòng. | BR-12, BR-15, BR-17 |
| FR-16 | C | Từ chối xếp lớp vào phòng không ở trạng thái `Active` (`Under_Maintenance` hoặc `Inactive`); từ chối chuyển phòng sang `Under_Maintenance` hoặc `Inactive` khi còn lớp sắp diễn ra. | BR-19 |
| FR-17 | C | Đăng ký lớp `class_enrollment` (mỗi hợp đồng một lần cho mỗi lớp); tự cập nhật `current_enrolled` khi đăng ký, hủy, xóa. | BR-14 |
| FR-18 | C | Từ chối đăng ký khi lớp đã đủ `max_capacity`. | BR-14 |
| FR-19 | C | Từ chối đăng ký lớp trùng giờ với ca PT hoặc lớp khác của hội viên; từ chối xếp lớp trùng ca PT của HLV. | BR-12, BR-16 |
| FR-20 | C | Lưu `facilities_room` với `max_capacity > 0`, trạng thái `Active`/`Under_Maintenance`/`Inactive`. | BR-13 |
| FR-21 | D | Tạo ca PT chỉ khi hợp đồng đúng hội viên, đang `Active`, giờ tập nằm trong thời hạn hợp đồng và số buổi còn lại lớn hơn số ca `Scheduled` đang chờ. | BR-18 |
| FR-22 | D | Từ chối ca PT chồng giờ của cùng HLV hoặc cùng hội viên (bỏ qua ca đã hủy) và chồng với lớp nhóm tương ứng. | BR-12, BR-16 |
| FR-23 | D | `end_time > start_time` và `booking_date` trùng ngày của `start_time` cho mọi ca PT. | BR-17 |
| FR-24 | D | Tự trừ 1 buổi khi ca PT chuyển sang `Completed`, `No_Show` hoặc `Late_Cancelled` (không trừ lần hai); từ chối khi `remaining_sessions` bằng 0. | BR-18, BR-25 |
| FR-25 | D | Hủy ca PT còn từ 24 giờ trở lên giữ `Cancelled` (không trừ buổi); còn dưới 24 giờ tự đổi thành `Late_Cancelled` (trừ 1 buổi). | BR-25 |
| FR-26 | E | Lưu `equipment` với `serial_number` duy nhất, `purchase_date` bắt buộc, `depreciation_months > 0`. | BR-26 |
| FR-27 | E | Giữ chỗ thiết bị `equipment_reservation` gắn đúng một nguồn (ca PT hoặc lớp); từ chối giữ chỗ trùng giờ trên cùng thiết bị. | BR-21 |
| FR-28 | E | Từ chối giữ chỗ thiết bị không ở trạng thái `Operational` (`Under_Maintenance` hoặc `Decommissioned`), trùng ca bảo trì `In_Progress` hoặc ngoài khung giờ ca/lớp; từ chối chuyển thiết bị sang `Under_Maintenance` hoặc `Decommissioned` khi còn lượt giữ chỗ tương lai; tự đồng bộ trạng thái thiết bị theo `maintenance_log`. | BR-19, BR-21 |
| FR-29 | E | Ghi `maintenance_log` với `cost >= 0`, `end_time >= start_time` (nếu có) và người thực hiện là nhân viên. | BR-20 |
| FR-30 | E | Bắt buộc ghi `created_by_user_id` (NOT NULL) từ biến phiên `app.current_user_id` khi tạo hợp đồng, hóa đơn, lịch lớp, ca PT, nhật ký bảo trì (từ chối nếu chưa đặt biến); ghi `updated_by_user_id`, `updated_at` mỗi `UPDATE` và cấm đổi `created_by_user_id`. | BR-23 |
| FR-31 | F | Cung cấp view `vw_active_member_subscriptions` liệt kê hợp đồng đang hiệu lực. | BR-05 |
| FR-32 | F | Cung cấp view `vw_trainer_schedule_overview` hợp nhất lịch lớp và ca PT của HLV. | BR-12 |
| FR-33 | F | Cung cấp truy vấn báo cáo: doanh thu theo kỳ, tỷ lệ lấp đầy lớp, hiệu suất HLV, hợp đồng sắp hết hạn, chi phí bảo trì. | — |

#### 1.1.6. Yêu cầu phi chức năng (Non-functional Requirements)

*Bảng 1-6. Yêu cầu phi chức năng NFR*

| Mã | Loại | Yêu cầu | Cách đáp ứng / kiểm chứng |
| --- | --- | --- | --- |
| NFR-SEC-01 | Bảo mật | Đặc quyền tối thiểu: không role nào có `TRUNCATE`; Lễ tân không có `DELETE` ở bất kỳ bảng nào. | `REVOKE ALL ... FROM PUBLIC`, `GRANT` theo ma trận; kiểm thử RBAC |
| NFR-SEC-02 | Bảo mật | Mật khẩu chỉ lưu dạng băm trong `user_account.password_hash`; cột này không đọc được bởi mọi role ứng dụng. | `GRANT SELECT` mức cột không gồm `password_hash` |
| NFR-SEC-03 | Bảo mật | Mã hóa dữ liệu khi lưu trữ (encryption at rest) và kết nối TLS. | **Đã thực thi trong demo:** TLS bắt buộc (`pg_hba.conf` `hostssl`, từ chối kết nối không mã hóa) và sao lưu mã hóa AES-256; mã hóa đĩa máy chủ thuộc hạ tầng; mật khẩu mẫu `gym_u_*` phải đổi khi triển khai thật |
| NFR-SEC-04 | Bảo mật | Hóa đơn bất biến theo bốn lớp: trigger `trg_billing_immutable_*`; chỉ `SELECT, INSERT` cho mọi role ứng dụng (kể cả Admin); đối tượng thuộc role `NOLOGIN` `gym_owner`; event trigger `evt_protect_billing_log`/`_drop` chặn `ALTER`/`DROP`. | Superuser vẫn bảo trì được bằng thao tác tường minh; kiểm thử ràng buộc và RBAC |
| NFR-SEC-05 | Bảo mật | Hàm trigger cần ghi vào bảng mà role gọi không có quyền phải chạy `SECURITY DEFINER` với `search_path` cố định (`public, pg_temp`). | Định nghĩa hàm trigger |
| NFR-PERF-01 | Hiệu năng | Truy vấn tra cứu/tìm kiếm chính dưới 200 ms với 100.000–200.000 bản ghi mỗi bảng nghiệp vụ. | Kiểm thử hiệu năng có/không chỉ mục |
| NFR-PERF-02 | Hiệu năng | Có chỉ mục cho truy vấn thường dùng. | `idx_member_subscription_member`, `idx_billing_log_subscription_date`, `idx_pt_booking_trainer`, `idx_pt_booking_dates`, `idx_class_schedule_dates` |
| NFR-INT-01 | Toàn vẹn | Mọi quan hệ được bảo vệ bằng khóa ngoại với hành động tham chiếu rõ ràng. | `ON DELETE RESTRICT` cho dữ liệu giao dịch; `CASCADE` chỉ cho hồ sơ 1:1 và lượt giữ chỗ phụ thuộc |
| NFR-INT-02 | Toàn vẹn | Miền giá trị (trạng thái, phương thức, số lượng, tiền, thời gian) được thực thi ở mức CSDL. | `CHECK`, `NOT NULL`, `UNIQUE` |
| NFR-INT-03 | Toàn vẹn | Xung đột lịch được chặn ở mức CSDL, không phụ thuộc ứng dụng. | `EXCLUDE USING gist` (cùng bảng), trigger (xuyên bảng) |
| NFR-INT-04 | Toàn vẹn | Cập nhật số buổi PT và sĩ số lớp an toàn khi truy cập đồng thời. | Khóa hàng `FOR UPDATE`, khóa tư vấn theo hợp đồng |
| NFR-INT-05 | Toàn vẹn | Dữ liệu mẫu thỏa mọi quy tắc. | Khối kiểm toán dữ liệu (`DO`) báo lỗi nếu có dòng vi phạm |
| NFR-AVL-01 | Sẵn sàng | Sao lưu định kỳ và kiểm tra khôi phục khi triển khai thật. | **Đã thực thi trong demo:** service `backup` (`pg_dump` định kỳ, mã hóa, giữ N bản) và `verify-restore.sh`; WAL lưu trữ liên tục (mã hóa) + `pg_basebackup` cho PITR, `verify-pitr.sh` |
| NFR-AVL-02 | Sẵn sàng | `sp_process_subscription_renewals` được bộ lập lịch ngoài gọi định kỳ (mặc định mỗi ngày) và an toàn khi gọi lặp. | Demo Docker có service `scheduler`; production dùng `pg_cron`/cron và phải đặt `app.current_user_id` |
| NFR-MNT-01 | Bảo trì | Mã SQL tuân thủ SQLStyle.guide (từ khóa HOA, định danh `snake_case`, thụt lề nhất quán). | Rà soát script |
| NFR-MNT-02 | Bảo trì | Ràng buộc đặt tên theo tiền tố để truy vết tới BR. | `pk_`, `fk_`, `uq_`, `chk_`, `ex_`, `idx_`, `trg_`, `sp_` |
| NFR-MNT-03 | Bảo trì | Script nạp đúng thứ tự phụ thuộc; nạp lại script trigger thì phải nạp lại script phân quyền. | Thứ tự nạp ở mục 4.1 |
| NFR-MNT-04 | Bảo trì | Có bộ kiểm thử tự động cho ràng buộc, phân quyền và hiệu năng, chạy trong giao dịch rồi `ROLLBACK`. | 114 test ràng buộc, 66 test RBAC, 8 test hiệu năng |
| NFR-USE-01 | Khả dụng | Lỗi nghiệp vụ của trigger nêu mã quy tắc (`BR-xx`) và đối tượng liên quan bằng tiếng Việt. | `RAISE EXCEPTION` trong hàm trigger |
| NFR-USE-02 | Khả dụng | Ứng dụng minh họa kết nối bằng tài khoản không phải superuser (`gym_u_*`) và cho chọn người thực hiện để ghi vết `created_by_user_id`. | Ứng dụng Streamlit minh họa |

#### 1.1.7. Ràng buộc và giả định

- **Ràng buộc:** PostgreSQL 16 với extension `btree_gist`; ứng dụng minh họa dùng Streamlit, chạy qua Docker Compose; một cơ sở (một phòng tập); SQL theo SQLStyle.guide.
- **Ràng buộc:** không tích hợp cổng thanh toán thật (thanh toán chỉ ghi nhận kết quả); PostgreSQL không có bộ lập lịch tích hợp nên BR-24 cần bộ lập lịch ngoài (container `scheduler` trong demo, `pg_cron`/cron trong production).
- **Giả định:** ca PT diễn ra ở khu tập tự do, không gắn phòng; BR-15 chỉ áp dụng cho lớp nhóm.
- **Giả định:** ứng dụng đặt `app.current_user_id` cho mỗi phiên (BR-23), nếu không thì thao tác ghi bị CSDL từ chối; chạy thủ công cần `SET app.current_user_id = '<id>'`, bộ lập lịch dùng `SCHEDULER_ACTOR_USER_ID` (mặc định 3).
- **Giả định:** kỹ thuật viên tự cập nhật trạng thái `Under_Maintenance`/`Inactive` của phòng; trạng thái thiết bị được hệ thống tự đồng bộ theo nhật ký bảo trì (riêng `Decommissioned` do kỹ thuật viên đặt); mỗi hội viên có tối đa một hợp đồng đang dùng tại một thời điểm.
- **Giả định:** chỉ mã hóa tệp dữ liệu trên đĩa máy chủ do hạ tầng triển khai đảm nhận; TLS và sao lưu mã hóa đã có trong demo.

### 1.2. Quy tắc nghiệp vụ & ràng buộc (Business Rules & Constraints)

Để duy trì tính nhất quán và loại bỏ trạng thái dữ liệu sai lệch, hệ thống áp dụng 26 quy tắc nghiệp vụ (BR-01 đến BR-26). Cột "Cơ chế thực thi" ghi đúng tên đối tượng CSDL đã triển khai. Cơ chế **Khai báo** (`PRIMARY KEY`, `UNIQUE`, `CHECK`, `FOREIGN KEY`, `EXCLUDE`, chỉ mục duy nhất từng phần) do DBMS thực thi trực tiếp; cơ chế **Thủ tục** (trigger, procedure) dùng cho quy tắc xuyên bảng hoặc phụ thuộc thời gian mà ràng buộc khai báo không diễn đạt được.

*Bảng 1-7. Quy tắc nghiệp vụ BR-01 … BR-26 và cơ chế thực thi*

| Mã | Tên quy tắc | Mô tả nghiệp vụ | Cơ chế thực thi |
| --- | --- | --- | --- |
| **BR-01** | Mã hội viên duy nhất | Mỗi hội viên có `user_id` duy nhất toàn hệ thống, đồng thời là khóa ngoại 1:1 tới `user_account`. | `member_profile.user_id` (PRIMARY KEY dùng chung), `fk_member_profile_user` (CASCADE), `fk_subscription_member` |
| **BR-02** | Liên hệ duy nhất | Email và số điện thoại của người dùng không được trùng. | `uq_user_account_email`, `uq_user_account_phone` (UNIQUE), NOT NULL |
| **BR-03** | Độ tuổi tối thiểu | Hội viên phải từ 12 tuổi trở lên (`dob <= CURRENT_DATE - 12 năm`); không áp dụng cho nhân viên/HLV. | Trigger `trg_check_member_dob`, `trg_check_user_dob_for_member` (CHECK không đọc được bảng khác) |
| **BR-04** | Tính hợp lệ gói tập | Gói có `duration_days > 0`, `total_sessions >= 0`, `price >= 0`. | `chk_membership_plan_duration/_sessions/_price` (CHECK); `fk_subscription_plan` (RESTRICT) |
| **BR-05** | Một hợp đồng kích hoạt | Tại một thời điểm, mỗi hội viên có tối đa 1 hợp đồng `Active`. | `uq_member_one_active_subscription` (UNIQUE từng phần, `WHERE sub_status = 'Active'`) |
| **BR-06** | Thứ tự thời gian hợp đồng | `end_time >= start_time`. | `chk_subscription_dates` (CHECK) |
| **BR-07** | Kích hoạt hợp đồng | Chỉ chuyển `Active` khi đã có hóa đơn `Completed`; khi hóa đơn `Completed` thì hợp đồng `Pending` tự kích hoạt. | `trg_require_payment_before_active`; `trg_activate_on_payment_insert/_update`; `chk_subscription_status` |
| **BR-08** | Duy nhất hóa đơn chu kỳ | Mỗi chu kỳ tính phí của hợp đồng có tối đa 1 hóa đơn `Pending`/`Completed`; `Failed`/`Refunded` không chiếm chu kỳ. | `uq_billing_subscription_period` (UNIQUE từng phần); `trg_fill_billing_period_start` (mặc định là ngày bắt đầu hợp đồng) |
| **BR-09** | Hóa đơn hợp lệ | `invoice_no` duy nhất, `amount > 0`, phương thức và trạng thái thuộc miền cho phép. | `uq_billing_invoice_no`, `chk_billing_amount/_method/_status`; `fk_billing_subscription` (RESTRICT) |
| **BR-10** | Thanh toán bất biến | Không xóa hóa đơn; `Completed` chỉ chuyển sang `Refunded`, cột khác giữ nguyên; `Failed`/`Refunded` là trạng thái cuối. | 4 lớp: trigger `trg_billing_immutable_update/_delete/_truncate`; chỉ `SELECT, INSERT` cho mọi role; chủ sở hữu `gym_owner` NOLOGIN; event trigger `evt_protect_billing_log`/`_drop` chặn `ALTER`/`DROP` |
| **BR-11** | Định danh huấn luyện viên | HLV có `user_id` duy nhất, email/phone duy nhất, điểm đánh giá 0–5. | `trainer_profile.user_id` (PRIMARY KEY), `fk_trainer_profile_user`; `uq_user_account_*`; `chk_trainer_rating` |
| **BR-12** | Không trùng lịch HLV | Một HLV không có 2 lịch (lớp hoặc ca PT) chồng khoảng thời gian. | `ex_class_trainer_no_overlap`, `ex_pt_trainer_no_overlap` (EXCLUDE gist, cần `btree_gist`); trigger `trg_check_class_schedule_conflicts`, `trg_check_pt_booking_conflicts` (lớp ↔ PT) |
| **BR-13** | Sức chứa phòng | Mỗi phòng có `max_capacity > 0`. | `chk_facilities_capacity`, `chk_facilities_status` (CHECK) |
| **BR-14** | Giới hạn đăng ký lớp | `current_enrolled` không vượt `max_capacity`; mỗi hợp đồng đăng ký một lớp tối đa một lần. | `trg_sync_class_enrollment_count` (tính lại sĩ số); `chk_class_enrollment_limit`, `chk_class_enrolled`, `chk_class_capacity`; `uq_enrollment_subscription_class` |
| **BR-15** | Không trùng lịch phòng | Một phòng không xếp đồng thời 2 lớp nhóm; ca PT không gắn phòng nên không bị ràng buộc này. | `ex_class_room_no_overlap` (EXCLUDE gist trên `room_id`, `tsrange`) |
| **BR-16** | Không trùng lịch hội viên | Hội viên không tham gia 2 lịch (lớp hoặc ca PT) trùng giờ. | `ex_pt_member_no_overlap` (PT ↔ PT); trigger `trg_check_class_enrollment_conflicts`, `trg_check_pt_booking_conflicts`, `trg_check_class_schedule_conflicts` |
| **BR-17** | Thời gian sự kiện hợp lệ | Với ca PT, lớp, giữ chỗ thiết bị: `end_time > start_time`; ngày ca PT trùng ngày bắt đầu. | `chk_pt_booking_time`, `chk_class_time`, `chk_reservation_time`, `chk_pt_booking_date` (CHECK) |
| **BR-18** | Trừ buổi tập PT | Ca PT chỉ tạo khi hợp đồng `Active`, giờ trong thời hạn và số buổi còn lại lớn hơn số ca `Scheduled` chờ; trừ 1 buổi khi chuyển sang trạng thái tính phí (BR-25); không trừ khi đã bằng 0. | `trg_check_pt_booking_creation` (khóa tư vấn); `trg_update_remaining_pt_sessions` (`FOR UPDATE`); `chk_subscription_remaining`; `fk_booking_subscription_member` |
| **BR-19** | Chặn khóa bảo trì | Chỉ xếp lớp vào phòng `Active`, chỉ giữ chỗ thiết bị `Operational` và không trùng ca `In_Progress`; không chuyển phòng sang `Under_Maintenance`/`Inactive` hoặc thiết bị sang `Under_Maintenance`/`Decommissioned` khi còn lịch tương lai; trạng thái thiết bị đồng bộ với `maintenance_log`. | `trg_prevent_class_in_maintenance_room`, `trg_prevent_equipment_reservation_under_maintenance`, `trg_check_reservation_window`, `trg_prevent_room_maintenance_with_future_classes`, `trg_prevent_equipment_maintenance_with_future_reservations`, `trg_start_equipment_maintenance_*`, `trg_finish_equipment_maintenance` (`SECURITY DEFINER`) |
| **BR-20** | Nhật ký bảo trì hợp lệ | Chi phí không âm, `end_time` (nếu có) không trước `start_time`, người thực hiện là nhân viên. | `chk_maintenance_cost`, `chk_maintenance_time`, `chk_maintenance_status`; `fk_maintenance_staff`, `fk_maintenance_equipment` |
| **BR-21** | Chống đụng máy tập | Thiết bị không bị giữ chỗ trùng giờ; mỗi lượt thuộc đúng một nguồn (ca PT hoặc lớp), nằm trong khung giờ nguồn và không trùng bảo trì. | `ex_reservation_equipment_no_overlap` (EXCLUDE gist); `chk_reservation_source`; `trg_check_reservation_window` |
| **BR-22** | Phân quyền RBAC | Tài khoản có một hoặc nhiều vai trò (Admin, Receptionist, Trainer, Technician, Member); quyền cấp theo đặc quyền tối thiểu. | `role`, `user_role` (`pk_user_role`), `permission`, `role_permission`; 5 role `gym_role_*` NOLOGIN, `REVOKE ALL ... FROM PUBLIC` rồi `GRANT` (cả mức cột); `SECURITY DEFINER SET search_path = public, pg_temp`; test SY-01..SY-05 kiểm tra `role_permission` khớp `GRANT` |
| **BR-23** | Vết truy xuất giao dịch | Giao dịch tạo mới (hợp đồng, hóa đơn, lịch lớp, ca PT, nhật ký bảo trì) phải ghi người thực hiện vào `created_by_user_id`. | `created_by_user_id NOT NULL`, `updated_by_user_id`, `updated_at` + khóa ngoại trên 5 bảng; trigger `trg_fill_created_by` (từ chối nếu thiếu `app.current_user_id`), `trg_set_updated_by` (cấm đổi `created_by_user_id`) |
| **BR-24** | Tự động gia hạn và ân hạn | Hợp đồng `is_recurring` quá hạn phát sinh hóa đơn `Pending`; quá ân hạn (mặc định 3 ngày) chưa thanh toán thì `Suspended`; hợp đồng không tự gia hạn quá hạn thì `Expired`; thanh toán gia hạn thì cộng `duration_days`, đặt lại số buổi, kích hoạt lại. | `sp_process_subscription_renewals(p_as_of, p_grace_days)` (idempotent) do bộ lập lịch ngoài gọi (service `scheduler` trong demo; `pg_cron`/cron trong production); `trg_activate_on_payment_*` |
| **BR-25** | Chính sách hủy ca PT | Buổi chỉ bị trừ khi hoàn thành. Hủy từ 24 giờ trở lên: `Cancelled`, không trừ. Hủy dưới 24 giờ: `Late_Cancelled`, trừ 1 buổi. `No_Show` và `Completed` cũng trừ 1 buổi, không trừ lần hai. | `trg_late_cancel_pt_booking`; `trg_update_remaining_pt_sessions`; `chk_pt_booking_status` |
| **BR-26** | Khấu hao thiết bị | Mỗi thiết bị ghi nhận `purchase_date` và `depreciation_months > 0`. | `purchase_date NOT NULL`; `chk_equipment_depreciation`; `uq_equipment_serial`; `chk_equipment_status` |

#### 1.2.1. Mức độ thực thi

- **Thực thi đầy đủ ở CSDL:** BR-01 đến BR-23, BR-25, BR-26.
- **Cần bộ lập lịch ngoài:** BR-24; logic nằm trong thủ tục, nhưng PostgreSQL không có bộ lập lịch tích hợp nên phải có service `scheduler` (demo) hoặc `pg_cron`/cron (production).
- **Lưu ý BR-10:** superuser là gốc tin cậy của DBMS, vẫn có thể bảo trì `billing_log` bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`; thao tác này phải tường minh.
- **Lưu ý NFR-SEC-03, NFR-AVL-01:** đã thực thi trong demo (TLS bắt buộc, sao lưu mã hóa tự động, kiểm tra khôi phục, WAL liên tục/PITR); còn lại chỉ mã hóa đĩa máy chủ (hạ tầng).
- **Lưu ý BR-22, BR-23:** `role_permission` và các lệnh `GRANT` vẫn duy trì thủ công ở hai nơi, nhưng sai lệch được phát hiện tự động bởi test SY-01..SY-05; mọi chương trình ghi dữ liệu phải đặt `app.current_user_id`.
## 2. Thiết kế cơ sở dữ liệu (Database Design – ISO/IEC 19505 / IE Standards)

Mô hình khái niệm EER (Enhanced Entity–Relationship: thực thể, quan hệ, chuyên biệt hóa, cung loại trừ) được vẽ theo ký hiệu Crow's Foot cho dễ đọc, độc lập với hệ quản trị CSDL. Theo yêu cầu của tài liệu chuẩn, nhóm bổ sung sơ đồ vật lý IE Crow's Foot sinh trực tiếp từ script DDL, bảo đảm khớp 100% với lược đồ thật. Mục 2.2 ánh xạ EER sang 18 quan hệ theo thuật toán 9 bước của Elmasri & Navathe; mục 2.3 chứng minh chuẩn hóa.

### 2.1. Mô hình khái niệm – Sơ đồ ER/EER (Conceptual Model – ER/EER Diagram)

#### 2.1.1. Chú giải ký hiệu

*Bảng 2-1. Chú giải ký hiệu Crow's Foot của sơ đồ khái niệm*

| Ký hiệu | Ý nghĩa |
| --- | --- |
| Hộp chữ nhật | Kiểu thực thể; mỗi dòng: kiểu dữ liệu, tên thuộc tính, PK = khóa chính, UK = khóa duy nhất, cột cuối = ghi chú ("dẫn xuất" = thuộc tính dẫn xuất) |
| Đường nối + nhãn | Kiểu quan hệ (tên tiếng Việt, tên gốc trong ngoặc) |
| Chân chim / vạch sát thực thể | Bậc tối đa: nhiều (N) / một (1) |
| Vòng tròn / vạch phía ngoài | Bậc tối thiểu: 0 = tham gia riêng phần / 1 = tham gia toàn phần |
| Đường nối nhãn "là" | Chuyên biệt hóa chồng lấn, riêng phần: mỗi USER_ACCOUNT có 0..1 hồ sơ MEMBER, TRAINER, STAFF |
| Đường nét đứt nhãn XOR | Cung loại trừ: mỗi lượt giữ máy thuộc đúng một nguồn (buổi PT hoặc lớp) |

#### 2.1.2. Sơ đồ ER (ký hiệu Crow's Foot)

![Mô hình khái niệm ER (ký hiệu Crow's Foot) của hệ thống Gym Membership & PT Planner](Phase%202/database_design/1_conceptual_er_eer_model/5_conceptual_crows_foot.png)

*Hình 2-1. Mô hình khái niệm ER (ký hiệu Crow's Foot) của hệ thống Gym Membership & PT Planner*

#### 2.1.3. Kiểu thực thể và kiểu quan hệ

*Bảng 2-2. Các kiểu thực thể (entity types) theo phân hệ; (D) là thuộc tính dẫn xuất*

| Phân hệ | Thực thể | Thuộc tính | Khóa |
| --- | --- | --- | --- |
| RBAC & Tài khoản | **USER_ACCOUNT** | user_id, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at | PK `user_id`; khóa ứng viên `email`, `phone` |
| | **ROLE** | role_id, role_name, description | PK `role_id`; `role_name` duy nhất |
| | **PERMISSION** | permission_id, permission_code, module_name, description | PK `permission_id`; `permission_code` duy nhất |
| | **MEMBER** (lớp con) | health_notes | `user_id` kế thừa |
| | **TRAINER** (lớp con) | specialization, bio, current_rating | `user_id` kế thừa |
| | **STAFF** (lớp con) | job_title, department | `user_id` kế thừa |
| Gói tập & Thanh toán | **MEMBERSHIP_PLAN** | plan_id, plan_name, duration_days, total_sessions, price, description | PK `plan_id` |
| | **MEMBER_SUBSCRIPTION** | subscription_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at | PK `subscription_id` |
| | **BILLING_LOG** | billing_id, invoice_no, billing_period_start, amount, payment_date, payment_method, payment_status, created_at | PK `billing_id`; `invoice_no` duy nhất |
| Lịch tập & Đặt chỗ | **CLASS_SCHEDULE** | class_id, class_name, start_time, end_time, max_capacity, **current_enrolled (D)** | PK `class_id` |
| | **PT_BOOKING** | booking_id, booking_date, start_time, end_time, status, created_at | PK `booking_id` |
| Cơ sở vật chất & Bảo trì | **FACILITIES_ROOM** | room_id, room_name, room_type, max_capacity, status | PK `room_id` |
| | **EQUIPMENT** | equipment_id, equipment_name, serial_number, purchase_date, depreciation_months, status | PK `equipment_id`; `serial_number` duy nhất |
| | **EQUIPMENT_RESERVATION** | reservation_id, start_time, end_time, status | PK `reservation_id` |
| | **MAINTENANCE_LOG** | maintenance_id, issue_description, start_time, end_time, cost, status, created_at | PK `maintenance_id` |

`current_enrolled` là thuộc tính dẫn xuất (bằng số bản ghi CLASS_ENROLLMENT trạng thái `Enrolled` hoặc `Attended`), được lưu vật lý và duy trì bằng trigger để chặn vượt sức chứa (`chk_class_enrollment_limit`).

*Bảng 2-3. Các kiểu quan hệ (relationship types)*

| Quan hệ | Thực thể tham gia | Tỷ số | Tham gia | Ràng buộc / BR liên quan |
| --- | --- | --- | --- | --- |
| HAS_ROLE | USER_ACCOUNT – ROLE | M:N | USER_ACCOUNT toàn phần (≥1 vai trò, bảo đảm ở quy trình tạo tài khoản, không khai báo được bằng ràng buộc đơn bảng); ROLE riêng phần | BR-22 |
| GRANTS | ROLE – PERMISSION | M:N | riêng phần cả hai | BR-22 |
| SUBSCRIBES | MEMBER – MEMBER_SUBSCRIPTION | 1:N | SUBSCRIPTION toàn phần; MEMBER riêng phần | Tối đa 1 hợp đồng Active (`uq_member_one_active_subscription`) |
| OF_PLAN | MEMBERSHIP_PLAN – MEMBER_SUBSCRIPTION | 1:N | SUBSCRIPTION toàn phần | Hợp đồng gắn đúng một gói |
| GENERATES | MEMBER_SUBSCRIPTION – BILLING_LOG | 1:N | BILLING_LOG toàn phần | BR-24 (hóa đơn gia hạn, bất biến) |
| BOOKS | MEMBER – PT_BOOKING | 1:N | PT_BOOKING toàn phần | `ex_pt_member_no_overlap` |
| CONDUCTS | TRAINER – PT_BOOKING | 1:N | PT_BOOKING toàn phần | `ex_pt_trainer_no_overlap` |
| CONSUMES | MEMBER_SUBSCRIPTION – PT_BOOKING | 1:N | PT_BOOKING toàn phần | BR-25 (trừ/hoàn buổi PT) |
| TEACHES | TRAINER – CLASS_SCHEDULE | 1:N | CLASS toàn phần | `ex_class_trainer_no_overlap` |
| HOSTS | FACILITIES_ROOM – CLASS_SCHEDULE | 1:N | CLASS toàn phần | `ex_class_room_no_overlap` |
| ENROLLS_IN | MEMBER_SUBSCRIPTION – CLASS_SCHEDULE | M:N (thuộc tính: enrollment_date, status) | riêng phần | Ghi danh lớp, sức chứa |
| CONTAINS | FACILITIES_ROOM – EQUIPMENT | 1:N | EQUIPMENT toàn phần | BR-26 |
| REPAIRED_IN | EQUIPMENT – MAINTENANCE_LOG | 1:N | MAINTENANCE_LOG toàn phần | BR-20 |
| PERFORMS | STAFF – MAINTENANCE_LOG | 1:N | MAINTENANCE_LOG toàn phần | BR-20 |
| RESERVED_FOR | EQUIPMENT – EQUIPMENT_RESERVATION | 1:N | RESERVATION toàn phần | BR-21 (`ex_reservation_equipment_no_overlap`) |
| FOR_BOOKING / FOR_CLASS | PT_BOOKING hoặc CLASS_SCHEDULE – EQUIPMENT_RESERVATION | 1:N, loại trừ XOR | riêng phần | BR-21, `chk_reservation_source` |
| CREATED_BY / UPDATED_BY | USER_ACCOUNT – {MEMBER_SUBSCRIPTION, BILLING_LOG, CLASS_SCHEDULE, PT_BOOKING, MAINTENANCE_LOG} | 1:N (5 cặp cùng mẫu) | CREATED_BY toàn phần (NOT NULL); UPDATED_BY riêng phần (NULL được, kèm `updated_at`) | BR-23 |

Năm cặp CREATED_BY/UPDATED_BY không vẽ thành đường trên sơ đồ khái niệm để tránh rối; chúng được ghi trong ô chú giải của sơ đồ và thể hiện đầy đủ ở sơ đồ vật lý (10 khóa ngoại `fk_*_created_by`, `fk_*_updated_by`).

**Cung loại trừ (exclusive arc) của EQUIPMENT_RESERVATION.** Mỗi lượt giữ chỗ thiết bị thuộc về đúng một nguồn: hoặc một ca PT_BOOKING hoặc một CLASS_SCHEDULE, không bao giờ cả hai và không bao giờ không có nguồn. Mô hình hóa bằng hai khóa ngoại nullable `booking_id`, `class_id` cùng ràng buộc `chk_reservation_source` (XOR); trên sơ đồ, FOR_BOOKING và FOR_CLASS nối vào vòng tròn XOR rồi vào EQUIPMENT_RESERVATION.

**Chuyên biệt hóa USER_ACCOUNT → MEMBER / TRAINER / STAFF: chồng lấn (overlapping), riêng phần (partial).**

- Chồng lấn: BR-22 cho phép một tài khoản giữ nhiều vai trò (bảng `user_role`), và lược đồ không cấm một `user_id` xuất hiện đồng thời trong `member_profile`, `trainer_profile`, `staff_profile` (ba bảng dùng chung khóa chính `user_id`); một PT hoặc nhân viên có thể đồng thời là hội viên. Ràng buộc `disjoint` sẽ làm sai BR-22.
- Riêng phần: tài khoản Admin (user 1–2) chỉ có vai trò, không có hồ sơ nào trong ba bảng con; nếu toàn phần thì Admin phải có hồ sơ.
- Thuộc tính định danh/đăng nhập nằm ở siêu lớp; lớp con chỉ thêm thuộc tính riêng.

#### 2.1.4. Sơ đồ vật lý IE Crow's Foot

Sơ đồ vật lý (Information Engineering – Crow's Foot) được sinh tự động từ catalog của CSDL sau khi nạp script DDL, gồm đủ 18 bảng với mọi cột, kiểu dữ liệu, ký hiệu PK/FK/UQ và cột `null`; đầu đường nối: chân chim = phía nhiều, vạch = đúng một, vòng tròn = tùy chọn (0).

![Sơ đồ vật lý IE Crow's Foot của 18 bảng (sinh từ script DDL)](Phase%202/database_design/1_conceptual_er_eer_model/4_physical_crows_foot.png)

*Hình 2-2. Sơ đồ vật lý IE Crow's Foot của 18 bảng (sinh từ script DDL)*

### 2.2. Ánh xạ lược đồ logic (Logical Schema Mapping)

#### 2.2.1. Ánh xạ EER → quan hệ theo thuật toán Elmasri & Navathe

*Bảng 2-4. Chín bước ánh xạ EER sang lược đồ quan hệ*

| Bước | Cấu trúc EER | Áp dụng trong mô hình | Kết quả (quan hệ / PK / FK) |
| --- | --- | --- | --- |
| 1 | Thực thể thông thường | 12 thực thể không phải lớp con (USER_ACCOUNT, ROLE, PERMISSION, MEMBERSHIP_PLAN, MEMBER_SUBSCRIPTION, BILLING_LOG, FACILITIES_ROOM, EQUIPMENT, CLASS_SCHEDULE, PT_BOOKING, EQUIPMENT_RESERVATION, MAINTENANCE_LOG) | Mỗi thực thể thành một quan hệ cùng tên chữ thường, PK là khóa thay thế `*_id` (`SERIAL`); khóa ứng viên thành `UNIQUE` (`email`, `phone`, `role_name`, `permission_code`, `invoice_no`, `serial_number`) |
| 2 | Thực thể yếu | Không có thực thể yếu đúng nghĩa: mọi thực thể đều có khóa thay thế riêng. Hai trường hợp gần nhất: CLASS_ENROLLMENT và các lớp con MEMBER/TRAINER/STAFF | CLASS_ENROLLMENT xử lý ở Bước 5; các lớp con dùng khóa chính chia sẻ + `ON DELETE CASCADE` (Bước 8) |
| 3 | Quan hệ 1:1 | Không có quan hệ 1:1 độc lập; quan hệ 1:1 duy nhất là "is-a" siêu lớp – lớp con | Xử lý ở Bước 8: `member_profile.user_id`, `trainer_profile.user_id`, `staff_profile.user_id` vừa là PK vừa là FK tới `user_account(user_id)` |
| 4 | Quan hệ 1:N | SUBSCRIBES, OF_PLAN, GENERATES, BOOKS, CONDUCTS, CONSUMES, TEACHES, HOSTS, CONTAINS, REPAIRED_IN, PERFORMS, RESERVED_FOR, FOR_BOOKING/FOR_CLASS, 5 cặp CREATED_BY/UPDATED_BY | Thêm khóa ngoại vào quan hệ phía N; tham gia toàn phần thì FK `NOT NULL`, riêng phần thì cho phép `NULL`. `pt_booking` có thêm FK ghép `(subscription_id, member_user_id) → member_subscription` (qua `uq_subscription_member`) để ca PT luôn ghi đúng chủ hợp đồng. Mọi FK dùng `ON DELETE RESTRICT`, riêng RESERVATION → EQUIPMENT/booking/class dùng `CASCADE`. Cung XOR: hai FK nullable `booking_id`, `class_id` + `chk_reservation_source` |
| 5 | Quan hệ M:N | HAS_ROLE, GRANTS, ENROLLS_IN | Bảng trung gian `user_role` PK `(user_id, role_id)`; `role_permission` PK `(role_id, permission_id)` (FK `CASCADE`); `class_enrollment` có thuộc tính `enrollment_date`, `status`, khóa thay thế `enrollment_id` và `uq_enrollment_subscription_class` trên cặp FK |
| 6 | Thuộc tính đa trị | Không có: mọi thuộc tính đơn trị, nguyên tố (1NF). Đa vai trò của người dùng là quan hệ M:N HAS_ROLE, không phải thuộc tính đa trị | Không tạo quan hệ riêng. Thuộc tính dẫn xuất `current_enrolled` được lưu vật lý, đồng bộ bằng trigger |
| 7 | Quan hệ n-ngôi | Không có. Ca PT liên quan hội viên, huấn luyện viên, hợp đồng nhưng biểu diễn bằng ba quan hệ nhị phân 1:N (BOOKS, CONDUCTS, CONSUMES) | Ba FK trên `pt_booking` + FK ghép `fk_booking_subscription_member` giữ nhất quán giữa chúng |
| 8 | Chuyên biệt hóa / tổng quát hóa | USER_ACCOUNT → MEMBER, TRAINER, STAFF (chồng lấn, riêng phần) | Phương án 8A: `user_account` + `member_profile`, `trainer_profile`, `staff_profile`; PK lớp con = FK tới `user_account(user_id)` (`ON DELETE CASCADE`) |
| 9 | Phạm trù (category / union) | Không có; gần nhất là cung XOR của EQUIPMENT_RESERVATION (chủ sở hữu là PT_BOOKING hoặc CLASS_SCHEDULE) | Dùng hai FK nullable + `chk_reservation_source` thay vì khóa thay thế, vì khóa thay thế làm mất kiểm tra tham chiếu khai báo và PostgreSQL không có FK đa hình |

Lý do chọn 8A thay cho 8B/8C/8D:

- Chuyên biệt hóa là chồng lấn và riêng phần (BR-22): 8B (chỉ các quan hệ con, lặp thuộc tính chung) bắt buộc mọi thực thể thuộc một lớp con, gây dư thừa/không nhất quán khi một người giữ nhiều vai trò và không biểu diễn được Admin không có hồ sơ.
- 8C (một quan hệ với cột loại) cần nhiều cột `NULL` và cột loại đơn trị không biểu diễn được chồng lấn; 8D (cờ boolean) vẫn nhiều `NULL` và không cho FK chính xác.
- 8A cho phép FK trỏ đúng lớp con (`pt_booking.trainer_user_id → trainer_profile`, `maintenance_log.staff_user_id → staff_profile`), không có `NULL` thừa và cho phép một `user_id` có nhiều hồ sơ.

#### 2.2.2. Lược đồ quan hệ

Quy ước: <u>gạch chân</u> = khóa chính (khóa ghép gạch chân đủ các thuộc tính); `→` = khóa ngoại; FK mặc định `ON DELETE RESTRICT`, chỉ ghi `CASCADE` khi khác mặc định. Các bảng giao dịch đều có `created_by_user_id → USER_ACCOUNT` (`NOT NULL`), `updated_by_user_id → USER_ACCOUNT` (cho phép `NULL`) và `updated_at` (BR-23), gọi chung là cột vết kiểm toán và viết tắt `audit` bên dưới.

**Phân hệ Tài khoản & Phân quyền RBAC**

- USER_ACCOUNT(<u>user_id</u>, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at); UNIQUE `email`, `phone`; CHECK `status IN ('Active','Inactive','Suspended')`
- ROLE(<u>role_id</u>, role_name, description); UNIQUE `role_name`
- USER_ROLE(<u>user_id</u> → USER_ACCOUNT, <u>role_id</u> → ROLE); cả hai FK `CASCADE`
- PERMISSION(<u>permission_id</u>, permission_code, module_name, description); UNIQUE `permission_code`
- ROLE_PERMISSION(<u>role_id</u> → ROLE, <u>permission_id</u> → PERMISSION); cả hai FK `CASCADE`

**Phân hệ Hồ sơ chuyên biệt (khóa chính chia sẻ)**

- MEMBER_PROFILE(<u>user_id</u> → USER_ACCOUNT, health_notes); `CASCADE`
- TRAINER_PROFILE(<u>user_id</u> → USER_ACCOUNT, specialization, bio, current_rating); `CASCADE`; CHECK `0.00 <= current_rating <= 5.00`
- STAFF_PROFILE(<u>user_id</u> → USER_ACCOUNT, job_title, department); `CASCADE`

**Phân hệ Gói tập & Thanh toán**

- MEMBERSHIP_PLAN(<u>plan_id</u>, plan_name, duration_days, total_sessions, price, description); CHECK `duration_days > 0`, `total_sessions >= 0`, `price >= 0`
- MEMBER_SUBSCRIPTION(<u>subscription_id</u>, member_user_id → MEMBER_PROFILE, plan_id → MEMBERSHIP_PLAN, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, audit); UNIQUE `(subscription_id, member_user_id)` (siêu khóa phục vụ FK ghép); UNIQUE một phần `(member_user_id) WHERE sub_status = 'Active'` (`uq_member_one_active_subscription`, BR-05); CHECK `actual_price >= 0`, `remaining_sessions >= 0`, `end_time >= start_time`, `sub_status IN ('Pending','Active','Expired','Suspended','Cancelled')`
- BILLING_LOG(<u>billing_id</u>, subscription_id → MEMBER_SUBSCRIPTION, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status, created_at, audit); UNIQUE `invoice_no`; UNIQUE một phần `(subscription_id, billing_period_start) WHERE payment_status IN ('Pending','Completed')` (`uq_billing_subscription_period`, BR-08; không phải khóa dự tuyển vì hóa đơn `Failed`/`Refunded` được lặp chu kỳ); CHECK `amount > 0`, `payment_method IN ('Cash','Credit_Card','Banking','E_Wallet')`, `payment_status IN ('Pending','Completed','Failed','Refunded')`

**Phân hệ Lịch tập & Đặt chỗ**

- FACILITIES_ROOM(<u>room_id</u>, room_name, max_capacity, room_type, status); CHECK `max_capacity > 0`, `status IN ('Active','Under_Maintenance','Inactive')`
- CLASS_SCHEDULE(<u>class_id</u>, trainer_user_id → TRAINER_PROFILE, room_id → FACILITIES_ROOM, class_name, start_time, end_time, max_capacity, current_enrolled, audit); EXCLUDE chồng lịch `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` (`ex_class_trainer_no_overlap`) và tương tự theo `room_id` (`ex_class_room_no_overlap`); CHECK `end_time > start_time`, `max_capacity > 0`, `0 <= current_enrolled <= max_capacity`
- CLASS_ENROLLMENT(<u>enrollment_id</u>, subscription_id → MEMBER_SUBSCRIPTION, class_id → CLASS_SCHEDULE, enrollment_date, status); cả hai FK `CASCADE`; UNIQUE `(subscription_id, class_id)`; CHECK `status IN ('Enrolled','Cancelled','Attended')`
- PT_BOOKING(<u>booking_id</u>, member_user_id → MEMBER_PROFILE, trainer_user_id → TRAINER_PROFILE, subscription_id → MEMBER_SUBSCRIPTION, booking_date, start_time, end_time, status, created_at, audit); FK ghép `(subscription_id, member_user_id) → MEMBER_SUBSCRIPTION(subscription_id, member_user_id)` (`fk_booking_subscription_member`); EXCLUDE chồng lịch theo `trainer_user_id` (`ex_pt_trainer_no_overlap`) và theo `member_user_id` (`ex_pt_member_no_overlap`), đều `WHERE status NOT IN ('Cancelled','Late_Cancelled')`; CHECK `end_time > start_time`, `booking_date = start_time::DATE` (`chk_pt_booking_date`), `status IN ('Scheduled','Completed','Cancelled','Late_Cancelled','No_Show')`

**Phân hệ Thiết bị & Bảo trì**

- EQUIPMENT(<u>equipment_id</u>, room_id → FACILITIES_ROOM, equipment_name, serial_number, purchase_date, depreciation_months, status); UNIQUE `serial_number`; CHECK `depreciation_months > 0`, `status IN ('Operational','Under_Maintenance','Decommissioned')`
- EQUIPMENT_RESERVATION(<u>reservation_id</u>, equipment_id → EQUIPMENT, booking_id → PT_BOOKING, class_id → CLASS_SCHEDULE, start_time, end_time, status); ba FK `CASCADE`, `booking_id` và `class_id` cho phép `NULL`; EXCLUDE `(equipment_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE status <> 'Cancelled'` (`ex_reservation_equipment_no_overlap`); CHECK `end_time > start_time`, `status IN ('Reserved','Completed','Cancelled')`, đúng một trong `booking_id`, `class_id` khác `NULL` (`chk_reservation_source`)
- MAINTENANCE_LOG(<u>maintenance_id</u>, equipment_id → EQUIPMENT, staff_user_id → STAFF_PROFILE, issue_description, start_time, end_time, cost, status, created_at, audit); CHECK `cost >= 0`, `status IN ('In_Progress','Completed','Cancelled')`, `end_time IS NULL OR end_time >= start_time`

Tổng cộng 18 bảng vật lý: 12 từ Bước 1, 3 bảng trung gian M:N từ Bước 5 (`user_role`, `role_permission`, `class_enrollment`) và 3 bảng lớp con từ Bước 8 (`member_profile`, `trainer_profile`, `staff_profile`); 10 khóa ngoại vết kiểm toán BR-23 (`created_by_user_id`, `updated_by_user_id` trên `member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log`) đều đã được tính.
### 2.3. Kiểm chứng chuẩn hóa (Normalization Verification – 1NF → 3NF/BCNF)

Mục này chứng minh hình thức dạng chuẩn của từng lược đồ quan hệ trong 18 bảng theo định nghĩa của Elmasri & Navathe (*Fundamentals of Database Systems*, Chương 14): liệt kê tập phụ thuộc hàm (Functional Dependencies – FD), xác định khóa dự tuyển bằng bao đóng, rồi kiểm tra 1NF → 2NF → 3NF → BCNF.

#### 2.3.1. Định nghĩa và phương pháp

*Bảng 2-5. Ký hiệu và định nghĩa các dạng chuẩn*

| Khái niệm | Nội dung |
| --- | --- |
| `X → Y` | Phụ thuộc hàm: hai bộ trùng giá trị trên `X` thì trùng giá trị trên `Y`. `X⁺` là bao đóng của `X` theo hệ tiên đề Armstrong; <u>gạch chân</u> là khóa chính |
| Thuộc tính khóa / không khóa | Thuộc tính thuộc / không thuộc ít nhất một khóa dự tuyển |
| **1NF** | Miền giá trị của mọi thuộc tính là nguyên tố; không có thuộc tính đa trị, phức hợp hay quan hệ lồng nhau |
| **2NF** | Đạt 1NF và mọi thuộc tính không khóa phụ thuộc hàm đầy đủ vào mọi khóa dự tuyển |
| **3NF** | Với mọi FD không tầm thường `X → A`: `X` là siêu khóa hoặc `A` là thuộc tính khóa (không có phụ thuộc bắc cầu của thuộc tính không khóa vào khóa) |
| **BCNF** | Với mọi FD không tầm thường `X → A`: `X` là siêu khóa |

Quy trình cho mỗi bảng: (1) xác định tập FD `F` từ ngữ nghĩa nghiệp vụ và các ràng buộc `PRIMARY KEY`, `UNIQUE`, `EXCLUDE`; (2) tìm khóa dự tuyển `K` sao cho `K⁺` là toàn bộ thuộc tính và không tập con thực sự nào của `K` có tính chất đó; (3) kiểm tra 1NF theo kiểu dữ liệu; (4) kiểm tra 2NF, chỉ cần khi có khóa dự tuyển từ 2 thuộc tính trở lên; (5) kiểm tra BCNF bằng cách duyệt mọi FD trong `F` và xét vế trái có phải siêu khóa (BCNF kéo theo 3NF).

**Bổ đề 1.** Nếu mọi FD không tầm thường của `R` đều có dạng `K → A` với `K` là khóa dự tuyển thì `R` đạt BCNF (do đó đạt 3NF, 2NF). *Chứng minh:* khóa dự tuyển là siêu khóa nên mọi FD thỏa điều kiện BCNF; BCNF ⇒ 3NF ⇒ 2NF. ∎

**Bổ đề 2.** Mọi bảng đều đạt 1NF. *Chứng minh:* toàn bộ cột có kiểu vô hướng (`SERIAL`, `INT`, `VARCHAR`, `TEXT`, `DATE`, `TIMESTAMP`, `DECIMAL`, `BOOLEAN`), không có `ARRAY`, `JSON` hay kiểu phức hợp. Các thuộc tính đa trị của mô hình khái niệm đã được tách bảng khi ánh xạ: vai trò của người dùng → `user_role`; quyền của vai trò → `role_permission`; lớp hội viên đăng ký → `class_enrollment`; thiết bị giữ chỗ cho một buổi tập → `equipment_reservation`. Các cột văn bản tự do (`health_notes`, `bio`, `description`, `issue_description`) và `password_hash` luôn được xử lý như một giá trị duy nhất nên vẫn nguyên tố. ∎

**Bổ đề 3.** Ba nhóm thành phần sau không làm đổi tập FD của bất kỳ bảng nào:

1. *Cột vết kiểm toán.* `created_by_user_id` (`NOT NULL`, FK về `user_account`, có ở `member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log`; BR-23) được trigger `trg_fill_created_by` điền từ biến phiên, không suy ra được từ thuộc tính nào khác (lễ tân tạo hợp đồng không xác định bởi `member_user_id` hay `plan_id`). Chỉ có FD dạng `K → created_by_user_id` với `K` là khóa. Tương tự `created_at` và cặp `updated_by_user_id`, `updated_at` (trigger `trg_set_updated_by`) chỉ phụ thuộc khóa.
2. *Ràng buộc miền* `CHECK ... IN (...)` (kể cả `'Late_Cancelled'` của `pt_booking.status`, BR-25, và `'E_Wallet'` của `billing_log.payment_method`) là ràng buộc trên một thuộc tính, không phải FD.
3. *Chỉ mục duy nhất một phần* (`uq_member_one_active_subscription`, `uq_billing_subscription_period`) chỉ ràng buộc một tập con bản ghi, trong khi khóa dự tuyển phải xác định duy nhất mọi bộ của quan hệ; vì vậy chúng không phải khóa dự tuyển và không thêm FD vào `F` (xem (10), (11)). ∎

#### 2.3.2. Bảng tổng hợp kết quả

*Bảng 2-6. Khóa dự tuyển và dạng chuẩn cao nhất của 18 bảng*

| # | Bảng | Khóa dự tuyển | Dạng chuẩn cao nhất | Ghi chú |
| --- | --- | --- | --- | --- |
| 1 | `user_account` | `{user_id}`, `{email}`, `{phone}` | BCNF | |
| 2 | `role` | `{role_id}`, `{role_name}` | BCNF | |
| 3 | `user_role` | `{user_id, role_id}` | BCNF | Bảng toàn khóa |
| 4 | `permission` | `{permission_id}`, `{permission_code}` | BCNF | |
| 5 | `role_permission` | `{role_id, permission_id}` | BCNF | Bảng toàn khóa |
| 6 | `member_profile` | `{user_id}` | BCNF | Lớp con EER |
| 7 | `trainer_profile` | `{user_id}` | BCNF | Lớp con EER |
| 8 | `staff_profile` | `{user_id}` | BCNF | Lớp con EER |
| 9 | `membership_plan` | `{plan_id}` | BCNF | |
| 10 | `member_subscription` | `{subscription_id}` | BCNF | `uq_member_one_active_subscription` không phải khóa |
| 11 | `billing_log` | `{billing_id}`, `{invoice_no}` | BCNF | `uq_billing_subscription_period` không phải khóa |
| 12 | `facilities_room` | `{room_id}` | BCNF | |
| 13 | `equipment` | `{equipment_id}`, `{serial_number}` | BCNF | |
| 14 | `class_schedule` | `{class_id}`, `{trainer_user_id, start_time}`, `{room_id, start_time}` | BCNF | `current_enrolled` là dữ liệu dẫn xuất |
| 15 | `class_enrollment` | `{enrollment_id}`, `{subscription_id, class_id}` | BCNF | |
| 16 | `pt_booking` | `{booking_id}` | 2NF | 2 phụ thuộc bắc cầu, phi chuẩn hóa có kiểm soát (2.3.4) |
| 17 | `equipment_reservation` | `{reservation_id}` | BCNF | |
| 18 | `maintenance_log` | `{maintenance_id}` | BCNF | |

17/18 bảng đạt BCNF. Riêng `pt_booking` chỉ đạt 2NF về mặt hình thức, hai phụ thuộc bắc cầu của nó đều được CSDL bảo đảm nhất quán (mục 2.3.4).

#### 2.3.3. Chứng minh từng bảng

Sau Bổ đề 2 (1NF), mỗi bảng chỉ trình bày tập FD, khóa dự tuyển và lập luận BCNF. Mục "FD loại trừ" nêu các phụ thuộc có vẻ hợp lý nhưng sai với nghiệp vụ, làm cơ sở khẳng định không có phụ thuộc bắc cầu ẩn.

**(1) USER_ACCOUNT(<u>user_id</u>, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at)**

- FD: `user_id → full_name, email, phone, dob, emergency_contact, password_hash, status, created_at`; `email → user_id` (`uq_user_account_email`, BR-02); `phone → user_id` (`uq_user_account_phone`, BR-02).
- Khóa dự tuyển: `{user_id}`, `{email}`, `{phone}` (`email⁺` và `phone⁺` đều chứa `user_id` rồi suy ra mọi thuộc tính; đều đơn thuộc tính nên tối thiểu). FD loại trừ: `full_name ↛ *`, `dob ↛ *` (có thể trùng).
- BCNF vì vế trái của mọi FD đều là khóa dự tuyển (Bổ đề 1). ∎

**(2), (4) ROLE(<u>role_id</u>, role_name, description) và PERMISSION(<u>permission_id</u>, permission_code, module_name, description)**

- FD: `role_id → role_name, description`; `role_name → role_id` (`uq_role_name`). `permission_id → permission_code, module_name, description`; `permission_code → permission_id` (`uq_permission_code`).
- Khóa dự tuyển: `{role_id}`, `{role_name}`; `{permission_id}`, `{permission_code}`. FD loại trừ: `module_name ↛ permission_code` (phân hệ `Member` có 3 quyền `MEMBER_VIEW`, `MEMBER_CREATE`, `MEMBER_EDIT`).
- BCNF vì mọi vế trái đều là khóa dự tuyển. ∎

**(3), (5) USER_ROLE(<u>user_id, role_id</u>) và ROLE_PERMISSION(<u>role_id, permission_id</u>)**

- FD: chỉ có FD tầm thường; cả hai là bảng toàn khóa (*all-key*) nên không có thuộc tính không khóa.
- Khóa dự tuyển: toàn bộ cặp thuộc tính. Tối thiểu vì quan hệ N:M (một người dùng giữ nhiều vai trò, BR-22; một vai trò có nhiều người dùng và nhiều quyền), không thuộc tính đơn nào xác định thuộc tính còn lại.
- 2NF vì không có thuộc tính không khóa nên không có phụ thuộc bộ phận. BCNF vì không có FD không tầm thường. ∎

**(6), (7), (8) MEMBER_PROFILE(<u>user_id</u>, health_notes); TRAINER_PROFILE(<u>user_id</u>, specialization, bio, current_rating); STAFF_PROFILE(<u>user_id</u>, job_title, department)**

- Ba bảng là kết quả ánh xạ chuyên biệt hóa `USER_ACCOUNT ⊃ {MEMBER, TRAINER, STAFF}` theo phương án 8A của Elmasri: khóa chính của lớp con cũng là khóa ngoại về lớp cha; thuộc tính chung chỉ nằm ở `user_account` nên không dư thừa giữa lớp cha và lớp con.
- FD: `user_id → ` toàn bộ thuộc tính còn lại của mỗi bảng. Khóa dự tuyển: `{user_id}`.
- FD loại trừ: `specialization ↛ current_rating` (hai HLV cùng chuyên môn có điểm khác nhau); `job_title ↛ department` (quy ước nghiệp vụ: cùng chức danh, ví dụ *Manager*, có thể ở nhiều phòng ban và một phòng ban có nhiều chức danh). Nếu quy định mỗi chức danh chỉ thuộc một phòng ban thì `user_id → job_title → department` là phụ thuộc bắc cầu và phải tách `JOB_TITLE(job_title, department)`; với quy ước hiện hành thì không.
- BCNF vì mọi FD có vế trái `user_id` là khóa. ∎

**(9) MEMBERSHIP_PLAN(<u>plan_id</u>, plan_name, duration_days, total_sessions, price, description)**

- FD: `plan_id → plan_name, duration_days, total_sessions, price, description`. Khóa dự tuyển: `{plan_id}`.
- FD loại trừ: `duration_days ↛ price` (gói 30 ngày thường và gói sinh viên khác giá); `total_sessions ↛ price`.
- BCNF vì chỉ có FD vế trái là khóa. ∎

**(10) MEMBER_SUBSCRIPTION(<u>subscription_id</u>, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, created_by_user_id, updated_by_user_id, updated_at)**

- FD: `subscription_id →` mọi thuộc tính còn lại. Khóa dự tuyển: `{subscription_id}`. `member_user_id` là FK về `member_profile`.
- Đây là bảng dễ bị nghi có phụ thuộc bắc cầu qua `plan_id` nhất, nên các FD giả định sau được loại trừ:

*Bảng 2-7. Các FD giả định của MEMBER_SUBSCRIPTION và lý do loại trừ*

| FD giả định | Vì sao không đúng |
| --- | --- |
| `plan_id → actual_price` | `actual_price` là giá chốt tại thời điểm ký (ảnh chụp lịch sử); hai hợp đồng cùng gói có thể khác giá khi giá gói đổi hoặc có khuyến mãi |
| `plan_id → remaining_sessions` | Trạng thái thay đổi theo từng hợp đồng (trigger trừ buổi); chỉ giá trị khởi tạo bằng `total_sessions` |
| `{plan_id, start_time} → end_time` | Ngày kết thúc có thể gia hạn, bảo lưu hoặc chỉnh tay; dữ liệu mẫu có 29/30 hợp đồng với `end_time ≠ start_time + duration_days` |
| `member_user_id → plan_id` | Một hội viên có nhiều hợp đồng theo thời gian (BR-05) |

- `uq_subscription_member UNIQUE (subscription_id, member_user_id)` là siêu khóa (chứa khóa chính), chỉ làm đích tham chiếu cho khóa ngoại ghép từ `pt_booking`. `uq_member_one_active_subscription` (UNIQUE một phần trên `member_user_id WHERE sub_status = 'Active'`, BR-05) không phải khóa dự tuyển vì một hội viên có nhiều hợp đồng không `Active`, nên không sinh FD `member_user_id → …` trên toàn bảng.
- BCNF vì mọi FD có vế trái `subscription_id`. ∎

**(11) BILLING_LOG(<u>billing_id</u>, subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status, created_at, created_by_user_id, updated_by_user_id, updated_at)**

- FD: `billing_id →` mọi thuộc tính còn lại; `invoice_no → billing_id` (`uq_billing_invoice_no`, BR-09). Khóa dự tuyển: `{billing_id}`, `{invoice_no}`. FD loại trừ: `subscription_id ↛ amount`, `subscription_id ↛ billing_period_start` (một hợp đồng có nhiều kỳ thanh toán). `billing_period_start` (`NOT NULL`, do trigger `trg_fill_billing_period_start` mặc định bằng `start_time::DATE` của hợp đồng) chỉ phụ thuộc khóa.
- Chỉ mục `uq_billing_subscription_period UNIQUE (subscription_id, billing_period_start) WHERE payment_status IN ('Pending', 'Completed')` (BR-08) trông giống khóa nhưng không phải: mệnh đề `WHERE` loại hóa đơn `Failed`, `Refunded`, nên một chu kỳ có thể có nhiều bộ cùng `(subscription_id, billing_period_start)` nhưng khác `billing_id`, `invoice_no`, `amount`, `payment_status` (ví dụ `Failed` rồi `Completed` phát hành lại, hoặc `Completed` rồi `Refunded`). FD `{subscription_id, billing_period_start} → billing_id` do đó không đúng trên toàn bảng và không thuộc `F`; đây là ràng buộc toàn vẹn có điều kiện, được DBMS thực thi bằng partial unique index.
- BCNF vì mọi vế trái của `F` là `billing_id` hoặc `invoice_no`. ∎

**(12) FACILITIES_ROOM(<u>room_id</u>, room_name, max_capacity, room_type, status)**

- FD: `room_id → room_name, max_capacity, room_type, status`. Khóa dự tuyển: `{room_id}` (`room_name` không `UNIQUE`).
- FD loại trừ: `room_type ↛ max_capacity`; phản ví dụ trong dữ liệu mẫu: hai phòng `Gym_Floor` có sức chứa 40 và 35.
- BCNF. ∎

**(13) EQUIPMENT(<u>equipment_id</u>, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status)**

- FD: `equipment_id →` mọi thuộc tính còn lại; `serial_number → equipment_id` (`uq_equipment_serial`). Khóa dự tuyển: `{equipment_id}`, `{serial_number}`.
- FD loại trừ: `equipment_name ↛ depreciation_months` (cùng model, mua ở thời điểm khác có thể khấu hao khác).
- BCNF vì mọi vế trái đều là khóa. ∎

**(14) CLASS_SCHEDULE(<u>class_id</u>, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled, created_by_user_id, updated_by_user_id, updated_at)**

- FD: F1 `class_id →` mọi thuộc tính; F2 `{trainer_user_id, start_time} → class_id`; F3 `{room_id, start_time} → class_id`.
- *Chứng minh F2 là FD:* giả sử hai bộ `t1 ≠ t2` có cùng `trainer_user_id` và cùng `start_time`. Vì `chk_class_time` bảo đảm `end_time > start_time`, cả hai khoảng `[start_time, end_time)` đều chứa `start_time` nên giao nhau, mâu thuẫn với `ex_class_trainer_no_overlap`. F3 chứng minh tương tự với `ex_class_room_no_overlap`. ∎
- Khóa dự tuyển: `{class_id}`, `{trainer_user_id, start_time}`, `{room_id, start_time}`; hai khóa ghép tối thiểu vì một HLV dạy nhiều lớp ở các thời điểm khác nhau và nhiều lớp có thể bắt đầu cùng giờ.
- 2NF: không thuộc tính không khóa nào phụ thuộc một phần khóa ghép (`trainer_user_id` một mình không xác định `class_name`; `start_time` một mình không xác định `room_id`). BCNF vì vế trái của F1–F3 đều là khóa.
- Ghi chú: `current_enrolled` bằng số bản ghi `class_enrollment` có trạng thái `Enrolled` hoặc `Attended`, là dữ liệu dẫn xuất giữa các bảng chứ không phải FD nội bảng nên không ảnh hưởng dạng chuẩn. Cột được giữ để khai báo `CHECK (current_enrolled <= max_capacity)` (BR-14); trigger `trg_sync_class_enrollment_count` bảo đảm nhất quán (kiểm chứng ở test TP-03, TP-04). ∎

**(15) CLASS_ENROLLMENT(<u>enrollment_id</u>, subscription_id, class_id, enrollment_date, status)**

- FD: `enrollment_id →` mọi thuộc tính; `{subscription_id, class_id} → enrollment_id` (`uq_enrollment_subscription_class`). Khóa dự tuyển: `{enrollment_id}`, `{subscription_id, class_id}`.
- 2NF (xét khóa ghép): `subscription_id ↛ status` (cùng hợp đồng có thể `Attended` lớp này và `Cancelled` lớp khác); `class_id ↛ enrollment_date` (hội viên đăng ký cùng lớp vào ngày khác nhau); không có phụ thuộc bộ phận.
- BCNF vì mọi vế trái đều là khóa. ∎

**(17) EQUIPMENT_RESERVATION(<u>reservation_id</u>, equipment_id, booking_id, class_id, start_time, end_time, status)**

- FD: `reservation_id →` mọi thuộc tính. Khóa dự tuyển: `{reservation_id}`.
- FD loại trừ: `booking_id ↛ start_time`, `class_id ↛ start_time`: một buổi tập giữ nhiều máy, mỗi máy một khung giờ con riêng (ví dụ 15 phút máy chạy đầu buổi, 30 phút giàn tạ cuối buổi), nên thời gian giữ chỗ là thuộc tính của lượt giữ chỗ.
- 1NF với cặp FK loại trừ nhau (*exclusive arc*): `booking_id`, `class_id` là hai thuộc tính đơn trị có thể `NULL`, `chk_reservation_source` bảo đảm đúng một trong hai có giá trị; `NULL` không phải giá trị đa trị.
- BCNF vì chỉ có FD vế trái là khóa. ∎

**(18) MAINTENANCE_LOG(<u>maintenance_id</u>, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status, created_at, created_by_user_id, updated_by_user_id, updated_at)**

- FD: `maintenance_id →` mọi thuộc tính. Khóa dự tuyển: `{maintenance_id}`. `staff_user_id` là FK về `staff_profile`.
- FD loại trừ: `equipment_id ↛ staff_user_id` (mỗi lần bảo trì có thể do kỹ thuật viên khác xử lý); `{equipment_id, start_time}` không khai báo `UNIQUE` nên không phải khóa.
- BCNF vì chỉ có FD vế trái là khóa. ∎

Bảng (16) `PT_BOOKING` được phân tích riêng ở mục 2.3.4.

#### 2.3.4. Trường hợp PT_BOOKING

**(16) PT_BOOKING(<u>booking_id</u>, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at, created_by_user_id, updated_by_user_id, updated_at)**

*Bảng 2-8. Tập phụ thuộc hàm của PT_BOOKING*

| FD | Nguồn gốc |
| --- | --- |
| F1: `booking_id →` mọi thuộc tính còn lại | Khóa chính |
| F2: `subscription_id → member_user_id` | Mỗi hợp đồng thuộc đúng một hội viên (kéo theo từ `member_subscription`, nơi `subscription_id` là khóa) |
| F3: `start_time → booking_date` | `booking_date = start_time::DATE`, được DBMS bảo đảm bởi `chk_pt_booking_date` nên mọi bản ghi đều thỏa |

`created_by_user_id` và giá trị `'Late_Cancelled'` của `status` không sinh FD mới (Bổ đề 3).

**Khóa dự tuyển.** `{booking_id}⁺` là toàn bộ thuộc tính. Các ứng viên khác không phải khóa: `{subscription_id}` (một hợp đồng có nhiều ca PT); `{start_time}` (nhiều ca bắt đầu cùng giờ); `{trainer_user_id, start_time}` vì `ex_pt_trainer_no_overlap` (và `ex_pt_member_no_overlap`) chỉ áp dụng cho bản ghi `status NOT IN ('Cancelled', 'Late_Cancelled')`, nên ca đã hủy và ca mới có thể trùng cặp giá trị này (test TP-05: ca `Cancelled` của HLV 5 không chặn ca mới cùng khung giờ). Vậy khóa dự tuyển duy nhất là `{booking_id}`.

**Kiểm tra dạng chuẩn.**

- 1NF đạt (Bổ đề 2). 2NF đạt vì khóa dự tuyển duy nhất chỉ có 1 thuộc tính nên không có phụ thuộc bộ phận.
- 3NF vi phạm: F2 có `subscription_id` không phải siêu khóa và `member_user_id` không khóa, tạo chuỗi bắc cầu `booking_id → subscription_id → member_user_id`; F3 tương tự qua `booking_id → start_time → booking_date`. Việc `CHECK` bảo đảm FD đúng không làm FD biến mất, nên về hình thức bảng vẫn không đạt 3NF, và do đó không đạt BCNF.
- Nhóm không tuyên bố `pt_booking` đạt 3NF/BCNF mà khẳng định điều yếu hơn nhưng có giá trị thực tiễn: hai phụ thuộc bắc cầu còn lại là dư thừa có kiểm soát, CSDL từ chối mọi trạng thái mâu thuẫn.

**Bất thường dữ liệu và cơ chế chặn.**

*Bảng 2-9. Bất thường dữ liệu của PT_BOOKING và cơ chế chặn*

| Loại | Ví dụ | Cơ chế chặn |
| --- | --- | --- |
| Cập nhật (F2) | Đổi chủ hợp đồng ở `member_subscription` khi đã có ca PT tham chiếu | `fk_booking_subscription_member` (`ON UPDATE` mặc định `NO ACTION`) |
| Chèn (F2) | Ca PT có `member_user_id` khác chủ của `subscription_id` | `fk_booking_subscription_member`, lỗi `23503` (test TC-29) |
| Cập nhật (F3) | Đổi `start_time` sang ngày khác nhưng quên sửa `booking_date` | `chk_pt_booking_date`, lỗi `23514` |

**Quyết định (a): giữ `member_user_id`, phi chuẩn hóa có kiểm soát.** BR-16 cấm một hội viên có hai ca PT chồng giờ. Trong PostgreSQL, `EXCLUDE USING gist` chỉ tham chiếu được cột cùng bảng; nếu bỏ `member_user_id` thì `ex_pt_member_no_overlap` không khai báo được và BR-16 phải chuyển sang trigger, vốn chậm hơn và dễ sai khi có giao dịch đồng thời. Tính nhất quán được bảo đảm bằng khóa ngoại ghép trỏ tới siêu khóa `uq_subscription_member` của `member_subscription`, nên cặp `(subscription_id, member_user_id)` luôn khớp với bảng cha:

```sql
CONSTRAINT fk_booking_subscription_member FOREIGN KEY (subscription_id, member_user_id)
    REFERENCES member_subscription (subscription_id, member_user_id) ON DELETE RESTRICT
```

**Quyết định (b): giữ `booking_date` và áp dụng `CHECK` (Cách 3).** Ba phương án đã cân nhắc: Cách 1, xóa cột và dùng `start_time::DATE`; Cách 2, cột sinh `booking_date DATE GENERATED ALWAYS AS (start_time::DATE) STORED`; Cách 3, giữ cột và thêm ràng buộc dưới đây. Cách 3 được chọn vì không phải sửa lệnh `INSERT` của dữ liệu mẫu và ứng dụng, giữ nguyên các truy vấn lọc theo `pb.booking_date`, và về toàn vẹn tương đương Cách 2 (không thể có hai giá trị mâu thuẫn). Đánh đổi: dư thừa lưu trữ một cột `DATE`; Cách 1 và 2 cũng chỉ loại được F3 chứ không loại được F2.

```sql
ALTER TABLE pt_booking
    ADD CONSTRAINT chk_pt_booking_date CHECK (booking_date = start_time::DATE);
```

**Phương án phân rã BCNF (đối chiếu).** Phân rã theo F2 và F3 cho `PT_BOOKING_BCNF(`<u>booking_id</u>`, trainer_user_id, subscription_id, start_time, end_time, status, created_at, created_by_user_id, updated_by_user_id, updated_at)`, trong đó `member_user_id` lấy qua phép nối với `MEMBER_SUBSCRIPTION(`<u>subscription_id</u>`, member_user_id, …)` (đã BCNF) và `booking_date` tính bằng `start_time::DATE`.

- *Lossless join (tính chất NJB):* với `R1 ∩ R2 = {subscription_id}` và `subscription_id` là khóa của `MEMBER_SUBSCRIPTION` thì `(R1 ∩ R2) → (R2 − R1)` thuộc `F⁺`, nên phân rã không mất thông tin. ∎
- *Bảo toàn phụ thuộc:* F1 (đã bỏ hai thuộc tính tách ra) nằm trong `PT_BOOKING_BCNF`, F2 nằm trong `MEMBER_SUBSCRIPTION`, F3 trở thành biểu thức tính.
- *Cái giá:* mất khả năng thực thi BR-16 bằng `EXCLUDE` như phân tích ở quyết định (a). Vì vậy nhóm giữ lược đồ hiện tại và chấp nhận `pt_booking` ở mức 2NF hình thức.

#### 2.3.5. Kết luận

17/18 bảng đạt BCNF: mọi FD không tầm thường đều có vế trái là khóa dự tuyển, còn các phụ thuộc "có vẻ hợp lý" đã bị loại bằng lập luận nghiệp vụ hoặc phản ví dụ từ dữ liệu mẫu. `pt_booking` đạt 2NF và không đạt 3NF/BCNF về hình thức, nhưng hai phụ thuộc bắc cầu là phi chuẩn hóa có chủ đích: `subscription_id → member_user_id` phục vụ `EXCLUDE` của BR-16 và được `fk_booking_subscription_member` bảo đảm tuyệt đối, `start_time → booking_date` được `chk_pt_booking_date` bảo đảm. Các cột vết kiểm toán (BR-23), `billing_period_start`, miền `Late_Cancelled`/`E_Wallet` và hai chỉ mục duy nhất một phần không phá BCNF của 17 bảng còn lại (Bổ đề 3). Các thuộc tính ảnh chụp lịch sử (`actual_price`, `end_time`, `remaining_sessions`) và dữ liệu dẫn xuất `current_enrolled` không tạo phụ thuộc bắc cầu và được giữ có chủ đích.
## 3. Từ điển dữ liệu (Data Dictionary – ISO/IEC 11179)

Từ điển dữ liệu mô tả metadata của toàn bộ **18 bảng** theo mẫu thuộc tính chuẩn hóa của ISO/IEC 11179, mỗi bảng một bảng thuộc tính, nhóm thành 5 phân hệ. Tên ràng buộc, chỉ mục và trigger trong cột cuối là tên thật trong DDL, kèm mã quy tắc BR để truy vết về mục 1.2.

Quy ước: kiểu dữ liệu theo PostgreSQL 16. `SERIAL` = `INTEGER` gắn sequence, mặc định là `nextval(...)`. Cột *Key Type*: `PK` khóa chính, `FK` khóa ngoại, `UK` khóa duy nhất, `PK, FK` thành phần khóa chính đồng thời là khóa ngoại, `None` không thuộc khóa. Default `None` = không có giá trị mặc định (cột nullable tự nhận NULL). Các cột kiểm toán `created_by_user_id`, `updated_by_user_id`, `updated_at` thuộc BR-23: `trg_fill_created_by` điền người tạo từ biến phiên `app.current_user_id` khi INSERT không nêu (thiếu cả hai thì báo lỗi BR-23); `trg_set_updated_by` ghi đè người/thời điểm sửa và không cho đổi người tạo.

### 3.1. Phân hệ 1: Quản lý người dùng & phân quyền RBAC (5 bảng)

Quản lý tài khoản định danh và phân quyền đa vai trò động (Role-Based Access Control) với quyền hạn chi tiết.

#### 3.1.1. USER_ACCOUNT

**Mô tả:** Tài khoản người dùng dùng chung toàn hệ thống (hội viên, HLV, nhân viên, quản trị).

*Bảng 3-1. Từ điển dữ liệu bảng USER_ACCOUNT*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | SERIAL | PK | No | nextval(seq) | Mã người dùng duy nhất (BR-01). `pk_user_account` |
| full_name | VARCHAR(100) | None | No | None | Họ và tên đầy đủ |
| email | VARCHAR(100) | UK | No | None | Email đăng nhập duy nhất. `uq_user_account_email` (BR-02) |
| phone | VARCHAR(20) | UK | No | None | Số điện thoại duy nhất. `uq_user_account_phone` (BR-02) |
| dob | DATE | None | No | None | Ngày sinh; hội viên phải đủ 12 tuổi, trigger `trg_check_member_dob`, `trg_check_user_dob_for_member` (BR-03) |
| emergency_contact | VARCHAR(100) | None | Yes | None | Liên hệ khẩn cấp (SĐT/họ tên) |
| password_hash | VARCHAR(255) | None | No | None | Mật khẩu đã băm, không lưu mật khẩu thô |
| status | VARCHAR(20) | None | No | 'Active' | Trạng thái tài khoản. `chk_user_account_status`: `IN ('Active', 'Inactive', 'Suspended')` |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo tài khoản |

Chỉ mục: `idx_user_account_status (status)`.

#### 3.1.2. ROLE

**Mô tả:** Danh mục vai trò hệ thống quy định nhóm thẩm quyền.

*Bảng 3-2. Từ điển dữ liệu bảng ROLE*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | SERIAL | PK | No | nextval(seq) | Mã vai trò. `pk_role` |
| role_name | VARCHAR(50) | UK | No | None | Member, Trainer, Receptionist, Technician, Admin. `uq_role_name` (BR-22) |
| description | VARCHAR(255) | None | Yes | None | Mô tả thẩm quyền và trách nhiệm của vai trò |

#### 3.1.3. USER_ROLE

**Mô tả:** Bảng trung gian gán vai trò cho người dùng (M:N, một người có thể giữ nhiều vai trò).

*Bảng 3-3. Từ điển dữ liệu bảng USER_ROLE*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Khóa chính ghép `pk_user_role (user_id, role_id)`. `fk_user_role_user` → USER_ACCOUNT, ON DELETE CASCADE (BR-22) |
| role_id | INT | PK, FK | No | None | Khóa chính ghép. `fk_user_role_role` → ROLE, ON DELETE CASCADE (BR-22) |

#### 3.1.4. PERMISSION

**Mô tả:** Danh mục quyền thao tác chi tiết theo phân hệ chức năng.

*Bảng 3-4. Từ điển dữ liệu bảng PERMISSION*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| permission_id | SERIAL | PK | No | nextval(seq) | Mã quyền. `pk_permission` |
| permission_code | VARCHAR(50) | UK | No | None | Mã quyền duy nhất (VD: MEMBER_CREATE, EQUIP_MANAGE). `uq_permission_code` |
| module_name | VARCHAR(50) | None | No | None | Phân hệ nghiệp vụ tương ứng (VD: Member, Schedule, Facility) |
| description | VARCHAR(255) | None | Yes | None | Diễn giải thao tác được phép |

#### 3.1.5. ROLE_PERMISSION

**Mô tả:** Bảng trung gian phân bổ quyền chi tiết cho vai trò (M:N).

*Bảng 3-5. Từ điển dữ liệu bảng ROLE_PERMISSION*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | INT | PK, FK | No | None | Khóa chính ghép `pk_role_permission (role_id, permission_id)`. `fk_role_permission_role` → ROLE, ON DELETE CASCADE (BR-22) |
| permission_id | INT | PK, FK | No | None | Khóa chính ghép. `fk_role_permission_permission` → PERMISSION, ON DELETE CASCADE (BR-22) |

### 3.2. Phân hệ 2: Hồ sơ chuyên biệt – các lớp con EER (3 bảng)

Thông tin riêng của từng nhóm người dùng theo cơ chế Shared Primary Key: khóa chính của lớp con đồng thời là khóa ngoại trỏ về `user_account`.

#### 3.2.1. MEMBER_PROFILE

**Mô tả:** Hồ sơ bổ sung của hội viên; `member_subscription` và `pt_booking` tham chiếu trực tiếp bảng này để bảo đảm chủ hợp đồng/ca tập là hội viên.

*Bảng 3-6. Từ điển dữ liệu bảng MEMBER_PROFILE*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_member_profile_user` → USER_ACCOUNT, ON DELETE CASCADE. Trigger `trg_check_member_dob` kiểm tra tuổi (BR-03) |
| health_notes | TEXT | None | Yes | None | Tình trạng sức khỏe, tiền sử bệnh lý, dị ứng |

#### 3.2.2. TRAINER_PROFILE

**Mô tả:** Hồ sơ chuyên môn của huấn luyện viên (PT); được `class_schedule` và `pt_booking` tham chiếu trực tiếp.

*Bảng 3-7. Từ điển dữ liệu bảng TRAINER_PROFILE*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_trainer_profile_user` → USER_ACCOUNT, ON DELETE CASCADE |
| specialization | VARCHAR(100) | None | Yes | None | Lĩnh vực chuyên môn (Gym, Yoga, Pilates, Boxing...) |
| bio | TEXT | None | Yes | None | Tiểu sử, kinh nghiệm, chứng chỉ |
| current_rating | DECIMAL(3,2) | None | No | 5.00 | Điểm đánh giá trung bình. `chk_trainer_rating`: `>= 0.00 AND <= 5.00` (BR-11) |

#### 3.2.3. STAFF_PROFILE

**Mô tả:** Hồ sơ công tác của nhân viên vận hành; được `maintenance_log` tham chiếu trực tiếp.

*Bảng 3-8. Từ điển dữ liệu bảng STAFF_PROFILE*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_staff_profile_user` → USER_ACCOUNT, ON DELETE CASCADE |
| job_title | VARCHAR(50) | None | No | None | Chức danh (Receptionist, Technician, Manager) |
| department | VARCHAR(50) | None | No | None | Phòng ban trực thuộc |

### 3.3. Phân hệ 3: Gói tập & thanh toán (3 bảng)

Quản lý gói dịch vụ, hợp đồng đăng ký của hội viên và nhật ký hóa đơn bất biến.

#### 3.3.1. MEMBERSHIP_PLAN

**Mô tả:** Danh mục gói tập tiêu chuẩn được kinh doanh.

*Bảng 3-9. Từ điển dữ liệu bảng MEMBERSHIP_PLAN*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| plan_id | SERIAL | PK | No | nextval(seq) | Mã gói tập. `pk_membership_plan` |
| plan_name | VARCHAR(100) | None | No | None | Tên gói (VD: Gói VIP 12 Tháng, Gói PT 20 Buổi) |
| duration_days | INT | None | No | None | Thời hạn (ngày). `chk_membership_plan_duration`: `> 0` (BR-04) |
| total_sessions | INT | None | No | 0 | Số buổi PT được cấp (0 nếu gói thời gian). `chk_membership_plan_sessions`: `>= 0` |
| price | DECIMAL(10,2) | None | No | None | Đơn giá niêm yết. `chk_membership_plan_price`: `>= 0` (BR-04) |
| description | TEXT | None | Yes | None | Đặc quyền và điều khoản gói tập |

#### 3.3.2. MEMBER_SUBSCRIPTION

**Mô tả:** Hợp đồng đăng ký gói tập cụ thể của hội viên.

*Bảng 3-10. Từ điển dữ liệu bảng MEMBER_SUBSCRIPTION*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| subscription_id | SERIAL | PK | No | nextval(seq) | Mã hợp đồng. `pk_member_subscription` |
| member_user_id | INT | FK | No | None | Hội viên đứng tên. `fk_subscription_member` → MEMBER_PROFILE, ON DELETE RESTRICT (BR-05) |
| plan_id | INT | FK | No | None | Gói đã chọn. `fk_subscription_plan` → MEMBERSHIP_PLAN, ON DELETE RESTRICT |
| actual_price | DECIMAL(10,2) | None | No | None | Giá bán thực tế chốt khi ký. `chk_subscription_price`: `>= 0` |
| remaining_sessions | INT | None | No | 0 | Số buổi PT còn lại. `chk_subscription_remaining`: `>= 0`; `trg_update_remaining_pt_sessions` trừ buổi (BR-18, BR-25) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu hiệu lực |
| end_time | TIMESTAMP | None | No | None | Thời điểm hết hiệu lực. `chk_subscription_dates`: `end_time >= start_time` (BR-06) |
| sub_status | VARCHAR(20) | None | No | 'Pending' | `chk_subscription_status`: `IN ('Pending', 'Active', 'Expired', 'Suspended', 'Cancelled')`; `trg_require_payment_before_active` yêu cầu hóa đơn Completed (BR-07) |
| is_recurring | BOOLEAN | None | No | FALSE | Tự động gia hạn; `sp_process_subscription_renewals(p_as_of, p_grace_days)` xử lý gia hạn/Expired/Suspended (BR-24) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo hợp đồng |
| created_by_user_id | INT | FK | No | None | Người tạo (BR-23). `fk_subscription_created_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_by_user_id | INT | FK | Yes | None | Người sửa gần nhất (BR-23). `fk_subscription_updated_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_at | TIMESTAMP | None | Yes | None | Thời điểm sửa gần nhất (BR-23); NULL = chưa từng sửa |

Ràng buộc/chỉ mục cấp bảng: `uq_subscription_member (subscription_id, member_user_id)` làm đích khóa ngoại ghép của PT_BOOKING; `uq_member_one_active_subscription`, UNIQUE INDEX một phần `(member_user_id) WHERE sub_status = 'Active'` (BR-05); `idx_member_subscription_member`, `idx_member_subscription_status`, `idx_member_subscription_dates (start_time, end_time)`.

#### 3.3.3. BILLING_LOG

**Mô tả:** Nhật ký giao dịch thanh toán bất biến (Immutable Billing Log).

*Bảng 3-11. Từ điển dữ liệu bảng BILLING_LOG*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| billing_id | SERIAL | PK | No | nextval(seq) | Mã giao dịch. `pk_billing_log` |
| subscription_id | INT | FK | No | None | Hợp đồng được thanh toán. `fk_billing_subscription` → MEMBER_SUBSCRIPTION, ON DELETE RESTRICT (BR-08) |
| billing_period_start | DATE | None | No | None | Ngày bắt đầu chu kỳ tính phí; `trg_fill_billing_period_start` tự điền từ hợp đồng nếu bỏ trống (BR-08) |
| invoice_no | VARCHAR(50) | UK | No | None | Số hóa đơn duy nhất. `uq_billing_invoice_no` (BR-09) |
| amount | DECIMAL(10,2) | None | No | None | Số tiền thanh toán. `chk_billing_amount`: `> 0` (BR-09) |
| payment_date | DATE | None | No | None | Ngày phát sinh thanh toán |
| payment_method | VARCHAR(50) | None | No | None | `chk_billing_method`: `IN ('Cash', 'Credit_Card', 'Banking', 'E_Wallet')` |
| payment_status | VARCHAR(20) | None | No | 'Completed' | `chk_billing_status`: `IN ('Pending', 'Completed', 'Failed', 'Refunded')`; `trg_billing_immutable_update/_delete/_truncate` chặn sửa/xóa (BR-10) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm ghi nhận hóa đơn |
| created_by_user_id | INT | FK | No | None | Người lập hóa đơn (BR-23). `fk_billing_created_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_by_user_id | INT | FK | Yes | None | Người sửa gần nhất (BR-23). `fk_billing_updated_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_at | TIMESTAMP | None | Yes | None | Thời điểm sửa gần nhất (BR-23); NULL = chưa từng sửa |

Ràng buộc/chỉ mục cấp bảng: `uq_billing_subscription_period`, UNIQUE INDEX một phần `(subscription_id, billing_period_start) WHERE payment_status IN ('Pending', 'Completed')`, hóa đơn Failed/Refunded không chiếm chu kỳ (BR-08); `idx_billing_log_subscription_date (subscription_id, payment_date DESC)`, `idx_billing_log_payment_date`; trigger kích hoạt hợp đồng `trg_activate_on_payment_insert`, `trg_activate_on_payment_update` (BR-07, BR-24).

### 3.4. Phân hệ 4: Lịch tập & đặt chỗ (4 bảng)

Quản lý phòng tập, lịch lớp nhóm, đăng ký lớp và đặt ca PT 1-1 chống đụng lịch.

#### 3.4.1. FACILITIES_ROOM

**Mô tả:** Danh mục phòng tập và khu vực chức năng.

*Bảng 3-12. Từ điển dữ liệu bảng FACILITIES_ROOM*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| room_id | SERIAL | PK | No | nextval(seq) | Mã phòng. `pk_facilities_room` |
| room_name | VARCHAR(100) | None | No | None | Tên phòng (VD: Phòng Yoga A1, Khu Máy Lưng) |
| max_capacity | INT | None | No | None | Sức chứa tối đa. `chk_facilities_capacity`: `> 0` (BR-13) |
| room_type | VARCHAR(50) | None | No | None | Loại phòng (VD: 'Yoga_Studio', 'Gym_Floor'); không có CHECK miền giá trị |
| status | VARCHAR(20) | None | No | 'Active' | `chk_facilities_status`: `IN ('Active', 'Under_Maintenance', 'Inactive')`; `trg_prevent_class_in_maintenance_room` chỉ cho xếp lớp vào phòng `Active`, `trg_prevent_room_maintenance_with_future_classes` cấm chuyển sang `Under_Maintenance`/`Inactive` khi còn lớp tương lai (BR-19) |

#### 3.4.2. CLASS_SCHEDULE

**Mô tả:** Lịch vận hành các lớp thể thao nhóm.

*Bảng 3-13. Từ điển dữ liệu bảng CLASS_SCHEDULE*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| class_id | SERIAL | PK | No | nextval(seq) | Mã lớp. `pk_class_schedule` |
| trainer_user_id | INT | FK | No | None | HLV phụ trách. `fk_class_trainer` → TRAINER_PROFILE, ON DELETE RESTRICT (BR-12) |
| room_id | INT | FK | No | None | Phòng tổ chức. `fk_class_room` → FACILITIES_ROOM, ON DELETE RESTRICT (BR-15) |
| class_name | VARCHAR(100) | None | No | None | Tên lớp (VD: Power Yoga K12, BodyPump Morning) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_class_time`: `end_time > start_time` (BR-17) |
| max_capacity | INT | None | No | None | Số hội viên tối đa. `chk_class_capacity`: `> 0` |
| current_enrolled | INT | None | No | 0 | Số đã đăng ký (dẫn xuất, `trg_sync_class_enrollment_count`). `chk_class_enrolled`: `>= 0`; `chk_class_enrollment_limit`: `<= max_capacity` (BR-14) |
| created_by_user_id | INT | FK | No | None | Người tạo lịch (BR-23). `fk_class_created_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_by_user_id | INT | FK | Yes | None | Người sửa gần nhất (BR-23). `fk_class_updated_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_at | TIMESTAMP | None | Yes | None | Thời điểm sửa gần nhất (BR-23); NULL = chưa từng sửa |

Ràng buộc/chỉ mục cấp bảng: `ex_class_trainer_no_overlap` EXCLUDE USING gist `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` (BR-12); `ex_class_room_no_overlap` tương tự theo `room_id` (BR-15); trigger `trg_check_class_schedule_conflicts` (BR-12, BR-16), `trg_prevent_class_in_maintenance_room` (BR-19); chỉ mục `idx_class_schedule_trainer`, `idx_class_schedule_room`, `idx_class_schedule_dates`.

#### 3.4.3. CLASS_ENROLLMENT

**Mô tả:** Bảng trung gian ghi nhận hội viên đăng ký lớp nhóm.

*Bảng 3-14. Từ điển dữ liệu bảng CLASS_ENROLLMENT*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| enrollment_id | SERIAL | PK | No | nextval(seq) | Mã lượt đăng ký. `pk_class_enrollment` |
| subscription_id | INT | FK | No | None | Hợp đồng dùng để đăng ký. `fk_enrollment_subscription` → MEMBER_SUBSCRIPTION, ON DELETE CASCADE |
| class_id | INT | FK | No | None | Lớp đăng ký. `fk_enrollment_class` → CLASS_SCHEDULE, ON DELETE CASCADE |
| enrollment_date | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm đăng ký |
| status | VARCHAR(20) | None | No | 'Enrolled' | `chk_enrollment_status`: `IN ('Enrolled', 'Cancelled', 'Attended')` |

Ràng buộc cấp bảng: `uq_enrollment_subscription_class UNIQUE (subscription_id, class_id)`; trigger `trg_check_class_enrollment_conflicts` (BR-16), `trg_sync_class_enrollment_count` (BR-14).

#### 3.4.4. PT_BOOKING

**Mô tả:** Ca tập cá nhân 1-1 giữa hội viên và HLV, diễn ra ở khu tập tự do nên không gắn với phòng (BR-15 chỉ áp dụng cho lớp nhóm).

*Bảng 3-15. Từ điển dữ liệu bảng PT_BOOKING*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| booking_id | SERIAL | PK | No | nextval(seq) | Mã ca tập. `pk_pt_booking` |
| member_user_id | INT | FK | No | None | Hội viên đặt ca. `fk_booking_member` → MEMBER_PROFILE, ON DELETE RESTRICT |
| trainer_user_id | INT | FK | No | None | PT phụ trách. `fk_booking_trainer` → TRAINER_PROFILE, ON DELETE RESTRICT (BR-12) |
| subscription_id | INT | FK | No | None | Gói dùng để trừ buổi. `fk_booking_subscription`; khóa ngoại ghép `fk_booking_subscription_member (subscription_id, member_user_id)`, ON DELETE RESTRICT (BR-18) |
| booking_date | DATE | None | No | None | Ngày ca tập. `chk_pt_booking_date`: `booking_date = start_time::DATE` |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_pt_booking_time`: `end_time > start_time` (BR-17) |
| status | VARCHAR(20) | None | No | 'Scheduled' | `chk_pt_booking_status`: `IN ('Scheduled', 'Completed', 'Cancelled', 'Late_Cancelled', 'No_Show')`; `trg_late_cancel_pt_booking` (BR-25) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo ca tập |
| created_by_user_id | INT | FK | No | None | Người đặt lịch (BR-23). `fk_booking_created_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_by_user_id | INT | FK | Yes | None | Người sửa gần nhất (BR-23). `fk_booking_updated_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_at | TIMESTAMP | None | Yes | None | Thời điểm sửa gần nhất (BR-23); NULL = chưa từng sửa |

Ràng buộc/chỉ mục cấp bảng: `ex_pt_trainer_no_overlap` và `ex_pt_member_no_overlap`, EXCLUDE USING gist `(trainer_user_id | member_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled'))` (BR-12, BR-16); trigger `trg_check_pt_booking_creation` (BR-18), `trg_check_pt_booking_conflicts` (BR-12, BR-16), `trg_late_cancel_pt_booking` (BR-25), `trg_update_remaining_pt_sessions` (BR-18, BR-25); chỉ mục `idx_pt_booking_trainer`, `idx_pt_booking_member`, `idx_pt_booking_subscription`, `idx_pt_booking_dates`.

### 3.5. Phân hệ 5: Thiết bị & bảo trì (3 bảng)

Quản lý thiết bị, khấu hao, giữ chỗ máy cho buổi tập và nhật ký sửa chữa.

#### 3.5.1. EQUIPMENT

**Mô tả:** Danh mục thiết bị và máy tập tại phòng tập.

*Bảng 3-16. Từ điển dữ liệu bảng EQUIPMENT*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| equipment_id | SERIAL | PK | No | nextval(seq) | Mã thiết bị. `pk_equipment` |
| room_id | INT | FK | No | None | Phòng đặt máy. `fk_equipment_room` → FACILITIES_ROOM, ON DELETE RESTRICT |
| equipment_name | VARCHAR(100) | None | No | None | Tên thiết bị (VD: Máy chạy bộ Technogym Run 1000) |
| serial_number | VARCHAR(100) | UK | No | None | Mã series duy nhất. `uq_equipment_serial` |
| purchase_date | DATE | None | No | None | Ngày nhập mua (BR-26) |
| depreciation_months | INT | None | No | None | Số tháng khấu hao. `chk_equipment_depreciation`: `> 0` (BR-26) |
| status | VARCHAR(20) | None | No | 'Operational' | `chk_equipment_status`: `IN ('Operational', 'Under_Maintenance', 'Decommissioned')`; `trg_prevent_equipment_reservation_under_maintenance` chỉ cho giữ chỗ thiết bị `Operational`, `trg_prevent_equipment_maintenance_with_future_reservations` cấm chuyển sang `Under_Maintenance`/`Decommissioned` khi còn giữ chỗ `Reserved` tương lai (BR-19) |

Chỉ mục: `idx_equipment_status (status)`.

#### 3.5.2. EQUIPMENT_RESERVATION

**Mô tả:** Lịch giữ chỗ trước máy tập cho ca PT hoặc lớp học, tránh trùng thiết bị.

*Bảng 3-17. Từ điển dữ liệu bảng EQUIPMENT_RESERVATION*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| reservation_id | SERIAL | PK | No | nextval(seq) | Mã lượt giữ chỗ. `pk_equipment_reservation` |
| equipment_id | INT | FK | No | None | Thiết bị được đặt. `fk_reservation_equipment` → EQUIPMENT, ON DELETE CASCADE |
| booking_id | INT | FK | Yes | None | Ca PT nếu giữ cho PT. `fk_reservation_booking` → PT_BOOKING, ON DELETE CASCADE (BR-21) |
| class_id | INT | FK | Yes | None | Lớp nhóm nếu giữ cho lớp. `fk_reservation_class` → CLASS_SCHEDULE, ON DELETE CASCADE (BR-21) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu giữ chỗ |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_reservation_time`: `end_time > start_time` |
| status | VARCHAR(20) | None | No | 'Reserved' | `chk_reservation_status`: `IN ('Reserved', 'Completed', 'Cancelled')` |

Ràng buộc cấp bảng: `chk_reservation_source` (đúng một trong `booking_id`, `class_id` khác NULL); `ex_reservation_equipment_no_overlap` EXCLUDE USING gist `(equipment_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status <> 'Cancelled')` (BR-21); trigger `trg_check_reservation_window` (BR-21), `trg_prevent_equipment_reservation_under_maintenance` (BR-19).

#### 3.5.3. MAINTENANCE_LOG

**Mô tả:** Nhật ký sự cố hư hỏng và tiến độ bảo trì thiết bị.

*Bảng 3-18. Từ điển dữ liệu bảng MAINTENANCE_LOG*

| Attribute Name | Data Type | Key Type | Nullable? | Default Value | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| maintenance_id | SERIAL | PK | No | nextval(seq) | Mã nhật ký bảo trì. `pk_maintenance_log` |
| equipment_id | INT | FK | No | None | Máy cần sửa. `fk_maintenance_equipment` → EQUIPMENT, ON DELETE RESTRICT |
| staff_user_id | INT | FK | No | None | Kỹ thuật viên xử lý. `fk_maintenance_staff` → STAFF_PROFILE, ON DELETE RESTRICT |
| issue_description | TEXT | None | No | None | Mô tả sự cố hoặc lý do bảo trì |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu bảo trì |
| end_time | TIMESTAMP | None | Yes | None | Thời điểm hoàn thành (NULL khi đang xử lý). `chk_maintenance_time`: `end_time IS NULL OR end_time >= start_time` (BR-20) |
| cost | DECIMAL(10,2) | None | No | 0.00 | Chi phí sửa chữa. `chk_maintenance_cost`: `>= 0` (BR-20) |
| status | VARCHAR(20) | None | No | 'In_Progress' | `chk_maintenance_status`: `IN ('In_Progress', 'Completed', 'Cancelled')` |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo bản ghi |
| created_by_user_id | INT | FK | No | None | Người ghi nhận (BR-23). `fk_maintenance_created_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_by_user_id | INT | FK | Yes | None | Người sửa gần nhất (BR-23). `fk_maintenance_updated_by` → USER_ACCOUNT, ON DELETE RESTRICT |
| updated_at | TIMESTAMP | None | Yes | None | Thời điểm sửa gần nhất (BR-23); NULL = chưa từng sửa |

Chỉ mục: `idx_maintenance_log_equipment (equipment_id)`.
## 4. Triển khai cơ sở dữ liệu (Database Implementation – SQL Style Guide Compliant)

Hệ thống được triển khai trên PostgreSQL 16 và tuân thủ SQLStyle.guide: từ khóa SQL viết hoa, định danh `snake_case` chữ thường, thụt lề nhất quán cho `JOIN` và truy vấn con. Mọi ràng buộc và đối tượng lập trình được đặt tên theo tiền tố để truy vết trực tiếp tới quy tắc nghiệp vụ (BR). Các đoạn mã dưới đây được trích từ script thực tế, có thể rút gọn bằng `-- ...`.

*Bảng 4-1. Quy ước đặt tên đối tượng cơ sở dữ liệu*

| Tiền tố | Đối tượng | Ví dụ |
| --- | --- | --- |
| `pk_` | Khóa chính | `pk_member_subscription` |
| `fk_` | Khóa ngoại | `fk_booking_subscription_member` |
| `uq_` | Ràng buộc / chỉ mục duy nhất | `uq_billing_invoice_no` |
| `chk_` | Ràng buộc `CHECK` | `chk_pt_booking_time` |
| `ex_` | Ràng buộc loại trừ (`EXCLUDE`) | `ex_pt_trainer_no_overlap` |
| `idx_` | Chỉ mục B-tree | `idx_pt_booking_trainer` |
| `trg_` / `trg_fn_` | Trigger / hàm trigger | `trg_billing_immutable_update` |
| `sp_` / `vw_` | Thủ tục / view | `sp_process_subscription_renewals`, `vw_active_member_subscriptions` |

### 4.1. Script DDL (Tables, Views, Indexes, Triggers)

#### 4.1.1. Tổng quan đối tượng CSDL

Số liệu được đếm trực tiếp từ catalog PostgreSQL sau khi nạp toàn bộ script.

*Bảng 4-2. Thống kê đối tượng cơ sở dữ liệu*

| Loại đối tượng | Số lượng | Ví dụ / ghi chú |
| --- | --- | --- |
| Bảng | 18 | Từ `user_account` đến `maintenance_log` |
| Khóa chính | 18 | Ba bảng hồ sơ dùng khóa chính chia sẻ `user_id` |
| Khóa ngoại | 34 | `ON DELETE RESTRICT` cho dữ liệu giao dịch; `CASCADE` chỉ cho hồ sơ 1:1, bảng nối và lượt giữ chỗ phụ thuộc |
| `UNIQUE` | 8 + 2 chỉ mục duy nhất từng phần | `uq_user_account_email`; từng phần: `uq_member_one_active_subscription` (BR-05), `uq_billing_subscription_period` (BR-08) |
| `CHECK` | 30 | `chk_billing_amount`, `chk_class_enrollment_limit`… |
| `EXCLUDE USING gist` | 5 | `ex_class_trainer_no_overlap`, `ex_class_room_no_overlap`, `ex_pt_trainer_no_overlap`, `ex_pt_member_no_overlap`, `ex_reservation_equipment_no_overlap` (cần `btree_gist`) |
| Chỉ mục tường minh | 15 | `idx_member_subscription_member`, `idx_billing_log_subscription_date`… (catalog có 48 chỉ mục, gồm chỉ mục sinh bởi PK/UNIQUE/EXCLUDE) |
| Trigger | 34 (24 hàm trigger) | 3 trigger trong script DDL (BR-03, BR-14) và 31 trigger trong script trigger |
| Event trigger | 2 | `evt_protect_billing_log`, `evt_protect_billing_log_drop` (BR-10) |
| View | 2 | `vw_active_member_subscriptions`, `vw_trainer_schedule_overview` |
| Thủ tục | 1 | `sp_process_subscription_renewals(p_as_of, p_grace_days)` (BR-24) |
| Role / tài khoản | 5 + 5 (+ 1) | `gym_role_*` (NOLOGIN), `gym_u_*` (LOGIN, INHERIT), `gym_owner` (chủ sở hữu mọi đối tượng) |

#### 4.1.2. Bảng, khóa, ràng buộc và chỉ mục

Bảng `member_subscription` có khóa chính, khóa duy nhất phụ `uq_subscription_member` làm đích cho khóa ngoại ghép, các khóa ngoại `RESTRICT`, ràng buộc `CHECK`, và **chỉ mục duy nhất từng phần** hiện thực BR-05 (mỗi hội viên tối đa một hợp đồng `Active`).

```sql
CREATE TABLE member_subscription (
    subscription_id    SERIAL,
    member_user_id     INT            NOT NULL,
    plan_id            INT            NOT NULL,
    actual_price       DECIMAL(10, 2) NOT NULL,
    remaining_sessions INT            NOT NULL DEFAULT 0,
    end_time           TIMESTAMP      NOT NULL,
    sub_status         VARCHAR(20)    NOT NULL DEFAULT 'Pending',
    -- ...
    CONSTRAINT pk_member_subscription PRIMARY KEY (subscription_id),
    CONSTRAINT uq_subscription_member UNIQUE (subscription_id, member_user_id),
    CONSTRAINT fk_subscription_member FOREIGN KEY (member_user_id)
        REFERENCES member_profile (user_id) ON DELETE RESTRICT,
    -- ...
    CONSTRAINT chk_subscription_dates CHECK (end_time >= start_time),
    CONSTRAINT chk_subscription_status CHECK (sub_status IN ('Pending', 'Active', 'Expired', 'Suspended', 'Cancelled'))
);

-- BR-05: tại một thời điểm một hội viên chỉ có tối đa 1 hợp đồng ở trạng thái Active.
CREATE UNIQUE INDEX uq_member_one_active_subscription
    ON member_subscription (member_user_id)
    WHERE sub_status = 'Active';
```

Bảng `pt_booking` dùng khóa ngoại ghép `fk_booking_subscription_member` để ca PT luôn thuộc đúng chủ hợp đồng, và hai ràng buộc `EXCLUDE USING gist` chống trùng lịch của huấn luyện viên và hội viên (BR-12, BR-16); các ca đã hủy được loại khỏi điều kiện.

```sql
CREATE TABLE pt_booking (
    booking_id      SERIAL,
    member_user_id  INT         NOT NULL,
    trainer_user_id INT         NOT NULL,
    subscription_id INT         NOT NULL,
    -- start_time, end_time, status ...
    CONSTRAINT pk_pt_booking PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_subscription_member FOREIGN KEY (subscription_id, member_user_id)
        REFERENCES member_subscription (subscription_id, member_user_id) ON DELETE RESTRICT,
    CONSTRAINT ex_pt_trainer_no_overlap EXCLUDE USING gist (
        trainer_user_id WITH =,
        tsrange(start_time, end_time, '[)') WITH &&
    ) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled')),
    CONSTRAINT ex_pt_member_no_overlap EXCLUDE USING gist (
        member_user_id WITH =,
        tsrange(start_time, end_time, '[)') WITH &&
    ) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled')),
    CONSTRAINT chk_pt_booking_time CHECK (end_time > start_time)
    -- ...
);
```

Bảng `billing_log` là nhật ký thanh toán bất biến (BR-08, BR-10). Chỉ mục duy nhất từng phần `uq_billing_subscription_period` bảo đảm mỗi chu kỳ tính phí của một hợp đồng chỉ có tối đa một hóa đơn còn hiệu lực; hóa đơn `Failed`/`Refunded` không chiếm chu kỳ nên có thể phát hành lại.

```sql
-- billing_log: CONSTRAINT uq_billing_invoice_no UNIQUE (invoice_no),
--              CONSTRAINT chk_billing_amount CHECK (amount > 0), ...
CREATE UNIQUE INDEX uq_billing_subscription_period
    ON billing_log (subscription_id, billing_period_start)
    WHERE payment_status IN ('Pending', 'Completed');
```

Mười lăm chỉ mục B-tree tường minh phục vụ truy vấn thường dùng (NFR-PERF-02), ví dụ `idx_pt_booking_trainer`, `idx_pt_booking_dates`; chỉ mục ghép `idx_billing_log_subscription_date (subscription_id, payment_date DESC)` phục vụ cả lọc theo hợp đồng lẫn `ORDER BY payment_date DESC`.

#### 4.1.3. Trigger

Trigger được dùng cho các quy tắc xuyên bảng hoặc phụ thuộc thời gian mà `CHECK` và `EXCLUDE` không diễn đạt được. Các trigger `trg_fill_created_by` (BEFORE INSERT) và `trg_set_updated_by` (BEFORE UPDATE) cùng hiện thực BR-23 (ghi nhận người thực hiện) trên 5 bảng giao dịch.

*Bảng 4-3. Các trigger nghiệp vụ của hệ thống*

| Trigger | Bảng / sự kiện | BR | Mục đích |
| --- | --- | --- | --- |
| `trg_check_member_dob`, `trg_check_user_dob_for_member` | `member_profile` (INSERT/UPDATE), `user_account` (UPDATE) | BR-03 | Hội viên phải đủ tuổi tối thiểu khi đăng ký hoặc khi đổi ngày sinh |
| `trg_sync_class_enrollment_count` | `class_enrollment` (AFTER I/U/D) | BR-14 | Đồng bộ số chỗ đã đăng ký của lớp |
| `trg_require_payment_before_active` | `member_subscription` (BEFORE I/U) | BR-07 | Chỉ cho `Active` khi đã có hóa đơn `Completed` |
| `trg_activate_on_payment_insert`, `trg_activate_on_payment_update` | `billing_log` (AFTER INSERT/UPDATE) | BR-07, BR-24 | Tự kích hoạt hợp đồng khi thanh toán hoàn tất |
| `trg_fill_billing_period_start` | `billing_log` (BEFORE INSERT) | BR-08 | Tự điền chu kỳ tính phí khi chưa chỉ định |
| `trg_billing_immutable_update`, `_delete`, `_truncate` | `billing_log` (BEFORE UPDATE/DELETE/TRUNCATE) | BR-10 | Nhật ký thanh toán bất biến |
| `trg_check_pt_booking_conflicts` | `pt_booking` (BEFORE I/U) | BR-12, BR-16 | Ca PT không trùng lớp nhóm do chính HLV đứng lớp (BR-12) hoặc lớp hội viên đã đăng ký (BR-16); trùng PT ↔ PT do `EXCLUDE` chặn |
| `trg_check_pt_booking_creation` | `pt_booking` (BEFORE INSERT) | BR-18 | Hợp đồng phải hiệu lực và còn buổi PT khi đặt lịch |
| `trg_late_cancel_pt_booking` | `pt_booking` (BEFORE UPDATE OF status) | BR-25 | Hủy khi còn dưới 24 giờ tự chuyển `Cancelled` → `Late_Cancelled` |
| `trg_update_remaining_pt_sessions` | `pt_booking` (AFTER UPDATE) | BR-18, BR-25 | Trừ buổi PT khi ca thuộc nhóm tính phí |
| `trg_check_class_schedule_conflicts` | `class_schedule` (BEFORE I/U) | BR-12, BR-16 | Lớp không trùng ca PT của HLV (BR-12); đổi giờ lớp không làm hội viên đã đăng ký bị trùng lịch (BR-16); trùng phòng do `EXCLUDE` chặn |
| `trg_check_class_enrollment_conflicts` | `class_enrollment` (BEFORE I/U) | BR-16 | Hội viên không đăng ký lớp trùng giờ với ca PT hoặc lớp khác của mình |
| `trg_prevent_class_in_maintenance_room`, `trg_prevent_room_maintenance_with_future_classes` | `class_schedule`, `facilities_room` | BR-19 | Chỉ xếp lớp vào phòng `Active`; không cho phòng chuyển sang bảo trì/ngừng dùng khi còn lớp tương lai |
| `trg_check_reservation_window`, `trg_prevent_equipment_reservation_under_maintenance` | `equipment_reservation` (BEFORE I/U) | BR-19, BR-21 | Kiểm tra khung giờ giữ chỗ; chỉ giữ chỗ thiết bị `Operational` (không bảo trì, không thanh lý) |
| `trg_prevent_equipment_maintenance_with_future_reservations` | `equipment` (BEFORE UPDATE) | BR-19 | Không chuyển bảo trì khi còn giữ chỗ tương lai |
| `trg_start_equipment_maintenance_insert`, `trg_start_equipment_maintenance_update`, `trg_finish_equipment_maintenance` | `maintenance_log` (AFTER INSERT/UPDATE) | BR-19 | Đồng bộ trạng thái thiết bị theo phiếu bảo trì |

Ví dụ 1 – **nhật ký thanh toán bất biến (BR-10)**: ba trigger chặn `UPDATE`, `DELETE`, `TRUNCATE` trên `billing_log`; hàm cho `UPDATE` chỉ cho phép `Completed → Refunded` (không đổi cột nào khác) và `Pending → Completed/Failed`.

```sql
CREATE OR REPLACE FUNCTION trg_fn_billing_immutable_delete()
RETURNS TRIGGER AS $$
BEGIN
    RAISE EXCEPTION 'Lỗi nghiệp vụ BR-10: Không được xóa hóa đơn % (nhật ký thanh toán bất biến); hãy chuyển sang Refunded nếu cần hoàn tiền',
        OLD.invoice_no;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_billing_immutable_update
BEFORE UPDATE ON billing_log
FOR EACH ROW
EXECUTE FUNCTION trg_fn_billing_immutable_update();
```

Ví dụ 2 – **trừ buổi PT an toàn khi truy cập đồng thời (BR-18, BR-25)**: `SELECT … FOR UPDATE` khóa hàng hợp đồng trước khi trừ, và chỉ trừ khi ca chuyển *sang* nhóm trạng thái tính phí (tránh trừ hai lần khi đổi `Completed → No_Show`).

```sql
CREATE OR REPLACE FUNCTION trg_fn_update_remaining_pt_sessions()
RETURNS TRIGGER AS $$
DECLARE
    v_current_remaining INT;
    v_deducting CONSTANT TEXT[] := ARRAY['Completed', 'No_Show', 'Late_Cancelled'];
BEGIN
    IF (NEW.status = ANY (v_deducting) AND NOT (OLD.status = ANY (v_deducting))) THEN
        SELECT remaining_sessions
        INTO v_current_remaining
        FROM member_subscription
        WHERE subscription_id = NEW.subscription_id
        FOR UPDATE;
        -- ... RAISE EXCEPTION BR-18 nếu không tìm thấy hợp đồng hoặc v_current_remaining <= 0 ...
        UPDATE member_subscription
        SET remaining_sessions = remaining_sessions - 1
        WHERE subscription_id = NEW.subscription_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

#### 4.1.4. View và thủ tục

*Bảng 4-4. View và thủ tục lưu trữ*

| Đối tượng | Loại | Mục đích |
| --- | --- | --- |
| `vw_active_member_subscriptions` | View | Hợp đồng `Active` kèm thông tin hội viên, gói, số buổi còn lại, số ngày còn lại và nhãn hiệu lực |
| `vw_trainer_schedule_overview` | View | Hợp nhất lịch lớp và ca PT của huấn luyện viên (`UNION ALL`) |
| `sp_process_subscription_renewals` | Procedure | BR-24: đánh dấu `Expired`, phát hành hóa đơn gia hạn `Pending`, chuyển `Suspended` khi quá hạn ân hạn |

Thủ tục `sp_process_subscription_renewals` là idempotent: hợp đồng không tự gia hạn quá hạn chuyển `Expired`; hợp đồng tự gia hạn được phát hành hóa đơn `Pending` cho chu kỳ kế tiếp; hợp đồng quá thời gian ân hạn mà chưa thanh toán chuyển `Suspended`.

```sql
CREATE OR REPLACE PROCEDURE sp_process_subscription_renewals(
    p_as_of      DATE DEFAULT CURRENT_DATE,
    p_grace_days INT  DEFAULT 3
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff TIMESTAMP := p_as_of::TIMESTAMP;
    -- ...
BEGIN
    -- Bước 1: hợp đồng không tự gia hạn đã hết hạn -> Expired
    -- Bước 2: phát hành hóa đơn gia hạn Pending (INSERT ... SELECT)
    -- ...

    -- Bước 3: hết thời gian ân hạn mà chưa thanh toán -> tạm ngưng
    UPDATE member_subscription
    SET sub_status = 'Suspended'
    WHERE sub_status = 'Active' AND is_recurring
      AND end_time + make_interval(days => p_grace_days) < v_cutoff;
END;
$$;
```

#### 4.1.5. Thứ tự nạp script và triển khai

Dự án được đóng gói bằng Docker Compose; PostgreSQL tự nạp bốn nhóm script đầu tiên (từ `/docker-entrypoint-initdb.d/`) theo đúng thứ tự dưới đây. Các script còn lại chạy thủ công.

*Bảng 4-5. Script SQL và thứ tự nạp*

| Thứ tự | File | Nội dung |
| --- | --- | --- |
| 1 (tự động) | `Phase 3/01_schema_ddl.sql` | Extension `btree_gist`, 18 bảng, ràng buộc, chỉ mục, 3 trigger (BR-03, BR-14) |
| 2 (tự động) | `Phase 3/02_mock_data/01..08_*.sql` | Dữ liệu mẫu cho 18 bảng: 9.928 bản ghi, gồm 3.000 người dùng và 500 thiết bị |
| 3 (tự động) | `Phase 3/04_triggers_views.sql` | 2 view, 31 trigger nghiệp vụ, thủ tục gia hạn, khối kiểm toán dữ liệu mẫu |
| 4 (tự động) | `Phase 3/08_rbac_security.sql` | Role, tài khoản demo, `GRANT`/`REVOKE`, `SECURITY DEFINER`, 2 event trigger bảo vệ `billing_log` |
| Thủ công | `Phase 3/03_complex_queries.sql` | 10 truy vấn nâng cao (mục 4.2) |
| Thủ công | `Phase 3/05_constraint_test_cases.sql` | 114 test ràng buộc và trigger (mục 5.1) |
| Thủ công | `Phase 3/06_performance_test_cases.sql` | 8 test hiệu năng với 100.000+ bản ghi (mục 4.2) |
| Thủ công | `Phase 3/09_rbac_test_cases.sql` | 66 test phân quyền (mục 5.2) |

Thư mục `Phase 3/` được mount chỉ-đọc vào `/sql/` trong container CSDL. Container `fitzone_web_app` (Streamlit) kết nối bằng `gym_u_admin` (không phải superuser) nên quyền CSDL luôn được áp dụng cho ứng dụng.

```bash
docker compose up --build        # CSDL cổng 5432, ứng dụng Streamlit: http://localhost:8501
# Script thủ công (tương tự cho 03, 06, 09)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/05_constraint_test_cases.sql
docker compose exec backup backup.sh --once   # sao lưu mã hóa ngay (./backups/<db>_<UTC>.dump.enc)
docker compose exec backup verify-restore.sh  # giải mã bản mới nhất, khôi phục vào CSDL tạm, so số dòng 18 bảng
docker compose exec backup verify-pitr.sh     # PITR: bản nền + phát lại WAL trên máy chủ tạm, so số dòng 18 bảng
docker compose down -v           # dọn sạch container, mạng và volume
```

Image CSDL `fitzone-postgres:16` (thư mục `docker/postgres/`, nền `postgres:16-alpine` cộng `openssl`) tạo chứng chỉ TLS tự ký khi khởi động (demo; production gắn chứng chỉ của CA vào `/etc/postgresql/tls`) và bật `ssl=on`, `ssl_min_protocol_version=TLSv1.2`; `pg_hba.conf` chỉ cho phép `hostssl` với `scram-sha-256` và `reject` kết nối `hostnossl`, nên mọi kết nối mạng bắt buộc dùng TLS (web: `DB_SSLMODE=require`; scheduler: `PGSSLMODE=require`). Service `backup` (container `fitzone_db_backup`) chạy `pg_dump -Fc` ngay khi khởi động rồi mỗi `BACKUP_INTERVAL_SECONDS` (mặc định 86400), mã hóa AES-256-CBC (PBKDF2, 200000 vòng) bằng `BACKUP_PASSPHRASE`, ghi `./backups/` (quyền 0600) và giữ `BACKUP_RETENTION` (mặc định 7) bản mới nhất. Phải đổi `BACKUP_PASSPHRASE` khi triển khai thật; mất mật khẩu này thì không khôi phục được bản sao lưu. Chưa bao gồm: mã hóa tệp dữ liệu trên đĩa máy chủ (hạ tầng: LUKS/mã hóa đĩa đám mây) và lưu trữ liên tục WAL/PITR.

Do mọi thao tác ghi vào 5 bảng giao dịch cần có người thực hiện (BR-23), khi chạy SQL thủ công cần `SET app.current_user_id = '<user_id>';` trước (các script test tự đặt). Vì PostgreSQL không có bộ lập lịch tích hợp, service `scheduler` (container `fitzone_renewal_scheduler`) gọi `CALL sp_process_subscription_renewals();` bằng `gym_u_reception` khi khởi động và lặp lại mỗi `RENEWAL_INTERVAL_SECONDS` giây (mặc định 86400); trong production dùng `pg_cron`/cron. Nạp lại tại chỗ CSDL đã có bị event trigger BR-10 chặn; cách đơn giản nhất là `docker compose down -v` rồi nạp lại.
### 4.2. Truy vấn nâng cao & kiểm thử hiệu năng (Advanced Queries & Performance Test Cases)

#### 4.2.1. Tổng quan

Mười truy vấn phức hợp dưới đây chạy trên PostgreSQL 16+ với dữ liệu mẫu. Q1–Q3 phụ thuộc `CURRENT_DATE` nên số dòng kết quả thay đổi theo ngày chạy.

*Bảng 4-6. Danh sách 10 truy vấn nâng cao, kỹ thuật SQL và yêu cầu phục vụ*

| Q | Nghiệp vụ | Kỹ thuật SQL | UR/FR phục vụ |
| --- | --- | --- | --- |
| Q1 | Doanh thu theo gói tập trong quý hiện tại | JOIN 3 bảng, GROUP BY, SUM/AVG, `DATE_TRUNC('quarter', …)` | Báo cáo doanh thu của Ban Giám đốc (thanh toán, gói tập) |
| Q2 | Top 3 HLV có số giờ dạy nhiều nhất trong tháng | CTE, UNION ALL, `EXTRACT(EPOCH …)`, GROUP BY, HAVING, LIMIT | Thống kê giờ dạy, thưởng KPI HLV |
| Q3 | Hội viên có gói sắp hết hạn trong 7 ngày | JOIN, WHERE, `CURRENT_TIMESTAMP`, INTERVAL | Nhắc gia hạn, chăm sóc khách hàng (Lễ tân) |
| Q4 | Thiết bị đang bảo trì, kỹ thuật viên và tổng chi phí | JOIN 4 bảng, subquery tương quan, `COALESCE`, SUM | Quản lý thiết bị và bảo trì (BR-19) |
| Q5 | Tỷ lệ lấp đầy lớp học nhóm | JOIN, biểu thức số học, `ROUND`, CASE WHEN | Quản lý lớp nhóm, tối ưu phân bổ phòng |
| Q6 | Ca PT 1-1 bị hủy muộn, hủy hoặc no-show | JOIN 3 bảng (self-join `user_account`), `IN`, CASE | Kiểm soát quy định hủy lịch (BR-25) |
| Q7 | Hội viên mua gói PT nhưng chưa đặt lịch | LEFT JOIN, `IS NULL` (anti-join) | Chăm sóc hội viên không hoạt động |
| Q8 | Gói tập được ưa chuộng nhất theo nhóm tuổi | 2 CTE, CASE, `AGE`, `DENSE_RANK() OVER (PARTITION BY …)` | Phân khúc khách hàng cho Marketing |
| Q9 | Xếp hạng chi tiêu hội viên (VIP tier) | JOIN, GROUP BY, window function `DENSE_RANK() OVER (ORDER BY SUM(…))` | Chính sách ưu đãi hội viên thân thiết |
| Q10 | Kiểm toán xung đột lịch HLV | CTE, UNION ALL, self-join khoảng thời gian chồng lấn | Toàn vẹn lịch dạy của HLV (BR-12) |

#### 4.2.2. Q1 – Doanh thu theo từng gói tập trong quý hiện tại

Giúp Ban Giám đốc đánh giá hiệu quả kinh doanh của từng gói dịch vụ (Gói tháng, VIP, PT) trong quý đang vận hành để điều chỉnh chính sách giá.

```sql
SELECT
    mp.plan_id,
    mp.plan_name,
    COUNT(bl.billing_id) AS total_transactions,
    SUM(bl.amount)       AS total_revenue,
    ROUND(AVG(bl.amount), 2) AS average_order_value
FROM
    membership_plan mp
JOIN
    member_subscription ms ON mp.plan_id = ms.plan_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
    AND bl.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)
    AND bl.payment_date <  DATE_TRUNC('quarter', CURRENT_DATE) + INTERVAL '3 months'
GROUP BY
    mp.plan_id,
    mp.plan_name
ORDER BY
    total_revenue DESC;
```

Kết quả: 3 dòng, mỗi gói một dòng kèm số giao dịch, tổng doanh thu và giá trị đơn trung bình.

#### 4.2.3. Q2 – Top 3 huấn luyện viên có số giờ dạy nhiều nhất trong tháng

Tổng hợp giờ dạy cả lớp nhóm lẫn PT 1-1 trong tháng hiện tại để xét thưởng KPI cho HLV xuất sắc.

```sql
WITH trainer_teaching_hours AS (
    SELECT
        pb.trainer_user_id AS trainer_id,
        ROUND((EXTRACT(EPOCH FROM (pb.end_time - pb.start_time)) / 3600.0)::NUMERIC, 2) AS hours_taught,
        'PT_1_ON_1' AS teaching_type
    FROM
        pt_booking pb
    WHERE
        pb.status = 'Completed'
        AND pb.booking_date >= DATE_TRUNC('month', CURRENT_DATE)
        AND pb.booking_date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
    UNION ALL
    SELECT
        cs.trainer_user_id AS trainer_id,
        ROUND((EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600.0)::NUMERIC, 2) AS hours_taught,
        'GROUP_CLASS' AS teaching_type
    FROM
        class_schedule cs
    WHERE
        cs.start_time >= DATE_TRUNC('month', CURRENT_DATE)
        AND cs.start_time <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
)
SELECT
    u.user_id AS trainer_id,
    u.full_name AS trainer_name,
    tp.specialization,
    tp.current_rating,
    COUNT(tth.hours_taught) AS total_sessions_conducted,
    SUM(tth.hours_taught)   AS total_hours_taught
FROM
    trainer_teaching_hours tth
JOIN
    user_account u ON tth.trainer_id = u.user_id
JOIN
    trainer_profile tp ON u.user_id = tp.user_id
GROUP BY
    u.user_id,
    u.full_name,
    tp.specialization,
    tp.current_rating
HAVING
    SUM(tth.hours_taught) > 0
ORDER BY
    total_hours_taught DESC
LIMIT 3;
```

Kết quả: 3 dòng (3 HLV đứng đầu).

- Chỉ tính ca PT ở trạng thái `Completed`; giờ lớp nhóm lấy theo lịch lớp.
- `UNION ALL` (không phải `UNION`) để không loại bỏ các buổi trùng giá trị.

#### 4.2.4. Q3 – Hội viên có gói tập sắp hết hạn trong 7 ngày tới

Hỗ trợ Lễ tân / Chăm sóc khách hàng chủ động nhắc gia hạn và tư vấn gói ưu đãi (chiến dịch giữ chân khách hàng).

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.phone,
    u.email,
    mp.plan_name,
    ms.subscription_id,
    ms.end_time AS expiration_date,
    ROUND(EXTRACT(EPOCH FROM (ms.end_time - CURRENT_TIMESTAMP)) / 86400.0, 1) AS days_remaining,
    ms.remaining_sessions AS pt_sessions_left,
    ms.is_recurring
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active'
    AND ms.end_time >= CURRENT_TIMESTAMP
    AND ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days'
ORDER BY
    ms.end_time ASC;
```

Kết quả: 3 dòng, sắp theo thời điểm hết hạn gần nhất.

#### 4.2.5. Q4 – Thiết bị đang bảo trì kèm kỹ thuật viên và tổng chi phí

Kiểm soát trạng thái vận hành của thiết bị (BR-19): thiết bị đang ngừng hoạt động, người phụ trách và chi phí sửa chữa lũy kế.

```sql
SELECT
    e.equipment_id,
    e.equipment_name,
    e.serial_number,
    fr.room_name AS location_room,
    e.status AS equipment_status,
    u.full_name AS technician_in_charge,
    ml.issue_description AS current_issue,
    ml.start_time AS maintenance_started_at,
    ml.cost AS current_ticket_cost,
    (
        SELECT COALESCE(SUM(all_ml.cost), 0)
        FROM maintenance_log all_ml
        WHERE all_ml.equipment_id = e.equipment_id
    ) AS total_historical_repair_cost
FROM
    equipment e
JOIN
    facilities_room fr ON e.room_id = fr.room_id
JOIN
    maintenance_log ml ON e.equipment_id = ml.equipment_id
JOIN
    user_account u ON ml.staff_user_id = u.user_id
WHERE
    e.status = 'Under_Maintenance'
    AND ml.status = 'In_Progress'
ORDER BY
    ml.start_time ASC;
```

Kết quả: 3 dòng.

- Subquery tương quan tính lũy kế chi phí toàn bộ lịch sử bảo trì của thiết bị, còn `ml.cost` là chi phí của phiếu đang xử lý.

#### 4.2.6. Q5 – Tỷ lệ lấp đầy (fill rate) của các lớp học nhóm

Đánh giá sức hút của từng lớp (Yoga, Pilates, CrossFit), phát hiện lớp có tỷ lệ lấp đầy thấp để tối ưu phân bổ phòng học.

```sql
SELECT
    cs.class_id,
    cs.class_name,
    u.full_name AS instructor_name,
    fr.room_name,
    cs.start_time,
    cs.max_capacity,
    cs.current_enrolled,
    ROUND((cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) * 100.0, 2) AS fill_rate_percentage,
    CASE
        WHEN (cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) >= 1.00 THEN 'Đầy Chỗ (Full 100%)'
        WHEN (cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) >= 0.70 THEN 'Tốt (High Demand)'
        WHEN (cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC) >= 0.40 THEN 'Trung Bình (Moderate)'
        ELSE 'Thấp (Low Attendance - Cần Khuyến Mãi)'
    END AS occupancy_category
FROM
    class_schedule cs
JOIN
    user_account u ON cs.trainer_user_id = u.user_id
JOIN
    facilities_room fr ON cs.room_id = fr.room_id
ORDER BY
    fill_rate_percentage DESC,
    cs.start_time ASC;
```

Kết quả: 20 dòng, mỗi lớp được xếp vào một trong bốn mức: đầy chỗ (≥ 100%), tốt (≥ 70%), trung bình (≥ 40%), thấp.

#### 4.2.7. Q6 – Ca PT 1-1 bị hủy muộn, hủy hoặc bỏ tập (no-show)

Kiểm soát quy định hủy lịch (BR-25), thống kê hội viên hay vắng mặt gây lãng phí thời gian biểu của HLV.

```sql
SELECT
    pb.booking_id,
    pb.booking_date,
    pb.start_time,
    m.user_id AS member_id,
    m.full_name AS member_name,
    m.phone AS member_phone,
    t.full_name AS trainer_name,
    pb.status AS incident_status,
    CASE pb.status
        WHEN 'No_Show'        THEN 'Hội viên không đến và không báo trước (Trừ 1 buổi theo BR-25)'
        WHEN 'Late_Cancelled' THEN 'Hủy muộn khi còn dưới 24 giờ (Trừ 1 buổi theo BR-25)'
        WHEN 'Cancelled'      THEN 'Hủy sớm trước 24 giờ (Không trừ buổi theo BR-25)'
        ELSE pb.status
    END AS rule_penalty_note
FROM
    pt_booking pb
JOIN
    user_account m ON pb.member_user_id = m.user_id
JOIN
    user_account t ON pb.trainer_user_id = t.user_id
WHERE
    pb.status IN ('Cancelled', 'Late_Cancelled', 'No_Show')
ORDER BY
    pb.booking_date DESC,
    pb.start_time DESC;
```

Kết quả: 4 dòng.

- `Late_Cancelled` là ca hủy khi còn dưới 24 giờ (trigger `trg_late_cancel_pt_booking` tự đổi trạng thái và trừ 1 buổi); `Cancelled` là hủy sớm, không bị trừ buổi.

#### 4.2.8. Q7 – Hội viên đã mua gói PT nhưng chưa từng đặt lịch

Xác định nhóm hội viên "ngủ đông" để Trưởng bộ phận HLV liên hệ hướng dẫn lên lịch.

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.phone,
    u.email,
    mp.plan_name,
    ms.subscription_id,
    ms.remaining_sessions,
    ms.start_time AS package_started_at,
    ms.end_time   AS package_expires_at
FROM
    member_subscription ms
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
JOIN
    user_account u ON ms.member_user_id = u.user_id
LEFT JOIN
    pt_booking pb ON ms.subscription_id = pb.subscription_id
WHERE
    mp.total_sessions > 0
    AND ms.sub_status = 'Active'
    AND pb.booking_id IS NULL
ORDER BY
    ms.start_time ASC;
```

Kết quả: 1 dòng.

#### 4.2.9. Q8 – Phân nhóm hội viên theo độ tuổi và gói tập được ưa chuộng nhất

Phân khúc nhân khẩu học để Marketing định hướng gói tập phù hợp cho từng nhóm tuổi.

```sql
WITH member_age_groups AS (
    SELECT
        u.user_id,
        u.dob,
        EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) AS age,
        CASE
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) < 25 THEN 'Nhóm 1: Dưới 25 tuổi (Học sinh - Sinh viên)'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 25 AND 35 THEN 'Nhóm 2: 25 - 35 tuổi (Người trẻ đi làm)'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 36 AND 50 THEN 'Nhóm 3: 36 - 50 tuổi (Trung niên - Gia đình)'
            ELSE 'Nhóm 4: Trên 50 tuổi (Cao niên - Phục hồi sức khỏe)'
        END AS age_bracket,
        mp.plan_name
    FROM
        user_account u
    JOIN
        member_subscription ms ON u.user_id = ms.member_user_id
    JOIN
        membership_plan mp ON ms.plan_id = mp.plan_id
),
plan_popularity AS (
    SELECT
        age_bracket,
        plan_name,
        COUNT(*) AS total_subscriptions,
        DENSE_RANK() OVER (PARTITION BY age_bracket ORDER BY COUNT(*) DESC) AS rank_in_bracket
    FROM
        member_age_groups
    GROUP BY
        age_bracket,
        plan_name
)
SELECT
    age_bracket,
    plan_name AS top_preferred_plan,
    total_subscriptions
FROM
    plan_popularity
WHERE
    rank_in_bracket = 1
ORDER BY
    age_bracket ASC,
    plan_name ASC;
```

Kết quả: 5 dòng, mỗi nhóm tuổi kèm gói được đăng ký nhiều nhất.

- `DENSE_RANK()` giữ lại mọi gói đồng hạng nhất trong cùng nhóm tuổi.

#### 4.2.10. Q9 – Xếp hạng doanh thu đóng góp của từng hội viên (window function)

Xây dựng bảng xếp hạng hội viên VIP theo tổng số tiền đã thanh toán thành công.

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.phone,
    u.email,
    COUNT(bl.billing_id) AS total_bills_paid,
    SUM(bl.amount)       AS total_money_spent,
    DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) AS spending_rank,
    CASE
        WHEN DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) <= 3 THEN 'Hội Viên Kim Cương (VIP Tier 1)'
        WHEN DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) <= 8 THEN 'Hội Viên Bạch Kim (VIP Tier 2)'
        ELSE 'Hội Viên Tiêu Chuẩn (Standard)'
    END AS loyalty_tier
FROM
    user_account u
JOIN
    member_subscription ms ON u.user_id = ms.member_user_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
GROUP BY
    u.user_id,
    u.full_name,
    u.phone,
    u.email
ORDER BY
    spending_rank ASC,
    total_money_spent DESC;
```

Kết quả: 20 dòng; hạng 1–3 là Kim Cương (VIP Tier 1), hạng 4–8 là Bạch Kim (VIP Tier 2), còn lại là Tiêu chuẩn.

#### 4.2.11. Q10 – Kiểm toán xung đột trùng lịch của huấn luyện viên

Phát hiện mọi cặp sự kiện (lớp nhóm, ca PT 1-1) của cùng một HLV bị chồng lấn thời gian (BR-12). Trùng phòng (BR-15) và trùng hội viên (BR-16) đã do `ex_class_room_no_overlap`, `ex_pt_member_no_overlap` và trigger chặn nên không nằm trong truy vấn này.

```sql
WITH all_trainer_events AS (
    SELECT
        cs.class_id AS event_id,
        'GROUP_CLASS' AS event_type,
        cs.trainer_user_id AS trainer_id,
        cs.class_name AS event_title,
        cs.start_time,
        cs.end_time
    FROM
        class_schedule cs
    UNION ALL
    SELECT
        pb.booking_id AS event_id,
        'PT_BOOKING' AS event_type,
        pb.trainer_user_id AS trainer_id,
        CONCAT('Ca tập PT với Hội viên ID: ', pb.member_user_id) AS event_title,
        pb.start_time,
        pb.end_time
    FROM
        pt_booking pb
    WHERE
        pb.status NOT IN ('Cancelled', 'Late_Cancelled')
)
SELECT
    e1.trainer_id,
    u.full_name AS trainer_name,
    e1.event_type  AS first_event_type,
    e1.event_title AS first_event_title,
    e1.start_time  AS first_start_time,
    e1.end_time    AS first_end_time,
    e2.event_type  AS conflict_event_type,
    e2.event_title AS conflict_event_title,
    e2.start_time  AS conflict_start_time,
    e2.end_time    AS conflict_end_time,
    'CẢNH BÁO: TRÙNG LỊCH HLV (BR-12)' AS conflict_alert
FROM
    all_trainer_events e1
JOIN
    all_trainer_events e2 ON e1.trainer_id = e2.trainer_id
                         AND e1.start_time < e2.end_time
                         AND e1.end_time > e2.start_time
JOIN
    user_account u ON e1.trainer_id = u.user_id
WHERE
    (e1.event_type, e1.event_id) < (e2.event_type, e2.event_id) -- Tránh lặp lại kết quả theo thứ tự hoán vị
ORDER BY
    e1.start_time ASC;
```

Kết quả: 0 dòng, đúng kỳ vọng.

- Do BR-12/15/16 đã được CSDL cưỡng chế (ràng buộc `EXCLUDE` và trigger), đây là truy vấn kiểm toán; nếu có dòng trả về nghĩa là dữ liệu đã vượt qua cơ chế bảo vệ.
- Điều kiện `start_a < end_b AND end_a > start_b` biểu diễn hai khoảng chồng lấn; so sánh bộ `(event_type, event_id)` loại cặp hoán vị.

#### 4.2.12. Kiểm thử hiệu năng và chỉ mục

Yêu cầu kiểm chứng NFR-PERF-01: truy vấn tra cứu/tìm kiếm chính phải trả kết quả dưới 200 ms với 100.000 – 200.000 bản ghi mỗi bảng nghiệp vụ. Script kiểm thử, bọc trong `BEGIN … ROLLBACK`, sinh tạm 100.000 tài khoản, 200.000 hóa đơn và 120.000 ca PT bằng `generate_series()`, chạy `ANALYZE`, làm nóng một lần rồi đo `EXPLAIN (ANALYZE)` hai lần cho mỗi truy vấn: có chỉ mục (kế hoạch bình thường) và không chỉ mục (tắt `enable_indexscan`, `enable_bitmapscan`, `enable_indexonlyscan` để buộc `Seq Scan`). Thời gian tuyệt đối phụ thuộc máy; điều cần quan sát là loại phép quét và tỉ lệ chênh lệch.

*Bảng 4-7. Kết quả 8 test hiệu năng, thời gian thực thi không chỉ mục (trước) so với có chỉ mục (sau)*

| ID | Truy vấn / kịch bản | Chỉ mục | Trước (ms) | Sau (ms) | Kết luận |
| --- | --- | --- | --- | --- | --- |
| PT-01 | Tra cứu tài khoản theo email khi đăng nhập | `uq_user_account_email` (Index Scan) | 14,119 | 0,037 | Nhanh hơn 381,6 lần; PASS |
| PT-02 | Tra cứu tài khoản theo số điện thoại | `uq_user_account_phone` (Index Scan) | 14,055 | 0,041 | Nhanh hơn 342,8 lần; PASS |
| PT-03 | Doanh thu theo phương thức thanh toán trong 1 tuần | `idx_billing_log_payment_date` (Bitmap Index Scan) | 33,374 | 0,842 | Nhanh hơn 39,6 lần; PASS |
| PT-04 | 20 hóa đơn gần nhất của một hợp đồng | `idx_billing_log_subscription_date` (Index Scan) | 18,321 | 0,058 | Nhanh hơn 315,9 lần; PASS |
| PT-05 | Tra cứu hóa đơn theo `invoice_no` | `uq_billing_invoice_no` (Index Scan) | 26,713 | 0,041 | Nhanh hơn 651,5 lần; PASS |
| PT-06 | Lịch ca PT trong một ngày của một HLV | `idx_pt_booking_dates` (Index Scan) | 12,300 | 0,058 | Nhanh hơn 212,1 lần; PASS |
| PT-07 | Kiểm tra trùng lịch HLV bằng toán tử `&&` | `ex_pt_trainer_no_overlap` (GiST, Index Scan) | 13,619 | 0,055 | Nhanh hơn 247,6 lần; PASS |
| PT-08 | Truy vấn Q1: doanh thu từng gói trong một quý | `idx_billing_log_payment_date` (Bitmap Index Scan) | 41,440 | 13,652 | Nhanh hơn 3,0 lần; PASS |

- 8/8 test đạt NFR-PERF-01 (thực tế dưới 14 ms); các tra cứu điểm (PT-01, 02, 04, 05, 06, 07) chạy trong 0,04 – 0,06 ms, nhanh hơn 212 – 652 lần so với quét toàn bảng.
- PT-04 dùng chỉ mục ghép `(subscription_id, payment_date DESC)` phục vụ cả lọc lẫn `ORDER BY`; PT-07 cho thấy chỉ mục GiST của ràng buộc `EXCLUDE` vừa bảo đảm toàn vẹn (BR-12) vừa tăng tốc tìm khoảng thời gian chồng lấn.
- PT-08 chỉ cải thiện 3,0 lần vì phần lớn thời gian nằm ở `JOIN` và `GROUP BY` chứ không ở bước lọc.
## 5. Kiểm thử & bảo mật (Verification & Security)

### 5.1. Test case chứng minh ràng buộc ngăn dữ liệu sai (Constraint Test Cases)

#### 5.1.1. Phương pháp

- Toàn bộ bộ kiểm thử chạy trong một giao dịch rồi `ROLLBACK` nên không làm thay đổi dữ liệu mẫu; mỗi test chạy trong một savepoint riêng (khối `BEGIN … EXCEPTION` của PL/pgSQL) và độc lập với nhau.
- **Test âm (TC-xx):** cố tình vi phạm một quy tắc nghiệp vụ; **PASS** khi CSDL từ chối với đúng mã lỗi SQLSTATE mong đợi: `23502` (`NOT NULL`), `23503` (`FOREIGN KEY`), `23505` (`UNIQUE`/`PRIMARY KEY`), `23514` (`CHECK`), `23P01` (`EXCLUDE USING gist`), `P0001` (trigger `RAISE EXCEPTION`, thông báo nêu mã `BR-xx`).
- **Test dương (TP-xx):** thao tác hợp lệ phải được chấp nhận (SQLSTATE `00000`) và trigger phải cập nhật đúng dữ liệu dẫn xuất (trừ buổi PT, đồng bộ `current_enrolled`, tự kích hoạt hợp đồng...).
- Mỗi test được đánh dấu PASS/FAIL bằng cách so sánh SQLSTATE thực tế với SQLSTATE mong đợi (và, với test âm, tên ràng buộc/trigger gây lỗi).
- Mọi test đặt `app.current_user_id` ở đầu phiên vì BR-23 từ chối ghi dữ liệu khi chưa có người thực hiện.

Ví dụ một test âm (TC-01, BR-02: trùng email):

```sql
SELECT pg_temp.expect_error('TC-01', 'BR-02',
    'Tạo tài khoản trùng email đã tồn tại (uq_user_account_email)', '23505', ARRAY[
    $q$INSERT INTO user_account (full_name, email, phone, dob, password_hash)
       SELECT 'Test Trung Email', email, '0999000001', DATE '2000-01-01', 'x'
       FROM user_account
       WHERE user_id = 11$q$
], 'uq_user_account_email');
```

#### 5.1.2. Kết quả

Kết quả chạy trên PostgreSQL 16: **114 test, 114 đạt, 0 không đạt** (78 test âm TC-xx và 36 test dương TP-xx).

*Bảng 5-1. Tổng hợp kết quả test ràng buộc theo nhóm quy tắc nghiệp vụ*

| BR | Số test âm | Số test dương | SQLSTATE điển hình | Kết quả |
| --- | --- | --- | --- | --- |
| BR-01 | 1 | 0 | `23503` | 1/1 PASS |
| BR-02 | 3 | 0 | `23505`, `23502` | 3/3 PASS |
| BR-03 | 2 | 1 | `P0001` | 3/3 PASS |
| BR-04 | 3 | 0 | `23514`, `23503` | 3/3 PASS |
| BR-05 | 1 | 1 | `23505` | 2/2 PASS |
| BR-06 | 1 | 0 | `23514` | 1/1 PASS |
| BR-07 | 2 | 1 | `P0001` | 3/3 PASS |
| BR-08 | 1 | 2 | `23505` | 3/3 PASS |
| BR-09 | 3 | 1 | `23505`, `23514` | 4/4 PASS |
| BR-10 | 7 | 3 | `23503`, `P0001` | 10/10 PASS |
| BR-11 | 1 | 0 | `23514` | 1/1 PASS |
| BR-12 | 4 | 1 | `23P01` | 5/5 PASS |
| BR-13 | 1 | 0 | `23514` | 1/1 PASS |
| BR-14 | 2 | 2 | `23514`, `23505` | 4/4 PASS |
| BR-15 | 1 | 1 | `23P01` | 2/2 PASS |
| BR-16 | 6 | 1 | `23P01` | 7/7 PASS |
| BR-17 | 2 | 0 | `23514` | 2/2 PASS |
| BR-18 | 8 | 2 | `23514`, `23503`, `P0001` | 10/10 PASS |
| BR-19 | 9 | 5 | `P0001` | 14/14 PASS |
| BR-20 | 3 | 0 | `23514`, `23503` | 3/3 PASS |
| BR-21 | 6 | 3 | `23514`, `23P01`, `P0001` | 9/9 PASS |
| BR-22 | 2 | 0 | `23514`, `23505` | 2/2 PASS |
| BR-23 | 4 | 4 | `23503`, `P0001` | 8/8 PASS |
| BR-24 | 1 | 4 | `P0001` | 5/5 PASS |
| BR-25 | 2 | 4 | `23514` | 6/6 PASS |
| BR-26 | 2 | 0 | `23514`, `23505` | 2/2 PASS |
| **Tổng** | **78** | **36** | | **114/114 PASS** |

*Bảng 5-2. Danh sách 114 test case ràng buộc và trigger (SQLSTATE mong đợi trùng SQLSTATE thực tế ở mọi test)*

| Mã | BR | Kịch bản | SQLSTATE | KQ |
| --- | --- | --- | --- | --- |
| TC-01 | BR-02 | Tạo tài khoản trùng email đã tồn tại (uq_user_account_email) | `23505` | PASS |
| TC-02 | BR-02 | Tạo tài khoản trùng số điện thoại đã tồn tại (uq_user_account_phone) | `23505` | PASS |
| TC-03 | BR-02 | Tạo tài khoản thiếu email (NOT NULL) | `23502` | PASS |
| TC-04 | BR-03 | Đăng ký hồ sơ hội viên cho người dưới 12 tuổi (trg_check_member_dob) | `P0001` | PASS |
| TC-05 | BR-03 | Sửa ngày sinh của hội viên hiện có thành dưới 12 tuổi (trg_check_user_dob_for_member) | `P0001` | PASS |
| TC-06 | BR-22 | Gán trạng thái tài khoản ngoài miền giá trị (chk_user_account_status) | `23514` | PASS |
| TC-07 | BR-11 | Điểm đánh giá HLV vượt quá 5.00 (chk_trainer_rating) | `23514` | PASS |
| TC-08 | BR-22 | Gán cùng một vai trò hai lần cho một người dùng (pk_user_role) | `23505` | PASS |
| TC-09 | BR-04 | Tạo gói tập có thời hạn 0 ngày (chk_membership_plan_duration) | `23514` | PASS |
| TC-10 | BR-04 | Tạo gói tập có giá âm (chk_membership_plan_price) | `23514` | PASS |
| TC-11 | BR-06 | Hợp đồng có ngày kết thúc trước ngày bắt đầu (chk_subscription_dates) | `23514` | PASS |
| TC-12 | BR-01 | Ký hợp đồng cho người không có hồ sơ hội viên (HLV ID 5) (fk_subscription_member) | `23503` | PASS |
| TC-13 | BR-18 | Số buổi PT còn lại bị âm (chk_subscription_remaining) | `23514` | PASS |
| TC-14 | BR-09 | Phát hành hóa đơn trùng số invoice_no (uq_billing_invoice_no) | `23505` | PASS |
| TC-15 | BR-09 | Hóa đơn có số tiền bằng 0 (chk_billing_amount) | `23514` | PASS |
| TC-16 | BR-09 | Phương thức thanh toán không hợp lệ (chk_billing_method) | `23514` | PASS |
| TC-17 | BR-10 | Xóa hợp đồng đã phát sinh hóa đơn (fk_billing_subscription, ON DELETE RESTRICT) | `23503` | PASS |
| TC-18 | BR-04 | Xóa gói tập đang được hợp đồng sử dụng (fk_subscription_plan) | `23503` | PASS |
| TC-19 | BR-13 | Phòng tập có sức chứa bằng 0 (chk_facilities_capacity) | `23514` | PASS |
| TC-20 | BR-17 | Lớp học có giờ kết thúc bằng giờ bắt đầu (chk_class_time) | `23514` | PASS |
| TC-21 | BR-15 | Xếp 2 lớp trùng giờ trong cùng một phòng (ex_class_room_no_overlap) | `23P01` | PASS |
| TC-22 | BR-12 | Một HLV dạy 2 lớp trùng giờ ở 2 phòng khác nhau (ex_class_trainer_no_overlap) | `23P01` | PASS |
| TC-23 | BR-19 | Xếp lớp vào phòng đang bảo trì, phòng ID 6 (trg_prevent_class_in_maintenance_room) | `P0001` | PASS |
| TC-24 | BR-14 | Đăng ký thêm hội viên vào lớp đã đầy, lớp ID 1: 20/20 (chk_class_enrollment_limit) | `23514` | PASS |
| TC-25 | BR-14 | Một hợp đồng đăng ký lại cùng một lớp sau khi hủy (uq_enrollment_subscription_class) | `23505` | PASS |
| TC-26 | BR-17 | Ca PT có giờ kết thúc bằng giờ bắt đầu (chk_pt_booking_time) | `23514` | PASS |
| TC-27 | BR-12 | Một HLV nhận 2 ca PT trùng giờ với 2 hội viên (ex_pt_trainer_no_overlap) | `23P01` | PASS |
| TC-28 | BR-16 | Một hội viên đặt 2 ca PT trùng giờ với 2 HLV (ex_pt_member_no_overlap) | `23P01` | PASS |
| TC-29 | BR-18 | Đặt ca PT bằng hợp đồng của hội viên khác (fk_booking_subscription_member) | `23503` | PASS |
| TC-30 | BR-18 | Hoàn thành ca PT khi hợp đồng đã hết buổi (trg_update_remaining_pt_sessions) | `P0001` | PASS |
| TC-31 | BR-25 | Trạng thái ca PT ngoài miền giá trị (chk_pt_booking_status) | `23514` | PASS |
| TC-32 | BR-26 | Thiết bị có thời gian khấu hao 0 tháng (chk_equipment_depreciation) | `23514` | PASS |
| TC-33 | BR-26 | Thiết bị trùng số serial (uq_equipment_serial) | `23505` | PASS |
| TC-34 | BR-19 | Giữ chỗ thiết bị đang bảo trì - cột status (trg_prevent_equipment_reservation_under_maintenance) | `P0001` | PASS |
| TC-35 | BR-21 | Lượt giữ chỗ gắn đồng thời cả ca PT và lớp học (chk_reservation_source) | `23514` | PASS |
| TC-36 | BR-21 | Lượt giữ chỗ không gắn với ca PT hay lớp học nào (chk_reservation_source) | `23514` | PASS |
| TC-37 | BR-20 | Nhật ký bảo trì có chi phí âm (chk_maintenance_cost) | `23514` | PASS |
| TC-38 | BR-20 | Nhật ký bảo trì hoàn thành trước khi bắt đầu (chk_maintenance_time) | `23514` | PASS |
| TC-39 | BR-20 | Giao việc bảo trì cho người không phải nhân viên, HLV ID 5 (fk_maintenance_staff) | `23503` | PASS |
| TP-01 | BR-03 | Hội viên đủ 18 tuổi được tạo hồ sơ thành công | `00000` | PASS |
| TP-02 | BR-18 | Hoàn thành ca PT tự động trừ đúng 1 buổi (hợp đồng ID 1: n -> n-1) | `00000` | PASS |
| TP-03 | BR-14 | Đăng ký lớp tự động tăng current_enrolled (lớp ID 2: 16 -> 17) | `00000` | PASS |
| TP-04 | BR-14 | Hủy đăng ký lớp tự động giảm current_enrolled (lớp ID 1: 20 -> 19) | `00000` | PASS |
| TP-05 | BR-12 | Ca PT đã hủy không chặn ca mới cùng khung giờ (exclusion có điều kiện) | `00000` | PASS |
| TP-06 | BR-15 | Hai lớp nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) không bị coi là trùng | `00000` | PASS |
| TP-07 | BR-09 | Hóa đơn hợp lệ ở chu kỳ tính phí mới được ghi nhận | `00000` | PASS |
| TC-40 | BR-05 | Hội viên đang Active có thêm hợp đồng Active thứ hai (uq_member_one_active_subscription) | `23505` | PASS |
| TC-41 | BR-07 | Tạo hợp đồng Active trực tiếp khi chưa có hóa đơn Completed (trg_require_payment_before_active) | `P0001` | PASS |
| TC-42 | BR-07 | Chuyển hợp đồng sang Active khi mới có hóa đơn Pending, chưa Completed (trg_require_payment_before_active) | `P0001` | PASS |
| TC-43 | BR-08 | Hai hóa đơn còn hiệu lực cho cùng một chu kỳ của một hợp đồng (uq_billing_subscription_period) | `23505` | PASS |
| TP-08 | BR-07 | Hợp đồng Pending + hóa đơn Completed -> tự động Active (trg_activate_on_payment_insert) | `00000` | PASS |
| TP-09 | BR-05 | Hợp đồng cũ chuyển Expired thì hội viên được kích hoạt hợp đồng mới (chỉ còn 1 Active) | `00000` | PASS |
| TP-10 | BR-08 | Hóa đơn Failed không chiếm chu kỳ: thanh toán lại (Completed) cùng chu kỳ được chấp nhận | `00000` | PASS |
| TP-11 | BR-08 | INSERT hóa đơn không nêu chu kỳ: trg_fill_billing_period_start điền ngày bắt đầu hợp đồng | `00000` | PASS |
| TC-44 | BR-10 | Sửa số tiền hóa đơn Completed có sẵn (trg_billing_immutable_update) | `P0001` | PASS |
| TC-45 | BR-10 | Xóa hóa đơn Completed có sẵn (trg_billing_immutable_delete) | `P0001` | PASS |
| TC-46 | BR-10 | TRUNCATE bảng billing_log (trg_billing_immutable_truncate) | `P0001` | PASS |
| TC-47 | BR-10 | Đổi hóa đơn Completed sang Failed - chỉ được sang Refunded (trg_billing_immutable_update) | `P0001` | PASS |
| TC-48 | BR-10 | Hóa đơn Pending bị đổi mã invoice_no (trg_billing_immutable_update) | `P0001` | PASS |
| TC-49 | BR-10 | Sửa hóa đơn đã ở trạng thái cuối Refunded (trg_billing_immutable_update) | `P0001` | PASS |
| TP-12 | BR-10 | Phiên kiểm thử chạy bằng superuser (chứng minh BR-10 không dựa vào phân quyền) | `00000` | PASS |
| TP-13 | BR-10 | Hóa đơn Completed chuyển sang Refunded được phép (hoàn tiền) | `00000` | PASS |
| TP-14 | BR-10 | Hóa đơn Pending chuyển sang Completed được phép và kích hoạt hợp đồng Pending | `00000` | PASS |
| TC-50 | BR-12 | HLV đã có ca PT, xếp thêm lớp nhóm trùng giờ cho chính HLV đó (trg_check_class_schedule_conflicts) | `23P01` | PASS |
| TC-51 | BR-12 | HLV đang đứng lớp nhóm, nhận thêm ca PT trùng giờ (trg_check_pt_booking_conflicts) | `23P01` | PASS |
| TC-52 | BR-16 | Hội viên đã đăng ký lớp nhóm, đặt thêm ca PT trùng giờ lớp đó (trg_check_pt_booking_conflicts) | `23P01` | PASS |
| TC-53 | BR-16 | Hội viên đã có ca PT, đăng ký lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts) | `23P01` | PASS |
| TC-54 | BR-16 | Hội viên đăng ký 2 lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts) | `23P01` | PASS |
| TC-55 | BR-16 | Đổi giờ lớp đã có người đăng ký sang giờ trùng ca PT của hội viên đó (trg_check_class_schedule_conflicts) | `23P01` | PASS |
| TC-68 | BR-16 | Đăng ký lần 2 cùng lớp khi đang Enrolled bị chặn bởi trigger BR-16 (trg_check_class_enrollment_conflicts) | `23P01` | PASS |
| TP-15 | BR-16 | Lớp nhóm và ca PT nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) của cùng hội viên được chấp nhận | `00000` | PASS |
| TC-56 | BR-18 | Đặt ca PT bằng hợp đồng chưa Active (Pending) (trg_check_pt_booking_creation) | `P0001` | PASS |
| TC-57 | BR-18 | Đặt ca PT sau ngày hết hạn hợp đồng (trg_check_pt_booking_creation) | `P0001` | PASS |
| TC-58 | BR-18 | Đặt ca PT trước ngày bắt đầu hợp đồng (trg_check_pt_booking_creation) | `P0001` | PASS |
| TC-59 | BR-18 | Số ca PT Scheduled vượt số buổi còn lại của hợp đồng (trg_check_pt_booking_creation) | `P0001` | PASS |
| TC-60 | BR-18 | Đặt ca PT bằng hợp đồng gói không có buổi PT (hợp đồng ID 2, 0 buổi) (trg_check_pt_booking_creation) | `P0001` | PASS |
| TP-16 | BR-18 | Còn đúng 1 buổi chưa đặt thì được đặt thêm 1 ca Scheduled | `00000` | PASS |
| TC-61 | BR-21 | Một thiết bị bị giữ chỗ trùng giờ cho 2 ca PT khác nhau (ex_reservation_equipment_no_overlap) | `23P01` | PASS |
| TC-62 | BR-21 | Giữ chỗ thiết bị trong lúc có ca bảo trì In_Progress chưa kết thúc (trg_check_reservation_window) | `23P01` | PASS |
| TC-63 | BR-21 | Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của ca PT gắn kèm (trg_check_reservation_window) | `P0001` | PASS |
| TC-64 | BR-21 | Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của lớp học gắn kèm (trg_check_reservation_window) | `P0001` | PASS |
| TP-17 | BR-21 | Giữ chỗ thiết bị nằm trọn trong khung giờ ca PT được chấp nhận | `00000` | PASS |
| TP-18 | BR-21 | Lượt giữ chỗ đã Cancelled không chiếm thiết bị: giữ chỗ mới cùng giờ được chấp nhận | `00000` | PASS |
| TP-19 | BR-21 | Ca bảo trì đã Completed không chặn giữ chỗ thiết bị | `00000` | PASS |
| TC-65 | BR-23 | Người thực hiện không tồn tại trong user_account (fk_booking_created_by) | `23503` | PASS |
| TP-20 | BR-23 | created_by_user_id tự điền từ SET LOCAL app.current_user_id cho 5 bảng giao dịch | `00000` | PASS |
| TP-21 | BR-23 | Giá trị created_by_user_id nêu rõ trong INSERT không bị trigger ghi đè | `00000` | PASS |
| TC-72 | BR-23 | INSERT khi chưa đặt app.current_user_id (và không nêu created_by_user_id) bị chặn | `P0001` | PASS |
| TC-73 | BR-23 | UPDATE khi chưa đặt app.current_user_id bị chặn (không có người sửa để ghi updated_by_user_id) | `P0001` | PASS |
| TC-74 | BR-23 | Không được đổi created_by_user_id sau khi đã ghi (vết người tạo bất biến) | `P0001` | PASS |
| TP-22 | BR-23 | UPDATE tự ghi updated_by_user_id (từ biến phiên, không tin giá trị truyền vào) và updated_at | `00000` | PASS |
| TP-35 | BR-23 | UPDATE nội bộ do trigger (BR-07 tự kích hoạt hợp đồng khi thanh toán) ghi người thao tác hiện tại vào updated_by_user_id | `00000` | PASS |
| TC-66 | BR-24 | Gọi thủ tục với số ngày ân hạn âm (sp_process_subscription_renewals) | `P0001` | PASS |
| TP-23 | BR-24 | Quá hạn: HĐ không tự gia hạn -> Expired; HĐ tự gia hạn -> hóa đơn Pending kỳ kế tiếp, vẫn Active trong ân… | `00000` | PASS |
| TP-24 | BR-24 | Gọi thủ tục nhiều lần trong ngày không phát sinh thêm hóa đơn gia hạn (idempotent) | `00000` | PASS |
| TP-25 | BR-24 | Quá thời gian ân hạn (3 ngày) mà chưa thanh toán -> hợp đồng tự gia hạn chuyển Suspended | `00000` | PASS |
| TP-26 | BR-24 | Thanh toán hóa đơn gia hạn: hợp đồng Suspended -> Active, end_time + duration_days, đặt lại số buổi PT | `00000` | PASS |
| TC-67 | BR-25 | Ngày đặt lịch booking_date khác ngày của start_time (chk_pt_booking_date) | `23514` | PASS |
| TP-27 | BR-25 | Hủy sớm (> 24 giờ): ca giữ trạng thái Cancelled và KHÔNG trừ buổi (trg_late_cancel_pt_booking) | `00000` | PASS |
| TP-28 | BR-25 | Hủy muộn (< 24 giờ): trigger đổi thành Late_Cancelled và trừ đúng 1 buổi | `00000` | PASS |
| TP-29 | BR-25 | Bỏ tập (No_Show) bị trừ đúng 1 buổi (trg_update_remaining_pt_sessions) | `00000` | PASS |
| TP-30 | BR-25 | Đổi Completed -> No_Show không bị trừ buổi lần thứ hai | `00000` | PASS |
| TC-69 | BR-19 | Chuyển phòng sang bảo trì khi còn lớp học tương lai (trg_prevent_room_maintenance_with_future_classes) | `P0001` | PASS |
| TC-70 | BR-19 | Chuyển thiết bị sang bảo trì khi còn lượt giữ chỗ Reserved tương lai (trg_prevent_equipment_maintenance_with_future_reservations) | `P0001` | PASS |
| TC-71 | BR-19 | Mở ca bảo trì In_Progress cho thiết bị còn lượt giữ chỗ tương lai bị chặn (chuỗi trg_start_equipment_maintenance_insert -> BR-19) | `P0001` | PASS |
| TP-31 | BR-19 | Phòng không còn lớp tương lai được chuyển sang bảo trì | `00000` | PASS |
| TP-32 | BR-19 | Chèn nhật ký bảo trì In_Progress tự chuyển thiết bị sang Under_Maintenance (trg_start_equipment_maintenance_insert) | `00000` | PASS |
| TP-33 | BR-19 | Hoàn tất ca bảo trì duy nhất tự đưa thiết bị về Operational (trg_finish_equipment_maintenance) | `00000` | PASS |
| TP-34 | BR-19 | Còn ca In_Progress khác thì hoàn tất 1 ca chưa đưa thiết bị về Operational; hoàn tất nốt mới về Operational | `00000` | PASS |
| TC-75 | BR-19 | Xếp lớp vào phòng ngừng sử dụng - Inactive (trg_prevent_class_in_maintenance_room) | `P0001` | PASS |
| TC-76 | BR-19 | Giữ chỗ thiết bị đã thanh lý - Decommissioned (trg_prevent_equipment_reservation_under_maintenance) | `P0001` | PASS |
| TC-77 | BR-19 | Chuyển phòng sang Inactive khi còn lớp học tương lai (trg_prevent_room_maintenance_with_future_classes) | `P0001` | PASS |
| TC-78 | BR-19 | Thanh lý thiết bị (Decommissioned) khi còn lượt giữ chỗ Reserved tương lai (trg_prevent_equipment_maintenance_with_future_reservations) | `P0001` | PASS |
| TP-36 | BR-19 | Thiết bị không còn lượt giữ chỗ tương lai được thanh lý (Decommissioned) | `00000` | PASS |

#### 5.1.3. Phạm vi và giới hạn

- Cả 26 quy tắc BR-01…BR-26 đều có test trực tiếp và được thực thi ở mức CSDL.
- Giới hạn còn lại: superuser là gốc tin cậy của BR-10 (chỉ vô hiệu hóa được bằng thao tác tường minh); BR-24 cần bộ lập lịch ngoài (Docker `scheduler`, production dùng `pg_cron`/cron) để tự kích hoạt theo thời gian; bảng `role_permission` và các lệnh `GRANT` vẫn duy trì thủ công ở hai nơi nhưng sai lệch được phát hiện tự động bởi test SY-01..SY-05 (chạy lại bộ test 09 sau khi đổi một trong hai nơi).
- Không dùng Row-Level Security (RLS) theo từng người vì tài khoản CSDL theo vai trò (đăng nhập demo dùng chung `gym_u_*`), không theo từng người nên CSDL không có định danh cá nhân để lọc; `gym_role_member` không đọc được dữ liệu cá nhân nào (chỉ gói tập, phòng, lịch lớp) nên không rò rỉ. RLS theo người cần mỗi người một tài khoản CSDL hoặc lớp xác thực tin cậy: đây là ranh giới phạm vi thiết kế, không phải lỗi.

### 5.2. Định nghĩa phân quyền theo vai trò – RBAC (GRANT/REVOKE)

#### 5.2.1. Thiết kế phân quyền

Hệ thống có hai tầng: **tầng dữ liệu ứng dụng** (`role`, `user_role`, `permission`, `role_permission`, mô hình RBAC đa vai trò M:N, BR-22) và **tầng CSDL** gồm 5 role nhóm PostgreSQL `NOLOGIN` (`gym_role_*`) cùng 5 tài khoản đăng nhập mẫu (`gym_u_*`, `LOGIN INHERIT`) thừa hưởng quyền của role nhóm. Mọi đối tượng ứng dụng thuộc role `NOLOGIN` `gym_owner` (không ai đăng nhập bằng role này).

Nguyên tắc đặc quyền tối thiểu (least privilege): thu hồi mọi quyền của `PUBLIC`, chỉ `GRANT` đúng những gì ma trận yêu cầu; cột nhạy cảm `user_account.password_hash` được bảo vệ bằng `GRANT` mức cột; script idempotent nên chạy lại an toàn.

*Bảng 5-3. Năm role nhóm và phạm vi quyền*

| Role nhóm | Tài khoản demo | Quyền ứng dụng | Phạm vi quyền ở mức CSDL |
| --- | --- | --- | --- |
| `gym_role_admin` | `gym_u_admin` | 1–10 | `SELECT/INSERT/UPDATE/DELETE` mọi bảng, **trừ**: `billing_log` chỉ `SELECT, INSERT` (BR-10); không `SELECT` được `password_hash`; không `TRUNCATE` |
| `gym_role_receptionist` | `gym_u_reception` | 1, 2, 3, 5, 6, 7 | Không `DELETE`; `UPDATE user_account` theo cột (không gồm `password_hash`); `INSERT` hóa đơn; gọi được `sp_process_subscription_renewals` |
| `gym_role_trainer` | `gym_u_trainer` | 1, 6, 7 | Chủ yếu `SELECT`; chỉ `UPDATE (status)` trên `pt_booking`, `class_enrollment`; chỉ đọc cột không nhạy cảm của `user_account`, `member_subscription` |
| `gym_role_technician` | `gym_u_tech` | 8, 9 | `SELECT/INSERT/UPDATE` trên `equipment`, `maintenance_log`; `UPDATE (status)` trên `facilities_room`; không đọc dữ liệu hội viên, hóa đơn |
| `gym_role_member` | `gym_u_member` | 1 | Chỉ `SELECT` danh mục công khai: `membership_plan`, `facilities_room`, `class_schedule` (cột công khai, ẩn `created_by_user_id`) |

#### 5.2.2. Ma trận quyền (role × bảng)

Ký hiệu: S = `SELECT`, I = `INSERT`, U = `UPDATE`, D = `DELETE`; `(...)` = chỉ trên các cột nêu; "x" = có quyền `EXECUTE`. Ma trận được sinh từ `has_table_privilege` / `has_column_privilege` trên CSDL đã phân quyền.

*Bảng 5-4. Ma trận quyền role × bảng/view*

| Bảng / View | Admin | Receptionist | Trainer | Technician | Member |
| --- | --- | --- | --- | --- | --- |
| billing_log | S, I | S, I | - | - | - |
| class_enrollment | S, I, U, D | S, I, U | S, U(status) | - | - |
| class_schedule | S, I, U, D | S, I, U | S | - | S(class_id, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled) |
| equipment | S, I, U, D | - | - | S, I, U | - |
| equipment_reservation | S, I, U, D | - | - | S | - |
| facilities_room | S, I, U, D | S | S | S, U(status) | S |
| maintenance_log | S, I, U, D | - | - | S, I, U | - |
| member_profile | S, I, U, D | S, I, U | S | - | - |
| member_subscription | S, I, U, D | S, I, U | S(subscription_id, member_user_id, plan_id, remaining_sessions, start_time, end_time, sub_status) | - | - |
| membership_plan | S, I, U, D | S | S | - | S |
| permission | S, I, U, D | - | - | - | - |
| pt_booking | S, I, U, D | S, I, U | S, U(status) | - | - |
| role | S, I, U, D | S | - | - | - |
| role_permission | S, I, U, D | - | - | - | - |
| staff_profile | S, I, U, D | - | - | S | - |
| trainer_profile | S, I, U, D | S | S | - | - |
| user_account | S(user_id, full_name, email, phone, dob, emergency_contact, status, created_at), I, U, D | S(user_id, full_name, email, phone, dob, emergency_contact, status, created_at), I, U(full_name, email, phone, dob, emergency_contact, status) | S(user_id, full_name, phone, emergency_contact) | - | - |
| user_role | S, I, U, D | I | - | - | - |
| vw_active_member_subscriptions | S | S | - | - | - |
| vw_trainer_schedule_overview | S | S | S | - | - |
| EXECUTE sp_process_subscription_renewals | x | x | - | - | - |

#### 5.2.3. Lệnh GRANT/REVOKE

Củng cố mặc định, tạo role nhóm và cấp quyền cho Admin (không sửa/xóa được hóa đơn, không đọc được `password_hash`):

```sql
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

CREATE ROLE gym_role_admin        NOLOGIN;
CREATE ROLE gym_role_receptionist NOLOGIN;
CREATE ROLE gym_role_trainer      NOLOGIN;
CREATE ROLE gym_role_technician   NOLOGIN;
CREATE ROLE gym_role_member       NOLOGIN;

GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gym_role_admin;
REVOKE UPDATE, DELETE ON billing_log FROM gym_role_admin;
REVOKE SELECT ON user_account FROM gym_role_admin;
GRANT SELECT (user_id, full_name, email, phone, dob, emergency_contact, status, created_at)
    ON user_account TO gym_role_admin;
```

Quyền hẹp theo trách nhiệm (mức cột), tài khoản đăng nhập mẫu (mật khẩu `demo_2026` chỉ để trình diễn) và quyền gọi thủ tục gia hạn:

```sql
-- Lễ tân: UPDATE mức cột, loại trừ password_hash
GRANT UPDATE (full_name, email, phone, dob, emergency_contact, status)
    ON user_account TO gym_role_receptionist;
GRANT SELECT, INSERT ON billing_log TO gym_role_receptionist;

-- Huấn luyện viên: chỉ được đổi trạng thái ca PT / điểm danh
GRANT SELECT (user_id, full_name, phone, emergency_contact)
    ON user_account TO gym_role_trainer;
GRANT UPDATE (status) ON pt_booking TO gym_role_trainer;
GRANT UPDATE (status) ON class_enrollment TO gym_role_trainer;

-- Kỹ thuật viên
GRANT SELECT, INSERT, UPDATE ON equipment, maintenance_log TO gym_role_technician;
GRANT UPDATE (status) ON facilities_room TO gym_role_technician;

-- Hội viên: không cấp created_by_user_id (BR-23)
GRANT SELECT (class_id, trainer_user_id, room_id, class_name, start_time, end_time,
              max_capacity, current_enrolled)
    ON class_schedule TO gym_role_member;

-- Tài khoản đăng nhập thừa hưởng quyền role nhóm
CREATE ROLE gym_u_trainer LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_trainer;

REVOKE EXECUTE ON PROCEDURE sp_process_subscription_renewals(DATE, INT) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE sp_process_subscription_renewals(DATE, INT)
    TO gym_role_admin, gym_role_receptionist;
```

Bảo vệ `billing_log` (BR-10, lớp 3 và 4): chủ sở hữu duy nhất `gym_owner` (`NOLOGIN`, không phải superuser) nên không tài khoản đăng nhập nào `ALTER`/`DROP` được bảng; event trigger chặn cả superuser:

```sql
CREATE EVENT TRIGGER evt_protect_billing_log ON ddl_command_end
    WHEN TAG IN ('ALTER TABLE', 'ALTER TRIGGER', 'ALTER FUNCTION', 'CREATE FUNCTION')
    EXECUTE FUNCTION fn_evt_protect_billing_log();

CREATE EVENT TRIGGER evt_protect_billing_log_drop ON sql_drop
    WHEN TAG IN ('DROP TABLE', 'DROP TRIGGER', 'DROP FUNCTION')
    EXECUTE FUNCTION fn_evt_protect_billing_log();
```

#### 5.2.4. Hàm SECURITY DEFINER

Hàm trigger mặc định chạy với quyền của người kích hoạt: khi huấn luyện viên đặt `pt_booking.status = 'Completed'`, trigger trừ buổi phải `UPDATE member_subscription`, bảng mà huấn luyện viên không được ghi; tương tự khi lễ tân thêm `class_enrollment` thì trigger cập nhật `class_schedule.current_enrolled`. Nếu không có `SECURITY DEFINER`, các thao tác hợp lệ này bị từ chối với `42501`, còn cấp thêm quyền ghi cho role sẽ phá vỡ nguyên tắc đặc quyền tối thiểu. Vì vậy mọi hàm trigger chạy bằng quyền chủ sở hữu hàm, kèm `SET search_path = public, pg_temp` cố định để chống chiếm quyền qua `search_path` (NFR-SEC-05). Thủ tục `sp_process_subscription_renewals` chạy với quyền người gọi (`SECURITY INVOKER`) nên chỉ Admin và Lễ tân mới gọi được.

#### 5.2.5. Kết quả kiểm thử phân quyền

Bộ test chạy bằng superuser nhưng chuyển sang từng role bằng `SET LOCAL ROLE` (tự hoàn tác cùng savepoint), trong giao dịch rồi `ROLLBACK`. Thao tác bị cấm phải nhận `42501` (insufficient_privilege); thao tác hợp lệ phải thành công (`00000`), kể cả khi đi qua chuỗi trigger `SECURITY DEFINER`. **Kết quả: 66/66 test PASS.** Mã test: `RA/TA/EA/MA/AA` = thao tác được phép; `RD/TD/ED/MD/AD` = thao tác bị từ chối; `LA/LD` = tài khoản đăng nhập thừa hưởng quyền; `EV-01..EV-13` = event trigger và quyền sở hữu bảo vệ BR-10; `SY-01..SY-05` = ma trận quyền ứng dụng (`role_permission`) của từng vai trò khớp `GRANT` của role CSDL tương ứng, kiểm tra hai chiều (BR-22).

*Bảng 5-5. Danh sách 66 test case phân quyền (SQLSTATE mong đợi trùng SQLSTATE thực tế ở mọi test)*

| Mã | Vai trò | Kịch bản | SQLSTATE | KQ |
| --- | --- | --- | --- | --- |
| RA-01 | gym_role_receptionist | Tạo tài khoản hội viên mới kèm hồ sơ member_profile | `00000` | PASS |
| RA-02 | gym_role_receptionist | Đọc thông tin hội viên (không gồm password_hash) | `00000` | PASS |
| RD-01 | gym_role_receptionist | Đọc cột password_hash của user_account | `42501` | PASS |
| RD-02 | gym_role_receptionist | SELECT * trên user_account (bao gồm password_hash) | `42501` | PASS |
| RD-03 | gym_role_receptionist | UPDATE hóa đơn billing_log (BR-10) | `42501` | PASS |
| RD-04 | gym_role_receptionist | DELETE hóa đơn billing_log (BR-10) | `42501` | PASS |
| RD-05 | gym_role_receptionist | DELETE hợp đồng member_subscription | `42501` | PASS |
| RD-06 | gym_role_receptionist | UPDATE giá gói tập membership_plan (thuộc quyền Admin) | `42501` | PASS |
| RA-03 | gym_role_receptionist | Thêm đăng ký lớp: trigger SECURITY DEFINER cập nhật current_enrolled (lớp ID 2: 16 -> 17) | `00000` | PASS |
| RA-04 | gym_role_receptionist | Ghi nhận hóa đơn thanh toán mới vào billing_log | `00000` | PASS |
| RA-05 | gym_role_receptionist | Gọi thủ tục sp_process_subscription_renewals (BR-24): phát hành hóa đơn gia hạn Pending | `00000` | PASS |
| RA-06 | gym_role_receptionist | Tạo hợp đồng Pending + hóa đơn Completed: chuỗi trigger tự kích hoạt Active (BR-07) và điền created_by_user_id (BR-23) | `00000` | PASS |
| RD-07 | gym_role_receptionist | Ghi đè billing_log.created_by_user_id (BR-10: UPDATE hóa đơn bị cấm) | `42501` | PASS |
| TA-01 | gym_role_trainer | Đánh dấu ca PT Completed: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | `00000` | PASS |
| TA-02 | gym_role_trainer | Đánh dấu ca PT No_Show: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | `00000` | PASS |
| TA-03 | gym_role_trainer | Hủy ca PT < 24h: trigger đổi Cancelled thành Late_Cancelled và trừ 1 buổi (BR-25) | `00000` | PASS |
| TA-04 | gym_role_trainer | Điểm danh lớp học: đổi class_enrollment.status sang Attended | `00000` | PASS |
| TA-05 | gym_role_trainer | Đọc khung nhìn vw_trainer_schedule_overview | `00000` | PASS |
| TD-01 | gym_role_trainer | Đổi HLV phụ trách pt_booking.trainer_user_id | `42501` | PASS |
| TD-02 | gym_role_trainer | Đọc billing_log | `42501` | PASS |
| TD-03 | gym_role_trainer | Đọc user_account.email của hội viên | `42501` | PASS |
| TD-04 | gym_role_trainer | Đọc member_subscription.actual_price (cột giá tiền) | `42501` | PASS |
| TD-05 | gym_role_trainer | Sửa trực tiếp số buổi member_subscription.remaining_sessions | `42501` | PASS |
| TD-06 | gym_role_trainer | Tạo lịch lớp học mới (INSERT class_schedule) | `42501` | PASS |
| TD-07 | gym_role_trainer | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | `42501` | PASS |
| EA-01 | gym_role_technician | Ghi nhật ký bảo trì mới vào maintenance_log | `00000` | PASS |
| EA-02 | gym_role_technician | Cập nhật equipment.status sang Under_Maintenance | `00000` | PASS |
| EA-03 | gym_role_technician | Quy trình BR-19: mở ca bảo trì In_Progress rồi hoàn tất, trigger tự đổi trạng thái thiết bị (Under_Maintenance -> Operational) dù… | `00000` | PASS |
| ED-01 | gym_role_technician | Đọc billing_log | `42501` | PASS |
| ED-02 | gym_role_technician | Đọc user_account | `42501` | PASS |
| ED-03 | gym_role_technician | Đọc member_subscription | `42501` | PASS |
| ED-04 | gym_role_technician | Xóa thiết bị (DELETE equipment) | `42501` | PASS |
| ED-05 | gym_role_technician | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | `42501` | PASS |
| MA-01 | gym_role_member | Xem lịch lớp học nhóm class_schedule | `00000` | PASS |
| MD-01 | gym_role_member | Đọc user_account | `42501` | PASS |
| MD-02 | gym_role_member | Tự đặt ca PT (INSERT pt_booking) | `42501` | PASS |
| MD-03 | gym_role_member | Đọc billing_log | `42501` | PASS |
| MD-04 | gym_role_member | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | `42501` | PASS |
| MD-05 | gym_role_member | Đọc class_schedule.created_by_user_id (cột nội bộ, BR-23) | `42501` | PASS |
| AA-01 | gym_role_admin | Điều chỉnh giá gói tập membership_plan | `00000` | PASS |
| AA-02 | gym_role_admin | Tạo tài khoản mới và đặt password_hash (INSERT cột nhạy cảm) | `00000` | PASS |
| AA-03 | gym_role_admin | Gọi thủ tục sp_process_subscription_renewals (BR-24) | `00000` | PASS |
| AD-01 | gym_role_admin | UPDATE hóa đơn billing_log (BR-10, kể cả Admin) | `42501` | PASS |
| AD-02 | gym_role_admin | DELETE hóa đơn billing_log (BR-10, kể cả Admin) | `42501` | PASS |
| AD-03 | gym_role_admin | TRUNCATE billing_log (không thể vượt rào DELETE) | `42501` | PASS |
| AD-04 | gym_role_admin | Đọc cột password_hash của user_account | `42501` | PASS |
| LD-01 | gym_u_trainer | Tài khoản gym_u_trainer thừa hưởng: không đọc được billing_log | `42501` | PASS |
| LA-01 | gym_u_tech | Tài khoản gym_u_tech thừa hưởng: đọc được equipment | `00000` | PASS |
| EV-01 | superuser | Superuser ALTER TABLE billing_log DISABLE TRIGGER USER bị event trigger chặn | `P0001` | PASS |
| EV-02 | superuser | Superuser DROP TRIGGER trg_billing_immutable_delete ON billing_log bị chặn | `P0001` | PASS |
| EV-03 | superuser | Superuser DROP TABLE billing_log CASCADE bị chặn | `P0001` | PASS |
| EV-04 | superuser | Superuser thay ruột hàm trigger bất biến (CREATE OR REPLACE FUNCTION) bị chặn | `P0001` | PASS |
| EV-05 | superuser | Superuser đổi tên trigger bất biến (ALTER TRIGGER ... RENAME) bị chặn | `P0001` | PASS |
| EV-06 | superuser | Lối thoát bảo trì: superuser đặt app.allow_billing_maintenance = on rồi DISABLE/DROP TRIGGER được phép | `00000` | PASS |
| EV-07 | gym_u_admin | gym_u_admin ALTER TABLE billing_log (kể cả khi đặt lối thoát) -> 42501 không phải chủ sở hữu | `42501` | PASS |
| EV-08 | gym_role_admin | gym_role_admin DROP TRIGGER trg_billing_immutable_update ON billing_log -> 42501 | `42501` | PASS |
| EV-09 | gym_role_admin | gym_role_admin DROP TABLE billing_log -> 42501 | `42501` | PASS |
| EV-10 | gym_role_admin | gym_role_admin ALTER TABLE billing_log DISABLE TRIGGER ALL -> 42501 | `42501` | PASS |
| EV-11 | superuser | Mọi bảng, view, sequence, hàm, thủ tục trong schema public đều thuộc gym_owner | `00000` | PASS |
| EV-12 | superuser | gym_owner NOLOGIN, không phải superuser; không gym_u_*/gym_role_* nào là thành viên của gym_owner | `00000` | PASS |
| EV-13 | superuser | Event trigger evt_protect_billing_log (ddl_command_end) và _drop (sql_drop) đang bật | `00000` | PASS |
| SY-01 | superuser | Ma trận quyền ứng dụng của Admin khớp GRANT của gym_role_admin (BR-22) | `00000` | PASS |
| SY-02 | superuser | Ma trận quyền ứng dụng của Receptionist khớp GRANT của gym_role_receptionist (BR-22) | `00000` | PASS |
| SY-03 | superuser | Ma trận quyền ứng dụng của Trainer khớp GRANT của gym_role_trainer (BR-22) | `00000` | PASS |
| SY-04 | superuser | Ma trận quyền ứng dụng của Technician khớp GRANT của gym_role_technician (BR-22) | `00000` | PASS |
| SY-05 | superuser | Ma trận quyền ứng dụng của Member khớp GRANT của gym_role_member (BR-22) | `00000` | PASS |

Lưu ý về mức độ thực thi:

- BR-10 được bảo vệ bốn lớp: trigger bất biến (`trg_billing_immutable_update/_delete/_truncate`), chỉ cấp `SELECT, INSERT` trên `billing_log` kể cả cho Admin, chủ sở hữu `gym_owner` không đăng nhập được, và event trigger `evt_protect_billing_log`. Giới hạn cố hữu: superuser vẫn bảo trì được bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`, thao tác này phải tường minh.
- Đã thực thi trong bản demo: TLS bắt buộc cho kết nối mạng (NFR-SEC-03) và sao lưu mã hóa tự động kèm kiểm tra khôi phục (NFR-AVL-01): `pg_dump` hằng ngày, lưu trữ WAL liên tục và `pg_basebackup` cho khôi phục theo thời điểm; `verify-restore.sh` và `verify-pitr.sh` đều ĐẠT. Còn lại: mã hóa tệp dữ liệu trên đĩa máy chủ (hạ tầng: LUKS/mã hóa đĩa đám mây).
- Mật khẩu mẫu `demo_2026` của các tài khoản `gym_u_*` chỉ để trình diễn và phải đổi khi triển khai thật.
