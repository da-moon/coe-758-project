library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use std.textio.all;
use work.utils_pkg.ALL;
use work.cache_pkg.ALL; 

entity direct_mapped_cache_controller_tb is
end direct_mapped_cache_controller_tb;

architecture testbench of direct_mapped_cache_controller_tb is
  -- constants ... 
   CONSTANT clock_period : TIME := 10 ns; 
   CONSTANT TEST_TIME : TIME := 2000 ns;
   CONSTANT C_FILE_NAME :string  := "test_results/direct_mapped_cache_controller.txt";
   -- clock gen component  
   COMPONENT clock_gen
   GENERIC (clock_period : TIME);
      PORT (
			clk : OUT std_logic 
		);
  END COMPONENT;
  -- test component
  COMPONENT direct_mapped_cache_controller

     PORT (
      valid            	: inout STD_LOGIC;
      dirty         	 	: inout STD_LOGIC; 
      dataCPU       	 	: inout STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0); 			
      clk              : in    STD_LOGIC; 
      reset            : in    STD_LOGIC; 
      addrCPU          	: in    STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH-1 downto 0);	
      setValid         	: in    STD_LOGIC; 
      setDirty         	: in    STD_LOGIC;
      wrCBLine 	: in	STD_LOGIC; 
      rdCBLine 	: in	STD_LOGIC;
      rdWord	 	: in	STD_LOGIC;
      wrWord   	: in	STD_LOGIC; 
      writeMode 	: in	STD_LOGIC; 
        tagFromBRAM 	: in STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE- 1  downto 0);
      dataFromBRAM	    : in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0); 
      newCacheBlockLine 	: in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
      hit 			 	: out   STD_LOGIC;
      tagToBRAM 		: out STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE- 1  downto 0);
      dataToMEM 		   	: out STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
      index 		: out STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE- 1 downto 0);
      writeToTagBRAM 	: out STD_LOGIC;
      writeToDataBRAM		: out STD_LOGIC;
      dataToBRAM		    : out STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0)
  
   );
 END COMPONENT;
  -- signals ... 
  -- in/out
  signal dataCPU       	 	:STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0); 			
  signal valid            :STD_LOGIC;
  signal dirty         	 	:STD_LOGIC; 
  -- inputs ....
  signal clk           :std_logic := '0';
  signal reset           :std_logic := '0';
  signal addrCPU          	:    STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH-1 downto 0);	
  signal newCacheBlockLine 	: STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
  signal setValid         	:    STD_LOGIC; 
  signal setDirty         	:    STD_LOGIC;
  signal wrCBLine 	:	STD_LOGIC; 
  signal rdCBLine 	:	STD_LOGIC; 
  signal rdWord	 	:	STD_LOGIC;  
  signal wrWord   	:	STD_LOGIC; 
  signal writeMode 	:	STD_LOGIC; 
  signal dataFromBRAM	   : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0); 
  signal tagFromBRAM 	: STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE- 1  downto 0);
  signal tagFromdirect_mapped_cache_controller 	: STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1  downto 0);
  signal dataFromdirect_mapped_cache_controller	    : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
  -- outputs ....
  signal hit 			 	:  STD_LOGIC;
  signal tagToBRAM 		:STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE- 1  downto 0);
  signal dataToMEM 		   	:STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
  signal index 		:STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE- 1 downto 0);
  signal writeToTagBRAM 	:STD_LOGIC;
  signal writeToDataBRAM		:STD_LOGIC;
  signal dataToBRAM		    :STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
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
uut : direct_mapped_cache_controller
    PORT MAP(
      valid=>valid,
      dirty=>dirty,
      dataCPU=>dataCPU,
      clk=>clk,
      reset=>reset,
      addrCPU=>addrCPU,
      setValid=>setValid,
      setDirty=>setDirty,
      wrCBLine=>wrCBLine,
      rdCBLine=>rdCBLine,
      rdWord=>rdWord,
      wrWord=>wrWord,
      writeMode=>writeMode,
      tagFromBRAM=>tagFromBRAM,
      dataFromBRAM=>dataFromBRAM,
      newCacheBlockLine=>newCacheBlockLine,
      hit=>hit,
      tagToBRAM=>tagToBRAM,
      dataToMEM=>dataToMEM,
      index=>index,
      writeToTagBRAM=>writeToTagBRAM,
      writeToDataBRAM=>writeToDataBRAM,
      dataToBRAM=>dataToBRAM
);

stim_proc: process
  variable fstatus       :file_open_status;
  variable L : line;
  variable counter     :integer;
  variable old_addr     :STD_LOGIC_VECTOR (7 downto 0);
  variable temp     :STD_LOGIC_VECTOR (1 to 1);
begin
  WAIT for 1 ns;
  write(L, string'("direct-mapped-cache-controller controller tests are emvedded into cache tests ... moving on !"));
  writeline(output, L);

  -- reset <= '1', '0' after 100 ns;
  -- counter := 0;
  -- eof       <= '0';
  -- wait until reset = '0';
  -- file_open(fstatus, fptr, C_FILE_NAME, write_mode);
  -- while (counter * 10 ns < TEST_TIME) loop
  --    wait until rising_edge(clk);
  --     temp(1):=reset;
  --     write(L, string'("reset : "), right, 2);
  --     write(L, TO_STRING(temp), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     temp(1):=valid;
  --     write(L, string'("valid : "), right, 2);
  --     write(L, TO_STRING(temp), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     temp(1):=dirty;
  --     write(L, string'("dirty : "), right, 2);
  --     write(L, TO_STRING(temp), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     temp(1):=hit;
  --     write(L, string'("hit : "), right, 2);
  --     write(L, TO_STRING(temp), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     temp(1):=writeToTagBRAM;
  --     write(L, string'("writeToTagBRAM : "), right, 2);
  --     write(L, TO_STRING(temp), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     temp(1):=writeToDataBRAM;
  --     write(L, string'("writeToDataBRAM : "), right, 2);
  --     write(L, TO_STRING(temp), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("addrCPU : "), right, 2);
  --     write(L, TO_STRING(addrCPU), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(addrCPU), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("dataCPU : "), right, 2);
  --     write(L, TO_STRING(dataCPU), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(dataCPU), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("tagFromBRAM : "), right, 2);
  --     write(L, TO_STRING(tagFromBRAM), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(tagFromBRAM), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("dataFromBRAM : "), right, 2);
  --     write(L, TO_STRING(dataFromBRAM), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(dataFromBRAM), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("newCacheBlockLine : "), right, 2);
  --     write(L, TO_STRING(newCacheBlockLine), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(newCacheBlockLine), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("tagToBRAM : "), right, 2);
  --     write(L, TO_STRING(tagToBRAM), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(tagToBRAM), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("dataToMEM : "), right, 2);
  --     write(L, TO_STRING(dataToMEM), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(dataToMEM), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("index : "), right, 2);
  --     write(L, TO_STRING(index), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(index), right, 2);
  --     writeline(fptr, L);
  --     -- 
  --     write(L, string'("dataToBRAM : "), right, 2);
  --     write(L, TO_STRING(dataToBRAM), right, 2);
  --     write(L, string'(" = 0x"), right, 2);
  --     -- write(L, TO_HEX_STRING(dataToBRAM), right, 2);
  --     writeline(fptr, L);
  --     --
  --     write(L, string'("--------------------------------"), right, 2);
  --     writeline(fptr, L);
  -- end loop;
  -- wait until rising_edge(clk);
  -- eof       <= '1';
  -- file_close(fptr);
  wait;
end process;
end testbench;
