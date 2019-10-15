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
	-- counter (auxiliary).
	signal counter : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
begin
-- NOT OPTIMAL....
	process(
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
	begin
		if(clk'event and rising_edge(clk))then
			-- initializing ...

			if  (reset = '1') then
				if (dirty = 'U')then
					dirty <= '0';
				end if;
				if (valid = 'U')then
					valid <= '0';
				end if;
			end if;
			
			--		counter <= 	counter-1 when state=READ_DATA and rising_edge(clk) else
			--					1		  when state=NOTHING;

			-- Update the counter.
			if state=READ_DATA then 
			counter <= 	counter-1;
			else
				counter <= 1;
			end if;

			-- -----------------------------------------------------------------------------
			-- Determines the read/write mode.
			-- -----------------------------------------------------------------------------
			-- state <= 		READ_DATA  when wr_word='0' AND rd_word='1' AND wr_cache_block_Line='0' AND rd_cache_block_line='0' else 
			-- 				WRITE_DATA when wr_word='1' AND rd_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='0' else 
			-- 				READ_LINE  when rd_word='0' and wr_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='1' else
			-- 				WRITE_LINE when rd_word='0' AND wr_word='0' AND wr_cache_block_Line='1' AND rd_cache_block_line='0' else 
			-- 				NOTHING;
			if (wr_word='0' AND rd_word='1' AND wr_cache_block_Line='0' AND rd_cache_block_line='0') then 
				state <= READ_DATA;
			elsif (wr_word='1' AND rd_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='0') then
				state <= WRITE_DATA;
			elsif (rd_word='0' and wr_word='0' AND wr_cache_block_Line='0' AND rd_cache_block_line='1') then
				state <= READ_LINE;
			elsif (rd_word='0' AND wr_word='0' AND wr_cache_block_Line='1' AND rd_cache_block_line='0' ) then
				state <= WRITE_LINE;
			else 
				state <= NOTHING;
			end if;

			-- -----------------------------------------------------------------------------
			-- Determine the offset, index and tag of the address signal.
			-- -----------------------------------------------------------------------------
			memoryAddress <= TO_MEMORY_ADDRESS( add_cpu); 
			index 		  <= memoryAddress.index;
			-- -----------------------------------------------------------------------------
			-- Determine the valid bit.
			-- -----------------------------------------------------------------------------
			-- valid <= valid_bits(memoryAddress.index_as_integer) when set_valid = '0' else 
			-- 		'Z';
			
			-- dirty <= dirty_bits(memoryAddress.index_as_integer) when set_dirty = '0' and rd_word='1' and reset = '0' else
			-- 		'Z' when set_dirty='1';

			if (set_valid = '0' ) then 
				valid <= valid_bits(memoryAddress.index_as_integer) ;
			else 
				valid <= 'Z';
			end if;
			if (set_dirty='1') then 
				dirty <= 'Z';
			elsif (set_dirty = '0' and rd_word='1' and reset = '0' ) then 
				dirty <= dirty_bits(memoryAddress.index_as_integer);
			end if;
			-- -----------------------------------------------------------------------------
			-- Reset directly the valid bits and the dirty bits when to reset.
			-- Otherwise, set the correspondent dirty bit and valid bit.
			-- -----------------------------------------------------------------------------
			--valid_bits <= (others=>'0') when reset='1' else
			--			MODIFY_VECTOR(memoryAddress.index_as_integer, valid_bits, '1') when write_to_data_brams='1';
			--dirty_bits <= (others=>'0') when reset='1' else
			--			MODIFY_VECTOR(memoryAddress.index_as_integer, dirty_bits, dirty) when set_dirty='1';
			if (reset='1') then 
				valid_bits <= (others=>'0');
			else 
				if (write_to_data_brams='1') then
					valid_bits <= MODIFY_VECTOR(memoryAddress.index_as_integer, valid_bits, '1') ;
				end if;
			end if;
			if (reset='1') then 
				dirty_bits <= (others=>'0');
			else 
				if (set_dirty='1') then
					dirty_bits <= MODIFY_VECTOR(memoryAddress.index_as_integer, dirty_bits, dirty);
				end if;
			end if;
			-- -----------------------------------------------------------------------------
			-- Determine whether a cache block/line should be read or written.
			-- -----------------------------------------------------------------------------
			-- cache_memory_data_bus <= data_from_bram when state=WRITE_DATA else
			-- 			data_from_bram when state=READ_DATA;
			if (state=WRITE_DATA) then 
				cache_memory_data_bus <= data_from_bram;
			else
				if (state=READ_DATA) then
					cache_memory_data_bus <= data_from_bram;
				end if;
			end if;
			-- -----------------------------------------------------------------------------
			-- Determine the new tag value to save in correspondent BRAM.
			-- -----------------------------------------------------------------------------
			
			-- tag_to_bram <= memoryAddress.tag when state=WRITE_DATA else 
			--			memoryAddress.tag when state=WRITE_LINE;
			if (state=WRITE_DATA) then 
				tag_to_bram <= memoryAddress.tag;
			else
				if (state=WRITE_LINE) then
					tag_to_bram <= memoryAddress.tag;
				end if;
			end if;
			-- -----------------------------------------------------------------------------
			-- Determine the start index and end index of the correspondent word in the cache line.
			-- -----------------------------------------------------------------------------
			data_start_index <= GET_START_INDEX( memoryAddress.offset_as_integer );
			data_end_index   <= GET_END_INDEX(memoryAddress.offset_as_integer);
			-- -----------------------------------------------------------------------------
			-- Determine the new cache block line.
			-- -----------------------------------------------------------------------------
			
			-- block_line_to_bram <= SET_BLOCK_LINE( block_line_from_bram, data_cpu, memoryAddress.offset_as_integer ) when state=WRITE_DATA else
			--				block_line_from_bram;
			
			if (state=WRITE_DATA) then 
				block_line_to_bram <= SET_BLOCK_LINE( block_line_from_bram, data_cpu, memoryAddress.offset_as_integer);
			else
				block_line_to_bram <= block_line_from_bram;
			end if;

			-- block_line_from_bram <= block_line_from_bram when state=READ_DATA and counter > 0 else
			-- 					TO_CACHE_BLOCK_LINE( data_from_bram );
			
			if (state=READ_DATA and counter > 0) then 
				block_line_from_bram <= block_line_from_bram;
			else
				block_line_from_bram <= TO_CACHE_BLOCK_LINE( data_from_bram);
			end if;

			-- data_to_bram <= new_cache_block_line when state=WRITE_LINE else 
			-- 			TO_STD_LOGIC_VECTOR( block_line_to_bram ) when state=WRITE_DATA;
			if (state=WRITE_LINE) then 
				data_to_bram <= new_cache_block_line;
			else
				if (state=WRITE_DATA) then
					data_to_bram <= TO_STD_LOGIC_VECTOR( block_line_to_bram );
				end if;
			end if;	
			-- data_cpu <= (others=>'0') when (state=READ_DATA and not(valid = '1' AND tags_are_equal = '1')) else
			-- 		(others=>'Z') when (wr_rd='1' ) else
			-- 		(others=>'0') when (state=READ_DATA and counter>0) else
			-- 		(block_line_from_bram(memoryAddress.offset_as_integer)) when state=READ_DATA else
			-- 		(others=>'Z');
			if (state=READ_DATA and not(valid = '1' AND tags_are_equal = '1')) then 
				data_cpu <= (others=>'0') ;
			else
				if (wr_rd='1') then
					data_cpu <= (others=>'Z');
				else
					if (state=READ_DATA and counter>0) then
							data_cpu <= (others=>'0');
					else
						if (state=READ_DATA) then
							data_cpu <= block_line_from_bram(memoryAddress.offset_as_integer);
						else
							data_cpu <= (others=>'Z');
						end if;
					end if;
				end if;
			end if;	
			-- -----------------------------------------------------------------------------
			-- Check whether to read or write the data BRAM.
			-- -----------------------------------------------------------------------------
			
			-- write_to_data_brams <= '0' when state=READ_DATA else 
			-- 					'1' when state=WRITE_DATA else 
			-- 					'1' when state=WRITE_LINE else
			-- 					'0' when state=READ_LINE else 
			-- 					'0';
			if (state=READ_DATA) then 
				write_to_data_brams <= '0';
			elsif (state=READ_LINE) then
				write_to_data_brams <= '0';
			elsif (state=WRITE_DATA) then 
				write_to_data_brams <= '1';
			elsif (state=WRITE_LINE) then
				write_to_data_brams <= '1';
			else
				write_to_data_brams<='0';
			end if;
			write_to_data_bram <= write_to_data_brams;
			write_to_tag_bram <= write_to_data_brams;
			
			-- tags_are_equal <= '1' when tag_from_bram=memoryAddress.tag else '0';
			-- hit 		 <= '1' when valid = '1' AND tags_are_equal = '1' else '0';

			if (tag_from_bram=memoryAddress.tag) then 
				tags_are_equal <= '1';
			else
				tags_are_equal<='0';
			end if;

			if (valid = '1' AND tags_are_equal = '1') then 
				hit <= '1';
			else
				hit<='0';
			end if;
		end if;
	end process;
	
end behaviour;
