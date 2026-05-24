from pathlib import Path

END_NS = 3500.0

PROJECT_DIR = Path(__file__).resolve().parents[1]
OUT_DIR = PROJECT_DIR / "wave_projects" / "section3_clean" / "quartus"

WIDTHS = {
    "dma_data": 16,
    "st": 5,
    "pc": 16,
    "ir0": 16,
    "ir1": 16,
    "op": 8,
    "regn": 4,
    "r1": 16,
    "r2": 16,
    "r3": 16,
    "r4": 16,
    "r5": 16,
    "r6": 16,
    "r7": 16,
    "flg": 4,
    "sp": 3,
    "rom_a": 16,
    "rom_d": 16,
    "c_a": 16,
    "c_wd": 16,
    "c_rd": 16,
    "bus_owner": 2,
    "ram_a": 16,
    "ram_wd": 16,
    "ram_rd": 16,
    "bp_hist": 2,
    "bp_tgt": 16,
}

INPUTS = ["clk", "rst", "dma_start", "dma_valid", "dma_data"]

FIGURES = {
    "fig_3_01_memory.vwf": [
        "clk", "rst", "st", "pc", "rom_en", "rom_a", "rom_d", "c_req",
        "c_we", "c_a", "c_rd", "ram_we", "ram_a", "ram_wd", "ram_rd",
    ],
    "fig_3_02_decoder.vwf": [
        "clk", "rst", "ir0", "op", "regn", "is_mr", "is_rm", "is_or",
        "is_nor", "is_sra", "is_incs", "is_push", "is_pop", "is_jmp",
        "is_jz", "is_hlt",
    ],
    "fig_3_03_phase_counter.vwf": [
        "clk", "rst", "st", "ph_f0", "ph_f1", "ph_dec", "ph_mem",
        "ph_alu", "ph_stk", "ph_br", "ph_fin", "halt",
    ],
    "fig_3_04_ip_ir.vwf": [
        "clk", "rst", "pc", "ir0", "ir1", "op", "regn", "is_jmp",
        "is_jz", "is_hlt", "halt",
    ],
    "fig_3_05_stack.vwf": [
        "clk", "rst", "st", "ir0", "is_push", "is_pop", "r1", "r3",
        "sp", "rf_we",
    ],
    "fig_3_06_registers.vwf": [
        "clk", "rst", "st", "ir0", "rf_we", "r1", "r2", "r3", "r4",
        "r5", "r6", "r7", "flg",
    ],
    "fig_3_07_alu.vwf": [
        "clk", "rst", "ir0", "op", "is_or", "is_nor", "is_sra",
        "is_incs", "r1", "r2", "r4", "flg", "rf_we",
    ],
    "fig_3_08_cache.vwf": [
        "clk", "rst", "c_req", "c_we", "c_a", "c_wd", "c_rd", "c_rdy",
        "c_hit", "c_miss", "req_cpu", "gnt_cpu", "ram_we", "ram_a",
        "ram_rd",
    ],
    "fig_3_09_branch_predictor.vwf": [
        "clk", "rst", "pc", "ir0", "ir1", "flg", "is_jz", "is_jmp",
        "bp_hist", "bp_pred", "bp_tgt", "halt",
    ],
    "fig_3_10_dma_controller.vwf": [
        "clk", "rst", "dma_start", "dma_valid", "dma_data", "req_dma",
        "gnt_dma", "ram_we", "ram_a", "ram_wd", "dma_done",
    ],
    "fig_3_11_bus_arbiter.vwf": [
        "clk", "rst", "req_cpu", "req_dma", "gnt_cpu", "gnt_dma",
        "bus_owner", "ram_we", "ram_a", "ram_wd", "ram_rd",
    ],
    "fig_3_12_full_microevm.vwf": [
        "clk", "rst", "dma_start", "dma_valid", "dma_data", "st", "pc",
        "ir0", "ir1", "r1", "r2", "r3", "r4", "r5", "r6", "r7",
        "flg", "sp", "c_hit", "c_miss", "req_cpu", "req_dma", "gnt_cpu",
        "gnt_dma", "ram_we", "ram_a", "dma_done", "halt",
    ],
}


def is_bus(name: str) -> bool:
    return WIDTHS.get(name, 1) > 1


def direction(name: str) -> str:
    return "INPUT" if name in INPUTS else "OUTPUT"


def signal_block(name: str) -> str:
    w = WIDTHS.get(name, 1)
    if w == 1:
        return f'''SIGNAL("{name}")
{{
\tVALUE_TYPE = NINE_LEVEL_BIT;
\tSIGNAL_TYPE = SINGLE_BIT;
\tWIDTH = 1;
\tLSB_INDEX = -1;
\tDIRECTION = {direction(name)};
\tPARENT = "";
}}

'''
    parts = [f'''SIGNAL("{name}")
{{
\tVALUE_TYPE = NINE_LEVEL_BIT;
\tSIGNAL_TYPE = BUS;
\tWIDTH = {w};
\tLSB_INDEX = 0;
\tDIRECTION = {direction(name)};
\tPARENT = "";
}}

''']
    for bit in range(w - 1, -1, -1):
        parts.append(f'''SIGNAL("{name}[{bit}]")
{{
\tVALUE_TYPE = NINE_LEVEL_BIT;
\tSIGNAL_TYPE = SINGLE_BIT;
\tWIDTH = 1;
\tLSB_INDEX = -1;
\tDIRECTION = {direction(name)};
\tPARENT = "{name}";
}}

''')
    return "".join(parts)


def intervals_to_levels(intervals):
    body = ["\tNODE", "\t{", "\t\tREPEAT = 1;"]
    for level, duration in intervals:
        if duration > 0:
            body.append(f"\t\tLEVEL {level} FOR {duration:.1f};")
    body.extend(["\t}", "}"])
    return "\n".join(body) + "\n\n"


def bit_intervals_from_words(words, bit):
    intervals = []
    for value, duration in words:
        intervals.append(("1" if ((value >> bit) & 1) else "0", duration))
    return intervals


def transition_block(name: str) -> str:
    if name == "clk":
        repeat = int(END_NS / 10.0)
        payload = f'''\tNODE
\t{{
\t\tREPEAT = {repeat};
\t\tLEVEL 0 FOR 5.0;
\t\tLEVEL 1 FOR 5.0;
\t}}
}}

'''
        return f'TRANSITION_LIST("{name}")\n{{\n{payload}'
    if name == "rst":
        payload = intervals_to_levels([("1", 30.0), ("0", END_NS - 30.0)])
        return f'TRANSITION_LIST("{name}")\n{{\n{payload}'
    if name == "dma_start":
        payload = intervals_to_levels([("0", 100.0), ("1", 20.0), ("0", END_NS - 120.0)])
        return f'TRANSITION_LIST("{name}")\n{{\n{payload}'
    if name == "dma_valid":
        payload = intervals_to_levels([("0", 140.0), ("1", 80.0), ("0", END_NS - 220.0)])
        return f'TRANSITION_LIST("{name}")\n{{\n{payload}'

    w = WIDTHS.get(name, 1)
    if name == "dma_data":
        words = [(0x0000, 140.0), (0x1111, 20.0), (0x2222, 20.0), (0x3333, 40.0), (0x0000, END_NS - 220.0)]
        parts = []
        for bit in range(w - 1, -1, -1):
            payload = intervals_to_levels(bit_intervals_from_words(words, bit))
            parts.append(f'TRANSITION_LIST("{name}[{bit}]")\n{{\n{payload}')
        return "".join(parts)

    if w == 1:
        payload = intervals_to_levels([("X", END_NS)])
        return f'TRANSITION_LIST("{name}")\n{{\n{payload}'

    parts = []
    for bit in range(w - 1, -1, -1):
        payload = intervals_to_levels([("X", END_NS)])
        parts.append(f'TRANSITION_LIST("{name}[{bit}]")\n{{\n{payload}')
    return "".join(parts)


def display_lines(visible):
    lines = []
    tree_index = 0
    for name in visible:
        w = WIDTHS.get(name, 1)
        if w == 1:
            lines.append(f'''DISPLAY_LINE
{{
\tCHANNEL = "{name}";
\tEXPAND_STATUS = COLLAPSED;
\tRADIX = ASCII;
\tTREE_INDEX = {tree_index};
\tTREE_LEVEL = 0;
}}

''')
            tree_index += 1
        else:
            children = list(range(tree_index + 1, tree_index + 1 + w))
            child_text = ", ".join(str(i) for i in children)
            lines.append(f'''DISPLAY_LINE
{{
\tCHANNEL = "{name}";
\tEXPAND_STATUS = COLLAPSED;
\tRADIX = Hexadecimal;
\tTREE_INDEX = {tree_index};
\tTREE_LEVEL = 0;
\tCHILDREN = {child_text};
}}

''')
            parent_index = tree_index
            tree_index += 1
            for bit in range(w - 1, -1, -1):
                lines.append(f'''DISPLAY_LINE
{{
\tCHANNEL = "{name}[{bit}]";
\tEXPAND_STATUS = COLLAPSED;
\tRADIX = ASCII;
\tTREE_INDEX = {tree_index};
\tTREE_LEVEL = 1;
\tPARENT = {parent_index};
}}

''')
                tree_index += 1
    return "".join(lines)


def make_vwf(visible):
    all_signals = []
    for name in INPUTS + visible:
        if name not in all_signals:
            all_signals.append(name)

    header = f'''/*
WARNING: Do NOT edit the input and output ports in this file in a text
editor if you plan to continue editing the waveform in Quartus.
*/

HEADER
{{
\tVERSION = 1;
\tTIME_UNIT = ns;
\tDATA_OFFSET = 0.0;
\tDATA_DURATION = {END_NS:.1f};
\tSIMULATION_TIME = 0.0;
\tGRID_PHASE = 0.0;
\tGRID_PERIOD = 10.0;
\tGRID_DUTY_CYCLE = 50;
}}

'''
    text = [header]
    for sig in all_signals:
        text.append(signal_block(sig))
    for sig in all_signals:
        text.append(transition_block(sig))
    text.append(display_lines(visible))
    text.append('TIME_BAR\n{\n\tTIME = 0;\n\tMASTER = TRUE;\n}\n;\n')
    return "".join(text)


def trim_display_lines(path: Path, visible):
    text = path.read_text(encoding="utf-8")
    marker = "DISPLAY_LINE\n{"
    time_marker = "TIME_BAR\n{"
    start = text.find(marker)
    end = text.find(time_marker)
    if start < 0 or end < 0 or end <= start:
        raise RuntimeError(f"Cannot locate display section in {path}")
    new_text = text[:start] + display_lines(visible) + text[end:]
    path.write_text(new_text, encoding="utf-8", newline="\n")


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for file_name, visible in FIGURES.items():
        path = OUT_DIR / file_name
        if path.exists():
            trim_display_lines(path, visible)
        else:
            path.write_text(make_vwf(visible), encoding="utf-8", newline="\n")
        shot_path = OUT_DIR / file_name.replace("fig_", "shot_", 1)
        shot_path.write_text(path.read_text(encoding="utf-8"), encoding="utf-8", newline="\n")
    print(f"Generated {len(FIGURES)} waveform files in {OUT_DIR}")


if __name__ == "__main__":
    main()
