library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.utils_pkg.ALL;
package cache_pkg is
	-- -----------------------------------------------------------------------------------------
    -- CACHE CONFIGURATION
    -- 
    -- Memory address is 16-bit wide.
    CONSTANT DEFAULT_MEMORY_ADDRESS_WIDTH : INTEGER := 16;
    -- CPU data width of bus connected to CPU
    CONSTANT DEFAULT_DATA_WIDTH           : integer := 8;
    -- Address Width or the number of cache blocks / lines is the depth of the cache
    CONSTANT DEFAULT_ADDRESS_WIDTH         : integer := 256;
    -- Number of words that a block contains 
    -- these are simultaneously loaded from the main memory into cache.
    CONSTANT DEFAULT_BLOCK_SIZE            : integer := 32;
    -- The number of bits specifies the smallest unit that can be selected
    -- in the cache. 
    CONSTANT DEFAULT_OFFSET_SIZE         : integer := 5; 
	-- -----------------------------------------------------------------------------------------------------------
	-- -----------------------------------------------------------------------------------------
    -- Possible states of the controller.
	-- -----------------------------------------------------------------------------------------------------------
    type STATE_TYPE is ( 
        -- Indicates to read a single word from the cache line.
        READ_DATA,      
        -- Indicates a delay state.
        DELAY,			
        -- Indicates to read a complete cache line.
        READ_LINE,      
        -- Indicates to write a single word from the cache line.
        WRITE_DATA,    
        -- Indicates to write a complete cache line.
        WRITE_LINE,    
        -- Do nothing.
        NOTHING	        
    ); 

	-- -----------------------------------------------------------------------------------------------------------
	-- A cache block line is an array of multiple vectors. Each vector represents a data word.
	-- -----------------------------------------------------------------------------------------------------------
	type CACHE_BLOCK_LINE is ARRAY ( DEFAULT_BLOCK_SIZE-1 downto 0) of STD_LOGIC_VECTOR( DEFAULT_DATA_WIDTH-1 downto 0 );
	-- -----------------------------------------------------------------------------------------------------------
    function CALCULATE_TAG_VECTOR_UPPER_INDEX return INTEGER;
    function CALCULATE_TAG_VECTOR_LOWER_INDEX return INTEGER;
    function CALCULATE_TAG_VECTOR_SIZE return INTEGER;
    function CALCULATE_INDEX_VECTOR_UPPER_INDEX return INTEGER;
    function CALCULATE_INDEX_VECTOR_LOWER_INDEX return INTEGER;
    function CALCULATE_INDEX_VECTOR_SIZE return INTEGER;
    function CALCULATE_OFFSET_VECTOR_UPPER_INDEX return INTEGER;
    function CALCULATE_OFFSET_VECTOR_LOWER_INDEX return INTEGER;
    function CALCULATE_OFFSET_VECTOR_SIZE return INTEGER;
	-- -----------------------------------------------------------------------------------------------------------
	-- A memory address contains a tag vector, index vector and offset vector.
	-- -----------------------------------------------------------------------------------------------------------
	type MEMORY_ADDRESS is record
		tag    : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 downto 0);
		index  : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 downto 0);
		offset : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 downto 0);
		index_as_integer : INTEGER;
		offset_as_integer : INTEGER;
    end record;
    -- -----------------------------------------------------------------------------------------------------------
	-- GET_START_INDEX - it is used to determine the start index of the data word in the cache line.
	-- -----------------------------------------------------------------------------------------------------------
	function GET_START_INDEX( offset : in INTEGER ) return INTEGER;
	-- -----------------------------------------------------------------------------------------------------------	
	-- GET_END_INDEX -  it is used to determine the end index of the data word in the cache line.
	-- -----------------------------------------------------------------------------------------------------------
	function GET_END_INDEX( offset : in INTEGER ) return INTEGER;
  	-- -----------------------------------------------------------------------------------------------------------
	-- TO_STD_LOGIC_VECTOR -  converts the given cache block line to a vector.
	-- -----------------------------------------------------------------------------------------------------------
    function TO_STD_LOGIC_VECTOR( ARG : in CACHE_BLOCK_LINE ) return STD_LOGIC_VECTOR;
   	-- -----------------------------------------------------------------------------------------------------------
	-- SET_BLOCK_LINE - modifies the given cache block line.
	-- -----------------------------------------------------------------------------------------------------------
	function SET_BLOCK_LINE( 
        b_in : in CACHE_BLOCK_LINE; 
        data : in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0);
        offset : in INTEGER
    ) return CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------------------------
	-- TO_CACHE_BLOCK_LINE - converts the given vector to a cache block line.
	-- -----------------------------------------------------------------------------------------------------------
	function TO_CACHE_BLOCK_LINE( ARG : in STD_LOGIC_VECTOR ) return CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------------------------
	-- TO_MEMORY_ADDRESS - converts the given vector to a memory address.
	-- -----------------------------------------------------------------------------------------------------------
	function TO_MEMORY_ADDRESS(ARG : in STD_LOGIC_VECTOR) return MEMORY_ADDRESS;
	END PACKAGE;