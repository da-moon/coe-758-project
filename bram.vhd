library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.ALL;
use STD.TEXTIO.ALL;
use IEEE.STD_LOGIC_TEXTIO.ALL;
use work.cache_pkg.all;
use work.utils_pkg.all;
entity bram is
    generic ( 
      ADDR     : integer  := 10;
      DATA     : integer  := 32;
      EDGE     : EdgeType := RISING;
      MODE     : MODEType := NO_CHANGE;
      RamFileName     : string 
  );
  port (
        clk, we: in  STD_LOGIC;
         adr    : in  STD_LOGIC_VECTOR(ADDR-1 downto 0);
         din    : in  STD_LOGIC_VECTOR(DATA-1 downto 0);
         dout   : out STD_LOGIC_VECTOR(DATA-1 downto 0)
       );
end;

