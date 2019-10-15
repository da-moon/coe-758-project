library ieee;
use std.textio.all;

entity cache_files_generator_tb is
end cache_files_generator_tb;
architecture testbench of cache_files_generator_tb is
    begin
        process
          variable L : line;
        begin
          WAIT for 1 ns;
          write(L, string'("there is no need to test cache files generator  ... moving on !"));
          writeline(output, L);
          wait;
        end process;
end testbench;
    