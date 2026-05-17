library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package lab_variant_pkg is
  constant DATA_W      : positive := 16;
  constant ADDR_W      : positive := 16;
  constant REG_COUNT   : positive := 12;
  constant STACK_DEPTH : positive := 7;
  constant CACHE_SETS  : positive := 8;
  constant CACHE_WAYS  : positive := 1;

  subtype word_t is std_logic_vector(DATA_W - 1 downto 0);
  subtype addr_t is std_logic_vector(ADDR_W - 1 downto 0);

  constant OP_HLT     : std_logic_vector(7 downto 0) := x"00";
  constant OP_MOV_MR  : std_logic_vector(7 downto 0) := x"01";
  constant OP_MOV_RM  : std_logic_vector(7 downto 0) := x"02";
  constant OP_CMP     : std_logic_vector(7 downto 0) := x"03";
  constant OP_NOR     : std_logic_vector(7 downto 0) := x"04";
  constant OP_SRA     : std_logic_vector(7 downto 0) := x"05";
  constant OP_PUSH    : std_logic_vector(7 downto 0) := x"07";
  constant OP_POP     : std_logic_vector(7 downto 0) := x"08";

  constant ALU_PASS_A : std_logic_vector(2 downto 0) := "000";
  constant ALU_CMP    : std_logic_vector(2 downto 0) := "001";
  constant ALU_NOR    : std_logic_vector(2 downto 0) := "010";
  constant ALU_SRA    : std_logic_vector(2 downto 0) := "011";

  constant STACK_IDLE     : std_logic_vector(1 downto 0) := "00";
  constant STACK_PUSH_REG : std_logic_vector(1 downto 0) := "01";
  constant STACK_POP_REG  : std_logic_vector(1 downto 0) := "10";
  constant STACK_PUSH_ALU : std_logic_vector(1 downto 0) := "11";
end package;

package body lab_variant_pkg is
end package body;
