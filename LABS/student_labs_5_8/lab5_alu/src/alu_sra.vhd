library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity alu_sra is
  port (
    a_i : in  word_t;
    y_o : out word_t;
    c_o : out std_logic
  );
end entity;

architecture rtl of alu_sra is
begin
  y_o <= a_i(DATA_W - 1) & a_i(DATA_W - 1 downto 1);
  c_o <= a_i(0);
end architecture;
