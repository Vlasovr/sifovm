library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity section3_clean_top is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    dma_start : in  std_logic;
    dma_valid : in  std_logic;
    dma_data  : in  word_t;

    halt      : out std_logic;
    dma_done  : out std_logic;

    st        : out std_logic_vector(4 downto 0);
    pc        : out addr_t;
    ir0       : out word_t;
    ir1       : out word_t;
    op        : out std_logic_vector(7 downto 0);
    regn      : out std_logic_vector(3 downto 0);

    r1        : out word_t;
    r2        : out word_t;
    r3        : out word_t;
    r4        : out word_t;
    r5        : out word_t;
    r6        : out word_t;
    r7        : out word_t;
    flg       : out std_logic_vector(3 downto 0);
    sp        : out std_logic_vector(2 downto 0);

    rom_en    : out std_logic;
    rom_a     : out addr_t;
    rom_d     : out word_t;

    c_req     : out std_logic;
    c_we      : out std_logic;
    c_a       : out addr_t;
    c_wd      : out word_t;
    c_rd      : out word_t;
    c_rdy     : out std_logic;
    c_hit     : out std_logic;
    c_miss    : out std_logic;

    req_cpu   : out std_logic;
    req_dma   : out std_logic;
    gnt_cpu   : out std_logic;
    gnt_dma   : out std_logic;
    bus_owner : out std_logic_vector(1 downto 0);

    ram_we    : out std_logic;
    ram_a     : out addr_t;
    ram_wd    : out word_t;
    ram_rd    : out word_t;

    bp_hist   : out std_logic_vector(1 downto 0);
    bp_pred   : out std_logic;
    bp_tgt    : out addr_t;

    is_mr     : out std_logic;
    is_rm     : out std_logic;
    is_or     : out std_logic;
    is_nor    : out std_logic;
    is_sra    : out std_logic;
    is_incs   : out std_logic;
    is_push   : out std_logic;
    is_pop    : out std_logic;
    is_jmp    : out std_logic;
    is_jz     : out std_logic;
    is_hlt    : out std_logic;

    ph_f0     : out std_logic;
    ph_f1     : out std_logic;
    ph_dec    : out std_logic;
    ph_mem    : out std_logic;
    ph_alu    : out std_logic;
    ph_stk    : out std_logic;
    ph_br     : out std_logic;
    ph_fin    : out std_logic;
    rf_we     : out std_logic
  );
end entity;

architecture structural of section3_clean_top is
  signal s_st      : std_logic_vector(4 downto 0);
  signal s_ir0     : word_t;
  signal s_op      : std_logic_vector(7 downto 0);
  signal s_gnt_cpu : std_logic;
  signal s_gnt_dma : std_logic;
begin
  st   <= s_st;
  ir0  <= s_ir0;
  s_op <= s_ir0(15 downto 8);
  op   <= s_op;
  regn <= s_ir0(7 downto 4);

  is_mr   <= '1' when s_op = OP_MOV_MR else '0';
  is_rm   <= '1' when s_op = OP_MOV_RM else '0';
  is_or   <= '1' when s_op = OP_OR else '0';
  is_nor  <= '1' when s_op = OP_NOR else '0';
  is_sra  <= '1' when s_op = OP_SRA else '0';
  is_incs <= '1' when s_op = OP_INCS else '0';
  is_push <= '1' when s_op = OP_PUSH else '0';
  is_pop  <= '1' when s_op = OP_POP else '0';
  is_jmp  <= '1' when s_op = OP_JMP else '0';
  is_jz   <= '1' when s_op = OP_JZ else '0';
  is_hlt  <= '1' when s_op = OP_HLT else '0';

  ph_f0  <= '1' when s_st = "00001" or s_st = "00010" or s_st = "00011" else '0';
  ph_f1  <= '1' when s_st = "00100" or s_st = "00101" or s_st = "00110" else '0';
  ph_dec <= '1' when s_st = "00111" else '0';
  ph_mem <= '1' when s_st = "01000" or s_st = "01001" or s_st = "01100" else '0';
  ph_alu <= '1' when s_st = "01010" or s_st = "01011" else '0';
  ph_stk <= '1' when s_st = "01101" or s_st = "01110" or s_st = "01111" else '0';
  ph_br  <= '1' when s_st = "10000" or s_st = "10001" else '0';
  ph_fin <= '1' when s_st = "10010" else '0';

  rf_we <= '1' when s_st = "01011" or s_st = "01100" or s_st = "01111" else '0';

  gnt_cpu <= s_gnt_cpu;
  gnt_dma <= s_gnt_dma;
  bus_owner <= "10" when s_gnt_dma = '1' else
               "01" when s_gnt_cpu = '1' else
               "00";

  U_TAP : entity work.section3_system_tap
    port map (
      clk_i       => clk,
      rst_i       => rst,
      dma_start_i => dma_start,
      dma_valid_i => dma_valid,
      dma_data_i  => dma_data,
      halt_o      => halt,
      dma_done_o  => dma_done,
      state_o     => s_st,
      pc_o        => pc,
      ir0_o       => s_ir0,
      ir1_o       => ir1,
      r1_o        => r1,
      r2_o        => r2,
      r3_o        => r3,
      r4_o        => r4,
      r5_o        => r5,
      r6_o        => r6,
      r7_o        => r7,
      flags_o     => flg,
      sp_o        => sp,
      rom_en_o    => rom_en,
      rom_addr_o  => rom_a,
      rom_data_o  => rom_d,
      cache_req_o   => c_req,
      cache_we_o    => c_we,
      cache_addr_o  => c_a,
      cache_wdata_o => c_wd,
      cache_rdata_o => c_rd,
      cache_ready_o => c_rdy,
      cache_hit_o   => c_hit,
      cache_miss_o  => c_miss,
      req_cpu_o   => req_cpu,
      req_dma_o   => req_dma,
      gnt_cpu_o   => s_gnt_cpu,
      gnt_dma_o   => s_gnt_dma,
      ram_we_o    => ram_we,
      ram_addr_o  => ram_a,
      ram_wdata_o => ram_wd,
      ram_rdata_o => ram_rd,
      bp_hist_o   => bp_hist,
      bp_pred_o   => bp_pred,
      bp_target_o => bp_tgt
    );
end architecture;
