library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.microcomputer_pkg.all;

entity cache_4way_age is
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

architecture rtl of cache_4way_age is
  subtype cache_tag_t is std_logic_vector(11 downto 0);
  type cache_state_t is (IDLE, WAIT_READ_GRANT, WAIT_READ_DATA, WAIT_WRITE_GRANT);
  type set_way_word_t is array (0 to CACHE_SETS-1, 0 to CACHE_WAYS-1) of word_t;
  type set_way_tag_t is array (0 to CACHE_SETS-1, 0 to CACHE_WAYS-1) of cache_tag_t;
  type set_way_age_t is array (0 to CACHE_SETS-1, 0 to CACHE_WAYS-1) of unsigned(1 downto 0);
  type set_way_valid_t is array (0 to CACHE_SETS-1, 0 to CACHE_WAYS-1) of std_logic;

  signal state_r      : cache_state_t := IDLE;
  signal data_r       : set_way_word_t := (others => (others => (others => '0')));
  signal tag_r        : set_way_tag_t := (others => (others => (others => '0')));
  signal age_r        : set_way_age_t := (others => (others => (others => '0')));
  signal valid_r      : set_way_valid_t := (others => (others => '0'));

  signal req_addr_r   : addr_t := (others => '0');
  signal req_wdata_r  : word_t := (others => '0');
  signal req_we_r     : std_logic := '0';
  signal write_hit_r  : std_logic := '0';
  signal victim_r     : integer range 0 to CACHE_WAYS-1 := 0;
  signal set_r        : integer range 0 to CACHE_SETS-1 := 0;
  signal tag_req_r    : cache_tag_t := (others => '0');

  signal cpu_rdata_r  : word_t := (others => '0');
  signal cpu_ready_r  : std_logic := '0';
  signal hit_r        : std_logic := '0';
  signal miss_r       : std_logic := '0';
  signal ram_req_r    : std_logic := '0';
  signal ram_we_r     : std_logic := '0';
  signal ram_addr_r   : addr_t := (others => '0');
  signal ram_wdata_r  : word_t := (others => '0');

  function cache_set(addr : addr_t) return integer is
  begin
    return to_integer(unsigned(addr(3 downto 0)));
  end function;

  function cache_tag(addr : addr_t) return cache_tag_t is
  begin
    return addr(15 downto 4);
  end function;

  function inc_age(v : unsigned(1 downto 0)) return unsigned is
  begin
    if v = "11" then
      return v;
    else
      return v + 1;
    end if;
  end function;
begin
  cpu_rdata_o <= cpu_rdata_r;
  cpu_ready_o <= cpu_ready_r;
  hit_o       <= hit_r;
  miss_o      <= miss_r;
  ram_req_o   <= ram_req_r;
  ram_we_o    <= ram_we_r;
  ram_addr_o  <= ram_addr_r;
  ram_wdata_o <= ram_wdata_r;

  process(clk_i)
    variable set_v    : integer range 0 to CACHE_SETS-1;
    variable hit_v    : boolean;
    variable hit_way  : integer range 0 to CACHE_WAYS-1;
    variable victim_v : integer range 0 to CACHE_WAYS-1;
    variable tag_v    : std_logic_vector(11 downto 0);
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        state_r     <= IDLE;
        data_r      <= (others => (others => (others => '0')));
        tag_r       <= (others => (others => (others => '0')));
        age_r       <= (others => (others => (others => '0')));
        valid_r     <= (others => (others => '0'));
        req_addr_r  <= (others => '0');
        req_wdata_r <= (others => '0');
        req_we_r    <= '0';
        write_hit_r <= '0';
        victim_r    <= 0;
        set_r       <= 0;
        tag_req_r   <= (others => '0');
        cpu_rdata_r <= (others => '0');
        cpu_ready_r <= '0';
        hit_r       <= '0';
        miss_r      <= '0';
        ram_req_r   <= '0';
        ram_we_r    <= '0';
        ram_addr_r  <= (others => '0');
        ram_wdata_r <= (others => '0');
      else
        cpu_ready_r <= '0';
        hit_r       <= '0';
        miss_r      <= '0';

        case state_r is
          when IDLE =>
            ram_req_r <= '0';
            ram_we_r  <= '0';

            if cpu_req_i = '1' and cpu_ready_r = '0' then
              set_v := cache_set(cpu_addr_i);
              tag_v := cache_tag(cpu_addr_i);
              hit_v := false;
              hit_way := 0;
              victim_v := 0;

              for way in 0 to CACHE_WAYS-1 loop
                if valid_r(set_v, way) = '1' and tag_r(set_v, way) = tag_v then
                  hit_v := true;
                  hit_way := way;
                end if;
              end loop;

              for way in 0 to CACHE_WAYS-1 loop
                if valid_r(set_v, way) = '0' then
                  victim_v := way;
                elsif valid_r(set_v, victim_v) = '1' and age_r(set_v, way) > age_r(set_v, victim_v) then
                  victim_v := way;
                end if;
              end loop;

              req_addr_r  <= cpu_addr_i;
              req_wdata_r <= cpu_wdata_i;
              req_we_r    <= cpu_we_i;
              write_hit_r <= '0';
              victim_r    <= victim_v;
              set_r       <= set_v;
              tag_req_r   <= tag_v;

              if hit_v and cpu_we_i = '0' then
                cpu_rdata_r <= data_r(set_v, hit_way);
                cpu_ready_r <= '1';
                hit_r       <= '1';
              elsif cpu_we_i = '1' then
                if hit_v then
                  data_r(set_v, hit_way) <= cpu_wdata_i;
                  victim_v := hit_way;
                  write_hit_r <= '1';
                end if;
                ram_req_r   <= '1';
                ram_we_r    <= '1';
                ram_addr_r  <= cpu_addr_i;
                ram_wdata_r <= cpu_wdata_i;
                victim_r    <= victim_v;
                state_r     <= WAIT_WRITE_GRANT;
                if hit_v then
                  hit_r <= '1';
                else
                  miss_r <= '1';
                end if;
              else
                ram_req_r   <= '1';
                ram_we_r    <= '0';
                ram_addr_r  <= cpu_addr_i;
                ram_wdata_r <= (others => '0');
                state_r     <= WAIT_READ_GRANT;
                miss_r      <= '1';
              end if;
            end if;

          when WAIT_READ_GRANT =>
            ram_req_r <= '1';
            ram_we_r  <= '0';
            ram_addr_r <= req_addr_r;
            if ram_grant_i = '1' then
              state_r <= WAIT_READ_DATA;
            end if;

          when WAIT_READ_DATA =>
            ram_req_r <= '0';
            ram_we_r  <= '0';
            data_r(set_r, victim_r)  <= ram_rdata_i;
            tag_r(set_r, victim_r)   <= tag_req_r;
            valid_r(set_r, victim_r) <= '1';
            age_r(set_r, victim_r)   <= (others => '0');
            for way in 0 to CACHE_WAYS-1 loop
              if way /= victim_r and valid_r(set_r, way) = '1' then
                age_r(set_r, way) <= inc_age(age_r(set_r, way));
              end if;
            end loop;
            cpu_rdata_r <= ram_rdata_i;
            cpu_ready_r <= '1';
            miss_r      <= '1';
            state_r     <= IDLE;

          when WAIT_WRITE_GRANT =>
            ram_req_r   <= '1';
            ram_we_r    <= '1';
            ram_addr_r  <= req_addr_r;
            ram_wdata_r <= req_wdata_r;
            if ram_grant_i = '1' then
              if write_hit_r = '0' then
                data_r(set_r, victim_r)  <= req_wdata_r;
                tag_r(set_r, victim_r)   <= tag_req_r;
                valid_r(set_r, victim_r) <= '1';
                age_r(set_r, victim_r)   <= (others => '0');
                for way in 0 to CACHE_WAYS-1 loop
                  if way /= victim_r and valid_r(set_r, way) = '1' then
                    age_r(set_r, way) <= inc_age(age_r(set_r, way));
                  end if;
                end loop;
              end if;
              cpu_ready_r <= '1';
              state_r     <= IDLE;
              ram_req_r   <= '0';
              ram_we_r    <= '0';
            end if;
        end case;
      end if;
    end if;
  end process;
end architecture;
