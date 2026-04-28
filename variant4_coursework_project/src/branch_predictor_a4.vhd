library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity branch_predictor_a4 is
  port (
    clk_i          : in  std_logic;
    rst_i          : in  std_logic;
    query_valid_i  : in  std_logic;
    pc_query_i     : in  addr_t;
    hist_o         : out std_logic_vector(1 downto 0);
    pred_taken_o   : out std_logic;
    pred_target_o  : out addr_t;
    update_valid_i : in  std_logic;
    pc_update_i    : in  addr_t;
    hist_i         : in  std_logic_vector(1 downto 0);
    actual_taken_i : in  std_logic;
    actual_tgt_i   : in  addr_t
  );
end entity;

architecture rtl of branch_predictor_a4 is
  type pht_t   is array (0 to 15) of unsigned(1 downto 0);
  type target_t is array (0 to 15) of addr_t;
  type valid_t  is array (0 to 15) of std_logic;

  signal pht       : pht_t    := (others => "01");
  signal btb_tgt   : target_t := (others => (others => '0'));
  signal btb_valid : valid_t  := (others => '0');
  signal ghr_r     : std_logic_vector(1 downto 0) := "00";

  function idx_of(pc : addr_t; hist : std_logic_vector(1 downto 0)) return integer is
    variable idx_v : std_logic_vector(3 downto 0);
  begin
    idx_v := std_logic_vector(pc(1 downto 0)) & hist;
    return to_integer(unsigned(idx_v));
  end function;

  function sat_dec(v : unsigned(1 downto 0)) return unsigned is
  begin
    if v = "00" then
      return v;
    else
      return v - 1;
    end if;
  end function;
begin
  hist_o <= ghr_r;

  process(query_valid_i, pc_query_i, ghr_r, pht, btb_valid, btb_tgt)
    variable idx : integer;
  begin
    pred_taken_o  <= '0';
    pred_target_o <= (others => '0');
    if query_valid_i = '1' then
      idx := idx_of(pc_query_i, ghr_r);
      if pht(idx)(1) = '1' and btb_valid(idx) = '1' then
        pred_taken_o  <= '1';
        pred_target_o <= btb_tgt(idx);
      end if;
    end if;
  end process;

  process(clk_i)
    variable idx : integer;
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        pht       <= (others => "01");
        btb_tgt   <= (others => (others => '0'));
        btb_valid <= (others => '0');
        ghr_r     <= "00";
      elsif update_valid_i = '1' then
        idx := idx_of(pc_update_i, hist_i);
        if actual_taken_i = '1' then
          pht(idx)       <= sat_inc2(pht(idx));
          btb_tgt(idx)   <= actual_tgt_i;
          btb_valid(idx) <= '1';
        else
          pht(idx) <= sat_dec(pht(idx));
        end if;
        ghr_r <= ghr_r(0) & actual_taken_i;
      end if;
    end if;
  end process;
end architecture;
