library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity stack_control is
  port (
    cmd_i      : in  std_logic_vector(1 downto 0);
    push_o     : out std_logic;
    pop_o      : out std_logic;
    alu_src_o  : out std_logic
  );
end entity;

architecture rtl of stack_control is
begin
  process(cmd_i)
  begin
    push_o    <= '0';
    pop_o     <= '0';
    alu_src_o <= '0';

    case cmd_i is
      when STACK_PUSH_REG =>
        push_o <= '1';
      when STACK_POP_REG =>
        pop_o <= '1';
      when STACK_PUSH_ALU =>
        push_o    <= '1';
        alu_src_o <= '1';
      when others =>
        null;
    end case;
  end process;
end architecture;
