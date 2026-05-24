library ieee;
use ieee.std_logic_1164.all;

entity ir_m is
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

architecture rtl of ir_m is
  signal r0 : std_logic_vector(15 downto 0) := (others => '0');
  signal r1 : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of r0 : signal is true;
  attribute keep of r1 : signal is true;
  attribute preserve of r0 : signal is true;
  attribute preserve of r1 : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r0 <= (others => '0');
        r1 <= (others => '0');
      else
        if l0 = '1' then r0 <= d0; end if;
        if l1 = '1' then r1 <= d1; end if;
      end if;
    end if;
  end process;

  cmd <= r0(15 downto 8);
  ra  <= r0(7 downto 4);
  adr <= r1;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec_m is
  port (
    cmd : in  std_logic_vector(7 downto 0);
    mr  : out std_logic;
    rm  : out std_logic
  );
end entity;

architecture rtl of dec_m is
begin
  mr <= '1' when cmd = x"01" else '0';
  rm <= '1' when cmd = x"02" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity rf_m is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    wa  : in  std_logic_vector(3 downto 0);
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of rf_m is
  signal r0 : std_logic_vector(15 downto 0) := x"0011";
  signal r1 : std_logic_vector(15 downto 0) := x"0022";
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of r0 : signal is true;
  attribute keep of r1 : signal is true;
  attribute preserve of r0 : signal is true;
  attribute preserve of r1 : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r0 <= (others => '0');
        r1 <= (others => '0');
      elsif we = '1' then
        if wa(0) = '0' then r0 <= d; else r1 <= d; end if;
      end if;
    end if;
  end process;

  q <= r0 when wa(0) = '0' else r1;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mem_m is
  port (
    ex  : in  std_logic;
    mr  : in  std_logic;
    rm  : in  std_logic;
    adr : in  std_logic_vector(15 downto 0);
    rd  : in  std_logic_vector(15 downto 0);
    rq  : out std_logic;
    we  : out std_logic;
    ma  : out std_logic_vector(15 downto 0);
    wd  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mem_m is
begin
  rq <= ex and (mr or rm);
  we <= ex and rm;
  ma <= adr;
  wd <= rd;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_mov_mr_rm_top is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    l0     : in  std_logic;
    l1     : in  std_logic;
    exec   : in  std_logic;
    ir0_i  : in  std_logic_vector(15 downto 0);
    ir1_i  : in  std_logic_vector(15 downto 0);
    mem_q  : in  std_logic_vector(15 downto 0);
    cmd_o  : out std_logic_vector(7 downto 0);
    reg_o  : out std_logic_vector(3 downto 0);
    adr_o  : out std_logic_vector(15 downto 0);
    mr_o   : out std_logic;
    rm_o   : out std_logic;
    mem_rq : out std_logic;
    mem_we : out std_logic;
    mem_a  : out std_logic_vector(15 downto 0);
    mem_d  : out std_logic_vector(15 downto 0);
    reg_q  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of section_2_mov_mr_rm_top is
  signal cmd_s : std_logic_vector(7 downto 0);
  signal reg_s : std_logic_vector(3 downto 0);
  signal adr_s : std_logic_vector(15 downto 0);
  signal mr_s  : std_logic;
  signal rm_s  : std_logic;
  signal rd_s  : std_logic_vector(15 downto 0);
  signal rfwe_s: std_logic;
begin
  u_ir : entity work.ir_m
    port map (clk => clk, rst => rst, l0 => l0, l1 => l1, d0 => ir0_i, d1 => ir1_i, cmd => cmd_s, ra => reg_s, adr => adr_s);

  u_dec : entity work.dec_m
    port map (cmd => cmd_s, mr => mr_s, rm => rm_s);

  rfwe_s <= exec and mr_s;

  u_rf : entity work.rf_m
    port map (clk => clk, rst => rst, we => rfwe_s, wa => reg_s, d => mem_q, q => rd_s);

  u_mem : entity work.mem_m
    port map (ex => exec, mr => mr_s, rm => rm_s, adr => adr_s, rd => rd_s, rq => mem_rq, we => mem_we, ma => mem_a, wd => mem_d);

  cmd_o <= cmd_s;
  reg_o <= reg_s;
  adr_o <= adr_s;
  mr_o  <= mr_s;
  rm_o  <= rm_s;
  reg_q <= rd_s;
end architecture;
