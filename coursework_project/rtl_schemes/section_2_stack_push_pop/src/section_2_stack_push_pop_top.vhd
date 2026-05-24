library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sp_s is
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    push : in  std_logic;
    pop  : in  std_logic;
    sp   : out std_logic_vector(2 downto 0);
    wa   : out std_logic_vector(2 downto 0);
    we   : out std_logic;
    emp  : out std_logic;
    ful  : out std_logic
  );
end entity;

architecture rtl of sp_s is
  signal r : unsigned(2 downto 0) := "111";
  signal w : unsigned(2 downto 0);
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of r : signal is true;
  attribute preserve of r : signal is true;
begin
  w <= r - 1;

  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r <= "111";
      elsif push = '1' and r /= "000" then
        r <= r - 1;
      elsif pop = '1' and r /= "111" then
        r <= r + 1;
      end if;
    end if;
  end process;

  sp  <= std_logic_vector(r);
  wa  <= std_logic_vector(w);
  we  <= push when r /= "000" else '0';
  emp <= '1' when r = "111" else '0';
  ful <= '1' when r = "000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mem_s is
  port (
    clk : in  std_logic;
    we  : in  std_logic;
    wa  : in  std_logic_vector(2 downto 0);
    ra  : in  std_logic_vector(2 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mem_s is
  type ram_t is array (0 to 6) of std_logic_vector(15 downto 0);
  signal ram : ram_t := (others => (others => '0'));
  signal qi  : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of ram : signal is true;
  attribute preserve of ram : signal is true;
begin
  process(clk)
    variable wi : integer range 0 to 7;
    variable ri : integer range 0 to 7;
  begin
    if rising_edge(clk) then
      wi := to_integer(unsigned(wa));
      ri := to_integer(unsigned(ra));
      if we = '1' and wi < 7 then
        ram(wi) <= d;
      end if;
      if ri < 7 then
        qi <= ram(ri);
      else
        qi <= (others => '0');
      end if;
    end if;
  end process;

  q <= qi;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec_s is
  port (
    cmd  : in  std_logic_vector(7 downto 0);
    exec : in  std_logic;
    push : out std_logic;
    pop  : out std_logic
  );
end entity;

architecture rtl of dec_s is
begin
  push <= exec when cmd = x"07" else '0';
  pop  <= exec when cmd = x"08" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_stack_push_pop_top is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    exec   : in  std_logic;
    cmd_i  : in  std_logic_vector(7 downto 0);
    data_i : in  std_logic_vector(15 downto 0);
    data_o : out std_logic_vector(15 downto 0);
    sp_o   : out std_logic_vector(2 downto 0);
    push_o : out std_logic;
    pop_o  : out std_logic;
    emp_o  : out std_logic;
    ful_o  : out std_logic
  );
end entity;

architecture structural of section_2_stack_push_pop_top is
  signal push_s,pop_s,we_s : std_logic;
  signal sp_sg,wa_s : std_logic_vector(2 downto 0);
begin
  u_dec : entity work.dec_s
    port map (cmd => cmd_i, exec => exec, push => push_s, pop => pop_s);

  u_sp : entity work.sp_s
    port map (clk => clk, rst => rst, push => push_s, pop => pop_s, sp => sp_sg, wa => wa_s, we => we_s, emp => emp_o, ful => ful_o);

  u_mem : entity work.mem_s
    port map (clk => clk, we => we_s, wa => wa_s, ra => sp_sg, d => data_i, q => data_o);

  sp_o   <= sp_sg;
  push_o <= push_s;
  pop_o  <= pop_s;
end architecture;
