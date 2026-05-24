# Мини-схемы для рисунков раздела 2

Эти проекты сделаны отдельно от основного проекта, чтобы получать аккуратные
рисунки через `RTL Viewer` и не менять исходную схему микро-ЭВМ.

Порядок для каждого проекта одинаковый:

1. Открыть `.qpf` в Quartus.
2. Выполнить `Processing -> Start -> Start Analysis & Elaboration`.
3. Открыть `Tools -> Netlist Viewers -> RTL Viewer`.
4. Сделать скриншот нужной схемы.

## Рекомендуемые рисунки

### Выборка и декодирование команды

Проект:

`coursework_project/rtl_schemes/section_2_fetch_decode/quartus/section_2_fetch_decode.qpf`

Подпись:

`Рисунок 2.x - Выборка и декодирование двухсловной команды`

### Команды MOV adr,Rn и MOV Rn,adr

Проект:

`coursework_project/rtl_schemes/section_2_mov_mr_rm/quartus/section_2_mov_mr_rm.qpf`

Подпись:

`Рисунок 2.x - Маршрутизация данных при выполнении MOV adr,Rn и MOV Rn,adr`

### Команды JMP и JZ

Проект:

`coursework_project/rtl_schemes/section_2_jmp_jz/quartus/section_2_jmp_jz.qpf`

Подпись:

`Рисунок 2.x - Формирование адреса следующей команды при выполнении JMP и JZ`

### Операции АЛУ

Проект:

`coursework_project/rtl_schemes/section_2_alu_ops/quartus/section_2_alu_ops.qpf`

Подпись:

`Рисунок 2.x - Маршрутизация операндов при выполнении операций АЛУ`

### Команды PUSH и POP

Проект:

`coursework_project/rtl_schemes/section_2_stack_push_pop/quartus/section_2_stack_push_pop.qpf`

Подпись:

`Рисунок 2.x - Изменение указателя стека при выполнении PUSH и POP`

### Команда HLT

Проект:

`coursework_project/rtl_schemes/section_2_hlt/quartus/section_2_hlt.qpf`

Подпись:

`Рисунок 2.x - Формирование сигнала останова при выполнении HLT`

## Куда вставлять

- В пункт 2.4 можно вставить рисунки `MOV`, `JMP/JZ`, `HLT`.
- В пункт 2.5 можно вставить рисунок операций АЛУ.
- В пункт 2.6 можно вставить рисунок `PUSH/POP`.
- Рисунок выборки и декодирования лучше поставить в начало описания устройства
  управления или перед описанием выполнения команд.
