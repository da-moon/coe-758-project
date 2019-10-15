LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY clock_gen IS
	GENERIC (clock_period : TIME := 10 ns);
	PORT (clk : OUT std_logic);
END clock_gen;