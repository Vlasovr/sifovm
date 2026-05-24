-- Appendix-oriented structural views for Quartus RTL Viewer.
-- These entities are documentation tops. They are intentionally split into
-- many small named blocks so RTL Viewer draws readable schemes for screenshots.

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_reg16 is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    en_i  : in  std_logic;
    d_i   : in  word_t;
    q_o   : out word_t
  );
end entity;

architecture rtl of rtl_doc_reg16 is
  signal q_r : word_t := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of q_r : signal is true;
  attribute keep     of q_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r <= (others => '0');
      elsif en_i = '1' then
        q_r <= d_i;
      end if;
    end if;
  end process;
  q_o <= q_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_reg12 is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    en_i  : in  std_logic;
    d_i   : in  std_logic_vector(11 downto 0);
    q_o   : out std_logic_vector(11 downto 0)
  );
end entity;

architecture rtl of rtl_doc_reg12 is
  signal q_r : std_logic_vector(11 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of q_r : signal is true;
  attribute keep     of q_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r <= (others => '0');
      elsif en_i = '1' then
        q_r <= d_i;
      end if;
    end if;
  end process;
  q_o <= q_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_reg8 is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    en_i  : in  std_logic;
    d_i   : in  std_logic_vector(7 downto 0);
    q_o   : out std_logic_vector(7 downto 0)
  );
end entity;

architecture rtl of rtl_doc_reg8 is
  signal q_r : std_logic_vector(7 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of q_r : signal is true;
  attribute keep     of q_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r <= (others => '0');
      elsif en_i = '1' then
        q_r <= d_i;
      end if;
    end if;
  end process;
  q_o <= q_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_reg4 is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    en_i  : in  std_logic;
    d_i   : in  std_logic_vector(3 downto 0);
    q_o   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of rtl_doc_reg4 is
  signal q_r : std_logic_vector(3 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of q_r : signal is true;
  attribute keep     of q_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r <= (others => '0');
      elsif en_i = '1' then
        q_r <= d_i;
      end if;
    end if;
  end process;
  q_o <= q_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_reg3 is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    en_i  : in  std_logic;
    d_i   : in  std_logic_vector(2 downto 0);
    q_o   : out std_logic_vector(2 downto 0)
  );
end entity;

architecture rtl of rtl_doc_reg3 is
  signal q_r : std_logic_vector(2 downto 0) := "111";
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of q_r : signal is true;
  attribute keep     of q_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r <= "111";
      elsif en_i = '1' then
        q_r <= d_i;
      end if;
    end if;
  end process;
  q_o <= q_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_reg2 is
  port (
    clk_i : in  std_logic;
    rst_i : in  std_logic;
    en_i  : in  std_logic;
    d_i   : in  std_logic_vector(1 downto 0);
    q_o   : out std_logic_vector(1 downto 0)
  );
end entity;

architecture rtl of rtl_doc_reg2 is
  signal q_r : std_logic_vector(1 downto 0) := (others => '0');
  attribute preserve : boolean;
  attribute keep     : boolean;
  attribute preserve of q_r : signal is true;
  attribute keep     of q_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        q_r <= (others => '0');
      elsif en_i = '1' then
        q_r <= d_i;
      end if;
    end if;
  end process;
  q_o <= q_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_decode12 is
  port (
    addr_i   : in  std_logic_vector(3 downto 0);
    enable_i : in  std_logic;
    onehot_o : out std_logic_vector(11 downto 0)
  );
end entity;

architecture rtl of rtl_doc_decode12 is
begin
  process(addr_i, enable_i)
    variable t : std_logic_vector(11 downto 0);
  begin
    t := (others => '0');
    if enable_i = '1' then
      case addr_i is
        when x"0" => t(0)  := '1';
        when x"1" => t(1)  := '1';
        when x"2" => t(2)  := '1';
        when x"3" => t(3)  := '1';
        when x"4" => t(4)  := '1';
        when x"5" => t(5)  := '1';
        when x"6" => t(6)  := '1';
        when x"7" => t(7)  := '1';
        when x"8" => t(8)  := '1';
        when x"9" => t(9)  := '1';
        when x"A" => t(10) := '1';
        when x"B" => t(11) := '1';
        when others => null;
      end case;
    end if;
    onehot_o <= t;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_decode7 is
  port (
    addr_i   : in  std_logic_vector(2 downto 0);
    enable_i : in  std_logic;
    onehot_o : out std_logic_vector(6 downto 0)
  );
end entity;

architecture rtl of rtl_doc_decode7 is
begin
  process(addr_i, enable_i)
    variable t : std_logic_vector(6 downto 0);
  begin
    t := (others => '0');
    if enable_i = '1' then
      case addr_i is
        when "000" => t(0) := '1';
        when "001" => t(1) := '1';
        when "010" => t(2) := '1';
        when "011" => t(3) := '1';
        when "100" => t(4) := '1';
        when "101" => t(5) := '1';
        when others => t(6) := '1';
      end case;
    end if;
    onehot_o <= t;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_opcode_decode11 is
  port (
    opcode_i : in  std_logic_vector(7 downto 0);
    op_o     : out std_logic_vector(10 downto 0)
  );
end entity;

architecture rtl of rtl_doc_opcode_decode11 is
begin
  op_o(0)  <= '1' when opcode_i = OP_HLT    else '0';
  op_o(1)  <= '1' when opcode_i = OP_MOV_MR else '0';
  op_o(2)  <= '1' when opcode_i = OP_MOV_RM else '0';
  op_o(3)  <= '1' when opcode_i = OP_OR     else '0';
  op_o(4)  <= '1' when opcode_i = OP_NOR    else '0';
  op_o(5)  <= '1' when opcode_i = OP_SRA    else '0';
  op_o(6)  <= '1' when opcode_i = OP_INCS   else '0';
  op_o(7)  <= '1' when opcode_i = OP_PUSH   else '0';
  op_o(8)  <= '1' when opcode_i = OP_POP    else '0';
  op_o(9)  <= '1' when opcode_i = OP_JMP    else '0';
  op_o(10) <= '1' when opcode_i = OP_JZ     else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_mux2_16 is
  port (
    sel_i : in  std_logic;
    d0_i  : in  word_t;
    d1_i  : in  word_t;
    y_o   : out word_t
  );
end entity;

architecture rtl of rtl_doc_mux2_16 is
begin
  y_o <= d1_i when sel_i = '1' else d0_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_mux4_16 is
  port (
    sel_i : in  std_logic_vector(1 downto 0);
    d0_i  : in  word_t;
    d1_i  : in  word_t;
    d2_i  : in  word_t;
    d3_i  : in  word_t;
    y_o   : out word_t
  );
end entity;

architecture rtl of rtl_doc_mux4_16 is
begin
  with sel_i select
    y_o <= d0_i when "00",
           d1_i when "01",
           d2_i when "10",
           d3_i when others;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_mux7_16 is
  port (
    sel_i : in  std_logic_vector(2 downto 0);
    d0_i  : in  word_t;
    d1_i  : in  word_t;
    d2_i  : in  word_t;
    d3_i  : in  word_t;
    d4_i  : in  word_t;
    d5_i  : in  word_t;
    d6_i  : in  word_t;
    y_o   : out word_t
  );
end entity;

architecture rtl of rtl_doc_mux7_16 is
begin
  with sel_i select
    y_o <= d0_i when "000",
           d1_i when "001",
           d2_i when "010",
           d3_i when "011",
           d4_i when "100",
           d5_i when "101",
           d6_i when others;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_mux12_16 is
  port (
    sel_i : in  std_logic_vector(3 downto 0);
    d0_i  : in  word_t; d1_i  : in  word_t; d2_i  : in  word_t; d3_i  : in  word_t;
    d4_i  : in  word_t; d5_i  : in  word_t; d6_i  : in  word_t; d7_i  : in  word_t;
    d8_i  : in  word_t; d9_i  : in  word_t; d10_i : in  word_t; d11_i : in  word_t;
    y_o   : out word_t
  );
end entity;

architecture rtl of rtl_doc_mux12_16 is
begin
  with sel_i select
    y_o <= d0_i  when x"0",
           d1_i  when x"1",
           d2_i  when x"2",
           d3_i  when x"3",
           d4_i  when x"4",
           d5_i  when x"5",
           d6_i  when x"6",
           d7_i  when x"7",
           d8_i  when x"8",
           d9_i  when x"9",
           d10_i when x"A",
           d11_i when others;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_compare16 is
  port (
    a_i  : in  word_t;
    b_i  : in  word_t;
    eq_o : out std_logic
  );
end entity;

architecture rtl of rtl_doc_compare16 is
begin
  eq_o <= '1' when a_i = b_i else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_or_bit is
  port (a_i : in std_logic; b_i : in std_logic; y_o : out std_logic);
end entity;

architecture rtl of rtl_doc_or_bit is
begin
  y_o <= a_i or b_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_nor_bit is
  port (a_i : in std_logic; b_i : in std_logic; y_o : out std_logic);
end entity;

architecture rtl of rtl_doc_nor_bit is
  signal or_s : std_logic;
  attribute keep : boolean;
  attribute keep of or_s : signal is true;
begin
  or_s <= a_i or b_i;
  y_o  <= not or_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_sra16 is
  port (
    a_i     : in  word_t;
    y_o     : out word_t;
    carry_o : out std_logic
  );
end entity;

architecture rtl of rtl_doc_sra16 is
begin
  y_o     <= a_i(15) & a_i(15 downto 1);
  carry_o <= a_i(0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_incs16 is
  port (
    a_i     : in  word_t;
    s_i     : in  std_logic;
    y_o     : out word_t;
    carry_o : out std_logic
  );
end entity;

architecture rtl of rtl_doc_incs16 is
  signal addend_s : word_t;
  signal sum_s    : unsigned(16 downto 0);
  attribute keep : boolean;
  attribute keep of addend_s : signal is true;
  attribute keep of sum_s    : signal is true;
begin
  addend_s <= (0 => s_i, others => '0');
  sum_s    <= ('0' & unsigned(a_i)) + ('0' & unsigned(addend_s));
  y_o      <= std_logic_vector(sum_s(15 downto 0));
  carry_o  <= sum_s(16);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_flags_logic is
  port (
    y_i       : in  word_t;
    carry_i   : in  std_logic;
    overflow_i: in  std_logic;
    flags_o   : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of rtl_doc_flags_logic is
begin
  flags_o(0) <= '1' when y_i = x"0000" else '0';
  flags_o(1) <= y_i(15);
  flags_o(2) <= carry_i;
  flags_o(3) <= overflow_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_control_matrix is
  port (
    op_i       : in  std_logic_vector(10 downto 0);
    flags_i    : in  std_logic_vector(3 downto 0);
    control_o  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of rtl_doc_control_matrix is
begin
  control_o(0)  <= op_i(1) or op_i(8);                         -- rf_we
  control_o(1)  <= op_i(2);                                    -- ram_write
  control_o(2)  <= op_i(1) or op_i(2);                         -- cache_req
  control_o(3)  <= op_i(7);                                    -- push
  control_o(4)  <= op_i(8);                                    -- pop
  control_o(5)  <= op_i(9) or (op_i(10) and flags_i(0));        -- pc_load
  control_o(6)  <= op_i(0);                                    -- halt
  control_o(9 downto 7) <= ALU_OR  when op_i(3) = '1' else
                           ALU_NOR when op_i(4) = '1' else
                           ALU_SRA when op_i(5) = '1' else
                           ALU_INCS when op_i(6) = '1' else
                           ALU_PASS_A;
  control_o(10) <= op_i(3) or op_i(4) or op_i(5) or op_i(6);    -- flag_we
  control_o(11) <= op_i(9) or op_i(10);                        -- bp_query
  control_o(12) <= op_i(10);                                   -- bp_update
  control_o(15 downto 13) <= (others => '0');
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_rom16x16 is
  port (
    addr_i : in  addr_t;
    q_o    : out word_t
  );
end entity;

architecture rtl of rtl_doc_rom16x16 is
begin
  q_o <= addr_i xor x"5A0F";
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_ram16x16 is
  port (
    clk_i   : in  std_logic;
    addr_i  : in  std_logic_vector(3 downto 0);
    we_i    : in  std_logic;
    data_i  : in  word_t;
    data_o  : out word_t
  );
end entity;

architecture rtl of rtl_doc_ram16x16 is
  type mem_t is array (0 to 15) of word_t;
  signal mem_r : mem_t := (others => (others => '0'));
  attribute preserve : boolean;
  attribute preserve of mem_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if we_i = '1' then
        mem_r(to_integer(unsigned(addr_i))) <= data_i;
      end if;
    end if;
  end process;
  data_o <= mem_r(to_integer(unsigned(addr_i)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_arbiter2 is
  port (
    cpu_req_i : in  std_logic;
    dma_req_i : in  std_logic;
    cpu_gnt_o : out std_logic;
    dma_gnt_o : out std_logic
  );
end entity;

architecture rtl of rtl_doc_arbiter2 is
begin
  dma_gnt_o <= dma_req_i;
  cpu_gnt_o <= cpu_req_i and not dma_req_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_doc_dma3word is
  port (
    clk_i     : in  std_logic;
    rst_i     : in  std_logic;
    start_i   : in  std_logic;
    grant_i   : in  std_logic;
    ram_req_o : out std_logic;
    ram_we_o  : out std_logic;
    addr_o    : out addr_t;
    data_o    : out word_t;
    busy_o    : out std_logic
  );
end entity;

architecture rtl of rtl_doc_dma3word is
  signal idx_r  : unsigned(1 downto 0) := (others => '0');
  signal busy_r : std_logic := '0';
  attribute preserve : boolean;
  attribute preserve of idx_r  : signal is true;
  attribute preserve of busy_r : signal is true;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        idx_r  <= (others => '0');
        busy_r <= '0';
      elsif start_i = '1' then
        busy_r <= '1';
        idx_r  <= (others => '0');
      elsif busy_r = '1' and grant_i = '1' then
        if idx_r = "10" then
          busy_r <= '0';
        else
          idx_r <= idx_r + 1;
        end if;
      end if;
    end if;
  end process;
  ram_req_o <= busy_r;
  ram_we_o  <= busy_r and grant_i;
  addr_o    <= x"000A" when idx_r = "00" else x"000B" when idx_r = "01" else x"000C";
  data_o    <= x"D000" or std_logic_vector(resize(idx_r, 16));
  busy_o    <= busy_r;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_a_command_system_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_a_command_system_top is
  signal pc_q, pc_next, rom_q, ir0_q, ir1_q : word_t;
  signal opcode_s : std_logic_vector(7 downto 0);
  signal op_s     : std_logic_vector(10 downto 0);
begin
  pc_next <= std_logic_vector(unsigned(pc_q) + 1);
  opcode_s <= ir0_q(15 downto 8);
  U_PC_REG             : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, pc_next, pc_q);
  U_PROGRAM_ROM        : entity work.rtl_doc_rom16x16 port map (pc_q, rom_q);
  U_IR_WORD0_OPCODE_RN : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, rom_q, ir0_q);
  U_IR_WORD1_ADDR_IMM  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, addr_i xor data_i, ir1_q);
  U_OPCODE_DECODER     : entity work.rtl_doc_opcode_decode11 port map (opcode_s, op_s);
  data_o <= ir0_q xor ir1_q xor pc_q;
  flag_o <= op_s(0) or op_s(1) or op_s(2) or op_s(3) or op_s(4) or op_s(5) or op_s(6) or op_s(7) or op_s(8) or op_s(9) or op_s(10);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_b_memory_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_b_memory_top is
  signal rom_q, ram_q, dma_data, dma_addr : word_t;
  signal cpu_gnt, dma_gnt, dma_req, dma_we, busy_s : std_logic;
begin
  U_COMMAND_ROM_256X16 : entity work.rtl_doc_rom16x16 port map (addr_i, rom_q);
  U_DATA_RAM_256X16    : entity work.rtl_doc_ram16x16 port map (clk_i, addr_i(3 downto 0), ctrl_i(0) and cpu_gnt, data_i xor dma_data, ram_q);
  U_DMA_3_WORDS_AT_0A  : entity work.rtl_doc_dma3word port map (clk_i, rst_i, ctrl_i(1), dma_gnt, dma_req, dma_we, dma_addr, dma_data, busy_s);
  U_RAM_BUS_ARBITER    : entity work.rtl_doc_arbiter2 port map (en_i, dma_req, cpu_gnt, dma_gnt);
  data_o <= rom_q xor ram_q xor dma_data;
  flag_o <= cpu_gnt or dma_gnt or busy_s or dma_we;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_v_control_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_v_control_top is
  signal opcode_q : std_logic_vector(7 downto 0);
  signal state_q, state_next : std_logic_vector(3 downto 0);
  signal flags_q : std_logic_vector(3 downto 0);
  signal op_s : std_logic_vector(10 downto 0);
  signal ctl_s : std_logic_vector(15 downto 0);
begin
  state_next <= std_logic_vector(unsigned(state_q) + 1);
  flags_q <= ctrl_i(3 downto 0);
  U_OPCODE_REGISTER : entity work.rtl_doc_reg8 port map (clk_i, rst_i, en_i, data_i(15 downto 8), opcode_q);
  U_STATE_REGISTER  : entity work.rtl_doc_reg4 port map (clk_i, rst_i, en_i, state_next, state_q);
  U_OPCODE_DECODER  : entity work.rtl_doc_opcode_decode11 port map (opcode_q, op_s);
  U_CONTROL_MATRIX  : entity work.rtl_doc_control_matrix port map (op_s, flags_q, ctl_s);
  data_o <= ctl_s;
  flag_o <= ctl_s(6) or ctl_s(10) or ctl_s(12);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_g_special_registers_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_g_special_registers_top is
  signal pc_q, ir0_q, ir1_q, pc_mux_q : word_t;
  signal fr_q, state_q : std_logic_vector(3 downto 0);
  signal sp_q : std_logic_vector(2 downto 0);
  signal ghr_q : std_logic_vector(1 downto 0);
begin
  U_NEXT_PC_MUX  : entity work.rtl_doc_mux2_16 port map (ctrl_i(0), std_logic_vector(unsigned(pc_q) + 1), addr_i, pc_mux_q);
  U_PC_REGISTER  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, pc_mux_q, pc_q);
  U_IR0_REGISTER : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, data_i, ir0_q);
  U_IR1_REGISTER : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, aux_i, ir1_q);
  U_FLAGS_REG    : entity work.rtl_doc_reg4  port map (clk_i, rst_i, en_i, ctrl_i(3 downto 0), fr_q);
  U_STACK_PTR    : entity work.rtl_doc_reg3  port map (clk_i, rst_i, en_i, ctrl_i(2 downto 0), sp_q);
  U_STATE_REG    : entity work.rtl_doc_reg4  port map (clk_i, rst_i, en_i, ctrl_i(7 downto 4), state_q);
  U_BP_GHR_REG   : entity work.rtl_doc_reg2  port map (clk_i, rst_i, en_i, ctrl_i(1 downto 0), ghr_q);
  data_o <= pc_q xor ir0_q xor ir1_q xor (x"000" & fr_q);
  flag_o <= sp_q(0) or ghr_q(0) or state_q(0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_d_reg_file_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_d_reg_file_top is
  signal dec_s : std_logic_vector(11 downto 0);
  signal r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11 : word_t;
  signal a_bus, b_bus : word_t;
begin
  U_WRITE_ADDR_DECODER_12 : entity work.rtl_doc_decode12 port map (addr_i(3 downto 0), ctrl_i(0), dec_s);
  U_RON0  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(0),  data_i, r0);
  U_RON1  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(1),  data_i, r1);
  U_RON2  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(2),  data_i, r2);
  U_RON3  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(3),  data_i, r3);
  U_RON4  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(4),  data_i, r4);
  U_RON5  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(5),  data_i, r5);
  U_RON6  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(6),  data_i, r6);
  U_RON7  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(7),  data_i, r7);
  U_RON8  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(8),  data_i, r8);
  U_RON9  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(9),  data_i, r9);
  U_RON10 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(10), data_i, r10);
  U_RON11 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(11), data_i, r11);
  U_READ_PORT_A_MUX12 : entity work.rtl_doc_mux12_16 port map (ctrl_i(3 downto 0), r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11, a_bus);
  U_READ_PORT_B_MUX12 : entity work.rtl_doc_mux12_16 port map (addr_i(7 downto 4), r0,r1,r2,r3,r4,r5,r6,r7,r8,r9,r10,r11, b_bus);
  data_o <= a_bus xor b_bus;
  flag_o <= dec_s(0) or dec_s(11);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_e_common_ops_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_e_common_ops_top is
  signal op_s : std_logic_vector(10 downto 0);
  signal ctl_s : std_logic_vector(15 downto 0);
  signal pc_q, pc_next : word_t;
  signal cache_q, stack_q : word_t;
begin
  U_COMMON_OPCODE_DECODER : entity work.rtl_doc_opcode_decode11 port map (ctrl_i, op_s);
  U_COMMON_CONTROL_MATRIX : entity work.rtl_doc_control_matrix port map (op_s, data_i(3 downto 0), ctl_s);
  U_PC_JMP_JZ_MUX         : entity work.rtl_doc_mux2_16 port map (ctl_s(5), std_logic_vector(unsigned(pc_q) + 1), addr_i, pc_next);
  U_PC_REGISTER           : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, pc_next, pc_q);
  U_CACHE_READ_WRITE_BUF  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, ctl_s(2), aux_i, cache_q);
  U_STACK_PUSH_POP_BUF    : entity work.rtl_doc_reg16 port map (clk_i, rst_i, ctl_s(3) or ctl_s(4), data_i, stack_q);
  data_o <= pc_q xor cache_q xor stack_q xor ctl_s;
  flag_o <= ctl_s(1) or ctl_s(2) or ctl_s(3) or ctl_s(4) or ctl_s(6);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_zh_jmp_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_zh_jmp_top is
  signal pc_q, next_q : word_t;
begin
  U_JMP_NEXT_PC_MUX : entity work.rtl_doc_mux2_16 port map (ctrl_i(0), std_logic_vector(unsigned(pc_q) + 1), addr_i, next_q);
  U_PC_LOAD_REG     : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, next_q, pc_q);
  U_TARGET_COMPARE  : entity work.rtl_doc_compare16 port map (pc_q, addr_i, flag_o);
  data_o <= pc_q;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_i_m_to_r_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_i_m_to_r_top is
  signal ram_q, read_buf, rf_q : word_t;
begin
  U_CACHE_OR_RAM_READ : entity work.rtl_doc_ram16x16 port map (clk_i, addr_i(3 downto 0), '0', data_i, ram_q);
  U_READ_DATA_REG     : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, ram_q, read_buf);
  U_RF_WRITEBACK_REG  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, ctrl_i(0), read_buf, rf_q);
  data_o <= rf_q;
  flag_o <= ctrl_i(0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_k_r_to_m_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_k_r_to_m_top is
  signal ram_q : word_t;
  signal cpu_gnt, dma_gnt : std_logic;
begin
  U_WRITE_GRANT_ARBITER : entity work.rtl_doc_arbiter2 port map (ctrl_i(0), ctrl_i(1), cpu_gnt, dma_gnt);
  U_CACHE_WRITE_RAM     : entity work.rtl_doc_ram16x16 port map (clk_i, addr_i(3 downto 0), cpu_gnt, data_i, ram_q);
  U_WRITTEN_COMPARE     : entity work.rtl_doc_compare16 port map (ram_q, data_i, flag_o);
  data_o <= ram_q;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_l_alu_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_l_alu_top is
  signal or_y, nor_y, sra_y, incs_y, alu_y : word_t;
  signal c_sra, c_inc : std_logic;
  signal flags_s : std_logic_vector(3 downto 0);
begin
  U_OPERATION_OR     : entity work.app_m_or_top   port map (clk_i, rst_i, en_i, addr_i, data_i, aux_i, ctrl_i, or_y, open);
  U_OPERATION_NOR    : entity work.app_n_nor_top  port map (clk_i, rst_i, en_i, addr_i, data_i, aux_i, ctrl_i, nor_y, open);
  U_OPERATION_SRA    : entity work.rtl_doc_sra16  port map (data_i, sra_y, c_sra);
  U_OPERATION_INCS   : entity work.rtl_doc_incs16 port map (data_i, ctrl_i(0), incs_y, c_inc);
  U_RESULT_MUX4      : entity work.rtl_doc_mux4_16 port map (ctrl_i(2 downto 1), or_y, nor_y, sra_y, incs_y, alu_y);
  U_ALU_FLAGS        : entity work.rtl_doc_flags_logic port map (alu_y, c_sra or c_inc, '0', flags_s);
  data_o <= alu_y;
  flag_o <= flags_s(0) or flags_s(1) or flags_s(2);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_m_or_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_m_or_top is
  signal y_s : word_t;
begin
  GEN_OR_BITS : for i in 0 to 15 generate
    U_OR_BIT : entity work.rtl_doc_or_bit port map (data_i(i), aux_i(i), y_s(i));
  end generate;
  data_o <= y_s;
  flag_o <= '1' when y_s = x"0000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_n_nor_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_n_nor_top is
  signal y_s : word_t;
begin
  GEN_NOR_BITS : for i in 0 to 15 generate
    U_NOR_BIT : entity work.rtl_doc_nor_bit port map (data_i(i), aux_i(i), y_s(i));
  end generate;
  data_o <= y_s;
  flag_o <= '1' when y_s = x"0000" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_p_sra_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_p_sra_top is
begin
  U_SIGN_EXT_ARITH_SHIFT : entity work.rtl_doc_sra16 port map (data_i, data_o, flag_o);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_r_incs_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_r_incs_top is
begin
  U_ADD_ONE_WHEN_S_FLAG : entity work.rtl_doc_incs16 port map (data_i, ctrl_i(1), data_o, flag_o);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_s_flags_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_s_flags_top is
  signal flags_s, flags_q : std_logic_vector(3 downto 0);
begin
  U_FLAG_COMBINATIONAL_LOGIC : entity work.rtl_doc_flags_logic port map (data_i, ctrl_i(0), ctrl_i(1), flags_s);
  U_FLAG_REGISTER           : entity work.rtl_doc_reg4 port map (clk_i, rst_i, en_i, flags_s, flags_q);
  data_o <= x"000" & flags_q;
  flag_o <= flags_q(0) or flags_q(1) or flags_q(2) or flags_q(3);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_t_stack_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_t_stack_top is
  signal sp_q, sp_next : std_logic_vector(2 downto 0);
  signal dec_s : std_logic_vector(6 downto 0);
  signal s0,s1,s2,s3,s4,s5,s6 : word_t;
  signal stack_q : word_t;
begin
  sp_next <= std_logic_vector(unsigned(sp_q) - 1) when ctrl_i(0) = '1' else
             std_logic_vector(unsigned(sp_q) + 1) when ctrl_i(1) = '1' else sp_q;
  U_SP_UP_DOWN_COUNTER : entity work.rtl_doc_reg3 port map (clk_i, rst_i, en_i, sp_next, sp_q);
  U_STACK_CELL_DECODER : entity work.rtl_doc_decode7 port map (sp_q, ctrl_i(0), dec_s);
  U_STACK0 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(0), data_i, s0);
  U_STACK1 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(1), data_i, s1);
  U_STACK2 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(2), data_i, s2);
  U_STACK3 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(3), data_i, s3);
  U_STACK4 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(4), data_i, s4);
  U_STACK5 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(5), data_i, s5);
  U_STACK6 : entity work.rtl_doc_reg16 port map (clk_i, rst_i, dec_s(6), data_i, s6);
  U_STACK_READ_MUX7 : entity work.rtl_doc_mux7_16 port map (sp_q, s0,s1,s2,s3,s4,s5,s6, stack_q);
  data_o <= stack_q;
  flag_o <= '1' when sp_q = "000" or sp_q = "111" else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_u_stack_exec_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_u_stack_exec_top is
  signal rf_a_q, stack_q, wb_q : word_t;
  signal ctl_s : std_logic_vector(15 downto 0);
  signal op_s  : std_logic_vector(10 downto 0);
begin
  U_PUSH_POP_OPCODE_DECODER : entity work.rtl_doc_opcode_decode11 port map (ctrl_i, op_s);
  U_PUSH_POP_CONTROL        : entity work.rtl_doc_control_matrix port map (op_s, data_i(3 downto 0), ctl_s);
  U_RF_SOURCE_REGISTER      : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, data_i, rf_a_q);
  U_STACK_DEVICE_7X16       : entity work.app_t_stack_top port map (clk_i, rst_i, en_i, addr_i, rf_a_q, aux_i, ctl_s(7 downto 0), stack_q, open);
  U_POP_WRITEBACK_REGISTER  : entity work.rtl_doc_reg16 port map (clk_i, rst_i, ctl_s(4), stack_q, wb_q);
  data_o <= wb_q xor rf_a_q;
  flag_o <= ctl_s(3) or ctl_s(4);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_f_cache_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_f_cache_top is
  signal ready_s, hit_s, miss_s, ram_req_s, ram_we_s : std_logic;
  signal ram_addr_s, ram_wdata_s : word_t;
begin
  U_CACHE_4WAY_STRUCTURAL_DOC : entity work.cache_4way_structural_doc
    port map (
      clk_i => clk_i, rst_i => rst_i, cpu_req_i => en_i, cpu_we_i => ctrl_i(0),
      cpu_addr_i => addr_i, cpu_wdata_i => data_i, cpu_rdata_o => data_o,
      cpu_ready_o => ready_s, hit_o => hit_s, miss_o => miss_s,
      ram_req_o => ram_req_s, ram_we_o => ram_we_s, ram_addr_o => ram_addr_s,
      ram_wdata_o => ram_wdata_s, ram_rdata_i => aux_i, ram_grant_i => ctrl_i(1)
    );
  flag_o <= ready_s or hit_s or miss_s or ram_req_s or ram_we_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_h_cache_data_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_h_cache_data_top is
  signal tag_s : std_logic_vector(11 downto 0);
  signal set_s : std_logic_vector(3 downto 0);
  signal d0,d1,d2,d3 : word_t;
  signal t0,t1,t2,t3 : std_logic_vector(11 downto 0);
  signal e0,e1,e2,e3 : std_logic;
begin
  U_ADDRESS_SPLIT : entity work.cache_address_split_doc port map (addr_i, tag_s, set_s);
  U_DATA_WAY0 : entity work.cache_data_way_doc port map (clk_i, set_s, ctrl_i(0), data_i, d0);
  U_DATA_WAY1 : entity work.cache_data_way_doc port map (clk_i, set_s, ctrl_i(1), data_i, d1);
  U_DATA_WAY2 : entity work.cache_data_way_doc port map (clk_i, set_s, ctrl_i(2), data_i, d2);
  U_DATA_WAY3 : entity work.cache_data_way_doc port map (clk_i, set_s, ctrl_i(3), data_i, d3);
  U_TAG_WAY0  : entity work.cache_tag_way_doc port map (clk_i, set_s, ctrl_i(0), tag_s, t0);
  U_TAG_WAY1  : entity work.cache_tag_way_doc port map (clk_i, set_s, ctrl_i(1), tag_s, t1);
  U_TAG_WAY2  : entity work.cache_tag_way_doc port map (clk_i, set_s, ctrl_i(2), tag_s, t2);
  U_TAG_WAY3  : entity work.cache_tag_way_doc port map (clk_i, set_s, ctrl_i(3), tag_s, t3);
  U_CMP0      : entity work.cache_tag_compare_doc port map (tag_s, t0, e0);
  U_CMP1      : entity work.cache_tag_compare_doc port map (tag_s, t1, e1);
  U_CMP2      : entity work.cache_tag_compare_doc port map (tag_s, t2, e2);
  U_CMP3      : entity work.cache_tag_compare_doc port map (tag_s, t3, e3);
  U_HIT_DATA_MUX4 : entity work.cache_hit_mux_doc port map (e0,e1,e2,e3,d0,d1,d2,d3, open, data_o);
  flag_o <= e0 or e1 or e2 or e3;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_ts_cache_flags_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_ts_cache_flags_top is
  signal set_s : std_logic_vector(3 downto 0);
  signal tag_s : std_logic_vector(11 downto 0);
  signal v0,v1,v2,v3 : std_logic;
  signal a0,a1,a2,a3 : unsigned(1 downto 0);
  signal victim_s : std_logic_vector(1 downto 0);
  signal onehot_s : std_logic_vector(3 downto 0);
begin
  U_ADDRESS_SPLIT_FOR_FLAGS : entity work.cache_address_split_doc port map (addr_i, tag_s, set_s);
  U_VALID_WAY0 : entity work.cache_valid_way_doc port map (clk_i, rst_i, set_s, ctrl_i(0), '1', v0);
  U_VALID_WAY1 : entity work.cache_valid_way_doc port map (clk_i, rst_i, set_s, ctrl_i(1), '1', v1);
  U_VALID_WAY2 : entity work.cache_valid_way_doc port map (clk_i, rst_i, set_s, ctrl_i(2), '1', v2);
  U_VALID_WAY3 : entity work.cache_valid_way_doc port map (clk_i, rst_i, set_s, ctrl_i(3), '1', v3);
  U_AGE_WAY0   : entity work.cache_age_way_doc port map (clk_i, rst_i, set_s, ctrl_i(0), ctrl_i(4), "00", a0);
  U_AGE_WAY1   : entity work.cache_age_way_doc port map (clk_i, rst_i, set_s, ctrl_i(1), ctrl_i(4), "00", a1);
  U_AGE_WAY2   : entity work.cache_age_way_doc port map (clk_i, rst_i, set_s, ctrl_i(2), ctrl_i(4), "00", a2);
  U_AGE_WAY3   : entity work.cache_age_way_doc port map (clk_i, rst_i, set_s, ctrl_i(3), ctrl_i(4), "00", a3);
  U_VICTIM_SELECT_INVALID_OR_MAX_AGE : entity work.cache_victim_select_doc port map (v0,v1,v2,v3,a0,a1,a2,a3,victim_s,onehot_s);
  data_o <= x"000" & onehot_s;
  flag_o <= victim_s(0) or victim_s(1);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_sh_microevm_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_sh_microevm_top is
  signal cpu_q, rom_q, cache_q, ram_q, dma_q, bp_q : word_t;
  signal cpu_gnt, dma_gnt, dma_req, dma_we, dma_busy : std_logic;
begin
  U_CPU_CORE_CU_RON_ALU_STACK : entity work.app_v_control_top port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,cpu_q,open);
  U_COMMAND_ROM              : entity work.rtl_doc_rom16x16 port map (cpu_q, rom_q);
  U_DATA_CACHE_4WAY          : entity work.app_f_cache_top port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,cache_q,open);
  U_RAM_ARBITER_CPU_DMA      : entity work.rtl_doc_arbiter2 port map (en_i,dma_req,cpu_gnt,dma_gnt);
  U_DATA_RAM                 : entity work.rtl_doc_ram16x16 port map (clk_i,addr_i(3 downto 0),cpu_gnt,data_i,ram_q);
  U_DMA_CONTROLLER_3_WORD    : entity work.rtl_doc_dma3word port map (clk_i,rst_i,ctrl_i(2),dma_gnt,dma_req,dma_we,open,dma_q,dma_busy);
  U_BRANCH_PREDICTOR_A4      : entity work.app_shch_branch_predictor_top port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,bp_q,open);
  data_o <= cpu_q xor rom_q xor cache_q xor ram_q xor dma_q xor bp_q;
  flag_o <= cpu_gnt or dma_gnt or dma_we or dma_busy;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity app_shch_branch_predictor_top is
  port (clk_i : in std_logic; rst_i : in std_logic; en_i : in std_logic; addr_i : in addr_t; data_i : in word_t; aux_i : in word_t; ctrl_i : in std_logic_vector(7 downto 0); data_o : out word_t; flag_o : out std_logic);
end entity;

architecture structural of app_shch_branch_predictor_top is
  signal ghr_q, pht_q, pht_next : std_logic_vector(1 downto 0);
  signal index_q : std_logic_vector(3 downto 0);
  signal btb_q, target_mux : word_t;
  signal eq_s : std_logic;
begin
  index_q <= addr_i(3 downto 2) & ghr_q;
  pht_next <= "11" when ctrl_i(0) = '1' and pht_q = "10" else
              "10" when ctrl_i(0) = '1' and pht_q = "01" else
              "01" when ctrl_i(0) = '0' and pht_q = "10" else
              pht_q;
  U_GLOBAL_HISTORY_REG : entity work.rtl_doc_reg2  port map (clk_i, rst_i, en_i, ghr_q(0) & ctrl_i(0), ghr_q);
  U_PHT_COUNTER_REG    : entity work.rtl_doc_reg2  port map (clk_i, rst_i, en_i, pht_next, pht_q);
  U_BTB_TARGET_REG     : entity work.rtl_doc_reg16 port map (clk_i, rst_i, en_i, aux_i, btb_q);
  U_PC_TAG_COMPARE     : entity work.rtl_doc_compare16 port map (addr_i, data_i, eq_s);
  U_TARGET_MUX         : entity work.rtl_doc_mux2_16 port map (pht_q(1) and eq_s, std_logic_vector(unsigned(addr_i) + 1), btb_q, target_mux);
  data_o <= target_mux xor (x"000" & index_q);
  flag_o <= pht_q(1) and eq_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity rtl_appendix_all_top is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    addr_i     : in  addr_t;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    screen_o   : out word_t;
    summary_o  : out std_logic
  );
end entity;

architecture structural of rtl_appendix_all_top is
  signal a,b,v,g,d,e,zh,i_mr,k_rm,l,m,n,p,r,s,t,u,f,h,ts,sh,shch : word_t;
  signal fa,fb,fv,fg,fd,fe,fzh,fi,fk,fl,fm,fn,fp,fr,fs,ft,fu,ff,fh,fts,fsh,fshch : std_logic;
begin
  U_APP_A_COMMAND_SYSTEM       : entity work.app_a_command_system_top       port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,a,fa);
  U_APP_B_MEMORY               : entity work.app_b_memory_top               port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,b,fb);
  U_APP_V_CONTROL_UNIT         : entity work.app_v_control_top              port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,v,fv);
  U_APP_G_SPECIAL_REGISTERS    : entity work.app_g_special_registers_top    port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,g,fg);
  U_APP_D_RON                  : entity work.app_d_reg_file_top             port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,d,fd);
  U_APP_E_COMMON_OPERATIONS    : entity work.app_e_common_ops_top           port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,e,fe);
  U_APP_ZH_JMP                 : entity work.app_zh_jmp_top                 port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,zh,fzh);
  U_APP_I_M_TO_R               : entity work.app_i_m_to_r_top               port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,i_mr,fi);
  U_APP_K_R_TO_M               : entity work.app_k_r_to_m_top               port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,k_rm,fk);
  U_APP_L_ALU                  : entity work.app_l_alu_top                  port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,l,fl);
  U_APP_M_OR                   : entity work.app_m_or_top                   port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,m,fm);
  U_APP_N_NOR                  : entity work.app_n_nor_top                  port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,n,fn);
  U_APP_P_SRA                  : entity work.app_p_sra_top                  port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,p,fp);
  U_APP_R_INCS                 : entity work.app_r_incs_top                 port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,r,fr);
  U_APP_S_FLAGS                : entity work.app_s_flags_top                port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,s,fs);
  U_APP_T_STACK                : entity work.app_t_stack_top                port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,t,ft);
  U_APP_U_STACK_EXEC           : entity work.app_u_stack_exec_top           port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,u,fu);
  U_APP_F_CACHE                : entity work.app_f_cache_top                port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,f,ff);
  U_APP_H_CACHE_DATA           : entity work.app_h_cache_data_top           port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,h,fh);
  U_APP_TS_CACHE_FLAGS         : entity work.app_ts_cache_flags_top         port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,ts,fts);
  U_APP_SH_MICRO_EVM           : entity work.app_sh_microevm_top            port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,sh,fsh);
  U_APP_SHCH_BRANCH_PREDICTOR  : entity work.app_shch_branch_predictor_top  port map (clk_i,rst_i,en_i,addr_i,data_i,aux_i,ctrl_i,shch,fshch);

  screen_o <= a xor b xor v xor g xor d xor e xor zh xor i_mr xor k_rm xor l xor m xor n xor p xor r xor s xor t xor u xor f xor h xor ts xor sh xor shch;
  summary_o <= fa or fb or fv or fg or fd or fe or fzh or fi or fk or fl or fm or fn or fp or fr or fs or ft or fu or ff or fh or fts or fsh or fshch;
end architecture;

