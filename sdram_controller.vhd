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


architecture Behavioral of sdram_controller is

SIGNAL RAM_SIG : MAIN_MEMORY;
    SIGNAL counter : INTEGER := 0;
BEGIN
    PROCESS (clk)
    BEGIN
        IF clk'event AND clk = '1' THEN

            IF counter = 0 THEN
                FOR I IN 0 TO 7 LOOP
                    FOR J IN 0 TO 31 LOOP
                        RAM_SIG(i, j) <= "11110000";
                    END LOOP;
                END LOOP;
                counter <= 1;
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

end Behavioral;

