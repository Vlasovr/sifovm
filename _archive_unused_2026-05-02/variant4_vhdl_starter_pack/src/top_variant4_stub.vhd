library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity top_variant4_stub is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    dma_start_i: in  std_logic;
    dma_data_i : in  word_t;
    dma_valid_i: in  std_logic;
    halt_o     : out std_logic
  );
end entity;

architecture structural of top_variant4_stub is
  signal rom_q      : word_t;
  signal ram_q      : word_t;
  signal dma_req    : std_logic;
  signal dma_grant  : std_logic;
  signal cpu_req    : std_logic;
  signal cpu_grant  : std_logic;
  signal dma_done   : std_logic;
  signal dma_we     : std_logic;
  signal dma_addr   : addr_t;
  signal dma_wdata  : word_t;
  signal pc         : addr_t := (others => '0');
begin
  cpu_req <= '1';
  halt_o  <= '0';

  U_ROM : entity work.rom_sync
    port map (
      clk_i  => clk_i,
      en_i   => '1',
      addr_i => pc,
      data_o => rom_q
    );

  U_RAM : entity work.ram_sync
    port map (
      clk_i  => clk_i,
      en_i   => '1',
      we_i   => dma_we,
      addr_i => dma_addr,
      din_i  => dma_wdata,
      dout_o => ram_q
    );

  U_ARB : entity work.bus_arbiter_2master
    port map (
      req_cpu_i   => cpu_req,
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

  -- The remaining processor datapath blocks are connected at the sheet level:
  -- IR/IP, control unit, register file, ALU, flags, stack, cache and predictor.
  -- This file is therefore a top-level shell to start a Quartus project and
  -- to wire the DMA/RAM/ROM part before the full CPU is inserted.
end architecture;
