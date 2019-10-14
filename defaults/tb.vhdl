use std.textio.all;

architecture testbench of tb is
begin
  process
    -- variable decleration
    variable L : line;
    variable byte : bit_vector(0 to 7);
    variable word : bit_vector(1 to 32);
    variable half_byte : bit_vector(1 to 4);
    variable overflow, div_by_zero, result : boolean;

  begin
    WAIT for 1 ns;
    write(L, string'("Start tests:"));
    writeline(output, L);
    wait;
  end process;

end testbench;
