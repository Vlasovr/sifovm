library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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

entity r3 is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    en  : in  std_logic;
    d   : in  std_logic_vector(2 downto 0);
    q   : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of r3 is
  signal qr : std_logic_vector(2 downto 0) := "111";
  attribute keep     : boolean;
  attribute preserve : boolean;
  attribute keep of qr     : signal is true;
  attribute preserve of qr : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        qr <= "111";
      elsif en = '1' then
        qr <= d;
      end if;
    end if;
  end process;

  q <= qr;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity is0 is
  port (
    a : in  std_logic_vector(2 downto 0);
    y : out std_logic
  );
end entity;

architecture rtl of is0 is
begin
  y <= '1' when a = "000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity is7 is
  port (
    a : in  std_logic_vector(2 downto 0);
    y : out std_logic
  );
end entity;

architecture rtl of is7 is
begin
  y <= '1' when a = "111" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ctl is
  port (
    cmd : in  std_logic_vector(1 downto 0);
    ful : in  std_logic;
    emp : in  std_logic;
    pu  : out std_logic;
    po  : out std_logic;
    en  : out std_logic;
    ov  : out std_logic;
    un  : out std_logic
  );
end entity;

architecture rtl of ctl is
  signal pu_s : std_logic;
  signal po_s : std_logic;
begin
  process(cmd, ful, emp)
  begin
    pu_s <= '0';
    po_s <= '0';
    ov <= '0';
    un <= '0';

    case cmd is
      when "01" =>
        if ful = '1' then
          ov <= '1';
        else
          pu_s <= '1';
        end if;
      when "10" =>
        if emp = '1' then
          un <= '1';
        else
          po_s <= '1';
        end if;
      when others =>
        null;
    end case;
  end process;

  pu <= pu_s;
  po <= po_s;
  en <= pu_s or po_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity spc is
  port (
    s  : in  std_logic_vector(2 downto 0);
    pu : in  std_logic;
    po : in  std_logic;
    wa : out std_logic_vector(2 downto 0);
    sn : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of spc is
  signal sv : unsigned(2 downto 0);
  signal wn : unsigned(2 downto 0);
  signal nn : unsigned(2 downto 0);
begin
  sv <= unsigned(s);
  wn <= sv - 1;
  nn <= sv - 1 when pu = '1' else
        sv + 1 when po = '1' else
        sv;

  wa <= std_logic_vector(wn);
  sn <= std_logic_vector(nn);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec7 is
  port (
    a  : in  std_logic_vector(2 downto 0);
    en : in  std_logic;
    y  : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of dec7 is
begin
  process(a, en)
  begin
    y <= (others => '0');
    if en = '1' then
      case a is
        when "000" => y <= "0000001";
        when "001" => y <= "0000010";
        when "010" => y <= "0000100";
        when "011" => y <= "0001000";
        when "100" => y <= "0010000";
        when "101" => y <= "0100000";
        when "110" => y <= "1000000";
        when others => y <= (others => '0');
      end case;
    end if;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mx7 is
  port (
    a  : in  std_logic_vector(2 downto 0);
    q0 : in  std_logic_vector(15 downto 0);
    q1 : in  std_logic_vector(15 downto 0);
    q2 : in  std_logic_vector(15 downto 0);
    q3 : in  std_logic_vector(15 downto 0);
    q4 : in  std_logic_vector(15 downto 0);
    q5 : in  std_logic_vector(15 downto 0);
    q6 : in  std_logic_vector(15 downto 0);
    y  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mx7 is
begin
  process(a, q0, q1, q2, q3, q4, q5, q6)
  begin
    case a is
      when "000" => y <= q0;
      when "001" => y <= q1;
      when "010" => y <= q2;
      when "011" => y <= q3;
      when "100" => y <= q4;
      when "101" => y <= q5;
      when "110" => y <= q6;
      when others => y <= (others => '0');
    end case;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity appendix_d_stack_top is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    cmd : in  std_logic_vector(1 downto 0);
    di  : in  std_logic_vector(15 downto 0);
    do  : out std_logic_vector(15 downto 0);
    top : out std_logic_vector(15 downto 0);
    sp  : out std_logic_vector(2 downto 0);
    emp : out std_logic;
    ful : out std_logic;
    ov  : out std_logic;
    un  : out std_logic;
    pu  : out std_logic;
    po  : out std_logic;
    we  : out std_logic_vector(6 downto 0)
  );
end entity;

architecture structural of appendix_d_stack_top is
  signal sp_s  : std_logic_vector(2 downto 0);
  signal sn_s  : std_logic_vector(2 downto 0);
  signal wa_s  : std_logic_vector(2 downto 0);
  signal emp_s : std_logic;
  signal ful_s : std_logic;
  signal pu_s  : std_logic;
  signal po_s  : std_logic;
  signal en_s  : std_logic;
  signal we_s  : std_logic_vector(6 downto 0);
  signal q0_s  : std_logic_vector(15 downto 0);
  signal q1_s  : std_logic_vector(15 downto 0);
  signal q2_s  : std_logic_vector(15 downto 0);
  signal q3_s  : std_logic_vector(15 downto 0);
  signal q4_s  : std_logic_vector(15 downto 0);
  signal q5_s  : std_logic_vector(15 downto 0);
  signal q6_s  : std_logic_vector(15 downto 0);
  signal top_s : std_logic_vector(15 downto 0);

  attribute keep : boolean;
  attribute keep of sp_s  : signal is true;
  attribute keep of sn_s  : signal is true;
  attribute keep of wa_s  : signal is true;
  attribute keep of we_s  : signal is true;
  attribute keep of top_s : signal is true;
begin
  u_c0  : entity work.is0 port map (sp_s, ful_s);
  u_c7  : entity work.is7 port map (sp_s, emp_s);
  u_ctl : entity work.ctl port map (cmd, ful_s, emp_s, pu_s, po_s, en_s, ov, un);
  u_spc : entity work.spc port map (sp_s, pu_s, po_s, wa_s, sn_s);
  u_sp  : entity work.r3 port map (clk, rst, en_s, sn_s, sp_s);
  u_dec : entity work.dec7 port map (wa_s, pu_s, we_s);

  u_m0 : entity work.r16 port map (clk, rst, we_s(0), di, q0_s);
  u_m1 : entity work.r16 port map (clk, rst, we_s(1), di, q1_s);
  u_m2 : entity work.r16 port map (clk, rst, we_s(2), di, q2_s);
  u_m3 : entity work.r16 port map (clk, rst, we_s(3), di, q3_s);
  u_m4 : entity work.r16 port map (clk, rst, we_s(4), di, q4_s);
  u_m5 : entity work.r16 port map (clk, rst, we_s(5), di, q5_s);
  u_m6 : entity work.r16 port map (clk, rst, we_s(6), di, q6_s);

  u_mx : entity work.mx7 port map (sp_s, q0_s, q1_s, q2_s, q3_s, q4_s, q5_s, q6_s, top_s);
  u_dr : entity work.r16 port map (clk, rst, po_s, top_s, do);

  top <= top_s;
  sp  <= sp_s;
  emp <= emp_s;
  ful <= ful_s;
  pu  <= pu_s;
  po  <= po_s;
  we  <= we_s;
end architecture;
