library ieee;
use ieee.std_logic_1164.all;
use std.textio.all;

entity clock_gen_tb is
end clock_gen_tb;

architecture bench of clock_gen_tb is

   constant C_FILE_NAME :string  := "DataOut.dat";
   constant C_DATA1_W   :integer := 16;
   constant C_DATA3_W   :integer :=  4;
   constant C_CLK       :time    := 10 ns;
   signal clk           :std_logic := '0';
   signal rst           :std_logic := '0';
   signal eof           :std_logic := '0';

   file fptr: text;
begin
ClockGenerator: process
begin
   clk <= '0' after C_CLK, '1' after 2*C_CLK;
   wait for 2*C_CLK;
end process;

rst <= '1', '0' after 100 ns;
WriteData_proc: process
   variable fstatus       :file_open_status;
   
   variable file_line     :line;
   variable var_data2     :integer;

begin

   var_data2 := 0;
   eof       <= '0';

   wait until rst = '0';

   file_open(fstatus, fptr, C_FILE_NAME, write_mode);

   while (var_data2 < 4) loop
      wait until clk = '1';
      var_data2   := var_data2 + 1;
      write(file_line, var_data2, right, 2);
      writeline(fptr, file_line);
   end loop;
   wait until rising_edge(clk);
   eof       <= '1';
   file_close(fptr);
   wait;
end process;

end bench;
