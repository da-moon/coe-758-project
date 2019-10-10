LIBRARY ieee;
USE ieee.std_logic_1164.ALL;

ENTITY cache_test IS
END cache_test;

ARCHITECTURE behavior OF cache_test IS
	CONSTANT ELEMENTS : integer := 8;
	CONSTANT ELEMENT_SIZE : integer := 32;
	CONSTANT period : TIME := 10 ns;

COMPONENT cache

	PORT (
		clk: in std_logic;
    reset : in std_logic;
    load_flag : in std_logic;
    we : in std_logic;
    address : in std_logic_vector(15 downto 0);
    tag : in std_logic;
    write_data0 : in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data1: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data2: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data3: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data4: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data5: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data6: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data7: in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    write_data8 : in std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data_tag_index : out cache_tag_index_vector;
    read_data : out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data1: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data2: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data3: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data4: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data5: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data6: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data7: out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    read_data8 : out std_logic_vector(DATA_BANDWIDTH-1 downto 0);
    -- push cache miss to the memory
    miss : out std_logic;
    valid_flag : out std_logic;
    dirty_flag : out std_logic;
    -- pull load from the memory
    load_data_en : in std_logic
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
		uut : cache
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
		REPORT "cache tests were successful" SEVERITY note;
		WAIT;
		END PROCESS;
END;