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
PACKAGE BODY utils_pkg IS
  FUNCTION MAX (LEFT, RIGHT : INTEGER) RETURN INTEGER IS
  BEGIN
    IF LEFT > RIGHT THEN
      RETURN LEFT;
    ELSE
      RETURN RIGHT;
    END IF;
  END MAX;

  FUNCTION MIN (LEFT, RIGHT : INTEGER) RETURN INTEGER IS
  BEGIN
    IF LEFT < RIGHT THEN
      RETURN LEFT;
    ELSE
      RETURN RIGHT;
    END IF;
  END MIN;
  FUNCTION TO_STRING (a : std_logic_vector) RETURN STRING IS
    VARIABLE b : STRING (1 TO a'length) := (OTHERS => NUL);
    VARIABLE stri : INTEGER := 1;
  BEGIN
    FOR i IN a'RANGE LOOP
      b(stri) := std_logic'image(a((i)))(2);
      stri := stri + 1;
    END LOOP;
    RETURN b;
  END TO_STRING;
  FUNCTION TO_I(ARG : IN STD_LOGIC_VECTOR) RETURN NATURAL IS
  BEGIN
    RETURN TO_INTEGER(UNSIGNED(ARG));
  END TO_I;

  FUNCTION TO_SLV(ARG : IN UNSIGNED) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR(ARG);
  END TO_SLV;

  FUNCTION TO_SLV(ARG : IN SIGNED) RETURN STD_LOGIC_VECTOR IS
  BEGIN
    RETURN STD_LOGIC_VECTOR(ARG);
  END TO_SLV;
  -- converts a std_logic_vector into a hex string.
  FUNCTION TO_HEX_STRING(slv : std_logic_vector) RETURN STRING IS
    VARIABLE hexlen : INTEGER;
    VARIABLE longslv : std_logic_vector(67 DOWNTO 0) := (OTHERS => '0');
    VARIABLE hex : STRING(1 TO 16);
    VARIABLE fourbit : std_logic_vector(3 DOWNTO 0);
  BEGIN
    hexlen := (slv'left + 1)/4;
    IF (slv'left + 1) MOD 4 /= 0 THEN
      hexlen := hexlen + 1;
    END IF;
    longslv(slv'left DOWNTO 0) := slv;
    FOR i IN (hexlen - 1) DOWNTO 0 LOOP
      fourbit := longslv(((i * 4) + 3) DOWNTO (i * 4));
      CASE fourbit IS
        WHEN "0000" => hex(hexlen - I) := '0';
        WHEN "0001" => hex(hexlen - I) := '1';
        WHEN "0010" => hex(hexlen - I) := '2';
        WHEN "0011" => hex(hexlen - I) := '3';
        WHEN "0100" => hex(hexlen - I) := '4';
        WHEN "0101" => hex(hexlen - I) := '5';
        WHEN "0110" => hex(hexlen - I) := '6';
        WHEN "0111" => hex(hexlen - I) := '7';
        WHEN "1000" => hex(hexlen - I) := '8';
        WHEN "1001" => hex(hexlen - I) := '9';
        WHEN "1010" => hex(hexlen - I) := 'A';
        WHEN "1011" => hex(hexlen - I) := 'B';
        WHEN "1100" => hex(hexlen - I) := 'C';
        WHEN "1101" => hex(hexlen - I) := 'D';
        WHEN "1110" => hex(hexlen - I) := 'E';
        WHEN "1111" => hex(hexlen - I) := 'F';
        WHEN "ZZZZ" => hex(hexlen - I) := 'z';
        WHEN "UUUU" => hex(hexlen - I) := 'u';
        WHEN "XXXX" => hex(hexlen - I) := 'x';
        WHEN OTHERS => hex(hexlen - I) := '?';
      END CASE;
    END LOOP;
    RETURN hex(1 TO hexlen);
  END FUNCTION TO_HEX_STRING;

  FUNCTION TO_HEX_STRING(slv : unsigned) RETURN STRING IS
  BEGIN
    RETURN TO_HEX_STRING(std_logic_vector(slv));
  END FUNCTION TO_HEX_STRING;
  FUNCTION CEIL_LOG_2(ARG : IN INTEGER) RETURN INTEGER IS
  BEGIN
    RETURN INTEGER(CEIL(LOG2(REAL(ARG))));
  END CEIL_LOG_2;
  -- -----------------------------------------------------------------------------------------------------------
  FUNCTION MODIFY_VECTOR(
    index_in : IN INTEGER;
    vector : IN STD_LOGIC_VECTOR;
    value_in : IN STD_LOGIC
  ) RETURN STD_LOGIC_VECTOR IS
    VARIABLE v : STD_LOGIC_VECTOR(vector'RANGE) := (OTHERS => '0');
  BEGIN
    v := vector;
    v(index_in) := value_in;
    RETURN v;
  END MODIFY_VECTOR;
  -- -----------------------------------------------------------------------------------------------------------  
  FUNCTION GET_RANDOM(rand : IN REAL) RETURN INTEGER IS
    VARIABLE irand : INTEGER;
  BEGIN
    irand := INTEGER((rand * 100.0 - 0.5) + 50.0);
    RETURN irand;
  END;
END utils_pkg;