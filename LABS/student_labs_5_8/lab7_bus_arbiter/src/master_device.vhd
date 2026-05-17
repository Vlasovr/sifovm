library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity master_device is
  generic (
    ID_VALUE    : natural := 1;
    START_CYCLE : natural := 1;
    HOLD_CYCLES : natural := 8
  );
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    grant_i : in  std_logic;
    req_o   : out std_logic;
    data_o  : out word_t;
    used_o  : out std_logic
  );
end entity;

architecture rtl of master_device is
  signal cycle_r : natural range 0 to 255 := 0;
  signal req_s   : std_logic;
  signal used_r  : std_logic := '0';
begin
  req_s <= '1' when cycle_r >= START_CYCLE and cycle_r < START_CYCLE + HOLD_CYCLES else '0';

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        cycle_r <= 0;
        used_r  <= '0';
      else
        if cycle_r < 255 then
          cycle_r <= cycle_r + 1;
        end if;
        if grant_i = '1' then
          used_r <= '1';
        end if;
      end if;
    end if;
  end process;

  req_o  <= req_s;
  data_o <= std_logic_vector(to_unsigned(ID_VALUE, DATA_W));
  used_o <= used_r;
end architecture;
