library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package microcomputer_pkg is
  constant DATA_W      : positive := 16;
  constant ADDR_W      : positive := 16;
  constant REG_COUNT   : positive := 12;
  constant STACK_DEPTH : positive := 7;
  constant CACHE_SETS  : positive := 16;
  constant CACHE_WAYS  : positive := 4;

  subtype word_t    is std_logic_vector(DATA_W-1 downto 0);
  subtype addr_t    is std_logic_vector(ADDR_W-1 downto 0);
  subtype reg_idx_t is unsigned(3 downto 0);

  type ram256_t is array (0 to 255) of word_t;

  constant ALU_PASS_A : std_logic_vector(2 downto 0) := "000";
  constant ALU_OR     : std_logic_vector(2 downto 0) := "001";
  constant ALU_NOR    : std_logic_vector(2 downto 0) := "010";
  constant ALU_SRA    : std_logic_vector(2 downto 0) := "011";
  constant ALU_INCS   : std_logic_vector(2 downto 0) := "100";

  constant OP_HLT     : std_logic_vector(7 downto 0) := x"00";
  constant OP_MOV_MR  : std_logic_vector(7 downto 0) := x"01";
  constant OP_MOV_RM  : std_logic_vector(7 downto 0) := x"02";
  constant OP_OR      : std_logic_vector(7 downto 0) := x"03";
  constant OP_NOR     : std_logic_vector(7 downto 0) := x"04";
  constant OP_SRA     : std_logic_vector(7 downto 0) := x"05";
  constant OP_INCS    : std_logic_vector(7 downto 0) := x"06";
  constant OP_PUSH    : std_logic_vector(7 downto 0) := x"07";
  constant OP_POP     : std_logic_vector(7 downto 0) := x"08";
  constant OP_JMP     : std_logic_vector(7 downto 0) := x"09";
  constant OP_JZ      : std_logic_vector(7 downto 0) := x"0A";

  function sat_inc2(v : unsigned(1 downto 0)) return unsigned;
end package;

package body microcomputer_pkg is
  function sat_inc2(v : unsigned(1 downto 0)) return unsigned is
  begin
    if v = "11" then
      return v;
    else
      return v + 1;
    end if;
  end function;
end package body;
