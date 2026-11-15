# Báo cáo tiến độ hằng tuần (Weekly Progress Reports)

> **Đề tài:** Gym Membership & Personal Training Planner – INT1313, Nhóm G9
> **Thành viên:** Lê Hoàng Tiến (N25DCAT050) · Lê Hòa Thuận (N25DCAT110) · Trần Minh Tiến (N25DCAT111)
> **Kỳ báo cáo:** 24/08/2026 – 15/11/2026 (12 tuần ISO, tính từ thứ Hai).

## Nguyên tắc lập báo cáo và lưu ý về độ tin cậy

- Báo cáo được lập **chỉ từ bằng chứng thực tế** của kho Git: `git log --date=short --format='%ad %an %s' --stat`, gom theo tuần ISO (thứ Hai – Chủ nhật). Không bổ sung họp nhóm, phân công hay đóng góp nào không có trong lịch sử commit.
- **Cột "Người commit" chỉ cho biết ai đã đẩy (commit) thay đổi lên kho mã, KHÔNG phản ánh ai thực sự làm ra công việc đó.** Trong nhóm, một người có thể tổng hợp bài của người khác rồi commit, hoặc làm việc cục bộ và nhờ người khác đẩy lên. Vì vậy không nên dùng các con số commit để chấm điểm đóng góp; phần đánh giá đóng góp do chính các thành viên tự điền ở `peer_evaluation_form.md`.
- Tên tác giả trong Git xuất hiện dưới nhiều dạng (cùng một người có thể có nhiều tên cấu hình): `Lê Hoàng Tiến` và `Le Hoang Tien - N25DCAT050`; `ThuanLH` và `Thuan_LH`. Báo cáo **suy đoán** các dạng này tương ứng với các thành viên Lê Hoàng Tiến và Lê Hòa Thuận (dựa trên tên và mã sinh viên trong tên tác giả); nhóm cần tự xác nhận.
- Lịch sử Git **không có commit nào** mang tên của Trần Minh Tiến (N25DCAT111). Điều này chỉ nói rằng chưa có commit mang tên đó, **không** có nghĩa thành viên này không đóng góp (ví dụ đóng góp có thể được người khác đẩy lên).
- Tuần không có commit được ghi rõ là "không có commit"; báo cáo không suy diễn nguyên nhân.
- Dữ liệu tính đến ngày 15/11/2026: **31 commit** trong lịch sử.

## Tổng hợp nhanh theo người đẩy commit (số liệu từ `git log`)

| Tên tác giả trong Git | Số commit |
|---|---:|
| Le Hoang Tien - N25DCAT050 | 9 |
| Lê Hoàng Tiến | 5 |
| ThuanLH | 15 |
| Thuan_LH | 2 |
| (không có) Trần Minh Tiến | 0 |

## Báo cáo theo tuần

### Tuần 24/08/2026 – 30/08/2026 (tuần ISO 35/2026)

**Số commit:** 2. **Người đẩy commit:** Lê Hoàng Tiến (2).

**Tóm tắt:** Khởi tạo kho mã (`Initial commit`) và đưa tài liệu báo cáo ban đầu của nhóm lên (file `.docx` và một bản `.pdf`).

| Ngày | Mã | Người commit | Nội dung commit (nguyên văn) | Số file | +/- dòng |
|---|---|---|---|---:|---:|
| 2026-08-26 | `df479ec` | Lê Hoàng Tiến | Initial commit | 1 | +1 / -0 |
| 2026-08-27 | `737a26e` | Lê Hoàng Tiến | Tài liệu của nhóm. | 2 | +0 / -0 |

### Tuần 31/08/2026 – 06/09/2026 (tuần ISO 36/2026)

**Không có commit nào trong tuần này.** Không có bằng chứng trong lịch sử Git về công việc được đẩy lên kho mã (không loại trừ việc làm cục bộ chưa đẩy lên).

### Tuần 07/09/2026 – 13/09/2026 (tuần ISO 37/2026)

**Số commit:** 4. **Người đẩy commit:** Lê Hoàng Tiến (3); Thuan_LH (1).

**Tóm tắt:** Chỉ chỉnh sửa `README.md` (4 commit nhỏ, mỗi commit 1 file). Không có thay đổi về thiết kế hay mã nguồn.

| Ngày | Mã | Người commit | Nội dung commit (nguyên văn) | Số file | +/- dòng |
|---|---|---|---|---:|---:|
| 2026-09-08 | `e1a2b1f` | Lê Hoàng Tiến | cap nhat readme | 1 | +20 / -1 |
| 2026-09-08 | `16083f7` | Lê Hoàng Tiến | sửa lại file readme | 1 | +4 / -4 |
| 2026-09-08 | `e28c277` | Lê Hoàng Tiến | sửa do sai file readme | 1 | +1 / -1 |
| 2026-09-08 | `06e76c1` | Thuan_LH | Update README.md | 1 | +1 / -1 |

### Tuần 14/09/2026 – 20/09/2026 (tuần ISO 38/2026)

**Số commit:** 8. **Người đẩy commit:** Thuan_LH (1); ThuanLH (1); Le Hoang Tien - N25DCAT050 (6).

**Tóm tắt:** Tập trung vào báo cáo Phase 1: cập nhật bảng quy tắc nghiệp vụ và trình bày trong file báo cáo `.docx`, dọn file sao lưu/PDF cũ, sửa lỗi logic mô hình EER và từ điển dữ liệu theo báo cáo. Có một commit giải quyết xung đột khi hợp nhất (merge conflict), cho thấy có người cùng chỉnh sửa file báo cáo trong tuần.

| Ngày | Mã | Người commit | Nội dung commit (nguyên văn) | Số file | +/- dòng |
|---|---|---|---|---:|---:|
| 2026-09-15 | `6734aff` | Thuan_LH | not important | 1 | +1 / -1 |
| 2026-09-15 | `6498060` | ThuanLH | update business rules | 1 | +0 / -0 |
| 2026-09-15 | `5268ea6` | Le Hoang Tien - N25DCAT050 | update thêm BR và chỉnh lại các phần trình bày | 4 | +585 / -0 |
| 2026-09-15 | `88a9a29` | Le Hoang Tien - N25DCAT050 | update thêm BR và chỉnh lại các phần trình bày, bỏ file backup không cần thiết | 2 | +0 / -585 |
| 2026-09-15 | `973421b` | Le Hoang Tien - N25DCAT050 | Resolve merge conflict keeping local docx version | 0 | +0 / -0 |
| 2026-09-15 | `6b036a2` | Le Hoang Tien - N25DCAT050 | Le Hoang Tien's Task for Phase 1 done | 1 | +0 / -0 |
| 2026-09-15 | `8f8848d` | Le Hoang Tien - N25DCAT050 | Xóa file PDF cũ, cập nhật lại file mới từ .docx mới nhất | 2 | +0 / -0 |
| 2026-09-15 | `7dacafd` | Le Hoang Tien - N25DCAT050 | Sửa các lỗi logic từ bảng EER và bảng định nghĩa của team làm | 2 | +0 / -0 |

### Tuần 21/09/2026 – 27/09/2026 (tuần ISO 39/2026)

**Không có commit nào trong tuần này.** Không có bằng chứng trong lịch sử Git về công việc được đẩy lên kho mã (không loại trừ việc làm cục bộ chưa đẩy lên).

### Tuần 28/09/2026 – 04/10/2026 (tuần ISO 40/2026)

**Không có commit nào trong tuần này.** Không có bằng chứng trong lịch sử Git về công việc được đẩy lên kho mã (không loại trừ việc làm cục bộ chưa đẩy lên).

### Tuần 05/10/2026 – 11/10/2026 (tuần ISO 41/2026)

**Không có commit nào trong tuần này.** Không có bằng chứng trong lịch sử Git về công việc được đẩy lên kho mã (không loại trừ việc làm cục bộ chưa đẩy lên).

### Tuần 12/10/2026 – 18/10/2026 (tuần ISO 42/2026)

**Số commit:** 9. **Người đẩy commit:** Le Hoang Tien - N25DCAT050 (1); ThuanLH (8).

**Tóm tắt:** Bước chuyển từ tài liệu sang cài đặt: thêm `Phase 3` (DDL, dữ liệu mẫu tách thành 8 file, truy vấn phức hợp, trigger/view), ứng dụng Streamlit `app/`, `docker-compose.yml`, `.env.example`; bổ sung BR-22 đến BR-26 và sửa BR-05; sửa lược đồ và dữ liệu mẫu; mở rộng thêm 200 thiết bị tập; chỉnh `business_rules.md`.

| Ngày | Mã | Người commit | Nội dung commit (nguyên văn) | Số file | +/- dòng |
|---|---|---|---|---:|---:|
| 2026-10-13 | `952b5ed` | Le Hoang Tien - N25DCAT050 | Chỉnh lại Problem statement; Bổ sung BR-22 -> BR-26, sửa lại BR05; sửa lại mô hình quan niệm; sửa lại từ điển dữ liệu; sửa lại phần chuẩn hóa 3NF; cập nhật thêm Frontend và Backend, chạy qua docker-compose.yml | 15 | +2779 / -20 |
| 2026-10-13 | `cf6c1d1` | ThuanLH | Cập nhật file schema ddl | 1 | +55 / -0 |
| 2026-10-13 | `fb698c3` | ThuanLH | Chỉnh sửa schema và mock-data | 2 | +987 / -0 |
| 2026-10-13 | `d8c478f` | ThuanLH | xóa bỏ file dư | 4 | +167 / -1056 |
| 2026-10-17 | `9ff6395` | ThuanLH | Chia dữ liệu thành các tệp SQL riêng biệt | 14 | +655 / -536 |
| 2026-10-17 | `aac759e` | ThuanLH | Mở rộng cập nhật thêm 200 máy tập | 1 | +188 / -2 |
| 2026-10-18 | `a70c158` | ThuanLH | Chỉnh sửa | 1 | +39 / -0 |
| 2026-10-18 | `6d71027` | ThuanLH | Chỉnh sửa và bổ sung nội dung | 1 | +1 / -3 |
| 2026-10-18 | `8d08bb4` | ThuanLH | Chỉnh sửa thư mục mock_data | 2 | +0 / -39 |

### Tuần 19/10/2026 – 25/10/2026 (tuần ISO 43/2026)

**Số commit:** 6. **Người đẩy commit:** ThuanLH (6).

**Tóm tắt:** Hoàn thiện tài liệu Phase 1 và Phase 2: `project_scope.md`, mô hình quan niệm (ảnh Mermaid + `2_conceptual.md`), ánh xạ lược đồ logic, kiểm tra chuẩn hóa, và từ điển dữ liệu chia theo 5 phân hệ (thay các file hướng dẫn cũ).

| Ngày | Mã | Người commit | Nội dung commit (nguyên văn) | Số file | +/- dòng |
|---|---|---|---|---:|---:|
| 2026-10-19 | `ffda3ee` | ThuanLH | Chỉnh sửa và bổ sung | 1 | +145 / -0 |
| 2026-10-20 | `6e72f26` | ThuanLH | Chỉnh sửa | 5 | +239 / -0 |
| 2026-10-20 | `69c0af2` | ThuanLH | Bổ sung | 2 | +26 / -0 |
| 2026-10-20 | `d089bd8` | ThuanLH | Chỉnh sửa | 2 | +67 / -0 |
| 2026-10-20 | `53adf5c` | ThuanLH | Điều chỉnh data_dictionary | 5 | +239 / -0 |
| 2026-10-20 | `a92cc33` | ThuanLH | Xóa các file hướng dẫn cũ | 5 | +0 / -239 |

### Tuần 26/10/2026 – 01/11/2026 (tuần ISO 44/2026)

**Không có commit nào trong tuần này.** Không có bằng chứng trong lịch sử Git về công việc được đẩy lên kho mã (không loại trừ việc làm cục bộ chưa đẩy lên).

### Tuần 02/11/2026 – 08/11/2026 (tuần ISO 45/2026)

**Không có commit nào trong tuần này.** Không có bằng chứng trong lịch sử Git về công việc được đẩy lên kho mã (không loại trừ việc làm cục bộ chưa đẩy lên).

### Tuần 09/11/2026 – 15/11/2026 (tuần ISO 46/2026)

**Số commit:** 2. **Người đẩy commit:** Le Hoang Tien - N25DCAT050 (2).

**Tóm tắt:** Bổ sung bộ kiểm thử bằng SQL (`05_constraint_test_cases.sql`, `06_performance_test_cases.sql`, `07_test_results.md`), mở rộng phần chuẩn hóa 3NF và bản chuyển đổi Markdown của báo cáo; sau đó một chỉnh sửa nhỏ ở `README.md`.

| Ngày | Mã | Người commit | Nội dung commit (nguyên văn) | Số file | +/- dòng |
|---|---|---|---|---:|---:|
| 2026-11-15 | `9840454` | Le Hoang Tien - N25DCAT050 | add test case in sql format | 6 | +1653 / -6 |
| 2026-11-15 | `a475a2c` | Le Hoang Tien - N25DCAT050 | minor change | 1 | +2 / -0 |


### Tuần hiện tại (chưa commit) – tính đến 15/11/2026

> Mục này tóm tắt **công việc đang dở dang**, đọc từ `git status` và `git diff --stat HEAD` tại thời điểm lập báo cáo. **Chưa có commit nên không xác định được tác giả**; các thay đổi dưới đây chưa được rà soát và có thể thay đổi trước khi commit. Báo cáo này không quy cho cá nhân nào.

**Quy mô:** 26 file đã có trong kho bị sửa (khoảng 3.200 dòng thêm, 820 dòng xóa) cộng các file mới chưa theo dõi (untracked), kèm thư mục `Phase 4/` đang được soạn.

| Nhóm công việc | File thay đổi (theo `git status`) | Nội dung đang làm (suy ra từ tên file và thống kê diff) |
|---|---|---|
| Phase 1 – Phân tích yêu cầu | `Phase 1/business_rules.md`, `Phase 1/project_scope.md`; file mới `Phase 1/requirements_specification.md` | Cập nhật quy tắc nghiệp vụ và phạm vi; bổ sung tài liệu đặc tả yêu cầu. |
| Phase 2 – Thiết kế | 5 file `Phase 2/data_dictionary/*.md`, `2_conceptual.md`, `2_logical_schema_mapping.md`, `3_normalization_verification.md`; file mới `3_eer_diagram.*`, `4_physical_crows_foot.*`, `generate_physical_diagram.sh`, `4_mapping_appendix.md` | Cập nhật từ điển dữ liệu, ánh xạ logic, chứng minh chuẩn hóa; vẽ sơ đồ EER và sơ đồ vật lý (chân chim) dạng `.dot/.svg/.png`. |
| Phase 3 – Lược đồ và dữ liệu | `01_schema_ddl.sql`, `02_mock_data/03..08`, `04_triggers_views.sql` (879 dòng thay đổi theo `--stat`) | Thêm cột vết người thực hiện, chỉ mục duy nhất một phần, trạng thái `Late_Cancelled`, `EXCLUDE` cho thiết bị; viết lại dữ liệu mẫu với ngày tương đối; bổ sung nhiều trigger và thủ tục `sp_process_subscription_renewals`. |
| Phase 3 – Kiểm thử | `05_constraint_test_cases.sql` (1.045 dòng thay đổi theo `--stat`), `06_performance_test_cases.sql`, `07_test_results.md`; file mới `08_rbac_security.sql`, `09_rbac_test_cases.sql` | Mở rộng bộ test ràng buộc; thêm phân quyền RBAC (GRANT/REVOKE) và test RBAC; cập nhật kết quả kiểm thử. |
| Phase 3 – Truy vấn | `03_complex_queries.sql` | Cập nhật truy vấn 6 (thêm `Late_Cancelled`) và truy vấn 10. |
| Ứng dụng và triển khai | `app/app.py` (445 dòng thay đổi theo `--stat`), `docker-compose.yml`, `.env.example`, `README.md` (một phần đã `git add`) | Cập nhật giao diện (đăng ký gói, hủy ca PT, gia hạn tự động, chọn người thao tác) và cấu hình Docker/biến môi trường. |
| Phase 4 | thư mục mới `Phase 4/` | Cẩm nang bảo vệ SQL, báo cáo tuần, mẫu đánh giá chéo, bộ slide. |

**Lưu ý trung thực:** các số liệu kiểm thử nêu trong `Phase 3/07_test_results.md` được cập nhật bởi bước tích hợp cuối; nhóm cần chạy lại các script trước khi nộp. Không thể xác định từ Git ai là người thực hiện từng thay đổi nói trên.
