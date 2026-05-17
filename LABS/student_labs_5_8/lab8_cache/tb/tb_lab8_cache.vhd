library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity tb_lab8_cache is
end entity;

architecture sim of tb_lab8_cache is
  signal clk          : std_logic := '0';
  signal rst          : std_logic := '1';
  signal cpu_req      : std_logic := '0';
  signal cpu_we       : std_logic := '0';
  signal cpu_addr     : addr_t := (others => '0');
  signal cpu_wdata    : word_t := (others => '0');
  signal cpu_rdata    : word_t;
  signal cpu_ready    : std_logic;
  signal hit          : std_logic;
  signal miss         : std_logic;
  signal ram_req      : std_logic;
  signal ram_we       : std_logic;
  signal ram_addr     : addr_t;
  signal ram_data     : word_t;

  procedure cpu_access(
    signal clk_s       : in std_logic;
    signal req_s       : out std_logic;
    signal we_s        : out std_logic;
    signal addr_s      : out addr_t;
    signal wdata_s     : out word_t;
    signal ready_s     : in std_logic;
    constant is_write  : in boolean;
    constant addr_c    : in addr_t;
    constant wdata_c   : in word_t
  ) is
  begin
    wait until rising_edge(clk_s);
    addr_s  <= addr_c;
    wdata_s <= wdata_c;
    if is_write then
      we_s <= '1';
    else
      we_s <= '0';
    end if;
    req_s <= '1';

    loop
      wait until rising_edge(clk_s);
      wait for 1 ns;
      exit when ready_s = '1';
    end loop;

    req_s <= '0';
    we_s  <= '0';
    wait for 1 ns;
  end procedure;
begin
  clk <= not clk after 5 ns;

  DUT : entity work.lab8_cache_top
    port map (
      clk_i          => clk,
      rst_i          => rst,
      cpu_req_i      => cpu_req,
      cpu_we_i       => cpu_we,
      cpu_addr_i     => cpu_addr,
      cpu_wdata_i    => cpu_wdata,
      cpu_rdata_o    => cpu_rdata,
      cpu_ready_o    => cpu_ready,
      hit_o          => hit,
      miss_o         => miss,
      ram_req_dbg_o  => ram_req,
      ram_we_dbg_o   => ram_we,
      ram_addr_dbg_o => ram_addr,
      ram_data_dbg_o => ram_data
    );

  stimulus : process
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';
    wait until rising_edge(clk);
    wait for 1 ns;

    cpu_access(clk, cpu_req, cpu_we, cpu_addr, cpu_wdata, cpu_ready, false, x"0010", x"0000");
    assert cpu_rdata = x"1110"
      report "First read from 0010h must be filled from main memory" severity failure;
    assert miss = '1'
      report "First read from 0010h must be a miss" severity failure;

    cpu_access(clk, cpu_req, cpu_we, cpu_addr, cpu_wdata, cpu_ready, false, x"0010", x"0000");
    assert cpu_rdata = x"1110" and hit = '1'
      report "Second read from 0010h must be a hit" severity failure;

    cpu_access(clk, cpu_req, cpu_we, cpu_addr, cpu_wdata, cpu_ready, true, x"0010", x"ABCD");
    cpu_access(clk, cpu_req, cpu_we, cpu_addr, cpu_wdata, cpu_ready, false, x"0010", x"0000");
    assert cpu_rdata = x"ABCD"
      report "Write-through hit must update the cached word" severity failure;

    cpu_access(clk, cpu_req, cpu_we, cpu_addr, cpu_wdata, cpu_ready, false, x"0018", x"0000");
    assert cpu_rdata = x"1198" and miss = '1'
      report "Direct mapped cache must replace the line with the same index" severity failure;

    cpu_access(clk, cpu_req, cpu_we, cpu_addr, cpu_wdata, cpu_ready, false, x"0010", x"0000");
    assert cpu_rdata = x"ABCD" and miss = '1'
      report "Reading the replaced direct-mapped line must fetch it again from RAM" severity failure;

    assert false report "tb_lab8_cache: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
