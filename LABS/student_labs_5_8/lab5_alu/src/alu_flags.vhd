library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity alu_flags is
  port (
    y_i : in  word_t;
    c_i : in  std_logic;
    o_i : in  std_logic;
    z_o : out std_logic;
    s_o : out std_logic;
    c_o : out std_logic;
    o_o : out std_logic
  );
end entity;

architecture rtl of alu_flags is
begin
  z_o <= '1' when y_i = x"0000" else '0';
  s_o <= y_i(DATA_W - 1);
  c_o <= c_i;
  o_o <= o_i;
end architecture;
