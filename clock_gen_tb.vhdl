library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity clock_gen_tb is
end clock_gen_tb;

architecture bench of clock_gen_tb is
   CONSTANT TEST_TIME : TIME := 2000 ns;
   signal clk           :std_logic := '0';
   signal rst           :std_logic := '0';

   COMPONENT clock_gen
      PORT (
			clk : OUT std_logic
		);
   END COMPONENT;
   for cg : clock_gen
   use entity work.clock_gen(behaviour)
     generic map (clock_period => 10 ns);
begin
   cg : clock_gen
   port map (clk);

stim_proc: process
   variable L : line;
   variable byte : bit_vector(0 to 7);
   variable word : bit_vector(1 to 32);
   variable half_byte : bit_vector(1 to 4);
-- using counter to test clock ...
   variable counter     :integer;
begin
   WAIT for 1 ns;
   write(L, string'("Clock Gen Tests ... :"));
   writeline(output, L);
   rst <= '1', '0' after 100 ns;
   counter := 0;
   wait until rst = '0';
   while (counter * 10 ns < TEST_TIME) loop
      wait until rising_edge(clk);
      counter   := counter + 1;
      -- write(L, counter, right, 2);
      -- writeline(output, L);
   end loop;
   write(L, string'("Final Count Value:"));
   writeline(output, L);
   write(L, counter, right, 2);
   writeline(output, L);
   wait;
end process;
end bench;
