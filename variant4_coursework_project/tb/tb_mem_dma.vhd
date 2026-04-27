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

  monitor : process(clk)
    variable write_count : integer := 0;
  begin
    if rising_edge(clk) then
      if rst = '1' then
        write_count := 0;
      elsif ram_we = '1' then
        case write_count is
          when 0 =>
            assert ram_addr = x"000A" and ram_din = x"1111"
              report "DMA first write must target 000Ah with 1111h" severity failure;
          when 1 =>
            assert ram_addr = x"000B" and ram_din = x"2222"
              report "DMA second write must target 000Bh with 2222h" severity failure;
          when 2 =>
            assert ram_addr = x"000C" and ram_din = x"3333"
              report "DMA third write must target 000Ch with 3333h" severity failure;
          when others =>
            assert false report "Unexpected extra DMA write" severity failure;
        end case;
        write_count := write_count + 1;
      end if;
    end if;
  end process;

  stimulus : process
  begin
    wait for 30 ns;
    rst <= '0';

    wait until rising_edge(clk);
    start    <= '1';
    dev_valid <= '1';
    dev_data <= x"1111";
    wait until rising_edge(clk);
    start <= '0';

    wait until rising_edge(clk);
    dev_data <= x"1111";
    wait until rising_edge(clk);
    dev_data <= x"2222";
    wait until rising_edge(clk);
    dev_data <= x"3333";
    wait until rising_edge(clk);
    dev_valid <= '0';
    wait until rising_edge(clk);
    wait for 1 ns;
    assert dma_done = '1'
      report "DMA must assert done after three words" severity failure;

    assert false report "tb_mem_dma: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
