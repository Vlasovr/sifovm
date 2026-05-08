#!/usr/bin/env python3
"""Generate a detailed A3 structural cache schematic for the coursework report."""

from __future__ import annotations

import subprocess
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.pagesizes import A3, landscape
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas


PROJECT_DIR = Path(__file__).resolve().parents[1]
OUT_PDF = PROJECT_DIR / "schemes" / "pdf" / "A4_cache_4way_structural_detailed.pdf"
OUT_GRAPHICS = PROJECT_DIR / "documents" / "graphics" / "Доп_лист_9а_Кэш_структурная_схема.pdf"
OUT_PNG_PREFIX = PROJECT_DIR / "documents" / "images" / "cache_structural_detailed"
FONT_REG = "CourseworkArial"
FONT_BOLD = "CourseworkArialBold"
FONT_PATH = Path("C:/Windows/Fonts/arial.ttf")
BOLD_FONT_PATH = Path("C:/Windows/Fonts/arialbd.ttf")

PAGE_W, PAGE_H = landscape(A3)


def register_fonts() -> None:
    if FONT_REG not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_REG, str(FONT_PATH)))
    if FONT_BOLD not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_BOLD, str(BOLD_FONT_PATH)))


def y_top(y: float) -> float:
    return PAGE_H - y


def rect_y(y: float, h: float) -> float:
    return PAGE_H - y - h


def text_center(c: canvas.Canvas, x: float, y: float, w: float, h: float, text: str, size: float = 7, bold: bool = False) -> None:
    font = FONT_BOLD if bold else FONT_REG
    c.setFont(font, size)
    lines = text.split("\n")
    line_h = size * 1.15
    start_y = y + h / 2 - (len(lines) - 1) * line_h / 2
    for idx, line in enumerate(lines):
        c.drawCentredString(x + w / 2, y_top(start_y + idx * line_h), line)


def box(c: canvas.Canvas, x: float, y: float, w: float, h: float, label: str, size: float = 7, stroke=colors.black, fill=None, dash=None) -> None:
    c.saveState()
    c.setStrokeColor(stroke)
    c.setLineWidth(0.75)
    if dash:
        c.setDash(dash)
    if fill is None:
        fill = colors.white
    c.setFillColor(fill)
    c.rect(x, rect_y(y, h), w, h, stroke=1, fill=1)
    c.restoreState()
    text_center(c, x, y, w, h, label, size=size)


def outline_box(c: canvas.Canvas, x: float, y: float, w: float, h: float, label_text: str = "", size: float = 6.5, dash=None) -> None:
    c.saveState()
    c.setStrokeColor(colors.HexColor("#777777"))
    c.setLineWidth(0.75)
    if dash:
        c.setDash(dash)
    c.rect(x, rect_y(y, h), w, h, stroke=1, fill=0)
    c.restoreState()
    if label_text:
        label(c, x + 8, y + 13, label_text, size, True)


def tiny_box(c: canvas.Canvas, x: float, y: float, w: float, h: float, label: str = "", size: float = 5.5) -> None:
    box(c, x, y, w, h, label, size=size, stroke=colors.HexColor("#777777"))


def pin(c: canvas.Canvas, x: float, y: float, label: str, signal: str, w: float = 88) -> None:
    c.setFont(FONT_REG, 6.2)
    c.drawString(x, y_top(y + 3), label)
    tiny_box(c, x + 2, y + 12, w, 11, signal, size=5.4)
    line(c, x + 2 + w, y + 17.5, x + 125, y + 17.5)
    dot(c, x + 125, y + 17.5)


def line(c: canvas.Canvas, x1: float, y1: float, x2: float, y2: float, width: float = 0.75, color=colors.black) -> None:
    c.saveState()
    c.setStrokeColor(color)
    c.setLineWidth(width)
    c.line(x1, y_top(y1), x2, y_top(y2))
    c.restoreState()


def polyline(c: canvas.Canvas, pts: list[tuple[float, float]], width: float = 0.75) -> None:
    for (x1, y1), (x2, y2) in zip(pts, pts[1:]):
        line(c, x1, y1, x2, y2, width=width)


def arrow(c: canvas.Canvas, x1: float, y1: float, x2: float, y2: float, width: float = 0.75) -> None:
    line(c, x1, y1, x2, y2, width=width)
    c.saveState()
    c.setFillColor(colors.black)
    if abs(x2 - x1) >= abs(y2 - y1):
        if x2 >= x1:
            pts = [(x2, y2), (x2 - 6, y2 - 3), (x2 - 6, y2 + 3)]
        else:
            pts = [(x2, y2), (x2 + 6, y2 - 3), (x2 + 6, y2 + 3)]
    else:
        if y2 >= y1:
            pts = [(x2, y2), (x2 - 3, y2 - 6), (x2 + 3, y2 - 6)]
        else:
            pts = [(x2, y2), (x2 - 3, y2 + 6), (x2 + 3, y2 + 6)]
    p = c.beginPath()
    p.moveTo(pts[0][0], y_top(pts[0][1]))
    p.lineTo(pts[1][0], y_top(pts[1][1]))
    p.lineTo(pts[2][0], y_top(pts[2][1]))
    p.close()
    c.drawPath(p, stroke=0, fill=1)
    c.restoreState()


def dot(c: canvas.Canvas, x: float, y: float, r: float = 2.2) -> None:
    c.saveState()
    c.setFillColor(colors.black)
    c.circle(x, y_top(y), r, stroke=0, fill=1)
    c.restoreState()


def label(c: canvas.Canvas, x: float, y: float, text: str, size: float = 6, bold: bool = False) -> None:
    c.setFont(FONT_BOLD if bold else FONT_REG, size)
    c.drawString(x, y_top(y), text)


def bus_label(c: canvas.Canvas, x: float, y: float, text: str) -> None:
    c.saveState()
    c.setFillColor(colors.white)
    c.setStrokeColor(colors.HexColor("#999999"))
    c.rect(x, rect_y(y - 7, 12), 98, 12, stroke=1, fill=1)
    c.restoreState()
    text_center(c, x, y - 7, 98, 12, text, size=5.2)


def and_gate(c: canvas.Canvas, x: float, y: float, name: str) -> None:
    tiny_box(c, x, y, 34, 18, name, 4.8)
    label(c, x + 8, y + 12, "&", 8, True)


def or_gate(c: canvas.Canvas, x: float, y: float, name: str) -> None:
    tiny_box(c, x, y, 38, 20, name, 4.8)
    label(c, x + 12, y + 13, ">=1", 6, True)


def title_block(c: canvas.Canvas) -> None:
    x, y, w, h = 835, 724, 330, 95
    c.setStrokeColor(colors.black)
    c.setLineWidth(0.75)
    c.rect(x, rect_y(y, h), w, h, stroke=1, fill=0)
    for dx in [42, 86, 132, 180, 222, 265]:
        line(c, x + dx, y, x + dx, y + h, 0.5)
    for dy in [18, 36, 54, 72]:
        line(c, x, y + dy, x + 180, y + dy, 0.5)
    c.setFont(FONT_REG, 6)
    c.drawString(x + 6, y_top(y + 13), "Изм.")
    c.drawString(x + 49, y_top(y + 13), "Лист")
    c.drawString(x + 94, y_top(y + 13), "N докум.")
    c.drawString(x + 139, y_top(y + 13), "Подп.")
    c.drawString(x + 187, y_top(y + 13), "Дата")
    c.setFont(FONT_REG, 6.5)
    c.drawString(x + 7, y_top(y + 31), "Разраб.")
    c.drawString(x + 49, y_top(y + 31), "Миронов")
    c.drawString(x + 7, y_top(y + 49), "Пров.")
    c.drawString(x + 49, y_top(y + 49), "Воронов")
    c.drawString(x + 7, y_top(y + 67), "Н. контр.")
    c.setFont(FONT_BOLD, 14)
    c.drawString(x + 190, y_top(y + 29), "ГУИР.400201.307")
    c.setFont(FONT_REG, 8)
    c.drawCentredString(x + 252, y_top(y + 53), "Блок кэш-памяти")
    c.drawCentredString(x + 252, y_top(y + 67), "Схема структурная")
    c.setFont(FONT_REG, 6.5)
    c.drawString(x + 278, y_top(y + 84), "Лист 1")
    c.drawString(x + 307, y_top(y + 84), "Листов 1")


def draw_way(c: canvas.Canvas, idx: int, x: float) -> None:
    w = 126
    data_y = 370
    tag_y = 520
    valid_y = 665
    box(c, x, data_y, w, 58, f"cache_data_way{idx}\nDATA[{idx}]\n16 x 16", size=5.9)
    tiny_box(c, x + 84, data_y + 12, 25, 28, "RAM", 5.2)
    box(c, x, tag_y, w, 58, f"cache_tag_way{idx}\nTAG[{idx}]\n16 x 12", size=5.9)
    tiny_box(c, x + 84, tag_y + 12, 25, 28, "RAM", 5.2)
    box(c, x + 8, valid_y, 52, 45, f"valid_r\nway{idx}", size=5.5)
    box(c, x + 70, valid_y, 52, 45, f"age_r\nway{idx}", size=5.5)
    box(c, x + 10, 603, 104, 32, f"tag_compare_way{idx}\nTAG == A[15:4]", size=5.1)

    # Vertical lane buses.
    line(c, x - 10, 300, x - 10, 710, 1.2)
    dot(c, x - 10, 300)
    dot(c, x - 10, 342)
    dot(c, x - 10, 724)

    # Inputs to data/tag/valid/age memories.
    line(c, x - 10, 300, x, data_y + 15, 1.0)
    line(c, x - 10, 342, x, data_y + 30, 1.0)
    line(c, x - 10, 342, x, tag_y + 30, 1.0)
    line(c, x - 10, 342, x + 8, valid_y + 18, 0.85)
    line(c, x - 10, 342, x + 70, valid_y + 18, 0.85)

    # Tag output to comparator; valid output to hit AND.
    line(c, x + w, tag_y + 30, x + w + 18, tag_y + 30, 1.1)
    line(c, x + w + 18, tag_y + 30, x + w + 18, 612 + idx * 7, 1.1)
    line(c, x + w + 18, 612 + idx * 7, x + 114, 612 + idx * 7, 1.1)
    polyline(c, [(x + 60, valid_y + 22), (x + 60, 645), (x + 84, 619)], 0.8)

    # Comparator result to hit logic.
    cmp_out_x = x + 114
    polyline(c, [(cmp_out_x, 619), (680, 619), (680, 138 + idx * 24), (720, 138 + idx * 24)], 0.8)

    # Data output to mux.
    polyline(c, [(x + w, data_y + 30), (872, data_y + 30), (872, 412 + idx * 14), (895, 412 + idx * 14)], 1.0)

    # AGE output to victim selector.
    polyline(c, [(x + 122, valid_y + 24), (x + 145, valid_y + 24), (x + 145, 225), (545 + idx * 42, 225), (545 + idx * 42, 192)], 0.75)


def draw_scheme(c: canvas.Canvas) -> None:
    c.setTitle("A4_cache_4way_structural_detailed")
    c.setStrokeColor(colors.black)
    c.setLineWidth(0.75)
    c.rect(14, rect_y(14, PAGE_H - 28), PAGE_W - 28, PAGE_H - 28, stroke=1, fill=0)

    label(c, 24, 32, "ГУИР.400201.307", 9, True)
    label(c, 480, 34, "Структурная схема блока кэш-памяти 4-way", 9, True)

    pin(c, 24, 120, "чтение/запрос", "cpu_req_i")
    pin(c, 24, 154, "запись", "cpu_we_i")
    pin(c, 24, 188, "сброс", "rst_i")
    pin(c, 24, 258, "данные на запись", "cpu_wdata_i[15..0]", 110)
    pin(c, 24, 326, "адрес от процессора", "cpu_addr_i[15..0]", 110)
    pin(c, 24, 724, "тактовый сигнал", "clk_i", 82)

    # Main buses.
    line(c, 126, 300, 1080, 300, 2.0)
    bus_label(c, 438, 293, "cpu_wdata_i[15..0]")
    line(c, 126, 342, 1080, 342, 2.0)
    bus_label(c, 430, 335, "cpu_addr_i[15..0]")
    line(c, 126, 724, 810, 724, 1.6)
    bus_label(c, 350, 717, "clk_i")
    line(c, 162, 342, 162, 690, 1.2)
    bus_label(c, 166, 350, "SET=A[3..0]")
    line(c, 180, 342, 180, 625, 1.0)
    bus_label(c, 184, 362, "TAG=A[15..4]")

    # Address splitter and control block.
    box(c, 164, 238, 126, 50, "ADDRESS_SPLIT\nTAG=A[15:4]\nSET=A[3:0]", size=6.1)
    polyline(c, [(126, 342), (145, 342), (145, 263), (164, 263)], 1.0)
    box(c, 318, 90, 142, 68, "CACHE_CONTROL FSM\nIDLE\nWAIT_READ_GRANT\nWAIT_READ_DATA\nWAIT_WRITE_GRANT", size=5.5)
    box(c, 492, 92, 105, 55, "victim_select\nfree way\nmax AGE", size=5.8)
    box(c, 318, 170, 118, 44, "way decoder\nwe_way[3..0]", size=5.8)
    arrow(c, 460, 124, 492, 120, 0.9)
    arrow(c, 545, 147, 380, 170, 0.9)

    polyline(c, [(126, 137.5), (250, 137.5), (250, 124), (318, 124)], 0.8)
    polyline(c, [(126, 171.5), (260, 171.5), (260, 132), (318, 132)], 0.8)
    polyline(c, [(126, 205.5), (270, 205.5), (270, 140), (318, 140)], 0.8)
    line(c, 380, 214, 380, 300, 0.9)

    # Write-enable gates per way.
    gate_x = 470
    for i in range(4):
        and_gate(c, gate_x + i * 52, 165, f"AND{i}")
        label(c, gate_x + i * 52 - 5, 158, f"we_way{i}", 5)
        polyline(c, [(gate_x + i * 52 + 34, 174), (gate_x + i * 52 + 42, 174), (gate_x + i * 52 + 42, 350), (220 + i * 170, 370)], 0.65)

    # Hit logic.
    for i in range(4):
        and_gate(c, 720, 128 + i * 24, f"HIT{i}")
        label(c, 674, 139 + i * 24, f"cmp_tag{i}", 5)
        label(c, 760, 139 + i * 24, f"valid{i}", 5)
    or_gate(c, 815, 165, "OR")
    arrow(c, 758, 137, 815, 175, 0.7)
    arrow(c, 758, 161, 815, 178, 0.7)
    arrow(c, 758, 185, 815, 181, 0.7)
    arrow(c, 758, 209, 815, 184, 0.7)
    line(c, 853, 175, 902, 175, 1.0)
    tiny_box(c, 902, 168, 76, 14, "hit_o", 5.2)
    tiny_box(c, 902, 194, 76, 14, "miss_o = !hit", 5.2)
    line(c, 860, 175, 860, 201, 0.7)
    tiny_box(c, 862, 190, 22, 22, "NOT", 5)
    line(c, 884, 201, 902, 201, 0.7)

    # Write-through and RAM interface.
    box(c, 1000, 92, 132, 80, "WRITE-THROUGH\nram_req_o\nram_we_o\nram_addr_o\nram_wdata_o", size=5.8)
    polyline(c, [(126, 300), (960, 300), (960, 125), (1000, 125)], 1.0)
    polyline(c, [(126, 342), (980, 342), (980, 145), (1000, 145)], 1.0)
    line(c, 1066, 172, 1066, 300, 1.0)
    tiny_box(c, 1030, 286, 112, 14, "ram_wdata_o[15..0]", 5.2)
    tiny_box(c, 1030, 328, 112, 14, "ram_addr_o[15..0]", 5.2)
    label(c, 1004, 211, "данные при записи в ОЗУ", 5.5)
    label(c, 1004, 229, "адрес доступа к ОЗУ", 5.5)

    # Dashed grouping of cache core.
    outline_box(c, 205, 352, 720, 372, "Массив строк кэша: 16 sets x 4 ways", 6.5, dash=[4, 3])

    # Four ways.
    xs = [220, 390, 560, 730]
    for idx, x in enumerate(xs):
        draw_way(c, idx, x)

    # Read mux and output mux.
    box(c, 895, 395, 94, 86, "cache_data_mux\n4:1\nsel = hit_way", size=5.5)
    box(c, 1030, 410, 100, 72, "cpu_data_out\nhit ? cache\nmiss ? ram", size=5.5)
    line(c, 989, 438, 1030, 438, 1.1)
    tiny_box(c, 1006, 386, 80, 13, "ram_rdata_i[15..0]", 5.2)
    line(c, 1046, 399, 1046, 410, 0.9)
    tiny_box(c, 1132, 438, 42, 13, "cpu_rdata_o", 5.2)
    arrow(c, 1130, 446, 1175, 446, 0.9)
    tiny_box(c, 1056, 495, 70, 13, "cpu_ready_o", 5.2)
    polyline(c, [(390, 124), (1090, 124), (1090, 501)], 0.7)

    # Victim and AGE/update paths.
    label(c, 522, 184, "выбор way для замещения", 5.5)
    line(c, 545, 147, 545, 220, 0.8)
    for idx, x in enumerate(xs):
        polyline(c, [(545, 220), (545, 247), (x + 96, 247), (x + 96, 665)], 0.55)
    tiny_box(c, 610, 228, 118, 15, "victim_way[1..0]", 5.2)

    # Result outputs and annotations.
    tiny_box(c, 970, 574, 108, 15, "tag_and_valid_way[3..0]", 5.2)
    polyline(c, [(880, 612), (940, 612), (940, 581), (970, 581)], 0.7)
    tiny_box(c, 970, 610, 106, 15, "hit_way[1..0]", 5.2)
    polyline(c, [(880, 628), (950, 628), (950, 617), (970, 617)], 0.7)
    tiny_box(c, 970, 646, 106, 15, "fill/update on miss", 5.2)
    polyline(c, [(545, 147), (932, 147), (932, 653), (970, 653)], 0.6)

    # Legend/table.
    box(c, 24, 616, 146, 84, "Поля адреса\nA[15:4]  TAG\nA[3:0]   SET\nстрока = 1 слово", size=6.1)
    box(c, 24, 486, 146, 94, "Параметры\n4 way\n16 наборов\nDATA 16 бит\nTAG 12 бит\nAGE 2 бита", size=6.1)
    box(c, 650, 238, 178, 50, "При чтении:\nTAG compare -> hit/miss\nhit: данные из cache_data_mux", size=5.8)
    box(c, 850, 238, 185, 50, "При записи:\nобновление way + запись в RAM\nрежим write-through", size=5.8)

    title_block(c)


def main() -> None:
    register_fonts()
    OUT_PDF.parent.mkdir(parents=True, exist_ok=True)
    OUT_GRAPHICS.parent.mkdir(parents=True, exist_ok=True)
    OUT_PNG_PREFIX.parent.mkdir(parents=True, exist_ok=True)

    c = canvas.Canvas(str(OUT_PDF), pagesize=landscape(A3))
    draw_scheme(c)
    c.showPage()
    c.save()

    OUT_GRAPHICS.write_bytes(OUT_PDF.read_bytes())

    try:
        subprocess.run(
            [
                "pdftoppm",
                "-png",
                "-r",
                "180",
                "-singlefile",
                str(OUT_PDF),
                str(OUT_PNG_PREFIX),
            ],
            check=True,
        )
    except (FileNotFoundError, subprocess.CalledProcessError):
        pass

    print(OUT_PDF)
    print(OUT_GRAPHICS)
    print(str(OUT_PNG_PREFIX) + ".png")


if __name__ == "__main__":
    main()
