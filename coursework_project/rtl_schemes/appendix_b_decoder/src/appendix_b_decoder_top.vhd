library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

entity eq8 is
  generic (
    K : std_logic_vector(7 downto 0) := x"00"
  );
  port (
    a : in  std_logic_vector(7 downto 0);
    y : out std_logic
  );
end entity;

architecture structural of eq8 is
begin
  cmp : lpm_compare
    generic map (
      lpm_hint           => "ONE_INPUT_IS_CONSTANT=YES",
      lpm_representation => "UNSIGNED",
      lpm_type           => "LPM_COMPARE",
      lpm_width          => 8
    )
    port map (
      dataa => a,
      datab => K,
      aeb   => y
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_or2 is
  port (
    a : in  std_logic;
    b : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_or2 is
begin
  y <= a or b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_or6 is
  port (
    a : in  std_logic;
    b : in  std_logic;
    c : in  std_logic;
    d : in  std_logic;
    e : in  std_logic;
    f : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_or6 is
begin
  y <= a or b or c or d or e or f;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_and2 is
  port (
    a : in  std_logic;
    b : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_and2 is
begin
  y <= a and b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_not1 is
  port (
    a : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_not1 is
begin
  y <= not a;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_b_decoder_top is
  port (
    cmd  : in  std_logic_vector(7 downto 0);
    z    : in  std_logic;
    ex   : in  std_logic;

    br   : out std_logic;
    ipl  : out std_logic;
    ipi  : out std_logic;
    hlt  : out std_logic;
    alu  : out std_logic_vector(2 downto 0);
    rw   : out std_logic;
    nz   : out std_logic;
    mw   : out std_logic;
    mr   : out std_logic;
    psh  : out std_logic;
    pop  : out std_logic;
    sl   : out std_logic;
    ra   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture structural of appendix_b_decoder_top is
  signal c_hlt_s : std_logic;
  signal c_mr_s  : std_logic;
  signal c_rm_s  : std_logic;
  signal c_or_s  : std_logic;
  signal c_nor_s : std_logic;
  signal c_sra_s : std_logic;
  signal c_inc_s : std_logic;
  signal c_psh_s : std_logic;
  signal c_pop_s : std_logic;
  signal c_jmp_s : std_logic;
  signal c_jz_s  : std_logic;

  signal br_s    : std_logic;
  signal jz_z_s  : std_logic;
  signal jmpz_s  : std_logic;
  signal nbr_s   : std_logic;
  signal nz_s    : std_logic;

  attribute keep : boolean;
  attribute keep of c_hlt_s : signal is true;
  attribute keep of c_mr_s  : signal is true;
  attribute keep of c_rm_s  : signal is true;
  attribute keep of c_or_s  : signal is true;
  attribute keep of c_nor_s : signal is true;
  attribute keep of c_sra_s : signal is true;
  attribute keep of c_inc_s : signal is true;
  attribute keep of c_psh_s : signal is true;
  attribute keep of c_pop_s : signal is true;
  attribute keep of c_jmp_s : signal is true;
  attribute keep of c_jz_s  : signal is true;
begin
  c_hlt : entity work.eq8 generic map (K => OP_HLT)    port map (cmd, c_hlt_s);
  c_mr  : entity work.eq8 generic map (K => OP_MOV_MR) port map (cmd, c_mr_s);
  c_rm  : entity work.eq8 generic map (K => OP_MOV_RM) port map (cmd, c_rm_s);
  c_or  : entity work.eq8 generic map (K => OP_OR)     port map (cmd, c_or_s);
  c_nor : entity work.eq8 generic map (K => OP_NOR)    port map (cmd, c_nor_s);
  c_sra : entity work.eq8 generic map (K => OP_SRA)    port map (cmd, c_sra_s);
  c_inc : entity work.eq8 generic map (K => OP_INCS)   port map (cmd, c_inc_s);
  c_psh : entity work.eq8 generic map (K => OP_PUSH)   port map (cmd, c_psh_s);
  c_pop : entity work.eq8 generic map (K => OP_POP)    port map (cmd, c_pop_s);
  c_jmp : entity work.eq8 generic map (K => OP_JMP)    port map (cmd, c_jmp_s);
  c_jz  : entity work.eq8 generic map (K => OP_JZ)     port map (cmd, c_jz_s);

  br_or  : entity work.g_or2  port map (c_jmp_s, c_jz_s, br_s);
  jz_and : entity work.g_and2 port map (c_jz_s, z, jz_z_s);
  ld_or  : entity work.g_or2  port map (c_jmp_s, jz_z_s, jmpz_s);
  ld_and : entity work.g_and2 port map (ex, jmpz_s, ipl);

  n_br   : entity work.g_not1 port map (br_s, nbr_s);
  inc_and: entity work.g_and2 port map (ex, nbr_s, ipi);

  n_z    : entity work.g_not1 port map (z, nz_s);
  nz_and : entity work.g_and2 port map (c_jz_s, nz_s, nz);

  rw_or  : entity work.g_or6 port map (c_mr_s, c_or_s, c_nor_s, c_sra_s, c_inc_s, c_pop_s, rw);
  sl_or  : entity work.g_or2 port map (ex, br_s, sl);

  alu0_or: entity work.g_or2 port map (c_or_s, c_sra_s, alu(0));
  alu1_or: entity work.g_or2 port map (c_nor_s, c_sra_s, alu(1));
  alu(2) <= c_inc_s;

  br  <= br_s;
  hlt <= c_hlt_s;
  mw  <= c_rm_s;
  mr  <= c_mr_s;
  psh <= c_psh_s;
  pop <= c_pop_s;
  ra  <= cmd(3 downto 0);
end architecture;
