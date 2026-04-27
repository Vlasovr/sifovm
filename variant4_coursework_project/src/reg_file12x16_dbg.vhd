library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.variant4_pkg.all;

entity reg_file12x16_dbg is
  port (
    clk_i       : in  std_logic;
    rst_i       : in  std_logic;
    we_i        : in  std_logic;
    wr_addr_i   : in  reg_idx_t;
    rd_addr_a_i : in  reg_idx_t;
    rd_addr_b_i : in  reg_idx_t;
    din_i       : in  word_t;
    dout_a_o    : out word_t;
    dout_b_o    : out word_t;
    r0_o        : out word_t;
    r1_o        : out word_t;
    r2_o        : out word_t;
    r3_o        : out word_t;
    r4_o        : out word_t;
    r5_o        : out word_t;
    r6_o        : out word_t;
    r7_o        : out word_t;
    r8_o        : out word_t;
    r9_o        : out word_t;
    r10_o       : out word_t;
    r11_o       : out word_t
  );
end entity;

architecture rtl of reg_file12x16_dbg is
  type reg_array_t is array (0 to REG_COUNT-1) of word_t;
  signal regs : reg_array_t := (others => (others => '0'));

  function read_reg(mem : reg_array_t; idx : reg_idx_t) return word_t is
  begin
    if to_integer(idx) < REG_COUNT then
      return mem(to_integer(idx));
    else
      return (others => '0');
    end if;
  end function;
begin
  dout_a_o <= read_reg(regs, rd_addr_a_i);
  dout_b_o <= read_reg(regs, rd_addr_b_i);

  r0_o  <= regs(0);
  r1_o  <= regs(1);
  r2_o  <= regs(2);
  r3_o  <= regs(3);
  r4_o  <= regs(4);
  r5_o  <= regs(5);
  r6_o  <= regs(6);
  r7_o  <= regs(7);
  r8_o  <= regs(8);
  r9_o  <= regs(9);
  r10_o <= regs(10);
  r11_o <= regs(11);

  process(clk_i)
  begin
    if rising_edge(clk_i) then
      if rst_i = '1' then
        regs <= (others => (others => '0'));
      elsif we_i = '1' and to_integer(wr_addr_i) < REG_COUNT then
        regs(to_integer(wr_addr_i)) <= din_i;
      end if;
    end if;
  end process;
end architecture;
