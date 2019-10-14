library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;

package utils_pkg is
  function MAX (LEFT, RIGHT: INTEGER) return INTEGER;
  function MIN (LEFT, RIGHT: INTEGER) return INTEGER;
  function TO_STRING ( a: std_logic_vector) return string;
  function TO_I  (ARG: in STD_LOGIC_VECTOR) return NATURAL;
  function TO_SLV(ARG: in UNSIGNED)         return STD_LOGIC_VECTOR;
  function TO_SLV(ARG: in SIGNED)           return STD_LOGIC_VECTOR;
  function TO_HEX_STRING(slv: std_logic_vector) return string;
  function TO_HEX_STRING(slv: unsigned) return string;
    
END PACKAGE;