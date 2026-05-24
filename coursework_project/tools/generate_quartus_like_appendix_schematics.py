#!/usr/bin/env python3
"""Generate Quartus/RTL-viewer-like printable appendix schematics.

These pages intentionally look like compact synthesized schematics: white page,
small LPM/DFF/MUX/COMPARE/logic blocks, teal ports/groups and purple wires.
They are not a full netlist dump, but a readable pseudo-RTL representation of
the real coursework architecture.
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
OUT_DIR = PROJECT_DIR / "documents" / "Схемы_как_у_товарища"
PDF_DIR = OUT_DIR / "pdf"
COMBINED = OUT_DIR / "Комплект_RTL_схем_приложения_А-Щ.pdf"

PAGE_W = 1600.0
PAGE_H = 1100.0
FONT = "ArialCoursework"
FONT_B = "ArialCourseworkBold"
FONT_PATH = Path(r"C:/Windows/Fonts/arial.ttf")
FONT_B_PATH = Path(r"C:/Windows/Fonts/arialbd.ttf")

INK = colors.HexColor("#202020")
WIRE = colors.HexColor("#8b00b5")
TEAL = colors.HexColor("#00897b")
BLUE = colors.HexColor("#0067ff")
MAGENTA = colors.HexColor("#bb00bb")
PALE = colors.HexColor("#f8fbff")
YELLOW = colors.HexColor("#fff9dd")


@dataclass
class B:
    name: str
    x: float
    y: float
    w: float
    h: float

    @property
    def c(self) -> tuple[float, float]:
        return self.x + self.w / 2, self.y + self.h / 2

    @property
    def l(self) -> tuple[float, float]:
        return self.x, self.y + self.h / 2

    @property
    def r(self) -> tuple[float, float]:
        return self.x + self.w, self.y + self.h / 2

    @property
    def t(self) -> tuple[float, float]:
        return self.x + self.w / 2, self.y

    @property
    def b(self) -> tuple[float, float]:
        return self.x + self.w / 2, self.y + self.h


class T:
    def __init__(self) -> None:
        self.pw, self.ph = landscape(A3)
        margin = 24.0
        self.s = min((self.pw - 2 * margin) / PAGE_W, (self.ph - 2 * margin) / PAGE_H)
        self.ox = (self.pw - PAGE_W * self.s) / 2
        self.oy = (self.ph - PAGE_H * self.s) / 2

    def p(self, x: float, y: float) -> tuple[float, float]:
        return self.ox + x * self.s, self.oy + (PAGE_H - y) * self.s

    def r(self, b: B) -> tuple[float, float, float, float]:
        x, y = self.p(b.x, b.y + b.h)
        return x, y, b.w * self.s, b.h * self.s

    def l(self, v: float) -> float:
        return v * self.s


def fonts() -> None:
    if FONT not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT, str(FONT_PATH)))
    if FONT_B not in pdfmetrics.getRegisteredFontNames():
        pdfmetrics.registerFont(TTFont(FONT_B, str(FONT_B_PATH)))


def txt(
    c: canvas.Canvas,
    tr: T,
    text: str,
    x: float,
    y: float,
    w: float,
    h: float,
    size: float = 8,
    color: colors.Color = BLUE,
    align: int = TA_CENTER,
    bold: bool = False,
) -> None:
    if not text:
        return
    px, py = tr.p(x, y + h)
    pw, ph = tr.l(w), tr.l(h)
    size = max(3.8, size * tr.s)
    esc = "<br/>".join(
        line.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")
        for line in text.splitlines()
    )
    pad = max(1.2, min(pw, ph) * 0.06)
    while size >= 3.8:
        st = ParagraphStyle(
            "s",
            fontName=FONT_B if bold else FONT,
            fontSize=size,
            leading=size * 1.08,
            alignment=align,
            textColor=color,
            splitLongWords=True,
            wordWrap="CJK",
        )
        p = Paragraph(esc, st)
        _, nh = p.wrap(max(2, pw - 2 * pad), max(2, ph - 2 * pad))
        if nh <= ph - 2 * pad or size <= 4.0:
            p.drawOn(c, px + pad, py + pad + max(0, (ph - 2 * pad - nh) / 2))
            return
        size -= 0.25


def rect(c: canvas.Canvas, tr: T, b: B, fill: colors.Color = colors.white, stroke: colors.Color = INK, dash: bool = False) -> None:
    x, y, w, h = tr.r(b)
    c.saveState()
    c.setFillColor(fill)
    c.setStrokeColor(stroke)
    c.setLineWidth(max(0.35, 0.9 * tr.s))
    if dash:
        c.setDash(5, 4)
    c.rect(x, y, w, h, stroke=1, fill=1)
    c.restoreState()


def block(c: canvas.Canvas, tr: T, name: str, x: float, y: float, w: float, h: float, body: str = "", fill: colors.Color = colors.white) -> B:
    b = B(name, x, y, w, h)
    rect(c, tr, b, fill, INK)
    txt(c, tr, name, x + 2, y + 2, w - 4, 15, 6.5, MAGENTA, bold=True)
    txt(c, tr, body, x + 6, y + 18, w - 12, h - 24, 7.2, BLUE)
    return b


def group(c: canvas.Canvas, tr: T, name: str, x: float, y: float, w: float, h: float) -> B:
    b = B(name, x, y, w, h)
    rect(c, tr, b, colors.Color(1, 1, 1, alpha=0), TEAL, True)
    txt(c, tr, name, x, y - 14, w, 14, 7.0, TEAL)
    return b


def port(c: canvas.Canvas, tr: T, name: str, x: float, y: float, side: str = "in", w: float = 98) -> B:
    b = B(name, x, y, w, 18)
    px, py = tr.p(x, y + 18)
    pw, ph = tr.l(w), tr.l(18)
    c.saveState()
    c.setStrokeColor(TEAL)
    c.setLineWidth(max(0.35, tr.s * 0.8))
    c.rect(px, py, pw, ph, stroke=1, fill=0)
    if side == "in":
        c.line(px + pw * 0.62, py + ph / 2, px + pw * 0.9, py + ph / 2)
    else:
        c.line(px + pw * 0.1, py + ph / 2, px + pw * 0.38, py + ph / 2)
    c.restoreState()
    txt(c, tr, name, x + 2, y + 1, w - 4, 16, 5.7, TEAL, TA_LEFT)
    return b


def wire(c: canvas.Canvas, tr: T, pts: list[tuple[float, float]], label: str = "", arrow: bool = False, color: colors.Color = WIRE, width: float = 1.15, dash: bool = False) -> None:
    if len(pts) < 2:
        return
    c.saveState()
    c.setStrokeColor(color)
    c.setFillColor(color)
    c.setLineWidth(max(0.45, width * tr.s))
    if dash:
        c.setDash(5, 3)
    for a, b in zip(pts, pts[1:]):
        ax, ay = tr.p(*a)
        bx, by = tr.p(*b)
        c.line(ax, ay, bx, by)
    if arrow:
        sx, sy = tr.p(*pts[-2])
        ex, ey = tr.p(*pts[-1])
        ang = math.atan2(ey - sy, ex - sx)
        length = 7
        spread = 4
        path = c.beginPath()
        path.moveTo(ex, ey)
        path.lineTo(ex - length * math.cos(ang) + spread * math.sin(ang), ey - length * math.sin(ang) - spread * math.cos(ang))
        path.lineTo(ex - length * math.cos(ang) - spread * math.sin(ang), ey - length * math.sin(ang) + spread * math.cos(ang))
        path.close()
        c.drawPath(path, stroke=0, fill=1)
    c.restoreState()
    if label:
        lx = sum(p[0] for p in pts) / len(pts)
        ly = sum(p[1] for p in pts) / len(pts)
        txt(c, tr, label, lx - 42, ly - 10, 84, 16, 5.3, WIRE)


def conn(c: canvas.Canvas, tr: T, a: B, b: B, label: str = "", via: float | None = None, color: colors.Color = WIRE, width: float = 1.1) -> None:
    sx, sy = a.r
    ex, ey = b.l
    if ex < sx:
        sx, sy = a.l
        ex, ey = b.r
    mx = via if via is not None else (sx + ex) / 2
    wire(c, tr, [(sx, sy), (mx, sy), (mx, ey), (ex, ey)], label, True, color, width)


def gate(c: canvas.Canvas, tr: T, kind: str, x: float, y: float, scale: float = 1.0) -> B:
    w, h = 48 * scale, 32 * scale
    b = B(kind, x, y, w, h)
    px, py = tr.p(x, y + h)
    pw, ph = tr.l(w), tr.l(h)
    c.saveState()
    c.setStrokeColor(INK)
    c.setFillColor(colors.white)
    c.setLineWidth(max(0.35, 0.85 * tr.s))
    if kind.startswith("NOT"):
        path = c.beginPath()
        path.moveTo(px, py)
        path.lineTo(px, py + ph)
        path.lineTo(px + pw * 0.72, py + ph / 2)
        path.close()
        c.drawPath(path, stroke=1, fill=1)
        c.circle(px + pw * 0.82, py + ph / 2, max(1.5, ph * 0.08), stroke=1, fill=0)
    elif kind.startswith("AND"):
        path = c.beginPath()
        path.moveTo(px, py)
        path.lineTo(px + pw * 0.45, py)
        path.curveTo(px + pw * 1.05, py, px + pw * 1.05, py + ph, px + pw * 0.45, py + ph)
        path.lineTo(px, py + ph)
        path.close()
        c.drawPath(path, stroke=1, fill=1)
    else:
        path = c.beginPath()
        path.moveTo(px, py)
        path.curveTo(px + pw * 0.35, py + ph * 0.10, px + pw * 0.35, py + ph * 0.90, px, py + ph)
        path.curveTo(px + pw * 0.55, py + ph * 0.82, px + pw * 0.8, py + ph * 0.65, px + pw, py + ph / 2)
        path.curveTo(px + pw * 0.8, py + ph * 0.35, px + pw * 0.55, py + ph * 0.18, px, py)
        c.drawPath(path, stroke=1, fill=1)
    c.restoreState()
    txt(c, tr, kind, x + w * 0.05, y + h + 1, w, 12, 5.2, TEAL)
    return b


def mux(c: canvas.Canvas, tr: T, name: str, x: float, y: float, w: float = 64, h: float = 82) -> B:
    b = B(name, x, y, w, h)
    px1, py1 = tr.p(x, y + h)
    px2, py2 = tr.p(x + w, y + h / 2)
    px3, py3 = tr.p(x, y)
    c.saveState()
    c.setFillColor(colors.white)
    c.setStrokeColor(INK)
    c.setLineWidth(max(0.35, 0.85 * tr.s))
    path = c.beginPath()
    path.moveTo(px1, py1)
    path.lineTo(px2, py2)
    path.lineTo(px3, py3)
    path.close()
    c.drawPath(path, stroke=1, fill=1)
    c.restoreState()
    txt(c, tr, name, x + 2, y + h + 2, w + 18, 14, 5.4, MAGENTA)
    txt(c, tr, "mux", x + 8, y + 24, w - 10, 30, 6.0, BLUE)
    return b


def dff(c: canvas.Canvas, tr: T, name: str, x: float, y: float, w: float = 108, h: float = 64, bits: str = "[15..0]") -> B:
    return block(c, tr, name, x, y, w, h, f"DFF\ndata{bits}\nclock  enable\nq{bits}")


def compare(c: canvas.Canvas, tr: T, name: str, x: float, y: float, text: str = "a=b") -> B:
    return block(c, tr, name, x, y, 125, 62, f"compare\ndataa\n{text}\ndatab")


def counter(c: canvas.Canvas, tr: T, name: str, x: float, y: float, bits: str = "[2..0]") -> B:
    return block(c, tr, name, x, y, 140, 78, f"up/down counter\nclock\nq{bits}")


def frame(c: canvas.Canvas, tr: T, app: str, title: str) -> None:
    x, y, w, h = tr.r(B("", 20, 20, PAGE_W - 40, PAGE_H - 40))
    c.saveState()
    c.setStrokeColor(INK)
    c.setLineWidth(1.4)
    c.rect(x, y, w, h, stroke=1, fill=0)
    c.restoreState()
    txt(c, tr, f"{app}\n{title}", 1010, 975, 390, 65, 10, INK, TA_LEFT, True)
    txt(c, tr, "Разраб. Власов Р.Е.\nПров. Третьяков", 1410, 980, 140, 45, 7, INK, TA_LEFT)


def bus_backbone(c: canvas.Canvas, tr: T, y: float, x1: float = 110, x2: float = 1480, n: int = 4) -> list[float]:
    ys = [y + i * 18 for i in range(n)]
    for yy in ys:
        wire(c, tr, [(x1, yy), (x2, yy)], width=1.1)
    return ys


def page_command(c: canvas.Canvas, tr: T) -> None:
    p0 = port(c, tr, "rom_data_i[15..0]", 65, 190)
    p1 = port(c, tr, "clk_i", 65, 235)
    pc = dff(c, tr, "pc_reg", 240, 150, 115, 64)
    rom = block(c, tr, "rom_sync", 450, 140, 150, 82, "addr[15..0]\nen\nq[15..0]")
    ir0 = dff(c, tr, "ir0_reg", 730, 110)
    ir1 = dff(c, tr, "ir1_reg", 730, 225)
    dec = block(c, tr, "opcode_decode", 1010, 110, 190, 210, "00 HLT\n01 M->R\n02 R->M\n03 OR\n04 NOR\n05 SRA\n06 INCS\n07 PUSH\n08 POP\n09 JMP\n0A JZ")
    tbl = block(c, tr, "command_format", 1250, 145, 220, 135, "IR0[15..8] opcode\nIR0[7..4] reg\nIR0[3..0] reserve\nIR1[15..0] addr/X")
    for a, b, lab in [(p0, ir0, "word0"), (p0, ir1, "word1"), (pc, rom, "addr"), (rom, ir0, "q"), (ir0, dec, "opcode"), (ir1, tbl, "addr"), (dec, tbl, "fields")]:
        conn(c, tr, a, b, lab)
    # Dense one-hot output lines.
    for i in range(11):
        y = 355 + i * 34
        out = port(c, tr, f"op_{i:02d}", 1420, y, "out")
        wire(c, tr, [(1200, 155 + i * 16), (1320, 155 + i * 16), (1320, out.c[1]), out.l], f"eq{i}", True)


def page_memory(c: canvas.Canvas, tr: T) -> None:
    cpu = block(c, tr, "cpu_core", 90, 260, 165, 160, "rom_addr\ncache_req\ncache_we\ncache_addr\ncache_wdata")
    rom = block(c, tr, "rom_sync", 390, 120, 160, 88, "256x16 ROM\naddr[15..0]\nq[15..0]")
    cache = block(c, tr, "cache_4way_age", 390, 340, 210, 160, "4 ways\n16 sets\nTAG+V+AGE\nhit/miss")
    arb = block(c, tr, "bus_arbiter", 760, 590, 155, 82, "req_cpu\nreq_dma\ngnt_cpu\ngnt_dma")
    ram = block(c, tr, "ram_sync", 1010, 350, 185, 130, "256x16 RAM\nen/we\naddr[15..0]\ndin/q[15..0]")
    dma = block(c, tr, "dma_3word", 1040, 620, 175, 105, "base=000A\nindex 0..2\nram_we")
    for pair in [(cpu, rom, "instr"), (cpu, cache, "data"), (cache, arb, "req_cpu"), (dma, arb, "req_dma"), (arb, cache, "gnt_cpu"), (arb, dma, "gnt_dma"), (cache, ram, "ram bus"), (dma, ram, "dma write")]:
        conn(c, tr, *pair)
    for y in bus_backbone(c, tr, 815, 170, 1320, 3):
        label(c, tr, f"addr/data/control bus", 740, y)


def label(c: canvas.Canvas, tr: T, s: str, x: float, y: float) -> None:
    txt(c, tr, s, x - 55, y - 8, 110, 15, 5.4, WIRE)


def page_control(c: canvas.Canvas, tr: T) -> None:
    ir0 = dff(c, tr, "ir0_reg", 100, 160, 115, 64)
    flags = dff(c, tr, "flags_reg", 100, 330, 115, 64, "[3..0]")
    dec = block(c, tr, "lpm_decode_opcode", 320, 130, 160, 210, "data[7..0]\neq0 HLT\n...\neq10 JZ")
    ctr = counter(c, tr, "phase_counter", 320, 430, "[4..0]")
    state = block(c, tr, "control_fsm", 610, 165, 210, 250, "FETCH0\nFETCH1\nDECODE\nCACHE_READ\nCACHE_WRITE\nALU_SETUP\nSTACK_PUSH\nSTACK_POP\nBRANCH\nHALT")
    matrix = block(c, tr, "control_matrix", 960, 150, 230, 255, "rf_we\nalu_op[2..0]\ncache_req/we\nstack_push/pop\nflag_we\nbp_query/update\nhalt")
    outs = [port(c, tr, n, 1360, 120 + i * 42, "out", 118) for i, n in enumerate(["rf_we", "alu_op[2..0]", "cache_req", "cache_we", "stack_push", "stack_pop", "pc_load", "halt_o", "bp_update"])]
    for pair in [(ir0, dec, "opcode"), (flags, state, "Z/S/C/O"), (dec, state, "eq"), (ctr, state, "phase"), (state, matrix, "state")]:
        conn(c, tr, *pair)
    for i, o in enumerate(outs):
        wire(c, tr, [matrix.r, (1250, matrix.c[1]), (1250, o.c[1]), o.l], f"ctl{i}", True)
    for i in range(7):
        g = gate(c, tr, "AND2", 865, 475 + i * 45, 0.75)
        wire(c, tr, [(480, 180 + i * 22), (850, 180 + i * 22), (850, g.c[1]), g.l], width=0.9)
        wire(c, tr, [g.r, (960, g.c[1])], width=0.9, arrow=True)


def page_special(c: canvas.Canvas, tr: T) -> None:
    pc = dff(c, tr, "pc_reg", 150, 160, 130, 70)
    add = block(c, tr, "lpm_add_sub", 410, 145, 135, 70, "A=PC\nB=2\nresult")
    m = mux(c, tr, "pc_mux", 670, 132)
    ir0 = dff(c, tr, "ir0_reg", 150, 345, 130, 70)
    ir1 = dff(c, tr, "ir1_reg", 410, 345, 130, 70)
    fr = dff(c, tr, "flags_reg", 675, 335, 130, 70, "[3..0]")
    sp = counter(c, tr, "sp_counter", 920, 335)
    bp = block(c, tr, "debug_regs", 1150, 315, 210, 100, "state\nR1..R7\nflags\nSP")
    for pair in [(pc, add, "PC"), (add, m, "PC+2"), (ir1, m, "IR1"), (m, pc, "next_pc"), (fr, bp, "flags"), (sp, bp, "SP")]:
        conn(c, tr, *pair)
    for p in [port(c, tr, "clk_i", 70, 565), port(c, tr, "rst_i", 70, 600), port(c, tr, "pc_we", 70, 635)]:
        wire(c, tr, [p.r, (1340, p.c[1])], width=0.9)


def page_registers(c: canvas.Canvas, tr: T) -> None:
    ins = [port(c, tr, n, 55, 120 + i * 48) for i, n in enumerate(["DATA_IN[15..0]", "WR_ADDR[3..0]", "RD_A[3..0]", "RD_B[3..0]", "WE", "CLK"])]
    dec = block(c, tr, "lpm_decode12", 260, 155, 145, 190, "data[3..0]\neq0..eq11\nenable")
    regs = []
    group(c, tr, "reg_file12x16", 500, 95, 250, 620)
    for i in range(12):
        regs.append(dff(c, tr, f"reg_r{i}", 535, 120 + i * 46, 130, 35, "[15..0]"))
    mx_a = mux(c, tr, "mux_a", 850, 220, 70, 150)
    mx_b = mux(c, tr, "mux_b", 850, 455, 70, 150)
    outs = [port(c, tr, "DOUT_A[15..0]", 1270, 285, "out", 125), port(c, tr, "DOUT_B[15..0]", 1270, 520, "out", 125)]
    conn(c, tr, ins[1], dec, "wr_addr")
    for i, r in enumerate(regs):
        wire(c, tr, [(405, 170 + i * 13), (475, 170 + i * 13), (475, r.c[1]), r.l], f"eq{i}", True, width=0.75)
        wire(c, tr, [ins[0].r, (455, ins[0].c[1]), (455, r.c[1]), r.l], width=0.75)
        wire(c, tr, [r.r, (810, r.c[1]), (810, mx_a.c[1]), mx_a.l], width=0.7)
        wire(c, tr, [r.r, (790, r.c[1]), (790, mx_b.c[1]), mx_b.l], width=0.7)
    conn(c, tr, mx_a, outs[0], "rf_a")
    conn(c, tr, mx_b, outs[1], "rf_b")


def page_common(c: canvas.Canvas, tr: T) -> None:
    dec = block(c, tr, "common_op_decode", 130, 235, 170, 250, "HLT\nJMP\nJZ\nM->R\nR->M")
    blocks = [
        block(c, tr, "hlt_logic", 450, 105, 135, 65, "halt_o=1\nstate=HALT"),
        block(c, tr, "pc_load_logic", 450, 225, 150, 80, "JMP/JZ\nPC<=IR1"),
        block(c, tr, "cache_read", 450, 370, 150, 80, "M->R\nreq we=0"),
        block(c, tr, "cache_write", 450, 515, 150, 80, "R->M\nreq we=1"),
    ]
    pc = dff(c, tr, "pc_reg", 780, 220, 120, 65)
    cache = block(c, tr, "cache_port", 780, 420, 160, 100, "addr=IR1\nwdata=rf_a\nrdata")
    rf = block(c, tr, "reg_file", 1130, 405, 160, 100, "rf_a\nrf_din\nrf_we")
    for b in blocks:
        conn(c, tr, dec, b, b.name.split("_")[0])
    conn(c, tr, blocks[1], pc, "pc_we")
    conn(c, tr, blocks[2], cache, "read")
    conn(c, tr, blocks[3], cache, "write")
    conn(c, tr, cache, rf, "rdata")


def page_jmp(c: canvas.Canvas, tr: T) -> None:
    ir1 = dff(c, tr, "ir1_reg", 180, 250, 130, 70)
    pc2 = block(c, tr, "pc_plus_2", 180, 435, 120, 65, "PC + 2")
    jmp = gate(c, tr, "AND2", 470, 275)
    m = mux(c, tr, "next_pc_mux", 690, 275, 78, 105)
    pc = dff(c, tr, "pc_reg", 1010, 285, 130, 70)
    op = port(c, tr, "OP_JMP", 120, 565)
    conn(c, tr, ir1, m, "target")
    conn(c, tr, pc2, m, "seq")
    wire(c, tr, [op.r, (450, op.c[1]), (450, jmp.c[1]), jmp.l], "jmp", True)
    wire(c, tr, [jmp.r, (655, jmp.c[1]), (655, m.c[1]), m.l], "sel", True)
    conn(c, tr, m, pc, "pc_load")


def page_mr(c: canvas.Canvas, tr: T) -> None:
    ir1 = dff(c, tr, "ir1_addr", 130, 210, 120, 65)
    req = gate(c, tr, "AND2", 340, 230)
    cache = block(c, tr, "cache_4way_age", 560, 190, 190, 120, "cpu_req=1\ncpu_we=0\nready")
    wait = block(c, tr, "wait_ready", 560, 425, 155, 75, "cache_ready")
    rf = block(c, tr, "reg_file_wr", 980, 255, 170, 95, "rf_din=cache_rdata\nrf_we=1")
    conn(c, tr, ir1, cache, "addr")
    wire(c, tr, [req.r, (535, req.c[1]), cache.l], "req", True)
    conn(c, tr, cache, wait, "ready")
    conn(c, tr, cache, rf, "rdata")


def page_rm(c: canvas.Canvas, tr: T) -> None:
    rf = block(c, tr, "reg_file_rd", 130, 220, 160, 80, "rf_a=Rn")
    ir1 = dff(c, tr, "ir1_addr", 130, 420, 120, 65)
    cache = block(c, tr, "cache_write", 530, 285, 190, 125, "cpu_req=1\ncpu_we=1\nwdata=rf_a")
    arb = block(c, tr, "bus_grant", 870, 510, 135, 70, "grant_cpu")
    ram = block(c, tr, "ram_sync", 1060, 300, 175, 90, "we=1\naddr/data")
    conn(c, tr, rf, cache, "wdata")
    conn(c, tr, ir1, cache, "addr")
    conn(c, tr, cache, arb, "REQ_CPU")
    conn(c, tr, arb, cache, "GNT_CPU")
    conn(c, tr, cache, ram, "write-through")


def page_alu(c: canvas.Canvas, tr: T) -> None:
    a = dff(c, tr, "a_reg", 100, 145, 120, 65)
    b = dff(c, tr, "b_reg", 100, 320, 120, 65)
    fs = dff(c, tr, "flag_s", 100, 520, 95, 55, "")
    ops = [
        block(c, tr, "op_or", 390, 105, 125, 55, "A OR B"),
        block(c, tr, "op_nor", 390, 215, 125, 55, "NOT(A OR B)"),
        block(c, tr, "op_sra", 390, 325, 125, 55, "A15&A15..1"),
        block(c, tr, "op_incs", 390, 435, 125, 55, "A + S"),
    ]
    m = mux(c, tr, "result_mux", 700, 255, 85, 170)
    flags = block(c, tr, "flag_logic", 950, 300, 150, 95, "Z,S,C,O")
    out = port(c, tr, "Y[15..0]", 1240, 330, "out", 115)
    for o in ops:
        conn(c, tr, a, o, "A", width=0.9)
        if "sra" not in o.name and "incs" not in o.name:
            conn(c, tr, b, o, "B", width=0.9)
        if "incs" in o.name:
            conn(c, tr, fs, o, "S", width=0.9)
        conn(c, tr, o, m, "result", width=0.9)
    conn(c, tr, m, flags, "Y")
    wire(c, tr, [m.r, (1160, m.c[1]), out.l], "Y", True)


def page_or(c: canvas.Canvas, tr: T) -> None:
    a = port(c, tr, "A[15..0]", 80, 190)
    b = port(c, tr, "B[15..0]", 80, 430)
    ors = [gate(c, tr, "OR2", 330 + (i % 4) * 130, 150 + (i // 4) * 105, 0.85) for i in range(8)]
    y = block(c, tr, "bus_join", 980, 275, 150, 90, "Y[15..0]\nbitwise OR")
    fl = block(c, tr, "flags", 1210, 290, 135, 75, "Z/S\nC=0 O=0")
    for i, g in enumerate(ors):
        wire(c, tr, [a.r, (280, a.c[1]), (280, g.c[1] - 8), (g.x, g.c[1] - 8)], width=0.65)
        wire(c, tr, [b.r, (295, b.c[1]), (295, g.c[1] + 8), (g.x, g.c[1] + 8)], width=0.65)
        wire(c, tr, [g.r, (930, g.c[1]), (930, y.c[1]), y.l], width=0.65, arrow=True)
    conn(c, tr, y, fl, "Y")


def page_nor(c: canvas.Canvas, tr: T) -> None:
    a = port(c, tr, "A[15..0]", 90, 210)
    b = port(c, tr, "B[15..0]", 90, 430)
    or_bus = block(c, tr, "OR bus", 360, 300, 160, 85, "T=A OR B")
    invs = [gate(c, tr, "NOT", 650 + (i % 4) * 100, 235 + (i // 4) * 90, 0.75) for i in range(8)]
    y = block(c, tr, "bus_join", 1100, 305, 150, 80, "Y=NOT T")
    conn(c, tr, a, or_bus, "A")
    conn(c, tr, b, or_bus, "B")
    for inv in invs:
        conn(c, tr, or_bus, inv, "T_i", width=0.75)
        conn(c, tr, inv, y, "Y_i", width=0.75)


def page_sra(c: canvas.Canvas, tr: T) -> None:
    a = port(c, tr, "A[15..0]", 90, 280)
    split = block(c, tr, "wire_split", 370, 240, 190, 100, "A[15]\nA[15..1]\nA[0]")
    join = block(c, tr, "shift_join", 760, 235, 190, 105, "Y[15]=A[15]\nY[14..0]=A[15..1]")
    cflag = dff(c, tr, "C_flag", 770, 450, 110, 58, "")
    out = port(c, tr, "Y[15..0]", 1160, 280, "out", 115)
    conn(c, tr, a, split, "A")
    conn(c, tr, split, join, "sign/data")
    conn(c, tr, split, cflag, "A0")
    wire(c, tr, [join.r, out.l], "Y", True)


def page_incs(c: canvas.Canvas, tr: T) -> None:
    a = port(c, tr, "A[15..0]", 90, 260)
    s = port(c, tr, "FR.S", 90, 510)
    ext = block(c, tr, "s_extend", 350, 490, 145, 70, "000..S")
    add = block(c, tr, "lpm_add_sub", 570, 260, 190, 95, "A + S\nsum17")
    fl = block(c, tr, "carry_overflow", 910, 280, 190, 90, "C=sum17[16]\nO=overflow")
    out = port(c, tr, "Y[15..0]", 1210, 305, "out", 115)
    conn(c, tr, a, add, "A")
    conn(c, tr, s, ext, "S")
    conn(c, tr, ext, add, "B")
    conn(c, tr, add, fl, "sum")
    wire(c, tr, [add.r, (1080, add.c[1]), out.l], "Y", True)


def page_flags(c: canvas.Canvas, tr: T) -> None:
    y = port(c, tr, "Y[15..0]", 90, 220)
    raw = port(c, tr, "C_raw/O_raw", 90, 430)
    z = block(c, tr, "zero_detect", 360, 165, 150, 75, "Y == 0000")
    s = block(c, tr, "sign_bit", 360, 295, 150, 55, "Y[15]")
    co = block(c, tr, "carry_ovf_sel", 360, 420, 160, 75, "C/O by op")
    regs = [dff(c, tr, f"fr_{n}", 760, 150 + i * 95, 95, 55, "") for i, n in enumerate(["z", "s", "c", "o"])]
    out = port(c, tr, "FR[3..0]", 1120, 300, "out", 115)
    conn(c, tr, y, z, "Y")
    conn(c, tr, y, s, "Y15")
    conn(c, tr, raw, co, "raw")
    for src, reg in zip([z, s, co, co], regs):
        conn(c, tr, src, reg, "flag", width=0.85)
        conn(c, tr, reg, out, "q", width=0.85)


def page_stack(c: canvas.Canvas, tr: T) -> None:
    din = port(c, tr, "DATA_IN[15..0]", 70, 175)
    push = port(c, tr, "PUSH", 70, 235)
    pop = port(c, tr, "POP", 70, 275)
    sp = counter(c, tr, "sp_counter", 280, 210)
    dec = block(c, tr, "lpm_decode7", 520, 185, 130, 135, "sel[2..0]\neq0..eq6")
    group(c, tr, "stack_mem 7x16", 760, 100, 210, 430)
    cells = [dff(c, tr, f"stack_r{i}", 795, 125 + i * 55, 115, 42, "[15..0]") for i in range(7)]
    m = mux(c, tr, "read_mux", 1080, 250, 75, 150)
    out = port(c, tr, "DATA_OUT[15..0]", 1300, 315, "out", 130)
    for p in [push, pop]:
        conn(c, tr, p, sp, p.name)
    conn(c, tr, sp, dec, "SP")
    for i, cell in enumerate(cells):
        conn(c, tr, dec, cell, f"eq{i}", width=0.7)
        wire(c, tr, [din.r, (725, din.c[1]), (725, cell.c[1]), cell.l], width=0.7)
        conn(c, tr, cell, m, "q", width=0.7)
    wire(c, tr, [m.r, out.l], "dout", True)


def page_stack_exec(c: canvas.Canvas, tr: T) -> None:
    cu = block(c, tr, "control", 110, 250, 160, 140, "S_STACK_PUSH\nS_STACK_POP\nS_RF_WRITE_POP")
    rf = block(c, tr, "reg_file", 430, 190, 160, 105, "rf_a -> din\nrf_din <- dout")
    st = block(c, tr, "stack7x16", 760, 235, 180, 135, "push_i/pop_i\nsp_o\nempty/full")
    wr = block(c, tr, "writeback", 1110, 245, 165, 95, "rf_we\nwr_addr=Rn")
    conn(c, tr, cu, st, "push/pop")
    conn(c, tr, rf, st, "din")
    conn(c, tr, st, wr, "dout")
    conn(c, tr, wr, rf, "rf_din")
    for yy, lab in [(520, "PUSH: mem(SP-1)<=Rn, SP--"), (565, "POP: dout<=mem(SP), SP++")]:
        txt(c, tr, lab, 430, yy, 600, 25, 7, MAGENTA)


def page_cache(c: canvas.Canvas, tr: T) -> None:
    cpu = block(c, tr, "cpu_if", 80, 260, 155, 125, "req/we\naddr/wdata\nrdata/ready")
    addr = block(c, tr, "addr_split", 330, 120, 155, 80, "TAG=15..4\nSET=3..0")
    group(c, tr, "cache ways", 350, 250, 360, 310)
    ways = [block(c, tr, f"way{i}", 385 + (i % 2) * 155, 285 + (i // 2) * 120, 125, 80, "DATA\nTAG,V,AGE") for i in range(4)]
    cmps = [compare(c, tr, f"cmp{i}", 820, 250 + i * 75, "tag=TAG\nAND V") for i in range(4)]
    hit = gate(c, tr, "OR4", 1040, 350)
    fsm = block(c, tr, "cache_fsm", 1190, 210, 190, 130, "IDLE\nWAIT_READ_GRANT\nWAIT_READ_DATA\nWAIT_WRITE_GRANT")
    ram = block(c, tr, "ram_if", 1190, 500, 190, 95, "ram_req/we\nram_addr/data\ngrant")
    conn(c, tr, cpu, addr, "addr")
    for w in ways:
        conn(c, tr, addr, w, "set/tag", width=0.75)
    for w, cmpb in zip(ways, cmps):
        conn(c, tr, w, cmpb, "tag/v", width=0.75)
        conn(c, tr, cmpb, hit, "hit", width=0.75)
    conn(c, tr, hit, cpu, "ready")
    conn(c, tr, hit, fsm, "miss/write")
    conn(c, tr, fsm, ram, "request")
    conn(c, tr, ram, ways[2], "fill")


def page_cache_data(c: canvas.Canvas, tr: T) -> None:
    req = block(c, tr, "req_reg", 70, 330, 130, 85, "addr\nwdata\nwe")
    way_boxes = []
    for i in range(4):
        y = 115 + i * 145
        group(c, tr, f"WAY {i}", 320, y, 300, 115)
        data = block(c, tr, f"data_way{i}", 345, y + 28, 105, 55, "16x16")
        tag = block(c, tr, f"tag_way{i}", 480, y + 20, 105, 70, "TAG\nV+AGE")
        way_boxes.append((data, tag))
    cmps = [compare(c, tr, f"cmp{i}", 760, 135 + i * 145, "tag=TAG") for i in range(4)]
    m = mux(c, tr, "mux4", 1060, 335, 80, 150)
    out = port(c, tr, "cpu_rdata[15..0]", 1300, 395, "out", 140)
    for i, (data, tag) in enumerate(way_boxes):
        conn(c, tr, req, data, "set", width=0.65)
        conn(c, tr, tag, cmps[i], "tag/v", width=0.65)
        conn(c, tr, data, m, f"data{i}", width=0.65)
    wire(c, tr, [m.r, out.l], "selected", True)


def page_cache_flags(c: canvas.Canvas, tr: T) -> None:
    valid = block(c, tr, "valid_mem", 120, 165, 170, 80, "4 x 16 bits")
    tag = block(c, tr, "tag_mem", 120, 330, 170, 80, "4 x 16 x 12")
    age = block(c, tr, "age_mem", 120, 500, 170, 90, "4 x 16 x 2\nsaturating")
    hit_update = block(c, tr, "hit_update", 500, 220, 190, 100, "hit way age=0\nothers inc_age")
    victim = block(c, tr, "victim_select", 500, 445, 200, 115, "invalid first\nelse max AGE")
    write = block(c, tr, "metadata_write", 900, 330, 210, 110, "valid<=1\ntag<=req_tag\nage<=0")
    for src in [valid, tag, age]:
        conn(c, tr, src, hit_update, "status", width=0.8)
        conn(c, tr, src, victim, "status", width=0.8)
    conn(c, tr, hit_update, write, "hit")
    conn(c, tr, victim, write, "miss")


def page_system(c: canvas.Canvas, tr: T) -> None:
    cpu = block(c, tr, "cpu_core", 100, 250, 185, 140, "CU+RON+ALU+STACK\nPC/IR/FR")
    rom = block(c, tr, "rom_sync", 120, 600, 145, 75, "ПЗУ команд")
    cache = block(c, tr, "cache_4way", 445, 260, 180, 115, "data cache")
    ram = block(c, tr, "ram_sync", 850, 260, 170, 95, "ОЗУ данных")
    arb = block(c, tr, "arbiter", 670, 575, 140, 75, "CPU/DMA grant")
    dma = block(c, tr, "dma_3word", 890, 570, 160, 80, "3 words @10")
    bp = block(c, tr, "branch_predictor", 445, 90, 190, 85, "A4 PHT+BTB+GHR")
    dbg = block(c, tr, "debug_out", 1130, 115, 170, 90, "state/R1..R7\nflags/SP")
    for pair in [(cpu, rom, "rom_addr/data"), (cpu, cache, "data_port"), (cache, ram, "RAM bus"), (cache, arb, "REQ_CPU"), (dma, arb, "REQ_DMA"), (arb, cache, "GNT_CPU"), (arb, dma, "GNT_DMA"), (dma, ram, "write"), (cpu, bp, "query/update"), (cpu, dbg, "debug")]:
        conn(c, tr, *pair)
    bus_backbone(c, tr, 760, 190, 1250, 5)


def page_bp(c: canvas.Canvas, tr: T) -> None:
    pc = port(c, tr, "pc_query[15..0]", 90, 180)
    ghr = dff(c, tr, "ghr_reg", 130, 420, 110, 58, "[1..0]")
    idx = block(c, tr, "index_logic", 410, 270, 175, 90, "PC[1..0] || GHR[1..0]")
    pht = block(c, tr, "pht", 750, 170, 160, 90, "16 x 2-bit\nsat counters")
    btb = block(c, tr, "btb", 750, 390, 160, 90, "16 targets\nvalid")
    pred = block(c, tr, "predict_logic", 1050, 270, 190, 105, "taken=PHT[1]\nAND valid\ntarget=BTB")
    upd = block(c, tr, "update_logic", 420, 610, 220, 110, "sat_inc/sat_dec\nGHR<=GHR(0)&taken")
    conn(c, tr, pc, idx, "PC(2)")
    conn(c, tr, ghr, idx, "GHR")
    conn(c, tr, idx, pht, "index")
    conn(c, tr, idx, btb, "index")
    conn(c, tr, pht, pred, "state")
    conn(c, tr, btb, pred, "target")
    conn(c, tr, pred, upd, "actual")
    conn(c, tr, upd, ghr, "next")


PAGES: list[tuple[str, str, str, Callable[[canvas.Canvas, T], None]]] = [
    ("ПРИЛОЖЕНИЕ А", "Система команд микро-ЭВМ", "01_Приложение_А_Система_команд.pdf", page_command),
    ("ПРИЛОЖЕНИЕ Б", "Схема совмещенного блока ЗУ", "02_Приложение_Б_ЗУ.pdf", page_memory),
    ("ПРИЛОЖЕНИЕ В", "Схема блока устройства управления", "03_Приложение_В_УУ.pdf", page_control),
    ("ПРИЛОЖЕНИЕ Г", "Схема блока специальных регистров", "04_Приложение_Г_Спец_регистры.pdf", page_special),
    ("ПРИЛОЖЕНИЕ Д", "Схема блока регистров общего назначения", "05_Приложение_Д_РОН.pdf", page_registers),
    ("ПРИЛОЖЕНИЕ Е", "Схема блока общих операций", "06_Приложение_Е_Общие_операции.pdf", page_common),
    ("ПРИЛОЖЕНИЕ Ж", "Схема блока операции JMP", "07_Приложение_Ж_JMP.pdf", page_jmp),
    ("ПРИЛОЖЕНИЕ И", "Схема блока операции M->R", "08_Приложение_И_MR.pdf", page_mr),
    ("ПРИЛОЖЕНИЕ К", "Схема блока операции R->M", "09_Приложение_К_RM.pdf", page_rm),
    ("ПРИЛОЖЕНИЕ Л", "Схема блока АЛУ", "10_Приложение_Л_АЛУ.pdf", page_alu),
    ("ПРИЛОЖЕНИЕ М", "Схема блока операции OR", "11_Приложение_М_OR.pdf", page_or),
    ("ПРИЛОЖЕНИЕ Н", "Схема блока операции NOR", "12_Приложение_Н_NOR.pdf", page_nor),
    ("ПРИЛОЖЕНИЕ П", "Схема блока операции SRA", "13_Приложение_П_SRA.pdf", page_sra),
    ("ПРИЛОЖЕНИЕ Р", "Схема блока операции INCS", "14_Приложение_Р_INCS.pdf", page_incs),
    ("ПРИЛОЖЕНИЕ С", "Схема блока регистра флагов", "15_Приложение_С_Флаги.pdf", page_flags),
    ("ПРИЛОЖЕНИЕ Т", "Схема стекового устройства", "16_Приложение_Т_Стек.pdf", page_stack),
    ("ПРИЛОЖЕНИЕ У", "Схема исполнительного блока стека", "17_Приложение_У_Стек_исполнительный.pdf", page_stack_exec),
    ("ПРИЛОЖЕНИЕ Ф", "Схема блока кэш-памяти", "18_Приложение_Ф_Кэш.pdf", page_cache),
    ("ПРИЛОЖЕНИЕ Х", "Схема блока данных кэша", "19_Приложение_Х_Данные_кэша.pdf", page_cache_data),
    ("ПРИЛОЖЕНИЕ Ц", "Схема блока флагов кэша", "20_Приложение_Ц_Флаги_кэша.pdf", page_cache_flags),
    ("ПРИЛОЖЕНИЕ Ш", "Схема блока микро-ЭВМ", "21_Приложение_Ш_МикроЭВМ.pdf", page_system),
    ("ПРИЛОЖЕНИЕ Щ", "Схема блока предсказателя переходов", "22_Приложение_Щ_Предсказатель.pdf", page_bp),
]


def draw_sheet(c: canvas.Canvas, app: str, title: str, fn: Callable[[canvas.Canvas, T], None]) -> None:
    tr = T()
    frame(c, tr, app, title)
    fn(c, tr)


def main() -> None:
    fonts()
    PDF_DIR.mkdir(parents=True, exist_ok=True)
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    combo = canvas.Canvas(str(COMBINED), pagesize=landscape(A3))
    combo.setTitle("RTL-like appendix schematics")
    combo.setAuthor("Власов Р.Е.")
    for app, title, filename, fn in PAGES:
        p = PDF_DIR / filename
        one = canvas.Canvas(str(p), pagesize=landscape(A3))
        one.setTitle(f"{app}: {title}")
        one.setAuthor("Власов Р.Е.")
        draw_sheet(one, app, title, fn)
        one.showPage()
        one.save()
        draw_sheet(combo, app, title, fn)
        combo.showPage()
        print(p)
    combo.save()
    (OUT_DIR / "README.txt").write_text(
        "Комплект схем в стиле RTL/Quartus: мелкие lpm/DFF/MUX/compare/gate блоки,\n"
        "фиолетовые связи, порты и реальные параметры варианта: 16 бит, 12 РОН,\n"
        "стек 7x16, OR/NOR/SRA/INCS, кэш 4-way, КПДП, предсказатель A4.\n",
        encoding="utf-8",
    )
    print(COMBINED)


if __name__ == "__main__":
    main()
