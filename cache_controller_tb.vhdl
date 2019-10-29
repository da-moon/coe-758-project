LIBRARY ieee;
-- USE std.textio.ALL;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.utils_pkg.ALL;
USE work.cache_pkg.ALL;
USE std.textio.ALL;

ENTITY cache_controller_tb IS
END cache_controller_tb;
ARCHITECTURE testbench OF cache_controller_tb IS
    CONSTANT clock_period : TIME := 10 ns;
    CONSTANT TEST_TIME : TIME := 2000 ns;
    CONSTANT C_FILE_NAME : STRING := "test_results/cache_controller.txt";
    -- file output ...
    SIGNAL eof : std_logic := '0';
    FILE fptr : text;
    -- -----------------------------------
    SIGNAL clk : std_logic := '0';
    SIGNAL trig : STD_LOGIC := '1';
    SIGNAL cpu_cs_sig : STD_LOGIC;
    SIGNAL cpu_dout_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL addr_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL douta_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sram_addr_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sram_din_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sram_dout_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sdram_addr_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL sdram_dina_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sdram_douta_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL wr_rd_sig : STD_LOGIC;
    SIGNAL mstrb_sig : STD_LOGIC;
    SIGNAL ready_sig : STD_LOGIC;
    SIGNAL hit_sig : STD_LOGIC;
    SIGNAL tag_sig : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => 'U');
    SIGNAL index_sig : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => 'U');
    SIGNAL offset_sig : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => 'U');
    SIGNAL valid_bit_sig : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => 'U');
    SIGNAL dirty_bit_sig : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => 'U');
    SIGNAL state_sig : STD_LOGIC_VECTOR(3 DOWNTO 0);
    SIGNAL sram_wen_sig : STD_LOGIC_VECTOR(0 DOWNTO 0);
    COMPONENT clock_gen
        GENERIC (clock_period : TIME);
        PORT (
            clk : OUT std_logic
        );
    END COMPONENT;
    COMPONENT cache_controller
        PORT (
            clk : IN STD_LOGIC;
            wr_rd : IN STD_LOGIC;
            cpu_cs : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
            cpu_dout : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            sram_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            sram_din : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            sram_dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            sdram_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
            sdram_dina : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            sdram_douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            mstrb, ready : OUT STD_LOGIC;
            --debug
            tag : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            index : INOUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            offset : INOUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            valid_bit : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            dirty_bit : INOUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            hit_debug : INOUT STD_LOGIC;
            state_debug : INOUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            sram_wen_debug : INOUT STD_LOGIC_VECTOR(0 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT CPU_gen
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            trig : IN STD_LOGIC;
            Address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            wr_rd : OUT STD_LOGIC;
            cs : OUT STD_LOGIC;
            Dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    clock_gen_instl : clock_gen
    GENERIC MAP(clock_period => clock_period)
    PORT MAP(
        clk => clk
    );
    cpu_gen_instl : cpu_gen
    PORT MAP(
        clk => clk,
        rst => '0',
        trig => trig,
        Address => addr_sig,
        wr_rd => wr_rd_sig,
        cs => cpu_cs_sig,
        DOut => cpu_dout_sig
    );
    -- unit under test
    uut : cache_controller
    PORT MAP(
        clk => clk,
        addr => addr_sig,
        douta => douta_sig,
        cpu_cs => cpu_cs_sig,
        cpu_dout => cpu_dout_sig,
        sram_addr => sram_addr_sig,
        sram_din => sram_din_sig,
        sram_dout => sram_dout_sig,
        sdram_addr => sdram_addr_sig,
        sdram_dina => sdram_dina_sig,
        sdram_douta => sdram_douta_sig,
        wr_rd => wr_rd_sig,
        mstrb => mstrb_sig,
        ready => ready_sig,
        tag => tag_sig,
        index => index_sig,
        offset => offset_sig,
        valid_bit =>valid_bit_sig,
        dirty_bit =>dirty_bit_sig,
        hit_debug => hit_sig,
        state_debug => state_sig,
        sram_wen_debug => sram_wen_sig
    );
    PROCESS
        VARIABLE L : line;
        VARIABLE fstatus : file_open_status;
        VARIABLE counter : INTEGER;
    BEGIN
        WAIT FOR 1 ns;
        write(L, STRING'("testing cache controller !"));
        writeline(output, L);
        file_open(fstatus, fptr, C_FILE_NAME, write_mode);
        WHILE (counter * 10 ns < TEST_TIME) LOOP
            WAIT UNTIL rising_edge(clk);
            trig <= NOT trig;
            -- valid_bit_sig
            -- dirty_bit_sig
            REPORT "state_sig [ " & TO_STRING(state_sig) & " ] " &  "wr_rd_sig [ " & STD_LOGIC'IMAGE(wr_rd_sig) & " ] " & "hit_sig [ " & STD_LOGIC'IMAGE(hit_sig) & " ] " & "cpu_cs_sig [ " & STD_LOGIC'IMAGE(cpu_cs_sig) & " ] " &  "sram_wen_sig [ " & TO_STRING(sram_wen_sig) & " ] "  &  "valid_bit_sig [ " & STD_LOGIC'IMAGE(valid_bit_sig(to_integer(unsigned(index_sig))))& " ] " & "dirty_bit_sig [ " & STD_LOGIC'IMAGE(dirty_bit_sig(to_integer(unsigned(index_sig)))) & " ] " & "ready_sig [ " & STD_LOGIC'IMAGE(ready_sig) & " ] " & "mstrb_sig [ " & STD_LOGIC'IMAGE(mstrb_sig) & " ] "  & "trig [ " & STD_LOGIC'IMAGE(trig) & " ] " SEVERITY NOTE;
            write(L, STRING'( "state_sig [ " & TO_STRING(state_sig) & " ] " &  "wr_rd_sig [ " & STD_LOGIC'IMAGE(wr_rd_sig) & " ] " & "hit_sig [ " & STD_LOGIC'IMAGE(hit_sig) & " ] "& "cpu_cs_sig [ " & STD_LOGIC'IMAGE(cpu_cs_sig) & " ] " &  "sram_wen_sig [ " & TO_STRING(sram_wen_sig) & " ] "  &  "valid_bit_sig [ " & STD_LOGIC'IMAGE(valid_bit_sig(to_integer(unsigned(index_sig))))& " ] " & "dirty_bit_sig [ " & STD_LOGIC'IMAGE(dirty_bit_sig(to_integer(unsigned(index_sig)))) & " ] " & "ready_sig [ " & STD_LOGIC'IMAGE(ready_sig) & " ] " & "mstrb_sig [ " & STD_LOGIC'IMAGE(mstrb_sig) & " ] "  & "trig [ " & STD_LOGIC'IMAGE(trig) & " ] " ), right, 2);
            writeline(fptr, L);
            IF NOT is_X (tag_sig) THEN
                REPORT "input address [ " & TO_STRING(addr_sig) & " ] " & "tag_sig [ " & TO_STRING(tag_sig) & " ] " & "index_sig [ " & TO_STRING(index_sig) & " ] " & "offset_sig [ " & TO_STRING(offset_sig) & " ] " SEVERITY NOTE;
                write(L, STRING'("input address [ " & TO_STRING(addr_sig) & " ] " & "tag_sig [ " & TO_STRING(tag_sig) & " ] " & "index_sig [ " & TO_STRING(index_sig) & " ] " & "offset_sig [ " & TO_STRING(offset_sig) & " ] "), right, 2);
                writeline(fptr, L);
            END IF;
            REPORT "cpu_dout_sig [ " & TO_STRING(cpu_dout_sig) & " ] " & "douta_sig [ " & TO_STRING(douta_sig) & " ] "  SEVERITY NOTE;
            write(L, STRING'("cpu_dout_sig [ " & TO_STRING(cpu_dout_sig) & " ] " & "douta_sig [ " & TO_STRING(douta_sig) & " ] " ), right, 2);
            writeline(fptr, L);
            REPORT "sram_addr_sig [ " & TO_STRING(sram_addr_sig) & " ] " & "sram_din_sig [ " & TO_STRING(sram_din_sig) & " ] " & "sram_dout_sig [ " & TO_STRING(sram_dout_sig) & " ] " SEVERITY NOTE;
            write(L, STRING'("sram_addr_sig [ " & TO_STRING(sram_addr_sig) & " ] " & "sram_din_sig [ " & TO_STRING(sram_din_sig) & " ] " & "sram_dout_sig [ " & TO_STRING(sram_dout_sig) & " ] "), right, 2);
            writeline(fptr, L);
            REPORT "sdram_addr_sig [ " & TO_STRING(sdram_addr_sig) & " ] " & "sdram_dina_sig [ " & TO_STRING(sdram_dina_sig) & " ] " & "sdram_douta_sig [ " & TO_STRING(sdram_douta_sig) & " ] " SEVERITY NOTE;
            write(L, STRING'("sdram_addr_sig [ " & TO_STRING(sdram_addr_sig) & " ] " & "sdram_dina_sig [ " & TO_STRING(sdram_dina_sig) & " ] " & "sdram_douta_sig [ " & TO_STRING(sdram_douta_sig) & " ] "), right, 2);
            writeline(fptr, L);
            write(L, STRING'("---------------------------------------------------------------------------------------------"), right, 2);
            writeline(fptr, L);
        END LOOP;

        WAIT UNTIL rising_edge(clk);
        file_close(fptr);
        WAIT;
    END PROCESS;
END testbench;