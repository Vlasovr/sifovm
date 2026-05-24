library ieee;
use ieee.std_logic_1164.all;

entity ab_r is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    la  : in  std_logic;
    lb  : in  std_logic;
    da  : in  std_logic_vector(15 downto 0);
    db  : in  std_logic_vector(15 downto 0);
    a   : out std_logic_vector(15 downto 0);
    b   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of ab_r is
  signal ar : std_logic_vector(15 downto 0) := (others => '0');
  signal br : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of ar : signal is true;
  attribute keep of br : signal is true;
  attribute preserve of ar : signal is true;
  attribute preserve of br : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ar <= (others => '0');
        br <= (others => '0');
      else
        if la = '1' then ar <= da; end if;
        if lb = '1' then br <= db; end if;
      end if;
    end if;
  end process;

  a <= ar;
  b <= br;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec_a is
  port (
    cmd : in  std_logic_vector(7 downto 0);
    so  : out std_logic;
    sn  : out std_logic;
    ss  : out std_logic;
    si  : out std_logic
  );
end entity;

architecture rtl of dec_a is
begin
  so <= '1' when cmd = x"03" else '0';
  sn <= '1' when cmd = x"04" else '0';
  ss <= '1' when cmd = x"05" else '0';
  si <= '1' when cmd = x"06" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity or_a is
  port (a,b : in std_logic_vector(15 downto 0); y : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of or_a is
begin
  y <= a or b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity nor_a is
  port (a,b : in std_logic_vector(15 downto 0); y : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of nor_a is
begin
  y <= not (a or b);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity sra_a is
  port (a : in std_logic_vector(15 downto 0); y : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of sra_a is
begin
  y <= a(15) & a(15 downto 1);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity inc_a is
  port (a : in std_logic_vector(15 downto 0); y : out std_logic_vector(15 downto 0));
end entity;

architecture rtl of inc_a is
begin
  y <= std_logic_vector(unsigned(a) + 1);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mux_a is
  port (
    so : in  std_logic;
    sn : in  std_logic;
    ss : in  std_logic;
    yo : in  std_logic_vector(15 downto 0);
    yn : in  std_logic_vector(15 downto 0);
    ys : in  std_logic_vector(15 downto 0);
    yi : in  std_logic_vector(15 downto 0);
    y  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mux_a is
begin
  y <= yo when so = '1' else
       yn when sn = '1' else
       ys when ss = '1' else
       yi;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity fl_a is
  port (
    y  : in  std_logic_vector(15 downto 0);
    a0 : in  std_logic;
    si : in  std_logic;
    ss : in  std_logic;
    f  : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of fl_a is
begin
  f(3) <= '1' when y = x"0000" else '0';
  f(2) <= y(15);
  f(1) <= ss and a0;
  f(0) <= si and y(15);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity out_a is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    df  : in  std_logic_vector(3 downto 0);
    q   : out std_logic_vector(15 downto 0);
    f   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of out_a is
  signal qr : std_logic_vector(15 downto 0) := (others => '0');
  signal fr : std_logic_vector(3 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of qr : signal is true;
  attribute keep of fr : signal is true;
  attribute preserve of qr : signal is true;
  attribute preserve of fr : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        qr <= (others => '0');
        fr <= (others => '0');
      elsif we = '1' then
        qr <= d;
        fr <= df;
      end if;
    end if;
  end process;

  q <= qr;
  f <= fr;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_alu_ops_top is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    la    : in  std_logic;
    lb    : in  std_logic;
    exec  : in  std_logic;
    cmd_i : in  std_logic_vector(7 downto 0);
    a_i   : in  std_logic_vector(15 downto 0);
    b_i   : in  std_logic_vector(15 downto 0);
    a_o   : out std_logic_vector(15 downto 0);
    b_o   : out std_logic_vector(15 downto 0);
    y_o   : out std_logic_vector(15 downto 0);
    f_o   : out std_logic_vector(3 downto 0);
    or_o  : out std_logic;
    nor_o : out std_logic;
    sra_o : out std_logic;
    inc_o : out std_logic
  );
end entity;

architecture structural of section_2_alu_ops_top is
  signal a_s,b_s : std_logic_vector(15 downto 0);
  signal yo_s,yn_s,ys_s,yi_s,y_s : std_logic_vector(15 downto 0);
  signal so_s,sn_s,ss_s,si_s : std_logic;
  signal fl_s : std_logic_vector(3 downto 0);
begin
  u_ab  : entity work.ab_r  port map (clk => clk, rst => rst, la => la, lb => lb, da => a_i, db => b_i, a => a_s, b => b_s);
  u_dec : entity work.dec_a port map (cmd => cmd_i, so => so_s, sn => sn_s, ss => ss_s, si => si_s);
  u_or  : entity work.or_a  port map (a => a_s, b => b_s, y => yo_s);
  u_nor : entity work.nor_a port map (a => a_s, b => b_s, y => yn_s);
  u_sra : entity work.sra_a port map (a => a_s, y => ys_s);
  u_inc : entity work.inc_a port map (a => a_s, y => yi_s);
  u_mux : entity work.mux_a port map (so => so_s, sn => sn_s, ss => ss_s, yo => yo_s, yn => yn_s, ys => ys_s, yi => yi_s, y => y_s);
  u_fl  : entity work.fl_a  port map (y => y_s, a0 => a_s(0), si => si_s, ss => ss_s, f => fl_s);
  u_out : entity work.out_a port map (clk => clk, rst => rst, we => exec, d => y_s, df => fl_s, q => y_o, f => f_o);

  a_o   <= a_s;
  b_o   <= b_s;
  or_o  <= so_s;
  nor_o <= sn_s;
  sra_o <= ss_s;
  inc_o <= si_s;
end architecture;
