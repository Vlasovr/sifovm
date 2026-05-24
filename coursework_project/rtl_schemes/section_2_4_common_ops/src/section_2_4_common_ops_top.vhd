library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pc_unit is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    d   : in  std_logic_vector(15 downto 0);
    q   : out std_logic_vector(15 downto 0);
    p2  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of pc_unit is
  signal pc_r : std_logic_vector(15 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of pc_r : signal is true;
  attribute keep of pc_r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        pc_r <= (others => '0');
      elsif we = '1' then
        pc_r <= d;
      end if;
    end if;
  end process;

  q  <= pc_r;
  p2 <= std_logic_vector(unsigned(pc_r) + 2);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity rom_fetch is
  port (
    pc  : in  std_logic_vector(15 downto 0);
    ph  : in  std_logic_vector(4 downto 0);
    ra  : out std_logic_vector(15 downto 0);
    re  : out std_logic
  );
end entity;

architecture rtl of rom_fetch is
begin
  ra <= pc when ph(2) = '0' else std_logic_vector(unsigned(pc) + 1);
  re <= '1' when ph(4 downto 1) = "0000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity ir_pair is
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

architecture rtl of ir_pair is
  signal ir0_r : std_logic_vector(15 downto 0) := (others => '0');
  signal ir1_r : std_logic_vector(15 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of ir0_r : signal is true;
  attribute preserve of ir1_r : signal is true;
  attribute keep of ir0_r : signal is true;
  attribute keep of ir1_r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        ir0_r <= (others => '0');
        ir1_r <= (others => '0');
      else
        if l0 = '1' then
          ir0_r <= d;
        end if;
        if l1 = '1' then
          ir1_r <= d;
        end if;
      end if;
    end if;
  end process;

  i0 <= ir0_r;
  i1 <= ir1_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity op_decode is
  port (
    ir0 : in  std_logic_vector(15 downto 0);
    cmd : out std_logic_vector(7 downto 0);
    rg  : out std_logic_vector(3 downto 0);
    mr  : out std_logic;
    rm  : out std_logic;
    alu : out std_logic;
    ps  : out std_logic;
    pp  : out std_logic;
    br  : out std_logic;
    jz  : out std_logic;
    ht  : out std_logic
  );
end entity;

architecture rtl of op_decode is
  constant OP_HLT    : std_logic_vector(7 downto 0) := x"00";
  constant OP_MOV_MR : std_logic_vector(7 downto 0) := x"01";
  constant OP_MOV_RM : std_logic_vector(7 downto 0) := x"02";
  constant OP_OR     : std_logic_vector(7 downto 0) := x"03";
  constant OP_NOR    : std_logic_vector(7 downto 0) := x"04";
  constant OP_SRA    : std_logic_vector(7 downto 0) := x"05";
  constant OP_INCS   : std_logic_vector(7 downto 0) := x"06";
  constant OP_PUSH   : std_logic_vector(7 downto 0) := x"07";
  constant OP_POP    : std_logic_vector(7 downto 0) := x"08";
  constant OP_JMP    : std_logic_vector(7 downto 0) := x"09";
  constant OP_JZ     : std_logic_vector(7 downto 0) := x"0A";

  signal c : std_logic_vector(7 downto 0);
begin
  c   <= ir0(15 downto 8);
  cmd <= c;
  rg  <= ir0(7 downto 4);
  mr  <= '1' when c = OP_MOV_MR else '0';
  rm  <= '1' when c = OP_MOV_RM else '0';
  alu <= '1' when c = OP_OR or c = OP_NOR or c = OP_SRA or c = OP_INCS else '0';
  ps  <= '1' when c = OP_PUSH else '0';
  pp  <= '1' when c = OP_POP else '0';
  br  <= '1' when c = OP_JMP or c = OP_JZ else '0';
  jz  <= '1' when c = OP_JZ else '0';
  ht  <= '1' when c = OP_HLT else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity state_ctl is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    ready : in  std_logic;
    mr    : in  std_logic;
    rm    : in  std_logic;
    alu   : in  std_logic;
    ps    : in  std_logic;
    pp    : in  std_logic;
    br    : in  std_logic;
    ht    : in  std_logic;
    ph    : out std_logic_vector(4 downto 0);
    l0    : out std_logic;
    l1    : out std_logic;
    pcwe  : out std_logic;
    rfwe  : out std_logic;
    mrd   : out std_logic;
    mwr   : out std_logic;
    ago   : out std_logic;
    push  : out std_logic;
    pop   : out std_logic;
    bgo   : out std_logic;
    hgo   : out std_logic
  );
end entity;

architecture rtl of state_ctl is
  signal s_r : unsigned(4 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of s_r : signal is true;
  attribute keep of s_r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        s_r <= "00000";
      else
        case s_r is
          when "00000" => s_r <= "00001";
          when "00001" => s_r <= "00010";
          when "00010" => s_r <= "00011";
          when "00011" => s_r <= "00100";
          when "00100" => s_r <= "00101";
          when "00101" => s_r <= "00110";
          when "00110" => s_r <= "00111";
          when "00111" =>
            if ht = '1' then
              s_r <= "11111";
            elsif mr = '1' or rm = '1' then
              s_r <= "01000";
            elsif alu = '1' then
              s_r <= "01010";
            elsif ps = '1' then
              s_r <= "01101";
            elsif pp = '1' then
              s_r <= "01110";
            elsif br = '1' then
              s_r <= "10000";
            else
              s_r <= "11111";
            end if;
          when "01000" =>
            if ready = '1' then
              if mr = '1' then
                s_r <= "01100";
              else
                s_r <= "10010";
              end if;
            end if;
          when "01010" => s_r <= "01011";
          when "01011" => s_r <= "10010";
          when "01100" => s_r <= "10010";
          when "01101" => s_r <= "10010";
          when "01110" => s_r <= "01111";
          when "01111" => s_r <= "10010";
          when "10000" => s_r <= "00001";
          when "10010" => s_r <= "00001";
          when others  => s_r <= "11111";
        end case;
      end if;
    end if;
  end process;

  ph   <= std_logic_vector(s_r);
  l0   <= '1' when s_r = "00011" else '0';
  l1   <= '1' when s_r = "00110" else '0';
  pcwe <= '1' when s_r = "10000" or s_r = "10010" else '0';
  rfwe <= '1' when s_r = "01011" or s_r = "01100" or s_r = "01111" else '0';
  mrd  <= '1' when s_r = "01000" and mr = '1' else '0';
  mwr  <= '1' when s_r = "01000" and rm = '1' else '0';
  ago  <= '1' when s_r = "01011" else '0';
  push <= '1' when s_r = "01101" else '0';
  pop  <= '1' when s_r = "01110" else '0';
  bgo  <= '1' when s_r = "10000" else '0';
  hgo  <= '1' when s_r = "11111" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity cache_path is
  port (
    rd  : in  std_logic;
    wr  : in  std_logic;
    a   : in  std_logic_vector(15 downto 0);
    wd  : in  std_logic_vector(15 downto 0);
    q   : in  std_logic_vector(15 downto 0);
    req : out std_logic;
    we  : out std_logic;
    ca  : out std_logic_vector(15 downto 0);
    cw  : out std_logic_vector(15 downto 0);
    cr  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of cache_path is
begin
  req <= rd or wr;
  we  <= wr;
  ca  <= a;
  cw  <= wd;
  cr  <= q;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity rf_port is
  port (
    clk : in  std_logic;
    we  : in  std_logic;
    wa  : in  std_logic_vector(3 downto 0);
    di  : in  std_logic_vector(15 downto 0);
    a   : out std_logic_vector(15 downto 0);
    b   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of rf_port is
  signal r1 : std_logic_vector(15 downto 0) := x"0001";
  signal r2 : std_logic_vector(15 downto 0) := x"0002";
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of r1 : signal is true;
  attribute preserve of r2 : signal is true;
  attribute keep of r1 : signal is true;
  attribute keep of r2 : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if we = '1' then
        if wa(0) = '0' then
          r1 <= di;
        else
          r2 <= di;
        end if;
      end if;
    end if;
  end process;

  a <= r1;
  b <= r2;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_exec is
  port (
    cmd : in  std_logic_vector(7 downto 0);
    a   : in  std_logic_vector(15 downto 0);
    b   : in  std_logic_vector(15 downto 0);
    fs  : in  std_logic;
    y   : out std_logic_vector(15 downto 0);
    fl  : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of alu_exec is
  constant OP_OR   : std_logic_vector(7 downto 0) := x"03";
  constant OP_NOR  : std_logic_vector(7 downto 0) := x"04";
  constant OP_SRA  : std_logic_vector(7 downto 0) := x"05";
  constant OP_INCS : std_logic_vector(7 downto 0) := x"06";
  signal y_s : std_logic_vector(15 downto 0);
begin
  with cmd select y_s <=
    a or b                                      when OP_OR,
    not (a or b)                                when OP_NOR,
    fs & a(15 downto 1)                         when OP_SRA,
    std_logic_vector(unsigned(a) + 1)            when OP_INCS,
    a                                           when others;

  y     <= y_s;
  fl(3) <= '1' when y_s = x"0000" else '0';
  fl(2) <= y_s(15);
  fl(1) <= '1' when cmd = OP_SRA and a(0) = '1' else '0';
  fl(0) <= '1' when cmd = OP_INCS and a = x"7FFF" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity flags_hold is
  port (
    clk : in  std_logic;
    rst : in  std_logic;
    we  : in  std_logic;
    d   : in  std_logic_vector(3 downto 0);
    q   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of flags_hold is
  signal f_r : std_logic_vector(3 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of f_r : signal is true;
  attribute keep of f_r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        f_r <= (others => '0');
      elsif we = '1' then
        f_r <= d;
      end if;
    end if;
  end process;

  q <= f_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity stack_exec is
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    push : in  std_logic;
    pop  : in  std_logic;
    d    : in  std_logic_vector(15 downto 0);
    q    : out std_logic_vector(15 downto 0);
    sp   : out std_logic_vector(2 downto 0);
    emp  : out std_logic;
    ful  : out std_logic
  );
end entity;

architecture rtl of stack_exec is
  type mem_t is array (0 to 6) of std_logic_vector(15 downto 0);
  signal mem_r : mem_t := (others => (others => '0'));
  signal sp_r  : unsigned(2 downto 0) := "111";
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of mem_r : signal is true;
  attribute preserve of sp_r : signal is true;
  attribute keep of mem_r : signal is true;
  attribute keep of sp_r : signal is true;
begin
  process(clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        sp_r <= "111";
      elsif push = '1' and sp_r /= "000" then
        sp_r <= sp_r - 1;
        mem_r(to_integer(sp_r - 1)) <= d;
      elsif pop = '1' and sp_r /= "111" then
        sp_r <= sp_r + 1;
      end if;
    end if;
  end process;

  q   <= mem_r(to_integer(sp_r)) when sp_r < 7 else (others => '0');
  sp  <= std_logic_vector(sp_r);
  emp <= '1' when sp_r = "111" else '0';
  ful <= '1' when sp_r = "000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity branch_pc is
  port (
    go  : in  std_logic;
    jz  : in  std_logic;
    z   : in  std_logic;
    p2  : in  std_logic_vector(15 downto 0);
    ja  : in  std_logic_vector(15 downto 0);
    nd  : out std_logic_vector(15 downto 0);
    bpu : out std_logic
  );
end entity;

architecture rtl of branch_pc is
begin
  nd  <= ja when go = '1' and (jz = '0' or z = '1') else p2;
  bpu <= go and jz;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity halt_ctl is
  port (
    hgo : in  std_logic;
    hlt : out std_logic
  );
end entity;

architecture rtl of halt_ctl is
begin
  hlt <= hgo;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity section_2_4_common_ops_top is
  port (
    clk          : in  std_logic;
    rst          : in  std_logic;
    rom_data     : in  std_logic_vector(15 downto 0);
    cache_rdata  : in  std_logic_vector(15 downto 0);
    cache_ready  : in  std_logic;
    cache_hit    : in  std_logic;
    cache_miss   : in  std_logic;
    bp_pred      : in  std_logic;
    bp_target    : in  std_logic_vector(15 downto 0);

    rom_addr     : out std_logic_vector(15 downto 0);
    rom_en       : out std_logic;
    cache_req    : out std_logic;
    cache_we     : out std_logic;
    cache_addr   : out std_logic_vector(15 downto 0);
    cache_wdata  : out std_logic_vector(15 downto 0);
    bp_query     : out std_logic;
    bp_update    : out std_logic;
    halt         : out std_logic;
    dbg_state    : out std_logic_vector(4 downto 0);
    dbg_pc       : out std_logic_vector(15 downto 0);
    dbg_ir0      : out std_logic_vector(15 downto 0);
    dbg_ir1      : out std_logic_vector(15 downto 0);
    dbg_flags    : out std_logic_vector(3 downto 0);
    dbg_sp       : out std_logic_vector(2 downto 0);
    dbg_result   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of section_2_4_common_ops_top is
  signal pc_s, pc2_s, pcn_s : std_logic_vector(15 downto 0);
  signal ir0_s, ir1_s       : std_logic_vector(15 downto 0);
  signal cmd_s              : std_logic_vector(7 downto 0);
  signal reg_s              : std_logic_vector(3 downto 0);
  signal ph_s               : std_logic_vector(4 downto 0);
  signal fl_s, fln_s        : std_logic_vector(3 downto 0);
  signal rfa_s, rfb_s       : std_logic_vector(15 downto 0);
  signal alu_s              : std_logic_vector(15 downto 0);
  signal stack_s            : std_logic_vector(15 downto 0);
  signal cache_s            : std_logic_vector(15 downto 0);
  signal wr_s               : std_logic_vector(15 downto 0);
  signal mr_s, rm_s, al_s   : std_logic;
  signal ps_s, pp_s, br_s   : std_logic;
  signal jz_s, ht_s         : std_logic;
  signal l0_s, l1_s, pcwe_s : std_logic;
  signal rfwe_s, mrd_s      : std_logic;
  signal mwr_s, ago_s       : std_logic;
  signal push_s, pop_s      : std_logic;
  signal bgo_s, hgo_s       : std_logic;
  signal st_emp_s, st_ful_s : std_logic;

  attribute keep : boolean;
  attribute keep of pc_s      : signal is true;
  attribute keep of ir0_s     : signal is true;
  attribute keep of ir1_s     : signal is true;
  attribute keep of cmd_s     : signal is true;
  attribute keep of ph_s      : signal is true;
  attribute keep of rfa_s     : signal is true;
  attribute keep of alu_s     : signal is true;
  attribute keep of stack_s   : signal is true;
  attribute keep of cache_s   : signal is true;
  attribute keep of fl_s      : signal is true;
begin
  u_pc : entity work.pc_unit
    port map (clk => clk, rst => rst, we => pcwe_s, d => pcn_s, q => pc_s, p2 => pc2_s);

  u_rom_fetch : entity work.rom_fetch
    port map (pc => pc_s, ph => ph_s, ra => rom_addr, re => rom_en);

  u_ir_pair : entity work.ir_pair
    port map (clk => clk, rst => rst, l0 => l0_s, l1 => l1_s, d => rom_data, i0 => ir0_s, i1 => ir1_s);

  u_decode : entity work.op_decode
    port map (ir0 => ir0_s, cmd => cmd_s, rg => reg_s, mr => mr_s, rm => rm_s,
              alu => al_s, ps => ps_s, pp => pp_s, br => br_s, jz => jz_s, ht => ht_s);

  u_state_ctl : entity work.state_ctl
    port map (clk => clk, rst => rst, ready => cache_ready, mr => mr_s, rm => rm_s,
              alu => al_s, ps => ps_s, pp => pp_s, br => br_s, ht => ht_s,
              ph => ph_s, l0 => l0_s, l1 => l1_s, pcwe => pcwe_s, rfwe => rfwe_s,
              mrd => mrd_s, mwr => mwr_s, ago => ago_s, push => push_s, pop => pop_s,
              bgo => bgo_s, hgo => hgo_s);

  u_rf : entity work.rf_port
    port map (clk => clk, we => rfwe_s, wa => reg_s, di => wr_s, a => rfa_s, b => rfb_s);

  u_cache_path : entity work.cache_path
    port map (rd => mrd_s, wr => mwr_s, a => ir1_s, wd => rfa_s, q => cache_rdata,
              req => cache_req, we => cache_we, ca => cache_addr, cw => cache_wdata, cr => cache_s);

  u_alu : entity work.alu_exec
    port map (cmd => cmd_s, a => rfa_s, b => cache_s, fs => fl_s(2), y => alu_s, fl => fln_s);

  u_flags : entity work.flags_hold
    port map (clk => clk, rst => rst, we => ago_s, d => fln_s, q => fl_s);

  u_stack : entity work.stack_exec
    port map (clk => clk, rst => rst, push => push_s, pop => pop_s, d => rfa_s,
              q => stack_s, sp => dbg_sp, emp => st_emp_s, ful => st_ful_s);

  u_branch : entity work.branch_pc
    port map (go => bgo_s, jz => jz_s, z => fl_s(3), p2 => pc2_s, ja => ir1_s,
              nd => pcn_s, bpu => bp_update);

  u_halt : entity work.halt_ctl
    port map (hgo => hgo_s, hlt => halt);

  wr_s       <= alu_s when ago_s = '1' else cache_s when mrd_s = '1' else stack_s;
  bp_query   <= cache_hit xor cache_miss xor bp_pred xor bp_target(0);
  dbg_state  <= ph_s;
  dbg_pc     <= pc_s;
  dbg_ir0    <= ir0_s;
  dbg_ir1    <= ir1_s;
  dbg_flags  <= fl_s;
  dbg_result <= wr_s;
end architecture;
