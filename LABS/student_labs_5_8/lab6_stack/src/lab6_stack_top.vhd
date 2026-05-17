library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity lab6_stack_top is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    cmd_i       : in  std_logic_vector(1 downto 0);
    reg_data_i  : in  word_t;
    alu_data_i  : in  word_t;
    stack_out_o : out word_t;
    sp_o        : out unsigned(2 downto 0);
    empty_o     : out std_logic;
    full_o      : out std_logic;
    overflow_o  : out std_logic;
    underflow_o : out std_logic;
    push_dbg_o  : out std_logic;
    pop_dbg_o   : out std_logic
  );
end entity;

architecture structural of lab6_stack_top is
  signal push_s   : std_logic;
  signal pop_s    : std_logic;
  signal alu_src_s: std_logic;
  signal din_s    : word_t;
begin
  U_CTRL : entity work.stack_control
    port map (
      cmd_i     => cmd_i,
      push_o    => push_s,
      pop_o     => pop_s,
      alu_src_o => alu_src_s
    );

  din_s <= alu_data_i when alu_src_s = '1' else reg_data_i;

  U_STACK : entity work.stack7x16
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      push_i      => push_s,
      pop_i       => pop_s,
      din_i       => din_s,
      dout_o      => stack_out_o,
      sp_o        => sp_o,
      empty_o     => empty_o,
      full_o      => full_o,
      overflow_o  => overflow_o,
      underflow_o => underflow_o
    );

  push_dbg_o <= push_s;
  pop_dbg_o  <= pop_s;
end architecture;
