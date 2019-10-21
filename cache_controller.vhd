LIBRARY ieee
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.cache_pkg.ALL;

ENTITY cache_controller IS
    PORT (
        clk : IN STD_LOGIC;
        addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sram_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sram_din : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sram_dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sdram_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        sdram_dina : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sdram_douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        cache_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_rd, mstrb, ready, cd : OUT STD_LOGIC);
END cache_controller;