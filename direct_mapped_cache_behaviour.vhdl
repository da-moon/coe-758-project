ARCHITECTURE behaviour OF direct_mapped_cache IS
	SUBTYPE CACHE_BLOCK_LINE_RANGE IS NATURAL RANGE (DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH) - 1 DOWNTO 0;
	SUBTYPE TAG_RANGE IS NATURAL RANGE CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0;
	-- Index identifies the line in the BRAMs.
	SIGNAL index : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 DOWNTO 0);
	-- Signal identifies whether a tag should be written ('1') to BRAM or should be read ('0') from BRAM.
	SIGNAL write_to_tag_bram : STD_LOGIC := '0';
	-- Cache block to be read from BRAM.  
	SIGNAL cache_block_from_bram : STD_LOGIC_VECTOR(CACHE_BLOCK_LINE_RANGE) := (OTHERS => '0');
	-- Cache block to be written into BRAM.
	SIGNAL cache_block_to_bram : STD_LOGIC_VECTOR(CACHE_BLOCK_LINE_RANGE) := (OTHERS => '0');
	-- Tag to be read from BRAM. 
	SIGNAL tag_from_bram : STD_LOGIC_VECTOR(TAG_RANGE);
	-- Tag to be written into BRAM.
	SIGNAL tag_to_bram : STD_LOGIC_VECTOR(TAG_RANGE);
	-- Signal identifies whether a cache block should be written ('1') to BRAM or should be read ('0') from BRAM.
	SIGNAL write_to_data_bram : STD_LOGIC := '0';

BEGIN

	direct_mapped_cache_controller : ENTITY work.direct_mapped_cache_controller

		PORT MAP(
			-- Clock and reset signal.
			clk => clk,
			reset => reset,
			-- Ports regarding CPU and MEM.
			add_cpu => add_cpu,
			data_cpu => data_cpu,
			cache_memory_data_bus => cache_memory_data_bus,
			new_cache_block_line => new_cache_block_line,
			valid => valid,
			dirty => dirty,
			set_valid => set_valid,
			set_dirty => set_dirty,
			hit => hit,
			-- Ports defines how to read or write the data BRAM.
			wr_cache_block_Line => wr_cache_block_Line,
			rd_cache_block_line => rd_cache_block_line,
			rd_word => rd_word,
			wr_word => wr_word,
			wr_rd => wr_rd,
			-- Index determines to which line of BRAM should be written or read.
			index => index,
			-- Ports regarding BRAM tag.
			tag_from_bram => tag_from_bram,
			tag_to_bram => tag_to_bram,
			write_to_tag_bram => write_to_tag_bram,

			-- Ports regarding BRAM data.
			data_to_bram => cache_block_to_bram,
			data_from_bram => cache_block_from_bram,
			write_to_data_bram => write_to_data_bram
		);

	-- The tag area should be BRAM blocks.
	-- -----------------------------------------------------------------------------
	BRAM_Tag : ENTITY work.bram
		GENERIC MAP(
			RamFileName => (TAG_FILENAME & FILE_EXTENSION),
			ADDR => CALCULATE_INDEX_VECTOR_SIZE,
			DATA => CALCULATE_TAG_VECTOR_SIZE,
			MODE => WRITE_FIRST
		)
		PORT MAP(clk, write_to_tag_bram, index, tag_to_bram, tag_from_bram);
	-- -----------------------------------------------------------------------------
	-- The data area should be BRAM blocks.
	-- -----------------------------------------------------------------------------
	BRAM_Data : ENTITY work.bram
		GENERIC MAP(
			RamFileName => (DATA_FILENAME & FILE_EXTENSION),
			ADDR => CALCULATE_INDEX_VECTOR_SIZE,
			DATA => DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH,
			MODE => WRITE_FIRST
		)
		PORT MAP(clk, write_to_data_bram, index, cache_block_to_bram, cache_block_from_bram);

END behaviour;