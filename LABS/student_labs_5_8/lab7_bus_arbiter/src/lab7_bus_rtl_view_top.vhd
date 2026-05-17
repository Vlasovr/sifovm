library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity lab7_bus_rtl_view_top is
  port (
    clock_i                            : in  std_logic;
    reset_i                            : in  std_logic;
    master_bus_request_lines_o         : out std_logic_vector(3 downto 0);
    arbiter_bus_grant_lines_o          : out std_logic_vector(3 downto 0);
    shared_data_bus_to_slave_o         : out word_t;
    slave_latched_data_from_bus_o      : out word_t;
    slave_data_valid_strobe_o          : out std_logic;
    current_time_quantum_slot_o        : out unsigned(1 downto 0);
    master_was_serviced_debug_o        : out std_logic_vector(3 downto 0)
  );
end entity;

architecture structural of lab7_bus_rtl_view_top is
begin
  U_BUS_SYSTEM : entity work.lab7_bus_top
    port map (
      clk_i         => clock_i,
      rst_i         => reset_i,
      req_o         => master_bus_request_lines_o,
      grant_o       => arbiter_bus_grant_lines_o,
      bus_data_o    => shared_data_bus_to_slave_o,
      slave_data_o  => slave_latched_data_from_bus_o,
      slave_valid_o => slave_data_valid_strobe_o,
      slot_o        => current_time_quantum_slot_o,
      used_o        => master_was_serviced_debug_o
    );
end architecture;
