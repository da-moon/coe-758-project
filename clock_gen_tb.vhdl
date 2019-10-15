LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE std.textio.ALL;

ENTITY clock_gen_tb IS
END clock_gen_tb;

ARCHITECTURE testbench OF clock_gen_tb IS
   CONSTANT TEST_TIME : TIME := 2000 ns;
   SIGNAL clk : std_logic := '0';
   SIGNAL rst : std_logic := '0';

   COMPONENT clock_gen
      PORT (
         clk : OUT std_logic
      );
   END COMPONENT;
   FOR cg : clock_gen
      USE ENTITY work.clock_gen(behaviour)
      GENERIC MAP(clock_period => 10 ns);
   BEGIN
      cg : clock_gen
      PORT MAP(clk);

      stim_proc : PROCESS
         VARIABLE L : line;
         VARIABLE byte : bit_vector(0 TO 7);
         VARIABLE word : bit_vector(1 TO 32);
         VARIABLE half_byte : bit_vector(1 TO 4);
         -- using counter to test clock ...
         VARIABLE counter : INTEGER;
      BEGIN
         WAIT FOR 1 ns;
         -- write(L, string'("Clock Gen Tests ... :"));
         -- writeline(output, L);
         rst <= '1', '0' AFTER 100 ns;
         counter := 0;
         WAIT UNTIL rst = '0';
         WHILE (counter * 10 ns < TEST_TIME) LOOP
            WAIT UNTIL rising_edge(clk);
            counter := counter + 1;
            -- write(L, counter, right, 2);
            -- writeline(output, L);
         END LOOP;
         -- write(L, string'("Final Count Value:"));
         -- writeline(output, L);
         -- write(L, counter, right, 2);
         -- writeline(output, L);
         WAIT;
      END PROCESS;
   END testbench;