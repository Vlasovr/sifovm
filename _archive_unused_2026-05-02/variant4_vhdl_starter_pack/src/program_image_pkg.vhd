library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

package program_image_pkg is
  constant ROM_INIT : ram256_t := (
    16#00# => x"0110", -- MOV 0020h, R1
    16#01# => x"0020",
    16#02# => x"0510", -- SRA R1
    16#03# => x"0000",
    16#04# => x"0610", -- INCS R1
    16#05# => x"0000",
    16#06# => x"0710", -- PUSH R1
    16#07# => x"0000",
    16#08# => x"0120", -- MOV 0021h, R2
    16#09# => x"0021",
    16#0A# => x"0320", -- OR R2, 0022h
    16#0B# => x"0022",
    16#0C# => x"0420", -- NOR R2, 0023h
    16#0D# => x"0023",
    16#0E# => x"0830", -- POP R3
    16#0F# => x"0000",
    16#10# => x"0230", -- MOV R3, 0030h
    16#11# => x"0030",
    16#12# => x"0140", -- MOV 0025h, R4
    16#13# => x"0025",
    16#14# => x"0440", -- NOR R4, 0025h
    16#15# => x"0025",
    16#16# => x"0A00", -- JZ 001Ah
    16#17# => x"001A",
    16#18# => x"0150", -- MOV 0024h, R5 (must be skipped)
    16#19# => x"0024",
    16#1A# => x"0900", -- JMP 001Eh
    16#1B# => x"001E",
    16#1C# => x"0160", -- MOV 0024h, R6 (must be skipped)
    16#1D# => x"0024",
    16#1E# => x"0170", -- MOV 000Ah, R7
    16#1F# => x"000A",
    16#20# => x"0000", -- HLT
    16#21# => x"0000",
    others  => (others => '0')
  );
end package;
