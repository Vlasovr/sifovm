#!/usr/bin/env python3
"""Generate compact printable appendix schemes for the SIFO VM coursework.

The goal of these drawings is not to dump the full synthesized netlist.  Each
page is a compact structural/logical view derived from the current VHDL module
set: real block names, real command set, 16-bit buses, 12 RON registers, 7x16
stack, 4-way cache, DMA and A4 branch predictor.
"""

from __future__ import annotations

import math
from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from reportlab.lib import colors
from reportlab.lib.enums import TA_CENTER, TA_LEFT
from reportlab.lib.pagesizes import A3, landscape
from reportlab.lib.styles import ParagraphStyle
from reportlab.pdfbase import pdfmetrics
from reportlab.pdfbase.ttfonts import TTFont
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph


PROJECT_DIR = Path(__file__).resolve().parents[1]
OUT_DIR = PROJECT_DIR / "documents" / "Схемы_для_печати_по_приложениям"
PDF_DIR = OUT_DIR / "pdf"
COMBINED_PDF = OUT_DIR / "Комплект_схем_приложения_А-Щ.pdf"

PAGE_W = 1600.0
PAGE_H = 1100.0

FONT_REGULAR = "CourseworkArial"
FONT_BOLD = "CourseworkArialBold"
FONT_PATH = Path(r"C:/Windows/Fonts/arial.ttf")
BOLD_FONT_PATH = Path(r"C:/Windows/Fonts/arialbd.ttf")

PANEL = colors.HexColor("#77a4d1")
PANEL_STROKE = colors.HexColor("#4f7fae")
PURPLE = colors.HexColor("#8a00b5")
CYAN = colors.HexColor("#008c8c")
BLUE = colors.HexColor("#004eea")
INK = colors.HexColor("#222222")
LIGHT_BLUE = colors.HexColor("#eaf2ff")
LIGHT_GREEN = colors.HexColor("#e7f6ec")
LIGHT_YELLOW = colors.HexColor("#fff7d6")
LIGHT_PURPLE = colors.HexColor("#f2e8ff")
LIGHT_RED = colors.HexColor("#ffe9e6")


@dataclass(frozen=True)
class Box:
    label: str
    x: float
    y: float
    w: float
    h: float
    fill: colors.Color = colors.white
    stroke: colors.Color = INK
    font_size: float = 13.0
    align: int = TA_CENTER
    dashed: bool = False

    @property
    def center(self) -> tuple[float, float]:
        return self.x + self.w / 2, self.y + self.h / 2


class Transform:
    def __init__(self) -> None:
        self.paper_w, self.paper_h = landscape(A3)
        margin = 22.0
        self.scale = min((self.paper_w - 2 * margin) / PAGE_W, (self.paper_h - 2 * margin) / PAGE_H)
        self.ox = (self.paper_w - PAGE_W * self.scale) / 2
        self.oy = (self.paper_h - PAGE_H * self.scale) / 2

    def point(self, x: float, y: float) -> tuple[float, float]:
        return self.ox + x * self.scale, self.oy + (PAGE_H - y) * self.scale

    def rect(self, box: Box) -> tuple[float, float, float, float]:
        px, py = self.point(box.x, box.y + box.h)
        return px, py, box.w * self.scale, box.h * self.scale

    def length(self, value: float) -> float:
        return value * self.scale


def register_fonts() -> None:
    if FONT_REGULAR not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_REGULAR, str(FONT_PATH)))
    if FONT_BOLD not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_BOLD, str(BOLD_FONT_PATH)))


def draw_text(
    c: canvas.Canvas,
    tr: Transform,
    text: str,
    x: float,
    y: float,
    w: float,
    h: float,
    font_size: float = 12.0,
    align: int = TA_CENTER,
    bold: bool = False,
    color: colors.Color = INK,
) -> None:
    if not text:
        return
    px, py = tr.point(x, y + h)
    pw, ph = tr.length(w), tr.length(h)
    padding = max(2.5, min(pw, ph) * 0.05)
    usable_w = max(4, pw - padding * 2)
    usable_h = max(4, ph - padding * 2)
    escaped = "<br/>".join(line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;") for line in text.splitlines())
    size = max(4.5, font_size * tr.scale)
    while size >= 4.4:
        style = ParagraphStyle(
            "txt",
            fontName=FONT_BOLD if bold else FONT_REGULAR,
            fontSize=size,
            leading=size * 1.12,
            alignment=align,
            textColor=color,
            splitLongWords=True,
            wordWrap="CJK",
        )
        p = Paragraph(escaped, style)
        _, need_h = p.wrap(usable_w, usable_h)
        if need_h <= usable_h or size <= 4.6:
            p.drawOn(c, px + padding, py + padding + max(0, (usable_h - need_h) / 2))
            return
        size -= 0.35


def draw_box(c: canvas.Canvas, tr: Transform, box: Box, rounded: bool = False, bold: bool = False) -> None:
    px, py, pw, ph = tr.rect(box)
    c.saveState()
    c.setFillColor(box.fill)
    c.setStrokeColor(box.stroke)
    c.setLineWidth(max(0.6, 1.2 * tr.scale))
    if box.dashed:
        c.setDash(6, 4)
    if rounded:
        c.roundRect(px, py, pw, ph, min(pw, ph) * 0.04, stroke=1, fill=1)
    else:
        c.rect(px, py, pw, ph, stroke=1, fill=1)
    c.restoreState()
    draw_text(c, tr, box.label, box.x, box.y, box.w, box.h, box.font_size, box.align, bold=bold, color=BLUE)


def panel(c: canvas.Canvas, tr: Transform, x: float = 70, y: float = 125, w: float = 1460, h: float = 780) -> Box:
    b = Box("", x, y, w, h, PANEL, PANEL_STROKE, 10)
    draw_box(c, tr, b, rounded=False)
    return b


def title_block(c: canvas.Canvas, tr: Transform, app: str, title: str) -> None:
    frame = Box("", 25, 25, PAGE_W - 50, PAGE_H - 50, colors.Color(1, 1, 1, alpha=0), INK)
    px, py, pw, ph = tr.rect(frame)
    c.saveState()
    c.setFillColor(colors.Color(1, 1, 1, alpha=0))
    c.setStrokeColor(INK)
    c.setLineWidth(1.6)
    c.rect(px, py, pw, ph, stroke=1, fill=0)
    c.restoreState()

    stamp = Box("", 950, 930, 585, 120, colors.white, INK)
    draw_box(c, tr, stamp, rounded=False)
    draw_text(c, tr, f"{app}\n{title}", 970, 945, 350, 90, 15, TA_LEFT, bold=True)
    draw_text(c, tr, "Разраб.\nВласов Р.Е.\nПров.\nТретьяков", 1325, 945, 115, 90, 10, TA_LEFT)
    draw_text(c, tr, "СиФО ЭВМ\nсхема для печати", 1440, 945, 80, 90, 9, TA_CENTER)


def port(c: canvas.Canvas, tr: Transform, text: str, x: float, y: float, side: str = "left") -> Box:
    b = Box(text, x, y, 110, 26, colors.white, CYAN, 8.5, TA_LEFT if side == "left" else TA_CENTER)
    draw_box(c, tr, b, rounded=False)
    return b


def component(c: canvas.Canvas, tr: Transform, label: str, x: float, y: float, w: float, h: float, fill: colors.Color = colors.white, fs: float = 11.5) -> Box:
    b = Box(label, x, y, w, h, fill, INK, fs)
    draw_box(c, tr, b, rounded=False)
    return b


def group(c: canvas.Canvas, tr: Transform, label: str, x: float, y: float, w: float, h: float) -> Box:
    b = Box(label, x, y, w, h, colors.Color(1, 1, 1, alpha=0), CYAN, 10.0, TA_CENTER, dashed=True)
    draw_box(c, tr, b, rounded=False)
    return b


def line(c: canvas.Canvas, tr: Transform, pts: list[tuple[float, float]], color: colors.Color = PURPLE, width: float = 2.0, arrow: bool = False, dashed: bool = False) -> None:
    if len(pts) < 2:
        return
    c.saveState()
    c.setStrokeColor(color)
    c.setFillColor(color)
    c.setLineWidth(max(0.7, width * tr.scale))
    if dashed:
        c.setDash(7, 4)
    p0 = tr.point(*pts[0])
    for a, b in zip(pts, pts[1:]):
        ax, ay = tr.point(*a)
        bx, by = tr.point(*b)
        c.line(ax, ay, bx, by)
    c.setDash()
    if arrow:
        sx, sy = tr.point(*pts[-2])
        ex, ey = tr.point(*pts[-1])
        ang = math.atan2(ey - sy, ex - sx)
        length = 8.0
        spread = 4.5
        path = c.beginPath()
        path.moveTo(ex, ey)
        path.lineTo(ex - length * math.cos(ang) + spread * math.sin(ang), ey - length * math.sin(ang) - spread * math.cos(ang))
        path.lineTo(ex - length * math.cos(ang) - spread * math.sin(ang), ey - length * math.sin(ang) + spread * math.cos(ang))
        path.close()
        c.drawPath(path, stroke=0, fill=1)
    c.restoreState()


def label(c: canvas.Canvas, tr: Transform, text: str, x: float, y: float, w: float = 120, color: colors.Color = PURPLE) -> None:
    draw_text(c, tr, text, x - w / 2, y - 10, w, 20, 9, TA_CENTER, color=color)


def connect(c: canvas.Canvas, tr: Transform, src: Box, dst: Box, text: str = "", color: colors.Color = PURPLE, width: float = 2.0) -> None:
    sx, sy = src.center
    dx, dy = dst.center
    if abs(dx - sx) >= abs(dy - sy):
        start = (src.x + (src.w if dx >= sx else 0), sy)
        end = (dst.x if dx >= sx else dst.x + dst.w, dy)
        mid = ((start[0] + end[0]) / 2, start[1])
        pts = [start, mid, (mid[0], end[1]), end]
    else:
        start = (sx, src.y + (src.h if dy >= sy else 0))
        end = (dx, dst.y if dy >= sy else dst.y + dst.h)
        mid = (start[0], (start[1] + end[1]) / 2)
        pts = [start, mid, (end[0], mid[1]), end]
    line(c, tr, pts, color=color, width=width, arrow=True)
    if text:
        lx = sum(p[0] for p in pts) / len(pts)
        ly = sum(p[1] for p in pts) / len(pts)
        label(c, tr, text, lx, ly)


def gate(c: canvas.Canvas, tr: Transform, kind: str, x: float, y: float) -> Box:
    b = Box(kind, x, y, 62, 42, colors.white, INK, 10)
    draw_box(c, tr, b, rounded=False, bold=True)
    return b


def mux(c: canvas.Canvas, tr: Transform, label_text: str, x: float, y: float, w: float = 95, h: float = 80) -> Box:
    px1, py1 = tr.point(x, y + h)
    px2, py2 = tr.point(x + w, y + h / 2)
    px3, py3 = tr.point(x, y)
    c.saveState()
    c.setFillColor(colors.white)
    c.setStrokeColor(INK)
    c.setLineWidth(1.0)
    path = c.beginPath()
    path.moveTo(px1, py1)
    path.lineTo(px2, py2)
    path.lineTo(px3, py3)
    path.close()
    c.drawPath(path, stroke=1, fill=1)
    c.restoreState()
    b = Box(label_text, x, y, w, h, colors.Color(1, 1, 1, alpha=0), colors.Color(1, 1, 1, alpha=0), 10)
    draw_text(c, tr, label_text, x + 8, y + 10, w - 15, h - 20, 10, TA_CENTER, color=BLUE)
    return b


def dff(c: canvas.Canvas, tr: Transform, name: str, x: float, y: float, w: float = 118, h: float = 72) -> Box:
    return component(c, tr, f"{name}\nDFF\nD[15:0]  Q[15:0]\nclk / en", x, y, w, h, colors.white, 8.5)


def small_array(c: canvas.Canvas, tr: Transform, title: str, x: float, y: float, count: int, prefix: str, bits: str = "[15:0]") -> list[Box]:
    group(c, tr, title, x - 18, y - 24, 190, count * 44 + 48)
    boxes = []
    for i in range(count):
        boxes.append(component(c, tr, f"{prefix}{i}{bits}", x, y + i * 44, 150, 32, colors.white, 8.3))
    return boxes


def table(c: canvas.Canvas, tr: Transform, title: str, rows: list[tuple[str, str]], x: float, y: float, w: float, row_h: float = 36) -> Box:
    h = 50 + len(rows) * row_h
    outer = Box("", x, y, w, h, colors.white, INK)
    draw_box(c, tr, outer)
    draw_box(c, tr, Box(title, x, y, w, 50, LIGHT_YELLOW, INK, 13), bold=True)
    for n, (a, b) in enumerate(rows):
        yy = y + 50 + n * row_h
        draw_box(c, tr, Box(a, x, yy, w * 0.36, row_h, colors.white, colors.HexColor("#bbbbbb"), 9, TA_LEFT))
        draw_box(c, tr, Box(b, x + w * 0.36, yy, w * 0.64, row_h, colors.white, colors.HexColor("#bbbbbb"), 9, TA_LEFT))
    return outer


def draw_header_note(c: canvas.Canvas, tr: Transform, text: str) -> None:
    draw_text(c, tr, text, 70, 55, 820, 42, 12, TA_LEFT, bold=True)


def page_a(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    draw_header_note(c, tr, "Формат команды: два 16-разрядных слова, IR0 содержит opcode и номер РОН, IR1 содержит адрес/операнд.")
    rom = component(c, tr, "rom_sync\nПЗУ команд\nROM_INIT[0..255]\nword_t = 16 бит", 120, 210, 230, 120, LIGHT_BLUE)
    ir0 = dff(c, tr, "IR0", 470, 190)
    ir1 = dff(c, tr, "IR1", 470, 320)
    dec = component(c, tr, "opcode decoder\nIR0[15:8]\nOP_HLT..OP_JZ", 700, 210, 230, 220, colors.white)
    fields = table(c, tr, "Поля команды", [("IR0[15:8]", "код операции"), ("IR0[7:4]", "номер РОН R0..R11"), ("IR0[3:0]", "резерв"), ("IR1[15:0]", "адрес ОЗУ/ПЗУ или X")], 1030, 190, 410)
    ops = table(c, tr, "Система команд", [("00", "HLT"), ("01", "M->R"), ("02", "R->M"), ("03", "OR"), ("04", "NOR"), ("05", "SRA"), ("06", "INCS"), ("07", "PUSH"), ("08", "POP"), ("09", "JMP"), ("0A", "JZ")], 1030, 420, 410, 30)
    connect(c, tr, rom, ir0, "rom_data_i")
    connect(c, tr, rom, ir1, "rom_data_i")
    connect(c, tr, ir0, dec, "opcode/reg")
    connect(c, tr, ir0, fields, "IR0")
    connect(c, tr, ir1, fields, "IR1")
    connect(c, tr, dec, ops, "one-hot")


def page_b(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    cpu = component(c, tr, "cpu_core\nrom_addr_o\ncache_req_o/cache_we_o", 120, 380, 230, 150, LIGHT_YELLOW)
    rom = component(c, tr, "rom_sync\nсинхронное ПЗУ\n256 x 16\nтолько чтение", 510, 230, 230, 135, LIGHT_BLUE)
    cache = component(c, tr, "cache_4way_age\n4-way, 16 sets\nTAG + VALID + AGE\nwrite-through", 510, 500, 260, 170, LIGHT_GREEN)
    ram = component(c, tr, "ram_sync\nсинхронное ОЗУ\n256 x 16\nчтение/запись", 1020, 500, 250, 155, LIGHT_BLUE)
    arb = component(c, tr, "bus_arbiter_2master\nREQ_CPU/REQ_DMA\nGNT_CPU/GNT_DMA", 820, 720, 250, 115, LIGHT_YELLOW)
    dma = component(c, tr, "dma_controller_3word\nbase = 000A\n3 слова = 6 байт", 1210, 720, 250, 115, LIGHT_YELLOW)
    connect(c, tr, cpu, rom, "команды")
    connect(c, tr, cpu, cache, "данные")
    connect(c, tr, cache, ram, "ram_req/we/addr/data")
    connect(c, tr, cache, arb, "REQ_CPU")
    connect(c, tr, dma, arb, "REQ_DMA")
    connect(c, tr, arb, cache, "GNT_CPU")
    connect(c, tr, arb, dma, "GNT_DMA")
    connect(c, tr, dma, ram, "DMA write")
    draw_text(c, tr, "Гарвардская структура: тракт команд отделён от тракта данных.", 930, 245, 430, 70, 13, TA_CENTER, bold=True)


def page_c(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    ir = component(c, tr, "IR0/IR1\nopcode, reg, addr", 120, 220, 220, 110, LIGHT_BLUE)
    dec = component(c, tr, "дешифратор\nOP_HLT..OP_JZ", 430, 200, 220, 130, colors.white)
    fsm = table(c, tr, "Автомат управления", [("FETCH0/1", "выборка двух слов"), ("DECODE", "анализ opcode"), ("CACHE_READ/WRITE", "обмен с кэшем"), ("ALU_WRITE", "запись результата"), ("STACK_PUSH/POP", "операции стека"), ("BRANCH_JMP/JZ", "загрузка PC"), ("HALT", "останов")], 760, 155, 360, 38)
    matrix = component(c, tr, "матрица управляющих сигналов\nrf_we, alu_op, cache_req,\nstack_push/pop, flag_we,\nbp_query/update, halt", 1170, 260, 270, 190, LIGHT_YELLOW)
    pc = dff(c, tr, "PC", 430, 560, 125, 80)
    flags = component(c, tr, "FR.Z/S/C/O\nусловия JZ, INCS", 120, 560, 220, 100, LIGHT_PURPLE)
    outs = component(c, tr, "исполнительные блоки\nРОН / АЛУ / стек / кэш\nПЗУ / ОЗУ / предсказатель", 1170, 620, 270, 150, LIGHT_GREEN)
    connect(c, tr, ir, dec, "IR0[15:8]")
    connect(c, tr, dec, fsm, "opcode")
    connect(c, tr, flags, fsm, "FR.Z/S")
    connect(c, tr, pc, fsm, "PC")
    connect(c, tr, fsm, matrix, "state")
    connect(c, tr, matrix, outs, "control")
    connect(c, tr, fsm, pc, "next_pc")


def page_d(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    pc = dff(c, tr, "PC/IP", 165, 210, 150, 90)
    inc = component(c, tr, "+2\nследующая команда", 410, 200, 145, 75, colors.white)
    mux_pc = mux(c, tr, "PC mux\n+2 / IR1", 650, 195, 120, 95)
    ir0 = dff(c, tr, "IR0", 165, 420, 150, 90)
    ir1 = dff(c, tr, "IR1", 410, 420, 150, 90)
    fr = component(c, tr, "FR\nZ  S  C  O\nDFF x4", 650, 420, 170, 95, LIGHT_PURPLE)
    sp = component(c, tr, "SP\n3 бита\n0..7", 900, 420, 150, 95, LIGHT_PURPLE)
    reg = component(c, tr, "dbg регистры\nstate, R1..R7,\ncache_hit/miss", 1130, 400, 270, 130, LIGHT_YELLOW)
    connect(c, tr, pc, inc, "PC")
    connect(c, tr, inc, mux_pc, "PC+2")
    connect(c, tr, ir1, mux_pc, "JMP/JZ target")
    connect(c, tr, mux_pc, pc, "pc_load")
    connect(c, tr, ir0, fr, "alu flags")
    connect(c, tr, sp, reg, "dbg_sp")
    connect(c, tr, fr, reg, "dbg_flags")
    draw_text(c, tr, "Специальные регистры фиксируют состояние выборки, результата АЛУ, стека и отладочных шин.", 175, 720, 1080, 70, 14, TA_CENTER, bold=True)


def page_e(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr, 45, 95, 1510, 850)
    inputs = component(c, tr, "DATA_IN[15:0]\nWR_ADDR[3:0]\nRD_A/RD_B[3:0]\nWE / CLK", 90, 210, 210, 150, LIGHT_YELLOW)
    dec = component(c, tr, "decode 4->12\nwrite enable\nкод 12..15 = резерв", 390, 190, 210, 140, colors.white)
    regs = small_array(c, tr, "reg_file12x16", 705, 125, 12, "R", "[15:0]")
    mux_a = component(c, tr, "MUX A\n12->1\nDOUT_A", 1040, 235, 150, 95, colors.white)
    mux_b = component(c, tr, "MUX B\n12->1\nDOUT_B", 1040, 465, 150, 95, colors.white)
    out = component(c, tr, "к АЛУ / стеку / памяти\nrf_a, rf_b", 1270, 345, 220, 120, LIGHT_GREEN)
    connect(c, tr, inputs, dec, "wr_addr/we")
    for i, r in enumerate(regs):
        line(c, tr, [(600, 260), (665, 260), (665, r.center[1]), (r.x, r.center[1])], arrow=True)
        line(c, tr, [(r.x + r.w, r.center[1]), (1015, r.center[1]), (1015, mux_a.center[1]), (mux_a.x, mux_a.center[1])], arrow=True, width=1.2)
        line(c, tr, [(r.x + r.w, r.center[1]), (1000, r.center[1]), (1000, mux_b.center[1]), (mux_b.x, mux_b.center[1])], arrow=True, width=1.2)
    connect(c, tr, mux_a, out, "rf_a")
    connect(c, tr, mux_b, out, "rf_b")


def page_f(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    dec = component(c, tr, "opcode decoder\nHLT, JMP, JZ,\nM->R, R->M", 150, 260, 230, 160, colors.white)
    hlt = component(c, tr, "HLT\nstate <= S_HALT\nhalt_o = 1", 520, 170, 220, 100, LIGHT_RED)
    jmp = component(c, tr, "JMP/JZ\nPC <= IR1\nили PC <= PC+2", 520, 315, 220, 115, LIGHT_PURPLE)
    mr = component(c, tr, "M->R\ncache read\nrf_we", 520, 480, 220, 105, LIGHT_GREEN)
    rm = component(c, tr, "R->M\ncache write\nwrite-through", 520, 625, 220, 105, LIGHT_GREEN)
    pc = dff(c, tr, "PC", 930, 260, 135, 85)
    rf = component(c, tr, "РОН\n12 x 16", 930, 490, 160, 95, LIGHT_BLUE)
    cache = component(c, tr, "кэш/ОЗУ\naddr = IR1", 1185, 490, 190, 105, LIGHT_GREEN)
    connect(c, tr, dec, hlt, "OP_HLT")
    connect(c, tr, dec, jmp, "OP_JMP/JZ")
    connect(c, tr, dec, mr, "OP_MR")
    connect(c, tr, dec, rm, "OP_RM")
    connect(c, tr, jmp, pc, "pc_load")
    connect(c, tr, mr, cache, "read")
    connect(c, tr, cache, rf, "rdata")
    connect(c, tr, rf, rm, "wdata")
    connect(c, tr, rm, cache, "write")


def page_g(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    ir1 = dff(c, tr, "IR1", 170, 320, 150, 90)
    pc_inc = component(c, tr, "PC + 2", 170, 520, 150, 70, colors.white)
    sel = component(c, tr, "OP_JMP\nselect target", 470, 300, 200, 95, LIGHT_YELLOW)
    mx = mux(c, tr, "MUX\nnext_pc", 780, 335, 120, 110)
    pc = dff(c, tr, "PC/IP", 1090, 320, 160, 95)
    connect(c, tr, ir1, mx, "IR1[15:0]")
    connect(c, tr, pc_inc, mx, "PC+2")
    connect(c, tr, sel, mx, "sel")
    connect(c, tr, mx, pc, "pc_r <= IR1")
    draw_text(c, tr, "Безусловный переход не использует АЛУ и память данных: адрес назначения берётся из второго слова команды.", 225, 700, 1000, 70, 14, TA_CENTER, bold=True)


def page_i(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    ir1 = dff(c, tr, "IR1 addr", 145, 260, 160, 90)
    cache = component(c, tr, "cache_4way_age\ncpu_req=1\ncpu_we=0\nready/hit/miss", 465, 220, 250, 160, LIGHT_GREEN)
    ram = component(c, tr, "ram_sync\nесли miss\nread data", 465, 560, 250, 115, LIGHT_BLUE)
    rf = component(c, tr, "РОН\nwrite Rn\nrf_we=1", 1010, 335, 210, 120, LIGHT_BLUE)
    ctrl = component(c, tr, "S_CACHE_READ\nS_RF_WRITE_MEM", 1010, 570, 235, 105, LIGHT_YELLOW)
    connect(c, tr, ir1, cache, "addr")
    connect(c, tr, cache, ram, "miss read")
    connect(c, tr, ram, cache, "ram_rdata")
    connect(c, tr, cache, rf, "cache_rdata_i")
    connect(c, tr, ctrl, cache, "req")
    connect(c, tr, ctrl, rf, "rf_we")


def page_k(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    rf = component(c, tr, "РОН\nrf_a = Rn", 165, 310, 190, 115, LIGHT_BLUE)
    ir1 = dff(c, tr, "IR1 addr", 165, 520, 150, 85)
    cache = component(c, tr, "cache_4way_age\ncpu_req=1\ncpu_we=1\nwrite-through", 540, 335, 260, 155, LIGHT_GREEN)
    ram = component(c, tr, "ram_sync\nзапись слова\nпри grant", 1035, 335, 240, 125, LIGHT_BLUE)
    arb = component(c, tr, "арбитр\nGNT_CPU", 820, 620, 190, 90, LIGHT_YELLOW)
    connect(c, tr, rf, cache, "wdata")
    connect(c, tr, ir1, cache, "addr")
    connect(c, tr, cache, arb, "REQ_CPU")
    connect(c, tr, arb, cache, "GNT_CPU")
    connect(c, tr, cache, ram, "ram_we/addr/data")


def page_l(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    a = dff(c, tr, "A reg", 125, 230, 135, 80)
    b = dff(c, tr, "B reg", 125, 430, 135, 80)
    op = component(c, tr, "ALU_OP[2:0]\nOR/NOR/SRA/INCS", 125, 650, 185, 100, LIGHT_YELLOW)
    blocks = [
        component(c, tr, "OR\nA or B", 430, 160, 150, 80, colors.white),
        component(c, tr, "NOR\nnot(A or B)", 430, 290, 150, 80, colors.white),
        component(c, tr, "SRA\nA15 & A15..1", 430, 420, 150, 80, colors.white),
        component(c, tr, "INCS\nA + flag_S", 430, 550, 150, 80, colors.white),
    ]
    mx = mux(c, tr, "MUX\nY", 760, 350, 130, 145)
    flags = component(c, tr, "flags logic\nZ,S,C,O", 1010, 360, 210, 110, LIGHT_PURPLE)
    out = component(c, tr, "Y[15:0]\nк записи в РОН", 1280, 360, 200, 105, LIGHT_GREEN)
    for b0 in blocks:
        connect(c, tr, a, b0, "A")
        if "SRA" not in b0.label and "INCS" not in b0.label:
            connect(c, tr, b, b0, "B")
        connect(c, tr, b0, mx, "result")
    connect(c, tr, op, mx, "select")
    connect(c, tr, mx, flags, "Y")
    connect(c, tr, mx, out, "Y")


def page_m(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    a = port(c, tr, "A[15:0]", 120, 250)
    b = port(c, tr, "B[15:0]", 120, 520)
    gates = []
    for i in range(8):
        gates.append(gate(c, tr, "OR", 420 + (i % 4) * 120, 210 + (i // 4) * 180))
    out = component(c, tr, "Y[i] = A[i] OR B[i]\nповторяется для 16 разрядов", 940, 330, 300, 130, LIGHT_GREEN)
    z = component(c, tr, "Z <= (Y = 0000h)\nS <= Y[15]\nC,O <= 0", 940, 540, 300, 120, LIGHT_PURPLE)
    for g in gates:
        connect(c, tr, a, g, "A_i", width=1.2)
        connect(c, tr, b, g, "B_i", width=1.2)
        connect(c, tr, g, out, "Y_i", width=1.2)
    connect(c, tr, out, z, "Y[15:0]")


def page_n(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    a = port(c, tr, "A[15:0]", 120, 250)
    b = port(c, tr, "B[15:0]", 120, 520)
    or_block = component(c, tr, "OR tree\nT = A OR B", 430, 330, 210, 110, colors.white)
    inv = component(c, tr, "INV[15:0]\nY = NOT T", 760, 330, 190, 110, colors.white)
    flags = component(c, tr, "flags\nZ/S обновляются\nC,O = 0", 1080, 330, 230, 110, LIGHT_PURPLE)
    connect(c, tr, a, or_block, "A")
    connect(c, tr, b, or_block, "B")
    connect(c, tr, or_block, inv, "T")
    connect(c, tr, inv, flags, "Y")


def page_p(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    a = component(c, tr, "A[15:0]\nисходный регистр", 170, 330, 210, 105, LIGHT_BLUE)
    wiring = component(c, tr, "арифметический сдвиг вправо\nY[15] = A[15]\nY[14:0] = A[15:1]", 560, 285, 310, 170, colors.white)
    carry = component(c, tr, "C <= A[0]\nвытесненный бит", 560, 540, 250, 85, LIGHT_PURPLE)
    out = component(c, tr, "Y[15:0]\nсохранение знака", 1080, 340, 230, 105, LIGHT_GREEN)
    connect(c, tr, a, wiring, "A[15:1]")
    connect(c, tr, a, carry, "A[0]")
    connect(c, tr, wiring, out, "Y")
    draw_text(c, tr, "SRA не обращается к памяти: используется только выбранный РОН.", 260, 720, 900, 60, 14, TA_CENTER, bold=True)


def page_r(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    a = component(c, tr, "A[15:0]\nвыбранный РОН", 160, 315, 210, 110, LIGHT_BLUE)
    fs = component(c, tr, "FR.S\n0 или 1", 160, 560, 160, 85, LIGHT_PURPLE)
    ext = component(c, tr, "zero extend\n000...FR.S", 510, 535, 220, 90, colors.white)
    add = component(c, tr, "16-bit adder\nY = A + FR.S", 510, 315, 250, 120, colors.white)
    flags = component(c, tr, "C = carry\nO = overflow\nZ/S from Y", 980, 330, 240, 125, LIGHT_PURPLE)
    connect(c, tr, a, add, "A")
    connect(c, tr, fs, ext, "S")
    connect(c, tr, ext, add, "+0/+1")
    connect(c, tr, add, flags, "Y/C/O")


def page_s(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    alu = component(c, tr, "ALU result\nY[15:0], C_raw, O_raw", 150, 320, 240, 120, LIGHT_GREEN)
    zlogic = component(c, tr, "NOR всех битов Y\nZ = 1 если Y=0", 520, 170, 220, 100, colors.white)
    slogic = component(c, tr, "S = Y[15]", 520, 320, 160, 80, colors.white)
    clogic = component(c, tr, "C\nSRA: A[0]\nINCS: carry", 520, 455, 210, 105, colors.white)
    ologic = component(c, tr, "O\nпереполнение INCS", 520, 615, 210, 80, colors.white)
    regs = small_array(c, tr, "flags_reg", 900, 210, 4, "FR.", "")
    for name, r in zip(["Z", "S", "C", "O"], regs):
        draw_text(c, tr, name, r.x + 55, r.y + 5, 40, 22, 10, TA_CENTER, bold=True, color=BLUE)
    for dst in [zlogic, slogic, clogic, ologic]:
        connect(c, tr, alu, dst, "Y/raw", width=1.3)
    for src, dst in zip([zlogic, slogic, clogic, ologic], regs):
        connect(c, tr, src, dst, "we")


def page_t(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    din = port(c, tr, "din_i[15:0]", 100, 300)
    sp = component(c, tr, "SP counter\n3 бита\nempty=7, full=0", 380, 245, 220, 130, LIGHT_PURPLE)
    dec = component(c, tr, "decoder\nSP-1 for PUSH\nSP for POP", 380, 520, 220, 125, colors.white)
    cells = small_array(c, tr, "stack memory 7 x 16", 745, 180, 7, "STK", "[15:0]")
    mx = component(c, tr, "MUX read\nselected STK[SP]", 1080, 330, 210, 110, colors.white)
    out = port(c, tr, "dout_o[15:0]", 1345, 365)
    connect(c, tr, din, cells[-1], "write data")
    connect(c, tr, sp, dec, "SP")
    for cell in cells:
        connect(c, tr, dec, cell, "we/sel", width=1.0)
        connect(c, tr, cell, mx, "q", width=1.0)
    connect(c, tr, mx, out, "pop data")


def page_u(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    ctrl = component(c, tr, "УУ\nS_STACK_PUSH\nS_STACK_POP\nS_RF_WRITE_POP", 120, 330, 230, 150, LIGHT_YELLOW)
    rf = component(c, tr, "РОН\nrf_a -> PUSH\nrf_din <- POP", 500, 260, 230, 135, LIGHT_BLUE)
    stack = component(c, tr, "stack7x16\npush_i/pop_i\nSP 7..0", 860, 320, 240, 145, LIGHT_PURPLE)
    rfwr = component(c, tr, "запись POP\nrf_we=1\nwr_addr=Rn", 1240, 300, 220, 120, LIGHT_GREEN)
    connect(c, tr, ctrl, stack, "push/pop")
    connect(c, tr, rf, stack, "din_i")
    connect(c, tr, stack, rfwr, "dout_o")
    connect(c, tr, rfwr, rf, "rf_din")
    draw_text(c, tr, "PUSH: SP уменьшается, слово пишется в STK[SP-1]. POP: слово читается из STK[SP], SP увеличивается.", 260, 670, 960, 70, 14, TA_CENTER, bold=True)


def page_f_cache(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    cpu = component(c, tr, "CPU data port\nreq/we/addr/wdata", 95, 360, 230, 130, LIGHT_YELLOW)
    addr = component(c, tr, "addr split\nTAG=addr[15:4]\nSET=addr[3:0]", 420, 170, 230, 120, colors.white)
    ways = component(c, tr, "4 ways x 16 sets\nDATA + TAG + VALID + AGE", 420, 360, 260, 155, LIGHT_GREEN)
    cmp = component(c, tr, "compare TAG\nhit0..hit3\nhit = OR", 790, 330, 220, 130, colors.white)
    fsm = component(c, tr, "cache FSM\nIDLE\nWAIT_READ_GRANT\nWAIT_READ_DATA\nWAIT_WRITE_GRANT", 1080, 210, 270, 170, LIGHT_PURPLE)
    ram = component(c, tr, "RAM bus\nram_req/we/addr/data\ngrant", 1080, 530, 270, 130, LIGHT_BLUE)
    connect(c, tr, cpu, addr, "addr")
    connect(c, tr, addr, ways, "set/tag")
    connect(c, tr, ways, cmp, "tag/valid")
    connect(c, tr, cmp, cpu, "ready/hit/miss")
    connect(c, tr, cmp, fsm, "miss/write")
    connect(c, tr, fsm, ram, "request")
    connect(c, tr, ram, ways, "fill/write")


def page_x(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr, 45, 95, 1510, 850)
    req = component(c, tr, "request register\naddr, wdata, we", 75, 365, 210, 120, LIGHT_YELLOW)
    way_boxes = []
    for i in range(4):
        g = group(c, tr, f"WAY {i}", 390, 135 + i * 185, 300, 150)
        data = component(c, tr, f"DATA way {i}\n16 x 16", 410, 170 + i * 185, 130, 70, colors.white, 9)
        tag = component(c, tr, f"TAG {i}\nV + AGE", 560, 155 + i * 185, 105, 95, colors.white, 9)
        way_boxes.append((data, tag))
    cmps = [component(c, tr, f"cmp {i}\ntag==TAG\nAND V", 805, 165 + i * 185, 150, 80, colors.white, 9) for i in range(4)]
    hit_or = component(c, tr, "OR\nhit0..hit3", 1040, 380, 150, 90, colors.white)
    mx = component(c, tr, "MUX 4->1\nread data", 1250, 360, 170, 105, colors.white)
    for i, ((data, tag), cmpb) in enumerate(zip(way_boxes, cmps)):
        connect(c, tr, req, data, "set", width=1.0)
        connect(c, tr, tag, cmpb, "tag/valid", width=1.0)
        connect(c, tr, data, mx, f"data{i}", width=1.0)
        connect(c, tr, cmpb, hit_or, f"hit{i}", width=1.0)
    connect(c, tr, hit_or, mx, "select")


def page_ts(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    valid = component(c, tr, "VALID bits\n4 ways x 16 sets", 130, 170, 240, 110, LIGHT_GREEN)
    tag = component(c, tr, "TAG RAM\n12-bit tag\nfor each way", 130, 350, 240, 120, LIGHT_GREEN)
    age = component(c, tr, "AGE counters\n2-bit saturating\nmax-age replacement", 130, 560, 260, 130, LIGHT_GREEN)
    hit = component(c, tr, "hit update\nchosen way age=0\nothers inc_age", 580, 245, 280, 130, colors.white)
    miss = component(c, tr, "miss/victim select\ninvalid first\nelse max AGE", 580, 505, 280, 145, colors.white)
    fill = component(c, tr, "fill/write path\nset VALID=1\nwrite TAG/DATA", 1030, 365, 280, 145, LIGHT_YELLOW)
    for src in [valid, tag, age]:
        connect(c, tr, src, hit, "status", width=1.1)
        connect(c, tr, src, miss, "status", width=1.1)
    connect(c, tr, hit, fill, "hit write")
    connect(c, tr, miss, fill, "victim")


def page_sh(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr, 45, 95, 1510, 850)
    cpu = component(c, tr, "cpu_core\nУУ + РОН + АЛУ + стек\nPC/IR/FR", 145, 315, 260, 170, LIGHT_YELLOW)
    rom = component(c, tr, "ПЗУ команд\nrom_sync", 160, 640, 210, 100, LIGHT_BLUE)
    cache = component(c, tr, "кэш данных\n4-way / AGE", 560, 320, 230, 130, LIGHT_GREEN)
    ram = component(c, tr, "ОЗУ данных\nram_sync", 950, 320, 230, 130, LIGHT_BLUE)
    dma = component(c, tr, "КПДП\n3 слова @ 10", 950, 620, 230, 110, LIGHT_YELLOW)
    arb = component(c, tr, "арбитр шины\nприоритет DMA", 720, 610, 190, 105, LIGHT_YELLOW)
    bp = component(c, tr, "предсказатель A4\nPHT + BTB + GHR", 560, 145, 260, 115, LIGHT_PURPLE)
    halt = component(c, tr, "HALT / debug\nstate, R1..R7,\nflags, SP", 1220, 180, 230, 125, LIGHT_PURPLE)
    connect(c, tr, cpu, rom, "rom_addr/data")
    connect(c, tr, cpu, cache, "data port")
    connect(c, tr, cache, ram, "RAM bus")
    connect(c, tr, cache, arb, "REQ_CPU")
    connect(c, tr, dma, arb, "REQ_DMA")
    connect(c, tr, arb, cache, "GNT_CPU")
    connect(c, tr, arb, dma, "GNT_DMA")
    connect(c, tr, dma, ram, "write")
    connect(c, tr, cpu, bp, "query/update")
    connect(c, tr, cpu, halt, "debug")


def page_shch(c: canvas.Canvas, tr: Transform) -> None:
    panel(c, tr)
    pc = component(c, tr, "PC query\npc_query_i[15:0]", 120, 230, 220, 100, LIGHT_BLUE)
    ghr = component(c, tr, "GHR[1:0]\nсдвиг истории", 120, 520, 220, 100, LIGHT_PURPLE)
    idx = component(c, tr, "INDEX\nPC[1:0] || GHR[1:0]\n4 бита", 485, 345, 260, 130, colors.white)
    pht = component(c, tr, "PHT\n16 x 2-bit\nсчётчики насыщения", 880, 185, 250, 125, LIGHT_GREEN)
    btb = component(c, tr, "BTB\n16 target + valid\nадрес цели", 880, 465, 250, 125, LIGHT_GREEN)
    pred = component(c, tr, "predict logic\nPHT[1]=1 and BTB.valid\npred_taken/target", 1230, 325, 250, 145, LIGHT_YELLOW)
    upd = component(c, tr, "update on JZ\nsat_inc/sat_dec\nGHR <= GHR(0)&taken", 485, 665, 320, 130, LIGHT_PURPLE)
    connect(c, tr, pc, idx, "PC(2)")
    connect(c, tr, ghr, idx, "GHR(2)")
    connect(c, tr, idx, pht, "index")
    connect(c, tr, idx, btb, "index")
    connect(c, tr, pht, pred, "state")
    connect(c, tr, btb, pred, "target")
    connect(c, tr, pred, upd, "actual update", width=1.3)
    connect(c, tr, upd, ghr, "next GHR")


PAGES: list[tuple[str, str, str, Callable[[canvas.Canvas, Transform], None]]] = [
    ("А", "Система команд микро-ЭВМ", "Приложение_А_Система_команд.pdf", page_a),
    ("Б", "Совмещенный блок запоминающих устройств", "Приложение_Б_Совмещенный_блок_ЗУ.pdf", page_b),
    ("В", "Блок устройства управления", "Приложение_В_Устройство_управления.pdf", page_c),
    ("Г", "Блок специальных регистров", "Приложение_Г_Специальные_регистры.pdf", page_d),
    ("Д", "Блок регистров общего назначения", "Приложение_Д_РОН.pdf", page_e),
    ("Е", "Блок общих операций", "Приложение_Е_Общие_операции.pdf", page_f),
    ("Ж", "Блок операции безусловный переход", "Приложение_Ж_JMP.pdf", page_g),
    ("И", "Блок операции M->R", "Приложение_И_M_to_R.pdf", page_i),
    ("К", "Блок операции R->M", "Приложение_К_R_to_M.pdf", page_k),
    ("Л", "Блок арифметико-логического устройства", "Приложение_Л_АЛУ.pdf", page_l),
    ("М", "Блок операции побитовое ИЛИ", "Приложение_М_OR.pdf", page_m),
    ("Н", "Блок операции побитовое ИЛИ-НЕ", "Приложение_Н_NOR.pdf", page_n),
    ("П", "Блок операции арифметический сдвиг вправо", "Приложение_П_SRA.pdf", page_p),
    ("Р", "Блок операции инкремент по флагу S", "Приложение_Р_INCS.pdf", page_r),
    ("С", "Блок формирования регистра флагов", "Приложение_С_Регистр_флагов.pdf", page_s),
    ("Т", "Блок стекового устройства", "Приложение_Т_Стек.pdf", page_t),
    ("У", "Исполнительный блок стекового ЗУ", "Приложение_У_Исполнительный_блок_стека.pdf", page_u),
    ("Ф", "Блок кэш-памяти", "Приложение_Ф_Кэш.pdf", page_f_cache),
    ("Х", "Блок данных кэша", "Приложение_Х_Данные_кэша.pdf", page_x),
    ("Ц", "Блок флагов кэша", "Приложение_Ц_Флаги_кэша.pdf", page_ts),
    ("Ш", "Блок микро-ЭВМ", "Приложение_Ш_Микро_ЭВМ.pdf", page_sh),
    ("Щ", "Блок управления предсказателя переходов", "Приложение_Щ_Предсказатель_A4.pdf", page_shch),
]


def draw_page(c: canvas.Canvas, app: str, title: str, draw: Callable[[canvas.Canvas, Transform], None]) -> None:
    tr = Transform()
    title_block(c, tr, f"ПРИЛОЖЕНИЕ {app}", title)
    draw(c, tr)


def make_one_pdf(filename: str, app: str, title: str, draw: Callable[[canvas.Canvas, Transform], None]) -> None:
    PDF_DIR.mkdir(parents=True, exist_ok=True)
    path = PDF_DIR / filename
    c = canvas.Canvas(str(path), pagesize=landscape(A3))
    c.setTitle(f"Приложение {app}: {title}")
    c.setAuthor("Власов Р.Е.")
    draw_page(c, app, title, draw)
    c.showPage()
    c.save()


def main() -> None:
    register_fonts()
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    PDF_DIR.mkdir(parents=True, exist_ok=True)

    combined = canvas.Canvas(str(COMBINED_PDF), pagesize=landscape(A3))
    combined.setTitle("Комплект схем приложений А-Щ")
    combined.setAuthor("Власов Р.Е.")

    for app, title, filename, draw in PAGES:
        make_one_pdf(filename, app, title, draw)
        draw_page(combined, app, title, draw)
        combined.showPage()
        print(PDF_DIR / filename)

    combined.save()
    readme = OUT_DIR / "README.txt"
    readme.write_text(
        "Комплект обобщённых структурно-логических схем для приложений А-Щ.\n"
        "Схемы сделаны по текущей архитектуре проекта: 16-битные шины, 12 РОН,\n"
        "стек 7x16, АЛУ OR/NOR/SRA/INCS, кэш 4-way, КПДП и предсказатель A4.\n"
        "Основной файл для печати: Комплект_схем_приложения_А-Щ.pdf\n",
        encoding="utf-8",
    )
    print(COMBINED_PDF)


if __name__ == "__main__":
    main()
