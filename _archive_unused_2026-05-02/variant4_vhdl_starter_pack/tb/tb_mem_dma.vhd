library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity tb_mem_dma is
end entity;

architecture sim of tb_mem_dma is
  signal clk      : std_logic := '0';
  signal rst      : std_logic := '1';
  signal start    : std_logic := '0';
  signal dev_valid: std_logic := '0';
  signal dev_data : word_t    := (others => '0');
  signal dma_req  : std_logic;
  signal dma_gnt  : std_logic;
  signal dma_done : std_logic;
  signal ram_we   : std_logic;
  signal ram_addr : addr_t;
  signal ram_din  : word_t;
  signal ram_dout : word_t;
begin
  clk <= not clk after 5 ns;
  dma_gnt <= dma_req;

  U_DMA : entity work.dma_controller_3word
    port map (
      clk_i => clk,
      rst_i => rst,
      start_i => start,
      grant_i => dma_gnt,
      dev_valid_i => dev_valid,
      dev_data_i => dev_data,
      req_o => dma_req,
      busy_o => open,
      done_o => dma_done,
      ram_we_o => ram_we,
      ram_addr_o => ram_addr,
      ram_data_o => ram_din
    );

  U_RAM : entity work.ram_sync
    port map (
      clk_i => clk,
      en_i => '1',
      we_i => ram_we,
      addr_i => ram_addr,
      din_i => ram_din,
      dout_o => ram_dout
    );

  stimulus : process
  begin
    wait for 12 ns;
    rst   <= '0';
    start <= '1';
    wait for 10 ns;
    start <= '0';

    dev_valid <= '1'; dev_data <= x"1111"; wait for 10 ns;
    dev_data  <= x"2222"; wait for 10 ns;
    dev_data  <= x"3333"; wait for 10 ns;
    dev_valid <= '0';

    wait;
  end process;
end architecture;
