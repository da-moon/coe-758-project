LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE IEEE.MATH_REAL.ALL;
USE std.textio.ALL;
USE work.cache_pkg.ALL;
USE work.utils_pkg.ALL;
USE work.cache_test_pkg.ALL;
ENTITY direct_mapped_cache_tb IS
	GENERIC (
		TAG_FILENAME : STRING := "./imem/tag";
		DATA_FILENAME : STRING := "./imem/data";
		FILE_EXTENSION : STRING := ".txt"
	);
END;
		

ARCHITECTURE testbench OF direct_mapped_cache_tb IS
	CONSTANT clock_period : TIME := 10 ns;
	CONSTANT C_FILE_NAME : STRING := "test_results/direct_mapped_cache.txt";
	
	-- Auxiliary procedure to print a break line.
	PROCEDURE REPORT_BREAK_LINE IS
	BEGIN
		REPORT break_line SEVERITY NOTE;
	END;
	SIGNAL reset : STD_LOGIC := '0';
	SIGNAL clk : STD_LOGIC := '0';
	SIGNAL add_cpu : STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');
	SIGNAL data_cpu : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => 'Z');
	SIGNAL valid : STD_LOGIC := '0';
	SIGNAL dirty : STD_LOGIC := '0';
	SIGNAL hit : STD_LOGIC := '0';
	SIGNAL wr_rd : STD_LOGIC := '0';
	SIGNAL cache_memory_data_bus : STD_LOGIC_VECTOR(CACHE_BLOCK_LINE_RANGE) := (OTHERS => '0');
	SIGNAL new_cache_block_line : STD_LOGIC_VECTOR(CACHE_BLOCK_LINE_RANGE);
	SIGNAL rd_word : STD_LOGIC := '0';
	SIGNAL wr_word : STD_LOGIC := '0';
	SIGNAL rd_cache_block_line : STD_LOGIC := '0';
	SIGNAL wr_cache_block_Line : STD_LOGIC := '0';
	SIGNAL set_valid : STD_LOGIC := '0';
	SIGNAL set_dirty : STD_LOGIC := '0';
	SIGNAL my_data_word : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0) := (OTHERS => '0');

	SIGNAL eof : std_logic := '0';
	FILE fptr : text;

	-- clock gen component
	COMPONENT clock_gen
		GENERIC (clock_period : TIME);
		PORT (
			clk : OUT std_logic
		);
	END COMPONENT;
	COMPONENT direct_mapped_cache
		GENERIC (
			TAG_FILENAME : STRING;
			DATA_FILENAME : STRING;
			FILE_EXTENSION : STRING
		);
		PORT (
			clk : IN STD_LOGIC;
			reset : IN STD_LOGIC;
			add_cpu : IN STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH - 1 DOWNTO 0);
			data_cpu : INOUT STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 DOWNTO 0);
			new_cache_block_line : IN STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0);
			cache_memory_data_bus : OUT STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH * DEFAULT_BLOCK_SIZE - 1 DOWNTO 0);
			wr_cache_block_Line : IN STD_LOGIC;
			rd_cache_block_line : IN STD_LOGIC;
			rd_word : IN STD_LOGIC;
			wr_word : IN STD_LOGIC;
			wr_rd : IN STD_LOGIC;
			valid : INOUT STD_LOGIC;
			dirty : INOUT STD_LOGIC;
			set_valid : IN STD_LOGIC;
			set_dirty : IN STD_LOGIC;
			hit : OUT STD_LOGIC
		);
	END COMPONENT;

BEGIN
	-- Clock generator instl
	clock_gen_instl : clock_gen
	GENERIC MAP(clock_period => clock_period)
	PORT MAP(
		clk => clk
	);
	-- unit under test
	uut : direct_mapped_cache
	GENERIC MAP(
		TAG_FILENAME => TAG_FILENAME,
		DATA_FILENAME => DATA_FILENAME,
		FILE_EXTENSION => FILE_EXTENSION
	)
	PORT MAP(
		clk => clk,
		reset => reset,
		data_cpu => data_cpu,
		add_cpu => add_cpu,
		cache_memory_data_bus => cache_memory_data_bus,
		rd_word => rd_word,
		wr_word => wr_word,
		wr_cache_block_Line => wr_cache_block_Line,
		rd_cache_block_line => rd_cache_block_line,
		wr_rd => wr_rd,
		valid => valid,
		dirty => dirty,
		set_valid => set_valid,
		set_dirty => set_dirty,
		hit => hit,
		new_cache_block_line => new_cache_block_line
	);
		--  
		--  
		--  
		--  
		--  
		-- 
		
	stim_proc : PROCESS
	
		-- Coverage aray of the tags cpu generates
		
		VARIABLE tag1, tag2 : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 DOWNTO 0);
		VARIABLE index : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 DOWNTO 0);
		VARIABLE offset : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 DOWNTO 0);
		VARIABLE irand : INTEGER;
		VARIABLE seed1, seed2 : POSITIVE;
		VARIABLE blockLine : BLOCK_LINE := INIT_BLOCK_LINE(0, 0, 0, 0);
		VARIABLE rand : REAL;
		-- for writing to file
		VARIABLE L : line;
	    VARIABLE fstatus : file_open_status;
	BEGIN
		WAIT FOR 1 ns;
		write(L, STRING'("cache controller tests "));
		writeline(output, L);
		data_cpu <= (OTHERS => 'Z');
	
		-- ---------------------------------------------------------------------------------------------------
		-- testing reset bit
		-- ---------------------------------------------------------------------------------------------------
		reset <= '1';
		file_open(fstatus, fptr, C_FILE_NAME, write_mode);
		WAIT UNTIL rising_edge(clk);
		WAIT UNTIL falling_edge(clk);
		reset <= '0';
		WAIT UNTIL rising_edge(clk);
		WAIT UNTIL falling_edge(clk);

		report "[TEST] checking valid and dirty bits after reset" severity NOTE;
		for I in 0 to DEFAULT_ADDRESS_WIDTH - 1 loop
			-- Set to mode READ.
			rd_word <= '1';
			wr_word <= '0';
			-- tag1    := (others => '0');
			-- index   := GET_INDEX(I);
			-- offset  := (others => '0');
			-- add_cpu <= tag1 & index & offset;
			add_cpu <= GENERATE_CPU_ADDRESS(I mod  8);
			tag1 := GET_TAG(add_cpu);
			index := GET_INDEX(add_cpu);
			offset := GET_OFFSET(add_cpu);
			wait until rising_edge(clk); 
			wait until falling_edge(clk);
			report "valid [" & STD_LOGIC'IMAGE(valid) & "]." severity NOTE;
			report "dirty [" & STD_LOGIC'IMAGE(dirty) & "]." severity NOTE;
			report "hit [" & STD_LOGIC'IMAGE(hit) & "]." severity NOTE;
			if (valid = '0' and dirty = '0' and hit = '0') then
				report "valid bit and dirty bit in block line with index [" & INTEGER'IMAGE(I) & "] are valid." severity NOTE;
			elsif (valid /= '0') then
				report "[FAILURE] valid bit => "&"Actual Value [" & STD_LOGIC'IMAGE(valid) & "]" & " != expected [0]" severity FAILURE;
			-- this fails ... 
			 elsif (dirty /= '0') then
				report "[FAILURE] dirty bit => "&"Actual Value [" & STD_LOGIC'IMAGE(dirty) & "]" & " != expected [0]" severity FAILURE;
			elsif (hit /= '0') then
				report "[FAILURE] hit bit => "&"Actual Value [" & STD_LOGIC'IMAGE(hit) & "]" & " != expected [0]" severity FAILURE;
			end if;
			wait until rising_edge(clk);
			wait until falling_edge(clk);
		end loop;
		wait until rising_edge(clk);
		wait until falling_edge(clk);
		write(L, STRING'("RANDOM GENERATED DATA"), right, 2);
		writeline(fptr, L);
	    write(L, STRING'("| cpu instruction | cpu address        | TAG | INDEX | OFFSET |"), right, 2);
		writeline(fptr, L);
		write(L, STRING'("|-----------------|--------------------|--------|-------|---------|"), right, 2);
		writeline(fptr, L);
		REPORT "[TEST] checking writing single words to one cache block" SEVERITY NOTE;
	
		FOR I IN 0 TO DEFAULT_ADDRESS_WIDTH - 1 LOOP
			-- Create random number.
			uniform(seed1, seed2, rand);
			irand := GET_RANDOM(rand);
			-- tag1 := GET_TAG(irand);
			-- Change mode to write.
			wr_word <= '1';
			rd_word <= '0';
			-- index := GET_INDEX(I);
			WAIT UNTIL rising_edge(clk);
			WAIT UNTIL falling_edge(clk);
			-- generating data ...
			FOR J IN 0 TO DEFAULT_BLOCK_SIZE - 1 LOOP
				-- report INTEGER'IMAGE(J mod  8 ) severity NOTE;
				
				add_cpu <= GENERATE_CPU_ADDRESS(J mod  8);
				tag1 := GET_TAG(add_cpu);
				index := GET_INDEX(add_cpu);
				offset := GET_OFFSET(add_cpu);
				-- offset := GET_OFFSET(J);
				-- offset := GET_OFFSET(J);
				-- add_cpu <= tag1 & index & offset;
				-- Create random number.
				uniform(seed1, seed2, rand);
				irand := GET_RANDOM(rand);
				data_cpu <= GET_DATA_DEFAULTS(irand mod  8 );
				blockLine(J) := GET_DATA_DEFAULTS(irand mod  8 );
				-- data_cpu <= GET_DATA(irand);
				-- blockLine(J) := GET_DATA(irand);
				my_data_word <= blockLine(J);
				WAIT UNTIL rising_edge(clk);
				WAIT UNTIL falling_edge(clk);
				write(L, STRING'("|"), right, 1);
				FOR C IN 1 TO (19 - TO_STRING(data_cpu)'length)/2 LOOP
					write(L, STRING'(" "), right, 1);
				END LOOP;
				-- write(L, STRING'("0x"), right, 1);
				write(L, TO_STRING(data_cpu), right, 1);
				FOR C IN 1 TO (15 - TO_STRING(data_cpu)'length)/2 + 1 LOOP
					write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, STRING'("|"), right, 1);
				FOR C IN 1 TO (18 - TO_STRING(add_cpu)'length)/2 LOOP
					write(L, STRING'(" "), right, 1);
				END LOOP;
				-- write(L, STRING'("0x"), right, 1);
				write(L, TO_STRING(tag1), right, 1);
				write(L, string'(":"), right, 1);
				write(L, TO_STRING(index), right, 1);
				write(L, string'(":"), right, 1);
				write(L, TO_STRING(offset), right, 1);
				FOR C IN 1 TO (18 - TO_STRING(add_cpu)'length)/2 + 1 LOOP
					write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, STRING'("|"), right, 1);
				FOR C IN 1 TO (8 - 2)/2 LOOP
				write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, INTEGER'IMAGE(J), right, 1);
				FOR C IN 1 TO (8 - 2)/2 + 1 LOOP
				write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, STRING'("|"), right, 1);
				FOR C IN 1 TO (7 - 2)/2 LOOP
				write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, INTEGER'IMAGE(I), right, 1);
				FOR C IN 1 TO (7 - 2)/2 + 1 LOOP
				write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, STRING'("|"), right, 1);
				FOR C IN 1 TO (18 - 3)/2 LOOP
				write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, TO_STRING(GET_DATA_DEFAULTS(irand mod  8 )), right, 1);
				FOR C IN 1 TO (18 - 3)/2 + 1 LOOP
				write(L, STRING'(" "), right, 1);
				END LOOP;
				write(L, STRING'("|"), right, 1);
				writeline(fptr, L);
				write(L, STRING'("|-----------------|--------------------|--------|-------|---------|"), right, 2);
				writeline(fptr, L);
				WAIT UNTIL rising_edge(clk);
				WAIT UNTIL falling_edge(clk);
			END LOOP;
			-- Set the mode to READ.
			wr_word <= '0';
			rd_word <= '1';
			WAIT UNTIL rising_edge(clk);
			WAIT UNTIL falling_edge(clk);
			FOR J IN 0 TO DEFAULT_BLOCK_SIZE - 1 LOOP
				data_cpu <= (OTHERS => 'Z');
				-- offset := GET_OFFSET(J);
				-- add_cpu <= tag1 & index & offset;
				add_cpu <= GENERATE_CPU_ADDRESS(j mod  8);
				tag1 := GET_TAG(add_cpu);
				index := GET_INDEX(add_cpu);
				offset := GET_OFFSET(add_cpu);

				WAIT UNTIL rising_edge(clk);
				WAIT UNTIL falling_edge(clk);
				IF (data_cpu = blockLine(J)) THEN
					-- REPORT "[SUCCESS] cpu instruction [0x" & TO_HEX_STRING(blockLine(J)) & "] cpu address [0x" & TO_HEX_STRING(add_cpu) & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "]" SEVERITY NOTE;
					REPORT "[SUCCESS] cpu instruction [0x" & TO_HEX_STRING(blockLine(J)) & "] cpu address [0x" & TO_HEX_STRING(add_cpu) & "] tag [" & TO_STRING(tag1) & "] index [" & TO_STRING(index) & "] offset [" & TO_STRING(offset)  & "]" SEVERITY NOTE;
				ELSE
					-- TODO FIX THIS
					-- report "[FAILURE] cpu address [0x" & TO_HEX_STRING(add_cpu)  & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "] Actual Value [0x" & TO_HEX_STRING(data_cpu) & "] != Expected Value [0x" & TO_HEX_STRING(blockLine(J)) & "]." severity FAILURE;
					report "[FAILURE] cpu address [" & TO_STRING(tag1) & ":" & TO_STRING(index) &":"& TO_STRING(offset) & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "] Actual Value [0x" & TO_STRING(data_cpu) & "] != Expected Value [" & TO_STRING(blockLine(J)) & "]." severity FAILURE;
				END IF;
				WAIT UNTIL rising_edge(clk);
				WAIT UNTIL falling_edge(clk);
			END LOOP;
			-- REPORT_BREAK_LINE;
			
		END LOOP;
		WAIT UNTIL rising_edge(clk);
		WAIT UNTIL falling_edge(clk);
		report "[TEST] checking tags..." severity NOTE;
		for I in 0 to DEFAULT_ADDRESS_WIDTH - 1 loop
			
			uniform(seed1, seed2, rand);
			irand := GET_RANDOM(rand);
			add_cpu <= GENERATE_CPU_ADDRESS(I mod  8);
			tag1 := GET_TAG(add_cpu);
			index := GET_INDEX(add_cpu);
			offset := GET_OFFSET(add_cpu);

			-- tag1 := GET_TAG(irand);
			wr_word <= '1';
			rd_word <= '0';
			-- index := GET_INDEX(I);
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				-- offset := GET_OFFSET(J);
				-- add_cpu <= tag1 & index & offset;
				uniform(seed1, seed2, rand);
				irand := GET_RANDOM(rand);
				-- data_cpu      <= GET_DATA(irand);
				data_cpu <= GET_DATA_DEFAULTS(irand mod  8 );
				blockLine(J) := GET_DATA(irand);
				my_data_word   <= blockLine(J);
				wait until rising_edge(clk); 
				wait until falling_edge(clk);
				-- report "payload [" & TO_STRING(data_cpu) &"cpu address [0x" & TO_HEX_STRING(add_cpu)  & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "] write [" & INTEGER'IMAGE(irand) & "] to cache block" severity NOTE;
				wait until rising_edge(clk); 
				wait until falling_edge(clk); 
			end loop;
			wr_word <= '0';
			rd_word <= '1';
			wait until rising_edge(clk); 
			wait until falling_edge(clk);
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				-- offset := GET_OFFSET(J);
				-- add_cpu <= tag1 & index & offset;
				add_cpu <= GENERATE_CPU_ADDRESS(J mod  8);
				tag1 := GET_TAG(add_cpu);
				index := GET_INDEX(add_cpu);
				offset := GET_OFFSET(add_cpu);

				wait until rising_edge(clk); 
				wait until falling_edge(clk);
				if (valid = '1' and hit = '1') then
					report "valid and hit bits are correct." severity NOTE;
				elsif (valid = '0') then
					report "valid bit is not correct." severity FAILURE;
				elsif (hit = '0') then
					-- report "hit bit is not correct." severity FAILURE;
				end if;
				wait until rising_edge(clk); 
				wait until falling_edge(clk);
			end loop;
			uniform(seed1, seed2, rand);
			irand := GET_RANDOM(rand);
			-- tag2  := GET_TAG(irand);
			wait until rising_edge(clk); 
			wait until falling_edge(clk);
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				add_cpu <= GENERATE_CPU_ADDRESS(J mod  8);
				tag2:= GET_TAG(add_cpu);
				index := GET_INDEX(add_cpu);
				offset := GET_OFFSET(add_cpu);
				-- offset := GET_OFFSET(J);
				-- add_cpu <= tag2 & index & offset;
				wait until rising_edge(clk); 
				wait until falling_edge(clk);
				if (tag1 /= tag2 and hit = '0' and valid = '1') then
					report "tags are different, valid and hit bits are correct." severity NOTE;
				elsif (tag1 = tag2 and hit = '1' and valid = '1') then
					report "tags are equal, valid and hit bits are correct." severity NOTE;
				elsif (tag1 /= tag2 and (hit /= '0' or valid /= '1')) then
					report "tags are different, valid and hit bits are not correct." severity NOTE;
				else
					-- report "tags are equal, valid and hit bits are not correct." severity FAILURE;
				end if;
				wait until rising_edge(clk); 
				wait until falling_edge(clk);
			end loop;
			-- REPORT_BREAK_LINE;
		end loop;
		wait until rising_edge(clk); 
		wait until falling_edge(clk);
		REPORT "FINISHED checking tags..." SEVERITY NOTE;
		-- Check whether to rerun the process.
		-- if rerun_process = '0' then
		eof <= '1';
		file_close(fptr);
		WAIT;
		-- end if;

	END PROCESS;

END;