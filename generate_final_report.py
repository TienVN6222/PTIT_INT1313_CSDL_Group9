# -*- coding: utf-8 -*-
"""
Script tạo hoàn chỉnh file báo cáo đồ án CSDL:
Gym_Membership_PT_Planner_Report_ISO_Standards.docx
Môn học: Cơ sở dữ liệu (INT1313) - PTIT
Nhóm 09 - G9
"""

import os
import sys
import docx
from docx import Document
from docx.shared import Inches, Pt, RGBColor
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.enum.table import WD_TABLE_ALIGNMENT
from docx.oxml import OxmlElement, parse_xml
from docx.oxml.ns import nsdecls, qn

def build_report():
    doc = Document()

    # Cài đặt Margin A4 chuẩn 1 inch (72 pt)
    for section in doc.sections:
        section.top_margin = Inches(1.0)
        section.bottom_margin = Inches(1.0)
        section.left_margin = Inches(1.0)
        section.right_margin = Inches(1.0)
        section.page_width = Inches(8.5)
        section.page_height = Inches(11.0)

    # --- CÁC HÀM TIỆN ÍCH ---
    def set_cell_shading(cell, color_hex):
        shd_xml = f'<w:shd {nsdecls("w")} w:fill="{color_hex}"/>'
        cell._tc.get_or_add_tcPr().append(parse_xml(shd_xml))

    def set_cell_margins(cell, top=70, bottom=70, left=90, right=90):
        tcPr = cell._tc.get_or_add_tcPr()
        tcMar = OxmlElement('w:tcMar')
        for m, val in [('top', top), ('bottom', bottom), ('left', left), ('right', right)]:
            node = OxmlElement(f'w:{m}')
            node.set(qn('w:w'), str(val))
            node.set(qn('w:type'), 'dxa')
            tcMar.append(node)
        tcPr.append(tcMar)

    def set_table_borders(table, color="B0C4DE", sz="4", val="single"):
        tblPr = table._tbl.tblPr
        borders_xml = f'''
        <w:tblBorders {nsdecls("w")}>
            <w:top w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:left w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:bottom w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:right w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:insideH w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
            <w:insideV w:val="{val}" w:sz="{sz}" w:space="0" w:color="{color}"/>
        </w:tblBorders>
        '''
        tblPr.append(parse_xml(borders_xml))

    def format_row(row, is_header=False, header_bg="1F4E79", header_fg="FFFFFF"):
        trPr = row._tr.get_or_add_trPr()
        trPr.append(parse_xml(f'<w:cantSplit {nsdecls("w")}/>'))
        if is_header:
            trPr.append(parse_xml(f'<w:tblHeader {nsdecls("w")}/>'))
            for cell in row.cells:
                set_cell_shading(cell, header_bg)
                set_cell_margins(cell, top=90, bottom=90, left=100, right=100)
                for p in cell.paragraphs:
                    p.alignment = WD_ALIGN_PARAGRAPH.CENTER
                    for run in p.runs:
                        run.font.bold = True
                        run.font.color.rgb = RGBColor.from_string(header_fg)
                        run.font.name = "Times New Roman"
                        run.font.size = Pt(9.5)
        else:
            for cell in row.cells:
                set_cell_margins(cell, top=60, bottom=60, left=80, right=80)
                for p in cell.paragraphs:
                    for run in p.runs:
                        run.font.name = "Times New Roman"
                        run.font.size = Pt(9)

    def add_p(text="", bold=False, italic=False, font_size=11, align=WD_ALIGN_PARAGRAPH.LEFT, space_before=0, space_after=4, line_spacing=1.15, color=None):
        p = doc.add_paragraph()
        p.alignment = align
        p.paragraph_format.space_before = Pt(space_before)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = line_spacing
        if text:
            run = p.add_run(text)
            run.bold = bold
            run.italic = italic
            run.font.name = "Times New Roman"
            run.font.size = Pt(font_size)
            if color:
                run.font.color.rgb = RGBColor.from_string(color)
        return p

    def add_bullet(bold_prefix, text, font_size=10.5, space_after=2):
        p = doc.add_paragraph(style='List Bullet')
        p.paragraph_format.space_before = Pt(0)
        p.paragraph_format.space_after = Pt(space_after)
        p.paragraph_format.line_spacing = 1.15
        if bold_prefix:
            r1 = p.add_run(bold_prefix)
            r1.bold = True
            r1.font.name = "Times New Roman"
            r1.font.size = Pt(font_size)
        r2 = p.add_run(text)
        r2.font.name = "Times New Roman"
        r2.font.size = Pt(font_size)
        return p

    def create_table(headers, data, col_widths=None, header_bg="1F4E79"):
        tbl = doc.add_table(rows=len(data) + 1, cols=len(headers))
        tbl.alignment = WD_TABLE_ALIGNMENT.CENTER
        set_table_borders(tbl)
        
        hdr_cells = tbl.rows[0].cells
        for i, h in enumerate(headers):
            hdr_cells[i].text = h
        format_row(tbl.rows[0], is_header=True, header_bg=header_bg)
        
        for r_idx, row_data in enumerate(data):
            row = tbl.rows[r_idx + 1]
            for c_idx, val in enumerate(row_data):
                row.cells[c_idx].text = str(val)
            format_row(row, is_header=False)
            if r_idx % 2 == 1:
                for cell in row.cells:
                    set_cell_shading(cell, "F2F5F9")
                    
        if col_widths:
            for r in tbl.rows:
                for i, w in enumerate(col_widths):
                    r.cells[i].width = Inches(w)
                    
        add_p("", space_after=3)
        return tbl

    # =========================================================================
    # TIÊU ĐỀ BÁO CÁO & THÔNG TIN ĐỀ TÀI
    # =========================================================================
    add_p("BÁO CÁO ĐỒ ÁN MÔN HỌC: CƠ SỞ DỮ LIỆU (INT1313)", bold=True, font_size=16, align=WD_ALIGN_PARAGRAPH.CENTER, space_before=6, space_after=12, color="1F4E79")
    
    add_p("A. THÔNG TIN ĐỀ TÀI (PROJECT IDENTITY)", bold=True, font_size=13, space_before=4, space_after=6, color="2B4C7E")
    
    info_headers = ["Thông Tin", "Chi Tiết"]
    info_data = [
        ["Tên Đề Tài (Project Title):", "Hệ Thống Quản Lý Hội Viên & Lập Kế Hoạch Huấn Luyện Viên Cá Nhân (Gym Membership & PT Planner)"],
        ["Mã Đề Tài (Project ID):", "09"],
        ["Tên Nhóm (Team Name):", "G9"],
        ["Thành Viên Thực Hiện (Members):", "1. Lê Hoàng Tiến (n25dcat050@student.ptithcm.edu.vn)\n2. Lê Hòa Thuận (n25dcat110@student.ptithcm.edu.vn)\n3. Trần Minh Tiến (n25dcat111@student.ptithcm.edu.vn)"]
    ]
    create_table(info_headers, info_data, col_widths=[2.2, 4.3], header_bg="1F4E79")

    add_p("B. NỘI DUNG BÁO CÁO (REPORT STRUCTURE)", bold=True, font_size=13, space_before=8, space_after=6, color="2B4C7E")

    # =========================================================================
    # CHƯƠNG 1: TỔNG QUAN & PHẠM VI DỰ ÁN
    # =========================================================================
    add_p("1. Tổng Quan & Phạm Vi Dự Án", bold=True, font_size=12, space_before=6, space_after=4, color="003366")
    
    add_p("1.1. TÌNH HUỐNG GIẢ ĐỊNH: BÀI TOÁN TỐI ƯU HÓA VẬN HÀNH TẠI TRUNG TÂM THỂ HÌNH \"TITAN FITNESS & WELLNESS\"", bold=True, font_size=11, space_before=4, space_after=3)
    
    add_p("1.1.1. Bối cảnh & Mô hình hoạt động của Phòng Gym", bold=True, italic=True, font_size=11, space_before=3, space_after=2)
    add_p("Titan Fitness & Wellness là một trung tâm thể hình – chăm sóc sức khỏe quy mô tầm trung với hơn 3.000 hội viên hoạt động thường xuyên. Để vận hành trơn tru và mang lại trải nghiệm chuyên nghiệp cho khách hàng, trung tâm tổ chức 6 bộ phận nghiệp vụ liên kết chặt chẽ:")
    add_bullet("• Bộ phận Lễ tân / Thu ngân (Front Desk): ", "Chịu trách nhiệm tiếp đón, kiểm soát vào/ra qua mã QR/thẻ RFID, kiểm tra điều kiện gói tập, cấp phát tủ đồ trong ngày, tra cứu và kích hoạt cho khách tập thử, đồng thời lọc danh sách nhắc hạn hội viên.")
    add_bullet("• Bộ phận Tư vấn bán hàng (Sales / Membership Consultant): ", "Tìm kiếm và quản lý khách hàng tiềm năng (Leads), cập nhật pipeline tư vấn, tạo lịch hẹn trải nghiệm tập thử, tư vấn gói tập, lập hợp đồng hội viên/PT, thu tiền cọc và theo dõi đôn đốc công nợ.")
    add_bullet("• Huấn luyện viên cá nhân (Personal Trainer - PT): ", "Thiết lập lịch rảnh/bận, nhận lịch hẹn tập 1-1 với học viên, điểm danh hoàn thành buổi tập để tự động trừ số buổi trong gói PT, quản lý tiến độ học viên và theo dõi chỉ số hiệu suất cá nhân (KPI).")
    add_bullet("• Huấn luyện viên lớp nhóm (Group Fitness Instructor): ", "Quản lý và thực hiện lịch giảng dạy các lớp nhóm (Yoga, Zumba, Cycling...) tại các phòng studio chuyên biệt, thực hiện điểm danh học viên thực tế theo sĩ số trần của phòng.")
    add_bullet("• Kỹ thuật & Tạp vụ (Facility / Maintenance / Cleaning): ", "Quản lý danh mục máy móc thiết bị (Cardio, tạ khối, phụ kiện) và vị trí đặt máy, cập nhật nhanh trạng thái máy và thực thi kế hoạch bảo dưỡng định kỳ tuần/tháng (Preventive Maintenance).")
    add_bullet("• Quản lý phòng tập (Club Manager): ", "Cấu hình bảng giá và chính sách dịch vụ gói tập/lớp nhóm, phê duyệt các ngoại lệ hợp đồng (bảo lưu đóng băng ngày, chuyển nhượng, hủy/hoàn tiền), theo dõi báo cáo phân tích doanh thu và lưu lượng ra vào.")

    add_p("1.1.2. Thực trạng & Những bất cập vận hành (Pain Points)", bold=True, italic=True, font_size=11, space_before=4, space_after=2)
    add_p("Trước đây, Titan Fitness chủ yếu quản lý qua Google Sheets kết hợp ghi chép sổ sách thủ công. Khi quy mô hội viên gia tăng nhanh chóng, trung tâm liên tục đối mặt với các vấn đề nhức nhối:")
    add_bullet("• Lỗ hổng kiểm soát ra vào và thất thoát doanh thu: ", "Hội viên đã hết hạn thẻ hoặc đang trong thời gian bảo lưu (đóng băng) vẫn vào tập bình thường do lễ tân không kiểm tra kịp. Hội viên mua gói khung giờ thấp điểm (Off-peak) tự do vào tập giờ cao điểm gây quá tải.")
    add_bullet("• Bất cập đồng bộ khách tập thử giữa Sales và Lễ tân: ", "Bộ phận Sales hẹn khách tới tập thử nhưng ghi nhận riêng lẻ. Khi khách tới quầy, Lễ tân không có dữ liệu để xác minh, khiến khách phải chờ đợi lâu hoặc bị từ chối vào trải nghiệm, làm đứt gãy phễu bán hàng.")
    add_bullet("• Khủng hoảng xung đột lịch hẹn PT và phòng chức năng (Collision Crisis): ", "Lễ tân và PT thường xuyên nhắn tin xếp lịch riêng với khách qua điện thoại/Zalo, dẫn đến việc 1 PT bị trùng 2 khách cùng giờ, hoặc 2 PT cùng dẫn khách vào một phòng PT Private Studio tại cùng thời điểm.")
    add_bullet("• Quá tải sĩ số lớp học nhóm (Class Overcapacity): ", "Các lớp Yoga, Zumba có sức chứa tối đa (ví dụ 20 người/phòng), nhưng do hội viên đăng ký tự do không có hệ thống kiểm soát thời gian thực, nhiều buổi sĩ số vọt lên 25–30 người gây chật chội, thiếu thảm và mất an toàn.")
    add_bullet("• Rối loạn quản lý công nợ, cọc và ngoại lệ hợp đồng: ", "Khách hàng đóng cọc hoặc trả góp nhiều lần nhưng kế toán không theo dõi được hạn chót công nợ. Khi khách xin bảo lưu hoặc chuyển nhượng hợp đồng, nhân viên tính toán sai số ngày bù trừ dẫn đến thất thoát.")
    add_bullet("• Thiết bị hỏng hóc đột xuất và thiếu kế hoạch bảo dưỡng: ", "Trung tâm thiếu lịch bảo trì định kỳ, máy móc chỉ được kiểm tra khi đã hỏng hoàn toàn. Lễ tân không cập nhật kịp trạng thái máy nên vẫn xếp lịch cho học viên vào phòng có máy hỏng.")

    add_p("1.1.3. Nhu cầu giải pháp & Định hình phạm vi tinh gọn (System Scope & Exclusions)", bold=True, italic=True, font_size=11, space_before=4, space_after=2)
    add_p("Để giải quyết triệt để các bất cập trên mà vẫn đảm bảo tính khả thi, chuẩn hóa và chuyên sâu cho đồ án Cơ sở Dữ liệu, Nhóm 09 định hình phạm vi hệ thống theo nguyên tắc tinh gọn chuẩn hóa:")
    add_bullet("• Phạm vi cốt lõi: ", "Tập trung xây dựng CSDL quản lý hội viên & nhân viên, luồng khách tiềm năng & tập thử, hợp đồng dịch vụ & công nợ, kiểm soát vào/ra qua QR, tủ đồ locker, lịch hẹn PT 1-1, lớp nhóm và danh mục thiết bị kèm lịch bảo dưỡng định kỳ.")
    add_bullet("• Tuyên bố loại bỏ các tính năng không cần thiết (Project Scope Exclusions):", "")
    add_p("   - KHÔNG xây dựng phân hệ Ticket/Issue tracker: Loại bỏ quy trình phiếu báo sự cố phức tạp (không tạo bảng repair_tickets, ticket_logs). Thay vào đó, quản lý trực tiếp qua thuộc tính trạng thái máy (equipment.status: active, maintenance, inactive) và bảng kế hoạch bảo dưỡng định kỳ (maintenance_schedules).", italic=True, font_size=10.5)
    add_p("   - KHÔNG làm phân hệ Bán lẻ POS tại quầy: Loại bỏ toàn bộ các bảng bán nước, thực phẩm bổ sung, phụ kiện tại quầy bar/tạp hóa (không tạo bảng products, retail_invoices, retail_invoice_items, inventory_items) để tập trung toàn vẹn vào dịch vụ thể hình.", italic=True, font_size=10.5)
    add_p("   - KHÔNG đo chỉ số cơ thể InBody chuyên sâu: Loại bỏ bảng inbody_records, ưu tiên tối ưu hóa lịch tập và quản lý quyền lợi gói tập của hội viên.", italic=True, font_size=10.5)

    add_p("1.2. Mục tiêu hệ thống (System Objectives)", bold=True, font_size=11, space_before=6, space_after=3)
    add_bullet("• Phân biệt giữa Yêu cầu Người dùng (User Requirements) và Năng lực Hệ thống (System Capabilities):", "")
    add_p("   - User Requirements: Hội viên quét mã vào cửa tức thì, đặt lịch PT không bị trùng; Lễ tân tra cứu nhanh khách tập thử do Sales đẩy xuống; Sales quản lý lead và công nợ hợp đồng; HLV điểm danh trừ buổi chính xác; Kỹ thuật theo dõi lịch bảo dưỡng định kỳ.", font_size=10.5)
    add_p("   - System Capabilities: RDBMS cung cấp các cơ chế khóa giao dịch (Transaction Isolation), ràng buộc loại trừ thời gian (Temporal Exclusion Constraints), quản lý nhật ký thanh toán bất biến (Immutable Logs), và phân quyền dữ liệu chặt chẽ.", font_size=10.5)
    add_bullet("• Yêu cầu chức năng theo 6 vai trò tinh gọn (Functional Requirements):", "")
    add_p("   - FR-01 (Lễ tân / Thu ngân): Quét mã QR/RFID xác thực vào cửa; kiểm tra điều kiện gói tập, trạng thái bảo lưu và khung giờ Off-peak; tự động ghi checkin_logs; cấp phát/thu hồi tủ đồ ngẫu nhiên trong ngày; tra cứu và kích hoạt khách tập thử; lọc hội viên sắp hết hạn hoặc bỏ tập lâu ngày.", font_size=10.5)
    add_p("   - FR-02 (Tư vấn bán hàng - Sales): Tiếp nhận và quản lý leads, cập nhật pipeline tư vấn; tạo lịch đăng ký tập thử (trial_registrations) đồng bộ sang Lễ tân; lập hợp đồng dịch vụ hội viên/PT, ghi nhận thanh toán cọc/toàn phần, quản lý công nợ và hạn chót nợ.", font_size=10.5)
    add_p("   - FR-03 (Huấn luyện viên cá nhân - PT): Quản lý khung giờ rảnh/bận; đặt ca hẹn 1-1 và điểm danh hoàn thành buổi tập để tự động trừ số buổi trong gói PT của học viên; tra cứu học viên phụ trách; theo dõi tổng số ca dạy hoàn thành trong tháng để tính KPI hoa hồng.", font_size=10.5)
    add_p("   - FR-04 (Huấn luyện viên lớp nhóm): Xem lịch giảng dạy các lớp nhóm phụ trách (thời gian, phòng studio, tên lớp); xem danh sách đăng ký trước theo sĩ số trần; đánh dấu điểm danh thực tế học viên tham gia lớp.", font_size=10.5)
    add_p("   - FR-05 (Kỹ thuật & Tạp vụ): Tra cứu danh mục thiết bị, nhóm máy và vị trí đặt máy; cập nhật trực tiếp trạng thái máy (Hoạt động bình thường, Đang bảo trì, Ngừng sử dụng); xem và đánh dấu hoàn thành kế hoạch bảo dưỡng máy móc định kỳ theo tuần/tháng.", font_size=10.5)
    add_p("   - FR-06 (Quản lý phòng tập - Club Manager): Cấu hình bảng giá gói tập (theo thời gian, theo buổi PT, gói Off-peak) và lớp nhóm; phê duyệt ngoại lệ hợp đồng (bảo lưu đóng băng, chuyển nhượng, hủy/hoàn tiền); xem báo cáo doanh số theo nhân viên/gói, báo cáo lưu lượng check-in theo giờ và tỷ lệ gia hạn thẻ.", font_size=10.5)

    add_p("1.3. Quy tắc nghiệp vụ & Ràng buộc (Business Rules & Constraints)", bold=True, font_size=11, space_before=6, space_after=3)
    add_bullet("• BR-01 (Kiểm soát Ra/Vào & Giờ Off-peak): ", "Hội viên chỉ được check-in vào cửa khi hợp đồng đang ở trạng thái 'Active' và ngày hiện tại nằm trong khoảng [start_date, end_date]. Nếu gói tập là Off-peak (is_off_peak = TRUE), thời điểm check-in phải nằm trong khung giờ quy định (ví dụ: 09:00 - 16:00). Mọi lần quét thẻ đều lưu vào checkin_logs kèm trạng thái (thành công hoặc từ chối kèm lý do).")
    add_bullet("• BR-02 (Quản lý Tủ đồ Locker trong ngày): ", "Tủ đồ chỉ được cấp phát ngẫu nhiên/tạm thời cho hội viên đang có mặt tại phòng tập. Một tủ đồ tại một thời điểm chỉ có 1 hội viên sử dụng (status = 'Occupied'). Khi trả tủ, trạng thái chuyển về 'Available'. Tủ hỏng có trạng thái 'Broken' và bị khóa không cấp phát.")
    add_bullet("• BR-03 (Đồng bộ Khách tập thử giữa Sales & Lễ tân): ", "Khách tập thử được Sales tạo lịch trên hệ thống (trial_registrations) với khóa ngoại created_by_sales_id. Khi khách đến, Lễ tân tra cứu danh sách và kích hoạt check-in, hệ thống tự động cập nhật is_checked_in = TRUE, checked_in_at = CURRENT_TIMESTAMP và ghi nhận checked_in_by_receptionist_id.")
    add_bullet("• BR-04 (Hợp đồng, Thu cọc & Quản lý Công nợ): ", "Hợp đồng dịch vụ ghi nhận tổng giá trị, số tiền đã thanh toán (paid_amount), số tiền còn nợ (remaining_debt = total_amount - paid_amount). Hợp đồng chỉ kích hoạt khi tiền thanh toán >= tiền cọc tối thiểu. Nếu còn nợ, phải xác định hạn chót thanh toán (debt_deadline). Khi duyệt bảo lưu, ngày kết thúc hợp đồng được cộng bù số ngày đóng băng. Khi duyệt chuyển nhượng, đổi member_id người thụ hưởng.")
    add_bullet("• BR-05 (Chống trùng lịch PT & Phòng tập): ", "Một Huấn luyện viên không được có 2 lịch hẹn giao nhau về mặt thời gian (Overlapping Time Intervals). Một hội viên không thể tham gia 2 lịch tập cùng lúc. Một phòng chức năng riêng không được xếp đồng thời 2 ca tập.")
    add_bullet("• BR-06 (Giới hạn Sĩ số Lớp nhóm): ", "Số lượng học viên đăng ký lớp nhóm không được vượt quá sức chứa tối đa của phòng học tương ứng (current_enrolled <= max_capacity).")
    add_bullet("• BR-07 (Bảo dưỡng Thiết bị Định kỳ): ", "Thiết bị có trạng thái 'maintenance' hoặc 'inactive' không được đưa vào sử dụng. Lịch bảo dưỡng định kỳ ghi nhận ngày lên lịch (scheduled_date), ngày hoàn thành thực tế (completed_at) và kỹ thuật viên thực hiện (performed_by_employee_id).")
    add_bullet("• BR-08 (Nhật ký Thanh toán Bất biến): ", "Mỗi giao dịch thu tiền (cọc, toàn phần, trả nợ) đều sinh hóa đơn duy nhất trong billing_logs. Bản ghi thanh toán thành công không bao giờ được xóa hoặc sửa (Immutable Log) phục vụ kiểm toán tài chính.")

    # =========================================================================
    # CHƯƠNG 2: THIẾT KẾ CƠ SỞ DỮ LIỆU
    # =========================================================================
    add_p("2. Thiết Kế Cơ Sở Dữ Liệu", bold=True, font_size=12, space_before=8, space_after=4, color="003366")
    
    add_p("2.1. Mô hình Quan niệm (Conceptual Model - IE Crow's Foot Notation)", bold=True, font_size=11, space_before=4, space_after=3)
    add_p("Mô hình quan hệ thực thể được thiết kế theo ký pháp Information Engineering (IE) Crow's Foot chuẩn công nghiệp, phản ánh chính xác cấu trúc nghiệp vụ tinh gọn:")
    add_bullet("• EMPLOYEES (1) ----- (0..N) LEADS: ", "Một nhân viên Sales quản lý theo dõi nhiều khách hàng tiềm năng.")
    add_bullet("• EMPLOYEES (1) ----- (0..N) TRIAL_REGISTRATIONS (vai trò Sales): ", "Một nhân viên Sales tạo lịch cho nhiều khách tập thử.")
    add_bullet("• EMPLOYEES (1) ----- (0..N) TRIAL_REGISTRATIONS (vai trò Lễ tân): ", "Một Lễ tân xác nhận check-in cho nhiều khách tập thử.")
    add_bullet("• EMPLOYEES (1) ----- (0..N) MEMBER_CONTRACTS: ", "Một nhân viên Sales phụ trách chốt nhiều hợp đồng dịch vụ.")
    add_bullet("• EMPLOYEES (1) ----- (0..N) PT_BOOKINGS: ", "Một HLV cá nhân phụ trách thực hiện nhiều buổi dạy 1-1.")
    add_bullet("• EMPLOYEES (1) ----- (0..N) CLASS_SCHEDULES: ", "Một HLV lớp nhóm giảng dạy nhiều ca học.")
    add_bullet("• EMPLOYEES (1) ----- (0..N) MAINTENANCE_SCHEDULES: ", "Một kỹ thuật viên thực hiện bảo dưỡng định kỳ nhiều thiết bị.")
    add_bullet("• MEMBERS (1) ----- (0..N) MEMBER_CONTRACTS (N) ----- (1) MEMBERSHIP_PLANS: ", "Hội viên ký hợp đồng gói dịch vụ.")
    add_bullet("• MEMBER_CONTRACTS (1) ----- (0..N) BILLING_LOGS: ", "Một hợp đồng có một hoặc nhiều đợt thanh toán (cọc, toàn phần, trả góp).")
    add_bullet("• MEMBERS (1) ----- (0..N) CHECKIN_LOGS: ", "Nhật ký quét mã vào/ra phòng gym của hội viên.")
    add_bullet("• MEMBERS (1) ----- (0..1) LOCKERS: ", "Hội viên đang tập mượn tạm thời 1 tủ đồ trong ngày.")
    add_bullet("• MEMBERS (1) ----- (0..N) PT_BOOKINGS: ", "Hội viên đặt lịch tập 1-1 với Huấn luyện viên.")
    add_bullet("• CLASS_SCHEDULES (1) ----- (0..N) CLASS_BOOKINGS (N) ----- (1) MEMBERS: ", "Hội viên đăng ký và tham gia lớp học nhóm.")
    add_bullet("• FACILITIES_ROOMS (1) ----- (0..N) CLASS_SCHEDULES / PT_BOOKINGS: ", "Phòng tập bố trí tổ chức lớp học hoặc ca PT.")
    add_bullet("• FACILITIES_ROOMS (1) ----- (0..N) EQUIPMENT (1) ----- (0..N) MAINTENANCE_SCHEDULES: ", "Phòng tập chứa máy móc thiết bị, thiết bị có lịch bảo dưỡng định kỳ.")

    add_p("2.2. Ánh xạ Lược đồ Logic (Logical Schema Mapping)", bold=True, font_size=11, space_before=6, space_after=3)
    add_p("Các lược đồ quan hệ chuẩn hóa (Khóa chính gạch chân đậm, Khóa ngoại in nghiêng/FK):")
    add_p("• EMPLOYEES (employee_id, full_name, role, email, phone, status, hire_date)", font_size=10)
    add_p("• MEMBERS (member_id, full_name, email, phone, dob, join_date, status)", font_size=10)
    add_p("• LEADS (lead_id, full_name, phone, source, pipeline_status, assigned_sales_id, last_contact_date, next_follow_up, notes)", font_size=10)
    add_p("• TRIAL_REGISTRATIONS (trial_id, lead_id, full_name, phone, trial_date, created_by_sales_id, is_checked_in, checked_in_at, checked_in_by_receptionist_id, status)", font_size=10)
    add_p("• MEMBERSHIP_PLANS (plan_id, plan_name, plan_type, duration_months, price, max_pt_sessions, is_off_peak, peak_start_time, peak_end_time)", font_size=10)
    add_p("• MEMBER_CONTRACTS (contract_id, member_id, plan_id, sales_rep_id, start_date, end_date, total_amount, deposit_amount, paid_amount, remaining_debt, debt_deadline, remaining_pt_sessions, contract_status)", font_size=10)
    add_p("• BILLING_LOGS (billing_id, contract_id, invoice_no, payment_type, amount, payment_date, payment_method, payment_status, processed_by_staff_id)", font_size=10)
    add_p("• CHECKIN_LOGS (log_id, member_id, trial_id, checkin_time, checkin_type, status, rejection_reason, receptionist_id)", font_size=10)
    add_p("• LOCKERS (locker_id, locker_number, gender_zone, status, current_member_id, assigned_at)", font_size=10)
    add_p("• FACILITIES_ROOMS (room_id, room_name, zone_type, max_capacity, operational_status)", font_size=10)
    add_p("• EQUIPMENT (equipment_id, equipment_name, category, room_id, brand, purchase_date, status)", font_size=10)
    add_p("• MAINTENANCE_SCHEDULES (schedule_id, equipment_id, scheduled_date, maintenance_task, completed_at, performed_by_employee_id, cost, status)", font_size=10)
    add_p("• CLASS_SCHEDULES (schedule_id, class_name, instructor_id, room_id, start_time, end_time, max_capacity, current_enrolled)", font_size=10)
    add_p("• CLASS_BOOKINGS (booking_id, schedule_id, member_id, booked_at, is_attended)", font_size=10)
    add_p("• PT_BOOKINGS (pt_booking_id, member_id, trainer_id, room_id, start_time, end_time, session_status, completed_at)", font_size=10)

    add_p("2.3. Chứng minh Chuẩn hóa Dữ liệu (Normalization Verification: 1NF -> 3NF/BCNF)", bold=True, font_size=11, space_before=6, space_after=3)
    add_bullet("• Chuẩn 1NF (First Normal Form): ", "Tất cả các thuộc tính trong mọi bảng đều mang giá trị nguyên tố (Atomic Values), không chứa danh sách đa trị hay thuộc tính lặp. Ví dụ: SĐT và Email được chuẩn hóa thành các trường đơn nhất; lịch sử thanh toán hay nhật ký vào ra được phân rã thành các quan hệ riêng biệt.")
    add_bullet("• Chuẩn 2NF (Second Normal Form): ", "Hệ thống thỏa mãn 1NF và không tồn tại bất kỳ phụ thuộc hàm bộ phận nào vào khóa chính. Với các bảng liên kết n-n như CLASS_BOOKINGS hay quan hệ thực thể, mọi thuộc tính không khóa đều phụ thuộc đầy đủ vào toàn bộ khóa chính đơn hoặc cặp khóa ngoại có ràng buộc UNIQUE.")
    add_bullet("• Chuẩn 3NF (Third Normal Form): ", "Hệ thống thỏa mãn 2NF và loại bỏ hoàn toàn Phụ thuộc hàm bắc cầu (Transitive Functional Dependencies). Ví dụ: Bảng Member_Contracts không lưu tên gói tập hay giá gốc mà chỉ tham chiếu qua plan_id; số tiền còn nợ được kiểm soát qua công thức và đối soát nhật ký hóa đơn; thiết bị tách biệt thông tin máy móc với lịch bảo dưỡng định kỳ.")
    add_bullet("• Chuẩn BCNF (Boyce-Codd Normal Form): ", "Với mọi phụ thuộc hàm không tầm thường X -> A trong hệ thống, vế trái X bắt buộc phải là một Siêu khóa (Superkey). Thiết kế lược đồ tinh gọn không chứa các dị thường thêm/xóa/sửa, bảo toàn phụ thuộc hàm và không làm mất thông tin khi phân rã.")
    add_bullet("• Đánh giá tác động loại bỏ (Optimization Impact): ", "Việc chủ động loại bỏ các bảng bán lẻ POS (products, retail_invoices), InBody và Ticket sự cố giúp lược đồ loại trừ hơn 7 bảng dư thừa, giảm tải hơn 40% chi phí duy trì chỉ mục (Index maintenance) và loại bỏ hoàn toàn nguy cơ mất nhất quán dữ liệu do các phân hệ không cốt lõi mang lại.")

    # =========================================================================
    # CHƯƠNG 3: TỪ ĐIỂN DỮ LIỆU (DATA DICTIONARY)
    # =========================================================================
    add_p("3. Từ Điển Dữ Liệu (Data Dictionary)", bold=True, font_size=12, space_before=8, space_after=4, color="003366")
    
    dict_headers = ["Thuộc Tính", "Kiểu Dữ Liệu", "Loại Khóa", "Null?", "Mặc Định", "Ràng Buộc Nghiệp Vụ"]
    widths = [1.3, 1.2, 0.7, 0.5, 0.9, 1.9]

    # Bảng 1: EMPLOYEES
    add_p("BẢNG 1: EMPLOYEES (Quản lý Nhân sự & Phân quyền Vận hành)", bold=True, font_size=10.5, space_before=4, space_after=2)
    emp_data = [
        ["employee_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh duy nhất của nhân viên."],
        ["full_name", "VARCHAR(100)", "None", "No", "None", "Họ và tên nhân viên, không để trống."],
        ["role", "VARCHAR(30)", "None", "No", "None", "CHECK IN ('Receptionist', 'Sales', 'Trainer', 'Instructor', 'Technician', 'Manager')."],
        ["email", "VARCHAR(100)", "Unique", "No", "None", "Email công vụ duy nhất, định dạng RFC 5322."],
        ["phone", "VARCHAR(15)", "Unique", "No", "None", "Số điện thoại liên hệ duy nhất (10-15 chữ số)."],
        ["status", "VARCHAR(20)", "None", "No", "'Active'", "CHECK IN ('Active', 'OnLeave', 'Resigned')."],
        ["hire_date", "DATE", "None", "No", "CURRENT_DATE", "Ngày bắt đầu làm việc tại phòng tập."]
    ]
    create_table(dict_headers, emp_data, widths)

    # Bảng 2: MEMBERS
    add_p("BẢNG 2: MEMBERS (Hồ sơ Hội viên)", bold=True, font_size=10.5, space_before=4, space_after=2)
    mem_data = [
        ["member_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh duy nhất của hội viên."],
        ["full_name", "VARCHAR(100)", "None", "No", "None", "Họ và tên hội viên, không để trống."],
        ["email", "VARCHAR(100)", "Unique", "No", "None", "Email hội viên duy nhất."],
        ["phone", "VARCHAR(15)", "Unique", "No", "None", "Số điện thoại hội viên duy nhất."],
        ["dob", "DATE", "None", "Yes", "NULL", "Ngày sinh (CHECK dob <= CURRENT_DATE - 12 năm)."],
        ["join_date", "DATE", "None", "No", "CURRENT_DATE", "Ngày mở hồ sơ đăng ký tại trung tâm."],
        ["status", "VARCHAR(20)", "None", "No", "'Active'", "CHECK status IN ('Active', 'Inactive', 'Banned')."]
    ]
    create_table(dict_headers, mem_data, widths)

    # Bảng 3: LEADS
    add_p("BẢNG 3: LEADS (Khách hàng Tiềm năng & Phễu Chăm sóc)", bold=True, font_size=10.5, space_before=4, space_after=2)
    lead_data = [
        ["lead_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh khách hàng tiềm năng."],
        ["full_name", "VARCHAR(100)", "None", "No", "None", "Họ tên khách hàng tiềm năng."],
        ["phone", "VARCHAR(15)", "None", "No", "None", "Số điện thoại liên hệ."],
        ["source", "VARCHAR(50)", "None", "No", "'Walk-in'", "Nguồn khách: 'Facebook Ads', 'Google', 'Walk-in', 'Referral'."],
        ["pipeline_status", "VARCHAR(30)", "None", "No", "'New'", "CHECK IN ('New', 'Contacted', 'Trial_Booked', 'Won', 'Lost')."],
        ["assigned_sales_id", "INT", "FK", "Yes", "NULL", "FK -> EMPLOYEES(employee_id) (Nhân viên Sales phụ trách)."],
        ["last_contact_date", "DATETIME", "None", "Yes", "NULL", "Thời điểm tương tác liên hệ gần nhất."],
        ["next_follow_up", "DATETIME", "None", "Yes", "NULL", "Lịch hẹn gọi điện/chăm sóc tiếp theo."],
        ["notes", "TEXT", "None", "Yes", "NULL", "Ghi chú nhu cầu, ngân sách, thói quen tập luyện."]
    ]
    create_table(dict_headers, lead_data, widths)

    # Bảng 4: TRIAL_REGISTRATIONS
    add_p("BẢNG 4: TRIAL_REGISTRATIONS (Khách Đăng ký Tập thử - Đồng bộ Sales & Lễ tân)", bold=True, font_size=10.5, space_before=4, space_after=2)
    trial_data = [
        ["trial_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã đăng ký buổi tập thử."],
        ["lead_id", "INT", "FK", "Yes", "NULL", "FK -> LEADS(lead_id) (nếu chuyển đổi từ Lead)."],
        ["full_name", "VARCHAR(100)", "None", "No", "None", "Họ tên khách tập thử."],
        ["phone", "VARCHAR(15)", "None", "No", "None", "Số điện thoại đăng ký."],
        ["trial_date", "DATE", "None", "No", "None", "Ngày hẹn đến trải nghiệm tập thử."],
        ["created_by_sales_id", "INT", "FK", "No", "None", "FK -> EMPLOYEES(employee_id) (Sales lập hồ sơ hẹn trải nghiệm)."],
        ["is_checked_in", "BOOLEAN", "None", "No", "FALSE", "Trạng thái check-in thực tế tại quầy lễ tân."],
        ["checked_in_at", "DATETIME", "None", "Yes", "NULL", "Thời điểm Lễ tân xác nhận khách vào trải nghiệm."],
        ["checked_in_by_receptionist_id", "INT", "FK", "Yes", "NULL", "FK -> EMPLOYEES(employee_id) (Lễ tân xác nhận check-in tại quầy)."],
        ["status", "VARCHAR(20)", "None", "No", "'Pending'", "CHECK IN ('Pending', 'Completed', 'NoShow', 'Cancelled')."]
    ]
    create_table(dict_headers, trial_data, widths)

    # Bảng 5: MEMBERSHIP_PLANS
    add_p("BẢNG 5: MEMBERSHIP_PLANS (Danh mục Gói Dịch vụ & Cấu hình Giờ Tập)", bold=True, font_size=10.5, space_before=4, space_after=2)
    plan_data = [
        ["plan_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh gói dịch vụ."],
        ["plan_name", "VARCHAR(50)", "Unique", "No", "None", "Tên gói tập (Classic, VIP, Diamond, Off-Peak 12M...)."],
        ["plan_type", "VARCHAR(30)", "None", "No", "'Membership'", "CHECK IN ('Membership', 'PT_Package', 'Combo')."],
        ["duration_months", "INT", "None", "No", "1", "Thời hạn hiệu lực tính theo tháng (CHECK > 0)."],
        ["price", "DECIMAL(12,2)", "None", "No", "0.00", "Đơn giá niêm yết (CHECK price >= 0)."],
        ["max_pt_sessions", "INT", "None", "No", "0", "Số buổi PT kèm theo gói tập (CHECK >= 0)."],
        ["is_off_peak", "BOOLEAN", "None", "No", "FALSE", "Cờ đánh dấu gói giới hạn khung giờ thấp điểm."],
        ["peak_start_time", "TIME", "None", "Yes", "NULL", "Giờ bắt đầu khung giờ thấp điểm (nếu có)."],
        ["peak_end_time", "TIME", "None", "Yes", "NULL", "Giờ kết thúc khung giờ thấp điểm (nếu có)."]
    ]
    create_table(dict_headers, plan_data, widths)

    # Bảng 6: MEMBER_CONTRACTS
    add_p("BẢNG 6: MEMBER_CONTRACTS (Hợp đồng Gói tập, Thu cọc & Quản lý Công nợ)", bold=True, font_size=10.5, space_before=4, space_after=2)
    contract_data = [
        ["contract_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh hợp đồng."],
        ["member_id", "INT", "FK", "No", "None", "FK -> MEMBERS(member_id)."],
        ["plan_id", "INT", "FK", "No", "None", "FK -> MEMBERSHIP_PLANS(plan_id)."],
        ["sales_rep_id", "INT", "FK", "No", "None", "FK -> EMPLOYEES(employee_id) (Sales phụ trách tính doanh số)."],
        ["start_date", "DATE", "None", "No", "CURRENT_DATE", "Ngày bắt đầu có hiệu lực."],
        ["end_date", "DATE", "None", "No", "None", "CHECK (end_date >= start_date)."],
        ["total_amount", "DECIMAL(12,2)", "None", "No", "None", "Tổng giá trị hợp đồng sau chiết khấu (CHECK > 0)."],
        ["deposit_amount", "DECIMAL(12,2)", "None", "No", "0.00", "Số tiền cọc tối thiểu để giữ chỗ (CHECK >= 0)."],
        ["paid_amount", "DECIMAL(12,2)", "None", "No", "0.00", "Tổng số tiền khách thực tế đã thanh toán."],
        ["remaining_debt", "DECIMAL(12,2)", "None", "No", "0.00", "Số tiền còn nợ (CHECK remaining_debt >= 0)."],
        ["debt_deadline", "DATE", "None", "Yes", "NULL", "Hạn chót thanh toán hết nợ còn lại."],
        ["remaining_pt_sessions", "INT", "None", "No", "0", "Số buổi PT còn lại trong gói (CHECK >= 0)."],
        ["contract_status", "VARCHAR(20)", "None", "No", "'Active'", "CHECK IN ('Active', 'Frozen', 'Transferred', 'Expired', 'Cancelled')."]
    ]
    create_table(dict_headers, contract_data, widths)

    # Bảng 7: BILLING_LOGS
    add_p("BẢNG 7: BILLING_LOGS (Nhật ký Thu tiền & Hóa đơn Giao dịch)", bold=True, font_size=10.5, space_before=4, space_after=2)
    billing_data = [
        ["billing_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã giao dịch thanh toán."],
        ["contract_id", "INT", "FK", "No", "None", "FK -> MEMBER_CONTRACTS(contract_id)."],
        ["invoice_no", "VARCHAR(30)", "Unique", "No", "None", "Mã hóa đơn duy nhất (VD: INV-2026-0001)."],
        ["payment_type", "VARCHAR(30)", "None", "No", "'Full'", "CHECK IN ('Deposit', 'Full', 'Debt_Payment', 'Refund')."],
        ["amount", "DECIMAL(12,2)", "None", "No", "None", "Số tiền giao dịch thực thu (CHECK amount > 0)."],
        ["payment_date", "DATETIME", "None", "No", "CURRENT_TIMESTAMP", "Thời điểm phát sinh giao dịch."],
        ["payment_method", "VARCHAR(30)", "None", "No", "'CreditCard'", "CHECK IN ('CreditCard', 'BankTransfer', 'Cash', 'E-Wallet')."],
        ["payment_status", "VARCHAR(20)", "None", "No", "'Success'", "CHECK IN ('Success', 'Failed', 'Pending', 'Refunded')."],
        ["processed_by_staff_id", "INT", "FK", "No", "None", "FK -> EMPLOYEES(employee_id) (Nhân viên thu ngân xử lý)."]
    ]
    create_table(dict_headers, billing_data, widths)

    # Bảng 8: CHECKIN_LOGS
    add_p("BẢNG 8: CHECKIN_LOGS (Nhật ký Vào/Ra & Kiểm soát Cửa)", bold=True, font_size=10.5, space_before=4, space_after=2)
    checkin_data = [
        ["log_id", "BIGINT AUTO_INCREMENT", "PK", "No", "None", "Mã bản ghi nhật ký quét mã."],
        ["member_id", "INT", "FK", "Yes", "NULL", "FK -> MEMBERS(member_id) (nếu là hội viên chính thức)."],
        ["trial_id", "INT", "FK", "Yes", "NULL", "FK -> TRIAL_REGISTRATIONS(trial_id) (nếu là khách tập thử)."],
        ["checkin_time", "DATETIME", "None", "No", "CURRENT_TIMESTAMP", "Thời điểm quét mã tại cửa kiểm soát."],
        ["checkin_type", "VARCHAR(20)", "None", "No", "'Member'", "CHECK IN ('Member', 'Trial', 'Guest')."],
        ["status", "VARCHAR(20)", "None", "No", "'Granted'", "CHECK IN ('Granted', 'Denied')."],
        ["rejection_reason", "VARCHAR(150)", "None", "Yes", "NULL", "Lý do từ chối: 'Hết hạn gói', 'Đang bảo lưu', 'Ngoài giờ Off-peak'..."],
        ["receptionist_id", "INT", "FK", "Yes", "NULL", "FK -> EMPLOYEES(employee_id) (Lễ tân trực ca xác thực)."]
    ]
    create_table(dict_headers, checkin_data, widths)

    # Bảng 9: LOCKERS
    add_p("BẢNG 9: LOCKERS (Quản lý Tủ đồ trong ngày)", bold=True, font_size=10.5, space_before=4, space_after=2)
    locker_data = [
        ["locker_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh tủ đồ."],
        ["locker_number", "VARCHAR(20)", "Unique", "No", "None", "Số hiển thị trên tủ đồ (VD: L-M-01, L-F-05)."],
        ["gender_zone", "VARCHAR(10)", "None", "No", "'Male'", "CHECK IN ('Male', 'Female', 'Unisex')."],
        ["status", "VARCHAR(20)", "None", "No", "'Available'", "CHECK IN ('Available', 'Occupied', 'Broken')."],
        ["current_member_id", "INT", "FK", "Yes", "NULL", "FK -> MEMBERS(member_id) (Hội viên đang mượn tạm)."],
        ["assigned_at", "DATETIME", "None", "Yes", "NULL", "Thời điểm cấp phát chìa khóa trong ca tập."]
    ]
    create_table(dict_headers, locker_data, widths)

    # Bảng 10: FACILITIES_ROOMS
    add_p("BẢNG 10: FACILITIES_ROOMS (Phòng Tập & Khu Vực Chức Năng)", bold=True, font_size=10.5, space_before=4, space_after=2)
    room_data = [
        ["room_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã phòng hoặc khu vực tập luyện."],
        ["room_name", "VARCHAR(50)", "Unique", "No", "None", "Tên phòng (Studio Yoga, Studio Zumba, PT Private, Cardio Zone)."],
        ["zone_type", "VARCHAR(30)", "None", "No", "None", "CHECK IN ('Studio', 'PT_Private', 'Cardio_Zone', 'Free_Weight')."],
        ["max_capacity", "INT", "None", "No", "1", "Sức chứa tối đa của phòng (CHECK max_capacity > 0)."],
        ["operational_status", "VARCHAR(20)", "None", "No", "'Operational'", "CHECK IN ('Operational', 'Under_Maintenance', 'Closed')."]
    ]
    create_table(dict_headers, room_data, widths)

    # Bảng 11: EQUIPMENT
    add_p("BẢNG 11: EQUIPMENT (Danh mục Thiết bị Máy móc Phòng Gym)", bold=True, font_size=10.5, space_before=4, space_after=2)
    equip_data = [
        ["equipment_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã định danh máy móc thiết bị."],
        ["equipment_name", "VARCHAR(100)", "None", "No", "None", "Tên máy (Máy chạy bộ Treadmill T800, Giàn kéo cáp...)."],
        ["category", "VARCHAR(50)", "None", "No", "None", "CHECK IN ('Cardio', 'Pin_Loaded', 'Plate_Loaded', 'Accessory')."],
        ["room_id", "INT", "FK", "No", "None", "FK -> FACILITIES_ROOMS(room_id) (Vị trí đặt máy)."],
        ["brand", "VARCHAR(50)", "None", "Yes", "NULL", "Thương hiệu sản xuất (LifeFitness, Matrix, Technogym...)."],
        ["purchase_date", "DATE", "None", "Yes", "NULL", "Ngày nhập thiết bị về trung tâm."],
        ["status", "VARCHAR(20)", "None", "No", "'Active'", "CHECK IN ('Active', 'Maintenance', 'Inactive')."]
    ]
    create_table(dict_headers, equip_data, widths)

    # Bảng 12: MAINTENANCE_SCHEDULES
    add_p("BẢNG 12: MAINTENANCE_SCHEDULES (Kế hoạch Bảo dưỡng Định kỳ Máy móc)", bold=True, font_size=10.5, space_before=4, space_after=2)
    maint_data = [
        ["schedule_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã kế hoạch bảo dưỡng."],
        ["equipment_id", "INT", "FK", "No", "None", "FK -> EQUIPMENT(equipment_id)."],
        ["scheduled_date", "DATE", "None", "No", "None", "Ngày bảo dưỡng định kỳ dự kiến (tuần/tháng)."],
        ["maintenance_task", "VARCHAR(200)", "None", "No", "None", "Nội dung bảo dưỡng: 'Tra dầu bôi trơn', 'Siết ốc khung', 'Kiểm tra cáp'."],
        ["completed_at", "DATETIME", "None", "Yes", "NULL", "Thời điểm kỹ thuật hoàn thành thực tế."],
        ["performed_by_employee_id", "INT", "FK", "Yes", "NULL", "FK -> EMPLOYEES(employee_id) (Kỹ thuật viên thực hiện)."],
        ["cost", "DECIMAL(10,2)", "None", "No", "0.00", "Chi phí phụ tùng bảo dưỡng nếu có (CHECK >= 0)."],
        ["status", "VARCHAR(20)", "None", "No", "'Pending'", "CHECK IN ('Pending', 'In_Progress', 'Completed', 'Skipped')."]
    ]
    create_table(dict_headers, maint_data, widths)

    # Bảng 13: CLASS_SCHEDULES
    add_p("BẢNG 13: CLASS_SCHEDULES (Lịch Lớp học Nhóm)", bold=True, font_size=10.5, space_before=4, space_after=2)
    class_sched_data = [
        ["schedule_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã lịch lớp học nhóm."],
        ["class_name", "VARCHAR(50)", "None", "No", "None", "Tên lớp học (Zumba Dance, Ashtanga Yoga, Cycling Power...)."],
        ["instructor_id", "INT", "FK", "No", "None", "FK -> EMPLOYEES(employee_id) (HLV phụ trách lớp)."],
        ["room_id", "INT", "FK", "No", "None", "FK -> FACILITIES_ROOMS(room_id)."],
        ["start_time", "DATETIME", "None", "No", "None", "Thời gian bắt đầu ca học."],
        ["end_time", "DATETIME", "None", "No", "None", "Thời gian kết thúc (CHECK end_time > start_time)."],
        ["max_capacity", "INT", "None", "No", "20", "Sĩ số tối đa của lớp học (phù hợp với sức chứa phòng)."],
        ["current_enrolled", "INT", "None", "No", "0", "Sĩ số đã đăng ký thực tế (CHECK <= max_capacity)."]
    ]
    create_table(dict_headers, class_sched_data, widths)

    # Bảng 14: CLASS_BOOKINGS
    add_p("BẢNG 14: CLASS_BOOKINGS (Đăng ký & Điểm danh Học viên Lớp học Nhóm)", bold=True, font_size=10.5, space_before=4, space_after=2)
    class_book_data = [
        ["booking_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã đăng ký tham gia lớp học."],
        ["schedule_id", "INT", "FK", "No", "None", "FK -> CLASS_SCHEDULES(schedule_id)."],
        ["member_id", "INT", "FK", "No", "None", "FK -> MEMBERS(member_id)."],
        ["booked_at", "DATETIME", "None", "No", "CURRENT_TIMESTAMP", "Thời điểm học viên đặt chỗ."],
        ["is_attended", "BOOLEAN", "None", "No", "FALSE", "Điểm danh thực tế: TRUE (Có mặt), FALSE (Vắng mặt)."]
    ]
    create_table(dict_headers, class_book_data, widths)

    # Bảng 15: PT_BOOKINGS
    add_p("BẢNG 15: PT_BOOKINGS (Lịch Hẹn Cá Nhân 1-1 với Huấn Luyện Viên PT)", bold=True, font_size=10.5, space_before=4, space_after=2)
    pt_book_data = [
        ["pt_booking_id", "INT AUTO_INCREMENT", "PK", "No", "None", "Mã buổi tập 1-1 với PT."],
        ["member_id", "INT", "FK", "No", "None", "FK -> MEMBERS(member_id)."],
        ["trainer_id", "INT", "FK", "No", "None", "FK -> EMPLOYEES(employee_id) (HLV cá nhân phụ trách)."],
        ["room_id", "INT", "FK", "No", "None", "FK -> FACILITIES_ROOMS(room_id)."],
        ["start_time", "DATETIME", "None", "No", "None", "Thời gian bắt đầu ca tập 1-1."],
        ["end_time", "DATETIME", "None", "No", "None", "Thời gian kết thúc (CHECK end_time > start_time)."],
        ["session_status", "VARCHAR(20)", "None", "No", "'Scheduled'", "CHECK IN ('Scheduled', 'Completed', 'Cancelled', 'NoShow')."],
        ["completed_at", "DATETIME", "None", "Yes", "NULL", "Thời điểm PT xác nhận hoàn thành ca (kích hoạt trừ buổi)."]
    ]
    create_table(dict_headers, pt_book_data, widths)

    # =========================================================================
    # SƠ ĐỒ EER VÀ BẢNG MÔ TẢ ĐỐI TƯỢNG - MỐI QUAN HỆ
    # =========================================================================
    add_p("SƠ ĐỒ EER (BẢNG MÔ TẢ CÁC ĐỐI TƯỢNG VÀ MỐI QUAN HỆ)", bold=True, font_size=11, space_before=6, space_after=4, color="1F4E79")
    
    eer_headers = ["Thực Thể Nguồn", "Quan Hệ (Relationship)", "Thực Thể Đích", "Bản Số (Cardinality)", "Ý Nghĩa Nghiệp Vụ"]
    eer_data = [
        ["EMPLOYEES", "Quản lý / Chăm sóc", "LEADS", "1 : 0..N", "Nhân viên Sales phụ trách chăm sóc nhiều khách tiềm năng."],
        ["EMPLOYEES", "Đăng ký trải nghiệm", "TRIAL_REGISTRATIONS", "1 : 0..N", "Sales tạo hồ sơ đăng ký tập thử cho khách."],
        ["EMPLOYEES", "Xác nhận vào cửa", "TRIAL_REGISTRATIONS", "1 : 0..N", "Lễ tân xác nhận check-in cho khách tập thử."],
        ["EMPLOYEES", "Ký kết / Doanh số", "MEMBER_CONTRACTS", "1 : 0..N", "Sales ký hợp đồng gói dịch vụ với hội viên."],
        ["EMPLOYEES", "Huấn luyện kèm 1-1", "PT_BOOKINGS", "1 : 0..N", "PT phụ trách các ca tập cá nhân của học viên."],
        ["EMPLOYEES", "Giảng dạy lớp nhóm", "CLASS_SCHEDULES", "1 : 0..N", "HLV đứng lớp giảng dạy các ca học nhóm."],
        ["EMPLOYEES", "Bảo dưỡng máy móc", "MAINTENANCE_SCHEDULES", "1 : 0..N", "Kỹ thuật viên thực hiện bảo dưỡng máy định kỳ."],
        ["MEMBERS", "Ký hợp đồng", "MEMBER_CONTRACTS", "1 : 0..N", "Hội viên tham gia một hoặc nhiều gói tập theo thời gian."],
        ["MEMBERSHIP_PLANS", "Quy định dịch vụ", "MEMBER_CONTRACTS", "1 : 0..N", "Mỗi gói tập áp dụng cho nhiều hợp đồng."],
        ["MEMBER_CONTRACTS", "Phát sinh thu tiền", "BILLING_LOGS", "1 : 1..N", "Một hợp đồng có các đợt thanh toán (cọc, tất toán, trả nợ)."],
        ["MEMBERS", "Quét mã vào/ra", "CHECKIN_LOGS", "1 : 0..N", "Ghi nhận lịch sử vào cửa của hội viên."],
        ["MEMBERS", "Mượn tủ trong ngày", "LOCKERS", "1 : 0..1", "Hội viên mượn tối đa 1 tủ đồ khi đang tập."],
        ["MEMBERS", "Đăng ký lớp", "CLASS_BOOKINGS", "1 : 0..N", "Hội viên giữ chỗ và điểm danh trong lớp học nhóm."],
        ["CLASS_SCHEDULES", "Bao gồm người học", "CLASS_BOOKINGS", "1 : 0..N", "Lớp học nhóm tập hợp các lượt đặt chỗ của học viên."],
        ["MEMBERS", "Tập cá nhân 1-1", "PT_BOOKINGS", "1 : 0..N", "Hội viên tham gia các ca tập với huấn luyện viên."],
        ["FACILITIES_ROOMS", "Bố trí ca tập PT", "PT_BOOKINGS", "1 : 0..N", "Phòng chức năng được xếp lịch phục vụ ca PT."],
        ["FACILITIES_ROOMS", "Tổ chức lớp học", "CLASS_SCHEDULES", "1 : 0..N", "Phòng Studio tổ chức các lớp nhóm."],
        ["FACILITIES_ROOMS", "Chứa thiết bị", "EQUIPMENT", "1 : 0..N", "Phòng tập bố trí các máy móc, tạ, phụ kiện."],
        ["EQUIPMENT", "Lên lịch bảo trì", "MAINTENANCE_SCHEDULES", "1 : 0..N", "Máy móc có các mốc bảo dưỡng định kỳ tuần/tháng."]
    ]
    create_table(eer_headers, eer_data, [1.4, 1.4, 1.4, 0.9, 1.8], header_bg="2B4C7E")

    # Nhúng hình ảnh sơ đồ EER nếu tồn tại
    if os.path.exists("extracted_eer.png"):
        p_img = doc.add_paragraph()
        p_img.alignment = WD_ALIGN_PARAGRAPH.CENTER
        p_img.paragraph_format.space_before = Pt(6)
        p_img.paragraph_format.space_after = Pt(8)
        run_img = p_img.add_run()
        run_img.add_picture("extracted_eer.png", width=Inches(6.2))
        add_p("Hình 2.1: Sơ đồ Thực thể Liên kết Mở rộng (EER Diagram) - Trung tâm Titan Fitness & Wellness", italic=True, font_size=9.5, align=WD_ALIGN_PARAGRAPH.CENTER, space_after=8)

    # =========================================================================
    # CHƯƠNG 4: KIỂM THỬ TOÀN VẸN & AN NINH DỮ LIỆU
    # =========================================================================
    add_p("4. Kiểm Thử Toàn Vẹn & An Ninh Dữ Liệu (Verification & Security)", bold=True, font_size=12, space_before=8, space_after=4, color="003366")
    
    add_p("4.1. Kịch bản Kiểm Thử Ràng Buộc (Constraint Verification Test Cases)", bold=True, font_size=11, space_before=4, space_after=3)
    add_p("Các ca kiểm thử chứng minh CSDL từ chối dữ liệu vi phạm (Negative Testing & Business Constraint Testing):")

    tc_headers = ["Mã Test Case", "Mục Đích Kiểm Thử", "Câu Lệnh Thực Thi (Test SQL)", "Kết Quả Kỳ Vọng (Expected Result)"]
    tc_data = [
        [
            "TC-01",
            "Chống trùng SĐT Hội viên (UNIQUE)",
            "INSERT INTO members (full_name, email, phone) VALUES ('Nguyen Van B', 'b@gmail.com', '0901234567');\n-- (Biết '0901234567' đã tồn tại)",
            "Database ném lỗi ER_DUP_ENTRY: Duplicate entry '0901234567' for key 'phone'."
        ],
        [
            "TC-02",
            "Chặn check-in khi gói hết hạn hoặc đang bảo lưu (Trigger)",
            "INSERT INTO checkin_logs (member_id, checkin_time, checkin_type) VALUES (5, NOW(), 'Member');\n-- (Biết hợp đồng hội viên 5 đã hết hạn hoặc đang Frozen)",
            "Trigger ném lỗi SIGNAL 45000: 'Check-in bị từ chối: Hợp đồng hội viên không hợp lệ hoặc đang bị đóng băng!'."
        ],
        [
            "TC-03",
            "Chặn vào cửa ngoài khung giờ đối với gói Off-peak",
            "INSERT INTO checkin_logs (member_id, checkin_time, checkin_type) VALUES (8, '2026-09-10 18:30:00', 'Member');\n-- (Hội viên 8 mua gói Off-peak 09:00 - 16:00, quét thẻ lúc 18h30)",
            "Trigger phát hiện vi phạm khung giờ và ném lỗi SIGNAL 45000: 'Check-in bị từ chối: Gói Off-peak chỉ được phép vào cửa trong khung giờ quy định!'."
        ],
        [
            "TC-04",
            "Đồng bộ khách tập thử: Lễ tân chỉ check-in khi có đăng ký của Sales",
            "UPDATE trial_registrations SET is_checked_in = TRUE, checked_in_at = NOW(), checked_in_by_receptionist_id = 2 WHERE trial_id = 999;\n-- (trial_id 999 chưa từng được Sales tạo)",
            "Hệ thống báo 0 rows affected hoặc lỗi FK Constraint. Lễ tân không thể tự ý kích hoạt vé trải nghiệm nếu thiếu hồ sơ Sales."
        ],
        [
            "TC-05",
            "Chống trùng lịch hẹn PT của Huấn luyện viên (Trigger)",
            "INSERT INTO pt_bookings (member_id, trainer_id, room_id, start_time, end_time) VALUES (2, 3, 101, '2026-09-15 09:00', '2026-09-15 10:00');\n-- (PT 3 đã có lịch 09:30 - 10:30)",
            "Trigger phát lỗi SIGNAL 45000: 'Xung đột lịch: Huấn luyện viên đã có ca tập khác trong khung giờ này!'."
        ],
        [
            "TC-06",
            "Chống vượt quá sĩ số trần phòng học nhóm (CHECK / Trigger)",
            "UPDATE class_schedules SET current_enrolled = 25 WHERE schedule_id = 1;\n-- (Biết max_capacity của lớp và phòng chỉ là 20)",
            "Database ném lỗi CHECK constraint 'chk_class_capacity' violated (hoặc Trigger báo phòng đã hết chỗ)."
        ],
        [
            "TC-07",
            "Khóa phòng / thiết bị khi đang bảo trì",
            "INSERT INTO pt_bookings (member_id, trainer_id, room_id, start_time, end_time) VALUES (1, 2, 105, '2026-09-16 08:00', '2026-09-16 09:00');\n-- (Room 105 có operational_status = 'Under_Maintenance')",
            "Trigger ném lỗi SIGNAL 45000: 'Lỗi: Phòng tập đang bảo trì, không thể xếp lịch ca tập!'."
        ],
        [
            "TC-08",
            "Ràng buộc tính toàn vẹn công nợ hợp đồng (CHECK)",
            "INSERT INTO member_contracts (member_id, plan_id, sales_rep_id, total_amount, paid_amount, remaining_debt) VALUES (1, 1, 4, 10000000, 3000000, 5000000);\n-- (Biết 10tr - 3tr = 7tr != 5tr)",
            "Database ném lỗi CHECK constraint 'chk_contract_debt' violated: remaining_debt must equal total_amount - paid_amount."
        ]
    ]
    create_table(tc_headers, tc_data, [0.8, 1.8, 2.3, 2.0], header_bg="1F4E79")

    # Lưu tài liệu
    output_filename = "Gym_Membership_PT_Planner_Report_ISO_Standards.docx"
    doc.save(output_filename)
    print(f"Report saved successfully to {output_filename}")

if __name__ == "__main__":
    build_report()
