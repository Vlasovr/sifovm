library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity lab7_bus_top is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    req_o       : out std_logic_vector(3 downto 0);
    grant_o     : out std_logic_vector(3 downto 0);
    bus_data_o  : out word_t;
    slave_data_o: out word_t;
    slave_valid_o: out std_logic;
    slot_o      : out unsigned(1 downto 0);
    used_o      : out std_logic_vector(3 downto 0)
  );
end entity;

architecture structural of lab7_bus_top is
  signal req_s        : std_logic_vector(3 downto 0);
  signal grant_s      : std_logic_vector(3 downto 0);
  signal data0_s      : word_t;
  signal data1_s      : word_t;
  signal data2_s      : word_t;
  signal data3_s      : word_t;
  signal bus_s        : word_t;
  signal busy_s       : std_logic;
  signal tick_s       : std_logic;
begin
  U_MASTER0 : entity work.master_device
    generic map (ID_VALUE => 16#1111#, START_CYCLE => 1, HOLD_CYCLES => 10)
    port map (clk_i => clk_i, rst_i => rst_i, grant_i => grant_s(0), req_o => req_s(0), data_o => data0_s, used_o => used_o(0));

  U_MASTER1 : entity work.master_device
    generic map (ID_VALUE => 16#2222#, START_CYCLE => 2, HOLD_CYCLES => 10)
    port map (clk_i => clk_i, rst_i => rst_i, grant_i => grant_s(1), req_o => req_s(1), data_o => data1_s, used_o => used_o(1));

  U_MASTER2 : entity work.master_device
    generic map (ID_VALUE => 16#3333#, START_CYCLE => 4, HOLD_CYCLES => 10)
    port map (clk_i => clk_i, rst_i => rst_i, grant_i => grant_s(2), req_o => req_s(2), data_o => data2_s, used_o => used_o(2));

  U_MASTER3 : entity work.master_device
    generic map (ID_VALUE => 16#4444#, START_CYCLE => 6, HOLD_CYCLES => 10)
    port map (clk_i => clk_i, rst_i => rst_i, grant_i => grant_s(3), req_o => req_s(3), data_o => data3_s, used_o => used_o(3));

  U_ARBITER : entity work.bus_arbiter_parallel_quantum
    generic map (QUANTUM_CYCLES => 2)
    port map (
      clk_i          => clk_i,
      rst_i          => rst_i,
      req_i          => req_s,
      grant_o        => grant_s,
      slot_o         => slot_o,
      quantum_tick_o => tick_s,
      busy_o         => busy_s
    );

  U_BUS : entity work.bus_mux_4
    port map (
      grant_i => grant_s,
      data0_i => data0_s,
      data1_i => data1_s,
      data2_i => data2_s,
      data3_i => data3_s,
      bus_o   => bus_s
    );

  U_SLAVE : entity work.slave_sync
    port map (
      clk_i    => clk_i,
      rst_i    => rst_i,
      strobe_i => busy_s,
      data_i   => bus_s,
      data_o   => slave_data_o,
      valid_o  => slave_valid_o
    );

  req_o      <= req_s;
  grant_o    <= grant_s;
  bus_data_o <= bus_s;
end architecture;
