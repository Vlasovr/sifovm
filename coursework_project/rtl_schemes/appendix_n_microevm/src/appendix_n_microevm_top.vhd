library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_phase_counter_unit is
  port (
    sload_i     : in  std_logic;
    reset_i     : in  std_logic;
    clock_i     : in  std_logic;
    is_fetch_o  : out std_logic;
    is_addr_h_o : out std_logic;
    is_exec_o   : out std_logic;
    is_addr_l_o : out std_logic
  );
end entity;

architecture rtl of appendix_n_phase_counter_unit is
  signal phase_r : unsigned(1 downto 0) := (others => '0');
begin
  process(clock_i)
  begin
    if rising_edge(clock_i) then
      if reset_i = '1' then
        phase_r <= (others => '0');
      elsif sload_i = '1' then
        phase_r <= phase_r + 1;
      end if;
    end if;
  end process;

  is_fetch_o  <= '1' when phase_r = "00" else '0';
  is_addr_h_o <= '1' when phase_r = "01" else '0';
  is_exec_o   <= '1' when phase_r = "10" else '0';
  is_addr_l_o <= '1' when phase_r = "11" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_special_registers is
  port (
    clock_i            : in  std_logic;
    reset_i            : in  std_logic;
    ip_inc_i           : in  std_logic;
    ip_load_i          : in  std_logic;
    ir_load_i          : in  std_logic;
    addr_h_load_i      : in  std_logic;
    addr_l_load_i      : in  std_logic;
    cache_cpu_data_i   : in  word_t;
    jmp_target_addr_i  : in  addr_t;
    ip_out_o           : out addr_t;
    ir_out_o           : out word_t;
    addr_h_out_o       : out word_t;
    addr_l_out_o       : out word_t
  );
end entity;

architecture rtl of appendix_n_special_registers is
  signal ip_r     : addr_t := (others => '0');
  signal ir_r     : word_t := (others => '0');
  signal addr_h_r : word_t := (others => '0');
  signal addr_l_r : word_t := (others => '0');
begin
  process(clock_i)
  begin
    if rising_edge(clock_i) then
      if reset_i = '1' then
        ip_r     <= (others => '0');
        ir_r     <= (others => '0');
        addr_h_r <= (others => '0');
        addr_l_r <= (others => '0');
      else
        if ip_load_i = '1' then
          ip_r <= jmp_target_addr_i;
        elsif ip_inc_i = '1' then
          ip_r <= std_logic_vector(unsigned(ip_r) + 1);
        end if;

        if ir_load_i = '1' then
          ir_r <= cache_cpu_data_i;
        end if;
        if addr_h_load_i = '1' then
          addr_h_r <= cache_cpu_data_i;
        end if;
        if addr_l_load_i = '1' then
          addr_l_r <= cache_cpu_data_i;
        end if;
      end if;
    end if;
  end process;

  ip_out_o     <= ip_r;
  ir_out_o     <= ir_r;
  addr_h_out_o <= addr_h_r;
  addr_l_out_o <= addr_l_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_decoder_unit is
  port (
    cmd_code_i  : in  std_logic_vector(7 downto 0);
    flag_z_i    : in  std_logic;
    is_exec_i   : in  std_logic;
    branch_o    : out std_logic;
    ip_load_o   : out std_logic;
    ip_inc_o    : out std_logic;
    cpu_halt_o  : out std_logic;
    alu_op_o    : out std_logic_vector(2 downto 0);
    reg_write_o : out std_logic;
    notz_en_o   : out std_logic;
    mem_write_o : out std_logic;
    mem_read_o  : out std_logic;
    push_en_o   : out std_logic;
    pop_en_o    : out std_logic;
    sload_o     : out std_logic;
    reg_addr_o  : out reg_idx_t
  );
end entity;

architecture rtl of appendix_n_decoder_unit is
  signal is_jmp_s    : std_logic;
  signal is_jz_s     : std_logic;
  signal is_branch_s : std_logic;
begin
  is_jmp_s    <= '1' when cmd_code_i = OP_JMP else '0';
  is_jz_s     <= '1' when cmd_code_i = OP_JZ else '0';
  is_branch_s <= is_jmp_s or is_jz_s;

  branch_o    <= is_branch_s;
  ip_load_o   <= is_exec_i and (is_jmp_s or (is_jz_s and flag_z_i));
  ip_inc_o    <= is_exec_i and not is_branch_s;
  cpu_halt_o  <= '1' when cmd_code_i = OP_HLT else '0';
  reg_write_o <= '1' when cmd_code_i = OP_MOV_MR or
                          cmd_code_i = OP_OR or
                          cmd_code_i = OP_NOR or
                          cmd_code_i = OP_SRA or
                          cmd_code_i = OP_INCS or
                          cmd_code_i = OP_POP else '0';
  notz_en_o   <= '1' when cmd_code_i = OP_JZ and flag_z_i = '0' else '0';
  mem_write_o <= '1' when cmd_code_i = OP_MOV_RM else '0';
  mem_read_o  <= '1' when cmd_code_i = OP_MOV_MR else '0';
  push_en_o   <= '1' when cmd_code_i = OP_PUSH else '0';
  pop_en_o    <= '1' when cmd_code_i = OP_POP else '0';
  sload_o     <= is_exec_i or is_branch_s;
  reg_addr_o  <= unsigned(cmd_code_i(3 downto 0));

  alu_op_o <= ALU_OR   when cmd_code_i = OP_OR else
              ALU_NOR  when cmd_code_i = OP_NOR else
              ALU_SRA  when cmd_code_i = OP_SRA else
              ALU_INCS when cmd_code_i = OP_INCS else
              ALU_PASS_A;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_n_cmp_is_jmp is
  port (
    cmd_code_i : in  std_logic_vector(7 downto 0);
    aeb_o      : out std_logic
  );
end entity;

architecture rtl of appendix_n_cmp_is_jmp is
begin
  aeb_o <= '1' when cmd_code_i = OP_JMP or cmd_code_i = OP_JZ else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_n_cmp_is_mem_to_reg is
  port (
    cmd_code_i : in  std_logic_vector(7 downto 0);
    aeb_o      : out std_logic
  );
end entity;

architecture rtl of appendix_n_cmp_is_mem_to_reg is
begin
  aeb_o <= '1' when cmd_code_i = OP_MOV_MR else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_n_cmp_is_reg_to_mem is
  port (
    cmd_code_i : in  std_logic_vector(7 downto 0);
    aeb_o      : out std_logic
  );
end entity;

architecture rtl of appendix_n_cmp_is_reg_to_mem is
begin
  aeb_o <= '1' when cmd_code_i = OP_MOV_RM else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_n_mux2_16 is
  port (
    sel_i    : in  std_logic;
    data0_i  : in  word_t;
    data1_i  : in  word_t;
    result_o : out word_t
  );
end entity;

architecture rtl of appendix_n_mux2_16 is
begin
  result_o <= data1_i when sel_i = '1' else data0_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_n_microevm_top is
  port (
    clock             : in  std_logic;
    reset             : in  std_logic;
    DMA_START         : in  std_logic;
    DMA_TEST_DATA     : in  std_logic_vector(7 downto 0);
    dmac_read         : in  std_logic;
    IR_valid          : in  std_logic;

    DBG_BUS_BUSY      : out std_logic;
    DBG_GHR           : out std_logic_vector(3 downto 0);
    DBG_S             : out std_logic;
    DBG_CF            : out std_logic;
    CPU_HALT          : out std_logic;
    NOTZ_en           : out std_logic;
    DBG_STACK_FULL    : out std_logic;
    DBG_STACK_EMPTY   : out std_logic;
    DBG_DMA_BUSY      : out std_logic;
    DBG_DMA_DONE      : out std_logic;
    DBG_HIT           : out std_logic;
    DBG_MISS          : out std_logic;
    DBG_IP            : out addr_t;
    DBG_IR            : out word_t;
    DBG_ALU_RESULT    : out word_t;
    DBG_MEMORY_DATA   : out word_t
  );
end entity;

architecture structural of appendix_n_microevm_top is
  signal phase_sload_s      : std_logic; -- synthesis keep
  signal is_fetch_s         : std_logic; -- synthesis keep
  signal is_addr_h_s        : std_logic; -- synthesis keep
  signal is_exec_s          : std_logic; -- synthesis keep
  signal is_addr_l_s        : std_logic; -- synthesis keep

  signal ip_out_s           : addr_t; -- synthesis keep
  signal ir_out_s           : word_t; -- synthesis keep
  signal addr_h_out_s       : word_t; -- synthesis keep
  signal addr_l_out_s       : word_t; -- synthesis keep
  signal special_addr_s     : addr_t; -- synthesis keep
  signal branch_target_s    : addr_t; -- synthesis keep

  signal branch_s           : std_logic; -- synthesis keep
  signal ip_load_s          : std_logic; -- synthesis keep
  signal ip_inc_s           : std_logic; -- synthesis keep
  signal decoder_halt_s     : std_logic; -- synthesis keep
  signal alu_op_s           : std_logic_vector(2 downto 0); -- synthesis keep
  signal reg_write_s        : std_logic; -- synthesis keep
  signal notz_en_s          : std_logic; -- synthesis keep
  signal mem_write_dec_s    : std_logic; -- synthesis keep
  signal mem_read_dec_s     : std_logic; -- synthesis keep
  signal push_en_s          : std_logic; -- synthesis keep
  signal pop_en_s           : std_logic; -- synthesis keep
  signal reg_addr_s         : reg_idx_t; -- synthesis keep

  signal cmp_jmp_s          : std_logic; -- synthesis keep
  signal cmp_mem_to_reg_s   : std_logic; -- synthesis keep
  signal cmp_reg_to_mem_s   : std_logic; -- synthesis keep
  signal is_3_byte_cmd_s    : std_logic; -- synthesis keep

  signal command_word_s     : word_t; -- synthesis keep
  signal reg_a_s            : word_t; -- synthesis keep
  signal reg_b_s            : word_t; -- synthesis keep
  signal reg_write_data_s   : word_t; -- synthesis keep
  signal alu_result_s       : word_t; -- synthesis keep
  signal flag_z_s           : std_logic; -- synthesis keep
  signal flag_s_s           : std_logic; -- synthesis keep
  signal flag_c_s           : std_logic; -- synthesis keep
  signal flag_o_s           : std_logic; -- synthesis keep

  signal stack_data_s       : word_t; -- synthesis keep
  signal stack_sp_s         : unsigned(2 downto 0); -- synthesis keep
  signal stack_empty_s      : std_logic; -- synthesis keep
  signal stack_full_s       : std_logic; -- synthesis keep
  signal stack_or_reg_s     : word_t; -- synthesis keep

  signal bp_hist_s          : std_logic_vector(1 downto 0); -- synthesis keep
  signal bp_prediction_s    : std_logic; -- synthesis keep
  signal bp_target_s        : addr_t; -- synthesis keep

  signal cpu_addr_s         : addr_t; -- synthesis keep
  signal sys_addr_s         : addr_t; -- synthesis keep
  signal final_addr_s       : addr_t; -- synthesis keep
  signal cache_cpu_data_s   : word_t; -- synthesis keep
  signal cache_ready_s      : std_logic; -- synthesis keep
  signal cache_hit_s        : std_logic; -- synthesis keep
  signal cache_miss_s       : std_logic; -- synthesis keep
  signal cache_mem_req_s    : std_logic; -- synthesis keep
  signal cache_mem_we_s     : std_logic; -- synthesis keep
  signal cache_mem_addr_s   : addr_t; -- synthesis keep
  signal cache_mem_wdata_s  : word_t; -- synthesis keep

  signal dmac_request_s     : std_logic; -- synthesis keep
  signal dmac_busy_s        : std_logic; -- synthesis keep
  signal dmac_done_s        : std_logic; -- synthesis keep
  signal dmac_write_s       : std_logic; -- synthesis keep
  signal dmac_addr_s        : addr_t; -- synthesis keep
  signal dmac_data_s        : word_t; -- synthesis keep

  signal grant_cpu_s        : std_logic; -- synthesis keep
  signal grant_dmac_s       : std_logic; -- synthesis keep
  signal memory_en_s        : std_logic; -- synthesis keep
  signal memory_write_s     : std_logic; -- synthesis keep
  signal memory_data_in_s   : word_t; -- synthesis keep
  signal memory_data_out_s  : word_t; -- synthesis keep
begin
  special_addr_s  <= addr_h_out_s(15 downto 8) & addr_l_out_s(7 downto 0);
  branch_target_s <= ir_out_s;
  is_3_byte_cmd_s <= cmp_jmp_s or cmp_mem_to_reg_s or cmp_reg_to_mem_s;
  phase_sload_s   <= IR_valid or is_3_byte_cmd_s or branch_s;

  memory_en_s     <= grant_cpu_s or grant_dmac_s;
  memory_write_s  <= (cache_mem_we_s and grant_cpu_s) or (dmac_write_s and grant_dmac_s);

  DBG_BUS_BUSY    <= grant_cpu_s or grant_dmac_s;
  DBG_GHR         <= "00" & bp_hist_s;
  DBG_S           <= flag_s_s;
  DBG_CF          <= flag_c_s;
  CPU_HALT        <= decoder_halt_s;
  NOTZ_en         <= notz_en_s;
  DBG_STACK_FULL  <= stack_full_s;
  DBG_STACK_EMPTY <= stack_empty_s;
  DBG_DMA_BUSY    <= dmac_busy_s;
  DBG_DMA_DONE    <= dmac_done_s;
  DBG_HIT         <= cache_hit_s;
  DBG_MISS        <= cache_miss_s;
  DBG_IP          <= ip_out_s;
  DBG_IR          <= ir_out_s;
  DBG_ALU_RESULT  <= alu_result_s;
  DBG_MEMORY_DATA <= memory_data_out_s;

  U_PHASE_COUNTER_UNIT : entity work.appendix_n_phase_counter_unit
    port map (
      sload_i     => phase_sload_s,
      reset_i     => reset,
      clock_i     => clock,
      is_fetch_o  => is_fetch_s,
      is_addr_h_o => is_addr_h_s,
      is_exec_o   => is_exec_s,
      is_addr_l_o => is_addr_l_s
    );

  U_SPECIAL_REGISTERS : entity work.appendix_n_special_registers
    port map (
      clock_i           => clock,
      reset_i           => reset,
      ip_inc_i          => ip_inc_s,
      ip_load_i         => ip_load_s,
      ir_load_i         => IR_valid,
      addr_h_load_i     => is_addr_h_s,
      addr_l_load_i     => is_addr_l_s,
      cache_cpu_data_i  => command_word_s,
      jmp_target_addr_i => branch_target_s,
      ip_out_o          => ip_out_s,
      ir_out_o          => ir_out_s,
      addr_h_out_o      => addr_h_out_s,
      addr_l_out_o      => addr_l_out_s
    );

  U_COMMAND_MEMORY_ROM : entity work.rom_sync
    port map (
      clk_i  => clock,
      en_i   => is_fetch_s,
      addr_i => ip_out_s,
      data_o => command_word_s
    );

  U_BRANCH_PREDICTOR : entity work.branch_predictor
    port map (
      clk_i          => clock,
      rst_i          => reset,
      query_valid_i  => is_fetch_s,
      pc_query_i     => ip_out_s,
      hist_o         => bp_hist_s,
      pred_taken_o   => bp_prediction_s,
      pred_target_o  => bp_target_s,
      update_valid_i => branch_s,
      pc_update_i    => ip_out_s,
      hist_i         => bp_hist_s,
      actual_taken_i => flag_z_s,
      actual_tgt_i   => branch_target_s
    );

  U_CMP_IS_JMP : entity work.appendix_n_cmp_is_jmp
    port map (
      cmd_code_i => ir_out_s(15 downto 8),
      aeb_o      => cmp_jmp_s
    );

  U_CMP_IS_MEM_TO_REG : entity work.appendix_n_cmp_is_mem_to_reg
    port map (
      cmd_code_i => ir_out_s(15 downto 8),
      aeb_o      => cmp_mem_to_reg_s
    );

  U_CMP_IS_REG_TO_MEM : entity work.appendix_n_cmp_is_reg_to_mem
    port map (
      cmd_code_i => ir_out_s(15 downto 8),
      aeb_o      => cmp_reg_to_mem_s
    );

  U_DECODER_UNIT : entity work.appendix_n_decoder_unit
    port map (
      cmd_code_i  => ir_out_s(15 downto 8),
      flag_z_i    => flag_z_s,
      is_exec_i   => is_exec_s,
      branch_o    => branch_s,
      ip_load_o   => ip_load_s,
      ip_inc_o    => ip_inc_s,
      cpu_halt_o  => decoder_halt_s,
      alu_op_o    => alu_op_s,
      reg_write_o => reg_write_s,
      notz_en_o   => notz_en_s,
      mem_write_o => mem_write_dec_s,
      mem_read_o  => mem_read_dec_s,
      push_en_o   => push_en_s,
      pop_en_o    => pop_en_s,
      sload_o     => open,
      reg_addr_o  => reg_addr_s
    );

  U_ALU_RON_REGISTER_FILE : entity work.reg_file12x16_dbg
    port map (
      clk_i       => clock,
      rst_i       => reset,
      we_i        => reg_write_s,
      wr_addr_i   => reg_addr_s,
      rd_addr_a_i => unsigned(ir_out_s(7 downto 4)),
      rd_addr_b_i => unsigned(ir_out_s(3 downto 0)),
      din_i       => reg_write_data_s,
      dout_a_o    => reg_a_s,
      dout_b_o    => reg_b_s,
      r0_o        => open,
      r1_o        => open,
      r2_o        => open,
      r3_o        => open,
      r4_o        => open,
      r5_o        => open,
      r6_o        => open,
      r7_o        => open,
      r8_o        => open,
      r9_o        => open,
      r10_o       => open,
      r11_o       => open
    );

  U_ALU_UNIT : entity work.alu_core
    port map (
      a_i      => reg_a_s,
      b_i      => reg_b_s,
      flag_s_i => flag_s_s,
      op_i     => alu_op_s,
      y_o      => alu_result_s,
      z_o      => flag_z_s,
      s_o      => flag_s_s,
      c_o      => flag_c_s,
      o_o      => flag_o_s
    );

  U_FLAGS_REGISTER : entity work.flags_reg
    port map (
      clk_i => clock,
      rst_i => reset,
      we_i  => is_exec_s,
      z_i   => flag_z_s,
      s_i   => flag_s_s,
      c_i   => flag_c_s,
      o_i   => flag_o_s,
      z_o   => open,
      s_o   => open,
      c_o   => open,
      o_o   => open
    );

  U_MUX_DATA_SOURCE : entity work.appendix_n_mux2_16
    port map (
      sel_i    => mem_read_dec_s,
      data0_i  => alu_result_s,
      data1_i  => cache_cpu_data_s,
      result_o => reg_write_data_s
    );

  U_STACK_CONTROL : entity work.stack7x16
    port map (
      clk_i   => clock,
      rst_i   => reset,
      push_i  => push_en_s,
      pop_i   => pop_en_s,
      din_i   => reg_a_s,
      dout_o  => stack_data_s,
      sp_o    => stack_sp_s,
      empty_o => stack_empty_s,
      full_o  => stack_full_s
    );

  U_MUX_MEM_STACK : entity work.appendix_n_mux2_16
    port map (
      sel_i    => pop_en_s,
      data0_i  => reg_a_s,
      data1_i  => stack_data_s,
      result_o => stack_or_reg_s
    );

  U_MUX_CPU_ADDR : entity work.appendix_n_mux2_16
    port map (
      sel_i    => bp_prediction_s,
      data0_i  => special_addr_s,
      data1_i  => bp_target_s,
      result_o => cpu_addr_s
    );

  U_MUX_SYS_ADDR : entity work.appendix_n_mux2_16
    port map (
      sel_i    => is_fetch_s,
      data0_i  => cpu_addr_s,
      data1_i  => ip_out_s,
      result_o => sys_addr_s
    );

  U_DATA_CACHE : entity work.cache_4way_age
    port map (
      clk_i       => clock,
      rst_i       => reset,
      cpu_req_i   => mem_read_dec_s or mem_write_dec_s,
      cpu_we_i    => mem_write_dec_s,
      cpu_addr_i  => sys_addr_s,
      cpu_wdata_i => stack_or_reg_s,
      cpu_rdata_o => cache_cpu_data_s,
      cpu_ready_o => cache_ready_s,
      hit_o       => cache_hit_s,
      miss_o      => cache_miss_s,
      ram_req_o   => cache_mem_req_s,
      ram_we_o    => cache_mem_we_s,
      ram_addr_o  => cache_mem_addr_s,
      ram_wdata_o => cache_mem_wdata_s,
      ram_rdata_i => memory_data_out_s,
      ram_grant_i => grant_cpu_s
    );

  U_DMAC_CONTROLLER : entity work.dma_controller_3word
    port map (
      clk_i       => clock,
      rst_i       => reset,
      start_i     => DMA_START,
      grant_i     => grant_dmac_s,
      dev_valid_i => dmac_read,
      dev_data_i  => x"00" & DMA_TEST_DATA,
      req_o       => dmac_request_s,
      busy_o      => dmac_busy_s,
      done_o      => dmac_done_s,
      ram_we_o    => dmac_write_s,
      ram_addr_o  => dmac_addr_s,
      ram_data_o  => dmac_data_s
    );

  U_BUS_ARBITER : entity work.bus_arbiter_2master
    port map (
      req_cpu_i   => cache_mem_req_s,
      req_dma_i   => dmac_request_s,
      grant_cpu_o => grant_cpu_s,
      grant_dma_o => grant_dmac_s
    );

  U_MUX_FINAL_ADDR : entity work.appendix_n_mux2_16
    port map (
      sel_i    => grant_dmac_s,
      data0_i  => cache_mem_addr_s,
      data1_i  => dmac_addr_s,
      result_o => final_addr_s
    );

  U_LPM_MUX_MEM : entity work.appendix_n_mux2_16
    port map (
      sel_i    => grant_dmac_s,
      data0_i  => cache_mem_wdata_s,
      data1_i  => dmac_data_s,
      result_o => memory_data_in_s
    );

  U_MEMORY : entity work.ram_sync
    port map (
      clk_i  => clock,
      en_i   => memory_en_s,
      we_i   => memory_write_s,
      addr_i => final_addr_s,
      din_i  => memory_data_in_s,
      dout_o => memory_data_out_s
    );
end architecture;
