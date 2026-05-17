library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity alu_or is
  port (
    a_i : in  word_t;
    b_i : in  word_t;
    y_o : out word_t
  );
end entity;

architecture rtl of alu_or is
begin
  y_o <= a_i or b_i;
end architecture;
