library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity alu_core is
  port (
    a_i      : in  word_t;
    b_i      : in  word_t;
    flag_s_i : in  std_logic;
    op_i     : in  std_logic_vector(2 downto 0);
    y_o      : out word_t;
    z_o      : out std_logic;
    s_o      : out std_logic;
    c_o      : out std_logic;
    o_o      : out std_logic
  );
end entity;

architecture rtl of alu_core is
begin
  process(a_i, b_i, flag_s_i, op_i)
    variable a_u   : unsigned(15 downto 0);
    variable sum17 : unsigned(16 downto 0);
    variable y_v   : word_t;
    variable z_v   : std_logic;
    variable s_v   : std_logic;
    variable c_v   : std_logic;
    variable o_v   : std_logic;
  begin
    a_u := unsigned(a_i);
    y_v := a_i;
    c_v := '0';
    o_v := '0';

    case op_i is
      when ALU_OR =>
        y_v := a_i or b_i;
      when ALU_NOR =>
        y_v := not (a_i or b_i);
      when ALU_SRA =>
        y_v := a_i(15) & a_i(15 downto 1);
        c_v := a_i(0);
      when ALU_INCS =>
        sum17 := ('0' & a_u);
        if flag_s_i = '1' then
          sum17 := ('0' & a_u) + to_unsigned(1, 17);
        end if;
        y_v := std_logic_vector(sum17(15 downto 0));
        c_v := sum17(16);
        o_v := (not a_i(15)) and flag_s_i and y_v(15);
      when others =>
        y_v := a_i;
    end case;

    if y_v = x"0000" then
      z_v := '1';
    else
      z_v := '0';
    end if;
    s_v := y_v(15);

    y_o <= y_v;
    z_o <= z_v;
    s_o <= s_v;
    c_o <= c_v;
    o_o <= o_v;
  end process;
end architecture;
