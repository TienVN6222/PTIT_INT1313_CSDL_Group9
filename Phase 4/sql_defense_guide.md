# Cẩm nang chuẩn bị Bảo vệ SQL cá nhân (Individual SQL Defense – 15%)

> **Đề tài:** Gym Membership & Personal Training Planner (INT1313 – Nhóm G9)
> **Thành viên:** Lê Hoàng Tiến (N25DCAT050) · Lê Hòa Thuận (N25DCAT110) · Trần Minh Tiến (N25DCAT111)
> **Hình thức thi:** mỗi sinh viên được yêu cầu *viết hoặc giải thích ngay tại chỗ* một truy vấn phức tạp, hoặc *sửa đổi* một truy vấn / thao tác có sẵn.
> **Nguồn đối chiếu:** `Phase 3/03_complex_queries.sql`, `Phase 3/01_schema_ddl.sql`, `Phase 3/04_triggers_views.sql`, `Phase 3/08_rbac_security.sql`, `Phase 2/database_design/3_normalization_verification.md`.

## 0. Cách dùng tài liệu này

**Quy ước các khối mã**

- Khối ` ```sql ` là câu lệnh **đã được nhóm chạy thử thật** trên PostgreSQL 16 (nạp `01_schema_ddl.sql` → `02_mock_data/01..08` → `04_triggers_views.sql` → `08_rbac_security.sql`). Mỗi khối được chạy riêng trong `BEGIN … ROLLBACK`, nên chạy lại bao nhiêu lần cũng không làm bẩn dữ liệu.
- Khối ` ```postgresql ` là **đoạn trích** từ file của nhóm (chỉ để đọc, không chạy riêng lẻ).
- Khối có dòng đầu `-- LỖI MONG ĐỢI: <SQLSTATE>` là câu lệnh **cố tình vi phạm** ràng buộc; kết quả đúng là CSDL báo lỗi với mã đó.

**Số liệu mẫu thay đổi theo ngày nạp.** Ngày tháng trong dữ liệu mẫu được tính tương đối theo `CURRENT_DATE`/`CURRENT_TIMESTAMP` lúc nạp, vì vậy tài liệu chỉ mô tả *hình dạng* kết quả (cột nào, mỗi dòng đại diện cho cái gì, sắp xếp ra sao) chứ không chép cứng con số. Khi thi, hãy nói "kết quả có … cột, mỗi dòng là …" thay vì đọc số.

**Chuẩn bị môi trường trước giờ thi** (xem README):

```bash
docker compose up --build            # CSDL + dữ liệu mẫu + views/triggers + RBAC + web app
docker exec -it fitzone_postgres_db psql -U gym_admin -d gym_management
```

**Bắt buộc đặt người thực hiện (BR-23).** Mọi câu `INSERT`/`UPDATE` vào 5 bảng giao dịch (`member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log`) đều bị CSDL từ chối nếu phiên chưa có `app.current_user_id`. Vì vậy các khối mã ghi dữ liệu trong tài liệu này mở đầu bằng `SET app.current_user_id = '3';` (3 là lễ tân mẫu); khi tự gõ trong `psql` hãy làm tương tự.

**Mẹo trả lời khi bị hỏi "sửa tại chỗ"**

1. Đọc lại yêu cầu bằng lời của mình, nói rõ *bảng nào – điều kiện nào – nhóm theo gì*.
2. Chỉ sửa **đúng chỗ cần sửa** (thường là mệnh đề `WHERE`, `HAVING`, `LIMIT`, hoặc thêm một cột/`JOIN`); nói to chỗ sửa trước khi gõ.
3. Chạy thử, đọc kết quả, đối chiếu với kỳ vọng (số dòng, thứ tự). Nếu 0 dòng, kiểm tra xem điều kiện thời gian có quá hẹp không.
4. Luôn gắn câu trả lời với **quy tắc nghiệp vụ (BR-xx)** tương ứng – giảng viên đánh giá cao việc hiểu "vì sao" hơn là thuộc lòng cú pháp.
5. Tuân thủ SQLStyle.guide: từ khóa IN HOA, tên `snake_case` thường, mỗi mệnh đề một dòng, thụt lề rõ ràng.

**Bản đồ lược đồ rút gọn (để nhớ khi viết `JOIN`)**

| Cần … | Đường nối |
|---|---|
| Tên hội viên / HLV / nhân viên | `user_account.user_id` ← `member_user_id` / `trainer_user_id` / `staff_user_id` |
| Gói tập của hợp đồng | `member_subscription.plan_id → membership_plan.plan_id` |
| Doanh thu | `billing_log.subscription_id → member_subscription.subscription_id` (**billing_log không có `plan_id`**, phải đi qua hợp đồng) |
| Ca PT của hợp đồng | `pt_booking.subscription_id` (kèm `member_user_id`, `trainer_user_id`) |
| Lớp học | `class_schedule` (HLV + phòng) ← `class_enrollment (subscription_id, class_id)` |
| Thiết bị | `equipment.room_id → facilities_room`; `maintenance_log.equipment_id`, `staff_user_id` |

---

# PHẦN A – 10 TRUY VẤN PHỨC HỢP (`Phase 3/03_complex_queries.sql`)

Mỗi truy vấn gồm: **mục đích nghiệp vụ → giải thích từng phần → hình dạng kết quả → bẫy/điểm hay bị hỏi → các biến thể "sửa tại chỗ" (có SQL đáp án)**.

---

## Truy vấn 1 – Doanh thu theo gói tập trong quý hiện tại

**Mục đích nghiệp vụ.** Ban giám đốc so sánh hiệu quả kinh doanh giữa các gói (tháng, quý, PT…) trong quý đang chạy để điều chỉnh giá.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `FROM membership_plan mp JOIN member_subscription ms … JOIN billing_log bl …` | `INNER JOIN` 3 bảng theo chuỗi khóa ngoại `plan → subscription → billing`. Phải đi qua `member_subscription` vì hóa đơn chỉ biết `subscription_id`. `INNER JOIN` nghĩa là gói chưa có hóa đơn nào **biến mất** khỏi kết quả. |
| `bl.payment_status = 'Completed'` | Chỉ tính tiền đã thu thật; loại `Pending`, `Failed`, `Refunded`. |
| `payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)` và `< … + INTERVAL '3 months'` | Khoảng **nửa mở** `[đầu quý, đầu quý sau)`. `DATE_TRUNC('quarter', …)` đưa ngày về 00:00 ngày đầu quý. Dùng nửa mở để không bỏ sót ngày cuối quý và không lọt sang quý sau. |
| `GROUP BY mp.plan_id, mp.plan_name` | Gom theo gói; mọi cột không nằm trong hàm tổng hợp ở `SELECT` đều phải có mặt trong `GROUP BY`. |
| `COUNT`, `SUM`, `ROUND(AVG(…), 2)` | Số giao dịch, tổng doanh thu, giá trị đơn trung bình. |
| `ORDER BY total_revenue DESC` | Dùng được alias vì `ORDER BY` thực thi sau `SELECT`. |

**Hình dạng kết quả.** Mỗi dòng = một gói có ít nhất một hóa đơn `Completed` trong quý; 5 cột (`plan_id`, `plan_name`, `total_transactions`, `total_revenue`, `average_order_value`), gói doanh thu cao nhất đứng đầu.

**Bẫy hay hỏi.** (1) Vì sao không `JOIN` thẳng `billing_log` với `membership_plan`? → không có khóa chung. (2) `WHERE` lọc *trước* khi gom nhóm, `HAVING` lọc *sau*. (3) Vì sao dùng khoảng nửa mở thay vì `BETWEEN`? → `BETWEEN` gồm cả hai đầu, dễ trùng giờ 00:00 của quý sau.

### Biến thể "sửa tại chỗ" cho truy vấn 1

**1a. "Chỉ lấy quý trước"** – dịch cả hai mốc lùi một quý:

```sql
SELECT
    mp.plan_id,
    mp.plan_name,
    COUNT(bl.billing_id)     AS total_transactions,
    SUM(bl.amount)           AS total_revenue,
    ROUND(AVG(bl.amount), 2) AS average_order_value
FROM
    membership_plan mp
JOIN
    member_subscription ms ON mp.plan_id = ms.plan_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
    AND bl.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE) - INTERVAL '3 months'
    AND bl.payment_date <  DATE_TRUNC('quarter', CURRENT_DATE)
GROUP BY
    mp.plan_id,
    mp.plan_name
ORDER BY
    total_revenue DESC;
```

**1b. "Chỉ giữ gói có doanh thu trên 2 triệu"** – điều kiện trên hàm tổng hợp phải nằm ở `HAVING`, không phải `WHERE`:

```sql
SELECT
    mp.plan_id,
    mp.plan_name,
    SUM(bl.amount) AS total_revenue
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
HAVING
    SUM(bl.amount) > 2000000
ORDER BY
    total_revenue DESC;
```

**1c. "Liệt kê cả gói chưa có doanh thu (hiển thị 0)"** – đổi sang `LEFT JOIN` và **chuyển điều kiện về bảng bên phải vào `ON`** (nếu để ở `WHERE`, `LEFT JOIN` bị biến thành `INNER JOIN`):

```sql
SELECT
    mp.plan_id,
    mp.plan_name,
    COUNT(bl.billing_id)         AS total_transactions,
    COALESCE(SUM(bl.amount), 0)  AS total_revenue
FROM
    membership_plan mp
LEFT JOIN
    member_subscription ms ON ms.plan_id = mp.plan_id
LEFT JOIN
    billing_log bl ON bl.subscription_id = ms.subscription_id
                  AND bl.payment_status = 'Completed'
                  AND bl.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)
                  AND bl.payment_date <  DATE_TRUNC('quarter', CURRENT_DATE) + INTERVAL '3 months'
GROUP BY
    mp.plan_id,
    mp.plan_name
ORDER BY
    total_revenue DESC,
    mp.plan_id;
```

**1d. "Thêm phương thức thanh toán"** – thêm cột vào cả `SELECT` lẫn `GROUP BY`:

```sql
SELECT
    mp.plan_name,
    bl.payment_method,
    COUNT(*)       AS total_transactions,
    SUM(bl.amount) AS total_revenue
FROM
    membership_plan mp
JOIN
    member_subscription ms ON mp.plan_id = ms.plan_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
GROUP BY
    mp.plan_name,
    bl.payment_method
ORDER BY
    mp.plan_name,
    total_revenue DESC;
```

---

## Truy vấn 2 – Top 3 HLV có tổng giờ dạy nhiều nhất trong tháng

**Mục đích nghiệp vụ.** Tính thưởng KPI cho HLV xuất sắc dựa trên **tổng giờ dạy cả hai hình thức**: lớp nhóm (`class_schedule`) và PT 1-1 (`pt_booking`).

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `WITH trainer_teaching_hours AS (…)` | **CTE** – đặt tên cho một bảng tạm để đọc theo từng bước. Ở đây CTE gộp hai nguồn dữ liệu về cùng một dạng `(trainer_id, hours_taught, teaching_type)`. |
| `UNION ALL` | Nối hai tập kết quả cùng số cột/kiểu dữ liệu. `ALL` giữ nguyên mọi dòng, **không khử trùng lặp** (nhanh hơn `UNION` và đúng nghiệp vụ: hai ca cùng độ dài vẫn phải cộng đủ). |
| `EXTRACT(EPOCH FROM (end_time - start_time)) / 3600.0` | Hiệu hai `TIMESTAMP` là `INTERVAL`; `EPOCH` đổi ra giây; chia 3600 ra giờ. `3600.0` (số thực) tránh chia nguyên. |
| `pb.status = 'Completed'` | PT chỉ tính khi **đã hoàn thành**. Lớp nhóm không có cột trạng thái nên tính mọi lớp có giờ bắt đầu trong tháng. |
| `booking_date >= DATE_TRUNC('month', …)` … `+ INTERVAL '1 month'` | Khoảng nửa mở của tháng hiện tại. |
| `JOIN user_account … JOIN trainer_profile …` | Lấy tên, chuyên môn, điểm đánh giá của HLV. |
| `COUNT(tth.hours_taught)`, `SUM(tth.hours_taught)` | Số buổi và tổng giờ của mỗi HLV. |
| `HAVING SUM(…) > 0` | Lọc nhóm sau khi tổng hợp (ở đây chủ yếu để minh họa; không loại ai vì mọi ca đều dài hơn 0). |
| `ORDER BY total_hours_taught DESC LIMIT 3` | Lấy 3 HLV đầu bảng. |

**Hình dạng kết quả.** Tối đa 3 dòng, mỗi dòng một HLV (`trainer_id`, `trainer_name`, `specialization`, `current_rating`, `total_sessions_conducted`, `total_hours_taught`), giờ dạy giảm dần. Nếu tháng này chưa có ca nào thì kết quả rỗng.

**Bẫy hay hỏi.** (1) `UNION` khác `UNION ALL` thế nào? (2) `LIMIT 3` **cắt cứng** nên nếu HLV thứ 3 và thứ 4 bằng điểm, một người bị loại ngẫu nhiên → dùng `FETCH FIRST 3 ROWS WITH TIES` (biến thể 2c). (3) Vì sao PT lọc theo `booking_date` còn lớp nhóm lọc theo `start_time`? → `pt_booking` có thêm cột `booking_date` (ràng buộc `chk_pt_booking_date` bảo đảm `booking_date = start_time::DATE`).

### Biến thể "sửa tại chỗ" cho truy vấn 2

**2a. "Top 5 thay vì top 3, và lấy tháng trước"** – đổi hai mốc tháng và `LIMIT`:

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
        AND pb.booking_date >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND pb.booking_date <  DATE_TRUNC('month', CURRENT_DATE)

    UNION ALL

    SELECT
        cs.trainer_user_id AS trainer_id,
        ROUND((EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600.0)::NUMERIC, 2) AS hours_taught,
        'GROUP_CLASS' AS teaching_type
    FROM
        class_schedule cs
    WHERE
        cs.start_time >= DATE_TRUNC('month', CURRENT_DATE) - INTERVAL '1 month'
        AND cs.start_time <  DATE_TRUNC('month', CURRENT_DATE)
)
SELECT
    u.user_id AS trainer_id,
    u.full_name AS trainer_name,
    COUNT(tth.hours_taught) AS total_sessions_conducted,
    SUM(tth.hours_taught)   AS total_hours_taught
FROM
    trainer_teaching_hours tth
JOIN
    user_account u ON tth.trainer_id = u.user_id
GROUP BY
    u.user_id,
    u.full_name
ORDER BY
    total_hours_taught DESC
LIMIT 5;
```

**2b. "Tách giờ PT và giờ lớp thành hai cột"** – dùng `SUM(…) FILTER (WHERE …)` (PostgreSQL) thay vì hai truy vấn:

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
        cs.trainer_user_id,
        ROUND((EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600.0)::NUMERIC, 2),
        'GROUP_CLASS'
    FROM
        class_schedule cs
    WHERE
        cs.start_time >= DATE_TRUNC('month', CURRENT_DATE)
        AND cs.start_time <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
)
SELECT
    u.user_id AS trainer_id,
    u.full_name AS trainer_name,
    COALESCE(SUM(tth.hours_taught) FILTER (WHERE tth.teaching_type = 'PT_1_ON_1'), 0)   AS pt_hours,
    COALESCE(SUM(tth.hours_taught) FILTER (WHERE tth.teaching_type = 'GROUP_CLASS'), 0) AS class_hours,
    SUM(tth.hours_taught) AS total_hours_taught
FROM
    trainer_teaching_hours tth
JOIN
    user_account u ON tth.trainer_id = u.user_id
GROUP BY
    u.user_id,
    u.full_name
ORDER BY
    total_hours_taught DESC
LIMIT 3;
```

**2c. "Nếu hai HLV bằng điểm ở hạng 3 thì sao?"** – thay `LIMIT 3` bằng `FETCH FIRST … WITH TIES` (PostgreSQL 13+); đoạn dưới chỉ đổi phần cuối của truy vấn gốc:

```sql
WITH trainer_teaching_hours AS (
    SELECT
        pb.trainer_user_id AS trainer_id,
        ROUND((EXTRACT(EPOCH FROM (pb.end_time - pb.start_time)) / 3600.0)::NUMERIC, 2) AS hours_taught
    FROM
        pt_booking pb
    WHERE
        pb.status = 'Completed'
        AND pb.booking_date >= DATE_TRUNC('month', CURRENT_DATE)
        AND pb.booking_date <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'

    UNION ALL

    SELECT
        cs.trainer_user_id,
        ROUND((EXTRACT(EPOCH FROM (cs.end_time - cs.start_time)) / 3600.0)::NUMERIC, 2)
    FROM
        class_schedule cs
    WHERE
        cs.start_time >= DATE_TRUNC('month', CURRENT_DATE)
        AND cs.start_time <  DATE_TRUNC('month', CURRENT_DATE) + INTERVAL '1 month'
)
SELECT
    u.user_id AS trainer_id,
    u.full_name AS trainer_name,
    SUM(tth.hours_taught) AS total_hours_taught
FROM
    trainer_teaching_hours tth
JOIN
    user_account u ON tth.trainer_id = u.user_id
GROUP BY
    u.user_id,
    u.full_name
ORDER BY
    total_hours_taught DESC
FETCH FIRST 3 ROWS WITH TIES;
```

---

## Truy vấn 3 – Hội viên có gói tập sắp hết hạn trong 7 ngày tới

**Mục đích nghiệp vụ.** Lễ tân / chăm sóc khách hàng chủ động liên hệ nhắc gia hạn (chiến dịch giữ chân – *retention*).

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `JOIN user_account … JOIN membership_plan …` | Lấy thông tin liên hệ và tên gói. |
| `ms.sub_status = 'Active'` | Chỉ nhắc hợp đồng còn hiệu lực. |
| `ms.end_time >= CURRENT_TIMESTAMP AND ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days'` | Cửa sổ thời gian `[bây giờ, bây giờ + 7 ngày]`; điều kiện đầu loại hợp đồng đã quá hạn. |
| `ROUND(EXTRACT(EPOCH FROM (ms.end_time - CURRENT_TIMESTAMP)) / 86400.0, 1)` | Số ngày còn lại (86400 giây/ngày), làm tròn 1 chữ số. |
| `ORDER BY ms.end_time ASC` | Hết hạn sớm nhất lên đầu, để lễ tân gọi theo độ khẩn. |

**Hình dạng kết quả.** Mỗi dòng = một hợp đồng Active sắp hết hạn (hội viên, SĐT, email, tên gói, số buổi PT còn lại, có tự gia hạn không). Có thể rỗng nếu không hợp đồng nào sắp hết hạn.

**Bẫy hay hỏi.** `CURRENT_TIMESTAMP` có múi giờ còn `end_time` là `TIMESTAMP` không múi giờ → PostgreSQL ngầm ép kiểu theo múi giờ phiên; với container chạy UTC thì trùng nhau. Nếu chỉ cần so theo **ngày** (không theo giờ) hãy ép `end_time::DATE` (biến thể 3c).

### Biến thể "sửa tại chỗ" cho truy vấn 3

**3a. "Mở rộng thành 30 ngày"** – chỉ đổi hằng khoảng thời gian:

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    mp.plan_name,
    ms.end_time AS expiration_date,
    ROUND(EXTRACT(EPOCH FROM (ms.end_time - CURRENT_TIMESTAMP)) / 86400.0, 1) AS days_remaining
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active'
    AND ms.end_time >= CURRENT_TIMESTAMP
    AND ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '30 days'
ORDER BY
    ms.end_time ASC;
```

**3b. "Chỉ hợp đồng tự gia hạn (`is_recurring`) và còn buổi PT"** – thêm hai điều kiện vào `WHERE`:

```sql
SELECT
    u.full_name AS member_name,
    mp.plan_name,
    ms.end_time AS expiration_date,
    ms.remaining_sessions
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active'
    AND ms.is_recurring
    AND ms.remaining_sessions > 0
    AND ms.end_time >= CURRENT_TIMESTAMP
    AND ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days'
ORDER BY
    ms.end_time;
```

**3c. "Tính theo ngày lịch, gồm cả hợp đồng vừa hết hạn trong 3 ngày qua"** – so sánh bằng `DATE` và bỏ ràng buộc trạng thái chỉ còn Active/Expired:

```sql
SELECT
    u.full_name AS member_name,
    mp.plan_name,
    ms.sub_status,
    ms.end_time::DATE AS expiration_day,
    ms.end_time::DATE - CURRENT_DATE AS days_left
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status IN ('Active', 'Expired')
    AND ms.end_time::DATE BETWEEN CURRENT_DATE - 3 AND CURRENT_DATE + 7
ORDER BY
    ms.end_time;
```

---

## Truy vấn 4 – Thiết bị đang bảo trì kèm kỹ thuật viên và tổng chi phí

**Mục đích nghiệp vụ.** Kiểm soát thiết bị ngừng hoạt động (BR-19), người phụ trách và lũy kế chi phí sửa chữa.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `JOIN` 4 bảng: `equipment → facilities_room`, `equipment → maintenance_log`, `maintenance_log → user_account` | Vị trí phòng, phiếu bảo trì, tên kỹ thuật viên. |
| `e.status = 'Under_Maintenance' AND ml.status = 'In_Progress'` | Thiết bị đang bảo trì **và** phiếu đang xử lý (loại phiếu cũ đã đóng). |
| Subquery vô hướng trong `SELECT`: `(SELECT COALESCE(SUM(all_ml.cost), 0) FROM maintenance_log all_ml WHERE all_ml.equipment_id = e.equipment_id)` | **Subquery tương quan** – chạy lại cho mỗi dòng ngoài, trả đúng 1 giá trị: tổng chi phí **mọi lần** bảo trì của thiết bị đó. `COALESCE(…, 0)` đổi `NULL` thành 0. |
| `ORDER BY ml.start_time ASC` | Máy hỏng lâu nhất lên đầu. |

**Hình dạng kết quả.** Mỗi dòng = một phiếu bảo trì đang xử lý của một thiết bị đang bảo trì (thiết bị, phòng, kỹ thuật viên, mô tả sự cố, chi phí phiếu hiện tại, tổng chi phí lịch sử).

**Bẫy hay hỏi.** Vì sao không dùng `SUM(ml.cost)` + `GROUP BY` ngay trong truy vấn chính? → vì `WHERE ml.status = 'In_Progress'` đã loại các phiếu cũ, tổng sẽ thiếu. Có hai cách thay thế: subquery tương quan (như bản gốc) hoặc gộp trước trong CTE (biến thể 4c). Nếu một thiết bị có 2 phiếu `In_Progress` thì dòng bị nhân đôi.

### Biến thể "sửa tại chỗ" cho truy vấn 4

**4a. "Chỉ thiết bị trong một phòng cụ thể"** – thêm điều kiện theo phòng (ở đây phòng có `room_id = 6`; có thể lọc theo tên bằng `fr.room_name ILIKE '%Boxing%'`):

```sql
SELECT
    e.equipment_id,
    e.equipment_name,
    fr.room_name AS location_room,
    u.full_name AS technician_in_charge,
    ml.start_time AS maintenance_started_at
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
    AND fr.room_id = 6
ORDER BY
    ml.start_time ASC;
```

**4b. "Chỉ máy đã hỏng quá 7 ngày"** – thêm điều kiện trên thời điểm bắt đầu phiếu và tính số ngày đã hỏng:

```sql
SELECT
    e.equipment_id,
    e.equipment_name,
    ml.start_time AS maintenance_started_at,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - ml.start_time))::INT AS days_down
FROM
    equipment e
JOIN
    maintenance_log ml ON e.equipment_id = ml.equipment_id
WHERE
    e.status = 'Under_Maintenance'
    AND ml.status = 'In_Progress'
    AND ml.start_time < CURRENT_TIMESTAMP - INTERVAL '7 days'
ORDER BY
    days_down DESC;
```

**4c. "Thay subquery bằng CTE" + thống kê theo kỹ thuật viên** – gộp chi phí một lần rồi nối:

```sql
WITH cost_by_equipment AS (
    SELECT
        equipment_id,
        SUM(cost) AS total_historical_repair_cost
    FROM
        maintenance_log
    GROUP BY
        equipment_id
)
SELECT
    e.equipment_id,
    e.equipment_name,
    ml.cost AS current_ticket_cost,
    c.total_historical_repair_cost
FROM
    equipment e
JOIN
    maintenance_log ml ON e.equipment_id = ml.equipment_id
JOIN
    cost_by_equipment c ON c.equipment_id = e.equipment_id
WHERE
    e.status = 'Under_Maintenance'
    AND ml.status = 'In_Progress'
ORDER BY
    c.total_historical_repair_cost DESC;
```

```sql
SELECT
    u.user_id AS technician_id,
    u.full_name AS technician_name,
    COUNT(*)     AS tickets,
    SUM(ml.cost) AS total_cost
FROM
    maintenance_log ml
JOIN
    user_account u ON ml.staff_user_id = u.user_id
GROUP BY
    u.user_id,
    u.full_name
HAVING
    COUNT(*) >= 1
ORDER BY
    total_cost DESC;
```

---

## Truy vấn 5 – Tỷ lệ lấp đầy (Fill Rate) của các lớp học nhóm

**Mục đích nghiệp vụ.** Đo sức hút của từng lớp (Yoga, Pilates, CrossFit…), phát hiện lớp ế để khuyến mãi hoặc đổi phòng.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `cs.current_enrolled::NUMERIC / cs.max_capacity::NUMERIC` | Ép kiểu `NUMERIC` **trước** khi chia; nếu chia hai `INT` thì kết quả là số nguyên (0 hoặc 1). `::` là toán tử ép kiểu của PostgreSQL. |
| `ROUND(… * 100.0, 2)` | Đổi sang phần trăm, 2 chữ số thập phân. |
| `CASE WHEN … THEN … END` | Phân loại theo ngưỡng: ≥ 100 % "Đầy", ≥ 70 % "Tốt", ≥ 40 % "Trung bình", còn lại "Thấp". Các nhánh được xét **từ trên xuống, nhánh đầu đúng sẽ thắng**, nên thứ tự ngưỡng giảm dần là bắt buộc. |
| `JOIN user_account` (HLV) và `JOIN facilities_room` | Tên giảng viên, tên phòng. |
| `ORDER BY fill_rate_percentage DESC, cs.start_time ASC` | Lớp đầy nhất lên đầu; hòa thì lớp sớm hơn đứng trước. |

**Hình dạng kết quả.** Mỗi dòng = một buổi lớp nhóm (mọi lớp trong bảng, không lọc thời gian) với sức chứa, số đã đăng ký, % lấp đầy và nhãn phân loại. Không bao giờ chia cho 0 vì `chk_class_capacity CHECK (max_capacity > 0)`; vẫn có thể phòng thủ bằng `NULLIF(cs.max_capacity, 0)`.

**Bẫy hay hỏi.** `current_enrolled` là cột **dẫn xuất** do trigger `trg_sync_class_enrollment_count` duy trì (BR-14) – nên tin cậy được; còn `max_capacity` của lớp có thể nhỏ hơn sức chứa phòng.

### Biến thể "sửa tại chỗ" cho truy vấn 5

**5a. "Chỉ lớp lấp đầy dưới 50 %"** – điều kiện trên biểu thức, không dùng alias trong `WHERE` (alias chưa tồn tại ở bước `WHERE`):

```sql
SELECT
    cs.class_id,
    cs.class_name,
    cs.current_enrolled,
    cs.max_capacity,
    ROUND(cs.current_enrolled * 100.0 / cs.max_capacity, 2) AS fill_rate_percentage
FROM
    class_schedule cs
WHERE
    cs.current_enrolled::NUMERIC / cs.max_capacity < 0.50
ORDER BY
    fill_rate_percentage ASC;
```

**5b. "Chỉ lớp trong tuần này, của một phòng"** – điều kiện thời gian + điều kiện theo phòng:

```sql
SELECT
    cs.class_id,
    cs.class_name,
    fr.room_name,
    cs.start_time,
    cs.current_enrolled,
    cs.max_capacity
FROM
    class_schedule cs
JOIN
    facilities_room fr ON cs.room_id = fr.room_id
WHERE
    cs.start_time >= DATE_TRUNC('week', CURRENT_DATE)
    AND cs.start_time <  DATE_TRUNC('week', CURRENT_DATE) + INTERVAL '1 week'
    AND fr.room_id = 1
ORDER BY
    cs.start_time;
```

**5c. "Tỷ lệ lấp đầy trung bình theo từng phòng, phòng nào thấp nhất"** – gom nhóm theo phòng:

```sql
SELECT
    fr.room_id,
    fr.room_name,
    COUNT(*) AS total_classes,
    ROUND(AVG(cs.current_enrolled * 100.0 / cs.max_capacity), 2) AS avg_fill_rate
FROM
    class_schedule cs
JOIN
    facilities_room fr ON cs.room_id = fr.room_id
GROUP BY
    fr.room_id,
    fr.room_name
ORDER BY
    avg_fill_rate ASC
LIMIT 1;
```

---

## Truy vấn 6 – Ca PT bị hủy muộn, hủy sớm hoặc bỏ tập (No-show)

**Mục đích nghiệp vụ.** Kiểm soát chính sách hủy lịch (BR-25): thống kê hội viên hay vắng mặt hoặc hủy sát giờ gây lãng phí thời gian HLV.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `JOIN user_account m … JOIN user_account t …` | **Self-join trên cùng một bảng** `user_account` hai lần với hai bí danh: `m` (hội viên) và `t` (HLV) vì `pt_booking` có hai khóa ngoại cùng trỏ về một bảng. |
| `WHERE pb.status IN ('Cancelled', 'Late_Cancelled', 'No_Show')` | Ba trạng thái "sự cố". `Late_Cancelled` là hủy khi còn **dưới 24 giờ** (trigger `trg_late_cancel_pt_booking` tự đổi từ `Cancelled`), vẫn bị trừ 1 buổi; `Cancelled` là hủy sớm, không trừ; `No_Show` là vắng mặt, trừ 1 buổi. |
| `CASE pb.status WHEN … THEN …` | *Simple CASE* (so sánh bằng với một biểu thức) – gọn hơn *searched CASE* khi chỉ so bằng. Mỗi trạng thái cho một chú thích chế tài BR-25. |
| `ORDER BY pb.booking_date DESC, pb.start_time DESC` | Sự cố mới nhất lên đầu. |

**Hình dạng kết quả.** Mỗi dòng = một ca PT có sự cố (mã ca, ngày giờ, hội viên + SĐT, HLV, trạng thái, ghi chú chế tài).

**Bẫy hay hỏi.** (1) Vì sao phải có trạng thái `Late_Cancelled` riêng thay vì tính từ thời điểm hủy? → bảng không lưu "thời điểm hủy"; trigger chốt phân loại ngay lúc hủy. (2) Vì sao `JOIN` bảng `user_account` 2 lần mà không bị nhầm cột? → dùng bí danh `m`, `t` và đặt tên cột kết quả bằng `AS`.

### Biến thể "sửa tại chỗ" cho truy vấn 6

**6a. "Chỉ hủy muộn trong 30 ngày gần nhất"**:

```sql
SELECT
    pb.booking_id,
    pb.booking_date,
    m.full_name AS member_name,
    t.full_name AS trainer_name
FROM
    pt_booking pb
JOIN
    user_account m ON pb.member_user_id = m.user_id
JOIN
    user_account t ON pb.trainer_user_id = t.user_id
WHERE
    pb.status = 'Late_Cancelled'
    AND pb.booking_date >= CURRENT_DATE - 30
ORDER BY
    pb.booking_date DESC;
```

**6b. "Hội viên có từ 2 sự cố trở lên, tách số lần No-show và Late-cancel"** – `COUNT(*) FILTER` + `HAVING`:

```sql
SELECT
    m.user_id AS member_id,
    m.full_name AS member_name,
    COUNT(*) FILTER (WHERE pb.status = 'No_Show')        AS no_shows,
    COUNT(*) FILTER (WHERE pb.status = 'Late_Cancelled') AS late_cancels,
    COUNT(*)                                             AS incidents
FROM
    pt_booking pb
JOIN
    user_account m ON pb.member_user_id = m.user_id
WHERE
    pb.status IN ('Late_Cancelled', 'No_Show')
GROUP BY
    m.user_id,
    m.full_name
HAVING
    COUNT(*) >= 2
ORDER BY
    incidents DESC,
    m.user_id;
```

**6c. "Thêm số buổi PT còn lại của hợp đồng"** – thêm một `JOIN`:

```sql
SELECT
    pb.booking_id,
    m.full_name AS member_name,
    pb.status AS incident_status,
    ms.remaining_sessions
FROM
    pt_booking pb
JOIN
    user_account m ON pb.member_user_id = m.user_id
JOIN
    member_subscription ms ON pb.subscription_id = ms.subscription_id
WHERE
    pb.status IN ('Late_Cancelled', 'No_Show')
ORDER BY
    pb.booking_date DESC;
```

---

## Truy vấn 7 – Hội viên mua gói PT nhưng chưa từng đặt lịch (nhóm "ngủ đông")

**Mục đích nghiệp vụ.** Tìm khách đã trả tiền gói có PT nhưng chưa dùng → trưởng bộ phận HLV gọi thăm hỏi, hướng dẫn lên lịch.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `LEFT JOIN pt_booking pb ON ms.subscription_id = pb.subscription_id` | Giữ **mọi hợp đồng**, kèm các ca PT nếu có; hợp đồng không có ca nào sẽ có các cột `pb.*` là `NULL`. |
| `WHERE pb.booking_id IS NULL` | Kỹ thuật **anti-join**: giữ đúng những hợp đồng *không tìm thấy* ca PT. Phải kiểm tra `IS NULL` trên cột khóa của bảng bên phải. |
| `mp.total_sessions > 0` | Chỉ gói có bao gồm PT (gói chỉ vào phòng tập không tính). |
| `ms.sub_status = 'Active'` | Chỉ hợp đồng đang hiệu lực. |
| `ORDER BY ms.start_time ASC` | Mua lâu nhất mà chưa dùng lên đầu. |

**Hình dạng kết quả.** Mỗi dòng = một hợp đồng PT Active chưa có ca PT nào (hội viên, liên hệ, gói, số buổi còn lại, ngày bắt đầu/hết hạn).

**Bẫy hay hỏi.** (1) Điều kiện `pb.booking_id IS NULL` đặt ở `WHERE`, còn điều kiện lọc *bảng phải* phải đặt trong `ON`. (2) "Chưa từng đặt" ở đây tính **cả ca đã hủy**: hội viên chỉ có toàn ca bị hủy vẫn bị coi là đã đặt → xem biến thể 7b. (3) Ba cách viết anti-join: `LEFT JOIN … IS NULL`, `NOT EXISTS`, `NOT IN`; **`NOT IN` nguy hiểm khi subquery có `NULL`** (cả biểu thức thành UNKNOWN → trả 0 dòng).

### Biến thể "sửa tại chỗ" cho truy vấn 7

**7a. "Viết lại bằng `NOT EXISTS`"** (tương đương, thường được ưa chuộng vì rõ nghĩa):

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    mp.plan_name,
    ms.subscription_id,
    ms.remaining_sessions
FROM
    member_subscription ms
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
JOIN
    user_account u ON ms.member_user_id = u.user_id
WHERE
    mp.total_sessions > 0
    AND ms.sub_status = 'Active'
    AND NOT EXISTS (
        SELECT 1
        FROM pt_booking pb
        WHERE pb.subscription_id = ms.subscription_id
    )
ORDER BY
    ms.start_time;
```

**7b. "Chưa từng có ca nào thực sự diễn ra hoặc đang chờ (bỏ qua ca đã hủy)"**:

```sql
SELECT
    u.full_name AS member_name,
    ms.subscription_id,
    ms.remaining_sessions
FROM
    member_subscription ms
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
JOIN
    user_account u ON ms.member_user_id = u.user_id
WHERE
    mp.total_sessions > 0
    AND ms.sub_status = 'Active'
    AND NOT EXISTS (
        SELECT 1
        FROM pt_booking pb
        WHERE pb.subscription_id = ms.subscription_id
          AND pb.status NOT IN ('Cancelled', 'Late_Cancelled')
    )
ORDER BY
    ms.start_time;
```

**7c. "Thêm số ngày kể từ lúc mua và lọc những người đã mua quá 14 ngày"**:

```sql
SELECT
    u.full_name AS member_name,
    ms.subscription_id,
    ms.start_time AS package_started_at,
    EXTRACT(DAY FROM (CURRENT_TIMESTAMP - ms.start_time))::INT AS days_since_purchase
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
    AND ms.start_time < CURRENT_TIMESTAMP - INTERVAL '14 days'
ORDER BY
    days_since_purchase DESC;
```

---

## Truy vấn 8 – Nhóm tuổi hội viên và gói tập được ưa chuộng nhất (CTE + `DENSE_RANK`)

**Mục đích nghiệp vụ.** Phân khúc nhân khẩu học để Marketing chọn gói phù hợp cho từng nhóm tuổi.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| CTE `member_age_groups` | Bước 1: mỗi dòng = một hợp đồng, kèm **tuổi** và **nhóm tuổi**. `AGE(CURRENT_DATE, u.dob)` trả `INTERVAL` (vd. "27 years 3 mons"); `EXTRACT(YEAR FROM …)` lấy số năm = tuổi tròn. |
| `CASE WHEN … < 25 … BETWEEN 25 AND 35 … BETWEEN 36 AND 50 … ELSE …` | Chia 4 nhóm. Tên nhóm có tiền tố "Nhóm 1…4" để `ORDER BY` theo chữ cái cũng ra đúng thứ tự. |
| CTE `plan_popularity` | Bước 2: đếm số hợp đồng theo cặp `(nhóm tuổi, gói)` rồi **xếp hạng trong từng nhóm tuổi**. |
| `DENSE_RANK() OVER (PARTITION BY age_bracket ORDER BY COUNT(*) DESC)` | **Window function.** `PARTITION BY` chia thành các "cửa sổ" riêng cho từng nhóm tuổi; `ORDER BY COUNT(*) DESC` xếp hạng theo số lượng giảm dần; `DENSE_RANK` cho các giá trị bằng nhau **cùng hạng** và hạng kế tiếp **không bị nhảy cóc** (1,1,2). Window function chạy *sau* `GROUP BY` nên được phép bọc hàm tổng hợp `COUNT(*)`. |
| `WHERE rank_in_bracket = 1` ở truy vấn ngoài | Không thể lọc trực tiếp theo window function trong cùng `SELECT` (nó tính sau `WHERE`), nên phải bọc trong CTE rồi lọc ở truy vấn ngoài. |

**Hình dạng kết quả.** Mỗi dòng = một gói đứng hạng 1 trong một nhóm tuổi (`age_bracket`, `top_preferred_plan`, `total_subscriptions`). **Một nhóm tuổi có thể có nhiều dòng** nếu nhiều gói đồng hạng 1 (đó là hệ quả của `DENSE_RANK`).

**Bẫy hay hỏi.** (1) `RANK` vs `DENSE_RANK` vs `ROW_NUMBER` (xem biến thể 9c). (2) Đếm theo **hợp đồng**, không phải theo hội viên: một hội viên có 3 hợp đồng được đếm 3 lần. (3) Tuổi tính theo ngày chạy truy vấn, không phải tuổi lúc mua gói.

### Biến thể "sửa tại chỗ" cho truy vấn 8

**8a. "Lấy top 2 gói mỗi nhóm tuổi, chỉ tính hợp đồng Active"** – thêm `WHERE ms.sub_status = 'Active'` ở CTE đầu và đổi `= 1` thành `<= 2`:

```sql
WITH member_age_groups AS (
    SELECT
        CASE
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) < 25 THEN 'Nhóm 1: Dưới 25 tuổi'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 25 AND 35 THEN 'Nhóm 2: 25 - 35 tuổi'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 36 AND 50 THEN 'Nhóm 3: 36 - 50 tuổi'
            ELSE 'Nhóm 4: Trên 50 tuổi'
        END AS age_bracket,
        mp.plan_name
    FROM
        user_account u
    JOIN
        member_subscription ms ON u.user_id = ms.member_user_id
    JOIN
        membership_plan mp ON ms.plan_id = mp.plan_id
    WHERE
        ms.sub_status = 'Active'
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
    plan_name,
    total_subscriptions,
    rank_in_bracket
FROM
    plan_popularity
WHERE
    rank_in_bracket <= 2
ORDER BY
    age_bracket,
    rank_in_bracket,
    plan_name;
```

**8b. "Mỗi nhóm tuổi chỉ đúng 1 dòng, hòa thì chọn tên gói theo thứ tự chữ cái"** – dùng `ROW_NUMBER()` với tiêu chí phá hòa:

```sql
WITH member_age_groups AS (
    SELECT
        CASE
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) < 25 THEN 'Nhóm 1: Dưới 25 tuổi'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 25 AND 35 THEN 'Nhóm 2: 25 - 35 tuổi'
            WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) BETWEEN 36 AND 50 THEN 'Nhóm 3: 36 - 50 tuổi'
            ELSE 'Nhóm 4: Trên 50 tuổi'
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
        ROW_NUMBER() OVER (
            PARTITION BY age_bracket
            ORDER BY COUNT(*) DESC, plan_name ASC
        ) AS rn
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
    rn = 1
ORDER BY
    age_bracket;
```

**8c. "Đổi mốc tuổi: dưới 18, 18–30, trên 30"** – chỉ sửa các nhánh `CASE` (lưu ý thứ tự nhánh):

```sql
SELECT
    CASE
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) < 18 THEN 'Dưới 18'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob)) <= 30 THEN '18 - 30'
        ELSE 'Trên 30'
    END AS age_bracket,
    COUNT(DISTINCT u.user_id) AS members
FROM
    user_account u
JOIN
    member_profile mpf ON u.user_id = mpf.user_id
GROUP BY
    1
ORDER BY
    1;
```

---

## Truy vấn 9 – Xếp hạng doanh thu đóng góp của từng hội viên (window function)

**Mục đích nghiệp vụ.** Bảng xếp hạng VIP (Kim Cương / Bạch Kim) theo tổng tiền thực chi.

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| `JOIN user_account → member_subscription → billing_log` | Từ hội viên đi qua hợp đồng tới hóa đơn. |
| `WHERE bl.payment_status = 'Completed'` | Chỉ tiền đã thu thật. |
| `GROUP BY u.user_id, u.full_name, u.phone, u.email` | Một dòng/hội viên; tổng hợp trên **tất cả** hợp đồng của họ. |
| `DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC)` | Cửa sổ **không có `PARTITION BY`** → xếp hạng toàn bảng. Hai hội viên cùng tổng tiền cùng hạng, hạng sau không nhảy cóc. |
| `CASE WHEN DENSE_RANK() OVER (...) <= 3 … <= 8 … ELSE …` | Phân hạng thành viên theo thứ hạng: top 3 = Kim Cương, hạng 4–8 = Bạch Kim, còn lại = Tiêu chuẩn. Window function lặp lại trong `CASE` vì không dùng được alias `spending_rank` cùng cấp. |
| `ORDER BY spending_rank ASC, total_money_spent DESC` | Sắp theo hạng. |

**Hình dạng kết quả.** Mỗi dòng = một hội viên đã có ít nhất một hóa đơn `Completed`; có cột `spending_rank` (có thể lặp) và `loyalty_tier`. Số hội viên "Kim Cương" có thể **lớn hơn 3** nếu có đồng hạng.

**Bẫy hay hỏi.** `RANK` / `DENSE_RANK` / `ROW_NUMBER` khác nhau thế nào? Vì sao không thể viết `WHERE spending_rank <= 5`? (window tính sau `WHERE`/`GROUP BY`/`HAVING`).

### Biến thể "sửa tại chỗ" cho truy vấn 9

**9a. "Chỉ lấy top 5"** – bọc truy vấn trong CTE/subquery rồi lọc theo hạng (không lọc trực tiếp trong cùng `SELECT`):

```sql
WITH member_spend AS (
    SELECT
        u.user_id AS member_id,
        u.full_name AS member_name,
        COUNT(bl.billing_id) AS total_bills_paid,
        SUM(bl.amount)       AS total_money_spent,
        DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) AS spending_rank
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
        u.full_name
)
SELECT
    *
FROM
    member_spend
WHERE
    spending_rank <= 5
ORDER BY
    spending_rank,
    member_id;
```

**9b. "Chỉ tính doanh thu quý này, kèm tỷ trọng % trên tổng"** – thêm điều kiện thời gian và `SUM(...) OVER ()` (cửa sổ toàn bảng, không phân vùng):

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    SUM(bl.amount) AS total_money_spent,
    ROUND(100.0 * SUM(bl.amount) / SUM(SUM(bl.amount)) OVER (), 2) AS pct_of_total,
    DENSE_RANK() OVER (ORDER BY SUM(bl.amount) DESC) AS spending_rank
FROM
    user_account u
JOIN
    member_subscription ms ON u.user_id = ms.member_user_id
JOIN
    billing_log bl ON ms.subscription_id = bl.subscription_id
WHERE
    bl.payment_status = 'Completed'
    AND bl.payment_date >= DATE_TRUNC('quarter', CURRENT_DATE)
    AND bl.payment_date <  DATE_TRUNC('quarter', CURRENT_DATE) + INTERVAL '3 months'
GROUP BY
    u.user_id,
    u.full_name
ORDER BY
    spending_rank,
    member_id;
```

**9c. "Phân biệt `RANK`, `DENSE_RANK`, `ROW_NUMBER`"** – ví dụ nhỏ trên dữ liệu giả có đồng hạng (rất hay được hỏi miệng):

```sql
SELECT
    v AS money,
    RANK()       OVER (ORDER BY v DESC) AS rank_,
    DENSE_RANK() OVER (ORDER BY v DESC) AS dense_rank_,
    ROW_NUMBER() OVER (ORDER BY v DESC) AS row_number_
FROM
    (VALUES (100), (90), (90), (80)) AS t (v);
```

Kết quả mong đợi: `RANK` = 1, 2, 2, 4 (nhảy cóc); `DENSE_RANK` = 1, 2, 2, 3 (không nhảy); `ROW_NUMBER` = 1, 2, 3, 4 (luôn duy nhất, hòa thì tùy thứ tự).

---

## Truy vấn 10 – Phát hiện xung đột trùng lịch của HLV (Self-join khoảng thời gian)

**Mục đích nghiệp vụ.** Kiểm toán tính toàn vẹn: tìm bất kỳ cặp sự kiện (lớp nhóm / ca PT) của **cùng một HLV** bị chồng giờ (BR-12).

**Giải thích từng phần**

| Phần | Giải thích |
|---|---|
| CTE `all_trainer_events` | Gộp lớp nhóm và ca PT chưa hủy (`Scheduled`, `Completed`) về dạng chung `(event_id, event_type, trainer_id, event_title, start_time, end_time)` bằng `UNION ALL`. |
| `FROM all_trainer_events e1 JOIN all_trainer_events e2 ON e1.trainer_id = e2.trainer_id` | **Self-join:** ghép mỗi sự kiện với mọi sự kiện khác của cùng HLV. |
| `e1.start_time < e2.end_time AND e1.end_time > e2.start_time` | **Điều kiện chồng lấn khoảng** (*overlap*): hai khoảng `[s1,e1)` và `[s2,e2)` giao nhau khi và chỉ khi *s1 < e2 và e1 > s2*. Dùng dấu `<`/`>` **nghiêm ngặt** nên hai ca nối tiếp nhau (ca 1 kết thúc 09:00, ca 2 bắt đầu 09:00) **không** bị coi là trùng. |
| `WHERE (e1.event_type, e1.event_id) < (e2.event_type, e2.event_id)` | Loại việc tự ghép với chính nó và chỉ giữ **một chiều** của mỗi cặp (A–B mà không có B–A). Dùng **so sánh bộ (row comparison)** của PostgreSQL trên cặp `(event_type, event_id)` vì `class_id` và `booking_id` là hai dãy số riêng, có thể trùng giá trị. |

**Hình dạng kết quả.** Mỗi dòng = một cặp sự kiện trùng giờ của một HLV. **Kết quả đúng của CSDL hiện tại là 0 dòng**, vì EXCLUDE `ex_class_trainer_no_overlap`, `ex_pt_trainer_no_overlap` và các trigger BR-12 đã chặn dữ liệu trùng ngay từ lúc ghi. Truy vấn này là công cụ *kiểm toán* (phát hiện dữ liệu cũ/nhập lậu), không phải chức năng nghiệp vụ hằng ngày.

**Bẫy hay hỏi.** (1) Vì sao phải so sánh `(event_type, event_id)` mà không chỉ `event_id`? Bản đầu của nhóm dùng `e1.event_id <> e2.event_id`, nhưng `event_id` của lớp lấy từ `class_id` còn của ca PT lấy từ `booking_id`: hai dãy số khác nhau có thể trùng giá trị (lớp #3 và ca PT #3), khi đó cặp xung đột thật bị **loại nhầm**. Nhóm đã sửa thành so sánh bộ; đây là điểm nên chủ động kể khi bảo vệ. (2) Vì sao kết quả là 0 dòng mà truy vấn vẫn có giá trị? → đó là truy vấn kiểm toán (xem biến thể 10a để chứng minh nó phát hiện được xung đột).

### Biến thể "sửa tại chỗ" cho truy vấn 10

**10a. "Chứng minh truy vấn hoạt động bằng dữ liệu giả"** (vì dữ liệu thật không có xung đột). Ba sự kiện: A 08:00–09:00, B 08:30–09:30, C 09:00–10:00 của cùng một HLV. Kỳ vọng đúng 2 cặp: A–B và B–C (A–C chỉ *chạm đầu mút* nên không tính):

```sql
WITH ev (event_id, trainer_id, start_time, end_time) AS (
    VALUES
        (1, 5, TIMESTAMP '2030-01-01 08:00', TIMESTAMP '2030-01-01 09:00'),
        (2, 5, TIMESTAMP '2030-01-01 08:30', TIMESTAMP '2030-01-01 09:30'),
        (3, 5, TIMESTAMP '2030-01-01 09:00', TIMESTAMP '2030-01-01 10:00')
)
SELECT
    e1.event_id AS first_event,
    e2.event_id AS conflict_event
FROM
    ev e1
JOIN
    ev e2 ON e1.trainer_id = e2.trainer_id
         AND e1.event_id < e2.event_id
         AND e1.start_time < e2.end_time
         AND e1.end_time > e2.start_time
ORDER BY
    e1.event_id,
    e2.event_id;
```

**10b. "Thêm phát hiện trùng phòng (hai lớp cùng phòng cùng giờ – BR-15) và chỉ xét 30 ngày tới"**:

```sql
SELECT
    a.room_id,
    a.class_id AS first_class,
    b.class_id AS conflict_class,
    a.start_time AS first_start,
    b.start_time AS conflict_start
FROM
    class_schedule a
JOIN
    class_schedule b ON a.room_id = b.room_id
                    AND a.class_id < b.class_id
                    AND a.start_time < b.end_time
                    AND a.end_time > b.start_time
WHERE
    a.start_time >= CURRENT_TIMESTAMP
    AND a.start_time <  CURRENT_TIMESTAMP + INTERVAL '30 days'
ORDER BY
    a.start_time;
```

**10c. "Vì sao phải so sánh bộ `(event_type, event_id)`?"** – chứng minh bằng dữ liệu giả có `event_id` trùng nhau giữa lớp và ca PT (cùng `id = 3`, cùng HLV, trùng giờ). Cột `buggy_pairs` dùng điều kiện cũ `e1.event_id < e2.event_id` nên **bỏ sót**; cột `fixed_pairs` dùng so sánh bộ nên phát hiện đúng 1 cặp:

```sql
WITH ev (event_type, event_id, trainer_id, start_time, end_time) AS (
    VALUES
        ('GROUP_CLASS', 3, 5, TIMESTAMP '2030-01-01 08:00', TIMESTAMP '2030-01-01 09:00'),
        ('PT_BOOKING',  3, 5, TIMESTAMP '2030-01-01 08:30', TIMESTAMP '2030-01-01 09:30')
)
SELECT
    (SELECT COUNT(*)
     FROM ev e1 JOIN ev e2 ON e1.trainer_id = e2.trainer_id
                          AND e1.event_id < e2.event_id
                          AND e1.start_time < e2.end_time
                          AND e1.end_time > e2.start_time) AS buggy_pairs,
    (SELECT COUNT(*)
     FROM ev e1 JOIN ev e2 ON e1.trainer_id = e2.trainer_id
                          AND (e1.event_type, e1.event_id) < (e2.event_type, e2.event_id)
                          AND e1.start_time < e2.end_time
                          AND e1.end_time > e2.start_time) AS fixed_pairs;
```

Kết quả mong đợi: `buggy_pairs = 0`, `fixed_pairs = 1`.

**10d. "Đếm số xung đột theo HLV"** – gom nhóm trên kết quả self-join:

```sql
WITH all_trainer_events AS (
    SELECT cs.trainer_user_id AS trainer_id, cs.start_time, cs.end_time, 'C' || cs.class_id AS ev_key
    FROM class_schedule cs
    UNION ALL
    SELECT pb.trainer_user_id, pb.start_time, pb.end_time, 'P' || pb.booking_id
    FROM pt_booking pb
    WHERE pb.status NOT IN ('Cancelled', 'Late_Cancelled')
)
SELECT
    e1.trainer_id,
    COUNT(*) AS conflicts
FROM
    all_trainer_events e1
JOIN
    all_trainer_events e2 ON e1.trainer_id = e2.trainer_id
                         AND e1.ev_key < e2.ev_key
                         AND e1.start_time < e2.end_time
                         AND e1.end_time > e2.start_time
GROUP BY
    e1.trainer_id
ORDER BY
    conflicts DESC;
```

---

# PHẦN B – TRIGGER, THỦ TỤC, VIEW VÀ RÀNG BUỘC TRONG LƯỢC ĐỒ

## B.0. Nguyên tắc phân chia: khi nào dùng ràng buộc, khi nào dùng trigger

Đây là câu hỏi "khung" rất hay gặp, hãy thuộc câu trả lời mẫu:

> **Ràng buộc khai báo** (`PRIMARY KEY`, `UNIQUE`, `CHECK`, `FOREIGN KEY`, `EXCLUDE`, chỉ mục duy nhất một phần) dùng cho quy tắc **trong phạm vi một dòng hoặc một bảng** – DBMS tối ưu sẵn, an toàn khi nhiều giao dịch chạy đồng thời. **Trigger** dùng cho quy tắc **liên quan nhiều bảng** hoặc cần **tính toán/ghi dẫn xuất** mà ràng buộc khai báo không diễn đạt được (ví dụ "chỉ được `Active` khi đã có hóa đơn `Completed`" – cần nhìn sang `billing_log`). Trigger chậm hơn và dễ sai khi có giao dịch đồng thời, nên nhóm chỉ dùng khi bắt buộc và bổ sung **khóa tư vấn** (`pg_advisory_xact_lock`) để tuần tự hóa.

**Bảng tổng hợp cơ chế thực thi** (chi tiết từng mục ở các mục sau):

| BR | Nội dung | Cơ chế | Đối tượng trong CSDL |
|---|---|---|---|
| BR-03 | Hội viên đủ 12 tuổi | Trigger | `trg_check_member_dob`, `trg_check_user_dob_for_member` |
| BR-05 | Mỗi hội viên tối đa 1 hợp đồng `Active` | Chỉ mục duy nhất một phần | `uq_member_one_active_subscription` |
| BR-07 | Chỉ `Active` khi đã có hóa đơn `Completed` | Trigger | `trg_require_payment_before_active`, `trg_activate_on_payment_*` |
| BR-08 | Mỗi chu kỳ chỉ 1 hóa đơn còn hiệu lực | Chỉ mục duy nhất một phần | `uq_billing_subscription_period` |
| BR-10 | Hóa đơn bất biến | Trigger + GRANT + chủ sở hữu `gym_owner` + event trigger | `trg_billing_immutable_*`, `gym_owner`, `evt_protect_billing_log`, `evt_protect_billing_log_drop` |
| BR-12, BR-15 | HLV / phòng không trùng lịch | `EXCLUDE` + trigger | `ex_class_trainer_no_overlap`, `ex_class_room_no_overlap`, `ex_pt_trainer_no_overlap`, `trg_check_*_conflicts` |
| BR-14 | Không vượt sức chứa lớp | `CHECK` + trigger đồng bộ | `chk_class_enrollment_limit`, `trg_sync_class_enrollment_count` |
| BR-16 | Hội viên không trùng lịch | `EXCLUDE` + trigger | `ex_pt_member_no_overlap`, `trg_check_pt_booking_conflicts`, `trg_check_class_enrollment_conflicts` |
| BR-18 | Trừ buổi PT / chỉ đặt khi còn buổi | Trigger | `trg_check_pt_booking_creation`, `trg_update_remaining_pt_sessions` |
| BR-19 | Chặn lịch vào phòng/máy đang bảo trì, chặn chuyển sang bảo trì khi còn lịch tương lai, đồng bộ trạng thái máy theo phiếu bảo trì | Trigger | `trg_prevent_class_in_maintenance_room`, `trg_prevent_equipment_reservation_under_maintenance`, `trg_prevent_room_maintenance_with_future_classes`, `trg_prevent_equipment_maintenance_with_future_reservations`, `trg_start_equipment_maintenance_*`, `trg_finish_equipment_maintenance` |
| BR-21 | Không giữ trùng máy, không giữ máy đang bảo trì | `EXCLUDE` + trigger | `ex_reservation_equipment_no_overlap`, `trg_check_reservation_window` |
| BR-23 | Lưu vết người thực hiện (tạo và sửa) | `NOT NULL` + FK + trigger | `trg_fill_created_by`, `trg_set_updated_by` (5 bảng), `fk_*_created_by`, `fk_*_updated_by` |
| BR-24 | Tự gia hạn / ân hạn | Thủ tục (container `scheduler` trong demo, `pg_cron`/cron trong production) + trigger | `sp_process_subscription_renewals`, `trg_activate_on_payment_*` |
| BR-25 | Hủy muộn < 24 h vẫn trừ buổi | Trigger | `trg_late_cancel_pt_booking` |

**Thứ tự thực thi cần nhớ.** Với cùng một sự kiện và cùng thời điểm (`BEFORE` / `AFTER`), PostgreSQL chạy các trigger theo **thứ tự bảng chữ cái của tên trigger**. Ví dụ khi `UPDATE pt_booking SET status = 'Cancelled'`: `BEFORE` → `trg_check_pt_booking_conflicts`, rồi `trg_late_cancel_pt_booking` (có thể đổi `NEW.status` thành `Late_Cancelled`), sau đó ghi dòng, cuối cùng `AFTER` → `trg_update_remaining_pt_sessions` (nhìn thấy trạng thái đã đổi nên trừ buổi).

---

## B.1. Nhóm trigger trong `01_schema_ddl.sql`

### B.1.1. `trg_check_member_dob` và `trg_check_user_dob_for_member` – BR-03 (tuổi tối thiểu 12)

| Thuộc tính | Nội dung |
|---|---|
| Bảng / sự kiện | `member_profile`: `BEFORE INSERT OR UPDATE OF user_id`; `user_account`: `BEFORE UPDATE OF dob` |
| Mức | `FOR EACH ROW` |
| Hàm | `trg_fn_check_user_age()`, `trg_fn_check_member_dob_update()` |
| Kiểm tra | Ngày sinh `> CURRENT_DATE - INTERVAL '12 years'` thì `RAISE EXCEPTION` (SQLSTATE `P0001`). |

**Vì sao cần hai trigger?** `member_profile` **không có cột `dob`** (ngày sinh nằm ở `user_account`) nên phải truy vấn sang `user_account` khi tạo hồ sơ hội viên; ngược lại khi *sửa ngày sinh* của một người đã là hội viên cũng phải chặn. **Vì sao không dùng `CHECK`?** (1) `CHECK` không được tham chiếu bảng khác; (2) `CURRENT_DATE` không phải biểu thức bất biến (*immutable*) nên không phù hợp cho `CHECK`; (3) quy tắc chỉ áp dụng cho **hội viên**, không áp dụng cho HLV/nhân viên.

```sql
-- LỖI MONG ĐỢI: P0001
INSERT INTO user_account (full_name, email, phone, dob, password_hash)
VALUES ('Be Tap Tanh', 'be.p4@example.com', '0999000002', (CURRENT_DATE - INTERVAL '8 years')::DATE, 'x');

INSERT INTO member_profile (user_id)
SELECT user_id FROM user_account WHERE email = 'be.p4@example.com';
```

### B.1.2. `trg_sync_class_enrollment_count` – BR-14 (sức chứa lớp, dữ liệu dẫn xuất)

| Thuộc tính | Nội dung |
|---|---|
| Bảng / sự kiện | `class_enrollment`: `AFTER INSERT OR UPDATE OR DELETE`, `FOR EACH ROW` |
| Hàm | `fn_sync_class_enrollment_count()` |
| Việc làm | Tính lại `class_schedule.current_enrolled` = số đăng ký có `status IN ('Enrolled','Attended')` của lớp đó (và của lớp cũ nếu đổi lớp). |
| Phối hợp | Khi đếm vượt `max_capacity`, `CHECK chk_class_enrollment_limit` (`current_enrolled <= max_capacity`) báo lỗi `23514`, **hủy luôn** lệnh `INSERT` đăng ký. |

**Vì sao `AFTER`?** Phải đợi dòng đăng ký đã nằm trong bảng thì mới đếm đúng được. **Vì sao tính lại bằng `COUNT(*)` thay vì `+1/-1`?** `COUNT` tự sửa sai (idempotent) và đúng cho mọi tổ hợp `INSERT/UPDATE/DELETE`, không lệch dần theo thời gian. Cột `current_enrolled` là **dữ liệu dẫn xuất** có kiểm soát (phi chuẩn hóa để đọc nhanh), xem Phần E.

```sql
-- LỖI MONG ĐỢI: 23514
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
VALUES (5, (SELECT MIN(room_id) FROM facilities_room WHERE status = 'Active'), 'Lop thu P4',
        CURRENT_DATE + INTERVAL '12 days 21 hours', CURRENT_DATE + INTERVAL '12 days 22 hours', 1);

INSERT INTO class_enrollment (subscription_id, class_id)
VALUES (8, (SELECT MAX(class_id) FROM class_schedule));

SELECT class_id, max_capacity, current_enrolled FROM class_schedule ORDER BY class_id DESC LIMIT 1;

INSERT INTO class_enrollment (subscription_id, class_id)
VALUES (1, (SELECT MAX(class_id) FROM class_schedule));
```

(Lớp chỉ có 1 chỗ: đăng ký đầu thành công và `current_enrolled` = 1; đăng ký thứ hai khiến `current_enrolled` = 2 > 1 nên bị `CHECK` chặn.)

---

## B.2. Nhóm trigger trong `04_triggers_views.sql`

### B.2.1. `trg_update_remaining_pt_sessions` – BR-18, BR-25 (trừ buổi PT)

| Thuộc tính | Nội dung |
|---|---|
| Bảng / sự kiện | `pt_booking`: **`AFTER UPDATE OF status`**, `FOR EACH ROW` |
| Hàm | `trg_fn_update_remaining_pt_sessions()` |
| Điều kiện trừ | Trạng thái mới thuộc `{Completed, No_Show, Late_Cancelled}` **và** trạng thái cũ **không** thuộc nhóm đó (tránh trừ hai lần khi `Completed` → `No_Show`). |
| Hành động | `SELECT … FOR UPDATE` khóa dòng hợp đồng → nếu `remaining_sessions <= 0` thì `RAISE EXCEPTION` (BR-18) → ngược lại `UPDATE … SET remaining_sessions = remaining_sessions - 1`. |
| Không trừ khi | Đặt lịch (`Scheduled`), hủy sớm (`Cancelled`). Buổi chỉ bị trừ khi **hoàn thành / vắng / hủy muộn**. |

**Vì sao `AFTER`?** Hành động trên bảng *khác* (`member_subscription`) và dòng `pt_booking` đã hợp lệ rồi mới trừ buổi; nếu trigger lỗi cả giao dịch bị hoàn tác. **Vì sao `FOR UPDATE`?** Khóa dòng hợp đồng để hai giao dịch đồng thời không cùng đọc "còn 1 buổi" rồi cùng trừ (Concurrency Control). **Vì sao `OF status`?** Chỉ kích hoạt khi cột `status` nằm trong danh sách `SET`.

**SECURITY DEFINER:** HLV (role `gym_role_trainer`) chỉ có quyền `UPDATE (status)` trên `pt_booking`, **không** có quyền ghi `member_subscription`; trigger phải chạy bằng quyền chủ sở hữu hàm mới trừ được buổi (xem B.4).

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Đặt ca PT 3 ngày tới (khung 21:00 luôn trống) rồi hoàn thành: remaining_sessions giảm đúng 1.
INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 3), CURRENT_DATE + INTERVAL '3 days 21 hours', CURRENT_DATE + INTERVAL '3 days 22 hours', 'Scheduled');

SELECT remaining_sessions AS before_complete FROM member_subscription WHERE subscription_id = 8;

UPDATE pt_booking
SET status = 'Completed'
WHERE booking_id = (SELECT MAX(booking_id) FROM pt_booking WHERE subscription_id = 8);

SELECT remaining_sessions AS after_complete FROM member_subscription WHERE subscription_id = 8;
```

### B.2.2. `trg_late_cancel_pt_booking` – BR-25 (hủy muộn)

| Thuộc tính | Nội dung |
|---|---|
| Bảng / sự kiện | `pt_booking`: **`BEFORE UPDATE OF status`**, `FOR EACH ROW` |
| Hàm | `trg_fn_late_cancel_pt_booking()` |
| Logic | Nếu `NEW.status = 'Cancelled'`, `OLD.status = 'Scheduled'` và `NEW.start_time < CURRENT_TIMESTAMP + 24 giờ` thì **gán lại** `NEW.status := 'Late_Cancelled'` + `RAISE NOTICE`. |
| Hệ quả | `trg_update_remaining_pt_sessions` (AFTER) thấy `Late_Cancelled` và trừ 1 buổi. Hủy sớm hơn 24 h giữ `Cancelled`, không trừ. |

**Vì sao `BEFORE`?** Chỉ `BEFORE` trigger mới được **sửa `NEW`** trước khi dòng được ghi. Ứng dụng chỉ cần `UPDATE … SET status='Cancelled'`, không cần tự tính 24 giờ → quy tắc nằm tập trung ở CSDL.

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Hủy sớm (> 24 h): giữ nguyên 'Cancelled', không trừ buổi.
INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 3), CURRENT_DATE + INTERVAL '3 days 21 hours', CURRENT_DATE + INTERVAL '3 days 22 hours', 'Scheduled');

UPDATE pt_booking SET status = 'Cancelled'
WHERE booking_id = (SELECT MAX(booking_id) FROM pt_booking WHERE subscription_id = 8)
RETURNING booking_id, status;
```

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Hủy muộn (< 24 h): trigger đổi thành 'Late_Cancelled' và trừ 1 buổi.
WITH slot AS (
    SELECT CASE WHEN LOCALTIMESTAMP < CURRENT_DATE + INTERVAL '21 hours'
                THEN CURRENT_DATE + INTERVAL '21 hours'
                ELSE CURRENT_DATE + INTERVAL '1 day 21 hours'
           END AS s
)
INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
SELECT 18, 5, 8, s::DATE, s, s + INTERVAL '1 hour', 'Scheduled' FROM slot;

SELECT remaining_sessions AS before_cancel FROM member_subscription WHERE subscription_id = 8;

UPDATE pt_booking SET status = 'Cancelled'
WHERE booking_id = (SELECT MAX(booking_id) FROM pt_booking WHERE subscription_id = 8)
RETURNING booking_id, status;

SELECT remaining_sessions AS after_cancel FROM member_subscription WHERE subscription_id = 8;
```

### B.2.3. `trg_check_pt_booking_creation` – BR-18 lúc **tạo** ca PT

| Thuộc tính | Nội dung |
|---|---|
| Bảng / sự kiện | `pt_booking`: `BEFORE INSERT`, `FOR EACH ROW` |
| Kiểm tra | Hợp đồng phải `Active`; giờ bắt đầu nằm trong `[start_time, end_time]` của hợp đồng; riêng ca `Scheduled`: `remaining_sessions` phải **lớn hơn** số ca `Scheduled` đang chờ (mỗi ca chờ sẽ tiêu 1 buổi). |
| Đồng thời | `pg_advisory_xact_lock(3, subscription_id)` để hai lễ tân đặt cùng lúc không cùng giành buổi cuối. |

Trigger này bổ sung cho trigger trừ buổi: một cái *chặn đặt thừa*, một cái *trừ khi tập xong*. Nếu hợp đồng còn 1 buổi và đã có 1 ca `Scheduled` thì ca thứ hai bị từ chối ngay.

### B.2.4. Cặp trigger `trg_require_payment_before_active` và `trg_activate_on_payment_insert/_update` – BR-07 (kích hoạt hợp đồng) và BR-24

| Trigger | Sự kiện | Vai trò |
|---|---|---|
| `trg_require_payment_before_active` | `member_subscription`: `BEFORE INSERT OR UPDATE OF sub_status … WHEN (NEW.sub_status = 'Active')` | **Cổng chặn:** chuyển/chèn `Active` mà chưa có hóa đơn `Completed` của hợp đồng đó thì `RAISE EXCEPTION` (BR-07). |
| `trg_activate_on_payment_insert` / `_update` | `billing_log`: `AFTER INSERT` / `AFTER UPDATE OF payment_status`, có `WHEN (… = 'Completed')` | **Tự kích hoạt:** hóa đơn thành `Completed` thì hợp đồng `Pending` → `Active`; nếu là hóa đơn **gia hạn** của hợp đồng tự gia hạn thì cộng `duration_days` vào `end_time`, đặt lại `remaining_sessions = total_sessions`, đưa hợp đồng về `Active` (BR-24). |

Luồng đúng: tạo hợp đồng `Pending` → ghi hóa đơn `Completed` → trigger tự đưa hợp đồng sang `Active`. Mệnh đề `WHEN` trong định nghĩa trigger giúp PostgreSQL **không gọi hàm** khi điều kiện sai (tiết kiệm). Nếu hội viên đang có hợp đồng `Active` khác, bước tự chuyển sang `Active` vi phạm `uq_member_one_active_subscription` (BR-05) và **toàn bộ lệnh ghi hóa đơn bị hủy**.

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Luồng đúng: Pending -> (hóa đơn Completed) -> tự động Active.
INSERT INTO user_account (full_name, email, phone, dob, password_hash)
VALUES ('Hoi Vien Demo P4', 'demo.p4@example.com', '0999000001', DATE '2000-01-01', 'x');

INSERT INTO member_profile (user_id)
SELECT user_id FROM user_account WHERE email = 'demo.p4@example.com';

INSERT INTO member_subscription (member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status)
SELECT user_id, (SELECT MIN(plan_id) FROM membership_plan), 500000, 0,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 'Pending'
FROM user_account WHERE email = 'demo.p4@example.com';

SELECT sub_status AS before_payment
FROM member_subscription
WHERE member_user_id = (SELECT user_id FROM user_account WHERE email = 'demo.p4@example.com');

INSERT INTO billing_log (subscription_id, invoice_no, amount, payment_date, payment_method, payment_status)
SELECT subscription_id, 'INV-P4-DEMO', 500000, CURRENT_DATE, 'Cash', 'Completed'
FROM member_subscription
WHERE member_user_id = (SELECT user_id FROM user_account WHERE email = 'demo.p4@example.com');

SELECT sub_status AS after_payment
FROM member_subscription
WHERE member_user_id = (SELECT user_id FROM user_account WHERE email = 'demo.p4@example.com');
```

```sql
-- LỖI MONG ĐỢI: P0001
-- Cố ép hợp đồng thành Active khi chưa có hóa đơn Completed.
INSERT INTO user_account (full_name, email, phone, dob, password_hash)
VALUES ('Hoi Vien Demo P4', 'demo.p4@example.com', '0999000001', DATE '2000-01-01', 'x');

INSERT INTO member_profile (user_id)
SELECT user_id FROM user_account WHERE email = 'demo.p4@example.com';

INSERT INTO member_subscription (member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status)
SELECT user_id, (SELECT MIN(plan_id) FROM membership_plan), 500000, 0,
       CURRENT_TIMESTAMP, CURRENT_TIMESTAMP + INTERVAL '30 days', 'Active'
FROM user_account WHERE email = 'demo.p4@example.com';
```

### B.2.5. `trg_billing_immutable_update / _delete / _truncate` – BR-10 (hóa đơn bất biến)

| Trigger | Sự kiện | Luật |
|---|---|---|
| `trg_billing_immutable_update` | `BEFORE UPDATE` (row) | Hóa đơn `Completed` chỉ được đổi `payment_status` sang `Refunded` (mọi cột khác giữ nguyên). Hóa đơn `Pending` được chuyển sang `Completed`/`Failed` (và ghi nhận `amount`, `payment_date`, `payment_method`), không đổi mã hóa đơn/hợp đồng/chu kỳ. `Failed`/`Refunded` là trạng thái cuối: cấm sửa. |
| `trg_billing_immutable_delete` | `BEFORE DELETE` (row) | Luôn chặn. Muốn hoàn tiền thì chuyển sang `Refunded`. |
| `trg_billing_immutable_truncate` | `BEFORE TRUNCATE` (**statement**) | Luôn chặn. `TRUNCATE` không gọi trigger row nên cần trigger mức câu lệnh riêng. |

**Vì sao dùng nhiều lớp mà không chỉ `REVOKE UPDATE, DELETE`?** `REVOKE` không có hiệu lực với **chủ sở hữu bảng và superuser**; trigger áp dụng cho tất cả nhưng chủ sở hữu vẫn có thể `ALTER TABLE … DISABLE TRIGGER`. Vì vậy BR-10 được bảo vệ **bốn lớp (defense in depth)**: (1) trigger bất biến; (2) `GRANT` chỉ cho role ứng dụng `SELECT, INSERT` trên `billing_log` (Phần D); (3) mọi đối tượng thuộc role `NOLOGIN` `gym_owner`, không tài khoản đăng nhập nào là chủ sở hữu hay thành viên của nó nên không ai `ALTER`/`DROP` được; (4) event trigger `evt_protect_billing_log` (`ddl_command_end`) và `evt_protect_billing_log_drop` (`sql_drop`) chặn `ALTER TABLE`, `DROP TABLE`, `DROP`/`ALTER TRIGGER` trên `billing_log` và việc sửa/xóa các hàm trigger bất biến, **kể cả với superuser** (lỗi `P0001`, thông báo chứa `BR-10`). Superuser là gốc tin cậy của mọi DBMS nên vẫn bảo trì có chủ đích được bằng `ALTER EVENT TRIGGER … DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`; thao tác phải tường minh. (Hệ quả: chạy lại `04_triggers_views.sql` trên CSDL đã có event trigger cần lối thoát này.)

```sql
-- LỖI MONG ĐỢI: P0001
UPDATE billing_log
SET amount = amount + 1
WHERE billing_id = (SELECT MIN(billing_id) FROM billing_log WHERE payment_status = 'Completed');
```

```sql
-- LỖI MONG ĐỢI: P0001
DELETE FROM billing_log
WHERE billing_id = (SELECT MIN(billing_id) FROM billing_log WHERE payment_status = 'Completed');
```

```sql
-- LỖI MONG ĐỢI: P0001
TRUNCATE TABLE billing_log;
```

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Được phép duy nhất: Completed -> Refunded (không đổi cột nào khác).
UPDATE billing_log
SET payment_status = 'Refunded'
WHERE billing_id = (SELECT MIN(billing_id) FROM billing_log WHERE payment_status = 'Completed')
RETURNING billing_id, invoice_no, payment_status;
```

Lớp (4) – event trigger chặn cả superuser:

```sql
-- LỖI MONG ĐỢI: P0001
ALTER TABLE billing_log DISABLE TRIGGER USER;
```

```sql
-- LỖI MONG ĐỢI: P0001
DROP TRIGGER trg_billing_immutable_delete ON billing_log;
```

```sql
-- Lối thoát bảo trì có chủ đích của superuser (chỉ hiệu lực trong giao dịch này).
SET LOCAL app.allow_billing_maintenance = 'on';
ALTER TABLE billing_log DISABLE TRIGGER USER;
ALTER TABLE billing_log ENABLE TRIGGER USER;
```

Lớp (3) – quyền sở hữu và lớp (4) đang bật:

```sql
SELECT c.relname, c.relowner::REGROLE AS owner
FROM pg_class AS c
WHERE c.relname = 'billing_log';

SELECT evtname, evtevent, evtenabled
FROM pg_event_trigger
ORDER BY evtname;
```

### B.2.6. `trg_fill_billing_period_start` – BR-08 (chu kỳ tính phí)

`BEFORE INSERT` trên `billing_log`: nếu câu `INSERT` không nêu `billing_period_start` thì điền bằng ngày bắt đầu hợp đồng. Nhờ đó câu `INSERT` cũ của ứng dụng vẫn chạy. Chống trùng chu kỳ do **chỉ mục duy nhất một phần** `uq_billing_subscription_period (subscription_id, billing_period_start) WHERE payment_status IN ('Pending','Completed')` – hóa đơn `Failed`/`Refunded` không chiếm chu kỳ nên được phát hành lại.

### B.2.7. `trg_fill_created_by` và `trg_set_updated_by` – BR-23 (vết người tạo và người sửa)

Trên 5 bảng giao dịch (`member_subscription`, `billing_log`, `class_schedule`, `pt_booking`, `maintenance_log`) có ba cột: `created_by_user_id INT NOT NULL`, `updated_by_user_id INT NULL`, `updated_at TIMESTAMP NULL`; hai cột người dùng đều có khóa ngoại tới `user_account` (`fk_*_created_by`, `fk_*_updated_by`).

| Trigger | Sự kiện | Luật |
|---|---|---|
| `trg_fill_created_by` | `BEFORE INSERT` | Nếu `created_by_user_id` còn `NULL`, điền từ `current_setting('app.current_user_id', TRUE)` (tham số `TRUE` = "không báo lỗi nếu biến chưa đặt"). Vẫn không xác định được người thực hiện thì **`RAISE EXCEPTION` (`P0001`, `BR-23`)**; kết hợp `NOT NULL` nên không còn dòng nào thiếu người tạo. |
| `trg_set_updated_by` | `BEFORE UPDATE` | Luôn ghi `updated_by_user_id` và `updated_at` từ phiên (không tin giá trị do câu lệnh truyền vào); **cấm đổi `created_by_user_id`**; từ chối nếu chưa đặt biến phiên. |

Mọi chương trình ghi dữ liệu phải đặt biến phiên: ứng dụng dùng `SET LOCAL` trong từng giao dịch (`db_tx`), service `scheduler` đặt qua `PGOPTIONS` (`SCHEDULER_ACTOR_USER_ID`, mặc định 3), script test đặt ở đầu tập tin. Vì vậy gọi `sp_process_subscription_renewals()` hoặc chạy DML thủ công mà không đặt biến sẽ lỗi **theo thiết kế**.

```sql
SET LOCAL app.current_user_id = '3';

INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 3), CURRENT_DATE + INTERVAL '3 days 21 hours', CURRENT_DATE + INTERVAL '3 days 22 hours', 'Scheduled');

SELECT booking_id, created_by_user_id, updated_by_user_id
FROM pt_booking
WHERE booking_id = (SELECT MAX(booking_id) FROM pt_booking);
```

```sql
-- LỖI MONG ĐỢI: P0001
RESET app.current_user_id;

INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 3), CURRENT_DATE + INTERVAL '3 days 21 hours', CURRENT_DATE + INTERVAL '3 days 22 hours', 'Scheduled');
```

```sql
-- UPDATE tự ghi người sửa và thời điểm sửa (người sửa lấy từ phiên, không phải từ câu lệnh).
SET LOCAL app.current_user_id = '4';

UPDATE member_subscription
SET is_recurring = is_recurring
WHERE subscription_id = 8
RETURNING subscription_id, created_by_user_id, updated_by_user_id, updated_at;
```

```sql
-- LỖI MONG ĐỢI: P0001
SET LOCAL app.current_user_id = '3';

UPDATE member_subscription
SET created_by_user_id = 4
WHERE subscription_id = 8;
```

**Câu hỏi hay gặp:** *"Vì sao `created_by_user_id` là `NOT NULL` nhưng `updated_by_user_id` cho phép `NULL`?"* – Mọi dòng đều có người tạo; còn người sửa chỉ tồn tại sau lần `UPDATE` đầu tiên (dòng chưa bao giờ sửa thì `NULL` là đúng ngữ nghĩa, không phải thiếu dữ liệu).

### B.2.8. Nhóm chống trùng lịch xuyên bảng – BR-12, BR-15, BR-16: `trg_check_class_schedule_conflicts`, `trg_check_pt_booking_conflicts`, `trg_check_class_enrollment_conflicts`

Ràng buộc `EXCLUDE` chỉ so sánh các dòng **trong cùng một bảng**. Nhưng một HLV có thể bị trùng giữa *lớp nhóm* (`class_schedule`) và *ca PT* (`pt_booking`), một hội viên có thể bị trùng giữa *ca PT* và *lớp đã đăng ký*. Các trigger này kiểm tra **chéo bảng** bằng toán tử `tsrange(...) && tsrange(...)`:

| Trigger | Bảng | Chặn |
|---|---|---|
| `trg_check_class_schedule_conflicts` | `class_schedule` (`BEFORE INSERT OR UPDATE OF trainer_user_id, start_time, end_time`) | (a) HLV có lớp trùng với ca PT chưa hủy của chính mình (BR-12); (b) khi **đổi giờ** lớp đã có người đăng ký, không hội viên nào được trùng ca PT/lớp khác (BR-16). |
| `trg_check_pt_booking_conflicts` | `pt_booking` (`BEFORE INSERT OR UPDATE OF trainer_user_id, member_user_id, start_time, end_time, status`) | Ca PT trùng lớp nhóm của HLV (BR-12) hoặc lớp hội viên đã đăng ký (BR-16). Bỏ qua ca `Cancelled`/`Late_Cancelled`. |
| `trg_check_class_enrollment_conflicts` | `class_enrollment` | Đăng ký lớp trùng ca PT hoặc trùng lớp khác của cùng hội viên, **kể cả khi dùng hai hợp đồng khác nhau** (suy hội viên qua hợp đồng). |

**Điểm đáng nói khi bảo vệ**

1. Trigger dùng `pg_advisory_xact_lock(loại, id)`: kiểm tra "chưa trùng" rồi mới `INSERT` là **hai bước**, nên hai giao dịch đồng thời cùng thấy "chưa trùng" và cùng ghi (*race condition*). Khóa tư vấn buộc các giao dịch cùng HLV/hội viên chạy tuần tự; khóa tự nhả khi `COMMIT`/`ROLLBACK`. Thứ tự giành khóa luôn **HLV → hội viên → hợp đồng** để tránh *deadlock*.
2. Lỗi báo với `ERRCODE = 'exclusion_violation'` (`23P01`), cùng mã với `EXCLUDE` để ứng dụng xử lý đồng nhất.
3. Dùng `tsrange(…, '[)')` (nửa mở) nên hai ca nối tiếp không bị coi là trùng.

```sql
-- LỖI MONG ĐỢI: 23P01
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- HLV 5 đang đứng lớp 21:00-22:00 thì không thể nhận ca PT 21:30-22:30.
INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
VALUES (5, (SELECT MIN(room_id) FROM facilities_room WHERE status = 'Active'), 'Lop thu P4',
        CURRENT_DATE + INTERVAL '12 days 21 hours', CURRENT_DATE + INTERVAL '12 days 22 hours', 10);

INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 12), CURRENT_DATE + INTERVAL '12 days 21 hours 30 minutes', CURRENT_DATE + INTERVAL '12 days 22 hours 30 minutes', 'Scheduled');
```

### B.2.9. `trg_prevent_class_in_maintenance_room`, `trg_prevent_equipment_reservation_under_maintenance` – BR-19

`BEFORE INSERT OR UPDATE OF room_id` trên `class_schedule` và `BEFORE INSERT OR UPDATE OF equipment_id` trên `equipment_reservation`: tra trạng thái phòng/thiết bị, nếu phòng không `Active` hoặc thiết bị không `Operational` thì `RAISE EXCEPTION` (kèm tên trạng thái hiện tại) kèm tên phòng/thiết bị. Dùng `BEFORE` để chặn **trước khi ghi**, nên không cần hoàn tác. Dùng `UPDATE OF room_id` để chỉ chạy khi thực sự đổi phòng.

```sql
-- LỖI MONG ĐỢI: P0001
INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
VALUES (5, (SELECT MIN(room_id) FROM facilities_room WHERE status = 'Under_Maintenance'), 'Lop cam xep',
        CURRENT_DATE + INTERVAL '12 days 21 hours', CURRENT_DATE + INTERVAL '12 days 22 hours', 10);
```

### B.2.9b. Nhóm đồng bộ bảo trì – BR-19 chiều ngược: `trg_prevent_room_maintenance_with_future_classes`, `trg_prevent_equipment_maintenance_with_future_reservations`, `trg_start_equipment_maintenance_insert/_update`, `trg_finish_equipment_maintenance`

B.2.9 chỉ chặn **xếp lịch mới** vào phòng/thiết bị đang bảo trì. Nhóm trigger này đóng nốt hai lỗ hổng còn lại: (1) chuyển phòng/thiết bị sang bảo trì trong khi **lịch tương lai đã xếp sẵn**; (2) trạng thái thiết bị **không khớp** nhật ký bảo trì (phải nhớ đổi tay).

| Trigger | Bảng, sự kiện | Việc làm |
|---|---|---|
| `trg_prevent_room_maintenance_with_future_classes` | `facilities_room`: `BEFORE UPDATE OF status`, `WHEN (NEW.status = 'Under_Maintenance' AND OLD.status IS DISTINCT FROM NEW.status)` | Đếm lớp của phòng có `start_time > CURRENT_TIMESTAMP`; còn lớp nào thì `RAISE EXCEPTION 'Lỗi nghiệp vụ BR-19: … còn N lớp học sắp diễn ra'` (`P0001`). Nhân viên phải dời/hủy lớp trước. |
| `trg_prevent_equipment_maintenance_with_future_reservations` | `equipment`: `BEFORE UPDATE OF status`, cùng điều kiện `WHEN` | Đếm lượt giữ chỗ `Reserved` có `start_time > CURRENT_TIMESTAMP` của thiết bị; còn thì từ chối (`P0001`). |
| `trg_start_equipment_maintenance_insert` / `_update` | `maintenance_log`: `AFTER INSERT` / `AFTER UPDATE OF status`, `WHEN (NEW.status = 'In_Progress')` | Đổi `equipment.status` từ `Operational` sang `Under_Maintenance`. Lệnh `UPDATE` này lại đi qua trigger kiểm tra giữ chỗ ở hàng trên, nên mở phiếu cho thiết bị còn giữ chỗ tương lai cũng bị từ chối (cả `INSERT` bị hoàn tác). |
| `trg_finish_equipment_maintenance` | `maintenance_log`: `AFTER UPDATE OF status`, `WHEN (OLD.status = 'In_Progress' AND NEW.status IN ('Completed', 'Cancelled'))` | Nếu thiết bị **không còn phiếu `In_Progress` nào khác** (`NOT EXISTS`) thì đưa về `Operational`; thiết bị `Decommissioned` giữ nguyên (điều kiện `status = 'Under_Maintenance'`). |

**Điểm đáng nói khi bảo vệ**

1. Dùng `BEFORE` cho hai trigger chặn (từ chối trước khi ghi) và `AFTER` cho hai trigger đồng bộ (phiếu đã ghi xong mới sửa bảng khác; hàm trả `NULL` vì giá trị trả về của `AFTER ... FOR EACH ROW` bị bỏ qua).
2. Mệnh đề `WHEN` lọc ngay ở mức định nghĩa trigger nên hàm chỉ chạy khi thật sự đổi sang `Under_Maintenance`; các lần cập nhật khác không tốn chi phí.
3. Kỹ thuật viên chỉ có `UPDATE (status)` trên `equipment`/`facilities_room` và `INSERT` trên `maintenance_log`, nhưng các hàm trigger là `SECURITY DEFINER SET search_path = public, pg_temp` (08 liệt kê động mọi hàm trigger) nên vẫn đọc được `class_schedule`/`equipment_reservation` và chạy trọn quy trình; test `EA-03` của `09_rbac_test_cases.sql` chứng minh điều này.
4. Câu hỏi bẫy: *"Hai ca bảo trì cùng lúc cho một thiết bị thì sao?"* → hoàn tất một ca không đưa thiết bị về `Operational` chừng nào còn ca `In_Progress` khác (test `TP-34`).

```sql
-- LỖI MONG ĐỢI: P0001
-- Phòng còn lớp học sắp diễn ra thì không thể chuyển sang bảo trì.
UPDATE facilities_room
SET status = 'Under_Maintenance'
WHERE room_id = (SELECT room_id FROM class_schedule WHERE start_time > CURRENT_TIMESTAMP ORDER BY class_id LIMIT 1);
```

```sql
-- LỖI MONG ĐỢI: P0001
-- Thiết bị còn lượt giữ chỗ Reserved trong tương lai thì không thể chuyển sang bảo trì.
UPDATE equipment
SET status = 'Under_Maintenance'
WHERE equipment_id = (SELECT equipment_id
                      FROM equipment_reservation
                      WHERE status = 'Reserved' AND start_time > CURRENT_TIMESTAMP
                      ORDER BY reservation_id LIMIT 1);
```

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Hợp lệ: mở phiếu bảo trì In_Progress cho thiết bị chưa có giữ chỗ tương lai
-- => thiết bị tự chuyển Under_Maintenance; hoàn tất phiếu => tự về Operational.
WITH target AS (
    SELECT e.equipment_id
    FROM equipment AS e
    WHERE e.status = 'Operational'
      AND NOT EXISTS (SELECT 1 FROM equipment_reservation AS r
                      WHERE r.equipment_id = e.equipment_id AND r.status = 'Reserved' AND r.start_time > CURRENT_TIMESTAMP)
    ORDER BY e.equipment_id
    LIMIT 1
)
INSERT INTO maintenance_log (equipment_id, staff_user_id, issue_description, start_time)
SELECT equipment_id, 4, 'Thay day curoa (demo bao ve)', CURRENT_TIMESTAMP
FROM target;

SELECT e.equipment_id, e.status AS status_sau_khi_mo_phieu
FROM equipment AS e
JOIN maintenance_log AS ml ON ml.equipment_id = e.equipment_id
WHERE ml.issue_description = 'Thay day curoa (demo bao ve)';

UPDATE maintenance_log
SET status = 'Completed', end_time = CURRENT_TIMESTAMP
WHERE issue_description = 'Thay day curoa (demo bao ve)';

SELECT e.equipment_id, e.status AS status_sau_khi_hoan_tat
FROM equipment AS e
JOIN maintenance_log AS ml ON ml.equipment_id = e.equipment_id
WHERE ml.issue_description = 'Thay day curoa (demo bao ve)';
```

### B.2.10. `trg_check_reservation_window` – BR-21 (giữ chỗ thiết bị)

`BEFORE INSERT OR UPDATE` trên `equipment_reservation`: (a) lượt giữ chỗ chưa hủy không được chồng với **phiếu bảo trì `In_Progress`** của thiết bị (phiếu chưa có `end_time` coi như kéo dài vô hạn: `COALESCE(end_time, 'infinity')`); (b) lượt giữ chỗ phải nằm **trọn** trong khung giờ của ca PT / lớp mà nó gắn vào. Phần "một thiết bị không bị giữ trùng giờ" do `EXCLUDE ex_reservation_equipment_no_overlap` đảm nhiệm.

```sql
-- LỖI MONG ĐỢI: 23P01
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Thiết bị 3 đang bảo trì (phiếu In_Progress): không thể giữ chỗ cho lớp tương lai.
INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
VALUES (5, (SELECT MIN(room_id) FROM facilities_room WHERE status = 'Active'), 'Lop thu P4',
        CURRENT_DATE + INTERVAL '12 days 21 hours', CURRENT_DATE + INTERVAL '12 days 22 hours', 10);

INSERT INTO equipment_reservation (equipment_id, class_id, start_time, end_time)
SELECT 3, class_id, start_time, end_time
FROM class_schedule
WHERE class_id = (SELECT MAX(class_id) FROM class_schedule);
```

### B.2.11. Thủ tục `sp_process_subscription_renewals(p_as_of, p_grace_days)` – BR-24

PostgreSQL **không có bộ lập lịch tích hợp**, nên quy tắc theo thời gian được viết thành `PROCEDURE` để `cron`/`pg_cron` gọi mỗi ngày (`CALL sp_process_subscription_renewals();`). Trong Docker demo, service `scheduler` (container `fitzone_renewal_scheduler`, image `postgres:16-alpine`) chạy vòng lặp shell gọi thủ tục này bằng tài khoản `gym_u_reception` ngay khi khởi động rồi mỗi `RENEWAL_INTERVAL_SECONDS` giây (mặc định 86400); xem bằng `docker logs fitzone_renewal_scheduler`. Tham số `p_as_of` (mặc định hôm nay) cho phép **truyền ngày giả để kiểm thử**; `p_grace_days` mặc định 3.

| Bước | Điều kiện | Hành động |
|---|---|---|
| 1 | Hợp đồng `Active`, **không** tự gia hạn, `end_time < p_as_of` | → `Expired` |
| 2 | Hợp đồng `Active`, **tự gia hạn**, quá hạn, chưa có hóa đơn `Pending`/`Completed` cho chu kỳ kế | Phát hành 1 hóa đơn `Pending` (số tiền = `actual_price`) |
| 3 | Hợp đồng `Active`, tự gia hạn, quá `end_time + p_grace_days` mà chưa trả | → `Suspended` |

Khi hóa đơn gia hạn được thanh toán, `trg_activate_on_payment_*` gia hạn `end_time`, đặt lại buổi PT và kích hoạt lại hợp đồng. Thủ tục **idempotent** (gọi lại nhiều lần cùng ngày không phát sinh thêm: bước 2 có `NOT EXISTS`, bước 1 và 3 chỉ chọn hợp đồng còn `Active`). **Vì sao `PROCEDURE` mà không `FUNCTION`?** Gọi bằng `CALL`, có thể quản lý giao dịch và không cần trả về giá trị.

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Giả lập "400 ngày sau": hợp đồng quá hạn bị Expired/Suspended, hóa đơn gia hạn Pending được phát hành.
CALL sp_process_subscription_renewals(CURRENT_DATE + 400, 3);

SELECT sub_status, COUNT(*) AS subscriptions
FROM member_subscription
GROUP BY sub_status
ORDER BY sub_status;
```

### B.2.12. Hai khung nhìn (View)

| View | Mục đích | Kỹ thuật |
|---|---|---|
| `vw_active_member_subscriptions` | Hợp đồng `Active` kèm số buổi còn lại, số ngày hiệu lực, nhãn "Đang hiệu lực / Sắp hết hạn / Đã quá hạn" | `JOIN` 3 bảng + `CASE` |
| `vw_trainer_schedule_overview` | Lịch dạy hợp nhất của HLV (lớp nhóm + PT 1-1) | `UNION ALL` hai nhánh cùng cấu trúc cột |

View không lưu dữ liệu, chỉ lưu truy vấn: luôn phản ánh dữ liệu mới nhất, và là **lớp trừu tượng + bảo mật** (HLV được `SELECT` view lịch tổng hợp dù không có quyền trực tiếp trên `user_account`, vì view chạy với quyền chủ sở hữu).

```sql
SELECT member_name, plan_name, current_remaining_pt_sessions, validity_status
FROM vw_active_member_subscriptions
ORDER BY days_until_expiration
LIMIT 5;
```

```sql
SELECT trainer_name, session_type, activity_title, start_time, status
FROM vw_trainer_schedule_overview
ORDER BY start_time DESC
LIMIT 5;
```

---

# PHẦN C – RÀNG BUỘC `EXCLUDE USING gist` VÀ `tsrange &&`

## C.1. Vấn đề cần giải quyết

"Một HLV (hoặc phòng, hoặc thiết bị) không được có hai khoảng thời gian chồng nhau." `UNIQUE` chỉ so sánh **bằng nhau**, `CHECK` chỉ nhìn **một dòng** → cả hai không diễn đạt được "chồng lấn giữa hai dòng". `EXCLUDE` là ràng buộc tổng quát hóa `UNIQUE`: *"không tồn tại hai dòng mà mọi cặp (cột, toán tử) đều đúng"*.

```postgresql
CONSTRAINT ex_class_trainer_no_overlap EXCLUDE USING gist (
    trainer_user_id WITH =,
    tsrange(start_time, end_time, '[)') WITH &&
)
```

Đọc là: **không tồn tại hai dòng có cùng `trainer_user_id` (`=`) mà khoảng thời gian giao nhau (`&&`)**.

## C.2. Từng thành phần

| Thành phần | Ý nghĩa |
|---|---|
| `tsrange(start_time, end_time, '[)')` | Tạo giá trị kiểu **khoảng** (`tsrange` = range of `timestamp`). `'[)'` = *đóng bên trái, mở bên phải*: gồm `start_time`, không gồm `end_time`. |
| `&&` | Toán tử "**overlap**" của kiểu range: đúng khi hai khoảng có ít nhất một điểm chung. |
| `USING gist` | Chỉ mục **GiST** hỗ trợ toán tử `&&`; chỉ mục B-tree thường không làm được. |
| `trainer_user_id WITH =` | Cột kiểu `INT` dùng toán tử `=` trong chỉ mục GiST – cần extension **`btree_gist`** (`CREATE EXTENSION btree_gist;` ở đầu `01_schema_ddl.sql`). |
| `WHERE (status NOT IN ('Cancelled','Late_Cancelled'))` (ở `pt_booking`, `equipment_reservation`) | **Ràng buộc một phần:** chỉ áp dụng cho dòng còn hiệu lực. Ca đã hủy không chiếm giờ nên được phép đặt lại. |
| Mã lỗi | Vi phạm trả SQLSTATE **`23P01`** (`exclusion_violation`). |

**Vì sao `'[)'` quan trọng?** Ca A 08:00–09:00 và ca B 09:00–10:00 *nối tiếp nhau*: nếu dùng `'[]'` (đóng cả hai đầu) thì 09:00 là điểm chung → bị báo trùng oan. Với `'[)'` không có điểm chung. Cùng tinh thần với điều kiện `start1 < end2 AND end1 > start2` (dấu `<`, `>` nghiêm ngặt) trong truy vấn 10.

```sql
SELECT
    tsrange(TIMESTAMP '2030-01-01 08:00', TIMESTAMP '2030-01-01 09:00', '[)')
    && tsrange(TIMESTAMP '2030-01-01 09:00', TIMESTAMP '2030-01-01 10:00', '[)') AS back_to_back,
    tsrange(TIMESTAMP '2030-01-01 08:00', TIMESTAMP '2030-01-01 09:00', '[)')
    && tsrange(TIMESTAMP '2030-01-01 08:30', TIMESTAMP '2030-01-01 09:30', '[)') AS overlapping,
    tsrange(TIMESTAMP '2030-01-01 08:00', TIMESTAMP '2030-01-01 09:00', '[]')
    && tsrange(TIMESTAMP '2030-01-01 09:00', TIMESTAMP '2030-01-01 10:00', '[]') AS back_to_back_closed;
```

Kết quả mong đợi: `back_to_back = f` (không trùng), `overlapping = t` (trùng), `back_to_back_closed = t` (nếu dùng `'[]'` sẽ báo trùng oan).

## C.3. Các ràng buộc `EXCLUDE` của nhóm

```sql
SELECT conrelid::regclass AS table_name, conname, pg_get_constraintdef(oid) AS definition
FROM pg_constraint
WHERE contype = 'x'
ORDER BY conrelid::regclass::TEXT, conname;
```

| Ràng buộc | Bảng | Quy tắc | Điều kiện `WHERE` |
|---|---|---|---|
| `ex_class_trainer_no_overlap` | `class_schedule` | BR-12: HLV không có hai lớp trùng giờ | – |
| `ex_class_room_no_overlap` | `class_schedule` | BR-15: phòng không có hai lớp trùng giờ | – |
| `ex_pt_trainer_no_overlap` | `pt_booking` | BR-12: HLV không có hai ca PT trùng giờ | `status NOT IN ('Cancelled','Late_Cancelled')` |
| `ex_pt_member_no_overlap` | `pt_booking` | BR-16: hội viên không có hai ca PT trùng giờ | cùng điều kiện |
| `ex_reservation_equipment_no_overlap` | `equipment_reservation` | BR-21: thiết bị không bị giữ trùng giờ | `status <> 'Cancelled'` |

**Vì sao ca PT không có `room_id`?** Ca PT diễn ra ở khu tập tự do (Gym Floor) nên BR-15 chỉ áp cho lớp nhóm; ràng buộc phòng nằm ở `class_schedule`.

**Vì sao `member_user_id` còn nằm trong `pt_booking` dù suy ra được từ hợp đồng?** Vì `EXCLUDE` chỉ tham chiếu **cột cùng bảng**: không có `member_user_id` trong `pt_booking` thì không khai báo được `ex_pt_member_no_overlap` (xem Phần E).

```sql
-- LỖI MONG ĐỢI: 23P01
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Một HLV dạy hai lớp trùng giờ ở hai phòng khác nhau: vi phạm ex_class_trainer_no_overlap.
INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
VALUES (5, (SELECT room_id FROM facilities_room WHERE status = 'Active' ORDER BY room_id LIMIT 1),
        'Lop A', CURRENT_DATE + INTERVAL '12 days 21 hours', CURRENT_DATE + INTERVAL '12 days 22 hours', 10);

INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity)
VALUES (5, (SELECT room_id FROM facilities_room WHERE status = 'Active' ORDER BY room_id OFFSET 1 LIMIT 1),
        'Lop B', CURRENT_DATE + INTERVAL '12 days 21 hours 30 minutes', CURRENT_DATE + INTERVAL '12 days 22 hours 30 minutes', 10);
```

---

# PHẦN D – PHÂN QUYỀN RBAC CẤP CSDL (`Phase 3/08_rbac_security.sql`)

## D.1. Hai lớp RBAC – đừng nhầm

| Lớp | Nằm ở đâu | Dùng để làm gì |
|---|---|---|
| **RBAC ứng dụng** (BR-22) | Các bảng `role`, `user_role`, `permission`, `role_permission` | Dữ liệu nghiệp vụ: người dùng X có vai trò gì, vai trò đó có những chức năng gì trên giao diện. |
| **RBAC cấp CSDL** (mục 5.2) | Role của PostgreSQL + `GRANT`/`REVOKE` | Cưỡng chế ở tầng CSDL: kể cả khi ứng dụng bị lỗi hay ai đó kết nối thẳng bằng `psql`, vẫn bị giới hạn đúng quyền. |

## D.2. Thiết kế

1. **Dọn sạch để chạy lại được (idempotent).** Role là đối tượng *toàn cụm* (cluster-wide), không bị xóa khi `DROP TABLE`; nên script `DROP OWNED BY` + `DROP ROLE` các role cũ trước khi tạo lại.
2. **Đặc quyền tối thiểu (Least Privilege).** `REVOKE ALL ON ALL TABLES/SEQUENCES IN SCHEMA public FROM PUBLIC` và `REVOKE CREATE ON SCHEMA public FROM PUBLIC`, sau đó chỉ cấp đúng thứ cần thiết.
3. **5 role nhóm `NOLOGIN`** (`gym_role_admin`, `gym_role_receptionist`, `gym_role_trainer`, `gym_role_technician`, `gym_role_member`) gom quyền; **5 tài khoản đăng nhập mẫu `gym_u_*`** (`LOGIN INHERIT`, mật khẩu `demo_2026`) thừa hưởng từ role nhóm tương ứng. Tách *role nhóm* khỏi *tài khoản* để thêm người mới chỉ cần `GRANT gym_role_trainer TO <người>`, không lặp lại danh sách quyền.
4. **Quyền mức cột** cho dữ liệu nhạy cảm: `password_hash` không ai được `SELECT` (Admin vẫn `INSERT/UPDATE` để đặt mật khẩu); lễ tân chỉ `UPDATE` các cột không gồm `password_hash`; HLV chỉ `SELECT (user_id, full_name, phone, emergency_contact)` của `user_account` và chỉ `UPDATE (status)` trên `pt_booking`/`class_enrollment`.
5. **BR-10 ở tầng quyền:** `billing_log` chỉ cấp `SELECT, INSERT` cho mọi role, **kể cả Admin** (`REVOKE UPDATE, DELETE ON billing_log FROM gym_role_admin`). Không role nào có `TRUNCATE` (sẽ vượt mọi giới hạn `DELETE`).
   **BR-10 ở tầng sở hữu:** mọi bảng, view, sequence, hàm, thủ tục thuộc role `NOLOGIN` `gym_owner` (không phải superuser, không là thành viên của role nào, và không `gym_u_*`/`gym_role_*` nào là thành viên của nó). Vì chủ sở hữu mới có quyền `ALTER`/`DROP` bảng, không tài khoản đăng nhập nào còn làm được điều đó (lỗi `42501`).
   **BR-10 ở tầng event trigger:** `evt_protect_billing_log` / `evt_protect_billing_log_drop` chặn cả superuser (xem B.2.5); lối thoát tường minh là `SET LOCAL app.allow_billing_maintenance = 'on'` hoặc `ALTER EVENT TRIGGER … DISABLE`.
6. **View chạy với quyền chủ sở hữu**, nên role được `SELECT` view không cần quyền trên bảng gốc.
7. **`SECURITY DEFINER` cho hàm trigger** (xem D.3).

**Ma trận quyền rút gọn** (S=SELECT, I=INSERT, U=UPDATE, D=DELETE; đầy đủ trong file `08_rbac_security.sql`):

| Bảng | admin | receptionist | trainer | technician | member |
|---|---|---|---|---|---|
| `user_account` | S\*, I, U, D | S\*, I, U\* | S (4 cột) | – | – |
| `member_subscription` | SIUD | S, I, U | S (7 cột, không giá) | – | – |
| `billing_log` | **S, I** | **S, I** | – | – | – |
| `pt_booking` | SIUD | S, I, U | S, U(`status`) | – | – |
| `class_schedule` | SIUD | S, I, U | S | – | S |
| `equipment`, `maintenance_log` | SIUD | – | – | S, I, U | – |
| `membership_plan`, `facilities_room` | SIUD | S | S | S (phòng) / U(`status`) | S |

(\* = SELECT/UPDATE mức cột, không gồm `password_hash`.)

```sql
SELECT r.rolname AS login_role, g.rolname AS member_of_group
FROM pg_auth_members m
JOIN pg_roles r ON r.oid = m.member
JOIN pg_roles g ON g.oid = m.roleid
WHERE r.rolname LIKE 'gym\_u\_%'
ORDER BY r.rolname;
```

```sql
SELECT
    has_table_privilege('gym_role_admin', 'billing_log', 'INSERT')  AS admin_insert_billing,
    has_table_privilege('gym_role_admin', 'billing_log', 'UPDATE')  AS admin_update_billing,
    has_table_privilege('gym_role_admin', 'billing_log', 'DELETE')  AS admin_delete_billing,
    has_column_privilege('gym_role_admin', 'user_account', 'password_hash', 'SELECT') AS admin_read_password_hash;
```

Kết quả mong đợi: `t, f, f, f`.

```sql
-- LỖI MONG ĐỢI: 42501
SET LOCAL ROLE gym_u_member;
SELECT * FROM billing_log LIMIT 1;
```

```sql
-- LỖI MONG ĐỢI: 42501
SET LOCAL ROLE gym_u_reception;
SELECT password_hash FROM user_account LIMIT 1;
```

```sql
-- LỖI MONG ĐỢI: 42501
SET LOCAL ROLE gym_u_admin;
DELETE FROM billing_log;
```

```sql
-- LỖI MONG ĐỢI: 42501
SET LOCAL ROLE gym_u_tech;
UPDATE membership_plan SET price = price * 2;
```

## D.3. `SECURITY DEFINER` cho hàm trigger – vì sao?

Mặc định hàm chạy với quyền **người gọi** (`SECURITY INVOKER`). Hai ví dụ thực tế trong hệ thống:

- HLV (`gym_role_trainer`) đổi `pt_booking.status = 'Completed'` → kích hoạt `trg_update_remaining_pt_sessions` → hàm này `SELECT … FOR UPDATE` và `UPDATE member_subscription`, nhưng HLV **không có quyền ghi** bảng này.
- Lễ tân thêm `class_enrollment` → trigger đồng bộ `UPDATE class_schedule.current_enrolled` – cột mà lễ tân chỉ có quyền ở mức dòng khác.

Nếu không có `SECURITY DEFINER`, các thao tác **hợp lệ** này bị từ chối (`42501`). Hiện cả **23 hàm trigger** của hệ thống đều là `SECURITY DEFINER` (kiểm chứng bằng truy vấn `pg_proc` bên dưới). Giải pháp: hàm trigger chạy bằng quyền **chủ sở hữu hàm** để role gọi giữ quyền trực tiếp ở mức tối thiểu. Kèm theo `SET search_path = public, pg_temp` để chống tấn công chiếm quyền qua `search_path` (kẻ tấn công tạo đối tượng trùng tên trong một schema do mình kiểm soát để hàm đặc quyền gọi nhầm); `pg_temp` đặt **cuối** để schema tạm không che khuất đối tượng thật.

```sql
SELECT proname, prosecdef AS is_security_definer, proconfig AS fixed_settings
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND prosecdef
ORDER BY proname;
```

```sql
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- HLV hoàn thành ca PT: được phép nhờ trigger SECURITY DEFINER, dù không có quyền ghi member_subscription.
INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 3), CURRENT_DATE + INTERVAL '3 days 21 hours', CURRENT_DATE + INTERVAL '3 days 22 hours', 'Scheduled');

SET LOCAL ROLE gym_u_trainer;

UPDATE pt_booking
SET status = 'Completed'
WHERE booking_id = (SELECT MAX(booking_id) FROM pt_booking WHERE subscription_id = 8);

RESET ROLE;

SELECT remaining_sessions FROM member_subscription WHERE subscription_id = 8;
```

```sql
-- LỖI MONG ĐỢI: 42501
SET app.current_user_id = '3';  -- BR-23: người thực hiện (lễ tân mẫu)
-- Đối chứng: bỏ SECURITY DEFINER thì thao tác hợp lệ của HLV bị từ chối.
INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
VALUES (18, 5, 8, (CURRENT_DATE + 3), CURRENT_DATE + INTERVAL '3 days 21 hours', CURRENT_DATE + INTERVAL '3 days 22 hours', 'Scheduled');

ALTER FUNCTION trg_fn_update_remaining_pt_sessions() SECURITY INVOKER;

SET LOCAL ROLE gym_u_trainer;

UPDATE pt_booking
SET status = 'Completed'
WHERE booking_id = (SELECT MAX(booking_id) FROM pt_booking WHERE subscription_id = 8);
```

---

# PHẦN E – CÂU HỎI VỀ CHUẨN HÓA (Normalization – 15%)

> Chứng minh đầy đủ nằm ở `Phase 2/database_design/3_normalization_verification.md`. Dưới đây là **câu trả lời mẫu ngắn gọn** để nói miệng. Nếu file chuẩn hóa được cập nhật, hãy đối chiếu lại kết luận cuối cùng trước khi thi.

**Ôn nhanh định nghĩa (nói được trong 20 giây)**

- **1NF:** thuộc tính nguyên tử, không nhóm lặp.
- **2NF:** đạt 1NF và mọi thuộc tính không khóa phụ thuộc **đầy đủ** vào *toàn bộ* khóa (chỉ có ý nghĩa khi khóa gồm ≥ 2 thuộc tính).
- **3NF:** đạt 2NF và không có thuộc tính không khóa nào phụ thuộc **bắc cầu** vào khóa (`khóa → X → A`, với `X` không phải khóa).
- **BCNF:** với mọi phụ thuộc hàm không tầm thường `X → A` thì `X` phải là **siêu khóa**.

### E.1. Vì sao `pt_booking` chỉ đạt 2NF (không đạt 3NF/BCNF)?

**Trả lời mẫu.** Khóa dự tuyển duy nhất là `{booking_id}` (một thuộc tính) nên **không thể có phụ thuộc bộ phận → đạt 2NF**. Nhưng bảng chứa hai phụ thuộc hàm bắc cầu:

- `booking_id → subscription_id → member_user_id`: mỗi hợp đồng thuộc đúng một hội viên (`subscription_id → member_user_id` được kéo từ `member_subscription`), mà `subscription_id` không phải khóa của `pt_booking`;
- `booking_id → start_time → booking_date`: `booking_date` luôn bằng `start_time::DATE`.

Hai phụ thuộc này vi phạm 3NF (và BCNF). **Đây là phi chuẩn hóa có kiểm soát**, không phải sơ suất:

- `member_user_id` được **giữ lại** vì BR-16 cần `EXCLUDE ex_pt_member_no_overlap`, mà `EXCLUDE` chỉ tham chiếu cột cùng bảng. Mâu thuẫn dữ liệu bị chặn bằng **khóa ngoại ghép** `FOREIGN KEY (subscription_id, member_user_id) REFERENCES member_subscription (subscription_id, member_user_id)` (nhờ `UNIQUE (subscription_id, member_user_id)` ở bảng cha), nên cặp này **không thể lệch** khỏi hợp đồng.
- `booking_date` được ràng buộc bằng `CHECK (booking_date = start_time::DATE)` (`chk_pt_booking_date`) nên không thể mâu thuẫn với `start_time`. Phương án triệt để hơn là xóa cột hoặc dùng cột sinh (`GENERATED ALWAYS AS (start_time::DATE) STORED`).

> Câu hỏi bẫy: *"Vậy sao không tách bảng cho đủ BCNF?"* → Tách `member_user_id` ra sẽ làm **mất khả năng khai báo `EXCLUDE` theo hội viên**, buộc phải chuyển BR-16 sang trigger (chậm hơn, dễ sai khi đồng thời). Nhóm đánh đổi có ý thức: chấp nhận dư thừa lưu trữ nhưng loại bỏ khả năng dữ liệu mâu thuẫn.

### E.2. Vì sao `member_subscription.actual_price` **không** là phụ thuộc bắc cầu qua `plan_id`?

**Trả lời mẫu.** Phụ thuộc bắc cầu chỉ tồn tại nếu `plan_id → actual_price` **thật sự đúng** (cùng gói thì luôn cùng giá). Điều đó **sai** về nghiệp vụ: `actual_price` là **giá chốt tại thời điểm ký hợp đồng** (ảnh chụp lịch sử), có thể khác `membership_plan.price` do khuyến mãi hoặc đổi giá về sau. Hai hợp đồng cùng `plan_id` có thể có `actual_price` khác nhau, nên `plan_id` **không xác định** `actual_price`. Vì vậy không có chuỗi `subscription_id → plan_id → actual_price`; `actual_price` phụ thuộc trực tiếp vào `subscription_id`. Tương tự `plan_id ↛ remaining_sessions` (số buổi còn lại giảm dần theo từng hợp đồng) và `{plan_id, start_time} ↛ end_time` (hợp đồng có thể bị gia hạn/bảo lưu thủ công). Nếu chuẩn hóa máy móc bỏ `actual_price` để tra `membership_plan.price` thì doanh thu lịch sử sẽ **đổi theo** mỗi lần chỉnh bảng giá – sai nghiệp vụ.

### E.3. `UNIQUE (subscription_id, member_user_id)` trên `member_subscription` có phải khóa dự tuyển không?

**Không.** Nó là một **siêu khóa** (chứa khóa chính `subscription_id`), không tối thiểu nên không phải khóa dự tuyển. Ràng buộc này chỉ tồn tại để làm **đích tham chiếu** cho khóa ngoại ghép từ `pt_booking`; không ảnh hưởng đến kết luận BCNF của `member_subscription` (mọi FD đều có vế trái `subscription_id`, là khóa).

### E.4. `class_schedule.current_enrolled` là dữ liệu dẫn xuất – có vi phạm chuẩn hóa không?

**Trả lời mẫu.** Về hình thức, các dạng chuẩn xét phụ thuộc hàm giữa các thuộc tính; `current_enrolled = COUNT(*) FROM class_enrollment …` là phụ thuộc vào **dữ liệu của bảng khác** nên không tạo FD trong bảng `class_schedule` và không vi phạm 1NF–BCNF. Tuy nhiên đây là **dữ liệu dư thừa (dẫn xuất)** nên có rủi ro lệch; nhóm kiểm soát bằng trigger `trg_sync_class_enrollment_count` (luôn đếm lại bằng `COUNT(*)`) và `CHECK (current_enrolled <= max_capacity)`. Lợi ích: kiểm tra sức chứa và hiển thị tỷ lệ lấp đầy mà không cần `JOIN` + đếm mỗi lần.

### E.5. `staff_profile`: `job_title → department` có phải phụ thuộc bắc cầu?

Chỉ khi nghiệp vụ quy định mỗi chức danh thuộc đúng một phòng ban. Theo quy ước của nhóm, cùng một chức danh có thể ở nhiều phòng ban nên `job_title ↛ department`, bảng đạt BCNF. Nếu quy ước đổi, phải tách `JOB_TITLE(job_title, department)` để đạt 3NF. Điểm cần nhấn: **chuẩn hóa phụ thuộc vào ngữ nghĩa nghiệp vụ**, không chỉ nhìn dữ liệu mẫu.

### E.6. Vì sao tách `user_account` với `member_profile` / `trainer_profile` / `staff_profile` (khóa chính dùng chung)?

Ánh xạ **chuyên biệt hóa (ISA / supertype–subtype)** theo kiểu "bảng riêng cho từng lớp con, khóa chính của lớp con = khóa ngoại tới lớp cha" (*shared primary key*, quan hệ 1:1). Lợi ích: tránh cột `NULL` hàng loạt (HLV không có `health_notes`, hội viên không có `specialization`), thêm thuộc tính riêng cho từng vai trò mà không đụng bảng chung, và khóa ngoại có thể nhắm đúng bảng con (ví dụ `pt_booking.trainer_user_id → trainer_profile`, nên không thể gán ca PT cho người không phải HLV – kiểm chứng ở test constraint `TC-12`-kiểu với khóa ngoại).

### E.7. Quan hệ N:M được xử lý thế nào?

Bằng **bảng liên kết** (associative table) có khóa chính ghép: `user_role (user_id, role_id)`, `role_permission (role_id, permission_id)`; riêng `class_enrollment` là bảng liên kết *có thuộc tính riêng* (`enrollment_date`, `status`) giữa hợp đồng và lớp, có khóa thay thế `enrollment_id` + `UNIQUE (subscription_id, class_id)` để một hợp đồng không đăng ký một lớp hai lần.

---

# PHẦN F – 15 CÂU HỎI LUYỆN TẬP (kèm đáp án)

> Hãy tự làm trước khi đọc đáp án. Các câu có SQL đều đã chạy thử.

### Câu 1 – (Viết truy vấn) HLV nào có nhiều ca PT bị hội viên bỏ tập (`No_Show`) nhất?

```sql
SELECT
    t.user_id AS trainer_id,
    t.full_name AS trainer_name,
    COUNT(*) AS no_show_count
FROM
    pt_booking pb
JOIN
    user_account t ON pb.trainer_user_id = t.user_id
WHERE
    pb.status = 'No_Show'
GROUP BY
    t.user_id,
    t.full_name
ORDER BY
    no_show_count DESC,
    t.user_id
LIMIT 1;
```

*Lời giải thích:* lọc ở `WHERE` (trước khi gom nhóm), `GROUP BY` HLV, sắp giảm dần và lấy dòng đầu. Nếu đề hỏi "tất cả HLV đồng hạng nhất" thì dùng `FETCH FIRST 1 ROWS WITH TIES` (bỏ phá hòa `t.user_id`) hoặc `DENSE_RANK()`.

### Câu 2 – Hội viên nào đã từng có **nhiều hơn một** hợp đồng (tức là đã gia hạn/đăng ký lại)?

```sql
SELECT
    u.user_id AS member_id,
    u.full_name AS member_name,
    COUNT(*) AS total_subscriptions
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
GROUP BY
    u.user_id,
    u.full_name
HAVING
    COUNT(*) > 1
ORDER BY
    total_subscriptions DESC,
    member_id;
```

*Lời giải thích:* điều kiện trên kết quả tổng hợp bắt buộc ở `HAVING`. (BR-05 chỉ giới hạn **một hợp đồng `Active` tại một thời điểm**, không giới hạn tổng số hợp đồng theo thời gian.)

### Câu 3 – Doanh thu theo từng phương thức thanh toán và tỷ trọng % trên tổng doanh thu.

```sql
SELECT
    bl.payment_method,
    SUM(bl.amount) AS revenue,
    ROUND(100.0 * SUM(bl.amount) / SUM(SUM(bl.amount)) OVER (), 2) AS pct_of_total
FROM
    billing_log bl
WHERE
    bl.payment_status = 'Completed'
GROUP BY
    bl.payment_method
ORDER BY
    revenue DESC;
```

*Lời giải thích:* `SUM(SUM(bl.amount)) OVER ()` – hàm tổng hợp bên trong là tổng theo nhóm, window bên ngoài cộng tất cả các nhóm (cửa sổ rỗng = toàn bảng kết quả). Window function chạy **sau** `GROUP BY` nên bọc được hàm tổng hợp.

### Câu 4 – (Lý thuyết) Khác nhau giữa `WHERE` và `HAVING`? Vì sao không dùng được alias của `SELECT` trong `WHERE`, và vì sao không lọc được theo window function trong cùng `SELECT`?

**Đáp án.** Thứ tự thực thi logic: `FROM/JOIN` → `WHERE` → `GROUP BY` → `HAVING` → *window function* → `SELECT` (tính biểu thức, đặt alias) → `DISTINCT` → `ORDER BY` → `LIMIT`. `WHERE` lọc **từng dòng trước** khi gom nhóm nên không dùng được hàm tổng hợp; `HAVING` lọc **nhóm** sau khi gom nhóm. Alias được đặt ở bước `SELECT` – sau `WHERE` – nên `WHERE` chưa biết alias (nhưng `ORDER BY` dùng được). Window function tính sau `WHERE/GROUP BY/HAVING` nên muốn lọc theo hạng phải bọc trong CTE/subquery rồi lọc ở truy vấn ngoài (như biến thể 9a).

### Câu 5 – HLV nào **không có** lớp nhóm hay ca PT nào trong 7 ngày tới?

```sql
SELECT
    u.user_id AS trainer_id,
    u.full_name AS trainer_name
FROM
    trainer_profile tp
JOIN
    user_account u ON tp.user_id = u.user_id
WHERE
    NOT EXISTS (
        SELECT 1
        FROM class_schedule cs
        WHERE cs.trainer_user_id = tp.user_id
          AND cs.start_time >= CURRENT_TIMESTAMP
          AND cs.start_time <  CURRENT_TIMESTAMP + INTERVAL '7 days'
    )
    AND NOT EXISTS (
        SELECT 1
        FROM pt_booking pb
        WHERE pb.trainer_user_id = tp.user_id
          AND pb.status = 'Scheduled'
          AND pb.start_time >= CURRENT_TIMESTAMP
          AND pb.start_time <  CURRENT_TIMESTAMP + INTERVAL '7 days'
    )
ORDER BY
    u.user_id;
```

*Lời giải thích:* anti-join bằng `NOT EXISTS` (an toàn với `NULL`, khác với `NOT IN`). Hai điều kiện `NOT EXISTS` nối bằng `AND`.

### Câu 6 – Hợp đồng PT còn **ít nhất 1 buổi** nhưng sẽ hết hạn trong 14 ngày tới (cần nhắc hội viên dùng gấp).

```sql
SELECT
    u.full_name AS member_name,
    mp.plan_name,
    ms.remaining_sessions,
    ms.end_time AS expires_at
FROM
    member_subscription ms
JOIN
    user_account u ON ms.member_user_id = u.user_id
JOIN
    membership_plan mp ON ms.plan_id = mp.plan_id
WHERE
    ms.sub_status = 'Active'
    AND ms.remaining_sessions > 0
    AND ms.end_time BETWEEN CURRENT_TIMESTAMP AND CURRENT_TIMESTAMP + INTERVAL '14 days'
ORDER BY
    ms.end_time;
```

### Câu 7 – (Lý thuyết) `tsrange(a, b, '[)')` nghĩa là gì và vì sao nhóm chọn `[)`? Hai ca 08:00–09:00 và 09:00–10:00 có bị coi là trùng không?

**Đáp án.** `'[)'` = đóng bên trái, mở bên phải: gồm `a`, không gồm `b`. Hai ca nối tiếp **không trùng** vì điểm 09:00 thuộc ca sau mà không thuộc ca trước, nên `&&` trả `FALSE`. Nếu dùng `'[]'` thì 09:00 thuộc cả hai và bị báo trùng oan. Đây cũng là lý do điều kiện chồng lấn viết bằng `<`/`>` nghiêm ngặt: `s1 < e2 AND e1 > s2`.

### Câu 8 – (Lý thuyết) Vì sao nhóm vừa `REVOKE UPDATE, DELETE` vừa dùng trigger để bảo vệ `billing_log`? Chỉ một lớp có đủ không?

**Đáp án.** Không đủ, nên nhóm dùng **bốn lớp**. `GRANT/REVOKE` **không ràng buộc chủ sở hữu bảng và superuser**; trigger chặn mọi tài khoản nhưng chủ sở hữu vẫn có thể `DISABLE TRIGGER`. Do đó nhóm chuyển quyền sở hữu mọi đối tượng cho role `NOLOGIN` `gym_owner` (không ai đăng nhập được bằng role này) và thêm **event trigger** `evt_protect_billing_log` chặn `ALTER`/`DROP` `billing_log`, trigger và hàm bất biến, kể cả với superuser. Chỉ có trigger thì role ứng dụng vẫn thấy lệnh `UPDATE`/`DELETE` và bị từ chối muộn; `REVOKE` từ chối sớm ở tầng quyền (`42501`). Trigger còn cho phép logic tinh vi mà `GRANT` không làm được: cho phép đúng một chuyển đổi `Completed → Refunded`. **Giới hạn cố hữu:** superuser là gốc tin cậy của mọi DBMS và vẫn bảo trì được có chủ đích bằng `ALTER EVENT TRIGGER … DISABLE` hoặc `SET LOCAL app.allow_billing_maintenance = 'on'`; thao tác này tường minh, không xảy ra vô tình.

### Câu 9 – Thiết bị nào **chưa từng** có phiếu bảo trì?

```sql
SELECT
    e.equipment_id,
    e.equipment_name,
    e.status
FROM
    equipment e
LEFT JOIN
    maintenance_log ml ON ml.equipment_id = e.equipment_id
WHERE
    ml.maintenance_id IS NULL
ORDER BY
    e.equipment_id
LIMIT 20;
```

*Lời giải thích:* `LEFT JOIN … IS NULL` (anti-join) trên **khóa chính** của bảng phải. Có thể viết tương đương bằng `NOT EXISTS`.

### Câu 10 – (Sửa dữ liệu) Tăng giá niêm yết 5 % cho các gói có PT (`total_sessions > 0`). Hợp đồng hiện hành có bị ảnh hưởng không?

```sql
UPDATE membership_plan
SET price = ROUND(price * 1.05, 2)
WHERE total_sessions > 0
RETURNING plan_id, plan_name, price;

SELECT COUNT(*) AS subscriptions_with_old_price
FROM member_subscription ms
JOIN membership_plan mp ON mp.plan_id = ms.plan_id
WHERE mp.total_sessions > 0
  AND ms.actual_price <> mp.price;
```

*Lời giải thích:* **Không ảnh hưởng** hợp đồng cũ, vì `actual_price` là giá chốt lúc ký (xem E.2); truy vấn thứ hai đếm các hợp đồng có giá khác bảng giá mới. `RETURNING` trả luôn các dòng vừa sửa. Chạy trong giao dịch có thể `ROLLBACK` nếu nhầm.

### Câu 11 – (Thêm dữ liệu) Thêm một hội viên mới cùng hồ sơ trong **một câu lệnh**.

```sql
WITH new_user AS (
    INSERT INTO user_account (full_name, email, phone, dob, password_hash)
    VALUES ('Nguyen Van Moi', 'nguyen.moi.p4@example.com', '0999000003', DATE '1999-05-20', 'x')
    RETURNING user_id
)
INSERT INTO member_profile (user_id, health_notes)
SELECT user_id, 'Khong co tien su benh'
FROM new_user
RETURNING user_id, health_notes;
```

*Lời giải thích:* **CTE ghi dữ liệu** (`WITH … INSERT … RETURNING`) lấy `user_id` mà `SERIAL` vừa sinh để chèn tiếp vào bảng con, đảm bảo nguyên tử. Lưu ý: nếu `dob` làm người này dưới 12 tuổi, trigger `trg_check_member_dob` (BR-03) sẽ hủy toàn bộ.

### Câu 12 – (Lý thuyết) `pg_advisory_xact_lock` dùng để làm gì trong các trigger chống trùng lịch?

**Đáp án.** Kiểm tra "chưa có lịch trùng" rồi `INSERT` là hai bước không nguyên tử. Dưới mức cô lập `READ COMMITTED`, hai giao dịch đồng thời cùng thấy "chưa trùng" rồi cùng ghi → trùng lịch (*race condition*). Khóa tư vấn (*advisory lock*) theo khóa nghiệp vụ (HLV / hội viên / hợp đồng) buộc các giao dịch cùng đối tượng chạy **tuần tự**; giao dịch sau đợi giao dịch trước `COMMIT` rồi mới kiểm tra, nên thấy dữ liệu đã chốt. Khóa tự nhả khi kết thúc giao dịch (`_xact_`). Thứ tự giành khóa cố định (HLV → hội viên → hợp đồng) để **tránh deadlock**. (Với trùng giữa hai ca PT cùng bảng, `EXCLUDE` đã xử lý đồng thời ở mức chỉ mục nên không cần khóa.)

### Câu 13 – (Lý thuyết) Vì sao gia hạn tự động viết thành thủ tục `sp_process_subscription_renewals` thay vì trigger? Gọi hai lần liên tiếp thì sao?

**Đáp án.** Trigger chỉ phản ứng với **sự kiện ghi dữ liệu**; "đến ngày hết hạn" là sự kiện **thời gian** không ai ghi gì, và PostgreSQL không có bộ lập lịch tích hợp – nên viết thành `PROCEDURE` để bộ lập lịch ngoài gọi mỗi ngày (demo: container `scheduler`; production: `pg_cron`/cron). Tham số `p_as_of` cho phép giả lập ngày khi kiểm thử. Thủ tục **idempotent**: bước 2 chỉ phát hành hóa đơn khi chưa có hóa đơn `Pending/Completed` của chu kỳ đó (`NOT EXISTS`, và còn được chỉ mục duy nhất một phần chặn), bước 1 và 3 chỉ chọn hợp đồng còn `Active` – gọi lại không sinh thêm gì.

### Câu 14 – (Window) Với mỗi hội viên, khoảng cách (số ngày) giữa hai lần thanh toán thành công liên tiếp.

```sql
SELECT
    u.full_name AS member_name,
    bl.payment_date,
    bl.amount,
    bl.payment_date - LAG(bl.payment_date) OVER (
        PARTITION BY ms.member_user_id
        ORDER BY bl.payment_date
    ) AS days_since_previous_payment
FROM
    billing_log bl
JOIN
    member_subscription ms ON bl.subscription_id = ms.subscription_id
JOIN
    user_account u ON ms.member_user_id = u.user_id
WHERE
    bl.payment_status = 'Completed'
ORDER BY
    u.full_name,
    bl.payment_date;
```

*Lời giải thích:* `LAG(cột) OVER (PARTITION BY … ORDER BY …)` lấy giá trị của dòng **liền trước** trong cùng phân vùng; dòng đầu tiên của mỗi hội viên có giá trị `NULL`. Hiệu hai `DATE` cho số nguyên (số ngày).

### Câu 15 – Chỉ mục nào hỗ trợ truy vấn 3 (hợp đồng sắp hết hạn)? Kiểm tra bằng `EXPLAIN`.

```sql
EXPLAIN
SELECT ms.subscription_id, ms.end_time
FROM member_subscription ms
WHERE ms.sub_status = 'Active'
  AND ms.end_time >= CURRENT_TIMESTAMP
  AND ms.end_time <= CURRENT_TIMESTAMP + INTERVAL '7 days';
```

**Đáp án.** Các chỉ mục `idx_member_subscription_status (sub_status)` và `idx_member_subscription_dates (start_time, end_time)` có thể được cân nhắc; nhưng chỉ mục ghép `(start_time, end_time)` có cột đầu là `start_time` nên **không tối ưu** cho điều kiện chỉ theo `end_time`. Với bảng nhỏ (vài chục dòng), trình tối ưu thường chọn **Seq Scan** vì rẻ hơn – không phải lỗi. Khi dữ liệu lớn (kiểm thử hiệu năng `06_performance_test_cases.sql`), có thể đề xuất chỉ mục một phần `CREATE INDEX … ON member_subscription (end_time) WHERE sub_status = 'Active'`. Đọc `EXPLAIN` theo thứ tự từ **node trong cùng ra ngoài**, chú ý loại quét (Seq Scan / Index Scan / Bitmap Heap Scan), `cost`, `rows` ước lượng; thêm `ANALYZE` để có thời gian thực.

---

# PHẦN G – CHECKLIST TRƯỚC KHI VÀO PHÒNG BẢO VỆ

- [ ] Đã chạy `docker compose up --build` thành công, truy cập được `http://localhost:8501`.
- [ ] Mở sẵn `psql` (`docker exec -it fitzone_postgres_db psql -U gym_admin -d gym_management`) và một tab soạn thảo có sẵn file `Phase 3/03_complex_queries.sql`.
- [ ] Mỗi thành viên **tự gõ lại không nhìn tài liệu** ít nhất truy vấn 2, 8, 9, 10 và một biến thể của mỗi truy vấn.
- [ ] Giải thích được bằng lời: vì sao `UNION ALL`; `LEFT JOIN … IS NULL`; `DENSE_RANK` khác `RANK`; điều kiện chồng khoảng `s1 < e2 AND e1 > s2`.
- [ ] Thuộc câu trả lời mẫu cho 3 câu hỏi "khung": (1) khi nào dùng trigger thay vì `CHECK`; (2) vì sao `SECURITY DEFINER`; (3) vì sao `pt_booking` chỉ đạt 2NF.
- [ ] Nhớ rằng số liệu mẫu thay đổi theo ngày: **đọc hình dạng kết quả, không đọc cứng con số**.

## Điểm yếu đã biết – nên chủ động nêu để thể hiện sự hiểu sâu

1. **Truy vấn 10:** kết quả hợp lệ là **0 dòng** vì các ràng buộc đã chặn trùng lịch từ lúc ghi (đây là truy vấn kiểm toán). Bản đầu so sánh `event_id` trần nên có thể bỏ sót cặp có `class_id` = `booking_id`; nhóm đã sửa thành so sánh bộ `(event_type, event_id)` (biến thể 10c).
2. **Truy vấn 2:** giờ lớp nhóm được tính cho mọi lớp có `start_time` trong tháng (kể cả lớp chưa diễn ra) vì `class_schedule` không có cột trạng thái; ca PT thì chỉ tính `Completed`.
3. **Truy vấn 8:** đếm theo **hợp đồng** (không phải số hội viên) và tuổi tính theo ngày chạy.
4. **Truy vấn 7:** "chưa từng đặt lịch" tính cả ca đã hủy là đã đặt (xem biến thể 7b).
5. **`pt_booking` không đạt 3NF** do phi chuẩn hóa có kiểm soát (xem E.1).
6. **Mật khẩu tài khoản demo `demo_2026`** chỉ dùng trình diễn, phải đổi khi triển khai thật.
7. **Superuser là gốc tin cậy:** BR-10 chặn được cả superuser ở mức thông thường, nhưng superuser vẫn tắt được event trigger một cách tường minh; đây là giới hạn cố hữu của mọi DBMS, không phải lỗ hổng thiết kế.
8. **BR-22:** bảng `role_permission` (ma trận quyền ứng dụng) và các lệnh `GRANT` vẫn duy trì thủ công ở hai nơi, nhưng mọi sai lệch được phát hiện tự động bởi test SY-01..SY-05 (chạy lại `09_rbac_test_cases.sql` sau khi đổi một trong hai nơi).
9. **BR-23:** mọi chương trình ghi dữ liệu phải đặt `app.current_user_id`; thiếu thì CSDL từ chối (theo thiết kế).
