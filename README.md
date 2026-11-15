# 🏋️‍♂️ Hệ Thống Quản Lý Phòng Tập & Huấn Luyện Viên Cá Nhân (Gym Membership & PT Planner)

[![PostgreSQL](https://img.shields.io/badge/Database-PostgreSQL%2016-336791?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Docker](https://img.shields.io/badge/Container-Docker%20Compose-2496ED?logo=docker&logoColor=white)](https://www.docker.com/)
[![Streamlit](https://img.shields.io/badge/Frontend-Streamlit%201.35-FF4B4B?logo=streamlit&logoColor=white)](https://streamlit.io/)
[![Standard](https://img.shields.io/badge/Standard-SQLStyle.guide-10b981)](https://www.sqlstyle.guide/)

> **Học phần:** Cơ sở dữ liệu (INT1313) — Học kỳ 1 (2026 - 2027)  
> **Mã Đề Tài (Project ID):** `09` | **Tên Nhóm (Team Name):** `G9`  
> **Hệ quản trị CSDL mục tiêu:** `PostgreSQL 16+`

---

## 👥 Danh Sách Nhóm Thực Hiện (Members)

| STT | Họ và Tên | Mã Sinh Viên | Email Sinh Viên | Tài Khoản GitHub |
| :---: | :--- | :---: | :--- | :--- |
| 1 | **Lê Hoàng Tiến** | N25DCAT050 | [n25dcat050@student.ptithcm.edu.vn](mailto:n25dcat050@student.ptithcm.edu.vn) | [TienVN6222](https://github.com/TienVN6222) |
| 2 | **Lê Hòa Thuận** | N25DCAT110 | [n25dcat110@student.ptithcm.edu.vn](mailto:n25dcat110@student.ptithcm.edu.vn) | [conphencoll115-bot](https://github.com/conphencoll115-bot) |
| 3 | **Trần Minh Tiến** | N25DCAT111 | [n25dcat111@student.ptithcm.edu.vn](mailto:n25dcat111@student.ptithcm.edu.vn) | [mtgin2312](https://github.com/mtgin2312) |

---

## 🚀 Hướng Dẫn Chạy Nhanh (1-Click Disposable Deployment)

Dự án được cấu hình đóng gói **100% trong môi trường dùng một lần (Disposable Container)** thông qua Docker Compose. Người dùng **không cần cài đặt PostgreSQL hay bất kỳ phần mềm quản trị CSDL nào lên máy tính cá nhân**.

### 1. Khởi động toàn bộ Hệ thống (CSDL + Mock Data + Views/Triggers + Web App)
Chỉ cần mở Terminal tại thư mục gốc của repository và chạy duy nhất 1 lệnh:

```bash
docker compose up --build
```

- Container `fitzone_postgres_db` tự động khởi chạy và nạp tuần tự các file script trong `/docker-entrypoint-initdb.d/`:
  1. `01_schema_ddl.sql` (Khởi tạo 18 bảng, PK, FK, CHECK, Trigger tuổi BR-03, Indexes).
  2. `02_mock_data.sql` (Chèn hơn 200 bản ghi mẫu đa dạng trạng thái).
  3. `04_triggers_views.sql` (Khởi tạo 2 Views và 2 Triggers nghiệp vụ).
- Container `fitzone_web_app` tự động kết nối CSDL và khởi động ứng dụng Web UI.

### 2. Truy cập Ứng dụng
Mở trình duyệt web và truy cập vào địa chỉ:
👉 **[http://localhost:8501](http://localhost:8501)**

### 3. Dọn dẹp sạch sẽ 100% (Disposable Teardown)
Khi hoàn tất kiểm thử hoặc chấm đồ án, bạn chỉ cần chạy lệnh sau để xóa sạch container, mạng và volume dữ liệu mà không để lại bất kỳ rác nào trên máy:

```bash
docker compose down -v
```

---

## 📁 Cấu Trúc Thư Mục Repository

```text
PTIT_INT1313_CSDL_Group9/
├── database/                                # KHO SCRIPT CSDL (PHASE 3)
│   ├── 01_schema_ddl.sql                   # DDL: 18 bảng, khóa chính, khóa ngoại, ràng buộc CHECK
│   ├── 02_mock_data.sql                    # DML: Dữ liệu mẫu chuẩn thứ tự phụ thuộc
│   ├── 03_complex_queries.sql              # 10 câu truy vấn SQL phức tạp có chú thích nghiệp vụ
│   └── 04_triggers_views.sql               # 2 Views tổng hợp và 2 Triggers bảo vệ dữ liệu
├── app/                                     # ỨNG DỤNG WEB GIAO DIỆN (PHASE 4)
│   ├── app.py                              # Streamlit Dashboard, CRUD, Queries runner, Test Bench
│   ├── requirements.txt                    # Thư viện Python phụ thuộc
│   └── Dockerfile                          # Build image độc lập cho Web UI
├── Notes/                                   # TÀI LIỆU TIÊU CHUẨN & PHÂN TÍCH
│   ├── Mermaid_Code.uml                    # Sơ đồ quan niệm EER 18 bảng
│   ├── 2627.HK1-Industrial Documentation... # Tiêu chuẩn kỹ thuật ISO
│   └── 2627.HK1-Milestone Project Plan...   # Khung tiêu chí đánh giá đồ án
├── Gym_Membership_PT_Planner_Report...docx  # Báo cáo kỹ thuật chi tiết
├── docker-compose.yml                       # Điều phối khởi chạy toàn bộ hệ thống
├── .env.example                             # File mẫu cấu hình tham số môi trường
└── README.md                                # Hướng dẫn tổng quan đồ án
```

---

## 🏛️ Lược Đồ Cơ Sở Dữ Liệu 18 Bảng (ISO/IEC 11179 Data Dictionary)

Hệ thống bao gồm **18 bảng quan hệ chuẩn hóa BCNF**, chia thành 5 phân hệ cốt lõi:

| STT | Tên Bảng (`snake_case`) | Khóa Chính (PK) | Mục Đích Nghiệp Vụ | Ràng Buộc Nổi Bật |
| :---: | :--- | :--- | :--- | :--- |
| 1 | `user_account` | `user_id` | Định danh tài khoản người dùng dùng chung | `UNIQUE(email, phone)`, Trigger `dob <= CURRENT_DATE - 12y` |
| 2 | `role` | `role_id` | Danh mục vai trò trong hệ thống (RBAC) | `UNIQUE(role_name)` |
| 3 | `user_role` | `(user_id, role_id)` | Bảng trung gian phân quyền đa vai trò (M:N) | `FK ON DELETE CASCADE` |
| 4 | `permission` | `permission_id` | Danh mục các quyền thao tác chức năng | `UNIQUE(permission_code)` |
| 5 | `role_permission` | `(role_id, permission_id)` | Phân bổ quyền cho vai trò (M:N) | `FK ON DELETE CASCADE` |
| 6 | `member_profile` | `user_id` (Shared PK) | Hồ sơ mở rộng lưu tiền sử sức khỏe hội viên | `FK user_account ON DELETE CASCADE` |
| 7 | `trainer_profile` | `user_id` (Shared PK) | Hồ sơ chuyên môn và xếp hạng HLV | `CHECK (current_rating BETWEEN 0.00 AND 5.00)` |
| 8 | `staff_profile` | `user_id` (Shared PK) | Hồ sơ nhân viên tiếp tân / kỹ thuật | `FK user_account ON DELETE CASCADE` |
| 9 | `membership_plan` | `plan_id` | Danh mục các gói tập (thời gian / PT) | `CHECK (duration_days > 0, price >= 0)` |
| 10 | `member_subscription` | `subscription_id` | Hợp đồng đăng ký gói tập của hội viên | `CHECK (end_time >= start_time, remaining_sessions >= 0)` |
| 11 | `billing_log` | `billing_id` | Nhật ký hóa đơn thanh toán bất biến | `UNIQUE(invoice_no)`, `CHECK (amount > 0)` |
| 12 | `facilities_room` | `room_id` | Danh mục phòng tập và khu vực tiện ích | `CHECK (max_capacity > 0)` |
| 13 | `equipment` | `equipment_id` | Danh mục máy móc thiết bị tập luyện | `UNIQUE(serial_number)`, `CHECK (depreciation_months > 0)` |
| 14 | `class_schedule` | `class_id` | Lịch xếp các lớp học nhóm | `CHECK (end_time > start_time, current_enrolled <= max_capacity)` |
| 15 | `class_enrollment` | `enrollment_id` | Danh sách hội viên đăng ký lớp học nhóm | `UNIQUE(subscription_id, class_id)` |
| 16 | `pt_booking` | `booking_id` | Lịch hẹn ca tập HLV cá nhân 1-1 | `CHECK (end_time > start_time)` |
| 17 | `equipment_reservation`| `reservation_id` | Đăng ký giữ chỗ máy móc trước giờ tập | `CHECK (end_time > start_time, 1 trong 2 nguồn FK)` |
| 18 | `maintenance_log` | `maintenance_id` | Nhật ký sửa chữa, bảo dưỡng thiết bị | `CHECK (cost >= 0, end_time >= start_time)` |

---

## 🔍 Danh Sách 10 Truy Vấn Nâng Cao (Complex Queries)

Tất cả các truy vấn đều được kiểm thử trên PostgreSQL 16 và tích hợp trực quan hóa trên giao diện Web:

1. **Thống kê doanh thu theo từng gói tập trong quý:** Sử dụng `JOIN 3 bảng`, `GROUP BY`, `SUM` và hàm `date_trunc('quarter', payment_date)`.
2. **Top 3 HLV có tổng số giờ dạy nhiều nhất trong tháng:** Hợp nhất giờ dạy lớp nhóm và PT 1-1 qua `UNION ALL` trong CTE, `EXTRACT(EPOCH)`, `HAVING`, `ORDER BY LIMIT 3`.
3. **Danh sách hội viên có gói tập sắp hết hạn trong 7 ngày tới:** Ứng dụng `WHERE`, `CURRENT_TIMESTAMP + INTERVAL '7 days'` phục vụ chiến dịch chăm sóc khách hàng.
4. **Thiết bị đang bảo trì kèm Kỹ thuật viên & Tổng chi phí:** `JOIN 4 bảng`, kết hợp Scalar Subquery tính tổng chi phí bảo trì lịch sử.
5. **Tỷ lệ lấp đầy (Fill Rate) của các Lớp học nhóm:** Tính toán `(current_enrolled / max_capacity) * 100%` và phân loại tình trạng bằng `CASE WHEN`.
6. **Danh sách ca tập PT 1-1 bị hủy muộn hoặc bỏ tập (No-show):** Lọc theo `status IN ('Cancelled', 'No_Show')` để áp dụng chế tài trừ buổi theo BR-25.
7. **Hội viên đã mua gói PT nhưng chưa từng đặt lịch buổi nào:** Kỹ thuật `LEFT JOIN ... WHERE pb.booking_id IS NULL` tìm khách hàng "ngủ đông".
8. **Phân nhóm hội viên theo độ tuổi & Gói tập ưa chuộng nhất:** Phân khúc nhân khẩu học qua `CASE WHEN`, xếp hạng gói tập bằng Window Function `DENSE_RANK() OVER (PARTITION BY age_bracket)`.
9. **Xếp hạng doanh thu đóng góp của Hội viên:** Xếp hạng khách hàng VIP qua Window Function `DENSE_RANK() OVER (ORDER BY SUM(amount) DESC)`.
10. **Phát hiện xung đột lịch tập (Overlapping Intervals) của HLV:** Tự kết nối (Self-Join) khoảng thời gian trong CTE để kiểm toán vi phạm trùng lịch (BR-12).

---

## ⚡ Khung Nhìn (Views) & Bộ Kích Hoạt (Triggers)

### 1. Khung Nhìn (Views)
- **`vw_active_member_subscriptions`**: Cung cấp cái nhìn tức thời về các hội viên đang có hợp đồng Active, số buổi PT còn lại và số ngày hết hạn.
- **`vw_trainer_schedule_overview`**: Hợp nhất toàn bộ lịch trình công tác của HLV (Lớp nhóm + Ca PT cá nhân) theo trình tự thời gian.

### 2. Bộ Kích Hoạt (Triggers)
- **`trg_update_remaining_pt_sessions` (BR-18, BR-25):** Tự động trừ 1 buổi tập trong `member_subscription` khi ca tập `pt_booking` được cập nhật sang `'Completed'`. Nếu số buổi còn lại `<= 0`, trigger sẽ `RAISE EXCEPTION` chặn giao dịch.
- **`trg_prevent_booking_under_maintenance` (BR-19, BR-21):** Tự động chặn và báo lỗi ngoại lệ nếu người dùng cố tình tạo lịch lớp học trong Phòng tập đang `Under_Maintenance` hoặc giữ chỗ Máy tập đang `Under_Maintenance`.
- **`trg_check_user_dob` (BR-03):** Tự động ngăn chặn việc tạo tài khoản người dùng có độ tuổi dưới 12 tuổi.

---

## 🖥️ Tính Năng Ứng Dụng Web (Streamlit UI - Phase 4)

1. **Dashboard & KPIs:** Giám sát thời gian thực tổng hội viên, hợp đồng active, doanh thu và thiết bị bảo trì; tra cứu tương tác trên 2 Views.
2. **Quản Lý Hội Viên & Gói Tập (CRUD):** Tiếp nhận hội viên mới (kiểm tra tuổi tự động), quản lý hồ sơ bệnh án, ký hợp đồng và sinh hóa đơn tức thì.
3. **Lập Lịch Thông Minh:** Đặt ca tập PT 1-1 và xếp lịch lớp nhóm có kiểm tra số buổi và sức chứa phòng.
4. **Complex Queries Playground:** Chọn và thực thi từng câu truy vấn trong số 10 câu nâng cao, hiển thị mã SQL, bảng dữ liệu và biểu đồ Plotly tương tác.
5. **Trigger Test Bench:** Môi trường thử nghiệm trực quan tương tác cho phép giảng viên/hội đồng kiểm tra trực tiếp phản ứng tự vệ của CSDL khi kích hoạt các Triggers.

 