library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.lab_variant_pkg.all;

entity tb_lab7_bus is
end entity;

architecture sim of tb_lab7_bus is
  signal clk         : std_logic := '0';
  signal rst         : std_logic := '1';
  signal req         : std_logic_vector(3 downto 0);
  signal grant       : std_logic_vector(3 downto 0);
  signal bus_data    : word_t;
  signal slave_data  : word_t;
  signal slave_valid : std_logic;
  signal slot        : unsigned(1 downto 0);
  signal used        : std_logic_vector(3 downto 0);

  function one_hot_or_zero(v : std_logic_vector(3 downto 0)) return boolean is
    variable cnt : integer := 0;
  begin
    for i in 0 to 3 loop
      if v(i) = '1' then
        cnt := cnt + 1;
      end if;
    end loop;
    return cnt <= 1;
  end function;
begin
  clk <= not clk after 5 ns;

  DUT : entity work.lab7_bus_top
    port map (
      clk_i         => clk,
      rst_i         => rst,
      req_o         => req,
      grant_o       => grant,
      bus_data_o    => bus_data,
      slave_data_o  => slave_data,
      slave_valid_o => slave_valid,
      slot_o        => slot,
      used_o        => used
    );

  stimulus : process
    variable seen : std_logic_vector(3 downto 0) := (others => '0');
  begin
    wait until rising_edge(clk);
    wait until rising_edge(clk);
    rst <= '0';

    for cycle in 0 to 24 loop
      wait until rising_edge(clk);
      wait for 1 ns;
      assert one_hot_or_zero(grant)
        report "Central arbiter must never grant the bus to more than one master" severity failure;

      for i in 0 to 3 loop
        if grant(i) = '1' then
          seen(i) := '1';
          assert req(i) = '1'
            report "Grant may be asserted only for an active request" severity failure;
        end if;
      end loop;
    end loop;

    assert seen = "1111"
      report "Every master must receive the bus during the modeled interval" severity failure;
    assert used = "1111"
      report "Each master must remember at least one successful grant" severity failure;
    assert slave_valid = '0' or slave_data = x"1111" or slave_data = x"2222" or slave_data = x"3333" or slave_data = x"4444"
      report "Slave must latch one of the master data words" severity failure;

    assert false report "tb_lab7_bus: TEST PASSED" severity note;
    wait;
  end process;
end architecture;
