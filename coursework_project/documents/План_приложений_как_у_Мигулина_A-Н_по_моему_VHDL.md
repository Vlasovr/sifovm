# План отрисовки приложений А-Н в стиле образца Мигулина

Этот файл сделан под текущий проект Власова Р.Е. в папке `D:\git\sifovm\coursework_project`.
Цель: не получать огромные нечитаемые схемы из RTL Viewer, а руками собрать в Quartus BDF нормальные структурные листы для печати, технически соответствующие твоему VHDL.

## 0. Главное решение

1. Для печати лучше рисовать схемы вручную в `Block Diagram/Schematic File (.bdf)`.
2. RTL Viewer использовать только как подсказку, если блок маленький.
3. В схемах не надо показывать каждую внутреннюю LUT-логику. Преподавателю обычно важнее, чтобы были правильные функциональные блоки, разрядности, направления сигналов и команды твоего варианта.
4. Пины у товарища сделаны отдельно потому, что в BDF добавлены символы `Input Pin` и `Output Pin`. Так и делай: входы слева, выходы справа, `clk/rst` отдельно снизу или слева снизу.

## 1. Где открывать проект

Основной проект:

`D:\git\sifovm\coursework_project\quartus\coursework.qpf`

Документационный RTL-проект, который я раньше делал для грубой основы:

`D:\git\sifovm\coursework_project\quartus_rtl_appendix\rtl_appendix.qpf`

Для ручных схем лучше создать отдельную папку, например:

`D:\git\sifovm\coursework_project\quartus_drawings`

Можно не компилировать эти BDF. Они нужны как чертежи для печати.

## 2. Общие действия в Quartus для каждого листа

1. Открой Quartus.
2. `File -> New Project Wizard`.
3. Папка проекта: `D:\git\sifovm\coursework_project\quartus_drawings`.
4. Название проекта, например: `coursework_drawings`.
5. Top-level entity можно поставить любое, например `app_a_memory`. Для ручных чертежей это не критично.
6. Устройство можно выбрать такое же, как в основном проекте: `Cyclone II`, `AUTO`.
7. Создай файл: `File -> New -> Block Diagram/Schematic File`.
8. Сразу сохрани: `File -> Save As`, например `app_a_memory.bdf`.
9. Вставляй пины: `Symbol Tool -> primitives -> pin -> input/output`.
10. Подписывай шины именно так: `addr[15..0]`, `data[15..0]`, `opcode[7..0]`, `rn[3..0]`.
11. Для прямоугольных функциональных блоков проще всего использовать:
    - `Symbol Tool -> primitives -> storage` для регистров/триггеров, если есть подходящий символ;
    - обычные блоки/мегафункции, если нужны RAM/ROM;
    - или прямоугольники/текст в BDF, если это схема для печати, а не для компиляции.
12. Провода веди `Orthogonal Node Tool`.
13. Толстые смысловые шины подписывай текстом, не пытайся проводить 16 отдельных линий.
14. Перед печатью: `File -> Page Setup`, выбери формат листа и ориентацию.
15. Печать в PDF: `File -> Print -> Microsoft Print to PDF`.

## 3. Обязательные параметры твоего варианта

Всегда держи эти параметры на схемах:

- разрядность данных: 16 бит;
- разрядность адреса: 16 бит;
- РОН: 12 регистров `R0...R11`;
- стек: 7 слов `STACK0...STACK6`;
- кэш: 4-way, 16 sets, `TAG=A[15..4]`, `SET=A[3..0]`;
- операции АЛУ: `OR`, `NOR`, `SRA`, `INCS`;
- команды: `HLT`, `M->R`, `R->M`, `OR`, `NOR`, `SRA`, `INCS`, `PUSH`, `POP`, `JMP`, `JZ`;
- КПДП: передача 3 слов, базовый адрес `000A`;
- предсказатель: `GHR[1..0]`, индекс `PC[1..0] & GHR[1..0]`, таблица PHT на 16 двухбитных счетчиков.

## 4. Где это лежит в VHDL

| Лист по образцу | Что рисовать | Откуда брать в твоем VHDL |
|---|---|---|
| А - память | ПЗУ, ОЗУ, выбор адреса/данных, связь с CPU/DMA/cache | `src/rom_sync.vhd`, `src/ram_sync.vhd`, `src/system_core.vhd` |
| Б - декодер | Декодер opcode и формирование управляющих линий | `src/microcomputer_pkg.vhd`, `src/cpu_core.vhd`, состояние `S_DECODE` |
| В - счетчик фаз | Регистр состояния/фазы и переходы между фазами | `src/cpu_core.vhd`, `type state_t`, `state_code` |
| Г - IP и IR | IP/PC, IR0, IR1, инкремент PC, выбор перехода | `src/cpu_core.vhd`, сигналы `pc_r`, `ir0_r`, `ir1_r`, `rom_addr_r` |
| Д - стек | SP, 7 ячеек стека, PUSH/POP, full/empty | `src/stack7x16.vhd` |
| Е - РОН | 12 регистров, write decoder, read mux | `src/reg_file12x16.vhd`, `src/reg_file12x16_dbg.vhd` |
| Ж - АЛУ | OR/NOR/SRA/INCS, mux результата, флаги | `src/alu_core.vhd`, `src/flags_reg.vhd` |
| И - кэш | 4 ways, DATA/TAG/VALID/AGE, compare, hit/miss, controller | `src/cache_4way_age.vhd`, лучше как подсказка `src/cache_4way_structural_doc.vhd` |
| К - предсказатель | GHR, PHT, BTB, сравнение PC/tag, update | `src/branch_predictor.vhd` |
| Л - КПДП | FSM, req/grant, счетчик 0..2, BASE_ADDR+index | `src/dma_controller_3word.vhd` |
| М - арбитраж шин | CPU/DMA request, grants, mux адреса/данных/we | `src/bus_arbiter_2master.vhd`, `src/system_core.vhd` |
| Н - микро-ЭВМ | CPU, ROM, cache, RAM, arbiter, DMA, predictor | `src/system_core.vhd`, `src/microcomputer_top.vhd`, `src/microcomputer_debug_top.vhd` |

## 5. Приложение А - блок памяти

Лучший вариант: рисовать обобщенно. Да, можно брать VHDL как основу, но не надо делать RTL Viewer на весь `system_core`, он будет грязный.

Что поставить на лист:

1. Слева входные пины:
   - `clk`
   - `rst`
   - `rom_addr[15..0]`
   - `ram_addr_cpu[15..0]`
   - `ram_wdata_cpu[15..0]`
   - `ram_we_cpu`
   - `dma_addr[15..0]`
   - `dma_wdata[15..0]`
   - `dma_we`
   - `cpu_grant`
   - `dma_grant`
2. В центре сверху блок `ROM_SYNC / ПЗУ команд 256x16`.
3. В центре снизу блок `RAM_SYNC / ОЗУ данных 256x16`.
4. Перед RAM поставь `MUX ADDR 2->1`: выбирает `ram_addr_cpu` или `dma_addr`.
5. Перед RAM поставь `MUX WDATA 2->1`: выбирает `ram_wdata_cpu` или `dma_wdata`.
6. Перед входом `we` RAM поставь `OR/selector`: `ram_we = (cpu_we and cpu_grant) or (dma_we and dma_grant)`.
7. Справа выходные пины:
   - `rom_data[15..0]`
   - `ram_rdata[15..0]`
8. Подпиши рядом:
   - `ПЗУ хранит двухсловные команды`;
   - `ОЗУ используется командами M->R, R->M, OR, NOR и КПДП`;
   - `адрес и данные 16 бит`.

Технически верно для твоего проекта:

- ROM берется из `rom_sync.vhd`;
- RAM берется из `ram_sync.vhd`;
- CPU/DMA выбор реально сделан в `system_core.vhd` вместе с арбитражем.

## 6. Приложение Б - декодер команд

Отдельного VHDL-файла декодера у тебя нет. Он находится внутри `cpu_core.vhd` в состоянии `S_DECODE`. Поэтому рисовать надо вручную.

Что поставить:

1. Слева пин `IR0[15..0]`.
2. От него провести две шины:
   - `opcode[7..0] = IR0[15..8]`;
   - `rn[3..0] = IR0[7..4]`.
3. Поставить блок `OPCODE DECODER 8->11`.
4. Из него вывести линии:
   - `op_hlt`
   - `op_m_to_r`
   - `op_r_to_m`
   - `op_or`
   - `op_nor`
   - `op_sra`
   - `op_incs`
   - `op_push`
   - `op_pop`
   - `op_jmp`
   - `op_jz`
5. Внутри или рядом с блоком написать коды:
   - `00 HLT`
   - `01 M->R`
   - `02 R->M`
   - `03 OR`
   - `04 NOR`
   - `05 SRA`
   - `06 INCS`
   - `07 PUSH`
   - `08 POP`
   - `09 JMP`
   - `0A JZ`
6. Справа поставь блок `CONTROL SIGNALS`.
7. Соедини:
   - `op_m_to_r`, `op_or`, `op_nor` -> `mem_read`;
   - `op_r_to_m` -> `mem_write`;
   - `op_or`, `op_nor`, `op_sra`, `op_incs` -> `alu_en`;
   - `op_sra`, `op_incs` -> `alu_reg_src`;
   - `op_push` -> `stack_push`;
   - `op_pop` -> `stack_pop`;
   - `op_jmp`, `op_jz` -> `branch_en`;
   - `op_hlt` -> `halt`.
8. Выведи справа пины управляющих сигналов.

Как в Quartus:

1. Создай `app_b_decoder.bdf`.
2. Поставь входной пин `IR0[15..0]`.
3. Нарисуй один крупный блок `OPCODE DECODER`.
4. Если хочешь сделать похоже на настоящую логику, рядом нарисуй 11 маленьких компараторов `opcode = 00`, `opcode = 01` и т.д.
5. Компараторы можно рисовать прямоугольниками, без реального компилируемого символа.

## 7. Приложение В - счетчик фаз / блок управления фазами

Можно посмотреть в RTL Viewer, но печатать лучше ручную схему. RTL даст слишком много мусора.

Что рисовать:

1. Слева входы:
   - `clk`
   - `rst`
   - `opcode[7..0]`
   - `cache_ready`
   - `flag_z`
   - `stack_empty`
   - `stack_full`
2. В центре блок `STATE REGISTER / PHASE COUNTER`.
3. Внутри подпиши `state[4..0]`.
4. Под ним блок `NEXT STATE LOGIC`.
5. Справа блок `PHASE DECODER`.
6. Выходные фазы:
   - `fetch0_req`
   - `fetch0_wait`
   - `fetch0_latch`
   - `fetch1_req`
   - `fetch1_wait`
   - `fetch1_latch`
   - `decode`
   - `cache_read`
   - `cache_write`
   - `alu_setup`
   - `alu_write`
   - `rf_write_mem`
   - `stack_push`
   - `stack_pop`
   - `rf_write_pop`
   - `branch_jmp`
   - `branch_jz`
   - `finish`
   - `halt`
7. Рядом можно сделать укрупненный маршрут:
   - `RESET -> FETCH0 -> FETCH1 -> DECODE`;
   - `DECODE -> MEMORY`, если `M->R`, `R->M`, `OR`, `NOR`;
   - `DECODE -> ALU`, если `SRA`, `INCS`;
   - `DECODE -> STACK`, если `PUSH`, `POP`;
   - `DECODE -> BRANCH`, если `JMP`, `JZ`;
   - `DECODE -> HALT`, если `HLT`;
   - после выполнения -> `FINISH -> FETCH0`.

Как делать в Quartus:

1. Создай `app_v_phase_counter.bdf`.
2. Поставь регистр или прямоугольник `STATE REGISTER`.
3. От него сделай обратную связь в `NEXT STATE LOGIC`.
4. От `NEXT STATE LOGIC` проводом верни `state_next[4..0]` на вход регистра.
5. От регистра проведи `state[4..0]` на `PHASE DECODER`.
6. Выходы `PHASE DECODER` вывести пинами справа.

Техническая привязка: список состояний находится в `cpu_core.vhd`, `type state_t`.

## 8. Приложение Г - IP и IR

Надо рисовать не максимально подробно по вентилям, а достаточно подробно: регистры, инкрементаторы, мультиплексор перехода, поля команды.

Что поставить:

1. Слева входы:
   - `clk`
   - `rst`
   - `rom_data[15..0]`
   - `branch_target[15..0]`
   - `branch_taken`
   - `pred_target[15..0]`
   - `pred_taken`
2. В центре блок `IP/PC REGISTER`.
3. От PC вывести:
   - на `ROM_ADDR`;
   - на сумматор `PC + 1`;
   - на сумматор `PC + 2`.
4. Блок `PC NEXT MUX`:
   - вход 0: `PC + 2`;
   - вход 1: `branch_target`;
   - вход 2: `pred_target`, если хочешь показать предсказатель.
5. Блоки регистров:
   - `IR0 REGISTER` - первое слово команды;
   - `IR1 REGISTER` - второе слово команды / адрес.
6. От `IR0` вывести поля:
   - `opcode = IR0[15..8]`;
   - `rn = IR0[7..4]`.
7. От `IR1` вывести:
   - `addr/imm = IR1[15..0]`.
8. Справа пины:
   - `rom_addr[15..0]`
   - `opcode[7..0]`
   - `rn[3..0]`
   - `addr[15..0]`

Почему так: в `cpu_core.vhd` команды читаются двумя словами: сначала `ir0_r`, потом `ir1_r`.

## 9. Приложение Д - стек

Стек лучше рисовать подробно. У тебя стек всего на 7 слов, схема получится красивой и не слишком большой.

Что поставить:

1. Входы слева:
   - `clk`
   - `rst`
   - `push`
   - `pop`
   - `din[15..0]`
2. Вверху блок `SP UP/DOWN COUNTER`.
3. Подпиши:
   - reset: `SP = 7`;
   - push: `SP = SP - 1`;
   - pop: `SP = SP + 1`.
4. От SP провести на блок `STACK ADDRESS DECODER 3->7`.
5. Нарисуй 7 регистров:
   - `STACK0 16 bit`
   - `STACK1 16 bit`
   - `STACK2 16 bit`
   - `STACK3 16 bit`
   - `STACK4 16 bit`
   - `STACK5 16 bit`
   - `STACK6 16 bit`
6. Общую шину `din[15..0]` проведи ко всем ячейкам.
7. Линии decoder `we0...we6` заведи на соответствующие ячейки.
8. Выходы всех ячеек заведи на `MUX 7->1`.
9. Управление MUX - от `SP[2..0]`.
10. Справа выходы:
    - `dout[15..0]`
    - `sp[2..0]`
    - `empty`
    - `full`
11. Логика флагов:
    - `empty = 1`, если `SP = 7`;
    - `full = 1`, если `SP = 0`.

Техническая привязка: `src/stack7x16.vhd`.

## 10. Приложение Е - РОН

РОН тоже лучше рисовать подробно. Для твоего варианта обязательно 12 регистров, а не 20.

Что поставить:

1. Входы:
   - `clk`
   - `rst`
   - `we`
   - `wr_addr[3..0]`
   - `rd_addr_a[3..0]`
   - `rd_addr_b[3..0]`
   - `din[15..0]`
2. Блок `WRITE DECODER 4->12`.
3. От decoder вывести `we0...we11`.
4. Нарисовать 12 регистров:
   - `R0 16 bit`
   - `R1 16 bit`
   - ...
   - `R11 16 bit`
5. Шину `din[15..0]` подать на все регистры.
6. Выходы всех регистров подать на два мультиплексора:
   - `MUX A 12->1`;
   - `MUX B 12->1`.
7. Управление:
   - `rd_addr_a[3..0]` -> `MUX A`;
   - `rd_addr_b[3..0]` -> `MUX B`.
8. Выходы:
   - `dout_a[15..0]`;
   - `dout_b[15..0]`.

Если хочешь сделать как у товарища, регистры можно расположить двумя колонками по 6 штук, справа поставить большой mux.

Техническая привязка: `src/reg_file12x16.vhd`, debug-версия `src/reg_file12x16_dbg.vhd`.

## 11. Приложение Ж - АЛУ

АЛУ рисовать средне подробно: блоки операций отдельно, результат через mux, флаги отдельно.

Что поставить:

1. Входы:
   - `a[15..0]`
   - `b[15..0]`
   - `alu_op[2..0]`
   - `flag_s`
2. Блок `OP DECODER`.
3. Четыре блока операций:
   - `OR: y = a OR b`;
   - `NOR: y = NOT(a OR b)`;
   - `SRA: y = a(15) & a(15 downto 1)`;
   - `INCS: y = a + S`.
4. Выходы операций завести на `RESULT MUX 4->1`.
5. От результата завести блок `FLAGS LOGIC`.
6. Справа выходы:
   - `y[15..0]`;
   - `Z`;
   - `S`;
   - `C`;
   - `O`.
7. Для `SRA` подпиши:
   - `C = a(0)`;
   - знак сохраняется.
8. Для `INCS` подпиши:
   - если `S=1`, выполняется инкремент;
   - если `S=0`, значение сохраняется.

Техническая привязка: `src/alu_core.vhd`, `src/flags_reg.vhd`.

## 12. Приложение И - кэш-память

Это самое важное приложение. Его надо рисовать максимально похоже на образец: четыре WAY, теги, valid, age, компараторы, mux данных, контроллер.

Что поставить:

1. Слева входы CPU:
   - `clk`
   - `rst`
   - `cpu_req`
   - `cpu_we`
   - `cpu_addr[15..0]`
   - `cpu_wdata[15..0]`
2. Первый блок: `ADDRESS SPLIT`.
3. Из него выходы:
   - `TAG = A[15..4]`;
   - `SET = A[3..0]`.
4. В центре нарисовать четыре одинаковые пунктирные области:
   - `WAY0`
   - `WAY1`
   - `WAY2`
   - `WAY3`
5. В каждой области:
   - `DATA way N 16x16`;
   - `TAG N`;
   - `VALID N`;
   - `AGE N`.
6. Для каждого way справа поставить компаратор:
   - `cmpN: TAG_req = TAG_N AND VALID_N`.
7. Выход каждого компаратора:
   - `hit0`
   - `hit1`
   - `hit2`
   - `hit3`
8. `hit0...hit3` завести на блок `OR hit0..3`.
9. От OR вывести:
   - `hit`;
   - через `NOT` получить `miss`.
10. Данные `data0...data3` завести на `MUX 4->1 READ DATA`.
11. Управление mux - по `hit0...hit3`.
12. Справа выходы CPU:
   - `cpu_rdata[15..0]`;
   - `cpu_ready`;
   - `hit`;
   - `miss`.
13. Справа/снизу блок `CACHE CONTROL FSM`.
14. Внутри FSM указать состояния:
   - `IDLE`;
   - `WAIT_READ_GRANT`;
   - `WAIT_READ_DATA`;
   - `WAIT_WRITE_GRANT`.
15. Снизу блок `VICTIM SELECT`.
16. На него подать:
   - `valid0...valid3`;
   - `age0...age3`.
17. Выход `victim[1..0]` идет на write-enable выбранного way.
18. Справа снизу блок `RAM INTERFACE`.
19. Пины RAM:
   - `ram_req`;
   - `ram_we`;
   - `ram_addr[15..0]`;
   - `ram_wdata[15..0]`;
   - `ram_rdata[15..0]`;
   - `ram_grant`.

Что подписать на листе:

- `4-way set associative cache`;
- `16 sets`;
- `TAG 12 bit, SET 4 bit`;
- `write-through`;
- `replacement by invalid/free way or max AGE`.

Техническая привязка:

- реальная логика: `src/cache_4way_age.vhd`;
- удобная структурная подсказка именно для рисования: `src/cache_4way_structural_doc.vhd`.

## 13. Приложение К - предсказатель переходов

Рисовать укрупненно, но технически точно.

Что поставить:

1. Входы:
   - `clk`
   - `rst`
   - `query`
   - `pc_query[15..0]`
   - `update`
   - `pc_update[15..0]`
   - `taken`
   - `target_update[15..0]`
2. Блок `GHR REGISTER 2 bit`.
3. Блок `INDEX FORMATION`.
4. Внутри подписать:
   - `index = PC[1..0] & GHR[1..0]`.
5. Блок `PHT 16 x 2-bit saturating counters`.
6. Блок `BTB TARGET TABLE 16 x 16`.
7. Блок `BTB VALID`.
8. Блок `PREDICT LOGIC`:
   - старший бит PHT -> `predict_taken`;
   - если valid, то target из BTB.
9. Блок `UPDATE LOGIC`:
   - если taken, счетчик PHT увеличивается;
   - если not taken, уменьшается;
   - target пишется в BTB;
   - GHR обновляется.
10. Выходы справа:
    - `pred_taken`;
    - `pred_target[15..0]`;
    - `hist[1..0]`.

Техническая привязка: `src/branch_predictor.vhd`.

## 14. Приложение Л - КПДП

КПДП можно сделать как у товарища: FSM + счетчик слова + адресатор + интерфейс RAM.

Что поставить:

1. Входы:
   - `clk`
   - `rst`
   - `start`
   - `bus_grant`
   - `dev_valid`
   - `dev_data[15..0]`
2. Блок `DMA CONTROL FSM`.
3. Внутри состояния:
   - `IDLE`;
   - `REQ_BUS`;
   - `WRITE_WORD`;
   - `FINISH`.
4. Блок `WORD COUNTER 0..2`.
5. Блок `BASE ADDR REGISTER`, подпись `BASE = 000A`.
6. Блок сумматора:
   - `ram_addr = BASE + index`.
7. Блок `DATA REGISTER`.
8. Выходы:
   - `bus_req`;
   - `ram_we`;
   - `ram_addr[15..0]`;
   - `ram_wdata[15..0]`;
   - `busy`;
   - `done`.
9. Подписать:
   - `передача 3 слов`;
   - `запись в ОЗУ по адресам 000A..000C`.

Техническая привязка: `src/dma_controller_3word.vhd`.

## 15. Приложение М - арбитраж шин

Здесь схема должна быть простой. Не усложняй.

Что поставить:

1. Входы:
   - `cpu_req`
   - `dma_req`
   - `cpu_addr[15..0]`
   - `dma_addr[15..0]`
   - `cpu_wdata[15..0]`
   - `dma_wdata[15..0]`
   - `cpu_we`
   - `dma_we`
2. Блок `BUS ARBITER 2 MASTER`.
3. Внутри правило:
   - если `dma_req=1`, дать `dma_grant`;
   - иначе при `cpu_req=1` дать `cpu_grant`.
4. Справа от арбитра:
   - `cpu_grant`;
   - `dma_grant`.
5. Ниже три mux:
   - `ADDR MUX`;
   - `WDATA MUX`;
   - `WE MUX`.
6. Выходы на RAM:
   - `ram_addr[15..0]`;
   - `ram_wdata[15..0]`;
   - `ram_we`.

Техническая привязка: `src/bus_arbiter_2master.vhd`, mux-логика в `src/system_core.vhd`.

## 16. Приложение Н - микро-ЭВМ

Это общий лист. Делай как большую структурную схему, не как RTL.

Что поставить:

1. В центре главный блок `CPU CORE`.
2. Внутри CPU или рядом меньшими блоками:
   - `CU`;
   - `IP/IR`;
   - `RON`;
   - `ALU`;
   - `FLAGS`;
   - `STACK`.
3. Слева/сверху блок `ROM / ПЗУ команд`.
4. Справа от CPU блок `CACHE 4-WAY`.
5. Ниже cache блок `RAM / ОЗУ данных`.
6. Между cache/RAM и DMA поставить `BUS ARBITER`.
7. Отдельно блок `DMA / КПДП`.
8. Отдельно блок `BRANCH PREDICTOR`.
9. Основные связи:
   - `CPU -> ROM`: `rom_addr`, `rom_en`;
   - `ROM -> CPU`: `rom_data`;
   - `CPU -> CACHE`: `cache_req`, `cache_we`, `cache_addr`, `cache_wdata`;
   - `CACHE -> CPU`: `cache_rdata`, `ready`, `hit/miss`;
   - `CACHE <-> RAM`: `ram_req`, `ram_we`, `ram_addr`, `ram_wdata`, `ram_rdata`;
   - `DMA -> ARBITER/RAM`: `dma_req`, `dma_addr`, `dma_data`;
   - `CPU <-> BP`: `bp_query`, `bp_update`, `pred_taken`, `pred_target`.
10. Выходы общего блока:
    - `halt`;
    - можно показать debug-пины `state`, `pc`, `flags`, `sp`.

Техническая привязка: `src/system_core.vhd`.

## 17. Что можно делать через RTL Viewer

Можно попробовать RTL Viewer для:

- `stack7x16` - стек;
- `reg_file12x16` - РОН;
- `alu_core` - АЛУ;
- `bus_arbiter_2master` - арбитраж;
- `dma_controller_3word` - КПДП;
- `branch_predictor` - предсказатель, но он может выйти не очень красиво;
- `cache_4way_structural_doc` - кэш, если хочешь основу.

Не советую брать RTL Viewer для:

- всего `microcomputer_debug_top`;
- всего `cpu_core`;
- обычного `cache_4way_age`.

Почему: будет либо слишком много страниц, либо каша из LUT/регистров.

## 18. Как посмотреть нужный блок в RTL Viewer

1. Открой основной проект:
   `D:\git\sifovm\coursework_project\quartus\coursework.qpf`.
2. `Processing -> Start -> Start Analysis & Elaboration`.
3. Дождись завершения.
4. `Tools -> Netlist Viewers -> RTL Viewer`.
5. В дереве слева найди нужный экземпляр:
   - `U_SYSTEM`;
   - внутри `U_CPU`, `U_ROM`, `U_CACHE`, `U_RAM`, `U_ARB`, `U_DMA`, `U_BP`.
6. Для маленьких блоков можно сделать скрин.
7. Для печатного приложения лучше по RTL Viewer только сверить сигналы, а сам лист рисовать в BDF.

Если хочешь посмотреть именно документационный кэш:

1. Открой:
   `D:\git\sifovm\coursework_project\quartus_rtl_appendix\rtl_appendix.qpf`.
2. Запусти `Analysis & Elaboration`.
3. Открой `RTL Viewer`.
4. Найди `U_APP_F_CACHE` или `cache_4way_structural_doc`.

## 19. Что обязательно проверить перед печатью

1. На РОН должно быть `R0...R11`, не `R0...R19`.
2. На стеке должно быть `STACK0...STACK6`, не 6 ячеек.
3. На АЛУ должны быть операции `OR`, `NOR`, `SRA`, `INCS`, а не `ADDC`, `AND`, `NOT`, `ROR`.
4. На декодере должны быть команды твоего варианта:
   `HLT`, `M->R`, `R->M`, `OR`, `NOR`, `SRA`, `INCS`, `PUSH`, `POP`, `JMP`, `JZ`.
5. На кэше должно быть `4-way`, `16 sets`, `TAG=A[15..4]`, `SET=A[3..0]`.
6. На КПДП должно быть `3 words`, `BASE=000A`.
7. На предсказателе должен быть `GHR[1..0]` и `PHT 16 x 2-bit`.
8. Все основные шины подписать `[15..0]`.
9. Все тексты в схемах лучше черным, линии оставить стандартными цветами Quartus.

## 20. Минимальный порядок работы

1. Сначала сделай приложение Н - микро-ЭВМ, чтобы была общая карта.
2. Потом А - память.
3. Потом Г - IP/IR.
4. Потом Б и В - декодер и фазы.
5. Потом Е - РОН.
6. Потом Ж - АЛУ.
7. Потом Д - стек.
8. Потом И - кэш.
9. Потом К - предсказатель.
10. Потом Л - КПДП.
11. Потом М - арбитраж.

Так проще, потому что общий лист Н задает связи между всеми остальными.

