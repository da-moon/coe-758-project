LIBRARY ieee;
USE IEEE.STD_LOGIC_1164.ALL;
USE ieee.numeric_std.ALL;
USE work.cache_pkg.ALL;

ENTITY cache_controller IS
    PORT (
        clk : IN STD_LOGIC;
        addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sram_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sram_din : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sram_dout : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sdram_addr : OUT STD_LOGIC_VECTOR(15 DOWNTO 0);
        sdram_dina : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        sdram_douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        cache_addr : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
        wr_rd, mstrb, ready, cd : OUT STD_LOGIC);
END cache_controller;

architecture Behavioral of cache_controller is

SIGNAL memory : CACHE_MEMORY := ((OTHERS => (OTHERS => '0')));
    --CPU Signals
    SIGNAL cpu_dout, cpu_din : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL cpu_addr : STD_LOGIC_VECTOR (15 DOWNTO 0);
    SIGNAL cpu_wr, cpu_cs : STD_LOGIC;
    SIGNAL trig : STD_LOGIC;
    SIGNAL cpu_tag : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL index : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL offset : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL Tag_index : STD_LOGIC_VECTOR(10 DOWNTO 0);

    --bram(cache memory) Signals
    SIGNAL dirty_vector : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL valid_vector : STD_LOGIC_VECTOR(7 DOWNTO 0) := "00000000";
    SIGNAL sram_addr_sig, sram_din_sig, sram_dout_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sram_wen : STD_LOGIC_VECTOR(0 DOWNTO 0);
    SIGNAL hit_signal : STD_LOGIC := '0';

    --SDRAM Signals
    SIGNAL sdram_dina_sig, sdram_douta_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL sdram_addr_sig : STD_LOGIC_VECTOR(15 DOWNTO 0);
    SIGNAL sdram_mstrb, sdram_wr_rd : STD_LOGIC;
    SIGNAL counter : INTEGER := 0;
    SIGNAL sdoffset : INTEGER := 0;
    -- state_signal signals
    SIGNAL state_current : STATE;
    SIGNAL state_signal : STD_LOGIC_VECTOR(3 DOWNTO 0);
    --ICON & VIO  & ILA Signals 
    SIGNAL control0 : STD_LOGIC_VECTOR(35 DOWNTO 0);
	     SIGNAL control1 : STD_LOGIC_VECTOR(35 DOWNTO 0);

    SIGNAL ila_data : std_logic_vector(99 DOWNTO 0);
    SIGNAL trig0 : std_logic_vector(0 TO 0);
	 	     SIGNAL vio_out : STD_LOGIC_VECTOR(1 DOWNTO 0);

    --Components
    COMPONENT sdram_controller
        PORT (
            clk : IN STD_LOGIC;
            addr : IN STD_LOGIC_VECTOR (15 DOWNTO 0);
            wr_rd : IN STD_LOGIC;
            mstrb : IN STD_LOGIC;
            dina : IN STD_LOGIC_VECTOR (7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
    END COMPONENT;
    COMPONENT bram
        PORT (
            clka : IN STD_LOGIC;
            wea : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
            addra : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            dina : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
            douta : OUT STD_LOGIC_VECTOR(7 DOWNTO 0));
    END COMPONENT;
    COMPONENT CPU_gen
        PORT (
            clk : IN STD_LOGIC;
            rst : IN STD_LOGIC;
            trig : IN STD_LOGIC;
            Address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
            wr_rd : OUT STD_LOGIC;
            cs : OUT STD_LOGIC;
            Dout : OUT STD_LOGIC_VECTOR (7 DOWNTO 0));
    END COMPONENT;
    COMPONENT icon
       port (
    CONTROL0: inout std_logic_vector(35 downto 0);
    CONTROL1: inout std_logic_vector(35 downto 0));
    END COMPONENT;

    COMPONENT ila
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK : IN STD_LOGIC;
            DATA : IN STD_LOGIC_VECTOR(99 DOWNTO 0);
            TRIG0 : IN STD_LOGIC_VECTOR(0 TO 0));
    END COMPONENT;
	 component vio
  PORT (
    CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
    ASYNC_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0));

end component;

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
    cpu_gen_instl : cpu_gen
    PORT MAP(
        clk => clk,
        rst => '0',
        trig => trig,
        Address => cpu_addr,
        wr_rd => cpu_wr,
        cs => cpu_cs,
        DOut => cpu_dout
    );
    bram_instl : bram
    PORT MAP(
        clka => clk,
        wea => sram_wen,
        addra => sram_addr_sig,
        dina => sram_din_sig,
        douta => sram_dout_sig
    );
    icon_instl : icon
    PORT MAP(
        CONTROL0 => CONTROL0,
		  CONTROL1 =>control1
    );
    ila_instl : ila
    PORT MAP(
        CONTROL => CONTROL0,
        CLK => clk,
        DATA => ila_data,
        TRIG0 => TRIG0
    );
	  vio_instl : vio
  port map (
    CONTROL => control1,
    ASYNC_OUT =>  vio_out);


    PROCESS (clk, cpu_cs)
    BEGIN
        IF (clk'event AND clk='1' ) THEN
            --Setting the signal values
            IF (state_current = READY_STATE) THEN
                trig <= '0';
                cpu_tag <= GET_TAG(cpu_addr);
                index <= GET_INDEX(cpu_addr);
                offset <= GET_OFFSET(cpu_addr);
                sdram_addr_sig(15 DOWNTO 5) <= cpu_addr(15 DOWNTO 5);
                sram_addr_sig(7 DOWNTO 0) <= cpu_addr(7 DOWNTO 0);
                sram_wen <= "0";
                --Evaluating a HIT/MISS
                -- HIT
                IF (valid_vector(to_integer(unsigned(index))) = '1'
                    AND memory(to_integer(unsigned(index))) = cpu_tag) THEN
                    hit_signal <= '1';
                    state_current <= HIT;
                    state_signal <= "0000";
                    --MISS
                ELSE
                    hit_signal <= '0';
                    --dirty and valid are both 1 => write back to main memory (SDRAM)
                    -- before loading to cache memory (bram)
                    IF (dirty_vector(to_integer(unsigned(index))) = '1'
                        AND valid_vector(to_integer(unsigned(index))) = '1') THEN
                        state_current <= WRITE_DATA;
                        state_signal <= "0010";
                    ELSE
                        state_current <= READ_DATA;
                        state_signal <= "0001";
                    END IF;
                END IF;

            ELSIF (state_current = HIT) THEN
                -- writing from cpu output
                -- to cache memory (bram)   
                IF (cpu_wr = '1') THEN
                    dirty_vector(to_integer(unsigned(index))) <= '1';
                    valid_vector(to_integer(unsigned(index))) <= '1';
                    sram_wen <= "1";
                    sram_din_sig <= cpu_dout;
                    cpu_din <= "00000000";
                    -- returning data from cache memory (sram)
                    -- to cpu
                ELSE
                    cpu_din <= sram_dout_sig;
                END IF;
                --making sure the state_signal is switched back to idle 
                -- after request completion
                state_current <= IDLE;
                state_signal <= "0011";

            ELSIF (state_current = READ_DATA) THEN
                --reading data from main memory
                IF (counter = 64) THEN
                    valid_vector(to_integer(unsigned(index))) <= '1';
                    memory(to_integer(unsigned(index))) <= cpu_tag;
                    counter <= 0;
                    state_current <= HIT;
                    sdoffset <= 0;
                    state_signal <= "0000";
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

            ELSIF (state_current = WRITE_DATA) THEN
                IF (counter = 64) THEN
                    dirty_vector(to_integer(unsigned(index))) <= '0';
                    state_current <= READ_DATA;
                    counter <= 0;
                    sdoffset <= 0;
                    state_signal <= "0001";
                ELSE
                    IF (counter MOD 2 = 1) THEN
                        sdram_mstrb <= '0';
                    ELSE
                        -- main memory
                        sdram_addr_sig(4 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(sdoffset, offset'length));
                        sram_addr_sig(4 DOWNTO 0) <= STD_LOGIC_VECTOR(to_unsigned(sdoffset, offset'length));
                        sram_addr_sig(7 DOWNTO 5) <= index;
                        sdram_wr_rd <= '1';
                        sram_wen <= "0";
                        sdram_dina_sig <= sram_dout_sig;
                        sdram_mstrb <= '1';
                        sdoffset <= sdoffset + 1;
                    END IF;
                    counter <= counter + 1;
                END IF;

            ELSIF (state_current = IDLE) THEN
                trig <= '1';
                IF (cpu_cs = '1') THEN
                    state_current <= READY_STATE;
                    state_signal <= "0100";
                END IF;
            END IF;
        END IF;
    END PROCESS;
	 -- trig<=vio_out(0);
	TRIG0(0)<=vio_out(0);
    mstrb <= sdram_mstrb;
    addr <= cpu_addr;
    wr_rd <= cpu_wr;
    douta <= cpu_din;
    ready <= trig;
    cd <= cpu_cs;
    sram_addr_sig <= sram_addr_sig;
    sram_din_sig <= sram_din_sig;
    sram_dout_sig <= sram_dout_sig;
    sdram_addr_sig <= sdram_addr_sig;
    sdram_dina_sig <= sdram_dina_sig;
    sdram_douta_sig <= sdram_douta_sig;
    cache_addr <= GET_TAG(cpu_addr);

    ila_data(15 DOWNTO 0) <= cpu_addr;
    ila_data(16) <= cpu_wr;
    ila_data(17) <= trig;
    ila_data(18) <= sdram_mstrb;
    ila_data(26 DOWNTO 19) <= cpu_din;
    ila_data(30 DOWNTO 27) <= state_signal;
    ila_data(31) <= cpu_cs;
    ila_data(32) <= valid_vector(to_integer(unsigned(index)));
    ila_data(33) <= dirty_vector(to_integer(unsigned(index)));
    ila_data(34) <= hit_signal;
    ila_data(42 DOWNTO 35) <= sram_addr_sig;
    ila_data(50 DOWNTO 43) <= sram_din_sig;
    ila_data(58 DOWNTO 51) <= sram_dout_sig;
    ila_data(74 DOWNTO 59) <= sdram_addr_sig;
    ila_data(82 DOWNTO 75) <= sdram_dina_sig;
    ila_data(90 DOWNTO 83) <= sdram_douta_sig;
    ila_data(98 DOWNTO 91) <= cpu_addr(15 DOWNTO 8);


end Behavioral;

