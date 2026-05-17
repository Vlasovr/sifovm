library ieee;
use ieee.std_logic_1164.all;
use work.lab_variant_pkg.all;

entity lab8_cache_rtl_view_top is
  port (
    clock_i                              : in  std_logic;
    reset_i                              : in  std_logic;
    cpu_cache_request_i                  : in  std_logic;
    cpu_write_enable_i                   : in  std_logic;
    cpu_address_tag_set_i                : in  addr_t;
    cpu_write_data_to_cache_i            : in  word_t;
    cpu_read_data_from_cache_o           : out word_t;
    cpu_cache_response_ready_o           : out std_logic;
    cache_hit_signal_o                   : out std_logic;
    cache_miss_signal_o                  : out std_logic;
    memory_request_from_cache_debug_o    : out std_logic;
    memory_write_enable_debug_o          : out std_logic;
    memory_address_debug_o               : out addr_t;
    memory_data_debug_o                  : out word_t
  );
end entity;

architecture structural of lab8_cache_rtl_view_top is
begin
  U_CACHE_SYSTEM : entity work.lab8_cache_top
    port map (
      clk_i          => clock_i,
      rst_i          => reset_i,
      cpu_req_i      => cpu_cache_request_i,
      cpu_we_i       => cpu_write_enable_i,
      cpu_addr_i     => cpu_address_tag_set_i,
      cpu_wdata_i    => cpu_write_data_to_cache_i,
      cpu_rdata_o    => cpu_read_data_from_cache_o,
      cpu_ready_o    => cpu_cache_response_ready_o,
      hit_o          => cache_hit_signal_o,
      miss_o         => cache_miss_signal_o,
      ram_req_dbg_o  => memory_request_from_cache_debug_o,
      ram_we_dbg_o   => memory_write_enable_debug_o,
      ram_addr_dbg_o => memory_address_debug_o,
      ram_data_dbg_o => memory_data_debug_o
    );
end architecture;
