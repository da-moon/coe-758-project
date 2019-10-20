LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE work.cache_pkg.ALL;
USE work.utils_pkg.ALL;
-- ----------------------------------------------------------------------------------------------------------------------
-- direct_mapped_cache_controller is the entity that handles the 
-- read and write operations to the tag BRAM and data BRAM.it stores whether a 
-- block line is dirty or not as well as whether it is valid or invalid. 
-- ----------------------------------------------------------------------------------------------------------------------|
-- ports																												 |
-- ----------------------------------------------------------------------------------------------------------------------|
-- | Name                  | Description                                                                                 |
-- |-----------------------|---------------------------------------------------------------------------------------------|
-- | clk                   | Clock signal is used for BRAM.                                                              |
-- | reset                 | Reset signal to reset the cache.                                                            |
-- | add_cpu               | Memory address from CPU is divided into block address and block offset.                     |
-- | data_cpu              | Data from CPU to cache or from cache to CPU.                                                |
-- | cache_memory_data_bus | Data to read from memory to cache or written from cache to memory.                          |
-- | wr_cache_block_Line   | Write signal identifies whether a complete cache block should be written into cache.        |
-- | rd_cache_block_line   | Read signal identifies whether a complete cache block should be read from cache.            |
-- | rd_word               | Read signal identifies to read data from the cache.                                         |
-- | wr_word               | Write signal identifies to write data into the cache.                                       |
-- | wr_rd                 | Signal identifies whether to read or write from cache.                                      |
-- | valid                 | Helps identify whether the cache block/line contains valid content.                         |
-- | dirty                 | Helps identify whether the cache block/line is changed as against the main memory.          |
-- | set_valid             | Helps with figuring out whether the valid bit should be set.                                |
-- | set_dirty             | Helps with figuring out whether the dirty bit should be set.                                |
-- | hit                   | Signal identify whether data are available in the cache ('1') or not ('0').                 |
-- | index                 | determines to which line of BRAM should be written or read.                                 |
-- | tag_to_bram           | address bus to bram                                                                         |
-- | tag_from_bram         | address bus from bram                                                                       |
-- | write_to_tag_bram     | identifies whether a tag should be written ('1') to BRAM or should be read ('0') from BRAM. |
-- | write_to_data_bram    | helps identify whether it is supposed to write data to b_ram                                |
-- | data_to_bram          | address bus for data to bram                                                                |
-- | data_from_bram        | address bus for data coming from bram                                                       |
-- |---------------------------------------------------------------------------------------------------------------------|

ENTITY direct_mapped_cache_controller IS
	PORT (
		clk : IN STD_LOGIC;
		reset : IN STD_LOGIC;
		add_cpu : IN STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH - 1 DOWNTO 0);
		data_cpu : INOUT STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0);
		cache_memory_data_bus : OUT STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0);
		valid : INOUT STD_LOGIC;
		dirty : INOUT STD_LOGIC;
		set_valid : IN STD_LOGIC;
		set_dirty : IN STD_LOGIC;
		hit : OUT STD_LOGIC;
		rd_word : IN STD_LOGIC;
		wr_word : IN STD_LOGIC;
		wr_rd : IN STD_LOGIC;
		wr_cache_block_Line : IN STD_LOGIC;
		rd_cache_block_line : IN STD_LOGIC;
		index : OUT STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 DOWNTO 0);
		tag_to_bram : OUT STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0);
		tag_from_bram : IN STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0);
		write_to_tag_bram : OUT STD_LOGIC;
		write_to_data_bram : OUT STD_LOGIC;
		data_to_bram : OUT STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0);
		data_from_bram : IN STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0);
		-- TODO Remove ? 
		new_cache_block_line : IN STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0)
	);
END;