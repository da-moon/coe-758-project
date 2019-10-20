
PACKAGE BODY cache_pkg IS

	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_TAG_VECTOR_UPPER_INDEX RETURN INTEGER IS
		VARIABLE number_of_bits_allocated_for_tag : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_offset : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_index : INTEGER := 0;
		VARIABLE r : INTEGER := 0;
	BEGIN
		number_of_bits_allocated_for_tag := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
		number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE) - 1;
		number_of_bits_allocated_for_index := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
		r := number_of_bits_allocated_for_offset + number_of_bits_allocated_for_index + number_of_bits_allocated_for_tag - 1;
		RETURN r;
	END CALCULATE_TAG_VECTOR_UPPER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_TAG_VECTOR_LOWER_INDEX RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_tag : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_offset : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_index : INTEGER := 0;
	BEGIN
		number_of_bits_allocated_for_tag := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
		number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE) - 1;
		number_of_bits_allocated_for_index := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
		r := number_of_bits_allocated_for_offset + number_of_bits_allocated_for_index;
		RETURN r;
	END CALCULATE_TAG_VECTOR_LOWER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_TAG_VECTOR_SIZE RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
	BEGIN
		r := CALCULATE_TAG_VECTOR_UPPER_INDEX - CALCULATE_TAG_VECTOR_LOWER_INDEX + 1;
		RETURN r;
	END CALCULATE_TAG_VECTOR_SIZE;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_INDEX_VECTOR_UPPER_INDEX RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_tag : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_offset : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_index : INTEGER := 0;
	BEGIN
		number_of_bits_allocated_for_tag := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
		number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE) - 1;
		number_of_bits_allocated_for_index := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
		r := number_of_bits_allocated_for_offset + number_of_bits_allocated_for_index - 1;
		RETURN r;
	END CALCULATE_INDEX_VECTOR_UPPER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_INDEX_VECTOR_LOWER_INDEX RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_tag : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_offset : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_index : INTEGER := 0;
	BEGIN
		number_of_bits_allocated_for_tag := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
		number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE) - 1;
		number_of_bits_allocated_for_index := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
		r := number_of_bits_allocated_for_offset;
		RETURN r;
	END CALCULATE_INDEX_VECTOR_LOWER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_INDEX_VECTOR_SIZE RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
	BEGIN
		r := CALCULATE_INDEX_VECTOR_UPPER_INDEX - CALCULATE_INDEX_VECTOR_LOWER_INDEX + 1;
		RETURN r;
	END CALCULATE_INDEX_VECTOR_SIZE;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_OFFSET_VECTOR_UPPER_INDEX RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_tag : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_offset : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_index : INTEGER := 0;
	BEGIN
		number_of_bits_allocated_for_tag := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
		number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE) - 1;
		number_of_bits_allocated_for_index := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
		r := number_of_bits_allocated_for_offset - 1;
		RETURN r;
	END CALCULATE_OFFSET_VECTOR_UPPER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_OFFSET_VECTOR_LOWER_INDEX RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_tag : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_offset : INTEGER := 0;
		VARIABLE number_of_bits_allocated_for_index : INTEGER := 0;
	BEGIN
		number_of_bits_allocated_for_tag := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
		number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE) - 1;
		number_of_bits_allocated_for_index := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
		r := 0;
		RETURN r;
	END CALCULATE_OFFSET_VECTOR_LOWER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION CALCULATE_OFFSET_VECTOR_SIZE RETURN INTEGER IS
		VARIABLE r : INTEGER := 0;
	BEGIN
		r := CALCULATE_OFFSET_VECTOR_UPPER_INDEX - CALCULATE_OFFSET_VECTOR_LOWER_INDEX + 1;
		RETURN r;
	END CALCULATE_OFFSET_VECTOR_SIZE;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION GET_START_INDEX(offset : IN INTEGER) RETURN INTEGER IS
		VARIABLE number_of_bits_in_a_block : INTEGER := 0;
	BEGIN
		number_of_bits_in_a_block := DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH;
		RETURN number_of_bits_in_a_block - 1 - (DEFAULT_DATA_WIDTH * offset);
	END FUNCTION;
	-- -----------------------------------------------------------------------------------------------------------	
	FUNCTION GET_END_INDEX (offset : IN INTEGER) RETURN INTEGER IS
		VARIABLE number_of_bits_in_a_block : INTEGER := 0;
	BEGIN
		number_of_bits_in_a_block := DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH;
		RETURN number_of_bits_in_a_block - 1 - (DEFAULT_DATA_WIDTH * offset) - DEFAULT_DATA_WIDTH + 1;
	END FUNCTION;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION TO_STD_LOGIC_VECTOR(ARG : IN CACHE_BLOCK_LINE) RETURN STD_LOGIC_VECTOR IS
		VARIABLE v : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE start_idx, end_idx : INTEGER;
	BEGIN
		FOR I IN 0 TO DEFAULT_BLOCK_SIZE - 1 LOOP
			start_idx := GET_START_INDEX(I);
			end_idx := GET_END_INDEX(I);
			v(start_idx DOWNTO end_idx) := ARG(I);
		END LOOP;
		RETURN v;
	END FUNCTION;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION SET_BLOCK_LINE(
		b_in : IN CACHE_BLOCK_LINE;
		data : IN STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0);
		offset : IN INTEGER
	) RETURN CACHE_BLOCK_LINE IS
		VARIABLE b : CACHE_BLOCK_LINE;
	BEGIN
		FOR I IN 0 TO DEFAULT_BLOCK_SIZE - 1 LOOP
			IF I = offset THEN
				b(I) := data;
			ELSE
				b(I) := b_in(I);
			END IF;
		END LOOP;
		RETURN b;
	END FUNCTION;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION TO_CACHE_BLOCK_LINE(ARG : IN STD_LOGIC_VECTOR) RETURN CACHE_BLOCK_LINE IS
		VARIABLE block_line : CACHE_BLOCK_LINE;
		VARIABLE start_idx : INTEGER;
		VARIABLE end_idx : INTEGER;
	BEGIN
		FOR I IN 0 TO DEFAULT_BLOCK_SIZE - 1 LOOP
			start_idx := GET_START_INDEX(I);
			end_idx := GET_END_INDEX(I);
			block_line(I) := ARG(start_idx DOWNTO end_idx);
		END LOOP;
		RETURN block_line;
	END FUNCTION;
	-- -----------------------------------------------------------------------------------------------------------
	FUNCTION TO_MEMORY_ADDRESS(ARG : IN STD_LOGIC_VECTOR) RETURN MEMORY_ADDRESS IS
		VARIABLE addr : MEMORY_ADDRESS := (
		tag => (OTHERS => '0'),
		index => (OTHERS => '0'),
		offset => (OTHERS => '0'),
		index_as_integer => 0,
		offset_as_integer => 0
		);
	BEGIN
		addr.tag := ARG(CALCULATE_TAG_VECTOR_UPPER_INDEX DOWNTO CALCULATE_TAG_VECTOR_LOWER_INDEX);
		addr.index := ARG(CALCULATE_INDEX_VECTOR_UPPER_INDEX DOWNTO CALCULATE_INDEX_VECTOR_LOWER_INDEX);
		addr.offset := ARG(CALCULATE_OFFSET_VECTOR_UPPER_INDEX DOWNTO CALCULATE_OFFSET_VECTOR_LOWER_INDEX);
		-- ---------------------------------------------------------------------
		-- ---------------------------------------------------------------------
		-- deal with cases that are meta value ... may cause issues ... 
		-- IF NOT is_X(addr.index) THEN
			addr.index_as_integer := TO_INTEGER(UNSIGNED(addr.index));
		-- ELSE
		-- 	addr.index_as_integer := 0;
		-- END IF;
		-- IF NOT is_X(addr.offset(CALCULATE_OFFSET_VECTOR_UPPER_INDEX DOWNTO CALCULATE_OFFSET_VECTOR_UPPER_INDEX - 1)) THEN
			addr.offset_as_integer := TO_INTEGER(UNSIGNED(addr.offset(CALCULATE_OFFSET_VECTOR_UPPER_INDEX DOWNTO CALCULATE_OFFSET_VECTOR_UPPER_INDEX - 1)));
		-- ELSE
		-- 	addr.offset_as_integer := 0;
		-- END IF;
		-- Check whether the offset integer is correct.
		IF (addr.offset_as_integer > DEFAULT_BLOCK_SIZE - 1 OR addr.offset_as_integer < 0) THEN
			REPORT "offset as integer is false. " & INTEGER'IMAGE(addr.offset_as_integer) SEVERITY FAILURE;
		END IF;
		-- Check whether the index integer is correct.
		IF (addr.index_as_integer > DEFAULT_ADDRESS_WIDTH - 1 OR addr.index_as_integer < 0) THEN
			REPORT "index as integer is false. " & INTEGER'IMAGE(addr.index_as_integer) SEVERITY FAILURE;
		END IF;
		-- Return the memory address.
		RETURN addr;
	END TO_MEMORY_ADDRESS;
END cache_pkg;