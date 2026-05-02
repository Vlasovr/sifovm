# Курсовой проект по СиФО ЭВМ

Репозиторий содержит материалы для курсового проекта по дисциплине
«Структурная и функциональная организация ЭВМ». Основной рабочий комплект
собран для **варианта 4**.

## Главное

Готовый комплект лежит в [`variant4_coursework_project`](variant4_coursework_project/).

Внутри него уже подготовлены:

- VHDL-исходники микро-ЭВМ;
- testbench-файлы для отдельных блоков и полной системы;
- MIF-образы ROM/RAM;
- ожидаемые дампы памяти;
- редактируемые схемы `.drawio` и 16 готовых PDF-листов;
- исправленная пояснительная записка;
- инструкции для Quartus/ModelSim;
- список сигналов, которые нужно снять на временных диаграммах.

## Быстрый маршрут перед сдачей

1. Открыть [`variant4_coursework_project/START_HERE.md`](variant4_coursework_project/START_HERE.md).
2. Проверить проект по [`docs/QUARTUS_MODELSIM_RUNBOOK.md`](variant4_coursework_project/docs/QUARTUS_MODELSIM_RUNBOOK.md).
3. Запустить полную модель `tb_system_variant4`.
4. Убедиться, что в transcript есть `tb_system_variant4: TEST PASSED`.
5. Снять waveform по [`docs/SIGNALS.md`](variant4_coursework_project/docs/SIGNALS.md).
6. Взять готовые PDF-схемы из [`variant4_coursework_project/schemes/pdf`](variant4_coursework_project/schemes/pdf/): 4 обязательных листа и 12 детальных дополнительных.
7. Вставить реальные скриншоты и схемы в записку.

## Вариант 4

| Параметр | Значение |
|---|---|
| Архитектура | Гарвардская |
| Шина адреса | 16 бит |
| Шина данных | 16 бит |
| Память | синхронные ROM/RAM |
| РОН | 12 регистров |
| АЛУ | `INCS`, `OR`, `NOR`, `SRA` |
| Стек | 7 слов, рост вниз |
| Кэш | `k = 4`, замещение по наибольшей давности хранения |
| Запись кэша | сквозная |
| Предсказатель | A4, `PC(2) || GHR(2)` |
| КПДП | стартовый адрес `10`, объём `6` байт |
| Арбитраж | централизованный параллельный |

## Структура репозитория

| Путь | Назначение |
|---|---|
| [`variant4_coursework_project`](variant4_coursework_project/) | основной готовый комплект варианта 4 |
| [`variant4_schemes`](variant4_schemes/) | исходная генерация схем `.drawio` |
| [`variant4_vhdl_starter_pack`](variant4_vhdl_starter_pack/) | ранний стартовый набор VHDL |
| [`stack_practical_variant4`](stack_practical_variant4/) | отдельная практическая проверка стека |
| [`Курсовая`](Курсовая/) | исходная пояснительная записка |
| [`Проектирование ЭВМ`](Проектирование%20ЭВМ/) | методические материалы |
| [`Курсовой проект СИФО Вариант 11`](Курсовой%20проект%20СИФО%20Вариант%2011/) | старый пример/референс другого варианта |

## Исправленная записка

Актуальная версия:

[`variant4_coursework_project/report/Записка_Власов_вариант4_исправленная.docx`](variant4_coursework_project/report/Записка_Власов_вариант4_исправленная.docx)

Что уже поправлено:

- удалены старые 8-битные фрагменты из чужого варианта;
- операции АЛУ приведены к варианту 4;
- добавлен двоичный листинг программы;
- добавлены контрольные дампы;
- добавлен состав графической части;
- убрано упоминание Quartus 9.1.

Подробный аудит:

[`variant4_coursework_project/docs/REPORT_AUDIT.md`](variant4_coursework_project/docs/REPORT_AUDIT.md)

## Проверка без Quartus

На macOS Quartus штатно не устанавливается, поэтому локально проект проверялся через
GHDL. Основные testbench проходят:

- `tb_alu_variant4`;
- `tb_stack7x16`;
- `tb_mem_dma`;
- `tb_system_variant4`.

Ожидаемый итог полной модели:

```text
tb_system_variant4: TEST PASSED
```

## Что ещё нужно сделать вручную

Перед финальной сдачей нужно снять реальные скриншоты в Quartus/ModelSim:

- временная диаграмма АЛУ;
- временная диаграмма стека;
- временная диаграмма КПДП и арбитра;
- временная диаграмма полной системы;
- дампы ROM/RAM/cache;
- вставить готовые PDF-схемы из [`variant4_coursework_project/schemes/pdf`](variant4_coursework_project/schemes/pdf/).

Минимальный список сигналов для waveform указан в
[`variant4_coursework_project/docs/SIGNALS.md`](variant4_coursework_project/docs/SIGNALS.md).
