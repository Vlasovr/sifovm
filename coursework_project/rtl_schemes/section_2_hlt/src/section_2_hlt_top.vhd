library ieee;
use ieee.std_logic_1164.all;

entity ir_h is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    ld  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    cmd : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of ir_h is
  signal r : std_logic_vector(15 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of r : signal is true;
  attribute preserve of r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r <= (others => '0');
      elsif ld = '1' then
        r <= d;
      end if;
    end if;
  end process;

  cmd <= r(15 downto 8);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec_h is
  port (
    cmd : in  std_logic_vector(7 downto 0);
    h   : out std_logic
  );
end entity;

architecture rtl of dec_h is
begin
  h <= '1' when cmd = x"00" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity run_h is
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    exec : in  std_logic;
    hcmd : in  std_logic;
    run  : out std_logic;
    halt : out std_logic
  );
end entity;

architecture rtl of run_h is
  signal r : std_logic := '1';
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of r : signal is true;
  attribute preserve of r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        r <= '1';
      elsif exec = '1' and hcmd = '1' then
        r <= '0';
      end if;
    end if;
  end process;

  run  <= r;
  halt <= not r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity gate_h is
  port (
    run    : in  std_logic;
    hcmd   : in  std_logic;
    exec   : in  std_logic;
    pc_we  : out std_logic;
    rom_en : out std_logic;
    rf_we  : out std_logic;
    mem_en : out std_logic
  );
end entity;

architecture rtl of gate_h is
begin
  pc_we  <= exec and run and not hcmd;
  rom_en <= run;
  rf_we  <= run and not hcmd;
  mem_en <= run and not hcmd;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_hlt_top is
  port (
    clk    : in  std_logic;
    rst    : in  std_logic;
    ld     : in  std_logic;
    exec   : in  std_logic;
    ir_i   : in  std_logic_vector(15 downto 0);
    cmd_o  : out std_logic_vector(7 downto 0);
    hcmd_o : out std_logic;
    run_o  : out std_logic;
    halt_o : out std_logic;
    pc_we  : out std_logic;
    rom_en : out std_logic;
    rf_we  : out std_logic;
    mem_en : out std_logic
  );
end entity;

architecture structural of section_2_hlt_top is
  signal cmd_s  : std_logic_vector(7 downto 0);
  signal hcmd_s : std_logic;
  signal run_s  : std_logic;
  signal halt_s : std_logic;
begin
  u_ir : entity work.ir_h
    port map (clk => clk, rst => rst, ld => ld, d => ir_i, cmd => cmd_s);

  u_dec : entity work.dec_h
    port map (cmd => cmd_s, h => hcmd_s);

  u_run : entity work.run_h
    port map (clk => clk, rst => rst, exec => exec, hcmd => hcmd_s, run => run_s, halt => halt_s);

  u_gate : entity work.gate_h
    port map (run => run_s, hcmd => hcmd_s, exec => exec, pc_we => pc_we, rom_en => rom_en, rf_we => rf_we, mem_en => mem_en);

  cmd_o  <= cmd_s;
  hcmd_o <= hcmd_s;
  run_o  <= run_s;
  halt_o <= halt_s;
end architecture;
