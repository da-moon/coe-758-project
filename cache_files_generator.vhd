library IEEE;
use IEEE.std_logic_1164.all;
 -- VHDL2008 lib
use IEEE.std_logic_textio.all;         
use STD.textio.all;
use work.cache_pkg.all;

-- --------------------------------------------------------------------------------
-- Definition of entity.
-- --------------------------------------------------------------------------------
entity cache_files_generator is
	generic(
		-- Filename of tag cache.
		TAG_FILENAME         : STRING  := "./imem/tag";
		-- Filename of instruction cache.
		DATA_FILENAME        : STRING  := "./imem/data";
		-- File extension of instruction file.
		FILE_EXTENSION       : STRING  := ".txt"
	);
end;