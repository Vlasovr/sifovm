library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity stack7x16 is
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    push_i  : in  std_logic;
    pop_i   : in  std_logic;
    din_i   : in  word_t;
    dout_o  : out word_t;
    sp_o    : out unsigned(2 downto 0);
    empty_o : out std_logic;
    full_o  : out std_logic
  );
end entity;

architecture rtl of stack7x16 is
  type stack_mem_t is array (0 to STACK_DEPTH-1) of word_t;
  signal mem    : stack_mem_t := (others => (others => '0'));
  signal sp_r   : unsigned(2 downto 0) := to_unsigned(STACK_DEPTH, 3);
  signal dout_r : word_t := (others => '0');
begin
  dout_o  <= dout_r;
  sp_o    <= sp_r;
  empty_o <= '1' when sp_r = to_unsigned(STACK_DEPTH, 3) else '0';
  full_o  <= '1' when sp_r = to_unsigned(0, 3) else '0';

  process(clk_i)
    variable sp_i : integer;
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        mem    <= (others => (others => '0'));
        sp_r   <= to_unsigned(STACK_DEPTH, 3);
        dout_r <= (others => '0');
      else
        sp_i := to_integer(sp_r);

        if push_i = '1' and pop_i = '0' then
          if sp_i > 0 then
            mem(sp_i - 1) <= din_i;
            sp_r <= to_unsigned(sp_i - 1, 3);
          end if;
        elsif pop_i = '1' and push_i = '0' then
          if sp_i < STACK_DEPTH then
            dout_r <= mem(sp_i);
            sp_r   <= to_unsigned(sp_i + 1, 3);
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
