LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
-- VHDL2008 lib
USE IEEE.std_logic_textio.ALL;
USE STD.textio.ALL;
USE work.cache_pkg.ALL;

-- --------------------------------------------------------------------------------
-- Definition of entity.
-- --------------------------------------------------------------------------------
ENTITY cache_files_generator IS
	GENERIC (
		-- Filename of tag cache.
		TAG_FILENAME : STRING := "./imem/tag";
		-- Filename of instruction cache.
		DATA_FILENAME : STRING := "./imem/data";
		-- File extension of instruction file.
		FILE_EXTENSION : STRING := ".txt"
	);
END;