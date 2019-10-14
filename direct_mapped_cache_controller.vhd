library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use work.cache_pkg.all;
use work.utils_pkg.all;
entity direct_mapped_cache_controller is
	port(
		-- Clock signal is used for BRAM.
		clk              : in    STD_LOGIC; 
		-- Reset signal to reset the cache.
		reset            : in    STD_LOGIC; 
		-- Ports regarding CPU and MEM.
		-- Memory address from CPU is divided into block address and block offset.
		addrCPU          	: in    STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH-1 downto 0);	
		-- Data from CPU to cache or from cache to CPU.
		dataCPU       	 	: inout STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0); 			
		 -- Data from memory to cache or from cache to memory
		dataToMEM 		   	: out STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
		newCacheBlockLine 	: in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
		 -- Identify whether the cache block/line contains valid content.
		valid            	: inout STD_LOGIC;
		-- Identify whether the cache block/line is changed as against the main memory.
		dirty         	 	: inout STD_LOGIC; 
		-- used to identify whether the valid bit should be set.
		setValid         	: in    STD_LOGIC; 
		-- used to identify whether the dirty bit should be set.
		setDirty         	: in    STD_LOGIC;
		-- Signal identify whether data are available in the cache ('1') or not ('0').
		hit 			 	: out   STD_LOGIC;
		-- Ports defines how to read or write the data BRAM.
		--
		-- Write signal identifies whether a complete cache block should be written into cache.
		wrCBLine 	: in	STD_LOGIC; 
		-- Read signal identifies whether a complete cache block should be read from cache.
		rdCBLine 	: in	STD_LOGIC;
		 -- Read signal identifies to read data word from the cache. 
		rdWord	 	: in	STD_LOGIC;
		-- Write signal identifies to write data word into the cache.
		wrWord   	: in	STD_LOGIC; 
		-- '1' when write mode. '0' when read mode.
		writeMode 	: in	STD_LOGIC; 
		-- Index determines to which line of BRAM should be written or read.
		index 		: out STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE- 1 downto 0);
		-- Ports regarding BRAM tag.
		tagToBRAM 		: out STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE- 1 downto 0);
		tagFromBRAM 	: in STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE- 1  downto 0);
		writeToTagBRAM 	: out STD_LOGIC;
		-- Ports regarding BRAM data.
		writeToDataBRAM		: out STD_LOGIC;
		dataToBRAM		    : out STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
		dataFromBRAM	    : in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0)
	);

end;