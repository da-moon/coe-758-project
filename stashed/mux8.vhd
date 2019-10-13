
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY mux8 IS
   generic(N : integer);
	PORT (
		input_000 : IN std_logic_vector(N-1 downto 0);
		input_001 : IN std_logic_vector(N-1 downto 0);
		input_010 : IN std_logic_vector(N-1 downto 0);
		input_011 : IN std_logic_vector(N-1 downto 0);
		input_100 : IN std_logic_vector(N-1 downto 0);
		input_101 : IN std_logic_vector(N-1 downto 0);
		input_110 : IN std_logic_vector(N-1 downto 0);
		input_111 : IN std_logic_vector(N-1 downto 0);
		selector : IN std_logic_vector(2 DOWNTO 0);
		output : OUT std_logic_vector(N-1 downto 0)
	);
END mux8;
ARCHITECTURE behavior OF mux8 IS
BEGIN
	PROCESS ( selector, input_000, input_001, input_010, input_011, input_100, input_101, input_110, input_111)
	BEGIN
        CASE selector IS
            WHEN "000" => output <= input_000;
            WHEN "001" => output <= input_001;
            WHEN "010" => output <= input_010;
            WHEN "011" => output <= input_011;
            WHEN "100" => output <= input_100;
            WHEN "101" => output <= input_101;
            WHEN "110" => output <= input_110;
            WHEN "111" => output <= input_111;
            WHEN OTHERS => output <= (OTHERS => 'X');
        END CASE;
	END PROCESS;
END ARCHITECTURE;