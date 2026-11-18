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
# (số liệu lấy từ lần chạy kiểm thử cuối trên CSDL mới, ngày 17/11/2026)
# ----------------------------------------------------------------------------
STATS = {
    "tc_total": "114/114",        # 05_constraint_test_cases.sql (TC-01..78 âm tính, TP-01..36 dương tính)
    "rbac_total": "66/66",        # 09_rbac_test_cases.sql (gồm EV-01..EV-13, SY-01..SY-05)
    "perf_total": "8/8",          # 06_performance_test_cases.sql
    "perf_limit_ms": "200",
    "perf_rows": "100k user, 200k hóa đơn, 120k ca PT",
    "mock_rows": "9.928",
    "tables": "18",
    "business_rules": "26",
    "triggers_secdef": "24",
    "bcnf": "17/18",
}
PRESENTERS = {
    "A": "Lê Hoàng Tiến",
    "B": "Lê Hòa Thuận",
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


A, B = PRESENTERS["A"], PRESENTERS["B"]

# ----------------------------------------------------------------------------
# HỖ TRỢ BỐ CỤC "DỄ NÓI": ví von đời thường + một câu chốt cuối slide
# ----------------------------------------------------------------------------
SOFT = RGBColor(0xE6, 0xF6, 0xF3)
BORDER = RGBColor(0xD1, 0xD9, 0xE0)


def takeaway(slide, text, y=6.22):
    """Dải 'Ý chính' ở cuối slide: câu người nói chỉ cần đọc to là đủ ý."""
    add_rect(slide, Inches(0.4), Inches(y), Inches(12.5), Inches(0.64), SOFT)
    add_rect(slide, Inches(0.4), Inches(y), Inches(0.1), Inches(0.64), TEAL)
    add_text(slide, Inches(0.65), Inches(y), Inches(12.15), Inches(0.64), [text],
             size=17, bold=True, color=NAVY, anchor=MSO_ANCHOR.MIDDLE)


def card(slide, x, y, w, h, title, lines, size=16, bullet=True, fill=LIGHT):
    add_rect(slide, x, y, w, h, fill, line=BORDER)
    add_text(slide, x + Inches(0.2), y + Inches(0.12), w - Inches(0.4), h - Inches(0.2),
             [(title, {"bold": True, "color": TEAL, "size": size + 3, "nobullet": True})] + lines,
             size=size, bullet=bullet, space_after=7)


def analogy(slide, x, y, w, h, text, size=16):
    """Ô 'Ví dụ đời thường' - câu mở đầu cho người chưa biết thuật ngữ."""
    card(slide, x, y, w, h, "Ví dụ đời thường", [text], size=size, bullet=False, fill=SOFT)


def flow(slide, x, y, w, box_h, gap, steps, size=15, fill=NAVY):
    """Chuỗi hộp dọc nối bằng mũi tên: dùng để kể một quy trình từng bước."""
    for i, st in enumerate(steps):
        top = y + i * (box_h + gap)
        b = add_rect(slide, x, Emu(int(top)), w, box_h, fill, shape=MSO_SHAPE.ROUNDED_RECTANGLE)
        add_text(slide, x + Inches(0.15), Emu(int(top)), w - Inches(0.3), box_h, [st],
                 size=size, color=WHITE, anchor=MSO_ANCHOR.MIDDLE, align=PP_ALIGN.CENTER)
        if i < len(steps) - 1:
            add_text(slide, x, Emu(int(top + box_h)), w, gap, ["▼"], size=13, color=TEAL,
                     align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)


def hflow(slide, x, y, w_each, h, gap, steps, size=14, fill=NAVY):
    """Chuỗi hộp ngang nối bằng mũi tên."""
    for i, st in enumerate(steps):
        left = x + i * (w_each + gap)
        add_rect(slide, Emu(int(left)), y, w_each, h, fill, shape=MSO_SHAPE.ROUNDED_RECTANGLE)
        add_text(slide, Emu(int(left + Inches(0.1))), y, w_each - Inches(0.2), h, [st],
                 size=size, color=WHITE, anchor=MSO_ANCHOR.MIDDLE, align=PP_ALIGN.CENTER)
        if i < len(steps) - 1:
            add_text(slide, Emu(int(left + w_each)), y, gap, h, ["►"], size=14, color=TEAL,
                     align=PP_ALIGN.CENTER, anchor=MSO_ANCHOR.MIDDLE)


# ============================================================================
# PHẦN 1 - LÊ HÒA THUẬN (slide 1-12)
# ============================================================================

# SLIDE 1 - TIÊU ĐỀ
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
note("Tiêu đề và nhóm", B, 0.3,
     "Em chào thầy cô. Chúng em là nhóm G9, đề tài số 09: hệ thống quản lý phòng tập và huấn luyện viên cá nhân. "
     "Nhóm gồm ba bạn: Lê Hoàng Tiến, Lê Hòa Thuận và Trần Minh Tiến. "
     "Phần đầu em sẽ trình bày bài toán và cách nhóm thiết kế dữ liệu; phần sau bạn Hoàng Tiến trình bày truy vấn, kiểm thử, phân quyền và demo.")

# SLIDE 2 - BÀI TOÁN
s = base_slide("Bài toán: phòng tập hay gặp chuyện gì?", B, 0.6)
card(s, Inches(0.4), Inches(1.35), Inches(6.1), Inches(4.65), "Vấn đề thực tế",
     ["HLV bị xếp hai lịch cùng một giờ",
      "Chưa trả tiền mà gói tập đã được dùng",
      "Hóa đơn bị sửa, bị xóa sau khi đã thu tiền",
      "Hủy buổi PT sát giờ mà không mất buổi",
      "Nhân viên xem được dữ liệu không thuộc việc của mình"], size=18)
card(s, Inches(6.8), Inches(1.35), Inches(6.1), Inches(4.65), "Nhóm đã làm gì",
     ["Đặt các luật này ngay trong cơ sở dữ liệu (PostgreSQL)",
      f"{STATS['tables']} bảng dữ liệu, {STATS['business_rules']} quy tắc nghiệp vụ (BR-01 đến BR-26)",
      "Bộ kiểm thử tự động: 114 + 66 + 8 bài, đều ĐẠT",
      "Trang web demo, bật bằng 1 lệnh Docker"], size=18)
takeaway(s, "Ý chính: luật đặt trong CSDL thì không ai lách được, dù vào bằng web hay gõ lệnh trực tiếp.")
note("Bài toán", B, 0.6,
     "Một phòng tập ngoài đời hay gặp năm chuyện ở bên trái: huấn luyện viên bị xếp trùng giờ, khách chưa trả tiền đã được tập, "
     "hóa đơn bị sửa sau khi thu tiền, khách hủy buổi sát giờ mà vẫn không mất buổi, và nhân viên xem được những thứ không phải việc của mình. "
     "Cách nhóm giải quyết là đặt các luật đó ngay trong cơ sở dữ liệu, tức là chỗ cất dữ liệu, chứ không chỉ kiểm trong trang web. "
     "Vì vậy dù ai vào bằng trang web hay gõ lệnh thẳng vào cơ sở dữ liệu thì dữ liệu sai vẫn bị từ chối. "
     "Hệ thống có 18 bảng, 26 quy tắc, có bộ kiểm thử tự động và một trang web để demo.\n\n"
     "NẾU BỊ HỎI 'vì sao không kiểm trong code web?': vì code web có thể bị bỏ qua, ví dụ người quản trị gõ lệnh trực tiếp; luật trong CSDL thì luôn chạy.")

# SLIDE 3 - QUY TẮC NGHIỆP VỤ
s = base_slide("Quy tắc nghiệp vụ (BR) nổi bật", B, 0.6)
rows = [
    ["Mã", "Luật của phòng tập (nói bằng lời thường)", "CSDL làm gì"],
    ["BR-05", "Mỗi hội viên chỉ có 1 gói đang dùng", "Từ chối gói đang dùng thứ hai"],
    ["BR-07", "Chưa trả tiền thì gói chưa chạy", "Trả tiền xong, gói tự bật Active"],
    ["BR-10", "Hóa đơn đã ghi thì không sửa, không xóa", "Mọi lệnh sửa / xóa bị từ chối"],
    ["BR-12/15/16", "HLV, phòng, hội viên không bị trùng giờ", "Lịch thứ hai bị trùng giờ bị từ chối"],
    ["BR-18", "Hết buổi PT thì không đặt thêm được", "Kiểm số buổi còn lại; tập xong tự trừ 1"],
    ["BR-19", "Phòng / máy đang bảo trì thì không xếp lịch", "Từ chối lịch rơi vào giờ bảo trì"],
    ["BR-24", "Hết hạn thì tự gia hạn hoặc tạm khóa", "Một thủ tục tự chạy mỗi ngày"],
    ["BR-25", "Hủy dưới 24 giờ trước buổi tập vẫn mất buổi", "Tự đổi thành 'hủy muộn', trừ 1 buổi"],
]
table(s, Inches(0.4), Inches(1.35), Inches(12.5), rows, [1.8, 5.9, 4.8], size=16, row_h=0.52)
takeaway(s, "BR = Business Rule = 'luật của phòng tập'. Nhóm có 26 luật, đây là 8 luật tiêu biểu.")
note("Quy tắc nghiệp vụ", B, 0.6,
     "BR là viết tắt của Business Rule, nghĩa là quy tắc nghiệp vụ, hiểu đơn giản là luật của phòng tập. Nhóm có 26 luật, em chọn 8 luật tiêu biểu. "
     "Ví dụ BR-05: mỗi hội viên chỉ có một gói đang dùng. BR-07: chưa trả tiền thì gói chưa chạy, trả tiền xong thì gói tự bật. "
     "BR-10: hóa đơn đã ghi là không sửa, không xóa được. BR-12, 15, 16: huấn luyện viên, phòng và hội viên không bị trùng giờ. "
     "BR-25: hủy buổi tập khi còn dưới 24 giờ thì vẫn bị trừ buổi. Cột bên phải là việc cơ sở dữ liệu tự làm để giữ luật đó. Slide sau em nói CSDL dùng công cụ gì.")

# SLIDE 4 - THỰC THI BR CHỈ BẰNG DBMS
s = base_slide("Giữ luật chỉ bằng DBMS: dùng công cụ nào?", B, 1)
rows = [
    ["Công cụ", "Hiểu như là", "Ví dụ trong dự án"],
    ["PRIMARY KEY (khóa chính)", "Số CCCD: mỗi dòng một mã, không trùng", "Mỗi tài khoản có user_id riêng"],
    ["UNIQUE", "Không hai dòng nào giống nhau ở cột này", "Không trùng email, số điện thoại (BR-02)"],
    ["NOT NULL", "Ô bắt buộc phải điền", "Phải ghi ai là người thao tác (BR-23)"],
    ["CHECK", "Điều kiện đúng thì mới cho lưu", "Giá không âm; giờ kết thúc sau giờ bắt đầu"],
    ["FOREIGN KEY (khóa ngoại)", "Phải trỏ tới thứ có thật ở bảng khác", "Buổi PT phải thuộc một hợp đồng có thật"],
    ["EXCLUDE", "Cấm hai khoảng giờ đè lên nhau", "HLV, phòng, hội viên không trùng lịch"],
    ["TRIGGER", "Cảm biến: tự chạy khi dữ liệu thay đổi", "Trả tiền xong, gói tự bật (BR-07)"],
    ["GRANT / REVOKE", "Phát / thu chìa khóa theo chức vụ", "Lễ tân không đọc được mật khẩu"],
]
table(s, Inches(0.4), Inches(1.3), Inches(12.5), rows, [3.3, 4.6, 4.6], size=15, row_h=0.52)
takeaway(s, "Luật đơn giản → khai báo (UNIQUE, CHECK...). Luật phải nhìn sang bảng khác → trigger.")
note("Giữ luật chỉ bằng DBMS", B, 1,
     "DBMS là phần mềm quản lý cơ sở dữ liệu, ở đây là PostgreSQL. Có thể hình dung nó như người gác cổng kho dữ liệu, và mỗi công cụ là một kiểu luật gác cổng. "
     "Khóa chính giống số căn cước: mỗi dòng một mã, không trùng. UNIQUE cấm hai dòng giống nhau, ví dụ hai tài khoản cùng email. "
     "NOT NULL là ô bắt buộc điền. CHECK là điều kiện đúng thì mới cho lưu, ví dụ giá không được âm. "
     "Khóa ngoại bắt dữ liệu phải trỏ tới thứ có thật, ví dụ một buổi PT phải thuộc một hợp đồng có thật. "
     "EXCLUDE cấm hai khoảng thời gian đè lên nhau, dùng để chống trùng lịch. Trigger giống cảm biến, tự chạy khi dữ liệu thay đổi. "
     "GRANT, REVOKE là phát và thu chìa khóa theo chức vụ. Nguyên tắc chọn ở dải dưới cùng: luật nào khai báo được thì khai báo, luật phải nhìn sang bảng khác mới dùng trigger.\n\n"
     "NẾU BỊ HỎI 'sao ưu tiên khai báo hơn trigger?': khai báo thì PostgreSQL tự kiểm, nhanh, không thể quên; trigger là code mình tự viết nên dễ sai hơn.")

# SLIDE 5 - EER
s = base_slide("Mô hình EER: bản vẽ trước khi xây bảng", B, 0.5)
img = EER_PNG if os.path.exists(EER_PNG) else EER_FALLBACK
if os.path.exists(img):
    from PIL import Image
    iw, ih = Image.open(img).size
    max_w, max_h = Inches(8.6), Inches(4.75)
    scale = min(max_w / iw, max_h / ih)
    w, h = int(iw * scale), int(ih * scale)
    s.shapes.add_picture(img, Inches(0.4), Inches(1.3), width=Emu(w), height=Emu(h))
else:
    add_text(s, Inches(0.5), Inches(2.5), Inches(8), Inches(1),
             ["[Chèn sơ đồ EER: không tìm thấy file ảnh]"], size=20, color=RED)
card(s, Inches(9.2), Inches(1.35), Inches(3.7), Inches(4.65), "Cách đọc sơ đồ",
     ["Mỗi hộp = một loại đối tượng: hội viên, HLV, gói tập, phòng...",
      "Đường nối = quan hệ giữa chúng",
      "Trung tâm là HỢP ĐỒNG: nối hội viên, gói tập, hóa đơn, buổi PT"], size=15)
takeaway(s, "EER giống bản vẽ ngôi nhà: vẽ xong, kiểm xong rồi mới xây thành bảng thật.")
note("Mô hình EER", B, 0.5,
     "EER là sơ đồ thực thể - liên kết mở rộng. Nói đơn giản đây là bản vẽ thiết kế, giống bản vẽ ngôi nhà trước khi xây. "
     "Mỗi hộp là một loại đối tượng như hội viên, huấn luyện viên, gói tập; mỗi đường nối là một quan hệ. "
     "Trung tâm của mô hình là hợp đồng: một hội viên mua một gói thì sinh ra hợp đồng, rồi từ hợp đồng mới có hóa đơn và các buổi PT.")

# SLIDE 6 - EER CHI TIẾT
s = base_slide("EER chi tiết: 3 điểm đặc biệt, ra 18 bảng", B, 1)
card(s, Inches(0.4), Inches(1.35), Inches(6.4), Inches(4.65), "3 điểm đặc biệt",
     ["Cha - con: ai cũng có 1 TÀI KHOẢN; hội viên, HLV, nhân viên có thêm hồ sơ riêng",
      "Một người có thể vừa là HLV vừa là hội viên; Admin thì không cần hồ sơ",
      "Chọn 1 trong 2: một lượt giữ máy thuộc buổi PT HOẶC lớp học, không bao giờ cả hai"], size=17)
rows = [
    ["Trên bản vẽ", "Thành bảng"],
    ["12 đối tượng chính", "12 bảng"],
    ["3 quan hệ nhiều - nhiều", "3 bảng nối ('sổ đăng ký')"],
    ["3 hồ sơ con", "3 bảng, dùng chung mã với tài khoản"],
    ["Tổng", "18 bảng"],
]
table(s, Inches(7.1), Inches(1.4), Inches(5.8), rows, [2.8, 3.0], size=16, row_h=0.7)
add_text(s, Inches(7.1), Inches(5.05), Inches(5.8), Inches(1.0),
         ["Nhiều - nhiều: 1 hội viên học nhiều lớp, 1 lớp có nhiều hội viên → cần bảng nối class_enrollment"],
         size=14, color=GREY)
takeaway(s, "Giống học sinh và môn học: một bạn học nhiều môn, một môn nhiều bạn, nên cần 'sổ đăng ký' ở giữa.")
note("EER chi tiết", B, 1,
     "Mô hình có ba điểm đặc biệt. Thứ nhất là quan hệ cha - con, gọi là chuyên biệt hóa: ai dùng hệ thống cũng có một tài khoản chung, "
     "còn hội viên, huấn luyện viên, nhân viên thì có thêm một hồ sơ riêng. Thứ hai, một người có thể vừa là huấn luyện viên vừa là hội viên, gọi là chồng lấn; "
     "còn Admin chỉ có tài khoản, không cần hồ sơ, gọi là riêng phần. Thứ ba là chọn một trong hai: một lượt giữ máy tập phải thuộc một buổi PT hoặc một lớp học, không bao giờ cả hai, "
     "cơ sở dữ liệu kiểm điều này bằng một điều kiện CHECK. "
     "Bên phải là cách chuyển bản vẽ thành bảng: 12 đối tượng chính thành 12 bảng; 3 quan hệ nhiều - nhiều thành 3 bảng nối, giống sổ đăng ký giữa học sinh và môn học; "
     "3 hồ sơ con thành 3 bảng dùng chung mã với tài khoản. Cộng lại là 18 bảng.")

# SLIDE 7 - CHUẨN HÓA: PHƯƠNG PHÁP
s = base_slide("Chuẩn hóa: mỗi thông tin cất ở một chỗ", B, 1)
analogy(s, Inches(0.4), Inches(1.35), Inches(6.2), Inches(1.75),
        "Nếu tên gói được chép vào 1.000 hợp đồng, đổi tên gói phải sửa 1.000 chỗ - sót một chỗ là sai. "
        "Chuẩn hóa = sắp xếp để mỗi thông tin chỉ nằm ở đúng một chỗ.", size=15)
card(s, Inches(0.4), Inches(3.25), Inches(6.2), Inches(2.75), "2 khái niệm cần biết",
     ["Phụ thuộc hàm X → Y: biết X là biết chắc Y (biết email → biết tài khoản nào)",
      "Khóa: thông tin đủ để chỉ ra đúng 1 dòng (như số CCCD)"], size=16)
rows = [
    ["Mức", "Điều kiện (càng xuống càng gọn)"],
    ["1NF", "Mỗi ô chỉ chứa 1 giá trị"],
    ["2NF", "Không cột nào chỉ dựa vào MỘT PHẦN của khóa"],
    ["3NF", "Không suy 'bắc cầu': A → B → C"],
    ["BCNF", "Mọi 'biết X là biết Y' đều có X là khóa"],
]
table(s, Inches(6.9), Inches(1.4), Inches(6.0), rows, [1.3, 4.7], size=16, row_h=0.62)
add_text(s, Inches(6.9), Inches(4.65), Inches(6.0), Inches(1.4),
         ["Cách kiểm 1 bảng: liệt kê các 'biết X là biết Y' → hỏi X có phải khóa không → tất cả là khóa thì đạt BCNF"],
         size=15, color=INK)
takeaway(s, "Ví dụ bảng tài khoản: chỉ user_id, email, số ĐT suy ra thông tin khác - cả ba đều là khóa → BCNF.")
note("Chuẩn hóa", B, 1,
     "Chuẩn hóa là sắp xếp bảng để mỗi thông tin chỉ nằm ở một chỗ. Ví dụ nếu tên gói tập được chép vào một nghìn hợp đồng, thì đổi tên gói phải sửa một nghìn chỗ, sót một chỗ là sai. "
     "Cần hai khái niệm. Phụ thuộc hàm, viết X mũi tên Y, nghĩa là biết X thì biết chắc Y, ví dụ biết email thì biết đó là tài khoản nào. "
     "Khóa là thông tin đủ để chỉ ra đúng một dòng, như số căn cước. "
     "Các mức chuẩn ở bảng bên phải, càng xuống càng gọn; mức cao nhất là BCNF: mọi phụ thuộc đều phải bắt đầu từ một khóa. "
     "Cách nhóm kiểm từng bảng: liệt kê các phụ thuộc, hỏi vế trái có phải khóa không. Ví dụ bảng tài khoản: chỉ có user_id, email và số điện thoại suy ra thông tin khác, "
     "mà ba cột này đều không trùng, tức đều là khóa, nên bảng đạt BCNF.\n\n"
     "NẾU BỊ HỎI '3NF khác BCNF chỗ nào?': 3NF còn cho phép vế trái không phải khóa nếu vế phải là một phần của khóa; BCNF thì không cho ngoại lệ đó.")

# SLIDE 8 - 17/18 BCNF
s = base_slide(f"Vì sao {STATS['bcnf']} bảng đạt BCNF?", B, 0.8)
card(s, Inches(0.4), Inches(1.35), Inches(5.0), Inches(4.65), "17 bảng: đạt BCNF",
     ["Làm theo cách kiểm ở slide trước cho từng bảng",
      "Mỗi thông tin chỉ cất ở 1 chỗ",
      "Ví dụ: hóa đơn chỉ lưu mã hợp đồng, muốn biết hội viên thì tra qua hợp đồng",
      "Chứng minh đầy đủ: báo cáo mục 2.3"], size=16)
card(s, Inches(5.7), Inches(1.35), Inches(7.2), Inches(4.65), "1 ngoại lệ có chủ đích: pt_booking (buổi PT) - 2NF",
     ["Bảng buổi PT lưu thêm cột 'hội viên nào', dù đã biết được qua hợp đồng (hợp đồng → hội viên)",
      "Lý do: luật chống trùng giờ của hội viên (EXCLUDE) chỉ đọc được cột nằm trong CÙNG bảng",
      "Chống sai lệch: khóa ngoại kép bắt cặp (hợp đồng, hội viên) phải khớp đúng bảng hợp đồng",
      "Tương tự 'ngày tập' suy ra từ giờ bắt đầu → có CHECK bắt hai cột phải khớp"], size=16)
takeaway(s, "Lưu dư 1 cột có kiểm soát, đổi lấy việc chống trùng lịch hội viên chắc chắn.")
note("Vì sao 17/18 BCNF", B, 0.8,
     "17 bảng em kiểm theo cách ở slide trước và đều đạt BCNF, tức mỗi thông tin chỉ nằm ở một chỗ. Ví dụ hóa đơn chỉ lưu mã hợp đồng; muốn biết hội viên nào thì tra qua hợp đồng. "
     "Có đúng một bảng nhóm cố ý để ở mức 2NF là bảng buổi PT. Bảng này lưu thêm cột hội viên, dù biết hợp đồng là đã biết hội viên rồi, tức là suy bắc cầu. "
     "Nhóm giữ cột này vì luật chống trùng giờ của hội viên dùng EXCLUDE, mà EXCLUDE chỉ đọc được cột nằm trong cùng một bảng. "
     "Để cột dư này không bao giờ sai, nhóm thêm khóa ngoại kép: cặp hợp đồng và hội viên phải khớp đúng như trong bảng hợp đồng. "
     "Tương tự, cột ngày tập suy ra được từ giờ bắt đầu, nên có điều kiện CHECK bắt hai cột phải khớp. Tóm lại là lưu dư có kiểm soát để đổi lấy chống trùng lịch chắc chắn.")

# SLIDE 9 - EXCLUDE
s = base_slide("Chống trùng lịch bằng EXCLUDE", B, 0.8)
analogy(s, Inches(0.4), Inches(1.35), Inches(12.5), Inches(1.1),
        "Như sổ đặt phòng họp: không cho ghi hai cuộc họp cùng một phòng mà giờ đè lên nhau.", size=16)
code_box(s, Inches(0.4), Inches(2.65), Inches(7.2), Inches(3.35),
         "EXCLUDE USING gist (\n"
         "  trainer_user_id WITH =,      -- cùng một HLV\n"
         "  tsrange(start_time, end_time, '[)')\n"
         "                  WITH &&      -- và giờ đè nhau\n"
         ")                              -- => CẤM\n"
         "WHERE (status NOT IN\n"
         "  ('Cancelled','Late_Cancelled')) -- ca đã hủy\n"
         "                                  -- không giữ chỗ", size=15)
card(s, Inches(7.9), Inches(2.65), Inches(5.0), Inches(3.35), "Ví dụ",
     ["8:00-9:00 và 9:00-10:00 → hợp lệ (nối tiếp, không đè)",
      "8:00-9:00 và 8:30-9:30 → bị từ chối, lỗi 23P01",
      "Ca đã hủy không chiếm giờ"], size=16)
takeaway(s, "Khai báo một lần, PostgreSQL tự kiểm ở mọi lần ghi. UNIQUE / CHECK không làm được việc này.")
note("EXCLUDE", B, 0.8,
     "Để chống trùng lịch, nhóm dùng EXCLUDE. Hình dung như sổ đặt phòng họp: không cho ghi hai cuộc họp cùng phòng mà giờ đè lên nhau. "
     "Đọc đoạn lệnh bên trái: cấm hai dòng có cùng huấn luyện viên, dấu bằng, và khoảng giờ đè lên nhau, dấu hai chữ và. "
     "Ký hiệu ngoặc vuông mở, ngoặc tròn đóng nghĩa là tính giờ bắt đầu nhưng không tính giờ kết thúc, nên ca 8 đến 9 giờ và ca 9 đến 10 giờ nối tiếp nhau không bị coi là trùng. "
     "Dòng WHERE nghĩa là ca đã hủy thì không giữ chỗ nữa. Nếu ai cố xếp trùng, PostgreSQL trả lỗi mã 23P01. "
     "UNIQUE không làm được vì UNIQUE chỉ so bằng nhau, còn CHECK chỉ nhìn được một dòng.\n\n"
     "NẾU BỊ HỎI 'gist là gì?': là một loại chỉ mục giúp tìm nhanh các khoảng giờ đè nhau; cần thêm extension btree_gist để kết hợp được với phép so sánh bằng.")

# SLIDE 10 - CHỐNG TRÙNG LỊCH: BR NÀO, CƠ CHẾ NÀO
s = base_slide("Chống trùng lịch: luật nào dùng cách nào?", B, 0.6)
rows = [
    ["Luật", "Trùng cùng loại (EXCLUDE)", "Trùng khác loại: lớp và PT (trigger)"],
    ["BR-12  HLV không trùng giờ", "lớp - lớp, PT - PT", "lớp - PT"],
    ["BR-15  Phòng không trùng lớp", "lớp - lớp", "-"],
    ["BR-16  Hội viên không trùng giờ", "PT - PT", "lớp - PT, lớp - lớp"],
    ["BR-21  Máy tập không bị giữ trùng", "giữ máy - giữ máy", "máy đang bảo trì, ngoài giờ buổi tập"],
]
table(s, Inches(0.4), Inches(1.35), Inches(12.5), rows, [4.2, 3.7, 4.6], size=16, row_h=0.62)
card(s, Inches(0.4), Inches(4.65), Inches(12.5), Inches(1.4), "Hai người bấm đặt cùng lúc?",
     ["Trigger 'xếp hàng' theo từng HLV / hội viên (pg_advisory_xact_lock): người sau đợi người trước xong rồi mới kiểm, nên không lọt"],
     size=15)
takeaway(s, "Hai lịch cùng một bảng → EXCLUDE. Hai lịch ở hai bảng khác nhau → trigger.")
note("Chống trùng lịch theo luật", B, 0.6,
     "Bảng này trả lời câu hỏi chống trùng lịch cho luật nào. Lớp học và buổi PT nằm ở hai bảng khác nhau. "
     "Nếu hai lịch cùng loại, ví dụ hai buổi PT của cùng huấn luyện viên, thì nằm trong cùng một bảng, EXCLUDE tự chặn. "
     "Nếu một bên là lớp, một bên là buổi PT, thì nằm ở hai bảng, EXCLUDE không nhìn sang được, nên nhóm viết trigger để kiểm. "
     "Còn một tình huống khó: hai người bấm đặt cùng một lúc, cả hai cùng thấy còn trống rồi cùng lưu. Trigger của nhóm bắt họ xếp hàng theo huấn luyện viên hoặc hội viên: "
     "người sau phải đợi người trước lưu xong mới được kiểm, nên không bị lọt.")

# SLIDE 11 - TRIGGER LÀ GÌ
s = base_slide("Trigger là gì?", B, 0.6)
analogy(s, Inches(0.4), Inches(1.35), Inches(6.0), Inches(1.5),
        "Như cửa tự động có cảm biến: có người đi qua thì cửa tự mở, không ai phải bấm. "
        "Trigger tự chạy khi có thêm / sửa / xóa dữ liệu.", size=15)
card(s, Inches(0.4), Inches(3.0), Inches(6.0), Inches(3.0), "2 loại",
     ["BEFORE: chạy TRƯỚC khi lưu → có thể sửa dữ liệu hoặc chặn hẳn (báo lỗi P0001)",
      "AFTER: chạy SAU khi lưu → cập nhật bảng khác",
      f"Nhóm có 34 trigger dùng {STATS['triggers_secdef']} hàm"], size=16)
add_text(s, Inches(6.8), Inches(1.3), Inches(6.1), Inches(0.45),
         ["Ví dụ BR-25: hủy muộn"], size=18, bold=True, color=TEAL)
flow(s, Inches(6.8), Inches(1.8), Inches(6.1), Inches(0.95), Inches(0.38),
     ["Lễ tân bấm 'Hủy' một buổi PT, còn 10 giờ nữa là tới giờ tập",
      "Trigger BEFORE: thấy còn dưới 24 giờ → tự đổi thành 'Late_Cancelled' (hủy muộn)",
      "Trigger AFTER: trừ 1 buổi trong hợp đồng của hội viên"], size=15)
takeaway(s, "Trang web không cần biết luật 24 giờ - cơ sở dữ liệu tự làm.")
note("Trigger là gì", B, 0.6,
     "Trigger giống cửa tự động có cảm biến: có người đi qua thì cửa tự mở, không ai phải bấm nút. Trigger là đoạn lệnh lưu trong cơ sở dữ liệu, tự chạy khi có ai thêm, sửa hoặc xóa dữ liệu. "
     "Có hai loại: BEFORE chạy trước khi lưu, nên có thể sửa dữ liệu hoặc chặn hẳn; AFTER chạy sau khi lưu, thường để cập nhật bảng khác. "
     "Ví dụ bên phải là luật hủy muộn: lễ tân bấm hủy một buổi PT khi chỉ còn 10 giờ nữa là tới giờ tập. Trigger BEFORE thấy còn dưới 24 giờ nên tự đổi trạng thái thành hủy muộn. "
     "Sau khi lưu, trigger AFTER trừ một buổi trong hợp đồng. Trang web chỉ gửi lệnh hủy bình thường, không cần biết luật 24 giờ.")

# SLIDE 12 - CÁC TRIGGER TIÊU BIỂU
s = base_slide("Các trigger tiêu biểu của nhóm", B, 0.8)
rows = [
    ["Việc", "Trigger làm gì (lời thường)"],
    ["BR-10  Hóa đơn bất biến", "Chặn sửa, xóa hóa đơn. Thêm 3 lớp: không cấp quyền sửa; không tài khoản đăng nhập nào là 'chủ' bảng; chặn cả lệnh xóa / đổi bảng"],
    ["BR-07  Tự kích hoạt gói", "Hóa đơn chuyển 'Đã thanh toán' → hợp đồng tự chuyển Active"],
    ["BR-25  Hủy muộn", "Hủy dưới 24 giờ → đổi thành hủy muộn và trừ 1 buổi"],
    ["BR-03  Giới hạn tuổi", "Hội viên dưới 12 tuổi → từ chối"],
    ["BR-23  Lưu vết", "Tự ghi ai tạo, ai sửa, sửa lúc nào"],
    ["BR-24  Gia hạn (thủ tục)", "Chạy mỗi ngày: hết hạn / tạo hóa đơn gia hạn / tạm khóa; chạy 2 lần không sinh trùng"],
]
table(s, Inches(0.4), Inches(1.35), Inches(12.5), rows, [3.6, 8.9], size=15, row_h=0.66)
takeaway(s, "Dùng trigger khi luật phải nhìn sang bảng khác hoặc phụ thuộc thời gian.")
note("Các trigger tiêu biểu", B, 0.8,
     "Đây là các trigger tiêu biểu. Hóa đơn bất biến được bảo vệ nhiều lớp: trigger chặn sửa và xóa; không ai được cấp quyền sửa; không tài khoản đăng nhập nào là chủ của bảng; "
     "và có một trigger đặc biệt chặn cả lệnh xóa hoặc đổi cấu trúc bảng hóa đơn. "
     "Tự kích hoạt: khi hóa đơn chuyển sang đã thanh toán thì hợp đồng tự chuyển Active. Hủy muộn như slide trước. Hội viên dưới 12 tuổi bị từ chối. "
     "Lưu vết: tự ghi ai tạo, ai sửa và lúc nào. Riêng gia hạn là một thủ tục chạy mỗi ngày, vì PostgreSQL không tự hẹn giờ được; chạy hai lần cũng không sinh hóa đơn trùng. "
     "Phần của em đến đây là hết, em xin mời bạn Hoàng Tiến trình bày phần tiếp theo.")

# ============================================================================
# PHẦN 2 - LÊ HOÀNG TIẾN (slide 13-22)
# ============================================================================

# SLIDE 13 - DBMS THỰC THI TRUY VẤN
s = base_slide("PostgreSQL chạy một truy vấn thế nào?", A, 1)
analogy(s, Inches(0.4), Inches(1.35), Inches(12.5), Inches(1.05),
        "Như Google Maps: cùng một điểm đến có nhiều đường đi; PostgreSQL ước tính và chọn cách nhanh nhất.", size=16)
hflow(s, Inches(0.4), Inches(2.6), Inches(2.85), Inches(0.85), Inches(0.37),
      ["1. Đọc hiểu câu SQL", "2. Mở view thành câu gốc", "3. Lập kế hoạch: chọn cách rẻ nhất", "4. Chạy theo kế hoạch"], size=14)
card(s, Inches(0.4), Inches(3.65), Inches(5.7), Inches(2.4), "Các 'cách đi' hay gặp",
     ["Seq Scan: đọc cả bảng (lật cả cuốn sách)",
      "Index Scan: tra mục lục rồi đi thẳng tới dòng cần",
      "Hash Join: lập danh bạ một bảng rồi dò bảng kia"], size=14)
card(s, Inches(6.4), Inches(3.65), Inches(6.5), Inches(2.4), "Kế hoạch thật của Q1 (doanh thu theo gói)",
     ["① Đọc hóa đơn, giữ hóa đơn đã thanh toán trong quý",
      "② Ghép với hợp đồng (Hash Join)",
      "③ Tra tên gói bằng mục lục khóa chính (Index Scan)",
      "④ Gom theo gói, cộng tiền, sắp xếp giảm dần"], size=14, bullet=False)
takeaway(s, "Xem kế hoạch thật bằng lệnh EXPLAIN ANALYZE - đây cũng là cách nhóm đo hiệu năng.")
note("PostgreSQL chạy truy vấn", A, 1,
     "Em xin trình bày phần hai. Khi nhận một câu truy vấn, PostgreSQL làm giống Google Maps: cùng một điểm đến có nhiều đường đi, nó ước tính và chọn đường nhanh nhất. "
     "Cụ thể có bốn bước: đọc hiểu câu SQL, mở các view thành câu gốc, lập kế hoạch, rồi chạy theo kế hoạch. "
     "Kế hoạch gồm các cách đi: Seq Scan là đọc cả bảng, như lật cả cuốn sách; Index Scan là tra mục lục rồi đi thẳng tới dòng cần; Hash Join là lập danh bạ một bảng rồi dò bảng kia. "
     "Bên phải là kế hoạch thật của truy vấn 1, doanh thu theo gói: đọc hóa đơn và giữ hóa đơn đã thanh toán trong quý, ghép với hợp đồng, tra tên gói bằng mục lục, rồi gom nhóm và sắp xếp. "
     "Muốn xem kế hoạch này thì dùng lệnh EXPLAIN ANALYZE.\n\n"
     "NẾU BỊ HỎI 'sao Q1 lại đọc cả bảng?': vì dữ liệu mẫu nhỏ, đọc hết còn nhanh hơn tra mục lục; khi dữ liệu lớn PostgreSQL tự chuyển sang dùng chỉ mục.")

# SLIDE 14 - TRUY VẤN 1/2
s = base_slide("Truy vấn phức hợp (1/2): Q2, Q8", A, 0.8)
card(s, Inches(0.4), Inches(1.35), Inches(6.1), Inches(4.7), "Q2: Top 3 HLV dạy nhiều giờ nhất tháng?",
     [("Cách làm:", {"bold": True, "nobullet": True}),
      "Lấy giờ dạy PT và giờ dạy lớp, nối thành một danh sách",
      "Cộng giờ theo từng HLV, lấy 3 người cao nhất",
      ("Kỹ thuật SQL:", {"bold": True, "nobullet": True}),
      "WITH (CTE), UNION ALL, GROUP BY, ORDER BY ... LIMIT 3"], size=16)
card(s, Inches(6.8), Inches(1.35), Inches(6.1), Inches(4.7), "Q8: Mỗi nhóm tuổi thích gói nào nhất?",
     [("Cách làm:", {"bold": True, "nobullet": True}),
      "Chia hội viên theo nhóm tuổi",
      "Đếm số người theo từng gói, xếp hạng TRONG từng nhóm tuổi, lấy hạng 1",
      ("Kỹ thuật SQL:", {"bold": True, "nobullet": True}),
      "CASE, DENSE_RANK() OVER (PARTITION BY nhóm tuổi)"], size=16)
takeaway(s, "WITH (CTE) = đặt tên cho bước trung gian, như viết nháp từng bước khi giải toán.")
note("Truy vấn 1/2", A, 0.8,
     "Nhóm viết 10 truy vấn nâng cao; em giới thiệu bốn câu. Câu 2 trả lời: ba huấn luyện viên nào dạy nhiều giờ nhất tháng này? "
     "Cách làm: lấy giờ dạy PT và giờ dạy lớp, nối thành một danh sách bằng UNION ALL, cộng theo từng người, rồi lấy ba người cao nhất. "
     "WITH, hay CTE, là đặt tên cho một bước trung gian, giống viết nháp từng bước khi giải toán. "
     "Câu 8 trả lời: mỗi nhóm tuổi thích gói nào nhất? Chia hội viên theo tuổi bằng CASE, đếm số người theo gói, rồi xếp hạng riêng trong từng nhóm tuổi bằng DENSE_RANK với PARTITION BY, và lấy hạng 1.\n\n"
     "NẾU BỊ HỎI 'UNION ALL khác UNION?': UNION bỏ các dòng giống nhau, UNION ALL giữ hết; ở đây hai buổi dài bằng nhau vẫn phải cộng cả hai nên dùng UNION ALL.")

# SLIDE 15 - TRUY VẤN 2/2
s = base_slide("Truy vấn phức hợp (2/2): Q9, Q10", A, 0.8)
card(s, Inches(0.4), Inches(1.35), Inches(6.1), Inches(4.7), "Q9: Xếp hạng hội viên theo tiền đã chi",
     [("Cách làm:", {"bold": True, "nobullet": True}),
      "Cộng các hóa đơn đã thanh toán theo từng người",
      "Xếp hạng toàn bộ; chia hạng Kim Cương / Bạch Kim / Tiêu chuẩn",
      ("Kỹ thuật SQL:", {"bold": True, "nobullet": True}),
      "JOIN 3 bảng, SUM, DENSE_RANK() OVER, CASE"], size=16)
card(s, Inches(6.8), Inches(1.35), Inches(6.1), Inches(4.7), "Q10: Có HLV nào bị trùng lịch không?",
     [("Cách làm:", {"bold": True, "nobullet": True}),
      "Ghép danh sách lịch với chính nó, tìm 2 lịch cùng HLV mà giờ đè nhau",
      "Kết quả đúng là 0 dòng - vì CSDL đã chặn trùng ngay từ lúc lưu",
      ("Kỹ thuật SQL:", {"bold": True, "nobullet": True}),
      "Tự nối bảng (self-join): bắt đầu 1 < kết thúc 2 VÀ kết thúc 1 > bắt đầu 2"], size=16)
takeaway(s, "DENSE_RANK: đồng hạng thì cùng số, hạng sau không nhảy (1, 1, 2 - không phải 1, 1, 3).")
note("Truy vấn 2/2", A, 0.8,
     "Câu 9 xếp hạng hội viên theo tổng tiền đã chi: cộng các hóa đơn đã thanh toán của từng người, xếp hạng, rồi chia thành hạng Kim Cương, Bạch Kim, Tiêu chuẩn. "
     "DENSE_RANK nghĩa là hai người bằng tiền thì cùng hạng, và người tiếp theo không bị nhảy hạng. "
     "Câu 10 là truy vấn kiểm tra: có huấn luyện viên nào bị trùng lịch không? Nó ghép danh sách lịch với chính nó để tìm hai lịch cùng người mà giờ đè nhau. "
     "Kết quả đúng là không có dòng nào, vì cơ sở dữ liệu đã chặn trùng ngay từ lúc lưu, như bạn Thuận đã trình bày. Cả 10 câu đều chạy được trên trang web.")

# SLIDE 16 - TEST CASE
s = base_slide("Test case được làm thế nào?", A, 1)
analogy(s, Inches(0.4), Inches(1.35), Inches(6.2), Inches(1.6),
        "Như thử ổ khóa: thử bằng chìa SAI thì cửa phải KHÔNG mở (test âm); thử bằng chìa ĐÚNG thì cửa phải mở (test dương).", size=15)
card(s, Inches(0.4), Inches(3.1), Inches(6.2), Inches(2.95), "Cách chạy",
     ["78 test âm (TC) + 36 test dương (TP)",
      "Test âm chỉ ĐẠT khi CSDL báo ĐÚNG MÃ lỗi, không chỉ 'có lỗi'",
      "Mỗi test chạy riêng (savepoint); cuối file hoàn tác hết (ROLLBACK) → dữ liệu không bẩn"], size=15)
rows = [
    ["Mã lỗi", "Nghĩa"],
    ["23505", "Trùng giá trị (UNIQUE)"],
    ["23514", "Sai điều kiện (CHECK)"],
    ["23503", "Trỏ tới thứ không có (khóa ngoại)"],
    ["23P01", "Trùng lịch (EXCLUDE)"],
    ["P0001", "Trigger chặn"],
    ["42501", "Không đủ quyền"],
]
table(s, Inches(6.9), Inches(1.4), Inches(6.0), rows, [1.5, 4.5], size=15, row_h=0.43)
add_text(s, Inches(6.9), Inches(4.55), Inches(6.0), Inches(1.5),
         ["Ví dụ TC-01: thêm tài khoản trùng email → CSDL báo 23505 → khớp mã mong đợi → ĐẠT"],
         size=15)
takeaway(s, f"Kết quả: {STATS['tc_total']} test ràng buộc ĐẠT (file 05_constraint_test_cases.sql).")
note("Test case", A, 1,
     "Kiểm thử giống thử ổ khóa. Test âm là thử bằng chìa sai: cố tình làm sai, ví dụ tạo tài khoản trùng email, và cửa phải không mở, tức cơ sở dữ liệu phải từ chối. "
     "Test dương là thử bằng chìa đúng: làm đúng thì phải thành công. Nhóm có 78 test âm và 36 test dương. "
     "Điểm quan trọng: test âm không chỉ cần có lỗi, mà phải đúng mã lỗi. Mỗi loại lỗi có một mã gọi là SQLSTATE, bảng bên phải là các mã nhóm dùng: 23505 là trùng giá trị, 23P01 là trùng lịch, P0001 là trigger chặn, v.v. "
     "Ví dụ test TC-01: thêm tài khoản trùng email, cơ sở dữ liệu báo 23505, khớp mã mong đợi nên đạt. "
     "Mỗi test chạy riêng nên test này hỏng không ảnh hưởng test kia, và cuối file hoàn tác hết nên dữ liệu mẫu không bị bẩn. Kết quả 114 trên 114 đạt.\n\n"
     "NẾU BỊ HỎI 'sao test chạy ngày nào cũng ra cùng kết quả?': giờ trong test tính theo ngày hôm nay và đặt vào khung 21 giờ đến 24 giờ, khung mà dữ liệu mẫu cố ý để trống.")

# SLIDE 17 - HIỆU NĂNG
s = base_slide("Hiệu năng được đo ra sao?", A, 1)
hflow(s, Inches(0.4), Inches(1.4), Inches(3.9), Inches(0.95), Inches(0.4),
      ["1. Sinh tạm ~420.000 dòng giả",
       "2. Chạy mỗi truy vấn 2 lần: CÓ và TẮT chỉ mục",
       "3. Đo bằng EXPLAIN ANALYZE, xong hoàn tác dữ liệu giả"], size=14)
rows = [
    ["Mã", "Truy vấn", "Có chỉ mục", "Tắt chỉ mục", "Nhanh hơn"],
    ["PT-01", "Tìm tài khoản theo email", "0,037 ms", "14,1 ms", "382 lần"],
    ["PT-05", "Tìm hóa đơn theo số hóa đơn", "0,041 ms", "26,7 ms", "652 lần"],
    ["PT-06", "Lịch PT trong ngày của 1 HLV", "0,058 ms", "12,3 ms", "212 lần"],
    ["PT-07", "Kiểm tra trùng lịch HLV", "0,055 ms", "13,6 ms", "248 lần"],
    ["PT-08", "Q1 doanh thu theo gói (nối 3 bảng)", "13,7 ms", "41,4 ms", "3 lần"],
]
table(s, Inches(0.4), Inches(2.6), Inches(12.5), rows, [1.2, 5.2, 2.0, 2.1, 2.0], size=15, row_h=0.5)
add_text(s, Inches(0.4), Inches(5.65), Inches(12.5), Inches(0.5),
         ["Chỉ mục = mục lục của sách: có mục lục thì mở thẳng trang cần tìm, không có thì phải lật từng trang"],
         size=15, color=GREY)
takeaway(s, f"{STATS['perf_total']} truy vấn dưới {STATS['perf_limit_ms']} ms (yêu cầu NFR-PERF-01).")
note("Đo hiệu năng", A, 1,
     "Dữ liệu mẫu chỉ khoảng mười nghìn dòng, quá ít để thấy khác biệt. Nên script tự sinh tạm khoảng bốn trăm hai mươi nghìn dòng giả, đo xong thì hoàn tác. "
     "Mỗi truy vấn chạy hai lần: một lần có chỉ mục, một lần tắt chỉ mục, đo thời gian bằng EXPLAIN ANALYZE. "
     "Chỉ mục giống mục lục của cuốn sách: có mục lục thì mở thẳng trang cần tìm, không có thì phải lật từng trang. "
     "Kết quả: tìm tài khoản theo email chỉ mất 0,037 mili giây so với 14 mili giây, nhanh hơn khoảng 380 lần. Truy vấn nặng nhất là truy vấn 1 nối ba bảng, 13,7 mili giây, vẫn dưới xa giới hạn 200. "
     "Tám trên tám truy vấn đạt yêu cầu.\n\n"
     "NẾU BỊ HỎI 'sao không để luôn 420 nghìn dòng trong dữ liệu mẫu?': dữ liệu mẫu cần đúng nghiệp vụ và nạp nhanh để demo; dữ liệu lớn chỉ cần cho lúc đo nên sinh tạm rồi xóa.")

# SLIDE 18 - TỔNG HỢP KIỂM THỬ
s = base_slide("Tổng hợp kết quả kiểm thử", A, 0.4)
cards = [
    (STATS["tc_total"], "Test ràng buộc", "78 âm + 36 dương, kiểm đúng mã lỗi"),
    (STATS["rbac_total"], "Test phân quyền", "Đóng vai từng chức vụ, thử việc được / không được làm"),
    (STATS["perf_total"], f"Hiệu năng < {STATS['perf_limit_ms']} ms", "Trên ~420.000 dòng dữ liệu giả"),
]
for i, (big, ttl, sub) in enumerate(cards):
    x = Inches(0.4 + i * 4.2)
    add_rect(s, x, Inches(1.5), Inches(4.0), Inches(3.2), LIGHT, line=BORDER)
    add_text(s, x, Inches(1.65), Inches(4.0), Inches(1.2), [big], size=56, bold=True,
             color=TEAL, align=PP_ALIGN.CENTER)
    add_text(s, x + Inches(0.15), Inches(2.95), Inches(3.7), Inches(1.7),
             [(ttl, {"bold": True, "size": 20}), (sub, {"size": 15, "color": GREY})],
             align=PP_ALIGN.CENTER, space_after=4)
add_text(s, Inches(0.4), Inches(4.95), Inches(12.5), Inches(1.2),
         [f"Dữ liệu mẫu {STATS['mock_rows']} dòng, ngày tháng tính theo ngày nạp → truy vấn 'tháng này / quý này' luôn có dữ liệu",
          "Q1 - Q9 đều trả về kết quả; Q10 (kiểm tra trùng lịch) trả 0 dòng đúng như mong đợi"],
         size=16, bullet=True)
takeaway(s, "Tất cả đều ĐẠT, chạy lại được bằng một lệnh (xem phần demo dòng lệnh).")
note("Tổng hợp kiểm thử", A, 0.4,
     "Tổng hợp lại: 114 trên 114 test ràng buộc đạt; 66 trên 66 test phân quyền đạt, em sẽ nói ở slide sau; 8 trên 8 truy vấn đo hiệu năng đều dưới 200 mili giây. "
     "Dữ liệu mẫu gần mười nghìn dòng, ngày tháng tính theo ngày nạp nên các truy vấn kiểu tháng này, quý này lúc nào cũng có dữ liệu.")

# SLIDE 19 - RBAC 1/2
s = base_slide("Phân quyền RBAC ở cấp CSDL (1/2)", A, 0.9)
analogy(s, Inches(0.4), Inches(1.35), Inches(6.2), Inches(1.45),
        "Như thẻ phòng khách sạn: lễ tân, lao công, khách mỗi người một loại thẻ, chỉ mở đúng cửa của mình.", size=15)
card(s, Inches(0.4), Inches(2.95), Inches(6.2), Inches(3.1), "Nhóm làm",
     ["5 vai trò: Admin, Lễ tân, HLV, Kỹ thuật viên, Hội viên",
      "Mặc định không ai có quyền gì, rồi cấp đúng phần cần",
      "Cấp tới từng CỘT: không ai đọc được cột mật khẩu",
      "Hóa đơn chỉ đọc và thêm - kể cả Admin"], size=15)
card(s, Inches(6.9), Inches(1.35), Inches(6.0), Inches(4.7), "Một vấn đề và cách giải",
     ["HLV chỉ được sửa TRẠNG THÁI buổi PT, không được sửa hợp đồng",
      "Nhưng HLV bấm 'Hoàn thành' thì trigger phải trừ buổi trong hợp đồng → bị chặn?",
      "Giải: trigger chạy bằng quyền của chủ hàm (SECURITY DEFINER) - như được ủy quyền làm đúng 1 việc",
      "Cố định search_path để không bị lừa gọi nhầm hàm giả"], size=15)
takeaway(s, "Quyền đặt ở CSDL: vào bằng web hay gõ lệnh psql đều bị giới hạn như nhau.")
note("RBAC 1/2", A, 0.9,
     "RBAC là phân quyền theo vai trò. Giống thẻ phòng khách sạn: lễ tân, lao công, khách mỗi người một loại thẻ, chỉ mở được đúng cửa của mình. "
     "Nhóm có 5 vai trò. Mặc định không ai có quyền gì, rồi cấp đúng phần cần thiết, gọi là quyền tối thiểu. Quyền cấp tới từng cột, nên không ai đọc được cột mật khẩu. "
     "Hóa đơn chỉ được đọc và thêm, kể cả Admin cũng không sửa được. Trang web cũng đăng nhập bằng một tài khoản bị giới hạn như vậy. "
     "Có một vấn đề: huấn luyện viên chỉ được sửa trạng thái buổi PT, không được đụng vào hợp đồng. Nhưng khi huấn luyện viên bấm hoàn thành, trigger phải trừ buổi trong hợp đồng. "
     "Cách giải là cho trigger chạy bằng quyền của chủ hàm, gọi là SECURITY DEFINER, giống được ủy quyền làm đúng một việc. Kèm theo đó cố định search_path để không ai lừa được nó gọi nhầm hàm giả.\n\n"
     "NẾU BỊ HỎI 'role NOLOGIN là gì?': là vai trò không đăng nhập được, chỉ để gom quyền; tài khoản đăng nhập thật thì thừa hưởng quyền từ vai trò đó.")

# SLIDE 20 - RBAC 2/2
s = base_slide("Phân quyền RBAC ở cấp CSDL (2/2)", A, 0.7)
rows = [
    ["Bảng", "Admin", "Lễ tân", "HLV", "Kỹ thuật", "Hội viên"],
    ["Tài khoản (user_account)", "Đọc*, thêm, sửa, xóa", "Đọc*, thêm, sửa", "Đọc 4 cột", "-", "-"],
    ["Hóa đơn (billing_log)", "Đọc, thêm", "Đọc, thêm", "-", "-", "-"],
    ["Buổi PT (pt_booking)", "Đủ quyền", "Đọc, thêm, sửa", "Đọc, sửa trạng thái", "-", "-"],
    ["Thiết bị, bảo trì", "Đủ quyền", "-", "-", "Đọc, thêm, sửa", "-"],
    ["Gói tập, phòng, lịch lớp", "Đủ quyền", "Đọc", "Đọc", "Đọc phòng", "Đọc"],
]
table(s, Inches(0.4), Inches(1.35), Inches(12.5), rows, [3.4, 2.3, 2.0, 1.9, 1.6, 1.3], size=14, row_h=0.5)
add_text(s, Inches(0.4), Inches(4.4), Inches(12.5), Inches(0.4),
         ["* Đọc mọi cột TRỪ cột mật khẩu"], size=13, color=GREY)
add_text(s, Inches(0.4), Inches(4.8), Inches(12.5), Inches(1.4),
         ["Test 'bị từ chối': đóng vai lễ tân (SET ROLE), thử đọc mật khẩu → phải nhận lỗi 42501",
          "Test 'được phép': đóng vai HLV, đánh dấu buổi hoàn thành → phải thành công và buổi bị trừ",
          "SY-01..05: tự so bảng phân quyền của ứng dụng với quyền thật trong CSDL - lệch là báo lỗi"],
         size=15, bullet=True)
takeaway(s, f"Kết quả: {STATS['rbac_total']} test phân quyền ĐẠT (file 09_rbac_test_cases.sql).")
note("RBAC 2/2", A, 0.7,
     "Đây là bảng quyền rút gọn. Điểm đáng chú ý: không ai đọc được cột mật khẩu; hóa đơn chỉ đọc và thêm, kể cả Admin; huấn luyện viên chỉ sửa được cột trạng thái của buổi PT, "
     "không đổi được giờ hay hội viên; kỹ thuật viên chỉ đụng tới thiết bị. "
     "Kiểm thử phân quyền dùng lệnh SET ROLE để đóng vai từng người. Ví dụ đóng vai lễ tân thử đọc mật khẩu thì phải nhận lỗi 42501, nghĩa là không đủ quyền. "
     "Đóng vai huấn luyện viên đánh dấu buổi hoàn thành thì phải thành công và buổi bị trừ. "
     "Năm test SY tự so bảng phân quyền mà trang web dùng với quyền thật trong cơ sở dữ liệu, ai sửa một bên mà quên bên kia thì test báo ngay. Kết quả 66 trên 66 đạt.")

# SLIDE 21 - DEMO WEB
s = base_slide("Demo (1/2): giao diện web - cổng 8501", A, 2.5)
rows = [
    ["Bước", "Bấm vào đâu", "Nói gì"],
    ["1", "Thanh bên: chọn 'Người thao tác'", "Hệ thống ghi lại ai làm (BR-23)"],
    ["2", "'📊 Dashboard & Khung Nhìn' > View 1, View 2", "Số liệu tổng quan hội viên, doanh thu"],
    ["3", "'👥 Quản Lý Hội Viên' > '➕ Đăng Ký Hội Viên Mới', nhập người dưới 12 tuổi", "CSDL từ chối (BR-03)"],
    ["4", "'💳 Đăng Ký Gói Tập' > chọn hội viên, gói, thanh toán", "Trả tiền xong gói tự Active (BR-07)"],
    ["5", "'📅 Lập Lịch PT 1-1' > đặt buổi rồi 'Hủy Ca Tập PT'", "Dưới 24 giờ → hủy muộn, trừ 1 buổi (BR-25)"],
    ["6", "'🔍 10 Truy Vấn Nâng Cao' > Q2 > 'Thực Thi'", "Câu SQL + bảng + biểu đồ"],
    ["7", "'⚡ Kiểm Thử Triggers' > Test 1, 2, 3", "Thử xong tự hoàn tác, dữ liệu không bẩn"],
]
table(s, Inches(0.4), Inches(1.35), Inches(12.5), rows, [0.8, 6.6, 5.1], size=14, row_h=0.6)
takeaway(s, "Web lỗi? Chuyển ngay sang slide sau: chạy kiểm thử bằng dòng lệnh, không cần web.")
note("Demo web", A, 2.5,
     "Trước giờ demo đã bật hệ thống bằng docker compose up và mở sẵn trang web. Đi theo đúng thứ tự trong bảng, mỗi bước nói câu ở cột phải. "
     "Bước 1: chọn người thao tác ở thanh bên, hệ thống sẽ ghi lại ai làm. Bước 2: xem số liệu tổng quan. "
     "Bước 3: đăng ký một hội viên sinh sau năm 2014, cơ sở dữ liệu từ chối vì dưới 12 tuổi. Bước 4: đăng ký gói và thanh toán, chỉ cho thầy cô thấy gói tự chuyển Active. "
     "Bước 5: đặt một buổi PT rồi hủy; nếu còn dưới 24 giờ thì thành hủy muộn và số buổi giảm 1. Bước 6: chạy truy vấn 2. "
     "Bước 7: dùng trang kiểm thử trigger, mọi phép thử đều tự hoàn tác. Nếu web có sự cố, chuyển ngay sang slide sau.")

# SLIDE 22 - DEMO TERMINAL
s = base_slide("Demo (2/2): dòng lệnh Docker và psql", A, 1)
code_box(s, Inches(0.4), Inches(1.35), Inches(12.5), Inches(4.7),
         "# Bật toàn bộ hệ thống (CSDL + dữ liệu mẫu + trigger + phân quyền + web)\n"
         "docker compose up --build\n\n"
         "# Chạy 114 test ràng buộc\n"
         "docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/05_constraint_test_cases.sql\n\n"
         "# Chạy 66 test phân quyền\n"
         "docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/09_rbac_test_cases.sql\n\n"
         "# Đăng nhập bằng tài khoản lễ tân (mật khẩu demo_2026), thử đọc mật khẩu\n"
         "docker exec -it fitzone_postgres_db psql -U gym_u_reception -d gym_management\n"
         "gym_management=> SELECT password_hash FROM user_account LIMIT 1;   -- permission denied", size=14)
takeaway(s, "Bị lỗi khi demo? Mở Phụ lục C (slide 27): tra lệnh xử lý theo từng tình huống.")
note("Demo dòng lệnh", A, 1,
     "Phần này chạy trên cửa sổ dòng lệnh, mở sẵn ở thư mục dự án. Lệnh đầu bật toàn bộ hệ thống. Hai lệnh tiếp theo chạy hai bộ kiểm thử, "
     "cuối mỗi bộ có bảng tổng hợp đạt hay không đạt, chỉ cho thầy cô dòng tổng. "
     "Lệnh cuối đăng nhập bằng tài khoản lễ tân rồi thử đọc cột mật khẩu, cơ sở dữ liệu trả lỗi permission denied, tức không đủ quyền. "
     "Nếu có sự cố thì mở phụ lục C ở slide 27 để tra lệnh xử lý.")

# SLIDE 23 - PHÂN CÔNG
s = base_slide("Phân công trình bày", None)
rows = [
    ["Thành viên", "Phần trình bày", "Slide", "Thời lượng"],
    [B, "Bài toán, luật nghiệp vụ và cách giữ luật bằng DBMS, EER, chuẩn hóa, chống trùng lịch, trigger", "1 - 12", "~ 7,5 phút"],
    [A, "Truy vấn phức hợp, test case, đo hiệu năng, phân quyền RBAC, demo web và dòng lệnh", "13 - 22", "~ 9 phút"],
    ["Cả nhóm", "Hỏi đáp; phụ lục dùng khi được hỏi", "24 - 27", "~ 3 phút"],
]
table(s, Inches(0.4), Inches(1.5), Inches(12.5), rows, [2.6, 6.6, 1.6, 1.7], size=18, row_h=0.8)
takeaway(s, "Tổng khoảng 16 phút; nếu thiếu giờ thì rút ngắn demo web (bỏ bước 2 và 6).", y=5.4)
note("Phân công", "Cả nhóm", 0.3,
     "Slide này chỉ để thầy cô biết ai trình bày phần nào. Không cần đọc, chuyển sang hỏi đáp.")

# SLIDE 24 - Q&A
s = prs.slides.add_slide(BLANK)
add_rect(s, 0, 0, SW, SH, NAVY)
add_rect(s, 0, Inches(4.3), SW, Inches(0.08), TEAL)
add_text(s, Inches(0.8), Inches(1.6), Inches(11.7), Inches(2.4),
         ["Hỏi đáp (Q&A)", ("Cảm ơn thầy cô đã lắng nghe", {"size": 26, "bold": False})],
         size=54, bold=True, color=WHITE, space_after=12)
add_text(s, Inches(0.8), Inches(4.7), Inches(11.7), Inches(2.2),
         ["Mã nguồn, script và tài liệu: kho mã nhóm G9 (README.md)",
          "Chạy lại toàn bộ: docker compose up --build  |  http://localhost:8501",
          ("Phụ lục: A - thuật ngữ  |  B - mã hóa, sao lưu  |  C - xử lý sự cố demo",
           {"size": 16, "color": RGBColor(0xBF, 0xE9, 0xE3)})],
         size=20, color=WHITE, space_after=10)
note("Hỏi đáp", "Cả nhóm", 3,
     "Em xin cảm ơn thầy cô đã lắng nghe, nhóm em xin nhận câu hỏi.\n\n"
     "MẸO TRẢ LỜI: câu hỏi về thuật ngữ thì mở phụ lục A. Nếu không chắc, nói thật: 'Phần này em chưa nắm chắc, em xin phép ghi nhận và tìm hiểu thêm'. "
     "Không đoán bừa. Câu hỏi mẫu và đáp án: Phase 4/sql_defense_guide.md.\n\n"
     "CÂU HAY BỊ HỎI:\n"
     "- Trigger khác CHECK thế nào? CHECK chỉ nhìn 1 dòng; trigger nhìn được bảng khác và làm thêm việc (trừ buổi, đổi trạng thái).\n"
     "- Vì sao pt_booking chỉ 2NF? Lưu thêm cột hội viên để EXCLUDE chống trùng giờ hội viên; khóa ngoại kép giữ cho cột đó luôn đúng.\n"
     "- Hai người đặt cùng lúc? Trigger bắt xếp hàng (advisory lock), người sau đợi người trước xong mới kiểm.\n"
     "- SECURITY DEFINER là gì? Hàm chạy bằng quyền của chủ hàm, để HLV bấm hoàn thành vẫn trừ được buổi trong hợp đồng.")

# PHỤ LỤC A - THUẬT NGỮ
s = base_slide("Phụ lục A: Bảng thuật ngữ", None)
rows = [
    ["Thuật ngữ", "Nghĩa đơn giản", "Thuật ngữ", "Nghĩa đơn giản"],
    ["DBMS", "Phần mềm quản lý CSDL (PostgreSQL)", "Trigger", "Lệnh tự chạy khi dữ liệu thay đổi"],
    ["Khóa chính", "Mã riêng của mỗi dòng (như CCCD)", "Thủ tục (procedure)", "Lệnh lưu sẵn, gọi khi cần"],
    ["Khóa ngoại", "Cột trỏ tới dòng có thật ở bảng khác", "View", "Bảng ảo = câu truy vấn được đặt tên"],
    ["CHECK", "Điều kiện đúng thì mới cho lưu", "Chỉ mục (index)", "Mục lục giúp tìm nhanh"],
    ["EXCLUDE", "Cấm hai khoảng giờ đè nhau", "CTE (WITH)", "Bước trung gian được đặt tên"],
    ["Phụ thuộc hàm", "Biết X là biết chắc Y", "DENSE_RANK", "Xếp hạng, đồng hạng không nhảy số"],
    ["Giao dịch", "Nhóm lệnh: xong hết hoặc hủy hết", "ROLLBACK", "Hủy mọi thay đổi chưa chốt"],
    ["Savepoint", "Điểm lưu để hủy một phần", "SQLSTATE", "Mã lỗi chuẩn 5 ký tự"],
    ["RBAC", "Phân quyền theo vai trò", "GRANT / REVOKE", "Cấp / thu hồi quyền"],
    ["NOLOGIN role", "Vai trò chỉ gom quyền, không đăng nhập", "SECURITY DEFINER", "Hàm chạy bằng quyền của chủ hàm"],
]
table(s, Inches(0.3), Inches(1.3), Inches(12.7), rows, [2.0, 4.35, 2.2, 4.15], size=13, row_h=0.48)
note("Phụ lục thuật ngữ", "Cả nhóm", 0,
     "Slide dự phòng: khi thầy cô hỏi nghĩa của một thuật ngữ thì mở slide này. Không trình bày trong thời gian chính.")

# PHỤ LỤC B - BẢO MẬT VẬN HÀNH
s = base_slide("Phụ lục B: Mã hóa, sao lưu, khôi phục", None)
card(s, Inches(0.4), Inches(1.35), Inches(6.2), Inches(5.45), "Nói đơn giản",
     ["TLS: mã hóa đường truyền giữa web và CSDL; kết nối không mã hóa bị từ chối",
      "Sao lưu mỗi ngày, bản sao lưu được mã hóa AES-256, giữ 7 bản gần nhất",
      "WAL = nhật ký mọi thay đổi, lưu liên tục → khôi phục về đúng thời điểm trước sự cố (PITR)",
      "Hai bài kiểm tra khôi phục đều ĐẠT (18 bảng khớp số dòng)"], size=15)
code_box(s, Inches(6.9), Inches(1.35), Inches(6.0), Inches(3.0),
         "# Sao lưu ngay\n"
         "docker compose exec backup backup.sh --once\n\n"
         "# Khôi phục thử vào CSDL tạm, so 18 bảng\n"
         "docker compose exec backup verify-restore.sh\n\n"
         "# Khôi phục theo thời điểm (bản nền + WAL)\n"
         "docker compose exec backup verify-pitr.sh", size=13)
add_text(s, Inches(6.9), Inches(4.55), Inches(6.0), Inches(2.0),
         ["Chưa làm (thuộc hạ tầng máy chủ): mã hóa ổ đĩa của máy chủ"], size=14, color=GREY)
note("Phụ lục bảo mật vận hành", "Cả nhóm", 0,
     "Slide dự phòng khi được hỏi về mã hóa và sao lưu. TLS là mã hóa đường truyền giữa ứng dụng và cơ sở dữ liệu, giống https của trang web. "
     "Bản sao lưu được mã hóa và có kiểm tra khôi phục tự động. WAL là nhật ký mọi thay đổi; lưu liên tục WAL cộng với bản sao lưu nền cho phép khôi phục về đúng thời điểm trước sự cố.")

# PHỤ LỤC C - XỬ LÝ SỰ CỐ KHI DEMO
s = base_slide("Phụ lục C: Xử lý sự cố khi demo", None)
rows = [
    ["Tình huống", "Lệnh xử lý"],
    ["Web không mở được (cổng 8501)", "docker compose ps  ->  docker compose restart web"],
    ["Web báo lỗi kết nối CSDL", "docker compose logs --tail 30 db  ->  docker compose restart db web"],
    ["Container không chạy", "docker compose up -d --build"],
    ["Dữ liệu demo bị bẩn, muốn làm lại", "docker compose down -v  ->  docker compose up -d --build"],
    ["Cần chứng minh ràng buộc khi web lỗi", "docker exec -i fitzone_postgres_db psql -U gym_admin -d gym_management -f /sql/05_constraint_test_cases.sql"],
    ["Ghi dữ liệu bằng psql bị từ chối (BR-23)", "SET app.current_user_id = '3';  rồi chạy lại lệnh"],
    ["Hỏi về phân quyền", "psql -U gym_u_reception ...  ->  SELECT password_hash ...  (permission denied)"],
]
table(s, Inches(0.3), Inches(1.3), Inches(12.7), rows, [4.0, 8.7], size=13, row_h=0.62)
add_text(s, Inches(0.3), Inches(6.5), Inches(12.7), Inches(0.4),
         ["Lưu ý: down -v xóa dữ liệu demo hiện tại và nạp lại dữ liệu mẫu (~1 phút); chỉ dùng khi thật cần"],
         size=13, color=RED)
note("Phụ lục xử lý sự cố", "Cả nhóm", 0,
     "Slide dự phòng cho phần demo: tra nhanh lệnh theo tình huống. Mở sẵn một cửa sổ dòng lệnh ở thư mục dự án trước giờ demo.")

# ----------------------------------------------------------------------------
# LƯU
# ----------------------------------------------------------------------------
out_pptx = os.path.join(HERE, "deck.pptx")
prs.save(out_pptx)

lines = ["# Ghi chú thuyết trình (Speaker Notes)", "",
         "> File này được sinh tự động bởi `build_deck.py` cùng với `deck.pptx` (ghi chú cũng nằm trong phần Notes của từng slide).",
         "> Ghi chú viết dạng LỜI NÓI: có thể đọc gần nguyên văn. Dòng 'NẾU BỊ HỎI' là câu trả lời chuẩn bị sẵn, không đọc khi trình bày.", ""]
for num, title, who, mins, text in NOTES:
    lines += [f"## Slide {num} - {title}", f"**Người trình bày:** {who}  |  **Thời lượng:** ~{mins} phút", "", text, ""]
open(os.path.join(HERE, "speaker_notes.md"), "w", encoding="utf-8").write("\n".join(lines))
print("OK:", out_pptx, "-", len(prs.slides), "slide")
