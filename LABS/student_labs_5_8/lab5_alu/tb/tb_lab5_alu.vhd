library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity tb_lab5_alu is
end entity;

architecture sim of tb_lab5_alu is
  signal opcode      : std_logic_vector(7 downto 0) := OP_HLT;
  signal a           : word_t := (others => '0');
  signal b           : word_t := (others => '0');
  signal flag_s      : std_logic := '0';
  signal y           : word_t;
  signal z, s, c, o  : std_logic;
  signal alu_op_dbg  : std_logic_vector(2 downto 0);
  signal use_b_dbg   : std_logic;
  signal wr_flags_dbg: std_logic;
begin
  DUT : entity work.lab5_alu_top
    port map (
      opcode_i       => opcode,
      a_i            => a,
      b_i            => b,
      flag_s_i       => flag_s,
      y_o            => y,
      z_o            => z,
      s_o            => s,
      c_o            => c,
      o_o            => o,
      alu_op_dbg_o   => alu_op_dbg,
      use_b_dbg_o    => use_b_dbg,
      wr_flags_dbg_o => wr_flags_dbg
    );

  stimulus : process
  begin
    opcode <= OP_OR;
    a <= x"00F0";
    b <= x"0F0F";
    wait for 10 ns;
    assert y = x"0FFF" and z = '0' and s = '0' and c = '0' and o = '0'
      report "OR operation failed" severity failure;
    assert use_b_dbg = '1' and wr_flags_dbg = '1'
      report "OR control signals failed" severity failure;

    opcode <= OP_NOR;
    a <= x"0FFF";
    b <= x"0FFF";
    wait for 10 ns;
    assert y = x"F000" and s = '1'
      report "NOR operation failed" severity failure;

    opcode <= OP_SRA;
    a <= x"8001";
    b <= x"FFFF";
    wait for 10 ns;
    assert y = x"C000" and c = '1' and s = '1'
      report "SRA operation failed" severity failure;

    opcode <= OP_INCS;
    a <= x"C000";
    flag_s <= '1';
    wait for 10 ns;
    assert y = x"C001" and s = '1'
      report "INCS with S=1 failed" severity failure;

    opcode <= OP_INCS;
    a <= x"1234";
    flag_s <= '0';
    wait for 10 ns;
    assert y = x"1234"
      report "INCS with S=0 must keep value" severity failure;

    opcode <= OP_NOR;
    a <= x"FFFF";
    b <= x"FFFF";
    wait for 10 ns;
    assert y = x"0000" and z = '1'
      report "Zero flag failed" severity failure;

    assert false report "tb_lab5_alu: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
