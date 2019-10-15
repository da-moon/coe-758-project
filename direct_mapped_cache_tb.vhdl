library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use IEEE.MATH_REAL.all;
use std.textio.all;
use work.cache_pkg.all;
use work.utils_pkg.all;
use work.cache_test_pkg.all;
entity direct_mapped_cache_tb is
	generic(
		TAG_FILENAME    : string  := "./imem/tag";
		DATA_FILENAME   : string  := "./imem/data";
		FILE_EXTENSION  : STRING  := ".txt"
	);
end;
architecture testbench of direct_mapped_cache_tb is
	CONSTANT clock_period : TIME := 10 ns;
	constant C_FILE_NAME :string  := "test_results/direct_mapped_cache.txt";
	-- Auxiliary procedure to print a break line.
	procedure REPORT_BREAK_LINE is
		begin
		report break_line severity NOTE;
	end;	
	signal reset : STD_LOGIC := '0';
	signal clk : STD_LOGIC := '0';
	signal add_cpu : STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH - 1 downto 0) := (others => '0');
	signal data_cpu        : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 downto 0)               := (others => 'Z');
	signal valid          : STD_LOGIC                                              := '0';
	signal dirty          : STD_LOGIC                                              := '0';
	signal hit            : STD_LOGIC                                              := '0';
	signal wr_rd      : STD_LOGIC                                              := '0';
	signal cache_memory_data_bus        : STD_LOGIC_VECTOR(CACHE_BLOCK_LINE_RANGE) := (others => '0');
	signal new_cache_block_line : STD_LOGIC_VECTOR(CACHE_BLOCK_LINE_RANGE);
	signal rd_word             : STD_LOGIC                                              := '0';
	signal wr_word             : STD_LOGIC                                              := '0';
	signal rd_cache_block_line       : STD_LOGIC                                              := '0';
	signal wr_cache_block_Line       : STD_LOGIC                                              := '0';
	signal set_valid       : STD_LOGIC                                              := '0';
	signal set_dirty       : STD_LOGIC                                              := '0';
	signal my_data_word : STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH - 1 downto 0) := (others => '0');
	-- clock gen component
	COMPONENT clock_gen
	GENERIC (clock_period : TIME);
		PORT (
			clk : OUT std_logic
		);
	END COMPONENT;
	COMPONENT direct_mapped_cache
	generic(
		TAG_FILENAME          : STRING;
		DATA_FILENAME         : STRING;
		FILE_EXTENSION       : STRING
	);
	port(
		clk              : in    STD_LOGIC;
		reset            : in    STD_LOGIC;
		add_cpu          : in    STD_LOGIC_VECTOR(DEFAULT_MEMORY_ADDRESS_WIDTH-1 downto 0); 
        data_cpu       	 : inout    STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH-1 downto 0); 
        new_cache_block_line : in STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0);
		cache_memory_data_bus         : out STD_LOGIC_VECTOR(DEFAULT_DATA_WIDTH*DEFAULT_BLOCK_SIZE-1 downto 0); 
		wr_cache_block_Line		 : in    STD_LOGIC;
        rd_cache_block_line		 : in	 STD_LOGIC; 
        rd_word           : in    STD_LOGIC; 
        wr_word           : in    STD_LOGIC; 
        wr_rd 		 : in    STD_LOGIC; 
        valid            : inout STD_LOGIC;
		dirty         	 : inout STD_LOGIC; 
        set_valid         : in    STD_LOGIC;
        set_dirty         : in    STD_LOGIC;
		hit              : out   STD_LOGIC
	);
	END COMPONENT;

begin
	-- Clock generator instl
	clock_gen_instl : clock_gen
	GENERIC MAP(clock_period => clock_period)
	PORT MAP(
			clk => clk
	);
	-- unit under test
	uut : direct_mapped_cache
		generic map(
			TAG_FILENAME         => TAG_FILENAME,
			DATA_FILENAME        => DATA_FILENAME,
			FILE_EXTENSION       => FILE_EXTENSION
		)
		port map(
			clk       => clk,
			reset     => reset,
			data_cpu   => data_cpu,
			add_cpu   => add_cpu,
			cache_memory_data_bus   => cache_memory_data_bus,
			rd_word    => rd_word,
			wr_word    => wr_word,
			wr_cache_block_Line  => wr_cache_block_Line,
			rd_cache_block_line  => rd_cache_block_line,
			wr_rd => wr_rd,
			valid     => valid,
			dirty     => dirty,
			set_valid  => set_valid,
			set_dirty  => set_dirty,
			hit       => hit,
			new_cache_block_line => new_cache_block_line
		);
	stim_proc : process
		variable tag1, tag2          : STD_LOGIC_VECTOR(CALCULATE_TAG_VECTOR_SIZE - 1 downto 0);
		variable index               : STD_LOGIC_VECTOR(CALCULATE_INDEX_VECTOR_SIZE - 1 downto 0);
		variable offset              : STD_LOGIC_VECTOR(CALCULATE_OFFSET_VECTOR_SIZE - 1 downto 0);
		variable irand               : INTEGER;
		variable seed1, seed2        : POSITIVE;
		variable blockLine           : BLOCK_LINE := INIT_BLOCK_LINE(0, 0, 0, 0);
		variable rand                : REAL;
		variable L : line	;
	begin
		WAIT for 1 ns;
		write(L, string'("cache controller tests "));
		writeline(output, L);
		data_cpu <= (others => 'Z');
		
		report "init dirty [" & STD_LOGIC'IMAGE(dirty) & "]." severity NOTE;

		-- ---------------------------------------------------------------------------------------------------
		-- testing reset bit
		-- ---------------------------------------------------------------------------------------------------
		reset <= '1';
		wait until rising_edge(clk);
		-- reset <= '0';
		-- wait until rising_edge(clk);

		report "[TEST] checking valid and dirty bits after reset" severity NOTE;
		for I in 0 to DEFAULT_ADDRESS_WIDTH - 1 loop
			-- Set to mode READ.
			rd_word <= '1';
			wr_word <= '0';
			tag1    := (others => '0');
			index   := GET_INDEX(I);
			offset  := (others => '0');
			add_cpu <= tag1 & index & offset;
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
			-- wait until falling_edge(clk);
		end loop;
		-- wait for 10 ns;
		wait until rising_edge(clk);
		-- wait until falling_edge(clk);
		report "[TEST] checking writing single words to one cache block" severity NOTE;
		for I in 0 to DEFAULT_ADDRESS_WIDTH - 1 loop
			-- Create random number.
			uniform(seed1, seed2, rand);
			irand := GET_RANDOM(rand);
			tag1 := GET_TAG(irand);
			-- Change mode to write.
			wr_word <= '1';
			rd_word <= '0';
			index := GET_INDEX(I);
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				offset := GET_OFFSET(J);
				add_cpu <= tag1 & index & offset;
				-- Create random number.
				uniform(seed1, seed2, rand);
				irand := GET_RANDOM(rand);
				data_cpu      <= GET_DATA(irand);
				blockLine(J) := GET_DATA(irand);
				my_data_word   <= blockLine(J);
				wait until rising_edge(clk);
				report "payload [0x" & TO_HEX_STRING(data_cpu) &"] cpu address [0x" & TO_HEX_STRING(add_cpu)  & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "] write [" & INTEGER'IMAGE(irand) & "] to cache block" severity NOTE;
				wait until rising_edge(clk); 
				-- wait until falling_edge(clk); 
			end loop;
			-- Wait.
			-- wait for 50 ns;
			-- Set the mode to READ.
			wr_word <= '0';
			rd_word <= '1';
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				data_cpu <= (others => 'Z');
				offset := GET_OFFSET(J);
				add_cpu <= tag1 & index & offset;
				wait until rising_edge(clk); 
				-- wait until falling_edge(clk); 
				-- wait until rising_edge(clk); 
				-- wait until falling_edge(clk); 
				if (data_cpu = blockLine(J)) then
					report "[SUCCESS] data_stored_in_mem [0x" & TO_HEX_STRING(blockLine(J)) &"] cpu address [0x" & TO_HEX_STRING(add_cpu)  & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "]" severity NOTE;
				else 
					-- TODO FIX THIS
					-- report "[FAILURE] cpu address [0x" & TO_HEX_STRING(add_cpu)  & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "] Actual Value [0x" & TO_HEX_STRING(data_cpu) & "] != Expected Value [0x" & TO_HEX_STRING(blockLine(J)) & "]." severity FAILURE;
				end if;
				wait until rising_edge(clk); 

			end loop;
			REPORT_BREAK_LINE;

		end loop;
		report "[TEST] checking tags..." severity NOTE;
		for I in 0 to DEFAULT_ADDRESS_WIDTH - 1 loop
			uniform(seed1, seed2, rand);
			irand := GET_RANDOM(rand);
			tag1 := GET_TAG(irand);
			wr_word <= '1';
			rd_word <= '0';
			index := GET_INDEX(I);
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				offset := GET_OFFSET(J);
				add_cpu <= tag1 & index & offset;
				uniform(seed1, seed2, rand);
				irand := GET_RANDOM(rand);
				data_cpu      <= GET_DATA(irand);
				blockLine(J) := GET_DATA(irand);
				my_data_word   <= blockLine(J);
				wait until rising_edge(clk);
				-- wait until falling_edge(clk);
				report "payload [" & TO_STRING(data_cpu) &"cpu address [0x" & TO_HEX_STRING(add_cpu)  & "] offset [" & INTEGER'IMAGE(J) & "] index [" & INTEGER'IMAGE(I) & "] write [" & INTEGER'IMAGE(irand) & "] to cache block" severity NOTE;
				wait until rising_edge(clk); 
				-- wait until falling_edge(clk);  
			end loop;
			-- wait for 50 ns;
			wr_word <= '0';
			rd_word <= '1';
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				offset := GET_OFFSET(J);
				add_cpu <= tag1 & index & offset;
				wait until rising_edge(clk); 
				-- wait until falling_edge(clk); 
				if (valid = '1' and hit = '1') then
					report "valid and hit bits are correct." severity NOTE;
				elsif (valid = '0') then
					report "valid bit is not correct." severity FAILURE;
				elsif (hit = '0') then
					report "hit bit is not correct." severity FAILURE;
				end if;
				wait until rising_edge(clk); 
				-- wait for 5 ns;
			end loop;
			uniform(seed1, seed2, rand);
			irand := GET_RANDOM(rand);
			tag2  := GET_TAG(irand);
			for J in 0 to DEFAULT_BLOCK_SIZE - 1 loop
				offset := GET_OFFSET(J);
				add_cpu <= tag2 & index & offset;
				wait until rising_edge(clk); --
				-- wait until falling_edge(clk); --  
				if (tag1 /= tag2 and hit = '0' and valid = '1') then
					report "tags are different, valid and hit bits are correct." severity NOTE;
				elsif (tag1 = tag2 and hit = '1' and valid = '1') then
					report "tags are equal, valid and hit bits are correct." severity NOTE;
				elsif (tag1 /= tag2 and (hit /= '0' or valid /= '1')) then
					report "tags are different, valid and hit bits are not correct." severity NOTE;
				else
					report "tags are equal, valid and hit bits are not correct." severity FAILURE;
				end if;
				wait until rising_edge(clk);

			end loop;
			REPORT_BREAK_LINE;
		end loop;
		report "FINISHED checking tags..." severity NOTE;
		-- Check whether to rerun the process.
		if rerun_process = '0' then
			wait;
		end if;

	end process;

end;
