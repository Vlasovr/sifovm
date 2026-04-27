library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity tb_alu_variant4 is
end entity;

architecture sim of tb_alu_variant4 is
  signal a      : word_t := (others => '0');
  signal b      : word_t := (others => '0');
  signal sflag  : std_logic := '0';
  signal op     : std_logic_vector(2 downto 0) := ALU_PASS_A;
  signal y      : word_t;
  signal z, s, c, o : std_logic;
begin
  DUT : entity work.alu_variant4
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

    sflag <= '1';
    op <= ALU_INCS;
    wait for 10 ns;

    a <= x"00F0";
    b <= x"0F0F";
    op <= ALU_OR;
    wait for 10 ns;

    a <= x"0FFF";
    b <= x"0FFF";
    op <= ALU_NOR;
    wait for 10 ns;

    sflag <= '0';
    a <= x"1234";
    op <= ALU_INCS;
    wait for 10 ns;

    wait;
  end process;
end architecture;
