library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;
use work.program_image_pkg.all;

entity rom_sync is
  port (
    clk_i  : in  std_logic;
    en_i   : in  std_logic;
    addr_i : in  addr_t;
    data_o : out word_t
  );
end entity;

architecture rtl of rom_sync is
  signal q_r : word_t := (others => '0');
begin
  data_o <= q_r;

  process(clk_i)
    variable idx : integer;
  begin
    if rising_edge(clk_i) then
      if en_i = '1' then
        idx := to_integer(unsigned(addr_i(7 downto 0)));
        q_r <= ROM_INIT(idx);
      end if;
    end if;
  end process;
end architecture;
