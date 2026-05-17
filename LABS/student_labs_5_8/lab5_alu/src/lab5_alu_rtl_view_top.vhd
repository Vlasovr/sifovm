library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity lab5_alu_rtl_view_top is
  port (
    cmd_opcode_alu_operation_i       : in  std_logic_vector(7 downto 0);
    operand_a_from_register_i        : in  word_t;
    operand_b_from_memory_or_reg_i   : in  word_t;
    result_y_to_register_file_o      : out word_t;
    flag_z_zero_result_o             : out std_logic;
    flag_s_negative_result_o         : out std_logic;
    flag_c_carry_or_shift_out_o      : out std_logic;
    flag_o_overflow_o                : out std_logic;
    ctrl_selected_alu_operation_o    : out std_logic_vector(2 downto 0);
    ctrl_second_operand_is_used_o    : out std_logic;
    ctrl_write_flags_register_o      : out std_logic
  );
end entity;

architecture structural of lab5_alu_rtl_view_top is
begin
  U_ALU : entity work.lab5_alu_top
    port map (
      opcode_i       => cmd_opcode_alu_operation_i,
      a_i            => operand_a_from_register_i,
      b_i            => operand_b_from_memory_or_reg_i,
      y_o            => result_y_to_register_file_o,
      z_o            => flag_z_zero_result_o,
      s_o            => flag_s_negative_result_o,
      c_o            => flag_c_carry_or_shift_out_o,
      o_o            => flag_o_overflow_o,
      alu_op_dbg_o   => ctrl_selected_alu_operation_o,
      use_b_dbg_o    => ctrl_second_operand_is_used_o,
      wr_flags_dbg_o => ctrl_write_flags_register_o
    );
end architecture;
