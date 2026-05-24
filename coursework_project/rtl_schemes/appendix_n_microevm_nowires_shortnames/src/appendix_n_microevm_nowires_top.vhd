library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity a is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of a is
  signal f_s, ah_s, ex_s, al_s : std_logic;
  signal summary_s : word_t;
begin
  U_PHASE_COUNTER_UNIT : entity work.appendix_n_phase_counter_unit
    port map (en_i, rst_i, clk_i, f_s, ah_s, ex_s, al_s);
  summary_s <= x"000" & f_s & ah_s & ex_s & al_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity b is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of b is
  signal ip_s, ir_s, ah_s, al_s : word_t;
  signal summary_s : word_t;
begin
  U_SPECIAL_REGISTERS : entity work.appendix_n_special_registers
    port map (clk_i, rst_i, ctrl_i(0), ctrl_i(1), en_i, ctrl_i(2), ctrl_i(3), data_i, aux_i, ip_s, ir_s, ah_s, al_s);
  summary_s <= ip_s xor ir_s xor ah_s xor al_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity c is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of c is
  signal summary_s : word_t;
begin
  U_COMMAND_MEMORY_ROM : entity work.rom_sync
    port map (clk_i, en_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity d is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of d is
  signal hist_s : std_logic_vector(1 downto 0);
  signal pred_s : std_logic;
  signal target_s : word_t;
  signal summary_s : word_t;
begin
  U_BRANCH_PREDICTOR : entity work.branch_predictor
    port map (clk_i, rst_i, en_i, aux_i, hist_s, pred_s, target_s, ctrl_i(0), aux_i, ctrl_i(2 downto 1), ctrl_i(3), data_i);
  summary_s <= target_s xor (x"000" & '0' & pred_s & hist_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity e is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of e is
  signal cmp_s : std_logic;
  signal summary_s : word_t;
begin
  U_CMP_IS_JMP : entity work.appendix_n_cmp_is_jmp
    port map (data_i(15 downto 8), cmp_s);
  summary_s <= x"000" & "000" & cmp_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity f is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of f is
  signal cmp_s : std_logic;
  signal summary_s : word_t;
begin
  U_CMP_IS_MEM_TO_REG : entity work.appendix_n_cmp_is_mem_to_reg
    port map (data_i(15 downto 8), cmp_s);
  summary_s <= x"000" & "000" & cmp_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity g is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of g is
  signal cmp_s : std_logic;
  signal summary_s : word_t;
begin
  U_CMP_IS_REG_TO_MEM : entity work.appendix_n_cmp_is_reg_to_mem
    port map (data_i(15 downto 8), cmp_s);
  summary_s <= x"000" & "000" & cmp_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity h is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of h is
  signal br_s, ip_load_s, ip_inc_s, halt_s, rw_s, notz_s, mw_s, mr_s, push_s, pop_s, sload_s : std_logic;
  signal alu_op_s : std_logic_vector(2 downto 0);
  signal reg_addr_s : reg_idx_t;
  signal summary_s : word_t;
begin
  U_DECODER_UNIT : entity work.appendix_n_decoder_unit
    port map (data_i(15 downto 8), ctrl_i(0), en_i, br_s, ip_load_s, ip_inc_s, halt_s, alu_op_s, rw_s, notz_s, mw_s, mr_s, push_s, pop_s, sload_s, reg_addr_s);
  summary_s <= br_s & ip_load_s & ip_inc_s & halt_s & rw_s & notz_s & mw_s & mr_s & push_s & pop_s & sload_s & alu_op_s & std_logic_vector(reg_addr_s(1 downto 0));
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity i is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture rtl of i is
  signal prediction_and_notz_s : std_logic;
  signal special_ip_load_s : std_logic;
  signal three_byte_cmd_s : std_logic;
  signal sload_s : std_logic;
  signal summary_s : word_t;
begin
  prediction_and_notz_s <= ctrl_i(0) and ctrl_i(1);
  special_ip_load_s <= prediction_and_notz_s or ctrl_i(2);
  three_byte_cmd_s <= ctrl_i(3) or ctrl_i(4) or ctrl_i(5);
  sload_s <= en_i and (three_byte_cmd_s or special_ip_load_s or ctrl_i(6));
  summary_s <= x"000" & prediction_and_notz_s & special_ip_load_s & three_byte_cmd_s & sload_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s xor data_i xor aux_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity j is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of j is
  signal a_s, b_s : word_t;
  signal summary_s : word_t;
begin
  U_ALU_RON_REGISTER_FILE : entity work.reg_file12x16_dbg
    port map (clk_i, rst_i, en_i, unsigned(ctrl_i(3 downto 0)), unsigned(data_i(3 downto 0)), unsigned(data_i(7 downto 4)), aux_i, a_s, b_s, open, open, open, open, open, open, open, open, open, open, open, open);
  summary_s <= a_s xor b_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity k is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of k is
  signal y_s : word_t;
  signal z_s, s_s, c_s, o_s : std_logic;
  signal summary_s : word_t;
begin
  U_ALU_UNIT : entity work.alu_core
    port map (data_i, aux_i, ctrl_i(7), ctrl_i(2 downto 0), y_s, z_s, s_s, c_s, o_s);
  summary_s <= y_s xor (x"000" & z_s & s_s & c_s & o_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity l is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of l is
  signal z_s, s_s, c_s, o_s : std_logic;
  signal summary_s : word_t;
begin
  U_FLAGS_REGISTER : entity work.flags_reg
    port map (clk_i, rst_i, en_i, ctrl_i(0), ctrl_i(1), ctrl_i(2), ctrl_i(3), z_s, s_s, c_s, o_s);
  summary_s <= x"000" & z_s & s_s & c_s & o_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity m is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of m is
  signal summary_s : word_t;
begin
  U_MUX_DATA_SOURCE : entity work.appendix_n_mux2_16
    port map (ctrl_i(0), data_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity n is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of n is
  signal summary_s : word_t;
begin
  U_MUX_MEM_STACK : entity work.appendix_n_mux2_16
    port map (ctrl_i(1), data_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity o is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of o is
  signal data_s : word_t;
  signal sp_s : unsigned(2 downto 0);
  signal empty_s, full_s : std_logic;
  signal summary_s : word_t;
begin
  U_STACK_CONTROL : entity work.stack7x16
    port map (clk_i, rst_i, ctrl_i(0), ctrl_i(1), data_i, data_s, sp_s, empty_s, full_s);
  summary_s <= data_s xor (x"00" & "000" & std_logic_vector(sp_s) & empty_s & full_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity p is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of p is
  signal data_s : word_t;
  signal ready_s, hit_s, miss_s : std_logic;
  signal summary_s : word_t;
begin
  U_DATA_CACHE : entity work.cache_4way_age
    port map (clk_i, rst_i, en_i, ctrl_i(0), aux_i, data_i, data_s, ready_s, hit_s, miss_s, open, open, open, open, data_i, ctrl_i(1));
  summary_s <= data_s xor (x"000" & '0' & ready_s & hit_s & miss_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity q is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of q is
  signal req_s, busy_s, done_s, we_s : std_logic;
  signal addr_s, data_s : word_t;
  signal summary_s : word_t;
begin
  U_DMAC_CONTROLLER : entity work.dma_controller_3word
    port map (clk_i, rst_i, en_i, ctrl_i(0), ctrl_i(1), data_i, req_s, busy_s, done_s, we_s, addr_s, data_s);
  summary_s <= addr_s xor data_s xor (x"000" & req_s & busy_s & done_s & we_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity r is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of r is
  signal cpu_s, dma_s : std_logic;
  signal summary_s : word_t;
begin
  U_BUS_ARBITER : entity work.bus_arbiter_2master
    port map (ctrl_i(0), ctrl_i(1), cpu_s, dma_s);
  summary_s <= x"000" & "00" & cpu_s & dma_s;
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity s is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of s is
  signal summary_s : word_t;
begin
  U_MUX_CPU_ADDR : entity work.appendix_n_mux2_16
    port map (ctrl_i(2), data_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity t is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of t is
  signal summary_s : word_t;
begin
  U_MUX_SYS_ADDR : entity work.appendix_n_mux2_16
    port map (ctrl_i(3), data_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity u is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of u is
  signal summary_s : word_t;
begin
  U_MUX_FINAL_ADDR : entity work.appendix_n_mux2_16
    port map (ctrl_i(4), data_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity v is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of v is
  signal summary_s : word_t;
begin
  U_LPM_MUX_MEM : entity work.appendix_n_mux2_16
    port map (ctrl_i(5), data_i, aux_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity w is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture structural of w is
  signal summary_s : word_t;
begin
  U_MEMORY : entity work.ram_sync
    port map (clk_i, en_i, ctrl_i(0), aux_i, data_i, summary_s);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity x is
  port (
    clk_i      : in  std_logic;
    rst_i      : in  std_logic;
    en_i       : in  std_logic;
    data_i     : in  word_t;
    aux_i      : in  word_t;
    ctrl_i     : in  std_logic_vector(7 downto 0);
    layout_i   : in  word_t;
    summary_o  : out word_t;
    layout_o   : out word_t
  );
end entity;

architecture rtl of x is
  signal summary_s : word_t;
begin
  summary_s <= data_i xor aux_i xor (x"00" & ctrl_i);
  summary_o <= summary_s;
  layout_o <= layout_i xor summary_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use work.microcomputer_pkg.all;

entity appendix_n_microevm_nowires_top is
  port (
    clock              : in  std_logic;
    reset              : in  std_logic;
    enable             : in  std_logic;
    page_data_i        : in  word_t;
    page_aux_i         : in  word_t;
    page_ctrl_i        : in  std_logic_vector(7 downto 0);

    ROW1_PHASE         : out word_t;
    ROW1_SPECIAL_REGS  : out word_t;
    ROW1_COMMAND_ROM   : out word_t;
    ROW1_BRANCH_PRED   : out word_t;
    ROW1_CMP_JMP       : out word_t;
    ROW1_CMP_MEM_REG   : out word_t;
    ROW1_CMP_REG_MEM   : out word_t;
    ROW1_DECODER       : out word_t;
    ROW1_CONTROL_LOGIC : out word_t;

    ROW2_DATA_MUX      : out word_t;
    ROW2_REGISTER_FILE : out word_t;
    ROW2_ALU_UNIT      : out word_t;
    ROW2_FLAGS         : out word_t;
    ROW2_MEM_STACK_MUX : out word_t;
    ROW2_STACK         : out word_t;

    ROW3_CACHE         : out word_t;
    ROW3_DMA           : out word_t;
    ROW3_BUS_ARBITER   : out word_t;
    ROW3_CPU_ADDR_MUX  : out word_t;
    ROW3_SYS_ADDR_MUX  : out word_t;
    ROW3_FINAL_ADDR_MUX: out word_t;
    ROW3_LPM_MUX_MEM   : out word_t;
    ROW3_MEMORY        : out word_t;
    ROW3_DEBUG         : out word_t;

    A2_CONTROL_CHAIN   : out word_t;
    A2_DATAPATH_CHAIN  : out word_t;
    A2_MEMORY_CHAIN    : out word_t
  );
end entity;

architecture a2_nowires of appendix_n_microevm_nowires_top is
  signal row1_0, row1_1, row1_2, row1_3, row1_4, row1_5, row1_6, row1_7, row1_8, row1_9 : word_t;
  signal row2_0, row2_1, row2_2, row2_3, row2_4, row2_5, row2_6 : word_t;
  signal row3_0, row3_1, row3_2, row3_3, row3_4, row3_5, row3_6, row3_7, row3_8, row3_9 : word_t;
begin
  row1_0 <= page_data_i xor page_aux_i xor (x"00" & page_ctrl_i);
  row2_0 <= page_data_i xor (x"00" & page_ctrl_i);
  row3_0 <= page_aux_i xor (x"00" & page_ctrl_i);

  ua : entity work.a port map (clock, reset, enable, row1_0, row1_0, row1_0(7 downto 0), row1_0, ROW1_PHASE, row1_1);
  ub : entity work.b port map (clock, reset, enable, row1_1, row1_1, row1_1(7 downto 0), row1_1, ROW1_SPECIAL_REGS, row1_2);
  uc : entity work.c port map (clock, reset, enable, row1_2, row1_2, row1_2(7 downto 0), row1_2, ROW1_COMMAND_ROM, row1_3);
  ud : entity work.d port map (clock, reset, enable, row1_3, row1_3, row1_3(7 downto 0), row1_3, ROW1_BRANCH_PRED, row1_4);
  ue : entity work.e port map (clock, reset, enable, row1_4, row1_4, row1_4(7 downto 0), row1_4, ROW1_CMP_JMP, row1_5);
  uf : entity work.f port map (clock, reset, enable, row1_5, row1_5, row1_5(7 downto 0), row1_5, ROW1_CMP_MEM_REG, row1_6);
  ug : entity work.g port map (clock, reset, enable, row1_6, row1_6, row1_6(7 downto 0), row1_6, ROW1_CMP_REG_MEM, row1_7);
  uh : entity work.h port map (clock, reset, enable, row1_7, row1_7, row1_7(7 downto 0), row1_7, ROW1_DECODER, row1_8);
  ui : entity work.i port map (clock, reset, enable, row1_8, row1_8, row1_8(7 downto 0), row1_8, ROW1_CONTROL_LOGIC, row1_9);

  uj : entity work.m port map (clock, reset, enable, row2_0, row2_0, row2_0(7 downto 0), row2_0, ROW2_DATA_MUX, row2_1);
  uk : entity work.j port map (clock, reset, enable, row2_1, row2_1, row2_1(7 downto 0), row2_1, ROW2_REGISTER_FILE, row2_2);
  ul : entity work.k port map (clock, reset, enable, row2_2, row2_2, row2_2(7 downto 0), row2_2, ROW2_ALU_UNIT, row2_3);
  um : entity work.l port map (clock, reset, enable, row2_3, row2_3, row2_3(7 downto 0), row2_3, ROW2_FLAGS, row2_4);
  un : entity work.n port map (clock, reset, enable, row2_4, row2_4, row2_4(7 downto 0), row2_4, ROW2_MEM_STACK_MUX, row2_5);
  uo : entity work.o port map (clock, reset, enable, row2_5, row2_5, row2_5(7 downto 0), row2_5, ROW2_STACK, row2_6);

  up : entity work.p port map (clock, reset, enable, row3_0, row3_0, row3_0(7 downto 0), row3_0, ROW3_CACHE, row3_1);
  uq : entity work.q port map (clock, reset, enable, row3_1, row3_1, row3_1(7 downto 0), row3_1, ROW3_DMA, row3_2);
  ur : entity work.r port map (clock, reset, enable, row3_2, row3_2, row3_2(7 downto 0), row3_2, ROW3_BUS_ARBITER, row3_3);
  us : entity work.s port map (clock, reset, enable, row3_3, row3_3, row3_3(7 downto 0), row3_3, ROW3_CPU_ADDR_MUX, row3_4);
  ut : entity work.t port map (clock, reset, enable, row3_4, row3_4, row3_4(7 downto 0), row3_4, ROW3_SYS_ADDR_MUX, row3_5);
  uu : entity work.u port map (clock, reset, enable, row3_5, row3_5, row3_5(7 downto 0), row3_5, ROW3_FINAL_ADDR_MUX, row3_6);
  uv : entity work.v port map (clock, reset, enable, row3_6, row3_6, row3_6(7 downto 0), row3_6, ROW3_LPM_MUX_MEM, row3_7);
  uw : entity work.w port map (clock, reset, enable, row3_7, row3_7, row3_7(7 downto 0), row3_7, ROW3_MEMORY, row3_8);
  ux : entity work.x port map (clock, reset, enable, row3_8, row3_8, row3_8(7 downto 0), row3_8, ROW3_DEBUG, row3_9);

  A2_CONTROL_CHAIN  <= row1_9;
  A2_DATAPATH_CHAIN <= row2_6;
  A2_MEMORY_CHAIN   <= row3_9;
end architecture;



