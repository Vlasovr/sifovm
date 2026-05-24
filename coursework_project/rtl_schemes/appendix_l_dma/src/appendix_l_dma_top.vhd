library ieee;
use ieee.std_logic_1164.all;

entity sr is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    d   : in  std_logic_vector(1 downto 0);
    q   : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of sr is
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
      else
        r <= d;
      end if;
    end if;
  end process;

  q <= r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ix is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    clr : in  std_logic;
    inc : in  std_logic;
    q   : out std_logic_vector(1 downto 0);
    ls  : out std_logic
  );
end entity;

architecture rtl of ix is
  signal r : unsigned(1 downto 0) := (others => '0');
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of r     : signal is true;
  attribute preserve of r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' or clr = '1' then
        r <= (others => '0');
      elsif inc = '1' then
        r <= r + 1;
      end if;
    end if;
  end process;

  q  <= std_logic_vector(r);
  ls <= '1' when r = "10" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity df is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    clr : in  std_logic;
    set : in  std_logic;
    q   : out std_logic
  );
end entity;

architecture rtl of df is
  signal r : std_logic := '0';
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of r     : signal is true;
  attribute preserve of r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r <= '0';
      elsif clr = '1' then
        r <= '0';
      elsif set = '1' then
        r <= '1';
      end if;
    end if;
  end process;

  q <= r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ct is
  port (
    st : in  std_logic_vector(1 downto 0);
    go : in  std_logic;
    gr : in  std_logic;
    dv : in  std_logic;
    ls : in  std_logic;
    nx : out std_logic_vector(1 downto 0);
    rq : out std_logic;
    bs : out std_logic;
    we : out std_logic;
    ic : out std_logic;
    ii : out std_logic;
    dc : out std_logic;
    ds : out std_logic;
    wa : out std_logic
  );
end entity;

architecture rtl of ct is
  constant S0 : std_logic_vector(1 downto 0) := "00";
  constant S1 : std_logic_vector(1 downto 0) := "01";
  constant S2 : std_logic_vector(1 downto 0) := "10";
  constant S3 : std_logic_vector(1 downto 0) := "11";
begin
  process(st, go, gr, dv, ls)
    variable wr_ok : std_logic;
  begin
    nx <= st;
    rq <= '0';
    bs <= '1';
    we <= '0';
    ic <= '0';
    ii <= '0';
    dc <= '0';
    ds <= '0';

    wr_ok := gr and dv;
    wa <= wr_ok;

    case st is
      when S0 =>
        bs <= '0';
        if go = '1' then
          nx <= S1;
          ic <= '1';
          dc <= '1';
        end if;

      when S1 =>
        rq <= '1';
        if gr = '1' then
          nx <= S2;
        end if;

      when S2 =>
        rq <= '1';
        we <= wr_ok;
        if wr_ok = '1' then
          if ls = '1' then
            nx <= S3;
          else
            ii <= '1';
          end if;
        end if;

      when others =>
        ds <= '1';
        nx <= S0;
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity ag is
  port (
    ix : in  std_logic_vector(1 downto 0);
    ba : out addr_t
  );
end entity;

architecture rtl of ag is
begin
  ba <= std_logic_vector(to_unsigned(10, ADDR_W) + resize(unsigned(ix), ADDR_W));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity ri is
  port (
    we : in  std_logic;
    ad : in  addr_t;
    dd : in  word_t;
    rw : out std_logic;
    ra : out addr_t;
    rd : out word_t
  );
end entity;

architecture rtl of ri is
begin
  rw <= we;
  ra <= ad;
  rd <= dd;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_l_dma_top is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;
    grant : in  std_logic;
    dv    : in  std_logic;
    dd    : in  word_t;

    req   : out std_logic;
    busy  : out std_logic;
    done  : out std_logic;
    we    : out std_logic;
    ra    : out addr_t;
    rd    : out word_t;

    st    : out std_logic_vector(1 downto 0);
    nx    : out std_logic_vector(1 downto 0);
    ixv   : out std_logic_vector(1 downto 0);
    last  : out std_logic;
    inc   : out std_logic;
    clr   : out std_logic;
    dclr  : out std_logic;
    dset  : out std_logic;
    wa    : out std_logic;
    ba    : out addr_t
  );
end entity;

architecture structural of appendix_l_dma_top is
  signal st_s   : std_logic_vector(1 downto 0);
  signal nx_s   : std_logic_vector(1 downto 0);
  signal ix_s   : std_logic_vector(1 downto 0);
  signal ls_s   : std_logic;
  signal rq_s   : std_logic;
  signal bs_s   : std_logic;
  signal we_s   : std_logic;
  signal ic_s   : std_logic;
  signal ii_s   : std_logic;
  signal dc_s   : std_logic;
  signal ds_s   : std_logic;
  signal wa_s   : std_logic;
  signal ba_s   : addr_t;

  attribute keep : boolean;
  attribute keep of st_s : signal is true;
  attribute keep of nx_s : signal is true;
  attribute keep of ix_s : signal is true;
  attribute keep of ba_s : signal is true;
begin
  u_st : entity work.sr port map (clk => clk, rst => rst, d => nx_s, q => st_s);
  u_ix : entity work.ix port map (clk => clk, rst => rst, clr => ic_s, inc => ii_s, q => ix_s, ls => ls_s);
  u_df : entity work.df port map (clk => clk, rst => rst, clr => dc_s, set => ds_s, q => done);
  u_ct : entity work.ct port map (st => st_s, go => start, gr => grant, dv => dv, ls => ls_s,
                                  nx => nx_s, rq => rq_s, bs => bs_s, we => we_s,
                                  ic => ic_s, ii => ii_s, dc => dc_s, ds => ds_s, wa => wa_s);
  u_ag : entity work.ag port map (ix => ix_s, ba => ba_s);
  u_ri : entity work.ri port map (we => we_s, ad => ba_s, dd => dd, rw => we, ra => ra, rd => rd);

  req  <= rq_s;
  busy <= bs_s;
  st   <= st_s;
  nx   <= nx_s;
  ixv  <= ix_s;
  last <= ls_s;
  inc  <= ii_s;
  clr  <= ic_s;
  dclr <= dc_s;
  dset <= ds_s;
  wa   <= wa_s;
  ba   <= ba_s;
end architecture;
