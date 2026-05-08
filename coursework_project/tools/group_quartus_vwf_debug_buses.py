from pathlib import Path
import re


VWF = Path(r"D:\git\sifovm\coursework_project\quartus\system_wave.vwf")

BUSES = {
    "DBG_STATE": (5, "Binary"),
    "DBG_PC": (16, "Hexadecimal"),
    "DBG_IR0": (16, "Hexadecimal"),
    "DBG_IR1": (16, "Hexadecimal"),
    "DBG_R1": (16, "Hexadecimal"),
    "DBG_R2": (16, "Hexadecimal"),
    "DBG_R3": (16, "Hexadecimal"),
    "DBG_R4": (16, "Hexadecimal"),
    "DBG_R5": (16, "Hexadecimal"),
    "DBG_R6": (16, "Hexadecimal"),
    "DBG_R7": (16, "Hexadecimal"),
    "DBG_FLAGS": (4, "Binary"),
    "DBG_SP": (3, "Hexadecimal"),
    "DBG_RAM_ADDR": (16, "Hexadecimal"),
    "DBG_RAM_WDATA": (16, "Hexadecimal"),
    "DBG_RAM_RDATA": (16, "Hexadecimal"),
    "DBG_BP_HIST": (2, "Binary"),
    "DBG_BP_TARGET": (16, "Hexadecimal"),
}

DISPLAY = [
    ("CLK", "Binary"),
    ("RESET", "Binary"),
    ("DMA_START", "Binary"),
    ("DMA_VALID", "Binary"),
    ("DMA_DATA", "Hexadecimal"),
    ("DBG_STATE", "Binary"),
    ("DBG_PC", "Hexadecimal"),
    ("DBG_IR0", "Hexadecimal"),
    ("DBG_IR1", "Hexadecimal"),
    ("DBG_R1", "Hexadecimal"),
    ("DBG_R2", "Hexadecimal"),
    ("DBG_R3", "Hexadecimal"),
    ("DBG_FLAGS", "Binary"),
    ("DBG_SP", "Hexadecimal"),
    ("DBG_CACHE_HIT", "Binary"),
    ("DBG_CACHE_MISS", "Binary"),
    ("DBG_REQ_CPU", "Binary"),
    ("DBG_REQ_DMA", "Binary"),
    ("DBG_GNT_CPU", "Binary"),
    ("DBG_GNT_DMA", "Binary"),
    ("DBG_RAM_WE", "Binary"),
    ("DBG_RAM_ADDR", "Hexadecimal"),
    ("DBG_RAM_WDATA", "Hexadecimal"),
    ("DBG_RAM_RDATA", "Hexadecimal"),
    ("DBG_BP_HIST", "Binary"),
    ("DBG_BP_PRED", "Binary"),
    ("DBG_BP_TARGET", "Hexadecimal"),
    ("HALT", "Binary"),
    ("DMA_DONE", "Binary"),
]


def bus_signal_block(name: str, width: int) -> str:
    return (
        f'SIGNAL("{name}")\n'
        "{\n"
        "\tVALUE_TYPE = NINE_LEVEL_BIT;\n"
        "\tSIGNAL_TYPE = BUS;\n"
        f"\tWIDTH = {width};\n"
        "\tLSB_INDEX = 0;\n"
        "\tDIRECTION = OUTPUT;\n"
        '\tPARENT = "";\n'
        "}\n\n"
    )


def display_block(name: str, radix: str, index: int, level: int = 0) -> str:
    return (
        "DISPLAY_LINE\n"
        "{\n"
        f'\tCHANNEL = "{name}";\n'
        "\tEXPAND_STATUS = COLLAPSED;\n"
        f"\tRADIX = {radix};\n"
        f"\tTREE_INDEX = {index};\n"
        f"\tTREE_LEVEL = {level};\n"
        "}\n\n"
    )


def set_parent_for_bit_blocks(text: str, bus: str) -> str:
    pattern = re.compile(
        rf'(SIGNAL\("{re.escape(bus)}\[(?:\d+)\]"\)\s*\{{.*?PARENT = )""(;.*?\}})',
        re.DOTALL,
    )
    return pattern.sub(rf'\1"{bus}"\2', text)


def main() -> None:
    text = VWF.read_text(encoding="utf-8")
    for name, (width, _radix) in BUSES.items():
        if f'SIGNAL("{name}")' not in text:
            first_bit = f'SIGNAL("{name}[0]")'
            pos = text.find(first_bit)
            if pos == -1:
                raise RuntimeError(f"Cannot find bit signals for {name}")
            text = text[:pos] + bus_signal_block(name, width) + text[pos:]
        text = set_parent_for_bit_blocks(text, name)

    display_pos = text.find("DISPLAY_LINE")
    if display_pos == -1:
        raise RuntimeError("Cannot find DISPLAY_LINE section")
    text = text[:display_pos]
    blocks = []
    index = 0
    for name, radix in DISPLAY:
        blocks.append(display_block(name, radix, index))
        index += 1
        width = BUSES.get(name, (16 if name == "DMA_DATA" else None, radix))[0]
        if width is not None:
            for bit in range(width - 1, -1, -1):
                blocks.append(display_block(f"{name}[{bit}]", radix, index, level=1))
                index += 1
    text += "".join(blocks)
    VWF.write_text(text, encoding="utf-8", newline="\r\n")


if __name__ == "__main__":
    main()
