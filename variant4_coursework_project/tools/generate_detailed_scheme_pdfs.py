#!/usr/bin/env python3
"""Generate additional detailed PDF drawings for SIFO VM variant 4."""

from __future__ import annotations

import math
from dataclasses import dataclass
from html import escape
from pathlib import Path

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A3, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph


PROJECT_DIR = Path(__file__).resolve().parents[1]
OUT_DIR = PROJECT_DIR / "schemes" / "pdf"

FONT_REGULAR = "CourseworkArial"
FONT_BOLD = "CourseworkArialBold"
FONT_PATH = Path("/System/Library/Fonts/Supplemental/Arial.ttf")
BOLD_FONT_PATH = Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf")

PAGE_W = 1600.0
PAGE_H = 1100.0

BLUE = colors.HexColor("#dae8fc")
BLUE_STROKE = colors.HexColor("#6c8ebf")
YELLOW = colors.HexColor("#fff2cc")
YELLOW_STROKE = colors.HexColor("#d6b656")
GREEN = colors.HexColor("#d5e8d4")
GREEN_STROKE = colors.HexColor("#82b366")
PURPLE = colors.HexColor("#e1d5e7")
PURPLE_STROKE = colors.HexColor("#9673a6")
RED = colors.HexColor("#f8cecc")
RED_STROKE = colors.HexColor("#b85450")
INK = colors.HexColor("#26384f")
BUS = colors.HexColor("#2f4b7c")
CTRL = colors.HexColor("#7f5d99")


@dataclass(frozen=True)
class Box:
    label: str
    x: float
    y: float
    w: float
    h: float
    fill: colors.Color = YELLOW
    stroke: colors.Color = YELLOW_STROKE
    font_size: float = 15
    align: int = TA_CENTER

    @property
    def center(self) -> tuple[float, float]:
        return self.x + self.w / 2, self.y + self.h / 2


class Transform:
    def __init__(self) -> None:
        self.paper_w, self.paper_h = landscape(A3)
        margin = 24.0
        self.scale = min((self.paper_w - 2 * margin) / PAGE_W, (self.paper_h - 2 * margin) / PAGE_H)
        self.ox = (self.paper_w - PAGE_W * self.scale) / 2
        self.oy = (self.paper_h - PAGE_H * self.scale) / 2

    def point(self, x: float, y: float) -> tuple[float, float]:
        return self.ox + x * self.scale, self.oy + (PAGE_H - y) * self.scale

    def rect(self, box: Box) -> tuple[float, float, float, float]:
        x, y = self.point(box.x, box.y + box.h)
        return x, y, box.w * self.scale, box.h * self.scale

    def length(self, value: float) -> float:
        return value * self.scale


def register_fonts() -> None:
    if FONT_REGULAR not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_REGULAR, str(FONT_PATH)))
    if FONT_BOLD not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_BOLD, str(BOLD_FONT_PATH)))


def draw_text(
    c: canvas.Canvas,
    text: str,
    left: float,
    bottom: float,
    width: float,
    height: float,
    font_size: float,
    align: int = TA_CENTER,
    bold: bool = False,
) -> None:
    if not text:
        return
    escaped = "<br/>".join(escape(line) for line in text.splitlines())
    padding = max(3.0, min(width, height) * 0.06)
    usable_w = max(4.0, width - 2 * padding)
    usable_h = max(4.0, height - 2 * padding)
    size = font_size
    while size >= 5.0:
        style = ParagraphStyle(
            "txt",
            fontName=FONT_BOLD if bold else FONT_REGULAR,
            fontSize=size,
            leading=size * 1.15,
            alignment=align,
            textColor=colors.HexColor("#222222"),
            splitLongWords=True,
            wordWrap="CJK",
        )
        paragraph = Paragraph(escaped, style)
        _, para_h = paragraph.wrap(usable_w, usable_h)
        if para_h <= usable_h or size <= 5.2:
            y = bottom + padding + max(0, (usable_h - para_h) / 2)
            paragraph.drawOn(c, left + padding, y)
            return
        size -= 0.5


def draw_box(c: canvas.Canvas, tr: Transform, box: Box, rounded: bool = True) -> None:
    x, y, w, h = tr.rect(box)
    c.saveState()
    c.setFillColor(box.fill)
    c.setStrokeColor(box.stroke)
    c.setLineWidth(1.0)
    if rounded:
        c.roundRect(x, y, w, h, min(w, h) * 0.08, stroke=1, fill=1)
    else:
        c.rect(x, y, w, h, stroke=1, fill=1)
    c.restoreState()
    draw_text(c, box.label, x, y, w, h, max(7.0, box.font_size * tr.scale), box.align)


def draw_title_block(c: canvas.Canvas, tr: Transform, sheet: str, title: str) -> None:
    frame = Box("", 20, 20, PAGE_W - 40, PAGE_H - 40, colors.white, colors.HexColor("#222222"), 10)
    x, y, w, h = tr.rect(frame)
    c.saveState()
    c.setFillColor(colors.Color(1, 1, 1, alpha=0))
    c.setStrokeColor(colors.HexColor("#222222"))
    c.setLineWidth(1.5)
    c.rect(x, y, w, h, stroke=1, fill=0)
    c.restoreState()

    stamp = Box(
        f"Курсовой проект СиФО ЭВМ\nВариант 4\n{sheet}\n{title}",
        1090,
        970,
        470,
        90,
        colors.white,
        colors.HexColor("#222222"),
        11,
        TA_LEFT,
    )
    draw_box(c, tr, stamp, rounded=False)


def edge_point(src: Box, dst: Box) -> tuple[float, float]:
    sx, sy = src.center
    dx = dst.center[0] - sx
    dy = dst.center[1] - sy
    if dx == 0 and dy == 0:
        return sx, sy
    kx = (src.w / 2) / abs(dx) if dx else math.inf
    ky = (src.h / 2) / abs(dy) if dy else math.inf
    k = min(kx, ky)
    return sx + dx * k, sy + dy * k


def draw_label(c: canvas.Canvas, tr: Transform, text: str, x: float, y: float) -> None:
    if not text:
        return
    px, py = tr.point(x, y)
    width = max(60.0, min(150.0, len(text) * 5.0))
    height = 18.0
    c.saveState()
    c.setFillColor(colors.white)
    c.setStrokeColor(colors.HexColor("#e2e2e2"))
    c.setLineWidth(0.35)
    c.roundRect(px - width / 2, py - height / 2, width, height, 2, stroke=1, fill=1)
    c.restoreState()
    draw_text(c, text, px - width / 2, py - height / 2, width, height, 7.6, TA_CENTER)


def arrow(
    c: canvas.Canvas,
    tr: Transform,
    start: tuple[float, float],
    end: tuple[float, float],
    label: str = "",
    color: colors.Color = INK,
    width: float = 2.0,
    dashed: bool = False,
) -> None:
    sx, sy = tr.point(*start)
    ex, ey = tr.point(*end)
    line_width = max(0.8, width * tr.scale)
    c.saveState()
    c.setStrokeColor(color)
    c.setFillColor(color)
    c.setLineWidth(line_width)
    if dashed:
        c.setDash(6, 4)
    c.line(sx, sy, ex, ey)
    c.setDash()
    angle = math.atan2(ey - sy, ex - sx)
    length = max(8.0, 10.0 * line_width)
    spread = length * 0.55
    path = c.beginPath()
    path.moveTo(ex, ey)
    path.lineTo(ex - length * math.cos(angle) + spread * math.sin(angle), ey - length * math.sin(angle) - spread * math.cos(angle))
    path.lineTo(ex - length * math.cos(angle) - spread * math.sin(angle), ey - length * math.sin(angle) + spread * math.cos(angle))
    path.close()
    c.drawPath(path, stroke=0, fill=1)
    c.restoreState()
    if label:
        draw_label(c, tr, label, (start[0] + end[0]) / 2, (start[1] + end[1]) / 2)


def connect(
    c: canvas.Canvas,
    tr: Transform,
    src: Box,
    dst: Box,
    label: str = "",
    color: colors.Color = INK,
    width: float = 2.0,
    dashed: bool = False,
) -> None:
    arrow(c, tr, edge_point(src, dst), edge_point(dst, src), label, color, width, dashed)


def table_box(c: canvas.Canvas, tr: Transform, title: str, rows: list[tuple[str, str]], x: float, y: float, w: float, row_h: float = 42) -> Box:
    h = 58 + row_h * len(rows)
    outer = Box("", x, y, w, h, colors.white, colors.HexColor("#555555"), 10)
    draw_box(c, tr, outer, rounded=False)
    header = Box(title, x, y, w, 58, YELLOW, YELLOW_STROKE, 14)
    draw_box(c, tr, header, rounded=False)
    for idx, (left, right) in enumerate(rows):
        row_y = y + 58 + idx * row_h
        left_box = Box(left, x, row_y, w * 0.44, row_h, colors.white, colors.HexColor("#d0d0d0"), 11, TA_LEFT)
        right_box = Box(right, x + w * 0.44, row_y, w * 0.56, row_h, colors.white, colors.HexColor("#d0d0d0"), 11, TA_LEFT)
        draw_box(c, tr, left_box, rounded=False)
        draw_box(c, tr, right_box, rounded=False)
    return outer


def page(filename: str, sheet: str, title: str, draw: callable) -> None:
    register_fonts()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    tr = Transform()
    pdf = canvas.Canvas(str(OUT_DIR / filename), pagesize=landscape(A3))
    pdf.setTitle(Path(filename).stem)
    pdf.setAuthor("Codex")
    draw_title_block(pdf, tr, sheet, title)
    draw(pdf, tr)
    pdf.showPage()
    pdf.save()
    print(OUT_DIR / filename)


def cpu_core(c: canvas.Canvas, tr: Transform) -> None:
    boxes = {
        "rom": Box("ROM\nкоманды", 70, 145, 190, 80, BLUE, BLUE_STROKE),
        "pc": Box("PC / IP\nадрес команды", 370, 130, 230, 90, YELLOW, YELLOW_STROKE),
        "ir": Box("IR0 / IR1\nдвухсловная команда", 370, 330, 230, 90, YELLOW, YELLOW_STROKE),
        "cu": Box("Устройство управления\nT0...T5 + Tw", 690, 245, 255, 115, YELLOW, YELLOW_STROKE),
        "rf": Box("РОН\n12 x 16", 1030, 140, 210, 80, BLUE, BLUE_STROKE),
        "alu": Box("АЛУ\nOR / NOR / SRA / INCS", 1030, 335, 225, 92, GREEN, GREEN_STROKE),
        "stack": Box("Стек\n7 x 16", 1320, 145, 150, 80, PURPLE, PURPLE_STROKE),
        "cache": Box("Кэш данных\n4-way, 16 sets", 1040, 570, 230, 95, GREEN, GREEN_STROKE),
        "ram": Box("RAM\nданные", 1330, 575, 170, 80, BLUE, BLUE_STROKE),
        "bp": Box("A4 predictor\nPHT + BTB + GHR", 680, 600, 270, 90, PURPLE, PURPLE_STROKE),
        "dma": Box("DMA / КПДП\n3 слова", 960, 795, 200, 80, YELLOW, YELLOW_STROKE),
        "arb": Box("Арбитр шины\nприоритет DMA", 1240, 790, 210, 85, YELLOW, YELLOW_STROKE),
    }
    for box in boxes.values():
        draw_box(c, tr, box)
    connect(c, tr, boxes["rom"], boxes["pc"], "instr", BUS, 3)
    connect(c, tr, boxes["pc"], boxes["ir"], "fetch", INK, 2)
    connect(c, tr, boxes["ir"], boxes["cu"], "opcode", INK, 2)
    connect(c, tr, boxes["cu"], boxes["rf"], "RF control", CTRL, 2, True)
    connect(c, tr, boxes["rf"], boxes["alu"], "A/B", BUS, 3)
    connect(c, tr, boxes["alu"], boxes["rf"], "Y", BUS, 3)
    connect(c, tr, boxes["rf"], boxes["stack"], "push/pop", BUS, 3)
    connect(c, tr, boxes["rf"], boxes["cache"], "addr/data", BUS, 3)
    connect(c, tr, boxes["cache"], boxes["ram"], "fill/write", BUS, 3)
    connect(c, tr, boxes["ir"], boxes["bp"], "PC", INK, 2)
    connect(c, tr, boxes["bp"], boxes["pc"], "target", INK, 2)
    connect(c, tr, boxes["cache"], boxes["arb"], "REQ_CPU", INK, 2)
    connect(c, tr, boxes["dma"], boxes["arb"], "REQ_DMA", INK, 2)
    connect(c, tr, boxes["dma"], boxes["ram"], "DMA write", BUS, 3)


def control_signals(c: canvas.Canvas, tr: Transform) -> None:
    left = table_box(
        c,
        tr,
        "Входы устройства управления",
        [
            ("opcode", "код операции IR0[15:8]"),
            ("reg", "номер R0..R11"),
            ("addr", "адрес IR1[15:0]"),
            ("FR", "Z/S/C/O"),
            ("ready", "cache_ready, dma_grant"),
        ],
        90,
        120,
        430,
    )
    center = Box("CU\nдешифратор + секвенсор\nT0 T1 T2 T3 T4 T5 Tw", 640, 330, 320, 150, YELLOW, YELLOW_STROKE, 16)
    right = table_box(
        c,
        tr,
        "Выходы управления",
        [
            ("RF_WE", "запись РОН"),
            ("ALU_OP", "OR/NOR/SRA/INCS"),
            ("MEM_RD/WR", "обмен с кэшем/RAM"),
            ("STK_PUSH/POP", "операции стека"),
            ("BP_UPD", "обновление A4 predictor"),
            ("HALT", "останов модели"),
        ],
        1080,
        120,
        430,
    )
    state = Box("Автомат фаз\nT0 fetch word0\nT1 fetch word1\nT2 decode\nT3 read\nT4 execute\nT5 writeback\nTw wait", 625, 610, 350, 210, GREEN, GREEN_STROKE, 14)
    draw_box(c, tr, center)
    draw_box(c, tr, state)
    connect(c, tr, left, center, "conditions", INK, 2)
    connect(c, tr, center, right, "control bus", BUS, 3)
    connect(c, tr, state, center, "phase", CTRL, 2, True)


def instruction_register(c: canvas.Canvas, tr: Transform) -> None:
    rom = Box("ROM\n16-bit word", 80, 175, 220, 85, BLUE, BLUE_STROKE)
    pc = Box("PC / IP\n+2 or target", 420, 170, 240, 95, YELLOW, YELLOW_STROKE)
    ir0 = Box("IR0\nopcode[15:8]\nreg[7:4]", 800, 120, 240, 120, GREEN, GREEN_STROKE)
    ir1 = Box("IR1\naddress / target\n[15:0]", 800, 320, 240, 120, GREEN, GREEN_STROKE)
    dec = Box("Decoder\nOP + Rn + adr", 1190, 225, 240, 110, YELLOW, YELLOW_STROKE)
    branch = Box("MUX next PC\nPC+2 / JMP / JZ / BTB", 420, 505, 300, 110, PURPLE, PURPLE_STROKE)
    for box in [rom, pc, ir0, ir1, dec, branch]:
        draw_box(c, tr, box)
    connect(c, tr, pc, rom, "addr", BUS, 3)
    connect(c, tr, rom, ir0, "word0", BUS, 3)
    connect(c, tr, rom, ir1, "word1", BUS, 3)
    connect(c, tr, ir0, dec, "opcode/reg", INK, 2)
    connect(c, tr, ir1, dec, "address", INK, 2)
    connect(c, tr, dec, branch, "control", CTRL, 2, True)
    connect(c, tr, branch, pc, "next PC", BUS, 3)
    table_box(c, tr, "Формат команды", [("word0[15:8]", "opcode"), ("word0[7:4]", "register"), ("word0[3:0]", "reserve"), ("word1[15:0]", "address/target")], 1040, 570, 360)


def register_file(c: canvas.Canvas, tr: Transform) -> None:
    rf = Box("Регистровая память\n12 x 16 бит", 625, 290, 310, 130, BLUE, BLUE_STROKE, 17)
    read_a = Box("Read port A\naddr_a -> data_a", 210, 170, 250, 90, GREEN, GREEN_STROKE)
    read_b = Box("Read port B\naddr_b -> data_b", 210, 445, 250, 90, GREEN, GREEN_STROKE)
    write = Box("Write port\naddr_w, data_w, we", 1090, 300, 270, 95, YELLOW, YELLOW_STROKE)
    mux = Box("Селектор R0..R11\n4-bit register index", 610, 560, 340, 90, PURPLE, PURPLE_STROKE)
    zero = Box("R0..R11\n16-bit registers\nreset to 0000h", 610, 110, 340, 110, colors.white, colors.HexColor("#777777"))
    for box in [zero, rf, read_a, read_b, write, mux]:
        draw_box(c, tr, box)
    connect(c, tr, mux, rf, "Rn index", INK, 2)
    connect(c, tr, rf, read_a, "data_a", BUS, 3)
    connect(c, tr, rf, read_b, "data_b", BUS, 3)
    connect(c, tr, write, rf, "writeback", BUS, 3)
    table_box(c, tr, "Контроль после HLT", [("R1", "C001h"), ("R2", "F000h"), ("R3", "C001h"), ("R4/R5/R6", "0000h"), ("R7", "1111h")], 1120, 590, 300)


def alu_flags(c: canvas.Canvas, tr: Transform) -> None:
    a = Box("Operand A\nRn", 110, 230, 230, 85, BLUE, BLUE_STROKE)
    b = Box("Operand B\nM[adr] / const / S", 110, 500, 230, 95, BLUE, BLUE_STROKE)
    muxa = Box("MUX A", 455, 230, 180, 75, YELLOW, YELLOW_STROKE)
    muxb = Box("MUX B", 455, 510, 180, 75, YELLOW, YELLOW_STROKE)
    alu = Box("ALU\nOR\nNOR\nSRA\nINCS", 780, 335, 260, 185, GREEN, GREEN_STROKE, 17)
    fr = Box("FR\nZ S C O", 1190, 255, 160, 90, PURPLE, PURPLE_STROKE)
    out = Box("Y[15:0]\nwriteback", 1190, 520, 180, 85, BLUE, BLUE_STROKE)
    for box in [a, b, muxa, muxb, alu, fr, out]:
        draw_box(c, tr, box)
    connect(c, tr, a, muxa, "A", BUS, 3)
    connect(c, tr, b, muxb, "B", BUS, 3)
    connect(c, tr, muxa, alu, "A bus", BUS, 3)
    connect(c, tr, muxb, alu, "B bus", BUS, 3)
    connect(c, tr, alu, fr, "flags", INK, 2)
    connect(c, tr, alu, out, "result", BUS, 3)
    table_box(c, tr, "Флаги", [("Z", "result = 0000h"), ("S", "result[15]"), ("C", "carry/shift out"), ("O", "signed overflow")], 625, 650, 360)


def stack(c: canvas.Canvas, tr: Transform) -> None:
    din = Box("DIN[15:0]\nиз РОН", 120, 270, 230, 90, BLUE, BLUE_STROKE)
    mem = Box("Стековая память\n7 x 16 бит\nадреса 0..6", 650, 230, 320, 160, PURPLE, PURPLE_STROKE, 17)
    sp = Box("SP\n3-bit pointer\nreset = 7", 650, 520, 260, 100, YELLOW, YELLOW_STROKE)
    dout = Box("DOUT[15:0]\nв writeback", 1190, 270, 240, 90, BLUE, BLUE_STROKE)
    ctl = Box("Управление\nPUSH / POP\nFULL / EMPTY", 1130, 545, 300, 115, GREEN, GREEN_STROKE)
    for box in [din, mem, sp, dout, ctl]:
        draw_box(c, tr, box)
    connect(c, tr, din, mem, "PUSH data", BUS, 3)
    connect(c, tr, mem, dout, "POP data", BUS, 3)
    connect(c, tr, ctl, mem, "we/re", CTRL, 2, True)
    connect(c, tr, sp, mem, "addr", INK, 2)
    connect(c, tr, ctl, sp, "inc/dec", CTRL, 2, True)
    table_box(c, tr, "Правило роста", [("PUSH", "SP := SP - 1, M[SP] := DIN"), ("POP", "DOUT := M[SP], SP := SP + 1"), ("Глубина", "7 слов по 16 бит")], 150, 595, 380)


def rom(c: canvas.Canvas, tr: Transform) -> None:
    addr = Box("PC[15:0]", 110, 250, 190, 75, BLUE, BLUE_STROKE)
    rom_box = Box("Синхронное ПЗУ команд\n16-bit address\n16-bit word", 545, 215, 330, 145, BLUE, BLUE_STROKE, 17)
    q = Box("Q[15:0]\nслово команды", 1130, 250, 220, 80, GREEN, GREEN_STROKE)
    clk = Box("CLK\nregistered address", 555, 500, 310, 85, YELLOW, YELLOW_STROKE)
    mif = table_box(c, tr, "ROM MIF", [("Файл", "memory/rom_variant4.mif"), ("Ширина", "16 бит"), ("Назначение", "программа со всеми командами"), ("Формат", "hex + binary listing")], 1020, 540, 380)
    for box in [addr, rom_box, q, clk]:
        draw_box(c, tr, box)
    connect(c, tr, addr, rom_box, "address", BUS, 3)
    connect(c, tr, rom_box, q, "instruction", BUS, 3)
    connect(c, tr, clk, rom_box, "sync read", CTRL, 2, True)
    connect(c, tr, mif, rom_box, "init", INK, 2)


def ram(c: canvas.Canvas, tr: Transform) -> None:
    cpu = Box("CPU/cache port\naddr, rd, wr, wdata", 90, 180, 280, 95, YELLOW, YELLOW_STROKE)
    dma = Box("DMA port\naddr, wr, wdata", 90, 520, 260, 90, YELLOW, YELLOW_STROKE)
    arb = Box("RAM access mux\nCPU or DMA", 520, 325, 260, 105, PURPLE, PURPLE_STROKE)
    ram_box = Box("Синхронное ОЗУ данных\n16-bit address\n16-bit data", 935, 300, 320, 135, BLUE, BLUE_STROKE, 17)
    out = Box("rdata[15:0]", 1340, 325, 170, 75, GREEN, GREEN_STROKE)
    for box in [cpu, dma, arb, ram_box, out]:
        draw_box(c, tr, box)
    connect(c, tr, cpu, arb, "CPU", BUS, 3)
    connect(c, tr, dma, arb, "DMA", BUS, 3)
    connect(c, tr, arb, ram_box, "selected port", BUS, 3)
    connect(c, tr, ram_box, out, "read data", BUS, 3)
    table_box(c, tr, "Контрольные ячейки", [("000Ah", "1111h"), ("000Bh", "2222h"), ("000Ch", "3333h"), ("0030h", "C001h")], 985, 580, 360)


def cache(c: canvas.Canvas, tr: Transform) -> None:
    addr = Box("CPU address\nindex + tag", 90, 210, 250, 85, BLUE, BLUE_STROKE)
    sets = Box("16 sets\n4 ways per set", 520, 150, 280, 90, GREEN, GREEN_STROKE)
    tag = Box("TAG compare\nvalid bits", 520, 340, 280, 90, GREEN, GREEN_STROKE)
    age = Box("AGE counters\nmax-age replacement", 520, 540, 280, 95, PURPLE, PURPLE_STROKE)
    ctl = Box("Cache controller\nhit / miss / fill\nwrite-through", 940, 300, 300, 150, YELLOW, YELLOW_STROKE, 16)
    ram = Box("RAM interface\nfill / write", 1320, 330, 190, 90, BLUE, BLUE_STROKE)
    for box in [addr, sets, tag, age, ctl, ram]:
        draw_box(c, tr, box)
    connect(c, tr, addr, sets, "set index", BUS, 3)
    connect(c, tr, sets, tag, "4 ways", INK, 2)
    connect(c, tr, tag, ctl, "hit/miss", INK, 2)
    connect(c, tr, age, ctl, "victim way", INK, 2)
    connect(c, tr, ctl, ram, "miss/write", BUS, 3)
    table_box(c, tr, "Параметры варианта", [("k", "4-way"), ("Sets", "16"), ("Line", "1 word"), ("Write", "сквозная"), ("Replacement", "max AGE")], 105, 555, 330)


def dma_controller(c: canvas.Canvas, tr: Transform) -> None:
    start = Box("START", 100, 220, 160, 70, GREEN, GREEN_STROKE)
    regs = Box("DMA registers\nADDR=000Ah\nCOUNT=3 words", 470, 170, 280, 120, YELLOW, YELLOW_STROKE)
    fsm = Box("DMA FSM\nIDLE -> REQ -> WRITE -> DONE", 470, 450, 320, 120, YELLOW, YELLOW_STROKE)
    arb = Box("Bus arbiter\nREQ_DMA / GNT_DMA", 980, 245, 300, 100, PURPLE, PURPLE_STROKE)
    ram = Box("RAM write port\n000A..000C", 1240, 540, 230, 90, BLUE, BLUE_STROKE)
    data = Box("DMA source data\n1111h, 2222h, 3333h", 110, 540, 280, 90, GREEN, GREEN_STROKE)
    for box in [start, regs, fsm, arb, ram, data]:
        draw_box(c, tr, box)
    connect(c, tr, start, regs, "load", INK, 2)
    connect(c, tr, regs, fsm, "addr/count", BUS, 3)
    connect(c, tr, fsm, arb, "REQ_DMA", INK, 2)
    connect(c, tr, arb, fsm, "GNT_DMA", INK, 2)
    connect(c, tr, data, ram, "wdata", BUS, 3)
    connect(c, tr, fsm, ram, "wr/addr", BUS, 3)
    table_box(c, tr, "Результат", [("DONE", "1 после 3 записей"), ("Priority", "DMA выше CPU"), ("Bytes", "6 байт = 3 слова")], 875, 670, 330)


def arbiter(c: canvas.Canvas, tr: Transform) -> None:
    cpu_req = Box("REQ_CPU\nот кэша", 120, 220, 200, 80, BLUE, BLUE_STROKE)
    dma_req = Box("REQ_DMA\nот КПДП", 120, 520, 200, 80, BLUE, BLUE_STROKE)
    arb = Box("Централизованный\nпараллельный арбитр\nприоритет DMA", 650, 320, 330, 150, YELLOW, YELLOW_STROKE, 17)
    cpu_gnt = Box("GNT_CPU", 1240, 230, 180, 70, GREEN, GREEN_STROKE)
    dma_gnt = Box("GNT_DMA", 1240, 520, 180, 70, GREEN, GREEN_STROKE)
    ram_bus = Box("RAM bus owner\nCPU or DMA", 660, 660, 300, 90, PURPLE, PURPLE_STROKE)
    for box in [cpu_req, dma_req, arb, cpu_gnt, dma_gnt, ram_bus]:
        draw_box(c, tr, box)
    connect(c, tr, cpu_req, arb, "request", INK, 2)
    connect(c, tr, dma_req, arb, "request", INK, 2)
    connect(c, tr, arb, cpu_gnt, "grant", INK, 2)
    connect(c, tr, arb, dma_gnt, "grant", INK, 2)
    connect(c, tr, arb, ram_bus, "owner", BUS, 3)
    table_box(c, tr, "Таблица приоритета", [("REQ_CPU=0, REQ_DMA=0", "GNT_CPU=0, GNT_DMA=0"), ("REQ_CPU=1, REQ_DMA=0", "GNT_CPU=1"), ("REQ_CPU=0, REQ_DMA=1", "GNT_DMA=1"), ("REQ_CPU=1, REQ_DMA=1", "GNT_DMA=1")], 470, 105, 600, 38)


def branch_predictor(c: canvas.Canvas, tr: Transform) -> None:
    pc = Box("PC[1:0]", 110, 200, 180, 70, BLUE, BLUE_STROKE)
    ghr = Box("GHR[1:0]", 110, 470, 180, 70, PURPLE, PURPLE_STROKE)
    idx = Box("Index\nPC(2) || GHR(2)\n4 bits", 450, 315, 260, 110, YELLOW, YELLOW_STROKE)
    pht = Box("PHT\n16 x 2-bit counter", 860, 185, 280, 100, GREEN, GREEN_STROKE)
    btb = Box("BTB\n16 target addresses", 860, 470, 280, 100, GREEN, GREEN_STROKE)
    decision = Box("Prediction\ncounter >= 2\nand BTB valid", 1250, 330, 250, 110, PURPLE, PURPLE_STROKE)
    upd = Box("Update on resolve\ncounter++, counter--\nBTB target write\nGHR shift", 555, 660, 390, 130, RED, RED_STROKE, 14)
    for box in [pc, ghr, idx, pht, btb, decision, upd]:
        draw_box(c, tr, box)
    connect(c, tr, pc, idx, "PC", INK, 2)
    connect(c, tr, ghr, idx, "history", INK, 2)
    connect(c, tr, idx, pht, "index", BUS, 3)
    connect(c, tr, idx, btb, "index", BUS, 3)
    connect(c, tr, pht, decision, "taken?", INK, 2)
    connect(c, tr, btb, decision, "target", INK, 2)
    connect(c, tr, upd, pht, "branch result", CTRL, 2, True)
    connect(c, tr, upd, btb, "target", CTRL, 2, True)
    connect(c, tr, upd, ghr, "new history", CTRL, 2, True)


def generate_all() -> None:
    page("A1_expanded_cpu_core.pdf", "Доп. лист 1, формат А3", "Расширенная схема процессорного ядра", cpu_core)
    page("A1_control_signals.pdf", "Доп. лист 2, формат А3", "Перечень входных и выходных сигналов УУ", control_signals)
    page("A3_instruction_register_pc.pdf", "Доп. лист 3, формат А3", "Тракт PC/IR и формат команды", instruction_register)
    page("A3_register_file_12x16.pdf", "Доп. лист 4, формат А3", "Регистровый файл 12 x 16", register_file)
    page("A3_alu_flags.pdf", "Доп. лист 5, формат А3", "АЛУ и регистр флагов", alu_flags)
    page("A3_stack7x16.pdf", "Доп. лист 6, формат А3", "Стек 7 x 16 с ростом вниз", stack)
    page("A4_rom_command_memory.pdf", "Доп. лист 7, формат А3", "Синхронное ПЗУ команд", rom)
    page("A4_ram_data_memory.pdf", "Доп. лист 8, формат А3", "Синхронное ОЗУ данных", ram)
    page("A4_cache_4way.pdf", "Доп. лист 9, формат А3", "Кэш 4-way со сквозной записью", cache)
    page("A4_dma_controller.pdf", "Доп. лист 10, формат А3", "Контроллер прямого доступа к памяти", dma_controller)
    page("A4_bus_arbiter.pdf", "Доп. лист 11, формат А3", "Централизованный параллельный арбитр", arbiter)
    page("A4_branch_predictor_a4.pdf", "Доп. лист 12, формат А3", "Предсказатель переходов A4", branch_predictor)


if __name__ == "__main__":
    generate_all()
