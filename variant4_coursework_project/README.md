# СиФО ЭВМ - курсовой проект, вариант 4

Рабочий комплект микро-ЭВМ на ПЛИС для варианта 4. В каталоге собраны VHDL,
testbench, MIF-образы памяти, схемы, пояснительная записка и инструкции для
снятия временных диаграмм.

## Коротко о варианте

| Узел | Параметры |
|---|---|
| Архитектура | Гарвардская, раздельные пространства команд и данных |
| Разрядность | адрес `16` бит, данные `16` бит |
| Память | синхронные ROM и RAM |
| РОН | `12 x 16` |
| АЛУ | `INCS`, `OR`, `NOR`, `SRA` |
| Стек | глубина `7`, рост вниз |
| Кэш | `4-way`, замещение по максимальному возрасту строки |
| Запись кэша | сквозная запись в RAM |
| Предсказатель | A4, индекс `PC(2) || GHR(2)` |
| КПДП | старт `000Ah`, объём `6` байт, то есть `3` слова |
| Арбитр | централизованный параллельный, приоритет DMA |

## Где что лежит

| Папка | Содержимое |
|---|---|
| [`src`](src/) | VHDL-исходники всех блоков и top-level |
| [`tb`](tb/) | testbench для АЛУ, стека, DMA и полной системы |
| [`memory`](memory/) | ROM/RAM MIF и ожидаемый RAM dump после `HLT` |
| [`quartus`](quartus/) | каркас Quartus-проекта и `.do` для ModelSim |
| [`schemes`](schemes/) | четыре редактируемых листа `.drawio` и 16 PDF-листов |
| [`docs`](docs/) | спецификация, сигналы, листинг, сценарии проверки |
| [`report`](report/) | исправленная пояснительная записка |
| [`tools`](tools/) | вспомогательные скрипты для подготовки документов |

## Главные файлы

| Файл | Зачем нужен |
|---|---|
| [`src/system_variant4_top.vhd`](src/system_variant4_top.vhd) | верхний модуль полной системы |
| [`src/cpu_core_variant4.vhd`](src/cpu_core_variant4.vhd) | процессорное ядро и автомат выполнения команд |
| [`tb/tb_system_variant4.vhd`](tb/tb_system_variant4.vhd) | сквозная проверка всей микро-ЭВМ |
| [`docs/SIGNALS.md`](docs/SIGNALS.md) | список сигналов для временных диаграмм |
| [`docs/PROGRAM_LISTING.md`](docs/PROGRAM_LISTING.md) | программа в symbolic, hex и binary |
| [`docs/QUARTUS_MODELSIM_RUNBOOK.md`](docs/QUARTUS_MODELSIM_RUNBOOK.md) | пошаговый запуск в Quartus/ModelSim |
| [`report/Записка_Власов_вариант4_исправленная.docx`](report/Записка_Власов_вариант4_исправленная.docx) | актуальная пояснительная записка |

## Быстрый запуск в ModelSim

Открыть проект из [`quartus/variant4_coursework.qpf`](quartus/variant4_coursework.qpf)
и выполнить:

```text
do run_tb_system_variant4.do
```

Ожидаемый результат в transcript:

```text
tb_system_variant4: TEST PASSED
```

## Проверка через GHDL

Если Quartus/ModelSim недоступен, функциональную логику можно проверить через
GHDL. Файлы компилируются в таком порядке:

```text
src/variant4_pkg.vhd
src/program_image_pkg.vhd
src/data_image_pkg.vhd
остальные файлы из src/
tb/tb_system_variant4.vhd
```

Проверенные testbench:

| Testbench | Что проверяет | Ожидаемый результат |
|---|---|---|
| `tb_alu_variant4` | `INCS`, `OR`, `NOR`, `SRA`, флаги | `TEST PASSED` |
| `tb_stack7x16` | `PUSH`, `POP`, `SP`, глубина 7 | `TEST PASSED` |
| `tb_mem_dma` | RAM, DMA, арбитр | `TEST PASSED` |
| `tb_system_variant4` | вся система и программа | `TEST PASSED` |

## Система команд

Команда занимает два 16-разрядных слова.

| Поле | Назначение |
|---|---|
| `word0[15:8]` | код операции |
| `word0[7:4]` | номер регистра `R0..R11` |
| `word0[3:0]` | резерв |
| `word1[15:0]` | адрес операнда или адрес перехода |

| Код | Команда | Действие |
|---|---|---|
| `00h` | `HLT` | останов |
| `01h` | `MOV adr, reg` | `M[adr] -> Rn` |
| `02h` | `MOV reg, adr` | `Rn -> M[adr]` |
| `03h` | `OR reg, adr` | `Rn := Rn OR M[adr]` |
| `04h` | `NOR reg, adr` | `Rn := NOT(Rn OR M[adr])` |
| `05h` | `SRA reg` | арифметический сдвиг вправо |
| `06h` | `INCS reg` | `Rn := Rn + S` |
| `07h` | `PUSH reg` | запись регистра в стек |
| `08h` | `POP reg` | чтение из стека в регистр |
| `09h` | `JMP adr` | безусловный переход |
| `0Ah` | `JZ adr` | переход при `Z = 1` |

## Что снимать на waveform

| Группа | Сигналы |
|---|---|
| Общие | `clk_i`, `rst_i`, `halt_o`, `dbg_state_o` |
| Команды | `dbg_pc_o`, `dbg_ir0_o`, `dbg_ir1_o` |
| РОН/АЛУ | `dbg_r1_o..dbg_r7_o`, `dbg_flags_o`, `ALU_OP`, `Y` |
| Память/кэш | `dbg_ram_addr_o`, `dbg_ram_wdata_o`, `dbg_ram_we_o`, `dbg_cache_hit_o`, `dbg_cache_miss_o` |
| Стек | `dbg_sp_o`, `push_i`, `pop_i`, `STK_DIN`, `STK_DOUT` |
| DMA/арбитр | `dma_start_i`, `dbg_req_dma_o`, `dbg_gnt_dma_o`, `dbg_req_cpu_o`, `dbg_gnt_cpu_o`, `dma_done_o` |
| Предсказатель | `dbg_bp_hist_o`, `dbg_bp_pred_o`, `dbg_bp_target_o` |

Полный список с пояснениями: [`docs/SIGNALS.md`](docs/SIGNALS.md).

## Контрольные значения после HLT

| Объект | Значение |
|---|---|
| `R1` | `C001h` |
| `R2` | `F000h` |
| `R3` | `C001h` |
| `R4` | `0000h` |
| `R5` | `0000h` |
| `R6` | `0000h` |
| `R7` | `1111h` |
| `FR` | `Z=1, S=0, C=0, O=0` |
| `SP` | `7` |
| `RAM[000A]` | `1111h` |
| `RAM[000B]` | `2222h` |
| `RAM[000C]` | `3333h` |
| `RAM[0030]` | `C001h` |

## Схемы

По заданию требуется графическая часть не менее четырёх листов А3. В комплекте
есть 4 обязательных листа и расширенный набор детальных листов по узлам.

| Лист | Редактируемый файл | PDF | Содержание |
|---|---|---|---|
| А1 | [`A1_general_structure.drawio`](schemes/A1_general_structure.drawio) | [`A1_general_structure.pdf`](schemes/pdf/A1_general_structure.pdf) | общая структура микро-ЭВМ |
| А2 | [`A2_control_unit.drawio`](schemes/A2_control_unit.drawio) | [`A2_control_unit.pdf`](schemes/pdf/A2_control_unit.pdf) | устройство управления |
| А3 | [`A3_datapath_alu_stack.drawio`](schemes/A3_datapath_alu_stack.drawio) | [`A3_datapath_alu_stack.pdf`](schemes/pdf/A3_datapath_alu_stack.pdf) | РОН, АЛУ, флаги, стек |
| А4 | [`A4_memory_dma_arbiter.drawio`](schemes/A4_memory_dma_arbiter.drawio) | [`A4_memory_dma_arbiter.pdf`](schemes/pdf/A4_memory_dma_arbiter.pdf) | память, кэш, DMA, арбитр, предсказатель |

Дополнительные PDF-листы:

| PDF | Содержание |
|---|---|
| [`A1_expanded_cpu_core.pdf`](schemes/pdf/A1_expanded_cpu_core.pdf) | расширенная схема процессорного ядра |
| [`A1_control_signals.pdf`](schemes/pdf/A1_control_signals.pdf) | входы и выходы устройства управления |
| [`A3_instruction_register_pc.pdf`](schemes/pdf/A3_instruction_register_pc.pdf) | тракт PC/IR и формат команды |
| [`A3_register_file_12x16.pdf`](schemes/pdf/A3_register_file_12x16.pdf) | регистровый файл 12 x 16 |
| [`A3_alu_flags.pdf`](schemes/pdf/A3_alu_flags.pdf) | АЛУ и регистр флагов |
| [`A3_stack7x16.pdf`](schemes/pdf/A3_stack7x16.pdf) | стек 7 x 16 |
| [`A4_rom_command_memory.pdf`](schemes/pdf/A4_rom_command_memory.pdf) | синхронное ПЗУ команд |
| [`A4_ram_data_memory.pdf`](schemes/pdf/A4_ram_data_memory.pdf) | синхронное ОЗУ данных |
| [`A4_cache_4way.pdf`](schemes/pdf/A4_cache_4way.pdf) | кэш 4-way |
| [`A4_dma_controller.pdf`](schemes/pdf/A4_dma_controller.pdf) | контроллер DMA/КПДП |
| [`A4_bus_arbiter.pdf`](schemes/pdf/A4_bus_arbiter.pdf) | централизованный параллельный арбитр |
| [`A4_branch_predictor_a4.pdf`](schemes/pdf/A4_branch_predictor_a4.pdf) | предсказатель переходов A4 |

PDF-листы уже экспортированы. Если правишь `.drawio`, пересобери PDF командой:

```text
/Users/Roman/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 tools/export_drawio_to_pdf.py
/Users/Roman/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3 tools/generate_detailed_scheme_pdfs.py
```

## Что осталось сделать руками

- Снять реальные временные диаграммы в Quartus/ModelSim.
- Снять дампы ROM/RAM/cache.
- Вставить реальные изображения в DOCX.
- Проверить финальный документ по [`docs/FINAL_CHECKLIST.md`](docs/FINAL_CHECKLIST.md).
