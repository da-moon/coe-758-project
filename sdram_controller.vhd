LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.cache_pkg.ALL;
ENTITY sdram_controller IS
    PORT (
        clk : IN STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        wr_rd : IN STD_LOGIC;
        mstrb : IN STD_LOGIC;
        dina : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END sdram_controller;