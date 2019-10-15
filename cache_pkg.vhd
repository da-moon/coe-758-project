LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.utils_pkg.ALL;
PACKAGE cache_pkg IS
    -- -----------------------------------------------------------------------------------------
    -- CACHE CONFIGURATION
    -- 
    -- Memory address is 16-bit wide.
    CONSTANT DEFAULT_MEMORY_ADDRESS_WIDTH : INTEGER := 16;
    -- CPU data width of bus connected to CPU
    CONSTANT DEFAULT_DATA_WIDTH : INTEGER := 8;
    -- Address Width or the number of cache blocks / lines is the depth of the cache
    CONSTANT DEFAULT_ADDRESS_WIDTH : INTEGER := 256;
    -- Number of words that a block contains 
    -- these are simultaneously loaded from the main memory into cache.
    CONSTANT DEFAULT_BLOCK_SIZE : INTEGER := 32;
    -- The number of bits specifies the smallest unit that can be selected
    -- in the cache. 
    CONSTANT DEFAULT_OFFSET_SIZE : INTEGER := 5;
    -- -----------------------------------------------------------------------------------------------------------
    -- -----------------------------------------------------------------------------------------
    -- Possible states of the controller.
    -- -----------------------------------------------------------------------------------------------------------
    TYPE STATE_TYPE IS (
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
    TYPE CACHE_BLOCK_LINE IS ARRAY (DEFAULT_BLOCK_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0);
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION CALCULATE_TAG_VECTOR_UPPER_INDEX RETURN INTEGER;
    FUNCTION CALCULATE_TAG_VECTOR_LOWER_INDEX RETURN INTEGER;
    FUNCTION CALCULATE_TAG_VECTOR_SIZE RETURN INTEGER;
    FUNCTION CALCULATE_INDEX_VECTOR_UPPER_INDEX RETURN INTEGER;
    FUNCTION CALCULATE_INDEX_VECTOR_LOWER_INDEX RETURN INTEGER;
    FUNCTION CALCULATE_INDEX_VECTOR_SIZE RETURN INTEGER;
    FUNCTION CALCULATE_OFFSET_VECTOR_UPPER_INDEX RETURN INTEGER;
    FUNCTION CALCULATE_OFFSET_VECTOR_LOWER_INDEX RETURN INTEGER;
    FUNCTION CALCULATE_OFFSET_VECTOR_SIZE RETURN INTEGER;
    -- -----------------------------------------------------------------------------------------------------------
    -- A memory address contains a tag vector, index vector and offset vector.
    -- -----------------------------------------------------------------------------------------------------------
    TYPE MEMORY_ADDRESS IS RECORD
        tag : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0);
        index : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 DOWNTO 0);
        offset : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 DOWNTO 0);
        index_as_integer : INTEGER;
        offset_as_integer : INTEGER;
    END RECORD;
    -- -----------------------------------------------------------------------------------------------------------
    -- GET_START_INDEX - it is used to determine the start index of the data word in the cache line.
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION GET_START_INDEX(offset : IN INTEGER) RETURN INTEGER;
    -- -----------------------------------------------------------------------------------------------------------	
    -- GET_END_INDEX -  it is used to determine the end index of the data word in the cache line.
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION GET_END_INDEX(offset : IN INTEGER) RETURN INTEGER;
    -- -----------------------------------------------------------------------------------------------------------
    -- TO_STD_LOGIC_VECTOR -  converts the given cache block line to a vector.
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION TO_STD_LOGIC_VECTOR(ARG : IN CACHE_BLOCK_LINE) RETURN STD_LOGIC_VECTOR;
    -- -----------------------------------------------------------------------------------------------------------
    -- SET_BLOCK_LINE - modifies the given cache block line.
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION SET_BLOCK_LINE(
        b_in : IN CACHE_BLOCK_LINE;
        data : IN STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0);
        offset : IN INTEGER
    ) RETURN CACHE_BLOCK_LINE;
    -- -----------------------------------------------------------------------------------------------------------
    -- TO_CACHE_BLOCK_LINE - converts the given vector to a cache block line.
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION TO_CACHE_BLOCK_LINE(ARG : IN STD_LOGIC_VECTOR) RETURN CACHE_BLOCK_LINE;
    -- -----------------------------------------------------------------------------------------------------------
    -- TO_MEMORY_ADDRESS - converts the given vector to a memory address.
    -- -----------------------------------------------------------------------------------------------------------
    FUNCTION TO_MEMORY_ADDRESS(ARG : IN STD_LOGIC_VECTOR) RETURN MEMORY_ADDRESS;
END PACKAGE;