library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity tb_stack7x16 is
end entity;

architecture sim of tb_stack7x16 is
  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal push  : std_logic := '0';
  signal pop   : std_logic := '0';
  signal din   : word_t := (others => '0');
  signal dout  : word_t;
  signal sp    : unsigned(2 downto 0);
  signal empty : std_logic;
  signal full  : std_logic;
begin
  clk <= not clk after 5 ns;

  DUT : entity work.stack7x16
    port map (
      clk_i => clk,
      rst_i => rst,
      push_i => push,
      pop_i => pop,
      din_i => din,
      dout_o => dout,
      sp_o => sp,
      empty_o => empty,
      full_o => full
    );

  stimulus : process
  begin
    wait for 12 ns;
    rst <= '0';
    wait for 1 ns;
    assert sp = to_unsigned(7, 3) and empty = '1' and full = '0'
      report "After reset stack must be empty with SP=7" severity failure;

    din <= x"0002"; push <= '1'; wait for 10 ns; push <= '0';
    din <= x"0006"; push <= '1'; wait for 10 ns; push <= '0';
    din <= x"0007"; push <= '1'; wait for 10 ns; push <= '0';
    din <= x"0078"; push <= '1'; wait for 10 ns; push <= '0';
    din <= x"03E0"; push <= '1'; wait for 10 ns; push <= '0';
    wait for 1 ns;
    assert sp = to_unsigned(2, 3)
      report "After five pushes SP must be 2" severity failure;

    pop <= '1'; wait for 10 ns; pop <= '0';
    wait for 1 ns;
    assert dout = x"03E0"
      report "First pop must return last pushed value 03E0h" severity failure;
    pop <= '1'; wait for 10 ns; pop <= '0';
    pop <= '1'; wait for 10 ns; pop <= '0';
    pop <= '1'; wait for 10 ns; pop <= '0';
    pop <= '1'; wait for 10 ns; pop <= '0';
    wait for 1 ns;
    assert sp = to_unsigned(7, 3) and empty = '1'
      report "After five pops stack must be empty with SP=7" severity failure;

    assert false report "tb_stack7x16: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
