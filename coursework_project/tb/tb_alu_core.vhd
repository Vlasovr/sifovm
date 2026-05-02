library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity tb_alu_core is
end entity;

architecture sim of tb_alu_core is
  signal a      : word_t := (others => '0');
  signal b      : word_t := (others => '0');
  signal sflag  : std_logic := '0';
  signal op     : std_logic_vector(2 downto 0) := ALU_PASS_A;
  signal y      : word_t;
  signal z, s, c, o : std_logic;
begin
  DUT : entity work.alu_core
    port map (
      a_i => a,
      b_i => b,
      flag_s_i => sflag,
      op_i => op,
      y_o => y,
      z_o => z,
      s_o => s,
      c_o => c,
      o_o => o
    );

  stimulus : process
  begin
    a <= x"8001";
    b <= x"00F0";
    op <= ALU_SRA;
    wait for 10 ns;
    assert y = x"C000" and c = '1' and s = '1'
      report "SRA 8001h must produce C000h, C=1, S=1" severity failure;

    a <= y;
    sflag <= '1';
    op <= ALU_INCS;
    wait for 10 ns;
    assert y = x"C001"
      report "INCS with S=1 must increment C000h to C001h" severity failure;

    a <= x"00F0";
    b <= x"0F0F";
    op <= ALU_OR;
    wait for 10 ns;
    assert y = x"0FFF"
      report "OR must produce 0FFFh" severity failure;

    a <= x"0FFF";
    b <= x"0FFF";
    op <= ALU_NOR;
    wait for 10 ns;
    assert y = x"F000"
      report "NOR must produce F000h" severity failure;

    sflag <= '0';
    a <= x"1234";
    op <= ALU_INCS;
    wait for 10 ns;
    assert y = x"1234"
      report "INCS with S=0 must keep source value" severity failure;

    assert false report "tb_alu_core: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
