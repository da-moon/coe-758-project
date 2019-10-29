LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
ENTITY cache_controller_top_level_test IS
    PORT (clk : IN STD_LOGIC);
END cache_controller_top_level_test;
ARCHITECTURE Behavioral OF cache_controller_top_level_test IS
    -- signals ...
    SIGNAL trig : STD_LOGIC;
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
    SIGNAL tag_sig : STD_LOGIC_VECTOR(7 DOWNTO 0);
    SIGNAL index_sig : STD_LOGIC_VECTOR(2 DOWNTO 0);
    SIGNAL offset_sig : STD_LOGIC_VECTOR(4 DOWNTO 0);
    SIGNAL state_sig : STD_LOGIC_VECTOR(3 DOWNTO 0);
    --ICON & VIO & ILA Signals
    SIGNAL control0_sig : STD_LOGIC_VECTOR(35 DOWNTO 0);
    SIGNAL control1_sig : STD_LOGIC_VECTOR(35 DOWNTO 0);
    SIGNAL ila_data_sig : std_logic_vector(104 DOWNTO 0);
    SIGNAL trig0_sig : std_logic_vector(0 TO 0);
    SIGNAL async_out_sig : STD_LOGIC_VECTOR(1 DOWNTO 0);
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
            tag_debug : OUT STD_LOGIC_VECTOR(7 DOWNTO 0);
            index_debug : OUT STD_LOGIC_VECTOR(2 DOWNTO 0);
            offset_debug : OUT STD_LOGIC_VECTOR(4 DOWNTO 0);
            state_debug : OUT STD_LOGIC_VECTOR(3 DOWNTO 0);
            hit_debug : OUT STD_LOGIC
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
    COMPONENT icon
        PORT (
            CONTROL0 : INOUT std_logic_vector(35 DOWNTO 0);
            CONTROL1 : INOUT std_logic_vector(35 DOWNTO 0)
        );
    END COMPONENT;
    COMPONENT ila
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            CLK : IN STD_LOGIC;
            DATA : IN STD_LOGIC_VECTOR(104 DOWNTO 0);
            TRIG0 : IN STD_LOGIC_VECTOR(0 TO 0)
        );
    END COMPONENT;
    COMPONENT vio
        PORT (
            CONTROL : INOUT STD_LOGIC_VECTOR(35 DOWNTO 0);
            ASYNC_OUT : OUT STD_LOGIC_VECTOR(1 DOWNTO 0)
        );
    END COMPONENT;
BEGIN
    cache_controller_instl : cache_controller
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
        hit_debug => hit_sig,
        state_debug => state_sig
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
    icon_instl : icon
    PORT MAP(
        CONTROL0 => control0_sig,
        CONTROL1 => control1_sig
    );
    ila_instl : ila
    PORT MAP(
        CONTROL => control0_sig,
        CLK => clk,
        DATA => ila_data_sig,
        TRIG0 => trig0_sig
    );
    vio_instl : vio
    PORT MAP(
        CONTROL => control1_sig,
        ASYNC_OUT => async_out_sig
    );
    --	 trig <= async_out_sig(0);
    --  trig0_sig(0) <= async_out_sig(0);
    trig <= '1';
    trig0_sig(0) <= '1';
    ila_data_sig(0) <= wr_rd_sig;
    ila_data_sig(1) <= ready_sig;
    ila_data_sig(2) <= mstrb_sig;
    ila_data_sig(3) <= hit_sig;
    ila_data_sig(4) <= cpu_cs_sig;
    ila_data_sig(20 DOWNTO 5) <= addr_sig;
    ila_data_sig(36 DOWNTO 21) <= sdram_addr_sig;
    ila_data_sig(44 DOWNTO 37) <= sram_addr_sig;
    ila_data_sig(52 DOWNTO 45) <= sram_din_sig;
    ila_data_sig(60 DOWNTO 53) <= sram_dout_sig;
    ila_data_sig(68 DOWNTO 61) <= sdram_dina_sig;
    ila_data_sig(76 DOWNTO 69) <= sdram_douta_sig;
    ila_data_sig(84 DOWNTO 77) <= douta_sig;
    ila_data_sig(92 DOWNTO 85) <= tag_sig;
    ila_data_sig(95 DOWNTO 93) <= index_sig;
    ila_data_sig(100 DOWNTO 96) <= offset_sig;
    ila_data_sig(104 DOWNTO 101) <= state_sig;
END Behavioral;