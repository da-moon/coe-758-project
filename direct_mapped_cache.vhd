library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use work.utils_pkg.all;
use work.cache_pkg.all;
-- -----------------------------------------------------------------------------
-- direct_mapped_cache is the top level entity that comes in contact with the 
-- CPU. THis entiry is also connected to two BRAMS : the tag BRAM and data BRAM
-- and acts as a bridge and connects all these three elements 
-- -----------------------------------------------------------------------------
-- generics
-- -----------------------------------------------------------------------------------------------------------
-- | Name           | Description              |
-- |----------------|--------------------------|
-- | TAG_FILENAME   | Filename for tag BRAM.   |
-- | DATA_FILENAME  | Filename for data BRAM.  |
-- | FILE_EXTENSION | File extension for BRAM. |
-- ---------------------------------------------------------------------------------------------------------------
-- ports
-- ---------------------------------------------------------------------------------------------------------------|
-- | Name                  | Description                                                                          |
-- |-----------------------|--------------------------------------------------------------------------------------|
-- | clk                   | Clock signal is used for BRAM.                                                       |
-- | reset                 | Reset signal to reset the cache.                                                     |
-- | add_cpu               | Memory address from CPU is divided into block address and block offset.              |
-- | data_cpu              | Data from CPU to cache or from cache to CPU.                                         |
-- | cache_memory_data_bus | Data to read from memory to cache or written from cache to memory.                   |
-- | wr_cache_block_Line   | Write signal identifies whether a complete cache block should be written into cache. |
-- | rd_cache_block_line   | Read signal identifies whether a complete cache block should be read from cache.     |
-- | rd_word               | Read signal identifies to read data from the cache.                                  |
-- | wr_word               | Write signal identifies to write data into the cache.                                |
-- | wr_rd                 | Signal identifies whether to read or write from cache.                               |
-- | valid                 | Helps identify whether the cache block/line contains valid content.                  |
-- | dirty                 | Helps identify whether the cache block/line is changed as against the main memory.   |
-- | set_valid             | Helps with figuring out whether the valid bit should be set.                         |
-- | set_dirty             | Helps with figuring out whether the dirty bit should be set.                         |
-- | hit                   | Signal identify whether data are available in the cache ('1') or not ('0').          |
-- -----------------------------------------------------------------------------------------------------------
-- -----------------------------------------------------------------------------------------------------------
entity direct_mapped_cache is
	generic(
		TAG_FILENAME          : STRING  := "./imem/tag";
		DATA_FILENAME         : STRING  := "./imem/data";
		FILE_EXTENSION       : STRING  := ".txt"
	);
	port(
		clk              : in    STD_LOGIC;
		reset            : in    STD_LOGIC;
		add_cpu          : in    STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH-1 downto 0); 
        data_cpu       	 : inout    STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0); 
		cache_memory_data_bus         : out STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0); 
		wr_cache_block_Line		 : in    STD_LOGIC;
        rd_cache_block_line		 : in	 STD_LOGIC; 
        rd_word           : in    STD_LOGIC; 
        wr_word           : in    STD_LOGIC; 
        wr_rd 		 : in    STD_LOGIC; 
        valid            : inout STD_LOGIC;
		dirty         	 : inout STD_LOGIC; 
        set_valid         : in    STD_LOGIC;
        set_dirty         : in    STD_LOGIC;
        hit              : out   STD_LOGIC;
        -- TODO Remove ?
        -- New cache block line.
        new_cache_block_line : in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0)

        );

end;