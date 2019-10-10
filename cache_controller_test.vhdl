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
		sram_address : OUT STD_LOGIC_VECTOR (7 downto 0);
		-- mux2 loader
		load_from_selector : IN STD_LOGIC;
		load_from_payload : OUT std_logic_vector(7 DOWNTO 0);
		incoming_cpu_payload : IN std_logic_vector(7 DOWNTO 0);
		incoming_sdram_controller_payload : IN std_logic_vector(7 DOWNTO 0)
	);
	END COMPONENT;
	SIGNAL clk : std_logic:= '0';
	SIGNAL address_in : std_logic_vector(15 DOWNTO 0);
	SIGNAL sram_address : std_logic_vector(7 DOWNTO 0);

	--mux2 load
	SIGNAL incoming_cpu_payload : std_logic_vector(7 DOWNTO 0);
	SIGNAL incoming_sdram_controller_payload : std_logic_vector(7 DOWNTO 0);
	SIGNAL load_from_selector : std_logic ;
	SIGNAL load_from_payload : std_logic_vector(7 DOWNTO 0);
	
BEGIN
        clk <= not clk after period/2;
        -- Instantiate the Unit Under Test (UUT)
		 uut : cache_controller
		 PORT MAP(
			 clk     =>clk,
			 address_in =>address_in,
			 sram_address =>sram_address,
			 load_from_selector => load_from_selector,
			 load_from_payload =>load_from_payload,
			 incoming_cpu_payload =>incoming_cpu_payload,
			 incoming_sdram_controller_payload =>incoming_sdram_controller_payload
		 );
		 
		-- Stimulus process
		stim_proc : PROCESS
		BEGIN
		-- loading initial data ... 
		incoming_cpu_payload <= x"c1";
		incoming_sdram_controller_payload <=x"d2";
		load_from_selector<='0';
		REPORT "[cache_controller] testing address decoder ..." SEVERITY note;
		address_in <= x"0000";
		wait until clk'event and clk='1';
		-- Initial data has been loaded now ...

		-- address_in <= address_in or x"0001";
		-- wait until clk'event and clk='1';
		-- REPORT "cache_controller@2 result" SEVERITY note;
		-- address_in <= address_in or x"0011";
		-- ASSERT sram_address = x"00" REPORT "[ERR]" SEVERITY note;
-- 
		-- wait until clk'event and clk='1';
		-- REPORT "cache_controller@3 result" SEVERITY note;
		-- address_in <= address_in and x"0010";
		-- ASSERT sram_address = x"01" REPORT "[ERR]" SEVERITY note;
		-- wait until clk'event and clk='1';
		-- REPORT "cache_controller@4 result" SEVERITY note;
		-- address_in <= address_in and x"0000";
		-- ASSERT sram_address = x"11" REPORT "[ERR]" SEVERITY note;
		-- wait until clk'event and clk='1';
		-- REPORT "cache_controller@5 result" SEVERITY note;
		-- address_in <= address_in and x"0000";
		-- ASSERT sram_address = x"10" REPORT "[ERR]" SEVERITY note;
		-- wait until clk'event and clk='1';
		-- REPORT "cache_controller@6 result" SEVERITY note;
		-- ASSERT sram_address = x"00" REPORT "[ERR]" SEVERITY note;
		-- wait until clk'event and clk='1';		

		REPORT "[cache_controller] testing sram Cache Input Payload selector ..." SEVERITY note;
		-- initialization
		load_from_selector<='1';
		
		wait until clk'event and clk='1';	
		REPORT "cache_controller@8 result" SEVERITY note;
		ASSERT load_from_payload = x"c1" REPORT "[ERR]" SEVERITY note;
		incoming_sdram_controller_payload<=x"d1";

		wait until clk'event and clk='1';		
		REPORT "cache_controller@9 result" SEVERITY note;
		ASSERT load_from_payload = x"d2" REPORT "[ERR]" SEVERITY note;
		load_from_selector<='0';
		incoming_cpu_payload <= x"c2";
		
		wait until clk'event and clk='1';		
		REPORT "cache_controller@10 result" SEVERITY note;
		ASSERT load_from_payload = x"d1" REPORT "[ERR]" SEVERITY note;

		wait until clk'event and clk='1';		
		REPORT "cache_controller@11 result" SEVERITY note;
		ASSERT load_from_payload = x"c2" REPORT "[ERR]" SEVERITY note;


		REPORT "cache_controller tests completed" SEVERITY note;
		WAIT;
		END PROCESS;
END;