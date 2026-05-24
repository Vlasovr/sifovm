library ieee;
use ieee.std_logic_1164.all;

entity arb_doc_input_pin is
  port (
    pin_i : in  std_logic;
    sig_o : out std_logic
  );
end entity;

architecture rtl of arb_doc_input_pin is
begin
  sig_o <= pin_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity arb_doc_not_gate is
  port (
    a_i : in  std_logic;
    y_o : out std_logic
  );
end entity;

architecture rtl of arb_doc_not_gate is
begin
  y_o <= not a_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity arb_doc_and2_gate is
  port (
    a_i : in  std_logic;
    b_i : in  std_logic;
    y_o : out std_logic
  );
end entity;

architecture rtl of arb_doc_and2_gate is
begin
  y_o <= a_i and b_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity arb_doc_or2_gate is
  port (
    a_i : in  std_logic;
    b_i : in  std_logic;
    y_o : out std_logic
  );
end entity;

architecture rtl of arb_doc_or2_gate is
begin
  y_o <= a_i or b_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity arb_doc_output_pin is
  port (
    sig_i : in  std_logic;
    pin_o : out std_logic
  );
end entity;

architecture rtl of arb_doc_output_pin is
begin
  pin_o <= sig_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bus_arbiter_doc_top is
  port (
    req_cpu_i   : in  std_logic;
    req_dma_i   : in  std_logic;
    grant_cpu_o : out std_logic;
    grant_dma_o : out std_logic;
    bus_busy_o  : out std_logic
  );
end entity;

architecture structural of bus_arbiter_doc_top is
  signal req_cpu_s    : std_logic; -- synthesis keep
  signal req_dma_s    : std_logic; -- synthesis keep
  signal not_dma_s    : std_logic; -- synthesis keep
  signal grant_cpu_s  : std_logic; -- synthesis keep
  signal grant_dma_s  : std_logic; -- synthesis keep
  signal bus_busy_s   : std_logic; -- synthesis keep
begin
  U_REQ_CPU_INPUT_PIN : entity work.arb_doc_input_pin
    port map (
      pin_i => req_cpu_i,
      sig_o => req_cpu_s
    );

  U_REQ_DMA_INPUT_PIN : entity work.arb_doc_input_pin
    port map (
      pin_i => req_dma_i,
      sig_o => req_dma_s
    );

  U_INVERT_DMA_REQUEST : entity work.arb_doc_not_gate
    port map (
      a_i => req_dma_s,
      y_o => not_dma_s
    );

  U_CPU_GRANT_AND_NOT_DMA : entity work.arb_doc_and2_gate
    port map (
      a_i => req_cpu_s,
      b_i => not_dma_s,
      y_o => grant_cpu_s
    );

  U_DMA_GRANT_DIRECT : entity work.arb_doc_output_pin
    port map (
      sig_i => req_dma_s,
      pin_o => grant_dma_s
    );

  U_BUS_BUSY_OR_GRANTS : entity work.arb_doc_or2_gate
    port map (
      a_i => grant_cpu_s,
      b_i => grant_dma_s,
      y_o => bus_busy_s
    );

  U_GRANT_CPU_OUTPUT_PIN : entity work.arb_doc_output_pin
    port map (
      sig_i => grant_cpu_s,
      pin_o => grant_cpu_o
    );

  U_GRANT_DMA_OUTPUT_PIN : entity work.arb_doc_output_pin
    port map (
      sig_i => grant_dma_s,
      pin_o => grant_dma_o
    );

  U_BUS_BUSY_OUTPUT_PIN : entity work.arb_doc_output_pin
    port map (
      sig_i => bus_busy_s,
      pin_o => bus_busy_o
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bus_arbiter_doc_exact_top is
  port (
    req_cpu_i   : in  std_logic;
    req_dma_i   : in  std_logic;
    grant_cpu_o : out std_logic;
    grant_dma_o : out std_logic
  );
end entity;

architecture structural of bus_arbiter_doc_exact_top is
  signal req_cpu_s    : std_logic; -- synthesis keep
  signal req_dma_s    : std_logic; -- synthesis keep
  signal not_dma_s    : std_logic; -- synthesis keep
  signal grant_cpu_s  : std_logic; -- synthesis keep
begin
  U_REQ_CPU_INPUT_PIN : entity work.arb_doc_input_pin
    port map (
      pin_i => req_cpu_i,
      sig_o => req_cpu_s
    );

  U_REQ_DMA_INPUT_PIN : entity work.arb_doc_input_pin
    port map (
      pin_i => req_dma_i,
      sig_o => req_dma_s
    );

  U_INVERT_DMA_REQUEST : entity work.arb_doc_not_gate
    port map (
      a_i => req_dma_s,
      y_o => not_dma_s
    );

  U_CPU_GRANT_AND_NOT_DMA : entity work.arb_doc_and2_gate
    port map (
      a_i => req_cpu_s,
      b_i => not_dma_s,
      y_o => grant_cpu_s
    );

  U_GRANT_CPU_OUTPUT_PIN : entity work.arb_doc_output_pin
    port map (
      sig_i => grant_cpu_s,
      pin_o => grant_cpu_o
    );

  U_GRANT_DMA_OUTPUT_PIN : entity work.arb_doc_output_pin
    port map (
      sig_i => req_dma_s,
      pin_o => grant_dma_o
    );
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_inv is
  port (
    a : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_inv is
begin
  y <= not a;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_and is
  port (
    a : in  std_logic;
    b : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_and is
begin
  y <= a and b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity g_or is
  port (
    a : in  std_logic;
    b : in  std_logic;
    y : out std_logic
  );
end entity;

architecture rtl of g_or is
begin
  y <= a or b;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bus_arbiter_doc_compact_top is
  port (
    req_cpu_i   : in  std_logic;
    req_dma_i   : in  std_logic;
    grant_cpu_o : out std_logic;
    grant_dma_o : out std_logic;
    bus_busy_o  : out std_logic
  );
end entity;

architecture structural of bus_arbiter_doc_compact_top is
  signal n_dma_s : std_logic; -- synthesis keep
  signal g_cpu_s : std_logic; -- synthesis keep
  signal g_dma_s : std_logic; -- synthesis keep
  signal busy_s  : std_logic; -- synthesis keep
begin
  U_NDMA : entity work.g_inv
    port map (
      a => req_dma_i,
      y => n_dma_s
    );

  U_CPU : entity work.g_and
    port map (
      a => req_cpu_i,
      b => n_dma_s,
      y => g_cpu_s
    );

  g_dma_s <= req_dma_i;

  U_BUSY : entity work.g_or
    port map (
      a => g_cpu_s,
      b => g_dma_s,
      y => busy_s
    );

  grant_cpu_o <= g_cpu_s;
  grant_dma_o <= g_dma_s;
  bus_busy_o  <= busy_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bus_arbiter_doc_compact_exact_top is
  port (
    req_cpu_i   : in  std_logic;
    req_dma_i   : in  std_logic;
    grant_cpu_o : out std_logic;
    grant_dma_o : out std_logic
  );
end entity;

architecture structural of bus_arbiter_doc_compact_exact_top is
  signal n_dma_s : std_logic; -- synthesis keep
  signal g_cpu_s : std_logic; -- synthesis keep
begin
  U_NDMA : entity work.g_inv
    port map (
      a => req_dma_i,
      y => n_dma_s
    );

  U_CPU : entity work.g_and
    port map (
      a => req_cpu_i,
      b => n_dma_s,
      y => g_cpu_s
    );

  grant_cpu_o <= g_cpu_s;
  grant_dma_o <= req_dma_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity arb2 is
  port (
    req_cpu_i   : in  std_logic;
    req_dma_i   : in  std_logic;
    grant_cpu_o : out std_logic;
    grant_dma_o : out std_logic
  );
end entity;

architecture rtl of arb2 is
  signal n_dma_s : std_logic; -- synthesis keep
begin
  n_dma_s     <= not req_dma_i;
  grant_dma_o <= req_dma_i;
  grant_cpu_o <= req_cpu_i and n_dma_s;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mux1 is
  port (
    sel_i : in  std_logic;
    d0_i  : in  std_logic;
    d1_i  : in  std_logic;
    y_o   : out std_logic
  );
end entity;

architecture rtl of mux1 is
begin
  y_o <= d1_i when sel_i = '1' else d0_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity mux16 is
  port (
    sel_i : in  std_logic;
    d0_i  : in  std_logic_vector(15 downto 0);
    d1_i  : in  std_logic_vector(15 downto 0);
    y_o   : out std_logic_vector(15 downto 0)
  );
end entity;

architecture rtl of mux16 is
begin
  y_o <= d1_i when sel_i = '1' else d0_i;
end architecture;

library ieee;
use ieee.std_logic_1164.all;

entity bus_arbiter_doc_full_top is
  port (
    cpu_req_i    : in  std_logic;
    cpu_we_i     : in  std_logic;
    cpu_addr_i   : in  std_logic_vector(15 downto 0);
    cpu_wdata_i  : in  std_logic_vector(15 downto 0);

    dma_req_i    : in  std_logic;
    dma_we_i     : in  std_logic;
    dma_addr_i   : in  std_logic_vector(15 downto 0);
    dma_wdata_i  : in  std_logic_vector(15 downto 0);

    grant_cpu_o  : out std_logic;
    grant_dma_o  : out std_logic;
    bus_busy_o   : out std_logic;

    ram_en_o     : out std_logic;
    ram_we_o     : out std_logic;
    ram_addr_o   : out std_logic_vector(15 downto 0);
    ram_wdata_o  : out std_logic_vector(15 downto 0)
  );
end entity;

architecture structural of bus_arbiter_doc_full_top is
  signal grant_cpu_s : std_logic; -- synthesis keep
  signal grant_dma_s : std_logic; -- synthesis keep
  signal cpu_en_s    : std_logic; -- synthesis keep
  signal dma_en_s    : std_logic; -- synthesis keep
begin
  U_ARB : entity work.arb2
    port map (
      req_cpu_i   => cpu_req_i,
      req_dma_i   => dma_req_i,
      grant_cpu_o => grant_cpu_s,
      grant_dma_o => grant_dma_s
    );

  U_CPU_EN : entity work.g_and
    port map (
      a => cpu_req_i,
      b => grant_cpu_s,
      y => cpu_en_s
    );

  U_DMA_EN : entity work.g_and
    port map (
      a => dma_we_i,
      b => grant_dma_s,
      y => dma_en_s
    );

  U_RAM_EN : entity work.g_or
    port map (
      a => cpu_en_s,
      b => dma_en_s,
      y => ram_en_o
    );

  U_RAM_WE : entity work.mux1
    port map (
      sel_i => grant_dma_s,
      d0_i  => cpu_we_i,
      d1_i  => dma_we_i,
      y_o   => ram_we_o
    );

  U_RAM_ADDR : entity work.mux16
    port map (
      sel_i => grant_dma_s,
      d0_i  => cpu_addr_i,
      d1_i  => dma_addr_i,
      y_o   => ram_addr_o
    );

  U_RAM_WDATA : entity work.mux16
    port map (
      sel_i => grant_dma_s,
      d0_i  => cpu_wdata_i,
      d1_i  => dma_wdata_i,
      y_o   => ram_wdata_o
    );

  U_BUSY : entity work.g_or
    port map (
      a => grant_cpu_s,
      b => grant_dma_s,
      y => bus_busy_o
    );

  grant_cpu_o <= grant_cpu_s;
  grant_dma_o <= grant_dma_s;
end architecture;
