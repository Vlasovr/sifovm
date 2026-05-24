library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity mc is
  port (
    ce : in  std_logic;
    cw : in  std_logic;
    cg : in  std_logic;
    dw : in  std_logic;
    dg : in  std_logic;
    s  : out std_logic;
    me : out std_logic;
    mw : out std_logic
  );
end entity;

architecture rtl of mc is
begin
  s  <= dg;
  me <= (ce and cg) or (dw and dg);
  mw <= dw when dg = '1' else cw;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity ma2 is
  port (
    s : in  std_logic;
    a : in  addr_t;
    b : in  addr_t;
    y : out addr_t
  );
end entity;

architecture rtl of ma2 is
begin
  y <= b when s = '1' else a;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity md2 is
  port (
    s : in  std_logic;
    a : in  word_t;
    b : in  word_t;
    y : out word_t
  );
end entity;

architecture rtl of md2 is
begin
  y <= b when s = '1' else a;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity al is
  port (
    a : in  addr_t;
    l : out std_logic_vector(7 downto 0);
    h : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of al is
begin
  l <= a(7 downto 0);
  h <= a(15 downto 8);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;
use work.program_image_pkg.all;

entity ro is
  port (
    clk : in  std_logic;
    en  : in  std_logic;
    i   : in  std_logic_vector(7 downto 0);
    q   : out word_t
  );
end entity;

architecture rtl of ro is
  signal qr : word_t := (others => '0');
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of qr     : signal is true;
  attribute preserve of qr : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        qr <= ROM_INIT(to_integer(unsigned(i)));
      end if;
    end if;
  end process;

  q <= qr;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;
use work.data_image_pkg.all;

entity ra is
  port (
    clk : in  std_logic;
    en  : in  std_logic;
    we  : in  std_logic;
    i   : in  std_logic_vector(7 downto 0);
    d   : in  word_t;
    q   : out word_t
  );
end entity;

architecture rtl of ra is
  signal m  : ram256_t := RAM_INIT;
  signal qr : word_t := (others => '0');
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of m      : signal is true;
  attribute keep of qr     : signal is true;
  attribute preserve of qr : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if en = '1' then
        if we = '1' then
          m(to_integer(unsigned(i))) <= d;
        end if;
        qr <= m(to_integer(unsigned(i)));
      end if;
    end if;
  end process;

  q <= qr;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_a_memory_top is
  port (
    clk : in  std_logic;

    re  : in  std_logic;
    pa  : in  addr_t;

    ce  : in  std_logic;
    cw  : in  std_logic;
    cg  : in  std_logic;
    ca  : in  addr_t;
    cd  : in  word_t;

    dw  : in  std_logic;
    dg  : in  std_logic;
    da  : in  addr_t;
    dd  : in  word_t;

    pd  : out word_t;
    rd  : out word_t;

    s   : out std_logic;
    me  : out std_logic;
    mw  : out std_logic;
    ma  : out addr_t;
    md  : out word_t;

    pi  : out std_logic_vector(7 downto 0);
    ph  : out std_logic_vector(7 downto 0);
    mi  : out std_logic_vector(7 downto 0);
    mh  : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of appendix_a_memory_top is
  signal s_s  : std_logic;
  signal me_s : std_logic;
  signal mw_s : std_logic;
  signal ma_s : addr_t;
  signal md_s : word_t;
  signal pi_s : std_logic_vector(7 downto 0);
  signal ph_s : std_logic_vector(7 downto 0);
  signal mi_s : std_logic_vector(7 downto 0);
  signal mh_s : std_logic_vector(7 downto 0);
  signal pd_s : word_t;
  signal rd_s : word_t;

  attribute keep : boolean;
  attribute keep of s_s  : signal is true;
  attribute keep of me_s : signal is true;
  attribute keep of mw_s : signal is true;
  attribute keep of ma_s : signal is true;
  attribute keep of md_s : signal is true;
  attribute keep of pi_s : signal is true;
  attribute keep of mi_s : signal is true;
begin
  u_ctl : entity work.mc
    port map (
      ce => ce,
      cw => cw,
      cg => cg,
      dw => dw,
      dg => dg,
      s  => s_s,
      me => me_s,
      mw => mw_s
    );

  u_ma : entity work.ma2
    port map (
      s => s_s,
      a => ca,
      b => da,
      y => ma_s
    );

  u_md : entity work.md2
    port map (
      s => s_s,
      a => cd,
      b => dd,
      y => md_s
    );

  u_pi : entity work.al
    port map (
      a => pa,
      l => pi_s,
      h => ph_s
    );

  u_mi : entity work.al
    port map (
      a => ma_s,
      l => mi_s,
      h => mh_s
    );

  u_rom : entity work.ro
    port map (
      clk => clk,
      en  => re,
      i   => pi_s,
      q   => pd_s
    );

  u_ram : entity work.ra
    port map (
      clk => clk,
      en  => me_s,
      we  => mw_s,
      i   => mi_s,
      d   => md_s,
      q   => rd_s
    );

  pd <= pd_s;
  rd <= rd_s;
  s  <= s_s;
  me <= me_s;
  mw <= mw_s;
  ma <= ma_s;
  md <= md_s;
  pi <= pi_s;
  ph <= ph_s;
  mi <= mi_s;
  mh <= mh_s;
end architecture;
