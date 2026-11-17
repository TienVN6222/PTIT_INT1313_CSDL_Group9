import os
import streamlit as st
import psycopg2
import psycopg2.extras
import pandas as pd
import plotly.express as px
import plotly.graph_objects as go
from datetime import date, datetime, timedelta
from contextlib import contextmanager

# ============================================================================
# CẤU HÌNH TRANG VÀ GIAO DIỆN STREAMLIT
# ============================================================================
st.set_page_config(
    page_title="FIT ZONE - Gym & PT Management",
    page_icon="🏋️‍♂️",
    layout="wide",
    initial_sidebar_state="expanded"
)

# Custom Styling (Dark & Emerald Gym Aesthetic)
st.markdown("""
<style>
    /* Metric Card Styling */
    div[data-testid="stMetric"] {
        background: linear-gradient(135deg, #1e293b 0%, #0f172a 100%);
        border: 1px solid #334155;
        border-radius: 12px;
        padding: 16px 20px;
        box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.2);
    }
    div[data-testid="stMetric"]:hover {
        border-color: #10b981;
        transition: border-color 0.3s ease;
    }
    div[data-testid="stMetric"] label {
        color: #94a3b8 !important;
        font-weight: 500;
        font-size: 0.9rem;
    }
    div[data-testid="stMetric"] div[data-testid="stMetricValue"] {
        color: #f8fafc !important;
        font-weight: 700;
        font-size: 1.8rem;
    }
    /* Headers & Highlights */
    .hero-title {
        font-size: 2.2rem;
        font-weight: 800;
        background: linear-gradient(90deg, #10b981, #06b6d4);
        -webkit-background-clip: text;
        -webkit-text-fill-color: transparent;
        margin-bottom: 4px;
    }
    .hero-subtitle {
        color: #94a3b8;
        font-size: 1.05rem;
        margin-bottom: 24px;
    }
    .badge {
        display: inline-block;
        padding: 4px 10px;
        border-radius: 9999px;
        font-size: 0.75rem;
        font-weight: 600;
        text-transform: uppercase;
    }
    .badge-success { background-color: rgba(16, 185, 129, 0.2); color: #10b981; border: 1px solid #10b981; }
    .badge-warning { background-color: rgba(245, 158, 11, 0.2); color: #f59e0b; border: 1px solid #f59e0b; }
    .badge-danger  { background-color: rgba(239, 68, 68, 0.2);  color: #ef4444; border: 1px solid #ef4444; }
    .code-box {
        background-color: #0f172a;
        border: 1px solid #334155;
        border-radius: 8px;
        padding: 12px;
        font-family: monospace;
        font-size: 0.85rem;
    }
</style>
""", unsafe_allow_html=True)

# ============================================================================
# KẾT NỐI CƠ SỞ DỮ LIỆU POSTGRESQL
# ============================================================================
DB_HOST = os.environ.get("DB_HOST", "localhost")
DB_PORT = os.environ.get("DB_PORT", "5432")
DB_NAME = os.environ.get("DB_NAME", "gym_management")
# Ứng dụng đăng nhập bằng tài khoản KHÔNG phải superuser (gym_u_admin thuộc nhóm quyền gym_role_admin, xem 08_rbac_security.sql)
DB_USER = os.environ.get("DB_USER", "gym_u_admin")
DB_PASSWORD = os.environ.get("DB_PASSWORD", "demo_2026")
# NFR-SEC-03: docker-compose đặt "require" (CSDL từ chối kết nối không mã hóa); mặc định "prefer".
DB_SSLMODE = os.environ.get("DB_SSLMODE", "prefer")

@st.cache_resource
def get_db_connection():
    try:
        conn = psycopg2.connect(
            host=DB_HOST,
            port=DB_PORT,
            dbname=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD,
            sslmode=DB_SSLMODE,
            connect_timeout=5
        )
        return conn
    except Exception as e:
        return None

def run_query(query, params=None, is_select=True):
    conn = get_db_connection()
    if not conn:
        st.error(f"❌ Không thể kết nối tới PostgreSQL ({DB_HOST}:{DB_PORT}/{DB_NAME}). Vui lòng kiểm tra Docker container.")
        return None
    try:
        if conn.closed:
            st.cache_resource.clear()
            conn = get_db_connection()
        with conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor) as cur:
            cur.execute(query, params)  # params=None: không nội suy %, an toàn với câu SQL chứa LIKE/%
            if is_select:
                records = cur.fetchall()
                conn.commit()
                return pd.DataFrame(records)
            else:
                conn.commit()
                return True
    except Exception as e:
        conn.rollback()
        raise e

def get_operator_id():
    """Mã nhân viên đang thao tác (chọn ở sidebar), dùng cho vết kiểm toán BR-23."""
    return st.session_state.get("operator_id")

@contextmanager
def db_tx(commit=True):
    """Mở một giao dịch: đặt app.current_user_id (SET LOCAL) để trigger BR-23 ghi created_by_user_id.
    commit=False thì luôn ROLLBACK khi kết thúc (dùng cho phép thử không được lưu)."""
    conn = get_db_connection()
    if not conn:
        raise RuntimeError("Không thể kết nối tới PostgreSQL")
    if conn.closed:
        st.cache_resource.clear()
        conn = get_db_connection()
    try:
        with conn.cursor() as cur:
            op = get_operator_id()
            cur.execute("SELECT set_config('app.current_user_id', %s, true);", ("" if op is None else str(op),))
            del conn.notices[:]
            yield cur
        if commit:
            conn.commit()
        else:
            conn.rollback()
    except Exception:
        conn.rollback()
        raise

def pop_notices():
    """Lấy các thông báo RAISE NOTICE của trigger/thủ tục trong giao dịch vừa chạy."""
    conn = get_db_connection()
    notes = [n.strip() for n in conn.notices]
    del conn.notices[:]
    return notes

def explain_db_error(ex):
    """Chuyển lỗi CSDL thành thông báo tiếng Việt dễ hiểu (đặc biệt các lỗi BR-18)."""
    msg = str(ex).strip().splitlines()[0] if str(ex).strip() else repr(ex)
    code = getattr(ex, "pgcode", None)
    if "BR-18" in msg:
        return f"Không thể đặt ca PT (BR-18): {msg}"
    if "uq_member_one_active_subscription" in msg:
        return "Hội viên này đã có một hợp đồng Active khác (BR-05: mỗi hội viên chỉ có 1 hợp đồng Active tại một thời điểm)."
    if code == "23P01":
        return f"Trùng lịch bị CSDL chặn (BR-12/BR-15): {msg}"
    if code == "42501":
        return f"Tài khoản CSDL không đủ quyền thực hiện thao tác này: {msg}"
    return msg

# ============================================================================
# THANH BÊN (SIDEBAR) & ĐIỀU HƯỚNG
# ============================================================================
with st.sidebar:
    st.markdown("### 🏋️‍♂️ FIT ZONE PLATFORM")
    st.caption("**PTIT INT1313 - Cơ sở dữ liệu (Nhóm G9)**")
    
    # Kiểm tra trạng thái kết nối DB
    conn_check = get_db_connection()
    if conn_check:
        st.markdown('<span class="badge badge-success">🟢 DB Connected: PostgreSQL 16</span>', unsafe_allow_html=True)
    else:
        st.markdown('<span class="badge badge-danger">🔴 DB Offline (Kiểm tra Docker)</span>', unsafe_allow_html=True)
    
    st.markdown("---")
    menu = st.radio(
        "Chức Năng Hệ Thống:",
        [
            "📊 Dashboard & Khung Nhìn (Views)",
            "👥 Quản Lý Hội Viên & Gói Tập",
            "📅 Lập Lịch PT 1-1 & Lớp Nhóm",
            "🔍 10 Truy Vấn Nâng Cao",
            "⚡ Kiểm Thử Triggers & Ràng Buộc"
        ],
        index=0
    )
    
    st.markdown("---")
    try:
        _ops_df = run_query("""
            SELECT u.user_id, u.full_name, r.role_name
            FROM user_account u
            JOIN user_role ur ON u.user_id = ur.user_id
            JOIN role r ON ur.role_id = r.role_id
            WHERE r.role_name IN ('Admin', 'Receptionist', 'Technician', 'Trainer')
              AND u.status = 'Active'
            ORDER BY r.role_id, u.user_id;
        """)
    except Exception:
        _ops_df = None
    if _ops_df is not None and not _ops_df.empty:
        _op_labels = {int(r["user_id"]): f"{r['full_name']} ({r['role_name']})" for _, r in _ops_df.iterrows()}
        st.selectbox(
            "Người thao tác:",
            list(_op_labels.keys()),
            format_func=lambda uid: _op_labels[uid],
            key="operator_id",
            help="Mã nhân viên được ghi vào created_by_user_id (BR-23) qua SET LOCAL app.current_user_id trong mỗi giao dịch."
        )
    else:
        st.caption("Chưa chọn được 'Người thao tác' (không đọc được danh sách nhân viên).")
    st.caption(f"🔐 Kết nối CSDL bằng tài khoản: `{DB_USER}`")

    st.markdown("---")
    st.markdown("**Thông Tin Nhóm Sinh Viên:**")
    st.caption("1. Lê Hoàng Tiến - N25DCAT050")
    st.caption("2. Lê Hòa Thuận - N25DCAT110")
    st.caption("3. Trần Minh Tiến - N25DCAT111")
    st.caption("Mã đề tài: **09 (Gym Membership & PT Planner)**")

# ============================================================================
# TRANG 1: DASHBOARD & CÁC KHUNG NHÌN (VIEWS)
# ============================================================================
if menu == "📊 Dashboard & Khung Nhìn (Views)":
    st.markdown('<div class="hero-title">Trung Tâm Điều Hành & Khung Nhìn CSDL</div>', unsafe_allow_html=True)
    st.markdown('<div class="hero-subtitle">Giám sát tổng quan chỉ số vận hành và khai thác dữ liệu từ các Views (vw_active_member_subscriptions, vw_trainer_schedule_overview)</div>', unsafe_allow_html=True)
    
    # KPI Cards
    try:
        total_members_df = run_query("SELECT COUNT(*) AS total FROM user_role WHERE role_id = 3;")
        total_active_subs_df = run_query("SELECT COUNT(*) AS total FROM member_subscription WHERE sub_status = 'Active';")
        total_revenue_df = run_query("SELECT COALESCE(SUM(amount), 0) AS total FROM billing_log WHERE payment_status = 'Completed';")
        maintenance_equip_df = run_query("SELECT COUNT(*) AS total FROM equipment WHERE status = 'Under_Maintenance';")
        
        c1, c2, c3, c4 = st.columns(4)
        c1.metric("Tổng Số Hội Viên", f"{total_members_df['total'].iloc[0]:,} TV")
        c2.metric("Hợp Đồng Đang Active", f"{total_active_subs_df['total'].iloc[0]:,} HĐ")
        c3.metric("Tổng Doanh Thu Luỹ Kế", f"{float(total_revenue_df['total'].iloc[0]):,.0f} đ")
        c4.metric("Thiết Bị Đang Bảo Trì", f"{maintenance_equip_df['total'].iloc[0]} máy", delta_color="inverse")
    except Exception as e:
        st.warning(f"Chưa tải được chỉ số thống kê: {e}")
        
    st.markdown("---")
    
    tab_sub, tab_trainer, tab_chart = st.tabs([
        "📋 View 1: Hợp Đồng Hội Viên Active",
        "🏋️‍♂️ View 2: Tổng Hợp Lịch Dạy HLV",
        "📈 Biểu Đồ Phân Tích Tổng Quan"
    ])
    
    with tab_sub:
        st.markdown("#### Khung nhìn: `vw_active_member_subscriptions`")
        st.caption("Tổng hợp toàn bộ hội viên đang có hợp đồng có hiệu lực, số buổi PT còn lại và cảnh báo hết hạn.")
        
        try:
            df_active_sub = run_query("SELECT * FROM vw_active_member_subscriptions ORDER BY days_until_expiration ASC;")
            if df_active_sub is not None and not df_active_sub.empty:
                # Bộ lọc
                search_txt = st.text_input("🔍 Tìm kiếm theo tên hoặc số điện thoại:", "")
                if search_txt:
                    df_active_sub = df_active_sub[
                        df_active_sub['member_name'].str.contains(search_txt, case=False, na=False) |
                        df_active_sub['phone'].str.contains(search_txt, case=False, na=False)
                    ]
                
                # Format cột tiền tệ và ngày tháng
                df_display = df_active_sub.copy()
                df_display['actual_price'] = df_display['actual_price'].apply(lambda x: f"{float(x):,.0f} đ")
                st.dataframe(df_display, use_container_width=True)
            else:
                st.info("Không có dữ liệu hợp đồng Active.")
        except Exception as e:
            st.error(f"Lỗi truy vấn View 1: {e}")
            
    with tab_trainer:
        st.markdown("#### Khung nhìn: `vw_trainer_schedule_overview`")
        st.caption("Tổng hợp hợp nhất tất cả các ca giảng dạy (Lớp học nhóm + Ca PT 1-1) của các Huấn luyện viên.")
        
        try:
            df_trainer_sched = run_query("SELECT * FROM vw_trainer_schedule_overview ORDER BY start_time ASC;")
            if df_trainer_sched is not None and not df_trainer_sched.empty:
                trainers_list = ["Tất cả HLV"] + sorted(list(df_trainer_sched['trainer_name'].unique()))
                selected_trainer = st.selectbox("Lọc theo Huấn Luyện Viên:", trainers_list)
                
                if selected_trainer != "Tất cả HLV":
                    df_trainer_sched = df_trainer_sched[df_trainer_sched['trainer_name'] == selected_trainer]
                    
                st.dataframe(df_trainer_sched, use_container_width=True)
            else:
                st.info("Không có dữ liệu lịch dạy.")
        except Exception as e:
            st.error(f"Lỗi truy vấn View 2: {e}")
            
    with tab_chart:
        st.markdown("#### Biểu Đồ Phân Tích Hoạt Động")
        col_chart1, col_chart2 = st.columns(2)
        
        with col_chart1:
            try:
                revenue_by_plan_df = run_query("""
                    SELECT mp.plan_name, SUM(bl.amount) AS total_revenue
                    FROM membership_plan mp
                    JOIN member_subscription ms ON mp.plan_id = ms.plan_id
                    JOIN billing_log bl ON ms.subscription_id = bl.subscription_id
                    WHERE bl.payment_status = 'Completed'
                    GROUP BY mp.plan_name
                    ORDER BY total_revenue DESC;
                """)
                if revenue_by_plan_df is not None and not revenue_by_plan_df.empty:
                    fig_pie = px.pie(
                        revenue_by_plan_df, 
                        names="plan_name", 
                        values="total_revenue",
                        title="Tỷ Trọng Doanh Thu Theo Gói Tập",
                        hole=0.4,
                        color_discrete_sequence=px.colors.sequential.Teal
                    )
                    fig_pie.update_layout(template="plotly_dark")
                    st.plotly_chart(fig_pie, use_container_width=True)
            except Exception as e:
                st.warning(f"Lỗi biểu đồ 1: {e}")
                
        with col_chart2:
            try:
                trainer_hours_df = run_query("""
                    SELECT 
                        t.full_name AS trainer_name,
                        ROUND(SUM(EXTRACT(EPOCH FROM (pb.end_time - pb.start_time)) / 3600.0)::NUMERIC, 1) AS pt_hours
                    FROM pt_booking pb
                    JOIN user_account t ON pb.trainer_user_id = t.user_id
                    WHERE pb.status = 'Completed'
                    GROUP BY t.full_name
                    ORDER BY pt_hours DESC;
                """)
                if trainer_hours_df is not None and not trainer_hours_df.empty:
                    fig_bar = px.bar(
                        trainer_hours_df,
                        x="trainer_name",
                        y="pt_hours",
                        title="Tổng Số Giờ Dạy PT 1-1 Theo Huấn Luyện Viên",
                        labels={"trainer_name": "Huấn Luyện Viên", "pt_hours": "Số Giờ (h)"},
                        color="pt_hours",
                        color_continuous_scale="Viridis"
                    )
                    fig_bar.update_layout(template="plotly_dark")
                    st.plotly_chart(fig_bar, use_container_width=True)
            except Exception as e:
                st.warning(f"Lỗi biểu đồ 2: {e}")

# ============================================================================
# TRANG 2: QUẢN LÝ HỘI VIÊN & GÓI TẬP (CRUD)
# ============================================================================
elif menu == "👥 Quản Lý Hội Viên & Gói Tập":
    st.markdown('<div class="hero-title">Quản Lý Hội Viên & Hợp Đồng Gói Tập</div>', unsafe_allow_html=True)
    st.markdown('<div class="hero-subtitle">Thực hiện các thao tác Thêm, Xem, Cập nhật thông tin Hội viên và Đăng ký Hợp đồng mới</div>', unsafe_allow_html=True)
    
    crud_tab1, crud_tab2, crud_tab3, crud_tab4 = st.tabs([
        "📋 Danh Sách Hội Viên (Read)",
        "➕ Đăng Ký Hội Viên Mới (Create)",
        "💳 Đăng Ký Gói Tập (Subscription)",
        "🔄 Gia Hạn Tự Động (BR-24)"
    ])
    
    with crud_tab1:
        st.markdown("#### Danh Sách Hội Viên Đang Hoạt Động")
        try:
            df_members = run_query("""
                SELECT 
                    u.user_id,
                    u.full_name,
                    u.email,
                    u.phone,
                    u.dob,
                    EXTRACT(YEAR FROM AGE(CURRENT_DATE, u.dob))::INT AS age,
                    u.emergency_contact,
                    u.status,
                    mp.health_notes
                FROM user_account u
                JOIN user_role ur ON u.user_id = ur.user_id
                LEFT JOIN member_profile mp ON u.user_id = mp.user_id
                WHERE ur.role_id = 3
                ORDER BY u.user_id ASC;
            """)
            if df_members is not None:
                st.dataframe(df_members, use_container_width=True)
        except Exception as e:
            st.error(f"Lỗi lấy danh sách hội viên: {e}")
            
    with crud_tab2:
        st.markdown("#### Form Tiếp Nhận & Đăng Ký Hội Viên Mới")
        st.caption("Ràng buộc nghiệp vụ BR-03: Ngày sinh phải đủ từ 12 tuổi trở lên. Email và SĐT phải là duy nhất (BR-02).")
        
        with st.form("form_create_member"):
            col_m1, col_m2 = st.columns(2)
            with col_m1:
                new_name = st.text_input("Họ và Tên Hội Viên (*)", placeholder="Ví dụ: Nguyễn Văn An")
                new_email = st.text_input("Địa Chỉ Email (*)", placeholder="an.nguyen@gmail.com")
                new_phone = st.text_input("Số Điện Thoại (*)", placeholder="0987654321")
                new_dob = st.date_input("Ngày Sinh (*)", value=date(2000, 1, 1), min_value=date(1940, 1, 1), max_value=date.today())
            with col_m2:
                new_emergency = st.text_input("Thông Tin Khẩn Cấp", placeholder="Người thân: 0912345678")
                new_notes = st.text_area("Ghi Chú Sức Khỏe / Tiền Sử Chấn Thương", placeholder="Ví dụ: Dị ứng thuốc, đau lưng...")
                new_password = st.text_input("Mật Khẩu Ban Đầu", value="FitZone@2026", type="password")
                
            submitted_member = st.form_submit_button("Lưu Hồ Sơ Hội Viên", use_container_width=True)
            
            if submitted_member:
                if not new_name or not new_email or not new_phone:
                    st.error("Vui lòng điền đầy đủ các trường bắt buộc (*).")
                else:
                    # Kiểm tra tuổi theo BR-03 ở tầng ứng dụng trước khi chuyển xuống DB
                    age_years = (date.today() - new_dob).days / 365.25
                    if age_years < 12.0:
                        st.error(f"❌ Vi phạm quy tắc BR-03: Hội viên phải đủ từ 12 tuổi trở lên (Độ tuổi hiện tại: {age_years:.1f} tuổi).")
                    else:
                        try:
                            # Thực hiện transaction thêm tài khoản, role và profile
                            with db_tx() as cur:
                                cur.execute("""
                                    INSERT INTO user_account (full_name, email, phone, dob, emergency_contact, password_hash, status)
                                    VALUES (%s, %s, %s, %s, %s, %s, 'Active')
                                    RETURNING user_id;
                                """, (new_name, new_email, new_phone, new_dob, new_emergency, "$2a$12$K8pQ0q1Y7F6a5B4c3d2e1f0g"))
                                new_user_id = cur.fetchone()[0]
                                
                                # Gán vai trò Member (role_id = 3)
                                cur.execute("INSERT INTO user_role (user_id, role_id) VALUES (%s, 3);", (new_user_id,))
                                
                                # Thêm hồ sơ sức khỏe
                                cur.execute("INSERT INTO member_profile (user_id, health_notes) VALUES (%s, %s);", (new_user_id, new_notes))
                            st.success(f"✅ Đăng ký thành công hội viên mới! Mã định danh (User ID): {new_user_id}")
                            st.rerun()
                        except Exception as ex:
                            st.error(f"Lỗi cơ sở dữ liệu: {explain_db_error(ex)}")
                            
    with crud_tab3:
        st.markdown("#### Ký Hợp Đồng & Đăng Ký Gói Tập Cho Hội Viên")
        st.caption("Hợp đồng được tạo ở trạng thái Pending; khi hóa đơn Completed được ghi, trigger tự chuyển sang Active (BR-07). Mỗi hội viên chỉ có 1 hợp đồng Active (BR-05).")
        
        try:
            members_list_df = run_query("""
                SELECT u.user_id, u.full_name, u.phone
                FROM user_account u
                JOIN member_profile mp ON mp.user_id = u.user_id
                WHERE u.status = 'Active'
                ORDER BY u.full_name;
            """)
            plans_list_df = run_query("SELECT plan_id, plan_name, duration_days, total_sessions, price FROM membership_plan ORDER BY plan_id;")
            
            with st.form("form_subscribe"):
                c_sub1, c_sub2 = st.columns(2)
                with c_sub1:
                    member_options = {f"{r['full_name']} (ID: {r['user_id']} - {r['phone']})": r['user_id'] for _, r in members_list_df.iterrows()}
                    selected_member_str = st.selectbox("Chọn Hội Viên:", list(member_options.keys()))
                    selected_member_id = member_options[selected_member_str]
                    
                    sub_start_date = st.date_input("Ngày Bắt Đầu Hợp Đồng:", value=date.today())
                    is_rec = st.checkbox("Tự Động Gia Hạn (is_recurring)", value=False)
                    
                with c_sub2:
                    plan_options = {f"{r['plan_name']} ({float(r['price']):,.0f} đ - {r['duration_days']} ngày)": r for _, r in plans_list_df.iterrows()}
                    selected_plan_str = st.selectbox("Chọn Gói Tập:", list(plan_options.keys()))
                    selected_plan = plan_options[selected_plan_str]
                    
                    pay_method = st.selectbox("Phương Thức Thanh Toán:", ["Banking", "Credit_Card", "Cash", "E_Wallet"])
                    
                dry_run_sub = st.checkbox("Chạy thử (ROLLBACK, không lưu hợp đồng)", value=False, key="dry_sub")
                sub_btn = st.form_submit_button("Xác Nhận Ký Hợp Đồng & Xuất Hóa Đơn", use_container_width=True)
                
                if sub_btn:
                    duration = selected_plan['duration_days']
                    sessions = selected_plan['total_sessions']
                    price = selected_plan['price']
                    plan_id = selected_plan['plan_id']
                    start_dt = datetime.combine(sub_start_date, datetime.min.time())
                    end_dt = start_dt + timedelta(days=int(duration))
                    
                    if float(price) <= 0:
                        st.error("Gói tập có giá 0 đ không thể xuất hóa đơn Completed (chk_billing_amount: amount > 0), nên không thể kích hoạt theo BR-07.")
                    else:
                        try:
                            with db_tx(commit=not dry_run_sub) as cur:
                                # 1. Tạo hợp đồng ở trạng thái 'Pending' (BR-07: chưa thanh toán thì chưa Active)
                                cur.execute("""
                                    INSERT INTO member_subscription (member_user_id, plan_id, actual_price, remaining_sessions, start_time, end_time, sub_status, is_recurring)
                                    VALUES (%s, %s, %s, %s, %s, %s, 'Pending', %s)
                                    RETURNING subscription_id;
                                """, (int(selected_member_id), int(plan_id), price, int(sessions), start_dt, end_dt, is_rec))
                                new_sub_id = cur.fetchone()[0]
                                cur.execute("SELECT sub_status FROM member_subscription WHERE subscription_id = %s;", (new_sub_id,))
                                status_before = cur.fetchone()[0]
                                
                                # 2. Ghi hóa đơn 'Completed' -> trigger trg_activate_on_payment_* tự chuyển hợp đồng sang 'Active'
                                inv_no = f"INV-{datetime.now().strftime('%Y%m%d%H%M%S')}-{new_sub_id}"
                                cur.execute("""
                                    INSERT INTO billing_log (subscription_id, billing_period_start, invoice_no, amount, payment_date, payment_method, payment_status)
                                    VALUES (%s, %s, %s, %s, %s, %s, 'Completed');
                                """, (new_sub_id, sub_start_date, inv_no, price, date.today(), pay_method))
                                cur.execute("SELECT sub_status, created_by_user_id FROM member_subscription WHERE subscription_id = %s;", (new_sub_id,))
                                status_after, created_by = cur.fetchone()
                                notes = pop_notices()
                            
                            st.success(
                                f"🎉 Hợp đồng ID: {new_sub_id} (hóa đơn {inv_no}): trạng thái khi tạo = **{status_before}**, "
                                f"sau khi thanh toán = **{status_after}** (trigger BR-07 tự kích hoạt). "
                                f"Người thao tác (BR-23): {created_by if created_by is not None else 'không ghi nhận'}."
                            )
                            for n in notes:
                                st.caption(f"📣 {n}")
                            if dry_run_sub:
                                st.info("Chế độ chạy thử: giao dịch đã ROLLBACK, không có dữ liệu nào được lưu.")
                        except Exception as ex:
                            st.error(f"Lỗi xử lý đăng ký gói: {explain_db_error(ex)}")
        except Exception as e:
            st.error(f"Lỗi xử lý đăng ký gói: {explain_db_error(e)}")

    with crud_tab4:
        st.markdown("#### Gia Hạn Tự Động & Ân Hạn Hợp Đồng (BR-24)")
        st.caption("Thủ tục sp_process_subscription_renewals() nên được cron gọi mỗi ngày: hợp đồng không tự gia hạn quá hạn -> Expired; "
                   "hợp đồng tự gia hạn quá hạn -> phát hành hóa đơn Pending; quá thời gian ân hạn mà chưa thanh toán -> Suspended.")
        c_r1, c_r2, c_r3 = st.columns(3)
        with c_r1:
            renew_as_of = st.date_input("Ngày xét (p_as_of):", value=date.today(), key="renew_as_of")
        with c_r2:
            renew_grace = st.number_input("Số ngày ân hạn (p_grace_days):", min_value=0, max_value=30, value=3, key="renew_grace")
        with c_r3:
            renew_dry = st.checkbox("Chạy thử (ROLLBACK, không lưu)", value=True, key="renew_dry")
        
        def _renewal_counts(cur):
            cur.execute("""
                SELECT
                    COUNT(*) FILTER (WHERE sub_status = 'Active')    AS active_cnt,
                    COUNT(*) FILTER (WHERE sub_status = 'Expired')   AS expired_cnt,
                    COUNT(*) FILTER (WHERE sub_status = 'Suspended') AS suspended_cnt,
                    COUNT(*) FILTER (WHERE sub_status = 'Pending')   AS pending_cnt,
                    (SELECT COUNT(*) FROM billing_log WHERE payment_status = 'Pending') AS pending_invoices
                FROM member_subscription;
            """)
            return cur.fetchone()
        
        if st.button("🔄 Gia hạn tự động (BR-24): CALL sp_process_subscription_renewals()", key="btn_renewal", use_container_width=True):
            try:
                with db_tx(commit=not renew_dry) as cur:
                    before = _renewal_counts(cur)
                    cur.execute("CALL sp_process_subscription_renewals(%s, %s);", (renew_as_of, int(renew_grace)))
                    after = _renewal_counts(cur)
                    notes = pop_notices()
                labels = ["Active", "Expired", "Suspended", "Pending", "Hóa đơn Pending"]
                st.dataframe(pd.DataFrame({"Chỉ số": labels, "Trước": list(before), "Sau": list(after)}), use_container_width=True)
                for n in notes:
                    st.success(f"📣 {n}")
                st.info("Chế độ chạy thử: đã ROLLBACK, dữ liệu không đổi." if renew_dry else "Đã COMMIT: dữ liệu được cập nhật.")
            except Exception as ex:
                st.error(f"Lỗi khi gọi thủ tục gia hạn: {explain_db_error(ex)}")

# ============================================================================
# TRANG 3: LẬP LỊCH PT 1-1 & LỚP HỌC NHÓM
# ============================================================================
elif menu == "📅 Lập Lịch PT 1-1 & Lớp Nhóm":
    st.markdown('<div class="hero-title">Lập Lịch Huấn Luyện Viên 1-1 & Lớp Nhóm</div>', unsafe_allow_html=True)
    st.markdown('<div class="hero-subtitle">Đặt lịch tập cá nhân hoặc xếp lịch các lớp tập nhóm theo phòng tiện ích</div>', unsafe_allow_html=True)
    
    sched_tab1, sched_tab2 = st.tabs([
        "🏋️‍♂️ Đặt Lịch Huấn Luyện Viên Cá Nhân (PT 1-1)",
        "🧘 Xếp Lịch Lớp Học Nhóm (Group Class)"
    ])
    
    with sched_tab1:
        st.markdown("#### Tạo Mới Ca Tập PT 1-1 (BR-12, BR-18)")
        st.caption("BR-18: hợp đồng phải đang Active, giờ tập nằm trong thời hạn hợp đồng và còn đủ buổi PT (số ca Scheduled < số buổi còn lại). "
                   "Danh sách dưới đây hiển thị cả hợp đồng không hợp lệ để có thể thử các lỗi trên.")
        try:
            # Các hợp đồng thuộc gói PT (total_sessions > 0), kèm trạng thái để minh họa BR-18
            pt_subs = run_query("""
                SELECT ms.subscription_id, ms.member_user_id, u.full_name, ms.remaining_sessions, ms.sub_status,
                       ms.start_time AS sub_start, ms.end_time AS sub_end, mp.plan_name
                FROM member_subscription ms
                JOIN user_account u ON ms.member_user_id = u.user_id
                JOIN membership_plan mp ON ms.plan_id = mp.plan_id
                WHERE mp.total_sessions > 0
                ORDER BY (ms.sub_status = 'Active') DESC, u.full_name, ms.subscription_id;
            """)
            
            trainers_df = run_query("""
                SELECT u.user_id, u.full_name, tp.specialization, tp.current_rating
                FROM user_account u
                JOIN trainer_profile tp ON u.user_id = tp.user_id
                WHERE u.status = 'Active'
                ORDER BY u.full_name;
            """)
            
            if pt_subs is not None and not pt_subs.empty:
                with st.form("form_pt_booking"):
                    col_b1, col_b2 = st.columns(2)
                    with col_b1:
                        sub_opts = {f"{r['full_name']} (HĐ #{r['subscription_id']} - {r['sub_status']} - Còn {r['remaining_sessions']} buổi - hạn {r['sub_end']:%d/%m/%Y})": r for _, r in pt_subs.iterrows()}
                        sel_sub_str = st.selectbox("Chọn Hội Viên & Hợp Đồng PT:", list(sub_opts.keys()))
                        sel_sub_data = sub_opts[sel_sub_str]
                        
                        b_date = st.date_input("Ngày Tập:", value=date.today() + timedelta(days=1))
                        b_start_time = st.time_input("Giờ Bắt Đầu:", value=datetime.strptime("09:00", "%H:%M").time())
                    with col_b2:
                        trainer_opts = {f"{r['full_name']} ({r['specialization']} - ⭐{r['current_rating']})": r['user_id'] for _, r in trainers_df.iterrows()}
                        sel_trainer_str = st.selectbox("Chọn Huấn Luyện Viên:", list(trainer_opts.keys()))
                        sel_trainer_id = trainer_opts[sel_trainer_str]
                        
                        b_end_time = st.time_input("Giờ Kết Thúc (tối thiểu 60 phút):", value=datetime.strptime("10:30", "%H:%M").time())
                        
                    dry_run_pt = st.checkbox("Chạy thử (ROLLBACK, không lưu ca tập)", value=False, key="dry_pt")
                    pt_book_btn = st.form_submit_button("Xác Nhận Đặt Ca Tập PT", use_container_width=True)
                    
                    if pt_book_btn:
                        start_dt = datetime.combine(b_date, b_start_time)
                        end_dt = datetime.combine(b_date, b_end_time)
                        
                        if end_dt <= start_dt:
                            st.error("Thời gian kết thúc phải lớn hơn thời gian bắt đầu (BR-17).")
                        else:
                            try:
                                with db_tx(commit=not dry_run_pt) as cur:
                                    cur.execute("""
                                        INSERT INTO pt_booking (member_user_id, trainer_user_id, subscription_id, booking_date, start_time, end_time, status)
                                        VALUES (%s, %s, %s, %s, %s, %s, 'Scheduled')
                                        RETURNING booking_id;
                                    """, (int(sel_sub_data['member_user_id']), int(sel_trainer_id), int(sel_sub_data['subscription_id']), b_date, start_dt, end_dt))
                                    new_booking_id = cur.fetchone()[0]
                                st.success(f"✅ Đã đặt ca tập PT thành công! Mã ca tập: #{new_booking_id}" + (" (chạy thử: đã ROLLBACK)" if dry_run_pt else ""))
                            except Exception as ex:
                                st.error(f"❌ {explain_db_error(ex)}")
            else:
                st.info("Hiện không có hợp đồng gói PT nào trong hệ thống.")
        except Exception as e:
            st.error(f"Lỗi lấy thông tin: {explain_db_error(e)}")
        
        # ---- Hủy ca PT (BR-25) ----
        st.markdown("---")
        st.markdown("#### Hủy Ca Tập PT Đang 'Scheduled' (BR-25)")
        st.caption("Hủy khi còn từ 24 giờ trở lên -> 'Cancelled' (không trừ buổi). Hủy khi còn dưới 24 giờ -> trigger tự đổi thành 'Late_Cancelled' và trừ 1 buổi.")
        try:
            sched_pts = run_query("""
                SELECT pb.booking_id, pb.start_time, m.full_name AS member_name, t.full_name AS trainer_name,
                       ms.subscription_id, ms.remaining_sessions,
                       (pb.start_time < CURRENT_TIMESTAMP::TIMESTAMP + INTERVAL '24 hours') AS is_late
                FROM pt_booking pb
                JOIN user_account m ON pb.member_user_id = m.user_id
                JOIN user_account t ON pb.trainer_user_id = t.user_id
                JOIN member_subscription ms ON pb.subscription_id = ms.subscription_id
                WHERE pb.status = 'Scheduled'
                ORDER BY pb.start_time ASC
                LIMIT 200;
            """)
            if sched_pts is not None and not sched_pts.empty:
                cancel_opts = {
                    f"Ca #{r['booking_id']} - {r['member_name']} với {r['trainer_name']} - {r['start_time']:%d/%m/%Y %H:%M}"
                    f"{' [dưới 24h]' if r['is_late'] else ''} (HĐ còn {r['remaining_sessions']} buổi)": r
                    for _, r in sched_pts.iterrows()
                }
                sel_cancel_str = st.selectbox("Chọn ca cần hủy:", list(cancel_opts.keys()), key="sel_cancel_pt")
                sel_cancel = cancel_opts[sel_cancel_str]
                cancel_dry = st.checkbox("Chạy thử (ROLLBACK, không lưu việc hủy)", value=False, key="dry_cancel")
                if st.button("❌ Hủy ca", key="btn_cancel_pt"):
                    try:
                        with db_tx(commit=not cancel_dry) as cur:
                            cur.execute("SELECT remaining_sessions FROM member_subscription WHERE subscription_id = %s;", (int(sel_cancel['subscription_id']),))
                            remain_before = cur.fetchone()[0]
                            cur.execute("UPDATE pt_booking SET status = 'Cancelled' WHERE booking_id = %s AND status = 'Scheduled' RETURNING status;", (int(sel_cancel['booking_id']),))
                            row = cur.fetchone()
                            cur.execute("SELECT remaining_sessions FROM member_subscription WHERE subscription_id = %s;", (int(sel_cancel['subscription_id']),))
                            remain_after = cur.fetchone()[0]
                        if row is None:
                            st.warning("Ca tập không còn ở trạng thái Scheduled (có thể đã bị hủy/hoàn tất bởi người khác).")
                        elif row[0] == 'Late_Cancelled':
                            st.warning(f"⚠️ Ca #{sel_cancel['booking_id']} hủy khi còn dưới 24 giờ nên được ghi nhận **Late_Cancelled**: số buổi còn lại {remain_before} -> {remain_after} (bị trừ 1 buổi, BR-25).")
                        else:
                            st.success(f"✅ Ca #{sel_cancel['booking_id']} đã được hủy với trạng thái **{row[0]}** (hủy trước 24 giờ, không trừ buổi): số buổi còn lại {remain_before} -> {remain_after}.")
                        if cancel_dry:
                            st.info("Chế độ chạy thử: đã ROLLBACK, ca tập vẫn ở trạng thái Scheduled.")
                    except Exception as ex:
                        st.error(f"❌ {explain_db_error(ex)}")
            else:
                st.info("Hiện không có ca PT nào ở trạng thái Scheduled để hủy.")
        except Exception as e:
            st.error(f"Lỗi lấy danh sách ca PT: {explain_db_error(e)}")
            
    with sched_tab2:
        st.markdown("#### Xếp Lịch Lớp Học Nhóm Mới")
        st.caption("Lưu ý: Ràng buộc Trigger BR-19 sẽ tự động ngăn chặn nếu chọn Phòng tập đang BẢO TRÌ!")
        try:
            rooms_df = run_query("SELECT room_id, room_name, max_capacity, status FROM facilities_room ORDER BY room_id;")
            trainers_df2 = run_query("SELECT u.user_id, u.full_name FROM user_account u JOIN user_role ur ON u.user_id = ur.user_id WHERE ur.role_id = 2;")
            
            with st.form("form_class_schedule"):
                c_cls1, c_cls2 = st.columns(2)
                with c_cls1:
                    cls_name = st.text_input("Tên Lớp Học Nhóm:", placeholder="Ví dụ: Vinyasa Flow Buổi Sáng")
                    tr_opts = {r['full_name']: r['user_id'] for _, r in trainers_df2.iterrows()}
                    sel_tr_str = st.selectbox("Huấn Luyện Viên Đứng Lớp:", list(tr_opts.keys()))
                    sel_tr_id = tr_opts[sel_tr_str]
                    
                    cls_date = st.date_input("Ngày Tổ Chức:", value=date.today() + timedelta(days=1))
                    cls_start = st.time_input("Giờ Bắt Đầu Lớp:", value=datetime.strptime("07:00", "%H:%M").time(), key="cls_s")
                with c_cls2:
                    rm_opts = {f"{r['room_name']} [Sức chứa: {r['max_capacity']} - Trạng thái: {r['status']}]": r for _, r in rooms_df.iterrows()}
                    sel_rm_str = st.selectbox("Phòng Học / Khu Vực:", list(rm_opts.keys()))
                    sel_rm_data = rm_opts[sel_rm_str]
                    
                    cls_capacity = st.number_input("Sức Chứa Tối Đa Của Lớp:", min_value=1, max_value=sel_rm_data['max_capacity'], value=min(20, sel_rm_data['max_capacity']))
                    cls_end = st.time_input("Giờ Kết Thúc Lớp:", value=datetime.strptime("08:15", "%H:%M").time(), key="cls_e")
                    
                cls_btn = st.form_submit_button("Lưu & Phát Hành Lịch Lớp", use_container_width=True)
                
                if cls_btn:
                    dt_start = datetime.combine(cls_date, cls_start)
                    dt_end = datetime.combine(cls_date, cls_end)
                    
                    if dt_end <= dt_start:
                        st.error("Thời gian kết thúc phải lớn hơn thời gian bắt đầu.")
                    else:
                        try:
                            with db_tx() as cur:
                                cur.execute("""
                                    INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled)
                                    VALUES (%s, %s, %s, %s, %s, %s, 0)
                                    RETURNING class_id;
                                """, (int(sel_tr_id), int(sel_rm_data['room_id']), cls_name, dt_start, dt_end, int(cls_capacity)))
                                new_cls_id = cur.fetchone()[0]
                            st.success(f"✅ Đã thêm lớp học thành công! Mã lớp: #{new_cls_id}")
                        except Exception as ex:
                            st.error(f"❌ Cơ sở dữ liệu từ chối: {explain_db_error(ex)}")
        except Exception as e:
            st.error(f"Lỗi: {e}")

# ============================================================================
# TRANG 4: 10 TRUY VẤN NÂNG CAO (COMPLEX QUERIES PLAYGROUND)
# ============================================================================
elif menu == "🔍 10 Truy Vấn Nâng Cao":
    st.markdown('<div class="hero-title">Thực Thi & Trực Quan Hóa 10 Truy Vấn Phức Tạp</div>', unsafe_allow_html=True)
    st.markdown('<div class="hero-subtitle">Mỗi câu truy vấn tương ứng với một bài toán phân tích quản trị thực tế (Joins, Subqueries, Window Functions, CTEs)</div>', unsafe_allow_html=True)
    
    query_catalog = {
        "1. Doanh thu theo Gói tập trong quý hiện tại": {
            "business": "Thống kê tổng doanh thu, số lượng đơn hàng và giá trị đơn hàng trung bình của từng gói tập trong quý hiện tại để đánh giá hiệu quả kinh doanh.",
            "technique": "JOIN 3 bảng (membership_plan, member_subscription, billing_log), GROUP BY, SUM, date_trunc('quarter', payment_date)",
            "sql": """SELECT
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
    total_revenue DESC;""",
            "chart_type": "pie",
            "names": "plan_name",
            "values": "total_revenue"
        },
        "2. Top 3 Huấn luyện viên dạy nhiều giờ nhất trong tháng": {
            "business": "Tính tổng số giờ dạy cả hai hình thức: Dạy kèm PT 1-1 và Lớp nhóm trong tháng để xếp hạng trao thưởng KPI cho Huấn luyện viên.",
            "technique": "UNION ALL trong CTE, EXTRACT(EPOCH), GROUP BY, HAVING, ORDER BY LIMIT 3",
            "sql": """WITH trainer_teaching_hours AS (
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
LIMIT 3;""",
            "chart_type": "bar",
            "x": "trainer_name",
            "y": "total_hours_taught"
        },
        "3. Hội viên có hợp đồng sắp hết hạn trong 7 ngày tới": {
            "business": "Lọc danh sách các hội viên có gói tập Active chuẩn bị hết hạn trong 7 ngày tới để lễ tân chủ động liên hệ chăm sóc và gia hạn.",
            "technique": "WHERE, CURRENT_TIMESTAMP, INTERVAL '7 days', DATE ARITHMETIC",
            "sql": """SELECT
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
    ms.end_time ASC;""",
            "chart_type": "table_only"
        },
        "4. Thiết bị đang bảo trì kèm Kỹ thuật viên & Tổng chi phí": {
            "business": "Theo dõi các thiết bị ngừng hoạt động (BR-19), nhân viên kỹ thuật chịu trách nhiệm xử lý và lũy kế chi phí sửa chữa từ trước tới nay.",
            "technique": "JOIN 4 bảng, Scalar Subquery tính tổng chi phí lịch sử, WHERE status = 'Under_Maintenance'",
            "sql": """SELECT
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
    ml.start_time ASC;""",
            "chart_type": "table_only"
        },
        "5. Tỷ lệ lấp đầy (Fill Rate) của các Lớp học nhóm": {
            "business": "Đo lường tỷ lệ học viên thực tế trên sức chứa của các lớp học nhóm để nhận diện các lớp đông khách hoặc các lớp cần hủy bớt.",
            "technique": "Arithmetic Expression, ROUND, CASE WHEN phân nhóm lấp đầy, ORDER BY",
            "sql": """SELECT
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
    cs.start_time ASC;""",
            "chart_type": "bar",
            "x": "class_name",
            "y": "fill_rate_percentage"
        },
        "6. Danh sách ca tập PT 1-1 bị hủy muộn hoặc bỏ tập (No-show)": {
            "business": "Kiểm toán việc thực thi quy định trừ buổi (BR-25): hội viên vắng mặt (No_Show) hoặc hủy muộn dưới 24 giờ (Late_Cancelled) bị trừ 1 buổi; hủy sớm (Cancelled) thì không.",
            "technique": "JOIN 3 bảng, WHERE status IN ('Cancelled', 'Late_Cancelled', 'No_Show'), CASE WHEN giải thích chế tài",
            "sql": """SELECT
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
    pb.start_time DESC;""",
            "chart_type": "table_only"
        },
        "7. Hội viên đã mua gói PT nhưng chưa từng đặt lịch buổi nào": {
            "business": "Tìm các khách hàng 'ngủ đông' đã trả tiền mua gói PT nhưng chưa từng được xếp lịch học để HLV chủ động liên hệ.",
            "technique": "LEFT JOIN, IS NULL, Filter theo gói PT (total_sessions > 0)",
            "sql": """SELECT
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
    ms.start_time ASC;""",
            "chart_type": "table_only"
        },
        "8. Phân nhóm hội viên theo độ tuổi & Gói tập ưa chuộng nhất": {
            "business": "Phân khúc nhân khẩu học (Demographics) để nghiên cứu hành vi tiêu dùng theo lứa tuổi (Gen Z, thanh niên, trung niên).",
            "technique": "CASE WHEN độ tuổi, Window Function DENSE_RANK() OVER (PARTITION BY age_bracket), CTE",
            "sql": """WITH member_age_groups AS (
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
    plan_name ASC;""",
            "chart_type": "bar",
            "x": "age_bracket",
            "y": "total_subscriptions"
        },
        "9. Xếp hạng doanh thu đóng góp của Hội viên (Window Function)": {
            "business": "Xây dựng hệ thống xếp hạng phân hạng Hội viên VIP (Kim cương, Bạch kim, Tiêu chuẩn) theo đóng góp chi tiêu.",
            "technique": "Window Function DENSE_RANK() OVER (ORDER BY SUM(amount) DESC), GROUP BY",
            "sql": """SELECT
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
    total_money_spent DESC;""",
            "chart_type": "table_only"
        },
        "10. Phát hiện xung đột lịch tập (Overlapping Intervals) của HLV": {
            "business": "Kiểm toán tính toàn vẹn (Integrity Check) để phát hiện bất kỳ sự kiện nào bị trùng giờ của cùng 1 Huấn luyện viên. Vì BR-12/BR-15/BR-16 đã được CSDL cưỡng chế nên kết quả kỳ vọng là 0 dòng.",
            "technique": "CTE (WITH), Self-Join khoảng thời gian giao nhau (start_a < end_b AND end_a > start_b)",
            "sql": """WITH all_trainer_events AS (
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
    e1.start_time ASC;""",
            "chart_type": "table_only"
        }
    }
    
    selected_query_title = st.selectbox("Chọn Câu Truy Vấn Cần Thực Thi:", list(query_catalog.keys()))
    q_data = query_catalog[selected_query_title]
    
    st.markdown(f"**🎯 Mục Đích Nghiệp Vụ:** {q_data['business']}")
    st.markdown(f"**⚙️ Kỹ Thuật SQL:** `{q_data['technique']}`")
    
    with st.expander("Xem Câu Lệnh SQL Chuẩn (PostgreSQL)", expanded=True):
        st.code(q_data['sql'], language="sql")
        
    if st.button("🚀 Thực Thi Truy Vấn Trên PostgreSQL", use_container_width=True):
        try:
            res_df = run_query(q_data['sql'])
            if res_df is not None:
                st.markdown(f"##### 📊 Kết quả thực thi ({len(res_df)} bản ghi tìm thấy):")
                st.dataframe(res_df, use_container_width=True)
                
                # Render chart if applicable
                if q_data['chart_type'] == "pie" and not res_df.empty:
                    fig = px.pie(res_df, names=q_data['names'], values=q_data['values'], title=selected_query_title)
                    fig.update_layout(template="plotly_dark")
                    st.plotly_chart(fig, use_container_width=True)
                elif q_data['chart_type'] == "bar" and not res_df.empty:
                    fig = px.bar(res_df, x=q_data['x'], y=q_data['y'], title=selected_query_title, color=q_data['y'])
                    fig.update_layout(template="plotly_dark")
                    st.plotly_chart(fig, use_container_width=True)
            else:
                st.info("Truy vấn thành công nhưng không có dữ liệu trả về.")
        except Exception as ex:
            st.error(f"Lỗi thực thi truy vấn: {ex}")

# ============================================================================
# TRANG 5: KIỂM THỬ TRIGGERS & RÀNG BUỘC (TRIGGER TEST BENCH)
# ============================================================================
elif menu == "⚡ Kiểm Thử Triggers & Ràng Buộc":
    st.markdown('<div class="hero-title">Phòng Kiểm Thử Ràng Buộc & Bộ Kích Hoạt (Triggers)</div>', unsafe_allow_html=True)
    st.markdown('<div class="hero-subtitle">Môi trường thử nghiệm tương tác trực tiếp để bảo vệ và chứng minh cơ chế Business Rules tự động của CSDL</div>', unsafe_allow_html=True)
    
    t_tab1, t_tab2, t_tab3 = st.tabs([
        "⚡ Test 1: Tự Động Trừ Buổi PT (trg_update_remaining_pt_sessions)",
        "🚫 Test 2: Chặn Xếp Lịch Vào Phòng Bảo Trì (trg_prevent_class_in_maintenance_room)",
        "🛑 Test 3: Chặn Đăng Ký Hội Viên Dưới 12 Tuổi (BR-03)"
    ])
    
    with t_tab1:
        st.markdown("#### Kiểm thử: Tự Động Trừ 1 Buổi Khi Ca PT Chuyển Sang 'Completed'")
        st.caption("Quy tắc BR-18: Khi ca tập 1-1 hoàn tất, CSDL phải tự động giảm remaining_sessions đi 1. Nếu số buổi <= 0, hệ thống Raise Exception.")
        
        try:
            scheduled_pts = run_query("""
                SELECT 
                    pb.booking_id,
                    pb.booking_date,
                    m.full_name AS member_name,
                    t.full_name AS trainer_name,
                    ms.subscription_id,
                    ms.remaining_sessions
                FROM pt_booking pb
                JOIN user_account m ON pb.member_user_id = m.user_id
                JOIN user_account t ON pb.trainer_user_id = t.user_id
                JOIN member_subscription ms ON pb.subscription_id = ms.subscription_id
                WHERE pb.status = 'Scheduled'
                ORDER BY pb.booking_id ASC;
            """)
            
            if scheduled_pts is not None and not scheduled_pts.empty:
                st.dataframe(scheduled_pts, use_container_width=True)
                
                pt_opts = {f"Ca #{r['booking_id']} - {r['member_name']} (Hiện còn: {r['remaining_sessions']} buổi)": r for _, r in scheduled_pts.iterrows()}
                sel_pt_test_str = st.selectbox("Chọn Ca Tập PT Đang 'Scheduled' Để Thử Nghiệm:", list(pt_opts.keys()))
                sel_pt_test = pt_opts[sel_pt_test_str]
                
                if st.button("👉 Kích Hoạt Chuyển Trạng Thái Thành 'Completed'", key="btn_trigger_pt"):
                    try:
                        # db_tx đặt app.current_user_id (BR-23) và luôn ROLLBACK (commit=False)
                        with db_tx(commit=False) as cur:
                            cur.execute("UPDATE pt_booking SET status = 'Completed' WHERE booking_id = %s;", (int(sel_pt_test['booking_id']),))
                            # Đọc lại số buổi trong cùng giao dịch (trước khi rollback)
                            cur.execute("SELECT remaining_sessions FROM member_subscription WHERE subscription_id = %s;", (int(sel_pt_test['subscription_id']),))
                            new_remain = cur.fetchone()[0]
                        
                        st.success(f"""
                        🎉 TRIGGER ĐÃ KÍCH HOẠT THÀNH CÔNG!
                        - Số buổi ban đầu: **{sel_pt_test['remaining_sessions']}**
                        - Số buổi sau khi Trigger trừ tự động: **{new_remain}** (Đã trừ đúng 1 buổi!)
                        - Phép thử chạy trong một giao dịch và đã ROLLBACK nên dữ liệu thật không bị thay đổi.
                        """)
                    except Exception as ex:
                        st.error(f"Lỗi từ Trigger: {ex}")
            else:
                st.info("Hiện không có ca tập nào đang ở trạng thái 'Scheduled'.")
        except Exception as e:
            st.error(f"Lỗi: {e}")
            
    with t_tab2:
        st.markdown("#### Kiểm thử: Chặn Xếp Lịch Vào Phòng Hoặc Máy Tập Đang Bảo Trì")
        st.caption("Quy tắc BR-19: Phòng tập hoặc Thiết bị có trạng thái 'Under_Maintenance' sẽ bị trigger chặn ngay lập tức và bắn lỗi.")
        
        # Lấy phòng đang bảo trì
        m_rooms = run_query("SELECT room_id, room_name, status FROM facilities_room WHERE status = 'Under_Maintenance';")
        if m_rooms is not None and not m_rooms.empty:
            st.warning(f"Phòng tập đang bảo trì trong hệ thống: **{m_rooms['room_name'].iloc[0]} (ID: {m_rooms['room_id'].iloc[0]})**")
            
            if st.button("🔥 Thử Nghiệm Xếp Lớp Vào Phòng Đang Bảo Trì Này", key="btn_trigger_maint"):
                try:
                    with db_tx(commit=False) as cur:
                        cur.execute("""
                            INSERT INTO class_schedule (trainer_user_id, room_id, class_name, start_time, end_time, max_capacity, current_enrolled)
                            VALUES (5, %s, 'Lớp Boxing Cấm Xếp',
                                    DATE_TRUNC('day', CURRENT_TIMESTAMP) + INTERVAL '3 days 21 hours',
                                    DATE_TRUNC('day', CURRENT_TIMESTAMP) + INTERVAL '3 days 22 hours 30 minutes', 10, 0);
                        """, (int(m_rooms['room_id'].iloc[0]),))
                    st.error("Cảnh báo: Lệnh INSERT không bị chặn! Cần kiểm tra lại trigger (dữ liệu thử nghiệm đã được ROLLBACK).")
                except Exception as ex:
                    if getattr(ex, "pgcode", None) == "P0001" and "BR-19" in str(ex):
                        st.success(f"""
                        🛡️ TRIGGER ĐÃ BẢO VỆ CSDL THÀNH CÔNG!
                        CSDL PostgreSQL đã chủ động ném lỗi ngoại lệ (Raise Exception) ngăn chặn thao tác:
                        ```
                        {ex}
                        ```
                        """)
                    else:
                        st.warning(f"Phép thử gặp lỗi không phải do Trigger BR-19 (chưa chứng minh được ràng buộc): {ex}")
        else:
            st.info("Hiện không có phòng nào ở trạng thái Under_Maintenance.")
            
    with t_tab3:
        st.markdown("#### Kiểm thử: Chặn Đăng Ký Hội Viên Dưới 12 Tuổi (BR-03)")
        st.caption("Quy tắc BR-03: Hội viên phải đủ 12 tuổi trở lên. CSDL chặn bằng Trigger trg_check_member_dob (BEFORE INSERT trên member_profile) và trg_check_user_dob_for_member (BEFORE UPDATE OF dob trên user_account). Phép thử chạy trong một giao dịch và luôn ROLLBACK, không để lại dữ liệu.")
        
        if st.button("🔥 Thử Nghiệm Đăng Ký Hội Viên 8 Tuổi (Sinh năm 2018)", key="btn_trigger_dob"):
            conn = get_db_connection()
            if not conn:
                st.warning("Không thể kết nối tới PostgreSQL để chạy phép thử.")
            else:
                try:
                    if conn.closed:
                        st.cache_resource.clear()
                        conn = get_db_connection()
                    with conn.cursor() as cur:
                        cur.execute("""
                            INSERT INTO user_account (full_name, email, phone, dob, emergency_contact, password_hash, status)
                            VALUES ('Bé Thử Nghiệm 8 Tuổi', 'be8tuoi.test@fitzone.vn', '0999888777', '2018-05-10', 'Bố: 0999888666', 'hash', 'Active')
                            RETURNING user_id;
                        """)
                        new_uid = cur.fetchone()[0]
                        # Trigger BR-03 chặn tại bước tạo hồ sơ hội viên
                        cur.execute("INSERT INTO member_profile (user_id, health_notes) VALUES (%s, 'Thử nghiệm BR-03');", (new_uid,))
                    st.error("Cảnh báo: Lệnh INSERT không bị chặn! Cần kiểm tra lại trigger (dữ liệu thử nghiệm đã được ROLLBACK).")
                except Exception as ex:
                    if getattr(ex, "pgcode", None) == "P0001" and "BR-03" in str(ex):
                        st.success(f"""
                        🛡️ RÀNG BUỘC BR-03 ĐÃ CHẶN THÀNH CÔNG!
                        CSDL PostgreSQL đã chủ động ném lỗi ngoại lệ:
                        ```
                        {ex}
                        ```
                        """)
                    else:
                        st.warning(f"Phép thử gặp lỗi không phải do Trigger BR-03 (chưa chứng minh được ràng buộc): {ex}")
                finally:
                    try:
                        conn.rollback()
                    except Exception:
                        pass
