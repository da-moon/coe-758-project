library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use work.cache_primitives.ALL;

entity cache_controller is
  port (
    clk : IN STD_LOGIC;
    address_in : IN STD_LOGIC_VECTOR (ADDRESS_LENGTH-1 downto 0);
		sram_address : OUT STD_LOGIC_VECTOR (ADDRESS_LENGTH-CACHE_TAG_SIZE-1 downto 0)

    -- cs : IN STD_LOGIC;
    -- wr_in : IN STD_LOGIC;
    -- cpu  outputs
    -- ready : OUT STD_LOGIC;

    -- sdram controller outputs
    -- address_out : OUT STD_LOGIC_VECTOR (ADDRESS_LENGTH-1 downto 0);
    -- mstrb : OUT STD_LOGIC;
    -- wr_out : OUT STD_LOGIC;
    -- cache sram outputs
    -- wen : OUT STD_LOGIC;
    -- used to either write load data from cpu or cache
    -- 0 <> cpu
    -- 1 <> cache
    -- load_data : OUT STD_LOGIC;
    -- used to either return data from cache (hit - 1)
    -- or load it from sdram controler (0)
    -- dout_mux2 : OUT STD_LOGIC

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
  -- setting up link between decoder and cache_controller
  	--Inputs
	SIGNAL address : std_logic_vector(15 DOWNTO 0) := (OTHERS => '0');
	--Outputs
	SIGNAL tag : std_logic_vector(7 DOWNTO 0);
	SIGNAL index : std_logic_vector(2 DOWNTO 0);
	SIGNAL offset : std_logic_vector(4 DOWNTO 0);
begin
	-- Instantiate link between cache decoder and signals
	cache_decoder_instl : cache_decoder
	PORT MAP(
		address => address,
		tag => tag,
		index => index,
		offset => offset
	);
  process(clk,address_in)
  begin
    IF (clk'EVENT AND clk = '1') THEN
      address<=address_in;
		END IF;
    
  end process;
  sram_address(ADDRESS_LENGTH-CACHE_TAG_SIZE-1 downto ADDRESS_LENGTH-CACHE_TAG_SIZE-CACHE_INDEX_SIZE) <= index;
  sram_address(ADDRESS_LENGTH-CACHE_TAG_SIZE-CACHE_INDEX_SIZE -1 downto ADDRESS_LENGTH-CACHE_TAG_SIZE-CACHE_INDEX_SIZE-CACHE_OFFSET_SIZE) <= offset;

end architecture;
