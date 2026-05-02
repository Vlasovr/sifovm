library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;
use work.data_image_pkg.all;

entity ram_sync is
  port (
    clk_i  : in  std_logic;
    en_i   : in  std_logic;
    we_i   : in  std_logic;
    addr_i : in  addr_t;
    din_i  : in  word_t;
    dout_o : out word_t
  );
end entity;

architecture rtl of ram_sync is
  signal mem : ram256_t := RAM_INIT;
  signal q_r : word_t := (others => '0');
begin
  dout_o <= q_r;

  process(clk_i)
    variable idx : integer;
  begin
    if rising_edge(clk_i) then
      if en_i = '1' then
        idx := to_integer(unsigned(addr_i(7 downto 0)));
        if we_i = '1' then
          mem(idx) <= din_i;
        end if;
        q_r <= mem(idx);
      end if;
    end if;
  end process;
end architecture;
