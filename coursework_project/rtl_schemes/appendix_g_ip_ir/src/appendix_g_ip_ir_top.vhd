library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity ip_ctl is
  port (
    ipi : in  std_logic;
    ipl : in  std_logic;
    ipe : out std_logic
  );
end entity;

architecture rtl of ip_ctl is
begin
  ipe <= ipi or ipl;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity ip_inc16 is
  port (
    a : in  std_logic_vector(15 downto 0);
    y : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of ip_inc16 is
  signal one_s : std_logic_vector(15 downto 0);

  attribute keep : boolean;
  attribute keep of one_s : signal is true;
begin
  one_s <= x"0001";

  ip_plus_one : lpm_add_sub
    generic map (
      lpm_direction      => "ADD",
      lpm_representation => "UNSIGNED",
      lpm_type           => "LPM_ADD_SUB",
      lpm_width          => 16
    )
    port map (
      dataa  => a,
      datab  => one_s,
      result => y
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ip_mux16 is
  port (
    sel : in  std_logic;
    inc : in  std_logic_vector(15 downto 0);
    jmp : in  std_logic_vector(15 downto 0);
    y   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of ip_mux16 is
begin
  y <= jmp when sel = '1' else inc;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity ip_reg16 is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    en  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of ip_reg16 is
begin
  ip_register : lpm_ff
    generic map (
      lpm_fftype => "DFF",
      lpm_type   => "LPM_FF",
      lpm_width  => 16
    )
    port map (
      data   => d,
      clock  => clk,
      enable => en,
      sclr   => rst,
      q      => q
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity r16 is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    ld  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of r16 is
begin
  dff16 : lpm_ff
    generic map (
      lpm_fftype => "DFF",
      lpm_type   => "LPM_FF",
      lpm_width  => 16
    )
    port map (
      data   => d,
      clock  => clk,
      enable => ld,
      sclr   => rst,
      q      => q
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity word_split is
  port (
    d  : in  std_logic_vector(15 downto 0);
    dh : out std_logic_vector(7 downto 0);
    dl : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of word_split is
begin
  dh <= d(15 downto 8);
  dl <= d(7 downto 0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ir_dec is
  port (
    ir  : in  std_logic_vector(15 downto 0);
    cmd : out std_logic_vector(7 downto 0);
    ra  : out std_logic_vector(3 downto 0);
    rb  : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of ir_dec is
begin
  cmd <= ir(15 downto 8);
  ra  <= ir(7 downto 4);
  rb  <= ir(3 downto 0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity addr_bytes is
  port (
    ah : in  std_logic_vector(15 downto 0);
    al : in  std_logic_vector(15 downto 0);
    mh : out std_logic_vector(7 downto 0);
    ml : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of addr_bytes is
begin
  mh <= ah(15 downto 8);
  ml <= al(7 downto 0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity addr_join is
  port (
    mh : in  std_logic_vector(7 downto 0);
    ml : in  std_logic_vector(7 downto 0);
    ma : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of addr_join is
begin
  ma <= mh & ml;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity appendix_g_ip_ir_top is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    ipi   : in  std_logic;
    ipl   : in  std_logic;
    irl   : in  std_logic;
    ahl   : in  std_logic;
    all_i : in  std_logic;
    din   : in  std_logic_vector(15 downto 0);
    jmp   : in  std_logic_vector(15 downto 0);

    ip    : out std_logic_vector(15 downto 0);
    ir    : out std_logic_vector(15 downto 0);
    ah    : out std_logic_vector(15 downto 0);
    al    : out std_logic_vector(15 downto 0);
    ip1   : out std_logic_vector(15 downto 0);
    ipd   : out std_logic_vector(15 downto 0);
    cmd   : out std_logic_vector(7 downto 0);
    ra    : out std_logic_vector(3 downto 0);
    rb    : out std_logic_vector(3 downto 0);
    dh    : out std_logic_vector(7 downto 0);
    dl    : out std_logic_vector(7 downto 0);
    mh    : out std_logic_vector(7 downto 0);
    ml    : out std_logic_vector(7 downto 0);
    ma    : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of appendix_g_ip_ir_top is
  signal ip_en_s : std_logic;
  signal ip1_s   : std_logic_vector(15 downto 0);
  signal ipd_s   : std_logic_vector(15 downto 0);
  signal ip_s    : std_logic_vector(15 downto 0);
  signal ir_s    : std_logic_vector(15 downto 0);
  signal ah_s    : std_logic_vector(15 downto 0);
  signal al_s    : std_logic_vector(15 downto 0);
  signal mh_s    : std_logic_vector(7 downto 0);
  signal ml_s    : std_logic_vector(7 downto 0);

  attribute keep : boolean;
  attribute keep of ip_en_s : signal is true;
  attribute keep of ip1_s   : signal is true;
  attribute keep of ipd_s   : signal is true;
  attribute keep of ip_s    : signal is true;
  attribute keep of ir_s    : signal is true;
  attribute keep of ah_s    : signal is true;
  attribute keep of al_s    : signal is true;
  attribute keep of mh_s    : signal is true;
  attribute keep of ml_s    : signal is true;
begin
  u_ctl : entity work.ip_ctl
    port map (
      ipi => ipi,
      ipl => ipl,
      ipe => ip_en_s
    );

  u_ip_inc : entity work.ip_inc16
    port map (
      a => ip_s,
      y => ip1_s
    );

  u_ip_mux : entity work.ip_mux16
    port map (
      sel => ipl,
      inc => ip1_s,
      jmp => jmp,
      y   => ipd_s
    );

  u_ip : entity work.ip_reg16
    port map (
      clk => clk,
      rst => rst,
      en  => ip_en_s,
      d   => ipd_s,
      q   => ip_s
    );

  u_ir : entity work.r16
    port map (
      clk => clk,
      rst => rst,
      ld  => irl,
      d   => din,
      q   => ir_s
    );

  u_ah : entity work.r16
    port map (
      clk => clk,
      rst => rst,
      ld  => ahl,
      d   => din,
      q   => ah_s
    );

  u_al : entity work.r16
    port map (
      clk => clk,
      rst => rst,
      ld  => all_i,
      d   => din,
      q   => al_s
    );

  ip  <= ip_s;
  ir  <= ir_s;
  ah  <= ah_s;
  al  <= al_s;
  ip1 <= ip1_s;
  ipd <= ipd_s;

  u_din : entity work.word_split
    port map (
      d  => din,
      dh => dh,
      dl => dl
    );

  u_dec : entity work.ir_dec
    port map (
      ir  => ir_s,
      cmd => cmd,
      ra  => ra,
      rb  => rb
    );

  u_ab : entity work.addr_bytes
    port map (
      ah => ah_s,
      al => al_s,
      mh => mh_s,
      ml => ml_s
    );

  u_ma : entity work.addr_join
    port map (
      mh => mh_s,
      ml => ml_s,
      ma => ma
    );

  mh <= mh_s;
  ml <= ml_s;
end architecture;
