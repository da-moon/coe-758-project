use std.textio.all;

architecture behaviour of direct_mapped_cache_controller is
	-- Memory address specifies which line and which data word in a cache block line should be read/written.
	signal memoryAddress : MEMORY_ADDRESS :=(
		tag => (others => '0'), 
		index => (others => '0'), 
		offset => (others => '0'), 
		indexAsInteger =>0,
		offsetAsInteger =>0 
	);
	-- -----------------------------------------------------------------------------------------
	-- Bit string contains for each cache block the correspondent valid bit.
	signal validBits : STD_LOGIC_VECTOR(DEFAULT_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
	-- -----------------------------------------------------------------------------------------
	-- Bit string contains for each cache block the correspondent dirty bit.
	-- 1 --> block line is modified
	-- 0 --> block line is unmodified.
	signal dirtyBits : STD_LOGIC_VECTOR(DEFAULT_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
	-- -----------------------------------------------------------------------------------------
	-- Signal identifies whether the tag of a 
	-- cache block and the tag of the given memory address are equal.
	signal tagsAreEqual : STD_LOGIC := '0';
	-- -----------------------------------------------------------------------------------------
	-- Start index of the word in the cache line.
	signal dataStartIndex : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
	-- End index of the word in the cache line.
	signal dataEndIndex : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
	--  signals writing data to b_ram
	signal writeToDataBRAMs : STD_LOGIC := '0';
	-- -----------------------------------------------------------------------------------------
	-- Current state of the controller.
	signal state : STATE_TYPE := NOTHING;
	-- -----------------------------------------------------------------------------------------
  	-- Cache block read from the BRAM.
	signal blockLineFromBRAM : CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------
	-- Cache block written to BRAM.
	signal blockLineToBRAM : CACHE_BLOCK_LINE;
	-- -----------------------------------------------------------------------------------------
	-- Auxiliary counter.
	signal counter : INTEGER := 0;
	-- -----------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------
begin
	
	-- Update the auxiliary counter.
	counter <= 	counter-1 when state=READ_DATA and rising_edge(clk) else
				1		  when state=NOTHING;
	-- -----------------------------------------------------------------------------
	-- Determines the read/write mode.
	-- -----------------------------------------------------------------------------
	state <= 		READ_DATA  when wrWord='0' AND rdWord='1' AND wrCBLine='0' AND rdCBLine='0' else 
	 	           	WRITE_DATA when wrWord='1' AND rdWord='0' AND wrCBLine='0' AND rdCBLine='0' else 
	 	           	READ_LINE  when rdWord='0' and wrWord='0' AND wrCBLine='0' AND rdCBLine='1' else
	 	           	WRITE_LINE when rdWord='0' AND wrWord='0' AND wrCBLine='1' AND rdCBLine='0' else 
	 	           	NOTHING;
	-- -----------------------------------------------------------------------------
	-- Determine the offset, index and tag of the address signal.
	-- -----------------------------------------------------------------------------
	memoryAddress <= TO_MEMORY_ADDRESS( addrCPU); 
	-- TODO UNCOMMENT
	index 		  <= memoryAddress.index;

	-- -----------------------------------------------------------------------------
	-- Determine the valid bit.
	-- -----------------------------------------------------------------------------
	valid <= validBits(memoryAddress.indexAsInteger) when setValid = '0' else 
	         'Z';
	dirty <= dirtyBits(memoryAddress.indexAsInteger) when setDirty = '0' and rdWord='1' and reset = '0' else
	         'Z' when setDirty='1';

	-- -----------------------------------------------------------------------------
	-- Reset directly the valid bits and the dirty bits when to reset.
	-- Otherwise, set the correspondent dirty bit and valid bit.
	-- -----------------------------------------------------------------------------
	validBits <= (others=>'0') when reset='1' else
				 RETURN_MODIFIED_VECTOR(memoryAddress.indexAsInteger, validBits, '1') when writeToDataBRAMs='1';
	dirtyBits <= (others=>'0') when reset='1' else
		         RETURN_MODIFIED_VECTOR(memoryAddress.indexAsInteger, dirtyBits, dirty) when setDirty='1';

	-- -----------------------------------------------------------------------------
	-- Determine whether a cache block/line should be read or written.
	-- -----------------------------------------------------------------------------
	dataToMEM <= dataFromBRAM when state=WRITE_DATA else
				 dataFromBRAM when state=READ_DATA;

	-- -----------------------------------------------------------------------------
	-- Determine the new tag value to save in correspondent BRAM.
	-- -----------------------------------------------------------------------------
	tagToBRAM <= memoryAddress.tag when state=WRITE_DATA else 
	             memoryAddress.tag when state=WRITE_LINE;

	-- -----------------------------------------------------------------------------
	-- Determine the start index and end index of the correspondent word in the cache line.
	-- -----------------------------------------------------------------------------
	dataStartIndex <= GET_START_INDEX( memoryAddress.offsetAsInteger );
	dataEndIndex   <= GET_END_INDEX(memoryAddress.offsetAsInteger);
	-- -----------------------------------------------------------------------------
	-- Determine the new cache block line.
	-- -----------------------------------------------------------------------------
	blockLineToBRAM <= SET_BLOCK_LINE( blockLineFromBRAM, dataCPU, memoryAddress.offsetAsInteger ) when state=WRITE_DATA else
					   blockLineFromBRAM;
	blockLineFromBRAM <= blockLineFromBRAM when state=READ_DATA and counter > 0 else
		 				 TO_CACHE_BLOCK_LINE( dataFromBRAM );
	dataToBRAM <= newCacheBlockLine when state=WRITE_LINE else 
	              TO_STD_LOGIC_VECTOR( blockLineToBRAM ) when state=WRITE_DATA;

	dataCPU <= (others=>'0') when (state=READ_DATA and not(valid = '1' AND tagsAreEqual = '1')	) else
			   (others=>'Z') when (writeMode='1' 												) else
			   (others=>'0') when (state=READ_DATA and counter>0) else
			   (blockLineFromBRAM(memoryAddress.offsetAsInteger)) when state=READ_DATA else
		       (others=>'Z');

	-- -----------------------------------------------------------------------------
	-- Check whether to read or write the data BRAM.
	-- -----------------------------------------------------------------------------
	 writeToDataBRAMs <= '0' when state=READ_DATA else 
	 	                 '1' when state=WRITE_DATA else 
	 	                 '1' when state=WRITE_LINE else
	 	                 '0' when state=READ_LINE else 
	 	                 '0';
	 writeToDataBRAM <= writeToDataBRAMs;
	 writeToTagBRAM <= writeToDataBRAMs;
	  
	-- -----------------------------------------------------------------------------
	-- The hit signal is supposed to be an asynchronous signal.
	-- -----------------------------------------------------------------------------
	tagsAreEqual <= '1' when tagFromBRAM=memoryAddress.tag else '0';
	hit 		 <= '1' when valid = '1' AND tagsAreEqual = '1' else '0';

end behaviour;
