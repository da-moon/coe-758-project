library IEEE;
use IEEE.STD_LOGIC_1164.all;

package utils_pkg is
  function MAX (LEFT, RIGHT: INTEGER) return INTEGER;
  function MIN (LEFT, RIGHT: INTEGER) return INTEGER;
  -- used to convert logic vector to string for representation
  function TO_STRING ( a: std_logic_vector) return string;
  -- used to convert std_logic to string
  -- function IMAGE(L: std_logic) return String;
END PACKAGE;