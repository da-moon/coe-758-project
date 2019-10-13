ARCHITECTURE behaviour OF clock_gen
	IS
	-- CONSTANT clock_period : TIME := 10 ns;
BEGIN
	-- Clock process definition
	clk_process : PROCESS
	BEGIN
		clk <= '0';
		WAIT FOR clock_period/2;
		clk <= '1';
		WAIT FOR clock_period/2;
	END PROCESS;
END behaviour;