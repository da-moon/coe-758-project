library ieee;
use ieee.std_logic_1164.all;
USE ieee.numeric_std.ALL;
use std.textio.all;
use work.utils_pkg.ALL;

entity cpu_gen_tb is
end cpu_gen_tb;

architecture bench of cpu_gen_tb is
  -- constants ... 
   CONSTANT clock_period : TIME := 10 ns;
   CONSTANT TEST_TIME : TIME := 2000 ns;
   constant C_FILE_NAME :string  := "test_results/cpu_gen.txt";

   -- clock gen component
   COMPONENT clock_gen
   GENERIC (clock_period : TIME);
      PORT (
			clk : OUT std_logic
		);
  END COMPONENT;
  -- test component
  COMPONENT cpu_gen
     PORT (
     clk 		: in  STD_LOGIC;
     rst 		: in  STD_LOGIC;
     trig 		: in  STD_LOGIC;
     Address 	: out  STD_LOGIC_VECTOR (15 downto 0);
     wr_rd 	: out  STD_LOGIC;
     cs 		: out  STD_LOGIC;
     DOut 		: out  STD_LOGIC_VECTOR (7 downto 0)
   );
 END COMPONENT;
  -- signals ... 
  -- inputs ....
  signal clk           :std_logic := '0';
  signal rst           :std_logic := '0';
  signal trig           :std_logic := '0';
  -- outputs ....
  signal Address           :STD_LOGIC_VECTOR (15 downto 0);
  signal wr_rd           :std_logic;
  signal cs           :std_logic ;
  signal DOut           :STD_LOGIC_VECTOR (7 downto 0) ;
  -- file output ...
  signal eof           :std_logic := '0';
  file fptr: text;

begin
 
-- Clock generator instl
clock_gen_instl : clock_gen
GENERIC MAP(clock_period => 10 ns)
PORT MAP(
		clk => clk
  );
-- unit under test instl... 
uut : cpu_gen
    PORT MAP(
    clk    =>clk,
    rst    =>rst,
    trig   =>trig,
    Address=>Address,
    wr_rd  =>wr_rd,
    cs     =>cs,
    DOut   =>DOut
);

stim_proc: process
  variable fstatus       :file_open_status;
  variable file_line     :line;
  variable var_data2     :integer;

-- Variables
  variable byte : bit_vector(0 to 7);
  variable word : bit_vector(1 to 32);
  variable half_byte : bit_vector(1 to 4);
  variable L : line;
  variable counter     :integer;
  variable old_addr     :STD_LOGIC_VECTOR (15 downto 0);
  variable temp     :STD_LOGIC_VECTOR (1 to 1);

begin
  WAIT for 1 ns;
  write(L, string'("cpu_gen tests ... :"));
  writeline(output, L);
  rst <= '1', '0' after 100 ns;
  counter := 0;
-- 
  eof       <= '0';
-- 
  wait until rst = '0';
  file_open(fstatus, fptr, C_FILE_NAME, write_mode);
  while (counter * 10 ns < TEST_TIME) loop
     wait until rising_edge(clk);
     trig <= not trig;
     if old_addr /= Address then 
        old_addr:=Address;
        temp(1):=trig;
        write(L, string'("TRIG : "), right, 2);
        write(L, TO_STRING(temp), right, 2);
        writeline(fptr, L);
        temp(1):=cs;
        write(L, string'("CPU cs : "), right, 2);
        write(L, TO_STRING(temp), right, 2);
        writeline(fptr, L);
        temp(1):=wr_rd;
        write(L, string'("CPU wr_rd : "), right, 2);
        write(L, TO_STRING(temp), right, 2);
        writeline(fptr, L);
        write(L, string'("CPU OUT ADDRESS : "), right, 2);
        write(L, TO_STRING(Address), right, 2);
        writeline(fptr, L);
        write(L, string'("CPU Data OUT : "), right, 2);
        write(L, TO_STRING(DOut), right, 2);
        writeline(fptr, L);
        write(L, string'("-------------"), right, 2);
        writeline(fptr, L);
     end if;
  end loop;
  wait until rising_edge(clk);
  eof       <= '1';
  file_close(fptr);
  wait;
end process;
end bench;
