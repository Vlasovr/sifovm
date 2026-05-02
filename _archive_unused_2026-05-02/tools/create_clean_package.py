from __future__ import annotations

from datetime import date
from pathlib import Path
import shutil


ROOT = Path(__file__).resolve().parents[1]
SOURCE_PROJECT = ROOT / "variant4_coursework_project"
TARGET_PROJECT = ROOT / "coursework_project"


NAME_REPLACEMENTS = {
    "variant4_pkg": "microcomputer_pkg",
    "alu_variant4": "alu_core",
    "branch_predictor_a4": "branch_predictor",
    "cache4way_age": "cache_4way_age",
    "cpu_core_variant4": "cpu_core",
    "system_variant4_top": "system_core",
    "tb_alu_variant4": "tb_alu_core",
    "tb_system_variant4": "tb_system",
}

VHDL_FILE_MAP = {
    "variant4_pkg.vhd": "microcomputer_pkg.vhd",
    "alu_variant4.vhd": "alu_core.vhd",
    "branch_predictor_a4.vhd": "branch_predictor.vhd",
    "cache4way_age.vhd": "cache_4way_age.vhd",
    "cpu_core_variant4.vhd": "cpu_core.vhd",
    "system_variant4_top.vhd": "system_core.vhd",
    "tb_alu_variant4.vhd": "tb_alu_core.vhd",
    "tb_system_variant4.vhd": "tb_system.vhd",
}

MEMORY_FILE_MAP = {
    "rom_variant4.mif": "rom_program.mif",
    "ram_variant4_initial.mif": "ram_initial.mif",
    "ram_variant4_expected_after_hlt.mif": "ram_expected_after_hlt.mif",
}

PDF_FILE_MAP = {
    "A1_general_structure.pdf": "Лист_А1_Общая_структурная_схема.pdf",
    "A2_control_unit.pdf": "Лист_А2_Устройство_управления.pdf",
    "A3_datapath_alu_stack.pdf": "Лист_А3_Исполнительный_тракт.pdf",
    "A4_memory_dma_arbiter.pdf": "Лист_А4_Память_DMA_КПДП_арбитр.pdf",
    "A1_expanded_cpu_core.pdf": "Доп_лист_1_Процессорное_ядро.pdf",
    "A1_control_signals.pdf": "Доп_лист_2_Сигналы_управления.pdf",
    "A3_instruction_register_pc.pdf": "Доп_лист_3_Тракт_PC_IR.pdf",
    "A3_register_file_12x16.pdf": "Доп_лист_4_Регистровый_файл.pdf",
    "A3_alu_flags.pdf": "Доп_лист_5_АЛУ_и_флаги.pdf",
    "A3_stack7x16.pdf": "Доп_лист_6_Стек.pdf",
    "A4_rom_command_memory.pdf": "Доп_лист_7_ПЗУ_команд.pdf",
    "A4_ram_data_memory.pdf": "Доп_лист_8_ОЗУ_данных.pdf",
    "A4_cache_4way.pdf": "Доп_лист_9_Кэш_данных.pdf",
    "A4_dma_controller.pdf": "Доп_лист_10_КПДП.pdf",
    "A4_bus_arbiter.pdf": "Доп_лист_11_Арбитр_шины.pdf",
    "A4_branch_predictor_a4.pdf": "Доп_лист_12_Предсказатель_A4.pdf",
}


def normalize_vhdl(text: str) -> str:
    for old, new in NAME_REPLACEMENTS.items():
        text = text.replace(old, new)
    return text


def normalize_markdown(text: str) -> str:
    replacements = {
        "варианта 4": "индивидуального задания",
        "варианту 4": "индивидуальному заданию",
        "вариант 4": "индивидуальное задание",
        "Вариант 4": "Индивидуальное задание",
        "variant4_coursework_project": "coursework_project",
        "variant4_coursework": "coursework",
        "variant4": "coursework",
        "tb_system_variant4": "tb_system",
        "system_variant4_top": "microcomputer_top",
    }
    for old, new in replacements.items():
        text = text.replace(old, new)
    return text


def copy_vhdl() -> None:
    for source_dir_name in ("src", "tb"):
        for source in (SOURCE_PROJECT / source_dir_name).glob("*.vhd"):
            text = normalize_vhdl(source.read_text(encoding="utf-8"))
            if source.name == "tb_system_variant4.vhd":
                text = adapt_system_testbench(text)
            target_name = VHDL_FILE_MAP.get(source.name, source.name)
            (TARGET_PROJECT / source_dir_name / target_name).write_text(
                text, encoding="utf-8", newline="\n"
            )

    (TARGET_PROJECT / "src" / "microcomputer_top.vhd").write_text(
        MICROCOMPUTER_TOP, encoding="utf-8", newline="\n"
    )


def adapt_system_testbench(text: str) -> str:
    mapping = {
        "UUT : entity work.system_core": "UUT : entity work.microcomputer_top",
        "clk_i            => clk,": "CLK              => clk,",
        "rst_i            => rst,": "RESET            => rst,",
        "dma_start_i      => dma_start,": "DMA_START        => dma_start,",
        "dma_valid_i      => dma_valid,": "DMA_VALID        => dma_valid,",
        "dma_data_i       => dma_data,": "DMA_DATA         => dma_data,",
        "halt_o           => halt,": "HALT             => halt,",
        "dma_done_o       => dma_done,": "DMA_DONE         => dma_done,",
        "dbg_state_o      => dbg_state,": "STATE            => dbg_state,",
        "dbg_pc_o         => dbg_pc,": "PC               => dbg_pc,",
        "dbg_ir0_o        => dbg_ir0,": "IR0              => dbg_ir0,",
        "dbg_ir1_o        => dbg_ir1,": "IR1              => dbg_ir1,",
        "dbg_r1_o         => dbg_r1,": "R1               => dbg_r1,",
        "dbg_r2_o         => dbg_r2,": "R2               => dbg_r2,",
        "dbg_r3_o         => dbg_r3,": "R3               => dbg_r3,",
        "dbg_r4_o         => dbg_r4,": "R4               => dbg_r4,",
        "dbg_r5_o         => dbg_r5,": "R5               => dbg_r5,",
        "dbg_r6_o         => dbg_r6,": "R6               => dbg_r6,",
        "dbg_r7_o         => dbg_r7,": "R7               => dbg_r7,",
        "dbg_flags_o      => dbg_flags,": "FLAGS            => dbg_flags,",
        "dbg_sp_o         => dbg_sp,": "SP               => dbg_sp,",
        "dbg_cache_hit_o  => cache_hit,": "CACHE_HIT        => cache_hit,",
        "dbg_cache_miss_o => cache_miss,": "CACHE_MISS       => cache_miss,",
        "dbg_req_cpu_o    => req_cpu,": "REQ_CPU          => req_cpu,",
        "dbg_req_dma_o    => req_dma,": "REQ_DMA          => req_dma,",
        "dbg_gnt_cpu_o    => gnt_cpu,": "GNT_CPU          => gnt_cpu,",
        "dbg_gnt_dma_o    => gnt_dma,": "GNT_DMA          => gnt_dma,",
        "dbg_ram_we_o     => ram_we,": "RAM_WRITE        => ram_we,",
        "dbg_ram_addr_o   => ram_addr,": "RAM_ADDRESS      => ram_addr,",
        "dbg_ram_wdata_o  => ram_wdata,": "RAM_WRITE_DATA   => ram_wdata,",
        "dbg_ram_rdata_o  => ram_rdata,": "RAM_READ_DATA    => ram_rdata,",
        "dbg_bp_hist_o    => bp_hist,": "BRANCH_HISTORY   => bp_hist,",
        "dbg_bp_pred_o    => bp_pred,": "BRANCH_PREDICT   => bp_pred,",
        "dbg_bp_target_o  => bp_target": "BRANCH_TARGET    => bp_target",
    }
    for old, new in mapping.items():
        text = text.replace(old, new)
    return text


MICROCOMPUTER_TOP = """library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity microcomputer_top is
  port (
    CLK              : in  std_logic;
    RESET            : in  std_logic;
    DMA_START        : in  std_logic;
    DMA_VALID        : in  std_logic;
    DMA_DATA         : in  word_t;

    HALT             : out std_logic;
    DMA_DONE         : out std_logic;

    STATE            : out std_logic_vector(4 downto 0);
    PC               : out addr_t;
    IR0              : out word_t;
    IR1              : out word_t;
    R1               : out word_t;
    R2               : out word_t;
    R3               : out word_t;
    R4               : out word_t;
    R5               : out word_t;
    R6               : out word_t;
    R7               : out word_t;
    FLAGS            : out std_logic_vector(3 downto 0);
    SP               : out unsigned(2 downto 0);

    CACHE_HIT        : out std_logic;
    CACHE_MISS       : out std_logic;
    REQ_CPU          : out std_logic;
    REQ_DMA          : out std_logic;
    GNT_CPU          : out std_logic;
    GNT_DMA          : out std_logic;
    RAM_WRITE        : out std_logic;
    RAM_ADDRESS      : out addr_t;
    RAM_WRITE_DATA   : out word_t;
    RAM_READ_DATA    : out word_t;
    BRANCH_HISTORY   : out std_logic_vector(1 downto 0);
    BRANCH_PREDICT   : out std_logic;
    BRANCH_TARGET    : out addr_t
  );
end entity;

architecture structural of microcomputer_top is
begin
  U_SYSTEM : entity work.system_core
    port map (
      clk_i            => CLK,
      rst_i            => RESET,
      dma_start_i      => DMA_START,
      dma_valid_i      => DMA_VALID,
      dma_data_i       => DMA_DATA,
      halt_o           => HALT,
      dma_done_o       => DMA_DONE,
      dbg_state_o      => STATE,
      dbg_pc_o         => PC,
      dbg_ir0_o        => IR0,
      dbg_ir1_o        => IR1,
      dbg_r1_o         => R1,
      dbg_r2_o         => R2,
      dbg_r3_o         => R3,
      dbg_r4_o         => R4,
      dbg_r5_o         => R5,
      dbg_r6_o         => R6,
      dbg_r7_o         => R7,
      dbg_flags_o      => FLAGS,
      dbg_sp_o         => SP,
      dbg_cache_hit_o  => CACHE_HIT,
      dbg_cache_miss_o => CACHE_MISS,
      dbg_req_cpu_o    => REQ_CPU,
      dbg_req_dma_o    => REQ_DMA,
      dbg_gnt_cpu_o    => GNT_CPU,
      dbg_gnt_dma_o    => GNT_DMA,
      dbg_ram_we_o     => RAM_WRITE,
      dbg_ram_addr_o   => RAM_ADDRESS,
      dbg_ram_wdata_o  => RAM_WRITE_DATA,
      dbg_ram_rdata_o  => RAM_READ_DATA,
      dbg_bp_hist_o    => BRANCH_HISTORY,
      dbg_bp_pred_o    => BRANCH_PREDICT,
      dbg_bp_target_o  => BRANCH_TARGET
    );
end architecture;
"""


def copy_memory() -> None:
    for source in (SOURCE_PROJECT / "memory").glob("*.mif"):
        target_name = MEMORY_FILE_MAP.get(source.name, source.name)
        shutil.copy2(source, TARGET_PROJECT / "memory" / target_name)


def copy_docs_and_schemes() -> None:
    for source in (SOURCE_PROJECT / "docs").glob("*.md"):
        target = TARGET_PROJECT / "docs" / source.name
        target.write_text(
            normalize_markdown(source.read_text(encoding="utf-8")),
            encoding="utf-8",
            newline="\n",
        )

    for source in (SOURCE_PROJECT / "schemes").glob("*.drawio"):
        text = source.read_text(encoding="utf-8")
        text = text.replace(
            "Курсовой проект СиФО ЭВМ&lt;br&gt;Вариант 4&lt;br&gt;",
            "Курсовой проект СиФО ЭВМ&lt;br&gt;",
        )
        shutil.copy2(source, TARGET_PROJECT / "schemes" / source.name)
        (TARGET_PROJECT / "schemes" / source.name).write_text(
            text, encoding="utf-8", newline="\n"
        )

    for source in (SOURCE_PROJECT / "schemes" / "pdf").glob("*.pdf"):
        target_name = PDF_FILE_MAP.get(source.name, source.name)
        shutil.copy2(source, TARGET_PROJECT / "documents" / "graphics" / target_name)


def copy_tools() -> None:
    for source in (SOURCE_PROJECT / "tools").glob("*.py"):
        text = source.read_text(encoding="utf-8")
        text = text.replace("variant4_coursework_project", "coursework_project")
        text = text.replace("variant4_coursework", "coursework")
        text = text.replace("variant 4", "individual task")
        text = text.replace("Variant 4", "Individual task")
        text = text.replace(
            'FONT_PATH = Path("/System/Library/Fonts/Supplemental/Arial.ttf")',
            'FONT_PATH = Path(r"C:/Windows/Fonts/arial.ttf")',
        )
        text = text.replace(
            'BOLD_FONT_PATH = Path("/System/Library/Fonts/Supplemental/Arial Bold.ttf")',
            'BOLD_FONT_PATH = Path(r"C:/Windows/Fonts/arialbd.ttf")',
        )
        text = text.replace("Вариант 4\\n", "")
        text = text.replace("Вариант 4", "Индивидуальное задание")
        text = text.replace("вариант 4", "индивидуальное задание")
        text = text.replace("Параметры варианта", "Параметры узла")
        (TARGET_PROJECT / "tools" / source.name).write_text(
            text, encoding="utf-8", newline="\n"
        )


def write_quartus_project() -> None:
    qpf = f"""QUARTUS_VERSION = "9.1"
DATE = "{date.today().strftime('%B %d, %Y')}"

PROJECT_REVISION = "coursework"
"""
    (TARGET_PROJECT / "quartus" / "coursework.qpf").write_text(
        qpf, encoding="ascii", newline="\n"
    )

    vhdl_order = [
        "microcomputer_pkg.vhd",
        "program_image_pkg.vhd",
        "data_image_pkg.vhd",
        "alu_core.vhd",
        "reg_file12x16.vhd",
        "reg_file12x16_dbg.vhd",
        "flags_reg.vhd",
        "stack7x16.vhd",
        "rom_sync.vhd",
        "ram_sync.vhd",
        "bus_arbiter_2master.vhd",
        "dma_controller_3word.vhd",
        "branch_predictor.vhd",
        "cache_4way_age.vhd",
        "cpu_core.vhd",
        "system_core.vhd",
        "microcomputer_top.vhd",
    ]
    ports = [
        "CLK",
        "RESET",
        "DMA_START",
        "DMA_VALID",
        "DMA_DATA[*]",
        "HALT",
        "DMA_DONE",
        "STATE[*]",
        "PC[*]",
        "IR0[*]",
        "IR1[*]",
        "R1[*]",
        "R2[*]",
        "R3[*]",
        "R4[*]",
        "R5[*]",
        "R6[*]",
        "R7[*]",
        "FLAGS[*]",
        "SP[*]",
        "CACHE_HIT",
        "CACHE_MISS",
        "REQ_CPU",
        "REQ_DMA",
        "GNT_CPU",
        "GNT_DMA",
        "RAM_WRITE",
        "RAM_ADDRESS[*]",
        "RAM_WRITE_DATA[*]",
        "RAM_READ_DATA[*]",
        "BRANCH_HISTORY[*]",
        "BRANCH_PREDICT",
        "BRANCH_TARGET[*]",
    ]
    qsf_lines = [
        "set_global_assignment -name DEVICE AUTO",
        'set_global_assignment -name TOP_LEVEL_ENTITY microcomputer_top',
        'set_global_assignment -name FAMILY "Cyclone II"',
        'set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"',
        "",
    ]
    qsf_lines.extend(
        f"set_global_assignment -name VHDL_FILE ../src/{name}" for name in vhdl_order
    )
    qsf_lines.extend(
        [
            "",
            "set_global_assignment -name MISC_FILE ../memory/rom_program.mif",
            "set_global_assignment -name MISC_FILE ../memory/ram_initial.mif",
            "set_global_assignment -name MISC_FILE ../memory/ram_expected_after_hlt.mif",
            "",
        ]
    )
    qsf_lines.extend(f"set_instance_assignment -name VIRTUAL_PIN ON -to {p}" for p in ports)
    qsf_lines.append("")
    (TARGET_PROJECT / "quartus" / "coursework.qsf").write_text(
        "\n".join(qsf_lines), encoding="ascii", newline="\n"
    )


def write_modelsim_script() -> None:
    run_do = """vlib work
vmap work work

vcom ../src/microcomputer_pkg.vhd
vcom ../src/program_image_pkg.vhd
vcom ../src/data_image_pkg.vhd
vcom ../src/alu_core.vhd
vcom ../src/reg_file12x16.vhd
vcom ../src/reg_file12x16_dbg.vhd
vcom ../src/flags_reg.vhd
vcom ../src/stack7x16.vhd
vcom ../src/rom_sync.vhd
vcom ../src/ram_sync.vhd
vcom ../src/bus_arbiter_2master.vhd
vcom ../src/dma_controller_3word.vhd
vcom ../src/branch_predictor.vhd
vcom ../src/cache_4way_age.vhd
vcom ../src/cpu_core.vhd
vcom ../src/system_core.vhd
vcom ../src/microcomputer_top.vhd
vcom ../tb/tb_system.vhd

vsim work.tb_system
add wave -radix hexadecimal sim:/tb_system/clk
add wave -radix hexadecimal sim:/tb_system/rst
add wave -radix hexadecimal sim:/tb_system/halt
add wave -radix hexadecimal sim:/tb_system/dma_start
add wave -radix hexadecimal sim:/tb_system/dma_valid
add wave -radix hexadecimal sim:/tb_system/dma_data
add wave -radix hexadecimal sim:/tb_system/dma_done
add wave -radix hexadecimal sim:/tb_system/dbg_state
add wave -radix hexadecimal sim:/tb_system/dbg_pc
add wave -radix hexadecimal sim:/tb_system/dbg_ir0
add wave -radix hexadecimal sim:/tb_system/dbg_ir1
add wave -radix hexadecimal sim:/tb_system/dbg_r1
add wave -radix hexadecimal sim:/tb_system/dbg_r2
add wave -radix hexadecimal sim:/tb_system/dbg_r3
add wave -radix hexadecimal sim:/tb_system/dbg_r4
add wave -radix hexadecimal sim:/tb_system/dbg_r5
add wave -radix hexadecimal sim:/tb_system/dbg_r6
add wave -radix hexadecimal sim:/tb_system/dbg_r7
add wave -radix hexadecimal sim:/tb_system/dbg_flags
add wave -radix unsigned sim:/tb_system/dbg_sp
add wave -radix hexadecimal sim:/tb_system/cache_hit
add wave -radix hexadecimal sim:/tb_system/cache_miss
add wave -radix hexadecimal sim:/tb_system/req_cpu
add wave -radix hexadecimal sim:/tb_system/req_dma
add wave -radix hexadecimal sim:/tb_system/gnt_cpu
add wave -radix hexadecimal sim:/tb_system/gnt_dma
add wave -radix hexadecimal sim:/tb_system/ram_we
add wave -radix hexadecimal sim:/tb_system/ram_addr
add wave -radix hexadecimal sim:/tb_system/ram_wdata
add wave -radix hexadecimal sim:/tb_system/ram_rdata
add wave -radix binary sim:/tb_system/bp_hist
add wave -radix hexadecimal sim:/tb_system/bp_pred
add wave -radix hexadecimal sim:/tb_system/bp_target

run 5 us
"""
    (TARGET_PROJECT / "quartus" / "run_tb_system.do").write_text(
        run_do, encoding="ascii", newline="\n"
    )


def write_readme() -> None:
    readme = """# Курсовой проект по СиФО ЭВМ

Чистый комплект проекта без упоминания номера индивидуального задания в именах файлов.

## Основные точки входа

- `quartus/coursework.qpf` - проект Quartus II 9.1.
- `src/microcomputer_top.vhd` - верхний модуль с пользовательскими портами.
- `src/system_core.vhd` - структурное ядро микро-ЭВМ.
- `tb/tb_system.vhd` - полный тест системы.
- `documents/Пояснительная_записка.docx` - итоговая записка.
- `documents/Приложение_А_Графическая_часть.docx` - графические листы.
- `documents/Приложение_Б_Листинг_и_дампы.docx` - программа, MIF и дампы памяти.
- `documents/Приложение_В_VHDL_листинги.docx` - листинги VHDL.
- `documents/Приложение_Г_Тестирование.docx` - материалы тестирования и временные диаграммы.
"""
    (TARGET_PROJECT / "README.md").write_text(readme, encoding="utf-8", newline="\n")


def create_directories() -> None:
    for subdir in [
        "src",
        "tb",
        "memory",
        "quartus",
        "docs",
        "schemes",
        "schemes/pdf",
        "tools",
        "documents",
        "documents/graphics",
        "documents/images",
        "sim/ghdl",
    ]:
        (TARGET_PROJECT / subdir).mkdir(parents=True, exist_ok=True)


def main() -> None:
    if not SOURCE_PROJECT.exists():
        raise SystemExit(f"Source project not found: {SOURCE_PROJECT}")
    if TARGET_PROJECT.exists():
        raise SystemExit(f"Target project already exists: {TARGET_PROJECT}")

    create_directories()
    copy_vhdl()
    copy_memory()
    copy_docs_and_schemes()
    copy_tools()
    write_quartus_project()
    write_modelsim_script()
    write_readme()
    print(TARGET_PROJECT)


if __name__ == "__main__":
    main()
