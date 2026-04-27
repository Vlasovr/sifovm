library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity tb_system_variant4 is
end entity;

architecture sim of tb_system_variant4 is
  signal clk          : std_logic := '0';
  signal rst          : std_logic := '1';
  signal dma_start    : std_logic := '0';
  signal dma_valid    : std_logic := '0';
  signal dma_data     : word_t := (others => '0');
  signal halt         : std_logic;
  signal dma_done     : std_logic;

  signal dbg_state    : std_logic_vector(4 downto 0);
  signal dbg_pc       : addr_t;
  signal dbg_ir0      : word_t;
  signal dbg_ir1      : word_t;
  signal dbg_r1       : word_t;
  signal dbg_r2       : word_t;
  signal dbg_r3       : word_t;
  signal dbg_r4       : word_t;
  signal dbg_r5       : word_t;
  signal dbg_r6       : word_t;
  signal dbg_r7       : word_t;
  signal dbg_flags    : std_logic_vector(3 downto 0);
  signal dbg_sp       : unsigned(2 downto 0);
  signal cache_hit    : std_logic;
  signal cache_miss   : std_logic;
  signal req_cpu      : std_logic;
  signal req_dma      : std_logic;
  signal gnt_cpu      : std_logic;
  signal gnt_dma      : std_logic;
  signal ram_we       : std_logic;
  signal ram_addr     : addr_t;
  signal ram_wdata    : word_t;
  signal ram_rdata    : word_t;
  signal bp_hist      : std_logic_vector(1 downto 0);
  signal bp_pred      : std_logic;
  signal bp_target    : addr_t;
begin
  clk <= not clk after 5 ns;

  UUT : entity work.system_variant4_top
    port map (
      clk_i            => clk,
      rst_i            => rst,
      dma_start_i      => dma_start,
      dma_valid_i      => dma_valid,
      dma_data_i       => dma_data,
      halt_o           => halt,
      dma_done_o       => dma_done,
      dbg_state_o      => dbg_state,
      dbg_pc_o         => dbg_pc,
      dbg_ir0_o        => dbg_ir0,
      dbg_ir1_o        => dbg_ir1,
      dbg_r1_o         => dbg_r1,
      dbg_r2_o         => dbg_r2,
      dbg_r3_o         => dbg_r3,
      dbg_r4_o         => dbg_r4,
      dbg_r5_o         => dbg_r5,
      dbg_r6_o         => dbg_r6,
      dbg_r7_o         => dbg_r7,
      dbg_flags_o      => dbg_flags,
      dbg_sp_o         => dbg_sp,
      dbg_cache_hit_o  => cache_hit,
      dbg_cache_miss_o => cache_miss,
      dbg_req_cpu_o    => req_cpu,
      dbg_req_dma_o    => req_dma,
      dbg_gnt_cpu_o    => gnt_cpu,
      dbg_gnt_dma_o    => gnt_dma,
      dbg_ram_we_o     => ram_we,
      dbg_ram_addr_o   => ram_addr,
      dbg_ram_wdata_o  => ram_wdata,
      dbg_ram_rdata_o  => ram_rdata,
      dbg_bp_hist_o    => bp_hist,
      dbg_bp_pred_o    => bp_pred,
      dbg_bp_target_o  => bp_target
    );

  stim : process
  begin
    rst <= '1';
    wait for 30 ns;
    rst <= '0';

    wait until rising_edge(clk);
    wait until rising_edge(clk);
    dma_start <= '1';
    dma_valid <= '1';
    dma_data  <= x"1111";
    wait until rising_edge(clk);
    dma_start <= '0';

    wait until rising_edge(clk);
    dma_data <= x"1111";
    wait until rising_edge(clk);
    dma_data <= x"2222";
    wait until rising_edge(clk);
    dma_data <= x"3333";
    wait until rising_edge(clk);
    dma_valid <= '0';

    wait until halt = '1';
    wait for 20 ns;

    assert dbg_r1 = x"C001" report "R1 must be C001 after SRA + INCS" severity failure;
    assert dbg_r2 = x"F000" report "R2 must be F000 after OR + NOR" severity failure;
    assert dbg_r3 = x"C001" report "R3 must receive popped stack value" severity failure;
    assert dbg_r4 = x"0000" report "R4 must be zero after NOR FFFF,FFFF" severity failure;
    assert dbg_r5 = x"0000" report "R5 must remain zero because JZ skips 0018h" severity failure;
    assert dbg_r6 = x"0000" report "R6 must remain zero because JMP skips 001Ch" severity failure;
    assert dbg_r7 = x"1111" report "R7 must read first DMA word from RAM[000Ah]" severity failure;
    assert dbg_flags = "1000" report "Final flags must be Z=1, S=0, C=0, O=0" severity failure;
    assert dbg_sp = to_unsigned(7, 3) report "Stack pointer must return to empty value 7" severity failure;
    assert dma_done = '1' report "DMA must complete three-word transfer" severity failure;
    assert bp_hist = "01" report "GHR must become 01 after one taken JZ" severity failure;

    assert false report "tb_system_variant4: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
