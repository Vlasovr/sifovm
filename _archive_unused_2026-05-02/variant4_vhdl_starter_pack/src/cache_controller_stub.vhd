library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity cache_controller_stub is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    req_i       : in  std_logic;
    we_i        : in  std_logic;
    addr_i      : in  addr_t;
    wdata_i     : in  word_t;
    rdata_o     : out word_t;
    hit_o       : out std_logic;
    miss_o      : out std_logic;
    ram_req_o   : out std_logic;
    ram_we_o    : out std_logic;
    ram_addr_o  : out addr_t;
    ram_wdata_o : out word_t;
    ram_rdata_i : in  word_t;
    ram_ready_i : in  std_logic
  );
end entity;

architecture rtl of cache_controller_stub is
begin
  -- This is intentionally a starter stub.
  -- Variant 4 requires a 4-way associative cache with 16 sets, one-word lines,
  -- replacement by maximum age and write-through policy.
  -- The simplest incremental workflow is:
  -- 1) keep lookup combinational;
  -- 2) store valid/tag/data/age arrays per set/way;
  -- 3) on hit return cached data immediately;
  -- 4) on miss issue ram_req_o and fill one victim way when ram_ready_i = '1';
  -- 5) on store always mirror the write to RAM (write-through).
  rdata_o     <= ram_rdata_i;
  hit_o       <= '0';
  miss_o      <= req_i;
  ram_req_o   <= req_i;
  ram_we_o    <= we_i;
  ram_addr_o  <= addr_i;
  ram_wdata_o <= wdata_i;
end architecture;
