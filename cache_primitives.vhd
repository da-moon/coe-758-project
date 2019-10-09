LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

PACKAGE cache_primitives IS
	-- each memory is 4-bit aligned
	CONSTANT CACHE_OFFSET_SIZE : NATURAL := 5;
	CONSTANT CACHE_INDEX_SIZE : NATURAL := 3;
	CONSTANT CACHE_TAG_SIZE : NATURAL := 8;
    CONSTANT ADDRESS_LENGTH : NATURAL := 16;
	CONSTANT DATA_BANDWIDTH : NATURAL := 8;
	CONSTANT DATA_BLOCK_SIZE : natural := 2**CACHE_OFFSET_SIZE;
    -- cache_offset_vector == std_logic_vector(4 DOWNTO 0)
	SUBTYPE cache_offset_vector IS std_logic_vector(CACHE_OFFSET_SIZE - 1 DOWNTO 0);
    -- cache_index_vector == std_logic_vector(2 DOWNTO 0)
	SUBTYPE cache_index_vector IS std_logic_vector(CACHE_INDEX_SIZE - 1 DOWNTO 0);
    -- cache_tag_vector == std_logic_vector(7 DOWNTO 0)
    SUBTYPE cache_tag_vector IS std_logic_vector(CACHE_TAG_SIZE - 1 DOWNTO 0);
    -- cache_tag_index_vector == std_logic_vector(10 DOWNTO 0)
	SUBTYPE cache_tag_index_vector IS std_logic_vector(CACHE_TAG_SIZE + CACHE_INDEX_SIZE - 1 DOWNTO 0);

	TYPE valid_array_type IS ARRAY(NATURAL RANGE <>) OF std_logic;
    TYPE dirty_array_type IS ARRAY(NATURAL RANGE <>) OF std_logic;
    -- dummy_ram is used for test
	TYPE dummy_ram IS ARRAY(NATURAL RANGE <>) OF std_logic_vector((DATA_BANDWIDTH-1) DOWNTO 0);
    --type ram_array is array (7 downto 0, (DATA_BLOCK_SIZE-1) downto 0) of std_logic_vector(7 downto 0);

	TYPE tag_array_type IS ARRAY(NATURAL RANGE <>) OF cache_tag_vector;
END PACKAGE;