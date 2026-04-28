# С чего начать

1. Открой `docs/QUARTUS_MODELSIM_RUNBOOK.md`.
2. Создай/открой Quartus-проект из `quartus/variant4_coursework.qpf`.
3. В ModelSim запусти скрипт:

```text
do run_tb_system_variant4.do
```

4. Если в transcript есть `tb_system_variant4: TEST PASSED`, снимай скриншоты по `docs/TESTING_SCENARIO.md`.
5. Возьми готовые PDF-схемы из `schemes/pdf/`: 4 основных листа и дополнительные детальные.
6. Вставь схемы, скриншоты и дампы в `Курсовая/Записка Власов.docx` по `docs/REPORT_INTEGRATION_TODO.md`.

Главные файлы:

- `src/system_variant4_top.vhd` - полный верхний модуль.
- `tb/tb_system_variant4.vhd` - полная симуляция.
- `docs/PROGRAM_LISTING.md` - листинг программы для записки.
- `docs/FINAL_CHECKLIST.md` - сверка перед сдачей.
