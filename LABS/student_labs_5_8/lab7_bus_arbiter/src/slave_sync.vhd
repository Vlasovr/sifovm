library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity slave_sync is
  port (
    clk_i    : in  std_logic;
    rst_i    : in  std_logic;
    strobe_i : in  std_logic;
    data_i   : in  word_t;
    data_o   : out word_t;
    valid_o  : out std_logic
  );
end entity;

architecture rtl of slave_sync is
  signal data_r  : word_t := (others => '0');
  signal valid_r : std_logic := '0';
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        data_r  <= (others => '0');
        valid_r <= '0';
      else
        valid_r <= strobe_i;
        if strobe_i = '1' then
          data_r <= data_i;
        end if;
      end if;
    end if;
  end process;

  data_o  <= data_r;
  valid_o <= valid_r;
end architecture;
