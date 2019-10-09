LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY mux2_test IS
	-- PORT (
	--	clk : IN STD_LOGIC
	-- );

END mux2_test;

ARCHITECTURE behavior OF mux2_test IS
	--Constants
	CONSTANT SIZE : INTEGER := 32;
	CONSTANT period : TIME := 10 ns;

	-- Component Declaration for the Unit Under Test (UUT)
	COMPONENT mux2
		GENERIC (N : INTEGER);
		PORT (
			input_0 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_1 : IN std_logic_vector(N - 1 DOWNTO 0);
			selector : IN std_logic;
			output : OUT std_logic_vector(N - 1 DOWNTO 0)
		);
	END COMPONENT;

	--Inputs
	SIGNAL input_0 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL input_1 : std_logic_vector(SIZE - 1 DOWNTO 0);
	SIGNAL selector : std_logic := '0';

	--Outputs
	SIGNAL output : std_logic_vector(SIZE - 1 DOWNTO 0);

BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut : mux2
		GENERIC MAP(N => SIZE)
	PORT MAP(
		input_0 => input_0,
		input_1 => input_1,
		selector => selector,
		output => output
	);
		-- Stimulus process
		stim_proc : PROCESS
		BEGIN
			input_0 <= X"00000001";
			input_1 <= X"00000000";
            WAIT FOR period;
			selector <= '0';
			WAIT FOR period;
			ASSERT output = X"00000001" REPORT "test faied for selector '0' " SEVERITY note;
			selector <= 'U';
			WAIT FOR period;
			ASSERT output = X"00000001" REPORT "test faied for selector 'U' " SEVERITY note;
			selector <= '-';
			WAIT FOR period;
			ASSERT output = X"00000001" REPORT "test faied for selector '-' " SEVERITY note;
			selector <= '1';
			WAIT FOR period;
			ASSERT output = X"00000000" REPORT "test faied for selector '1' " SEVERITY note;
			ASSERT false REPORT "Mux2 test were completed" SEVERITY note;

			WAIT;
		END PROCESS;
END;