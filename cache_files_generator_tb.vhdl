LIBRARY ieee;
USE std.textio.ALL;

ENTITY cache_files_generator_tb IS
END cache_files_generator_tb;
ARCHITECTURE testbench OF cache_files_generator_tb IS
BEGIN
  PROCESS
    VARIABLE L : line;
  BEGIN
    WAIT FOR 1 ns;
    write(L, STRING'("there is no need to test cache files generator  ... moving on !"));
    writeline(output, L);
    WAIT;
  END PROCESS;
END testbench;