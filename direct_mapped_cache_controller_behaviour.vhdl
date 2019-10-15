architecture behaviour of direct_mapped_cache_controller is
	-- Memory address specifies which line and which data word in a cache block line should be read/written.
	signal memoryAddress : MEMORY_ADDRESS :=(
		tag => (others => '0'), 
		index => (others => '0'), 
		offset => (others => '0'), 
		index_as_integer =>0,
		offset_as_integer =>0 
	);
	-- -----------------------------------------------------------------------------------------
	-- Bit string contains for each cache block the correspondent valid bit.
	signal valid_bits : STD_LOGIC_VECTOR(DEFAULT_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
	-- -----------------------------------------------------------------------------------------
	-- Bit string contains for each cache block the correspondent dirty bit.
	-- 1 --> block line is modified
	-- 0 --> block line is unmodified.
	signal dirty_bits : STD_LOGIC_VECTOR(DEFAULT_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
	-- -----------------------------------------------------------------------------------------
	-- Signal identifies whether the tag of a 
	-- cache block and the tag of the given memory address are equal.
	signal tags_are_equal : STD_LOGIC := '0';
	-- -----------------------------------------------------------------------------------------
	-- Start index of the word in the cache line.
	signal data_start_index : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
	-- End index of the word in the cache line.
	signal data_end_index : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
	--  signals writing data to b_ram
	signal write_to_data_brams : STD_LOGIC := '0';
	-- -----------------------------------------------------------------------------------------
	-- Current state of the controller.
	signal state : STATE_TYPE := NOTHING;
	-- -----------------------------------------------------------------------------------------
  	-- Cache block read from the BRAM.
	signal block_line_from_bram : CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------
	-- Cache block written to BRAM.
	signal block_line_to_bram : CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------
	-- Auxiliary counter.
	signal counter : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
begin
	
	-- Update the auxiliary counter.
	counter <= 	counter-1 when state=READ_DATA and rising_edge(clk) else
				1		  when state=NOTHING;
	-- -----------------------------------------------------------------------------
	-- Determines the read/write mode.
	-- -----------------------------------------------------------------------------
	state <= 		READ_DATA  when wr_word='0' AND rd_word='1' AND wr_cache_block_Line='0' AND rd_cache_block_line='0' else 
	 	           	WRITE_DATA when wr_word='1' AND rd_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='0' else 
	 	           	READ_LINE  when rd_word='0' and wr_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='1' else
	 	           	WRITE_LINE when rd_word='0' AND wr_word='0' AND wr_cache_block_Line='1' AND rd_cache_block_line='0' else 
	 	           	NOTHING;
	-- -----------------------------------------------------------------------------
	-- Determine the offset, index and tag of the address signal.
	-- -----------------------------------------------------------------------------
	memoryAddress <= TO_MEMORY_ADDRESS( add_cpu); 
	-- TODO UNCOMMENT
	index 		  <= memoryAddress.index;
	-- -----------------------------------------------------------------------------
	-- Determine the valid bit.
	-- -----------------------------------------------------------------------------
	valid <= valid_bits(memoryAddress.index_as_integer) when set_valid = '0' else 
	         'Z';
	dirty <= dirty_bits(memoryAddress.index_as_integer) when set_dirty = '0' and rd_word='1' and reset = '0' else
	         'Z' when set_dirty='1';

	-- -----------------------------------------------------------------------------
	-- Reset directly the valid bits and the dirty bits when to reset.
	-- Otherwise, set the correspondent dirty bit and valid bit.
	-- -----------------------------------------------------------------------------
	valid_bits <= (others=>'0') when reset='1' else
				 MODIFY_VECTOR(memoryAddress.index_as_integer, valid_bits, '1') when write_to_data_brams='1';
	dirty_bits <= (others=>'0') when reset='1' else
		         MODIFY_VECTOR(memoryAddress.index_as_integer, dirty_bits, dirty) when set_dirty='1';

	-- -----------------------------------------------------------------------------
	-- Determine whether a cache block/line should be read or written.
	-- -----------------------------------------------------------------------------
	cache_memory_data_bus <= data_from_bram when state=WRITE_DATA else
				 data_from_bram when state=READ_DATA;

	-- -----------------------------------------------------------------------------
	-- Determine the new tag value to save in correspondent BRAM.
	-- -----------------------------------------------------------------------------
	tag_to_bram <= memoryAddress.tag when state=WRITE_DATA else 
	             memoryAddress.tag when state=WRITE_LINE;

	-- -----------------------------------------------------------------------------
	-- Determine the start index and end index of the correspondent word in the cache line.
	-- -----------------------------------------------------------------------------
	data_start_index <= GET_START_INDEX( memoryAddress.offset_as_integer );
	data_end_index   <= GET_END_INDEX(memoryAddress.offset_as_integer);
	-- -----------------------------------------------------------------------------
	-- Determine the new cache block line.
	-- -----------------------------------------------------------------------------
	block_line_to_bram <= SET_BLOCK_LINE( block_line_from_bram, data_cpu, memoryAddress.offset_as_integer ) when state=WRITE_DATA else
					   block_line_from_bram;
	block_line_from_bram <= block_line_from_bram when state=READ_DATA and counter > 0 else
		 				 TO_CACHE_BLOCK_LINE( data_from_bram );
	data_to_bram <= new_cache_block_line when state=WRITE_LINE else 
	              TO_STD_LOGIC_VECTOR( block_line_to_bram ) when state=WRITE_DATA;

	data_cpu <= (others=>'0') when (state=READ_DATA and not(valid = '1' AND tags_are_equal = '1')	) else
			   (others=>'Z') when (wr_rd='1' 												) else
			   (others=>'0') when (state=READ_DATA and counter>0) else
			   (block_line_from_bram(memoryAddress.offset_as_integer)) when state=READ_DATA else
		       (others=>'Z');

	-- -----------------------------------------------------------------------------
	-- Check whether to read or write the data BRAM.
	-- -----------------------------------------------------------------------------
	 write_to_data_brams <= '0' when state=READ_DATA else 
	 	                 '1' when state=WRITE_DATA else 
	 	                 '1' when state=WRITE_LINE else
	 	                 '0' when state=READ_LINE else 
	 	                 '0';
	 write_to_data_bram <= write_to_data_brams;
	 write_to_tag_bram <= write_to_data_brams;
	  
	-- -----------------------------------------------------------------------------
	-- The hit signal is supposed to be an asynchronous signal.
	-- -----------------------------------------------------------------------------
	tags_are_equal <= '1' when tag_from_bram=memoryAddress.tag else '0';
	hit 		 <= '1' when valid = '1' AND tags_are_equal = '1' else '0';

end behaviour;
