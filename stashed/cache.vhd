library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use work.cache_primitives.ALL;

entity cache is
  port (
    clk: in std_logic;
    reset : in std_logic;
    load_flag : in std_logic;
    we : in std_logic;
    address : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
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
end entity;

architecture behavior of cache is
  -- constants
  -- constant SIZE : natural := 256; 
  
  component cache_decoder
    port (
      address : in std_logic_vector(ADDRESS_LENGTH-1 downto 0);
      tag : out cache_tag_vector;
      index : out cache_index_vector;
      offset : out cache_offset_vector
    );
  end component;
  component mux8
    generic(N : integer);
    port (
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
  end component;

  component mux2
    generic(N : integer);
    port (
      input_0 : IN STD_LOGIC_VECTOR (N-1 downto 0);
      input_1 : IN STD_LOGIC_VECTOR (N-1 downto 0);
      selector : IN STD_LOGIC;
      output : OUT STD_LOGIC_VECTOR (N-1 downto 0)
    );
  end component;
  
  -- decode addr
  signal signal_address_tag : cache_tag_vector;
  signal signal_address_index : cache_index_vector;
  signal signal_address_offset : cache_offset_vector;
  -- defining real memory
  signal signal_ram1_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram2_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram3_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram4_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram5_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram6_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram7_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_ram8_datum : std_logic_vector((DATA_BLOCK_SIZE)-1 downto 0);
  signal signal_valid_datum, signal_dirty_datum: std_logic;
  signal signal_tag_datum : cache_tag_vector;

  -- is cache miss occurs or not
  -- selector for mux8
  signal signal_rd_s : cache_offset_vector; 
  signal signal_rd_tag : cache_tag_vector;

begin
  cache_decoder0 : cache_decoder port map(
    address => address,
    tag => signal_address_tag,
    index => signal_address_index,
    offset => signal_address_offset
  );
  -- read & write data or load block from memory
  process(clk, reset, we, signal_address_tag, signal_valid_datum, signal_address_index, signal_address_offset, write_data1, write_data2, write_data3, write_data4, write_data5, write_data6, write_data7, write_data8, write_data0)
    -- v_idx 3 bits
    variable v_idx : natural;
    variable v_valid_data : valid_array_type(0 to DATA_BANDWIDTH-1);
    variable v_tag_data : tag_array_type(0 to DATA_BANDWIDTH-1);
    variable v_dirty_data : dirty_array_type(0 to DATA_BANDWIDTH-1);
    variable v_ram1_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram2_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram3_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram4_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram5_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram6_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram7_data : dummy_ram(0 to DATA_BANDWIDTH-1);
    variable v_ram8_data : dummy_ram(0 to DATA_BANDWIDTH-1);
  begin
       -- initialization
       if reset = '1' then
         -- initialize with zeros
         v_valid_data := (others => '0');
       -- writeback
       elsif rising_edge(clk) then
       -- pull the notification from the memory
       if load_data_en = '1' then
           v_idx := to_integer(unsigned(signal_address_index));
           -- when the ram_data is initial state
           v_valid_data(v_idx) := '1';
           v_dirty_data(v_idx) := '0';
           v_tag_data(v_idx) := signal_address_tag;
           v_ram1_data(v_idx) := write_data1;
           v_ram2_data(v_idx) := write_data2;
           v_ram3_data(v_idx) := write_data3;
           v_ram4_data(v_idx) := write_data4;
           v_ram5_data(v_idx) := write_data5;
           v_ram6_data(v_idx) := write_data6;
           v_ram7_data(v_idx) := write_data7;
           v_ram8_data(v_idx) := write_data8;
       elsif we = '1' then
         if signal_valid_datum = '1' then
           -- cache hit!
           if signal_tag_datum = signal_address_tag then
             v_dirty_data(v_idx) := '1';
             v_idx := to_integer(unsigned(signal_address_index));
--             case signal_address_offset is
--              case signal_address_offset is
--               when "000" =>
--                 v_ram1_data(v_idx) := write_data0;
--               when "001" =>
--                 v_ram2_data(v_idx) := write_data0;
--               when "010" =>
--                 v_ram3_data(v_idx) := write_data0;
--               when "011" =>
--                 v_ram4_data(v_idx) := write_data0;
--               when "100" =>
--                 v_ram5_data(v_idx) := write_data0;
--               when "101" =>
--                 v_ram6_data(v_idx) := write_data0;
--               when "110" =>
--                 v_ram7_data(v_idx) := write_data0;
--               when "111" =>
--                 v_ram8_data(v_idx) := write_data0;
--               when others =>
                 -- do nothing
--             end case;
          end if;
         end if;
       end if;
       end if;
-- 
--     -- read
--     if not is_X(signal_address_index) then
--       signal_ram1_datum <= v_ram1_data(to_integer(unsigned(signal_address_index)));
--       signal_ram2_datum <= v_ram2_data(to_integer(unsigned(signal_address_index)));
--       signal_ram3_datum <= v_ram3_data(to_integer(unsigned(signal_address_index)));
--       signal_ram4_datum <= v_ram4_data(to_integer(unsigned(signal_address_index)));
--       signal_ram5_datum <= v_ram5_data(to_integer(unsigned(signal_address_index)));
--       signal_ram6_datum <= v_ram6_data(to_integer(unsigned(signal_address_index)));
--       signal_ram7_datum <= v_ram7_data(to_integer(unsigned(signal_address_index)));
--       signal_ram8_datum <= v_ram8_data(to_integer(unsigned(signal_address_index)));
--       signal_dirty_datum <= v_dirty_data(to_integer(unsigned(signal_address_index)));
--       signal_valid_datum <= v_valid_data(to_integer(unsigned(signal_address_index)));
--       signal_tag_datum <= v_tag_data(to_integer(unsigned(signal_address_index)));
--     end if;
   end process;
-- 
--   valid_flag <= signal_valid_datum;
--   dirty_flag <= signal_dirty_datum;
--   Inst_mux8: mux8 generic map(N=>32)
--   PORT MAP(
--     clk => clk,
--     input_000 => signal_ram1_datum,
--     input_001 => signal_ram2_datum,
--     input_010 => signal_ram3_datum,
--     input_011 => signal_ram4_datum,
--     input_100 => signal_ram5_datum,
--     input_101 => signal_ram6_datum,
--     input_110 => signal_ram7_datum,
--     input_111 => signal_ram8_datum,
--     selector => signal_rd_s,
--     output => read_data
--   );
--   -- out rd_tag, rd_index,rd0*
--   Inst_mux2 : mux2 generic map(N=>CACHE_TAG_SIZE)
--   port map (
--     clk => clk,
-- 	 input_0 => signal_tag_datum,
--     input_1 => signal_address_tag,
--     selector => tag,
--     output => signal_rd_tag
--   );
--   read_data_tag_index <= signal_rd_tag & signal_address_index;
-- 
--   read_data1 <= signal_ram1_datum;
--   read_data2 <= signal_ram2_datum;
--   read_data3 <= signal_ram3_datum;
--   read_data4 <= signal_ram4_datum;
--   read_data5 <= signal_ram5_datum;
--   read_data6 <= signal_ram6_datum;
--   read_data7 <= signal_ram7_datum;
--   read_data8 <= signal_ram8_datum;
end architecture;
