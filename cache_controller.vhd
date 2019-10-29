LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.cache_pkg.ALL;
USE work.utils_pkg.ALL;

ENTITY cache_controller IS
    PORT (
        clk : IN STD_LOGIC;
        wr_rd : IN STD_LOGIC;
        cpu_cs : IN STD_LOGIC;
        addr : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        -- our input from cpu
        cpu_dout : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        -- our output form cache controller
        cpu_din : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
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
        dirty_flag : INOUT STD_LOGIC;
        hit_debug : INOUT STD_LOGIC;
        sdram_wr_rd_debug : INOUT STD_LOGIC;
        sram_wen_debug : INOUT STD_LOGIC_VECTOR(0 DOWNTO 0)
    );
END cache_controller;
ARCHITECTURE Behavioral OF cache_controller IS
    -- DISK BACKED BRAM ....  COMMENT OUT WHEN BUILDING IN ISE
    CONSTANT bram_addr_size : INTEGER := 8;
    CONSTANT bram_data_size : INTEGER := 8;
    CONSTANT EDGE : EdgeType := RISING;
    CONSTANT RamFileName : STRING := "fixtures/bram.hex";
    -- END OF BRAM CONTANTS
    SIGNAL tag_register : CACHE_MEMORY := (OTHERS => (OTHERS => '0'));
    --bram(cache tag_register) Signals
    SIGNAL sram_addr_sig, sram_din_sig, sram_dout_sig : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sram_wen : STD_LOGIC_VECTOR(0 DOWNTO 0) := (OTHERS => '0');
    --SDRAM Signals
    SIGNAL sdram_dina_sig, sdram_douta_sig : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sdram_addr_sig : STD_LOGIC_VECTOR(15 DOWNTO 0) := (OTHERS => '0');
    SIGNAL sdram_mstrb_sig, sdram_wr_rd_sig : STD_LOGIC := 'U';
    SIGNAL counter : INTEGER := 0;
    --CPU Signals

    -- this is needed to make sure offset tha is extracted from cpu payload doesn't
    -- mess up and point to an out of index entity of CACHE_MEMORY
    -- basically , helps with making an alias for offset
    -- SIGNAL sdoffset : INTEGER := 0;
    -- debug signals
    -- SIGNAL hit_debug_sig : STD_LOGIC;
    SIGNAL ready_sig : STD_LOGIC := 'U';
    --Components
    COMPONENT sdram_controller
        PORT (
            clk : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            wr_rd : INOUT STD_LOGIC;
            mstrb : INOUT STD_LOGIC;
            dina : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT bram
        -- TODO : COMMENT OUT THE GENERIC WHEN COMPILING IN ISE
        GENERIC (
            addr : INTEGER;
            DATA : INTEGER;
            EDGE : EdgeType;
            MODE : MODEType := NO_CHANGE;
            RamFileName : STRING
        );
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    sdram_controller_instl : sdram_controller
    PORT MAP(
        clk => clk,
        addr => sdram_addr_sig,
        wr_rd => sdram_wr_rd_sig,
        mstrb => sdram_mstrb_sig,
        dina => sdram_dina_sig,
        douta => sdram_douta_sig
    );
    bram_instl : bram
    -- TODO : COMMENT OUT THE GENERIC WHEN COMPILING IN ISE
    GENERIC MAP(
        addr => bram_addr_size,
        DATA => bram_data_size,
        EDGE => EDGE,
        RamFileName => RamFileName
    )
    PORT MAP(
        clka => clk,
        wea => sram_wen,
        addra => sram_addr_sig,
        dina => sram_din_sig,
        douta => sram_dout_sig
    );
    PROCESS (
        clk,
        cpu_cs)
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            IF (cpu_cs = '1') THEN
                -- linking signals to outputs
                ready <= ready_sig;
                sdram_wr_rd_debug <= sdram_wr_rd_sig;
                mstrb <= sdram_mstrb_sig;
                sram_wen_debug <= sram_wen;
                sram_addr <= sram_addr_sig;
                sram_din <= sram_din_sig;
                sram_dout <= sram_dout_sig;
                sdram_addr <= sdram_addr_sig;
                sdram_dina <= sdram_dina_sig;
                sdram_douta <= sdram_douta_sig;
                -- extracting tag ,index and offset values from what the cpu gave us
                tag <= GET_TAG(addr);
                index <= GET_INDEX(addr);
                offset <= GET_OFFSET(addr);
                -- initialize tag_register before dealing with different ops...
                IF (counter /= 64) THEN
                    -- since sdram hasn't been initialized, set ready signal to zero
                    ready_sig <= '0';
                    sdram_addr_sig(4 DOWNTO 0) <= (OTHERS => '0');
                    -- passing the given index to sdram
                    sdram_addr_sig(7 DOWNTO 5) <= index;
                    -- passing the given tag to sdram
                    sdram_addr_sig(15 DOWNTO 8) <= tag;
                    -- passing data to sdram
                    sdram_dina_sig <= cpu_dout;
                    -- make sure that the visited tags in tag_register are not set initially
                    tag_register(to_integer(unsigned(index))) <= (OTHERS => 'U');
                    -- setting valid bits to 0 and dirty bits to 0
                    valid_bit(to_integer(unsigned(index))) <= '0';
                    dirty_bit(to_integer(unsigned(index))) <= '0';

                    -- counter is not 64 so we must initialize sdram values
                    IF (counter MOD 2 = 1) THEN
                        sdram_mstrb_sig <= '0';
                    ELSE
                        sdram_mstrb_sig <= '1';
                        -- setting write bits to write payloads
                        -- to sdram for initialization
                        sdram_wr_rd_sig <= '1';
                    END IF;
                    cpu_din <= (OTHERS => 'U');

                    counter <= counter + 1;
                ELSE
                    -- making sure that after initialization we have the correct flags
                    dirty_flag <= '0';
                    hit_debug <= '0';
                    -- sdram has been initialized so set ready to 1
                    ready_sig <= '1';
                    -- testing to see if sdram has been properly initialized 
                    sdram_mstrb_sig <= '1';
                    sdram_wr_rd_sig <= '0';

                END IF;
                IF ready_sig = '1' THEN
                    -- in cases of miss...
                    IF hit_debug = '0' THEN
                        -- In case dirty bit is set to 0
                        -- eg , case 3
                        IF (dirty_flag = '0') THEN

                            -- putting the tag given by the cpu into local tag register
                            tag_register(to_integer(unsigned(index))) <= tag;
                            IF valid_bit(to_integer(unsigned(index))) = '0' THEN
                                -- setting valid bit to 1
                                valid_bit(to_integer(unsigned(index))) <= '1';
                            END IF;
                            -- preparing to read from cache controller
                            sdram_mstrb_sig <= '1';

                            sdram_wr_rd_sig <= '0';
                            -- preparing to write to sram
                            sram_wen <= "1";
                            -- before doing any ops, do cache block replacement and set 
                            -- local state tag tracker
                            -- passing offset zero to sdram
                            sdram_addr_sig(4 DOWNTO 0) <= (OTHERS => '0');
                            -- sram_addr_sig(4 DOWNTO 0) <= offset;
                            -- passing the given index to sdram
                            sdram_addr_sig(7 DOWNTO 5) <= index;
                            -- passing the given tag to sdram
                            sdram_addr_sig(15 DOWNTO 8) <= tag;
                            -- passing offset and index to sram
                            sram_addr_sig(4 DOWNTO 0) <= offset;
                            sram_addr_sig(7 DOWNTO 5) <= index;

                            sram_din_sig <= sdram_douta_sig;

                        END IF;
                        -- In case we have a miss and dirty flag is set to 1
                        -- bahaviour case 4
                        IF (dirty_flag = '1') THEN
                            -- analyzing  dirty bit for corresponding cpu address ...
                            -- if it is set to 1 , then write value in sram into sdram.
                            IF (dirty_bit(to_integer(unsigned(index))) = '1') THEN
                                sram_addr_sig(4 DOWNTO 0) <= offset;
                                sram_addr_sig(7 DOWNTO 5) <= index;
                                -- passing index and offset zero to sdram
                                --  to prepare it for writing
                                sdram_addr_sig(4 DOWNTO 0) <= (OTHERS => '0');
                                -- sram_addr_sig(4 DOWNTO 0) <= offset;
                                -- passing the given index to sdram
                                sdram_addr_sig(7 DOWNTO 5) <= index;
                                -- passing the given tag to sdram
                                sdram_addr_sig(15 DOWNTO 8) <= tag;
                                -- passing offset and index to sram
                                sram_wen <= "0";
                                sdram_mstrb_sig <= '1';
                                sdram_wr_rd_sig <= '1';
                                sdram_dina_sig <= sram_dout_sig;
                            END IF;
                            -- putting the tag given by the cpu into local tag register
                            tag_register(to_integer(unsigned(index))) <= tag;
                            -- setting valid bit to 1
                            valid_bit(to_integer(unsigned(index))) <= '1';

                            sdram_addr_sig(4 DOWNTO 0) <= (OTHERS => '0');
                            -- sram_addr_sig(4 DOWNTO 0) <= offset;
                            -- passing the given index to sdram
                            sdram_addr_sig(7 DOWNTO 5) <= index;

                            -- passing the given tag to sdram
                            sdram_addr_sig(15 DOWNTO 8) <= tag;
                            -- passing offset and index to sram
                            sram_addr_sig(4 DOWNTO 0) <= offset;
                            sram_addr_sig(7 DOWNTO 5) <= index;

                            sdram_mstrb_sig <= '1';
                            -- preparing to read from cache controller
                            sdram_wr_rd_sig <= '0';
                            -- preparing to write to sram
                            sram_wen <= "1";
                            sram_din_sig <= sdram_douta_sig;
                        END IF;
                   
                        -- evaluating HIT/MISS 
                        IF (tag_register(to_integer(unsigned(index))) = tag) THEN
                             -- setting hit signal
                             hit_debug<= '1';
                            IF (wr_rd = '1') THEN
                                -- setting sdram offset to zero
                                sdram_addr_sig(4 DOWNTO 0) <= (OTHERS => '0');
                                -- passing the given index to sdram
                                sdram_addr_sig(7 DOWNTO 5) <= index;
                                -- passing the given tag to sdram
                                sdram_addr_sig(15 DOWNTO 8) <= tag;
                                -- passing offset and index to sram
                                sram_addr_sig(4 DOWNTO 0) <= offset;
                                sram_addr_sig(7 DOWNTO 5) <= index;
                                -- writing incoming data
                                -- to cache tag_register (bram) because it was in hit state
                                -- we are writing to sram so there would be a collision
                                -- between sdram value and sram and we must set dirty bit
                                -- setting dirty for corresponding cpu address to 1
                                dirty_bit(to_integer(unsigned(index))) <= '1';
                                -- setting dirty flag to 1
                                dirty_flag <= '1';
                                sram_wen <= "1";
                                sram_din_sig <= cpu_dout;
                                -- cpu_din <= cpu_dout;
                                cpu_din <= (OTHERS => 'Z');
                            ELSE

                                -- passing offset and index to sram
                                sram_addr_sig(4 DOWNTO 0) <= offset;
                                sram_addr_sig(7 DOWNTO 5) <= index;
                                -- reading 
                                sram_wen <= "0";
                                -- just to be safe , setting dirty for corresponding cpu address to 0
                                dirty_bit(to_integer(unsigned(index))) <= '0';
                                -- just to be safe , setting dirty flag to 0
                                dirty_flag <= '0';
                                -- returning data from cache tag_register (sram)
                                -- to cpu
                                cpu_din <= sram_dout_sig;
                            END IF;
                        ELSE
                            hit_debug <= '0';
                        END IF;
                    END IF;
                END IF;
            END IF;
        END IF;

    END PROCESS;

END Behavioral;