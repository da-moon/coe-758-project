LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY dp_ram_test IS
END dp_ram_test;

ARCHITECTURE behavior OF dp_ram_test IS
	CONSTANT ELEMENTS : integer := 8;
	CONSTANT ELEMENT_SIZE : integer := 32;
	CONSTANT period : TIME := 10 ns;

COMPONENT dp_ram_wrapper
	generic (
		ELEMENTS     : integer;
		ELEMENT_SIZE : integer;
		RAM_TYPE     : string  := "block"
		);
	PORT (
		clk     : in std_logic;
		aresetn : in std_logic;
		wr     : in  std_logic;
		wraddr : in  integer range 0 to ELEMENTS-1;
		wrdata : in  std_logic_vector(ELEMENT_SIZE-1 downto 0);
		rd     : in  std_logic;
		rdaddr : in  integer range 0 to ELEMENTS-1;
		rddata : out std_logic_vector(ELEMENT_SIZE-1 downto 0)
	);
	END COMPONENT;

	--Inputs
	SIGNAL clk : std_logic:= '1';
	SIGNAL wrdata : std_logic_vector(ELEMENT_SIZE - 1 DOWNTO 0);
	SIGNAL aresetn : std_logic ;
	SIGNAL rdaddr : integer range 0 to ELEMENTS-1;
	SIGNAL wraddr : integer range 0 to ELEMENTS-1;
	
	SIGNAL wr : std_logic :='1' ;
	SIGNAL rd : std_logic :='0' ;
	--Outputs
	SIGNAL rddata : std_logic_vector(ELEMENT_SIZE - 1 DOWNTO 0);
BEGIN
			clk <= not clk after period/2;
			wr <= not wr after period;
			rd <= not rd after period;

			-- Instantiate the Unit Under Test (UUT)
		uut : dp_ram
		GENERIC MAP(ELEMENTS => ELEMENTS,ELEMENT_SIZE=>ELEMENT_SIZE)
		PORT MAP(
			clk     =>clk,
			aresetn =>aresetn,
			wr     =>wr,
			wraddr =>wraddr,
			wrdata =>wrdata,
			rd     =>rd,
			rdaddr =>rdaddr,
			rddata =>rddata
		);
		-- Stimulus process
		stim_proc : PROCESS
		BEGIN
	
		wait until clk'event and clk='1';
		ASSERT wr = '0' REPORT "test 1 faied for wr " SEVERITY note;
		rdaddr<=00000000;
		wait until clk'event and clk='1';
		ASSERT wr = '1' REPORT "test 2 faied for wr " SEVERITY note;
		ASSERT rd = '0' REPORT "test 2 faied for wr " SEVERITY note;
		wraddr<=00000000;
		wrdata<=X"00000001";
		wait until clk'event and clk='1';
		ASSERT wr = '0' REPORT "test 2 faied for wr " SEVERITY note;
		ASSERT rd = '1' REPORT "test 2 faied for wr " SEVERITY note;
		rdaddr<=00000000;
		ASSERT rddata = X"00000001" REPORT "[ERR] rddata @ T3 " SEVERITY note;
		REPORT "dp_ram tests were successful" SEVERITY note;
		WAIT;
		END PROCESS;
END;