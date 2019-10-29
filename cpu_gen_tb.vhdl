LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.utils_pkg.ALL;

ENTITY cpu_gen_tb IS
END cpu_gen_tb;

ARCHITECTURE testbench OF cpu_gen_tb IS
    -- constants ...
    CONSTANT clock_period : TIME := 10 ns;
    CONSTANT TEST_TIME : TIME := 2000 ns;
    CONSTANT C_FILE_NAME : STRING := "test_results/cpu_gen.txt";

    -- clock gen component
    COMPONENT clock_gen
        GENERIC (clock_period : TIME);
        PORT (
            clk : OUT std_logic
        );
    END COMPONENT;
    -- test component
    COMPONENT cpu_gen
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            trig : IN STD_LOGIC;
            Address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            wr_rd : OUT STD_LOGIC;
            cs : OUT STD_LOGIC;
            DOut : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;
    -- signals ...
    -- inputs ....
    SIGNAL clk : std_logic := '0';
    SIGNAL rst : std_logic := '0';
    SIGNAL trig : std_logic := '0';
    -- outputs ....
    SIGNAL Address : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL wr_rd : std_logic;
    SIGNAL cs : std_logic;
    SIGNAL DOut : STD_LOGIC_VECTOR (7 DOWNTO 0);
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
    uut : cpu_gen
    PORT MAP(
        clk => clk,
        rst => rst,
        trig => trig,
        Address => Address,
        wr_rd => wr_rd,
        cs => cs,
        DOut => DOut
    );

    stim_proc : PROCESS
        VARIABLE fstatus : file_open_status;
        VARIABLE file_line : line;
        VARIABLE var_data2 : INTEGER;

        -- Variables
        VARIABLE byte : bit_vector(0 TO 7);
        VARIABLE word : bit_vector(1 TO 32);
        VARIABLE half_byte : bit_vector(1 TO 4);
        VARIABLE L : line;
        VARIABLE counter : INTEGER;
        VARIABLE old_addr : STD_LOGIC_VECTOR (15 DOWNTO 0);
        VARIABLE temp : STD_LOGIC_VECTOR (1 TO 1);

    BEGIN
        WAIT FOR 1 ns;
        write(L, STRING'("cpu_gen tests ... :"));
        writeline(output, L);
        rst <= '1', '0' AFTER 100 ns;
        counter := 0;
        eof <= '0';
        WAIT UNTIL rst = '0';
        file_open(fstatus, fptr, C_FILE_NAME, write_mode);
        write(L, STRING'("| cs | wr_rd | add    | dout |"), right, 2);
        writeline(fptr, L);
        write(L, STRING'(" | ----|-------|--------|------|"), right, 2);
        writeline(fptr, L);

        WHILE (counter * 10 ns < TEST_TIME) LOOP
            WAIT UNTIL rising_edge(clk);
            trig <= NOT trig;
            IF old_addr /= Address THEN
                old_addr := Address;
                write(L, STRING'("|"), right, 1);
                temp(1) := cs;
                -- for beautifying output ...
                FOR C IN 1 TO (4 - TO_STRING(temp)'length)/2 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, TO_STRING(temp), right, 1);
                FOR C IN 1 TO (4 - TO_STRING(temp)'length)/2 + 1 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, STRING'("|"), right, 1);
                temp(1) := wr_rd;
                FOR C IN 1 TO (7 - TO_STRING(temp)'length)/2 - 1 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, TO_STRING(temp), right, 1);
                FOR C IN 1 TO (7 - TO_STRING(temp)'length)/2 + 1 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, STRING'("|"), right, 1);

                FOR C IN 1 TO (6 - TO_HEX_STRING(Address)'length)/2 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, STRING'("0x"), right, 1);
                write(L, TO_HEX_STRING(Address), right, 1);
                FOR C IN 1 TO (6 - TO_HEX_STRING(Address)'length)/2 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, STRING'("|"), right, 1);
                FOR C IN 1 TO (4 - TO_HEX_STRING(DOut)'length)/2 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, STRING'("0x"), right, 1);
                write(L, TO_HEX_STRING(DOut), right, 1);
                FOR C IN 1 TO (4 - TO_HEX_STRING(DOut)'length)/2 LOOP
                    write(L, STRING'(" "), right, 1);
                END LOOP;
                write(L, STRING'("|"), right, 1);
                writeline(fptr, L);
                write(L, STRING'(" | ----|-------|--------|------|"), right, 2);
                writeline(fptr, L);
            END IF;
        END LOOP;
        WAIT UNTIL rising_edge(clk);
        eof <= '1';
        file_close(fptr);
        WAIT;
    END PROCESS;
END testbench;