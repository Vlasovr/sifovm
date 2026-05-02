vlib work
vmap work work

vcom ../src/microcomputer_pkg.vhd
vcom ../src/program_image_pkg.vhd
vcom ../src/data_image_pkg.vhd
vcom ../src/alu_core.vhd
vcom ../src/reg_file12x16.vhd
vcom ../src/reg_file12x16_dbg.vhd
vcom ../src/flags_reg.vhd
vcom ../src/stack7x16.vhd
vcom ../src/rom_sync.vhd
vcom ../src/ram_sync.vhd
vcom ../src/bus_arbiter_2master.vhd
vcom ../src/dma_controller_3word.vhd
vcom ../src/branch_predictor.vhd
vcom ../src/cache_4way_age.vhd
vcom ../src/cpu_core.vhd
vcom ../src/system_core.vhd
vcom ../src/microcomputer_top.vhd
vcom ../tb/tb_system.vhd

vsim work.tb_system
add wave -radix hexadecimal sim:/tb_system/clk
add wave -radix hexadecimal sim:/tb_system/rst
add wave -radix hexadecimal sim:/tb_system/halt
add wave -radix hexadecimal sim:/tb_system/dma_start
add wave -radix hexadecimal sim:/tb_system/dma_valid
add wave -radix hexadecimal sim:/tb_system/dma_data
add wave -radix hexadecimal sim:/tb_system/dma_done
add wave -radix hexadecimal sim:/tb_system/dbg_state
add wave -radix hexadecimal sim:/tb_system/dbg_pc
add wave -radix hexadecimal sim:/tb_system/dbg_ir0
add wave -radix hexadecimal sim:/tb_system/dbg_ir1
add wave -radix hexadecimal sim:/tb_system/dbg_r1
add wave -radix hexadecimal sim:/tb_system/dbg_r2
add wave -radix hexadecimal sim:/tb_system/dbg_r3
add wave -radix hexadecimal sim:/tb_system/dbg_r4
add wave -radix hexadecimal sim:/tb_system/dbg_r5
add wave -radix hexadecimal sim:/tb_system/dbg_r6
add wave -radix hexadecimal sim:/tb_system/dbg_r7
add wave -radix hexadecimal sim:/tb_system/dbg_flags
add wave -radix unsigned sim:/tb_system/dbg_sp
add wave -radix hexadecimal sim:/tb_system/cache_hit
add wave -radix hexadecimal sim:/tb_system/cache_miss
add wave -radix hexadecimal sim:/tb_system/req_cpu
add wave -radix hexadecimal sim:/tb_system/req_dma
add wave -radix hexadecimal sim:/tb_system/gnt_cpu
add wave -radix hexadecimal sim:/tb_system/gnt_dma
add wave -radix hexadecimal sim:/tb_system/ram_we
add wave -radix hexadecimal sim:/tb_system/ram_addr
add wave -radix hexadecimal sim:/tb_system/ram_wdata
add wave -radix hexadecimal sim:/tb_system/ram_rdata
add wave -radix binary sim:/tb_system/bp_hist
add wave -radix hexadecimal sim:/tb_system/bp_pred
add wave -radix hexadecimal sim:/tb_system/bp_target

run 5 us
