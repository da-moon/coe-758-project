ARCHITECTURE behaviour OF direct_mapped_cache_controller IS
	-- Memory address specifies which line and which data word in a cache block line should be read/written.
	SIGNAL memoryAddress : MEMORY_ADDRESS := (
	tag => (OTHERS => '0'),
	index => (OTHERS => '0'),
	offset => (OTHERS => '0'),
	index_as_integer => 0,
	offset_as_integer => 0
	);
	-- -----------------------------------------------------------------------------------------
	-- Bit string contains for each cache block the correspondent valid bit.
	SIGNAL valid_bits : STD_LOGIC_VECTOR(DEFAULT_ADDRESS_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	-- -----------------------------------------------------------------------------------------
	-- Bit string contains for each cache block the correspondent dirty bit.
	-- 1 --> block line is modified
	-- 0 --> block line is unmodified.
	SIGNAL dirty_bits : STD_LOGIC_VECTOR(DEFAULT_ADDRESS_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	-- -----------------------------------------------------------------------------------------
	-- Signal identifies whether the tag of a 
	-- cache block and the tag of the given memory address are equal.
	SIGNAL tags_are_equal : STD_LOGIC := '0';
	-- -----------------------------------------------------------------------------------------
	-- Start index of the word in the cache line.
	SIGNAL data_start_index : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
	-- End index of the word in the cache line.
	SIGNAL data_end_index : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
	--  signals writing data to b_ram
	SIGNAL write_to_data_brams : STD_LOGIC := '0';
	-- -----------------------------------------------------------------------------------------
	-- Current state of the controller.
	SIGNAL state : STATE_TYPE := NOTHING;
	-- -----------------------------------------------------------------------------------------
	-- Cache block read from the BRAM.
	SIGNAL block_line_from_bram : CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------
	-- Cache block written to BRAM.
	SIGNAL block_line_to_bram : CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------
	-- counter (auxiliary).
	SIGNAL counter : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
BEGIN
	-- NOT OPTIMAL....
	PROCESS (
		clk,
		reset,
		add_cpu,
		data_cpu,
		valid,
		dirty,
		set_valid,
		set_dirty,
		wr_word,
		wr_rd,
		wr_cache_block_Line,
		rd_cache_block_line,
		tag_from_bram,
		data_from_bram,
		new_cache_block_line
		)
	BEGIN
		IF (clk'event AND rising_edge(clk)) THEN
			-- initializing ...

			IF (reset = '1') THEN
				IF (dirty = 'U') THEN
					dirty <= '0';
				END IF;
				IF (valid = 'U') THEN
					valid <= '0';
				END IF;
			END IF;

			--		counter <= 	counter-1 when state=READ_DATA and rising_edge(clk) else
			--					1		  when state=NOTHING;

			-- Update the counter.
			IF state = READ_DATA THEN
				counter <= counter - 1;
			ELSE
				counter <= 1;
			END IF;

			-- -----------------------------------------------------------------------------
			-- Determines the read/write mode.
			-- -----------------------------------------------------------------------------
			-- state <= 		READ_DATA  when wr_word='0' AND rd_word='1' AND wr_cache_block_Line='0' AND rd_cache_block_line='0' else 
			-- 				WRITE_DATA when wr_word='1' AND rd_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='0' else 
			-- 				READ_LINE  when rd_word='0' and wr_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='1' else
			-- 				WRITE_LINE when rd_word='0' AND wr_word='0' AND wr_cache_block_Line='1' AND rd_cache_block_line='0' else 
			-- 				NOTHING;
			IF (wr_word = '0' AND rd_word = '1' AND wr_cache_block_Line = '0' AND rd_cache_block_line = '0') THEN
				state <= READ_DATA;
			ELSIF (wr_word = '1' AND rd_word = '0' AND wr_cache_block_Line = '0' AND rd_cache_block_line = '0') THEN
				state <= WRITE_DATA;
			ELSIF (rd_word = '0' AND wr_word = '0' AND wr_cache_block_Line = '0' AND rd_cache_block_line = '1') THEN
				state <= READ_LINE;
			ELSIF (rd_word = '0' AND wr_word = '0' AND wr_cache_block_Line = '1' AND rd_cache_block_line = '0') THEN
				state <= WRITE_LINE;
			ELSE
				state <= NOTHING;
			END IF;

			-- -----------------------------------------------------------------------------
			-- Determine the offset, index and tag of the address signal.
			-- -----------------------------------------------------------------------------
			memoryAddress <= TO_MEMORY_ADDRESS(add_cpu);
			index <= memoryAddress.index;
			-- -----------------------------------------------------------------------------
			-- Determine the valid bit.
			-- -----------------------------------------------------------------------------
			-- valid <= valid_bits(memoryAddress.index_as_integer) when set_valid = '0' else 
			-- 		'Z';

			-- dirty <= dirty_bits(memoryAddress.index_as_integer) when set_dirty = '0' and rd_word='1' and reset = '0' else
			-- 		'Z' when set_dirty='1';

			IF (set_valid = '0') THEN
				valid <= valid_bits(memoryAddress.index_as_integer);
			ELSE
				valid <= 'Z';
			END IF;
			IF (set_dirty = '1') THEN
				dirty <= 'Z';
			ELSIF (set_dirty = '0' AND rd_word = '1' AND reset = '0') THEN
				dirty <= dirty_bits(memoryAddress.index_as_integer);
			END IF;
			-- -----------------------------------------------------------------------------
			-- Reset directly the valid bits and the dirty bits when to reset.
			-- Otherwise, set the correspondent dirty bit and valid bit.
			-- -----------------------------------------------------------------------------
			--valid_bits <= (others=>'0') when reset='1' else
			--			MODIFY_VECTOR(memoryAddress.index_as_integer, valid_bits, '1') when write_to_data_brams='1';
			--dirty_bits <= (others=>'0') when reset='1' else
			--			MODIFY_VECTOR(memoryAddress.index_as_integer, dirty_bits, dirty) when set_dirty='1';
			IF (reset = '1') THEN
				valid_bits <= (OTHERS => '0');
			ELSE
				IF (write_to_data_brams = '1') THEN
					valid_bits <= MODIFY_VECTOR(memoryAddress.index_as_integer, valid_bits, '1');
				END IF;
			END IF;
			IF (reset = '1') THEN
				dirty_bits <= (OTHERS => '0');
			ELSE
				IF (set_dirty = '1') THEN
					dirty_bits <= MODIFY_VECTOR(memoryAddress.index_as_integer, dirty_bits, dirty);
				END IF;
			END IF;
			-- -----------------------------------------------------------------------------
			-- Determine whether a cache block/line should be read or written.
			-- -----------------------------------------------------------------------------
			-- cache_memory_data_bus <= data_from_bram when state=WRITE_DATA else
			-- 			data_from_bram when state=READ_DATA;
			IF (state = WRITE_DATA) THEN
				cache_memory_data_bus <= data_from_bram;
			ELSE
				IF (state = READ_DATA) THEN
					cache_memory_data_bus <= data_from_bram;
				END IF;
			END IF;
			-- -----------------------------------------------------------------------------
			-- Determine the new tag value to save in correspondent BRAM.
			-- -----------------------------------------------------------------------------

			-- tag_to_bram <= memoryAddress.tag when state=WRITE_DATA else 
			--			memoryAddress.tag when state=WRITE_LINE;
			IF (state = WRITE_DATA) THEN
				tag_to_bram <= memoryAddress.tag;
			ELSE
				IF (state = WRITE_LINE) THEN
					tag_to_bram <= memoryAddress.tag;
				END IF;
			END IF;
			-- -----------------------------------------------------------------------------
			-- Determine the start index and end index of the correspondent word in the cache line.
			-- -----------------------------------------------------------------------------
			data_start_index <= GET_START_INDEX(memoryAddress.offset_as_integer);
			data_end_index <= GET_END_INDEX(memoryAddress.offset_as_integer);
			-- -----------------------------------------------------------------------------
			-- Determine the new cache block line.
			-- -----------------------------------------------------------------------------

			-- block_line_to_bram <= SET_BLOCK_LINE( block_line_from_bram, data_cpu, memoryAddress.offset_as_integer ) when state=WRITE_DATA else
			--				block_line_from_bram;

			IF (state = WRITE_DATA) THEN
				block_line_to_bram <= SET_BLOCK_LINE(block_line_from_bram, data_cpu, memoryAddress.offset_as_integer);
			ELSE
				block_line_to_bram <= block_line_from_bram;
			END IF;

			-- block_line_from_bram <= block_line_from_bram when state=READ_DATA and counter > 0 else
			-- 					TO_CACHE_BLOCK_LINE( data_from_bram );

			IF (state = READ_DATA AND counter > 0) THEN
				block_line_from_bram <= block_line_from_bram;
			ELSE
				block_line_from_bram <= TO_CACHE_BLOCK_LINE(data_from_bram);
			END IF;

			-- data_to_bram <= new_cache_block_line when state=WRITE_LINE else 
			-- 			TO_STD_LOGIC_VECTOR( block_line_to_bram ) when state=WRITE_DATA;
			IF (state = WRITE_LINE) THEN
				data_to_bram <= new_cache_block_line;
			ELSE
				IF (state = WRITE_DATA) THEN
					data_to_bram <= TO_STD_LOGIC_VECTOR(block_line_to_bram);
				END IF;
			END IF;
			-- data_cpu <= (others=>'0') when (state=READ_DATA and not(valid = '1' AND tags_are_equal = '1')) else
			-- 		(others=>'Z') when (wr_rd='1' ) else
			-- 		(others=>'0') when (state=READ_DATA and counter>0) else
			-- 		(block_line_from_bram(memoryAddress.offset_as_integer)) when state=READ_DATA else
			-- 		(others=>'Z');
			IF (state = READ_DATA AND NOT(valid = '1' AND tags_are_equal = '1')) THEN
				data_cpu <= (OTHERS => '0');
			ELSE
				IF (wr_rd = '1') THEN
					data_cpu <= (OTHERS => 'Z');
				ELSE
					IF (state = READ_DATA AND counter > 0) THEN
						data_cpu <= (OTHERS => '0');
					ELSE
						IF (state = READ_DATA) THEN
							data_cpu <= block_line_from_bram(memoryAddress.offset_as_integer);
						ELSE
							data_cpu <= (OTHERS => 'Z');
						END IF;
					END IF;
				END IF;
			END IF;
			-- -----------------------------------------------------------------------------
			-- Check whether to read or write the data BRAM.
			-- -----------------------------------------------------------------------------

			-- write_to_data_brams <= '0' when state=READ_DATA else 
			-- 					'1' when state=WRITE_DATA else 
			-- 					'1' when state=WRITE_LINE else
			-- 					'0' when state=READ_LINE else 
			-- 					'0';
			IF (state = READ_DATA) THEN
				write_to_data_brams <= '0';
			ELSIF (state = READ_LINE) THEN
				write_to_data_brams <= '0';
			ELSIF (state = WRITE_DATA) THEN
				write_to_data_brams <= '1';
			ELSIF (state = WRITE_LINE) THEN
				write_to_data_brams <= '1';
			ELSE
				write_to_data_brams <= '0';
			END IF;
			write_to_data_bram <= write_to_data_brams;
			write_to_tag_bram <= write_to_data_brams;

			-- tags_are_equal <= '1' when tag_from_bram=memoryAddress.tag else '0';
			-- hit 		 <= '1' when valid = '1' AND tags_are_equal = '1' else '0';

			IF (tag_from_bram = memoryAddress.tag) THEN
				tags_are_equal <= '1';
			ELSE
				tags_are_equal <= '0';
			END IF;

			IF (valid = '1' AND tags_are_equal = '1') THEN
				hit <= '1';
			ELSE
				hit <= '0';
			END IF;
		END IF;
	END PROCESS;

END behaviour;