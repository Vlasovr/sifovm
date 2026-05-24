library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_microevm_row1_control_top is
  port (
    clock             : in  std_logic;
    reset             : in  std_logic;
    enable            : in  std_logic;
    IR_valid          : in  std_logic;
    cmd_code          : in  std_logic_vector(7 downto 0);
    addr_i            : in  addr_t;
    data_i            : in  word_t;
    aux_i             : in  word_t;
    ctrl_i            : in  std_logic_vector(7 downto 0);

    DBG_PHASE         : out std_logic_vector(3 downto 0);
    DBG_CMD_MATCH     : out std_logic_vector(2 downto 0);
    DBG_DECODER_CTRL  : out std_logic_vector(7 downto 0);
    DBG_IP            : out addr_t;
    DBG_IR            : out word_t;
    DBG_ROM_DATA      : out word_t;
    DBG_RON_A         : out word_t;
    DBG_RON_B         : out word_t;
    DBG_ALU_RESULT    : out word_t;
    DBG_FLAGS         : out std_logic_vector(3 downto 0);
    DBG_BP_TARGET     : out addr_t;
    DBG_BP_STATUS     : out std_logic_vector(2 downto 0)
  );
end entity;

architecture structural of appendix_n_microevm_row1_control_top is
  signal phase_fetch_s       : std_logic; -- synthesis keep
  signal phase_addr_h_s      : std_logic; -- synthesis keep
  signal phase_exec_s        : std_logic; -- synthesis keep
  signal phase_addr_l_s      : std_logic; -- synthesis keep
  signal ip_s                : addr_t; -- synthesis keep
  signal ir_s                : word_t; -- synthesis keep
  signal addr_h_s            : word_t; -- synthesis keep
  signal addr_l_s            : word_t; -- synthesis keep
  signal branch_s            : std_logic; -- synthesis keep
  signal ip_load_s           : std_logic; -- synthesis keep
  signal ip_inc_s            : std_logic; -- synthesis keep
  signal halt_s              : std_logic; -- synthesis keep
  signal reg_write_s         : std_logic; -- synthesis keep
  signal notz_en_s           : std_logic; -- synthesis keep
  signal mem_write_s         : std_logic; -- synthesis keep
  signal mem_read_s          : std_logic; -- synthesis keep
  signal push_en_s           : std_logic; -- synthesis keep
  signal pop_en_s            : std_logic; -- synthesis keep
  signal sload_s             : std_logic; -- synthesis keep
  signal alu_op_s            : std_logic_vector(2 downto 0); -- synthesis keep
  signal reg_addr_s          : reg_idx_t; -- synthesis keep
  signal cmp_jmp_s           : std_logic; -- synthesis keep
  signal cmp_mem_to_reg_s    : std_logic; -- synthesis keep
  signal cmp_reg_to_mem_s    : std_logic; -- synthesis keep
  signal rom_data_s          : word_t; -- synthesis keep
  signal bp_hist_s           : std_logic_vector(1 downto 0); -- synthesis keep
  signal bp_pred_s           : std_logic; -- synthesis keep
  signal bp_target_s         : addr_t; -- synthesis keep
  signal ron_a_s             : word_t; -- synthesis keep
  signal ron_b_s             : word_t; -- synthesis keep
  signal alu_y_s             : word_t; -- synthesis keep
  signal alu_z_s             : std_logic; -- synthesis keep
  signal alu_s_s             : std_logic; -- synthesis keep
  signal alu_c_s             : std_logic; -- synthesis keep
  signal alu_o_s             : std_logic; -- synthesis keep
  signal flag_z_s            : std_logic; -- synthesis keep
  signal flag_s_s            : std_logic; -- synthesis keep
  signal flag_c_s            : std_logic; -- synthesis keep
  signal flag_o_s            : std_logic; -- synthesis keep
begin
  DBG_PHASE        <= phase_fetch_s & phase_addr_h_s & phase_exec_s & phase_addr_l_s;
  DBG_CMD_MATCH    <= cmp_jmp_s & cmp_mem_to_reg_s & cmp_reg_to_mem_s;
  DBG_DECODER_CTRL <= halt_s & reg_write_s & notz_en_s & mem_write_s & mem_read_s & push_en_s & pop_en_s & sload_s;
  DBG_IP           <= ip_s;
  DBG_IR           <= ir_s;
  DBG_ROM_DATA     <= rom_data_s;
  DBG_RON_A        <= ron_a_s;
  DBG_RON_B        <= ron_b_s;
  DBG_ALU_RESULT   <= alu_y_s;
  DBG_FLAGS        <= flag_z_s & flag_s_s & flag_c_s & flag_o_s;
  DBG_BP_TARGET    <= bp_target_s;
  DBG_BP_STATUS    <= bp_pred_s & bp_hist_s;

  U_PHASE_COUNTER_UNIT : entity work.appendix_n_phase_counter_unit
    port map (IR_valid, reset, clock, phase_fetch_s, phase_addr_h_s, phase_exec_s, phase_addr_l_s);

  U_SPECIAL_REGISTERS : entity work.appendix_n_special_registers
    port map (clock, reset, ctrl_i(0), ctrl_i(1), IR_valid, ctrl_i(2), ctrl_i(3), data_i, addr_i, ip_s, ir_s, addr_h_s, addr_l_s);

  U_COMMAND_MEMORY_ROM : entity work.rom_sync
    port map (clock, enable, addr_i, rom_data_s);

  U_BRANCH_PREDICTOR : entity work.branch_predictor
    port map (clock, reset, ctrl_i(0), addr_i, bp_hist_s, bp_pred_s, bp_target_s, ctrl_i(1), addr_i, ctrl_i(3 downto 2), ctrl_i(4), aux_i);

  U_CMP_IS_JMP : entity work.appendix_n_cmp_is_jmp
    port map (cmd_code, cmp_jmp_s);

  U_CMP_IS_MEM_TO_REG : entity work.appendix_n_cmp_is_mem_to_reg
    port map (cmd_code, cmp_mem_to_reg_s);

  U_CMP_IS_REG_TO_MEM : entity work.appendix_n_cmp_is_reg_to_mem
    port map (cmd_code, cmp_reg_to_mem_s);

  U_DECODER_UNIT : entity work.appendix_n_decoder_unit
    port map (cmd_code, ctrl_i(4), ctrl_i(5), branch_s, ip_load_s, ip_inc_s, halt_s, alu_op_s, reg_write_s, notz_en_s, mem_write_s, mem_read_s, push_en_s, pop_en_s, sload_s, reg_addr_s);

  U_ALU_RON_REGISTER_FILE : entity work.reg_file12x16_dbg
    port map (
      clock, reset, enable, unsigned(ctrl_i(3 downto 0)), unsigned(addr_i(3 downto 0)), unsigned(addr_i(7 downto 4)),
      data_i, ron_a_s, ron_b_s, open, open, open, open, open, open, open, open, open, open, open, open
    );

  U_ALU_UNIT : entity work.alu_core
    port map (data_i, aux_i, ctrl_i(6), ctrl_i(2 downto 0), alu_y_s, alu_z_s, alu_s_s, alu_c_s, alu_o_s);

  U_FLAGS_REGISTER : entity work.flags_reg
    port map (clock, reset, enable, alu_z_s, alu_s_s, alu_c_s, alu_o_s, flag_z_s, flag_s_s, flag_c_s, flag_o_s);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_microevm_row2_memory_top is
  port (
    clock             : in  std_logic;
    reset             : in  std_logic;
    enable            : in  std_logic;
    DMA_START         : in  std_logic;
    DMA_TEST_DATA     : in  std_logic_vector(7 downto 0);
    dmac_read         : in  std_logic;
    addr_i            : in  addr_t;
    data_i            : in  word_t;
    aux_i             : in  word_t;
    ctrl_i            : in  std_logic_vector(7 downto 0);

    DBG_MUX_DATA      : out word_t;
    DBG_MUX_ADDR      : out word_t;
    DBG_STACK_DATA    : out word_t;
    DBG_STACK_STATUS  : out std_logic_vector(1 downto 0);
    DBG_CACHE_DATA    : out word_t;
    DBG_CACHE_STATUS  : out std_logic_vector(1 downto 0);
    DBG_DMA_ADDR      : out addr_t;
    DBG_DMA_DATA      : out word_t;
    DBG_DMA_STATUS    : out std_logic_vector(1 downto 0);
    DBG_BUS_GRANT     : out std_logic_vector(1 downto 0);
    DBG_MEMORY_DATA   : out word_t
  );
end entity;

architecture structural of appendix_n_microevm_row2_memory_top is
  signal mux_data_source_s   : word_t; -- synthesis keep
  signal mux_mem_stack_s     : word_t; -- synthesis keep
  signal mux_cpu_addr_s      : word_t; -- synthesis keep
  signal mux_sys_addr_s      : word_t; -- synthesis keep
  signal mux_final_addr_s    : word_t; -- synthesis keep
  signal mux_mem_s           : word_t; -- synthesis keep
  signal stack_data_s        : word_t; -- synthesis keep
  signal stack_sp_s          : unsigned(2 downto 0); -- synthesis keep
  signal stack_empty_s       : std_logic; -- synthesis keep
  signal stack_full_s        : std_logic; -- synthesis keep
  signal cache_data_s        : word_t; -- synthesis keep
  signal cache_ready_s       : std_logic; -- synthesis keep
  signal cache_hit_s         : std_logic; -- synthesis keep
  signal cache_miss_s        : std_logic; -- synthesis keep
  signal dma_addr_s          : addr_t; -- synthesis keep
  signal dma_data_s          : word_t; -- synthesis keep
  signal dma_req_s           : std_logic; -- synthesis keep
  signal dma_busy_s          : std_logic; -- synthesis keep
  signal dma_done_s          : std_logic; -- synthesis keep
  signal grant_cpu_s         : std_logic; -- synthesis keep
  signal grant_dma_s         : std_logic; -- synthesis keep
  signal memory_data_s       : word_t; -- synthesis keep
begin
  DBG_MUX_DATA     <= mux_data_source_s xor mux_mem_stack_s xor mux_mem_s;
  DBG_MUX_ADDR     <= mux_cpu_addr_s xor mux_sys_addr_s xor mux_final_addr_s;
  DBG_STACK_DATA   <= stack_data_s;
  DBG_STACK_STATUS <= stack_full_s & stack_empty_s;
  DBG_CACHE_DATA   <= cache_data_s;
  DBG_CACHE_STATUS <= cache_hit_s & cache_miss_s;
  DBG_DMA_ADDR     <= dma_addr_s;
  DBG_DMA_DATA     <= dma_data_s;
  DBG_DMA_STATUS   <= dma_busy_s & dma_done_s;
  DBG_BUS_GRANT    <= grant_cpu_s & grant_dma_s;
  DBG_MEMORY_DATA  <= memory_data_s;

  U_MUX_DATA_SOURCE : entity work.appendix_n_mux2_16
    port map (ctrl_i(0), data_i, aux_i, mux_data_source_s);

  U_MUX_MEM_STACK : entity work.appendix_n_mux2_16
    port map (ctrl_i(1), data_i, aux_i, mux_mem_stack_s);

  U_MUX_CPU_ADDR : entity work.appendix_n_mux2_16
    port map (ctrl_i(2), addr_i, aux_i, mux_cpu_addr_s);

  U_MUX_SYS_ADDR : entity work.appendix_n_mux2_16
    port map (ctrl_i(3), addr_i, aux_i, mux_sys_addr_s);

  U_MUX_FINAL_ADDR : entity work.appendix_n_mux2_16
    port map (ctrl_i(4), addr_i, aux_i, mux_final_addr_s);

  U_LPM_MUX_MEM : entity work.appendix_n_mux2_16
    port map (ctrl_i(5), data_i, aux_i, mux_mem_s);

  U_STACK_CONTROL : entity work.stack7x16
    port map (clock, reset, ctrl_i(0), ctrl_i(1), data_i, stack_data_s, stack_sp_s, stack_empty_s, stack_full_s);

  U_DATA_CACHE : entity work.cache_4way_age
    port map (clock, reset, ctrl_i(0), ctrl_i(1), addr_i, data_i, cache_data_s, cache_ready_s, cache_hit_s, cache_miss_s, open, open, open, open, aux_i, ctrl_i(2));

  U_DMAC_CONTROLLER : entity work.dma_controller_3word
    port map (clock, reset, DMA_START, ctrl_i(0), dmac_read, x"00" & DMA_TEST_DATA, dma_req_s, dma_busy_s, dma_done_s, open, dma_addr_s, dma_data_s);

  U_BUS_ARBITER : entity work.bus_arbiter_2master
    port map (ctrl_i(0), ctrl_i(1), grant_cpu_s, grant_dma_s);

  U_MEMORY : entity work.ram_sync
    port map (clock, enable, ctrl_i(0), addr_i, data_i, memory_data_s);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_microevm_2row_top is
  port (
    clock             : in  std_logic;
    reset             : in  std_logic;
    enable            : in  std_logic;
    DMA_START         : in  std_logic;
    DMA_TEST_DATA     : in  std_logic_vector(7 downto 0);
    dmac_read         : in  std_logic;
    IR_valid          : in  std_logic;
    cmd_code          : in  std_logic_vector(7 downto 0);
    addr_i            : in  addr_t;
    data_i            : in  word_t;
    aux_i             : in  word_t;
    ctrl_i            : in  std_logic_vector(7 downto 0);

    ROW1_STATUS       : out word_t;
    ROW2_STATUS       : out word_t;
    ROW1_FLAGS        : out std_logic_vector(7 downto 0);
    ROW2_FLAGS        : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of appendix_n_microevm_2row_top is
  signal phase_s       : std_logic_vector(3 downto 0);
  signal cmd_match_s   : std_logic_vector(2 downto 0);
  signal decoder_s     : std_logic_vector(7 downto 0);
  signal ip_s          : addr_t;
  signal ir_s          : word_t;
  signal rom_s         : word_t;
  signal ron_a_s       : word_t;
  signal ron_b_s       : word_t;
  signal alu_s         : word_t;
  signal flags_s       : std_logic_vector(3 downto 0);
  signal bp_target_s   : addr_t;
  signal bp_status_s   : std_logic_vector(2 downto 0);
  signal mux_data_s    : word_t;
  signal mux_addr_s    : word_t;
  signal stack_s       : word_t;
  signal stack_stat_s  : std_logic_vector(1 downto 0);
  signal cache_s       : word_t;
  signal cache_stat_s  : std_logic_vector(1 downto 0);
  signal dma_addr_s    : addr_t;
  signal dma_data_s    : word_t;
  signal dma_stat_s    : std_logic_vector(1 downto 0);
  signal bus_grant_s   : std_logic_vector(1 downto 0);
  signal memory_s      : word_t;
begin
  ROW1_STATUS <= ip_s xor ir_s xor rom_s xor ron_a_s xor ron_b_s xor alu_s xor bp_target_s;
  ROW2_STATUS <= mux_data_s xor mux_addr_s xor stack_s xor cache_s xor dma_addr_s xor dma_data_s xor memory_s;
  ROW1_FLAGS  <= phase_s & flags_s;
  ROW2_FLAGS  <= stack_stat_s & cache_stat_s & dma_stat_s & bus_grant_s;

  U_ROW_1_CONTROL_AND_ALU : entity work.appendix_n_microevm_row1_control_top
    port map (
      clock, reset, enable, IR_valid, cmd_code, addr_i, data_i, aux_i, ctrl_i,
      phase_s, cmd_match_s, decoder_s, ip_s, ir_s, rom_s, ron_a_s, ron_b_s, alu_s, flags_s, bp_target_s, bp_status_s
    );

  U_ROW_2_MEMORY_DMA_BUS : entity work.appendix_n_microevm_row2_memory_top
    port map (
      clock, reset, enable, DMA_START, DMA_TEST_DATA, dmac_read, addr_i, data_i, aux_i, ctrl_i,
      mux_data_s, mux_addr_s, stack_s, stack_stat_s, cache_s, cache_stat_s, dma_addr_s, dma_data_s, dma_stat_s, bus_grant_s, memory_s
    );
end architecture;
