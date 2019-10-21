LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.utils_pkg.ALL;
USE work.cache_pkg.ALL;

ENTITY bram_tb IS
END bram_tb;

ARCHITECTURE testbench OF bram_tb IS
  -- constants ... 
  CONSTANT clock_period : TIME := 10 ns;
  CONSTANT TEST_TIME : TIME := 2000 ns;
  CONSTANT C_FILE_NAME : STRING := "test_results/bram.txt";
  --    
  CONSTANT addr : INTEGER := 8;
  CONSTANT DATA : INTEGER := 8;
  CONSTANT EDGE : EdgeType := RISING;
  CONSTANT RamFileName : STRING := "fixtures/bram.hex";
  -- clock gen component
  COMPONENT clock_gen
    GENERIC (clock_period : TIME);
    PORT (
      clk : OUT std_logic
    );
  END COMPONENT;
  -- test component
  COMPONENT bram
    GENERIC (
      addr : INTEGER;
      DATA : INTEGER;
      EDGE : EdgeType;
      MODE : MODEType := NO_CHANGE;
      RamFileName : STRING
    );
    PORT (
      clk : IN STD_LOGIC;
      we : IN STD_LOGIC;
      adr : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      din : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
      dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
    );
  END COMPONENT;
  -- signals ... 
  -- inputs ....
  SIGNAL clk : std_logic := '0';
  SIGNAL rst : std_logic := '0';
  SIGNAL we : std_logic := '0';
  -- outputs ....
  SIGNAL adr : STD_LOGIC_VECTOR (7 DOWNTO 0) := "00000000";
  SIGNAL din : STD_LOGIC_VECTOR (7 DOWNTO 0) := x"00";
  SIGNAL dout : STD_LOGIC_VECTOR (7 DOWNTO 0);
  -- file output ...
  SIGNAL eof : std_logic := '0';
  FILE fptr : text;

BEGIN

  -- Clock generator instl
  clock_gen_instl : clock_gen
  GENERIC MAP(clock_period => 10 ns)
  PORT MAP(
    clk => clk
  );
  -- unit under test instl... 
  uut : bram
  GENERIC MAP(
    addr => addr,
    DATA => DATA,
    EDGE => EDGE,
    RamFileName => RamFileName
  )
  PORT MAP(
    clk => clk,
    we => we,
    adr => adr,
    din => din,
    dout => dout
  );

  stim_proc : PROCESS
    VARIABLE fstatus : file_open_status;
    VARIABLE L : line;
    VARIABLE counter : INTEGER;
    VARIABLE old_addr : STD_LOGIC_VECTOR (7 DOWNTO 0);
    VARIABLE temp : STD_LOGIC_VECTOR (1 TO 1);
  BEGIN
    WAIT FOR 1 ns;
    -- write(L, string'("bram(file backend) tests ... :"));
    -- writeline(output, L);
    rst <= '1', '0' AFTER 100 ns;
    counter := 0;
    -- 
    eof <= '0';
    -- 
    WAIT UNTIL rst = '0';
    file_open(fstatus, fptr, C_FILE_NAME, write_mode);
    write(L, STRING'("| write_enable | address | din  | dout |"), right, 2);
    writeline(fptr, L);
    write(L, STRING'(" | --------------|---------|------|------|"), right, 2);
    writeline(fptr, L);
    WHILE (counter * 10 ns < TEST_TIME) LOOP
      WAIT UNTIL rising_edge(clk);
      we <= NOT we;
      IF we = '1' THEN
        adr <= std_logic_vector(unsigned(adr) + (1));
        din <= std_logic_vector(unsigned(din) + (1));
      END IF;
      temp(1) := we;
      write(L, STRING'("|"), right, 1);
      -- for beautifying output ...
      FOR C IN 1 TO (13 - TO_STRING(temp)'length)/2 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;
      write(L, TO_STRING(temp), right, 1);
      FOR C IN 1 TO (13 - TO_STRING(temp)'length)/2 + 1 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;
      write(L, STRING'("|"), right, 1);
      FOR C IN 1 TO (7 - TO_STRING(temp)'length)/2 - 1 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;
      write(L, STRING'("0x"), right, 1);
      write(L, TO_HEX_STRING(adr), right, 1);
      FOR C IN 1 TO (7 - TO_STRING(temp)'length)/2 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;

      write(L, STRING'("|"), right, 1);
      FOR C IN 1 TO (4 - TO_STRING(temp)'length)/2 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;
      write(L, STRING'("0x"), right, 1);
      write(L, TO_HEX_STRING(din), right, 1);

      FOR C IN 1 TO (4 - TO_STRING(temp)'length)/2 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;

      write(L, STRING'("|"), right, 1);
      FOR C IN 1 TO (4 - TO_STRING(temp)'length)/2 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;
      write(L, STRING'("0x"), right, 1);
      write(L, TO_HEX_STRING(dout), right, 1);
      FOR C IN 1 TO (4 - TO_STRING(temp)'length)/2 LOOP
        write(L, STRING'(" "), right, 1);
      END LOOP;
      write(L, STRING'("|"), right, 1);
      writeline(fptr, L);
      write(L, STRING'(" | --------------|---------|------|------|"), right, 2);
      writeline(fptr, L);
    END LOOP;
    WAIT UNTIL rising_edge(clk);
    eof <= '1';
    file_close(fptr);
    WAIT;
  END PROCESS;
END testbench;