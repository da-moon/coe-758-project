LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE work.cache_pkg.ALL;
USE work.utils_pkg.ALL;

ENTITY sdram_controller IS
    PORT (
        clk : IN STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
        wr_rd : INOUT STD_LOGIC;
        mstrb : INOUT STD_LOGIC;
        dina : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
END sdram_controller;
ARCHITECTURE Behavioral OF sdram_controller IS
    SIGNAL RAM_SIG : MAIN_MEMORY;
    SIGNAL init : INTEGER := 0;
BEGIN
    PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN
            IF init = 0 THEN
                RAM_SIG <= INITIALIZE_MAIN_MEMORY;
                init <= 1;
            END IF;
            IF mstrb = '1' THEN
                IF wr_rd = '1' THEN
                    RAM_SIG(to_integer(unsigned(addr(7 DOWNTO 5))), to_integer(unsigned(addr(4 DOWNTO 0)))) <= dina;
                ELSE
                    douta <= RAM_SIG(to_integer(unsigned(addr(7 DOWNTO 5))), to_integer(unsigned(addr(4 DOWNTO 0))));
                END IF;
            END IF;
        END IF;
    END PROCESS;

END Behavioral;