LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.std_logic_unsigned.ALL;
USE ieee.numeric_std.ALL;
USE std.textio.ALL;
USE work.utils_pkg.ALL;
USE work.cache_pkg.ALL;

ENTITY direct_mapped_cache_controller_tb IS
END direct_mapped_cache_controller_tb;

ARCHITECTURE testbench OF direct_mapped_cache_controller_tb IS
BEGIN

  stim_proc : PROCESS
    VARIABLE L : line;
  BEGIN
    WAIT FOR 1 ns;
    write(L, STRING'("direct-mapped-cache-controller controller tests are emvedded into cache tests ... moving on !"));
    writeline(output, L);

    WAIT;
  END PROCESS;
END testbench;