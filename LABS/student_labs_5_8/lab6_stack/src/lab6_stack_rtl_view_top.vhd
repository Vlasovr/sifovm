library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity lab6_stack_rtl_view_top is
  port (
    clock_i                         : in  std_logic;
    reset_i                         : in  std_logic;
    stack_command_idle_push_pop_i   : in  std_logic_vector(1 downto 0);
    data_from_register_file_i       : in  word_t;
    alu_result_for_push_i           : in  word_t;
    data_popped_to_register_file_o  : out word_t;
    stack_pointer_current_value_o   : out unsigned(2 downto 0);
    status_stack_empty_o            : out std_logic;
    status_stack_full_o             : out std_logic;
    error_push_to_full_stack_o      : out std_logic;
    error_pop_from_empty_stack_o    : out std_logic;
    ctrl_push_enable_o              : out std_logic;
    ctrl_pop_enable_o               : out std_logic
  );
end entity;

architecture structural of lab6_stack_rtl_view_top is
begin
  U_STACK_SYSTEM : entity work.lab6_stack_top
    port map (
      clk_i       => clock_i,
      rst_i       => reset_i,
      cmd_i       => stack_command_idle_push_pop_i,
      reg_data_i  => data_from_register_file_i,
      alu_data_i  => alu_result_for_push_i,
      stack_out_o => data_popped_to_register_file_o,
      sp_o        => stack_pointer_current_value_o,
      empty_o     => status_stack_empty_o,
      full_o      => status_stack_full_o,
      overflow_o  => error_push_to_full_stack_o,
      underflow_o => error_pop_from_empty_stack_o,
      push_dbg_o  => ctrl_push_enable_o,
      pop_dbg_o   => ctrl_pop_enable_o
    );
end architecture;
