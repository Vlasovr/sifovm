# Clean waveforms for section 3

Open this Quartus project:

`D:\git\sifovm\coursework_project\wave_projects\section3_clean\quartus\section3_clean.qpf`

The project does not modify the main coursework project. It uses the same
microcomputer modules, but the top entity exposes short, readable pins for
screenshots in section 3.

## Ready waveform files

The `quartus` folder already contains prefilled and simulated waveform files.
Open the needed file and take the screenshot; you do not need to add signals
manually.

- `shot_3_01_memory.vwf`
- `shot_3_02_decoder.vwf`
- `shot_3_03_phase_counter.vwf`
- `shot_3_04_ip_ir.vwf`
- `shot_3_05_stack.vwf`
- `shot_3_06_registers.vwf`
- `shot_3_07_alu.vwf`
- `shot_3_08_cache.vwf`
- `shot_3_09_branch_predictor.vwf`
- `shot_3_10_dma_controller.vwf`
- `shot_3_11_bus_arbiter.vwf`
- `shot_3_12_full_microevm.vwf`

The older `fig_...` files are also present, but the `shot_...` files are safer
for screenshots because Quartus will not reuse a previously opened tab state.

- `fig_3_01_memory.vwf`
- `fig_3_02_decoder.vwf`
- `fig_3_03_phase_counter.vwf`
- `fig_3_04_ip_ir.vwf`
- `fig_3_05_stack.vwf`
- `fig_3_06_registers.vwf`
- `fig_3_07_alu.vwf`
- `fig_3_08_cache.vwf`
- `fig_3_09_branch_predictor.vwf`
- `fig_3_10_dma_controller.vwf`
- `fig_3_11_bus_arbiter.vwf`
- `fig_3_12_full_microevm.vwf`

If you want to recalculate a file, first run `Processing -> Generate Functional
Simulation Netlist`, then open the required `.vwf` file and run
`Processing -> Start Simulation`.

## Required input stimulus

Use these inputs for the full-system run:

- `clk`: clock, period `10 ns`, duty `50%`
- `rst`: `1` from `0 ns` to `30 ns`, then `0`
- `dma_start`: `0` to `100 ns`, `1` from `100 ns` to `120 ns`, then `0`
- `dma_valid`: `0` to `140 ns`, `1` from `140 ns` to `220 ns`, then `0`
- `dma_data`: `0000h` to `140 ns`, `1111h` from `140 ns` to `160 ns`,
  `2222h` from `160 ns` to `180 ns`, `3333h` from `180 ns` to `220 ns`,
  then `0000h`

For figures that do not show DMA, it is also acceptable to keep
`dma_start = 0`, `dma_valid = 0`, `dma_data = 0000h`.

Set `End Time = 3500 ns`.

## How to insert clean buses in Quartus

1. Open the project `section3_clean.qpf`.
2. Run `Processing -> Start -> Start Analysis & Synthesis`.
3. Open `File -> New -> Vector Waveform File`.
4. Open `Edit -> End Time...` and set `3500 ns`.
5. Open `Edit -> Insert -> Insert Node or Bus...`.
6. In `Node Finder`, set `Filter = Pins: all`, then press `List`.
7. Select bus names such as `pc`, `ir0`, `ram_a`, not separate bits like
   `pc[0]`.
8. After adding buses, right click each bus and set `Radix -> Hexadecimal`.
9. Save the file with a name like `fig_3_01_memory.vwf`.
10. Start simulation with `Processing -> Start Simulation`.

If a bus is accidentally expanded into many bit rows, delete those rows and
insert the parent bus again.

## Suggested signal sets

### Figure 3.1 - memory

`clk`, `rst`, `st`, `pc`, `rom_en`, `rom_a`, `rom_d`, `c_req`, `c_we`,
`c_a`, `c_rd`, `ram_we`, `ram_a`, `ram_wd`, `ram_rd`

### Figure 3.2 - command decoder

`clk`, `rst`, `ir0`, `op`, `regn`, `is_mr`, `is_rm`, `is_or`, `is_nor`,
`is_sra`, `is_incs`, `is_push`, `is_pop`, `is_jmp`, `is_jz`, `is_hlt`

### Figure 3.3 - command phase counter

`clk`, `rst`, `st`, `ph_f0`, `ph_f1`, `ph_dec`, `ph_mem`, `ph_alu`,
`ph_stk`, `ph_br`, `ph_fin`, `halt`

### Figure 3.4 - IP and IR

`clk`, `rst`, `pc`, `ir0`, `ir1`, `op`, `regn`, `is_jmp`, `is_jz`,
`is_hlt`, `halt`

### Figure 3.5 - stack

`clk`, `rst`, `st`, `ir0`, `is_push`, `is_pop`, `r1`, `r3`, `sp`, `rf_we`

### Figure 3.6 - general-purpose registers

`clk`, `rst`, `st`, `ir0`, `rf_we`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`,
`r7`, `flg`

### Figure 3.7 - ALU

`clk`, `rst`, `ir0`, `op`, `is_or`, `is_nor`, `is_sra`, `is_incs`, `r1`,
`r2`, `r4`, `flg`, `rf_we`

### Figure 3.8 - cache

`clk`, `rst`, `c_req`, `c_we`, `c_a`, `c_wd`, `c_rd`, `c_rdy`, `c_hit`,
`c_miss`, `req_cpu`, `gnt_cpu`, `ram_we`, `ram_a`, `ram_rd`

### Figure 3.9 - branch predictor

`clk`, `rst`, `pc`, `ir0`, `ir1`, `flg`, `is_jz`, `is_jmp`, `bp_hist`,
`bp_pred`, `bp_tgt`, `halt`

### Figure 3.10 - DMA controller

`clk`, `rst`, `dma_start`, `dma_valid`, `dma_data`, `req_dma`, `gnt_dma`,
`ram_we`, `ram_a`, `ram_wd`, `dma_done`

### Figure 3.11 - bus arbiter

`clk`, `rst`, `req_cpu`, `req_dma`, `gnt_cpu`, `gnt_dma`, `bus_owner`,
`ram_we`, `ram_a`, `ram_wd`, `ram_rd`

### Figure 3.12 - full microcomputer

`clk`, `rst`, `dma_start`, `dma_valid`, `dma_data`, `st`, `pc`, `ir0`,
`ir1`, `r1`, `r2`, `r3`, `r4`, `r5`, `r6`, `r7`, `flg`, `sp`, `c_hit`,
`c_miss`, `req_cpu`, `req_dma`, `gnt_cpu`, `gnt_dma`, `ram_we`, `ram_a`,
`dma_done`, `halt`

## Good screenshot windows

- Fetch/decode and first memory access: `0-450 ns`
- ALU and stack: `250-1000 ns`
- MOV Rn,adr and memory write: `900-1500 ns`
- JZ/JMP/predictor: `1400-2300 ns`
- DMA and arbiter: `80-260 ns`
- Full system: `0-3500 ns`
