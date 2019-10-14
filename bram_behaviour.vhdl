
ARCHITECTURE behaviour OF bram IS
constant memTypeLength : INTEGER := 2 ** ADDR - 1;
TYPE MemType IS ARRAY(0 TO memTypeLength) OF STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0);
impure FUNCTION InitRamFromFile (ARG : IN STRING) RETURN MemType IS
    -- FILE RamFile : text IS IN ARG;
    file RamFile: text;
    variable fstatus       :file_open_status;
    VARIABLE RamFileLine : line;
    VARIABLE RAM : MemType;
BEGIN
    file_open(fstatus, RamFile, ARG, read_mode);
    FOR I IN MemType'RANGE LOOP
        readline (RamFile, RamFileLine);
        hread (RamFileLine, RAM(I)
        );
    END LOOP; 
    file_close(RamFile);
    RETURN RAM;
END InitRamFromFile;
SIGNAL mem : MemType := InitRamFromFile(RamFileName);
SIGNAL do : STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
PROCESS (clk)
BEGIN
    IF EDGE = RISING THEN
        IF we = '1' THEN
            mem(to_i(adr)) <= din;
        ELSE
            do <= mem(to_i(adr));
        END IF;
    ELSE
        IF we = '1' THEN
            mem(to_i(adr)) <= din;
        ELSE
            do <= mem(to_i(adr));
        END IF;
    END IF;
END PROCESS;

--do <= mem(to_i(adr));
dout <= do;

END behaviour;