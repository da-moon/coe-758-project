LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.cache_pkg.ALL;
ENTITY cache_controller IS
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
        tag_debug : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        index_debug : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
        offset_debug : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
        state_debug : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
        hit_debug : OUT STD_LOGIC
    );
END cache_controller;
ARCHITECTURE Behavioral OF cache_controller IS
    SIGNAL memory : CACHE_MEMORY := ((OTHERS => (OTHERS => '0')));
    SIGNAL tag : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL index : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL offset : STD_LOGIC_VECTOR(4 DOWNTO 0);
    --bram(cache memory) Signals
    SIGNAL dirty_vector : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL valid_vector : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL sram_addr_sig, sram_din_sig, sram_dout_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sram_wen : STD_LOGIC_VECTOR(0 DOWNTO 0);
    --SDRAM Signals
    SIGNAL sdram_dina_sig, sdram_douta_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sdram_addr_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL sdram_mstrb, sdram_wr_rd : STD_LOGIC;
    SIGNAL counter : INTEGER := 0;
    SIGNAL sdoffset : INTEGER := 0;
    -- state_signal signals
    SIGNAL state_current : STATE;
    --Components
    COMPONENT sdram_controller
        PORT (
            clk : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            wr_rd : IN STD_LOGIC;
            mstrb : IN STD_LOGIC;
            dina : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT bram
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
        wr_rd => sdram_wr_rd,
        mstrb => sdram_mstrb,
        dina => sdram_dina_sig,
        douta => sdram_douta_sig
    );
    bram_instl : bram
    PORT MAP(
        clka => clk,
        wea => sram_wen,
        addra => sram_addr_sig,
        dina => sram_din_sig,
        douta => sram_dout_sig
    );
    PROCESS (clk, cpu_cs)
    BEGIN
        IF (clk'EVENT AND clk = '1') THEN
            --Setting the signal values
            IF (state_current = READY_STATE) THEN
                ready <= '0';
                tag <= GET_TAG(addr);
                tag_debug <= tag;
                index <= GET_INDEX(addr);
                index_debug <= index;
                offset <= GET_OFFSET(addr);
                offset_debug <= offset;
                sdram_addr_sig(15 DOWNTO 5) <= addr(15 DOWNTO 5);
                sram_addr_sig(7 DOWNTO 0) <= addr(7 DOWNTO 0);
                sram_wen <= "0";
                --Evaluating a HIT/MISS
                -- HIT
                IF (valid_vector(to_integer(unsigned(index))) = '1' AND memory(to_integer(unsigned(index))) = tag) THEN
                    hit_debug <= '1';
                    IF (wr_rd = '1') THEN
                        -- writing incoming data
                        -- to cache memory (bram) because it was in hit state
                        dirty_vector(to_integer(unsigned(index))) <= '1';
                        valid_vector(to_integer(unsigned(index))) <= '1';
                        sram_wen <= "1";
                        sram_din_sig <= cpu_dout;
                        douta <= (OTHERS => 'Z');

                    ELSE
                        -- returning data from cache memory (sram)
                        -- to cpu
                        douta <= sram_dout_sig;
                    END IF;
                    -- making sure the state_signal is switched back to idle
                    -- after request completion
                    state_current <= IDLE_STATE;
                    state_debug <= "0011";
                ELSE
                    --MISS
                    hit_debug <= '0';
                    -- dirty =1 && valid == 1 && hit == 0
                    -- write back to main memory (SDRAM)
                    -- before loading to cache memory (bram)
                    --
                    IF (dirty_vector(to_integer(unsigned(index))) = '1' AND valid_vector(to_integer(unsigned(index))) = '1') THEN
                        state_current <= WRITE_DATA_STATE;
                        state_debug <= "0010";
                    ELSE
                        state_current <= READ_DATA_STATE;
                        state_debug <= "0001";
                    END IF;
                END IF;

            ELSIF (state_current = READ_DATA_STATE) THEN
                --reading data from main memory
                IF (counter = 64) THEN
                    valid_vector(to_integer(unsigned(index))) <= '1';
                    memory(to_integer(unsigned(index))) <= tag;
                    counter <= 0;
                    state_current <= HIT_STATE;
                    sdoffset <= 0;
                    state_debug <= "0000";
                ELSE
                    IF (counter MOD 2 = 1) THEN
                        sdram_mstrb <= '0';
                    ELSE
                        -- main memory
                        sdram_addr_sig(4 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(sdoffset, offset'length));
                        -- cache memory
                        sram_addr_sig(4 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(sdoffset, offset'length));
                        sram_addr_sig(7 DOWNTO 5) <= index;
                        sdram_wr_rd <= '0';
                        sdram_mstrb <= '1';
                        sram_din_sig <= sdram_douta_sig;
                        sram_wen <= "1";
                        sdoffset <= sdoffset + 1;
                    END IF;
                    counter <= counter + 1;
                END IF;
            ELSIF (state_current = WRITE_DATA_STATE) THEN
                IF (counter = 64) THEN
                    dirty_vector(to_integer(unsigned(index))) <= '0';
                    counter <= 0;
                    sdoffset <= 0;
                    state_debug <= "0001";
                    state_current <= READ_DATA_STATE;

                ELSE
                    IF (counter MOD 2 = 1) THEN
                        sdram_mstrb <= '0';
                    ELSE
                        sdram_addr_sig(4 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(sdoffset, offset'length));
                        sram_addr_sig(4 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(sdoffset, offset'length));
                        sram_addr_sig(7 DOWNTO 5) <= index;
                        sdram_wr_rd <= '1';
                        sram_wen <= "0";
                        sdram_mstrb <= '1';
                        sdram_dina_sig <= sram_dout_sig;
                        sdoffset <= sdoffset + 1;
                    END IF;
                    counter <= counter + 1;
                END IF;
            ELSIF (state_current = IDLE_STATE) THEN
                ready <= '1';
                IF (cpu_cs = '1') THEN
                    state_current <= READY_STATE;
                    state_debug <= "0100";
                END IF;
            END IF;
        END IF;
    END PROCESS;
    mstrb <= sdram_mstrb;
    sram_addr <= sram_addr_sig;
    sram_din <= sram_din_sig;
    sram_dout <= sram_dout_sig;
    sdram_addr <= sdram_addr_sig;
    sdram_dina <= sdram_dina_sig;
    sdram_douta <= sdram_douta_sig;
END Behavioral;