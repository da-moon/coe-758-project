LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE work.cache_primitives.ALL;

-- CACHE_OFFSET_SIZE := 5;
-- CACHE_INDEX_SIZE := 3;
-- CACHE_TAG_SIZE := 8;
-- ALIGNED_SIZE := 2;

ENTITY cache_decoder IS
	PORT (
		address : IN std_logic_vector(ADDRESS_LENGTH-1 DOWNTO 0);
        -- cache_tag_vector == std_logic_vector(7 DOWNTO 0)
        tag : OUT cache_tag_vector;
        -- cache_index_vector == std_logic_vector(2 DOWNTO 0)
        index : OUT cache_index_vector;
        -- cache_offset_vector == std_logic_vector(4 DOWNTO 0)
		offset : OUT cache_offset_vector
	);
END ENTITY;

ARCHITECTURE behavior OF cache_decoder IS
BEGIN
    -- 15 DOWNTO 8 = len(cache_tag_vector) == 8
    tag <= address((ADDRESS_LENGTH-1) DOWNTO (ADDRESS_LENGTH - CACHE_TAG_SIZE));
    -- 7 DOWNTO 5 = len(cache_index_vector)== 3
    index <= address(((ADDRESS_LENGTH-1) - CACHE_TAG_SIZE) DOWNTO (ADDRESS_LENGTH - (CACHE_TAG_SIZE + CACHE_INDEX_SIZE)));
    -- 4 DOWNTO 0 == len(5) = 5
	offset <= address(((ADDRESS_LENGTH-1) - (CACHE_TAG_SIZE + CACHE_INDEX_SIZE)) DOWNTO 0);
END ARCHITECTURE;