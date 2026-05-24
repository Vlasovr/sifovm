# section_2_jmp_jz

Отдельный проект для рисунка раздела 2: формирование перехода командами `JMP`
и `JZ`.

Открывать в Quartus:

`coursework_project/rtl_schemes/section_2_jmp_jz/quartus/section_2_jmp_jz.qpf`

Для скриншота:

1. `Processing -> Start -> Start Analysis & Elaboration`
2. `Tools -> Netlist Viewers -> RTL Viewer`
3. Подпись рисунка: `Формирование адреса следующей команды при выполнении JMP и JZ`

Что видно на схеме:

- `u_ir` хранит `IR0` и `IR1`;
- `u_dec` распознает коды `JMP = 09h` и `JZ = 0Ah`;
- `u_z` хранит флаг нуля `Z`;
- `u_take` формирует условие перехода: `JMP OR (JZ AND Z)`;
- `u_add` формирует последовательный адрес `PC + 2`;
- `u_mux` выбирает `PC + 2` или адрес из `IR1`;
- `u_pc` загружает новый адрес в указатель команд;
- `u_bp` показывает связь с предсказателем переходов.
