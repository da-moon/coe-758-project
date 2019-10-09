
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux8_test IS
END mux8_test;

ARCHITECTURE behavior OF mux8_test IS
	--Constants
	CONSTANT SIZE : INTEGER := 8;
	CONSTANT period : TIME := 10 ns;
	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT mux8
		GENERIC (N : INTEGER);
		PORT (
			input_000 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_001 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_010 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_011 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_100 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_101 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_110 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_111 : IN std_logic_vector(N - 1 DOWNTO 0);
			selector : IN std_logic_vector(2 DOWNTO 0);
			output : OUT std_logic_vector(N - 1 DOWNTO 0)
		);
	END COMPONENT;
	--Inputs
	SIGNAL input_000 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_001 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_010 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_011 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_100 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_101 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_110 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_111 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL selector : std_logic_vector(2 DOWNTO 0);

	--Outputs
	SIGNAL output : std_logic_vector(SIZE - 1 DOWNTO 0);

BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut : mux8
		GENERIC MAP(N => SIZE)
	PORT MAP(
		input_000 => input_000,
		input_001 => input_001,
		input_010 => input_010,
		input_011 => input_011,
		input_100 => input_100,
		input_101 => input_101,
		input_110 => input_110,
		input_111 => input_111,
		selector => selector,
		output => output
	);

		-- Stimulus process
		stim_proc : PROCESS
		BEGIN
			input_000 <= X"01";
			selector <= "000";
			WAIT FOR period;
			ASSERT output = X"01" REPORT "test faied for selector '000' " SEVERITY note;
			selector <= "XXX";
			-- hold reset state for 100 ns.
			-- WAIT FOR period * 10;
			WAIT FOR period;
			input_001 <= X"02";
			selector <= "001";
			WAIT FOR period;
			ASSERT output = X"02" REPORT "test faied for selector '001' " SEVERITY note;
			input_010 <= X"03";
			selector <= "010";
			WAIT FOR period;
			ASSERT output = X"03" REPORT "test faied for selector '010' " SEVERITY note;
			input_011 <= X"04";
			selector <= "011";
			WAIT FOR period;
			ASSERT output = X"04" REPORT "test faied for selector '011' " SEVERITY note;
			input_100 <= X"05";
			selector <= "100";
			WAIT FOR period;
			ASSERT output = X"05" REPORT "test faied for selector '100' " SEVERITY note;
			input_101 <= X"06";
			selector <= "101";
			WAIT FOR period;
			ASSERT output = X"06" REPORT "test faied for selector '101' " SEVERITY note;
			input_110 <= X"07";
			selector <= "110";
			WAIT FOR period;
			ASSERT output = X"07" REPORT "test faied for selector '110' " SEVERITY note;
			input_111 <= X"08";
			selector <= "111";
			WAIT FOR period;
			ASSERT output = X"08" REPORT "test faied for selector '111' " SEVERITY note;
			ASSERT false REPORT "Mux8 test were completed" SEVERITY note;
			WAIT;
		END PROCESS;

END;