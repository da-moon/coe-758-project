
ARCHITECTURE Behavioral OF sdram_controller IS
    SIGNAL RAM_SIG : MAIN_MEMORY;
    SIGNAL counter : INTEGER := 0;
BEGIN
    PROCESS (CLK)
    BEGIN
        IF CLK'event AND CLK = '1' THEN

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
END Behavioral;