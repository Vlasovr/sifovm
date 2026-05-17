library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity tb_lab6_stack is
end entity;

architecture sim of tb_lab6_stack is
  signal clk       : std_logic := '0';
  signal rst       : std_logic := '1';
  signal cmd       : std_logic_vector(1 downto 0) := STACK_IDLE;
  signal reg_data  : word_t := (others => '0');
  signal alu_data  : word_t := (others => '0');
  signal stack_out : word_t;
  signal sp        : unsigned(2 downto 0);
  signal empty     : std_logic;
  signal full      : std_logic;
  signal overflow  : std_logic;
  signal underflow : std_logic;
  signal push_dbg  : std_logic;
  signal pop_dbg   : std_logic;

  procedure one_cycle(signal clk_s : in std_logic) is
  begin
    wait until rising_edge(clk_s);
    wait for 1 ns;
  end procedure;
begin
  clk <= not clk after 5 ns;

  DUT : entity work.lab6_stack_top
    port map (
      clk_i       => clk,
      rst_i       => rst,
      cmd_i       => cmd,
      reg_data_i  => reg_data,
      alu_data_i  => alu_data,
      stack_out_o => stack_out,
      sp_o        => sp,
      empty_o     => empty,
      full_o      => full,
      overflow_o  => overflow,
      underflow_o => underflow,
      push_dbg_o  => push_dbg,
      pop_dbg_o   => pop_dbg
    );

  stimulus : process
  begin
    one_cycle(clk);
    rst <= '0';
    one_cycle(clk);
    assert sp = to_unsigned(7, 3) and empty = '1' and full = '0'
      report "Reset state must be empty stack with SP=7" severity failure;

    reg_data <= x"1111";
    cmd <= STACK_PUSH_REG;
    one_cycle(clk);
    cmd <= STACK_IDLE;
    assert sp = to_unsigned(0, 3)
      report "SP must point to first occupied cell after first push" severity failure;

    reg_data <= x"2222";
    cmd <= STACK_PUSH_REG;
    one_cycle(clk);
    cmd <= STACK_IDLE;

    cmd <= STACK_POP_REG;
    one_cycle(clk);
    cmd <= STACK_IDLE;
    assert stack_out = x"2222" and sp = to_unsigned(0, 3)
      report "POP must return the last pushed register value" severity failure;

    alu_data <= x"000F";
    cmd <= STACK_PUSH_ALU;
    one_cycle(clk);
    cmd <= STACK_IDLE;
    assert sp = to_unsigned(1, 3)
      report "ALU result push must occupy stack cell" severity failure;

    reg_data <= x"3333"; cmd <= STACK_PUSH_REG; one_cycle(clk);
    reg_data <= x"4444"; cmd <= STACK_PUSH_REG; one_cycle(clk);
    reg_data <= x"5555"; cmd <= STACK_PUSH_REG; one_cycle(clk);
    reg_data <= x"6666"; cmd <= STACK_PUSH_REG; one_cycle(clk);
    reg_data <= x"7777"; cmd <= STACK_PUSH_REG; one_cycle(clk);
    cmd <= STACK_IDLE;
    assert full = '1' and sp = to_unsigned(6, 3)
      report "Seven occupied words must set FULL" severity failure;

    reg_data <= x"8888";
    cmd <= STACK_PUSH_REG;
    one_cycle(clk);
    cmd <= STACK_IDLE;
    assert overflow = '1'
      report "Push into full stack must set overflow flag" severity failure;

    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_POP_REG; one_cycle(clk);
    cmd <= STACK_IDLE;
    assert empty = '1' and sp = to_unsigned(7, 3)
      report "After seven pops stack must be empty" severity failure;

    cmd <= STACK_POP_REG;
    one_cycle(clk);
    cmd <= STACK_IDLE;
    assert underflow = '1'
      report "Pop from empty stack must set underflow flag" severity failure;

    assert false report "tb_lab6_stack: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
