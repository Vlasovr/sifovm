library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity microcomputer_top is
  port (
    CLK              : in  std_logic;
    RESET            : in  std_logic;
    DMA_START        : in  std_logic;
    DMA_VALID        : in  std_logic;
    DMA_DATA         : in  word_t;

    HALT             : out std_logic;
    DMA_DONE         : out std_logic
  );
end entity;

architecture structural of microcomputer_top is
begin
  U_SYSTEM : entity work.system_core
    port map (
      clk_i            => CLK,
      rst_i            => RESET,
      dma_start_i      => DMA_START,
      dma_valid_i      => DMA_VALID,
      dma_data_i       => DMA_DATA,
      halt_o           => HALT,
      dma_done_o       => DMA_DONE,
      dbg_state_o      => open,
      dbg_pc_o         => open,
      dbg_ir0_o        => open,
      dbg_ir1_o        => open,
      dbg_r1_o         => open,
      dbg_r2_o         => open,
      dbg_r3_o         => open,
      dbg_r4_o         => open,
      dbg_r5_o         => open,
      dbg_r6_o         => open,
      dbg_r7_o         => open,
      dbg_flags_o      => open,
      dbg_sp_o         => open,
      dbg_cache_hit_o  => open,
      dbg_cache_miss_o => open,
      dbg_req_cpu_o    => open,
      dbg_req_dma_o    => open,
      dbg_gnt_cpu_o    => open,
      dbg_gnt_dma_o    => open,
      dbg_ram_we_o     => open,
      dbg_ram_addr_o   => open,
      dbg_ram_wdata_o  => open,
      dbg_ram_rdata_o  => open,
      dbg_bp_hist_o    => open,
      dbg_bp_pred_o    => open,
      dbg_bp_target_o  => open
    );
end architecture;
