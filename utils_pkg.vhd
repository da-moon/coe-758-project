LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;
USE ieee.math_real.ceil;
USE ieee.math_real.log2;

PACKAGE utils_pkg IS
  TYPE EdgeType IS (RISING, FALLING);
  TYPE ModeType IS (WRITE_FIRST, READ_FIRST, NO_CHANGE);
  FUNCTION MAX (LEFT, RIGHT : INTEGER) RETURN INTEGER;
  FUNCTION MIN (LEFT, RIGHT : INTEGER) RETURN INTEGER;
  FUNCTION TO_STRING (a : std_logic_vector) RETURN STRING;
  FUNCTION TO_I (ARG : IN STD_LOGIC_VECTOR) RETURN NATURAL;
  FUNCTION TO_SLV(ARG : IN UNSIGNED) RETURN STD_LOGIC_VECTOR;
  FUNCTION TO_SLV(ARG : IN SIGNED) RETURN STD_LOGIC_VECTOR;
  FUNCTION TO_HEX_STRING(slv : std_logic_vector) RETURN STRING;
  FUNCTION TO_HEX_STRING(slv : unsigned) RETURN STRING;
  FUNCTION CEIL_LOG_2(ARG : IN INTEGER) RETURN INTEGER;
  -- -----------------------------------------------------------------------------------------------------------
  -- MODIFY_VECTOR :
  -- first modifies the given vector by copying the given vector and
  -- setting the value at the specified position with the given index.
  -- The new value at this position is given by the parameter.
  -- Finally, the function returns the modified vector.
  -- -----------------------------------------------------------------------------------------------------------
  FUNCTION MODIFY_VECTOR(
    index_in : IN INTEGER;
    vector : IN STD_LOGIC_VECTOR;
    value_in : IN STD_LOGIC
  ) RETURN STD_LOGIC_VECTOR;
  -- -----------------------------------------------------------------------------------------------------------
  -- GET_RANDOM -- returns a random integer between 50 and 150.
  -- -----------------------------------------------------------------------------------------------------------
  FUNCTION GET_RANDOM(rand : IN REAL) RETURN INTEGER;
END PACKAGE;