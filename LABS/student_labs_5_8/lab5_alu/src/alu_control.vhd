library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity alu_control is
  port (
    opcode_i      : in  std_logic_vector(7 downto 0);
    alu_op_o      : out std_logic_vector(2 downto 0);
    use_b_o       : out std_logic;
    write_flags_o : out std_logic
  );
end entity;

architecture rtl of alu_control is
begin
  process(opcode_i)
  begin
    alu_op_o      <= ALU_PASS_A;
    use_b_o       <= '0';
    write_flags_o <= '0';

    case opcode_i is
      when OP_OR =>
        alu_op_o      <= ALU_OR;
        use_b_o       <= '1';
        write_flags_o <= '1';
      when OP_NOR =>
        alu_op_o      <= ALU_NOR;
        use_b_o       <= '1';
        write_flags_o <= '1';
      when OP_SRA =>
        alu_op_o      <= ALU_SRA;
        write_flags_o <= '1';
      when OP_INCS =>
        alu_op_o      <= ALU_INCS;
        write_flags_o <= '1';
      when others =>
        null;
    end case;
  end process;
end architecture;
