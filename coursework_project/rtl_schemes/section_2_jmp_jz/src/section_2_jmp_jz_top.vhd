library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ir_pair_j is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    l0  : in  std_logic;
    l1  : in  std_logic;
    d0  : in  std_logic_vector(15 downto 0);
    d1  : in  std_logic_vector(15 downto 0);
    cmd : out std_logic_vector(7 downto 0);
    ra  : out std_logic_vector(3 downto 0);
    adr : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of ir_pair_j is
  signal ir0 : std_logic_vector(15 downto 0) := (others => '0');
  signal ir1 : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of ir0 : signal is true;
  attribute keep of ir1 : signal is true;
  attribute preserve of ir0 : signal is true;
  attribute preserve of ir1 : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ir0 <= (others => '0');
        ir1 <= (others => '0');
      else
        if l0 = '1' then
          ir0 <= d0;
        end if;
        if l1 = '1' then
          ir1 <= d1;
        end if;
      end if;
    end if;
  end process;

  cmd <= ir0(15 downto 8);
  ra  <= ir0(7 downto 4);
  adr <= ir1;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec_j is
  port (
    cmd : in  std_logic_vector(7 downto 0);
    jmp : out std_logic;
    jz  : out std_logic;
    br  : out std_logic
  );
end entity;

architecture rtl of dec_j is
  constant OP_JMP : std_logic_vector(7 downto 0) := x"09";
  constant OP_JZ  : std_logic_vector(7 downto 0) := x"0A";
begin
  jmp <= '1' when cmd = OP_JMP else '0';
  jz  <= '1' when cmd = OP_JZ else '0';
  br  <= '1' when cmd = OP_JMP or cmd = OP_JZ else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity z_reg is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    d   : in  std_logic;
    q   : out std_logic
  );
end entity;

architecture rtl of z_reg is
  signal z : std_logic := '0';
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of z : signal is true;
  attribute preserve of z : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        z <= '0';
      elsif we = '1' then
        z <= d;
      end if;
    end if;
  end process;

  q <= z;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity take_j is
  port (
    jmp  : in  std_logic;
    jz   : in  std_logic;
    z    : in  std_logic;
    take : out std_logic
  );
end entity;

architecture rtl of take_j is
begin
  take <= jmp or (jz and z);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_add2 is
  port (
    pc  : in  std_logic_vector(15 downto 0);
    pc2 : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of pc_add2 is
begin
  pc2 <= std_logic_vector(unsigned(pc) + 2);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity pc_mux_j is
  port (
    take : in  std_logic;
    seq  : in  std_logic_vector(15 downto 0);
    adr  : in  std_logic_vector(15 downto 0);
    y    : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of pc_mux_j is
begin
  y <= adr when take = '1' else seq;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity pc_reg_j is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of pc_reg_j is
  signal pc : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of pc : signal is true;
  attribute preserve of pc : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pc <= (others => '0');
      elsif we = '1' then
        pc <= d;
      end if;
    end if;
  end process;

  q <= pc;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bp_j is
  port (
    br   : in  std_logic;
    jz   : in  std_logic;
    take : in  std_logic;
    pc   : in  std_logic_vector(15 downto 0);
    adr  : in  std_logic_vector(15 downto 0);
    qry  : out std_logic;
    upd  : out std_logic;
    bt   : out std_logic;
    bpc  : out std_logic_vector(15 downto 0);
    bad  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of bp_j is
begin
  qry <= br;
  upd <= jz;
  bt  <= take;
  bpc <= pc;
  bad <= adr;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_jmp_jz_top is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    l0     : in  std_logic;
    l1     : in  std_logic;
    exec   : in  std_logic;
    f_we   : in  std_logic;
    f_z    : in  std_logic;
    ir0_i  : in  std_logic_vector(15 downto 0);
    ir1_i  : in  std_logic_vector(15 downto 0);

    pc_o   : out std_logic_vector(15 downto 0);
    next_o : out std_logic_vector(15 downto 0);
    adr_o  : out std_logic_vector(15 downto 0);
    cmd_o  : out std_logic_vector(7 downto 0);
    reg_o  : out std_logic_vector(3 downto 0);
    z_o    : out std_logic;
    jmp_o  : out std_logic;
    jz_o   : out std_logic;
    take_o : out std_logic;
    bp_q   : out std_logic;
    bp_u   : out std_logic;
    bp_t   : out std_logic;
    bp_pc  : out std_logic_vector(15 downto 0);
    bp_adr : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of section_2_jmp_jz_top is
  signal cmd_s  : std_logic_vector(7 downto 0);
  signal reg_s  : std_logic_vector(3 downto 0);
  signal adr_s  : std_logic_vector(15 downto 0);
  signal pc_s   : std_logic_vector(15 downto 0);
  signal seq_s  : std_logic_vector(15 downto 0);
  signal nxt_s  : std_logic_vector(15 downto 0);
  signal z_s    : std_logic;
  signal jmp_s  : std_logic;
  signal jz_s   : std_logic;
  signal br_s   : std_logic;
  signal take_s : std_logic;

  attribute keep : boolean;
  attribute keep of cmd_s  : signal is true;
  attribute keep of adr_s  : signal is true;
  attribute keep of pc_s   : signal is true;
  attribute keep of seq_s  : signal is true;
  attribute keep of nxt_s  : signal is true;
  attribute keep of z_s    : signal is true;
  attribute keep of take_s : signal is true;
begin
  u_ir : entity work.ir_pair_j
    port map (
      clk => clk,
      rst => rst,
      l0  => l0,
      l1  => l1,
      d0  => ir0_i,
      d1  => ir1_i,
      cmd => cmd_s,
      ra  => reg_s,
      adr => adr_s
    );

  u_dec : entity work.dec_j
    port map (
      cmd => cmd_s,
      jmp => jmp_s,
      jz  => jz_s,
      br  => br_s
    );

  u_z : entity work.z_reg
    port map (
      clk => clk,
      rst => rst,
      we  => f_we,
      d   => f_z,
      q   => z_s
    );

  u_take : entity work.take_j
    port map (
      jmp  => jmp_s,
      jz   => jz_s,
      z    => z_s,
      take => take_s
    );

  u_add : entity work.pc_add2
    port map (
      pc  => pc_s,
      pc2 => seq_s
    );

  u_mux : entity work.pc_mux_j
    port map (
      take => take_s,
      seq  => seq_s,
      adr  => adr_s,
      y    => nxt_s
    );

  u_pc : entity work.pc_reg_j
    port map (
      clk => clk,
      rst => rst,
      we  => exec,
      d   => nxt_s,
      q   => pc_s
    );

  u_bp : entity work.bp_j
    port map (
      br   => br_s,
      jz   => jz_s,
      take => take_s,
      pc   => pc_s,
      adr  => adr_s,
      qry  => bp_q,
      upd  => bp_u,
      bt   => bp_t,
      bpc  => bp_pc,
      bad  => bp_adr
    );

  pc_o   <= pc_s;
  next_o <= nxt_s;
  adr_o  <= adr_s;
  cmd_o  <= cmd_s;
  reg_o  <= reg_s;
  z_o    <= z_s;
  jmp_o  <= jmp_s;
  jz_o   <= jz_s;
  take_o <= take_s;
end architecture;
