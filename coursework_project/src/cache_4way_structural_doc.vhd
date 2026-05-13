library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

-- Documentation-oriented structural cache model.
-- It is intentionally split into named blocks so Quartus RTL Viewer can draw
-- a readable one-page cache structure instead of a 75-page primitive netlist.

entity cache_data_way_doc is
  port (
    clk_i   : in  std_logic;
    set_i   : in  std_logic_vector(3 downto 0);
    we_i    : in  std_logic;
    data_i  : in  word_t;
    data_o  : out word_t
  );
end entity;

architecture rtl of cache_data_way_doc is
  type data_mem_t is array (0 to CACHE_SETS-1) of word_t;
  signal mem_r : data_mem_t := (others => (others => '0'));
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if we_i = '1' then
        mem_r(to_integer(unsigned(set_i))) <= data_i;
      end if;
    end if;
  end process;

  data_o <= mem_r(to_integer(unsigned(set_i)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_tag_way_doc is
  port (
    clk_i   : in  std_logic;
    set_i   : in  std_logic_vector(3 downto 0);
    we_i    : in  std_logic;
    tag_i   : in  std_logic_vector(11 downto 0);
    tag_o   : out std_logic_vector(11 downto 0)
  );
end entity;

architecture rtl of cache_tag_way_doc is
  type tag_mem_t is array (0 to CACHE_SETS-1) of std_logic_vector(11 downto 0);
  signal mem_r : tag_mem_t := (others => (others => '0'));
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if we_i = '1' then
        mem_r(to_integer(unsigned(set_i))) <= tag_i;
      end if;
    end if;
  end process;

  tag_o <= mem_r(to_integer(unsigned(set_i)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_valid_way_doc is
  port (
    clk_i    : in  std_logic;
    rst_i    : in  std_logic;
    set_i    : in  std_logic_vector(3 downto 0);
    we_i     : in  std_logic;
    valid_i  : in  std_logic;
    valid_o  : out std_logic
  );
end entity;

architecture rtl of cache_valid_way_doc is
  type valid_mem_t is array (0 to CACHE_SETS-1) of std_logic;
  signal mem_r : valid_mem_t := (others => '0');
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        mem_r <= (others => '0');
      elsif we_i = '1' then
        mem_r(to_integer(unsigned(set_i))) <= valid_i;
      end if;
    end if;
  end process;

  valid_o <= mem_r(to_integer(unsigned(set_i)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_age_way_doc is
  port (
    clk_i   : in  std_logic;
    rst_i   : in  std_logic;
    set_i   : in  std_logic_vector(3 downto 0);
    we_i    : in  std_logic;
    inc_i   : in  std_logic;
    age_i   : in  unsigned(1 downto 0);
    age_o   : out unsigned(1 downto 0)
  );
end entity;

architecture rtl of cache_age_way_doc is
  type age_mem_t is array (0 to CACHE_SETS-1) of unsigned(1 downto 0);
  signal mem_r : age_mem_t := (others => (others => '0'));
begin
  process(clk_i)
    variable idx_v : integer range 0 to CACHE_SETS-1;
  begin
    if rising_edge(clk_i) then
      idx_v := to_integer(unsigned(set_i));
      if rst_i = '1' then
        mem_r <= (others => (others => '0'));
      elsif we_i = '1' then
        mem_r(idx_v) <= age_i;
      elsif inc_i = '1' then
        mem_r(idx_v) <= sat_inc2(mem_r(idx_v));
      end if;
    end if;
  end process;

  age_o <= mem_r(to_integer(unsigned(set_i)));
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_tag_compare_doc is
  port (
    req_tag_i  : in  std_logic_vector(11 downto 0);
    way_tag_i  : in  std_logic_vector(11 downto 0);
    equal_o    : out std_logic
  );
end entity;

architecture rtl of cache_tag_compare_doc is
begin
  equal_o <= '1' when way_tag_i = req_tag_i else '0';
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_hit_miss_logic_doc is
  port (
    tag_equal0_i : in  std_logic;
    tag_equal1_i : in  std_logic;
    tag_equal2_i : in  std_logic;
    tag_equal3_i : in  std_logic;
    valid0_i     : in  std_logic;
    valid1_i     : in  std_logic;
    valid2_i     : in  std_logic;
    valid3_i     : in  std_logic;
    way_hit_o    : out std_logic_vector(3 downto 0);
    hit_o        : out std_logic;
    miss_o       : out std_logic
  );
end entity;

architecture rtl of cache_hit_miss_logic_doc is
  signal way_hit_s : std_logic_vector(3 downto 0);
  signal hit_s     : std_logic;
begin
  -- These four ANDs plus OR/NOT are the useful "primitives" to show in the report.
  way_hit_s(0) <= tag_equal0_i and valid0_i;
  way_hit_s(1) <= tag_equal1_i and valid1_i;
  way_hit_s(2) <= tag_equal2_i and valid2_i;
  way_hit_s(3) <= tag_equal3_i and valid3_i;
  hit_s        <= way_hit_s(0) or way_hit_s(1) or way_hit_s(2) or way_hit_s(3);

  way_hit_o <= way_hit_s;
  hit_o     <= hit_s;
  miss_o    <= not hit_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_hit_mux_doc is
  port (
    hit0_i   : in  std_logic;
    hit1_i   : in  std_logic;
    hit2_i   : in  std_logic;
    hit3_i   : in  std_logic;
    data0_i  : in  word_t;
    data1_i  : in  word_t;
    data2_i  : in  word_t;
    data3_i  : in  word_t;
    hit_way_o: out std_logic_vector(1 downto 0);
    data_o   : out word_t
  );
end entity;

architecture rtl of cache_hit_mux_doc is
begin
  process(hit0_i, hit1_i, hit2_i, hit3_i, data0_i, data1_i, data2_i, data3_i)
  begin
    if hit0_i = '1' then
      data_o    <= data0_i;
      hit_way_o <= "00";
    elsif hit1_i = '1' then
      data_o    <= data1_i;
      hit_way_o <= "01";
    elsif hit2_i = '1' then
      data_o    <= data2_i;
      hit_way_o <= "10";
    else
      data_o    <= data3_i;
      hit_way_o <= "11";
    end if;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_address_split_doc is
  port (
    cpu_addr_i : in  addr_t;
    tag_o      : out std_logic_vector(11 downto 0);
    set_o      : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of cache_address_split_doc is
begin
  tag_o <= cpu_addr_i(15 downto 4);
  set_o <= cpu_addr_i(3 downto 0);
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_victim_select_doc is
  port (
    valid0_i  : in  std_logic;
    valid1_i  : in  std_logic;
    valid2_i  : in  std_logic;
    valid3_i  : in  std_logic;
    age0_i    : in  unsigned(1 downto 0);
    age1_i    : in  unsigned(1 downto 0);
    age2_i    : in  unsigned(1 downto 0);
    age3_i    : in  unsigned(1 downto 0);
    victim_o  : out std_logic_vector(1 downto 0);
    onehot_o  : out std_logic_vector(3 downto 0)
  );
end entity;

architecture rtl of cache_victim_select_doc is
begin
  process(valid0_i, valid1_i, valid2_i, valid3_i, age0_i, age1_i, age2_i, age3_i)
  begin
    if valid0_i = '0' then
      victim_o <= "00";
      onehot_o <= "0001";
    elsif valid1_i = '0' then
      victim_o <= "01";
      onehot_o <= "0010";
    elsif valid2_i = '0' then
      victim_o <= "10";
      onehot_o <= "0100";
    elsif valid3_i = '0' then
      victim_o <= "11";
      onehot_o <= "1000";
    elsif age1_i >= age0_i and age1_i >= age2_i and age1_i >= age3_i then
      victim_o <= "01";
      onehot_o <= "0010";
    elsif age2_i >= age0_i and age2_i >= age1_i and age2_i >= age3_i then
      victim_o <= "10";
      onehot_o <= "0100";
    elsif age3_i >= age0_i and age3_i >= age1_i and age3_i >= age2_i then
      victim_o <= "11";
      onehot_o <= "1000";
    else
      victim_o <= "00";
      onehot_o <= "0001";
    end if;
  end process;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_control_doc is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    cpu_req_i   : in  std_logic;
    cpu_we_i    : in  std_logic;
    hit_i       : in  std_logic;
    hit_way_i   : in  std_logic_vector(1 downto 0);
    victim_i    : in  std_logic_vector(1 downto 0);
    victim_oh_i : in  std_logic_vector(3 downto 0);
    ram_grant_i : in  std_logic;
    way_we_o    : out std_logic_vector(3 downto 0);
    age_inc_o   : out std_logic_vector(3 downto 0);
    ram_req_o   : out std_logic;
    ram_we_o    : out std_logic;
    fill_sel_o  : out std_logic;
    cpu_ready_o : out std_logic
  );
end entity;

architecture rtl of cache_control_doc is
  type state_t is (IDLE, HIT_READ, MISS_READ_REQ, MISS_FILL, WRITE_THROUGH);
  signal state_r : state_t := IDLE;
begin
  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        state_r <= IDLE;
      else
        case state_r is
          when IDLE =>
            if cpu_req_i = '1' and cpu_we_i = '0' and hit_i = '1' then
              state_r <= HIT_READ;
            elsif cpu_req_i = '1' and cpu_we_i = '0' then
              state_r <= MISS_READ_REQ;
            elsif cpu_req_i = '1' and cpu_we_i = '1' then
              state_r <= WRITE_THROUGH;
            else
              state_r <= IDLE;
            end if;
          when HIT_READ =>
            state_r <= IDLE;
          when MISS_READ_REQ =>
            if ram_grant_i = '1' then
              state_r <= MISS_FILL;
            end if;
          when MISS_FILL =>
            state_r <= IDLE;
          when WRITE_THROUGH =>
            if ram_grant_i = '1' then
              state_r <= IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;

  ram_req_o   <= '1' when state_r = MISS_READ_REQ or state_r = WRITE_THROUGH else '0';
  ram_we_o    <= '1' when state_r = WRITE_THROUGH else '0';
  fill_sel_o  <= '1' when state_r = MISS_FILL else '0';
  cpu_ready_o <= '1' when state_r = HIT_READ or state_r = MISS_FILL or (state_r = WRITE_THROUGH and ram_grant_i = '1') else '0';

  way_we_o <= victim_oh_i when state_r = MISS_FILL else
              "0001" when state_r = WRITE_THROUGH and hit_i = '1' and hit_way_i = "00" else
              "0010" when state_r = WRITE_THROUGH and hit_i = '1' and hit_way_i = "01" else
              "0100" when state_r = WRITE_THROUGH and hit_i = '1' and hit_way_i = "10" else
              "1000" when state_r = WRITE_THROUGH and hit_i = '1' and hit_way_i = "11" else
              victim_oh_i when state_r = WRITE_THROUGH else
              "0000";

  age_inc_o <= not victim_oh_i when state_r = MISS_FILL else "0000";
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_ram_interface_doc is
  port (
    cpu_addr_i   : in  addr_t;
    cpu_wdata_i  : in  word_t;
    cpu_we_i     : in  std_logic;
    ram_req_i    : in  std_logic;
    ram_we_i     : in  std_logic;
    ram_req_o    : out std_logic;
    ram_we_o     : out std_logic;
    ram_addr_o   : out addr_t;
    ram_wdata_o  : out word_t
  );
end entity;

architecture rtl of cache_ram_interface_doc is
begin
  ram_req_o   <= ram_req_i;
  ram_we_o    <= ram_we_i and cpu_we_i;
  ram_addr_o  <= cpu_addr_i;
  ram_wdata_o <= cpu_wdata_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_4way_structural_doc is
  port (
    clk_i        : in  std_logic;
    rst_i        : in  std_logic;
    cpu_req_i    : in  std_logic;
    cpu_we_i     : in  std_logic;
    cpu_addr_i   : in  addr_t;
    cpu_wdata_i  : in  word_t;
    cpu_rdata_o  : out word_t;
    cpu_ready_o  : out std_logic;
    hit_o        : out std_logic;
    miss_o       : out std_logic;
    ram_req_o    : out std_logic;
    ram_we_o     : out std_logic;
    ram_addr_o   : out addr_t;
    ram_wdata_o  : out word_t;
    ram_rdata_i  : in  word_t;
    ram_grant_i  : in  std_logic
  );
end entity;

architecture structural of cache_4way_structural_doc is
  signal set_s       : std_logic_vector(3 downto 0);
  signal tag_s       : std_logic_vector(11 downto 0);
  signal data_in_s   : word_t;

  signal data0_s     : word_t;
  signal data1_s     : word_t;
  signal data2_s     : word_t;
  signal data3_s     : word_t;
  signal tag0_s      : std_logic_vector(11 downto 0);
  signal tag1_s      : std_logic_vector(11 downto 0);
  signal tag2_s      : std_logic_vector(11 downto 0);
  signal tag3_s      : std_logic_vector(11 downto 0);
  signal valid0_s    : std_logic;
  signal valid1_s    : std_logic;
  signal valid2_s    : std_logic;
  signal valid3_s    : std_logic;
  signal age0_s      : unsigned(1 downto 0);
  signal age1_s      : unsigned(1 downto 0);
  signal age2_s      : unsigned(1 downto 0);
  signal age3_s      : unsigned(1 downto 0);

  signal tag_equal0_s: std_logic;
  signal tag_equal1_s: std_logic;
  signal tag_equal2_s: std_logic;
  signal tag_equal3_s: std_logic;
  signal way_hit_s   : std_logic_vector(3 downto 0);
  signal hit_any_s   : std_logic;
  signal miss_s      : std_logic;
  signal hit_way_s   : std_logic_vector(1 downto 0);
  signal victim_s    : std_logic_vector(1 downto 0);
  signal victim_oh_s : std_logic_vector(3 downto 0);
  signal way_we_s    : std_logic_vector(3 downto 0);
  signal age_inc_s   : std_logic_vector(3 downto 0);
  signal fill_sel_s  : std_logic;
  signal ram_req_s   : std_logic;
  signal ram_we_s    : std_logic;
  signal cache_data_s: word_t;
begin
  data_in_s <= ram_rdata_i when fill_sel_s = '1' else cpu_wdata_i;
  hit_o     <= hit_any_s;
  miss_o    <= miss_s;
  cpu_rdata_o <= cache_data_s when hit_any_s = '1' else ram_rdata_i;

  U_ADDRESS_SPLIT_TAG_SET : entity work.cache_address_split_doc
    port map (
      cpu_addr_i => cpu_addr_i,
      tag_o      => tag_s,
      set_o      => set_s
    );

  U_CACHE_CONTROL : entity work.cache_control_doc
    port map (
      clk_i       => clk_i,
      rst_i       => rst_i,
      cpu_req_i   => cpu_req_i,
      cpu_we_i    => cpu_we_i,
      hit_i       => hit_any_s,
      hit_way_i   => hit_way_s,
      victim_i    => victim_s,
      victim_oh_i => victim_oh_s,
      ram_grant_i => ram_grant_i,
      way_we_o    => way_we_s,
      age_inc_o   => age_inc_s,
      ram_req_o   => ram_req_s,
      ram_we_o    => ram_we_s,
      fill_sel_o  => fill_sel_s,
      cpu_ready_o => cpu_ready_o
    );

  U_VICTIM_SELECT : entity work.cache_victim_select_doc
    port map (
      valid0_i => valid0_s,
      valid1_i => valid1_s,
      valid2_i => valid2_s,
      valid3_i => valid3_s,
      age0_i   => age0_s,
      age1_i   => age1_s,
      age2_i   => age2_s,
      age3_i   => age3_s,
      victim_o => victim_s,
      onehot_o => victim_oh_s
    );

  U_RAM_INTERFACE : entity work.cache_ram_interface_doc
    port map (
      cpu_addr_i  => cpu_addr_i,
      cpu_wdata_i => cpu_wdata_i,
      cpu_we_i    => cpu_we_i,
      ram_req_i   => ram_req_s,
      ram_we_i    => ram_we_s,
      ram_req_o   => ram_req_o,
      ram_we_o    => ram_we_o,
      ram_addr_o  => ram_addr_o,
      ram_wdata_o => ram_wdata_o
    );

  U_DATA_MUX : entity work.cache_hit_mux_doc
    port map (
      hit0_i    => way_hit_s(0),
      hit1_i    => way_hit_s(1),
      hit2_i    => way_hit_s(2),
      hit3_i    => way_hit_s(3),
      data0_i   => data0_s,
      data1_i   => data1_s,
      data2_i   => data2_s,
      data3_i   => data3_s,
      hit_way_o => hit_way_s,
      data_o    => cache_data_s
    );

  U_DATA_WAY0 : entity work.cache_data_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(0), data_i => data_in_s, data_o => data0_s);
  U_DATA_WAY1 : entity work.cache_data_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(1), data_i => data_in_s, data_o => data1_s);
  U_DATA_WAY2 : entity work.cache_data_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(2), data_i => data_in_s, data_o => data2_s);
  U_DATA_WAY3 : entity work.cache_data_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(3), data_i => data_in_s, data_o => data3_s);

  U_TAG_WAY0 : entity work.cache_tag_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(0), tag_i => tag_s, tag_o => tag0_s);
  U_TAG_WAY1 : entity work.cache_tag_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(1), tag_i => tag_s, tag_o => tag1_s);
  U_TAG_WAY2 : entity work.cache_tag_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(2), tag_i => tag_s, tag_o => tag2_s);
  U_TAG_WAY3 : entity work.cache_tag_way_doc port map (clk_i => clk_i, set_i => set_s, we_i => way_we_s(3), tag_i => tag_s, tag_o => tag3_s);

  U_VALID_WAY0 : entity work.cache_valid_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(0), valid_i => '1', valid_o => valid0_s);
  U_VALID_WAY1 : entity work.cache_valid_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(1), valid_i => '1', valid_o => valid1_s);
  U_VALID_WAY2 : entity work.cache_valid_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(2), valid_i => '1', valid_o => valid2_s);
  U_VALID_WAY3 : entity work.cache_valid_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(3), valid_i => '1', valid_o => valid3_s);

  U_AGE_WAY0 : entity work.cache_age_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(0), inc_i => age_inc_s(0), age_i => "00", age_o => age0_s);
  U_AGE_WAY1 : entity work.cache_age_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(1), inc_i => age_inc_s(1), age_i => "00", age_o => age1_s);
  U_AGE_WAY2 : entity work.cache_age_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(2), inc_i => age_inc_s(2), age_i => "00", age_o => age2_s);
  U_AGE_WAY3 : entity work.cache_age_way_doc port map (clk_i => clk_i, rst_i => rst_i, set_i => set_s, we_i => way_we_s(3), inc_i => age_inc_s(3), age_i => "00", age_o => age3_s);

  U_TAG_COMPARE0 : entity work.cache_tag_compare_doc port map (req_tag_i => tag_s, way_tag_i => tag0_s, equal_o => tag_equal0_s);
  U_TAG_COMPARE1 : entity work.cache_tag_compare_doc port map (req_tag_i => tag_s, way_tag_i => tag1_s, equal_o => tag_equal1_s);
  U_TAG_COMPARE2 : entity work.cache_tag_compare_doc port map (req_tag_i => tag_s, way_tag_i => tag2_s, equal_o => tag_equal2_s);
  U_TAG_COMPARE3 : entity work.cache_tag_compare_doc port map (req_tag_i => tag_s, way_tag_i => tag3_s, equal_o => tag_equal3_s);

  U_HIT_MISS_LOGIC_AND_OR_NOT : entity work.cache_hit_miss_logic_doc
    port map (
      tag_equal0_i => tag_equal0_s,
      tag_equal1_i => tag_equal1_s,
      tag_equal2_i => tag_equal2_s,
      tag_equal3_i => tag_equal3_s,
      valid0_i     => valid0_s,
      valid1_i     => valid1_s,
      valid2_i     => valid2_s,
      valid3_i     => valid3_s,
      way_hit_o    => way_hit_s,
      hit_o        => hit_any_s,
      miss_o       => miss_s
    );
end architecture;
