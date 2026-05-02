library ieee;
use ieee.std_logic_1164.all;

entity bus_arbiter_2master is
  port (
    req_cpu_i   : in  std_logic;
    req_dma_i   : in  std_logic;
    grant_cpu_o : out std_logic;
    grant_dma_o : out std_logic
  );
end entity;

architecture rtl of bus_arbiter_2master is
begin
  grant_dma_o <= req_dma_i;
  grant_cpu_o <= req_cpu_i and (not req_dma_i);
end architecture;
