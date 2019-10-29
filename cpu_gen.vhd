LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY CPU_gen IS
    PORT (
        clk : IN STD_LOGIC;
        rst : IN STD_LOGIC;
        trig : IN STD_LOGIC;
        -- Interface to the Cache Controller.
        Address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
        wr_rd : OUT STD_LOGIC;
        cs : OUT STD_LOGIC;
        DOut : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
    );
END CPU_gen;
ARCHITECTURE Behavioral OF CPU_gen IS
    -- Pattern storage and control.
    SIGNAL patOut : std_logic_vector(24 DOWNTO 0);
    SIGNAL patCtrl : std_logic_vector(2 DOWNTO 0) := "111";
    SIGNAL updPat : std_logic;

    -- Main control.
    SIGNAL st1 : std_logic_vector(2 DOWNTO 0) := "000";
    SIGNAL st1N : std_logic_vector(2 DOWNTO 0);

    -- Rising edge detection.
    SIGNAL rReg1, rReg2 : std_logic;
    SIGNAL trig_r : std_logic;

BEGIN

    --------------------------------------------------------------------------
    -- Main control FSM.
    --------------------------------------------------------------------------

    -- State storage.
    PROCESS (clk, rst, st1N)
    BEGIN
        IF (rst = '1') THEN
            st1 <= "000";
        ELSE
            IF (clk'event AND clk = '1') THEN
                st1 <= st1N;
            END IF;
        END IF;
    END PROCESS;

    -- Next state generation.
    PROCESS (st1, trig_r)
    BEGIN
        IF (st1 = "000") THEN
            IF (trig_r = '1') THEN
                st1N <= "001";
            ELSE
                st1N <= "000";
            END IF;
        ELSIF (st1 = "001") THEN
            st1N <= "010";
        ELSIF (st1 = "010") THEN
            st1N <= "011";
        ELSIF (st1 = "011") THEN
            st1N <= "100";
        ELSIF (st1 = "100") THEN
            st1N <= "101";
        ELSIF (st1 = "101") THEN
            st1N <= "000";
        ELSE
            st1N <= "000";
        END IF;
    END PROCESS;

    -- Output generation.
    PROCESS (st1)
    BEGIN
        IF (st1 = "000") THEN
            updPat <= '0';
            cs <= '0';
        ELSIF (st1 = "001") THEN
            updPat <= '1';
            cs <= '0';
        ELSIF (st1 = "010") THEN
            updPat <= '0';
            cs <= '1';
        ELSIF (st1 = "011") THEN
            updPat <= '0';
            cs <= '1';
        ELSIF (st1 = "100") THEN
            updPat <= '0';
            cs <= '1';
        ELSIF (st1 = "101") THEN
            updPat <= '0';
            cs <= '1';
        ELSE
        END IF;
    END PROCESS;

    --------------------------------------------------------------------------
    -- Pattern generator and control circuit.
    --------------------------------------------------------------------------

    -- Generator control circuit.
    PROCESS (clk, rst, updPat, patCtrl)
    BEGIN
        IF (rst = '1') THEN
            patCtrl <= "111";
        ELSE
            IF (clk'event AND clk = '1') THEN
                IF (updPat = '1') THEN
                    patCtrl <= patCtrl + "001";
                ELSE
                    patCtrl <= patCtrl;
                END IF;
            END IF;
        END IF;
    END PROCESS;

    -- Pattern storage.
    PROCESS (patCtrl)
    BEGIN
        IF (patCtrl = "000") THEN
            patOut <= "0001000100000000101010101"; -- 16 bit addr, 8 bit data, 1 bit wr
        ELSIF (PatCtrl = "001") THEN
            patOut <= "0001000100000010101110111";
        ELSIF (PatCtrl = "010") THEN
            patOut <= "0001000100000000000000000";
        ELSIF (PatCtrl = "011") THEN
            patOut <= "0001000100000010000000000";
        ELSIF (PatCtrl = "100") THEN
            patOut <= "0011001101000110000000000";
        ELSIF (PatCtrl = "101") THEN
            patOut <= "0100010001000100000000000";
        ELSIF (PatCtrl = "110") THEN
            patOut <= "0101010100000100110011001";
        ELSE
            patOut <= "0110011000000110000000000";
        END IF;
    END PROCESS;

    --------------------------------------------------------------------------
    -- Rising edge detector.
    --------------------------------------------------------------------------

    -- Register 1
    PROCESS (clk, trig)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            rReg1 <= trig;
        END IF;
    END PROCESS;

    -- Register 2
    PROCESS (clk, rReg1)
    BEGIN
        IF (clk'event AND clk = '1') THEN
            rReg2 <= rReg1;
        END IF;
    END PROCESS;

    trig_r <= rReg1 AND (NOT rReg2);

    --------------------------------------------------------------------------
    -- Output connections.
    --------------------------------------------------------------------------

    -- Output mapping:
    -- Address [24 .. 9]
    -- Data [8 .. 1]
    -- Wr/Rd [0]

    Address(15 DOWNTO 0) <= patOut(24 DOWNTO 9);
    DOut(7 DOWNTO 0) <= patOut(8 DOWNTO 1);
    wr_rd <= patOut(0);
END Behavioral;