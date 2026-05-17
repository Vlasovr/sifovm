library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity tb_lab5_alu is
end entity;

architecture sim of tb_lab5_alu is
  signal opcode      : std_logic_vector(7 downto 0) := OP_HLT;
  signal a           : word_t := (others => '0');
  signal b           : word_t := (others => '0');
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
    opcode <= OP_CMP;
    a <= x"0010";
    b <= x"0001";
    wait for 10 ns;
    assert y = x"000F" and z = '0' and s = '0' and c = '0' and o = '0'
      report "CMP positive difference failed" severity failure;
    assert use_b_dbg = '1' and wr_flags_dbg = '1'
      report "CMP control signals failed" severity failure;

    opcode <= OP_CMP;
    a <= x"1234";
    b <= x"1234";
    wait for 10 ns;
    assert y = x"0000" and z = '1'
      report "CMP equality must set zero flag" severity failure;

    opcode <= OP_CMP;
    a <= x"0001";
    b <= x"0002";
    wait for 10 ns;
    assert y = x"FFFF" and s = '1' and c = '1'
      report "CMP borrow/sign flags failed" severity failure;

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
