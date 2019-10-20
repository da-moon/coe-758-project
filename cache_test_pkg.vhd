LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.utils_pkg.ALL;
USE work.cache_pkg.ALL;
-- this is a utility package used to test cache
PACKAGE cache_test_pkg IS
	-- rerun_process - value determines whether to rerun the testbench process or not.
	CONSTANT rerun_process : STD_LOGIC := '0';
	CONSTANT break_line : STRING := "----------------------------------------------------------------------------------------------";
	TYPE BLOCK_LINE IS ARRAY (DEFAULT_BLOCK_SIZE - 1 DOWNTO 0) OF STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0);
	SUBTYPE CACHE_BLOCK_LINE_RANGE IS NATURAL RANGE (DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH) - 1 DOWNTO 0;
	-- -----------------------------------------------------------------------------------------------------------
	-- INIT_BLOCK_LINE -  initializes a block line with the given parameters.
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION INIT_BLOCK_LINE(ARG1, ARG2, ARG3, ARG4 : IN INTEGER) RETURN BLOCK_LINE;
	FUNCTION GENERATE_CPU_ADDRESS(ARG: IN INTEGER) RETURN STD_LOGIC_VECTOR;
	-- -----------------------------------------------------------------------------------------------------------
	-- GET_TAG -  returns tag as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION GET_TAG(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR;
	-- -----------------------------------------------------------------------------------------------------------
	-- GET_INDEX -  returns index as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION GET_INDEX(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR;
	-- -----------------------------------------------------------------------------------------------------------
	-- GET_OFFSET -  returns offset as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION GET_OFFSET(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR;
	-- -----------------------------------------------------------------------------------------------------------
	-- GET_DATA -  returns data as std logic vector.
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION GET_DATA(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR;
	FUNCTION GET_TAG(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR ;
	FUNCTION GET_INDEX(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR ;
	FUNCTION GET_OFFSET(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR ;
	FUNCTION GET_DATA_DEFAULTS(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR;
	FUNCTION GET_WR_RD_DEFAULTS(ARG : IN INTEGER) RETURN STD_LOGIC;
END PACKAGE;