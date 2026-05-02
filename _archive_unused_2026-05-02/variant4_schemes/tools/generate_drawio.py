#!/usr/bin/env python3
"""Generate editable draw.io drafts for SIFO VM coursework variant 4."""

from __future__ import annotations

from html import escape
from pathlib import Path


OUT_DIR = Path(__file__).resolve().parents[1]

PAGE_W = 1600
PAGE_H = 1100

STYLE = {
    "frame": "rounded=0;whiteSpace=wrap;html=1;strokeColor=#222222;fillColor=none;strokeWidth=2;",
    "title": "rounded=0;whiteSpace=wrap;html=1;strokeColor=#222222;fillColor=#ffffff;fontSize=12;align=left;verticalAlign=middle;spacing=6;",
    "rom": "rounded=1;whiteSpace=wrap;html=1;arcSize=12;fillColor=#dae8fc;strokeColor=#6c8ebf;fontSize=16;",
    "logic": "rounded=1;whiteSpace=wrap;html=1;arcSize=12;fillColor=#fff2cc;strokeColor=#d6b656;fontSize=16;",
    "exec": "rounded=1;whiteSpace=wrap;html=1;arcSize=12;fillColor=#d5e8d4;strokeColor=#82b366;fontSize=16;",
    "state": "rounded=1;whiteSpace=wrap;html=1;arcSize=12;fillColor=#e1d5e7;strokeColor=#9673a6;fontSize=16;",
    "mem": "rounded=1;whiteSpace=wrap;html=1;arcSize=12;fillColor=#dae8fc;strokeColor=#6c8ebf;fontSize=16;",
    "note": "rounded=1;whiteSpace=wrap;html=1;arcSize=12;fillColor=#f8cecc;strokeColor=#b85450;fontSize=14;",
    "edge": "endArrow=block;html=1;rounded=1;strokeWidth=2;strokeColor=#43556b;fontSize=13;",
    "bus": "endArrow=block;html=1;rounded=1;strokeWidth=3;strokeColor=#2f4b7c;fontSize=13;",
    "ctrl": "endArrow=block;html=1;rounded=1;strokeWidth=2;dashed=1;strokeColor=#9673a6;fontSize=13;",
}


class Diagram:
    def __init__(self, title: str, sheet: str, filename: str) -> None:
        self.title = title
        self.sheet = sheet
        self.filename = filename
        self.cells: list[str] = []
        self.next_id = 2
        self._base()

    def _new_id(self, prefix: str) -> str:
        value = f"{prefix}{self.next_id}"
        self.next_id += 1
        return value

    def label(self, text: str) -> str:
        return escape(text).replace("\n", "&lt;br&gt;")

    def vertex(self, value: str, x: int, y: int, w: int, h: int, style: str) -> str:
        cell_id = self._new_id("v")
        self.cells.append(
            f'<mxCell id="{cell_id}" value="{self.label(value)}" style="{style}" vertex="1" parent="1">'
            f'<mxGeometry x="{x}" y="{y}" width="{w}" height="{h}" as="geometry"/>'
            f"</mxCell>"
        )
        return cell_id

    def edge(self, source: str, target: str, value: str = "", style: str | None = None) -> str:
        cell_id = self._new_id("e")
        edge_style = style or STYLE["edge"]
        self.cells.append(
            f'<mxCell id="{cell_id}" value="{self.label(value)}" style="{edge_style}" edge="1" parent="1" source="{source}" target="{target}">'
            '<mxGeometry relative="1" as="geometry"/>'
            "</mxCell>"
        )
        return cell_id

    def _base(self) -> None:
        self.cells.append('<mxCell id="0"/>')
        self.cells.append('<mxCell id="1" parent="0"/>')
        self.vertex("", 20, 20, PAGE_W - 40, PAGE_H - 40, STYLE["frame"])
        self.vertex(
            f"Курсовой проект СиФО ЭВМ\nВариант 4\n{self.sheet}\n{self.title}",
            1090,
            970,
            470,
            90,
            STYLE["title"],
        )

    def write(self) -> None:
        body = "\n".join(self.cells)
        xml = f'''<mxfile host="app.diagrams.net" modified="2026-04-27T00:00:00.000Z" agent="Codex" version="24.7.17" type="device">
  <diagram id="{escape(self.filename)}" name="{escape(self.sheet)}">
    <mxGraphModel dx="1600" dy="1100" grid="1" gridSize="10" guides="1" tooltips="1" connect="1" arrows="1" fold="1" page="1" pageScale="1" pageWidth="{PAGE_W}" pageHeight="{PAGE_H}" math="0" shadow="0">
      <root>
{body}
      </root>
    </mxGraphModel>
  </diagram>
</mxfile>
'''
        (OUT_DIR / self.filename).write_text(xml, encoding="utf-8")


def build_a1() -> None:
    d = Diagram("Общая структурная схема микро-ЭВМ", "Лист 1, формат А3", "A1_general_structure.drawio")
    rom = d.vertex("ПЗУ команд\n16 бит адрес / 16 бит слово\nсинхронное чтение", 55, 410, 220, 90, STYLE["rom"])
    ipir = d.vertex("IP + IR\nвыборка и декодирование\nдвухсловной команды", 360, 405, 235, 100, STYLE["logic"])
    cu = d.vertex("Устройство управления\nавтомат T0...T5 + Tw\nуправляющие сигналы", 705, 260, 240, 115, STYLE["logic"])
    rf = d.vertex("РОН\n12 x 16 бит\n2 порта чтения / 1 порт записи", 1010, 220, 250, 90, STYLE["mem"])
    alu = d.vertex("АЛУ\nOR, NOR, SRA, INCS", 1060, 55, 210, 80, STYLE["exec"])
    flags = d.vertex("FR\nZ S C O", 1310, 75, 110, 60, STYLE["state"])
    stack = d.vertex("Стек\n7 x 16 бит\nрост вниз", 1350, 220, 160, 80, STYLE["state"])
    cache = d.vertex("Кэш данных\n4-way, 16 sets\n1-word line\nwrite-through", 1110, 480, 250, 115, STYLE["exec"])
    ram = d.vertex("ОЗУ данных\n16 бит адрес / 16 бит слово\nсинхронное чтение/запись", 1340, 670, 220, 95, STYLE["mem"])
    pred = d.vertex("Предсказатель A4\nPHT 16x2, BTB 16\nиндекс PC(2)||GHR(2)", 710, 590, 270, 100, STYLE["state"])
    arb = d.vertex("Арбитр шины\nцентрализованный параллельный\nприоритет DMA", 720, 790, 250, 100, STYLE["logic"])
    dma = d.vertex("КПДП\nстартовый адрес 10\n3 слова (6 байт)", 1110, 790, 220, 90, STYLE["logic"])

    d.edge(rom, ipir, "instr", STYLE["bus"])
    d.edge(ipir, cu, "opcode / reg / adr", STYLE["edge"])
    d.edge(cu, rf, "RF_WE, SRC/DST", STYLE["ctrl"])
    d.edge(rf, alu, "A, B", STYLE["bus"])
    d.edge(alu, rf, "Y", STYLE["bus"])
    d.edge(alu, flags, "new flags", STYLE["edge"])
    d.edge(flags, cu, "FR.Z/S/C/O", STYLE["ctrl"])
    d.edge(rf, stack, "push data", STYLE["bus"])
    d.edge(stack, rf, "pop data", STYLE["bus"])
    d.edge(cu, stack, "PUSH/POP", STYLE["ctrl"])
    d.edge(rf, cache, "addr/data", STYLE["bus"])
    d.edge(cu, cache, "load/store", STYLE["ctrl"])
    d.edge(cache, ram, "miss / write-through", STYLE["bus"])
    d.edge(ipir, pred, "PC", STYLE["edge"])
    d.edge(pred, ipir, "predicted target", STYLE["edge"])
    d.edge(cu, pred, "branch update", STYLE["ctrl"])
    d.edge(cache, arb, "REQ_CPU", STYLE["edge"])
    d.edge(arb, cache, "GNT_CPU", STYLE["edge"])
    d.edge(dma, arb, "REQ_DMA", STYLE["edge"])
    d.edge(arb, dma, "GNT_DMA", STYLE["edge"])
    d.edge(dma, ram, "DMA write", STYLE["bus"])
    d.write()


def build_a2() -> None:
    d = Diagram("Структура устройства управления", "Лист 2, формат А3", "A2_control_unit.drawio")
    ir = d.vertex("IR0 + IR1\nполя opcode / reg / adr", 90, 90, 220, 85, STYLE["logic"])
    decoder = d.vertex("Дешифратор команды\nкласс инструкции\nвыбор маршрута", 515, 120, 250, 100, STYLE["logic"])
    seq = d.vertex("Секвенсор тактов\nT0 T1 T2 T3 T4 T5 Tw", 520, 350, 250, 90, STYLE["logic"])
    events = d.vertex("Внешние события\nCACHE_MISS, DMA_WAIT, HLT", 165, 285, 250, 80, STYLE["mem"])
    cond = d.vertex("Условия переходов\nFR.Z, FR.S, FR.C, FR.O", 165, 500, 250, 80, STYLE["state"])
    matrix = d.vertex("Матрица управляющих сигналов\nSRC_A, SRC_B, DST_SEL\nRF_WE, FLAG_WE\nMEM_RD, MEM_WR\nSTK_PUSH, STK_POP\nCACHE_CTL, BP_UPD", 535, 575, 270, 180, STYLE["logic"])
    ip = d.vertex("Логика IP\nIP+2 / branch target\nflush on mispredict", 100, 780, 255, 100, STYLE["mem"])
    targets = d.vertex("К целевым блокам\nРОН, АЛУ, стек, кэш,\nОЗУ, предсказатель", 530, 830, 275, 95, STYLE["mem"])
    bp = d.vertex("Предсказатель A4\nPRED_REQ / PRED_UPD", 960, 520, 230, 90, STYLE["state"])
    wait = d.vertex("Tw\nудержание адресов\nдо ready/grant", 960, 330, 230, 90, STYLE["note"])
    halt = d.vertex("HALT\nостанов автомата\nдо reset/start", 985, 125, 200, 85, STYLE["note"])

    d.edge(ir, decoder, "opcode", STYLE["edge"])
    d.edge(decoder, seq, "тип команды", STYLE["edge"])
    d.edge(events, seq, "вставка Tw / HLT", STYLE["ctrl"])
    d.edge(seq, wait, "CACHE_MISS or DMA_WAIT", STYLE["ctrl"])
    d.edge(wait, seq, "ready", STYLE["ctrl"])
    d.edge(seq, matrix, "активный такт", STYLE["edge"])
    d.edge(cond, matrix, "условия", STYLE["ctrl"])
    d.edge(decoder, halt, "OP_HLT", STYLE["ctrl"])
    d.edge(matrix, ip, "JMP/JZ / next PC", STYLE["ctrl"])
    d.edge(ip, ir, "адрес выборки", STYLE["edge"])
    d.edge(matrix, targets, "управляющие сигналы", STYLE["bus"])
    d.edge(matrix, bp, "branch resolve", STYLE["ctrl"])
    d.edge(bp, ip, "predicted target", STYLE["edge"])
    d.write()


def build_a3() -> None:
    d = Diagram("Исполнительный тракт: РОН, АЛУ, стек и FR", "Лист 3, формат А3", "A3_datapath_alu_stack.drawio")
    memif = d.vertex("Интерфейс данных\nкэш / RAM", 70, 120, 230, 75, STYLE["logic"])
    wbmux = d.vertex("MUX записи\nALU / POP / MEM", 550, 115, 230, 80, STYLE["logic"])
    rf = d.vertex("РОН\n12 x 16 бит\nдва канала чтения\nодин канал записи", 955, 325, 255, 125, STYLE["mem"])
    muxa = d.vertex("MUX A\nвыбор Rn / const 0", 70, 515, 240, 80, STYLE["mem"])
    muxb = d.vertex("MUX B\nвыбор M[adr] / FR.S / const", 1260, 520, 250, 85, STYLE["mem"])
    alu = d.vertex("АЛУ\nOR / NOR / SRA / INCS\nPASS A/B", 400, 660, 250, 110, STYLE["exec"])
    fr = d.vertex("FR\nZ S C O", 830, 660, 120, 70, STYLE["state"])
    stack = d.vertex("Стек\n7 x 16 бит\npush/pop\nSP 7..0", 1320, 120, 160, 105, STYLE["state"])
    ctl = d.vertex("Управляющие сигналы\nRF_WE, ALU_OP, FLAG_WE\nSTK_PUSH, STK_POP", 650, 855, 310, 105, STYLE["logic"])

    d.edge(memif, wbmux, "load data", STYLE["bus"])
    d.edge(wbmux, rf, "writeback", STYLE["bus"])
    d.edge(rf, muxa, "A port", STYLE["bus"])
    d.edge(muxa, alu, "A", STYLE["bus"])
    d.edge(rf, muxb, "B port", STYLE["bus"])
    d.edge(muxb, alu, "B", STYLE["bus"])
    d.edge(alu, wbmux, "Y", STYLE["bus"])
    d.edge(alu, fr, "new flags", STYLE["edge"])
    d.edge(fr, muxb, "S flag", STYLE["edge"])
    d.edge(rf, stack, "push source", STYLE["bus"])
    d.edge(stack, wbmux, "POP data", STYLE["bus"])
    d.edge(ctl, rf, "select/write", STYLE["ctrl"])
    d.edge(ctl, alu, "ALU_OP", STYLE["ctrl"])
    d.edge(ctl, fr, "FLAG_WE", STYLE["ctrl"])
    d.edge(ctl, stack, "PUSH/POP", STYLE["ctrl"])
    d.write()


def build_a4() -> None:
    d = Diagram("Подсистема памяти, кэша, DMA и арбитража", "Лист 4, формат А3", "A4_memory_dma_arbiter.drawio")
    rom = d.vertex("ROM\nсинхронная\nкомандная память", 55, 300, 200, 85, STYLE["rom"])
    fetch = d.vertex("IP / IR\nтракт выборки команд", 335, 300, 230, 85, STYLE["logic"])
    cpu_port = d.vertex("CPU data port\naddr / rd / wr / wdata", 335, 545, 245, 85, STYLE["logic"])
    cache = d.vertex("4-way cache\n16 sets, 1 word line\nTAG + V + AGE\nmax-age replacement", 940, 130, 260, 125, STYLE["exec"])
    cache_ctl = d.vertex("Контроллер кэша\nhit/miss/fill\nвыбор строки AGE", 945, 360, 250, 105, STYLE["exec"])
    arb = d.vertex("Bus arbiter\nREQ/GNT\npriority DMA", 690, 485, 220, 95, STYLE["logic"])
    ram = d.vertex("RAM\nсинхронная память данных\n16 x 16 тракт модели", 1310, 315, 230, 90, STYLE["mem"])
    dma = d.vertex("DMA / КПДП\n3 слова в RAM\nstart @ 10", 1065, 670, 220, 95, STYLE["logic"])
    pred = d.vertex("Branch predictor A4\nPHT + BTB + GHR", 705, 760, 240, 90, STYLE["state"])
    note = d.vertex("Проверка на диаграмме\nREQ_CPU=1 и REQ_DMA=1\nGNT_DMA=1, GNT_CPU=0", 1055, 880, 330, 90, STYLE["note"])

    d.edge(rom, fetch, "instruction words", STYLE["bus"])
    d.edge(fetch, cpu_port, "decoded memory op", STYLE["edge"])
    d.edge(cpu_port, cache_ctl, "lookup/read/write", STYLE["bus"])
    d.edge(cache_ctl, cache, "line select", STYLE["edge"])
    d.edge(cache, cache_ctl, "hit/data", STYLE["edge"])
    d.edge(cache_ctl, arb, "REQ_CPU", STYLE["edge"])
    d.edge(arb, cache_ctl, "CPU grant", STYLE["edge"])
    d.edge(cache, ram, "fill / write-through", STYLE["bus"])
    d.edge(dma, arb, "REQ_DMA", STYLE["edge"])
    d.edge(arb, dma, "DMA grant", STYLE["edge"])
    d.edge(dma, ram, "DMA writes", STYLE["bus"])
    d.edge(cpu_port, pred, "branch update", STYLE["ctrl"])
    d.edge(pred, fetch, "predicted target", STYLE["edge"])
    d.edge(note, arb, "контроль", STYLE["ctrl"])
    d.write()


def main() -> None:
    build_a1()
    build_a2()
    build_a3()
    build_a4()


if __name__ == "__main__":
    main()
