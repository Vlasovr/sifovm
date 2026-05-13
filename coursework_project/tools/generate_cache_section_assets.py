#!/usr/bin/env python3
"""Generate cache report figures that are hard to export cleanly from Quartus."""

from __future__ import annotations

from pathlib import Path
import textwrap

from PIL import Image, ImageDraw, ImageFont


PROJECT_DIR = Path(__file__).resolve().parents[1]
OUT_IMG = PROJECT_DIR / "documents" / "images"
OUT_GFX = PROJECT_DIR / "documents" / "graphics"
FONT = Path(r"C:\Windows\Fonts\arial.ttf")
FONT_BOLD = Path(r"C:\Windows\Fonts\arialbd.ttf")


def font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    return ImageFont.truetype(str(FONT_BOLD if bold else FONT), size)


def center_text(draw: ImageDraw.ImageDraw, box: tuple[int, int, int, int], text: str, size: int, bold: bool = False, fill=(0, 0, 0)) -> None:
    f = font(size, bold)
    lines = text.splitlines()
    line_h = int(size * 1.25)
    total_h = line_h * len(lines)
    y = box[1] + (box[3] - box[1] - total_h) // 2
    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=f)
        x = box[0] + (box[2] - box[0] - (bbox[2] - bbox[0])) // 2
        draw.text((x, y), line, font=f, fill=fill)
        y += line_h


def wrap_cell(text: str, width: int = 42) -> str:
    return "\n".join(textwrap.wrap(text, width=width, break_long_words=False))


def arrow(draw: ImageDraw.ImageDraw, start: tuple[int, int], end: tuple[int, int], label: str = "", color=(0, 0, 0), width: int = 3) -> None:
    draw.line([start, end], fill=color, width=width)
    x1, y1 = start
    x2, y2 = end
    dx, dy = x2 - x1, y2 - y1
    if abs(dx) >= abs(dy):
        s = 1 if dx >= 0 else -1
        head = [(x2, y2), (x2 - 14 * s, y2 - 7), (x2 - 14 * s, y2 + 7)]
    else:
        s = 1 if dy >= 0 else -1
        head = [(x2, y2), (x2 - 7, y2 - 14 * s), (x2 + 7, y2 - 14 * s)]
    draw.polygon(head, fill=color)
    if label:
        mx = (x1 + x2) // 2
        my = (y1 + y2) // 2
        f = font(18)
        bbox = draw.textbbox((0, 0), label, font=f)
        pad = 5
        draw.rounded_rectangle([mx - 8, my - 30, mx + bbox[2] - bbox[0] + pad * 2 - 8, my - 2], radius=4, fill=(255, 255, 255), outline=color)
        draw.text((mx + pad - 8, my - 28), label, font=f, fill=color)


def state(draw: ImageDraw.ImageDraw, center: tuple[int, int], text: str, color=(40, 95, 170)) -> None:
    x, y = center
    w, h = 220, 86
    box = (x - w // 2, y - h // 2, x + w // 2, y + h // 2)
    draw.rounded_rectangle(box, radius=22, fill=(238, 247, 255), outline=color, width=4)
    center_text(draw, box, text, 20, True, color)


def generate_fsm() -> None:
    img = Image.new("RGB", (1500, 900), "white")
    draw = ImageDraw.Draw(img)
    draw.text((40, 28), "Автомат управления кэш-памятью", font=font(34, True), fill=(0, 0, 0))
    draw.text((40, 72), "Построен по VHDL-описанию cache_4way_age: state_r", font=font(20), fill=(80, 80, 80))

    idl = (210, 370)
    wrg = (610, 220)
    wrd = (1030, 220)
    wwg = (610, 540)

    state(draw, idl, "IDLE\nожидание запроса")
    state(draw, wrg, "WAIT_READ_GRANT\nзапрос чтения RAM")
    state(draw, wrd, "WAIT_READ_DATA\nзаполнение строки")
    state(draw, wwg, "WAIT_WRITE_GRANT\nсквозная запись")

    arrow(draw, (320, 340), (500, 245), "read miss", (27, 94, 32))
    arrow(draw, (720, 220), (920, 220), "ram_grant_i=1", (27, 94, 32))
    arrow(draw, (1030, 265), (330, 390), "fill cache, ready", (27, 94, 32))
    arrow(draw, (320, 402), (500, 520), "cpu_we_i=1", (180, 65, 20))
    arrow(draw, (500, 560), (320, 430), "ram_grant_i=1", (180, 65, 20))

    # Self-loops and hit path.
    draw.arc((90, 238, 330, 502), start=120, end=415, fill=(80, 80, 80), width=3)
    arrow(draw, (118, 318), (122, 316), "no request", (80, 80, 80), 3)
    arrow(draw, (120, 370), (320, 370), "read hit: hit_o=1, ready", (100, 45, 160))
    arrow(draw, (610, 170), (610, 150), "grant=0", (80, 80, 80), 3)
    arrow(draw, (610, 590), (610, 615), "grant=0", (80, 80, 80), 3)

    note = (
        "Смысл состояний:\n"
        "IDLE - кэш принимает запрос CPU и проверяет TAG/VALID.\n"
        "WAIT_READ_GRANT - при miss запрашивается чтение из RAM.\n"
        "WAIT_READ_DATA - слово из RAM записывается в выбранный way и выдается CPU.\n"
        "WAIT_WRITE_GRANT - при записи выставляются ram_we_o, ram_addr_o, ram_wdata_o."
    )
    draw.rounded_rectangle((80, 665, 1410, 845), radius=10, fill=(255, 255, 238), outline=(120, 120, 120), width=2)
    draw.text((105, 685), note, font=font(20), fill=(0, 0, 0), spacing=5)

    OUT_IMG.mkdir(parents=True, exist_ok=True)
    OUT_GFX.mkdir(parents=True, exist_ok=True)
    png = OUT_IMG / "cache_control_fsm.png"
    pdf = OUT_GFX / "Рисунок_кэш_автомат_управления.pdf"
    img.save(png)
    img.save(pdf, "PDF", resolution=180.0)


def generate_addr_table() -> None:
    img = Image.new("RGB", (1450, 540), "white")
    draw = ImageDraw.Draw(img)
    draw.text((40, 28), "Разбиение адреса обращения к кэш-памяти", font=font(32, True), fill=(0, 0, 0))
    draw.text((40, 70), "Адрес 16 бит: TAG выбирает метку, SET выбирает набор; смещение отсутствует, строка = 1 слово.", font=font(19), fill=(70, 70, 70))

    x, y = 70, 150
    widths = [210, 260, 190, 680]
    heights = [56, 86, 86, 86]
    headers = ["Разряды", "Поле", "Размер", "Назначение"]
    rows = [
        ["A[15:4]", "TAG", "12 бит", wrap_cell("Сравнивается с тегами way0..3 для определения hit/miss", 50)],
        ["A[3:0]", "SET", "4 бита", "Выбирает один из 16 наборов кэша"],
        ["-", "OFFSET", "0 бит", wrap_cell("Смещение отсутствует, одна строка содержит одно 16-битное слово", 50)],
    ]
    cx = x
    for i, h in enumerate(headers):
        draw.rectangle((cx, y, cx + widths[i], y + heights[0]), fill=(230, 237, 246), outline=(0, 0, 0), width=2)
        center_text(draw, (cx, y, cx + widths[i], y + heights[0]), h, 20, True)
        cx += widths[i]
    cy = y + heights[0]
    for r, row in enumerate(rows):
        cx = x
        for i, cell in enumerate(row):
            fill = (255, 255, 255) if r % 2 == 0 else (248, 248, 248)
            draw.rectangle((cx, cy, cx + widths[i], cy + heights[r + 1]), fill=fill, outline=(0, 0, 0), width=2)
            center_text(draw, (cx + 8, cy, cx + widths[i] - 8, cy + heights[r + 1]), cell, 18, i in (0, 1))
            cx += widths[i]
        cy += heights[r + 1]

    draw.rounded_rectangle((70, 450, 1410, 505), radius=8, fill=(255, 255, 238), outline=(120, 120, 120), width=2)
    draw.text((90, 465), "Итого: 4-way set-associative cache, 16 наборов, в каждом наборе 4 way.", font=font(20, True), fill=(0, 0, 0))

    OUT_IMG.mkdir(parents=True, exist_ok=True)
    OUT_GFX.mkdir(parents=True, exist_ok=True)
    png = OUT_IMG / "cache_address_split_table.png"
    pdf = OUT_GFX / "Рисунок_кэш_разбиение_адреса.pdf"
    img.save(png)
    img.save(pdf, "PDF", resolution=180.0)


def main() -> None:
    generate_fsm()
    generate_addr_table()
    print(OUT_IMG / "cache_control_fsm.png")
    print(OUT_IMG / "cache_address_split_table.png")
    print(OUT_GFX / "Рисунок_кэш_автомат_управления.pdf")
    print(OUT_GFX / "Рисунок_кэш_разбиение_адреса.pdf")


if __name__ == "__main__":
    main()
