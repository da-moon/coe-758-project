
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY cache_decoder_test IS
END cache_decoder_test;

ARCHITECTURE behavior OF cache_decoder_test IS
	-- Constants
	CONSTANT period : TIME := 10 ps;

	-- Component Declaration for the Unit Under Test (UUT)

	COMPONENT cache_decoder
		PORT (
			address : IN std_logic_vector(15 DOWNTO 0);
			tag : OUT std_logic_vector(7 DOWNTO 0);
			index : OUT std_logic_vector(2 DOWNTO 0);
			offset : OUT std_logic_vector(4 DOWNTO 0)
		);
	END COMPONENT;
	--Inputs
	SIGNAL address : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');

	--Outputs
	SIGNAL tag : std_logic_vector(7 DOWNTO 0);
	SIGNAL index : std_logic_vector(2 DOWNTO 0);
	SIGNAL offset : std_logic_vector(4 DOWNTO 0);

BEGIN
	-- Instantiate the Unit Under Test (UUT)
	uut : cache_decoder
	PORT MAP(
		address => address,
		tag => tag,
		index => index,
		offset => offset
	);
	-- address <= "0000,0000,0000,0000";

	-- Stimulus process
	stim_proc : PROCESS
	BEGIN
		address <= "0000000000000000";
		-----------------------------------
		WAIT FOR period;
		ASSERT tag = "00000000" REPORT "[ERR] tag @ 0000000000000000" SEVERITY error;
		ASSERT index = "000" REPORT "[ERR] index @ 0000000000000000" SEVERITY error;
		ASSERT offset = "00000" REPORT "[ERR] offset @ 0000000000000000" SEVERITY error;
		WAIT FOR period;
		-----------------------------------
		address <= "0010000001000001";
		WAIT FOR period;		
		ASSERT tag = "00100000" REPORT "[ERR] tag @ 0010000000000001" SEVERITY error;
		ASSERT index = "010" REPORT "[ERR] index @ 0010000001000001" SEVERITY error;
		ASSERT offset = "00001" REPORT "[ERR] offset @ 0010000000000001" SEVERITY error;
		WAIT FOR period;
		ASSERT false REPORT "[cache_decoder] tests were successfully completed" SEVERITY note;
		WAIT;
	END PROCESS;

END;