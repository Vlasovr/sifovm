library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity main_memory_sync is
  port (
    clk_i   : in  std_logic;
    req_i   : in  std_logic;
    we_i    : in  std_logic;
    addr_i  : in  addr_t;
    wdata_i : in  word_t;
    rdata_o : out word_t;
    grant_o : out std_logic
  );
end entity;

architecture rtl of main_memory_sync is
  type mem_t is array (0 to 255) of word_t;

  function init_mem return mem_t is
    variable m : mem_t;
  begin
    for i in 0 to 255 loop
      m(i) := std_logic_vector(to_unsigned(16#1000# + i * 17, DATA_W));
    end loop;
    return m;
  end function;

  signal mem_r   : mem_t := init_mem;
  signal rdata_r : word_t := (others => '0');
  signal grant_r : std_logic := '0';
begin
  process(clk_i)
    variable idx_v : integer range 0 to 255;
  begin
    if rising_edge(clk_i) then
      grant_r <= req_i;
      idx_v := to_integer(unsigned(addr_i(7 downto 0)));
      if req_i = '1' then
        if we_i = '1' then
          mem_r(idx_v) <= wdata_i;
          rdata_r <= wdata_i;
        else
          rdata_r <= mem_r(idx_v);
        end if;
      end if;
    end if;
  end process;

  rdata_o <= rdata_r;
  grant_o <= grant_r;
end architecture;
