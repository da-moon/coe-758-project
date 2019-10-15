LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;
ENTITY cpu_gen IS
   PORT (
      clk : IN STD_LOGIC;
      rst : IN STD_LOGIC;
      trig : IN STD_LOGIC;
      -- Interface to the Cache Controller.
      Address : OUT STD_LOGIC_VECTOR (15 DOWNTO 0);
      wr_rd : OUT STD_LOGIC;
      cs : OUT STD_LOGIC;
      DOut : OUT STD_LOGIC_VECTOR (7 DOWNTO 0)
   );
END cpu_gen;