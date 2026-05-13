#!/usr/bin/env python3
"""Add report-friendly callouts to the Quartus RTL Viewer cache screenshot."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


PROJECT_DIR = Path(__file__).resolve().parents[1]
SRC = Path(r"C:\Users\user\Pictures\Screenshots\Снимок экрана 2026-05-09 002705.png")
OUT = PROJECT_DIR / "documents" / "images" / "cache_4way_structural_rtl_annotated.png"
OUT_CROP = PROJECT_DIR / "documents" / "images" / "cache_4way_structural_rtl_clean.png"
OUT_NUMBERED = PROJECT_DIR / "documents" / "images" / "cache_4way_structural_rtl_numbered.png"
OUT_NUMBERED_PDF = PROJECT_DIR / "documents" / "graphics" / "Доп_лист_9б_Кэш_RTL_подписанный.pdf"

FONT = Path(r"C:\Windows\Fonts\arial.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\arialbd.ttf")


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_BOLD if bold else FONT), size)


def text_size(draw: ImageDraw.ImageDraw, text: str, fnt: ImageFont.FreeTypeFont) -> tuple[int, int]:
    lines = text.splitlines()
    widths = [draw.textbbox((0, 0), line, font=fnt)[2] for line in lines]
    line_h = int(fnt.size * 1.25)
    return max(widths, default=0), line_h * len(lines)


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], color: str) -> None:
    draw.line([start, end], fill=color, width=4)
    x1, y1 = start
    x2, y2 = end
    dx = x2 - x1
    dy = y2 - y1
    if abs(dx) >= abs(dy):
        sign = 1 if dx >= 0 else -1
        pts = [(x2, y2), (x2 - 14 * sign, y2 - 7), (x2 - 14 * sign, y2 + 7)]
    else:
        sign = 1 if dy >= 0 else -1
        pts = [(x2, y2), (x2 - 7, y2 - 14 * sign), (x2 + 7, y2 - 14 * sign)]
    draw.polygon(pts, fill=color)


def callout(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    text: str,
    target: tuple[int, int],
    color: str,
    width: int = 315,
) -> None:
    x, y = xy
    pad = 12
    f_title = font(20, True)
    f_body = font(17)
    lines = text.splitlines()
    title = lines[0]
    body = "\n".join(lines[1:])
    _, title_h = text_size(draw, title, f_title)
    _, body_h = text_size(draw, body, f_body)
    h = pad * 2 + title_h + (6 if body else 0) + body_h

    fill = (255, 255, 238)
    draw.rounded_rectangle([x, y, x + width, y + h], radius=8, fill=fill, outline=color, width=3)
    draw.text((x + pad, y + pad), title, font=f_title, fill=(30, 30, 30))
    if body:
        draw.text((x + pad, y + pad + title_h + 4), body, font=f_body, fill=(30, 30, 30), spacing=2)

    if target[0] < x:
        start = (x, y + h // 2)
    else:
        start = (x + width, y + h // 2)
    arrow(draw, start, target, color)


def label_band(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str, color: str) -> None:
    x1, y1, x2, y2 = box
    draw.rounded_rectangle(box, radius=8, outline=color, width=4)
    draw.rectangle([x1 + 8, y1 - 18, x1 + 8 + 12 * len(text), y1 + 8], fill=(255, 255, 255))
    draw.text((x1 + 14, y1 - 20), text, font=font(18, True), fill=color)


def badge(draw: ImageDraw.ImageDraw, xy: tuple[int, int], number: int, color: str) -> None:
    x, y = xy
    r = 18
    draw.ellipse([x - r, y - r, x + r, y + r], fill=color, outline=(255, 255, 255), width=4)
    text = str(number)
    fnt = font(20, True)
    bbox = draw.textbbox((0, 0), text, font=fnt)
    draw.text((x - (bbox[2] - bbox[0]) / 2, y - (bbox[3] - bbox[1]) / 2 - 1), text, font=fnt, fill=(255, 255, 255))


def legend_item(
    draw: ImageDraw.ImageDraw,
    xy: tuple[int, int],
    number: int,
    title: str,
    body: str,
    color: str,
    width: int = 360,
) -> int:
    x, y = xy
    pad = 12
    title_f = font(19, True)
    body_f = font(16)
    _, title_h = text_size(draw, title, title_f)
    _, body_h = text_size(draw, body, body_f)
    h = max(72, pad * 2 + title_h + body_h + 6)
    draw.rounded_rectangle([x, y, x + width, y + h], radius=8, fill=(255, 255, 238), outline=color, width=3)
    badge(draw, (x + 24, y + 28), number, color)
    draw.text((x + 54, y + 11), title, font=title_f, fill=(20, 20, 20))
    draw.text((x + 54, y + 36), body, font=body_f, fill=(35, 35, 35), spacing=2)
    return h


def main() -> None:
    src = Image.open(SRC).convert("RGB")

    # Remove Quartus hierarchy tree; keep the schematic canvas.
    crop_left = 350
    clean = src.crop((crop_left, 70, src.width, src.height))
    OUT_CROP.parent.mkdir(parents=True, exist_ok=True)
    clean.save(OUT_CROP)

    margin_right = 390
    margin_top = 70
    margin_bottom = 35
    canvas = Image.new("RGB", (clean.width + margin_right, clean.height + margin_top + margin_bottom), "white")
    canvas.paste(clean, (0, margin_top))
    draw = ImageDraw.Draw(canvas)

    # Header.
    draw.text((24, 18), "Блок кэш-памяти: структурная схема RTL Viewer", font=font(28, True), fill=(0, 0, 0))
    draw.text((24, 50), "Подписи добавлены поверх экспортированной схемы Quartus; рабочая реализация VHDL не меняется.",
              font=font(17), fill=(80, 80, 80))

    # Main grouping rectangles on the cropped schematic.
    y = margin_top
    label_band(draw, (155, y + 30, 380, y + 1120), "Метаданные way: VALID / TAG / AGE", "#1f77b4")
    label_band(draw, (480, y + 70, 650, y + 1040), "Сравнение TAG и выбор way", "#7a3db8")
    label_band(draw, (655, y + 70, 900, y + 1060), "Банки данных DATA way0..3", "#2b8a3e")
    label_band(draw, (920, y + 80, 1090, y + 230), "MUX 4:1", "#d97706")
    label_band(draw, (1115, y + 105, 1325, y + 300), "Управляющий автомат", "#b91c1c")
    label_band(draw, (1335, y + 1170, 1518, y + 1305), "Интерфейс ОЗУ", "#0f766e")

    callout(
        draw,
        (clean.width + 26, margin_top + 45),
        "Входы процессора\ncpu_req_i, cpu_we_i, cpu_addr_i,\ncpu_wdata_i задают операцию\nчтения/записи и адрес строки.",
        (115, margin_top + 1040),
        "#111827",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 190),
        "Разбиение адреса\nTAG = cpu_addr_i[15..4]\nSET = cpu_addr_i[3..0]\nSET выбирает один из 16 наборов.",
        (155, margin_top + 70),
        "#1f77b4",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 355),
        "TAG / VALID / AGE\nTAG хранит старшую часть адреса;\nVALID показывает достоверность;\nAGE нужен для замещения.",
        (270, margin_top + 610),
        "#1f77b4",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 535),
        "TAG compare\nДля каждого way проверяется:\nсохраненный TAG == TAG запроса.\nСовпадение участвует в hit.",
        (565, margin_top + 460),
        "#7a3db8",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 710),
        "DATA way0..3\nЧетыре банка данных кэша.\nПри hit MUX выбирает данные\nиз найденного way.",
        (760, margin_top + 1080),
        "#2b8a3e",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 890),
        "HIT / MISS\nhit = OR(way_hit0..3),\nmiss = NOT(hit).\nЭто те AND/OR/NOT, которые\nимеет смысл показывать.",
        (985, margin_top + 220),
        "#d97706",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 1095),
        "CACHE CONTROL\nАвтомат управляет чтением,\nпромахом, заполнением строки,\nзаписью и сигналом ready.",
        (1245, margin_top + 235),
        "#b91c1c",
    )
    callout(
        draw,
        (clean.width + 26, margin_top + 1260),
        "RAM interface\nПри miss читает данные из ОЗУ;\nпри записи выполняет\nwrite-through в ОЗУ.",
        (1435, margin_top + 1238),
        "#0f766e",
    )

    # Small in-place labels for outputs.
    f = font(18, True)
    draw.rounded_rectangle([1328, margin_top + 55, 1560, margin_top + 92], radius=6, fill=(255, 255, 238), outline="#d97706", width=2)
    draw.text((1340, margin_top + 62), "cpu_rdata_o: данные CPU", font=f, fill="#111827")
    draw.rounded_rectangle([1305, margin_top + 190, 1580, margin_top + 258], radius=6, fill=(255, 255, 238), outline="#b91c1c", width=2)
    draw.text((1317, margin_top + 200), "hit_o / miss_o / ready_o", font=f, fill="#111827")
    draw.text((1317, margin_top + 224), "результат обращения к кэшу", font=font(16), fill="#111827")

    OUT.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(OUT)

    # Cleaner report variant: numbered markers instead of long crossing arrows.
    canvas2 = Image.new("RGB", (clean.width + margin_right, clean.height + margin_top + margin_bottom), "white")
    canvas2.paste(clean, (0, margin_top))
    draw2 = ImageDraw.Draw(canvas2)
    draw2.text((24, 18), "Блок кэш-памяти: структурная схема RTL Viewer", font=font(28, True), fill=(0, 0, 0))
    draw2.text((24, 50), "Нумерация показывает основные функциональные узлы и направления обмена.",
               font=font(17), fill=(80, 80, 80))
    draw2.line([(0, margin_top - 4), (clean.width, margin_top - 4)], fill=(120, 120, 120), width=2)

    label_band(draw2, (155, y + 30, 380, y + 1120), "2-3: TAG / VALID / AGE", "#1f77b4")
    label_band(draw2, (480, y + 70, 650, y + 1040), "4: TAG compare", "#7a3db8")
    label_band(draw2, (655, y + 70, 900, y + 1060), "5: DATA way0..3", "#2b8a3e")
    label_band(draw2, (920, y + 80, 1090, y + 230), "6: MUX 4:1 / HIT", "#d97706")
    label_band(draw2, (1115, y + 105, 1325, y + 300), "8: CACHE CONTROL", "#b91c1c")
    label_band(draw2, (1335, y + 1170, 1518, y + 1305), "9: RAM interface", "#0f766e")

    markers = [
        ((110, margin_top + 1070), 1, "#111827"),
        ((165, margin_top + 78), 2, "#1f77b4"),
        ((270, margin_top + 610), 3, "#1f77b4"),
        ((560, margin_top + 455), 4, "#7a3db8"),
        ((765, margin_top + 1020), 5, "#2b8a3e"),
        ((970, margin_top + 170), 6, "#d97706"),
        ((985, margin_top + 225), 7, "#d97706"),
        ((1248, margin_top + 235), 8, "#b91c1c"),
        ((1438, margin_top + 1240), 9, "#0f766e"),
    ]
    for xy, num, color in markers:
        badge(draw2, xy, num, color)

    legend_x = clean.width + 20
    legend_y = margin_top + 25
    items = [
        (1, "Входы CPU", "req/we/address/wdata:\nоперация процессора.", "#111827"),
        (2, "Разбиение адреса", "TAG=A[15..4], SET=A[3..0].\nSET выбирает 1 из 16 наборов.", "#1f77b4"),
        (3, "Метаданные way", "TAG хранит адресную метку;\nVALID - достоверность;\nAGE - возраст строки.", "#1f77b4"),
        (4, "Сравнение TAG", "Для каждого way:\nstored TAG == request TAG.", "#7a3db8"),
        (5, "Банки DATA", "Четыре банка данных cache way0..3.", "#2b8a3e"),
        (6, "MUX 4:1", "При hit выбирает DATA\nиз найденного way.", "#d97706"),
        (7, "HIT/MISS", "hit=OR(way_hit0..3),\nmiss=NOT(hit).", "#d97706"),
        (8, "CACHE CONTROL", "FSM управляет miss/refill,\nwrite-through и ready.", "#b91c1c"),
        (9, "RAM interface", "Обмен с ОЗУ:\nread on miss, write-through on write.", "#0f766e"),
    ]
    for item in items:
        h = legend_item(draw2, (legend_x, legend_y), *item)
        legend_y += h + 14

    canvas2.save(OUT_NUMBERED)
    OUT_NUMBERED_PDF.parent.mkdir(parents=True, exist_ok=True)
    canvas2.save(OUT_NUMBERED_PDF, "PDF", resolution=180.0)
    print(OUT)
    print(OUT_CROP)
    print(OUT_NUMBERED)
    print(OUT_NUMBERED_PDF)


if __name__ == "__main__":
    main()
