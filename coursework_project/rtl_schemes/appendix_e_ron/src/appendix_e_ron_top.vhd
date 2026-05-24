library ieee;
use ieee.std_logic_1164.all;

entity a2 is
  port (
    a : in  std_logic;
    b : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of a2 is
begin
  y <= a and b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity r16 is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    en  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of r16 is
  signal qr : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of qr     : signal is true;
  attribute preserve of qr : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        qr <= (others => '0');
      elsif en = '1' then
        qr <= d;
      end if;
    end if;
  end process;

  q <= qr;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec12 is
  port (
    a : in  std_logic_vector(3 downto 0);
    y : out std_logic_vector(11 downto 0)
  );
end entity;

architecture rtl of dec12 is
begin
  process(a)
  begin
    y <= (others => '0');
    case a is
      when x"0" => y <= "000000000001";
      when x"1" => y <= "000000000010";
      when x"2" => y <= "000000000100";
      when x"3" => y <= "000000001000";
      when x"4" => y <= "000000010000";
      when x"5" => y <= "000000100000";
      when x"6" => y <= "000001000000";
      when x"7" => y <= "000010000000";
      when x"8" => y <= "000100000000";
      when x"9" => y <= "001000000000";
      when x"A" => y <= "010000000000";
      when x"B" => y <= "100000000000";
      when others => y <= (others => '0');
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mx12 is
  port (
    a   : in  std_logic_vector(3 downto 0);
    q0  : in  std_logic_vector(15 downto 0);
    q1  : in  std_logic_vector(15 downto 0);
    q2  : in  std_logic_vector(15 downto 0);
    q3  : in  std_logic_vector(15 downto 0);
    q4  : in  std_logic_vector(15 downto 0);
    q5  : in  std_logic_vector(15 downto 0);
    q6  : in  std_logic_vector(15 downto 0);
    q7  : in  std_logic_vector(15 downto 0);
    q8  : in  std_logic_vector(15 downto 0);
    q9  : in  std_logic_vector(15 downto 0);
    q10 : in  std_logic_vector(15 downto 0);
    q11 : in  std_logic_vector(15 downto 0);
    y   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mx12 is
begin
  process(a, q0, q1, q2, q3, q4, q5, q6, q7, q8, q9, q10, q11)
  begin
    case a is
      when x"0" => y <= q0;
      when x"1" => y <= q1;
      when x"2" => y <= q2;
      when x"3" => y <= q3;
      when x"4" => y <= q4;
      when x"5" => y <= q5;
      when x"6" => y <= q6;
      when x"7" => y <= q7;
      when x"8" => y <= q8;
      when x"9" => y <= q9;
      when x"A" => y <= q10;
      when x"B" => y <= q11;
      when others => y <= (others => '0');
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mx6 is
  port (
    a  : in  std_logic_vector(2 downto 0);
    q0 : in  std_logic_vector(15 downto 0);
    q1 : in  std_logic_vector(15 downto 0);
    q2 : in  std_logic_vector(15 downto 0);
    q3 : in  std_logic_vector(15 downto 0);
    q4 : in  std_logic_vector(15 downto 0);
    q5 : in  std_logic_vector(15 downto 0);
    y  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mx6 is
begin
  process(a, q0, q1, q2, q3, q4, q5)
  begin
    case a is
      when "000" => y <= q0;
      when "001" => y <= q1;
      when "010" => y <= q2;
      when "011" => y <= q3;
      when "100" => y <= q4;
      when "101" => y <= q5;
      when others => y <= (others => '0');
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mx2 is
  port (
    s : in  std_logic;
    a : in  std_logic_vector(15 downto 0);
    b : in  std_logic_vector(15 downto 0);
    y : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mx2 is
begin
  y <= b when s = '1' else a;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity msk16 is
  port (
    en : in  std_logic;
    a  : in  std_logic_vector(15 downto 0);
    y  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of msk16 is
begin
  y <= a when en = '1' else (others => '0');
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity sel12 is
  port (
    a  : in  std_logic_vector(3 downto 0);
    lo : out std_logic_vector(2 downto 0);
    hi : out std_logic_vector(2 downto 0);
    hs : out std_logic;
    ok : out std_logic
  );
end entity;

architecture rtl of sel12 is
begin
  process(a)
  begin
    lo <= a(2 downto 0);
    hi <= "000";
    hs <= '0';
    ok <= '1';

    case a is
      when x"0" | x"1" | x"2" | x"3" | x"4" | x"5" =>
        null;
      when x"6" =>
        hi <= "000"; hs <= '1';
      when x"7" =>
        hi <= "001"; hs <= '1';
      when x"8" =>
        hi <= "010"; hs <= '1';
      when x"9" =>
        hi <= "011"; hs <= '1';
      when x"A" =>
        hi <= "100"; hs <= '1';
      when x"B" =>
        hi <= "101"; hs <= '1';
      when others =>
        ok <= '0';
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bank6 is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    w   : in  std_logic_vector(5 downto 0);
    di  : in  std_logic_vector(15 downto 0);
    sa  : in  std_logic_vector(2 downto 0);
    sb  : in  std_logic_vector(2 downto 0);
    qa  : out std_logic_vector(15 downto 0);
    qb  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of bank6 is
  signal q0_s : std_logic_vector(15 downto 0);
  signal q1_s : std_logic_vector(15 downto 0);
  signal q2_s : std_logic_vector(15 downto 0);
  signal q3_s : std_logic_vector(15 downto 0);
  signal q4_s : std_logic_vector(15 downto 0);
  signal q5_s : std_logic_vector(15 downto 0);
begin
  u_r0 : entity work.r16 port map (clk, rst, w(0), di, q0_s);
  u_r1 : entity work.r16 port map (clk, rst, w(1), di, q1_s);
  u_r2 : entity work.r16 port map (clk, rst, w(2), di, q2_s);
  u_r3 : entity work.r16 port map (clk, rst, w(3), di, q3_s);
  u_r4 : entity work.r16 port map (clk, rst, w(4), di, q4_s);
  u_r5 : entity work.r16 port map (clk, rst, w(5), di, q5_s);

  u_ma : entity work.mx6 port map (sa, q0_s, q1_s, q2_s, q3_s, q4_s, q5_s, qa);
  u_mb : entity work.mx6 port map (sb, q0_s, q1_s, q2_s, q3_s, q4_s, q5_s, qb);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity appendix_e_ron_top is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    wa  : in  std_logic_vector(3 downto 0);
    ra  : in  std_logic_vector(3 downto 0);
    rb  : in  std_logic_vector(3 downto 0);
    di  : in  std_logic_vector(15 downto 0);
    qa  : out std_logic_vector(15 downto 0);
    qb  : out std_logic_vector(15 downto 0);
    wd  : out std_logic_vector(11 downto 0)
  );
end entity;

architecture structural of appendix_e_ron_top is
  signal d_s  : std_logic_vector(11 downto 0);
  signal w_s  : std_logic_vector(11 downto 0);
  signal la_s : std_logic_vector(2 downto 0);
  signal ha_s : std_logic_vector(2 downto 0);
  signal lb_s : std_logic_vector(2 downto 0);
  signal hb_s : std_logic_vector(2 downto 0);
  signal hsa_s : std_logic;
  signal hsb_s : std_logic;
  signal oka_s : std_logic;
  signal okb_s : std_logic;
  signal qa_l  : std_logic_vector(15 downto 0);
  signal qa_h  : std_logic_vector(15 downto 0);
  signal qb_l  : std_logic_vector(15 downto 0);
  signal qb_h  : std_logic_vector(15 downto 0);
  signal qax_s : std_logic_vector(15 downto 0);
  signal qbx_s : std_logic_vector(15 downto 0);
  signal qa_s : std_logic_vector(15 downto 0);
  signal qb_s : std_logic_vector(15 downto 0);

  attribute keep : boolean;
  attribute keep of d_s  : signal is true;
  attribute keep of w_s  : signal is true;
  attribute keep of la_s : signal is true;
  attribute keep of ha_s : signal is true;
  attribute keep of lb_s : signal is true;
  attribute keep of hb_s : signal is true;
  attribute keep of qa_s : signal is true;
  attribute keep of qb_s : signal is true;
begin
  u_dec : entity work.dec12 port map (wa, d_s);

  u_w0  : entity work.a2 port map (we, d_s(0),  w_s(0));
  u_w1  : entity work.a2 port map (we, d_s(1),  w_s(1));
  u_w2  : entity work.a2 port map (we, d_s(2),  w_s(2));
  u_w3  : entity work.a2 port map (we, d_s(3),  w_s(3));
  u_w4  : entity work.a2 port map (we, d_s(4),  w_s(4));
  u_w5  : entity work.a2 port map (we, d_s(5),  w_s(5));
  u_w6  : entity work.a2 port map (we, d_s(6),  w_s(6));
  u_w7  : entity work.a2 port map (we, d_s(7),  w_s(7));
  u_w8  : entity work.a2 port map (we, d_s(8),  w_s(8));
  u_w9  : entity work.a2 port map (we, d_s(9),  w_s(9));
  u_w10 : entity work.a2 port map (we, d_s(10), w_s(10));
  u_w11 : entity work.a2 port map (we, d_s(11), w_s(11));

  u_sa : entity work.sel12 port map (ra, la_s, ha_s, hsa_s, oka_s);
  u_sb : entity work.sel12 port map (rb, lb_s, hb_s, hsb_s, okb_s);

  u_lo : entity work.bank6 port map (clk, rst, w_s(5 downto 0), di, la_s, lb_s, qa_l, qb_l);
  u_hi : entity work.bank6 port map (clk, rst, w_s(11 downto 6), di, ha_s, hb_s, qa_h, qb_h);

  u_xa : entity work.mx2 port map (hsa_s, qa_l, qa_h, qax_s);
  u_xb : entity work.mx2 port map (hsb_s, qb_l, qb_h, qbx_s);
  u_qa : entity work.msk16 port map (oka_s, qax_s, qa_s);
  u_qb : entity work.msk16 port map (okb_s, qbx_s, qb_s);

  qa <= qa_s;
  qb <= qb_s;
  wd <= w_s;
end architecture;
