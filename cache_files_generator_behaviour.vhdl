
architecture behaviour of cache_files_generator is
	constant number_of_bits_in_a_block       : INTEGER := DEFAULT_BLOCK_SIZE * DEFAULT_DATA_WIDTH;
begin
	process
		file tagFile : TEXT open WRITE_MODE is TAG_FILENAME & FILE_EXTENSION;
		file dataFile : TEXT open WRITE_MODE is DATA_FILENAME & FILE_EXTENSION;
		variable cacheBlock    : STD_LOGIC_VECTOR(number_of_bits_in_a_block - 1 downto 0) := (others => '0');
		variable tag           : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 downto 0)   := (others => '0');
		variable cacheTagLine  : LINE;
		variable cacheDataLine : LINE;

	begin
		for j in 0 to DEFAULT_ADDRESS_WIDTH - 1 loop
			hwrite(cacheTagLine, tag);
			writeline(tagFile, cacheTagLine);

			hwrite(cacheDataLine, cacheBlock);
			writeline(dataFile, cacheDataLine);
		end loop;

		wait;

	end process;

end architecture;