vlib work
vmap work work

vcom ../src/variant4_pkg.vhd
vcom ../src/program_image_pkg.vhd
vcom ../src/data_image_pkg.vhd
vcom ../src/alu_variant4.vhd
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
vcom ../src/cpu_core_variant4.vhd
vcom ../src/system_variant4_top.vhd
vcom ../tb/tb_system_variant4.vhd

vsim work.tb_system_variant4
add wave -radix hexadecimal sim:/tb_system_variant4/clk
add wave -radix hexadecimal sim:/tb_system_variant4/rst
add wave -radix hexadecimal sim:/tb_system_variant4/halt
add wave -radix hexadecimal sim:/tb_system_variant4/dma_start
add wave -radix hexadecimal sim:/tb_system_variant4/dma_valid
add wave -radix hexadecimal sim:/tb_system_variant4/dma_data
add wave -radix hexadecimal sim:/tb_system_variant4/dma_done
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_state
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_pc
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_ir0
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_ir1
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r1
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r2
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r3
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r4
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r5
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r6
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_r7
add wave -radix hexadecimal sim:/tb_system_variant4/dbg_flags
add wave -radix unsigned sim:/tb_system_variant4/dbg_sp
add wave -radix hexadecimal sim:/tb_system_variant4/cache_hit
add wave -radix hexadecimal sim:/tb_system_variant4/cache_miss
add wave -radix hexadecimal sim:/tb_system_variant4/req_cpu
add wave -radix hexadecimal sim:/tb_system_variant4/req_dma
add wave -radix hexadecimal sim:/tb_system_variant4/gnt_cpu
add wave -radix hexadecimal sim:/tb_system_variant4/gnt_dma
add wave -radix hexadecimal sim:/tb_system_variant4/ram_we
add wave -radix hexadecimal sim:/tb_system_variant4/ram_addr
add wave -radix hexadecimal sim:/tb_system_variant4/ram_wdata
add wave -radix hexadecimal sim:/tb_system_variant4/ram_rdata
add wave -radix binary sim:/tb_system_variant4/bp_hist
add wave -radix hexadecimal sim:/tb_system_variant4/bp_pred
add wave -radix hexadecimal sim:/tb_system_variant4/bp_target

run 5 us
