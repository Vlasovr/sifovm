library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity bus_arbiter_parallel_quantum is
  generic (
    QUANTUM_CYCLES : positive := 2
  );
  port (
    clk_i          : in  std_logic;
    rst_i          : in  std_logic;
    req_i          : in  std_logic_vector(3 downto 0);
    grant_o        : out std_logic_vector(3 downto 0);
    slot_o         : out unsigned(1 downto 0);
    quantum_tick_o : out std_logic;
    busy_o         : out std_logic
  );
end entity;

architecture rtl of bus_arbiter_parallel_quantum is
  signal slot_r     : unsigned(1 downto 0) := (others => '0');
  signal quantum_r  : integer range 0 to QUANTUM_CYCLES - 1 := 0;
  signal grant_s    : std_logic_vector(3 downto 0);
  signal tick_s     : std_logic;
begin
  process(req_i, slot_r)
  begin
    grant_s <= (others => '0');
    if req_i(to_integer(slot_r)) = '1' then
      grant_s(to_integer(slot_r)) <= '1';
    end if;
  end process;

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        slot_r    <= (others => '0');
        quantum_r <= 0;
      elsif quantum_r = QUANTUM_CYCLES - 1 then
        quantum_r <= 0;
        slot_r    <= slot_r + 1;
      else
        quantum_r <= quantum_r + 1;
      end if;
    end if;
  end process;

  tick_s <= '1' when quantum_r = QUANTUM_CYCLES - 1 else '0';

  grant_o        <= grant_s;
  slot_o         <= slot_r;
  quantum_tick_o <= tick_s;
  busy_o         <= '1' when grant_s /= "0000" else '0';
end architecture;
