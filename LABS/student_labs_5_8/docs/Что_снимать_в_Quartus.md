# Что снять руками в Quartus для ЛР5-8

Этот файл нужен, если преподаватель просит именно скриншоты из Quartus, а не только готовые схемы и GHDL/VCD. Все проекты уже компилируются; ниже указано, какие окна открыть и какие сигналы показать.

## Общий порядок

1. Открой `.qpf` нужной лабораторной:
   - ЛР5: `lab5_alu/quartus/lab5_alu.qpf`
   - ЛР6: `lab6_stack/quartus/lab6_stack.qpf`
   - ЛР7: `lab7_bus_arbiter/quartus/lab7_bus_arbiter.qpf`
   - ЛР8: `lab8_cache/quartus/lab8_cache.qpf`
2. Выполни `Processing -> Start Compilation`.
3. Сними скриншот успешной компиляции или окна `Compilation Report -> Flow Summary`.
4. Открой `Tools -> Netlist Viewers -> RTL Viewer` и сними скриншот верхнего уровня.
   В `.qsf` специально выбран верхний модуль `*_rtl_view_top`: это тонкая обертка над рабочей схемой, которая не меняет алгоритм, но выводит наружу пины с понятными именами. Поэтому на RTL-схеме сразу видно, где команда, операнды, флаги, запросы, гранты, память и диагностические линии.
5. Если нужен режим функционального моделирования в самом Quartus:
   - `Processing -> Simulator Tool`;
   - `Simulation mode: Functional`;
   - нажать `Generate Functional Simulation Netlist`;
   - создать `.vwf` через `File -> New -> Verification/Debugging Files -> Vector Waveform File`;
   - добавить пины через `Edit -> Insert -> Insert Node or Bus`.

Если преподаватель просит конкретное семейство ПЛИС, его можно выбрать вручную через `Assignments -> Device` и пересобрать проект. VHDL-описание не привязано к семействозависимым мегаблокам, поэтому логика устройства от этого не меняется.

## ЛР5. АЛУ

Окна/скриншоты:

- RTL Viewer верхнего модуля `lab5_alu_rtl_view_top`;
- внутри можно раскрыть рабочий структурный модуль `lab5_alu_top`;
- отдельно хорошо показать блоки `alu_control`, `alu_sra`, `alu_incs`;
- временная диаграмма операций.

Сигналы для VWF:

| Сигнал | Что показать |
|---|---|
| `cmd_opcode_alu_operation_i[7..0]` | `03h`, `04h`, `05h`, `06h` |
| `operand_a_from_register_i[15..0]` | `00F0`, `0FFF`, `8001`, `C000`, `1234`, `FFFF` |
| `operand_b_from_memory_or_reg_i[15..0]` | `0F0F`, `0FFF`, `FFFF` |
| `flag_s_from_flags_register_i` | `1` только для проверки `INCS` |
| `result_y_to_register_file_o[15..0]` | `0FFF`, `F000`, `C000`, `C001`, `1234`, `0000` |
| `flag_z_zero_result_o`, `flag_s_negative_result_o`, `flag_c_carry_or_shift_out_o`, `flag_o_overflow_o` | флаги результата |

Контрольные точки:

- `OR 00F0h,0F0Fh -> 0FFFh`;
- `NOR 0FFFh,0FFFh -> F000h`;
- `SRA 8001h -> C000h`, `C=1`;
- `INCS C000h` при `FR.S=1 -> C001h`;
- `NOR FFFFh,FFFFh -> 0000h`, `Z=1`.

## ЛР6. Стек

Окна/скриншоты:

- RTL Viewer `lab6_stack_rtl_view_top`;
- внутри можно раскрыть рабочий модуль `lab6_stack_top`;
- схема `stack7x16` с регистровым массивом;
- диаграмма `PUSH`, `POP`, `PUSH_ALU`, `overflow`, `underflow`.

Сигналы:

| Сигнал | Что показать |
|---|---|
| `clock_i`, `reset_i` | такт и сброс |
| `stack_command_idle_push_pop_i[1..0]` | `01` PUSH, `10` POP, `11` PUSH_ALU |
| `data_from_register_file_i[15..0]` | `1111`, `2222`, затем заполнение |
| `alu_result_for_push_i[15..0]` | `C001` |
| `data_popped_to_register_file_o[15..0]` | результат POP |
| `stack_pointer_current_value_o[2..0]` | `7 -> 6 -> 5 -> ... -> 0 -> 7` |
| `status_stack_empty_o`, `status_stack_full_o` | пустой/полный стек |
| `error_push_to_full_stack_o`, `error_pop_from_empty_stack_o` | ошибки границ |

Ключевая фраза для защиты: стек растет вниз; при `PUSH` сначала используется ячейка `SP-1`, затем `SP` уменьшается. При `POP` читается текущая вершина `mem[SP]`, затем `SP` увеличивается.

## ЛР7. Арбитраж шин

Окна/скриншоты:

- RTL Viewer `lab7_bus_rtl_view_top`;
- внутри можно раскрыть рабочий модуль `lab7_bus_top`;
- центральный арбитр `bus_arbiter_parallel_quantum`;
- диаграмма `REQ/GNT/BUS`.

Сигналы:

| Сигнал | Что показать |
|---|---|
| `master_bus_request_lines_o[3..0]` | независимые запросы ведущих |
| `arbiter_bus_grant_lines_o[3..0]` | one-hot предоставление шины |
| `current_time_quantum_slot_o[1..0]` | текущий квант `0,0,1,1,2,2,3,3...` |
| `shared_data_bus_to_slave_o[15..0]` | данные выбранного ведущего |
| `slave_latched_data_from_bus_o[15..0]` | данные, зафиксированные ведомым |
| `slave_data_valid_strobe_o` | прием данных ведомым |

Контроль: одновременно активен не более один `grant_o`. Если в текущем слоте запрос есть, шина отдается соответствующему ведущему; если запроса нет, шина свободна до следующего кванта.

## ЛР8. Кэш-память

Окна/скриншоты:

- RTL Viewer `lab8_cache_rtl_view_top`;
- внутри можно раскрыть рабочий модуль `lab8_cache_top`;
- внутри показать `cache4way_age`;
- диаграмма чтения, попадания, промаха, write-through и вытеснения.

Сигналы:

| Сигнал | Что показать |
|---|---|
| `cpu_cache_request_i`, `cpu_write_enable_i` | запрос CPU, чтение/запись |
| `cpu_address_tag_set_i[15..0]` | `0010`, `0020`, `0030`, `0040`, `0050` |
| `cpu_write_data_to_cache_i[15..0]` | `ABCD` для write-through |
| `cpu_read_data_from_cache_o[15..0]` | `1110`, `ABCD`, `1220`, `1330`, `1440`, `1550` |
| `cpu_cache_response_ready_o` | готовность ответа |
| `cache_hit_signal_o`, `cache_miss_signal_o` | попадание/промах |
| `memory_request_from_cache_debug_o`, `memory_write_enable_debug_o` | обращение к основной памяти |
| `memory_address_debug_o[15..0]`, `memory_data_debug_o[15..0]` | адрес и данные RAM |

Последовательность:

1. `R[0010]` - первый промах, загрузка из RAM.
2. `R[0010]` - попадание.
3. `W[0010]=ABCD` - сквозная запись и обновление строки.
4. `R[0020]`, `R[0030]`, `R[0040]`, `R[0050]` - заполнение того же набора.
5. Повтор `R[0010]` - промах после вытеснения самой старой строки; из RAM возвращается `ABCD`.
