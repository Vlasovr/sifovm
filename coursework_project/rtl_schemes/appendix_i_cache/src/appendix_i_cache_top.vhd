library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity sp is
  port (
    ad : in  addr_t;
    tg : out std_logic_vector(11 downto 0);
    st : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of sp is
begin
  tg <= ad(15 downto 4);
  st <= ad(3 downto 0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity dw is
  port (
    clk : in  std_logic;
    st  : in  std_logic_vector(3 downto 0);
    we  : in  std_logic;
    d   : in  word_t;
    q   : out word_t
  );
end entity;

architecture rtl of dw is
  type mem_t is array (0 to CACHE_SETS-1) of word_t;
  signal m : mem_t := (others => (others => '0'));
  attribute keep : boolean;
  attribute keep of m : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        m(to_integer(unsigned(st))) <= d;
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(st)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity tw is
  port (
    clk : in  std_logic;
    st  : in  std_logic_vector(3 downto 0);
    we  : in  std_logic;
    d   : in  std_logic_vector(11 downto 0);
    q   : out std_logic_vector(11 downto 0)
  );
end entity;

architecture rtl of tw is
  type mem_t is array (0 to CACHE_SETS-1) of std_logic_vector(11 downto 0);
  signal m : mem_t := (others => (others => '0'));
  attribute keep : boolean;
  attribute keep of m : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        m(to_integer(unsigned(st))) <= d;
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(st)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity vw is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    st  : in  std_logic_vector(3 downto 0);
    we  : in  std_logic;
    d   : in  std_logic;
    q   : out std_logic
  );
end entity;

architecture rtl of vw is
  type mem_t is array (0 to CACHE_SETS-1) of std_logic;
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
        m(to_integer(unsigned(st))) <= d;
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(st)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity aw is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    st  : in  std_logic_vector(3 downto 0);
    we  : in  std_logic;
    inc : in  std_logic;
    d   : in  unsigned(1 downto 0);
    q   : out unsigned(1 downto 0)
  );
end entity;

architecture rtl of aw is
  type mem_t is array (0 to CACHE_SETS-1) of unsigned(1 downto 0);
  signal m : mem_t := (others => (others => '0'));
  attribute keep : boolean;
  attribute keep of m : signal is true;
begin
  process(clk)
    variable i : integer range 0 to CACHE_SETS-1;
  begin
    if rising_edge(clk) then
      i := to_integer(unsigned(st));
      if rst = '1' then
        m <= (others => (others => '0'));
      elsif we = '1' then
        m(i) <= d;
      elsif inc = '1' then
        m(i) <= sat_inc2(m(i));
      end if;
    end if;
  end process;

  q <= m(to_integer(unsigned(st)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity eq is
  port (
    a : in  std_logic_vector(11 downto 0);
    b : in  std_logic_vector(11 downto 0);
    y : out std_logic
  );
end entity;

architecture rtl of eq is
begin
  y <= '1' when a = b else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity hm is
  port (
    e  : in  std_logic_vector(3 downto 0);
    v  : in  std_logic_vector(3 downto 0);
    wh : out std_logic_vector(3 downto 0);
    hw : out std_logic_vector(1 downto 0);
    h  : out std_logic;
    m  : out std_logic
  );
end entity;

architecture rtl of hm is
  signal w : std_logic_vector(3 downto 0);
  signal hs : std_logic;
begin
  w(0) <= e(0) and v(0);
  w(1) <= e(1) and v(1);
  w(2) <= e(2) and v(2);
  w(3) <= e(3) and v(3);
  hs   <= w(0) or w(1) or w(2) or w(3);

  hw <= "00" when w(0) = '1' else
        "01" when w(1) = '1' else
        "10" when w(2) = '1' else
        "11";

  wh <= w;
  h  <= hs;
  m  <= not hs;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity mx is
  port (
    hw : in  std_logic_vector(1 downto 0);
    d0 : in  word_t;
    d1 : in  word_t;
    d2 : in  word_t;
    d3 : in  word_t;
    q  : out word_t
  );
end entity;

architecture rtl of mx is
begin
  process(hw, d0, d1, d2, d3)
  begin
    case hw is
      when "00" => q <= d0;
      when "01" => q <= d1;
      when "10" => q <= d2;
      when others => q <= d3;
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vc is
  port (
    v  : in  std_logic_vector(3 downto 0);
    a0 : in  unsigned(1 downto 0);
    a1 : in  unsigned(1 downto 0);
    a2 : in  unsigned(1 downto 0);
    a3 : in  unsigned(1 downto 0);
    vw : out std_logic_vector(1 downto 0);
    oh : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of vc is
begin
  process(v, a0, a1, a2, a3)
    variable n : std_logic_vector(1 downto 0);
  begin
    n := "00";

    -- Same priority as the real cache: the last invalid way wins;
    -- if all are valid, the way with the strictly greatest age wins.
    if v(0) = '0' then
      n := "00";
    end if;
    if v(1) = '0' then
      n := "01";
    elsif v(to_integer(unsigned(n))) = '1' and a1 > a0 then
      n := "01";
    end if;
    if v(2) = '0' then
      n := "10";
    elsif v(to_integer(unsigned(n))) = '1' and
          ((n = "00" and a2 > a0) or
           (n = "01" and a2 > a1)) then
      n := "10";
    end if;
    if v(3) = '0' then
      n := "11";
    elsif v(to_integer(unsigned(n))) = '1' and
          ((n = "00" and a3 > a0) or
           (n = "01" and a3 > a1) or
           (n = "10" and a3 > a2)) then
      n := "11";
    end if;

    vw <= n;
    case n is
      when "00" => oh <= "0001";
      when "01" => oh <= "0010";
      when "10" => oh <= "0100";
      when others => oh <= "1000";
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ct is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    req : in  std_logic;
    we  : in  std_logic;
    h   : in  std_logic;
    hw  : in  std_logic_vector(1 downto 0);
    vo  : in  std_logic_vector(3 downto 0);
    rg  : in  std_logic;
    ww  : out std_logic_vector(3 downto 0);
    ai  : out std_logic_vector(3 downto 0);
    rr  : out std_logic;
    rw  : out std_logic;
    fs  : out std_logic;
    rdy : out std_logic;
    hp  : out std_logic;
    mp  : out std_logic
  );
end entity;

architecture rtl of ct is
  type st_t is (id, rgnt, rfil, wgnt);
  signal st  : st_t := id;
  signal whr : std_logic := '0';
  signal vq  : std_logic_vector(3 downto 0) := (others => '0');

  function oh2(i : std_logic_vector(1 downto 0)) return std_logic_vector is
  begin
    case i is
      when "00" => return "0001";
      when "01" => return "0010";
      when "10" => return "0100";
      when others => return "1000";
    end case;
  end function;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        st  <= id;
        whr <= '0';
        vq  <= (others => '0');
      else
        case st is
          when id =>
            vq <= vo;
            if req = '1' and we = '0' and h = '0' then
              st <= rgnt;
            elsif req = '1' and we = '1' then
              whr <= h;
              st <= wgnt;
            else
              st <= id;
            end if;
          when rgnt =>
            if rg = '1' then
              st <= rfil;
            end if;
          when rfil =>
            st <= id;
          when wgnt =>
            if rg = '1' then
              st <= id;
            end if;
        end case;
      end if;
    end if;
  end process;

  rr <= '1' when st = rgnt or st = wgnt else '0';
  rw <= '1' when st = wgnt else '0';
  fs <= '1' when st = rfil else '0';

  rdy <= '1' when (st = id and req = '1' and we = '0' and h = '1') or
                  st = rfil or
                  (st = wgnt and rg = '1') else '0';

  hp <= '1' when (st = id and req = '1' and h = '1') else '0';
  mp <= '1' when (st = id and req = '1' and h = '0') or st = rfil else '0';

  ww <= oh2(hw) when st = id and req = '1' and we = '1' and h = '1' else
        vq      when st = rfil else
        vq      when st = wgnt and rg = '1' and whr = '0' else
        "0000";

  ai <= not vq when st = rfil else
        not vq when st = wgnt and rg = '1' and whr = '0' else
        "0000";
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity ri is
  port (
    ad : in  addr_t;
    wd : in  word_t;
    rr : in  std_logic;
    rw : in  std_logic;
    ra : out addr_t;
    ww : out word_t;
    ro : out std_logic;
    wo : out std_logic
  );
end entity;

architecture rtl of ri is
begin
  ra <= ad;
  ww <= wd;
  ro <= rr;
  wo <= rw;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity appendix_i_cache_top is
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    req  : in  std_logic;
    we   : in  std_logic;
    ad   : in  addr_t;
    wd   : in  word_t;
    rmd  : in  word_t;
    rg   : in  std_logic;

    rd   : out word_t;
    rdy  : out std_logic;
    hit  : out std_logic;
    miss : out std_logic;
    rr   : out std_logic;
    rw   : out std_logic;
    ra   : out addr_t;
    rwd  : out word_t;

    tg   : out std_logic_vector(11 downto 0);
    si   : out std_logic_vector(3 downto 0);
    wh   : out std_logic_vector(3 downto 0);
    hw   : out std_logic_vector(1 downto 0);
    vw   : out std_logic_vector(1 downto 0);
    vo   : out std_logic_vector(3 downto 0);
    ww   : out std_logic_vector(3 downto 0);
    ai   : out std_logic_vector(3 downto 0);
    di   : out word_t;
    cd   : out word_t;
    d0   : out word_t;
    d1   : out word_t;
    d2   : out word_t;
    d3   : out word_t;
    t0   : out std_logic_vector(11 downto 0);
    t1   : out std_logic_vector(11 downto 0);
    t2   : out std_logic_vector(11 downto 0);
    t3   : out std_logic_vector(11 downto 0);
    vv   : out std_logic_vector(3 downto 0);
    aa   : out std_logic_vector(7 downto 0)
  );
end entity;

architecture structural of appendix_i_cache_top is
  signal tag_s  : std_logic_vector(11 downto 0);
  signal set_s  : std_logic_vector(3 downto 0);
  signal din_s  : word_t;

  signal d0_s, d1_s, d2_s, d3_s : word_t;
  signal t0_s, t1_s, t2_s, t3_s : std_logic_vector(11 downto 0);
  signal v_s   : std_logic_vector(3 downto 0);
  signal a0_s, a1_s, a2_s, a3_s : unsigned(1 downto 0);
  signal eq_s  : std_logic_vector(3 downto 0);
  signal wh_s  : std_logic_vector(3 downto 0);
  signal hw_s  : std_logic_vector(1 downto 0);
  signal hit_s : std_logic;
  signal mis_s : std_logic;
  signal vw_s  : std_logic_vector(1 downto 0);
  signal vo_s  : std_logic_vector(3 downto 0);
  signal ww_s  : std_logic_vector(3 downto 0);
  signal ai_s  : std_logic_vector(3 downto 0);
  signal rrs_s : std_logic;
  signal rws_s : std_logic;
  signal fs_s  : std_logic;
  signal cd_s  : word_t;
  signal hp_s  : std_logic;
  signal mp_s  : std_logic;

  attribute keep : boolean;
  attribute keep of tag_s : signal is true;
  attribute keep of set_s : signal is true;
  attribute keep of wh_s  : signal is true;
  attribute keep of vo_s  : signal is true;
  attribute keep of ww_s  : signal is true;
  attribute keep of ai_s  : signal is true;
begin
  din_s <= rmd when fs_s = '1' else wd;
  rd    <= cd_s when hit_s = '1' else rmd;
  hit   <= hp_s;
  miss  <= mp_s or (mis_s and req);

  u_sp : entity work.sp port map (ad => ad, tg => tag_s, st => set_s);

  u_ct : entity work.ct
    port map (
      clk => clk,
      rst => rst,
      req => req,
      we  => we,
      h   => hit_s,
      hw  => hw_s,
      vo  => vo_s,
      rg  => rg,
      ww  => ww_s,
      ai  => ai_s,
      rr  => rrs_s,
      rw  => rws_s,
      fs  => fs_s,
      rdy => rdy,
      hp  => hp_s,
      mp  => mp_s
    );

  u_vc : entity work.vc port map (v => v_s, a0 => a0_s, a1 => a1_s, a2 => a2_s, a3 => a3_s, vw => vw_s, oh => vo_s);
  u_ri : entity work.ri port map (ad => ad, wd => wd, rr => rrs_s, rw => rws_s, ra => ra, ww => rwd, ro => rr, wo => rw);
  u_mx : entity work.mx port map (hw => hw_s, d0 => d0_s, d1 => d1_s, d2 => d2_s, d3 => d3_s, q => cd_s);

  u_d0 : entity work.dw port map (clk => clk, st => set_s, we => ww_s(0), d => din_s, q => d0_s);
  u_d1 : entity work.dw port map (clk => clk, st => set_s, we => ww_s(1), d => din_s, q => d1_s);
  u_d2 : entity work.dw port map (clk => clk, st => set_s, we => ww_s(2), d => din_s, q => d2_s);
  u_d3 : entity work.dw port map (clk => clk, st => set_s, we => ww_s(3), d => din_s, q => d3_s);

  u_t0 : entity work.tw port map (clk => clk, st => set_s, we => ww_s(0), d => tag_s, q => t0_s);
  u_t1 : entity work.tw port map (clk => clk, st => set_s, we => ww_s(1), d => tag_s, q => t1_s);
  u_t2 : entity work.tw port map (clk => clk, st => set_s, we => ww_s(2), d => tag_s, q => t2_s);
  u_t3 : entity work.tw port map (clk => clk, st => set_s, we => ww_s(3), d => tag_s, q => t3_s);

  u_v0 : entity work.vw port map (clk => clk, rst => rst, st => set_s, we => ww_s(0), d => '1', q => v_s(0));
  u_v1 : entity work.vw port map (clk => clk, rst => rst, st => set_s, we => ww_s(1), d => '1', q => v_s(1));
  u_v2 : entity work.vw port map (clk => clk, rst => rst, st => set_s, we => ww_s(2), d => '1', q => v_s(2));
  u_v3 : entity work.vw port map (clk => clk, rst => rst, st => set_s, we => ww_s(3), d => '1', q => v_s(3));

  u_a0 : entity work.aw port map (clk => clk, rst => rst, st => set_s, we => ww_s(0), inc => ai_s(0), d => "00", q => a0_s);
  u_a1 : entity work.aw port map (clk => clk, rst => rst, st => set_s, we => ww_s(1), inc => ai_s(1), d => "00", q => a1_s);
  u_a2 : entity work.aw port map (clk => clk, rst => rst, st => set_s, we => ww_s(2), inc => ai_s(2), d => "00", q => a2_s);
  u_a3 : entity work.aw port map (clk => clk, rst => rst, st => set_s, we => ww_s(3), inc => ai_s(3), d => "00", q => a3_s);

  u_e0 : entity work.eq port map (a => tag_s, b => t0_s, y => eq_s(0));
  u_e1 : entity work.eq port map (a => tag_s, b => t1_s, y => eq_s(1));
  u_e2 : entity work.eq port map (a => tag_s, b => t2_s, y => eq_s(2));
  u_e3 : entity work.eq port map (a => tag_s, b => t3_s, y => eq_s(3));

  u_hm : entity work.hm port map (e => eq_s, v => v_s, wh => wh_s, hw => hw_s, h => hit_s, m => mis_s);

  tg <= tag_s;
  si <= set_s;
  wh <= wh_s;
  hw <= hw_s;
  vw <= vw_s;
  vo <= vo_s;
  ww <= ww_s;
  ai <= ai_s;
  di <= din_s;
  cd <= cd_s;
  d0 <= d0_s;
  d1 <= d1_s;
  d2 <= d2_s;
  d3 <= d3_s;
  t0 <= t0_s;
  t1 <= t1_s;
  t2 <= t2_s;
  t3 <= t3_s;
  vv <= v_s;
  aa <= std_logic_vector(a3_s) & std_logic_vector(a2_s) & std_logic_vector(a1_s) & std_logic_vector(a0_s);
end architecture;
