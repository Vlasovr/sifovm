# Курсовой проект СиФО ЭВМ, вариант 4

Этот каталог - рабочий комплект проекта микро-ЭВМ на ПЛИС для варианта 4.

## Состав

- `src/` - VHDL-исходники блоков и полной системы.
- `tb/` - testbench-файлы для автономной и сквозной проверки.
- `memory/` - образы ROM/RAM и ожидаемый дамп после выполнения программы.
- `quartus/` - каркас Quartus-проекта.
- `schemes/` - редактируемые листы `.drawio` для графической части.
- `docs/` - спецификация, таблица сигналов, программа и сценарии моделирования.

## Главный top-level

Для функциональной симуляции использовать:

- top entity: `tb_system_variant4`;
- полный модуль системы: `system_variant4_top`;
- процессорное ядро: `cpu_core_variant4`.

Для Quartus-проекта можно назначить top-level `system_variant4_top`, если нужен синтезируемый верхний уровень, или `tb_system_variant4`, если проект используется только для ModelSim simulation.

## Порядок добавления файлов в Quartus/ModelSim

1. `src/variant4_pkg.vhd`
2. `src/program_image_pkg.vhd`
3. `src/data_image_pkg.vhd`
4. Остальные файлы из `src/`
5. Нужный testbench из `tb/`

Минимальный сквозной запуск:

```text
tb_system_variant4
```

Ожидаемая строка в transcript:

```text
tb_system_variant4: TEST PASSED
```

## Что снять для записки

1. ALU: `tb_alu_variant4`.
2. Стек: `tb_stack7x16`.
3. ROM/RAM + DMA: `tb_mem_dma`.
4. Полная система: `tb_system_variant4`.
5. Отдельно показать на общей диаграмме: `dbg_pc`, `dbg_ir0`, `dbg_ir1`, `dbg_r1..dbg_r7`, `dbg_flags`, `dbg_sp`, `cache_hit`, `cache_miss`, `req_cpu`, `req_dma`, `gnt_cpu`, `gnt_dma`, `ram_we`, `ram_addr`, `ram_wdata`, `bp_hist`.

## Документы внутри комплекта

- `docs/OBJECTIVE.md` - параметры варианта 4 и система команд.
- `docs/SIGNALS.md` - таблица основных сигналов.
- `docs/PROGRAM_LISTING.md` - листинг программы в символьном, hex и binary виде.
- `docs/MEMORY_DUMPS.md` - дампы ROM/RAM до и после выполнения.
- `docs/TESTING_SCENARIO.md` - что запускать и какие значения должны получиться.
- `docs/QUARTUS_MODELSIM_RUNBOOK.md` - пошаговая инструкция для Quartus/ModelSim.
- `docs/REPORT_INTEGRATION_TODO.md` - что перенести в пояснительную записку.
- `docs/FINAL_CHECKLIST.md` - контроль перед сдачей и защита.

## Ограничение

В этой среде нет Quartus/ModelSim/GHDL, поэтому здесь подготовлены исходники, сценарии и ожидаемые результаты. Финальные временные диаграммы нужно снять у тебя локально в Quartus/ModelSim и затем заменить ими референсные изображения в записке.
