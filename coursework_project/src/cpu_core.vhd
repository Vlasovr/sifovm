library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cpu_core is
  port (
    clk_i          : in  std_logic;
    rst_i          : in  std_logic;

    rom_addr_o     : out addr_t;
    rom_en_o       : out std_logic;
    rom_data_i     : in  word_t;

    cache_req_o    : out std_logic;
    cache_we_o     : out std_logic;
    cache_addr_o   : out addr_t;
    cache_wdata_o  : out word_t;
    cache_rdata_i  : in  word_t;
    cache_ready_i  : in  std_logic;
    cache_hit_i    : in  std_logic;
    cache_miss_i   : in  std_logic;

    bp_query_o     : out std_logic;
    bp_pc_query_o  : out addr_t;
    bp_hist_i      : in  std_logic_vector(1 downto 0);
    bp_pred_i      : in  std_logic;
    bp_target_i    : in  addr_t;
    bp_update_o    : out std_logic;
    bp_pc_update_o : out addr_t;
    bp_hist_o      : out std_logic_vector(1 downto 0);
    bp_taken_o     : out std_logic;
    bp_target_o    : out addr_t;

    halt_o         : out std_logic;

    dbg_state_o    : out std_logic_vector(4 downto 0);
    dbg_pc_o       : out addr_t;
    dbg_ir0_o      : out word_t;
    dbg_ir1_o      : out word_t;
    dbg_r1_o       : out word_t;
    dbg_r2_o       : out word_t;
    dbg_r3_o       : out word_t;
    dbg_r4_o       : out word_t;
    dbg_r5_o       : out word_t;
    dbg_r6_o       : out word_t;
    dbg_r7_o       : out word_t;
    dbg_flags_o    : out std_logic_vector(3 downto 0);
    dbg_sp_o       : out unsigned(2 downto 0)
  );
end entity;

architecture rtl of cpu_core is
  subtype state_code_t is std_logic_vector(4 downto 0);
  type state_t is (
    S_RESET,
    S_FETCH0_REQ,
    S_FETCH0_WAIT,
    S_FETCH0_LATCH,
    S_FETCH1_REQ,
    S_FETCH1_WAIT,
    S_FETCH1_LATCH,
    S_DECODE,
    S_CACHE_READ,
    S_CACHE_WRITE,
    S_ALU_SETUP_REG,
    S_ALU_WRITE,
    S_RF_WRITE_MEM,
    S_STACK_PUSH,
    S_STACK_POP,
    S_RF_WRITE_POP,
    S_BRANCH_JMP,
    S_BRANCH_JZ,
    S_FINISH,
    S_HALT
  );

  signal state_r       : state_t := S_RESET;
  signal pc_r          : addr_t := (others => '0');
  signal ir0_r         : word_t := (others => '0');
  signal ir1_r         : word_t := (others => '0');
  signal cur_reg_r     : reg_idx_t := (others => '0');
  signal cur_opcode_r  : std_logic_vector(7 downto 0) := OP_HLT;

  signal rom_addr_r    : addr_t := (others => '0');
  signal rom_en_r      : std_logic := '0';

  signal rf_we         : std_logic;
  signal rf_wr_addr    : reg_idx_t;
  signal rf_rd_a       : reg_idx_t;
  signal rf_rd_b       : reg_idx_t;
  signal rf_din        : word_t;
  signal rf_a          : word_t;
  signal rf_b          : word_t;

  signal alu_a_r       : word_t := (others => '0');
  signal alu_b_r       : word_t := (others => '0');
  signal alu_op_r      : std_logic_vector(2 downto 0) := ALU_PASS_A;
  signal alu_y         : word_t;
  signal alu_z         : std_logic;
  signal alu_s         : std_logic;
  signal alu_c         : std_logic;
  signal alu_o         : std_logic;

  signal flag_we       : std_logic;
  signal flag_z        : std_logic;
  signal flag_s        : std_logic;
  signal flag_c        : std_logic;
  signal flag_o        : std_logic;

  signal stack_push    : std_logic;
  signal stack_pop     : std_logic;
  signal stack_dout    : word_t;
  signal stack_sp      : unsigned(2 downto 0);
  signal stack_empty   : std_logic;
  signal stack_full    : std_logic;

  signal r1_dbg        : word_t;
  signal r2_dbg        : word_t;
  signal r3_dbg        : word_t;
  signal r4_dbg        : word_t;
  signal r5_dbg        : word_t;
  signal r6_dbg        : word_t;
  signal r7_dbg        : word_t;

  function state_code(s : state_t) return state_code_t is
  begin
    case s is
      when S_RESET        => return "00000";
      when S_FETCH0_REQ   => return "00001";
      when S_FETCH0_WAIT  => return "00010";
      when S_FETCH0_LATCH => return "00011";
      when S_FETCH1_REQ   => return "00100";
      when S_FETCH1_WAIT  => return "00101";
      when S_FETCH1_LATCH => return "00110";
      when S_DECODE       => return "00111";
      when S_CACHE_READ   => return "01000";
      when S_CACHE_WRITE  => return "01001";
      when S_ALU_SETUP_REG=> return "01010";
      when S_ALU_WRITE    => return "01011";
      when S_RF_WRITE_MEM => return "01100";
      when S_STACK_PUSH   => return "01101";
      when S_STACK_POP    => return "01110";
      when S_RF_WRITE_POP => return "01111";
      when S_BRANCH_JMP   => return "10000";
      when S_BRANCH_JZ    => return "10001";
      when S_FINISH       => return "10010";
      when S_HALT         => return "11111";
    end case;
  end function;
begin
  rom_addr_o <= rom_addr_r;
  rom_en_o   <= rom_en_r;

  rf_wr_addr <= cur_reg_r;
  rf_rd_a    <= cur_reg_r;
  rf_rd_b    <= (others => '0');
  rf_we      <= '1' when state_r = S_ALU_WRITE or state_r = S_RF_WRITE_MEM or state_r = S_RF_WRITE_POP else '0';
  rf_din     <= alu_y when state_r = S_ALU_WRITE else
                cache_rdata_i when state_r = S_RF_WRITE_MEM else
                stack_dout;

  flag_we <= '1' when state_r = S_ALU_WRITE else '0';

  stack_push <= '1' when state_r = S_STACK_PUSH else '0';
  stack_pop  <= '1' when state_r = S_STACK_POP else '0';

  cache_req_o   <= '1' when state_r = S_CACHE_READ or state_r = S_CACHE_WRITE else '0';
  cache_we_o    <= '1' when state_r = S_CACHE_WRITE else '0';
  cache_addr_o  <= ir1_r;
  cache_wdata_o <= rf_a;

  bp_query_o     <= '1' when state_r = S_FETCH0_REQ else '0';
  bp_pc_query_o  <= pc_r;
  bp_update_o    <= '1' when state_r = S_BRANCH_JZ else '0';
  bp_pc_update_o <= pc_r;
  bp_hist_o      <= bp_hist_i;
  bp_taken_o     <= flag_z;
  bp_target_o    <= ir1_r;

  halt_o      <= '1' when state_r = S_HALT else '0';
  dbg_state_o <= state_code(state_r);
  dbg_pc_o    <= pc_r;
  dbg_ir0_o   <= ir0_r;
  dbg_ir1_o   <= ir1_r;
  dbg_r1_o    <= r1_dbg;
  dbg_r2_o    <= r2_dbg;
  dbg_r3_o    <= r3_dbg;
  dbg_r4_o    <= r4_dbg;
  dbg_r5_o    <= r5_dbg;
  dbg_r6_o    <= r6_dbg;
  dbg_r7_o    <= r7_dbg;
  dbg_flags_o <= flag_z & flag_s & flag_c & flag_o;
  dbg_sp_o    <= stack_sp;

  U_RF : entity work.reg_file12x16_dbg
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      we_i        => rf_we,
      wr_addr_i   => rf_wr_addr,
      rd_addr_a_i => rf_rd_a,
      rd_addr_b_i => rf_rd_b,
      din_i       => rf_din,
      dout_a_o    => rf_a,
      dout_b_o    => rf_b,
      r0_o        => open,
      r1_o        => r1_dbg,
      r2_o        => r2_dbg,
      r3_o        => r3_dbg,
      r4_o        => r4_dbg,
      r5_o        => r5_dbg,
      r6_o        => r6_dbg,
      r7_o        => r7_dbg,
      r8_o        => open,
      r9_o        => open,
      r10_o       => open,
      r11_o       => open
    );

  U_ALU : entity work.alu_core
    port map (
      a_i      => alu_a_r,
      b_i      => alu_b_r,
      flag_s_i => flag_s,
      op_i     => alu_op_r,
      y_o      => alu_y,
      z_o      => alu_z,
      s_o      => alu_s,
      c_o      => alu_c,
      o_o      => alu_o
    );

  U_FLAGS : entity work.flags_reg
    port map (
      clk_i => clk_i,
      rst_i => rst_i,
      we_i  => flag_we,
      z_i   => alu_z,
      s_i   => alu_s,
      c_i   => alu_c,
      o_i   => alu_o,
      z_o   => flag_z,
      s_o   => flag_s,
      c_o   => flag_c,
      o_o   => flag_o
    );

  U_STACK : entity work.stack7x16
    port map (
      clk_i   => clk_i,
      rst_i   => rst_i,
      push_i  => stack_push,
      pop_i   => stack_pop,
      din_i   => rf_a,
      dout_o  => stack_dout,
      sp_o    => stack_sp,
      empty_o => stack_empty,
      full_o  => stack_full
    );

  process(clk_i)
    variable opcode_v : std_logic_vector(7 downto 0);
    variable next_pc  : unsigned(15 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        state_r      <= S_RESET;
        pc_r         <= (others => '0');
        ir0_r        <= (others => '0');
        ir1_r        <= (others => '0');
        cur_reg_r    <= (others => '0');
        cur_opcode_r <= OP_HLT;
        rom_addr_r   <= (others => '0');
        rom_en_r     <= '0';
        alu_a_r      <= (others => '0');
        alu_b_r      <= (others => '0');
        alu_op_r     <= ALU_PASS_A;
      else
        rom_en_r <= '1';
        next_pc := unsigned(pc_r) + 2;

        case state_r is
          when S_RESET =>
            pc_r       <= (others => '0');
            rom_addr_r <= (others => '0');
            state_r    <= S_FETCH0_REQ;

          when S_FETCH0_REQ =>
            rom_addr_r <= pc_r;
            state_r    <= S_FETCH0_WAIT;

          when S_FETCH0_WAIT =>
            state_r <= S_FETCH0_LATCH;

          when S_FETCH0_LATCH =>
            ir0_r      <= rom_data_i;
            rom_addr_r <= std_logic_vector(unsigned(pc_r) + 1);
            state_r    <= S_FETCH1_REQ;

          when S_FETCH1_REQ =>
            state_r <= S_FETCH1_WAIT;

          when S_FETCH1_WAIT =>
            state_r <= S_FETCH1_LATCH;

          when S_FETCH1_LATCH =>
            ir1_r   <= rom_data_i;
            state_r <= S_DECODE;

          when S_DECODE =>
            opcode_v     := ir0_r(15 downto 8);
            cur_opcode_r <= opcode_v;
            cur_reg_r    <= unsigned(ir0_r(7 downto 4));
            if opcode_v = OP_MOV_MR or opcode_v = OP_OR or opcode_v = OP_NOR then
              state_r <= S_CACHE_READ;
            elsif opcode_v = OP_MOV_RM then
              state_r <= S_CACHE_WRITE;
            elsif opcode_v = OP_SRA or opcode_v = OP_INCS then
              state_r <= S_ALU_SETUP_REG;
            elsif opcode_v = OP_PUSH then
              state_r <= S_STACK_PUSH;
            elsif opcode_v = OP_POP then
              state_r <= S_STACK_POP;
            elsif opcode_v = OP_JMP then
              state_r <= S_BRANCH_JMP;
            elsif opcode_v = OP_JZ then
              state_r <= S_BRANCH_JZ;
            elsif opcode_v = OP_HLT then
              state_r <= S_HALT;
            else
              state_r <= S_HALT;
            end if;

          when S_CACHE_READ =>
            if cache_ready_i = '1' then
              if cur_opcode_r = OP_MOV_MR then
                state_r <= S_RF_WRITE_MEM;
              else
                alu_a_r <= rf_a;
                alu_b_r <= cache_rdata_i;
                if cur_opcode_r = OP_OR then
                  alu_op_r <= ALU_OR;
                else
                  alu_op_r <= ALU_NOR;
                end if;
                state_r <= S_ALU_WRITE;
              end if;
            end if;

          when S_CACHE_WRITE =>
            if cache_ready_i = '1' then
              state_r <= S_FINISH;
            end if;

          when S_ALU_SETUP_REG =>
            alu_a_r <= rf_a;
            alu_b_r <= (others => '0');
            if cur_opcode_r = OP_SRA then
              alu_op_r <= ALU_SRA;
            else
              alu_op_r <= ALU_INCS;
            end if;
            state_r <= S_ALU_WRITE;

          when S_ALU_WRITE =>
            state_r <= S_FINISH;

          when S_RF_WRITE_MEM =>
            state_r <= S_FINISH;

          when S_STACK_PUSH =>
            state_r <= S_FINISH;

          when S_STACK_POP =>
            state_r <= S_RF_WRITE_POP;

          when S_RF_WRITE_POP =>
            state_r <= S_FINISH;

          when S_BRANCH_JMP =>
            pc_r    <= ir1_r;
            state_r <= S_FETCH0_REQ;

          when S_BRANCH_JZ =>
            if flag_z = '1' then
              pc_r <= ir1_r;
            else
              pc_r <= std_logic_vector(next_pc);
            end if;
            state_r <= S_FETCH0_REQ;

          when S_FINISH =>
            pc_r    <= std_logic_vector(next_pc);
            state_r <= S_FETCH0_REQ;

          when S_HALT =>
            state_r <= S_HALT;
        end case;
      end if;
    end if;
  end process;

end architecture;
