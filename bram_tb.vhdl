library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use std.textio.all;
use work.utils_pkg.ALL;
use work.cache_pkg.ALL;

entity bram_tb is
end bram_tb;

architecture bench of bram_tb is
  -- constants ... 
   CONSTANT clock_period : TIME := 10 ns;
   CONSTANT TEST_TIME : TIME := 2000 ns;
   constant C_FILE_NAME :string  := "test_results/bram.txt";
    --    
   constant ADDR     : integer  := 8;
   constant DATA     : integer  := 8;
   constant EDGE     : EdgeType := RISING;
   constant RamFileName     : string   := "fixtures/bram.hex";
   -- clock gen component
   COMPONENT clock_gen
   GENERIC (clock_period : TIME);
      PORT (
			clk : OUT std_logic
		);
  END COMPONENT;
  -- test component
  COMPONENT bram
  generic ( 
            ADDR     : integer ;
            DATA     : integer  ;
            EDGE     : EdgeType ;
            RamFileName     : string  
          );
     PORT (
        clk : in  STD_LOGIC;
        we: in  STD_LOGIC;
        adr    : in  STD_LOGIC_VECTOR(7 downto 0);
        din    : in  STD_LOGIC_VECTOR(7 downto 0);
        dout   : out STD_LOGIC_VECTOR(7 downto 0)
   );
 END COMPONENT;
  -- signals ... 
  -- inputs ....
  signal clk           :std_logic := '0';
  signal rst           :std_logic := '0';
  signal we           :std_logic := '0';
  -- outputs ....
  signal adr           :STD_LOGIC_VECTOR (7 downto 0):= "00000000" ;
  signal din           :STD_LOGIC_VECTOR (7 downto 0) := x"00" ;
  signal dout           :STD_LOGIC_VECTOR (7 downto 0) ;
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
uut : bram
GENERIC MAP(
    ADDR => ADDR , 
    DATA => DATA , 
    EDGE =>EDGE,
    RamFileName =>RamFileName
    )
    PORT MAP(
    clk    =>clk,
    we   =>we,
    adr=> adr,
    din  =>din,
    dout   =>dout
);

stim_proc: process
  variable fstatus       :file_open_status;
  variable L : line;
  variable counter     :integer;
  variable old_addr     :STD_LOGIC_VECTOR (7 downto 0);
  variable temp     :STD_LOGIC_VECTOR (1 to 1);
begin
  WAIT for 1 ns;
  write(L, string'("bram(file backend) tests ... :"));
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
     we <= not we;
     if we = '1' then 
        adr<=std_logic_vector(unsigned(adr) + (1));
        din <= std_logic_vector(unsigned(din) + (1));
     end if;
        temp(1):=clk;
        write(L, string'("clk : "), right, 2);
        write(L, TO_STRING(temp), right, 2);
        -- writeline(output, L);
        writeline(fptr, L);
        temp(1):=we;
        write(L, string'("write_enable : "), right, 2);
        write(L, TO_STRING(temp), right, 2);
        -- writeline(output, L);
        writeline(fptr, L);
        write(L, string'("address :0x"), right, 2);
        write(L, TO_HEX_STRING(adr), right, 2);
        -- writeline(output, L);
        writeline(fptr, L);
        write(L, string'("din :0x"), right, 2);
        write(L, TO_HEX_STRING(din), right, 2);
        -- writeline(output, L);
        writeline(fptr, L);
        write(L, string'("dout :0x"), right, 2);
        write(L, TO_HEX_STRING(dout), right, 2);
        -- writeline(output, L);
        writeline(fptr, L);
        write(L, string'("-------------"), right, 2);
        -- writeline(output, L);
        writeline(fptr, L);
  end loop;
  wait until rising_edge(clk);
  eof       <= '1';
  file_close(fptr);
  wait;
end process;
end bench;
