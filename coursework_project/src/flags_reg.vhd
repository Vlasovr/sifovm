library ieee;
use ieee.std_logic_1164.all;

entity flags_reg is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    we_i  : in  std_logic;
    z_i   : in  std_logic;
    s_i   : in  std_logic;
    c_i   : in  std_logic;
    o_i   : in  std_logic;
    z_o   : out std_logic;
    s_o   : out std_logic;
    c_o   : out std_logic;
    o_o   : out std_logic
  );
end entity;

architecture rtl of flags_reg is
  signal z_r, s_r, c_r, o_r : std_logic := '0';
begin
  z_o <= z_r;
  s_o <= s_r;
  c_o <= c_r;
  o_o <= o_r;

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        z_r <= '0';
        s_r <= '0';
        c_r <= '0';
        o_r <= '0';
      elsif we_i = '1' then
        z_r <= z_i;
        s_r <= s_i;
        c_r <= c_i;
        o_r <= o_i;
      end if;
    end if;
  end process;
end architecture;
