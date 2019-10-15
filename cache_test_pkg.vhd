library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;
use work.utils_pkg.ALL;
use work.cache_pkg.ALL;
-- this is a utility package used to test cache
package cache_test_pkg is
    -- rerun_process - value determines whether to rerun the testbench process or not.
	constant rerun_process : STD_LOGIC := '0';
    constant break_line : STRING := "----------------------------------------------------------------------------------------------";
	TYPE BLOCK_LINE IS ARRAY (DEFAULT_BLOCK_SIZE - 1 downto 0) of STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 downto 0);
    subtype CACHE_BLOCK_LINE_RANGE is NATURAL range (DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH)-1 downto 0;
    -- -----------------------------------------------------------------------------------------------------------
	-- INIT_BLOCK_LINE -  initializes a block line with the given parameters.
	-- -----------------------------------------------------------------------------------------------------------
	function INIT_BLOCK_LINE(ARG1, ARG2, ARG3, ARG4 : in INTEGER) return BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------------------------
	-- GET_TAG -  returns tag as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
    function GET_TAG(ARG : in INTEGER) return STD_LOGIC_VECTOR ;
	-- -----------------------------------------------------------------------------------------------------------
   	-- GET_INDEX -  returns index as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
    function GET_INDEX(ARG : in INTEGER) return STD_LOGIC_VECTOR ;
	-- -----------------------------------------------------------------------------------------------------------
    -- GET_OFFSET -  returns offset as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
    function GET_OFFSET(ARG : in INTEGER) return STD_LOGIC_VECTOR ;
	-- -----------------------------------------------------------------------------------------------------------
    -- GET_DATA -  returns data as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
 function GET_DATA(ARG : in INTEGER) return STD_LOGIC_VECTOR ;
END PACKAGE;
