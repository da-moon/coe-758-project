LIBRARY ieee;
USE std.textio.ALL;

ENTITY sdram_controller_tb IS
END sdram_controller_tb;
ARCHITECTURE testbench OF sdram_controller_tb IS
BEGIN
  PROCESS
    VARIABLE L : line;
  BEGIN
    WAIT FOR 1 ns;
    write(L, STRING'("there is no need to test sdram controller  ... moving on !"));
    writeline(output, L);
    WAIT;
  END PROCESS;
END testbench;