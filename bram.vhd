LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE STD.TEXTIO.ALL;
USE IEEE.STD_LOGIC_TEXTIO.ALL;
USE work.cache_pkg.ALL;
USE work.utils_pkg.ALL;
ENTITY bram IS
  GENERIC (
    addr : INTEGER := 10;
    DATA : INTEGER := 32;
    EDGE : EdgeType := RISING;
    MODE : MODEType := NO_CHANGE;
    RamFileName : STRING
  );
  PORT (
    clk, we : IN STD_LOGIC;
    adr : IN STD_LOGIC_VECTOR(addr - 1 DOWNTO 0);
    din : IN STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0);
    dout : OUT STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0)
  );
END;
ARCHITECTURE behaviour OF bram IS
  CONSTANT memTypeLength : INTEGER := 2 ** addr - 1;
  TYPE MemType IS ARRAY(0 TO memTypeLength) OF STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0);
  IMPURE FUNCTION InitRamFromFile (ARG : IN STRING) RETURN MemType IS
    -- FILE RamFile : text IS IN ARG;
    FILE RamFile : text;
    VARIABLE fstatus : file_open_status;
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
      CASE MODE IS
        WHEN READ_FIRST => IF rising_edge(clk) THEN
        IF NOT is_X(mem(to_i(adr))) THEN
          do <= mem(to_i(adr));
        ELSE
          do <= (OTHERS => '0');
        END IF;
        IF we = '1' THEN
          IF NOT is_X(din) THEN
            mem(to_i(adr)) <= din;
          ELSE
            mem(to_i(adr)) <= (OTHERS => '0');
          END IF;
        END IF;
      END IF;
      WHEN WRITE_FIRST => IF rising_edge(clk) THEN
      IF we = '1' THEN
        IF NOT is_X(din) THEN
          mem(to_i(adr)) <= din;
          do <= din;
        ELSE
          mem(to_i(adr)) <= (OTHERS => '0');
          do <= (OTHERS => '0');
        END IF;
      ELSE
        IF NOT is_X(mem(to_i(adr))) THEN
          do <= mem(to_i(adr));
        ELSE
          do <= (OTHERS => '0');
        END IF;
      END IF;
    END IF;
    WHEN NO_CHANGE => IF rising_edge(clk) THEN
    IF we = '1' THEN
      IF NOT is_X(din) THEN
        mem(to_i(adr)) <= din;
      ELSE
        mem(to_i(adr)) <= (OTHERS => '0');
      END IF;
    ELSE
      IF NOT is_X(mem(to_i(adr))) THEN
        do <= mem(to_i(adr));
      ELSE
        do <= (OTHERS => '0');
      END IF;
    END IF;
  END IF;
END CASE;
ELSE
CASE MODE IS
  WHEN READ_FIRST => IF falling_edge(clk) THEN
    IF NOT is_X(mem(to_i(adr))) THEN
      do <= mem(to_i(adr));
    ELSE
      do <= (OTHERS => '0');
    END IF;
    IF we = '1' THEN
      IF NOT is_X(din) THEN
        mem(to_i(adr)) <= din;
      ELSE
        mem(to_i(adr)) <= (OTHERS => '0');
      END IF;
    END IF;
END IF;
WHEN WRITE_FIRST => IF falling_edge(clk) THEN
IF we = '1' THEN
  IF NOT is_X(din) THEN
    mem(to_i(adr)) <= din;
    do <= din;
  ELSE
    mem(to_i(adr))  <= (OTHERS => '0');
    do <= (OTHERS => '0');
  END IF;
ELSE
  IF NOT is_X(mem(to_i(adr))) THEN
    do <= mem(to_i(adr));
  ELSE
    do<= (OTHERS => '0');
  END IF;
END IF;
END IF;
WHEN NO_CHANGE => IF falling_edge(clk) THEN
IF we = '1' THEN
  IF NOT is_X(din) THEN
    mem(to_i(adr)) <= din;
  ELSE
    mem(to_i(adr))<= (OTHERS => '0');
  END IF;
ELSE
  IF NOT is_X(mem(to_i(adr))) THEN
    do <= mem(to_i(adr));
  ELSE
    do <= (OTHERS => '0');
  END IF;
END IF;
END IF;
END CASE;
END IF;
END PROCESS;
--do <= mem(to_i(adr));
dout <= do;
END behaviour;