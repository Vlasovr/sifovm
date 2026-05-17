library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity stack7x16 is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    push_i      : in  std_logic;
    pop_i       : in  std_logic;
    din_i       : in  word_t;
    dout_o      : out word_t;
    sp_o        : out unsigned(2 downto 0);
    empty_o     : out std_logic;
    full_o      : out std_logic;
    overflow_o  : out std_logic;
    underflow_o : out std_logic
  );
end entity;

architecture rtl of stack7x16 is
  type stack_mem_t is array (0 to STACK_DEPTH - 1) of word_t;
  signal mem_r       : stack_mem_t := (others => (others => '0'));
  signal sp_r        : unsigned(2 downto 0) := to_unsigned(STACK_DEPTH, 3);
  signal dout_r      : word_t := (others => '0');
  signal overflow_r  : std_logic := '0';
  signal underflow_r : std_logic := '0';
begin
  dout_o      <= dout_r;
  sp_o        <= sp_r;
  empty_o     <= '1' when sp_r = to_unsigned(STACK_DEPTH, 3) else '0';
  full_o      <= '1' when sp_r = to_unsigned(0, 3) else '0';
  overflow_o  <= overflow_r;
  underflow_o <= underflow_r;

  process(clk_i)
    variable sp_v : integer;
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        mem_r       <= (others => (others => '0'));
        sp_r        <= to_unsigned(STACK_DEPTH, 3);
        dout_r      <= (others => '0');
        overflow_r  <= '0';
        underflow_r <= '0';
      else
        overflow_r  <= '0';
        underflow_r <= '0';
        sp_v := to_integer(sp_r);

        if push_i = '1' and pop_i = '0' then
          if sp_v > 0 then
            mem_r(sp_v - 1) <= din_i;
            sp_r <= to_unsigned(sp_v - 1, 3);
          else
            overflow_r <= '1';
          end if;
        elsif pop_i = '1' and push_i = '0' then
          if sp_v < STACK_DEPTH then
            dout_r <= mem_r(sp_v);
            sp_r   <= to_unsigned(sp_v + 1, 3);
          else
            underflow_r <= '1';
          end if;
        end if;
      end if;
    end if;
  end process;
end architecture;
