library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity tb_stack7x16_standalone is
end entity;

architecture sim of tb_stack7x16_standalone is
  signal clk   : std_logic := '0';
  signal rst   : std_logic := '1';
  signal push  : std_logic := '0';
  signal pop   : std_logic := '0';
  signal din   : std_logic_vector(15 downto 0) := (others => '0');
  signal dout  : std_logic_vector(15 downto 0);
  signal sp    : unsigned(2 downto 0);
  signal empty : std_logic;
  signal full  : std_logic;

  procedure tick is
  begin
    wait until rising_edge(clk);
    wait for 1 ns;
  end procedure;
begin
  clk <= not clk after 5 ns;

  dut : entity work.stack7x16_standalone
    port map (
      clk_i   => clk,
      rst_i   => rst,
      push_i  => push,
      pop_i   => pop,
      din_i   => din,
      dout_o  => dout,
      sp_o    => sp,
      empty_o => empty,
      full_o  => full
    );

  stimulus : process
  begin
    tick;
    rst <= '0';
    tick;

    assert empty = '1' report "After reset stack must be empty" severity error;
    assert full = '0' report "After reset stack must not be full" severity error;
    assert sp = to_unsigned(7, 3) report "After reset SP must be 7" severity error;

    din <= x"1111"; push <= '1'; tick; push <= '0';
    assert sp = to_unsigned(6, 3) report "SP after 1st push must be 6" severity error;
    assert empty = '0' report "Stack must not be empty after 1st push" severity error;

    din <= x"2222"; push <= '1'; tick; push <= '0';
    assert sp = to_unsigned(5, 3) report "SP after 2nd push must be 5" severity error;

    din <= x"3333"; push <= '1'; tick; push <= '0';
    assert sp = to_unsigned(4, 3) report "SP after 3rd push must be 4" severity error;

    din <= x"4444"; push <= '1'; tick; push <= '0';
    din <= x"5555"; push <= '1'; tick; push <= '0';
    din <= x"6666"; push <= '1'; tick; push <= '0';
    din <= x"7777"; push <= '1'; tick; push <= '0';

    assert sp = to_unsigned(0, 3) report "SP after filling stack must be 0" severity error;
    assert full = '1' report "Stack must be full after 7 pushes" severity error;

    din <= x"AAAA"; push <= '1'; tick; push <= '0';
    assert sp = to_unsigned(0, 3) report "Overflow push must not change SP" severity error;
    assert full = '1' report "Full flag must stay active on overflow push" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"7777" report "1st pop must return 7777" severity error;
    assert sp = to_unsigned(1, 3) report "SP after 1st pop must be 1" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"6666" report "2nd pop must return 6666" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"5555" report "3rd pop must return 5555" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"4444" report "4th pop must return 4444" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"3333" report "5th pop must return 3333" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"2222" report "6th pop must return 2222" severity error;

    pop <= '1'; tick; pop <= '0';
    assert dout = x"1111" report "7th pop must return 1111" severity error;
    assert empty = '1' report "Stack must be empty after 7 pops" severity error;
    assert sp = to_unsigned(7, 3) report "SP after emptying stack must be 7" severity error;

    pop <= '1'; tick; pop <= '0';
    assert sp = to_unsigned(7, 3) report "Underflow pop must not change SP" severity error;
    assert empty = '1' report "Empty flag must stay active on underflow pop" severity error;

    push <= '1'; pop <= '1'; din <= x"0F0F"; tick; push <= '0'; pop <= '0';
    assert sp = to_unsigned(7, 3) report "Simultaneous push and pop is treated as no-op" severity error;

    report "tb_stack7x16_standalone: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
