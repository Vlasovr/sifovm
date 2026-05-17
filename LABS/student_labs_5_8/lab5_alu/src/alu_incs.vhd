library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity alu_incs is
  port (
    a_i      : in  word_t;
    flag_s_i : in  std_logic;
    y_o      : out word_t;
    c_o      : out std_logic;
    o_o      : out std_logic
  );
end entity;

architecture rtl of alu_incs is
begin
  process(a_i, flag_s_i)
    variable sum_v : unsigned(DATA_W downto 0);
    variable y_v   : word_t;
  begin
    sum_v := '0' & unsigned(a_i);
    if flag_s_i = '1' then
      sum_v := ('0' & unsigned(a_i)) + to_unsigned(1, DATA_W + 1);
    end if;

    y_v := std_logic_vector(sum_v(DATA_W - 1 downto 0));
    y_o <= y_v;
    c_o <= sum_v(DATA_W);
    o_o <= (not a_i(DATA_W - 1)) and flag_s_i and y_v(DATA_W - 1);
  end process;
end architecture;
