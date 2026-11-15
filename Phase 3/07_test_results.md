# Kết quả Kiểm thử Cơ sở Dữ liệu (Mục 4.2 & 5.1 của Báo cáo)

> **Môi trường kiểm thử:** PostgreSQL 16 (image `postgres:16-alpine`), nạp lần lượt `01_schema_ddl.sql` → `02_mock_data/01..08` → `04_triggers_views.sql`.
> **Ngày chạy:** 15/11/2026.
> **Script:** [`05_constraint_test_cases.sql`](05_constraint_test_cases.sql) (mục 5.1) và [`06_performance_test_cases.sql`](06_performance_test_cases.sql) (mục 4.2). Cả hai script đều được bọc trong `BEGIN ... ROLLBACK` nên **không làm thay đổi dữ liệu mẫu**.

Cách chạy lại (sau khi CSDL đã được khởi tạo):

```bash
psql -U gym_admin -d gym_management -f "Phase 3/05_constraint_test_cases.sql"
psql -U gym_admin -d gym_management -f "Phase 3/06_performance_test_cases.sql"
```

---

## 5.1. Kiểm thử ràng buộc ngăn chặn dữ liệu sai (Constraint Test Cases)

### Phương pháp

- **Negative test (TC-xx):** cố tình thực hiện thao tác vi phạm quy tắc nghiệp vụ. Test **PASS** khi CSDL từ chối thao tác với **đúng mã lỗi SQLSTATE** mong đợi.
- **Positive test (TP-xx):** thao tác hợp lệ phải được chấp nhận và các trigger phải cập nhật dữ liệu dẫn xuất chính xác.
- Mỗi test chạy trong một savepoint riêng (khối `BEGIN ... EXCEPTION` của PL/pgSQL) và luôn được hoàn tác, nên các test độc lập với nhau.

| SQLSTATE | Ý nghĩa | Cơ chế thực thi |
|---|---|---|
| `23502` | not_null_violation | `NOT NULL` |
| `23503` | foreign_key_violation | `FOREIGN KEY ... ON DELETE RESTRICT` |
| `23505` | unique_violation | `PRIMARY KEY`, `UNIQUE` |
| `23514` | check_violation | `CHECK` |
| `23P01` | exclusion_violation | `EXCLUDE USING gist` (chống trùng khoảng thời gian) |
| `P0001` | raise_exception | Trigger PL/pgSQL chủ động `RAISE EXCEPTION` |

### Kết quả: 46/46 test PASS

| Mã | Quy tắc | Kịch bản | SQLSTATE mong đợi | SQLSTATE thực tế | Kết quả | Thông báo của CSDL |
|---|---|---|---|---|---|---|
| TC-01 | BR-02 | Tạo tài khoản trùng email đã tồn tại | `23505` | `23505` | **PASS** | duplicate key value violates unique constraint "uq_user_account_email" |
| TC-02 | BR-02 | Tạo tài khoản trùng số điện thoại đã tồn tại | `23505` | `23505` | **PASS** | duplicate key value violates unique constraint "uq_user_account_phone" |
| TC-03 | BR-02 | Tạo tài khoản thiếu email (NOT NULL) | `23502` | `23502` | **PASS** | null value in column "email" of relation "user_account" violates not-null constraint |
| TC-04 | BR-03 | Đăng ký hồ sơ hội viên cho người dưới 12 tuổi | `P0001` | `P0001` | **PASS** | Lỗi nghiệp vụ BR-03: Hội viên phải đủ 12 tuổi trở lên (Ngày sinh: 2020-01-01) |
| TC-05 | BR-03 | Sửa ngày sinh của hội viên hiện có thành dưới 12 tuổi | `P0001` | `P0001` | **PASS** | Lỗi nghiệp vụ BR-03: Hội viên phải đủ 12 tuổi trở lên (Ngày sinh: 2020-01-01) |
| TC-06 | BR-22 | Gán trạng thái tài khoản ngoài miền giá trị | `23514` | `23514` | **PASS** | new row for relation "user_account" violates check constraint "chk_user_account_status" |
| TC-07 | BR-11 | Điểm đánh giá HLV vượt quá 5.00 | `23514` | `23514` | **PASS** | new row for relation "trainer_profile" violates check constraint "chk_trainer_rating" |
| TC-08 | BR-22 | Gán cùng một vai trò hai lần cho một người dùng | `23505` | `23505` | **PASS** | duplicate key value violates unique constraint "pk_user_role" |
| TC-09 | BR-04 | Tạo gói tập có thời hạn 0 ngày | `23514` | `23514` | **PASS** | new row for relation "membership_plan" violates check constraint "chk_membership_plan_duration" |
| TC-10 | BR-04 | Tạo gói tập có giá âm | `23514` | `23514` | **PASS** | new row for relation "membership_plan" violates check constraint "chk_membership_plan_price" |
| TC-11 | BR-06 | Hợp đồng có ngày kết thúc trước ngày bắt đầu | `23514` | `23514` | **PASS** | new row for relation "member_subscription" violates check constraint "chk_subscription_dates" |
| TC-12 | BR-01 | Ký hợp đồng cho người không có hồ sơ hội viên (HLV ID 5) | `23503` | `23503` | **PASS** | insert or update on table "member_subscription" violates foreign key constraint "fk_subscription_member" |
| TC-13 | BR-18 | Số buổi PT còn lại bị âm | `23514` | `23514` | **PASS** | new row for relation "member_subscription" violates check constraint "chk_subscription_remaining" |
| TC-14 | BR-09 | Phát hành hóa đơn trùng số invoice_no | `23505` | `23505` | **PASS** | duplicate key value violates unique constraint "uq_billing_invoice_no" |
| TC-15 | BR-09 | Hóa đơn có số tiền bằng 0 | `23514` | `23514` | **PASS** | new row for relation "billing_log" violates check constraint "chk_billing_amount" |
| TC-16 | BR-09 | Phương thức thanh toán không hợp lệ | `23514` | `23514` | **PASS** | new row for relation "billing_log" violates check constraint "chk_billing_method" |
| TC-17 | BR-10 | Xóa hợp đồng đã phát sinh hóa đơn (ON DELETE RESTRICT) | `23503` | `23503` | **PASS** | update or delete on table "member_subscription" violates foreign key constraint "fk_billing_subscription" on table "billing_log" |
| TC-18 | BR-04 | Xóa gói tập đang được hợp đồng sử dụng | `23503` | `23503` | **PASS** | update or delete on table "membership_plan" violates foreign key constraint "fk_subscription_plan" on table "member_subscription" |
| TC-19 | BR-13 | Phòng tập có sức chứa bằng 0 | `23514` | `23514` | **PASS** | new row for relation "facilities_room" violates check constraint "chk_facilities_capacity" |
| TC-20 | BR-17 | Lớp học có giờ kết thúc trước giờ bắt đầu | `23514` | `23514` | **PASS** | new row for relation "class_schedule" violates check constraint "chk_class_time" |
| TC-21 | BR-15 | Xếp 2 lớp trùng giờ trong cùng một phòng | `23P01` | `23P01` | **PASS** | conflicting key value violates exclusion constraint "ex_class_room_no_overlap" |
| TC-22 | BR-12 | Một HLV dạy 2 lớp trùng giờ ở 2 phòng khác nhau | `23P01` | `23P01` | **PASS** | conflicting key value violates exclusion constraint "ex_class_trainer_no_overlap" |
| TC-23 | BR-19 | Xếp lớp vào phòng đang bảo trì (phòng ID 6) | `P0001` | `P0001` | **PASS** | Lỗi nghiệp vụ BR-19: Phòng tập "Octagon Combat & Boxing Ring" (ID: 6) hiện đang ở trạng thái BẢO TRÌ (Under_Maintenance). Không thể xếp lịch! |
| TC-24 | BR-14 | Đăng ký thêm hội viên vào lớp đã đầy (lớp ID 1: 20/20) | `23514` | `23514` | **PASS** | new row for relation "class_schedule" violates check constraint "chk_class_enrollment_limit" |
| TC-25 | BR-14 | Một hợp đồng đăng ký cùng một lớp 2 lần | `23505` | `23505` | **PASS** | duplicate key value violates unique constraint "uq_enrollment_subscription_class" |
| TC-26 | BR-17 | Ca PT có giờ kết thúc bằng giờ bắt đầu | `23514` | `23514` | **PASS** | new row for relation "pt_booking" violates check constraint "chk_pt_booking_time" |
| TC-27 | BR-12 | Một HLV nhận 2 ca PT trùng giờ với 2 hội viên | `23P01` | `23P01` | **PASS** | conflicting key value violates exclusion constraint "ex_pt_trainer_no_overlap" |
| TC-28 | BR-16 | Một hội viên đặt 2 ca PT trùng giờ với 2 HLV | `23P01` | `23P01` | **PASS** | conflicting key value violates exclusion constraint "ex_pt_member_no_overlap" |
| TC-29 | BR-18 | Đặt ca PT bằng hợp đồng của hội viên khác (FK ghép) | `23503` | `23503` | **PASS** | insert or update on table "pt_booking" violates foreign key constraint "fk_booking_subscription_member" |
| TC-30 | BR-18 | Hoàn thành ca PT khi hợp đồng đã hết buổi (hợp đồng ID 2: 0 buổi) | `P0001` | `P0001` | **PASS** | Lỗi nghiệp vụ BR-18: Hợp đồng ID: 2 đã hết số buổi tập PT khả dụng (Còn lại: 0 buổi) |
| TC-31 | BR-25 | Trạng thái ca PT ngoài miền giá trị | `23514` | `23514` | **PASS** | new row for relation "pt_booking" violates check constraint "chk_pt_booking_status" |
| TC-32 | BR-26 | Thiết bị có thời gian khấu hao 0 tháng | `23514` | `23514` | **PASS** | new row for relation "equipment" violates check constraint "chk_equipment_depreciation" |
| TC-33 | BR-26 | Thiết bị trùng số serial | `23505` | `23505` | **PASS** | duplicate key value violates unique constraint "uq_equipment_serial" |
| TC-34 | BR-19 | Giữ chỗ thiết bị đang bảo trì (thiết bị ID 3) | `P0001` | `P0001` | **PASS** | Lỗi nghiệp vụ BR-19: Thiết bị "Máy chạy bộ Technogym Skillrun 7000" (ID: 3) hiện đang BẢO TRÌ (Under_Maintenance). Không thể tạo lịch giữ chỗ! |
| TC-35 | BR-21 | Lượt giữ chỗ gắn đồng thời cả ca PT và lớp học | `23514` | `23514` | **PASS** | new row for relation "equipment_reservation" violates check constraint "chk_reservation_source" |
| TC-36 | BR-21 | Lượt giữ chỗ không gắn với ca PT hay lớp học nào | `23514` | `23514` | **PASS** | new row for relation "equipment_reservation" violates check constraint "chk_reservation_source" |
| TC-37 | BR-20 | Nhật ký bảo trì có chi phí âm | `23514` | `23514` | **PASS** | new row for relation "maintenance_log" violates check constraint "chk_maintenance_cost" |
| TC-38 | BR-20 | Nhật ký bảo trì hoàn thành trước khi bắt đầu | `23514` | `23514` | **PASS** | new row for relation "maintenance_log" violates check constraint "chk_maintenance_time" |
| TC-39 | BR-20 | Giao việc bảo trì cho người không phải nhân viên (HLV ID 5) | `23503` | `23503` | **PASS** | insert or update on table "maintenance_log" violates foreign key constraint "fk_maintenance_staff" |
| TP-01 | BR-03 | Hội viên đủ 18 tuổi được tạo hồ sơ thành công | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-02 | BR-18 | Hoàn thành ca PT tự động trừ 1 buổi (hợp đồng ID 1: 16 -> 15) | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-03 | BR-14 | Đăng ký lớp tự động tăng current_enrolled (lớp ID 2: 16 -> 17) | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-04 | BR-14 | Hủy đăng ký lớp tự động giảm current_enrolled (lớp ID 1: 20 -> 19) | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-05 | BR-12 | Ca PT đã hủy không chặn ca mới cùng khung giờ (exclusion có điều kiện) | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-06 | BR-15 | Hai lớp nối tiếp nhau (07:00 kết thúc, 07:00 bắt đầu) không bị coi là trùng | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |
| TP-07 | BR-09 | Hóa đơn hợp lệ được ghi nhận | `00000` | `00000` | **PASS** | Thao tác hợp lệ được chấp nhận, kết quả đúng |

### Quy tắc nghiệp vụ CHƯA được CSDL thực thi (đã kiểm chứng)

Các quy tắc dưới đây được mô tả trong `Phase 1/business_rules.md` nhưng **khi thử thao tác sai, CSDL vẫn chấp nhận**. Chúng không được đưa vào bộ test PASS ở trên. Nhóm cần bổ sung trigger/ràng buộc, hoặc điều chỉnh lại phần mô tả quy tắc cho khớp với thực tế triển khai.

| Quy tắc | Thao tác sai đã thử | Kết quả hiện tại |
|---|---|---|
| BR-05 | Tạo hợp đồng `Active` thứ hai cho cùng một hội viên | Được chấp nhận |
| BR-07 | Tạo hợp đồng `Active` khi chưa có hóa đơn thanh toán | Được chấp nhận |
| BR-08 | Một hóa đơn duy nhất cho mỗi chu kỳ gia hạn | Chưa có cột chu kỳ tính phí |
| BR-10 | `UPDATE` / `DELETE` hóa đơn đã `Completed` | Được chấp nhận |
| BR-12 | HLV có lớp nhóm và ca PT trùng giờ (giữa 2 bảng khác nhau) | Được chấp nhận |
| BR-16 | Hội viên có lớp nhóm và ca PT trùng giờ | Chưa kiểm tra |
| BR-18 | **Tạo** ca PT khi hợp đồng còn 0 buổi | Được chấp nhận (chỉ bị chặn lúc chuyển sang `Completed`, xem TC-30) |
| BR-21 | Giữ chỗ cùng một thiết bị cho 2 lượt trùng giờ | Được chấp nhận |
| BR-23 | Lưu `created_by_user_id` | Chưa có cột |
| BR-24, BR-25 | Tự động gia hạn/ân hạn; chính sách hủy ca PT | Chưa triển khai |

---

## 4.2. Kiểm thử hiệu năng & chỉ mục (Performance Test Cases)

### Yêu cầu phi chức năng được kiểm chứng

> **NFR-PERF-01:** Các truy vấn tra cứu/tìm kiếm phải trả kết quả dưới **200 ms** khi mỗi bảng nghiệp vụ có cỡ 100.000+ bản ghi.

### Phương pháp

1. Dữ liệu mẫu gốc chỉ có ~700 bản ghi, quá nhỏ để bộ tối ưu hóa chọn dùng chỉ mục. Script sinh tạm **100.000 tài khoản, 200.000 hóa đơn và 120.000 ca PT** bằng `generate_series()` (không vi phạm ràng buộc nào), sau đó chạy `ANALYZE`.
2. Mỗi truy vấn được chạy `EXPLAIN (ANALYZE)` hai lần:
   - **(a) Có chỉ mục:** bộ tối ưu hóa chọn kế hoạch thực thi bình thường.
   - **(b) Không chỉ mục:** tắt `enable_indexscan`, `enable_bitmapscan`, `enable_indexonlyscan` để mô phỏng bảng không có chỉ mục (buộc phải `Seq Scan`).
3. Mỗi truy vấn được chạy làm nóng (warm-up) một lần trước khi đo. Toàn bộ dữ liệu sinh tạm bị `ROLLBACK` sau khi đo.

> Thời gian tuyệt đối phụ thuộc cấu hình máy; điều cần quan sát là **loại phép quét** và **tỉ lệ chênh lệch** giữa (a) và (b).

### Kết quả: 8/8 test đạt NFR-PERF-01

| Mã | Truy vấn | Kế hoạch (a) có chỉ mục | (a) ms | Kế hoạch (b) không chỉ mục | (b) ms | Nhanh hơn | < 200 ms |
|---|---|---|---:|---|---:|---:|---|
| PT-01 | Tra cứu tài khoản theo email khi đăng nhập | Index Scan (`uq_user_account_email`) | 0.036 | Seq Scan (`user_account`) | 19.734 | 548× | **PASS** |
| PT-02 | Tra cứu tài khoản theo số điện thoại | Index Scan (`uq_user_account_phone`) | 0.078 | Seq Scan (`user_account`) | 12.957 | 166× | **PASS** |
| PT-03 | Doanh thu theo phương thức thanh toán trong 1 tuần | Bitmap Index Scan (`idx_billing_log_payment_date`) | 0.774 | Seq Scan (`billing_log`) | 28.579 | 37× | **PASS** |
| PT-04 | 20 hóa đơn gần nhất của một hợp đồng | Index Scan (`idx_billing_log_payment_date`) | 0.506 | Seq Scan (`billing_log`) | 23.746 | 47× | **PASS** |
| PT-05 | Tra cứu hóa đơn theo `invoice_no` | Index Scan (`uq_billing_invoice_no`) | 0.050 | Seq Scan (`billing_log`) | 26.537 | 531× | **PASS** |
| PT-06 | Lịch ca PT trong một ngày của một HLV | Bitmap Index Scan (`idx_pt_booking_dates`) | 0.727 | Seq Scan (`pt_booking`) | 10.999 | 15× | **PASS** |
| PT-07 | Kiểm tra HLV có bị trùng lịch (toán tử `&&`) | Index Scan (`ex_pt_trainer_no_overlap`, GiST) | 0.056 | Seq Scan (`pt_booking`) | 4.391 | 78× | **PASS** |
| PT-08 | Truy vấn phức hợp Q1: doanh thu từng gói trong một quý (JOIN 3 bảng) | Bitmap Index Scan (`idx_billing_log_payment_date`) | 12.910 | Seq Scan (`billing_log`) | 35.966 | 2.8× | **PASS** |

### Kế hoạch thực thi minh họa

**PT-01 – Tra cứu theo email** (chỉ mục B-tree do ràng buộc `UNIQUE` tự sinh):

```text
Index Scan using uq_user_account_email on user_account (actual time=0.034..0.035 rows=1 loops=1)
  Index Cond: ((email)::text = 'perf_user_77777@perf.test'::text)
Planning Time: 0.090 ms
Execution Time: 0.059 ms
```

**PT-07 – Kiểm tra trùng lịch HLV.** Chỉ mục GiST của ràng buộc `EXCLUDE` vừa bảo đảm toàn vẹn (BR-12) vừa tăng tốc truy vấn tìm khoảng thời gian chồng lấn:

```text
Result (actual time=0.058..0.059 rows=1 loops=1)
  InitPlan 1 (returns $0)
    ->  Index Scan using ex_pt_trainer_no_overlap on pt_booking (actual time=0.057..0.057 rows=1 loops=1)
          Index Cond: ((trainer_user_id = 8) AND (tsrange(start_time, end_time, '[)'::text) && '["2032-03-15 10:30:00","2032-03-15 11:30:00")'::tsrange))
Planning Time: 0.126 ms
Execution Time: 0.078 ms
```

### Nhận xét & đề xuất tối ưu

- Tất cả truy vấn tra cứu điểm (PT-01, 02, 05, 07) chạy dưới **0.1 ms** nhờ chỉ mục, nhanh hơn 78–531 lần so với quét toàn bảng.
- **PT-04:** bộ tối ưu hóa **không** dùng `idx_billing_log_subscription` mà quét ngược `idx_billing_log_payment_date` rồi lọc theo `subscription_id`. Kế hoạch này chỉ nhanh vì dữ liệu sinh tạm phân bố đều; nếu một hợp đồng hiếm khi phát sinh hóa đơn, nó phải quét gần hết chỉ mục. Đề xuất thay bằng **chỉ mục ghép**, phục vụ được cả điều kiện lọc lẫn `ORDER BY`:

  ```sql
  CREATE INDEX idx_billing_log_subscription_date
      ON billing_log (subscription_id, payment_date DESC);
  ```

- **PT-08:** mức cải thiện thấp hơn (2.8×) vì một quý chiếm khoảng 1/12 bảng `billing_log` (~16.000 dòng), nên phần lớn thời gian nằm ở phép `JOIN` và `GROUP BY` chứ không ở bước lọc.
- Script chạy mất khoảng 1 phút, chủ yếu do bước sinh 120.000 ca PT phải kiểm tra 2 ràng buộc `EXCLUDE` cho từng dòng. Đây cũng là chi phí ghi của cơ chế chống trùng lịch.
