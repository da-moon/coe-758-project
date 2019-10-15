library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
USE ieee.numeric_std.ALL;
use std.textio.all;
use work.utils_pkg.ALL;
use work.cache_pkg.ALL; 

entity direct_mapped_cache_controller_tb is
end direct_mapped_cache_controller_tb;

architecture testbench of direct_mapped_cache_controller_tb is
begin
 
stim_proc: process
  variable L : line;
begin
  WAIT for 1 ns;
  write(L, string'("direct-mapped-cache-controller controller tests are emvedded into cache tests ... moving on !"));
  writeline(output, L);

  wait;
end process;
end testbench;
