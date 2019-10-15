
package body cache_pkg is

	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_TAG_VECTOR_UPPER_INDEX return INTEGER is
			variable number_of_bits_allocated_for_tag : INTEGER := 0;     
			variable number_of_bits_allocated_for_offset : INTEGER := 0;     
			variable number_of_bits_allocated_for_index : INTEGER := 0;     
			variable r : INTEGER := 0;
		begin
			number_of_bits_allocated_for_tag    := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
			number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE)-1;
			number_of_bits_allocated_for_index  := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
			r := number_of_bits_allocated_for_offset + number_of_bits_allocated_for_index + number_of_bits_allocated_for_tag - 1;
			return r;
	end CALCULATE_TAG_VECTOR_UPPER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_TAG_VECTOR_LOWER_INDEX return INTEGER is
			variable r : INTEGER := 0;
			variable number_of_bits_allocated_for_tag : INTEGER := 0;     
			variable number_of_bits_allocated_for_offset : INTEGER := 0;     
			variable number_of_bits_allocated_for_index : INTEGER := 0;     
		begin
			number_of_bits_allocated_for_tag    := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
			number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE)-1;
			number_of_bits_allocated_for_index  := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
			r:= number_of_bits_allocated_for_offset + number_of_bits_allocated_for_index;
			return r;
	end CALCULATE_TAG_VECTOR_LOWER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_TAG_VECTOR_SIZE return INTEGER is
			variable r : INTEGER := 0;
		begin
			r:= CALCULATE_TAG_VECTOR_UPPER_INDEX - CALCULATE_TAG_VECTOR_LOWER_INDEX+1;
			return r;
	end CALCULATE_TAG_VECTOR_SIZE;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_INDEX_VECTOR_UPPER_INDEX return INTEGER is
			variable r : INTEGER := 0;
			variable number_of_bits_allocated_for_tag : INTEGER := 0;     
			variable number_of_bits_allocated_for_offset : INTEGER := 0;     
			variable number_of_bits_allocated_for_index : INTEGER := 0;     
		begin
			number_of_bits_allocated_for_tag    := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
			number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE)-1;
			number_of_bits_allocated_for_index  := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
			r         := number_of_bits_allocated_for_offset + number_of_bits_allocated_for_index - 1;
			return r;
	end CALCULATE_INDEX_VECTOR_UPPER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_INDEX_VECTOR_LOWER_INDEX return INTEGER is
			variable r : INTEGER := 0;
			variable number_of_bits_allocated_for_tag : INTEGER := 0;     
			variable number_of_bits_allocated_for_offset : INTEGER := 0;     
			variable number_of_bits_allocated_for_index : INTEGER := 0;     
		begin
			number_of_bits_allocated_for_tag    := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
			number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE)-1;
			number_of_bits_allocated_for_index  := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
			r         := number_of_bits_allocated_for_offset;		
			return r;
	end CALCULATE_INDEX_VECTOR_LOWER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_INDEX_VECTOR_SIZE return INTEGER is
			variable r : INTEGER := 0;
		begin
			r:= CALCULATE_INDEX_VECTOR_UPPER_INDEX - CALCULATE_INDEX_VECTOR_LOWER_INDEX+1;
			return r;
	end CALCULATE_INDEX_VECTOR_SIZE;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_OFFSET_VECTOR_UPPER_INDEX return INTEGER is
			variable r : INTEGER := 0;
			variable number_of_bits_allocated_for_tag : INTEGER := 0;     
			variable number_of_bits_allocated_for_offset : INTEGER := 0;     
			variable number_of_bits_allocated_for_index : INTEGER := 0;     
		begin
			number_of_bits_allocated_for_tag    := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
			number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE)-1;
			number_of_bits_allocated_for_index  := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
			r        := number_of_bits_allocated_for_offset - 1;
			return r;
	end CALCULATE_OFFSET_VECTOR_UPPER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_OFFSET_VECTOR_LOWER_INDEX return INTEGER is
			variable r : INTEGER := 0;
			variable number_of_bits_allocated_for_tag : INTEGER := 0;     
			variable number_of_bits_allocated_for_offset : INTEGER := 0;     
			variable number_of_bits_allocated_for_index : INTEGER := 0;     
		begin
			number_of_bits_allocated_for_tag    := CEIL_LOG_2(DEFAULT_ADDRESS_WIDTH);
			number_of_bits_allocated_for_offset := CEIL_LOG_2(DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH / DEFAULT_OFFSET_SIZE)-1;
			number_of_bits_allocated_for_index  := DEFAULT_MEMORY_ADDRESS_WIDTH - number_of_bits_allocated_for_tag - number_of_bits_allocated_for_offset;
			r        := 0;
			return r;
	end CALCULATE_OFFSET_VECTOR_LOWER_INDEX;
	-- -----------------------------------------------------------------------------------------------------------
	function CALCULATE_OFFSET_VECTOR_SIZE return INTEGER is
		variable r : INTEGER := 0;
		begin
			r:= CALCULATE_OFFSET_VECTOR_UPPER_INDEX - CALCULATE_OFFSET_VECTOR_LOWER_INDEX +1;
			return r;
	end CALCULATE_OFFSET_VECTOR_SIZE;
	-- -----------------------------------------------------------------------------------------------------------
	function GET_START_INDEX( offset : in INTEGER )  return INTEGER is
		variable number_of_bits_in_a_block : INTEGER := 0 ;
		begin
			number_of_bits_in_a_block       := DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH;
			return number_of_bits_in_a_block-1-(DEFAULT_DATA_WIDTH*offset);
	end function;
	-- -----------------------------------------------------------------------------------------------------------	
	function GET_END_INDEX ( offset : in INTEGER ) return INTEGER is
		variable number_of_bits_in_a_block : INTEGER := 0 ;
		begin
			number_of_bits_in_a_block       := DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH;
			return number_of_bits_in_a_block-1-(DEFAULT_DATA_WIDTH*offset)-DEFAULT_DATA_WIDTH+1;
	end function;
	-- -----------------------------------------------------------------------------------------------------------
	function TO_STD_LOGIC_VECTOR(ARG : in CACHE_BLOCK_LINE ) return STD_LOGIC_VECTOR is
		variable v : STD_LOGIC_VECTOR( DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0 ) := (others=>'0');
		variable start_idx, end_idx : INTEGER;
		begin 
			for I in 0 to DEFAULT_BLOCK_SIZE-1 loop
				start_idx := GET_START_INDEX(I);
				end_idx := GET_END_INDEX(I);
				v(start_idx downto end_idx) := ARG(I);
			end loop;
			return v;
	end function;
	-- -----------------------------------------------------------------------------------------------------------
	function SET_BLOCK_LINE( 
			b_in : in CACHE_BLOCK_LINE;
			data : in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0);
			offset : in INTEGER
		) return CACHE_BLOCK_LINE is
		variable b : CACHE_BLOCK_LINE;
	begin
		for I in 0 to DEFAULT_BLOCK_SIZE-1 loop
		if I=offset then
			b(I):=data;
		else
			b(I):=b_in(I);
		end if;
		end loop;
		return b;
	end function;
	-- -----------------------------------------------------------------------------------------------------------
	function TO_CACHE_BLOCK_LINE( ARG : in STD_LOGIC_VECTOR) return CACHE_BLOCK_LINE is
		variable block_line : CACHE_BLOCK_LINE;
		variable start_idx : INTEGER;
		variable end_idx : INTEGER;
	begin
		for I in 0 to DEFAULT_BLOCK_SIZE-1 loop
			start_idx := GET_START_INDEX(I);
			end_idx := GET_END_INDEX(I);
			block_line(I) := ARG( start_idx downto end_idx );
		end loop;
		return block_line;
	end function;
	-- -----------------------------------------------------------------------------------------------------------
	function TO_MEMORY_ADDRESS(ARG : in STD_LOGIC_VECTOR) return MEMORY_ADDRESS is
		variable addr : MEMORY_ADDRESS :=(
			tag => (others => '0'), 
			index => (others => '0'), 
			offset => (others => '0'), 
			index_as_integer =>0,
			offset_as_integer =>0 
		);
	begin
		addr.tag    := ARG(CALCULATE_TAG_VECTOR_UPPER_INDEX downto CALCULATE_TAG_VECTOR_LOWER_INDEX);
		addr.index  := ARG(CALCULATE_INDEX_VECTOR_UPPER_INDEX downto CALCULATE_INDEX_VECTOR_LOWER_INDEX);
		addr.offset := ARG(CALCULATE_OFFSET_VECTOR_UPPER_INDEX downto CALCULATE_OFFSET_VECTOR_LOWER_INDEX);
		-- ---------------------------------------------------------------------
		-- addr.index_as_integer := TO_INTEGER(UNSIGNED(addr.index));
		-- addr.offset_as_integer := TO_INTEGER(UNSIGNED(addr.offset(4 downto 3)));
		-- ---------------------------------------------------------------------
		-- deal with cases that are meta value ... may cause issues ... 
		if not is_X(addr.index) then
			addr.index_as_integer := TO_INTEGER(UNSIGNED(addr.index));
		else 
			addr.index_as_integer := 0 ;
		end if;
		if not is_X(addr.offset(CALCULATE_OFFSET_VECTOR_UPPER_INDEX downto CALCULATE_OFFSET_VECTOR_UPPER_INDEX-1)) then
			addr.offset_as_integer := TO_INTEGER(UNSIGNED(addr.offset(CALCULATE_OFFSET_VECTOR_UPPER_INDEX downto CALCULATE_OFFSET_VECTOR_UPPER_INDEX-1)));
		else 
			addr.offset_as_integer := 0 ;
		end if;
		-- Check whether the offset integer is correct.
		if (addr.offset_as_integer > DEFAULT_BLOCK_SIZE-1 or addr.offset_as_integer < 0) then
			report "offset as integer is false. " & INTEGER'IMAGE(addr.offset_as_integer) severity FAILURE; 
		end if;
		-- Check whether the index integer is correct.
		if (addr.index_as_integer > DEFAULT_ADDRESS_WIDTH-1 or addr.index_as_integer < 0) then
			report "index as integer is false. " & INTEGER'IMAGE(addr.index_as_integer) severity FAILURE;
		end if;
		-- Return the memory address.
		return addr;
	end TO_MEMORY_ADDRESS;
end cache_pkg;
