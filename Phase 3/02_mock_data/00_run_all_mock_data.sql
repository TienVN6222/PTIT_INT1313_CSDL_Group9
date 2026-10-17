-- Chạy bằng psql từ thư mục Gym_Mock_Data_Split, sau khi schema đã được tạo.
-- Ví dụ: psql -U postgres -d ten_database -f 00_run_all_mock_data.sql
\i 01_reference_data.sql
\i 02_users_and_profiles.sql
\i 03_equipment.sql
\i 04_subscriptions_and_billing.sql
\i 05_classes_and_enrollments.sql
\i 06_pt_bookings.sql
\i 07_equipment_reservations.sql
\i 08_maintenance_logs.sql
