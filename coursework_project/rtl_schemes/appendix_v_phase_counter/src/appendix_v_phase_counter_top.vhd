library ieee;
use ieee.std_logic_1164.all;

entity Phase_Counter is
  port (
    sclr  : in  std_logic;
    sload : in  std_logic;
    clock : in  std_logic;
    q     : out std_logic_vector(1 downto 0)
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

architecture structural of Phase_Counter is
begin
  TWO_BIT_PHASE_COUNTER : lpm_counter
    generic map (
      lpm_direction   => "UP",
      lpm_modulus     => 4,
      lpm_port_updown => "PORT_UNUSED",
      lpm_type        => "LPM_COUNTER",
      lpm_width       => 2
    )
    port map (
      clock  => clock,
      sclr   => sclr,
      cnt_en => sload,
      data   => "00",
      q      => q,
      cout   => open,
      eq     => open
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity PHASE_FETCH_COMP is
  port (
    phase_data : in  std_logic_vector(1 downto 0);
    is_fetch   : out std_logic
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

architecture structural of PHASE_FETCH_COMP is
  signal FETCH_PHASE_CODE_00 : std_logic_vector(1 downto 0);

  attribute keep : boolean;
  attribute keep of FETCH_PHASE_CODE_00 : signal is true;
begin
  FETCH_EQUALS_00_COMPARE : lpm_compare
    generic map (
      lpm_hint           => "ONE_INPUT_IS_CONSTANT=YES",
      lpm_representation => "UNSIGNED",
      lpm_type           => "LPM_COMPARE",
      lpm_width          => 2
    )
    port map (
      dataa => phase_data,
      datab => FETCH_PHASE_CODE_00,
      aeb   => is_fetch
    );

  FETCH_PHASE_CODE_00 <= "00";
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity PHASE_ADDR_H_COMP is
  port (
    phase_data : in  std_logic_vector(1 downto 0);
    is_addr_h  : out std_logic
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

architecture structural of PHASE_ADDR_H_COMP is
  signal ADDR_H_PHASE_CODE_01 : std_logic_vector(1 downto 0);

  attribute keep : boolean;
  attribute keep of ADDR_H_PHASE_CODE_01 : signal is true;
begin
  ADDR_H_EQUALS_01_COMPARE : lpm_compare
    generic map (
      lpm_hint           => "ONE_INPUT_IS_CONSTANT=YES",
      lpm_representation => "UNSIGNED",
      lpm_type           => "LPM_COMPARE",
      lpm_width          => 2
    )
    port map (
      dataa => phase_data,
      datab => ADDR_H_PHASE_CODE_01,
      aeb   => is_addr_h
    );

  ADDR_H_PHASE_CODE_01 <= "01";
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity PHASE_EXEC_COMP is
  port (
    phase_data : in  std_logic_vector(1 downto 0);
    is_exec    : out std_logic
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

architecture structural of PHASE_EXEC_COMP is
  signal EXEC_PHASE_CODE_10 : std_logic_vector(1 downto 0);

  attribute keep : boolean;
  attribute keep of EXEC_PHASE_CODE_10 : signal is true;
begin
  EXEC_EQUALS_10_COMPARE : lpm_compare
    generic map (
      lpm_hint           => "ONE_INPUT_IS_CONSTANT=YES",
      lpm_representation => "UNSIGNED",
      lpm_type           => "LPM_COMPARE",
      lpm_width          => 2
    )
    port map (
      dataa => phase_data,
      datab => EXEC_PHASE_CODE_10,
      aeb   => is_exec
    );

  EXEC_PHASE_CODE_10 <= "10";
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity PHASE_ADDR_L_COMP is
  port (
    phase_data : in  std_logic_vector(1 downto 0);
    is_addr_l  : out std_logic
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

library lpm;
use lpm.lpm_components.all;

architecture structural of PHASE_ADDR_L_COMP is
  signal ADDR_L_PHASE_CODE_11 : std_logic_vector(1 downto 0);

  attribute keep : boolean;
  attribute keep of ADDR_L_PHASE_CODE_11 : signal is true;
begin
  ADDR_L_EQUALS_11_COMPARE : lpm_compare
    generic map (
      lpm_hint           => "ONE_INPUT_IS_CONSTANT=YES",
      lpm_representation => "UNSIGNED",
      lpm_type           => "LPM_COMPARE",
      lpm_width          => 2
    )
    port map (
      dataa => phase_data,
      datab => ADDR_L_PHASE_CODE_11,
      aeb   => is_addr_l
    );

  ADDR_L_PHASE_CODE_11 <= "11";
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity appendix_v_phase_counter_top is
  port (
    reset     : in  std_logic;
    sload     : in  std_logic;
    clock     : in  std_logic;
    is_fetch  : out std_logic;
    is_addr_h : out std_logic;
    is_exec   : out std_logic;
    is_addr_l : out std_logic
  );
end entity;

library ieee;
use ieee.std_logic_1164.all;

architecture structural of appendix_v_phase_counter_top is
  signal phase_data : std_logic_vector(1 downto 0);

  attribute keep : boolean;
  attribute keep of phase_data : signal is true;
begin
  PHASE_COUNTER_BLOCK : entity work.Phase_Counter
    port map (
      sclr  => reset,
      sload => sload,
      clock => clock,
      q     => phase_data
    );

  FETCH_PHASE_DETECTOR : entity work.PHASE_FETCH_COMP
    port map (
      phase_data => phase_data,
      is_fetch   => is_fetch
    );

  ADDR_H_PHASE_DETECTOR : entity work.PHASE_ADDR_H_COMP
    port map (
      phase_data => phase_data,
      is_addr_h  => is_addr_h
    );

  EXEC_PHASE_DETECTOR : entity work.PHASE_EXEC_COMP
    port map (
      phase_data => phase_data,
      is_exec    => is_exec
    );

  ADDR_L_PHASE_DETECTOR : entity work.PHASE_ADDR_L_COMP
    port map (
      phase_data => phase_data,
      is_addr_l  => is_addr_l
    );
end architecture;
