# Project-1

## Overview

- install docker
- to build the project and run tests , run the following in terminal 
  ```bash
    make -j$(nproc) build
  ```

## states 

- Valid bit is 0 => CACHE `MISS` => Cache is updated with the new dataset 
-  

## mux2 left [temp]

 
payload associated with mux2 left
selector passed to mux2 that either causes sram cache to load from sdram controller
or from the data passed to it from the cpu . defaults to loading from cpu
0 :: cpu | 1:: sdram controller

```vhdl
entity cache_controller is
  port (
    load_from_selector : IN STD_LOGIC;
    load_from_payload : OUT std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
    incoming_cpu_payload : IN std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
    incoming_sdram_controller_payload : IN std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0)
  );
end entity;
```

## Dump

```vhdl
entity cache_controller is
  port (
    clk : IN STD_LOGIC;
    address_in : IN STD_LOGIC_VECTOR (ADDRESS_LENGTH-1 downto 0);
		sram_address : OUT STD_LOGIC_VECTOR (ADDRESS_LENGTH-CACHE_TAG_SIZE-1 downto 0);
    load_from_selector : IN STD_LOGIC;
    load_from_payload : OUT std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
    incoming_cpu_payload : IN std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0);
    incoming_sdram_controller_payload : IN std_logic_vector(DATA_BANDWIDTH - 1 DOWNTO 0)
    --------------------------------------------------------------------
    --------------------------------------------------------------------
   
    -- read or write signal coming from cpu
    -- wr_in : IN STD_LOGIC;
    -- cs : IN STD_LOGIC;
    -- cpu  outputs
    -- ready : OUT STD_LOGIC;

    -- sdram controller outputs
    -- address_out : OUT STD_LOGIC_VECTOR (ADDRESS_LENGTH-1 downto 0);
    -- mstrb : OUT STD_LOGIC;
    -- cache sram outputs
    -- wen : OUT STD_LOGIC;
    -- used to either write load data from cpu or cache
    -- 0 <> cpu
    -- 1 <> cache
    -- load_data : OUT STD_LOGIC;
    -- used to either return data from cache (hit - 1)
    -- or load it from sdram controler (0)
    -- dout_mux2 : OUT STD_LOGIC
    --------------------------------------------------------------------
    -- debug ...
    -- dirty_hit : OUT STD_LOGIC

  );
end entity;
```