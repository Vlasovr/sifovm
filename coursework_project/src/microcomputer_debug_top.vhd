library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity microcomputer_debug_top is
  port (
    CLK              : in  std_logic;
    RESET            : in  std_logic;
    DMA_START        : in  std_logic;
    DMA_VALID        : in  std_logic;
    DMA_DATA         : in  word_t;

    HALT             : out std_logic;
    DMA_DONE         : out std_logic;

    DBG_STATE        : out std_logic_vector(4 downto 0);
    DBG_PC           : out addr_t;
    DBG_IR0          : out word_t;
    DBG_IR1          : out word_t;
    DBG_R1           : out word_t;
    DBG_R2           : out word_t;
    DBG_R3           : out word_t;
    DBG_R4           : out word_t;
    DBG_R5           : out word_t;
    DBG_R6           : out word_t;
    DBG_R7           : out word_t;
    DBG_FLAGS        : out std_logic_vector(3 downto 0);
    DBG_SP           : out unsigned(2 downto 0);
    DBG_CACHE_HIT    : out std_logic;
    DBG_CACHE_MISS   : out std_logic;
    DBG_REQ_CPU      : out std_logic;
    DBG_REQ_DMA      : out std_logic;
    DBG_GNT_CPU      : out std_logic;
    DBG_GNT_DMA      : out std_logic;
    DBG_RAM_WE       : out std_logic;
    DBG_RAM_ADDR     : out addr_t;
    DBG_RAM_WDATA    : out word_t;
    DBG_RAM_RDATA    : out word_t;
    DBG_BP_HIST      : out std_logic_vector(1 downto 0);
    DBG_BP_PRED      : out std_logic;
    DBG_BP_TARGET    : out addr_t
  );
end entity;

architecture structural of microcomputer_debug_top is
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
      dbg_state_o      => DBG_STATE,
      dbg_pc_o         => DBG_PC,
      dbg_ir0_o        => DBG_IR0,
      dbg_ir1_o        => DBG_IR1,
      dbg_r1_o         => DBG_R1,
      dbg_r2_o         => DBG_R2,
      dbg_r3_o         => DBG_R3,
      dbg_r4_o         => DBG_R4,
      dbg_r5_o         => DBG_R5,
      dbg_r6_o         => DBG_R6,
      dbg_r7_o         => DBG_R7,
      dbg_flags_o      => DBG_FLAGS,
      dbg_sp_o         => DBG_SP,
      dbg_cache_hit_o  => DBG_CACHE_HIT,
      dbg_cache_miss_o => DBG_CACHE_MISS,
      dbg_req_cpu_o    => DBG_REQ_CPU,
      dbg_req_dma_o    => DBG_REQ_DMA,
      dbg_gnt_cpu_o    => DBG_GNT_CPU,
      dbg_gnt_dma_o    => DBG_GNT_DMA,
      dbg_ram_we_o     => DBG_RAM_WE,
      dbg_ram_addr_o   => DBG_RAM_ADDR,
      dbg_ram_wdata_o  => DBG_RAM_WDATA,
      dbg_ram_rdata_o  => DBG_RAM_RDATA,
      dbg_bp_hist_o    => DBG_BP_HIST,
      dbg_bp_pred_o    => DBG_BP_PRED,
      dbg_bp_target_o  => DBG_BP_TARGET
    );
end architecture;
