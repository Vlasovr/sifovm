# Инструкция для Quartus/ModelSim

## Создание проекта

1. Открыть Quartus.
2. Создать новый проект в каталоге `coursework_project/quartus`.
3. Название проекта: `coursework`.
4. Добавить все `.vhd` из `../src`.
5. Для симуляции добавить нужный файл из `../tb`.
6. Если Quartus просит top-level:
   - для полной системы выбрать `system_coursework_top`;
   - для testbench в ModelSim выбрать `tb_system_coursework`.

## Порядок компиляции VHDL

Если ModelSim требует ручной порядок:

```text
vcom ../src/coursework_pkg.vhd
vcom ../src/program_image_pkg.vhd
vcom ../src/data_image_pkg.vhd
vcom ../src/alu_coursework.vhd
vcom ../src/reg_file12x16.vhd
vcom ../src/reg_file12x16_dbg.vhd
vcom ../src/flags_reg.vhd
vcom ../src/stack7x16.vhd
vcom ../src/rom_sync.vhd
vcom ../src/ram_sync.vhd
vcom ../src/bus_arbiter_2master.vhd
vcom ../src/dma_controller_3word.vhd
vcom ../src/branch_predictor_a4.vhd
vcom ../src/cache4way_age.vhd
vcom ../src/cpu_core_coursework.vhd
vcom ../src/system_coursework_top.vhd
vcom ../tb/tb_system_coursework.vhd
vsim work.tb_system_coursework
run 5 us
```

## Как это выглядит в Quartus

Блоки проекта сделаны не как ручная `.bdf`-схема, а как отдельные VHDL-модули.
Quartus собирает их в иерархию от верхнего файла `system_coursework_top.vhd`.

Основные блоки:

- `cpu_core_coursework` - процессорное ядро и автомат выполнения команд;
- `alu_coursework` - АЛУ индивидуального задания;
- `reg_file12x16` - 12 регистров общего назначения;
- `flags_reg` - регистр флагов `Z/S/C/O`;
- `stack7x16` - стек глубиной 7 слов;
- `rom_sync` - синхронное ПЗУ команд;
- `ram_sync` - синхронное ОЗУ данных;
- `cache4way_age` - 4-way кэш с замещением по возрасту;
- `dma_controller_3word` - КПДП на 3 слова;
- `bus_arbiter_2master` - централизованный параллельный арбитр;
- `branch_predictor_a4` - предсказатель A4.

После компиляции их можно открыть через `Tools -> Netlist Viewers -> RTL Viewer`
или посмотреть дерево `Project Navigator -> Hierarchy`. Если преподаватель
требует именно символы для `.bdf`, в Quartus можно открыть каждый `.vhd` и
выполнить `File -> Create / Update -> Create Symbol Files for Current File`.

## Сигналы для добавления на waveform

Для полной модели добавить:

```text
sim:/tb_system_coursework/clk
sim:/tb_system_coursework/rst
sim:/tb_system_coursework/halt
sim:/tb_system_coursework/dma_start
sim:/tb_system_coursework/dma_valid
sim:/tb_system_coursework/dma_data
sim:/tb_system_coursework/dma_done
sim:/tb_system_coursework/dbg_state
sim:/tb_system_coursework/dbg_pc
sim:/tb_system_coursework/dbg_ir0
sim:/tb_system_coursework/dbg_ir1
sim:/tb_system_coursework/dbg_r1
sim:/tb_system_coursework/dbg_r2
sim:/tb_system_coursework/dbg_r3
sim:/tb_system_coursework/dbg_r4
sim:/tb_system_coursework/dbg_r5
sim:/tb_system_coursework/dbg_r6
sim:/tb_system_coursework/dbg_r7
sim:/tb_system_coursework/dbg_flags
sim:/tb_system_coursework/dbg_sp
sim:/tb_system_coursework/cache_hit
sim:/tb_system_coursework/cache_miss
sim:/tb_system_coursework/req_cpu
sim:/tb_system_coursework/req_dma
sim:/tb_system_coursework/gnt_cpu
sim:/tb_system_coursework/gnt_dma
sim:/tb_system_coursework/ram_we
sim:/tb_system_coursework/ram_addr
sim:/tb_system_coursework/ram_wdata
sim:/tb_system_coursework/ram_rdata
sim:/tb_system_coursework/bp_hist
sim:/tb_system_coursework/bp_pred
sim:/tb_system_coursework/bp_target
```

## Как снять скриншоты

1. Запустить `run 5 us`.
2. Убедиться, что в transcript есть `TEST PASSED`.
3. Выставить radix `hexadecimal` для 16-битных шин.
4. Для общей диаграммы сделать два скрина:
   - участок с `SRA`, `INCS`, `PUSH`, `POP`;
   - участок с `JZ`, `JMP`, чтением DMA-данных и `HLT`.
5. Для DMA отдельно приблизить участок, где `gnt_dma=1`, `ram_we=1`, адреса `000A`, `000B`, `000C`.

## Что делать, если не компилируется

- Проверить, что `coursework_pkg.vhd` скомпилирован первым.
- Проверить, что используется библиотека `work`.
- Если ModelSim старый и ругается на VHDL-2008, выставить VHDL-93/2002: текущие файлы специально написаны без `process(all)`.
- Если RAM/ROM не видят пакеты с образами, вручную добавить `program_image_pkg.vhd` и `data_image_pkg.vhd` перед `rom_sync.vhd` и `ram_sync.vhd`.
