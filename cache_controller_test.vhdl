LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cache_controller_test IS
END cache_controller_test;

ARCHITECTURE behavior OF cache_controller_test IS
	CONSTANT period : TIME := 10 ns;

COMPONENT cache_controller
	
	PORT (
		clk : IN STD_LOGIC;
		address_in : IN STD_LOGIC_VECTOR (15 downto 0);
		sram_address : OUT STD_LOGIC_VECTOR (7 downto 0)
	);
	END COMPONENT;
	SIGNAL clk : std_logic:= '0';
	SIGNAL address_in : std_logic_vector(15 DOWNTO 0);
	SIGNAL sram_address : std_logic_vector(7 DOWNTO 0);
BEGIN
        clk <= not clk after period/2;
        -- Instantiate the Unit Under Test (UUT)
		 uut : cache_controller
		 PORT MAP(
			 clk     =>clk,
			 address_in =>address_in,
			 sram_address =>sram_address
		 );
		 
		-- Stimulus process
		stim_proc : PROCESS
		BEGIN
		address_in <= x"0000";
		wait until clk'event and clk='1';
		address_in <= address_in or x"0001";
		wait until clk'event and clk='1';
		REPORT "cache_controller@2 result" SEVERITY note;
		address_in <= address_in or x"0011";
		ASSERT sram_address = x"00" REPORT "[ERR]" SEVERITY note;

		wait until clk'event and clk='1';
		REPORT "cache_controller@3 result" SEVERITY note;
		address_in <= address_in and x"0010";
		ASSERT sram_address = x"01" REPORT "[ERR]" SEVERITY note;

		wait until clk'event and clk='1';
		REPORT "cache_controller@4 result" SEVERITY note;
		address_in <= address_in and x"0000";
		ASSERT sram_address = x"11" REPORT "[ERR]" SEVERITY note;

		wait until clk'event and clk='1';
		REPORT "cache_controller@5 result" SEVERITY note;
		address_in <= address_in and x"0000";
		ASSERT sram_address = x"10" REPORT "[ERR]" SEVERITY note;
		
		wait until clk'event and clk='1';
		REPORT "cache_controller@6 result" SEVERITY note;
		ASSERT sram_address = x"00" REPORT "[ERR]" SEVERITY note;

		
		REPORT "cache_controller tests completed" SEVERITY note;
		WAIT;
		END PROCESS;
END;