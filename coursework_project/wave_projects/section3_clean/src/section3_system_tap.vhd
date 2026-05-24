library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity section3_system_tap is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    dma_start_i : in  std_logic;
    dma_valid_i : in  std_logic;
    dma_data_i  : in  word_t;

    halt_o      : out std_logic;
    dma_done_o  : out std_logic;

    state_o     : out std_logic_vector(4 downto 0);
    pc_o        : out addr_t;
    ir0_o       : out word_t;
    ir1_o       : out word_t;
    r1_o        : out word_t;
    r2_o        : out word_t;
    r3_o        : out word_t;
    r4_o        : out word_t;
    r5_o        : out word_t;
    r6_o        : out word_t;
    r7_o        : out word_t;
    flags_o     : out std_logic_vector(3 downto 0);
    sp_o        : out std_logic_vector(2 downto 0);

    rom_en_o    : out std_logic;
    rom_addr_o  : out addr_t;
    rom_data_o  : out word_t;

    cache_req_o   : out std_logic;
    cache_we_o    : out std_logic;
    cache_addr_o  : out addr_t;
    cache_wdata_o : out word_t;
    cache_rdata_o : out word_t;
    cache_ready_o : out std_logic;
    cache_hit_o   : out std_logic;
    cache_miss_o  : out std_logic;

    req_cpu_o   : out std_logic;
    req_dma_o   : out std_logic;
    gnt_cpu_o   : out std_logic;
    gnt_dma_o   : out std_logic;

    ram_we_o    : out std_logic;
    ram_addr_o  : out addr_t;
    ram_wdata_o : out word_t;
    ram_rdata_o : out word_t;

    bp_hist_o   : out std_logic_vector(1 downto 0);
    bp_pred_o   : out std_logic;
    bp_target_o : out addr_t
  );
end entity;

architecture structural of section3_system_tap is
  signal rom_addr     : addr_t;
  signal rom_en       : std_logic;
  signal rom_data     : word_t;

  signal cache_req    : std_logic;
  signal cache_we     : std_logic;
  signal cache_addr   : addr_t;
  signal cache_wdata  : word_t;
  signal cache_rdata  : word_t;
  signal cache_ready  : std_logic;
  signal cache_hit    : std_logic;
  signal cache_miss   : std_logic;

  signal cache_ram_req   : std_logic;
  signal cache_ram_we    : std_logic;
  signal cache_ram_addr  : addr_t;
  signal cache_ram_wdata : word_t;

  signal dma_req      : std_logic;
  signal dma_grant    : std_logic;
  signal cpu_grant    : std_logic;
  signal dma_done     : std_logic;
  signal dma_we       : std_logic;
  signal dma_addr     : addr_t;
  signal dma_wdata    : word_t;

  signal ram_en       : std_logic;
  signal ram_we       : std_logic;
  signal ram_addr     : addr_t;
  signal ram_wdata    : word_t;
  signal ram_rdata    : word_t;

  signal bp_query     : std_logic;
  signal bp_pc_query  : addr_t;
  signal bp_hist      : std_logic_vector(1 downto 0);
  signal bp_pred      : std_logic;
  signal bp_target    : addr_t;
  signal bp_update    : std_logic;
  signal bp_pc_update : addr_t;
  signal bp_hist_upd  : std_logic_vector(1 downto 0);
  signal bp_taken     : std_logic;
  signal bp_tgt_upd   : addr_t;

  signal dbg_sp       : unsigned(2 downto 0);
begin
  ram_en    <= (cache_ram_req and cpu_grant) or (dma_we and dma_grant);
  ram_we    <= dma_we when dma_grant = '1' else cache_ram_we;
  ram_addr  <= dma_addr when dma_grant = '1' else cache_ram_addr;
  ram_wdata <= dma_wdata when dma_grant = '1' else cache_ram_wdata;

  dma_done_o <= dma_done;
  sp_o       <= std_logic_vector(dbg_sp);

  rom_en_o   <= rom_en;
  rom_addr_o <= rom_addr;
  rom_data_o <= rom_data;

  cache_req_o   <= cache_req;
  cache_we_o    <= cache_we;
  cache_addr_o  <= cache_addr;
  cache_wdata_o <= cache_wdata;
  cache_rdata_o <= cache_rdata;
  cache_ready_o <= cache_ready;
  cache_hit_o   <= cache_hit;
  cache_miss_o  <= cache_miss;

  req_cpu_o <= cache_ram_req;
  req_dma_o <= dma_req;
  gnt_cpu_o <= cpu_grant;
  gnt_dma_o <= dma_grant;

  ram_we_o    <= ram_we;
  ram_addr_o  <= ram_addr;
  ram_wdata_o <= ram_wdata;
  ram_rdata_o <= ram_rdata;

  bp_hist_o   <= bp_hist;
  bp_pred_o   <= bp_pred;
  bp_target_o <= bp_target;

  U_CPU : entity work.cpu_core
    port map (
      clk_i          => clk_i,
      rst_i          => rst_i,
      rom_addr_o     => rom_addr,
      rom_en_o       => rom_en,
      rom_data_i     => rom_data,
      cache_req_o    => cache_req,
      cache_we_o     => cache_we,
      cache_addr_o   => cache_addr,
      cache_wdata_o  => cache_wdata,
      cache_rdata_i  => cache_rdata,
      cache_ready_i  => cache_ready,
      cache_hit_i    => cache_hit,
      cache_miss_i   => cache_miss,
      bp_query_o     => bp_query,
      bp_pc_query_o  => bp_pc_query,
      bp_hist_i      => bp_hist,
      bp_pred_i      => bp_pred,
      bp_target_i    => bp_target,
      bp_update_o    => bp_update,
      bp_pc_update_o => bp_pc_update,
      bp_hist_o      => bp_hist_upd,
      bp_taken_o     => bp_taken,
      bp_target_o    => bp_tgt_upd,
      halt_o         => halt_o,
      dbg_state_o    => state_o,
      dbg_pc_o       => pc_o,
      dbg_ir0_o      => ir0_o,
      dbg_ir1_o      => ir1_o,
      dbg_r1_o       => r1_o,
      dbg_r2_o       => r2_o,
      dbg_r3_o       => r3_o,
      dbg_r4_o       => r4_o,
      dbg_r5_o       => r5_o,
      dbg_r6_o       => r6_o,
      dbg_r7_o       => r7_o,
      dbg_flags_o    => flags_o,
      dbg_sp_o       => dbg_sp
    );

  U_ROM : entity work.rom_sync
    port map (
      clk_i  => clk_i,
      en_i   => rom_en,
      addr_i => rom_addr,
      data_o => rom_data
    );

  U_CACHE : entity work.cache_4way_age
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      cpu_req_i   => cache_req,
      cpu_we_i    => cache_we,
      cpu_addr_i  => cache_addr,
      cpu_wdata_i => cache_wdata,
      cpu_rdata_o => cache_rdata,
      cpu_ready_o => cache_ready,
      hit_o       => cache_hit,
      miss_o      => cache_miss,
      ram_req_o   => cache_ram_req,
      ram_we_o    => cache_ram_we,
      ram_addr_o  => cache_ram_addr,
      ram_wdata_o => cache_ram_wdata,
      ram_rdata_i => ram_rdata,
      ram_grant_i => cpu_grant
    );

  U_RAM : entity work.ram_sync
    port map (
      clk_i  => clk_i,
      en_i   => ram_en,
      we_i   => ram_we,
      addr_i => ram_addr,
      din_i  => ram_wdata,
      dout_o => ram_rdata
    );

  U_ARB : entity work.bus_arbiter_2master
    port map (
      req_cpu_i   => cache_ram_req,
      req_dma_i   => dma_req,
      grant_cpu_o => cpu_grant,
      grant_dma_o => dma_grant
    );

  U_DMA : entity work.dma_controller_3word
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      start_i     => dma_start_i,
      grant_i     => dma_grant,
      dev_valid_i => dma_valid_i,
      dev_data_i  => dma_data_i,
      req_o       => dma_req,
      busy_o      => open,
      done_o      => dma_done,
      ram_we_o    => dma_we,
      ram_addr_o  => dma_addr,
      ram_data_o  => dma_wdata
    );

  U_BP : entity work.branch_predictor
    port map (
      clk_i          => clk_i,
      rst_i          => rst_i,
      query_valid_i  => bp_query,
      pc_query_i     => bp_pc_query,
      hist_o         => bp_hist,
      pred_taken_o   => bp_pred,
      pred_target_o  => bp_target,
      update_valid_i => bp_update,
      pc_update_i    => bp_pc_update,
      hist_i         => bp_hist_upd,
      actual_taken_i => bp_taken,
      actual_tgt_i   => bp_tgt_upd
    );
end architecture;
