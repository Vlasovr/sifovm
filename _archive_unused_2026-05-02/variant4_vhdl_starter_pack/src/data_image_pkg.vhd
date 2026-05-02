library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

package data_image_pkg is
  constant RAM_INIT : ram256_t := (
    16#0A# => x"0000",
    16#0B# => x"0000",
    16#0C# => x"0000",
    16#20# => x"8001",
    16#21# => x"00F0",
    16#22# => x"0F0F",
    16#23# => x"0000",
    16#24# => x"1234",
    16#25# => x"FFFF",
    16#30# => x"0000",
    others  => (others => '0')
  );
end package;
