
ARCHITECTURE behaviour OF cache_files_generator IS
	CONSTANT number_of_bits_in_a_block : INTEGER := DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH;
BEGIN
	PROCESS
		FILE tagFile : TEXT OPEN WRITE_MODE IS TAG_FILENAME & FILE_EXTENSION;
		FILE dataFile : TEXT OPEN WRITE_MODE IS DATA_FILENAME & FILE_EXTENSION;
		VARIABLE cacheBlock : STD_LOGIC_VECTOR(number_of_bits_in_a_block - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE tag : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0) := (OTHERS => '0');
		VARIABLE cacheTagLine : LINE;
		VARIABLE cacheDataLine : LINE;

	BEGIN
		FOR j IN 0 TO DEFAULT_ADDRESS_WIDTH - 1 LOOP
			hwrite(cacheTagLine, tag);
			writeline(tagFile, cacheTagLine);
			hwrite(cacheDataLine, cacheBlock);
			writeline(dataFile, cacheDataLine);
		END LOOP;

		WAIT;

	END PROCESS;

END ARCHITECTURE;