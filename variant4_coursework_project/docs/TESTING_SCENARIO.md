# Сценарии функционального моделирования

## 1. АЛУ

Testbench: `tb_alu_variant4`.

Вывести сигналы:

```text
a, b, op, y, z, s, c, o
```

Контроль:

| Операция | Входы | Ожидаемый результат |
|---|---|---|
| `SRA` | `A=8001h` | `Y=C000h`, `C=1`, `S=1` |
| `INCS` | `A=C000h`, `FR.S=1` | `Y=C001h` |
| `OR` | `A=00F0h`, `B=0F0Fh` | `Y=0FFFh` |
| `NOR` | `A=0FFFh`, `B=0000h` | `Y=F000h` |
| `INCS` | `A=1234h`, `FR.S=0` | `Y=1234h` |

## 2. Стек

Testbench: `tb_stack7x16`.

Вывести сигналы:

```text
clk, rst, push, pop, din, dout, sp, empty, full
```

Контроль:

- после reset: `SP=7`, `empty=1`, `full=0`;
- после `PUSH C001h`: `SP=6`;
- после `POP`: `DOUT=C001h`, `SP=7`.

## 3. Память, DMA и арбитр

Testbench: `tb_mem_dma`.

Вывести сигналы:

```text
start, dev_valid, dev_data, dma_req, dma_gnt, ram_we, ram_addr, ram_din, dma_done
```

Контроль:

- при `REQ_CPU=1` и `REQ_DMA=1` приоритет должен получать DMA;
- DMA записывает `1111h`, `2222h`, `3333h` по адресам `000Ah`, `000Bh`, `000Ch`;
- после третьего слова появляется `done`.

## 4. Полная система

Testbench: `tb_system_variant4`.

Добавить на waveform:

```text
clk
rst
halt
dma_start
dma_valid
dma_data
dma_done
dbg_state
dbg_pc
dbg_ir0
dbg_ir1
dbg_r1
dbg_r2
dbg_r3
dbg_r4
dbg_r5
dbg_r6
dbg_r7
dbg_flags
dbg_sp
cache_hit
cache_miss
req_cpu
req_dma
gnt_cpu
gnt_dma
ram_we
ram_addr
ram_wdata
ram_rdata
bp_hist
bp_pred
bp_target
```

Контрольные точки:

| Событие | Что должно быть видно |
|---|---|
| Выполнение `SRA R1` | `R1` становится `C000h`, затем после `INCS` - `C001h` |
| `PUSH/POP` | `SP` уходит `7 -> 6 -> 7`, `R3=C001h` |
| `MOV R3, 0030h` | запись `C001h` в RAM по адресу `0030h` |
| DMA | записи `1111h`, `2222h`, `3333h` по адресам `000Ah..000Ch` |
| `NOR R4, 0025h` | `R4=0000h`, устанавливается `Z=1` |
| `JZ 001Ah` | переход выполняется, `R5` остается `0000h` |
| `JMP 001Eh` | команда по `001Ch` пропускается, `R6=0000h` |
| `MOV 000Ah, R7` | `R7=1111h` |
| `HLT` | `halt=1` |

В transcript должно появиться:

```text
tb_system_variant4: TEST PASSED
```

## Минимальный набор скриншотов для записки

1. ALU.
2. Стек.
3. DMA + арбитр + RAM.
4. Полная система, первая половина программы.
5. Полная система, переходы `JZ/JMP` и `HLT`.
6. Предсказатель: обновление `GHR` после `JZ`.
