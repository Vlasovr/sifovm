library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack7x16_standalone is
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    push_i  : in  std_logic;
    pop_i   : in  std_logic;
    din_i   : in  std_logic_vector(15 downto 0);
    dout_o  : out std_logic_vector(15 downto 0);
    sp_o    : out unsigned(2 downto 0);
    empty_o : out std_logic;
    full_o  : out std_logic
  );
end entity;

architecture rtl of stack7x16_standalone is
  constant STACK_DEPTH_C : integer := 7;
  subtype word_t is std_logic_vector(15 downto 0);
  type stack_mem_t is array (0 to STACK_DEPTH_C - 1) of word_t;

  signal mem_r  : stack_mem_t := (others => (others => '0'));
  signal sp_r   : unsigned(2 downto 0) := to_unsigned(STACK_DEPTH_C, 3);
  signal dout_r : word_t := (others => '0');
begin
  dout_o  <= dout_r;
  sp_o    <= sp_r;
  empty_o <= '1' when sp_r = to_unsigned(STACK_DEPTH_C, 3) else '0';
  full_o  <= '1' when sp_r = to_unsigned(0, 3) else '0';

  process(clk_i)
    variable sp_v : integer;
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        mem_r  <= (others => (others => '0'));
        sp_r   <= to_unsigned(STACK_DEPTH_C, 3);
        dout_r <= (others => '0');
      else
        sp_v := to_integer(sp_r);

        if push_i = '1' and pop_i = '0' then
          if sp_v > 0 then
            mem_r(sp_v - 1) <= din_i;
            sp_r <= to_unsigned(sp_v - 1, 3);
          end if;
        elsif pop_i = '1' and push_i = '0' then
          if sp_v < STACK_DEPTH_C then
            dout_r <= mem_r(sp_v);
            sp_r   <= to_unsigned(sp_v + 1, 3);
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
