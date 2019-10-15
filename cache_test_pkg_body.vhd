package body cache_test_pkg is
    function INIT_BLOCK_LINE(ARG1, ARG2, ARG3, ARG4 : in INTEGER) return BLOCK_LINE is
		variable v : BLOCK_LINE;
	begin
		v(3) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG1, DEFAULT_DATA_WIDTH));
		v(2) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG2, DEFAULT_DATA_WIDTH));
		v(1) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG3, DEFAULT_DATA_WIDTH));
		v(0) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG4, DEFAULT_DATA_WIDTH));
		return v;
	end;
	-- -----------------------------------------------------------------------------------------------------------	
	function GET_TAG(ARG : in INTEGER) return STD_LOGIC_VECTOR is
		variable tag : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 downto 0) := (others => '0');
	begin
		tag := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, CALCULATE_TAG_VECTOR_SIZE));
		return tag;
	end;
	-- -----------------------------------------------------------------------------------------------------------

	function GET_INDEX(ARG : in INTEGER) return STD_LOGIC_VECTOR is
		variable index : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 downto 0) := (others => '0');
	begin
		index := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, CALCULATE_INDEX_VECTOR_SIZE));
		return index;
	end;
	-- -----------------------------------------------------------------------------------------------------------

	function GET_OFFSET(ARG : in INTEGER) return STD_LOGIC_VECTOR is
		variable offset : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 downto 0) := (others => '0');
	begin
		offset := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, CALCULATE_OFFSET_VECTOR_SIZE));
		return offset;
	end;
	-- -----------------------------------------------------------------------------------------------------------

	function GET_DATA(ARG : in INTEGER) return STD_LOGIC_VECTOR is
		variable data : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 downto 0) := (others => '0');
	begin
		data := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, DEFAULT_DATA_WIDTH));
		return data;
	end;
end cache_test_pkg;
    