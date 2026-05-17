library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity lab5_alu_top is
  port (
    opcode_i      : in  std_logic_vector(7 downto 0);
    a_i           : in  word_t;
    b_i           : in  word_t;
    y_o           : out word_t;
    z_o           : out std_logic;
    s_o           : out std_logic;
    c_o           : out std_logic;
    o_o           : out std_logic;
    alu_op_dbg_o  : out std_logic_vector(2 downto 0);
    use_b_dbg_o   : out std_logic;
    wr_flags_dbg_o: out std_logic
  );
end entity;

architecture structural of lab5_alu_top is
  signal alu_op     : std_logic_vector(2 downto 0);
  signal use_b      : std_logic;
  signal write_flags: std_logic;

  signal y_cmp      : word_t;
  signal y_nor      : word_t;
  signal y_sra      : word_t;
  signal y_mux      : word_t;
  signal c_cmp      : std_logic;
  signal o_cmp      : std_logic;
  signal c_sra      : std_logic;
  signal c_mux      : std_logic;
  signal o_mux      : std_logic;
begin
  U_CTRL : entity work.alu_control
    port map (
      opcode_i      => opcode_i,
      alu_op_o      => alu_op,
      use_b_o       => use_b,
      write_flags_o => write_flags
    );

  U_CMP : entity work.alu_cmp
    port map (a_i => a_i, b_i => b_i, y_o => y_cmp, c_o => c_cmp, o_o => o_cmp);

  U_NOR : entity work.alu_nor
    port map (a_i => a_i, b_i => b_i, y_o => y_nor);

  U_SRA : entity work.alu_sra
    port map (a_i => a_i, y_o => y_sra, c_o => c_sra);

  process(a_i, y_cmp, y_nor, y_sra, c_cmp, o_cmp, c_sra, alu_op)
  begin
    y_mux <= a_i;
    c_mux <= '0';
    o_mux <= '0';

    case alu_op is
      when ALU_CMP =>
        y_mux <= y_cmp;
        c_mux <= c_cmp;
        o_mux <= o_cmp;
      when ALU_NOR =>
        y_mux <= y_nor;
      when ALU_SRA =>
        y_mux <= y_sra;
        c_mux <= c_sra;
      when others =>
        null;
    end case;
  end process;

  U_FLAGS : entity work.alu_flags
    port map (
      y_i => y_mux,
      c_i => c_mux,
      o_i => o_mux,
      z_o => z_o,
      s_o => s_o,
      c_o => c_o,
      o_o => o_o
    );

  y_o            <= y_mux;
  alu_op_dbg_o   <= alu_op;
  use_b_dbg_o    <= use_b;
  wr_flags_dbg_o <= write_flags;
end architecture;
