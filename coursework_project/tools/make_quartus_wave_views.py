from pathlib import Path


BASE = Path(r"D:\git\sifovm\coursework_project\quartus\system_wave.vwf")
OUT_DIR = BASE.parent


VIEWS = {
    "system_memory_wave.vwf": [
        ("CLK", "Binary"),
        ("RESET", "Binary"),
        ("DMA_START", "Binary"),
        ("DMA_VALID", "Binary"),
        ("DMA_DATA", "Hexadecimal"),
        ("DBG_REQ_DMA", "Binary"),
        ("DBG_GNT_DMA", "Binary"),
        ("DBG_REQ_CPU", "Binary"),
        ("DBG_GNT_CPU", "Binary"),
        ("DBG_RAM_WE", "Binary"),
        ("DBG_RAM_ADDR", "Hexadecimal"),
        ("DBG_RAM_WDATA", "Hexadecimal"),
        ("DBG_RAM_RDATA", "Hexadecimal"),
        ("DBG_CACHE_HIT", "Binary"),
        ("DBG_CACHE_MISS", "Binary"),
        ("DMA_DONE", "Binary"),
        ("HALT", "Binary"),
    ],
    "system_control_wave.vwf": [
        ("CLK", "Binary"),
        ("RESET", "Binary"),
        ("DBG_STATE", "Binary"),
        ("DBG_PC", "Hexadecimal"),
        ("DBG_IR0", "Hexadecimal"),
        ("DBG_IR1", "Hexadecimal"),
        ("DBG_R1", "Hexadecimal"),
        ("DBG_R2", "Hexadecimal"),
        ("DBG_R3", "Hexadecimal"),
        ("DBG_R4", "Hexadecimal"),
        ("DBG_R7", "Hexadecimal"),
        ("DBG_FLAGS", "Binary"),
        ("DBG_SP", "Hexadecimal"),
        ("DBG_BP_HIST", "Binary"),
        ("DBG_BP_PRED", "Binary"),
        ("DBG_BP_TARGET", "Hexadecimal"),
        ("HALT", "Binary"),
    ],
}

WIDTHS = {
    "DMA_DATA": 16,
    "DBG_STATE": 5,
    "DBG_PC": 16,
    "DBG_IR0": 16,
    "DBG_IR1": 16,
    "DBG_R1": 16,
    "DBG_R2": 16,
    "DBG_R3": 16,
    "DBG_R4": 16,
    "DBG_R7": 16,
    "DBG_FLAGS": 4,
    "DBG_SP": 3,
    "DBG_RAM_ADDR": 16,
    "DBG_RAM_WDATA": 16,
    "DBG_RAM_RDATA": 16,
    "DBG_BP_HIST": 2,
    "DBG_BP_TARGET": 16,
}


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


def main() -> None:
    text = BASE.read_text(encoding="utf-8")
    pos = text.find("DISPLAY_LINE")
    if pos == -1:
        raise RuntimeError("DISPLAY_LINE section not found")
    prefix = text[:pos]
    for filename, display in VIEWS.items():
        out = OUT_DIR / filename
        blocks = []
        index = 0
        for name, radix in display:
            blocks.append(display_block(name, radix, index))
            index += 1
            if name in WIDTHS:
                for bit in range(WIDTHS[name] - 1, -1, -1):
                    blocks.append(display_block(f"{name}[{bit}]", radix, index, level=1))
                    index += 1
        view_text = prefix + "".join(blocks)
        out.write_text(view_text, encoding="utf-8", newline="\r\n")


if __name__ == "__main__":
    main()
