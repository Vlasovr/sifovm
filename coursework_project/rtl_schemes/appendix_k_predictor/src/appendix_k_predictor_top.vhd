library ieee;
use ieee.std_logic_1164.all;

entity ix is
  port (
    pc : in  std_logic_vector(1 downto 0);
    h  : in  std_logic_vector(1 downto 0);
    x  : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of ix is
begin
  x <= pc & h;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity gh is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    en  : in  std_logic;
    t   : in  std_logic;
    q   : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of gh is
  signal r : std_logic_vector(1 downto 0) := "00";
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of r     : signal is true;
  attribute preserve of r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r <= "00";
      elsif en = '1' then
        r <= r(0) & t;
      end if;
    end if;
  end process;

  q <= r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity up is
  port (
    c : in  std_logic_vector(1 downto 0);
    t : in  std_logic;
    n : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of up is
begin
  process(c, t)
  begin
    if t = '1' then
      if c = "11" then
        n <= "11";
      else
        n <= std_logic_vector(unsigned(c) + 1);
      end if;
    else
      if c = "00" then
        n <= "00";
      else
        n <= std_logic_vector(unsigned(c) - 1);
      end if;
    end if;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ph is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    iq  : in  std_logic_vector(3 downto 0);
    iu  : in  std_logic_vector(3 downto 0);
    d   : in  std_logic_vector(1 downto 0);
    q   : out std_logic_vector(1 downto 0);
    u   : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of ph is
  type mem_t is array (0 to 15) of std_logic_vector(1 downto 0);
  signal m : mem_t := (others => "01");
  attribute keep : boolean;
  attribute keep of m : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        m <= (others => "01");
      elsif we = '1' then
        m(to_integer(unsigned(iu))) <= d;
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(iq)));
  u <= m(to_integer(unsigned(iu)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity bt is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    iq  : in  std_logic_vector(3 downto 0);
    iu  : in  std_logic_vector(3 downto 0);
    d   : in  addr_t;
    q   : out addr_t
  );
end entity;

architecture rtl of bt is
  type mem_t is array (0 to 15) of addr_t;
  signal m : mem_t := (others => (others => '0'));
  attribute keep : boolean;
  attribute keep of m : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        m <= (others => (others => '0'));
      elsif we = '1' then
        m(to_integer(unsigned(iu))) <= d;
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(iq)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vl is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    iq  : in  std_logic_vector(3 downto 0);
    iu  : in  std_logic_vector(3 downto 0);
    q   : out std_logic
  );
end entity;

architecture rtl of vl is
  type mem_t is array (0 to 15) of std_logic;
  signal m : mem_t := (others => '0');
  attribute keep : boolean;
  attribute keep of m : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        m <= (others => '0');
      elsif we = '1' then
        m(to_integer(unsigned(iu))) <= '1';
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(iq)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity pr is
  port (
    qv : in  std_logic;
    c  : in  std_logic_vector(1 downto 0);
    v  : in  std_logic;
    tg : in  addr_t;
    pt : out std_logic;
    pa : out addr_t
  );
end entity;

architecture rtl of pr is
begin
  process(qv, c, v, tg)
  begin
    pt <= '0';
    pa <= (others => '0');
    if qv = '1' and c(1) = '1' and v = '1' then
      pt <= '1';
      pa <= tg;
    end if;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_k_predictor_top is
  port (
    clk : in  std_logic;
    rst : in  std_logic;

    qv  : in  std_logic;
    pcq : in  std_logic_vector(1 downto 0);
    uv  : in  std_logic;
    pcu : in  std_logic_vector(1 downto 0);
    hi  : in  std_logic_vector(1 downto 0);
    at  : in  std_logic;
    ta  : in  addr_t;

    ho  : out std_logic_vector(1 downto 0);
    pt  : out std_logic;
    pa  : out addr_t;

    iq  : out std_logic_vector(3 downto 0);
    iu  : out std_logic_vector(3 downto 0);
    cq  : out std_logic_vector(1 downto 0);
    cu  : out std_logic_vector(1 downto 0);
    cn  : out std_logic_vector(1 downto 0);
    vq  : out std_logic;
    btq : out addr_t;
    wr  : out std_logic
  );
end entity;

architecture structural of appendix_k_predictor_top is
  signal h_s   : std_logic_vector(1 downto 0);
  signal iq_s  : std_logic_vector(3 downto 0);
  signal iu_s  : std_logic_vector(3 downto 0);
  signal cq_s  : std_logic_vector(1 downto 0);
  signal cu_s  : std_logic_vector(1 downto 0);
  signal cn_s  : std_logic_vector(1 downto 0);
  signal vq_s  : std_logic;
  signal btq_s : addr_t;
  signal wr_s  : std_logic;

  attribute keep : boolean;
  attribute keep of h_s   : signal is true;
  attribute keep of iq_s  : signal is true;
  attribute keep of iu_s  : signal is true;
  attribute keep of cq_s  : signal is true;
  attribute keep of cu_s  : signal is true;
  attribute keep of cn_s  : signal is true;
  attribute keep of vq_s  : signal is true;
  attribute keep of btq_s : signal is true;
begin
  wr_s <= uv and at;

  u_gh  : entity work.gh port map (clk => clk, rst => rst, en => uv, t => at, q => h_s);
  u_ixq : entity work.ix port map (pc => pcq, h => h_s, x => iq_s);
  u_ixu : entity work.ix port map (pc => pcu, h => hi,  x => iu_s);
  u_up  : entity work.up port map (c => cu_s, t => at, n => cn_s);
  u_ph  : entity work.ph port map (clk => clk, rst => rst, we => uv, iq => iq_s, iu => iu_s, d => cn_s, q => cq_s, u => cu_s);
  u_bt  : entity work.bt port map (clk => clk, rst => rst, we => wr_s, iq => iq_s, iu => iu_s, d => ta, q => btq_s);
  u_vl  : entity work.vl port map (clk => clk, rst => rst, we => wr_s, iq => iq_s, iu => iu_s, q => vq_s);
  u_pr  : entity work.pr port map (qv => qv, c => cq_s, v => vq_s, tg => btq_s, pt => pt, pa => pa);

  ho  <= h_s;
  iq  <= iq_s;
  iu  <= iu_s;
  cq  <= cq_s;
  cu  <= cu_s;
  cn  <= cn_s;
  vq  <= vq_s;
  btq <= btq_s;
  wr  <= wr_s;
end architecture;
