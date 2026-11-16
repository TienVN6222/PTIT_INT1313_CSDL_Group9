HỌC VIỆN CÔNG NGHỆ BƯU CHÍNH VIỄN THÔNG – CƠ SỞ TP. HỒ CHÍ MINH

# BÁO CÁO ĐỒ ÁN MÔN HỌC: CƠ SỞ DỮ LIỆU (INT1313)

Hệ thống Quản lý Hội viên & Lập kế hoạch Huấn luyện viên cá nhân

(Gym Membership & Personal Training Planner)

Học kỳ 1, năm học 2026 – 2027  |  Đề tài số 09  |  Nhóm G9  |  PostgreSQL 16

## A. Thông tin đề tài (Project Identity)

| Hạng mục | Nội dung |
| --- | --- |
| **Mã & tên đề tài (Project ID & Title)** | #09 – Gym Membership & Personal Training Planner |
| **Tên nhóm (Team Name)** | G9 |
| **Thành viên (Team Members)** | 1. Lê Hoàng Tiến (n25dcat050@student.ptithcm.edu.vn)<br>2. Lê Hòa Thuận (n25dcat110@student.ptithcm.edu.vn)<br>3. Trần Minh Tiến (n25dcat111@student.ptithcm.edu.vn) |
| **Tên đồ án (Project Title)** | Hệ thống Quản lý Hội viên & Lập kế hoạch Huấn luyện viên cá nhân (Gym Membership & PT Planner) |
| **Học phần** | Cơ sở dữ liệu (INT1313), Học kỳ 1, 2026 – 2027 |
| **Hệ quản trị CSDL** | PostgreSQL 16 (Docker image `postgres:16-alpine`); ứng dụng minh họa Streamlit |
| **Thời điểm hoàn thành báo cáo** | Tháng 11/2026 |

## B. Cấu trúc báo cáo (Report Structure)

1. **Giới thiệu & Phạm vi dự án (ISO/IEC/IEEE 29148)**
  - 1.1 Mục tiêu hệ thống (yêu cầu người dùng, yêu cầu hệ thống FR/NFR)
  - 1.2 Quy tắc nghiệp vụ & ràng buộc (BR-01 … BR-26)
2. **Thiết kế cơ sở dữ liệu (ISO/IEC 19505 / IE Crow's Foot)**
  - 2.1 Mô hình khái niệm (sơ đồ EER, sơ đồ vật lý Crow's Foot)
  - 2.2 Ánh xạ lược đồ logic
  - 2.3 Kiểm tra chuẩn hóa (chứng minh hình thức 1NF → 3NF/BCNF)
3. **Từ điển dữ liệu (ISO/IEC 11179)**
  - 18 bảng, 5 phân hệ
4. **Triển khai cơ sở dữ liệu (SQLStyle.guide)**
  - 4.1 Script DDL (bảng, view, chỉ mục, trigger)
  - 4.2 Truy vấn nâng cao & kiểm thử hiệu năng
5. **Kiểm thử & bảo mật**
  - 5.1 Test case chứng minh ràng buộc chặn dữ liệu sai
  - 5.2 Phân quyền theo vai trò (RBAC: GRANT/REVOKE)
- **Phụ lục A:** Mapping Appendix (EER → lược đồ quan hệ theo thuật toán Elmasri & Navathe); **Phụ lục B:** hướng dẫn chạy dự án; **Phụ lục C:** tài liệu tham khảo.
## Mục lục

- [A. Thông tin đề tài (Project Identity)](#a-thông-tin-đề-tài-project-identity)
- [B. Cấu trúc báo cáo (Report Structure)](#b-cấu-trúc-báo-cáo-report-structure)
- [1. Giới thiệu & Phạm vi dự án (Introduction & Project Scope – ISO/IEC/IEEE 29148)](#1-giới-thiệu--phạm-vi-dự-án-introduction--project-scope--isoiecieee-29148)
  - [1.1. Mục tiêu hệ thống (System Objective)](#11-mục-tiêu-hệ-thống-system-objective)
  - [1.2. Quy tắc nghiệp vụ & ràng buộc (Business Rules & Constraints)](#12-quy-tắc-nghiệp-vụ--ràng-buộc-business-rules--constraints)
- [2. Thiết kế cơ sở dữ liệu (Database Design – ISO/IEC 19505 / IE Standards)](#2-thiết-kế-cơ-sở-dữ-liệu-database-design--isoiec-19505--ie-standards)
  - [2.1. Mô hình Quan niệm – Sơ đồ ER/EER (Conceptual Model – ER/EER Diagram)](#21-mô-hình-quan-niệm--sơ-đồ-ereer-conceptual-model--ereer-diagram)
  - [2.2. Ánh xạ Lược đồ Logic (Logical Schema Mapping)](#22-ánh-xạ-lược-đồ-logic-logical-schema-mapping)
  - [2.3. Chứng minh Chuẩn hóa Dữ liệu (Normalization Verification: 1NF -> 3NF/BCNF)](#23-chứng-minh-chuẩn-hóa-dữ-liệu-normalization-verification-1nf---3nfbcnf)
- [3. Từ điển dữ liệu (Data Dictionary – ISO/IEC 11179)](#3-từ-điển-dữ-liệu-data-dictionary--isoiec-11179)
  - [3.1. Phân hệ 1: Quản lý người dùng & phân quyền RBAC (5 bảng)](#31-phân-hệ-1-quản-lý-người-dùng--phân-quyền-rbac-5-bảng)
  - [3.2. Phân hệ 2: Hồ sơ chuyên biệt – các lớp con EER (3 bảng)](#32-phân-hệ-2-hồ-sơ-chuyên-biệt--các-lớp-con-eer-3-bảng)
  - [3.3. Phân hệ 3: Gói tập & thanh toán (3 bảng)](#33-phân-hệ-3-gói-tập--thanh-toán-3-bảng)
  - [3.4. Phân hệ 4: Lịch tập & đặt chỗ (4 bảng)](#34-phân-hệ-4-lịch-tập--đặt-chỗ-4-bảng)
  - [3.5. Phân hệ 5: Thiết bị & bảo trì (3 bảng)](#35-phân-hệ-5-thiết-bị--bảo-trì-3-bảng)
- [4. Triển khai cơ sở dữ liệu (Database Implementation – SQLStyle.guide)](#4-triển-khai-cơ-sở-dữ-liệu-database-implementation--sqlstyleguide)
  - [4.1. Script DDL: bảng, ràng buộc, chỉ mục, trigger, view (DDL Script)](#41-script-ddl-bảng-ràng-buộc-chỉ-mục-trigger-view-ddl-script)
  - [4.2. Truy vấn nâng cao & kiểm thử hiệu năng (Advanced Queries & Performance Test Cases)](#42-truy-vấn-nâng-cao--kiểm-thử-hiệu-năng-advanced-queries--performance-test-cases)
- [5. Kiểm thử & bảo mật (Verification & Security)](#5-kiểm-thử--bảo-mật-verification--security)
  - [5.1. Test case chứng minh ràng buộc ngăn chặn dữ liệu sai (Constraint Test Cases)](#51-test-case-chứng-minh-ràng-buộc-ngăn-chặn-dữ-liệu-sai-constraint-test-cases)
  - [5.2. Phân quyền theo vai trò – RBAC (GRANT/REVOKE)](#52-phân-quyền-theo-vai-trò--rbac-grantrevoke)
- [Phụ lục A. Mapping Appendix: ánh xạ EER → lược đồ quan hệ theo thuật toán Elmasri & Navathe](#phụ-lục-a-mapping-appendix-ánh-xạ-eer--lược-đồ-quan-hệ-theo-thuật-toán-elmasri--navathe)
  - [Bước 1. Ánh xạ kiểu thực thể thông thường (regular entity)](#bước-1-ánh-xạ-kiểu-thực-thể-thông-thường-regular-entity)
  - [Bước 2. Ánh xạ thực thể yếu (weak entity)](#bước-2-ánh-xạ-thực-thể-yếu-weak-entity)
  - [Bước 3. Ánh xạ quan hệ 1:1](#bước-3-ánh-xạ-quan-hệ-11)
  - [Bước 4. Ánh xạ quan hệ 1:N (thêm khóa ngoại về phía N)](#bước-4-ánh-xạ-quan-hệ-1n-thêm-khóa-ngoại-về-phía-n)
  - [Bước 5. Ánh xạ quan hệ M:N (quan hệ riêng / bảng trung gian)](#bước-5-ánh-xạ-quan-hệ-mn-quan-hệ-riêng--bảng-trung-gian)
  - [Bước 6. Ánh xạ thuộc tính đa trị (multivalued)](#bước-6-ánh-xạ-thuộc-tính-đa-trị-multivalued)
  - [Bước 7. Ánh xạ quan hệ n-ngôi (n > 2)](#bước-7-ánh-xạ-quan-hệ-n-ngôi-n--2)
  - [Bước 8. Ánh xạ chuyên biệt hóa / tổng quát hóa](#bước-8-ánh-xạ-chuyên-biệt-hóa--tổng-quát-hóa)
  - [Bước 9. Ánh xạ phạm trù / hợp (category, union type)](#bước-9-ánh-xạ-phạm-trù--hợp-category-union-type)
  - [Checklist: đủ 18 bảng vật lý](#checklist-đủ-18-bảng-vật-lý)
- [Phụ lục B. Hướng dẫn chạy dự án (How to run)](#phụ-lục-b-hướng-dẫn-chạy-dự-án-how-to-run)
  - [B.1. Khởi động toàn bộ hệ thống](#b1-khởi-động-toàn-bộ-hệ-thống)
  - [B.2. Chạy các script truy vấn và kiểm thử](#b2-chạy-các-script-truy-vấn-và-kiểm-thử)
  - [B.3. Tài khoản demo và gọi thủ tục gia hạn](#b3-tài-khoản-demo-và-gọi-thủ-tục-gia-hạn)
  - [B.4. Dọn dẹp](#b4-dọn-dẹp)
  - [B.5. Cấu trúc thư mục repository](#b5-cấu-trúc-thư-mục-repository)
- [Phụ lục C. Tài liệu và chuẩn tham chiếu](#phụ-lục-c-tài-liệu-và-chuẩn-tham-chiếu)

## 1. Giới thiệu & Phạm vi dự án (Introduction & Project Scope – ISO/IEC/IEEE 29148)

Chương này trình bày mục tiêu, phạm vi, yêu cầu và quy tắc nghiệp vụ của hệ thống theo cấu trúc của đặc tả yêu cầu phần mềm ISO/IEC/IEEE 29148 đã được điều chỉnh cho phạm vi một dự án cơ sở dữ liệu: **yêu cầu người dùng** (UR, mô tả nhu cầu bằng ngôn ngữ nghiệp vụ) được tách riêng khỏi **yêu cầu hệ thống** (FR/NFR, mô tả dữ liệu và hành vi của hệ thống), và **quy tắc nghiệp vụ** (BR) được liệt kê tường minh kèm cơ chế thực thi. Bản đầy đủ của đặc tả nằm ở `Phase 1/requirements_specification.md`.

### 1.1. Mục tiêu hệ thống (System Objective)

#### 1.1.1. Tổng quan

**Gym Membership & Personal Training Planner** là dự án cơ sở dữ liệu quan hệ nhằm quản lý hoạt động của phòng tập thể hình trên một nền tảng thống nhất.

Hệ thống tập trung vào quản lý tài khoản và hồ sơ hội viên, gói tập và đăng ký hội viên, lịch lớp học nhóm, lịch huấn luyện cá nhân (Personal Training – PT), thiết bị phòng tập, bảo trì thiết bị, hóa đơn và thanh toán. Hệ thống bảo đảm tính toàn vẹn dữ liệu bằng ràng buộc, trigger và thủ tục ở mức CSDL, và phân quyền truy cập theo vai trò bằng 5 role PostgreSQL (`gym_role_*`).

Yêu cầu chi tiết xem requirements_specification.md (yêu cầu người dùng UR, yêu cầu chức năng FR, phi chức năng NFR, ma trận truy vết); quy tắc nghiệp vụ và cơ chế thực thi xem business_rules.md.

Dự án được thiết kế để hỗ trợ lưu trữ và quản lý dữ liệu có cấu trúc, hạn chế xung đột lịch, theo dõi trạng thái giao dịch và giữ lại lịch sử cần thiết cho việc kiểm tra, đối soát.

#### 1.1.2. Mục tiêu

Dự án hướng đến các mục tiêu sau:

1. Quản lý tập trung tài khoản người dùng và hồ sơ tương ứng với các vai trò trong phòng tập.
2. Quản lý gói hội viên, thời hạn đăng ký và trạng thái sử dụng dịch vụ.
3. Theo dõi thông tin thanh toán và lịch sử giao dịch liên quan đến dịch vụ phòng tập.
4. Quản lý lịch lớp học nhóm và việc đăng ký tham gia của hội viên.
5. Hạn chế việc một huấn luyện viên cá nhân bị đặt lịch trùng trong cùng khoảng thời gian.
6. Quản lý danh mục thiết bị, lịch đặt hoặc sử dụng thiết bị và thông tin bảo trì.
7. Hạn chế việc đặt lịch vào thời gian tài nguyên không sẵn sàng.
8. Áp dụng khóa chính, khóa ngoại, ràng buộc duy nhất, ràng buộc kiểm tra và cơ chế kiểm soát ở cơ sở dữ liệu khi phù hợp.
9. Phân quyền theo vai trò và nguyên tắc chỉ cấp quyền tối thiểu cần thiết.
10. Duy trì tính nhất quán của dữ liệu và lưu giữ lịch sử nghiệp vụ cần thiết.

#### 1.1.3. Mô hình dữ liệu cốt lõi

Mô hình dữ liệu logic của dự án gồm 18 bảng, được định nghĩa trong `Phase 3/01_schema_ddl.sql`, xoay quanh các nhóm thực thể sau.

*Bảng 1-1. Các thực thể (18 bảng) của hệ thống*

| Thực thể | Trách nhiệm |
| --- | --- |
| `USER_ACCOUNT` | Lưu thông tin tài khoản người dùng |
| `ROLE` | Danh mục vai trò trong hệ thống |
| `USER_ROLE` | Liên kết tài khoản với vai trò |
| `PERMISSION` | Danh mục quyền thao tác |
| `ROLE_PERMISSION` | Liên kết vai trò với quyền |
| `MEMBER_PROFILE` | Lưu hồ sơ hội viên |
| `TRAINER_PROFILE` | Lưu hồ sơ và chuyên môn huấn luyện viên |
| `STAFF_PROFILE` | Lưu hồ sơ nhân viên |
| `MEMBERSHIP_PLAN` | Danh mục gói hội viên hoặc gói dịch vụ |
| `MEMBER_SUBSCRIPTION` | Thông tin đăng ký gói và thời hạn sử dụng |
| `CLASS_SCHEDULE` | Lịch tổ chức lớp tập nhóm |
| `CLASS_ENROLLMENT` | Đăng ký tham gia lớp của hội viên |
| `PT_BOOKING` | Lịch đặt buổi huấn luyện cá nhân |
| `EQUIPMENT` | Danh mục thiết bị phòng tập |
| `EQUIPMENT_RESERVATION` | Thông tin đặt hoặc sử dụng thiết bị |
| `MAINTENANCE_LOG` | Lịch sử bảo trì, sửa chữa thiết bị |
| `BILLING_LOG` | Hóa đơn/thanh toán bất biến: khoản phải thu, trạng thái thanh toán, chu kỳ tính phí |
| `FACILITIES_ROOM` | Danh mục phòng tập / khu vực |

#### 1.1.4. Phạm vi thực hiện

##### Quản lý tài khoản và hồ sơ người dùng

- Lưu thông tin tài khoản, thông tin liên hệ và trạng thái tài khoản.
- Hỗ trợ các nhóm người dùng như quản trị viên, nhân viên, huấn luyện viên và hội viên theo thiết kế dữ liệu.
- Liên kết tài khoản với vai trò và hồ sơ chuyên biệt tương ứng.
- Kiểm soát quyền truy cập theo vai trò và nhiệm vụ.
- Hạn chế xóa dữ liệu có liên quan đến giao dịch hoặc lịch sử nghiệp vụ khi việc xóa có thể làm mất tính toàn vẹn dữ liệu.

##### Quản lý gói hội viên và đăng ký dịch vụ

- Quản lý danh mục gói tập, thông tin thời hạn, giá và quyền lợi được mô tả trong dữ liệu dự án.
- Ghi nhận hội viên đăng ký gói, ngày bắt đầu, ngày kết thúc và trạng thái đăng ký.
- Liên kết đăng ký dịch vụ với hội viên và gói tương ứng bằng các khóa quan hệ.
- Kiểm tra trạng thái đăng ký khi xử lý nghiệp vụ liên quan: hợp đồng chỉ `Active` sau khi thanh toán (BR-07), mỗi hội viên tối đa một hợp đồng `Active` (BR-05), tự gia hạn và tạm ngưng sau ân hạn (BR-24, thủ tục `sp_process_subscription_renewals`).

##### Quản lý lịch lớp học nhóm

- Lưu lịch lớp, thời gian tổ chức và các thông tin cần thiết của lớp.
- Ghi nhận việc hội viên đăng ký tham gia lớp.
- Kiểm soát số lượng đăng ký theo sức chứa lớp (`max_capacity`, `current_enrolled`, BR-14).
- Ngăn đăng ký trùng lặp của cùng một hợp đồng cho cùng một lớp (`uq_enrollment_subscription_class`).
- Quản lý trạng thái lịch học và đăng ký theo các giá trị được quy định trong DDL.

##### Quản lý lịch huấn luyện cá nhân (PT)

- Lưu thông tin đặt buổi tập giữa hội viên và huấn luyện viên.
- Ghi nhận ngày tập, giờ bắt đầu, giờ kết thúc và trạng thái buổi tập theo cấu trúc dữ liệu.
- Kiểm tra tính hợp lệ của khoảng thời gian đặt lịch.
- Ngăn các lịch PT đang có hiệu lực bị chồng lấn đối với cùng một huấn luyện viên.
- Ngăn một hội viên có nhiều buổi PT hoặc lớp bị chồng lấn (BR-16).
- Ca PT diễn ra ở khu tập tự do, không gắn phòng; chỉ ca đặt khi hợp đồng `Active` còn buổi (BR-18); buổi tập bị trừ khi hoàn thành, bỏ tập hoặc hủy muộn dưới 24 giờ (BR-25).
- Theo dõi trạng thái buổi tập theo các giá trị được định nghĩa trong hệ thống.

##### Quản lý thiết bị và bảo trì

- Quản lý danh mục thiết bị, thông tin nhận dạng và trạng thái sử dụng.
- Ghi nhận việc giữ chỗ thiết bị cho ca PT hoặc lớp (`equipment_reservation`), không cho trùng giờ (BR-21).
- Lưu lịch sử bảo trì, sửa chữa, thời gian thực hiện và chi phí (BR-20).
- Hạn chế đặt hoặc sử dụng thiết bị trong thời gian thiết bị đang bảo trì hoặc không khả dụng.
- Duy trì liên kết giữa hồ sơ thiết bị và các bản ghi bảo trì để phục vụ tra cứu lịch sử.

##### Quản lý hóa đơn và thanh toán

- Lưu thông tin khoản phí phát sinh từ việc đăng ký gói hoặc sử dụng dịch vụ theo phạm vi của cơ sở dữ liệu.
- Ghi nhận số tiền, ngày thanh toán, phương thức, trạng thái và chu kỳ tính phí của hóa đơn (BR-08, BR-09); hóa đơn bất biến (BR-10).
- Liên kết hóa đơn với hợp đồng bằng khóa ngoại `fk_billing_subscription`.
- Kiểm tra giá trị tiền tệ hợp lệ (`amount > 0`).
- Bảo đảm trạng thái thanh toán nhất quán với trạng thái hợp đồng bằng trigger `trg_activate_on_payment_*`.

##### Bảo mật và phân quyền truy cập

- Xác định 5 vai trò: Admin, Receptionist, Trainer, Technician, Member.
- Gán quyền thao tác theo vai trò qua các bảng `role`, `user_role`, `permission`, `role_permission` và `GRANT`/`REVOKE` trong `Phase 3/08_rbac_security.sql`.
- Chỉ cấp quyền đọc hoặc ghi cần thiết cho từng nhóm người dùng; cột `password_hash` không đọc được bởi role ứng dụng.
- Hạn chế quyền chỉnh sửa dữ liệu quan trọng đối với những vai trò không có trách nhiệm nghiệp vụ tương ứng.
- Truy vết người thực hiện giao dịch qua `created_by_user_id` (BR-23, phụ thuộc ứng dụng đặt `app.current_user_id`).
- Mã hóa dữ liệu lưu trữ và sao lưu là yêu cầu triển khai, chưa có trong bản Docker demo (NFR-SEC-03, NFR-AVL-01).

#### 1.1.5. Ngoài phạm vi dự án

Trừ khi được bổ sung rõ ràng vào yêu cầu hoặc mô hình dữ liệu, các nội dung sau không được xem là phạm vi cốt lõi:

- Phát triển ứng dụng di động hoàn chỉnh hoặc giao diện người dùng thương mại.
- Tích hợp trực tiếp với cổng thanh toán bên thứ ba hoặc ngân hàng thật.
- Kết nối với thiết bị đeo, máy quét hoặc phần cứng phòng tập theo thời gian thực.
- Xây dựng hệ thống kế toán, thuế hoặc quản trị doanh nghiệp toàn diện.
- Tư vấn y tế, chẩn đoán bệnh hoặc xây dựng hệ thống hồ sơ y tế.
- Triển khai hạ tầng nhiều chi nhánh hoặc nhiều phòng tập nếu chưa có trong yêu cầu.
- Các báo cáo phân tích nâng cao hoặc mô hình dự đoán không thuộc yêu cầu cơ sở dữ liệu hiện tại.

#### 1.1.6. Sản phẩm bàn giao

- Lược đồ cơ sở dữ liệu và các tệp DDL tạo bảng, khóa và ràng buộc.
- Các tệp SQL dữ liệu mẫu phục vụ kiểm thử.
- Các truy vấn hoặc thao tác SQL minh họa những nghiệp vụ chính.
- Mô hình dữ liệu ER/EER hoặc sơ đồ quan hệ theo yêu cầu môn học.
- Tài liệu mô tả phạm vi, thực thể, quan hệ và các quy tắc nghiệp vụ.
- Kết quả kiểm thử ràng buộc (`05_constraint_test_cases.sql`), phân quyền (`09_rbac_test_cases.sql`) và hiệu năng (`06_performance_test_cases.sql`).
- Hướng dẫn triển khai và chạy các tệp SQL theo đúng thứ tự phụ thuộc: `01_schema_ddl` → `02_mock_data/01..08` → `04_triggers_views` → `08_rbac_security`.
- Đặc tả yêu cầu phần mềm: requirements_specification.md.

#### 1.1.7. Chuẩn tham chiếu, thuật ngữ và nhóm người dùng

**Chuẩn tham chiếu:** ISO/IEC/IEEE 29148 (Systems and software engineering – Life cycle processes – Requirements engineering), điều chỉnh cho phạm vi một dự án cơ sở dữ liệu.

**Quy ước:** mọi yêu cầu dùng động từ "phải" và có thể kiểm chứng. Mã `UR-xx` là yêu cầu người dùng; `FR-xx` / `NFR-xx` là yêu cầu hệ thống; `BR-xx` là quy tắc nghiệp vụ (mục 1.2).

*Bảng 1-2. Định nghĩa và thuật ngữ*

| Thuật ngữ | Ý nghĩa |
| --- | --- |
| PT (Personal Training) | Buổi huấn luyện cá nhân 1-1 giữa hội viên và huấn luyện viên, diễn ra ở khu tập tự do (không gắn phòng) |
| Hợp đồng (`member_subscription`) | Việc hội viên đăng ký một gói tập trong một khoảng thời gian |
| Hóa đơn (`billing_log`) | Bản ghi thanh toán, bất biến sau khi hoàn tất |
| Ân hạn (grace period) | Số ngày (mặc định 3) sau hạn hợp đồng tự gia hạn mà chưa thanh toán thì hợp đồng bị tạm ngưng |
| RBAC | Role-Based Access Control — phân quyền theo vai trò |
| Least privilege | Chỉ cấp quyền tối thiểu cần cho nhiệm vụ |
| BR | Business Rule — quy tắc nghiệp vụ, xem `business_rules.md` |
| UR / FR / NFR | Yêu cầu người dùng / chức năng hệ thống / phi chức năng |

*Bảng 1-3. Bên liên quan và nhóm người dùng*

| Nhóm | Vai trò CSDL | Mục tiêu chính |
| --- | --- | --- |
| Admin (quản trị) | `gym_role_admin` | Quản lý toàn bộ danh mục, tài khoản, phân quyền, xem báo cáo doanh thu và hiệu suất; không được sửa dữ liệu thanh toán |
| Receptionist (lễ tân) | `gym_role_receptionist` | Tiếp đón, tạo hồ sơ hội viên, bán gói, thu tiền, xếp lớp, đặt ca PT cho hội viên |
| Trainer (HLV) | `gym_role_trainer` | Xem lịch dạy lớp và ca PT của mình, điểm danh, đánh dấu hoàn thành/bỏ tập |
| Technician (kỹ thuật viên) | `gym_role_technician` | Quản lý thiết bị, ghi nhật ký bảo trì, đặt trạng thái bảo trì phòng/thiết bị |
| Member (hội viên) | `gym_role_member` | Xem gói tập, lịch lớp, tình trạng phòng; theo dõi quyền lợi của mình |
| Giảng viên / người chấm | — | Kiểm chứng thiết kế, ràng buộc, hiệu năng và phân quyền |

#### 1.1.8. Yêu cầu người dùng (User Requirements)

Các yêu cầu dưới đây mô tả điều người dùng cần, không nêu cách cài đặt.

*Bảng 1-4. Yêu cầu người dùng UR-01 … UR-18*

| Mã | Người dùng | Yêu cầu người dùng |
| --- | --- | --- |
| UR-01 | Admin, Lễ tân | Tôi phải tạo và quản lý được tài khoản của hội viên, HLV, nhân viên với thông tin liên hệ không bị trùng. |
| UR-02 | Admin | Tôi phải gán được vai trò cho từng người dùng để mỗi người chỉ làm đúng việc của mình. |
| UR-03 | Lễ tân | Tôi phải đăng ký được gói tập cho hội viên và biết hợp đồng nào đang có hiệu lực. |
| UR-04 | Lễ tân | Tôi phải ghi nhận được thanh toán, và hợp đồng chỉ có hiệu lực khi đã thanh toán. |
| UR-05 | FR-12, NFR-SEC-04 | BR-10 |
| UR-06 | Hội viên, Lễ tân | Hợp đồng dài hạn phải tự gia hạn đúng hạn, và hội viên không trả tiền phải bị tạm ngưng sau thời gian ân hạn. |
| UR-07 | Lễ tân, HLV | Tôi phải lập được lịch lớp nhóm mà không bị trùng giờ HLV hay trùng phòng. |
| UR-08 | Lễ tân, Hội viên | Hội viên phải đăng ký được lớp, nhưng không vượt quá sức chứa và không bị trùng với lịch khác của họ. |
| UR-09 | Lễ tân, Hội viên | Tôi phải đặt được ca PT khi hội viên còn buổi, và buổi tập phải được trừ chính xác. |
| UR-10 | Hội viên, HLV | Chính sách hủy ca PT phải rõ ràng: hủy sớm không mất buổi, hủy muộn hoặc bỏ tập thì mất buổi. |
| UR-11 | HLV | Tôi phải xem được lịch dạy tổng hợp (lớp và PT) và điểm danh được buổi của mình. |
| UR-12 | Kỹ thuật viên | Tôi phải quản lý được danh mục thiết bị, ngày mua, khấu hao và lịch sử bảo trì kèm chi phí. |
| UR-13 | Lễ tân, HLV | Thiết bị hoặc phòng đang bảo trì không được xếp vào lịch mới, và một máy không bị hai ca giữ cùng lúc. |
| UR-14 | Admin | Tôi phải xem được báo cáo doanh thu, tỷ lệ lấp đầy lớp, hiệu suất HLV, và các hợp đồng sắp hết hạn. |
| UR-15 | FR-30 | BR-23 |
| UR-16 | Mọi người dùng | Mật khẩu và thông tin nhạy cảm của tôi phải được bảo vệ. |
| UR-17 | Mọi người dùng | Tra cứu thông tin phải phản hồi nhanh, không phải chờ đáng kể khi dữ liệu lớn. |
| UR-18 | Admin | Dữ liệu phải được sao lưu để khôi phục được khi có sự cố. |

#### 1.1.9. Yêu cầu hệ thống – chức năng (Functional Requirements)

##### Nhóm A — Tài khoản và phân quyền (RBAC)

*Bảng 1-5. Nhóm A — Tài khoản và phân quyền (RBAC)*

| Mã | Yêu cầu | BR |
| --- | --- | --- |
| FR-01 | Hệ thống phải cho phép tạo tài khoản `user_account` với email và số điện thoại duy nhất, ngày sinh bắt buộc, trạng thái thuộc `Active`/`Inactive`/`Suspended`. | BR-02 |
| FR-02 | Hệ thống phải từ chối tạo hoặc sửa hồ sơ hội viên có ngày sinh dưới 12 tuổi. | BR-03 |
| FR-03 | Hệ thống phải lưu hồ sơ chuyên biệt 1:1 theo khóa chính dùng chung: `member_profile`, `trainer_profile` (điểm đánh giá 0–5), `staff_profile`. | BR-01, BR-11 |
| FR-04 | Hệ thống phải cho phép gán một hoặc nhiều vai trò cho tài khoản qua `user_role`, không cho gán trùng một vai trò hai lần, và lưu ma trận quyền trong `role_permission`. | BR-22 |
| FR-05 | Hệ thống phải cung cấp 5 role CSDL (`gym_role_admin`, `gym_role_receptionist`, `gym_role_trainer`, `gym_role_technician`, `gym_role_member`) với quyền `GRANT` đúng ma trận quyền trong `08_rbac_security.sql`. | BR-22 |

##### Nhóm B — Gói tập, hợp đồng và thanh toán

*Bảng 1-6. Nhóm B — Gói tập, hợp đồng và thanh toán*

| Mã | Yêu cầu | BR |
| --- | --- | --- |
| FR-06 | Hệ thống phải cho phép quản lý gói tập (`membership_plan`) với thời hạn `duration_days > 0`, `total_sessions >= 0`, `price >= 0`, và phải từ chối xóa gói đang được hợp đồng sử dụng. | BR-04 |
| FR-07 | Hệ thống phải cho phép Lễ tân tạo hợp đồng (`member_subscription`) ở trạng thái `Pending`, với `end_time >= start_time` và `remaining_sessions >= 0`. | BR-06 |
| FR-08 | Hệ thống phải bảo đảm mỗi hội viên có tối đa một hợp đồng `Active` tại một thời điểm. | BR-05 |
| FR-09 | Hệ thống phải từ chối chuyển hợp đồng sang `Active` khi chưa có hóa đơn `Completed`, và phải tự chuyển hợp đồng `Pending` sang `Active` khi hóa đơn của nó được ghi nhận `Completed`. | BR-07 |
| FR-10 | Hệ thống phải cho phép ghi hóa đơn (`billing_log`) với `invoice_no` duy nhất, `amount > 0`, phương thức và trạng thái thuộc miền giá trị quy định. | BR-09 |
| FR-11 | Hệ thống phải bảo đảm mỗi chu kỳ tính phí (`billing_period_start`) của một hợp đồng chỉ có tối đa một hóa đơn `Pending` hoặc `Completed`. | BR-08 |
| FR-12 | Hệ thống phải từ chối xóa và `TRUNCATE` hóa đơn; hóa đơn `Completed` chỉ được chuyển sang `Refunded` và không được đổi cột nào khác; hóa đơn `Failed`/`Refunded` không được sửa; việc `ALTER`/`DROP` bảng `billing_log`, trigger bất biến và các hàm trigger bất biến cũng bị chặn (kể cả với superuser, trừ khi bảo trì có chủ đích). | BR-10 |
| FR-13 | Hệ thống phải cung cấp thủ tục `sp_process_subscription_renewals(p_as_of, p_grace_days)` để: chuyển hợp đồng không tự gia hạn quá hạn sang `Expired`; phát hành hóa đơn `Pending` cho hợp đồng tự gia hạn quá hạn; chuyển hợp đồng tự gia hạn sang `Suspended` khi quá hạn ân hạn mà chưa thanh toán; thủ tục phải idempotent. | BR-24 |
| FR-14 | Hệ thống phải gia hạn hợp đồng (cộng `duration_days`, đặt lại `remaining_sessions`, chuyển `Active`) khi hóa đơn gia hạn được thanh toán. | BR-24, BR-07 |

##### Nhóm C — Lớp học nhóm

*Bảng 1-7. Nhóm C — Lớp học nhóm*

| Mã | Yêu cầu | BR |
| --- | --- | --- |
| FR-15 | Hệ thống phải cho phép tạo lịch lớp (`class_schedule`) với `end_time > start_time`, `max_capacity > 0`, và phải từ chối lịch chồng giờ của cùng HLV hoặc cùng phòng. | BR-12, BR-15, BR-17 |
| FR-16 | Hệ thống phải từ chối xếp lớp vào phòng ở trạng thái `Under_Maintenance`, và từ chối chuyển phòng sang `Under_Maintenance` khi phòng còn lớp học sắp diễn ra. | BR-19 |
| FR-17 | Hệ thống phải cho phép đăng ký lớp (`class_enrollment`), mỗi hợp đồng một lần cho mỗi lớp, và phải tự cập nhật `current_enrolled` khi đăng ký, hủy hoặc xóa. | BR-14 |
| FR-18 | Hệ thống phải từ chối đăng ký khi lớp đã đủ `max_capacity`. | BR-14 |
| FR-19 | Hệ thống phải từ chối đăng ký lớp trùng giờ với ca PT hoặc lớp khác của cùng hội viên, và từ chối xếp lớp trùng ca PT của HLV. | BR-12, BR-16 |
| FR-20 | Hệ thống phải lưu phòng tập (`facilities_room`) với `max_capacity > 0` và trạng thái `Active`/`Under_Maintenance`/`Inactive`. | BR-13 |

##### Nhóm D — Huấn luyện cá nhân (PT)

*Bảng 1-8. Nhóm D — Huấn luyện cá nhân (PT)*

| Mã | Yêu cầu | BR |
| --- | --- | --- |
| FR-21 | Hệ thống phải cho phép Lễ tân tạo ca PT (`pt_booking`) chỉ khi hợp đồng thuộc đúng hội viên, đang `Active`, giờ tập nằm trong thời hạn hợp đồng, và số buổi còn lại lớn hơn số ca `Scheduled` đang chờ. | BR-18 |
| FR-22 | Hệ thống phải từ chối ca PT chồng giờ của cùng HLV hoặc cùng hội viên (bỏ qua ca đã hủy), và chồng với lớp nhóm tương ứng. | BR-12, BR-16 |
| FR-23 | Hệ thống phải bảo đảm `end_time > start_time` và `booking_date` trùng ngày của `start_time` cho mọi ca PT. | BR-17 |
| FR-24 | Hệ thống phải tự trừ 1 buổi `remaining_sessions` khi ca PT chuyển sang `Completed`, `No_Show` hoặc `Late_Cancelled`, và không trừ lần hai khi chuyển giữa các trạng thái tính phí; phải từ chối khi `remaining_sessions` bằng 0. | BR-18, BR-25 |
| FR-25 | Hệ thống phải xử lý hủy ca PT: hủy khi còn từ 24 giờ trở lên giữ trạng thái `Cancelled` (không trừ buổi); hủy khi còn dưới 24 giờ tự đổi thành `Late_Cancelled` (trừ 1 buổi). | BR-25 |

##### Nhóm E — Thiết bị và bảo trì

*Bảng 1-9. Nhóm E — Thiết bị và bảo trì*

| Mã | Yêu cầu | BR |
| --- | --- | --- |
| FR-26 | Hệ thống phải lưu thiết bị (`equipment`) với `serial_number` duy nhất, `purchase_date` bắt buộc, `depreciation_months > 0`. | BR-26 |
| FR-27 | Hệ thống phải cho phép giữ chỗ thiết bị (`equipment_reservation`) gắn đúng một nguồn (ca PT hoặc lớp), và từ chối giữ chỗ trùng giờ trên cùng thiết bị. | BR-21 |
| FR-28 | Hệ thống phải từ chối giữ chỗ thiết bị đang `Under_Maintenance`, hoặc trùng khung giờ ca bảo trì `In_Progress`, hoặc vượt ngoài khung giờ của ca/lớp gắn kèm; từ chối chuyển thiết bị sang `Under_Maintenance` khi còn lượt giữ chỗ `Reserved` trong tương lai; và tự đồng bộ trạng thái thiết bị theo nhật ký bảo trì (mở ca `In_Progress` → `Under_Maintenance`; ca kết thúc và không còn ca đang sửa → `Operational`). | BR-19, BR-21 |
| FR-29 | Hệ thống phải cho phép Kỹ thuật viên ghi nhật ký bảo trì (`maintenance_log`) với `cost >= 0`, `end_time >= start_time` (nếu có) và người thực hiện là nhân viên. | BR-20 |
| FR-30 | Hệ thống phải bắt buộc ghi `created_by_user_id` (NOT NULL) từ biến phiên `app.current_user_id` khi tạo hợp đồng, hóa đơn, lịch lớp, ca PT và nhật ký bảo trì, từ chối thao tác nếu chưa đặt biến phiên; và phải ghi `updated_by_user_id`, `updated_at` ở mỗi `UPDATE` đồng thời cấm đổi `created_by_user_id`. | BR-23 |

##### Nhóm F — Báo cáo và truy vấn

*Bảng 1-10. Nhóm F — Báo cáo và truy vấn*

| Mã | Yêu cầu | BR |
| --- | --- | --- |
| FR-31 | Hệ thống phải cung cấp view `vw_active_member_subscriptions` liệt kê hợp đồng đang hiệu lực. | BR-05 |
| FR-32 | Hệ thống phải cung cấp view `vw_trainer_schedule_overview` hợp nhất lịch lớp và ca PT của HLV. | BR-12 |
| FR-33 | Hệ thống phải cung cấp các truy vấn báo cáo trong `03_complex_queries.sql` (doanh thu theo kỳ, tỷ lệ lấp đầy lớp, hiệu suất HLV, hợp đồng sắp hết hạn, chi phí bảo trì). | — |

#### 1.1.10. Yêu cầu hệ thống – phi chức năng (Non-functional Requirements)

##### Bảo mật (Security)

*Bảng 1-11. Bảo mật (Security)*

| Mã | Yêu cầu |
| --- | --- |
| NFR-SEC-01 | Hệ thống phải áp dụng đặc quyền tối thiểu: `REVOKE ALL` trên mọi bảng và sequence của schema `public` khỏi `PUBLIC`, sau đó chỉ `GRANT` cho 5 role nhóm đúng quyền theo ma trận trong `08_rbac_security.sql`; không role nào có `TRUNCATE`; Lễ tân không có `DELETE` ở bất kỳ bảng nào. |
| NFR-SEC-02 | Mật khẩu phải chỉ được lưu dưới dạng băm trong `user_account.password_hash` (không lưu bản rõ), và cột này phải không đọc được (`SELECT` mức cột không gồm `password_hash`) bởi mọi role ứng dụng; Lễ tân không được `UPDATE` cột này. |
| NFR-SEC-03 | Dữ liệu phải được mã hóa khi lưu trữ (encryption at rest). **Đây là yêu cầu triển khai** (đĩa/volume mã hóa như LUKS hoặc mã hóa lưu trữ của nhà cung cấp đám mây, kết nối TLS); bản Docker demo **chưa** cài đặt mã hóa này và bản demo dùng mật khẩu mẫu `demo_2026` cho các tài khoản `gym_u_*` phải được đổi khi triển khai thật. |
| NFR-SEC-04 | Hóa đơn phải bất biến theo bốn lớp: (1) trigger `trg_billing_immutable_*` chặn `UPDATE`/`DELETE`/`TRUNCATE` sai quy định; (2) mọi role ứng dụng (kể cả Admin) chỉ có `SELECT, INSERT` trên `billing_log`; (3) mọi đối tượng ứng dụng thuộc role `NOLOGIN` `gym_owner`, không tài khoản đăng nhập nào là chủ sở hữu; (4) event trigger `evt_protect_billing_log`/`_drop` chặn `ALTER`/`DROP` `billing_log`, trigger và hàm bất biến, kể cả với superuser (superuser chỉ bảo trì được bằng thao tác tường minh `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`). |
| NFR-SEC-05 | Hàm trigger cần ghi vào bảng mà role gọi không có quyền phải chạy `SECURITY DEFINER` với `search_path` cố định (`public, pg_temp`) để không phải cấp thêm quyền ghi cho role. |

##### Hiệu năng (Performance)

*Bảng 1-12. Hiệu năng (Performance)*

| Mã | Yêu cầu |
| --- | --- |
| NFR-PERF-01 | Các truy vấn tra cứu/tìm kiếm chính phải trả kết quả dưới 200 ms với khối lượng 100.000 – 200.000 bản ghi mỗi bảng nghiệp vụ; chứng minh bằng `Phase 3/06_performance_test_cases.sql` (so sánh có và không có chỉ mục). |
| NFR-PERF-02 | Hệ thống phải có chỉ mục hỗ trợ truy vấn thường dùng, ví dụ `idx_member_subscription_member`, `idx_billing_log_subscription_date`, `idx_pt_booking_trainer`, `idx_pt_booking_dates`, `idx_class_schedule_dates`. |

##### Toàn vẹn dữ liệu (Integrity)

*Bảng 1-13. Toàn vẹn dữ liệu (Integrity)*

| Mã | Yêu cầu |
| --- | --- |
| NFR-INT-01 | Mọi quan hệ phải được bảo vệ bằng khóa ngoại với hành động tham chiếu rõ ràng (`ON DELETE RESTRICT` cho dữ liệu giao dịch; `CASCADE` chỉ cho hồ sơ 1:1 và lượt giữ chỗ phụ thuộc). |
| NFR-INT-02 | Miền giá trị (trạng thái, phương thức thanh toán, số lượng, tiền, thời gian) phải được thực thi bằng `CHECK`, `NOT NULL`, `UNIQUE` ở mức CSDL, không chỉ ở ứng dụng. |
| NFR-INT-03 | Xung đột lịch phải được chặn bằng ràng buộc `EXCLUDE USING gist` (cùng bảng) và trigger (xuyên bảng) để không phụ thuộc kiểm tra phía ứng dụng. |
| NFR-INT-04 | Cập nhật số buổi PT và sĩ số lớp phải an toàn khi truy cập đồng thời (khóa hàng `FOR UPDATE`, khóa tư vấn theo hợp đồng). |
| NFR-INT-05 | Dữ liệu mẫu phải thỏa mọi quy tắc; khối kiểm toán dữ liệu (`DO` cuối `04_triggers_views.sql`) phải báo lỗi nếu có dòng vi phạm. |

##### Sẵn sàng và sao lưu (Availability / Backup)

*Bảng 1-14. Sẵn sàng và sao lưu (Availability / Backup)*

| Mã | Yêu cầu |
| --- | --- |
| NFR-AVL-01 | Khi triển khai thật, quản trị phải sao lưu định kỳ (khuyến nghị `pg_dump` hằng ngày kèm sao lưu liên tục WAL) và kiểm tra khôi phục. Bản demo chỉ dùng Docker volume, chưa có lịch sao lưu tự động. |
| NFR-AVL-02 | Thủ tục `sp_process_subscription_renewals` phải được bộ lập lịch bên ngoài gọi định kỳ (mặc định mỗi ngày) và an toàn khi gọi lặp. Docker demo có service `scheduler` (`fitzone_renewal_scheduler`, chu kỳ `RENEWAL_INTERVAL_SECONDS`, người thực hiện ghi vết BR-23 lấy từ `SCHEDULER_ACTOR_USER_ID`, mặc định 3); production dùng `pg_cron` hoặc cron và phải đặt `app.current_user_id` cho phiên gọi. |

##### Khả bảo trì (Maintainability)

*Bảng 1-15. Khả bảo trì (Maintainability)*

| Mã | Yêu cầu |
| --- | --- |
| NFR-MNT-01 | Mã SQL phải tuân thủ SQLStyle.guide (từ khóa viết HOA, định danh `snake_case` chữ thường, thụt lề nhất quán). |
| NFR-MNT-02 | Ràng buộc phải được đặt tên theo tiền tố (`pk_`, `fk_`, `uq_`, `chk_`, `ex_`, `idx_`, `trg_`, `sp_`) để truy vết tới BR. |
| NFR-MNT-03 | Các tập tin SQL phải nạp đúng thứ tự: `01_schema_ddl` → `02_mock_data/01..08` → `04_triggers_views` → `08_rbac_security`; nạp lại 04 thì phải nạp lại 08. |
| NFR-MNT-04 | Phải có bộ kiểm thử tự động cho ràng buộc (`05_constraint_test_cases.sql`), phân quyền (`09_rbac_test_cases.sql`) và hiệu năng (`06_performance_test_cases.sql`) chạy trong giao dịch rồi `ROLLBACK`. |

##### Khả dụng cho người dùng (Usability)

*Bảng 1-16. Khả dụng cho người dùng (Usability)*

| Mã | Yêu cầu |
| --- | --- |
| NFR-USE-01 | Thông báo lỗi nghiệp vụ của trigger phải nêu mã quy tắc (`BR-xx`) và đối tượng liên quan bằng tiếng Việt để người dùng hiểu nguyên nhân. |
| NFR-USE-02 | Ứng dụng minh họa phải kết nối CSDL bằng tài khoản không phải superuser (`gym_u_*`, thuộc nhóm quyền `gym_role_*`) để quyền của CSDL luôn được áp dụng, và phải cho chọn người thực hiện thao tác để ghi vết `created_by_user_id`. |

#### 1.1.11. Ràng buộc và giả định

**Ràng buộc**

- Hệ quản trị: PostgreSQL 16 với extension `btree_gist`; ứng dụng minh họa dùng Streamlit, chạy qua Docker Compose.
- Một cơ sở (một phòng tập); không đa chi nhánh.
- Mã SQL theo SQLStyle.guide; tài liệu bằng tiếng Việt.
- Không tích hợp cổng thanh toán thật; thanh toán chỉ ghi nhận kết quả.
- PostgreSQL không có bộ lập lịch tích hợp; quy tắc theo thời gian (BR-24) cần bộ lập lịch ngoài (container `scheduler` trong demo, `pg_cron`/cron trong production).
**Giả định**

- Ca PT diễn ra ở khu tập tự do, không gắn với phòng cụ thể; BR-15 chỉ áp dụng cho lớp nhóm.
- Ứng dụng đặt `app.current_user_id` cho mỗi phiên làm việc để truy vết người thực hiện (BR-23); nếu không đặt thì thao tác ghi bị CSDL từ chối (người dùng thủ công chạy `SET app.current_user_id = '<id>'`; bộ lập lịch dùng biến `SCHEDULER_ACTOR_USER_ID`, mặc định 3).
- Nhân viên kỹ thuật cập nhật trạng thái `Under_Maintenance` của phòng/thiết bị; hệ thống không tự suy ra từ nhật ký bảo trì.
- Mỗi hội viên có hợp đồng đang dùng tối đa một gói tại một thời điểm.
- Mã hóa dữ liệu lưu trữ và sao lưu do hạ tầng triển khai đảm nhận.

#### 1.1.12. Ma trận truy vết (Traceability Matrix)

Cột "Kiểm chứng" dẫn đến mã test cụ thể trong: **05** = `05_constraint_test_cases.sql` (109 test: TC-01..TC-74, TP-01..TP-35), **09** = `09_rbac_test_cases.sql` (61 test: RA/RD/TA/TD/EA/ED/MA/MD/AA/AD/LA/LD và EV-01..EV-13), **06** = `06_performance_test_cases.sql` (PT-01..PT-08). Mã test được kiểm tra khớp với tập tin SQL tại thời điểm cập nhật.

*Bảng 1-17. Ma trận truy vết UR → FR/NFR → BR → bảng → đối tượng thực thi → kiểm chứng*

| UR | FR / NFR | BR | Bảng | Đối tượng thực thi | Kiểm chứng |
| --- | --- | --- | --- | --- | --- |
| UR-01 | FR-01, FR-02, FR-03 | BR-01, BR-02, BR-03, BR-11 | `user_account`, `member_profile`, `trainer_profile`, `staff_profile` | `uq_user_account_email`, `uq_user_account_phone`, `chk_user_account_status`, `trg_check_member_dob`, `trg_check_user_dob_for_member`, `chk_trainer_rating` | 05: BR-02: TC-01..TC-03; BR-03: TC-04, TC-05, TP-01; BR-11: TC-07 |
| UR-02 | FR-04, FR-05 | BR-22 | `role`, `user_role`, `permission`, `role_permission` | `pk_user_role`, `uq_role_name`, 5 role `gym_role_*` | 05: BR-22: TC-06, TC-08; 09: RD-06, AA-01, LD-01, LA-01 (role nhóm và tài khoản thừa hưởng) |
| UR-03 | FR-06, FR-07, FR-08, FR-31 | BR-04, BR-05, BR-06 | `membership_plan`, `member_subscription` | `chk_membership_plan_*`, `chk_subscription_dates`, `uq_member_one_active_subscription`, `vw_active_member_subscriptions` | 05: BR-04: TC-09, TC-10, TC-18; BR-05: TC-40, TP-09; BR-06: TC-11 |
| UR-04 | FR-09, FR-10, FR-11 | BR-07, BR-08, BR-09 | `billing_log`, `member_subscription` | `trg_require_payment_before_active`, `trg_activate_on_payment_*`, `uq_billing_invoice_no`, `chk_billing_amount`, `uq_billing_subscription_period` | 05: BR-07: TC-41, TC-42, TP-08; BR-08: TC-43, TP-10, TP-11; BR-09: TC-14..TC-16, TP-07 |
| UR-05 | FR-12, NFR-SEC-04 | BR-10 | `billing_log` | `trg_billing_immutable_update/_delete/_truncate`; `GRANT SELECT, INSERT` | 05: BR-10: TC-17, TC-44..TC-49, TP-12..TP-14; 09: RD-03, RD-04, AD-01, AD-02, AD-03 (billing_log bị từ chối UPDATE/DELETE/TRUNCATE) |
| UR-06 | FR-13, FR-14, NFR-AVL-02 | BR-24, BR-07 | `member_subscription`, `billing_log` | `sp_process_subscription_renewals`, `trg_activate_on_payment_*` | 05: BR-24: TC-66, TP-23..TP-26 |
| UR-07 | FR-15, FR-16, FR-19, FR-20 | BR-12, BR-13, BR-15, BR-17, BR-19 | `class_schedule`, `facilities_room` | `ex_class_trainer_no_overlap`, `ex_class_room_no_overlap`, `chk_class_time`, `chk_facilities_capacity`, `trg_prevent_class_in_maintenance_room`, `trg_prevent_room_maintenance_with_future_classes`, `trg_check_class_schedule_conflicts` | 05: BR-12: TC-22, TC-27, TC-50, TC-51, TP-05; BR-13: TC-19; BR-15: TC-21, TP-06; BR-17: TC-20, TC-26; BR-19: TC-23, TC-34, TC-69, TP-31 |
| UR-08 | FR-17, FR-18, FR-19 | BR-14, BR-16 | `class_enrollment`, `class_schedule` | `trg_sync_class_enrollment_count`, `chk_class_enrollment_limit`, `uq_enrollment_subscription_class`, `trg_check_class_enrollment_conflicts` | 05: BR-14: TC-24, TC-25, TP-03, TP-04; BR-16: TC-28, TC-52..TC-55, TC-68, TP-15 |
| UR-09 | FR-21, FR-22, FR-23, FR-24 | BR-12, BR-16, BR-17, BR-18 | `pt_booking`, `member_subscription` | `trg_check_pt_booking_creation`, `trg_update_remaining_pt_sessions`, `fk_booking_subscription_member`, `ex_pt_trainer_no_overlap`, `ex_pt_member_no_overlap`, `chk_pt_booking_time`, `chk_pt_booking_date`, `chk_subscription_remaining` | 05: BR-12: TC-22, TC-27, TC-50, TC-51, TP-05; BR-16: TC-28, TC-52..TC-55, TC-68, TP-15; BR-17: TC-20, TC-26; BR-18: TC-13, TC-29, TC-30, TC-56..TC-60, TP-02, TP-16 |
| UR-10 | FR-24, FR-25 | BR-25 | `pt_booking`, `member_subscription` | `trg_late_cancel_pt_booking`, `trg_update_remaining_pt_sessions`, `chk_pt_booking_status` | 05: BR-25: TC-31, TC-67, TP-27..TP-30 |
| UR-11 | FR-32, FR-05 | BR-22 | `pt_booking`, `class_enrollment` | `vw_trainer_schedule_overview`; `GRANT UPDATE (status)` cho `gym_role_trainer` | 09: TA-01..TA-05, TD-01, TD-05 (quyền HLV) |
| UR-12 | FR-26, FR-29 | BR-20, BR-26 | `equipment`, `maintenance_log` | `chk_equipment_depreciation`, `uq_equipment_serial`, `chk_maintenance_cost`, `chk_maintenance_time`, `fk_maintenance_staff` | 05: BR-20: TC-37..TC-39; BR-26: TC-32, TC-33; 09: EA-01, EA-02, ED-01..ED-05 (quyền kỹ thuật viên) |
| UR-13 | FR-16, FR-27, FR-28 | BR-19, BR-21 | `equipment_reservation`, `equipment`, `facilities_room`, `maintenance_log` | `ex_reservation_equipment_no_overlap`, `chk_reservation_source`, `trg_prevent_equipment_reservation_under_maintenance`, `trg_prevent_equipment_maintenance_with_future_reservations`, `trg_start_equipment_maintenance_*`, `trg_finish_equipment_maintenance`, `trg_check_reservation_window` | 05: BR-19: TC-23, TC-34, TC-69..TC-71, TP-31..TP-34; 09: EA-03; BR-21: TC-35, TC-36, TC-61..TC-64, TP-17..TP-19 |
| UR-14 | FR-33, FR-31, FR-32 | — | các bảng nghiệp vụ | truy vấn trong `03_complex_queries.sql`, 2 view | 06: PT-03, PT-08 (truy vấn phức hợp); chạy thử trên Streamlit |
| UR-15 | FR-30 | BR-23 | `member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log` | cột `created_by_user_id` + `fk_*_created_by`, `trg_fill_created_by` | 05: BR-23: TC-65, TP-20..TP-22 |
| UR-16 | NFR-SEC-01, NFR-SEC-02, NFR-SEC-03, NFR-SEC-05 | BR-22 | `user_account` | `REVOKE ... FROM PUBLIC`, `GRANT SELECT (cột)` không gồm `password_hash`, `SECURITY DEFINER` | 09: RD-01, RD-02, AD-04 (ẩn password_hash), RD-03..RD-06, TD-01..TD-07, ED-01..ED-05, MD-01..MD-05 (từ chối quyền ngoài ma trận), TA-01, RA-03 (SECURITY DEFINER) |
| UR-17 | NFR-PERF-01, NFR-PERF-02 | — | `user_account`, `billing_log`, `pt_booking` | các chỉ mục `idx_*` | 06: PT-01..PT-08 |
| UR-18 | NFR-AVL-01 | — | toàn CSDL | quy trình `pg_dump` (triển khai) | Không kiểm thử tự động; kiểm chứng thủ công khi triển khai |
| UR-01..UR-13 | NFR-INT-01..NFR-INT-05 | BR-01..BR-26 | toàn CSDL | khóa ngoại, `CHECK`, `EXCLUDE`, khối kiểm toán dữ liệu | 05: TC-01..TC-74, TP-01..TP-35 (toàn bộ 109 test); khối DATA AUDIT của `04_triggers_views.sql` |
| — | NFR-MNT-01..NFR-MNT-04, NFR-USE-01, NFR-USE-02 | — | — | SQLStyle.guide, đặt tên ràng buộc, thứ tự nạp tập tin, thông báo `RAISE EXCEPTION` | Rà soát tài liệu; 05/09/06 chạy được từ đầu đến cuối |

**Các yêu cầu chưa thực thi hoặc chỉ thực thi một phần:** NFR-SEC-03 (mã hóa khi lưu trữ) và NFR-AVL-01 (sao lưu) là yêu cầu triển khai, không có trong bản Docker demo; BR-10 và BR-23 được thực thi đầy đủ ở CSDL, lưu ý còn lại là superuser vốn là gốc tin cậy (bảo trì `billing_log` phải tường minh) và mọi chương trình ghi dữ liệu phải đặt `app.current_user_id`; FR-13/BR-24 cần bộ lập lịch ngoài (đã có container `scheduler` trong demo; production dùng `pg_cron`/cron). Chi tiết xem business_rules.md, mục "Tổng hợp mức độ thực thi".

### 1.2. Quy tắc nghiệp vụ & ràng buộc (Business Rules & Constraints)

Để duy trì tính nhất quán của cơ sở dữ liệu và loại bỏ các trạng thái dữ liệu sai lệch, hệ thống áp dụng 26 quy tắc nghiệp vụ (BR-01 đến BR-26). Cột "Cơ chế Thực thi" dưới đây ghi **đúng tên đối tượng cơ sở dữ liệu** đã triển khai trong `Phase 3/01_schema_ddl.sql` (DDL), `Phase 3/04_triggers_views.sql` (trigger, thủ tục) và `Phase 3/08_rbac_security.sql` (phân quyền). Quy tắc được kiểm chứng bằng `Phase 3/05_constraint_test_cases.sql` (ràng buộc, trigger) và `Phase 3/09_rbac_test_cases.sql` (phân quyền); xem thêm ma trận truy vết trong requirements_specification.md.

Phân loại cơ chế: **Khai báo** (`PRIMARY KEY`, `UNIQUE`, `CHECK`, `FOREIGN KEY`, `EXCLUDE`, chỉ mục duy nhất từng phần) được DBMS thực thi trực tiếp; **Thủ tục** (trigger, procedure) dùng cho các quy tắc xuyên bảng hoặc phụ thuộc thời gian mà ràng buộc khai báo không diễn đạt được.

*Bảng 1-18. Bảng tóm tắt quy tắc nghiệp vụ BR-01 … BR-26 và cơ chế thực thi*

| Mã Quy tắc | Tên Quy tắc | Mô tả Chi tiết Nghiệp vụ | Cơ chế Thực thi |
| --- | --- | --- | --- |
| **BR-01** | Mã Hội viên Duy nhất | Mỗi `HỘI VIÊN` (`MEMBER_PROFILE`) phải có một mã định danh `user_id` duy nhất trên toàn hệ thống; mã này đồng thời là khóa ngoại 1:1 tới `user_account`. | `PRIMARY KEY` trên `member_profile.user_id` (khóa chính dùng chung); `fk_member_profile_user` (`ON DELETE CASCADE`); `fk_subscription_member` buộc hợp đồng chỉ gắn với người có hồ sơ hội viên. |
| **BR-02** | Liên hệ Duy nhất | Email và Số điện thoại của người dùng (bao gồm hội viên) phải duy nhất, không được trùng lặp. | `uq_user_account_email` (`UNIQUE (email)`), `uq_user_account_phone` (`UNIQUE (phone)`) và `NOT NULL` trên `user_account`. |
| **BR-03** | Độ tuổi Tối thiểu | Hội viên phải từ 12 tuổi trở lên (`dob <= CURRENT_DATE - 12 năm`). Quy tắc chỉ áp dụng cho hội viên, không áp dụng cho nhân viên/HLV. | Trigger `trg_check_member_dob` (`BEFORE INSERT OR UPDATE OF user_id ON member_profile`, hàm `trg_fn_check_user_age`) và `trg_check_user_dob_for_member` (`BEFORE UPDATE OF dob ON user_account`, hàm `trg_fn_check_member_dob_update`). Dùng trigger vì `CHECK` không đọc được bảng khác (`member_profile`). |
| **BR-04** | Tính Hợp lệ Gói tập | Mỗi `GÓI TẬP` (`MEMBERSHIP_PLAN`) phải có thời hạn tính theo ngày (`duration_days > 0`), số buổi PT không âm (`total_sessions >= 0`) và đơn giá không âm (`price >= 0`). | `chk_membership_plan_duration`, `chk_membership_plan_sessions`, `chk_membership_plan_price` (`CHECK`); `fk_subscription_plan ... ON DELETE RESTRICT` ngăn xóa gói đang được sử dụng. |
| **BR-05** | Một Hợp đồng Kích hoạt | Một hội viên có thể có nhiều hợp đồng theo thời gian nhưng tại một thời điểm chỉ có tối đa 1 hợp đồng `Active`. | Chỉ mục duy nhất từng phần `uq_member_one_active_subscription ON member_subscription (member_user_id) WHERE sub_status = 'Active'`. |
| **BR-06** | Thứ tự Thời gian Hợp đồng | Trong một hợp đồng, thời điểm kết thúc phải lớn hơn hoặc bằng thời điểm bắt đầu (`end_time >= start_time`). | `chk_subscription_dates` (`CHECK`) trên `member_subscription`. |
| **BR-07** | Kích hoạt Hợp đồng | Hợp đồng chỉ được chuyển sang `Active` khi đã có hóa đơn `Completed`; ngược lại, khi hóa đơn chuyển `Completed` thì hợp đồng `Pending` được tự kích hoạt. | `trg_require_payment_before_active` (`BEFORE INSERT OR UPDATE OF sub_status ON member_subscription`, hàm `trg_fn_require_payment_before_active`) chặn kích hoạt khi chưa thanh toán; `trg_activate_on_payment_insert` / `trg_activate_on_payment_update` (`AFTER ... ON billing_log`, hàm `trg_fn_activate_on_payment`) kích hoạt sau thanh toán. Miền giá trị: `chk_subscription_status`. |
| **BR-08** | Duy nhất Hóa đơn Chu kỳ | Mỗi chu kỳ tính phí của một hợp đồng chỉ có tối đa 1 hóa đơn còn hiệu lực (`Pending`/`Completed`); hóa đơn `Failed`/`Refunded` không chiếm chu kỳ nên được phát hành lại. | Chỉ mục duy nhất từng phần `uq_billing_subscription_period ON billing_log (subscription_id, billing_period_start) WHERE payment_status IN ('Pending', 'Completed')`; cột `billing_period_start DATE NOT NULL`; trigger `trg_fill_billing_period_start` (`BEFORE INSERT`) mặc định chu kỳ là ngày bắt đầu hợp đồng nếu không nêu. |
| **BR-09** | Hóa đơn Thanh toán Hợp lệ | Mỗi hóa đơn phải có `invoice_no` duy nhất, số tiền lớn hơn 0, phương thức và trạng thái thuộc miền giá trị cho phép. | `uq_billing_invoice_no` (`UNIQUE`), `chk_billing_amount` (`amount > 0`), `chk_billing_method`, `chk_billing_status` (`CHECK`); `fk_billing_subscription ... ON DELETE RESTRICT`. |
| **BR-10** | Dữ liệu Thanh toán Bất biến | Hóa đơn thanh toán là nhật ký bất biến: không được xóa; hóa đơn `Completed` chỉ được chuyển sang `Refunded`, mọi cột khác giữ nguyên; hóa đơn `Failed`/`Refunded` là trạng thái cuối. | Bốn lớp bảo vệ. (1) Ba trigger trên `billing_log`: `trg_billing_immutable_update` (`BEFORE UPDATE`), `trg_billing_immutable_delete` (`BEFORE DELETE`), `trg_billing_immutable_truncate` (`BEFORE TRUNCATE`) chặn mọi người dùng. (2) Phân quyền trong `08_rbac_security.sql`: mọi role ứng dụng (kể cả `gym_role_admin`) chỉ có `SELECT, INSERT` trên `billing_log` (`REVOKE UPDATE, DELETE ON billing_log FROM gym_role_admin`), không role nào có `TRUNCATE` (lỗi `42501`). (3) Mọi đối tượng ứng dụng thuộc role `NOLOGIN` `gym_owner`; không tài khoản đăng nhập nào là chủ sở hữu hay thành viên của role này nên không thể `ALTER`/`DROP` `billing_log` hay vô hiệu hóa trigger. (4) Event trigger `evt_protect_billing_log` (`ddl_command_end`) và `evt_protect_billing_log_drop` (`sql_drop`) chặn `ALTER TABLE`, `DROP TABLE`, `DROP`/`ALTER TRIGGER` trên `billing_log` và việc sửa/xóa các hàm trigger bất biến (lỗi `P0001` chứa `BR-10`), kể cả với superuser. **Giới hạn còn lại (cố hữu):** superuser là gốc tin cậy của mọi DBMS nên vẫn có thể bảo trì có chủ đích bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`; thao tác này phải tường minh và để lại dấu vết. |
| **BR-11** | Định danh Huấn luyện viên | Mỗi huấn luyện viên có `user_id` duy nhất; `phone` và `email` duy nhất; điểm đánh giá trong khoảng 0–5. | `trainer_profile.user_id` là `PRIMARY KEY` + `fk_trainer_profile_user`; email/phone duy nhất nhờ `uq_user_account_email`, `uq_user_account_phone` trên `user_account` (HLV là một tài khoản); `chk_trainer_rating` (`current_rating BETWEEN 0 AND 5`). |
| **BR-12** | Không Trùng lịch HLV | Một HLV không được có 2 lịch (lớp nhóm hoặc ca PT) chồng chéo khoảng thời gian. | Cùng bảng: `ex_class_trainer_no_overlap` (`EXCLUDE USING gist` trên `class_schedule`) và `ex_pt_trainer_no_overlap` (trên `pt_booking`, bỏ qua ca `Cancelled`/`Late_Cancelled`); xuyên bảng lớp ↔ PT: trigger `trg_check_class_schedule_conflicts` và `trg_check_pt_booking_conflicts` (code lỗi nghiệp vụ BR-12). Cần extension `btree_gist`. |
| **BR-13** | Giới hạn Sức chứa Phòng | Mỗi `PHÒNG TẬP / KHU VỰC` (`FACILITIES_ROOM`) có sức chứa tối đa dương (`max_capacity > 0`). | `chk_facilities_capacity` (`CHECK`); `chk_facilities_status` giới hạn trạng thái phòng. |
| **BR-14** | Giới hạn Đăng ký Lớp | Số hội viên đăng ký một lớp nhóm (`current_enrolled`) không được vượt sức chứa tối đa của lớp (`max_capacity`); mỗi hợp đồng chỉ đăng ký một lớp 1 lần. | `fn_sync_class_enrollment_count` / trigger `trg_sync_class_enrollment_count` (`AFTER INSERT OR UPDATE OR DELETE ON class_enrollment`) tự tính lại `current_enrolled` (chỉ đếm `Enrolled`/`Attended`); `chk_class_enrollment_limit` (`current_enrolled <= max_capacity`) từ chối đăng ký khi lớp đầy; `chk_class_enrolled` (`>= 0`), `chk_class_capacity` (`max_capacity > 0`); `uq_enrollment_subscription_class` (`UNIQUE (subscription_id, class_id)`). |
| **BR-15** | Không Trùng lịch Phòng tập | Một phòng tập không được xếp đồng thời 2 **lớp học nhóm** tại cùng thời điểm. Quy tắc chỉ áp dụng cho lớp nhóm: ca PT 1-1 diễn ra ở khu tập tự do và không gắn với phòng (`pt_booking` không có cột `room_id`). | `ex_class_room_no_overlap` (`EXCLUDE USING gist (room_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` trên `class_schedule`). |
| **BR-16** | Không Trùng lịch Hội viên | Một hội viên không được tham gia 2 lịch (lớp nhóm hoặc ca PT) trùng thời điểm. | PT ↔ PT: `ex_pt_member_no_overlap` (`EXCLUDE USING gist` trên `pt_booking`, bỏ qua ca đã hủy); PT ↔ lớp và lớp ↔ lớp: trigger `trg_check_class_enrollment_conflicts` (`class_enrollment`), `trg_check_pt_booking_conflicts` (`pt_booking`) và `trg_check_class_schedule_conflicts` (khi đổi giờ lớp). |
| **BR-17** | Thời gian Sự kiện Hợp lệ | Thời điểm kết thúc của ca PT, lớp nhóm hoặc lượt giữ chỗ thiết bị phải sau thời điểm bắt đầu (`end_time > start_time`); ngày ca PT phải trùng ngày bắt đầu. | `chk_pt_booking_time`, `chk_class_time`, `chk_reservation_time` (`CHECK`); `chk_pt_booking_date` (`booking_date = start_time::DATE`). |
| **BR-18** | Trừ Buổi tập PT | Ca PT `Scheduled` chỉ được tạo khi hợp đồng đang `Active`, giờ tập nằm trong thời hạn hợp đồng và số buổi còn lại (`remaining_sessions`) lớn hơn số ca `Scheduled` đang chờ. Buổi tập bị trừ 1 khi ca chuyển sang trạng thái tính phí (xem BR-25); không cho phép trừ khi `remaining_sessions` đã bằng 0. | `trg_check_pt_booking_creation` (`BEFORE INSERT ON pt_booking`, khóa tư vấn theo hợp đồng chống 2 lễ tân giành buổi cuối); `trg_update_remaining_pt_sessions` (`AFTER UPDATE OF status ON pt_booking`, `SELECT ... FOR UPDATE` rồi trừ 1); `chk_subscription_remaining` (`remaining_sessions >= 0`); khóa ngoại ghép `fk_booking_subscription_member (subscription_id, member_user_id)` bảo đảm hợp đồng thuộc đúng hội viên. |
| **BR-19** | Chặn Khóa Bảo trì | Hai chiều. (1) Không được xếp lớp vào phòng `Under_Maintenance`, không được giữ chỗ thiết bị `Under_Maintenance` hoặc trùng khung giờ một ca bảo trì `In_Progress`. (2) Không được chuyển phòng sang `Under_Maintenance` khi phòng còn lớp học sắp diễn ra (`start_time > CURRENT_TIMESTAMP`), và không được chuyển thiết bị sang `Under_Maintenance` khi còn lượt giữ chỗ `Reserved` trong tương lai; nhân viên phải dời/hủy lịch trước. (3) Trạng thái thiết bị đồng bộ với `maintenance_log`: mở ca `In_Progress` thì thiết bị tự chuyển `Under_Maintenance`; khi ca kết thúc (`Completed`/`Cancelled`) và không còn ca `In_Progress` nào khác thì thiết bị tự về `Operational` (trừ khi đã `Decommissioned`). | `trg_prevent_class_in_maintenance_room` (`BEFORE INSERT OR UPDATE OF room_id ON class_schedule`, hàm `trg_fn_prevent_room_under_maintenance`); `trg_prevent_equipment_reservation_under_maintenance` (`BEFORE INSERT OR UPDATE OF equipment_id ON equipment_reservation`, hàm `trg_fn_prevent_equipment_under_maintenance`); `trg_check_reservation_window` (đối chiếu ca bảo trì `In_Progress`); `trg_prevent_room_maintenance_with_future_classes` (`BEFORE UPDATE OF status ON facilities_room`); `trg_prevent_equipment_maintenance_with_future_reservations` (`BEFORE UPDATE OF status ON equipment`); `trg_start_equipment_maintenance_insert` / `_update` và `trg_finish_equipment_maintenance` (`AFTER` trên `maintenance_log`). Chuỗi trigger chạy bằng `SECURITY DEFINER` nên kỹ thuật viên (chỉ có `UPDATE (status)` và `INSERT` nhật ký) vẫn thực hiện được trọn quy trình. **Thực thi đầy đủ ở CSDL.** Ca PT không bị ràng buộc vì không dùng phòng. |
| **BR-20** | Nhật ký Bảo trì Hợp lệ | Mỗi `NHẬT KÝ BẢO TRÌ` có chi phí không âm (`cost >= 0`) và thời gian hoàn thành (nếu có) không trước thời gian bắt đầu; người thực hiện phải là nhân viên. | `chk_maintenance_cost`, `chk_maintenance_time` (`end_time IS NULL OR end_time >= start_time`), `chk_maintenance_status` (`CHECK`); `fk_maintenance_staff` → `staff_profile`, `fk_maintenance_equipment`. |
| **BR-21** | Chống Đụng Máy tập | Một thiết bị không được bị giữ chỗ trùng khung giờ; lượt giữ chỗ phải thuộc đúng một nguồn (ca PT hoặc lớp), nằm trong khung giờ của ca/lớp đó và không trùng ca bảo trì đang diễn ra. | `ex_reservation_equipment_no_overlap` (`EXCLUDE USING gist`, bỏ qua lượt `Cancelled`); `chk_reservation_source` (đúng một trong `booking_id`/`class_id`); trigger `trg_check_reservation_window` (`BEFORE INSERT OR UPDATE ON equipment_reservation`) kiểm tra khung giờ ca/lớp và bảo trì `In_Progress`. |
| **BR-22** | Phân quyền RBAC | Một tài khoản có thể có một hoặc nhiều vai trò (Admin, Receptionist, Trainer, Technician, Member); quyền thao tác được cấp theo vai trò và theo nguyên tắc đặc quyền tối thiểu. | Mô hình ứng dụng: `role`, `user_role` (`pk_user_role (user_id, role_id)`), `permission`, `role_permission`. Mức CSDL (`08_rbac_security.sql`): 5 role nhóm `gym_role_admin`, `gym_role_receptionist`, `gym_role_trainer`, `gym_role_technician`, `gym_role_member` (`NOLOGIN`), 5 tài khoản mẫu `gym_u_*`; `REVOKE ALL ... FROM PUBLIC` rồi `GRANT` tối thiểu theo ma trận quyền; `GRANT` mức cột (ẩn `password_hash`); hàm trigger `SECURITY DEFINER SET search_path = public, pg_temp`. Hạn chế: bảng `role_permission` là dữ liệu ma trận cho ứng dụng, còn `GRANT` được viết tay tương ứng, hai nơi không tự đồng bộ. |
| **BR-23** | Vết Truy xuất Giao dịch | Mọi giao dịch tạo mới (hợp đồng, hóa đơn, lịch lớp, ca PT, nhật ký bảo trì) phải ghi nhận người thực hiện vào `created_by_user_id`. | Cột `created_by_user_id INT NOT NULL` và `updated_by_user_id INT NULL`, `updated_at TIMESTAMP NULL`, mỗi cột người dùng có khóa ngoại tới `user_account` (`fk_subscription_created_by`/`_updated_by`, `fk_billing_*`, `fk_class_*`, `fk_booking_*`, `fk_maintenance_*`) trên 5 bảng. Trigger `trg_fill_created_by` (`BEFORE INSERT`, hàm `trg_fn_fill_created_by`) điền `created_by_user_id` từ biến phiên `app.current_user_id` và **từ chối** (lỗi `P0001`, `BR-23`) nếu biến chưa được đặt; trigger `trg_set_updated_by` (`BEFORE UPDATE`, hàm `trg_fn_set_updated_by`) luôn ghi `updated_by_user_id`/`updated_at` từ phiên và cấm đổi `created_by_user_id`. Mọi chương trình ghi dữ liệu phải `SET [LOCAL] app.current_user_id = '<user_id>'` (ứng dụng làm việc này trong `db_tx`; bộ lập lịch qua `PGOPTIONS`, biến `SCHEDULER_ACTOR_USER_ID`, mặc định 3; các script test đặt ở đầu tập tin). **Thực thi đầy đủ ở CSDL:** gọi `sp_process_subscription_renewals` hay chạy DML thủ công mà không đặt biến phiên sẽ bị từ chối theo thiết kế. |
| **BR-24** | Tự động Gia hạn & Ân hạn | Hợp đồng tự gia hạn (`is_recurring = TRUE`) khi quá hạn sẽ phát sinh hóa đơn gia hạn `Pending`; nếu quá thời gian ân hạn (mặc định 3 ngày) chưa thanh toán thì chuyển `Suspended`; hợp đồng không tự gia hạn quá hạn chuyển `Expired`. Khi hóa đơn gia hạn được thanh toán, hợp đồng được cộng thêm `duration_days`, đặt lại số buổi PT và kích hoạt lại. | Thủ tục `sp_process_subscription_renewals(p_as_of DATE DEFAULT CURRENT_DATE, p_grace_days INT DEFAULT 3)` (idempotent) được **bộ lập lịch bên ngoài gọi định kỳ**: trong Docker demo là service `scheduler` (container `fitzone_renewal_scheduler`, image `postgres:16-alpine`, vòng lặp shell chạy ngay khi khởi động rồi lặp lại mỗi `RENEWAL_INTERVAL_SECONDS` giây, mặc định 86400, đăng nhập bằng `gym_u_reception` có `EXECUTE`); trong production dùng `pg_cron` hoặc cron của hệ điều hành (ví dụ `SELECT cron.schedule('gym-renewals', '5 0 * * *', 'CALL sp_process_subscription_renewals()')`). Phần thanh toán gia hạn do `trg_activate_on_payment_insert/_update`. Lưu ý: PostgreSQL không có bộ lập lịch tích hợp, nên quy tắc theo thời gian chỉ chạy khi bộ lập lịch bên ngoài đang hoạt động. |
| **BR-25** | Chính sách Hủy Ca PT | Buổi PT chỉ bị trừ khi hoàn thành, không trừ lúc đặt lịch. Hủy sớm (còn từ 24 giờ trở lên) → `Cancelled`, **không trừ** buổi. Hủy muộn (còn dưới 24 giờ) → `Late_Cancelled` và **bị trừ** 1 buổi. Bỏ tập (`No_Show`) và `Completed` cũng bị trừ 1 buổi; chuyển giữa các trạng thái tính phí không trừ lần hai. | `trg_late_cancel_pt_booking` (`BEFORE UPDATE OF status ON pt_booking`, hàm `trg_fn_late_cancel_pt_booking`) đổi `Cancelled` thành `Late_Cancelled` khi hủy ca `Scheduled` còn dưới 24 giờ; `trg_update_remaining_pt_sessions` trừ `remaining_sessions` khi ca chuyển sang `Completed`/`No_Show`/`Late_Cancelled`; `chk_pt_booking_status` (miền trạng thái gồm `Late_Cancelled`). |
| **BR-26** | Theo dõi Khấu hao Thiết bị | Mỗi thiết bị phải ghi nhận ngày đưa vào sử dụng (`purchase_date`) và thời gian khấu hao dự kiến theo tháng (`depreciation_months > 0`). | `purchase_date DATE NOT NULL`; `chk_equipment_depreciation` (`CHECK`); `uq_equipment_serial` (`UNIQUE (serial_number)`); `chk_equipment_status`. |

#### 1.2.1. Tổng hợp mức độ thực thi

- **Thực thi đầy đủ ở CSDL:** BR-01 đến BR-23 (BR-10 với bốn lớp bảo vệ; BR-19 gồm cả chiều chặn chuyển sang bảo trì khi còn lịch tương lai và đồng bộ trạng thái thiết bị theo `maintenance_log`; BR-22 ở mức CSDL; BR-23 bắt buộc `created_by_user_id` và ghi vết `UPDATE`), BR-25, BR-26.
- **Thực thi đầy đủ khi có bộ lập lịch ngoài:** BR-24 (logic nằm trong thủ tục; demo Docker có container `scheduler` gọi hằng ngày, production dùng `pg_cron`/cron).
- **Các lưu ý còn lại (không phải quy tắc thực thi một phần):**
  - **Superuser là gốc tin cậy** của mọi DBMS: với BR-10 chỉ superuser mới tắt được event trigger (`ALTER EVENT TRIGGER ... DISABLE`) hoặc đặt `app.allow_billing_maintenance = 'on'`, thao tác tường minh và để lại dấu vết. Chạy lại `04_triggers_views.sql` trên CSDL đã có event trigger cũng cần lối thoát này.
  - **BR-22:** bảng `role_permission` (dữ liệu ma trận cho ứng dụng) và các lệnh `GRANT` được viết tay tương ứng, không tự đồng bộ.
  - **BR-23:** mọi chương trình ghi dữ liệu phải đặt `app.current_user_id`; chạy thủ công cần `SET app.current_user_id = '<id>'` trước.

## 2. Thiết kế cơ sở dữ liệu (Database Design – ISO/IEC 19505 / IE Standards)

Mô hình khái niệm được vẽ theo ký hiệu EER của Elmasri & Navathe (độc lập DBMS); theo yêu cầu của tài liệu chuẩn, nhóm kèm **sơ đồ vật lý IE Crow's Foot** sinh trực tiếp từ DDL và **Mapping Appendix** (Phụ lục A) chuyển từ EER sang lược đồ quan hệ. Mục 2.2 là lược đồ logic 18 quan hệ, mục 2.3 là chứng minh chuẩn hóa.

### 2.1. Mô hình Quan niệm – Sơ đồ ER/EER (Conceptual Model – ER/EER Diagram)

Mô hình quan niệm của hệ thống **Gym Membership & Personal Training Planner** được vẽ theo ký hiệu **Elmasri & Navathe (EER)**, độc lập với DBMS. Sơ đồ vật lý (IE Crow's Foot) ở mục 2.1.6 được sinh trực tiếp từ lược đồ thật `Phase 3/01_schema_ddl.sql`, bảo đảm khớp 100% với DDL.

#### 2.1.1. Chú giải ký hiệu (Notation legend)

*Bảng 2-1. Chú giải ký hiệu (Notation legend)*

| Ký hiệu | Ý nghĩa |
| --- | --- |
| Hình chữ nhật | Kiểu thực thể (entity type) |
| Hình thoi | Kiểu quan hệ (relationship type) |
| Hình oval | Thuộc tính; <u>gạch chân</u> = thuộc tính khóa; oval nét đứt = thuộc tính dẫn xuất (derived) |
| Đường đơn / đường đôi | Tham gia riêng phần (partial) / tham gia toàn phần (total) |
| 1, N, M | Tỷ số lực lượng (cardinality ratio) |
| Vòng tròn `o` + ký hiệu ⊂ | Chuyên biệt hóa **chồng lấn (overlapping)**; ⊂ hướng về lớp con |
| Vòng tròn `XOR` nét đứt | Cung loại trừ (exclusive arc) |

#### 2.1.2. Sơ đồ EER (Elmasri)

![Sơ đồ EER (ký hiệu Elmasri & Navathe) của hệ thống Gym Membership & PT Planner](Phase%202/database_design/1_conceptual_er_eer_model/3_eer_diagram.png)

*Hình 2-1. Sơ đồ EER (ký hiệu Elmasri & Navathe) của hệ thống Gym Membership & PT Planner*

(Bản vector: 3_eer_diagram.svg; mã nguồn Graphviz: 3_eer_diagram.dot.)

#### 2.1.3. Các kiểu thực thể (Entity types)

Gạch chân/(PK) là khóa; (D) là thuộc tính dẫn xuất.

##### Phân hệ Phân quyền & Tài khoản (RBAC)

*Bảng 2-2. Phân hệ Phân quyền & Tài khoản (RBAC)*

| Thực thể | Thuộc tính | Khóa |
| --- | --- | --- |
| **USER_ACCOUNT** | user_id, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at | PK `user_id`; khóa ứng viên `email`, `phone` |
| **ROLE** | role_id, role_name, description | PK `role_id`; `role_name` duy nhất |
| **PERMISSION** | permission_id, permission_code, module_name, description | PK `permission_id`; `permission_code` duy nhất |
| **MEMBER** (lớp con) | health_notes (+ kế thừa USER_ACCOUNT) | `user_id` kế thừa |
| **TRAINER** (lớp con) | specialization, bio, current_rating | `user_id` kế thừa |
| **STAFF** (lớp con) | job_title, department | `user_id` kế thừa |

##### Phân hệ Gói tập & Thanh toán

*Bảng 2-3. Phân hệ Gói tập & Thanh toán*

| Thực thể | Thuộc tính | Khóa |
| --- | --- | --- |
| **MEMBERSHIP_PLAN** | plan_id, plan_name, duration_days, total_sessions, price, description | PK `plan_id` |
| **MEMBER_SUBSCRIPTION** | subscription_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at | PK `subscription_id` |
| **BILLING_LOG** | billing_id, invoice_no, billing_period_start, amount, payment_date, payment_method, payment_status, created_at | PK `billing_id`; `invoice_no` duy nhất |

##### Phân hệ Lịch tập & Đặt chỗ

*Bảng 2-4. Phân hệ Lịch tập & Đặt chỗ*

| Thực thể | Thuộc tính | Khóa |
| --- | --- | --- |
| **CLASS_SCHEDULE** | class_id, class_name, start_time, end_time, max_capacity, **current_enrolled (D)** | PK `class_id` |
| **PT_BOOKING** | booking_id, booking_date, start_time, end_time, status, created_at | PK `booking_id` |

`current_enrolled` là thuộc tính **dẫn xuất** (= số ghi nhận CLASS_ENROLLMENT trạng thái `Enrolled`), được lưu vật lý và duy trì bằng trigger để chặn vượt sức chứa (BR liên quan `chk_class_enrollment_limit`).

##### Phân hệ Cơ sở vật chất & Bảo trì

*Bảng 2-5. Phân hệ Cơ sở vật chất & Bảo trì*

| Thực thể | Thuộc tính | Khóa |
| --- | --- | --- |
| **FACILITIES_ROOM** | room_id, room_name, room_type, max_capacity, status | PK `room_id` |
| **EQUIPMENT** | equipment_id, equipment_name, serial_number, purchase_date, depreciation_months, status | PK `equipment_id`; `serial_number` duy nhất |
| **EQUIPMENT_RESERVATION** | reservation_id, start_time, end_time, status | PK `reservation_id` |
| **MAINTENANCE_LOG** | maintenance_id, issue_description, start_time, end_time, cost, status, created_at | PK `maintenance_id` |

#### 2.1.4. Các kiểu quan hệ (Relationship types)

*Bảng 2-6. Các kiểu quan hệ (Relationship types)*

| Quan hệ | Thực thể tham gia | Tỷ số | Tham gia | BR nguồn |
| --- | --- | --- | --- | --- |
| HAS_ROLE | USER_ACCOUNT – ROLE | M:N | USER_ACCOUNT: toàn phần (mọi tài khoản có ≥1 vai trò); ROLE: riêng phần | BR-22 |
| GRANTS | ROLE – PERMISSION | M:N | riêng phần cả hai | BR-22 |
| SUBSCRIBES | MEMBER – MEMBER_SUBSCRIPTION | 1:N | SUBSCRIPTION toàn phần; MEMBER riêng phần | Hội viên có thể có nhiều hợp đồng theo thời gian; tối đa 1 hợp đồng Active (index `uq_member_one_active_subscription`) |
| OF_PLAN | MEMBERSHIP_PLAN – MEMBER_SUBSCRIPTION | 1:N | SUBSCRIPTION toàn phần | Hợp đồng gắn đúng một gói |
| GENERATES | MEMBER_SUBSCRIPTION – BILLING_LOG | 1:N | BILLING_LOG toàn phần | BR-24 (hóa đơn gia hạn, bất biến) |
| BOOKS | MEMBER – PT_BOOKING | 1:N | PT_BOOKING toàn phần | BR đặt ca PT |
| CONDUCTS | TRAINER – PT_BOOKING | 1:N | PT_BOOKING toàn phần | BR chống trùng lịch PT (`ex_pt_trainer_no_overlap`) |
| CONSUMES | MEMBER_SUBSCRIPTION – PT_BOOKING | 1:N | PT_BOOKING toàn phần | BR-25 (trừ/hoàn buổi PT) |
| TEACHES | TRAINER – CLASS_SCHEDULE | 1:N | CLASS toàn phần | BR chống trùng lịch HLV (`ex_class_trainer_no_overlap`) |
| HOSTS | FACILITIES_ROOM – CLASS_SCHEDULE | 1:N | CLASS toàn phần | `ex_class_room_no_overlap` |
| ENROLLS_IN | MEMBER_SUBSCRIPTION – CLASS_SCHEDULE | M:N (thuộc tính: enrollment_date, status) | riêng phần | BR ghi danh lớp, sức chứa |
| CONTAINS | FACILITIES_ROOM – EQUIPMENT | 1:N | EQUIPMENT toàn phần | BR-26 |
| REPAIRED_IN | EQUIPMENT – MAINTENANCE_LOG | 1:N | MAINTENANCE_LOG toàn phần | BR-20 |
| PERFORMS | STAFF – MAINTENANCE_LOG | 1:N | MAINTENANCE_LOG toàn phần | BR-20 |
| RESERVED_FOR | EQUIPMENT – EQUIPMENT_RESERVATION | 1:N | RESERVATION toàn phần | BR-21 (`ex_reservation_equipment_no_overlap`) |
| FOR_BOOKING / FOR_CLASS | PT_BOOKING (hoặc CLASS_SCHEDULE) – EQUIPMENT_RESERVATION | 1:N, **loại trừ XOR** | riêng phần | BR-21, `chk_reservation_source` |
| CREATED_BY / UPDATED_BY | USER_ACCOUNT – {MEMBER_SUBSCRIPTION, BILLING_LOG, CLASS_SCHEDULE, PT_BOOKING, MAINTENANCE_LOG} | 1:N (mỗi quan hệ 2 khóa ngoại) | CREATED_BY toàn phần (`created_by_user_id` NOT NULL); UPDATED_BY riêng phần (`updated_by_user_id` cho phép NULL, kèm `updated_at`) | BR-23 |

Quan hệ CREATED_BY/UPDATED_BY (5 cặp quan hệ cùng mẫu) không vẽ thành đường trên sơ đồ EER để tránh rối; chúng được ghi trong hộp chú thích màu tím cạnh USER_ACCOUNT và thể hiện đầy đủ ở sơ đồ vật lý (10 khóa ngoại `fk_*_created_by` và `fk_*_updated_by`).

##### Cung loại trừ (Exclusive arc) của EQUIPMENT_RESERVATION

Mỗi lượt giữ chỗ thiết bị thuộc về **đúng một** nguồn: hoặc một ca `PT_BOOKING` hoặc một `CLASS_SCHEDULE`, không bao giờ cả hai và không bao giờ không có nguồn nào. Mô hình hóa bằng hai khóa ngoại cùng nullable `booking_id`, `class_id` cùng ràng buộc `chk_reservation_source` (XOR). Trên sơ đồ, hai quan hệ FOR_BOOKING và FOR_CLASS nối vào vòng tròn XOR rồi vào EQUIPMENT_RESERVATION.

#### 2.1.5. Chuyên biệt hóa USER_ACCOUNT → MEMBER / TRAINER / STAFF

- **Ràng buộc: chồng lấn (overlapping), riêng phần (partial)** — ký hiệu vòng tròn `o`, đường đơn từ siêu lớp.
- **Chồng lấn:** BR-22 cho phép một tài khoản giữ nhiều vai trò (bảng `user_role` M:N), và lược đồ không có ràng buộc cấm một `user_id` xuất hiện đồng thời trong `member_profile`, `trainer_profile` và `staff_profile` (ba bảng cùng dùng khóa chính chia sẻ `user_id`). Vì vậy một PT hoặc nhân viên cũng có thể đồng thời là hội viên. Dữ liệu mẫu hiện tại chưa có người dùng nào giữ hai hồ sơ, nhưng ràng buộc `disjoint` sẽ làm sai BR-22.
- **Riêng phần:** tài khoản Admin (user 1–2) chỉ có vai trò, không có hồ sơ nào trong ba bảng con; vậy không phải mọi USER_ACCOUNT đều thuộc một lớp con (nếu toàn phần thì Admin phải có hồ sơ).
- Thuộc tính định danh/đăng nhập nằm ở siêu lớp; lớp con chỉ thêm thuộc tính riêng.

#### 2.1.6. Sơ đồ vật lý (IE Crow's Foot)

![Sơ đồ vật lý IE Crow's Foot của 18 bảng (sinh từ `Phase 3/01_schema_ddl.sql`)](Phase%202/database_design/1_conceptual_er_eer_model/4_physical_crows_foot.png)

*Hình 2-2. Sơ đồ vật lý IE Crow's Foot của 18 bảng (sinh từ `Phase 3/01_schema_ddl.sql`)*

(Bản vector: 4_physical_crows_foot.svg.) Sơ đồ gồm đủ 18 bảng với tên đầy đủ, mọi cột, kiểu dữ liệu, ký hiệu PK/FK/UQ, cột `null`; đầu đường nối: chân chim = phía nhiều, vạch = đúng một, vòng tròn = tùy chọn (0). Các cột mới `created_by_user_id` (5 bảng) và `billing_log.billing_period_start` đã xuất hiện.

**Cách tái sinh sơ đồ vật lý** (cần docker và python3):

```bash
cd "Phase 2/database_design/1_conceptual_er_eer_model"
./generate_physical_diagram.sh        # DPI=100 ./generate_physical_diagram.sh để ảnh nét hơn
```

Script tạo container tạm `g9_eer_db` (`postgres:16-alpine`), nạp riêng `Phase 3/01_schema_ddl.sql`, đọc catalog, sinh DOT rồi render bằng Graphviz (`g9_eer_dot`), và tự xóa container khi kết thúc. Sơ đồ EER được render từ `3_eer_diagram.dot` bằng `neato -n2 -Tsvg` / `neato -Tpng` (vị trí các nút được ghim thủ công).

Ánh xạ từ EER sang lược đồ quan hệ xem 4_mapping_appendix.md.

### 2.2. Ánh xạ Lược đồ Logic (Logical Schema Mapping)

Mục này trình bày 18 lược đồ quan hệ thu được sau khi ánh xạ mô hình EER sang mô hình quan hệ, khớp với `01_schema_ddl.sql`. Quy ước ký hiệu:

- <u>gạch chân</u> = khóa chính (PK); khóa chính ghép liệt kê đủ các thuộc tính cùng gạch chân.
- `FK` = khóa ngoại, ghi dạng `thuộc_tính --> BẢNG(thuộc_tính)` kèm hành động `ON DELETE`.
- `AK` = khóa phụ / khóa dự tuyển (UNIQUE). Chỉ mục duy nhất **một phần** (partial UNIQUE) được ghi riêng là `UNIQUE (…) WHERE …` vì không phải khóa dự tuyển trên toàn bộ bản ghi.
- `EXCLUDE` = ràng buộc loại trừ chồng lấn khoảng thời gian (GiST, cần extension `btree_gist`); `CHECK` = ràng buộc miền / liên thuộc tính.
- Các khóa ngoại `created_by_user_id` (`NOT NULL`) và `updated_by_user_id` (cho phép `NULL`, kèm `updated_at`) (BR-23) là thuộc tính vết kiểm toán, trỏ về `USER_ACCOUNT` (người thực hiện thao tác bất kỳ vai trò nào); mọi lần tạo/sửa dữ liệu giao dịch đều gắn với một người dùng.

#### Phân hệ Tài khoản & Phân quyền RBAC

- **USER_ACCOUNT** (<u>user_id</u>, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at)
  - AK: `email` (`uq_user_account_email`), `phone` (`uq_user_account_phone`)
  - CHECK: `status IN ('Active','Inactive','Suspended')`
- **ROLE** (<u>role_id</u>, role_name, description)
  - AK: `role_name` (`uq_role_name`)
- **USER_ROLE** (<u>user_id, role_id</u>)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE
  - FK: `role_id --> ROLE(role_id)` ON DELETE CASCADE
- **PERMISSION** (<u>permission_id</u>, permission_code, module_name, description)
  - AK: `permission_code` (`uq_permission_code`)
- **ROLE_PERMISSION** (<u>role_id, permission_id</u>)
  - FK: `role_id --> ROLE(role_id)` ON DELETE CASCADE
  - FK: `permission_id --> PERMISSION(permission_id)` ON DELETE CASCADE

#### Phân hệ Hồ sơ Chuyên biệt (Shared Primary Key)

- **MEMBER_PROFILE** (<u>user_id</u>, health_notes)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE
- **TRAINER_PROFILE** (<u>user_id</u>, specialization, bio, current_rating)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE
  - CHECK: `0.00 <= current_rating <= 5.00`
- **STAFF_PROFILE** (<u>user_id</u>, job_title, department)
  - FK: `user_id --> USER_ACCOUNT(user_id)` ON DELETE CASCADE

#### Phân hệ Gói tập & Thanh toán

- **MEMBERSHIP_PLAN** (<u>plan_id</u>, plan_name, duration_days, total_sessions, price, description)
  - CHECK: `duration_days > 0`, `total_sessions >= 0`, `price >= 0`
- **MEMBER_SUBSCRIPTION** (<u>subscription_id</u>, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, created_by_user_id, updated_by_user_id, updated_at)
  - FK: `member_user_id --> MEMBER_PROFILE(user_id)` ON DELETE RESTRICT (`fk_subscription_member`)
  - FK: `plan_id --> MEMBERSHIP_PLAN(plan_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_subscription_created_by`)
  - FK: `updated_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_subscription_updated_by`)
  - AK (siêu khóa phục vụ khóa ngoại ghép): `(subscription_id, member_user_id)` (`uq_subscription_member`)
  - UNIQUE một phần: `(member_user_id) WHERE sub_status = 'Active'` (`uq_member_one_active_subscription`, BR-05)
  - CHECK: `actual_price >= 0`, `remaining_sessions >= 0`, `end_time >= start_time`, `sub_status IN ('Pending','Active','Expired','Suspended','Cancelled')`
- **BILLING_LOG** (<u>billing_id</u>, subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status, created_at, created_by_user_id, updated_by_user_id, updated_at)
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_billing_created_by`)
  - FK: `updated_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_billing_updated_by`)
  - AK: `invoice_no` (`uq_billing_invoice_no`)
  - UNIQUE một phần: `(subscription_id, billing_period_start) WHERE payment_status IN ('Pending','Completed')` (`uq_billing_subscription_period`, BR-08). **Không** phải khóa dự tuyển vì hóa đơn `Failed`/`Refunded` được phép lặp chu kỳ.
  - CHECK: `amount > 0`, `payment_method IN ('Cash','Credit_Card','Banking','E_Wallet')`, `payment_status IN ('Pending','Completed','Failed','Refunded')`

#### Phân hệ Lịch tập & Đặt chỗ

- **FACILITIES_ROOM** (<u>room_id</u>, room_name, max_capacity, room_type, status)
  - CHECK: `max_capacity > 0`, `status IN ('Active','Under_Maintenance','Inactive')`
- **CLASS_SCHEDULE** (<u>class_id</u>, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled, created_by_user_id, updated_by_user_id, updated_at)
  - FK: `trainer_user_id --> TRAINER_PROFILE(user_id)` ON DELETE RESTRICT
  - FK: `room_id --> FACILITIES_ROOM(room_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_class_created_by`)
  - FK: `updated_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_class_updated_by`)
  - EXCLUDE: `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` (`ex_class_trainer_no_overlap`)
  - EXCLUDE: `(room_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)` (`ex_class_room_no_overlap`)
  - CHECK: `end_time > start_time`, `max_capacity > 0`, `current_enrolled >= 0`, `current_enrolled <= max_capacity`
- **CLASS_ENROLLMENT** (<u>enrollment_id</u>, subscription_id, class_id, enrollment_date, status)
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)` ON DELETE CASCADE
  - FK: `class_id --> CLASS_SCHEDULE(class_id)` ON DELETE CASCADE
  - AK: `(subscription_id, class_id)` (`uq_enrollment_subscription_class`)
  - CHECK: `status IN ('Enrolled','Cancelled','Attended')`
- **PT_BOOKING** (<u>booking_id</u>, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at, created_by_user_id, updated_by_user_id, updated_at)
  - FK: `member_user_id --> MEMBER_PROFILE(user_id)` ON DELETE RESTRICT (`fk_booking_member`)
  - FK: `trainer_user_id --> TRAINER_PROFILE(user_id)` ON DELETE RESTRICT (`fk_booking_trainer`)
  - FK: `subscription_id --> MEMBER_SUBSCRIPTION(subscription_id)` ON DELETE RESTRICT (`fk_booking_subscription`)
  - FK ghép: `(subscription_id, member_user_id) --> MEMBER_SUBSCRIPTION(subscription_id, member_user_id)` ON DELETE RESTRICT (`fk_booking_subscription_member`), bảo đảm ca PT luôn ghi đúng chủ hợp đồng
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_booking_created_by`)
  - FK: `updated_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_booking_updated_by`)
  - EXCLUDE: `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled','Late_Cancelled'))` (`ex_pt_trainer_no_overlap`)
  - EXCLUDE: `(member_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled','Late_Cancelled'))` (`ex_pt_member_no_overlap`)
  - CHECK: `end_time > start_time`, `booking_date = start_time::DATE` (`chk_pt_booking_date`), `status IN ('Scheduled','Completed','Cancelled','Late_Cancelled','No_Show')`

#### Phân hệ Thiết bị & Bảo trì

- **EQUIPMENT** (<u>equipment_id</u>, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status)
  - FK: `room_id --> FACILITIES_ROOM(room_id)` ON DELETE RESTRICT
  - AK: `serial_number` (`uq_equipment_serial`)
  - CHECK: `depreciation_months > 0`, `status IN ('Operational','Under_Maintenance','Decommissioned')`
- **EQUIPMENT_RESERVATION** (<u>reservation_id</u>, equipment_id, booking_id, class_id, start_time, end_time, status)
  - FK: `equipment_id --> EQUIPMENT(equipment_id)` ON DELETE CASCADE
  - FK: `booking_id --> PT_BOOKING(booking_id)` ON DELETE CASCADE (cho phép NULL)
  - FK: `class_id --> CLASS_SCHEDULE(class_id)` ON DELETE CASCADE (cho phép NULL)
  - EXCLUDE: `(equipment_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status <> 'Cancelled')` (`ex_reservation_equipment_no_overlap`)
  - CHECK: `end_time > start_time`, `status IN ('Reserved','Completed','Cancelled')`, đúng một trong `booking_id`, `class_id` khác NULL (`chk_reservation_source`)
- **MAINTENANCE_LOG** (<u>maintenance_id</u>, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status, created_at, created_by_user_id, updated_by_user_id, updated_at)
  - FK: `equipment_id --> EQUIPMENT(equipment_id)` ON DELETE RESTRICT
  - FK: `staff_user_id --> STAFF_PROFILE(user_id)` ON DELETE RESTRICT
  - FK: `created_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_maintenance_created_by`)
  - FK: `updated_by_user_id --> USER_ACCOUNT(user_id)` ON DELETE RESTRICT (`fk_maintenance_updated_by`)
  - CHECK: `cost >= 0`, `status IN ('In_Progress','Completed','Cancelled')`, `end_time IS NULL OR end_time >= start_time`

### 2.3. Chứng minh Chuẩn hóa Dữ liệu (Normalization Verification: 1NF -> 3NF/BCNF)

Mục này chứng minh hình thức (formal proof) dạng chuẩn của **từng lược đồ quan hệ** trong số 18 bảng của `01_schema_ddl.sql`. Với mỗi bảng, nhóm liệt kê tập phụ thuộc hàm (Functional Dependencies – FD), xác định các khóa dự tuyển bằng phép tính bao đóng, rồi kiểm tra lần lượt các điều kiện 1NF → 2NF → 3NF → BCNF theo định nghĩa của Elmasri & Navathe (*Fundamentals of Database Systems*, Chương 14).

#### 2.3.1. Định nghĩa và phương pháp

##### Ký hiệu

*Bảng 2-7. Ký hiệu*

| Ký hiệu | Ý nghĩa |
| --- | --- |
| `X → Y` | Phụ thuộc hàm: hai bộ bất kỳ trùng giá trị trên `X` thì trùng giá trị trên `Y` |
| `X⁺` | Bao đóng của `X`: tập mọi thuộc tính suy ra được từ `X` theo hệ tiên đề Armstrong |
| <u>gạch chân</u> | Khóa chính (Primary Key) |
| Thuộc tính khóa (prime) | Thuộc tính thuộc ít nhất một khóa dự tuyển |
| Thuộc tính không khóa (non-prime) | Thuộc tính không thuộc khóa dự tuyển nào |

##### Định nghĩa các dạng chuẩn

*Bảng 2-8. Định nghĩa các dạng chuẩn*

| Dạng chuẩn | Điều kiện (Elmasri) |
| --- | --- |
| **1NF** | Miền giá trị của mọi thuộc tính là nguyên tố; không có thuộc tính đa trị, thuộc tính phức hợp hay quan hệ lồng nhau. |
| **2NF** | Đạt 1NF, và mọi thuộc tính không khóa phụ thuộc hàm **đầy đủ** vào mọi khóa dự tuyển (không phụ thuộc vào một tập con thực sự của khóa). |
| **3NF** | Với mọi FD không tầm thường `X → A`: hoặc `X` là siêu khóa, hoặc `A` là thuộc tính khóa. Tương đương: không có thuộc tính không khóa nào phụ thuộc **bắc cầu** vào khóa. |
| **BCNF** | Với mọi FD không tầm thường `X → A`: `X` là siêu khóa. |

##### Quy trình áp dụng cho mỗi bảng

1. **Xác định tập FD `F`** từ ngữ nghĩa nghiệp vụ (Phase 1) và các ràng buộc `PRIMARY KEY`, `UNIQUE`, `EXCLUDE` trong DDL.
2. **Tìm khóa dự tuyển:** với mỗi ứng viên `K`, tính `K⁺`. Nếu `K⁺` = toàn bộ thuộc tính và không tập con thực sự nào của `K` có tính chất này, thì `K` là khóa dự tuyển.
3. **Kiểm tra 1NF** dựa trên kiểu dữ liệu của cột.
4. **Kiểm tra 2NF:** chỉ cần xét khi có khóa dự tuyển gồm từ 2 thuộc tính trở lên. Bảng mà mọi khóa dự tuyển chỉ có 1 thuộc tính thì đạt 2NF ngay khi đạt 1NF.
5. **Kiểm tra BCNF** (từ đó suy ra 3NF): duyệt mọi FD trong `F` và kiểm tra vế trái có phải siêu khóa hay không.

##### Bổ đề dùng chung

> **Bổ đề 1.** Nếu mọi FD không tầm thường của `R` đều có dạng `K → A` với `K` là một khóa dự tuyển, thì `R` đạt BCNF (và do đó đạt 3NF, 2NF).

> *Chứng minh:* Theo định nghĩa, khóa dự tuyển là siêu khóa, nên mọi FD đều thỏa điều kiện BCNF. Theo Elmasri, BCNF ⇒ 3NF ⇒ 2NF. ∎

> **Bổ đề 2.** Mọi bảng đều đạt 1NF.

> *Chứng minh:* Theo DDL, toàn bộ cột có kiểu vô hướng (`SERIAL`, `INT`, `VARCHAR`, `TEXT`, `DATE`, `TIMESTAMP`, `DECIMAL`, `BOOLEAN`). Không có cột kiểu mảng (`ARRAY`), `JSON` hay kiểu phức hợp. Các thuộc tính đa trị trong mô hình khái niệm đã được tách thành bảng riêng khi ánh xạ:

- vai trò của người dùng → `user_role`;
- quyền của vai trò → `role_permission`;
- danh sách lớp hội viên đăng ký → `class_enrollment`;
- danh sách thiết bị giữ chỗ cho một buổi tập → `equipment_reservation`.
> Các cột chứa văn bản tự do (`health_notes`, `bio`, `description`, `issue_description`) được hệ thống xử lý như **một giá trị duy nhất**, không bao giờ tách ra để truy vấn từng phần, nên vẫn là nguyên tố. Cột `password_hash` lưu một chuỗi băm duy nhất. ∎

> **Bổ đề 3 (các cột và ràng buộc bổ sung của lược đồ hiện hành).** Ba nhóm thay đổi sau không làm đổi tập FD của bất kỳ bảng nào:

1. **Cột `created_by_user_id`** (5 bảng: `member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log`; BR-23) là thuộc tính khóa ngoại trỏ về `user_account` (`NOT NULL`: mọi dòng bắt buộc có người tạo), mang ý nghĩa vết kiểm toán *"ai đã thực hiện thao tác"*. Giá trị do trigger `trg_fill_created_by` điền từ biến phiên, không suy ra được từ bất kỳ thuộc tính nào khác (ví dụ lễ tân tạo hợp đồng không xác định bởi `member_user_id` hay `plan_id`). Vì vậy chỉ có FD tầm thường kiểu khóa `K → created_by_user_id` với `K` là khóa dự tuyển, bảng giữ nguyên dạng chuẩn. Tương tự `created_at` (mặc định `CURRENT_TIMESTAMP`) chỉ phụ thuộc vào khóa. Cặp cột `updated_by_user_id` (FK, cho phép `NULL`) và `updated_at` do trigger `trg_set_updated_by` ghi cũng là thuộc tính vết kiểm toán chỉ phụ thuộc khóa: không sinh FD mới, không phá chuẩn (một dòng một người sửa gần nhất).
2. **Miền giá trị trạng thái** (`CHECK ... IN (...)`), gồm cả bổ sung `'Late_Cancelled'` cho `pt_booking.status` (BR-25) và `'E_Wallet'` cho `billing_log.payment_method`: ràng buộc miền một thuộc tính **không phải là FD**, nên không ảnh hưởng đến 2NF/3NF/BCNF.
3. **Chỉ mục duy nhất một phần** (`uq_member_one_active_subscription`, `uq_billing_subscription_period`): chỉ ràng buộc một *tập con* bản ghi. Theo định nghĩa, khóa dự tuyển phải xác định duy nhất **mọi** bộ của quan hệ, nên chỉ mục duy nhất một phần **không** là khóa dự tuyển (xem chi tiết ở mục (10) và (11)). ∎

#### 2.3.2. Bảng tổng hợp kết quả

*Bảng 2-9. Bảng tổng hợp kết quả*

| # | Bảng | Khóa dự tuyển | 1NF | 2NF | 3NF | BCNF |
| --- | --- | --- | --- | --- | --- | --- |
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
| 11 | `billing_log` | `{billing_id}`, `{invoice_no}` (và chỉ mục duy nhất một phần `(subscription_id, billing_period_start)`, không phải khóa) | ✔ | ✔ | ✔ | ✔ |
| 12 | `facilities_room` | `{room_id}` | ✔ | ✔ | ✔ | ✔ |
| 13 | `equipment` | `{equipment_id}`, `{serial_number}` | ✔ | ✔ | ✔ | ✔ |
| 14 | `class_schedule` | `{class_id}`, `{trainer_user_id, start_time}`, `{room_id, start_time}` | ✔ | ✔ | ✔ | ✔ |
| 15 | `class_enrollment` | `{enrollment_id}`, `{subscription_id, class_id}` | ✔ | ✔ | ✔ | ✔ |
| 16 | `pt_booking` | `{booking_id}` | ✔ | ✔ | ✘ (chủ đích) | ✘ (chủ đích) |
| 17 | `equipment_reservation` | `{reservation_id}` | ✔ | ✔ | ✔ | ✔ |
| 18 | `maintenance_log` | `{maintenance_id}` | ✔ | ✔ | ✔ | ✔ |

**Kết luận tổng quát:** 17/18 bảng đạt **BCNF**. Bảng `pt_booking` chỉ đạt **2NF** về mặt hình thức do có 2 phụ thuộc bắc cầu, cả hai đều là **phi chuẩn hóa có kiểm soát** (không thể sinh dữ liệu mâu thuẫn):

- `subscription_id → member_user_id`: cần thiết để thực thi BR-16 bằng ràng buộc `EXCLUDE`, nhất quán được bảo đảm bằng khóa ngoại ghép `fk_booking_subscription_member`;
- `start_time → booking_date`: nhóm đã chọn **Cách 3** (giữ cột và khai báo `chk_pt_booking_date CHECK (booking_date = start_time::DATE)`), nên hai cột không thể lệch nhau.
Phân tích chi tiết và phương án tách về BCNF ở mục 2.3.4.

#### 2.3.3. Chứng minh chi tiết từng bảng

> Ở các bảng dưới đây, sau khi áp dụng Bổ đề 2 (1NF), nhóm chỉ trình bày tập FD, khóa dự tuyển và lập luận BCNF. Mục **"FD bị loại trừ"** ghi lại các phụ thuộc có vẻ hợp lý nhưng **không** đúng với nghiệp vụ, kèm lý do. Đây là cơ sở để khẳng định bảng không có phụ thuộc bắc cầu ẩn.

##### A. Phân hệ Tài khoản & Phân quyền (RBAC)

###### (1) USER_ACCOUNT(<u>user_id</u>, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at)

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

###### (2) ROLE(<u>role_id</u>, role_name, description)

- **FD:** `role_id → role_name, description`; `role_name → role_id` (`UNIQUE uq_role_name`).
- **Khóa dự tuyển:** `{role_id}`, `{role_name}`.
- **BCNF:** mọi vế trái đều là khóa ⇒ **BCNF**. ∎

###### (3) USER_ROLE(<u>user_id, role_id</u>)

- **FD:** chỉ có FD tầm thường. Bảng không có thuộc tính không khóa (*all-key relation*).
- **Khóa dự tuyển:** `{user_id, role_id}`. Tối thiểu vì một người dùng có thể giữ nhiều vai trò (BR-22) và một vai trò có nhiều người dùng, nên không thuộc tính đơn lẻ nào xác định thuộc tính còn lại.
- **2NF:** không có thuộc tính không khóa ⇒ không thể có phụ thuộc bộ phận.
- **BCNF:** không có FD không tầm thường ⇒ **BCNF**. ∎

###### (4) PERMISSION(<u>permission_id</u>, permission_code, module_name, description)

- **FD:** `permission_id → permission_code, module_name, description`; `permission_code → permission_id` (`UNIQUE uq_permission_code`).
- **Khóa dự tuyển:** `{permission_id}`, `{permission_code}`.
- **FD bị loại trừ:** `module_name ↛ permission_code`. Một phân hệ có nhiều quyền; ví dụ phân hệ `Member` có 3 quyền `MEMBER_VIEW`, `MEMBER_CREATE`, `MEMBER_EDIT`.
- **BCNF:** mọi vế trái đều là khóa ⇒ **BCNF**. ∎

###### (5) ROLE_PERMISSION(<u>role_id, permission_id</u>)

- Bảng all-key, lập luận giống (3) ⇒ **BCNF**. ∎

##### B. Phân hệ Hồ sơ chuyên biệt (lớp con EER, ánh xạ dùng chung khóa chính)

Ba bảng dưới đây là kết quả ánh xạ quan hệ chuyên biệt hóa `USER_ACCOUNT ⊃ {MEMBER, TRAINER, STAFF}` theo phương án **8A của Elmasri**: mỗi lớp con là một quan hệ riêng, dùng khóa chính của lớp cha làm khóa chính, đồng thời làm khóa ngoại. Các thuộc tính chung (họ tên, email, ngày sinh…) chỉ nằm ở `user_account`, nên không có dư thừa giữa lớp cha và lớp con.

###### (6) MEMBER_PROFILE(<u>user_id</u>, health_notes)

- **FD:** `user_id → health_notes`. **Khóa dự tuyển:** `{user_id}` ⇒ **BCNF**. ∎

###### (7) TRAINER_PROFILE(<u>user_id</u>, specialization, bio, current_rating)

- **FD:** `user_id → specialization, bio, current_rating`.
- **FD bị loại trừ:** `specialization ↛ current_rating`. Hai HLV cùng chuyên môn có điểm đánh giá khác nhau.
- **Khóa dự tuyển:** `{user_id}` ⇒ **BCNF**. ∎

###### (8) STAFF_PROFILE(<u>user_id</u>, job_title, department)

- **FD:** `user_id → job_title, department`.
- **FD bị loại trừ:** `job_title ↛ department`. Đây là điểm dễ gây nhầm là phụ thuộc bắc cầu. Nhóm quy ước nghiệp vụ: cùng một chức danh (ví dụ *Manager*, *Supervisor*) có thể tồn tại ở nhiều phòng ban, và một phòng ban có nhiều chức danh. Vì vậy `job_title` không xác định `department` và ngược lại.
  - *Nếu* phòng tập quy định mỗi chức danh chỉ thuộc một phòng ban, thì `user_id → job_title → department` là phụ thuộc bắc cầu. Khi đó phải tách thành `JOB_TITLE(job_title, department)` để đạt 3NF.
- **Khóa dự tuyển:** `{user_id}` ⇒ **BCNF** (theo quy ước trên). ∎

##### C. Phân hệ Gói tập & Thanh toán

###### (9) MEMBERSHIP_PLAN(<u>plan_id</u>, plan_name, duration_days, total_sessions, price, description)

- **FD:** `plan_id → plan_name, duration_days, total_sessions, price, description`.
- **FD bị loại trừ:** `duration_days ↛ price` (gói 30 ngày thường và gói 30 ngày dành cho sinh viên có giá khác nhau); `total_sessions ↛ price`.
- **Khóa dự tuyển:** `{plan_id}` ⇒ **BCNF**. ∎

###### (10) MEMBER_SUBSCRIPTION(<u>subscription_id</u>, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, created_by_user_id, updated_by_user_id, updated_at)

- **FD:** `subscription_id → member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, created_by_user_id, updated_by_user_id, updated_at`. Khóa ngoại `member_user_id` trỏ về `member_profile` (không phải `user_account`); `created_by_user_id` là FK vết kiểm toán, không tạo FD mới (Bổ đề 3).
- **FD bị loại trừ:** đây là bảng dễ bị nghi ngờ có phụ thuộc bắc cầu qua `plan_id` nhất, nên nhóm xét từng trường hợp:

*Bảng 2-10. (10) MEMBER_SUBSCRIPTION(subscription_id, member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring, created_at, created_by_user_id, updated_by_user_id, updated_at)*

| FD giả định | Vì sao KHÔNG đúng |
| --- | --- |
| `plan_id → actual_price` | `actual_price` là giá **chốt tại thời điểm ký hợp đồng** (ảnh chụp lịch sử). Khi `membership_plan.price` thay đổi hoặc có khuyến mãi, các hợp đồng cũ vẫn giữ giá cũ. Hai hợp đồng cùng `plan_id` có thể có `actual_price` khác nhau. |
| `plan_id → remaining_sessions` | Đây là trạng thái thay đổi theo từng hợp đồng (giảm dần khi trigger trừ buổi). Chỉ có giá trị khởi tạo bằng `total_sessions`. |
| `{plan_id, start_time} → end_time` | Ngày kết thúc có thể được gia hạn, bảo lưu hoặc điều chỉnh thủ công. **Kiểm chứng trên dữ liệu mẫu: 29/30 hợp đồng có `end_time ≠ start_time + duration_days`.** |
| `member_user_id → plan_id` | Một hội viên có nhiều hợp đồng theo thời gian (BR-05). |

- `uq_subscription_member UNIQUE (subscription_id, member_user_id)` là một **siêu khóa** (chứa khóa chính), không phải khóa dự tuyển. Ràng buộc này chỉ tồn tại để làm đích tham chiếu cho khóa ngoại ghép từ `pt_booking`.
- `uq_member_one_active_subscription` (UNIQUE một phần trên `member_user_id WHERE sub_status = 'Active'`, BR-05) cũng **không phải khóa dự tuyển**: một hội viên có nhiều hợp đồng ở trạng thái khác `Active`, nên `member_user_id` không xác định duy nhất mọi bộ. Nó là ràng buộc nghiệp vụ trên tập con bản ghi, không sinh FD `member_user_id → …` trên toàn bảng.
- **Khóa dự tuyển:** `{subscription_id}` ⇒ **BCNF**. ∎

###### (11) BILLING_LOG(<u>billing_id</u>, subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status, created_at, created_by_user_id, updated_by_user_id, updated_at)

- **FD:** `billing_id → *`; `invoice_no → billing_id` (`UNIQUE uq_billing_invoice_no`, BR-09).
- **FD bị loại trừ:** `subscription_id ↛ amount` (một hợp đồng có nhiều kỳ thanh toán với số tiền khác nhau).
- **Chỉ mục duy nhất một phần `uq_billing_subscription_period`:** `UNIQUE (subscription_id, billing_period_start) WHERE payment_status IN ('Pending', 'Completed')` (BR-08). Chỉ mục này trông giống một khóa dự tuyển `{subscription_id, billing_period_start}` nhưng **không phải**:
  - Khóa dự tuyển đòi hỏi `K → toàn bộ thuộc tính` đúng với **mọi** bộ của quan hệ. Ở đây mệnh đề `WHERE` loại các hóa đơn `Failed` và `Refunded` ra khỏi ràng buộc: một chu kỳ có thể có hóa đơn `Failed` (thanh toán lỗi) rồi hóa đơn `Completed` phát hành lại, hoặc `Completed` rồi `Refunded`, tức là **nhiều bộ cùng `(subscription_id, billing_period_start)`** nhưng khác `billing_id`, `invoice_no`, `amount`, `payment_status`. Do đó FD `{subscription_id, billing_period_start} → billing_id` **không đúng** trên toàn bảng và ta không được thêm nó vào tập `F`.
  - Hệ quả với dạng chuẩn: vì không có FD mới nào, tập `F` vẫn chỉ gồm các FD có vế trái là `billing_id` hoặc `invoice_no`, nên **BCNF vẫn đạt**. Ràng buộc này thuộc loại *ràng buộc toàn vẹn nghiệp vụ có điều kiện* (conditional uniqueness), được DBMS thực thi hiệu quả bằng partial unique index.
  - Thuộc tính `billing_period_start` (NOT NULL, do trigger `trg_fill_billing_period_start` mặc định bằng `start_time::DATE` của hợp đồng) chỉ phụ thuộc vào khóa; `subscription_id ↛ billing_period_start` vì một hợp đồng có nhiều chu kỳ.
  - Cột `created_by_user_id`, `updated_by_user_id`, `updated_at` là FK/thuộc tính vết kiểm toán, không tạo FD (Bổ đề 3). Miền `payment_status` (4 giá trị) và `payment_method` (4 giá trị gồm `E_Wallet`) là ràng buộc miền, không phải FD.
- **Khóa dự tuyển:** `{billing_id}`, `{invoice_no}`. Mọi vế trái đều là khóa ⇒ **BCNF**. ∎

##### D. Phân hệ Cơ sở vật chất & Lịch tập

###### (12) FACILITIES_ROOM(<u>room_id</u>, room_name, max_capacity, room_type, status)

- **FD:** `room_id → room_name, max_capacity, room_type, status`.
- **FD bị loại trừ:** `room_type ↛ max_capacity`. **Phản ví dụ trong dữ liệu mẫu:** có 2 phòng loại `Gym_Floor` với sức chứa khác nhau (40 và 35). `room_name` không có ràng buộc `UNIQUE` nên không phải khóa.
- **Khóa dự tuyển:** `{room_id}` ⇒ **BCNF**. ∎

###### (13) EQUIPMENT(<u>equipment_id</u>, room_id, equipment_name, serial_number, purchase_date, depreciation_months, status)

- **FD:** `equipment_id → *`; `serial_number → equipment_id` (`UNIQUE uq_equipment_serial`).
- **FD bị loại trừ:** `equipment_name ↛ depreciation_months` (cùng model máy, mua ở các thời điểm khác nhau có thể áp dụng chính sách khấu hao khác nhau).
- **Khóa dự tuyển:** `{equipment_id}`, `{serial_number}` ⇒ **BCNF**. ∎

###### (14) CLASS_SCHEDULE(<u>class_id</u>, trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled, created_by_user_id, updated_by_user_id, updated_at)

- **FD:**
  - F1: `class_id → *` (PK)
  - F2: `{trainer_user_id, start_time} → class_id`
  - F3: `{room_id, start_time} → class_id`
  - (`created_by_user_id` là FK vết kiểm toán, chỉ phụ thuộc khóa; Bổ đề 3.)
- **Chứng minh F2, F3 là FD:** ràng buộc `ex_class_trainer_no_overlap` cấm hai lớp của cùng một HLV có khoảng `[start_time, end_time)` giao nhau. Giả sử tồn tại hai bộ khác nhau `t1`, `t2` có `t1.trainer_user_id = t2.trainer_user_id` và `t1.start_time = t2.start_time`. Do `chk_class_time` bảo đảm `end_time > start_time`, cả hai khoảng đều chứa thời điểm `start_time`, nên hai khoảng giao nhau. Điều này mâu thuẫn với ràng buộc `EXCLUDE`. Vậy F2 đúng. F3 chứng minh tương tự với `ex_class_room_no_overlap`. ∎
- **Khóa dự tuyển:** `{class_id}`, `{trainer_user_id, start_time}`, `{room_id, start_time}`. Hai khóa ghép là tối thiểu vì một HLV dạy nhiều lớp ở các thời điểm khác nhau, và nhiều HLV có lớp bắt đầu cùng giờ.
- **2NF (có khóa ghép):** không thuộc tính không khóa nào phụ thuộc vào một phần của khóa ghép. `trainer_user_id` một mình không xác định `class_name` (HLV dạy nhiều lớp), và `start_time` một mình không xác định `room_id` (nhiều lớp cùng giờ ở các phòng khác nhau).
- **BCNF:** vế trái của F1–F3 đều là khóa ⇒ **BCNF**.
- **Ghi chú về `current_enrolled`:** cột này bằng `COUNT(*)` các bản ghi `class_enrollment` có trạng thái `Enrolled` hoặc `Attended`. Đây là **dữ liệu dẫn xuất giữa các bảng**, không phải FD bên trong `class_schedule`, nên không ảnh hưởng đến dạng chuẩn. Nhóm giữ cột này để có thể khai báo `CHECK (current_enrolled <= max_capacity)` (BR-14). Tính nhất quán được trigger `trg_sync_class_enrollment_count` bảo đảm, đã kiểm chứng ở test **TP-03** và **TP-04** (`Phase 3/07_test_results.md`). ∎

###### (15) CLASS_ENROLLMENT(<u>enrollment_id</u>, subscription_id, class_id, enrollment_date, status)

- **FD:** `enrollment_id → *`; `{subscription_id, class_id} → enrollment_id` (`UNIQUE uq_enrollment_subscription_class`).
- **Khóa dự tuyển:** `{enrollment_id}`, `{subscription_id, class_id}`.
- **2NF:** xét khóa ghép `{subscription_id, class_id}`:
  - `subscription_id ↛ status`: cùng một hợp đồng có thể `Attended` lớp này nhưng `Cancelled` lớp khác.
  - `class_id ↛ enrollment_date`: các hội viên đăng ký cùng một lớp vào các ngày khác nhau. ⇒ Không có phụ thuộc bộ phận.
- **BCNF:** mọi vế trái đều là khóa ⇒ **BCNF**. ∎

###### (16) PT_BOOKING – xem phân tích riêng ở mục 2.3.4.

###### (17) EQUIPMENT_RESERVATION(<u>reservation_id</u>, equipment_id, booking_id, class_id, start_time, end_time, status)

- **FD:** `reservation_id → *`.
- **FD bị loại trừ:** `booking_id ↛ start_time` và `class_id ↛ start_time`. Một buổi tập có thể giữ nhiều máy, mỗi máy cho một khung giờ con khác nhau trong buổi (ví dụ 15 phút máy chạy đầu buổi, 30 phút giàn tạ cuối buổi). Vì vậy thời gian giữ chỗ là thuộc tính riêng của lượt giữ chỗ, không suy ra được từ buổi tập.
- **1NF với cặp khóa ngoại loại trừ nhau:** `booking_id` và `class_id` là hai thuộc tính đơn trị có thể `NULL` (*exclusive arc*). `CHECK chk_reservation_source` bảo đảm đúng một trong hai có giá trị. `NULL` không phải giá trị đa trị nên không vi phạm 1NF.
- **Khóa dự tuyển:** `{reservation_id}` ⇒ **BCNF**. ∎

###### (18) MAINTENANCE_LOG(<u>maintenance_id</u>, equipment_id, staff_user_id, issue_description, start_time, end_time, cost, status, created_at, created_by_user_id, updated_by_user_id, updated_at)

- **FD:** `maintenance_id → *` (gồm `created_by_user_id`, FK vết kiểm toán; Bổ đề 3). `staff_user_id` trỏ về `staff_profile`.
- **FD bị loại trừ:** `equipment_id ↛ staff_user_id` (mỗi lần bảo trì có thể do kỹ thuật viên khác xử lý); `{equipment_id, start_time}` không được khai báo `UNIQUE` nên không phải khóa.
- **Khóa dự tuyển:** `{maintenance_id}` ⇒ **BCNF**. ∎

#### 2.3.4. Phân tích bảng PT_BOOKING (chỉ đạt 2NF) và quyết định thiết kế

**PT_BOOKING**(<u>booking_id</u>, member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at, created_by_user_id, updated_by_user_id, updated_at)

##### Tập phụ thuộc hàm

*Bảng 2-11. Tập phụ thuộc hàm*

| FD | Nguồn gốc |
| --- | --- |
| F1: `booking_id → member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status, created_at, created_by_user_id, updated_by_user_id, updated_at` | Khóa chính |
| F2: `subscription_id → member_user_id` | Mỗi hợp đồng thuộc đúng một hội viên. FD này được kéo theo từ `member_subscription`, nơi `subscription_id` là khóa. |
| F3: `start_time → booking_date` | `booking_date = start_time::DATE`. FD này **được DBMS bảo đảm** bởi `chk_pt_booking_date CHECK (booking_date = start_time::DATE)`; mọi bản ghi (hiện có và tương lai) đều thỏa. |

`created_by_user_id` là FK vết kiểm toán và `status` có thêm giá trị `'Late_Cancelled'` (BR-25); cả hai không sinh FD mới (Bổ đề 3).

##### Khóa dự tuyển

`{booking_id}⁺` = toàn bộ thuộc tính. Các ứng viên khác đều không phải khóa:

- `{subscription_id}`: một hợp đồng có nhiều ca PT;
- `{start_time}`: nhiều ca PT bắt đầu cùng giờ;
- `{trainer_user_id, start_time}`: ràng buộc `ex_pt_trainer_no_overlap` (và `ex_pt_member_no_overlap`) chỉ áp dụng cho bản ghi có `status NOT IN ('Cancelled', 'Late_Cancelled')`, nên một ca đã hủy và một ca mới có thể trùng cặp giá trị này (đã kiểm chứng ở test **TP-05**: ca `Cancelled` của HLV 5 không chặn ca mới cùng khung giờ). Tương tự các EXCLUDE chỉ có điều kiện, chúng không phải khóa dự tuyển.
⇒ **Khóa dự tuyển duy nhất là `{booking_id}`.**

##### Kiểm tra từng dạng chuẩn

- **1NF:** đạt (Bổ đề 2).
- **2NF:** khóa dự tuyển duy nhất có 1 thuộc tính ⇒ không thể có phụ thuộc bộ phận ⇒ **đạt 2NF**. Kết luận này **không thay đổi** sau khi thêm `chk_pt_booking_date`, vì FD `start_time → booking_date` vẫn tồn tại.
- **3NF:** xét F2 `subscription_id → member_user_id`: `subscription_id` không phải siêu khóa, và `member_user_id` là thuộc tính không khóa ⇒ chuỗi bắc cầu `booking_id → subscription_id → member_user_id` ⇒ **vi phạm 3NF**. F3 vi phạm tương tự qua `booking_id → start_time → booking_date` (`start_time` không phải siêu khóa, `booking_date` không khóa). Việc `CHECK` bảo đảm FD **đúng** không làm FD biến mất, nên về mặt hình thức bảng vẫn không đạt 3NF.
- **BCNF:** vi phạm (vì không đạt 3NF).
> **Trung thực về kết luận:** nhóm **không** tuyên bố `pt_booking` đạt 3NF/BCNF. Nhóm khẳng định điều yếu hơn nhưng quan trọng hơn trong thực tiễn: hai phụ thuộc bắc cầu còn lại đều là **dư thừa có kiểm soát**, CSDL từ chối mọi trạng thái mâu thuẫn.

##### Bất thường dữ liệu và cơ chế chặn

*Bảng 2-12. Bất thường dữ liệu và cơ chế chặn*

| Loại bất thường | Ví dụ | Trạng thái hiện hành |
| --- | --- | --- |
| Cập nhật (F2) | Chuyển hợp đồng sang hội viên khác mà chỉ sửa `member_subscription`, các ca PT cũ ghi sai hội viên. | **Bị chặn**: sửa `member_user_id` ở bảng cha khi đã có ca PT tham chiếu vi phạm `fk_booking_subscription_member` (`ON UPDATE` mặc định `NO ACTION`). |
| Chèn (F2) | Chèn ca PT có `member_user_id` khác chủ của `subscription_id`. | **Bị chặn**: `fk_booking_subscription_member`, lỗi `23503` (test **TC-29** trong `05_constraint_test_cases.sql`). |
| Cập nhật (F3) | Đổi `start_time` sang ngày khác nhưng quên sửa `booking_date`. | **Bị chặn**: `chk_pt_booking_date`, lỗi `23514`. (Trước đây đây là khuyến nghị chưa áp dụng.) |

##### Quyết định thiết kế

**(a) `member_user_id`: giữ lại, phi chuẩn hóa có kiểm soát.**

- *Lý do giữ:* BR-16 yêu cầu một hội viên không có 2 ca PT chồng giờ. Trong PostgreSQL, ràng buộc `EXCLUDE USING gist` chỉ tham chiếu được các cột **cùng bảng**. Nếu bỏ `member_user_id`, ràng buộc `ex_pt_member_no_overlap` không thể khai báo được, và BR-16 phải chuyển sang trigger, vốn chậm hơn và dễ sai khi có giao dịch đồng thời.
- *Cơ chế loại trừ bất thường:* khóa ngoại ghép

```sql
CONSTRAINT fk_booking_subscription_member FOREIGN KEY (subscription_id, member_user_id)
    REFERENCES member_subscription (subscription_id, member_user_id) ON DELETE RESTRICT
```

(đích tham chiếu là `uq_subscription_member UNIQUE (subscription_id, member_user_id)`, một siêu khóa của `member_subscription`) bảo đảm cặp `(subscription_id, member_user_id)` trong `pt_booking` **luôn trùng khớp** với `member_subscription`.

- ⇒ Dư thừa vẫn tồn tại về mặt lưu trữ, nhưng **không thể dẫn đến dữ liệu mâu thuẫn**.
**(b) `booking_date`: đã chọn Cách 3, giữ cột và áp dụng `CHECK`.**

Ba phương án đã được cân nhắc:

```sql
-- Cách 1 (chuẩn hóa triệt để): xóa cột, dùng start_time::DATE khi cần
ALTER TABLE pt_booking DROP COLUMN booking_date;

-- Cách 2: giữ cột nhưng để CSDL tự tính (cột sinh, không thể sai lệch)
ALTER TABLE pt_booking DROP COLUMN booking_date;
ALTER TABLE pt_booking ADD COLUMN booking_date DATE GENERATED ALWAYS AS (start_time::DATE) STORED;

-- Cách 3 (thay đổi tối thiểu): thêm ràng buộc kiểm tra   <== ĐÃ ÁP DỤNG trong 01_schema_ddl.sql
ALTER TABLE pt_booking ADD CONSTRAINT chk_pt_booking_date CHECK (booking_date = start_time::DATE);
```

Nhóm chọn **Cách 3** vì: (i) không phải sửa lệnh `INSERT` của dữ liệu mẫu và ứng dụng (vẫn cung cấp `booking_date`); (ii) các truy vấn phức hợp đang dùng `pb.booking_date` (lọc theo ngày, có thể tận dụng cột thay vì ép kiểu) giữ nguyên; (iii) về tính toàn vẹn thì tương đương Cách 2: không thể có hai giá trị mâu thuẫn. Đánh đổi: còn dư thừa lưu trữ 1 cột `DATE` và `pt_booking` vẫn không đạt 3NF hình thức (Cách 1 và 2 cũng chỉ loại bỏ được F3 chứ không loại được F2).

##### Phân rã về BCNF (phương án đối chiếu)

Nếu áp dụng chuẩn hóa tuyệt đối, phân rã `PT_BOOKING` theo F2 và F3:

- **PT_BOOKING_BCNF**(<u>booking_id</u>, trainer_user_id, subscription_id, start_time, end_time, status, created_at, created_by_user_id, updated_by_user_id, updated_at)
- `member_user_id` lấy qua phép nối với **MEMBER_SUBSCRIPTION**(<u>subscription_id</u>, member_user_id, …), vốn đã đạt BCNF;
- `booking_date` tính bằng biểu thức `start_time::DATE`.
**Chứng minh phân rã bảo toàn thông tin (lossless join):** theo Elmasri (Tính chất NJB), phân rã `R` thành `{R1, R2}` là không mất mát nếu `(R1 ∩ R2) → (R1 − R2)` hoặc `(R1 ∩ R2) → (R2 − R1)` thuộc `F⁺`. Ở đây `R1 ∩ R2 = {subscription_id}`, và `subscription_id` là khóa của `MEMBER_SUBSCRIPTION` nên `subscription_id → (R2 − R1)`. Vậy phân rã là **lossless**. ∎

**Bảo toàn phụ thuộc:** F1 (bỏ 2 thuộc tính đã tách) nằm trong `PT_BOOKING_BCNF`, F2 nằm trong `MEMBER_SUBSCRIPTION`, còn F3 trở thành biểu thức tính toán ⇒ phân rã **bảo toàn phụ thuộc**.

**Cái giá phải trả:** mất khả năng thực thi BR-16 bằng `EXCLUDE`, như đã phân tích ở mục (a). Vì vậy nhóm giữ lược đồ hiện tại, chấp nhận `pt_booking` ở mức 2NF hình thức.

#### 2.3.5. Kết luận

1. **17/18 bảng đạt BCNF.** Mọi phụ thuộc hàm không tầm thường đều có vế trái là khóa dự tuyển. Các phụ thuộc "có vẻ hợp lý" đã được xét và loại trừ bằng lập luận nghiệp vụ, hoặc bằng phản ví dụ từ dữ liệu mẫu.
2. **`pt_booking` đạt 2NF, không đạt 3NF/BCNF về mặt hình thức.** Hai phụ thuộc bắc cầu còn lại là phi chuẩn hóa **có chủ đích và có kiểm soát**: `subscription_id → member_user_id` phục vụ ràng buộc `EXCLUDE` (BR-16) và được khóa ngoại ghép `fk_booking_subscription_member` bảo đảm tuyệt đối; `start_time → booking_date` được `chk_pt_booking_date` (Cách 3, đã áp dụng) bảo đảm. Cả hai đều không thể sinh dữ liệu mâu thuẫn.
3. **Các bổ sung của lược đồ hiện hành không phá vỡ BCNF của 17 bảng còn lại:** cột `created_by_user_id`, `updated_by_user_id`, `updated_at` (FK/thuộc tính vết kiểm toán, BR-23), cột `billing_period_start`, miền `Late_Cancelled`/`E_Wallet`, và hai chỉ mục duy nhất một phần (`uq_member_one_active_subscription`, `uq_billing_subscription_period`). Chỉ mục duy nhất một phần chỉ ràng buộc một tập con bản ghi nên **không** là khóa dự tuyển và không thêm FD nào (Bổ đề 3), đặc biệt `billing_log` vẫn đạt BCNF.
4. Các thuộc tính **ảnh chụp lịch sử** (`actual_price`, `end_time`, `remaining_sessions` trong `member_subscription`) và **dữ liệu dẫn xuất được trigger đồng bộ** (`current_enrolled`) không tạo ra phụ thuộc bắc cầu. Chúng được giữ có chủ đích để bảo toàn lịch sử giao dịch và để thực thi ràng buộc ở mức CSDL.

## 3. Từ điển dữ liệu (Data Dictionary – ISO/IEC 11179)

Từ điển dữ liệu mô tả metadata của toàn bộ **18 bảng** theo mẫu bảng chuẩn hóa của tài liệu ISO/IEC 11179 do giảng viên cung cấp (Attribute Name, Data Type, Key, Nullable, Default, Business Rules / Constraints). Mỗi bảng có một bảng thuộc tính riêng; các bảng được nhóm thành 5 phân hệ. Tên ràng buộc, chỉ mục và trigger ghi trong cột cuối là tên thật trong DDL, kèm mã quy tắc BR để truy vết ngược về mục 1.2.

### 3.1. Phân hệ 1: Quản lý người dùng & phân quyền RBAC (5 bảng)

Quản lý thông tin định danh tài khoản, hệ thống phân quyền đa vai trò động (Role-Based Access Control) và phân cấp quyền hạn chi tiết.

> **Quy ước chung (ISO/IEC 11179):** kiểu dữ liệu theo PostgreSQL 16 và khớp 100% với `01_schema_ddl.sql` (đã đối chiếu tự động với `information_schema.columns`). `SERIAL` = `INTEGER` + sequence, giá trị mặc định là `nextval(...)`. Cột *Key*: `PK` khóa chính, `FK` khóa ngoại, `UK` khóa duy nhất (UNIQUE), `None` không có. Tên ràng buộc ghi trong dấu `` ` ` `` là tên thật trong DDL.

#### Bảng 3.1.1: USER_ACCOUNT

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

#### Bảng 3.1.2: ROLE

**Mô tả:** Danh mục các vai trò hệ thống quy định nhóm thẩm quyền sử dụng.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh vai trò hệ thống. `pk_role` |
| role_name | VARCHAR(50) | UK | No | None | Tên vai trò duy nhất: Member, Trainer, Receptionist, Technician, Admin. `uq_role_name` (BR-22) |
| description | VARCHAR(255) | None | Yes | NULL | Mô tả chi tiết thẩm quyền và trách nhiệm của vai trò |

#### Bảng 3.1.3: USER_ROLE

**Mô tả:** Bảng trung gian gán vai trò cho người dùng (quan hệ M:N, hỗ trợ một người giữ nhiều vai trò).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép `pk_user_role (user_id, role_id)`. `fk_user_role_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE** (BR-22) |
| role_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép. `fk_user_role_role` → ROLE(role_id) **ON DELETE CASCADE** (BR-22) |

#### Bảng 3.1.4: PERMISSION

**Mô tả:** Danh mục các quyền thao tác chi tiết theo từng phân hệ chức năng.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| permission_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh quyền thao tác. `pk_permission` |
| permission_code | VARCHAR(50) | UK | No | None | Mã quyền duy nhất (VD: MEMBER_CREATE, EQUIP_EDIT). `uq_permission_code` |
| module_name | VARCHAR(50) | None | No | None | Phân hệ nghiệp vụ tương ứng (VD: Billing, Booking) |
| description | VARCHAR(255) | None | Yes | NULL | Diễn giải chi tiết thao tác được phép thực hiện |

#### Bảng 3.1.5: ROLE_PERMISSION

**Mô tả:** Bảng trung gian phân bổ các quyền chi tiết cho từng vai trò hệ thống (quan hệ M:N).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| role_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép `pk_role_permission (role_id, permission_id)`. `fk_role_permission_role` → ROLE(role_id) **ON DELETE CASCADE** (BR-22) |
| permission_id | INT | PK, FK | No | None | Thành phần của khóa chính ghép. `fk_role_permission_permission` → PERMISSION(permission_id) **ON DELETE CASCADE** (BR-22) |

### 3.2. Phân hệ 2: Hồ sơ chuyên biệt – các lớp con EER (3 bảng)

Mở rộng thông tin chuyên môn riêng cho từng nhóm người dùng (Hội viên, PT, Nhân viên) theo cơ chế Shared Primary Key: khóa chính của lớp con đồng thời là khóa ngoại trỏ về `user_account`.

#### Bảng 3.2.1: MEMBER_PROFILE

**Mô tả:** Hồ sơ thông tin bổ sung dành riêng cho nhóm hội viên tập luyện. Các bảng `member_subscription` và `pt_booking` tham chiếu **trực tiếp bảng này** (không tham chiếu `user_account`) để bảo đảm chủ hợp đồng/ca tập chắc chắn là hội viên.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_member_profile_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE**. Trigger `trg_check_member_dob` kiểm tra đủ 12 tuổi khi thêm hồ sơ (BR-03) |
| health_notes | TEXT | None | Yes | NULL | Ghi chú tình trạng sức khỏe, tiền sử bệnh lý hoặc dị ứng |

#### Bảng 3.2.2: TRAINER_PROFILE

**Mô tả:** Hồ sơ thông tin chuyên môn dành cho huấn luyện viên cá nhân (PT). Được `class_schedule` và `pt_booking` tham chiếu trực tiếp.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_trainer_profile_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE** |
| specialization | VARCHAR(100) | None | Yes | NULL | Lĩnh vực chuyên môn giảng dạy (Gym, Yoga, Pilates, Boxing...) |
| bio | TEXT | None | Yes | NULL | Tiểu sử cá nhân, kinh nghiệm công tác và bằng cấp chứng chỉ |
| current_rating | DECIMAL(3,2) | None | No | 5.00 | Điểm đánh giá trung bình từ hội viên. `chk_trainer_rating`: `current_rating >= 0.00 AND current_rating <= 5.00` (BR-11) |

#### Bảng 3.2.3: STAFF_PROFILE

**Mô tả:** Hồ sơ công tác dành cho nhóm nhân viên vận hành (lễ tân, kỹ thuật viên). Được `maintenance_log` tham chiếu trực tiếp.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| user_id | INT | PK, FK | No | None | Shared PK. `fk_staff_profile_user` → USER_ACCOUNT(user_id) **ON DELETE CASCADE** |
| job_title | VARCHAR(50) | None | No | None | Chức danh công việc (Receptionist, Technician, Manager) |
| department | VARCHAR(50) | None | No | None | Phòng ban công tác trực thuộc |

### 3.3. Phân hệ 3: Gói tập & thanh toán (3 bảng)

Quản lý gói dịch vụ phòng tập, hợp đồng đăng ký hội viên và nhật ký hóa đơn gia hạn tự động bất biến.

#### Bảng 3.3.1: MEMBERSHIP_PLAN

**Mô tả:** Danh mục các gói tập tiêu chuẩn được phòng tập kinh doanh.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| plan_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh gói tập. `pk_membership_plan` |
| plan_name | VARCHAR(100) | None | No | None | Tên hiển thị gói tập (VD: Gói VIP 12 Tháng, Gói PT 20 Buổi) |
| duration_days | INT | None | No | None | Thời hạn hiệu lực tính theo ngày. `chk_membership_plan_duration`: `duration_days > 0` (BR-04) |
| total_sessions | INT | None | No | 0 | Tổng số buổi PT được cấp (0 nếu là gói thời gian). `chk_membership_plan_sessions`: `total_sessions >= 0` |
| price | DECIMAL(10,2) | None | No | None | Đơn giá niêm yết của gói tập. `chk_membership_plan_price`: `price >= 0` (BR-04) |
| description | TEXT | None | Yes | NULL | Mô tả chi tiết các đặc quyền và điều khoản gói tập |

#### Bảng 3.3.2: MEMBER_SUBSCRIPTION

**Mô tả:** Hợp đồng đăng ký gói tập cụ thể của hội viên.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| subscription_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh hợp đồng đăng ký. `pk_member_subscription` |
| member_user_id | INT | FK | No | None | Hội viên đứng tên hợp đồng. `fk_subscription_member` → **MEMBER_PROFILE**(user_id) **ON DELETE RESTRICT** (BR-05). Cùng `subscription_id` tạo thành `uq_subscription_member (subscription_id, member_user_id)` làm đích cho khóa ngoại ghép của PT_BOOKING |
| plan_id | INT | FK | No | None | Gói tập đã chọn. `fk_subscription_plan` → MEMBERSHIP_PLAN(plan_id) **ON DELETE RESTRICT** |
| actual_price | DECIMAL(10,2) | None | No | None | Giá bán thực tế chốt tại thời điểm ký (độc lập với giá niêm yết). `chk_subscription_price`: `actual_price >= 0` |
| remaining_sessions | INT | None | No | 0 | Số buổi PT còn lại. `chk_subscription_remaining`: `remaining_sessions >= 0`. Trigger `trg_update_remaining_pt_sessions` trừ buổi khi ca PT chuyển sang Completed / Late_Cancelled / No_Show (BR-18, BR-25) |
| start_time | TIMESTAMP | None | No | None | Thời điểm hợp đồng bắt đầu có hiệu lực |
| end_time | TIMESTAMP | None | No | None | Thời điểm hết hiệu lực. `chk_subscription_dates`: `end_time >= start_time` (BR-06) |
| sub_status | VARCHAR(20) | None | No | 'Pending' | Trạng thái hợp đồng. `chk_subscription_status`: `IN ('Pending', 'Active', 'Expired', 'Suspended', 'Cancelled')`. Trigger `trg_require_payment_before_active` chỉ cho 'Active' khi đã có hóa đơn Completed; `trg_activate_on_payment_insert/_update` tự kích hoạt khi thanh toán (BR-07) |
| is_recurring | BOOLEAN | None | No | FALSE | Cấu hình tự động gia hạn định kỳ; thủ tục `sp_process_subscription_renewals(p_as_of, p_grace_days)` phát hành hóa đơn gia hạn / chuyển Expired / Suspended (BR-24) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo hợp đồng |
| created_by_user_id | INT | FK | No | None | Người thực hiện thao tác tạo hợp đồng, bắt buộc (BR-23). `fk_subscription_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa hợp đồng lần gần nhất (BR-23). `fk_subscription_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `uq_member_one_active_subscription`: UNIQUE INDEX một phần trên `(member_user_id) WHERE sub_status = 'Active'`, mỗi hội viên có tối đa 1 hợp đồng Active tại một thời điểm (BR-05).
- Chỉ mục: `idx_member_subscription_member (member_user_id)`, `idx_member_subscription_status (sub_status)`, `idx_member_subscription_dates (start_time, end_time)`.

#### Bảng 3.3.3: BILLING_LOG

**Mô tả:** Nhật ký lưu vết giao dịch thanh toán hóa đơn bất biến (Immutable Billing Log).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| billing_id | SERIAL | PK | No | SERIAL (nextval) | Mã nhật ký giao dịch thanh toán. `pk_billing_log` |
| subscription_id | INT | FK | No | None | Hợp đồng được thanh toán. `fk_billing_subscription` → MEMBER_SUBSCRIPTION(subscription_id) **ON DELETE RESTRICT** (BR-08) |
| billing_period_start | DATE | None | No | None | Ngày bắt đầu chu kỳ tính phí mà hóa đơn chi trả. Nếu INSERT bỏ trống, trigger `trg_fill_billing_period_start` điền `start_time::DATE` của hợp đồng. Thành phần của chỉ mục duy nhất một phần `uq_billing_subscription_period` (BR-08) |
| invoice_no | VARCHAR(50) | UK | No | None | Số hóa đơn duy nhất toàn hệ thống. `uq_billing_invoice_no` (BR-09) |
| amount | DECIMAL(10,2) | None | No | None | Số tiền thanh toán thực tế. `chk_billing_amount`: `amount > 0` (BR-09) |
| payment_date | DATE | None | No | None | Ngày phát sinh giao dịch thanh toán |
| payment_method | VARCHAR(50) | None | No | None | Phương thức thanh toán. `chk_billing_method`: `IN ('Cash', 'Credit_Card', 'Banking', 'E_Wallet')` |
| payment_status | VARCHAR(20) | None | No | 'Completed' | Trạng thái hóa đơn. `chk_billing_status`: `IN ('Pending', 'Completed', 'Failed', 'Refunded')`. Bản ghi bất biến: trigger `trg_billing_immutable_update/_delete/_truncate` chặn sửa/xóa/TRUNCATE (BR-10) |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm ghi nhận hóa đơn |
| created_by_user_id | INT | FK | No | None | Người lập hóa đơn, bắt buộc (BR-23). `fk_billing_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa hóa đơn lần gần nhất (chỉ Completed→Refunded hoặc Pending→Completed/Failed, BR-10) (BR-23). `fk_billing_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `uq_billing_subscription_period`: UNIQUE INDEX một phần `(subscription_id, billing_period_start) WHERE payment_status IN ('Pending', 'Completed')`. Mỗi chu kỳ của một hợp đồng chỉ có tối đa 1 hóa đơn còn hiệu lực; hóa đơn Failed/Refunded không chiếm chu kỳ nên được phát hành lại (BR-08).
- Chỉ mục: `idx_billing_log_subscription_date (subscription_id, payment_date DESC)`, `idx_billing_log_payment_date (payment_date)`.
- Trigger kích hoạt hợp đồng khi thanh toán: `trg_activate_on_payment_insert` (AFTER INSERT), `trg_activate_on_payment_update` (AFTER UPDATE OF payment_status) (BR-07, BR-24).

### 3.4. Phân hệ 4: Lịch tập & đặt chỗ (4 bảng)

Quản lý phòng tập, lịch lớp học nhóm, đăng ký lớp học và đặt ca tập PT 1-1 chống đụng lịch.

#### Bảng 3.4.1: FACILITIES_ROOM

**Mô tả:** Danh mục phòng tập và các khu vực chức năng trong trung tâm.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| room_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh phòng tập / khu vực. `pk_facilities_room` |
| room_name | VARCHAR(100) | None | No | None | Tên hiển thị của phòng (VD: Phòng Yoga A1, Khu Máy Lưng) |
| max_capacity | INT | None | No | None | Sức chứa tối đa cùng lúc. `chk_facilities_capacity`: `max_capacity > 0` (BR-13) |
| room_type | VARCHAR(50) | None | No | None | Loại phòng (VD: 'Yoga_Studio', 'Gym_Floor', 'Boxing_Ring'); không có CHECK miền giá trị |
| status | VARCHAR(20) | None | No | 'Active' | Trạng thái phòng. `chk_facilities_status`: `IN ('Active', 'Under_Maintenance', 'Inactive')`. Trigger `trg_prevent_class_in_maintenance_room` cấm xếp lớp vào phòng không 'Active' (BR-19) |

#### Bảng 3.4.2: CLASS_SCHEDULE

**Mô tả:** Lịch vận hành các lớp học thể thao nhóm cố định.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| class_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh lớp học nhóm. `pk_class_schedule` |
| trainer_user_id | INT | FK | No | None | HLV phụ trách lớp. `fk_class_trainer` → **TRAINER_PROFILE**(user_id) **ON DELETE RESTRICT** (BR-12) |
| room_id | INT | FK | No | None | Phòng tổ chức lớp. `fk_class_room` → FACILITIES_ROOM(room_id) **ON DELETE RESTRICT** (BR-15) |
| class_name | VARCHAR(100) | None | No | None | Tên lớp học nhóm (VD: Power Yoga K12, BodyPump Morning) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu lớp học |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_class_time`: `end_time > start_time` (BR-17) |
| max_capacity | INT | None | No | None | Số hội viên tối đa được đăng ký. `chk_class_capacity`: `max_capacity > 0` |
| current_enrolled | INT | None | No | 0 | Số hội viên đã đăng ký (dữ liệu dẫn xuất, đồng bộ bởi `trg_sync_class_enrollment_count`). `chk_class_enrolled`: `>= 0`; `chk_class_enrollment_limit`: `current_enrolled <= max_capacity` (BR-14) |
| created_by_user_id | INT | FK | No | None | Người tạo lịch, bắt buộc (BR-23). `fk_class_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa lịch lớp lần gần nhất (BR-23). `fk_class_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `ex_class_trainer_no_overlap`: EXCLUDE USING gist `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)`, một HLV không dạy 2 lớp chồng giờ (BR-12).
- `ex_class_room_no_overlap`: EXCLUDE USING gist `(room_id WITH =, tsrange(start_time, end_time, '[)') WITH &&)`, một phòng không tổ chức 2 lớp chồng giờ (BR-15).
- Trigger: `trg_check_class_schedule_conflicts` (BR-12, BR-16), `trg_prevent_class_in_maintenance_room` (BR-19).
- Chỉ mục: `idx_class_schedule_trainer`, `idx_class_schedule_room`, `idx_class_schedule_dates (start_time, end_time)`.

#### Bảng 3.4.3: CLASS_ENROLLMENT

**Mô tả:** Bảng trung gian ghi nhận hội viên đăng ký tham gia lớp học nhóm.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| enrollment_id | SERIAL | PK | No | SERIAL (nextval) | Mã lượt đăng ký lớp học. `pk_class_enrollment` |
| subscription_id | INT | FK | No | None | Hợp đồng gói tập dùng để đăng ký. `fk_enrollment_subscription` → MEMBER_SUBSCRIPTION(subscription_id) **ON DELETE CASCADE** |
| class_id | INT | FK | No | None | Lớp học nhóm đăng ký. `fk_enrollment_class` → CLASS_SCHEDULE(class_id) **ON DELETE CASCADE** |
| enrollment_date | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm đăng ký thành công |
| status | VARCHAR(20) | None | No | 'Enrolled' | Trạng thái đăng ký. `chk_enrollment_status`: `IN ('Enrolled', 'Cancelled', 'Attended')` |

**Ràng buộc cấp bảng:** `uq_enrollment_subscription_class UNIQUE (subscription_id, class_id)`, một hợp đồng không đăng ký trùng một lớp. Trigger `trg_check_class_enrollment_conflicts` (BR-16) chống đăng ký các lớp chồng giờ; `trg_sync_class_enrollment_count` (AFTER INSERT/UPDATE/DELETE) đồng bộ `class_schedule.current_enrolled` (BR-14).

#### Bảng 3.4.4: PT_BOOKING

**Mô tả:** Quản lý ca tập cá nhân 1-1 giữa hội viên và huấn luyện viên. Ca PT diễn ra ở khu tập tự do nên không gắn với phòng tập (BR-15 chỉ áp dụng cho lớp nhóm).

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| booking_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh ca tập PT 1-1. `pk_pt_booking` |
| member_user_id | INT | FK | No | None | Hội viên đặt ca tập. `fk_booking_member` → **MEMBER_PROFILE**(user_id) **ON DELETE RESTRICT**. Cặp `(subscription_id, member_user_id)` được bảo vệ bởi khóa ngoại ghép `fk_booking_subscription_member` |
| trainer_user_id | INT | FK | No | None | PT chịu trách nhiệm. `fk_booking_trainer` → **TRAINER_PROFILE**(user_id) **ON DELETE RESTRICT** (BR-12) |
| subscription_id | INT | FK | No | None | Gói PT dùng để trừ buổi. `fk_booking_subscription` → MEMBER_SUBSCRIPTION(subscription_id) **ON DELETE RESTRICT**; khóa ngoại ghép `fk_booking_subscription_member` (subscription_id, member_user_id) → MEMBER_SUBSCRIPTION(subscription_id, member_user_id) **ON DELETE RESTRICT** (BR-18) |
| booking_date | DATE | None | No | None | Ngày diễn ra ca tập. `chk_pt_booking_date`: `booking_date = start_time::DATE` (đã áp dụng, loại bỏ nguy cơ lệch với `start_time`) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu ca tập 1-1 |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc. `chk_pt_booking_time`: `end_time > start_time` (BR-17) |
| status | VARCHAR(20) | None | No | 'Scheduled' | Trạng thái ca tập. `chk_pt_booking_status`: `IN ('Scheduled', 'Completed', 'Cancelled', 'Late_Cancelled', 'No_Show')`. `Late_Cancelled` = hủy muộn < 24h, vẫn trừ 1 buổi (BR-25); do trigger `trg_late_cancel_pt_booking` tự chuyển từ Cancelled |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo ca tập |
| created_by_user_id | INT | FK | No | None | Người đặt lịch (lễ tân/hội viên), bắt buộc (BR-23). `fk_booking_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa ca PT lần gần nhất (đổi trạng thái, hủy) (BR-23). `fk_booking_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Ràng buộc/chỉ mục cấp bảng:**

- `ex_pt_trainer_no_overlap`: EXCLUDE USING gist `(trainer_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled'))` (BR-12, BR-16).
- `ex_pt_member_no_overlap`: EXCLUDE USING gist `(member_user_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled'))`, lý do phải lưu `member_user_id` trong bảng này (BR-16).
- Trigger: `trg_check_pt_booking_creation` (BEFORE INSERT: hợp đồng Active, giờ nằm trong thời hạn, còn buổi: BR-18), `trg_check_pt_booking_conflicts` (BR-12, BR-16), `trg_late_cancel_pt_booking` (BR-25), `trg_update_remaining_pt_sessions` (AFTER UPDATE OF status: BR-18, BR-25).
- Chỉ mục: `idx_pt_booking_trainer`, `idx_pt_booking_member`, `idx_pt_booking_subscription (subscription_id)`, `idx_pt_booking_dates (start_time, end_time)`.

### 3.5. Phân hệ 5: Thiết bị & bảo trì (3 bảng)

Quản lý thiết bị máy tập, theo dõi khấu hao, lịch sử giữ chỗ máy cho buổi tập và nhật ký sửa chữa, bảo trì.

#### Bảng 3.5.1: EQUIPMENT

**Mô tả:** Danh mục thiết bị và máy móc thể hình trang bị tại phòng tập.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| equipment_id | SERIAL | PK | No | SERIAL (nextval) | Mã định danh thiết bị / máy tập. `pk_equipment` |
| room_id | INT | FK | No | None | Vị trí phòng đặt máy. `fk_equipment_room` → FACILITIES_ROOM(room_id) **ON DELETE RESTRICT** |
| equipment_name | VARCHAR(100) | None | No | None | Tên thiết bị (VD: Máy chạy bộ Technogym Run 1000) |
| serial_number | VARCHAR(100) | UK | No | None | Mã series thiết bị duy nhất. `uq_equipment_serial` |
| purchase_date | DATE | None | No | None | Ngày nhập mua đưa vào sử dụng (BR-26) |
| depreciation_months | INT | None | No | None | Số tháng khấu hao dự kiến. `chk_equipment_depreciation`: `depreciation_months > 0` (BR-26) |
| status | VARCHAR(20) | None | No | 'Operational' | Trạng thái máy. `chk_equipment_status`: `IN ('Operational', 'Under_Maintenance', 'Decommissioned')`. Trigger `trg_prevent_equipment_reservation_under_maintenance` cấm giữ chỗ máy không 'Operational' (BR-19) |

**Chỉ mục:** `idx_equipment_status (status)`.

#### Bảng 3.5.2: EQUIPMENT_RESERVATION

**Mô tả:** Lịch giữ chỗ trước máy tập cho ca PT hoặc lớp học, nhằm tránh trùng thiết bị.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| reservation_id | SERIAL | PK | No | SERIAL (nextval) | Mã lượt giữ chỗ máy. `pk_equipment_reservation` |
| equipment_id | INT | FK | No | None | Thiết bị được đặt trước. `fk_reservation_equipment` → EQUIPMENT(equipment_id) **ON DELETE CASCADE** |
| booking_id | INT | FK | Yes | NULL | Ca PT 1-1 nếu giữ cho PT. `fk_reservation_booking` → PT_BOOKING(booking_id) **ON DELETE CASCADE** (BR-21) |
| class_id | INT | FK | Yes | NULL | Lớp nhóm nếu giữ cho lớp. `fk_reservation_class` → CLASS_SCHEDULE(class_id) **ON DELETE CASCADE** (BR-21) |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu giữ chỗ |
| end_time | TIMESTAMP | None | No | None | Thời điểm kết thúc giữ chỗ. `chk_reservation_time`: `end_time > start_time` |
| status | VARCHAR(20) | None | No | 'Reserved' | Trạng thái. `chk_reservation_status`: `IN ('Reserved', 'Completed', 'Cancelled')` |

**Ràng buộc cấp bảng:**

- `chk_reservation_source`: đúng một trong `booking_id`, `class_id` khác NULL (exclusive arc).
- `ex_reservation_equipment_no_overlap`: EXCLUDE USING gist `(equipment_id WITH =, tsrange(start_time, end_time, '[)') WITH &&) WHERE (status <> 'Cancelled')`, một thiết bị không bị giữ trùng giờ (BR-21).
- Trigger: `trg_check_reservation_window` (khung giờ giữ chỗ nằm trong buổi tập và không rơi vào lịch bảo trì: BR-21), `trg_prevent_equipment_reservation_under_maintenance` (BR-19).

#### Bảng 3.5.3: MAINTENANCE_LOG

**Mô tả:** Nhật ký ghi nhận sự cố hư hỏng và tiến độ bảo trì thiết bị.

| Attribute Name | Data Type | Key | Null? | Default | Business Rules / Constraints |
| --- | --- | --- | --- | --- | --- |
| maintenance_id | SERIAL | PK | No | SERIAL (nextval) | Mã nhật ký bảo trì. `pk_maintenance_log` |
| equipment_id | INT | FK | No | None | Máy tập cần sửa chữa. `fk_maintenance_equipment` → EQUIPMENT(equipment_id) **ON DELETE RESTRICT** |
| staff_user_id | INT | FK | No | None | Kỹ thuật viên xử lý. `fk_maintenance_staff` → **STAFF_PROFILE**(user_id) **ON DELETE RESTRICT** |
| issue_description | TEXT | None | No | None | Mô tả sự cố hoặc lý do bảo trì |
| start_time | TIMESTAMP | None | No | None | Thời điểm bắt đầu bảo trì |
| end_time | TIMESTAMP | None | Yes | NULL | Thời điểm hoàn thành (NULL khi đang xử lý). `chk_maintenance_time`: `end_time IS NULL OR end_time >= start_time` (BR-20) |
| cost | DECIMAL(10,2) | None | No | 0.00 | Chi phí sửa chữa. `chk_maintenance_cost`: `cost >= 0` (BR-20) |
| status | VARCHAR(20) | None | No | 'In_Progress' | Trạng thái xử lý. `chk_maintenance_status`: `IN ('In_Progress', 'Completed', 'Cancelled')` |
| created_at | TIMESTAMP | None | No | CURRENT_TIMESTAMP | Thời điểm tạo bản ghi |
| created_by_user_id | INT | FK | No | None | Người ghi nhận, bắt buộc (BR-23). `fk_maintenance_created_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; `trg_fill_created_by` điền từ biến phiên `app.current_user_id` khi câu INSERT không nêu, nếu cả hai đều thiếu thì RAISE lỗi BR-23; `trg_set_updated_by` không cho đổi sau khi ghi |
| updated_by_user_id | INT | FK | Yes | NULL | Người sửa ca bảo trì lần gần nhất (BR-23). `fk_maintenance_updated_by` → USER_ACCOUNT(user_id) **ON DELETE RESTRICT**; luôn do `trg_set_updated_by` ghi đè từ `app.current_user_id`; NULL = chưa từng sửa |
| updated_at | TIMESTAMP | None | Yes | NULL | Thời điểm sửa gần nhất (BR-23), do `trg_set_updated_by` ghi `CURRENT_TIMESTAMP`; NULL = chưa từng sửa |

**Chỉ mục:** `idx_maintenance_log_equipment (equipment_id)`.

## 4. Triển khai cơ sở dữ liệu (Database Implementation – SQLStyle.guide)

Toàn bộ mã SQL nằm trong thư mục `Phase 3/` và tuân thủ SQLStyle.guide (Simon Holywell): từ khóa SQL viết hoa, định danh `snake_case` chữ thường, thụt lề nhất quán cho `JOIN` và truy vấn con, ràng buộc đặt tên theo tiền tố (`pk_`, `fk_`, `uq_`, `chk_`, `ex_`, `idx_`, `trg_`, `sp_`) để truy vết tới quy tắc BR. Các đoạn mã dưới đây được trích nguyên văn từ các tập tin nguồn.

### 4.1. Script DDL: bảng, ràng buộc, chỉ mục, trigger, view (DDL Script)

#### 4.1.1. Tổng quan các đối tượng cơ sở dữ liệu

Số liệu dưới đây đếm trực tiếp từ catalog PostgreSQL sau khi nạp `01_schema_ddl.sql`, `02_mock_data/*`, `04_triggers_views.sql` và `08_rbac_security.sql` trên PostgreSQL 16.

*Bảng 4-1. Thống kê đối tượng cơ sở dữ liệu*

| Loại đối tượng | Số lượng | Ví dụ / ghi chú | Tập tin |
| --- | --- | --- | --- |
| Bảng | 18 | Từ `user_account` đến `maintenance_log` (xem chương 3) | `01_schema_ddl.sql` |
| Khóa chính (`PRIMARY KEY`) | 18 | `pk_*`; ba bảng hồ sơ dùng khóa chính chia sẻ `user_id` | `01_schema_ddl.sql` |
| Khóa ngoại (`FOREIGN KEY`) | 34 | `ON DELETE RESTRICT` cho dữ liệu giao dịch; `CASCADE` chỉ cho hồ sơ 1:1, bảng nối và lượt giữ chỗ phụ thuộc; khóa ngoại ghép `fk_booking_subscription_member` | `01_schema_ddl.sql` |
| Ràng buộc duy nhất (`UNIQUE`) | 8 + 2 chỉ mục duy nhất từng phần | `uq_user_account_email`, `uq_billing_invoice_no`; từng phần: `uq_member_one_active_subscription` (BR-05), `uq_billing_subscription_period` (BR-08) | `01_schema_ddl.sql` |
| Ràng buộc kiểm tra (`CHECK`) | 30 | `chk_billing_amount`, `chk_pt_booking_time`, `chk_class_enrollment_limit`… | `01_schema_ddl.sql` |
| Ràng buộc loại trừ (`EXCLUDE USING gist`) | 5 | `ex_class_trainer_no_overlap`, `ex_class_room_no_overlap`, `ex_pt_trainer_no_overlap`, `ex_pt_member_no_overlap`, `ex_reservation_equipment_no_overlap` (cần `btree_gist`) | `01_schema_ddl.sql` |
| Chỉ mục tường minh (`CREATE INDEX`) | 15 | `idx_member_subscription_member`, `idx_billing_log_subscription_date`, `idx_pt_booking_trainer`… (catalog có 48 chỉ mục, gồm cả chỉ mục do PK/UNIQUE/EXCLUDE sinh ra) | `01_schema_ddl.sql` |
| Trigger | 34 (24 hàm trigger) | 3 trigger trong DDL (BR-03, BR-14) và 31 trigger trong `04_triggers_views.sql`; bảng liệt kê ở mục 4.1.3. Ngoài ra có 2 event trigger bảo vệ `billing_log` (BR-10) trong `08_rbac_security.sql` | `01`, `04` |
| View | 2 | `vw_active_member_subscriptions`, `vw_trainer_schedule_overview` | `04_triggers_views.sql` |
| Thủ tục (`PROCEDURE`) | 1 | `sp_process_subscription_renewals(p_as_of, p_grace_days)` (BR-24) | `04_triggers_views.sql` |
| Role / tài khoản đăng nhập | 5 + 5 (+ 1 role chủ sở hữu) | `gym_role_*` (NOLOGIN), `gym_u_*` (LOGIN, INHERIT) và `gym_owner` (NOLOGIN, chủ sở hữu mọi đối tượng) | `08_rbac_security.sql` |
| Event trigger | 2 | `evt_protect_billing_log` (`ddl_command_end`), `evt_protect_billing_log_drop` (`sql_drop`), BR-10 | `08_rbac_security.sql` |

#### 4.1.2. Ví dụ DDL: bảng, khóa, ràng buộc và chỉ mục

Bảng `member_subscription` minh họa khóa chính, siêu khóa phục vụ khóa ngoại ghép, các khóa ngoại `RESTRICT`, ràng buộc `CHECK` và **chỉ mục duy nhất từng phần** hiện thực BR-05 (mỗi hội viên tối đa một hợp đồng `Active`):

```sql
CREATE TABLE member_subscription (
    subscription_id    SERIAL,
    member_user_id     INT            NOT NULL,
    plan_id            INT            NOT NULL,
    actual_price       DECIMAL(10, 2) NOT NULL,
    remaining_sessions INT            NOT NULL DEFAULT 0,
    start_time         TIMESTAMP      NOT NULL,
    end_time           TIMESTAMP      NOT NULL,
    sub_status         VARCHAR(20)    NOT NULL DEFAULT 'Pending',
    is_recurring       BOOLEAN        NOT NULL DEFAULT FALSE,
    created_at         TIMESTAMP      NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INT NOT NULL,
    updated_by_user_id INT,
    updated_at TIMESTAMP,
    CONSTRAINT pk_member_subscription PRIMARY KEY (subscription_id),
    CONSTRAINT uq_subscription_member UNIQUE (subscription_id, member_user_id),
    CONSTRAINT fk_subscription_member FOREIGN KEY (member_user_id)
        REFERENCES member_profile (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_subscription_plan FOREIGN KEY (plan_id)
        REFERENCES membership_plan (plan_id) ON DELETE RESTRICT,
    CONSTRAINT fk_subscription_created_by FOREIGN KEY (created_by_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_subscription_updated_by FOREIGN KEY (updated_by_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT chk_subscription_price CHECK (actual_price >= 0),
    CONSTRAINT chk_subscription_remaining CHECK (remaining_sessions >= 0),
    CONSTRAINT chk_subscription_dates CHECK (end_time >= start_time),
    CONSTRAINT chk_subscription_status CHECK (sub_status IN ('Pending', 'Active', 'Expired', 'Suspended', 'Cancelled'))
);

-- BR-05: tại một thời điểm một hội viên chỉ có tối đa 1 hợp đồng ở trạng thái Active.
CREATE UNIQUE INDEX uq_member_one_active_subscription
    ON member_subscription (member_user_id)
    WHERE sub_status = 'Active';
```

Bảng `pt_booking` minh họa khóa ngoại ghép bảo đảm ca PT luôn thuộc đúng chủ hợp đồng, và hai ràng buộc `EXCLUDE USING gist` chống trùng lịch của huấn luyện viên và hội viên (BR-12, BR-16); các ca đã hủy được loại khỏi điều kiện:

```sql
CREATE TABLE pt_booking (
    booking_id      SERIAL,
    member_user_id  INT         NOT NULL,
    trainer_user_id INT         NOT NULL,
    subscription_id INT         NOT NULL,
    booking_date    DATE        NOT NULL,
    start_time      TIMESTAMP   NOT NULL,
    end_time        TIMESTAMP   NOT NULL,
    status          VARCHAR(20) NOT NULL DEFAULT 'Scheduled',
    created_at      TIMESTAMP   NOT NULL DEFAULT CURRENT_TIMESTAMP,
    created_by_user_id INT NOT NULL,
    updated_by_user_id INT,
    updated_at TIMESTAMP,
    CONSTRAINT pk_pt_booking PRIMARY KEY (booking_id),
    CONSTRAINT fk_booking_member FOREIGN KEY (member_user_id)
        REFERENCES member_profile (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_trainer FOREIGN KEY (trainer_user_id)
        REFERENCES trainer_profile (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_subscription FOREIGN KEY (subscription_id)
        REFERENCES member_subscription (subscription_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_subscription_member FOREIGN KEY (subscription_id, member_user_id)
        REFERENCES member_subscription (subscription_id, member_user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_created_by FOREIGN KEY (created_by_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT fk_booking_updated_by FOREIGN KEY (updated_by_user_id)
        REFERENCES user_account (user_id) ON DELETE RESTRICT,
    CONSTRAINT ex_pt_trainer_no_overlap EXCLUDE USING gist (
        trainer_user_id WITH =,
        tsrange(start_time, end_time, '[)') WITH &&
    ) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled')),
    CONSTRAINT ex_pt_member_no_overlap EXCLUDE USING gist (
        member_user_id WITH =,
        tsrange(start_time, end_time, '[)') WITH &&
    ) WHERE (status NOT IN ('Cancelled', 'Late_Cancelled')),
    CONSTRAINT chk_pt_booking_time CHECK (end_time > start_time),
    CONSTRAINT chk_pt_booking_date CHECK (booking_date = start_time::DATE),
    CONSTRAINT chk_pt_booking_status CHECK (status IN ('Scheduled', 'Completed', 'Cancelled', 'Late_Cancelled', 'No_Show'))
);
```

Các chỉ mục B-tree phục vụ truy vấn thường dùng (NFR-PERF-02); chỉ mục ghép `idx_billing_log_subscription_date` phục vụ cả lọc theo hợp đồng lẫn `ORDER BY payment_date DESC`:

```sql
CREATE INDEX idx_user_account_status ON user_account (status);
CREATE INDEX idx_member_subscription_member ON member_subscription (member_user_id);
CREATE INDEX idx_member_subscription_status ON member_subscription (sub_status);
CREATE INDEX idx_member_subscription_dates ON member_subscription (start_time, end_time);
-- Thay cho idx_billing_log_subscription (subscription_id): chỉ mục ghép bao trùm tiền tố subscription_id
-- và phục vụ luôn truy vấn "lịch sử hóa đơn mới nhất của một hợp đồng" (ORDER BY payment_date DESC).
CREATE INDEX idx_billing_log_subscription_date ON billing_log (subscription_id, payment_date DESC);
CREATE INDEX idx_billing_log_payment_date ON billing_log (payment_date);
CREATE INDEX idx_pt_booking_trainer ON pt_booking (trainer_user_id);
CREATE INDEX idx_pt_booking_member ON pt_booking (member_user_id);
CREATE INDEX idx_pt_booking_subscription ON pt_booking (subscription_id);
CREATE INDEX idx_pt_booking_dates ON pt_booking (start_time, end_time);
CREATE INDEX idx_class_schedule_trainer ON class_schedule (trainer_user_id);
CREATE INDEX idx_class_schedule_room ON class_schedule (room_id);
CREATE INDEX idx_class_schedule_dates ON class_schedule (start_time, end_time);
CREATE INDEX idx_equipment_status ON equipment (status);
CREATE INDEX idx_maintenance_log_equipment ON maintenance_log (equipment_id);
```

#### 4.1.3. Trigger

Trigger được dùng cho các quy tắc xuyên bảng hoặc phụ thuộc thời gian mà `CHECK` và `EXCLUDE` không diễn đạt được. Cột "BR" được truy ra từ bảng cơ chế thực thi ở mục 1.2.

*Bảng 4-2. 34 trigger của hệ thống*

| Bảng | Trigger | Thời điểm / sự kiện | Hàm trigger | BR |
| --- | --- | --- | --- | --- |
| `billing_log` | `trg_activate_on_payment_insert` | AFTER INSERT | `trg_fn_activate_on_payment` | BR-07, BR-24 |
| `billing_log` | `trg_activate_on_payment_update` | AFTER UPDATE | `trg_fn_activate_on_payment` | BR-07 |
| `billing_log` | `trg_billing_immutable_delete` | BEFORE DELETE | `trg_fn_billing_immutable_delete` | BR-10 |
| `billing_log` | `trg_billing_immutable_truncate` | BEFORE TRUNCATE | `trg_fn_billing_immutable_truncate` | BR-10 |
| `billing_log` | `trg_billing_immutable_update` | BEFORE UPDATE | `trg_fn_billing_immutable_update` | BR-10 |
| `billing_log` | `trg_fill_billing_period_start` | BEFORE INSERT | `trg_fn_fill_billing_period_start` | BR-08 |
| `billing_log` | `trg_fill_created_by` | BEFORE INSERT | `trg_fn_fill_created_by` | BR-23 |
| `billing_log` | `trg_set_updated_by` | BEFORE UPDATE | `trg_fn_set_updated_by` | BR-23 |
| `class_enrollment` | `trg_check_class_enrollment_conflicts` | BEFORE INSERT OR UPDATE | `trg_fn_check_class_enrollment_conflicts` | BR-16 |
| `class_enrollment` | `trg_sync_class_enrollment_count` | AFTER INSERT OR UPDATE OR DELETE | `fn_sync_class_enrollment_count` | BR-14 |
| `class_schedule` | `trg_check_class_schedule_conflicts` | BEFORE INSERT OR UPDATE | `trg_fn_check_class_schedule_conflicts` | BR-12, BR-16 |
| `class_schedule` | `trg_fill_created_by` | BEFORE INSERT | `trg_fn_fill_created_by` | BR-23 |
| `class_schedule` | `trg_prevent_class_in_maintenance_room` | BEFORE INSERT OR UPDATE | `trg_fn_prevent_room_under_maintenance` | BR-19 |
| `class_schedule` | `trg_set_updated_by` | BEFORE UPDATE | `trg_fn_set_updated_by` | BR-23 |
| `equipment` | `trg_prevent_equipment_maintenance_with_future_reservations` | BEFORE UPDATE | `trg_fn_prevent_equipment_maintenance_with_future_reservations` | BR-19 |
| `equipment_reservation` | `trg_check_reservation_window` | BEFORE INSERT OR UPDATE | `trg_fn_check_reservation_window` | BR-19, BR-21 |
| `equipment_reservation` | `trg_prevent_equipment_reservation_under_maintenance` | BEFORE INSERT OR UPDATE | `trg_fn_prevent_equipment_under_maintenance` | BR-19 |
| `facilities_room` | `trg_prevent_room_maintenance_with_future_classes` | BEFORE UPDATE | `trg_fn_prevent_room_maintenance_with_future_classes` | BR-19 |
| `maintenance_log` | `trg_fill_created_by` | BEFORE INSERT | `trg_fn_fill_created_by` | BR-23 |
| `maintenance_log` | `trg_finish_equipment_maintenance` | AFTER UPDATE | `trg_fn_finish_equipment_maintenance` | BR-19 |
| `maintenance_log` | `trg_set_updated_by` | BEFORE UPDATE | `trg_fn_set_updated_by` | BR-23 |
| `maintenance_log` | `trg_start_equipment_maintenance_insert` | AFTER INSERT | `trg_fn_start_equipment_maintenance` | BR-19 |
| `maintenance_log` | `trg_start_equipment_maintenance_update` | AFTER UPDATE | `trg_fn_start_equipment_maintenance` | – |
| `member_profile` | `trg_check_member_dob` | BEFORE INSERT OR UPDATE | `trg_fn_check_user_age` | BR-03 |
| `member_subscription` | `trg_fill_created_by` | BEFORE INSERT | `trg_fn_fill_created_by` | BR-23 |
| `member_subscription` | `trg_require_payment_before_active` | BEFORE INSERT OR UPDATE | `trg_fn_require_payment_before_active` | BR-07 |
| `member_subscription` | `trg_set_updated_by` | BEFORE UPDATE | `trg_fn_set_updated_by` | BR-23 |
| `pt_booking` | `trg_check_pt_booking_conflicts` | BEFORE INSERT OR UPDATE | `trg_fn_check_pt_booking_conflicts` | BR-12, BR-16 |
| `pt_booking` | `trg_check_pt_booking_creation` | BEFORE INSERT | `trg_fn_check_pt_booking_creation` | BR-18 |
| `pt_booking` | `trg_fill_created_by` | BEFORE INSERT | `trg_fn_fill_created_by` | BR-23 |
| `pt_booking` | `trg_late_cancel_pt_booking` | BEFORE UPDATE | `trg_fn_late_cancel_pt_booking` | BR-25 |
| `pt_booking` | `trg_set_updated_by` | BEFORE UPDATE | `trg_fn_set_updated_by` | BR-23 |
| `pt_booking` | `trg_update_remaining_pt_sessions` | AFTER UPDATE | `trg_fn_update_remaining_pt_sessions` | BR-18, BR-25 |
| `user_account` | `trg_check_user_dob_for_member` | BEFORE UPDATE | `trg_fn_check_member_dob_update` | BR-03 |

Ví dụ 1 – **nhật ký thanh toán bất biến (BR-10)**: ba trigger chặn `UPDATE`, `DELETE`, `TRUNCATE` trên `billing_log` với mọi người dùng (lớp bảo vệ còn lại ở mục 5.2.6) (hàm `trg_fn_billing_immutable_update` chỉ cho phép `Completed → Refunded` và `Pending → Completed/Failed`):

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

CREATE TRIGGER trg_billing_immutable_truncate
BEFORE TRUNCATE ON billing_log
FOR EACH STATEMENT
EXECUTE FUNCTION trg_fn_billing_immutable_truncate();
```

Ví dụ 2 – **trừ buổi PT tự động và an toàn khi truy cập đồng thời (BR-18, BR-25)**: `SELECT … FOR UPDATE` khóa hàng hợp đồng trước khi trừ, và chỉ trừ khi ca chuyển sang nhóm trạng thái tính phí:

```sql
CREATE OR REPLACE FUNCTION trg_fn_update_remaining_pt_sessions()
RETURNS TRIGGER AS $$
DECLARE
    v_current_remaining INT;
    -- Các trạng thái làm phát sinh việc trừ buổi (BR-25): đã tập xong, bỏ tập, hủy muộn.
    v_deducting CONSTANT TEXT[] := ARRAY['Completed', 'No_Show', 'Late_Cancelled'];
BEGIN
    -- Chỉ trừ buổi khi chuyển SANG nhóm trạng thái tính phí từ một trạng thái không thuộc nhóm đó
    -- (tránh trừ hai lần khi đổi Completed -> No_Show...). Hủy sớm (Cancelled) không bị trừ vì
    -- buổi tập chỉ bị trừ khi hoàn thành, không trừ lúc đặt lịch.
    IF (NEW.status = ANY (v_deducting) AND NOT (OLD.status = ANY (v_deducting))) THEN
        -- Khóa bản ghi hợp đồng để kiểm tra tránh tranh chấp đồng thời (Concurrency Control)
        SELECT remaining_sessions
        INTO v_current_remaining
        FROM member_subscription
        WHERE subscription_id = NEW.subscription_id
        FOR UPDATE;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Không tìm thấy hợp đồng đăng ký ID: % tương ứng', NEW.subscription_id;
        END IF;

        IF v_current_remaining <= 0 THEN
            RAISE EXCEPTION 'Lỗi nghiệp vụ BR-18: Hợp đồng ID: % đã hết số buổi tập PT khả dụng (Còn lại: % buổi)',
                NEW.subscription_id, v_current_remaining;
        END IF;

        -- Trừ 1 buổi tập còn lại
        UPDATE member_subscription
        SET remaining_sessions = remaining_sessions - 1
        WHERE subscription_id = NEW.subscription_id;

        RAISE NOTICE 'Đã tự động trừ 1 buổi PT (ca chuyển sang %) cho hợp đồng ID: %. Số buổi còn lại: %',
            NEW.status, NEW.subscription_id, (v_current_remaining - 1);
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_update_remaining_pt_sessions ON pt_booking;
CREATE TRIGGER trg_update_remaining_pt_sessions
AFTER UPDATE OF status ON pt_booking
FOR EACH ROW
EXECUTE FUNCTION trg_fn_update_remaining_pt_sessions();
```

#### 4.1.4. View và thủ tục

View `vw_active_member_subscriptions` tổng hợp hợp đồng đang hiệu lực kèm số ngày còn lại và nhãn hiệu lực; view `vw_trainer_schedule_overview` hợp nhất lịch lớp và ca PT của huấn luyện viên (`UNION ALL`).

```sql
CREATE VIEW vw_active_member_subscriptions AS
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    u.email,
    u.phone,
    u.dob,
    mp.plan_id,
    mp.plan_name,
    mp.total_sessions AS package_initial_sessions,
    ms.subscription_id,
    ms.actual_price,
    ms.remaining_sessions AS current_remaining_pt_sessions,
    ms.start_time AS subscription_start,
    ms.end_time   AS subscription_end,
    ms.is_recurring,
    ROUND(EXTRACT(EPOCH FROM (ms.end_time - CURRENT_TIMESTAMP)) / 86400.0, 1) AS days_until_expiration,
    CASE
        WHEN ms.end_time < CURRENT_TIMESTAMP THEN 'Đã Quá Hạn'
        WHEN ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days' THEN 'Sắp Hết Hạn (<= 7 ngày)'
        ELSE 'Đang Hiệu Lực'
    END AS validity_status
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active';
```

Thủ tục `sp_process_subscription_renewals` (BR-24) là thủ tục idempotent: đánh dấu `Expired` cho hợp đồng không tự gia hạn quá hạn, phát hành hóa đơn gia hạn `Pending`, và chuyển `Suspended` khi quá thời gian ân hạn. PostgreSQL không có bộ lập lịch tích hợp nên thủ tục phải được bộ lập lịch ngoài gọi định kỳ: trong Docker demo là service `scheduler` (container `fitzone_renewal_scheduler`, chu kỳ `RENEWAL_INTERVAL_SECONDS`, mặc định 1 ngày), trong production là `pg_cron`/cron (xem mục 5.2.6):

```sql
CREATE OR REPLACE PROCEDURE sp_process_subscription_renewals(
    p_as_of      DATE DEFAULT CURRENT_DATE,
    p_grace_days INT  DEFAULT 3
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_cutoff    TIMESTAMP := p_as_of::TIMESTAMP;
    v_expired   INT;
    v_invoiced  INT;
    v_suspended INT;
BEGIN
    IF p_grace_days < 0 THEN
        RAISE EXCEPTION 'p_grace_days phải >= 0 (nhận được: %)', p_grace_days;
    END IF;

    -- Bước 1: hợp đồng không tự gia hạn hết hạn
    UPDATE member_subscription
    SET sub_status = 'Expired'
    WHERE sub_status = 'Active'
      AND NOT is_recurring
      AND end_time < v_cutoff;
    GET DIAGNOSTICS v_expired = ROW_COUNT;

    -- ... Bước 2: phát hành hóa đơn gia hạn Pending cho chu kỳ kế tiếp (INSERT ... SELECT) ...

    -- Bước 3: hết thời gian ân hạn mà chưa thanh toán -> tạm ngưng
    UPDATE member_subscription
    SET sub_status = 'Suspended'
    WHERE sub_status = 'Active'
      AND is_recurring
      AND end_time + make_interval(days => p_grace_days) < v_cutoff;
    GET DIAGNOSTICS v_suspended = ROW_COUNT;

    RAISE NOTICE 'BR-24 (ngày xét %, ân hạn % ngày): % hợp đồng Expired, % hóa đơn gia hạn mới, % hợp đồng Suspended',
        p_as_of, p_grace_days, v_expired, v_invoiced, v_suspended;
END;
$$;
```

#### 4.1.5. Tập tin SQL, thứ tự nạp và chạy bằng Docker

*Bảng 4-3. Tập tin SQL và thứ tự nạp*

| Thứ tự | Tập tin | Nạp | Nội dung |
| --- | --- | --- | --- |
| 1 | `Phase 3/01_schema_ddl.sql` | Tự động | Extension `btree_gist`, 18 bảng, ràng buộc, chỉ mục, 3 trigger (BR-03, BR-14) |
| 2 | `Phase 3/02_mock_data/01..08_*.sql` | Tự động | Dữ liệu mẫu cho 18 bảng (tham chiếu, người dùng, thiết bị, hợp đồng và hóa đơn, lớp, ca PT, giữ chỗ, bảo trì) |
| 3 | `Phase 3/04_triggers_views.sql` | Tự động | 2 view, 31 trigger nghiệp vụ (gồm `trg_fill_created_by`/`trg_set_updated_by`, BR-23), thủ tục gia hạn và khối kiểm toán dữ liệu mẫu |
| 4 | `Phase 3/08_rbac_security.sql` | Tự động | 5 role nhóm, 5 tài khoản demo, role chủ sở hữu `gym_owner`, `GRANT`/`REVOKE`, `SECURITY DEFINER`, 2 event trigger bảo vệ `billing_log` (nạp lại 04 thì phải nạp lại 08; nạp lại 04 khi event trigger đã có cần lối thoát `SET LOCAL app.allow_billing_maintenance = 'on'` của superuser) |
| – | `Phase 3/03_complex_queries.sql` | Thủ công | 10 truy vấn nâng cao (mục 4.2) |
| – | `Phase 3/05_constraint_test_cases.sql` | Thủ công | 109 test ràng buộc/trigger (mục 5.1) |
| – | `Phase 3/06_performance_test_cases.sql` | Thủ công | 8 test hiệu năng với 100.000+ bản ghi (mục 4.2.12) |
| – | `Phase 3/09_rbac_test_cases.sql` | Thủ công | 61 test phân quyền (mục 5.2) |
| – | `Phase 3/07_test_results.md` | – | Kết quả kiểm thử dạng văn bản |

Chạy toàn bộ hệ thống (CSDL + dữ liệu mẫu + view/trigger + RBAC + ứng dụng web) chỉ bằng một lệnh tại thư mục gốc của repository; PostgreSQL tự nạp các tập tin 01 → 02 → 04 → 08 từ `/docker-entrypoint-initdb.d/`:

```bash
docker compose up --build        # CSDL: cổng 5432, ứng dụng Streamlit: http://localhost:8501
docker compose down -v           # dọn sạch container, mạng và volume
```

### 4.2. Truy vấn nâng cao & kiểm thử hiệu năng (Advanced Queries & Performance Test Cases)

#### 4.2.1. Tổng quan 10 truy vấn nâng cao

Mười truy vấn trong `Phase 3/03_complex_queries.sql` (đáp ứng yêu cầu tối thiểu 10 truy vấn phức hợp của học phần) bao gồm `JOIN` nhiều bảng, truy vấn con, CTE, hàm tổng hợp, window function và `UNION ALL`. **Số dòng kết quả được đo trên dữ liệu mẫu hiện tại**; các truy vấn Q1–Q3 phụ thuộc `CURRENT_DATE` nên số dòng thay đổi theo ngày chạy.

*Bảng 4-4. Danh sách truy vấn nâng cao và số dòng kết quả*

| Q | Nội dung | Kỹ thuật SQL chính | Số dòng |
| --- | --- | --- | --- |
| Q1 | Doanh thu theo từng gói tập trong quý hiện tại | JOIN 3 bảng, GROUP BY, SUM, date_trunc('quarter', payment_date) | 3 |
| Q2 | Top 3 huấn luyện viên có tổng số giờ dạy nhiều nhất trong tháng | UNION ALL, CTE, EXTRACT(EPOCH), GROUP BY, HAVING, ORDER BY LIMIT 3 | 3 |
| Q3 | Hội viên có gói tập sắp hết hạn trong 7 ngày tới | WHERE, CURRENT_TIMESTAMP, INTERVAL, DATE PART | 3 |
| Q4 | Thiết bị đang bảo trì kèm kỹ thuật viên và tổng chi phí | JOIN 4 bảng, WHERE, GROUP BY, SUM | 3 |
| Q5 | Tỷ lệ lấp đầy (fill rate) của các lớp học nhóm | CASE WHEN, ROUND, JOIN, Arithmetic Expression, ORDER BY | 20 |
| Q6 | Ca PT 1-1 bị hủy muộn, hủy hoặc bỏ tập (no-show) | JOIN 3 bảng, WHERE status IN (...), ORDER BY | 4 |
| Q7 | Hội viên đã mua gói PT nhưng chưa từng đặt lịch | LEFT JOIN, IS NULL, WHERE total_sessions > 0 | 1 |
| Q8 | Phân nhóm hội viên theo độ tuổi và gói tập được ưa chuộng nhất | CASE WHEN, EXTRACT(YEAR), CTE, DENSE_RANK() OVER (PARTITION BY) | 5 |
| Q9 | Xếp hạng doanh thu đóng góp của từng hội viên (window function) | Window Function DENSE_RANK() OVER (ORDER BY SUM(amount) DESC) | 20 |
| Q10 | Kiểm toán xung đột trùng lịch của huấn luyện viên | CTE (WITH), Self-Join khoảng thời gian (start_a < end_b AND end_a > start_b) | 0 |

#### 4.2.2. Q1 – Doanh thu theo từng gói tập trong quý hiện tại

**Mục đích nghiệp vụ.** Giúp Ban Giám đốc đánh giá hiệu quả kinh doanh của từng dòng gói dịch vụ (Gói tháng, VIP, PT) trong quý đang vận hành để điều chỉnh chính sách giá.

**Kỹ thuật SQL.** JOIN 3 bảng, GROUP BY, SUM, date_trunc('quarter', payment_date)

**Kết quả trên dữ liệu mẫu.** 3 dòng.

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

#### 4.2.3. Q2 – Top 3 huấn luyện viên có tổng số giờ dạy nhiều nhất trong tháng

**Mục đích nghiệp vụ.** Tổng hợp giờ giảng dạy cả hai hình thức: Dạy lớp nhóm (Class) và Dạy kèm cá nhân (PT 1-1) trong tháng hiện tại để tính thưởng KPI cho HLV xuất sắc.

**Kỹ thuật SQL.** UNION ALL, CTE, EXTRACT(EPOCH), GROUP BY, HAVING, ORDER BY LIMIT 3

**Kết quả trên dữ liệu mẫu.** 3 dòng.

```sql
WITH trainer_teaching_hours AS (
    -- Nguồn 1: Giờ dạy kèm 1-1 (PT_BOOKING) trạng thái Completed
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

    -- Nguồn 2: Giờ đứng lớp học nhóm (CLASS_SCHEDULE)
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

#### 4.2.4. Q3 – Hội viên có gói tập sắp hết hạn trong 7 ngày tới

**Mục đích nghiệp vụ.** Hỗ trợ bộ phận Lễ tân / Chăm sóc khách hàng chủ động liên hệ nhắc nhở gia hạn hợp đồng và tư vấn các gói ưu đãi trung thành (Retention Campaign).

**Kỹ thuật SQL.** WHERE, CURRENT_TIMESTAMP, INTERVAL, DATE PART

**Kết quả trên dữ liệu mẫu.** 3 dòng.

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

#### 4.2.5. Q4 – Thiết bị đang bảo trì kèm kỹ thuật viên và tổng chi phí

**Mục đích nghiệp vụ.** Kiểm soát trạng thái vận hành của trang thiết bị (BR-19), theo dõi các thiết bị đang ngừng hoạt động, người chịu trách nhiệm và lũy kế chi phí.

**Kỹ thuật SQL.** JOIN 4 bảng, WHERE, GROUP BY, SUM

**Kết quả trên dữ liệu mẫu.** 3 dòng.

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

#### 4.2.6. Q5 – Tỷ lệ lấp đầy (fill rate) của các lớp học nhóm

**Mục đích nghiệp vụ.** Đánh giá sức hút của từng lớp học nhóm (Yoga, Pilates, CrossFit), phát hiện các lớp bị ế ẩm (Low fill rate) để tối ưu hóa việc phân bổ phòng học.

**Kỹ thuật SQL.** CASE WHEN, ROUND, JOIN, Arithmetic Expression, ORDER BY

**Kết quả trên dữ liệu mẫu.** 20 dòng.

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

#### 4.2.7. Q6 – Ca PT 1-1 bị hủy muộn, hủy hoặc bỏ tập (no-show)

**Mục đích nghiệp vụ.** Kiểm soát quy định hủy lịch (BR-25), thống kê các hội viên hay vắng mặt không lý do gây lãng phí thời gian biểu của Huấn luyện viên.

**Kỹ thuật SQL.** JOIN 3 bảng, WHERE status IN (...), ORDER BY

**Ghi chú.** 'Late_Cancelled' là ca hủy khi còn dưới 24 giờ (trigger trg_late_cancel_pt_booking tự đổi trạng thái và trừ 1 buổi); 'Cancelled' là hủy sớm, không bị trừ buổi.

**Kết quả trên dữ liệu mẫu.** 4 dòng.

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

#### 4.2.8. Q7 – Hội viên đã mua gói PT nhưng chưa từng đặt lịch

**Mục đích nghiệp vụ.** Xác định nhóm hội viên "ngủ đông" (Inactive/Unengaged) để phân bổ cho Trưởng bộ phận Huấn luyện viên gọi điện thăm hỏi, hướng dẫn lên lịch.

**Kỹ thuật SQL.** LEFT JOIN, IS NULL, WHERE total_sessions > 0

**Kết quả trên dữ liệu mẫu.** 1 dòng.

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

#### 4.2.9. Q8 – Phân nhóm hội viên theo độ tuổi và gói tập được ưa chuộng nhất

**Mục đích nghiệp vụ.** Phân khúc khách hàng nhân khẩu học (Demographics) để bộ phận Marketing định hướng gói tập phù hợp cho Gen Z, Dân văn phòng và Người trung niên.

**Kỹ thuật SQL.** CASE WHEN, EXTRACT(YEAR), CTE, DENSE_RANK() OVER (PARTITION BY)

**Kết quả trên dữ liệu mẫu.** 5 dòng.

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
    age_bracket ASC;
```

#### 4.2.10. Q9 – Xếp hạng doanh thu đóng góp của từng hội viên (window function)

**Mục đích nghiệp vụ.** Xây dựng bảng xếp hạng Hội viên VIP (Loyalty Tier: Vàng, Kim Cương) dựa trên tổng số tiền thực tế đã chi trả qua hóa đơn thanh toán thành công.

**Kỹ thuật SQL.** Window Function DENSE_RANK() OVER (ORDER BY SUM(amount) DESC)

**Kết quả trên dữ liệu mẫu.** 20 dòng.

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

#### 4.2.11. Q10 – Kiểm toán xung đột trùng lịch của huấn luyện viên

**Mục đích nghiệp vụ.** Kiểm toán tính toàn vẹn (Integrity Audit) nhằm phát hiện bất kỳ sự kiện nào bị đụng giờ (Overlapping Time Intervals - BR-12, BR-15) giữa các lớp học nhóm và ca tập PT 1-1 của cùng Huấn luyện viên.

**Kỹ thuật SQL.** CTE (WITH), Self-Join khoảng thời gian (start_a < end_b AND end_a > start_b)

**Ghi chú.** do các quy tắc BR-12/BR-15/BR-16 nay đã được CSDL cưỡng chế (EXCLUDE constraint và trigger), truy vấn này là truy vấn KIỂM TOÁN và được kỳ vọng trả về 0 dòng; nếu xuất hiện dòng nào thì dữ liệu đã bị nạp/sửa vượt qua cơ chế bảo vệ.

**Kết quả trên dữ liệu mẫu.** 0 dòng. (truy vấn kiểm toán, kỳ vọng 0 dòng vì các quy tắc BR-12/15/16 đã được CSDL cưỡng chế).

```sql
WITH all_trainer_events AS (
    -- Tập hợp tất cả sự kiện có sự tham gia của HLV (Lớp nhóm)
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

    -- Tập hợp tất cả ca dạy PT 1-1 chưa bị hủy
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
        pb.status IN ('Scheduled', 'Completed')
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
                         -- Điều kiện chồng lấn thời gian (Overlapping intervals)
                         AND e1.start_time < e2.end_time
                         AND e1.end_time > e2.start_time
JOIN
    user_account u ON e1.trainer_id = u.user_id
WHERE
    (e1.event_type, e1.event_id) < (e2.event_type, e2.event_id) -- Tránh lặp lại kết quả theo thứ tự hoán vị
ORDER BY
    e1.start_time ASC;
```

#### 4.2.12. Kiểm thử hiệu năng và chỉ mục (Performance Test Cases)

**Yêu cầu được kiểm chứng (NFR-PERF-01):** các truy vấn tra cứu/tìm kiếm chính phải trả kết quả dưới 200 ms với khối lượng 100.000 – 200.000 bản ghi mỗi bảng nghiệp vụ.

**Phương pháp** (`Phase 3/06_performance_test_cases.sql`, bọc trong `BEGIN … ROLLBACK`): (1) sinh tạm 100.000 tài khoản, 200.000 hóa đơn và 120.000 ca PT bằng `generate_series()` không vi phạm ràng buộc nào (các trigger nghiệp vụ của người dùng trên `billing_log` và `pt_booking` được tắt tạm trong lúc nạp hàng loạt bằng lối thoát bảo trì `SET LOCAL app.allow_billing_maintenance = 'on'` của superuser vì event trigger BR-10 chặn `ALTER TABLE`, rồi bật lại trước khi đo), rồi `ANALYZE`; (2) mỗi truy vấn chạy `EXPLAIN (ANALYZE)` hai lần: **(a) có chỉ mục** (kế hoạch bình thường) và **(b) không chỉ mục** (tắt `enable_indexscan`, `enable_bitmapscan`, `enable_indexonlyscan` để buộc `Seq Scan`); (3) có chạy làm nóng một lần trước khi đo. Thời gian tuyệt đối phụ thuộc máy; điều cần quan sát là loại phép quét và tỉ lệ chênh lệch giữa (a) và (b).

*Bảng 4-5. Kết quả 8 test hiệu năng: có chỉ mục (a) so với không chỉ mục (b)*

| Mã | Truy vấn | Kế hoạch (a) có chỉ mục | (a) ms | Kế hoạch (b) không chỉ mục | (b) ms | Nhanh hơn | < 200 ms |
| --- | --- | --- | --- | --- | --- | --- | --- |
| PT-01 | Tra cứu tài khoản theo email khi đăng nhập | Index Scan (uq_user_account_email) | 0.037 | Seq Scan (user_account) | 14.119 | 381.6x | PASS |
| PT-02 | Tra cứu tài khoản theo số điện thoại | Index Scan (uq_user_account_phone) | 0.041 | Seq Scan (user_account) | 14.055 | 342.8x | PASS |
| PT-03 | Tổng doanh thu theo phương thức thanh toán trong 1 tuần | Bitmap Index Scan (idx_billing_log_payment_date) | 0.842 | Seq Scan (billing_log) | 33.374 | 39.6x | PASS |
| PT-04 | Lịch sử 20 hóa đơn gần nhất của một hợp đồng | Index Scan (idx_billing_log_subscription_date) | 0.058 | Seq Scan (billing_log) | 18.321 | 315.9x | PASS |
| PT-05 | Tra cứu một hóa đơn theo invoice_no | Index Scan (uq_billing_invoice_no) | 0.041 | Seq Scan (billing_log) | 26.713 | 651.5x | PASS |
| PT-06 | Lịch ca PT trong một ngày của một HLV | Index Scan (idx_pt_booking_dates) | 0.058 | Seq Scan (pt_booking) | 12.300 | 212.1x | PASS |
| PT-07 | Kiểm tra trùng lịch HLV bằng toán tử chồng lấn khoảng thời gian (&&) | Index Scan (ex_pt_trainer_no_overlap) | 0.055 | Seq Scan (pt_booking) | 13.619 | 247.6x | PASS |
| PT-08 | Truy vấn phức hợp Q1: doanh thu từng gói tập trong một quý (JOIN 3 bảng) | Bitmap Index Scan (idx_billing_log_payment_date) | 13.652 | Seq Scan (billing_log) | 41.440 | 3.0x | PASS |

**Kết luận:** 8/8 test đạt NFR-PERF-01 (mọi truy vấn dưới 200 ms, thực tế dưới 14 ms). Các truy vấn tra cứu điểm (PT-01, 02, 04, 05, 06, 07) chạy trong khoảng 0,04 – 0,06 ms nhờ chỉ mục, nhanh hơn 212 – 652 lần so với quét toàn bảng. PT-04 dùng chỉ mục ghép `idx_billing_log_subscription_date (subscription_id, payment_date DESC)` phục vụ cả điều kiện lọc lẫn `ORDER BY`. PT-07 cho thấy chỉ mục GiST của ràng buộc `EXCLUDE` vừa bảo đảm toàn vẹn (BR-12) vừa tăng tốc phép tìm khoảng thời gian chồng lấn (`&&`). PT-08 (truy vấn phức hợp Q1) chỉ cải thiện 3,0 lần vì phần lớn thời gian nằm ở `JOIN` và `GROUP BY` chứ không ở bước lọc.

Kế hoạch thực thi minh họa – PT-01 (tra cứu theo email, chỉ mục B-tree do `UNIQUE` tự sinh):

```text
 Index Scan using uq_user_account_email on user_account (actual time=0.047..0.049 rows=1 loops=1)
   Index Cond: ((email)::text = 'perf_user_77777@perf.test'::text)
 Planning Time: 0.075 ms
 Execution Time: 0.073 ms
```

PT-07 (kiểm tra trùng lịch huấn luyện viên bằng chỉ mục GiST của `ex_pt_trainer_no_overlap`):

```text
 Result (actual time=0.070..0.071 rows=1 loops=1)
   InitPlan 1 (returns $0)
     ->  Index Scan using ex_pt_trainer_no_overlap on pt_booking (actual time=0.069..0.069 rows=1 loops=1)
           Index Cond: ((trainer_user_id = 8) AND (tsrange(start_time, end_time, '[)'::text) && '["2032-03-15 10:30:00","2032-03-15 11:30:00")'::tsrange))
 Planning Time: 0.139 ms
 Execution Time: 0.091 ms
```

## 5. Kiểm thử & bảo mật (Verification & Security)

### 5.1. Test case chứng minh ràng buộc ngăn chặn dữ liệu sai (Constraint Test Cases)

#### 5.1.1. Phương pháp

Bộ kiểm thử `Phase 3/05_constraint_test_cases.sql` chạy trong một giao dịch rồi `ROLLBACK` nên không làm thay đổi dữ liệu mẫu; mỗi test chạy trong một savepoint riêng (khối `BEGIN … EXCEPTION` của PL/pgSQL) và độc lập với nhau.

- **Negative test (TC-xx):** cố tình thực hiện thao tác vi phạm quy tắc nghiệp vụ. Test **PASS** khi CSDL từ chối thao tác với **đúng mã lỗi SQLSTATE** mong đợi.
- **Positive test (TP-xx):** thao tác hợp lệ phải được chấp nhận (SQLSTATE `00000`) và các trigger phải cập nhật dữ liệu dẫn xuất chính xác (ví dụ trừ buổi PT, đồng bộ `current_enrolled`).

*Bảng 5-1. Mã SQLSTATE dùng trong test*

| SQLSTATE | Ý nghĩa | Cơ chế thực thi |
| --- | --- | --- |
| `23502` | not_null_violation | `NOT NULL` |
| `23503` | foreign_key_violation | `FOREIGN KEY … ON DELETE RESTRICT` |
| `23505` | unique_violation | `PRIMARY KEY`, `UNIQUE`, chỉ mục duy nhất từng phần |
| `23514` | check_violation | `CHECK` |
| `23P01` | exclusion_violation | `EXCLUDE USING gist` (chống trùng khoảng thời gian) |
| `P0001` | raise_exception | Trigger PL/pgSQL chủ động `RAISE EXCEPTION` (thông báo nêu mã `BR-xx`) |
| `00000` | successful_completion | Test dương (TP-xx): thao tác hợp lệ được chấp nhận |

#### 5.1.2. Kết quả: 109/109 test PASS

Kết quả chạy trên PostgreSQL 16: **109 test, 109 đạt, 0 không đạt** (74 test âm TC-xx và 35 test dương TP-xx). Cột "Quy tắc" cho biết quy tắc nghiệp vụ được kiểm chứng; thông báo lỗi chi tiết của CSDL có trong `Phase 3/07_test_results.md`.

*Bảng 5-2. 109 test case ràng buộc và trigger*

| Mã | Quy tắc | Kịch bản | Mong đợi | Thực tế | Kết quả |
| --- | --- | --- | --- | --- | --- |
| TC-01 | BR-02 | Tạo tài khoản trùng email đã tồn tại (uq_user_account_email) | 23505 | 23505 | PASS |
| TC-02 | BR-02 | Tạo tài khoản trùng số điện thoại đã tồn tại (uq_user_account_phone) | 23505 | 23505 | PASS |
| TC-03 | BR-02 | Tạo tài khoản thiếu email (NOT NULL) | 23502 | 23502 | PASS |
| TC-04 | BR-03 | Đăng ký hồ sơ hội viên cho người dưới 12 tuổi (trg_check_member_dob) | P0001 | P0001 | PASS |
| TC-05 | BR-03 | Sửa ngày sinh của hội viên hiện có thành dưới 12 tuổi (trg_check_user_dob_for_member) | P0001 | P0001 | PASS |
| TC-06 | BR-22 | Gán trạng thái tài khoản ngoài miền giá trị (chk_user_account_status) | 23514 | 23514 | PASS |
| TC-07 | BR-11 | Điểm đánh giá HLV vượt quá 5.00 (chk_trainer_rating) | 23514 | 23514 | PASS |
| TC-08 | BR-22 | Gán cùng một vai trò hai lần cho một người dùng (pk_user_role) | 23505 | 23505 | PASS |
| TC-09 | BR-04 | Tạo gói tập có thời hạn 0 ngày (chk_membership_plan_duration) | 23514 | 23514 | PASS |
| TC-10 | BR-04 | Tạo gói tập có giá âm (chk_membership_plan_price) | 23514 | 23514 | PASS |
| TC-11 | BR-06 | Hợp đồng có ngày kết thúc trước ngày bắt đầu (chk_subscription_dates) | 23514 | 23514 | PASS |
| TC-12 | BR-01 | Ký hợp đồng cho người không có hồ sơ hội viên (HLV ID 5) (fk_subscription_member) | 23503 | 23503 | PASS |
| TC-13 | BR-18 | Số buổi PT còn lại bị âm (chk_subscription_remaining) | 23514 | 23514 | PASS |
| TC-14 | BR-09 | Phát hành hóa đơn trùng số invoice_no (uq_billing_invoice_no) | 23505 | 23505 | PASS |
| TC-15 | BR-09 | Hóa đơn có số tiền bằng 0 (chk_billing_amount) | 23514 | 23514 | PASS |
| TC-16 | BR-09 | Phương thức thanh toán không hợp lệ (chk_billing_method) | 23514 | 23514 | PASS |
| TC-17 | BR-10 | Xóa hợp đồng đã phát sinh hóa đơn (fk_billing_subscription, ON DELETE RESTRICT) | 23503 | 23503 | PASS |
| TC-18 | BR-04 | Xóa gói tập đang được hợp đồng sử dụng (fk_subscription_plan) | 23503 | 23503 | PASS |
| TC-19 | BR-13 | Phòng tập có sức chứa bằng 0 (chk_facilities_capacity) | 23514 | 23514 | PASS |
| TC-20 | BR-17 | Lớp học có giờ kết thúc bằng giờ bắt đầu (chk_class_time) | 23514 | 23514 | PASS |
| TC-21 | BR-15 | Xếp 2 lớp trùng giờ trong cùng một phòng (ex_class_room_no_overlap) | 23P01 | 23P01 | PASS |
| TC-22 | BR-12 | Một HLV dạy 2 lớp trùng giờ ở 2 phòng khác nhau (ex_class_trainer_no_overlap) | 23P01 | 23P01 | PASS |
| TC-23 | BR-19 | Xếp lớp vào phòng đang bảo trì, phòng ID 6 (trg_prevent_class_in_maintenance_room) | P0001 | P0001 | PASS |
| TC-24 | BR-14 | Đăng ký thêm hội viên vào lớp đã đầy, lớp ID 1: 20/20 (chk_class_enrollment_limit) | 23514 | 23514 | PASS |
| TC-25 | BR-14 | Một hợp đồng đăng ký lại cùng một lớp sau khi hủy (uq_enrollment_subscription_class) | 23505 | 23505 | PASS |
| TC-26 | BR-17 | Ca PT có giờ kết thúc bằng giờ bắt đầu (chk_pt_booking_time) | 23514 | 23514 | PASS |
| TC-27 | BR-12 | Một HLV nhận 2 ca PT trùng giờ với 2 hội viên (ex_pt_trainer_no_overlap) | 23P01 | 23P01 | PASS |
| TC-28 | BR-16 | Một hội viên đặt 2 ca PT trùng giờ với 2 HLV (ex_pt_member_no_overlap) | 23P01 | 23P01 | PASS |
| TC-29 | BR-18 | Đặt ca PT bằng hợp đồng của hội viên khác (fk_booking_subscription_member) | 23503 | 23503 | PASS |
| TC-30 | BR-18 | Hoàn thành ca PT khi hợp đồng đã hết buổi (trg_update_remaining_pt_sessions) | P0001 | P0001 | PASS |
| TC-31 | BR-25 | Trạng thái ca PT ngoài miền giá trị (chk_pt_booking_status) | 23514 | 23514 | PASS |
| TC-32 | BR-26 | Thiết bị có thời gian khấu hao 0 tháng (chk_equipment_depreciation) | 23514 | 23514 | PASS |
| TC-33 | BR-26 | Thiết bị trùng số serial (uq_equipment_serial) | 23505 | 23505 | PASS |
| TC-34 | BR-19 | Giữ chỗ thiết bị đang bảo trì - cột status (trg_prevent_equipment_reservation_under_maintenance) | P0001 | P0001 | PASS |
| TC-35 | BR-21 | Lượt giữ chỗ gắn đồng thời cả ca PT và lớp học (chk_reservation_source) | 23514 | 23514 | PASS |
| TC-36 | BR-21 | Lượt giữ chỗ không gắn với ca PT hay lớp học nào (chk_reservation_source) | 23514 | 23514 | PASS |
| TC-37 | BR-20 | Nhật ký bảo trì có chi phí âm (chk_maintenance_cost) | 23514 | 23514 | PASS |
| TC-38 | BR-20 | Nhật ký bảo trì hoàn thành trước khi bắt đầu (chk_maintenance_time) | 23514 | 23514 | PASS |
| TC-39 | BR-20 | Giao việc bảo trì cho người không phải nhân viên, HLV ID 5 (fk_maintenance_staff) | 23503 | 23503 | PASS |
| TP-01 | BR-03 | Hội viên đủ 18 tuổi được tạo hồ sơ thành công | 00000 | 00000 | PASS |
| TP-02 | BR-18 | Hoàn thành ca PT tự động trừ đúng 1 buổi (hợp đồng ID 1: n -> n-1) | 00000 | 00000 | PASS |
| TP-03 | BR-14 | Đăng ký lớp tự động tăng current_enrolled (lớp ID 2: 16 -> 17) | 00000 | 00000 | PASS |
| TP-04 | BR-14 | Hủy đăng ký lớp tự động giảm current_enrolled (lớp ID 1: 20 -> 19) | 00000 | 00000 | PASS |
| TP-05 | BR-12 | Ca PT đã hủy không chặn ca mới cùng khung giờ (exclusion có điều kiện) | 00000 | 00000 | PASS |
| TP-06 | BR-15 | Hai lớp nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) không bị coi là trùng | 00000 | 00000 | PASS |
| TP-07 | BR-09 | Hóa đơn hợp lệ ở chu kỳ tính phí mới được ghi nhận | 00000 | 00000 | PASS |
| TC-40 | BR-05 | Hội viên đang Active có thêm hợp đồng Active thứ hai (uq_member_one_active_subscription) | 23505 | 23505 | PASS |
| TC-41 | BR-07 | Tạo hợp đồng Active trực tiếp khi chưa có hóa đơn Completed (trg_require_payment_before_active) | P0001 | P0001 | PASS |
| TC-42 | BR-07 | Chuyển hợp đồng sang Active khi mới có hóa đơn Pending, chưa Completed (trg_require_payment_before_active) | P0001 | P0001 | PASS |
| TC-43 | BR-08 | Hai hóa đơn còn hiệu lực cho cùng một chu kỳ của một hợp đồng (uq_billing_subscription_period) | 23505 | 23505 | PASS |
| TP-08 | BR-07 | Hợp đồng Pending + hóa đơn Completed -> tự động Active (trg_activate_on_payment_insert) | 00000 | 00000 | PASS |
| TP-09 | BR-05 | Hợp đồng cũ chuyển Expired thì hội viên được kích hoạt hợp đồng mới (chỉ còn 1 Active) | 00000 | 00000 | PASS |
| TP-10 | BR-08 | Hóa đơn Failed không chiếm chu kỳ: thanh toán lại (Completed) cùng chu kỳ được chấp nhận | 00000 | 00000 | PASS |
| TP-11 | BR-08 | INSERT hóa đơn không nêu chu kỳ: trg_fill_billing_period_start điền ngày bắt đầu hợp đồng | 00000 | 00000 | PASS |
| TC-44 | BR-10 | Sửa số tiền hóa đơn Completed có sẵn (trg_billing_immutable_update) | P0001 | P0001 | PASS |
| TC-45 | BR-10 | Xóa hóa đơn Completed có sẵn (trg_billing_immutable_delete) | P0001 | P0001 | PASS |
| TC-46 | BR-10 | TRUNCATE bảng billing_log (trg_billing_immutable_truncate) | P0001 | P0001 | PASS |
| TC-47 | BR-10 | Đổi hóa đơn Completed sang Failed - chỉ được sang Refunded (trg_billing_immutable_update) | P0001 | P0001 | PASS |
| TC-48 | BR-10 | Hóa đơn Pending bị đổi mã invoice_no (trg_billing_immutable_update) | P0001 | P0001 | PASS |
| TC-49 | BR-10 | Sửa hóa đơn đã ở trạng thái cuối Refunded (trg_billing_immutable_update) | P0001 | P0001 | PASS |
| TP-12 | BR-10 | Phiên kiểm thử chạy bằng superuser (chứng minh BR-10 không dựa vào phân quyền) | 00000 | 00000 | PASS |
| TP-13 | BR-10 | Hóa đơn Completed chuyển sang Refunded được phép (hoàn tiền) | 00000 | 00000 | PASS |
| TP-14 | BR-10 | Hóa đơn Pending chuyển sang Completed được phép và kích hoạt hợp đồng Pending | 00000 | 00000 | PASS |
| TC-50 | BR-12 | HLV đã có ca PT, xếp thêm lớp nhóm trùng giờ cho chính HLV đó (trg_check_class_schedule_conflicts) | 23P01 | 23P01 | PASS |
| TC-51 | BR-12 | HLV đang đứng lớp nhóm, nhận thêm ca PT trùng giờ (trg_check_pt_booking_conflicts) | 23P01 | 23P01 | PASS |
| TC-52 | BR-16 | Hội viên đã đăng ký lớp nhóm, đặt thêm ca PT trùng giờ lớp đó (trg_check_pt_booking_conflicts) | 23P01 | 23P01 | PASS |
| TC-53 | BR-16 | Hội viên đã có ca PT, đăng ký lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts) | 23P01 | 23P01 | PASS |
| TC-54 | BR-16 | Hội viên đăng ký 2 lớp nhóm trùng giờ (trg_check_class_enrollment_conflicts) | 23P01 | 23P01 | PASS |
| TC-55 | BR-16 | Đổi giờ lớp đã có người đăng ký sang giờ trùng ca PT của hội viên đó (trg_check_class_schedule_conflicts) | 23P01 | 23P01 | PASS |
| TC-68 | BR-16 | Đăng ký lần 2 cùng lớp khi đang Enrolled bị chặn bởi trigger BR-16 (trg_check_class_enrollment_conflicts) | 23P01 | 23P01 | PASS |
| TP-15 | BR-16 | Lớp nhóm và ca PT nối tiếp nhau (22:00 kết thúc, 22:00 bắt đầu) của cùng hội viên được chấp nhận | 00000 | 00000 | PASS |
| TC-56 | BR-18 | Đặt ca PT bằng hợp đồng chưa Active (Pending) (trg_check_pt_booking_creation) | P0001 | P0001 | PASS |
| TC-57 | BR-18 | Đặt ca PT sau ngày hết hạn hợp đồng (trg_check_pt_booking_creation) | P0001 | P0001 | PASS |
| TC-58 | BR-18 | Đặt ca PT trước ngày bắt đầu hợp đồng (trg_check_pt_booking_creation) | P0001 | P0001 | PASS |
| TC-59 | BR-18 | Số ca PT Scheduled vượt số buổi còn lại của hợp đồng (trg_check_pt_booking_creation) | P0001 | P0001 | PASS |
| TC-60 | BR-18 | Đặt ca PT bằng hợp đồng gói không có buổi PT (hợp đồng ID 2, 0 buổi) (trg_check_pt_booking_creation) | P0001 | P0001 | PASS |
| TP-16 | BR-18 | Còn đúng 1 buổi chưa đặt thì được đặt thêm 1 ca Scheduled | 00000 | 00000 | PASS |
| TC-61 | BR-21 | Một thiết bị bị giữ chỗ trùng giờ cho 2 ca PT khác nhau (ex_reservation_equipment_no_overlap) | 23P01 | 23P01 | PASS |
| TC-62 | BR-21 | Giữ chỗ thiết bị trong lúc có ca bảo trì In_Progress chưa kết thúc (trg_check_reservation_window) | 23P01 | 23P01 | PASS |
| TC-63 | BR-21 | Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của ca PT gắn kèm (trg_check_reservation_window) | P0001 | P0001 | PASS |
| TC-64 | BR-21 | Giờ giữ chỗ thiết bị vượt ra ngoài khung giờ của lớp học gắn kèm (trg_check_reservation_window) | P0001 | P0001 | PASS |
| TP-17 | BR-21 | Giữ chỗ thiết bị nằm trọn trong khung giờ ca PT được chấp nhận | 00000 | 00000 | PASS |
| TP-18 | BR-21 | Lượt giữ chỗ đã Cancelled không chiếm thiết bị: giữ chỗ mới cùng giờ được chấp nhận | 00000 | 00000 | PASS |
| TP-19 | BR-21 | Ca bảo trì đã Completed không chặn giữ chỗ thiết bị | 00000 | 00000 | PASS |
| TC-65 | BR-23 | Người thực hiện không tồn tại trong user_account (fk_booking_created_by) | 23503 | 23503 | PASS |
| TP-20 | BR-23 | created_by_user_id tự điền từ SET LOCAL app.current_user_id cho 5 bảng giao dịch | 00000 | 00000 | PASS |
| TP-21 | BR-23 | Giá trị created_by_user_id nêu rõ trong INSERT không bị trigger ghi đè | 00000 | 00000 | PASS |
| TC-72 | BR-23 | INSERT khi chưa đặt app.current_user_id (và không nêu created_by_user_id) bị chặn | P0001 | P0001 | PASS |
| TC-73 | BR-23 | UPDATE khi chưa đặt app.current_user_id bị chặn (không có người sửa để ghi updated_by_user_id) | P0001 | P0001 | PASS |
| TC-74 | BR-23 | Không được đổi created_by_user_id sau khi đã ghi (vết người tạo bất biến) | P0001 | P0001 | PASS |
| TP-22 | BR-23 | UPDATE tự ghi updated_by_user_id (từ biến phiên, không tin giá trị truyền vào) và updated_at | 00000 | 00000 | PASS |
| TP-35 | BR-23 | UPDATE nội bộ do trigger (BR-07 tự kích hoạt hợp đồng khi thanh toán) ghi người thao tác hiện tại vào updated_by_user_id | 00000 | 00000 | PASS |
| TC-66 | BR-24 | Gọi thủ tục với số ngày ân hạn âm (sp_process_subscription_renewals) | P0001 | P0001 | PASS |
| TP-23 | BR-24 | Quá hạn: HĐ không tự gia hạn -> Expired; HĐ tự gia hạn -> hóa đơn Pending kỳ kế tiếp, vẫn Active trong ân hạn | 00000 | 00000 | PASS |
| TP-24 | BR-24 | Gọi thủ tục nhiều lần trong ngày không phát sinh thêm hóa đơn gia hạn (idempotent) | 00000 | 00000 | PASS |
| TP-25 | BR-24 | Quá thời gian ân hạn (3 ngày) mà chưa thanh toán -> hợp đồng tự gia hạn chuyển Suspended | 00000 | 00000 | PASS |
| TP-26 | BR-24 | Thanh toán hóa đơn gia hạn: hợp đồng Suspended -> Active, end_time + duration_days, đặt lại số buổi PT | 00000 | 00000 | PASS |
| TC-67 | BR-25 | Ngày đặt lịch booking_date khác ngày của start_time (chk_pt_booking_date) | 23514 | 23514 | PASS |
| TP-27 | BR-25 | Hủy sớm (> 24 giờ): ca giữ trạng thái Cancelled và KHÔNG trừ buổi (trg_late_cancel_pt_booking) | 00000 | 00000 | PASS |
| TP-28 | BR-25 | Hủy muộn (< 24 giờ): trigger đổi thành Late_Cancelled và trừ đúng 1 buổi | 00000 | 00000 | PASS |
| TP-29 | BR-25 | Bỏ tập (No_Show) bị trừ đúng 1 buổi (trg_update_remaining_pt_sessions) | 00000 | 00000 | PASS |
| TP-30 | BR-25 | Đổi Completed -> No_Show không bị trừ buổi lần thứ hai | 00000 | 00000 | PASS |
| TC-69 | BR-19 | Chuyển phòng sang bảo trì khi còn lớp học tương lai (trg_prevent_room_maintenance_with_future_classes) | P0001 | P0001 | PASS |
| TC-70 | BR-19 | Chuyển thiết bị sang bảo trì khi còn lượt giữ chỗ Reserved tương lai (trg_prevent_equipment_maintenance_with_future_reservations) | P0001 | P0001 | PASS |
| TC-71 | BR-19 | Mở ca bảo trì In_Progress cho thiết bị còn lượt giữ chỗ tương lai bị chặn (chuỗi trg_start_equipment_maintenance_insert -> BR-19) | P0001 | P0001 | PASS |
| TP-31 | BR-19 | Phòng không còn lớp tương lai được chuyển sang bảo trì | 00000 | 00000 | PASS |
| TP-32 | BR-19 | Chèn nhật ký bảo trì In_Progress tự chuyển thiết bị sang Under_Maintenance (trg_start_equipment_maintenance_insert) | 00000 | 00000 | PASS |
| TP-33 | BR-19 | Hoàn tất ca bảo trì duy nhất tự đưa thiết bị về Operational (trg_finish_equipment_maintenance) | 00000 | 00000 | PASS |
| TP-34 | BR-19 | Còn ca In_Progress khác thì hoàn tất 1 ca chưa đưa thiết bị về Operational; hoàn tất nốt mới về Operational | 00000 | 00000 | PASS |

#### 5.1.3. Phạm vi kiểm chứng và giới hạn

Các quy tắc có test trực tiếp: BR-01, BR-02, BR-03, BR-04, BR-05, BR-06, BR-07, BR-08, BR-09, BR-10, BR-11, BR-12, BR-13, BR-14, BR-15, BR-16, BR-17, BR-18, BR-19, BR-20, BR-21, BR-22, BR-23, BR-24, BR-25, BR-26. Quy tắc không có test riêng trong bộ 05 (được kiểm chứng gián tiếp hoặc ở bộ khác): không có.

Mọi quy tắc BR-01…BR-26 đều được thực thi ở mức CSDL; các lưu ý còn lại (superuser là gốc tin cậy của BR-10, BR-24 cần bộ lập lịch ngoài, BR-22 đồng bộ thủ công bảng `role_permission` với `GRANT`) được nêu trong mục 1.2.1 và tổng hợp ở mục 5.2.6. Mọi script test đặt `app.current_user_id` ở đầu tập tin vì BR-23 từ chối ghi dữ liệu khi chưa có người thực hiện.

### 5.2. Phân quyền theo vai trò – RBAC (GRANT/REVOKE)

#### 5.2.1. Thiết kế phân quyền

Hệ thống có hai tầng phân quyền. **Tầng dữ liệu ứng dụng** gồm các bảng `role`, `user_role`, `permission`, `role_permission` (mô hình RBAC đa vai trò M:N, BR-22). **Tầng CSDL** (`Phase 3/08_rbac_security.sql`) hiện thực 5 role nhóm PostgreSQL `NOLOGIN` tương ứng 5 vai trò, cùng 5 tài khoản đăng nhập mẫu thừa hưởng (`INHERIT`) quyền của role nhóm; mọi đối tượng ứng dụng thuộc role `NOLOGIN` `gym_owner` (không ai đăng nhập bằng role này). Nguyên tắc đặc quyền tối thiểu: thu hồi mọi quyền của `PUBLIC`, rồi chỉ `GRANT` đúng những gì ma trận quyền yêu cầu; cột nhạy cảm `user_account.password_hash` được bảo vệ bằng `GRANT` mức cột; script idempotent (dọn role cũ rồi tạo lại) nên chạy lại nhiều lần vẫn an toàn.

*Bảng 5-3. Năm role nhóm và phạm vi quyền*

| Role nhóm | Tài khoản demo | Quyền ứng dụng | Phạm vi quyền ở mức CSDL |
| --- | --- | --- | --- |
| `gym_role_admin` | `gym_u_admin` | 1–10 | `SELECT/INSERT/UPDATE/DELETE` trên mọi bảng, **trừ**: `billing_log` chỉ `SELECT, INSERT` (BR-10); không `SELECT` được `password_hash` (vẫn `INSERT/UPDATE` để đặt mật khẩu); không có `TRUNCATE` |
| `gym_role_receptionist` | `gym_u_reception` | 1, 2, 3, 5, 6, 7 | Không có `DELETE` ở bất kỳ bảng nào; `UPDATE user_account` theo cột (không gồm `password_hash`); `INSERT` hóa đơn; được gọi `sp_process_subscription_renewals` |
| `gym_role_trainer` | `gym_u_trainer` | 1, 6, 7 | Chủ yếu `SELECT`; chỉ `UPDATE (status)` trên `pt_booking`, `class_enrollment`; chỉ đọc cột không nhạy cảm của `user_account`, `member_subscription` |
| `gym_role_technician` | `gym_u_tech` | 8, 9 | `SELECT/INSERT/UPDATE` trên `equipment`, `maintenance_log`; `UPDATE (status)` trên `facilities_room`; không đọc được dữ liệu hội viên và hóa đơn |
| `gym_role_member` | `gym_u_member` | 1 | Chỉ `SELECT` danh mục công khai: `membership_plan`, `facilities_room`, `class_schedule` (các cột công khai, ẩn `created_by_user_id`) |

#### 5.2.2. Ma trận quyền (role × bảng)

Ký hiệu: S = `SELECT`, I = `INSERT`, U = `UPDATE`, D = `DELETE`; `(...)` = chỉ trên các cột nêu trong ngoặc; "x" = có quyền `EXECUTE`. Ma trận được sinh tự động từ `has_table_privilege` / `has_column_privilege` trên CSDL đã nạp `08_rbac_security.sql`.

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

#### 5.2.3. Các lệnh GRANT/REVOKE tiêu biểu

**Củng cố mặc định và tạo role nhóm** – thu hồi toàn bộ quyền của `PUBLIC`, tạo 5 role `NOLOGIN`:

```sql
REVOKE ALL ON ALL TABLES IN SCHEMA public FROM PUBLIC;
REVOKE ALL ON ALL SEQUENCES IN SCHEMA public FROM PUBLIC;
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

CREATE ROLE gym_role_admin        NOLOGIN;
CREATE ROLE gym_role_receptionist NOLOGIN;
CREATE ROLE gym_role_trainer      NOLOGIN;
CREATE ROLE gym_role_technician   NOLOGIN;
CREATE ROLE gym_role_member       NOLOGIN;

GRANT USAGE ON SCHEMA public TO gym_role_admin, gym_role_receptionist,
                                gym_role_trainer, gym_role_technician, gym_role_member;
```

**Quản trị viên** – toàn quyền DML nhưng không sửa/xóa được hóa đơn và không đọc được `password_hash`:

```sql
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO gym_role_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA public TO gym_role_admin;

REVOKE UPDATE, DELETE ON billing_log FROM gym_role_admin;

REVOKE SELECT ON user_account FROM gym_role_admin;
GRANT SELECT (user_id, full_name, email, phone, dob, emergency_contact, status, created_at)
    ON user_account TO gym_role_admin;
```

**Lễ tân** – `GRANT` mức cột trên `user_account` (không có `password_hash`), chỉ `INSERT` hóa đơn, không có `DELETE`:

```sql
GRANT SELECT (user_id, full_name, email, phone, dob, emergency_contact, status, created_at)
    ON user_account TO gym_role_receptionist;
GRANT INSERT ON user_account TO gym_role_receptionist;
-- UPDATE mức cột, loại trừ password_hash để lễ tân không thể ghi đè mật khẩu người khác.
GRANT UPDATE (full_name, email, phone, dob, emergency_contact, status)
    ON user_account TO gym_role_receptionist;
GRANT SELECT, INSERT ON billing_log TO gym_role_receptionist;
GRANT SELECT, INSERT, UPDATE ON member_subscription TO gym_role_receptionist;
GRANT SELECT, INSERT, UPDATE ON pt_booking TO gym_role_receptionist;
```

**Huấn luyện viên, kỹ thuật viên, hội viên** – quyền hẹp theo trách nhiệm:

```sql
-- gym_role_trainer
GRANT SELECT (user_id, full_name, phone, emergency_contact)
    ON user_account TO gym_role_trainer;
GRANT SELECT (subscription_id, member_user_id, plan_id, remaining_sessions,
              start_time, end_time, sub_status)
    ON member_subscription TO gym_role_trainer;
-- Chỉ được đổi trạng thái (điểm danh, Completed, No_Show), không được đổi HLV/hội viên/giờ.
GRANT UPDATE (status) ON pt_booking TO gym_role_trainer;
GRANT UPDATE (status) ON class_enrollment TO gym_role_trainer;

-- gym_role_technician
GRANT SELECT, INSERT, UPDATE ON equipment, maintenance_log TO gym_role_technician;
GRANT SELECT ON facilities_room TO gym_role_technician;
GRANT UPDATE (status) ON facilities_room TO gym_role_technician;

-- gym_role_member
GRANT SELECT ON membership_plan, facilities_room TO gym_role_member;
-- class_schedule: không cấp created_by_user_id (BR-23: vết người thực hiện là dữ liệu nội bộ của nhân viên).
GRANT SELECT (class_id, trainer_user_id, room_id, class_name, start_time, end_time,
              max_capacity, current_enrolled)
    ON class_schedule TO gym_role_member;
```

**Tài khoản đăng nhập mẫu** (mật khẩu `demo_2026` chỉ dùng để trình diễn, phải đổi khi triển khai thật) và **quyền thực thi thủ tục gia hạn** (chỉ Admin và Lễ tân):

```sql
CREATE ROLE gym_u_admin     LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_admin;
CREATE ROLE gym_u_reception LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_receptionist;
CREATE ROLE gym_u_trainer   LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_trainer;
CREATE ROLE gym_u_tech      LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_technician;
CREATE ROLE gym_u_member    LOGIN INHERIT PASSWORD 'demo_2026' IN ROLE gym_role_member;

REVOKE EXECUTE ON PROCEDURE sp_process_subscription_renewals(DATE, INT) FROM PUBLIC;
GRANT EXECUTE ON PROCEDURE sp_process_subscription_renewals(DATE, INT)
    TO gym_role_admin, gym_role_receptionist;
```

**Chủ sở hữu duy nhất `gym_owner` và event trigger bảo vệ `billing_log` (BR-10, lớp 3 và 4)** – không tài khoản đăng nhập nào sở hữu bảng nên không `ALTER`/`DROP` được; event trigger chặn cả superuser (superuser chỉ bảo trì được bằng thao tác tường minh `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`):

```sql
-- gym_owner: role NOLOGIN, KHÔNG phải superuser, không là thành viên của role nào và không role
-- đăng nhập nào là thành viên của nó. Chỉ superuser (gốc tin cậy) mới SET ROLE/ALTER OWNER được.
-- Không bao giờ DROP gym_owner khi chạy lại vì làm vậy sẽ kéo theo xóa đối tượng ứng dụng.
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gym_owner') THEN
        CREATE ROLE gym_owner NOLOGIN;
    END IF;
END;
$$;

GRANT USAGE, CREATE ON SCHEMA public TO gym_owner;

CREATE EVENT TRIGGER evt_protect_billing_log ON ddl_command_end
    WHEN TAG IN ('ALTER TABLE', 'ALTER TRIGGER', 'ALTER FUNCTION', 'CREATE FUNCTION')
    EXECUTE FUNCTION fn_evt_protect_billing_log();

CREATE EVENT TRIGGER evt_protect_billing_log_drop ON sql_drop
    WHEN TAG IN ('DROP TABLE', 'DROP TRIGGER', 'DROP FUNCTION')
    EXECUTE FUNCTION fn_evt_protect_billing_log();
```

#### 5.2.4. Hàm trigger SECURITY DEFINER: lý do

Hàm trigger mặc định chạy với quyền của **người kích hoạt**. Nếu huấn luyện viên đổi `pt_booking.status = 'Completed'`, trigger trừ buổi phải `UPDATE member_subscription` – bảng mà huấn luyện viên không (và không được) có quyền ghi; tương tự, lễ tân thêm `class_enrollment` sẽ kích hoạt cập nhật `class_schedule.current_enrolled`. Nếu không có `SECURITY DEFINER`, các thao tác hợp lệ này sẽ bị từ chối với `42501`; còn nếu cấp thêm quyền ghi cho các role thì phá vỡ nguyên tắc đặc quyền tối thiểu. Giải pháp: mọi hàm trigger chạy bằng quyền chủ sở hữu hàm, kèm `SET search_path = public, pg_temp` cố định để chống tấn công chiếm quyền qua `search_path` (NFR-SEC-05). Danh sách hàm được liệt kê động từ `pg_proc` nên hàm trigger thêm sau này cũng tự được áp dụng khi chạy lại script.

```sql
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'gym_owner') THEN
        CREATE ROLE gym_owner NOLOGIN;
    END IF;
END;
$$;
```

Thủ tục `sp_process_subscription_renewals` chạy với quyền **người gọi** (`SECURITY INVOKER`) nên chỉ role có quyền `UPDATE member_subscription` và `INSERT billing_log` (Admin, Lễ tân) mới gọi được.

#### 5.2.5. Kết quả kiểm thử phân quyền

Bộ `Phase 3/09_rbac_test_cases.sql` chạy bằng superuser nhưng chuyển sang từng role bằng `SET LOCAL ROLE` (tự hoàn tác cùng savepoint) để thử cả thao tác được phép lẫn thao tác bị cấm, chạy trong giao dịch rồi `ROLLBACK`. Thao tác bị cấm phải nhận `42501` (insufficient_privilege); thao tác hợp lệ phải thành công (`00000`) kể cả khi phải đi qua chuỗi trigger `SECURITY DEFINER`. **Kết quả: 61/61 test PASS.** Mã test: `RA/TA/EA/MA/AA` = thao tác được phép; `RD/TD/ED/MD/AD` = thao tác bị từ chối; `LA/LD` = tài khoản đăng nhập thừa hưởng quyền role nhóm; `EV-01..EV-13` = kiểm thử event trigger và quyền sở hữu bảo vệ BR-10 (superuser bị chặn `P0001`, role ứng dụng bị chặn `42501`, lối thoát bảo trì có chủ đích, tất cả đối tượng thuộc `gym_owner`).

*Bảng 5-5. 61 test case phân quyền*

| Mã | Vai trò | Kịch bản | Mong đợi | Thực tế | Kết quả |
| --- | --- | --- | --- | --- | --- |
| RA-01 | gym_role_receptionist | Tạo tài khoản hội viên mới kèm hồ sơ member_profile | 00000 | 00000 | PASS |
| RA-02 | gym_role_receptionist | Đọc thông tin hội viên (không gồm password_hash) | 00000 | 00000 | PASS |
| RD-01 | gym_role_receptionist | Đọc cột password_hash của user_account | 42501 | 42501 | PASS |
| RD-02 | gym_role_receptionist | SELECT * trên user_account (bao gồm password_hash) | 42501 | 42501 | PASS |
| RD-03 | gym_role_receptionist | UPDATE hóa đơn billing_log (BR-10) | 42501 | 42501 | PASS |
| RD-04 | gym_role_receptionist | DELETE hóa đơn billing_log (BR-10) | 42501 | 42501 | PASS |
| RD-05 | gym_role_receptionist | DELETE hợp đồng member_subscription | 42501 | 42501 | PASS |
| RD-06 | gym_role_receptionist | UPDATE giá gói tập membership_plan (thuộc quyền Admin) | 42501 | 42501 | PASS |
| RA-03 | gym_role_receptionist | Thêm đăng ký lớp: trigger SECURITY DEFINER cập nhật current_enrolled (lớp ID 2: 16 -> 17) | 00000 | 00000 | PASS |
| RA-04 | gym_role_receptionist | Ghi nhận hóa đơn thanh toán mới vào billing_log | 00000 | 00000 | PASS |
| RA-05 | gym_role_receptionist | Gọi thủ tục sp_process_subscription_renewals (BR-24): phát hành hóa đơn gia hạn Pending | 00000 | 00000 | PASS |
| RA-06 | gym_role_receptionist | Tạo hợp đồng Pending + hóa đơn Completed: chuỗi trigger tự kích hoạt Active (BR-07) và điền created_by_user_id (BR-23) | 00000 | 00000 | PASS |
| RD-07 | gym_role_receptionist | Ghi đè billing_log.created_by_user_id (BR-10: UPDATE hóa đơn bị cấm) | 42501 | 42501 | PASS |
| TA-01 | gym_role_trainer | Đánh dấu ca PT Completed: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | 00000 | 00000 | PASS |
| TA-02 | gym_role_trainer | Đánh dấu ca PT No_Show: trigger SECURITY DEFINER trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | 00000 | 00000 | PASS |
| TA-03 | gym_role_trainer | Hủy ca PT < 24h: trigger đổi Cancelled thành Late_Cancelled và trừ 1 buổi (BR-25) | 00000 | 00000 | PASS |
| TA-04 | gym_role_trainer | Điểm danh lớp học: đổi class_enrollment.status sang Attended | 00000 | 00000 | PASS |
| TA-05 | gym_role_trainer | Đọc khung nhìn vw_trainer_schedule_overview | 00000 | 00000 | PASS |
| TD-01 | gym_role_trainer | Đổi HLV phụ trách pt_booking.trainer_user_id | 42501 | 42501 | PASS |
| TD-02 | gym_role_trainer | Đọc billing_log | 42501 | 42501 | PASS |
| TD-03 | gym_role_trainer | Đọc user_account.email của hội viên | 42501 | 42501 | PASS |
| TD-04 | gym_role_trainer | Đọc member_subscription.actual_price (cột giá tiền) | 42501 | 42501 | PASS |
| TD-05 | gym_role_trainer | Sửa trực tiếp số buổi member_subscription.remaining_sessions | 42501 | 42501 | PASS |
| TD-06 | gym_role_trainer | Tạo lịch lớp học mới (INSERT class_schedule) | 42501 | 42501 | PASS |
| TD-07 | gym_role_trainer | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | 42501 | 42501 | PASS |
| EA-01 | gym_role_technician | Ghi nhật ký bảo trì mới vào maintenance_log | 00000 | 00000 | PASS |
| EA-02 | gym_role_technician | Cập nhật equipment.status sang Under_Maintenance | 00000 | 00000 | PASS |
| EA-03 | gym_role_technician | Quy trình BR-19: mở ca bảo trì In_Progress rồi hoàn tất, trigger tự đổi trạng thái thiết bị (Under_Maintenance -> Operational) dù role chỉ có UPDATE(status) | 00000 | 00000 | PASS |
| ED-01 | gym_role_technician | Đọc billing_log | 42501 | 42501 | PASS |
| ED-02 | gym_role_technician | Đọc user_account | 42501 | 42501 | PASS |
| ED-03 | gym_role_technician | Đọc member_subscription | 42501 | 42501 | PASS |
| ED-04 | gym_role_technician | Xóa thiết bị (DELETE equipment) | 42501 | 42501 | PASS |
| ED-05 | gym_role_technician | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | 42501 | 42501 | PASS |
| MA-01 | gym_role_member | Xem lịch lớp học nhóm class_schedule | 00000 | 00000 | PASS |
| MD-01 | gym_role_member | Đọc user_account | 42501 | 42501 | PASS |
| MD-02 | gym_role_member | Tự đặt ca PT (INSERT pt_booking) | 42501 | 42501 | PASS |
| MD-03 | gym_role_member | Đọc billing_log | 42501 | 42501 | PASS |
| MD-04 | gym_role_member | Gọi thủ tục sp_process_subscription_renewals (chỉ Admin/Lễ tân) | 42501 | 42501 | PASS |
| MD-05 | gym_role_member | Đọc class_schedule.created_by_user_id (cột nội bộ, BR-23) | 42501 | 42501 | PASS |
| AA-01 | gym_role_admin | Điều chỉnh giá gói tập membership_plan | 00000 | 00000 | PASS |
| AA-02 | gym_role_admin | Tạo tài khoản mới và đặt password_hash (INSERT cột nhạy cảm) | 00000 | 00000 | PASS |
| AA-03 | gym_role_admin | Gọi thủ tục sp_process_subscription_renewals (BR-24) | 00000 | 00000 | PASS |
| AD-01 | gym_role_admin | UPDATE hóa đơn billing_log (BR-10, kể cả Admin) | 42501 | 42501 | PASS |
| AD-02 | gym_role_admin | DELETE hóa đơn billing_log (BR-10, kể cả Admin) | 42501 | 42501 | PASS |
| AD-03 | gym_role_admin | TRUNCATE billing_log (không thể vượt rào DELETE) | 42501 | 42501 | PASS |
| AD-04 | gym_role_admin | Đọc cột password_hash của user_account | 42501 | 42501 | PASS |
| LD-01 | gym_u_trainer | Tài khoản gym_u_trainer thừa hưởng: không đọc được billing_log | 42501 | 42501 | PASS |
| LA-01 | gym_u_tech | Tài khoản gym_u_tech thừa hưởng: đọc được equipment | 00000 | 00000 | PASS |
| EV-01 | superuser | Superuser ALTER TABLE billing_log DISABLE TRIGGER USER bị event trigger chặn | P0001 | P0001 | PASS |
| EV-02 | superuser | Superuser DROP TRIGGER trg_billing_immutable_delete ON billing_log bị chặn | P0001 | P0001 | PASS |
| EV-03 | superuser | Superuser DROP TABLE billing_log CASCADE bị chặn | P0001 | P0001 | PASS |
| EV-04 | superuser | Superuser thay ruột hàm trigger bất biến (CREATE OR REPLACE FUNCTION) bị chặn | P0001 | P0001 | PASS |
| EV-05 | superuser | Superuser đổi tên trigger bất biến (ALTER TRIGGER ... RENAME) bị chặn | P0001 | P0001 | PASS |
| EV-06 | superuser | Lối thoát bảo trì: superuser đặt app.allow_billing_maintenance = on rồi DISABLE/DROP TRIGGER được phép | 00000 | 00000 | PASS |
| EV-07 | gym_u_admin | gym_u_admin ALTER TABLE billing_log (kể cả khi đặt lối thoát) -> 42501 không phải chủ sở hữu | 42501 | 42501 | PASS |
| EV-08 | gym_role_admin | gym_role_admin DROP TRIGGER trg_billing_immutable_update ON billing_log -> 42501 | 42501 | 42501 | PASS |
| EV-09 | gym_role_admin | gym_role_admin DROP TABLE billing_log -> 42501 | 42501 | 42501 | PASS |
| EV-10 | gym_role_admin | gym_role_admin ALTER TABLE billing_log DISABLE TRIGGER ALL -> 42501 | 42501 | 42501 | PASS |
| EV-11 | superuser | Mọi bảng, view, sequence, hàm, thủ tục trong schema public đều thuộc gym_owner | 00000 | 00000 | PASS |
| EV-12 | superuser | gym_owner NOLOGIN, không phải superuser; không gym_u_*/gym_role_* nào là thành viên của gym_owner | 00000 | 00000 | PASS |
| EV-13 | superuser | Event trigger evt_protect_billing_log (ddl_command_end) và _drop (sql_drop) đang bật | 00000 | 00000 | PASS |

#### 5.2.6. Tổng hợp mức độ thực thi và giới hạn còn lại

Bảng dưới đây ghi trung thực những gì được CSDL thực thi và những lưu ý, giới hạn còn lại hoặc chưa có trong bản demo.

*Bảng 5-6. Mức độ thực thi và giới hạn của các cơ chế bảo vệ*

| Hạng mục | Mức độ | Giới hạn / ghi chú |
| --- | --- | --- |
| Ràng buộc khai báo (`PRIMARY KEY`, `FOREIGN KEY`, `UNIQUE`, `CHECK`, `EXCLUDE`, chỉ mục duy nhất từng phần) và trigger xuyên bảng: BR-01…BR-09, BR-11…BR-21 (kể cả BR-19 hai chiều), BR-25, BR-26 | Đầy đủ ở CSDL | Được kiểm chứng bằng 109 test (mục 5.1). Mọi đối tượng thuộc role `NOLOGIN` `gym_owner` nên không tài khoản đăng nhập nào là chủ sở hữu để vô hiệu hóa trigger. |
| BR-10 – hóa đơn bất biến | Đầy đủ ở CSDL (bốn lớp) | BR-10 được bảo vệ bốn lớp. (1) Trigger `trg_billing_immutable_update/_delete/_truncate` chặn sửa/xóa/`TRUNCATE` hóa đơn với mọi role. (2) Phân quyền chỉ cấp `SELECT, INSERT` trên `billing_log`, kể cả cho Admin (lỗi `42501`). (3) Mọi đối tượng ứng dụng thuộc role `NOLOGIN` `gym_owner`; không tài khoản đăng nhập nào là chủ sở hữu hay thành viên của role này nên không thể `ALTER`/`DROP` `billing_log` hay vô hiệu hóa trigger. (4) Event trigger `evt_protect_billing_log` chặn `ALTER TABLE`, `DROP TABLE`, `DROP`/`ALTER TRIGGER` trên `billing_log` và việc sửa/xóa các hàm trigger bất biến (lỗi `P0001` 'BR-10'), kể cả với superuser. Giới hạn cố hữu: superuser là gốc tin cậy của mọi DBMS nên vẫn có thể bảo trì có chủ đích bằng `ALTER EVENT TRIGGER ... DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`; thao tác này phải tường minh. Chạy lại `04_triggers_views.sql` trên CSDL đã có event trigger cũng cần lối thoát này. |
| BR-22 – RBAC | Đầy đủ ở mức CSDL (có hạn chế) | Bảng `role_permission` là dữ liệu ma trận cho ứng dụng còn `GRANT` được viết tay tương ứng; hai nơi không tự đồng bộ. Không dùng Row-Level Security: hội viên chỉ đọc được danh mục công khai ở mức CSDL, việc xem dữ liệu cá nhân theo từng hội viên chưa được thực thi ở CSDL. |
| BR-23 – vết người thực hiện | Đầy đủ ở CSDL | `created_by_user_id INT NOT NULL`, `updated_by_user_id`, `updated_at` và khóa ngoại `fk_*_created_by`/`fk_*_updated_by` trên 5 bảng; `trg_fill_created_by` (`BEFORE INSERT`) từ chối nếu chưa đặt `app.current_user_id`; `trg_set_updated_by` (`BEFORE UPDATE`) luôn ghi người sửa và thời điểm sửa, cấm đổi `created_by_user_id`. Mọi chương trình ghi dữ liệu phải đặt `app.current_user_id` (ứng dụng qua `db_tx`, bộ lập lịch qua `PGOPTIONS` và `SCHEDULER_ACTOR_USER_ID`, script test ở đầu tập tin); gọi thủ tục hay chạy DML thủ công khi chưa đặt biến sẽ lỗi theo thiết kế. |
| BR-24 – tự gia hạn và ân hạn | Đầy đủ khi có bộ lập lịch ngoài | Logic nằm trong thủ tục idempotent; PostgreSQL không có bộ lập lịch tích hợp nên Docker demo có service `scheduler` (`fitzone_renewal_scheduler`) gọi thủ tục khi khởi động và mỗi `RENEWAL_INTERVAL_SECONDS` giây, production dùng `pg_cron`/cron. Nếu không có bộ lập lịch nào chạy thì quy tắc theo thời gian không tự kích hoạt. |
| NFR-SEC-03 – mã hóa dữ liệu lưu trữ | Chưa có trong demo | Là yêu cầu triển khai (đĩa/volume mã hóa, TLS); bản Docker demo chưa cài đặt. |
| NFR-AVL-01 – sao lưu | Chưa có trong demo | Khuyến nghị `pg_dump` hằng ngày kèm sao lưu WAL; demo chỉ dùng Docker volume, chưa có lịch sao lưu tự động; không có kiểm thử tự động. |
| Mật khẩu tài khoản demo | Chỉ để trình diễn | Mật khẩu mẫu `demo_2026` của các tài khoản `gym_u_*` phải được đổi khi triển khai thật. |

## Phụ lục A. Mapping Appendix: ánh xạ EER → lược đồ quan hệ theo thuật toán Elmasri & Navathe

Phụ lục này chứng minh từng cấu trúc trong sơ đồ EER (2_conceptual.md) được chuyển thành quan hệ, khóa chính (PK), khóa ngoại (FK) và ràng buộc DDL trong `Phase 3/01_schema_ddl.sql` như thế nào, theo 9 bước của thuật toán.

### Bước 1. Ánh xạ kiểu thực thể thông thường (regular entity)

Mỗi thực thể mạnh thành một quan hệ chứa mọi thuộc tính đơn; chọn một khóa làm PK.

*Bảng A-1. Bước 1. Ánh xạ kiểu thực thể thông thường (regular entity)*

| Cấu trúc EER | Quan hệ / thuộc tính | PK | Ràng buộc DDL |
| --- | --- | --- | --- |
| USER_ACCOUNT | user_account(user_id, full_name, email, phone, dob, emergency_contact, password_hash, status, created_at) | user_id | `pk_user_account`; `uq_user_account_email`, `uq_user_account_phone`; `chk_user_account_status` |
| ROLE | role(role_id, role_name, description) | role_id | `pk_role`, `uq_role_name` |
| PERMISSION | permission(permission_id, permission_code, module_name, description) | permission_id | `pk_permission`, `uq_permission_code` |
| MEMBERSHIP_PLAN | membership_plan(plan_id, plan_name, duration_days, total_sessions, price, description) | plan_id | `pk_membership_plan`; `chk_membership_plan_duration/_sessions/_price` |
| MEMBER_SUBSCRIPTION | member_subscription(subscription_id, …) | subscription_id | `pk_member_subscription`; `uq_subscription_member`; `chk_subscription_*` |
| BILLING_LOG | billing_log(billing_id, invoice_no, billing_period_start, amount, …) | billing_id | `pk_billing_log`; `uq_billing_invoice_no`; `uq_billing_subscription_period` (unique một phần); `chk_billing_*` |
| FACILITIES_ROOM | facilities_room(room_id, room_name, room_type, max_capacity, status) | room_id | `pk_facilities_room`; `chk_facilities_*` |
| EQUIPMENT | equipment(equipment_id, equipment_name, serial_number, purchase_date, depreciation_months, status) | equipment_id | `pk_equipment`; `uq_equipment_serial`; `chk_equipment_depreciation/_status` |
| CLASS_SCHEDULE | class_schedule(class_id, class_name, start_time, end_time, max_capacity, current_enrolled) | class_id | `pk_class_schedule`; `chk_class_time/_capacity/_enrolled/_enrollment_limit` (current_enrolled là thuộc tính dẫn xuất được lưu) |
| PT_BOOKING | pt_booking(booking_id, booking_date, start_time, end_time, status, created_at) | booking_id | `pk_pt_booking`; `chk_pt_booking_time/_date/_status` |
| EQUIPMENT_RESERVATION | equipment_reservation(reservation_id, start_time, end_time, status) | reservation_id | `pk_equipment_reservation`; `chk_reservation_time/_status` |
| MAINTENANCE_LOG | maintenance_log(maintenance_id, issue_description, start_time, end_time, cost, status, created_at) | maintenance_id | `pk_maintenance_log`; `chk_maintenance_*` |

### Bước 2. Ánh xạ thực thể yếu (weak entity)

Mô hình không có thực thể yếu đúng nghĩa: mọi thực thể đều có khóa thay thế riêng (`*_id` kiểu `SERIAL`). Hai trường hợp gần nhất được xử lý như sau để chứng minh đã xem xét:

*Bảng A-2. Bước 2. Ánh xạ thực thể yếu (weak entity)*

| Cấu trúc EER | Cách xử lý | Ràng buộc DDL |
| --- | --- | --- |
| CLASS_ENROLLMENT (liên kết yếu giữa subscription và class) | Là quan hệ M:N có thuộc tính (Bước 5), dùng khóa thay thế `enrollment_id` và ràng buộc duy nhất trên cặp khóa ngoại | `pk_class_enrollment`, `uq_enrollment_subscription_class` |
| Các lớp con MEMBER/TRAINER/STAFF (phụ thuộc tồn tại vào USER_ACCOUNT) | Khóa chính chia sẻ + `ON DELETE CASCADE` (Bước 8A) | `fk_*_profile_user` |

### Bước 3. Ánh xạ quan hệ 1:1

Không có quan hệ 1:1 độc lập. Quan hệ 1:1 duy nhất là "is-a" giữa siêu lớp và lớp con, được xử lý ở Bước 8 bằng khóa chính chia sẻ (shared PK): `member_profile.user_id`, `trainer_profile.user_id`, `staff_profile.user_id` vừa là PK vừa là FK tới `user_account(user_id)`.

### Bước 4. Ánh xạ quan hệ 1:N (thêm khóa ngoại về phía N)

*Bảng A-3. Bước 4. Ánh xạ quan hệ 1:N (thêm khóa ngoại về phía N)*

| Quan hệ EER | Quan hệ phía N | FK | Tham gia (NOT NULL?) | Constraint DDL |
| --- | --- | --- | --- | --- |
| SUBSCRIBES | member_subscription | member_user_id → member_profile(user_id) | toàn phần, NOT NULL | `fk_subscription_member` (RESTRICT) |
| OF_PLAN | member_subscription | plan_id → membership_plan | toàn phần, NOT NULL | `fk_subscription_plan` |
| GENERATES | billing_log | subscription_id → member_subscription | toàn phần, NOT NULL | `fk_billing_subscription` |
| BOOKS | pt_booking | member_user_id → member_profile | toàn phần | `fk_booking_member` |
| CONDUCTS | pt_booking | trainer_user_id → trainer_profile | toàn phần | `fk_booking_trainer` |
| CONSUMES | pt_booking | subscription_id → member_subscription | toàn phần | `fk_booking_subscription`; `fk_booking_subscription_member` (khóa ngoại ghép (subscription_id, member_user_id) → `uq_subscription_member`, đảm bảo booking thuộc đúng hội viên chủ hợp đồng) |
| TEACHES | class_schedule | trainer_user_id → trainer_profile | toàn phần | `fk_class_trainer` |
| HOSTS | class_schedule | room_id → facilities_room | toàn phần | `fk_class_room` |
| CONTAINS | equipment | room_id → facilities_room | toàn phần | `fk_equipment_room` |
| REPAIRED_IN | maintenance_log | equipment_id → equipment | toàn phần | `fk_maintenance_equipment` |
| PERFORMS | maintenance_log | staff_user_id → staff_profile | toàn phần | `fk_maintenance_staff` |
| RESERVED_FOR | equipment_reservation | equipment_id → equipment | toàn phần | `fk_reservation_equipment` (CASCADE) |
| FOR_BOOKING (XOR) | equipment_reservation | booking_id → pt_booking (NULL được) | riêng phần | `fk_reservation_booking`, `chk_reservation_source` |
| FOR_CLASS (XOR) | equipment_reservation | class_id → class_schedule (NULL được) | riêng phần | `fk_reservation_class`, `chk_reservation_source` |
| CREATED_BY / UPDATED_BY ×5 (BR-23) | member_subscription, billing_log, class_schedule, pt_booking, maintenance_log | created_by_user_id → user_account(user_id) NOT NULL (toàn phần); updated_by_user_id → user_account(user_id) NULL được (riêng phần, kèm updated_at) | toàn phần (created) / riêng phần (updated) | `fk_subscription_created_by`, `fk_billing_created_by`, `fk_class_created_by`, `fk_booking_created_by`, `fk_maintenance_created_by` và 5 khóa `fk_*_updated_by` (đều RESTRICT) |

Cung loại trừ XOR của EQUIPMENT_RESERVATION được ánh xạ bằng hai FK nullable cộng `chk_reservation_source` (đúng một trong hai khác NULL); tránh trùng lịch thiết bị bằng `ex_reservation_equipment_no_overlap`.

### Bước 5. Ánh xạ quan hệ M:N (quan hệ riêng / bảng trung gian)

*Bảng A-4. Bước 5. Ánh xạ quan hệ M:N (quan hệ riêng / bảng trung gian)*

| Quan hệ EER | Quan hệ mới | Thuộc tính | PK | FK | Constraint DDL |
| --- | --- | --- | --- | --- | --- |
| HAS_ROLE | user_role | – | (user_id, role_id) | user_id → user_account; role_id → role | `pk_user_role`, `fk_user_role_user`, `fk_user_role_role` (CASCADE) |
| GRANTS | role_permission | – | (role_id, permission_id) | role_id → role; permission_id → permission | `pk_role_permission`, `fk_role_permission_role`, `fk_role_permission_permission` |
| ENROLLS_IN | class_enrollment | enrollment_date, status | enrollment_id (khóa thay thế) | subscription_id → member_subscription; class_id → class_schedule | `pk_class_enrollment`, `fk_enrollment_subscription`, `fk_enrollment_class`, `uq_enrollment_subscription_class`, `chk_enrollment_status` |

### Bước 6. Ánh xạ thuộc tính đa trị (multivalued)

Mô hình không có thuộc tính đa trị: mọi thuộc tính đều đơn trị và nguyên tố (1NF, xem `3_normalization_verification.md`). Vai trò đa trị của người dùng được mô hình hóa là quan hệ M:N HAS_ROLE chứ không phải thuộc tính đa trị (Bước 5). Thuộc tính dẫn xuất `current_enrolled` được lưu vật lý, đồng bộ bằng trigger.

### Bước 7. Ánh xạ quan hệ n-ngôi (n > 2)

Không có quan hệ n-ngôi thật sự. Ba thực thể liên quan trong một ca PT (hội viên, huấn luyện viên, hợp đồng) được biểu diễn bằng ba quan hệ nhị phân 1:N (BOOKS, CONDUCTS, CONSUMES) trên cùng `pt_booking`, cộng khóa ngoại ghép `fk_booking_subscription_member` để giữ tính nhất quán giữa chúng. Quan hệ EQUIPMENT_RESERVATION với booking/class là cung XOR (Bước 4), không phải n-ngôi.

### Bước 8. Ánh xạ chuyên biệt hóa / tổng quát hóa

**Phương án dùng: 8A — một quan hệ cho siêu lớp và một quan hệ cho mỗi lớp con, khóa chính của lớp con chính là khóa của siêu lớp.**

*Bảng A-5. Bước 8. Ánh xạ chuyên biệt hóa / tổng quát hóa*

| Lớp | Quan hệ | Thuộc tính riêng | PK = FK | Constraint DDL |
| --- | --- | --- | --- | --- |
| USER_ACCOUNT (siêu lớp) | user_account | toàn bộ thuộc tính chung | user_id | `pk_user_account` |
| MEMBER | member_profile | health_notes | user_id → user_account | PK không đặt tên (`member_profile_pkey`), `fk_member_profile_user` (CASCADE) |
| TRAINER | trainer_profile | specialization, bio, current_rating | user_id → user_account | `trainer_profile_pkey`, `fk_trainer_profile_user`, `chk_trainer_rating` |
| STAFF | staff_profile | job_title, department | user_id → user_account | `staff_profile_pkey`, `fk_staff_profile_user` |

**Vì sao chọn 8A, không chọn 8B/8C/8D:**

- Chuyên biệt hóa là **chồng lấn và riêng phần** (BR-22): 8B (chỉ các quan hệ con, lặp thuộc tính chung) yêu cầu mọi thực thể phải thuộc lớp con và gây dư thừa/không nhất quán khi một người giữ nhiều vai trò; Admin không có hồ sơ cũng không biểu diễn được.
- 8C (một quan hệ đơn với cột loại) đòi hỏi nhiều cột NULL (health_notes, specialization, job_title…) và cột loại đơn trị không biểu diễn được chồng lấn; 8D (cờ boolean) khả thi nhưng vẫn nhiều NULL và không cho FK chính xác.
- 8A cho phép khóa ngoại trỏ đúng lớp con (ví dụ `pt_booking.trainer_user_id → trainer_profile`, `maintenance_log.staff_user_id → staff_profile`), loại bỏ các giá trị NULL và cho phép một `user_id` có đồng thời nhiều hồ sơ (chồng lấn). Tài khoản không có hồ sơ (Admin) hợp lệ (riêng phần).

### Bước 9. Ánh xạ phạm trù / hợp (category, union type)

Mô hình không có category (không có lớp con có nhiều siêu lớp khác nhau). Gần nhất là cung XOR của EQUIPMENT_RESERVATION (chủ sở hữu là PT_BOOKING hoặc CLASS_SCHEDULE): Elmasri xử lý category bằng khóa thay thế, nhưng ở đây dùng hai FK nullable cùng `chk_reservation_source`, vì khóa thay thế sẽ làm mất kiểm tra tham chiếu khai báo và PostgreSQL không có FK đa hình.

### Checklist: đủ 18 bảng vật lý

*Bảng A-6. Checklist: đủ 18 bảng vật lý*

| # | Bảng | Đến từ | Bước |
| --- | --- | --- | --- |
| 1 | user_account | USER_ACCOUNT | 1 |
| 2 | role | ROLE | 1 |
| 3 | user_role | HAS_ROLE (M:N) | 5 |
| 4 | permission | PERMISSION | 1 |
| 5 | role_permission | GRANTS (M:N) | 5 |
| 6 | member_profile | MEMBER (lớp con) | 8A |
| 7 | trainer_profile | TRAINER (lớp con) | 8A |
| 8 | staff_profile | STAFF (lớp con) | 8A |
| 9 | membership_plan | MEMBERSHIP_PLAN | 1 |
| 10 | member_subscription | MEMBER_SUBSCRIPTION + SUBSCRIBES + OF_PLAN | 1, 4 |
| 11 | billing_log | BILLING_LOG + GENERATES | 1, 4 |
| 12 | facilities_room | FACILITIES_ROOM | 1 |
| 13 | equipment | EQUIPMENT + CONTAINS | 1, 4 |
| 14 | class_schedule | CLASS_SCHEDULE + TEACHES + HOSTS | 1, 4 |
| 15 | class_enrollment | ENROLLS_IN (M:N) | 5 |
| 16 | pt_booking | PT_BOOKING + BOOKS + CONDUCTS + CONSUMES | 1, 4, 7 |
| 17 | equipment_reservation | EQUIPMENT_RESERVATION + RESERVED_FOR + XOR | 1, 4, 9 |
| 18 | maintenance_log | MAINTENANCE_LOG + REPAIRED_IN + PERFORMS | 1, 4 |

Khóa ngoại `created_by_user_id` và `updated_by_user_id` (BR-23): 10/10 đã tính — `member_subscription` (`fk_subscription_created_by`), `billing_log` (`fk_billing_created_by`), `class_schedule` (`fk_class_created_by`), `pt_booking` (`fk_booking_created_by`), `maintenance_log` (`fk_maintenance_created_by`); cùng 5 bảng có thêm `fk_subscription_updated_by`, `fk_billing_updated_by`, `fk_class_updated_by`, `fk_booking_updated_by`, `fk_maintenance_updated_by`.

## Phụ lục B. Hướng dẫn chạy dự án (How to run)

### B.1. Khởi động toàn bộ hệ thống

Dự án được đóng gói trong môi trường dùng một lần bằng Docker Compose; không cần cài PostgreSQL lên máy. Tại thư mục gốc của repository:

```bash
docker compose up --build
```

- Container `fitzone_postgres_db` (PostgreSQL 16) tự nạp tuần tự: `01_schema_ddl.sql` → `02_mock_data/01..08` → `04_triggers_views.sql` → `08_rbac_security.sql` (từ `/docker-entrypoint-initdb.d/`).
- Container `fitzone_web_app` (Streamlit) kết nối CSDL bằng tài khoản `gym_u_admin` (không phải superuser, thuộc nhóm `gym_role_admin`) nên quyền của CSDL luôn được áp dụng cho ứng dụng; truy cập tại `http://localhost:8501`.
- Container `fitzone_renewal_scheduler` (cùng image `postgres:16-alpine`) chờ CSDL sẵn sàng rồi gọi `CALL sp_process_subscription_renewals();` bằng tài khoản `gym_u_reception` khi khởi động và lặp lại mỗi `RENEWAL_INTERVAL_SECONDS` giây (mặc định 86400); xem log bằng `docker logs fitzone_renewal_scheduler` (BR-24).
- `POSTGRES_USER=gym_admin` chỉ dùng để khởi tạo CSDL và chạy các script kiểm thử.

### B.2. Chạy các script truy vấn và kiểm thử

Thư mục `Phase 3/` được mount chỉ-đọc vào `/sql/` trong container CSDL; các script dưới đây không chạy tự động lúc khởi tạo.

```bash
# 03 - 10 truy vấn nâng cao
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/03_complex_queries.sql

# 05 - kiểm thử ràng buộc & trigger (109 test case)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/05_constraint_test_cases.sql

# 06 - kiểm thử hiệu năng (mất khoảng 1 phút)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/06_performance_test_cases.sql

# 09 - kiểm thử phân quyền RBAC (61 test case)
docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/09_rbac_test_cases.sql
```

**Lưu ý BR-23:** mọi thao tác ghi vào 5 bảng giao dịch cần có người thực hiện; khi chạy SQL thủ công hãy `SET app.current_user_id = '<user_id>';` trước (các script test tự đặt; bộ lập lịch dùng biến môi trường `SCHEDULER_ACTOR_USER_ID`, mặc định 3).

**Nạp lại CSDL đã có (BR-10):** Bản nạp lại (01 `DROP` `billing_log`, 04 `DROP`/`CREATE` trigger và hàm bất biến) bị event trigger BR-10 chặn, kể cả với superuser. Cách đơn giản nhất là tạo CSDL mới (`docker compose down -v` rồi `docker compose up --build`). Nếu muốn nạp lại tại chỗ, superuser đặt lối thoát trong cùng phiên `psql` (`SET app.allow_billing_maintenance = 'on';` trước khi `\i` các tập tin) hoặc tắt event trigger bằng hai lệnh riêng `ALTER EVENT TRIGGER evt_protect_billing_log DISABLE;` và `ALTER EVENT TRIGGER evt_protect_billing_log_drop DISABLE;`, sau đó nạp lại 08 để tạo lại chúng.

### B.3. Tài khoản demo và gọi thủ tục gia hạn

*Bảng B-1. Tài khoản đăng nhập demo*

| Tài khoản | Vai trò | Mật khẩu |
| --- | --- | --- |
| `gym_u_admin` | Quản trị viên | `demo_2026` |
| `gym_u_reception` | Lễ tân | `demo_2026` |
| `gym_u_trainer` | Huấn luyện viên | `demo_2026` |
| `gym_u_tech` | Kỹ thuật viên | `demo_2026` |
| `gym_u_member` | Hội viên | `demo_2026` |

```bash
docker exec -it fitzone_postgres_db psql -U gym_u_reception -d gym_management

# Docker demo: service scheduler tự gọi thủ tục (xem log: docker logs fitzone_renewal_scheduler)
# Production: crontab (00:05 mỗi ngày) gọi thủ tục gia hạn BR-24
5 0 * * * docker exec fitzone_postgres_db psql -U gym_u_admin -d gym_management -c "CALL sp_process_subscription_renewals();"
```

### B.4. Dọn dẹp

```bash
docker compose down -v
```

### B.5. Cấu trúc thư mục repository

```text
PTIT_INT1313_CSDL_Group9/
├── Phase 1/   project_scope.md, business_rules.md, requirements_specification.md
├── Phase 2/   data_dictionary/ (5 tệp, 18 bảng), database_design/ (EER, sơ đồ vật lý, ánh xạ logic,
│              chuẩn hóa, mapping appendix)
├── Phase 3/   01_schema_ddl.sql, 02_mock_data/01..08, 03_complex_queries.sql, 04_triggers_views.sql,
│              05_constraint_test_cases.sql, 06_performance_test_cases.sql, 07_test_results.md,
│              08_rbac_security.sql, 09_rbac_test_cases.sql
├── Phase 4/   sql_defense_guide.md, weekly_progress_reports.md, peer_evaluation_form.md,
│              presentation/ (deck.pptx, speaker_notes.md)
├── app/       ứng dụng web Streamlit (app.py, requirements.txt, Dockerfile)
├── docker-compose.yml, .env.example, README.md
└── Gym_Membership_PT_Planner_Report_ISO_Standards.docx / .md   (báo cáo này)
```

## Phụ lục C. Tài liệu và chuẩn tham chiếu

- ISO/IEC/IEEE 29148 – Systems and software engineering – Life cycle processes – Requirements engineering (thay thế IEEE 830).
- ISO/IEC 19505 (UML) và ký hiệu IE Crow's Foot cho sơ đồ vật lý; ký hiệu EER của Elmasri & Navathe cho mô hình khái niệm.
- ISO/IEC 11179 – Metadata registries: nguyên tắc của từ điển dữ liệu (chương 3).
- SQLStyle.guide (Simon Holywell) và Google SQL Style Guide cho mã SQL.
- R. Elmasri, S. B. Navathe, *Fundamentals of Database Systems*, các chương về mô hình EER, ánh xạ ER/EER sang quan hệ và chuẩn hóa.
- PostgreSQL 16 Documentation: constraints, exclusion constraints và `btree_gist`, triggers, `SECURITY DEFINER`, privileges.
- Đề cương môn INT1313: Milestone Project Plan and Evaluation; Industrial Documentation Standards and Frameworks; Project topics (đề tài 9).
