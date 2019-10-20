PACKAGE BODY cache_test_pkg IS
	FUNCTION INIT_BLOCK_LINE(ARG1, ARG2, ARG3, ARG4 : IN INTEGER) RETURN BLOCK_LINE IS
		VARIABLE v : BLOCK_LINE;
	BEGIN
		v(3) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG1, DEFAULT_DATA_WIDTH));
		v(2) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG2, DEFAULT_DATA_WIDTH));
		v(1) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG3, DEFAULT_DATA_WIDTH));
		v(0) := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG4, DEFAULT_DATA_WIDTH));
		RETURN v;
	END;
	-- based on cpu gen specification
	FUNCTION GENERATE_CPU_ADDRESS(ARG: IN INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE v   :STD_LOGIC_VECTOR(15 DOWNTO 0) ;
	BEGIN
		if (ARG=7) then
			v := 		"0001000100000000";
		elsif  (ARG=6) then
			v := 		"0001000100000010";
		elsif  (ARG=5) then
			v := 		"0001000100000000";
		elsif  (ARG=4) then
			v := 		"0001000100000010";
		elsif  (ARG=3) then
			v := 		"0011001101000110";
		elsif  (ARG=2) then
			v := 		"0100010001000100";
		elsif  (ARG=1) then
			v := 		"0101010100000100";
		else 
			v := 		"0110011000000110";
		end if;

		RETURN v;
	END;
	FUNCTION GET_DATA_DEFAULTS(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE v : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		if (ARG=7) then
			v := 		"10101010";
		elsif  (ARG=6) then
			v := 		"10111011";
		elsif  (ARG=5) then
			v := 		"00000000";
		elsif  (ARG=4) then
			v := 		"00000000";
		elsif  (ARG=3) then
			v := 		"00000000";
		elsif  (ARG=2) then
			v := 		"00000000";
		elsif  (ARG=1) then
			v := 		"11001100";
		else
			v := 		"00000000";
		end if;
		RETURN v;
	END;
	-- -----------------------------------------------------------------------------------------------------------	
	FUNCTION GET_WR_RD_DEFAULTS(ARG : IN INTEGER) RETURN STD_LOGIC IS
		VARIABLE v : STD_LOGIC;
	BEGIN
		if (ARG=7) then
			v := 		'1';
		elsif  (ARG=6) then
			v := 		'1';
		elsif  (ARG=5) then
			v := 		'0';
		elsif  (ARG=4) then
			v := 		'0';
		elsif  (ARG=3) then
			v := 		'0';
		elsif  (ARG=2) then
			v := 		'0';
		elsif  (ARG=1) then
			v := 		'1';
		else
			v := 		'0';
		end if;
		RETURN v;
	END;
	-- -----------------------------------------------------------------------------------------------------------	
	FUNCTION GET_TAG(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE tag : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		tag := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, CALCULATE_TAG_VECTOR_SIZE));
		RETURN tag;
	END;
	FUNCTION GET_TAG(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
		VARIABLE tag : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		tag := ARG(CALCULATE_TAG_VECTOR_UPPER_INDEX DOWNTO CALCULATE_TAG_VECTOR_LOWER_INDEX );
		RETURN tag;
	END;
	-- -----------------------------------------------------------------------------------------------------------

	FUNCTION GET_INDEX(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE index : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		index := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, CALCULATE_INDEX_VECTOR_SIZE));
		RETURN index;
	END;

	FUNCTION GET_INDEX(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
		VARIABLE index : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		index := ARG(CALCULATE_INDEX_VECTOR_UPPER_INDEX DOWNTO CALCULATE_INDEX_VECTOR_LOWER_INDEX);
		RETURN index;
	END;
	-- -----------------------------------------------------------------------------------------------------------

	FUNCTION GET_OFFSET(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE offset : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		offset := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, CALCULATE_OFFSET_VECTOR_SIZE));
		RETURN offset;
	END;
	FUNCTION GET_OFFSET(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
	VARIABLE offset : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		offset := ARG(CALCULATE_OFFSET_VECTOR_UPPER_INDEX DOWNTO CALCULATE_OFFSET_VECTOR_LOWER_INDEX );
		RETURN offset;
	END;
	-- -----------------------------------------------------------------------------------------------------------

	FUNCTION GET_DATA(ARG : IN INTEGER) RETURN STD_LOGIC_VECTOR IS
		VARIABLE data : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	BEGIN
		data := STD_LOGIC_VECTOR(TO_UNSIGNED(ARG, DEFAULT_DATA_WIDTH));
		RETURN data;
	END;
	
	
	
	
	

	
	
	
END cache_test_pkg;