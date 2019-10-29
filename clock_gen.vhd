LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY clock_gen IS
	generic(clock_period : TIME);
	PORT (clk : OUT std_logic);
END clock_gen; 
ARCHITECTURE Behavioral OF clock_gen
	IS
	-- CONSTANT clock_period : TIME := 10 ns;
BEGIN
	-- Clock process definition
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clock_period/2;
		clk <= '1';
		WAIT FOR clock_period/2;
	END PROCESS;
END Behavioral;