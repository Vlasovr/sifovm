library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity alu_cmp is
  port (
    a_i : in  word_t;
    b_i : in  word_t;
    y_o : out word_t;
    c_o : out std_logic;
    o_o : out std_logic
  );
end entity;

architecture rtl of alu_cmp is
begin
  process(a_i, b_i)
    variable diff_v : unsigned(DATA_W downto 0);
    variable y_v    : word_t;
  begin
    diff_v := ('0' & unsigned(a_i)) - ('0' & unsigned(b_i));
    y_v := std_logic_vector(diff_v(DATA_W - 1 downto 0));

    y_o <= y_v;
    if unsigned(a_i) < unsigned(b_i) then
      c_o <= '1';
    else
      c_o <= '0';
    end if;
    o_o <= (a_i(DATA_W - 1) xor b_i(DATA_W - 1)) and
           (a_i(DATA_W - 1) xor y_v(DATA_W - 1));
  end process;
end architecture;
