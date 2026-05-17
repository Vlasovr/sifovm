from __future__ import annotations

from pathlib import Path
from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
SCHEMES = ROOT / "assets" / "schemes"
WAVES = ROOT / "assets" / "waveforms"

INK = "#111827"
MUTED = "#475569"
LINE = "#26364d"
HEADER = "#e2e8f0"
BLUE = "#dbeafe"
CYAN = "#e0f2fe"
GREEN = "#dcfce7"
YELLOW = "#fef3c7"
PINK = "#fee2e2"
GRAY = "#f8fafc"


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    name = "arialbd.ttf" if bold else "arial.ttf"
    return ImageFont.truetype(str(Path("C:/Windows/Fonts") / name), size)


F_TITLE = font(42, True)
F_SUB = font(25)
F_H = font(27, True)
F = font(25)
F_S = font(21)
F_XS = font(18)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont) -> tuple[int, int]:
    box = draw.textbbox((0, 0), text, font=fnt)
    return box[2] - box[0], box[3] - box[1]


def centered(draw: ImageDraw.ImageDraw, xywh: tuple[int, int, int, int], text: str, fnt, fill=INK):
    x, y, w, h = xywh
    tw, th = text_size(draw, text, fnt)
    draw.text((x + (w - tw) / 2, y + (h - th) / 2 - 2), text, font=fnt, fill=fill)


def box(draw: ImageDraw.ImageDraw, x: int, y: int, w: int, h: int, title: str, lines=(), fill=GRAY):
    draw.rounded_rectangle((x, y, x + w, y + h), radius=10, fill=fill, outline=LINE, width=3)
    if lines:
        centered(draw, (x, y + 18, w, 32), title, F_H)
        step = 29
        start = y + 58
        for i, line in enumerate(lines):
            centered(draw, (x + 8, start + i * step, w - 16, step), line, F)
    else:
        centered(draw, (x, y, w, h), title, F_H)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], text: str = ""):
    draw.line((start, end), fill=INK, width=4)
    x1, y1 = start
    x2, y2 = end
    if abs(x2 - x1) >= abs(y2 - y1):
        s = 1 if x2 >= x1 else -1
        pts = [(x2, y2), (x2 - 18 * s, y2 - 9), (x2 - 18 * s, y2 + 9)]
    else:
        s = 1 if y2 >= y1 else -1
        pts = [(x2, y2), (x2 - 9, y2 - 18 * s), (x2 + 9, y2 - 18 * s)]
    draw.polygon(pts, fill=INK)
    if text:
        tx = (x1 + x2) / 2
        ty = (y1 + y2) / 2 - 25
        draw.text((tx, ty), text, font=F_XS, fill=MUTED)


def canvas(title: str, subtitle: str) -> tuple[Image.Image, ImageDraw.ImageDraw]:
    img = Image.new("RGB", (1900, 1080), "white")
    draw = ImageDraw.Draw(img)
    draw.rectangle((0, 0, 1900, 98), fill=HEADER)
    draw.text((40, 24), title, font=F_TITLE, fill=INK)
    draw.text((42, 68), subtitle, font=F_SUB, fill=MUTED)
    return img, draw


def save(img: Image.Image, path: Path):
    path.parent.mkdir(parents=True, exist_ok=True)
    img.save(path)


def lab5_scheme():
    img, d = canvas("ЛР5. Арифметико-логическое устройство", "Вариант 4: SRA, CMP, NOR; признаки результата Z/S/C/O")
    box(d, 80, 230, 210, 108, "opcode", ["8 бит"], YELLOW)
    box(d, 80, 535, 210, 100, "A", ["16 бит"], GREEN)
    box(d, 80, 715, 210, 100, "B", ["16 бит"], GREEN)
    box(d, 385, 180, 330, 205, "Блок управления АЛУ", ["дешифрация команды", "выбор операции", "запись признаков"], BLUE)
    box(d, 835, 165, 285, 120, "CMP", ["A - B", "Z/S/C/O"], GRAY)
    box(d, 835, 355, 285, 120, "NOR", ["NOT(A OR B)", "Z/S"], GRAY)
    box(d, 835, 545, 285, 120, "SRA", ["A15 & A15..A1", "C=A0"], GRAY)
    box(d, 1235, 355, 265, 160, "MUX результата", ["alu_op[2..0]", "выбор ветви"], CYAN)
    box(d, 1580, 350, 230, 138, "Y", ["результат", "16 бит"], GREEN)
    box(d, 1580, 625, 230, 145, "Флаги", ["Z  S  C  O"], PINK)

    arrow(d, (290, 284), (385, 284))
    for yy in (225, 415, 605):
        arrow(d, (715, 282), (835, yy), "alu_op")
    for yy in (225, 415, 605):
        arrow(d, (290, 585), (835, yy))
    arrow(d, (290, 765), (835, 225))
    arrow(d, (290, 765), (835, 415))
    arrow(d, (1120, 225), (1235, 435))
    arrow(d, (1120, 415), (1235, 435))
    arrow(d, (1120, 605), (1235, 435))
    arrow(d, (1500, 435), (1580, 419))
    arrow(d, (1695, 488), (1695, 625))
    d.text((85, 930), "Коды команд: OP_CMP=03h, OP_NOR=04h, OP_SRA=05h. CMP формирует признаки по результату A-B.", font=F_S, fill=MUTED)
    save(img, SCHEMES / "lab5_alu_scheme.png")


def lab6_scheme():
    img, d = canvas("ЛР6. Стековое запоминающее устройство", "Вариант 4: глубина 7 слов, рост вверх, SP указывает последнюю занятую ячейку")
    box(d, 80, 195, 245, 135, "Команда", ["PUSH", "POP", "PUSH_ALU"], YELLOW)
    box(d, 80, 470, 245, 100, "Данные РОН", ["16 бит"], GREEN)
    box(d, 80, 650, 245, 100, "Результат АЛУ", ["CMP"], GREEN)
    box(d, 420, 205, 330, 180, "Блок управления", ["дешифрация команды", "push/pop", "выбор источника"], BLUE)
    box(d, 420, 545, 330, 150, "MUX входа", ["РОН или АЛУ", "16 бит"], CYAN)
    d.rounded_rectangle((905, 175, 1255, 815), radius=10, fill=GRAY, outline=LINE, width=3)
    d.text((1010, 190), "Стек 7 x 16", font=F_H, fill=INK)
    for i in range(7):
        y = 235 + (6 - i) * 70
        fill = "#eff6ff" if i % 2 == 0 else "#ffffff"
        d.rounded_rectangle((955, y, 1205, y + 48), radius=5, fill=fill, outline=LINE, width=2)
        d.text((970, y + 11), f"ячейка {i}", font=F_S, fill=INK)
    arrow(d, (1290, 705), (1290, 245))
    d.text((1320, 330), "Рост вверх", font=F_S, fill=MUTED)
    d.text((1320, 455), "SP: последняя\nзанятая ячейка", font=F, fill=INK)
    box(d, 1485, 230, 270, 135, "Выход POP", ["данные в РОН"], GREEN)
    box(d, 1485, 515, 270, 185, "Признаки", ["empty", "full", "overflow", "underflow"], PINK)

    arrow(d, (325, 265), (420, 265))
    arrow(d, (325, 520), (420, 620))
    arrow(d, (325, 700), (420, 620))
    arrow(d, (750, 620), (905, 620), "din")
    arrow(d, (750, 295), (905, 295), "push/pop")
    arrow(d, (1255, 300), (1485, 295))
    arrow(d, (1255, 625), (1485, 610))
    d.text((85, 930), "Пустой стек: SP=7. После первой записи SP=0. Полный стек: SP=6.", font=F_S, fill=MUTED)
    save(img, SCHEMES / "lab6_stack_scheme.png")


def lab7_scheme():
    img, d = canvas("ЛР7. Арбитраж общей шины", "Вариант 4: централизованный параллельный арбитраж, фиксированный квант времени")
    for i, y in enumerate((185, 340, 495, 650)):
        box(d, 80, y, 250, 100, f"Ведущий {i}", [f"REQ{i}", f"DATA{i}"], GREEN)
        arrow(d, (330, y + 35), (585, 290 + i * 55), f"REQ{i}")
        arrow(d, (330, y + 75), (1095, 600), f"DATA{i}")
    box(d, 585, 210, 360, 260, "Центральный арбитр", ["слоты 0..3", "фиксированный квант", "one-hot GNT"], BLUE)
    box(d, 1040, 500, 280, 175, "MUX общей шины", ["выбор DATA", "по GNT"], CYAN)
    box(d, 1450, 455, 300, 170, "Ведомый модуль", ["прием по BUSY", "регистр данных"], YELLOW)
    arrow(d, (945, 340), (1040, 585), "GNT[3..0]")
    arrow(d, (1320, 590), (1450, 540), "BUS[15..0]")
    arrow(d, (945, 420), (1450, 615), "BUSY")
    d.text((85, 930), "Арбитр циклически перебирает ведущие устройства. В своем слоте ведущий получает шину только при активном запросе.", font=F_S, fill=MUTED)
    save(img, SCHEMES / "lab7_bus_scheme.png")


def lab8_scheme():
    img, d = canvas("ЛР8. Кэш-память с прямым отображением", "Вариант 4: 8 строк, 1 слово в строке, замещение не требуется")
    box(d, 85, 225, 250, 170, "CPU", ["REQ / WE", "ADDR[15..0]", "WDATA[15..0]"], GREEN)
    box(d, 470, 160, 325, 145, "Разбор адреса", ["TAG = A[15..3]", "INDEX = A[2..0]"], BLUE)
    box(d, 470, 500, 325, 160, "Управление", ["hit/miss", "ready", "write-through"], BLUE)
    d.rounded_rectangle((955, 145, 1385, 665), radius=10, fill=GRAY, outline=LINE, width=3)
    d.text((1090, 165), "Массив кэша", font=F_H, fill=INK)
    d.text((1005, 205), "valid", font=F_S, fill=INK)
    d.text((1110, 205), "tag", font=F_S, fill=INK)
    d.text((1265, 205), "data", font=F_S, fill=INK)
    for i in range(8):
        y = 230 + i * 48
        d.rounded_rectangle((995, y, 1335, y + 34), radius=4, fill="#ffffff", outline=LINE, width=2)
        d.text((960, y + 6), str(i), font=F_XS, fill=MUTED)
        d.text((1015, y + 6), "V", font=F_XS, fill=INK)
        d.text((1115, y + 6), "TAG", font=F_XS, fill=INK)
        d.text((1260, y + 6), "DATA", font=F_XS, fill=INK)
    box(d, 1515, 235, 280, 180, "Основная память", ["чтение при miss", "запись при WE"], YELLOW)
    box(d, 1515, 590, 280, 135, "Ответ CPU", ["RDATA", "READY/HIT/MISS"], GREEN)

    arrow(d, (335, 305), (470, 232))
    arrow(d, (795, 232), (955, 255), "index")
    arrow(d, (795, 232), (955, 190), "tag")
    arrow(d, (335, 305), (470, 580))
    arrow(d, (795, 580), (955, 520), "we/req")
    arrow(d, (1385, 350), (1515, 320), "miss")
    arrow(d, (1515, 665), (1385, 520), "data")
    arrow(d, (1385, 520), (1515, 650), "hit/read")
    d.text((85, 930), "При совпадении valid и tag формируется hit. При miss выбранная индексом строка перезаписывается данными из основной памяти.", font=F_S, fill=MUTED)
    save(img, SCHEMES / "lab8_cache_scheme.png")


def draw_wave(path: Path, title: str, rows: list[tuple[str, list[str]]], notes: list[str]):
    w, h = 1700, 120 + len(rows) * 62 + 105
    img = Image.new("RGB", (w, h), "white")
    d = ImageDraw.Draw(img)
    d.rectangle((0, 0, w, 78), fill=HEADER)
    d.text((35, 22), title, font=font(34, True), fill=INK)
    left = 250
    slot_w = (w - left - 50) // max(len(rows[0][1]), 1)
    top = 110
    for i in range(len(rows[0][1]) + 1):
        x = left + i * slot_w
        d.line((x, 92, x, h - 82), fill="#cbd5e1", width=1)
        if i < len(rows[0][1]):
            centered(d, (x, 84, slot_w, 22), f"t{i}", F_XS, MUTED)
    for r, (name, values) in enumerate(rows):
        y = top + r * 62
        d.text((35, y + 15), name, font=F_S, fill=INK)
        d.line((left, y + 42, w - 50, y + 42), fill=LINE, width=2)
        for i, value in enumerate(values):
            x = left + i * slot_w
            fill = "#ecfeff" if i % 2 else "#f8fafc"
            d.rectangle((x + 2, y + 5, x + slot_w - 2, y + 39), fill=fill, outline="#e2e8f0")
            centered(d, (x + 4, y + 7, slot_w - 8, 28), value, F_XS)
    note_y = h - 72
    for note in notes:
        d.text((35, note_y), note, font=F_XS, fill=MUTED)
        note_y += 24
    save(img, path)


def waveforms():
    draw_wave(
        WAVES / "lab5_waveform.png",
        "ЛР5. Контрольная временная диаграмма АЛУ",
        [
            ("Команда", ["CMP", "CMP", "CMP", "NOR", "SRA", "NOR"]),
            ("A", ["0010", "1234", "0001", "0FFF", "8001", "FFFF"]),
            ("B", ["0001", "1234", "0002", "0FFF", "----", "FFFF"]),
            ("Y", ["000F", "0000", "FFFF", "F000", "C000", "0000"]),
            ("Z", ["0", "1", "0", "0", "0", "1"]),
            ("S", ["0", "0", "1", "1", "1", "0"]),
            ("C", ["0", "0", "1", "0", "1", "0"]),
            ("O", ["0", "0", "0", "0", "0", "0"]),
        ],
        ["CMP задает признаки по разности A-B; NOR проверяет логический результат; SRA сохраняет знак и выдает младший бит в C."],
    )
    draw_wave(
        WAVES / "lab6_waveform.png",
        "ЛР6. Контрольная временная диаграмма стека",
        [
            ("Режим", ["RST", "PUSH", "PUSH", "POP", "PUSH_ALU", "FILL", "PUSH", "POPx7", "POP"]),
            ("DIN", ["0000", "1111", "2222", "----", "000F", "3333..7777", "8888", "----", "----"]),
            ("DOUT", ["0000", "0000", "0000", "2222", "2222", "2222", "2222", "1111", "1111"]),
            ("SP", ["7", "0", "1", "0", "1", "6", "6", "7", "7"]),
            ("EMPTY", ["1", "0", "0", "0", "0", "0", "0", "1", "1"]),
            ("FULL", ["0", "0", "0", "0", "0", "1", "1", "0", "0"]),
            ("OVER", ["0", "0", "0", "0", "0", "0", "1", "0", "0"]),
            ("UNDER", ["0", "0", "0", "0", "0", "0", "0", "0", "1"]),
        ],
        ["SP=7 означает пустой стек. При росте вверх первая запись занимает ячейку 0, полный стек соответствует SP=6."],
    )
    draw_wave(
        WAVES / "lab7_waveform.png",
        "ЛР7. Контрольная временная диаграмма арбитража",
        [
            ("Слот", ["0", "1", "2", "3", "0", "1", "2", "3"]),
            ("REQ", ["0001", "0010", "0100", "1000", "0001", "0000", "0100", "1000"]),
            ("GNT", ["0001", "0010", "0100", "1000", "0001", "0000", "0100", "1000"]),
            ("BUSY", ["1", "1", "1", "1", "1", "0", "1", "1"]),
            ("BUS", ["A001", "B002", "C003", "D004", "A001", "0000", "C003", "D004"]),
            ("SLAVE", ["A001", "B002", "C003", "D004", "A001", "A001", "C003", "D004"]),
        ],
        ["Grant выдается только ведущему текущего временного слота; при отсутствии запроса шина остается свободной."],
    )
    draw_wave(
        WAVES / "lab8_waveform.png",
        "ЛР8. Контрольная временная диаграмма кэш-памяти",
        [
            ("Операция", ["READ", "READ", "WRITE", "READ", "READ"]),
            ("Адрес", ["0010", "0010", "0010", "0018", "0010"]),
            ("WE", ["0", "0", "1", "0", "0"]),
            ("HIT", ["0", "1", "1", "0", "0"]),
            ("MISS", ["1", "0", "0", "1", "1"]),
            ("READY", ["1", "1", "1", "1", "1"]),
            ("DATA", ["1110", "1110", "ABCD", "1198", "ABCD"]),
            ("RAM_REQ", ["1", "0", "1", "1", "1"]),
        ],
        ["Адреса 0010h и 0018h имеют одинаковый индекс, поэтому во втором чтении 0018h строка прямого отображения заменяется."],
    )


def main():
    lab5_scheme()
    lab6_scheme()
    lab7_scheme()
    lab8_scheme()
    waveforms()


if __name__ == "__main__":
    main()
