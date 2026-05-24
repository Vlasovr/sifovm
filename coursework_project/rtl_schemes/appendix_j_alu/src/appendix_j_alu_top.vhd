library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity dec5 is
  port (
    op : in  std_logic_vector(2 downto 0);
    d  : out std_logic_vector(4 downto 0)
  );
end entity;

architecture rtl of dec5 is
begin
  process(op)
  begin
    d <= "00000";
    case op is
      when "000" => d(0) <= '1';
      when "001" => d(1) <= '1';
      when "010" => d(2) <= '1';
      when "011" => d(3) <= '1';
      when "100" => d(4) <= '1';
      when others => d(0) <= '1';
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity o16 is
  port (
    a : in  std_logic_vector(15 downto 0);
    b : in  std_logic_vector(15 downto 0);
    y : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of o16 is
begin
  y <= a or b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity n16 is
  port (
    a : in  std_logic_vector(15 downto 0);
    b : in  std_logic_vector(15 downto 0);
    y : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of n16 is
begin
  y <= not (a or b);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity s16 is
  port (
    a : in  std_logic_vector(15 downto 0);
    y : out std_logic_vector(15 downto 0);
    c : out std_logic
  );
end entity;

architecture rtl of s16 is
begin
  y <= a(15) & a(15 downto 1);
  c <= a(0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i16 is
  port (
    a  : in  std_logic_vector(15 downto 0);
    fs : in  std_logic;
    y  : out std_logic_vector(15 downto 0);
    c  : out std_logic;
    o  : out std_logic
  );
end entity;

architecture rtl of i16 is
  signal sm : unsigned(16 downto 0);
  signal yy : std_logic_vector(15 downto 0);
begin
  sm <= ('0' & unsigned(a)) + 1 when fs = '1' else ('0' & unsigned(a));
  yy <= std_logic_vector(sm(15 downto 0));

  y <= yy;
  c <= sm(16);
  o <= (not a(15)) and fs and yy(15);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mx5 is
  port (
    op : in  std_logic_vector(2 downto 0);
    p  : in  std_logic_vector(15 downto 0);
    yo : in  std_logic_vector(15 downto 0);
    yn : in  std_logic_vector(15 downto 0);
    ys : in  std_logic_vector(15 downto 0);
    yi : in  std_logic_vector(15 downto 0);
    y  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mx5 is
begin
  process(op, p, yo, yn, ys, yi)
  begin
    case op is
      when "001" => y <= yo;
      when "010" => y <= yn;
      when "011" => y <= ys;
      when "100" => y <= yi;
      when others => y <= p;
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity cmx is
  port (
    d  : in  std_logic_vector(4 downto 0);
    cs : in  std_logic;
    ci : in  std_logic;
    oi : in  std_logic;
    c  : out std_logic;
    o  : out std_logic
  );
end entity;

architecture rtl of cmx is
begin
  c <= (d(3) and cs) or (d(4) and ci);
  o <= d(4) and oi;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity flg is
  port (
    y : in  std_logic_vector(15 downto 0);
    c : in  std_logic;
    o : in  std_logic;
    f : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of flg is
begin
  f(0) <= '1' when y = x"0000" else '0';
  f(1) <= y(15);
  f(2) <= c;
  f(3) <= o;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity appendix_j_alu_top is
  port (
    a  : in  std_logic_vector(15 downto 0);
    b  : in  std_logic_vector(15 downto 0);
    fs : in  std_logic;
    op : in  std_logic_vector(2 downto 0);

    y  : out std_logic_vector(15 downto 0);
    z  : out std_logic;
    s  : out std_logic;
    c  : out std_logic;
    ov : out std_logic;

    do : out std_logic_vector(4 downto 0);
    yo : out std_logic_vector(15 downto 0);
    yn : out std_logic_vector(15 downto 0);
    ys : out std_logic_vector(15 downto 0);
    yi : out std_logic_vector(15 downto 0);
    ff : out std_logic_vector(3 downto 0)
  );
end entity;

architecture structural of appendix_j_alu_top is
  signal d_s  : std_logic_vector(4 downto 0);
  signal p_s  : std_logic_vector(15 downto 0);
  signal o_s  : std_logic_vector(15 downto 0);
  signal n_s  : std_logic_vector(15 downto 0);
  signal s_s  : std_logic_vector(15 downto 0);
  signal i_s  : std_logic_vector(15 downto 0);
  signal y_s  : std_logic_vector(15 downto 0);
  signal cs_s : std_logic;
  signal ci_s : std_logic;
  signal oi_s : std_logic;
  signal c_s  : std_logic;
  signal ov_s : std_logic;
  signal f_s  : std_logic_vector(3 downto 0);

  attribute keep : boolean;
  attribute keep of d_s  : signal is true;
  attribute keep of o_s  : signal is true;
  attribute keep of n_s  : signal is true;
  attribute keep of s_s  : signal is true;
  attribute keep of i_s  : signal is true;
  attribute keep of y_s  : signal is true;
  attribute keep of f_s  : signal is true;
begin
  p_s <= a;

  u_dc : entity work.dec5 port map (op => op, d => d_s);
  u_or : entity work.o16  port map (a => a, b => b, y => o_s);
  u_nr : entity work.n16  port map (a => a, b => b, y => n_s);
  u_sr : entity work.s16  port map (a => a, y => s_s, c => cs_s);
  u_in : entity work.i16  port map (a => a, fs => fs, y => i_s, c => ci_s, o => oi_s);
  u_mx : entity work.mx5  port map (op => op, p => p_s, yo => o_s, yn => n_s, ys => s_s, yi => i_s, y => y_s);
  u_cf : entity work.cmx  port map (d => d_s, cs => cs_s, ci => ci_s, oi => oi_s, c => c_s, o => ov_s);
  u_fl : entity work.flg  port map (y => y_s, c => c_s, o => ov_s, f => f_s);

  y  <= y_s;
  z  <= f_s(0);
  s  <= f_s(1);
  c  <= f_s(2);
  ov <= f_s(3);

  do <= d_s;
  yo <= o_s;
  yn <= n_s;
  ys <= s_s;
  yi <= i_s;
  ff <= f_s;
end architecture;
