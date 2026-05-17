library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity lab8_cache_top is
  port (
    clk_i          : in  std_logic;
    rst_i          : in  std_logic;
    cpu_req_i      : in  std_logic;
    cpu_we_i       : in  std_logic;
    cpu_addr_i     : in  addr_t;
    cpu_wdata_i    : in  word_t;
    cpu_rdata_o    : out word_t;
    cpu_ready_o    : out std_logic;
    hit_o          : out std_logic;
    miss_o         : out std_logic;
    ram_req_dbg_o  : out std_logic;
    ram_we_dbg_o   : out std_logic;
    ram_addr_dbg_o : out addr_t;
    ram_data_dbg_o : out word_t
  );
end entity;

architecture structural of lab8_cache_top is
  signal ram_req_s   : std_logic;
  signal ram_we_s    : std_logic;
  signal ram_addr_s  : addr_t;
  signal ram_wdata_s : word_t;
  signal ram_rdata_s : word_t;
  signal ram_grant_s : std_logic;
begin
  U_CACHE : entity work.cache4way_age
    port map (
      clk_i        => clk_i,
      rst_i        => rst_i,
      cpu_req_i    => cpu_req_i,
      cpu_we_i     => cpu_we_i,
      cpu_addr_i   => cpu_addr_i,
      cpu_wdata_i  => cpu_wdata_i,
      cpu_rdata_o  => cpu_rdata_o,
      cpu_ready_o  => cpu_ready_o,
      hit_o        => hit_o,
      miss_o       => miss_o,
      ram_req_o    => ram_req_s,
      ram_we_o     => ram_we_s,
      ram_addr_o   => ram_addr_s,
      ram_wdata_o  => ram_wdata_s,
      ram_rdata_i  => ram_rdata_s,
      ram_grant_i  => ram_grant_s
    );

  U_RAM : entity work.main_memory_sync
    port map (
      clk_i   => clk_i,
      req_i   => ram_req_s,
      we_i    => ram_we_s,
      addr_i  => ram_addr_s,
      wdata_i => ram_wdata_s,
      rdata_o => ram_rdata_s,
      grant_o => ram_grant_s
    );

  ram_req_dbg_o  <= ram_req_s;
  ram_we_dbg_o   <= ram_we_s;
  ram_addr_dbg_o <= ram_addr_s;
  ram_data_dbg_o <= ram_wdata_s when ram_we_s = '1' else ram_rdata_s;
end architecture;
