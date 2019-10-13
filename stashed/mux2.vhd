LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY mux2 IS
  generic(N : integer);
	PORT (
		input_0 : IN STD_LOGIC_VECTOR (N-1 downto 0);
		input_1 : IN STD_LOGIC_VECTOR (N-1 downto 0);
		selector : IN STD_LOGIC;
		output : OUT STD_LOGIC_VECTOR (N-1 downto 0)
	);
END mux2;

ARCHITECTURE behavior OF mux2 IS
BEGIN
	PROCESS (selector,input_0, input_1 )
	BEGIN
        IF (selector = '1') THEN
            output <= input_1;
        ELSE
            output <= input_0;
        END IF;
	END PROCESS;
END ARCHITECTURE;