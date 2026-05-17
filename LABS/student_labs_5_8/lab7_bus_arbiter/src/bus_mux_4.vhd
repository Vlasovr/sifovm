library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity bus_mux_4 is
  port (
    grant_i : in  std_logic_vector(3 downto 0);
    data0_i : in  word_t;
    data1_i : in  word_t;
    data2_i : in  word_t;
    data3_i : in  word_t;
    bus_o   : out word_t
  );
end entity;

architecture rtl of bus_mux_4 is
begin
  process(grant_i, data0_i, data1_i, data2_i, data3_i)
  begin
    bus_o <= (others => '0');
    if grant_i(0) = '1' then
      bus_o <= data0_i;
    elsif grant_i(1) = '1' then
      bus_o <= data1_i;
    elsif grant_i(2) = '1' then
      bus_o <= data2_i;
    elsif grant_i(3) = '1' then
      bus_o <= data3_i;
    end if;
  end process;
end architecture;
