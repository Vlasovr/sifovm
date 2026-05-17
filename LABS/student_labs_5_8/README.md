# Лабораторные работы 5-8 по СиФО ЭВМ

Комплект сделан под индивидуальный вариант курсового проекта:

- АЛУ: `OR`, `NOR`, `SRA`, `INCS`;
- стек: 7 слов по 16 бит, рост вниз;
- арбитраж: централизованный параллельный, фиксированный квант времени;
- кэш: 4-way set associative, 16 наборов, замещение по наибольшей давности хранения, write-through.

## Структура

| Папка | Содержимое |
|---|---|
| `common/` | общий пакет VHDL с константами варианта |
| `lab5_alu/` | проект АЛУ, testbench, отчет |
| `lab6_stack/` | проект стекового ЗУ, testbench, отчет |
| `lab7_bus_arbiter/` | проект арбитража шин, testbench, отчет |
| `lab8_cache/` | проект кэш-памяти, testbench, отчет |
| `assets/` | схемы и временные диаграммы для отчетов |
| `docs/` | инструкции по ручной проверке и подготовке к защите |
| `sim/` | скрипт запуска GHDL и VCD-дампы |

## Проверка

GHDL:

```powershell
cd D:\git\sifovm\LABS\student_labs_5_8\sim
powershell -ExecutionPolicy Bypass -File .\run_all_ghdl.ps1
```

Результат: все 4 testbench проходят, VCD-файлы создаются в `sim/vcd/`.

Quartus:

```powershell
cd D:\git\sifovm\LABS\student_labs_5_8\lab5_alu\quartus
quartus_sh --flow compile lab5_alu

cd D:\git\sifovm\LABS\student_labs_5_8\lab6_stack\quartus
quartus_sh --flow compile lab6_stack

cd D:\git\sifovm\LABS\student_labs_5_8\lab7_bus_arbiter\quartus
quartus_sh --flow compile lab7_bus_arbiter

cd D:\git\sifovm\LABS\student_labs_5_8\lab8_cache\quartus
quartus_sh --flow compile lab8_cache
```

Проверено: все 4 проекта компилируются в Quartus II 9.1 без ошибок. Предупреждения о незакрепленных пинах нормальны для функционального учебного проекта без привязки к конкретной плате.

## Отчеты

Готовые DOCX:

- `lab5_alu/report/LR5_ALU_variant.docx`
- `lab6_stack/report/LR6_STACK_variant.docx`
- `lab7_bus_arbiter/report/LR7_BUS_ARBITER_variant.docx`
- `lab8_cache/report/LR8_CACHE_variant.docx`

Отчеты переписаны в развернутом формате по образцу: титульный лист, содержание, цель работы, исходные данные, теоретические сведения, подробное выполнение работы, таблицы входных и выходных сигналов, алгоритм, описание VHDL-модулей, моделирование, результаты синтеза и вывод.
