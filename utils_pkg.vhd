library IEEE;
use IEEE.STD_LOGIC_1164.all;
use IEEE.NUMERIC_STD.all;
use ieee.math_real.ceil;
use ieee.math_real.log2;

package utils_pkg is
  type EdgeType      is ( RISING, FALLING );
  type ModeType is (WRITE_FIRST, READ_FIRST, NO_CHANGE);
  function MAX (LEFT, RIGHT: INTEGER) return INTEGER;
  function MIN (LEFT, RIGHT: INTEGER) return INTEGER;
  function TO_STRING ( a: std_logic_vector) return string;
  function TO_I  (ARG: in STD_LOGIC_VECTOR) return NATURAL;
  function TO_SLV(ARG: in UNSIGNED)         return STD_LOGIC_VECTOR;
  function TO_SLV(ARG: in SIGNED)           return STD_LOGIC_VECTOR;
  function TO_HEX_STRING(slv: std_logic_vector) return string;
  function TO_HEX_STRING(slv: unsigned) return string;
  function CEIL_LOG_2(ARG : in INTEGER) return INTEGER;
  -- -----------------------------------------------------------------------------------------------------------
  -- RETURN_MODIFIED_VECTOR :
  --  first modifies the given vector by copying the given vector and
  -- setting the value at the specified position with the given index.
  -- The new value at this position is given by the parameter.
  -- Finally, the function returns the modified vector.
  -- -----------------------------------------------------------------------------------------------------------
  function RETURN_MODIFIED_VECTOR( 
      index_in : in INTEGER;
      vector : in STD_LOGIC_VECTOR;
      value_in : in STD_LOGIC
  ) return STD_LOGIC_VECTOR;
END PACKAGE;