library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ph_f is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    run : in  std_logic;
    ph  : out std_logic_vector(1 downto 0);
    l0  : out std_logic;
    l1  : out std_logic;
    dec : out std_logic;
    pcw : out std_logic
  );
end entity;

architecture rtl of ph_f is
  signal q : unsigned(1 downto 0) := (others => '0');
  attribute keep : boolean;
  attribute preserve : boolean;
  attribute keep of q : signal is true;
  attribute preserve of q : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        q <= (others => '0');
      elsif run = '1' then
        q <= q + 1;
      end if;
    end if;
  end process;

  ph  <= std_logic_vector(q);
  l0  <= '1' when q = "01" else '0';
  l1  <= '1' when q = "10" else '0';
  dec <= '1' when q = "11" else '0';
  pcw <= '1' when q = "11" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_f is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    pc  : out std_logic_vector(15 downto 0);
    pc1 : out std_logic_vector(15 downto 0);
    pc2 : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of pc_f is
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
      elsif we = '1' then
        r <= std_logic_vector(unsigned(r) + 2);
      end if;
    end if;
  end process;

  pc  <= r;
  pc1 <= std_logic_vector(unsigned(r) + 1);
  pc2 <= std_logic_vector(unsigned(r) + 2);
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity rom_f is
  port (
    ph  : in  std_logic_vector(1 downto 0);
    pc  : in  std_logic_vector(15 downto 0);
    pc1 : in  std_logic_vector(15 downto 0);
    ra  : out std_logic_vector(15 downto 0);
    re  : out std_logic
  );
end entity;

architecture rtl of rom_f is
begin
  ra <= pc1 when ph = "01" or ph = "10" else pc;
  re <= '1' when ph = "00" or ph = "01" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ir_f is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    l0  : in  std_logic;
    l1  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    i0  : out std_logic_vector(15 downto 0);
    i1  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of ir_f is
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
        if l0 = '1' then
          r0 <= d;
        end if;
        if l1 = '1' then
          r1 <= d;
        end if;
      end if;
    end if;
  end process;

  i0 <= r0;
  i1 <= r1;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity dec_f is
  port (
    i0  : in  std_logic_vector(15 downto 0);
    i1  : in  std_logic_vector(15 downto 0);
    cmd : out std_logic_vector(7 downto 0);
    rg  : out std_logic_vector(3 downto 0);
    adr : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of dec_f is
begin
  cmd <= i0(15 downto 8);
  rg  <= i0(7 downto 4);
  adr <= i1;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_fetch_decode_top is
  port (
    clk      : in  std_logic;
    rst      : in  std_logic;
    run      : in  std_logic;
    rom_data : in  std_logic_vector(15 downto 0);
    rom_addr : out std_logic_vector(15 downto 0);
    rom_en   : out std_logic;
    pc_o     : out std_logic_vector(15 downto 0);
    pc2_o    : out std_logic_vector(15 downto 0);
    ir0_o    : out std_logic_vector(15 downto 0);
    ir1_o    : out std_logic_vector(15 downto 0);
    cmd_o    : out std_logic_vector(7 downto 0);
    reg_o    : out std_logic_vector(3 downto 0);
    adr_o    : out std_logic_vector(15 downto 0);
    ph_o     : out std_logic_vector(1 downto 0);
    dec_o    : out std_logic
  );
end entity;

architecture structural of section_2_fetch_decode_top is
  signal ph_s       : std_logic_vector(1 downto 0);
  signal l0_s,l1_s  : std_logic;
  signal pcw_s      : std_logic;
  signal pc_s       : std_logic_vector(15 downto 0);
  signal pc1_s      : std_logic_vector(15 downto 0);
  signal pc2_s      : std_logic_vector(15 downto 0);
  signal ir0_s      : std_logic_vector(15 downto 0);
  signal ir1_s      : std_logic_vector(15 downto 0);
begin
  u_ph : entity work.ph_f
    port map (clk => clk, rst => rst, run => run, ph => ph_s, l0 => l0_s, l1 => l1_s, dec => dec_o, pcw => pcw_s);

  u_pc : entity work.pc_f
    port map (clk => clk, rst => rst, we => pcw_s, pc => pc_s, pc1 => pc1_s, pc2 => pc2_s);

  u_rom : entity work.rom_f
    port map (ph => ph_s, pc => pc_s, pc1 => pc1_s, ra => rom_addr, re => rom_en);

  u_ir : entity work.ir_f
    port map (clk => clk, rst => rst, l0 => l0_s, l1 => l1_s, d => rom_data, i0 => ir0_s, i1 => ir1_s);

  u_dec : entity work.dec_f
    port map (i0 => ir0_s, i1 => ir1_s, cmd => cmd_o, rg => reg_o, adr => adr_o);

  pc_o  <= pc_s;
  pc2_o <= pc2_s;
  ir0_o <= ir0_s;
  ir1_o <= ir1_s;
  ph_o  <= ph_s;
end architecture;
