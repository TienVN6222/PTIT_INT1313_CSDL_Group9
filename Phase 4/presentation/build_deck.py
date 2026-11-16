#!/usr/bin/env python3
"""Sinh bộ slide bảo vệ đồ án (deck.pptx) và speaker_notes.md cho nhóm G9.

Cách dùng (tạo môi trường ảo ở ngoài kho mã, không cài vào hệ thống):
    python3 -m venv /tmp/p4venv
    /tmp/p4venv/bin/pip install python-pptx
    /tmp/p4venv/bin/python "Phase 4/presentation/build_deck.py"

Kết quả: Phase 4/presentation/deck.pptx và Phase 4/presentation/speaker_notes.md.

Muốn cập nhật số liệu cuối: sửa dictionary STATS bên dưới rồi chạy lại.
Người trình bày (phân công đề xuất): sửa PRESENTERS rồi chạy lại.
"""
import os

from pptx import Presentation
from pptx.dml.color import RGBColor
from pptx.enum.shapes import MSO_SHAPE
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.util import Emu, Inches, Pt

HERE = os.path.dirname(os.path.abspath(__file__))
REPO = os.path.abspath(os.path.join(HERE, "..", ".."))
EER_DIR = os.path.join(REPO, "Phase 2", "database_design", "1_conceptual_er_eer_model")
EER_PNG = os.path.join(EER_DIR, "3_eer_diagram.png")
EER_FALLBACK = os.path.join(EER_DIR, "1_mermaid-diagram.png")

# ----------------------------------------------------------------------------
# SỐ LIỆU CÓ THỂ THAY ĐỔI - sửa tại đây rồi chạy lại script
# (số liệu lấy từ lần chạy kiểm thử cuối trên CSDL mới, ngày 16/11/2026)
# ----------------------------------------------------------------------------
STATS = {
    "tc_total": "109/109",        # 05_constraint_test_cases.sql (TC-01..74 âm tính, TP-01..35 dương tính)
    "rbac_total": "61/61",        # 09_rbac_test_cases.sql (gồm EV-01..EV-13)
    "perf_total": "8/8",          # 06_performance_test_cases.sql
    "perf_limit_ms": "200",
    "perf_rows": "100k user, 200k hóa đơn, 120k ca PT",
    "mock_rows": "715",
    "tables": "18",
    "business_rules": "26",
    "triggers_secdef": "24",
    "bcnf": "17/18",
}
PRESENTERS = {
    "A": "Lê Hoàng Tiến",
    "B": "Lê Hòa Thuận",
    "C": "Trần Minh Tiến",
}

# ----------------------------------------------------------------------------
# GIAO DIỆN
# ----------------------------------------------------------------------------
NAVY = RGBColor(0x14, 0x2B, 0x4D)
TEAL = RGBColor(0x0F, 0x9D, 0x8A)
LIGHT = RGBColor(0xF4, 0xF7, 0xFA)
INK = RGBColor(0x1F, 0x29, 0x37)
GREY = RGBColor(0x6B, 0x72, 0x80)
CODE_BG = RGBColor(0x0F, 0x17, 0x2A)
CODE_FG = RGBColor(0xE2, 0xE8, 0xF0)
WHITE = RGBColor(0xFF, 0xFF, 0xFF)
RED = RGBColor(0xB9, 0x1C, 0x1C)

FONT = "Calibri"
MONO = "Consolas"

prs = Presentation()
prs.slide_width = Inches(13.333)
prs.slide_height = Inches(7.5)
BLANK = prs.slide_layouts[6]
SW, SH = prs.slide_width, prs.slide_height

NOTES = []  # (số slide, tiêu đề, người trình bày, thời lượng, ghi chú)


def _run(par, text, size=20, bold=False, color=INK, font=FONT):
    r = par.add_run()
    r.text = text
    r.font.size = Pt(size)
    r.font.bold = bold
    r.font.name = font
    r.font.color.rgb = color
    return r


def add_text(slide, x, y, w, h, lines, size=20, color=INK, bold=False,
             anchor=MSO_ANCHOR.TOP, align=PP_ALIGN.LEFT, font=FONT, bullet=False,
             space_after=6):
    """lines: danh sách chuỗi hoặc (chuỗi, {size,bold,color}) ."""
    tb = slide.shapes.add_textbox(x, y, w, h)
    tf = tb.text_frame
    tf.word_wrap = True
    tf.vertical_anchor = anchor
    tf.margin_left = tf.margin_right = Inches(0.05)
    first = True
    for item in lines:
        opts = {}
        if isinstance(item, tuple):
            item, opts = item
        par = tf.paragraphs[0] if first else tf.add_paragraph()
        first = False
        par.alignment = align
        par.space_after = Pt(space_after)
        txt = ("•  " + item) if (bullet and not opts.get("nobullet")) else item
        _run(par, txt, opts.get("size", size), opts.get("bold", bold),
             opts.get("color", color), opts.get("font", font))
    return tb


def add_rect(slide, x, y, w, h, fill, line=None, shape=MSO_SHAPE.RECTANGLE):
    s = slide.shapes.add_shape(shape, x, y, w, h)
    s.fill.solid()
    s.fill.fore_color.rgb = fill
    if line is None:
        s.line.fill.background()
    else:
        s.line.color.rgb = line
    s.shadow.inherit = False
    return s


def base_slide(title, presenter=None, minutes=None):
    s = prs.slides.add_slide(BLANK)
    add_rect(s, 0, 0, SW, SH, WHITE)
    add_rect(s, 0, 0, SW, Inches(1.05), NAVY)
    add_rect(s, 0, Inches(1.05), SW, Inches(0.06), TEAL)
    add_text(s, Inches(0.5), Inches(0.12), Inches(11.3), Inches(0.85), [title],
             size=30, bold=True, color=WHITE, anchor=MSO_ANCHOR.MIDDLE)
    n = len(prs.slides)
    add_text(s, Inches(12.0), Inches(6.98), Inches(1.2), Inches(0.35), [str(n)],
             size=12, color=GREY, align=PP_ALIGN.RIGHT)
    add_text(s, Inches(0.5), Inches(6.98), Inches(9), Inches(0.35),
             ["INT1313 - Nhóm G9 - Gym Membership & PT Planner"], size=12, color=GREY)
    if presenter:
        tag = presenter + (f" - {minutes} phút" if minutes else "")
        add_text(s, Inches(9.3), Inches(0.14), Inches(3.8), Inches(0.35), [tag],
                 size=12, color=RGBColor(0xBF, 0xE9, 0xE3), align=PP_ALIGN.RIGHT)
    return s


def code_box(slide, x, y, w, h, code, size=14):
    add_rect(slide, x, y, w, h, CODE_BG)
    add_text(slide, x + Inches(0.15), y + Inches(0.1), w - Inches(0.3), h - Inches(0.2),
             code.split("\n"), size=size, color=CODE_FG, font=MONO, space_after=0)


def table(slide, x, y, w, rows, col_w, size=15, row_h=0.45, header=True):
    nrows, ncols = len(rows), len(rows[0])
    gs = slide.shapes.add_table(nrows, ncols, x, y, w, Inches(row_h * nrows))
    t = gs.table
    for j, cw in enumerate(col_w):
        t.columns[j].width = Inches(cw)
    for i, row in enumerate(rows):
        t.rows[i].height = Inches(row_h)
        for j, val in enumerate(row):
            c = t.cell(i, j)
            c.margin_left = c.margin_right = Inches(0.08)
            c.margin_top = c.margin_bottom = Inches(0.03)
            tf = c.text_frame
            tf.word_wrap = True
            par = tf.paragraphs[0]
            is_head = header and i == 0
            _run(par, val, size, bold=is_head, color=WHITE if is_head else INK)
            c.fill.solid()
            c.fill.fore_color.rgb = NAVY if is_head else (LIGHT if i % 2 == 0 else WHITE)
            c.vertical_anchor = MSO_ANCHOR.MIDDLE
    return t


def note(title, who, minutes, text):
    NOTES.append((len(prs.slides), title, who, minutes, text))
    prs.slides[len(prs.slides) - 1].notes_slide.notes_text_frame.text = text


A, B, C = PRESENTERS["A"], PRESENTERS["B"], PRESENTERS["C"]

# ----------------------------------------------------------------------------
# SLIDE 1 - TIÊU ĐỀ
# ----------------------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_rect(s, 0, 0, SW, SH, NAVY)
add_rect(s, 0, Inches(4.55), SW, Inches(0.08), TEAL)
add_text(s, Inches(0.8), Inches(1.0), Inches(11.7), Inches(0.5),
         ["HỌC PHẦN CƠ SỞ DỮ LIỆU (INT1313) - HỌC KỲ 1 (2026 - 2027)"],
         size=18, color=RGBColor(0xBF, 0xE9, 0xE3), bold=True)
add_text(s, Inches(0.8), Inches(1.7), Inches(11.7), Inches(2.6),
         ["Gym Membership & Personal Training Planner",
          ("Hệ thống quản lý phòng tập và huấn luyện viên cá nhân", {"size": 26, "bold": False})],
         size=42, bold=True, color=WHITE, space_after=10)
add_text(s, Inches(0.8), Inches(4.9), Inches(11.7), Inches(1.9),
         ["Nhóm G9 - Mã đề tài 09",
          "Lê Hoàng Tiến (N25DCAT050)   |   Lê Hòa Thuận (N25DCAT110)   |   Trần Minh Tiến (N25DCAT111)",
          ("PostgreSQL 16  -  Streamlit  -  Docker Compose", {"size": 18, "color": RGBColor(0xBF, 0xE9, 0xE3)})],
         size=22, color=WHITE, space_after=8)
note("Tiêu đề và nhóm", f"{A}", 0.5,
     "Chào hội đồng, chúng em là nhóm G9, đề tài 09: Hệ thống quản lý phòng tập và huấn luyện viên cá nhân. "
     "Nhóm gồm ba thành viên (đọc tên và mã sinh viên). Trong 15 phút tới nhóm sẽ trình bày: bài toán, thiết kế dữ liệu, "
     "các cơ chế bảo vệ dữ liệu ở tầng CSDL, kết quả kiểm thử, và demo trực tiếp. Phần cuối dành cho hỏi đáp.")

# ----------------------------------------------------------------------------
# SLIDE 2 - BÀI TOÁN & PHẠM VI
# ----------------------------------------------------------------------------
s = base_slide("Bài toán và phạm vi", A, 1)
add_text(s, Inches(0.5), Inches(1.35), Inches(6.2), Inches(5.4),
         [("Bài toán", {"bold": True, "color": TEAL, "size": 22, "nobullet": True}),
          "Phòng tập có nhiều gói tập, huấn luyện viên (HLV), lớp nhóm, thiết bị",
          "Lịch tập dễ bị trùng (HLV, phòng, hội viên, máy)",
          "Hóa đơn phải chính xác, không được sửa lén",
          "Gói PT trừ buổi đúng quy tắc; hủy muộn bị tính phí",
          "Nhiều vai trò dùng chung hệ thống: lễ tân, HLV, kỹ thuật viên, hội viên"],
         size=19, bullet=True)
add_text(s, Inches(6.9), Inches(1.35), Inches(6.0), Inches(5.4),
         [("Phạm vi hệ thống", {"bold": True, "color": TEAL, "size": 22, "nobullet": True}),
          f"{STATS['tables']} bảng, 5 phân hệ: tài khoản/RBAC, hồ sơ, gói & thanh toán, lịch & đặt chỗ, thiết bị & bảo trì",
          f"{STATS['business_rules']} quy tắc nghiệp vụ (BR-01 đến BR-26)",
          "DDL, dữ liệu mẫu, 10 truy vấn nâng cao, view, trigger, thủ tục",
          "Kiểm thử ràng buộc, hiệu năng, phân quyền",
          "Giao diện web Streamlit chạy bằng 1 lệnh Docker"],
         size=19, bullet=True)
note("Bài toán và phạm vi", A, 1,
     "Vấn đề thực tế: lịch tập rất dễ trùng, hóa đơn cần bất biến, gói PT phải trừ buổi đúng. Nhóm không giải quyết bằng code ứng dụng "
     "mà đặt các quy tắc này vào chính cơ sở dữ liệu. Hệ thống có 18 bảng, 26 quy tắc nghiệp vụ, kèm bộ kiểm thử và giao diện web. "
     "Phần mô tả đầy đủ theo ISO/IEC/IEEE 29148 nằm trong báo cáo, mục 1.")

# ----------------------------------------------------------------------------
# SLIDE 3 - QUY TẮC NGHIỆP VỤ
# ----------------------------------------------------------------------------
s = base_slide("Quy tắc nghiệp vụ nổi bật", A, 1)
rows = [
    ["Mã", "Quy tắc", "Cơ chế thực thi"],
    ["BR-05", "Mỗi hội viên tối đa 1 hợp đồng Active", "Chỉ mục duy nhất một phần"],
    ["BR-07", "Chỉ Active khi đã có hóa đơn Completed", "Trigger kích hoạt tự động"],
    ["BR-10", "Hóa đơn bất biến (không sửa/xóa)", "Trigger + REVOKE + gym_owner + event trigger"],
    ["BR-12/15/16", "HLV, phòng, hội viên không trùng lịch", "EXCLUDE gist + trigger"],
    ["BR-18", "Chỉ đặt PT khi còn buổi; hoàn thành thì trừ 1", "Trigger"],
    ["BR-19", "Chặn xếp lịch vào phòng/máy bảo trì; không cho bảo trì khi còn lịch tương lai", "Trigger"],
    ["BR-24", "Tự gia hạn và ân hạn hợp đồng", "Thủ tục chạy hằng ngày"],
    ["BR-25", "Hủy < 24 giờ: Late_Cancelled, vẫn trừ 1 buổi", "Trigger BEFORE UPDATE"],
]
table(s, Inches(0.5), Inches(1.4), Inches(12.3), rows, [1.8, 6.5, 4.0], size=17, row_h=0.6)
note("Quy tắc nghiệp vụ", A, 1,
     "Đây là tám quy tắc tiêu biểu. Nguyên tắc của nhóm: quy tắc trong một bảng thì dùng ràng buộc khai báo (UNIQUE, CHECK, EXCLUDE), "
     "quy tắc liên quan nhiều bảng mới dùng trigger. Ví dụ BR-07 cần nhìn sang bảng hóa đơn nên phải dùng trigger.")

# ----------------------------------------------------------------------------
# SLIDE 4 - EER
# ----------------------------------------------------------------------------
s = base_slide("Mô hình quan niệm (EER)", A, 0.5)
img = EER_PNG if os.path.exists(EER_PNG) else EER_FALLBACK
if os.path.exists(img):
    from PIL import Image
    iw, ih = Image.open(img).size
    max_w, max_h = Inches(9.2), Inches(5.6)
    scale = min(max_w / iw, max_h / ih)
    w, h = int(iw * scale), int(ih * scale)
    s.shapes.add_picture(img, Inches(0.4), Inches(1.3), width=Emu(w), height=Emu(h))
else:
    add_text(s, Inches(0.5), Inches(2.5), Inches(8), Inches(1),
             ["[Chèn sơ đồ EER: không tìm thấy file ảnh]"], size=20, color=RED)
add_text(s, Inches(9.7), Inches(1.4), Inches(3.5), Inches(5.4),
         [("Điểm nhấn thiết kế", {"bold": True, "color": TEAL, "size": 20, "nobullet": True}),
          "Chuyên biệt hóa: user_account cha, 3 hồ sơ con (hội viên, HLV, nhân viên) dùng chung khóa chính",
          "N:M qua bảng liên kết: user_role, role_permission, class_enrollment",
          "Hợp đồng gắn hội viên + gói, hóa đơn gắn hợp đồng",
          "Ca PT nối hội viên, HLV, hợp đồng"],
         size=14, bullet=True)
note("Mô hình EER", A, 0.5,
     "Sơ đồ EER nằm trong báo cáo mục 2.1. Điểm quan trọng là chuyên biệt hóa: mọi người dùng là user_account, "
     "sau đó có hồ sơ riêng cho hội viên, HLV, nhân viên với khóa chính dùng chung. Các quan hệ nhiều-nhiều dùng bảng liên kết. "
     "Hợp đồng là trung tâm: nối hội viên, gói tập, hóa đơn, ca PT và đăng ký lớp.")

# ----------------------------------------------------------------------------
# SLIDE 5 - LOGIC & CHUẨN HÓA
# ----------------------------------------------------------------------------
s = base_slide("Lược đồ logic và chuẩn hóa", B, 1)
rows = [
    ["Phân hệ", "Bảng"],
    ["Tài khoản và RBAC", "user_account, role, user_role, permission, role_permission"],
    ["Hồ sơ chuyên biệt", "member_profile, trainer_profile, staff_profile"],
    ["Gói tập và thanh toán", "membership_plan, member_subscription, billing_log"],
    ["Cơ sở vật chất", "facilities_room, equipment, maintenance_log"],
    ["Lịch và đặt chỗ", "class_schedule, class_enrollment, pt_booking, equipment_reservation"],
]
table(s, Inches(0.5), Inches(1.4), Inches(7.4), rows, [2.3, 5.1], size=14, row_h=0.62)
add_text(s, Inches(8.2), Inches(1.4), Inches(4.9), Inches(5.4),
         [("Chuẩn hóa", {"bold": True, "color": TEAL, "size": 20, "nobullet": True}),
          f"{STATS['bcnf']} bảng đạt BCNF (chứng minh bằng tập phụ thuộc hàm)",
          "pt_booking chỉ đạt 2NF: phi chuẩn hóa có kiểm soát",
          "member_user_id giữ lại để khai báo EXCLUDE theo hội viên; khóa ngoại ghép chặn mâu thuẫn",
          "actual_price là giá chốt lúc ký, không phụ thuộc bắc cầu qua plan_id"],
         size=16, bullet=True)
note("Lược đồ logic và chuẩn hóa", B, 1,
     "18 bảng chia thành 5 phân hệ. Về chuẩn hóa, 17 trên 18 bảng đạt BCNF. Bảng pt_booking chỉ đạt 2NF vì có hai phụ thuộc bắc cầu: "
     "subscription_id xác định member_user_id, và start_time xác định booking_date. Nhóm giữ có chủ đích: member_user_id cần có trong bảng để khai báo "
     "ràng buộc EXCLUDE chống trùng lịch theo hội viên, vì EXCLUDE chỉ tham chiếu cột cùng bảng. Dữ liệu không thể mâu thuẫn nhờ khóa ngoại ghép "
     "(subscription_id, member_user_id). Còn actual_price không phải phụ thuộc bắc cầu vì là giá chốt lúc ký, hai hợp đồng cùng gói có thể khác giá. "
     "Chứng minh đầy đủ ở mục 2.3.")

# ----------------------------------------------------------------------------
# SLIDE 6 - EXCLUDE GIST
# ----------------------------------------------------------------------------
s = base_slide("Chống trùng lịch bằng EXCLUDE USING gist", B, 1)
code_box(s, Inches(0.5), Inches(1.4), Inches(7.6), Inches(2.7),
         "CONSTRAINT ex_class_trainer_no_overlap\n"
         "  EXCLUDE USING gist (\n"
         "    trainer_user_id WITH =,\n"
         "    tsrange(start_time, end_time, '[)')\n"
         "      WITH &&\n"
         "  )", size=17)
code_box(s, Inches(0.5), Inches(4.3), Inches(7.6), Inches(2.4),
         "-- Ca PT: chỉ áp dụng cho ca còn hiệu lực\n"
         "EXCLUDE USING gist (\n"
         "  trainer_user_id WITH =,\n"
         "  tsrange(start_time, end_time, '[)') WITH &&\n"
         ") WHERE (status NOT IN\n"
         "  ('Cancelled', 'Late_Cancelled'))", size=15)
add_text(s, Inches(8.4), Inches(1.4), Inches(4.7), Inches(5.4),
         ["Đọc là: không tồn tại hai dòng cùng HLV mà khoảng thời gian giao nhau",
          "'[)' : ca nối tiếp 08-09h và 09-10h không bị coi là trùng",
          "Cần extension btree_gist cho phép so sánh = trong chỉ mục gist",
          "Vi phạm trả SQLSTATE 23P01",
          "5 ràng buộc EXCLUDE: HLV, phòng, hội viên, thiết bị",
          "Trùng chéo bảng (lớp và ca PT): trigger + khóa tư vấn pg_advisory_xact_lock"],
         size=16, bullet=True)
note("EXCLUDE gist", B, 1,
     "UNIQUE chỉ so sánh bằng, CHECK chỉ nhìn một dòng, nên không diễn đạt được hai khoảng thời gian chồng nhau. EXCLUDE làm được: "
     "không tồn tại hai dòng cùng trainer_user_id mà khoảng thời gian giao nhau, toán tử && là overlap của kiểu range. "
     "Dùng nửa mở [) nên hai ca nối tiếp không bị báo trùng oan. Phần ca PT có điều kiện WHERE để ca đã hủy không chiếm giờ. "
     "Với trùng giữa hai bảng khác nhau, EXCLUDE không làm được nên nhóm dùng trigger có khóa tư vấn để hai giao dịch đồng thời không cùng lọt qua.")

# ----------------------------------------------------------------------------
# SLIDE 7 - HÓA ĐƠN, KÍCH HOẠT, HỦY MUỘN
# ----------------------------------------------------------------------------
s = base_slide("Trigger: hóa đơn, kích hoạt, hủy muộn", C, 1)
rows = [
    ["Cơ chế", "Trigger / thủ tục", "Hành vi"],
    ["BR-10 Hóa đơn bất biến", "trg_billing_immutable_update/delete/truncate",
     "Cấm xóa, cấm TRUNCATE; Completed chỉ được đổi sang Refunded. Thêm 3 lớp: GRANT, chủ sở hữu gym_owner NOLOGIN, event trigger chặn ALTER/DROP (kể cả superuser)"],
    ["BR-07 Tự kích hoạt", "trg_require_payment_before_active, trg_activate_on_payment_*",
     "Hóa đơn Completed: hợp đồng Pending thành Active"],
    ["BR-25 Hủy muộn", "trg_late_cancel_pt_booking (BEFORE) + trg_update_remaining_pt_sessions (AFTER)",
     "Hủy < 24 giờ: đổi thành Late_Cancelled và trừ 1 buổi"],
    ["BR-24 Gia hạn", "sp_process_subscription_renewals(p_as_of, p_grace_days)",
     "Expired / hóa đơn gia hạn Pending / Suspended; chạy lại không phát sinh thêm"],
    ["BR-23 Vết thao tác", "trg_fill_created_by, trg_set_updated_by", "Bắt buộc created_by_user_id (NOT NULL) từ app.current_user_id; UPDATE ghi updated_by_user_id, updated_at"],
]
table(s, Inches(0.5), Inches(1.4), Inches(12.3), rows, [2.6, 5.2, 4.5], size=14, row_h=0.85)
add_text(s, Inches(0.5), Inches(6.55), Inches(12.3), Inches(0.4),
         ["Thứ tự: BEFORE sửa NEW trước khi ghi; AFTER nhìn thấy trạng thái đã sửa nên trừ buổi đúng"],
         size=14, color=GREY)
note("Trigger nghiệp vụ", C, 1,
     "Năm cơ chế tiêu biểu. Hóa đơn bất biến có bốn lớp: trigger áp dụng cho mọi tài khoản; chỉ cấp SELECT, INSERT; mọi đối tượng thuộc role NOLOGIN gym_owner nên không tài khoản đăng nhập nào là chủ sở hữu; event trigger chặn ALTER, DROP bảng, trigger và hàm bất biến kể cả với superuser (superuser là gốc tin cậy nên vẫn bảo trì được nếu cố ý tắt event trigger). Vết thao tác BR-23: tạo thì bắt buộc có người thực hiện, sửa thì tự ghi người sửa và thời điểm sửa. "
     "Tự kích hoạt: tạo hợp đồng Pending, ghi hóa đơn Completed, trigger tự chuyển Active. Hủy muộn: ứng dụng chỉ gửi trạng thái Cancelled, "
     "trigger BEFORE tự đổi thành Late_Cancelled nếu còn dưới 24 giờ, rồi trigger AFTER trừ một buổi. Gia hạn tự động là thủ tục vì PostgreSQL không có "
     "bộ lập lịch, cron gọi mỗi ngày; thủ tục idempotent. Cuối cùng created_by lưu vết người thao tác.")

# ----------------------------------------------------------------------------
# SLIDE 8 - TRUY VẤN 1
# ----------------------------------------------------------------------------
s = base_slide("Truy vấn phức hợp (1/2): top HLV, nhóm tuổi", C, 1)
code_box(s, Inches(0.5), Inches(1.4), Inches(6.3), Inches(5.3),
         "-- Q2: Top 3 HLV theo giờ dạy trong tháng\n"
         "WITH trainer_teaching_hours AS (\n"
         "  SELECT trainer_user_id AS trainer_id,\n"
         "         hours  -- PT Completed\n"
         "  FROM pt_booking ...\n"
         "  UNION ALL\n"
         "  SELECT trainer_user_id, hours\n"
         "  FROM class_schedule ...\n"
         ")\n"
         "SELECT u.full_name,\n"
         "       SUM(hours_taught)\n"
         "FROM trainer_teaching_hours tth\n"
         "JOIN user_account u ...\n"
         "GROUP BY u.user_id, u.full_name\n"
         "ORDER BY 2 DESC\n"
         "LIMIT 3;", size=14)
code_box(s, Inches(7.0), Inches(1.4), Inches(6.1), Inches(3.0),
         "-- Q8: gói được ưa chuộng theo nhóm tuổi\n"
         "DENSE_RANK() OVER (\n"
         "  PARTITION BY age_bracket\n"
         "  ORDER BY COUNT(*) DESC\n"
         ") AS rank_in_bracket\n"
         "...\n"
         "WHERE rank_in_bracket = 1", size=14)
add_text(s, Inches(7.0), Inches(4.55), Inches(6.1), Inches(2.3),
         ["Q2: CTE + UNION ALL + EXTRACT(EPOCH) + HAVING + LIMIT",
          "Q8: CTE + CASE + window DENSE_RANK PARTITION BY",
          "Window function tính sau GROUP BY nên phải bọc CTE rồi mới lọc theo hạng"],
         size=15, bullet=True)
note("Truy vấn phức hợp 1", C, 1,
     "Truy vấn 2 gộp giờ dạy kèm 1-1 và giờ đứng lớp nhóm bằng UNION ALL trong CTE rồi lấy top 3. UNION ALL giữ mọi dòng, không khử trùng lặp, "
     "đúng nghiệp vụ vì hai ca cùng độ dài vẫn phải cộng. Truy vấn 8 phân nhóm tuổi bằng CASE rồi dùng DENSE_RANK theo từng nhóm tuổi; "
     "đồng hạng cùng thứ hạng và hạng sau không nhảy cóc. Vì window function tính sau WHERE nên muốn lọc hạng 1 phải bọc trong CTE. "
     "Cả mười truy vấn có trong file 03 và trong giao diện web.")

# ----------------------------------------------------------------------------
# SLIDE 9 - TRUY VẤN 2
# ----------------------------------------------------------------------------
s = base_slide("Truy vấn phức hợp (2/2): xếp hạng, kiểm toán", C, 1)
code_box(s, Inches(0.5), Inches(1.4), Inches(6.3), Inches(3.2),
         "-- Q9: xếp hạng doanh thu hội viên\n"
         "SELECT u.full_name, SUM(bl.amount),\n"
         "  DENSE_RANK() OVER (\n"
         "    ORDER BY SUM(bl.amount) DESC\n"
         "  ) AS spending_rank\n"
         "FROM user_account u\n"
         "JOIN member_subscription ms ...\n"
         "JOIN billing_log bl ...\n"
         "WHERE bl.payment_status = 'Completed'\n"
         "GROUP BY u.user_id, u.full_name;", size=14)
code_box(s, Inches(7.0), Inches(1.4), Inches(6.1), Inches(3.2),
         "-- Q10: self-join khoảng thời gian\n"
         "FROM all_trainer_events e1\n"
         "JOIN all_trainer_events e2\n"
         "  ON e1.trainer_id = e2.trainer_id\n"
         " AND e1.start_time < e2.end_time\n"
         " AND e1.end_time   > e2.start_time\n"
         "WHERE (e1.event_type, e1.event_id)\n"
         "    < (e2.event_type, e2.event_id);", size=14)
add_text(s, Inches(0.5), Inches(4.85), Inches(12.6), Inches(2.0),
         ["Q9: DENSE_RANK không PARTITION = xếp hạng toàn bảng; phân hạng Kim Cương / Bạch Kim / Tiêu chuẩn bằng CASE",
          "Q10 là truy vấn KIỂM TOÁN: kết quả đúng là 0 dòng vì EXCLUDE và trigger đã chặn trùng lịch từ lúc ghi",
          "So sánh bộ (event_type, event_id) vì class_id và booking_id là hai dãy số có thể trùng giá trị"],
         size=16, bullet=True)
note("Truy vấn phức hợp 2", C, 1,
     "Truy vấn 9 xếp hạng hội viên theo tổng tiền thực chi bằng DENSE_RANK không phân vùng. Truy vấn 10 là self-join tìm hai sự kiện của cùng HLV "
     "chồng giờ, điều kiện chồng lấn là start1 nhỏ hơn end2 và end1 lớn hơn start2, dùng dấu nghiêm ngặt để hai ca nối tiếp không bị tính. "
     "Kết quả kỳ vọng là 0 dòng, vì CSDL đã chặn dữ liệu trùng ngay lúc ghi; đây là công cụ kiểm toán. Nhóm đã sửa một lỗi tinh vi: "
     "mã của lớp và mã của ca PT có thể trùng số nên phải so sánh cặp (loại, mã).")

# ----------------------------------------------------------------------------
# SLIDE 10 - KẾT QUẢ KIỂM THỬ
# ----------------------------------------------------------------------------
s = base_slide("Kết quả kiểm thử", C, 1)
cards = [
    (STATS["tc_total"], "Mục 5.1 - Test ràng buộc",
     "68 âm tính (TC) + 30 dương tính (TP), kiểm đúng SQLSTATE"),
    (STATS["rbac_total"], "Mục 5.2 - Test phân quyền RBAC",
     f"5 role nhóm, 5 tài khoản gym_u_*, {STATS['triggers_secdef']} hàm trigger SECURITY DEFINER"),
    (STATS["perf_total"], f"Mục 4.2 - Hiệu năng < {STATS['perf_limit_ms']} ms",
     f"Trên {STATS['perf_rows']}"),
]
for i, (big, ttl, sub) in enumerate(cards):
    x = Inches(0.5 + i * 4.17)
    add_rect(s, x, Inches(1.5), Inches(3.95), Inches(3.0), LIGHT, line=RGBColor(0xD1, 0xD9, 0xE0))
    add_text(s, x, Inches(1.6), Inches(3.95), Inches(1.2), [big], size=54, bold=True,
             color=TEAL, align=PP_ALIGN.CENTER)
    add_text(s, x + Inches(0.15), Inches(2.85), Inches(3.65), Inches(1.6),
             [(ttl, {"bold": True, "size": 18}), (sub, {"size": 14, "color": GREY})],
             align=PP_ALIGN.CENTER, space_after=4)
add_text(s, Inches(0.5), Inches(4.8), Inches(12.3), Inches(2.0),
         [f"Dữ liệu mẫu {STATS['mock_rows']} dòng, ngày tháng tương đối theo ngày nạp nên truy vấn 'tháng này/quý này' luôn có dữ liệu",
          "Truy vấn Q1-Q9 trả về dòng dữ liệu; Q10 (kiểm toán trùng lịch) trả về 0 dòng đúng như kỳ vọng",
          "Tra cứu theo chỉ mục 0,04 - 0,2 ms so với 10 - 30 ms khi quét tuần tự; kiểm tra trùng lịch PT dùng chỉ mục GiST ex_pt_trainer_no_overlap"],
         size=16, bullet=True)
note("Kết quả kiểm thử", C, 1,
     "Ba bộ kiểm thử. Mục 5.1: một trăm linh chín test ràng buộc đạt cả, gồm 74 test âm tính và 35 test dương tính; mỗi test kiểm đúng mã lỗi SQLSTATE "
     "và chạy trong savepoint nên độc lập. Mục 5.2: sáu mươi mốt test phân quyền đạt cả, gồm cả các test event trigger bảo vệ hóa đơn. Mục 4.2: tám phép đo hiệu năng đều dưới 200 mili giây "
     "trên một trăm nghìn người dùng, hai trăm nghìn hóa đơn và 120 nghìn ca PT; tra cứu theo chỉ mục chỉ 0,04 đến 0,2 mili giây so với 10 đến 30 mili giây "
     "khi quét tuần tự. Dữ liệu mẫu 715 dòng, ngày tháng tính tương đối. Số liệu lấy từ lần chạy cuối ngày 16/11/2026; "
     "nếu sửa lại CSDL thì chạy lại ba script rồi cập nhật các số này.")

# ----------------------------------------------------------------------------
# SLIDE 11 - RBAC
# ----------------------------------------------------------------------------
s = base_slide("Phân quyền RBAC cấp CSDL (GRANT / REVOKE)", B, 0.5)
add_text(s, Inches(0.5), Inches(1.4), Inches(6.3), Inches(5.4),
         [("Thiết kế", {"bold": True, "color": TEAL, "size": 20, "nobullet": True}),
          "5 role nhóm NOLOGIN; 5 tài khoản gym_u_* thừa hưởng (INHERIT)",
          "REVOKE ALL khỏi PUBLIC rồi chỉ cấp phần cần thiết (đặc quyền tối thiểu)",
          "Quyền mức cột: password_hash không ai được SELECT",
          "billing_log chỉ SELECT, INSERT - kể cả Admin (BR-10)",
          "Mọi đối tượng thuộc role NOLOGIN gym_owner; event trigger chặn ALTER/DROP billing_log, kể cả superuser",
          "Ứng dụng web kết nối bằng gym_u_admin, không dùng superuser"],
         size=17, bullet=True)
add_text(s, Inches(7.0), Inches(1.4), Inches(6.1), Inches(5.4),
         [("SECURITY DEFINER cho hàm trigger", {"bold": True, "color": TEAL, "size": 20, "nobullet": True}),
          "HLV chỉ UPDATE(status) trên pt_booking, không có quyền ghi member_subscription",
          "Trigger trừ buổi phải chạy bằng quyền chủ sở hữu hàm mới hoạt động",
          "SET search_path = public, pg_temp chống chiếm quyền qua search_path",
          f"Hiện {STATS['triggers_secdef']}/{STATS['triggers_secdef']} hàm trigger đều SECURITY DEFINER",
          "Hai lớp RBAC: bảng role/permission (ứng dụng) và role PostgreSQL (CSDL)"],
         size=17, bullet=True)
note("RBAC", B, 0.5,
     "Phân quyền ở tầng CSDL nên dù ai kết nối thẳng bằng psql vẫn bị giới hạn. Năm role nhóm không đăng nhập được, năm tài khoản demo thừa hưởng. "
     "Mật khẩu hội viên không ai đọc được nhờ quyền mức cột. Hóa đơn chỉ được đọc và thêm, kể cả Admin. "
     "Vì quyền tối thiểu nên HLV không ghi được bảng hợp đồng, nhưng khi HLV đánh dấu ca hoàn thành thì trigger phải trừ buổi trong bảng hợp đồng; "
     "giải pháp là hàm trigger chạy SECURITY DEFINER, kèm search_path cố định để chống tấn công. Ứng dụng web cũng kết nối bằng tài khoản bị hạn chế này.")

# ----------------------------------------------------------------------------
# SLIDE 12 - DEMO UI
# ----------------------------------------------------------------------------
s = base_slide("Demo trực tiếp (1/2): giao diện web (cổng 8501)", A, 3)
rows = [
    ["Bước", "Thao tác (đường đi trên giao diện)", "Điều cần chỉ ra"],
    ["1", "Thanh bên: chọn 'Người thao tác'", "BR-23: created_by_user_id được ghi"],
    ["2", "Menu '📊 Dashboard & Khung Nhìn' > tab View 1, View 2", "2 view, KPI hội viên/doanh thu"],
    ["3", "'👥 Quản Lý Hội Viên' > '➕ Đăng Ký Hội Viên Mới'",
     "Nhập ngày sinh dưới 12 tuổi: bị trigger BR-03 chặn"],
    ["4", "'💳 Đăng Ký Gói Tập' > chọn hội viên, gói, thanh toán",
     "Pending, hóa đơn Completed, tự động Active (BR-07)"],
    ["5", "'📅 Lập Lịch PT 1-1' > đặt ca; mục 'Hủy Ca Tập PT'",
     "Hủy >= 24h: Cancelled; < 24h: Late_Cancelled, trừ 1 buổi (BR-25)"],
    ["6", "'🔍 10 Truy Vấn Nâng Cao' > chọn Q2, bấm 'Thực Thi'", "SQL + bảng + biểu đồ"],
    ["7", "'⚡ Kiểm Thử Triggers' > Test 1, 2, 3",
     "Trừ buổi tự động; chặn phòng bảo trì; chặn < 12 tuổi (đều ROLLBACK)"],
]
table(s, Inches(0.4), Inches(1.35), Inches(12.5), rows, [0.8, 6.4, 5.3], size=14, row_h=0.62)
add_text(s, Inches(0.4), Inches(6.4), Inches(12.5), Inches(0.5),
         ["Dự phòng nếu web lỗi: chuyển sang phần psql ở slide tiếp theo (các script kiểm thử chạy độc lập với giao diện web)"],
         size=13, color=GREY)
note("Demo giao diện", A, 3,
     "Kịch bản demo 3 phút, đi theo đúng thứ tự trong bảng. Trước giờ demo đã chạy docker compose up --build và mở sẵn trang. "
     "Bước 1 chọn người thao tác ở thanh bên. Bước 3: nhập hội viên sinh sau năm 2014 để cho thấy trigger tuổi chặn. Bước 4: ký hợp đồng và xuất hóa đơn, "
     "chỉ ra hợp đồng tự lên Active nhờ trigger. Bước 5: đặt một ca PT rồi hủy; nếu ca còn trên 24 giờ trạng thái là Cancelled, ngược lại là Late_Cancelled và số buổi giảm 1. "
     "Bước 6 chạy truy vấn 2. Bước 7 dùng phòng kiểm thử trigger, mọi phép thử đều ROLLBACK nên không làm bẩn dữ liệu. "
     "Lưu ý: tên menu có biểu tượng; nếu giao diện đổi chữ thì điều chỉnh theo.")

# ----------------------------------------------------------------------------
# SLIDE 13 - DEMO TERMINAL
# ----------------------------------------------------------------------------
s = base_slide("Demo trực tiếp (2/2): dòng lệnh Docker và psql", B, 1.5)
code_box(s, Inches(0.4), Inches(1.35), Inches(12.5), Inches(5.45),
         "# Khởi động toàn bộ hệ thống (CSDL + dữ liệu mẫu + trigger/view + RBAC + web)\n"
         "docker compose up --build\n\n"
         "# Chạy bộ test ràng buộc 5.1 (109 test)\n"
         "docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management \\\n"
         "    -f /sql/05_constraint_test_cases.sql\n\n"
         "# Chạy bộ test phân quyền 5.2 (61 test)\n"
         "docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management \\\n"
         "    -f /sql/09_rbac_test_cases.sql\n\n"
         "# Đăng nhập bằng tài khoản lễ tân (mật khẩu demo_2026), thử đọc cột nhạy cảm\n"
         "docker exec -it fitzone_postgres_db psql -U gym_u_reception -d gym_management\n"
         "gym_management=> SELECT password_hash FROM user_account LIMIT 1;   -- permission denied\n\n"
         "# Dọn sạch sau khi xong\n"
         "docker compose down -v", size=15)
note("Demo dòng lệnh", B, 1.5,
     "Bốn lệnh chính lấy từ README. Hệ thống khởi động bằng một lệnh docker compose up --build. Sau đó chạy script kiểm thử ràng buộc, "
     "kết thúc bằng bảng tổng hợp đạt/không đạt. Phần phân quyền: đăng nhập bằng gym_u_reception rồi thử SELECT password_hash để cho thấy bị từ chối. "
     "Script hiệu năng 06 mất khoảng một phút nên chỉ chạy nếu còn thời gian, hoặc chiếu kết quả đã chạy sẵn. "
     "Dọn dẹp bằng docker compose down -v.")

# ----------------------------------------------------------------------------
# SLIDE 14 - PHÂN CÔNG
# ----------------------------------------------------------------------------
s = base_slide("Phân công trình bày", None)
rows = [
    ["Thành viên", "Phần trình bày", "Slide", "Thời lượng"],
    [A, "Mở đầu, bài toán, quy tắc nghiệp vụ, EER, demo giao diện", "1 - 4, 12", "~ 6 phút"],
    [B, "Lược đồ logic, chuẩn hóa, EXCLUDE, RBAC, demo dòng lệnh", "5, 6, 11, 13", "~ 4 phút"],
    [C, "Trigger nghiệp vụ, truy vấn phức hợp, kết quả kiểm thử", "7 - 10", "~ 4 phút"],
    ["Cả nhóm", "Hỏi đáp (Q&A)", "15", "~ 3 phút"],
]
table(s, Inches(0.5), Inches(1.5), Inches(12.3), rows, [2.6, 6.4, 1.6, 1.7], size=18, row_h=0.8)
add_text(s, Inches(0.5), Inches(5.7), Inches(12.3), Inches(1.0),
         ["Phân công đề xuất - nhóm có thể đổi trong PRESENTERS (build_deck.py) rồi chạy lại",
          "Tổng thời lượng dự kiến: khoảng 14 phút trình bày + hỏi đáp"],
         size=15, color=GREY)
note("Phân công", "Cả nhóm", 0.5,
     "Slide này chỉ để hội đồng biết ai trình bày phần nào. Đây là phân công đề xuất; nhóm có thể đổi trong PRESENTERS rồi chạy lại build_deck.py. "
     "Mỗi thành viên nên chuẩn bị trả lời câu hỏi SQL ở bất kỳ phần nào, vì phần bảo vệ SQL cá nhân hỏi từng người.")

# ----------------------------------------------------------------------------
# SLIDE 15 - Q&A
# ----------------------------------------------------------------------------
s = prs.slides.add_slide(BLANK)
add_rect(s, 0, 0, SW, SH, NAVY)
add_rect(s, 0, Inches(4.3), SW, Inches(0.08), TEAL)
add_text(s, Inches(0.8), Inches(1.6), Inches(11.7), Inches(2.4),
         ["Hỏi đáp (Q&A)", ("Cảm ơn hội đồng đã lắng nghe", {"size": 26, "bold": False})],
         size=54, bold=True, color=WHITE, space_after=12)
add_text(s, Inches(0.8), Inches(4.7), Inches(11.7), Inches(2.2),
         ["Mã nguồn, script và tài liệu: kho mã nhóm G9 (README.md)",
          "Chạy lại toàn bộ: docker compose up --build  |  http://localhost:8501",
          ("Chủ đề có thể được hỏi: trigger vs CHECK, EXCLUDE gist, SECURITY DEFINER, 2NF của pt_booking, "
           "giải thích/sửa truy vấn tại chỗ", {"size": 16, "color": RGBColor(0xBF, 0xE9, 0xE3)})],
         size=20, color=WHITE, space_after=10)
note("Hỏi đáp", "Cả nhóm", 3,
     "Mời hội đồng đặt câu hỏi. Người nào được hỏi trả lời, người khác bổ sung nếu cần. Câu hỏi thường gặp và đáp án mẫu nằm trong "
     "Phase 4/sql_defense_guide.md. Nếu bị hỏi một việc nhóm chưa làm, nói thẳng là chưa làm và nêu hướng cải tiến.")

# ----------------------------------------------------------------------------
# LƯU
# ----------------------------------------------------------------------------
out_pptx = os.path.join(HERE, "deck.pptx")
prs.save(out_pptx)

lines = ["# Ghi chú thuyết trình (Speaker Notes)", "",
         "> File này được sinh tự động bởi `build_deck.py` cùng với `deck.pptx` (ghi chú cũng nằm trong phần Notes của từng slide).",
         "> Thời lượng mục tiêu: 15 phút trình bày + hỏi đáp. Tên người trình bày là chỗ trống để nhóm tự gán.", ""]
for num, title, who, mins, text in NOTES:
    lines += [f"## Slide {num} - {title}", f"**Người trình bày:** {who}  |  **Thời lượng:** ~{mins} phút", "", text, ""]
open(os.path.join(HERE, "speaker_notes.md"), "w", encoding="utf-8").write("\n".join(lines))
print("OK:", out_pptx, "-", len(prs.slides), "slide")
