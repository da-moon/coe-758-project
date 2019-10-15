ARCHITECTURE behaviour OF cpu_gen IS
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
		IF (ieee.std_logic_unsigned."=" (st1, "000")) THEN
			-- if(st1 = "000")then
			IF (trig_r = '1') THEN
				st1N <= "001";
			ELSE
				st1N <= "000";
			END IF;
		ELSIF (ieee.std_logic_unsigned."=" (st1, "001")) THEN
			-- elsif(st1 = "001")then
			st1N <= "010";
		ELSIF (ieee.std_logic_unsigned."=" (st1, "010")) THEN
			-- elsif(st1 = "010")then
			st1N <= "011";
		ELSIF (ieee.std_logic_unsigned."=" (st1, "011")) THEN
			-- elsif(st1 = "011")then
			st1N <= "100";
		ELSIF (ieee.std_logic_unsigned."=" (st1, "100")) THEN
			-- elsif(st1 = "100")then
			st1N <= "101";
		ELSIF (ieee.std_logic_unsigned."=" (st1, "101")) THEN
			-- elsif(st1 = "101")then
			st1N <= "000";
		ELSE
			st1N <= "000";
		END IF;
	END PROCESS;

	-- Output generation.
	PROCESS (st1)
	BEGIN

		IF (ieee.std_logic_unsigned."=" (st1, "000")) THEN
			-- if(st1 = "000")then
			updPat <= '0';
			cs <= '0';
		ELSIF (ieee.std_logic_unsigned."=" (st1, "001")) THEN
			-- elsif(st1 = "001")then
			updPat <= '1';
			cs <= '0';
		ELSIF (ieee.std_logic_unsigned."=" (st1, "010")) THEN
			-- elsif(st1 = "010")then
			updPat <= '0';
			cs <= '1';
		ELSIF (ieee.std_logic_unsigned."=" (st1, "011")) THEN
			-- elsif(st1 = "011")then
			updPat <= '0';
			cs <= '1';
		ELSIF (ieee.std_logic_unsigned."=" (st1, "100")) THEN
			-- elsif(st1 = "100")then
			updPat <= '0';
			cs <= '1';
		ELSIF (ieee.std_logic_unsigned."=" (st1, "101")) THEN
			-- elsif(st1 = "101")then
			updPat <= '0';
			cs <= '1';
		ELSE
		END IF;
	END PROCESS;
	--------------------------------------------------------------------------
	-- Pattern generator and control circuit.

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
		IF (ieee.std_logic_unsigned."=" (patCtrl, "000")) THEN
			-- if(patCtrl = "000")then
			patOut <= "0001000100000000101010101";
		ELSIF (ieee.std_logic_unsigned."=" (patCtrl, "001")) THEN
			-- elsif(PatCtrl = "001")then
			patOut <= "0001000100000010101110111";
		ELSIF (ieee.std_logic_unsigned."=" (patCtrl, "010")) THEN
			-- elsif(PatCtrl = "010")then
			patOut <= "0001000100000000000000000";
		ELSIF (ieee.std_logic_unsigned."=" (patCtrl, "011")) THEN
			-- elsif(PatCtrl = "011")then
			patOut <= "0001000100000010000000000";
		ELSIF (ieee.std_logic_unsigned."=" (patCtrl, "100")) THEN
			-- elsif(PatCtrl = "100")then
			patOut <= "0011001101000110000000000";
		ELSIF (ieee.std_logic_unsigned."=" (patCtrl, "101")) THEN
			-- elsif(PatCtrl = "101")then
			patOut <= "0100010001000100000000000";
		ELSIF (ieee.std_logic_unsigned."=" (patCtrl, "110")) THEN
			-- elsif(PatCtrl = "110")then
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
END behaviour;