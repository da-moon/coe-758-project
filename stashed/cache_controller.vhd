library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cache_primitives.ALL;

entity cache_controller is
  port (
    clk : IN STD_LOGIC;
    address_in : IN STD_LOGIC_VECTOR (ADDRESS_LENGTH-1 downto 0);
		sram_address : OUT STD_LOGIC_VECTOR (ADDRESS_LENGTH-CACHE_TAG_SIZE-1 downto 0);
    load_from_selector : IN STD_LOGIC;
    load_from_payload : OUT std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
    incoming_cpu_payload : IN std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
    incoming_sdram_controller_payload : IN std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0)
  );
end entity;

architecture behavior of cache_controller is

	COMPONENT cache_decoder
  PORT (
    address : IN std_logic_vector(ADDRESS_LENGTH-1 DOWNTO 0);
    tag : OUT std_logic_vector(CACHE_TAG_SIZE-1 DOWNTO 0);
    index : OUT std_logic_vector(CACHE_INDEX_SIZE-1 DOWNTO 0);
    offset : OUT std_logic_vector(CACHE_OFFSET_SIZE-1 DOWNTO 0)
  );
  END COMPONENT;

  COMPONENT mux2
		GENERIC (N : INTEGER);
		PORT (
			input_0 : IN std_logic_vector(N - 1 DOWNTO 0);
			input_1 : IN std_logic_vector(N - 1 DOWNTO 0);
			selector : IN std_logic;
			output : OUT std_logic_vector(N - 1 DOWNTO 0)
		);
	END COMPONENT;
  -- setting up link between decoder and cache_controller
	SIGNAL address : std_logic_vector(ADDRESS_LENGTH-1 DOWNTO 0) := (OTHERS => '0');
  -- decoder ...
  SIGNAL tag : std_logic_vector(CACHE_TAG_SIZE-1  DOWNTO 0);
	SIGNAL index : std_logic_vector(CACHE_INDEX_SIZE-1 DOWNTO 0);
  SIGNAL offset : std_logic_vector(CACHE_OFFSET_SIZE-1 DOWNTO 0);
  --------------------------------------------------------------------
  -- mux2 : Sram Cache Input Payload selector
	SIGNAL s_incoming_cpu_payload : std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
  SIGNAL s_incoming_sdram_controller_payload : std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
  SIGNAL s_load_from_selector : std_logic := '0';
  SIGNAL s_load_from_payload : std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
  --------------------------------------------------------------------
begin
	cache_decoder_instl : cache_decoder
	PORT MAP(
		address => address,
		tag => tag,
		index => index,
    offset => offset
  );
  mux2_sram_cache_input_payload : mux2
  GENERIC MAP(N => DATA_BANDWIDTH)
	PORT MAP(
		input_0 => s_incoming_cpu_payload,
		input_1 => s_incoming_sdram_controller_payload,
		selector => s_load_from_selector,
		output => s_load_from_payload
  );
   process(clk,address_in)
   begin
     IF (clk'EVENT AND clk = '1') THEN
       address<=address_in;
       END IF;
   end process;
  -- s_load_from_selector -> depends on dirty and valid bits ...
  
  -- sram Cache Input Payload selector
  process(clk,load_from_selector,incoming_cpu_payload,incoming_sdram_controller_payload)
  begin
    IF (clk'EVENT AND clk = '1') THEN
      s_load_from_selector<=load_from_selector;
      s_incoming_cpu_payload<=incoming_cpu_payload;
      s_incoming_sdram_controller_payload<=incoming_sdram_controller_payload;
    END IF;
  end process;
  sram_address(ADDRESS_LENGTH-CACHE_TAG_SIZE-1 downto ADDRESS_LENGTH-CACHE_TAG_SIZE-CACHE_INDEX_SIZE) <= index;
  sram_address(ADDRESS_LENGTH-CACHE_TAG_SIZE-CACHE_INDEX_SIZE -1 downto ADDRESS_LENGTH-CACHE_TAG_SIZE-CACHE_INDEX_SIZE-CACHE_OFFSET_SIZE) <= offset;
  load_from_payload<=s_load_from_payload;

  end architecture;
