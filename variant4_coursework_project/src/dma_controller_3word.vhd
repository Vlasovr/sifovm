library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity dma_controller_3word is
  generic (
    BASE_ADDR_G : addr_t := x"000A"
  );
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    start_i     : in  std_logic;
    grant_i     : in  std_logic;
    dev_valid_i : in  std_logic;
    dev_data_i  : in  word_t;
    req_o       : out std_logic;
    busy_o      : out std_logic;
    done_o      : out std_logic;
    ram_we_o    : out std_logic;
    ram_addr_o  : out addr_t;
    ram_data_o  : out word_t
  );
end entity;

architecture rtl of dma_controller_3word is
  type state_t is (IDLE, REQ_BUS, WRITE_WORD, FINISH);
  signal state_r  : state_t := IDLE;
  signal index_r  : unsigned(1 downto 0) := (others => '0');
  signal done_r   : std_logic := '0';
begin
  busy_o     <= '0' when state_r = IDLE else '1';
  req_o      <= '1' when state_r = REQ_BUS or state_r = WRITE_WORD else '0';
  ram_we_o   <= '1' when state_r = WRITE_WORD and grant_i = '1' and dev_valid_i = '1' else '0';
  ram_addr_o <= std_logic_vector(unsigned(BASE_ADDR_G) + resize(index_r, ADDR_W));
  ram_data_o <= dev_data_i;
  done_o     <= done_r;

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        state_r <= IDLE;
        index_r <= (others => '0');
        done_r  <= '0';
      else
        case state_r is
          when IDLE =>
            if start_i = '1' then
              index_r <= (others => '0');
              done_r  <= '0';
              state_r <= REQ_BUS;
            end if;
          when REQ_BUS =>
            if grant_i = '1' then
              state_r <= WRITE_WORD;
            end if;
          when WRITE_WORD =>
            if grant_i = '1' and dev_valid_i = '1' then
              if index_r = "10" then
                state_r <= FINISH;
              else
                index_r <= index_r + 1;
              end if;
            end if;
          when FINISH =>
            done_r  <= '1';
            state_r <= IDLE;
        end case;
      end if;
    end if;
  end process;
end architecture;
