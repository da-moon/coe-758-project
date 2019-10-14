package body utils_pkg is
    function MAX (LEFT, RIGHT: INTEGER) return INTEGER is
    begin
      if LEFT > RIGHT then return LEFT;
      else return RIGHT;
      end if;
    end MAX;

    function MIN (LEFT, RIGHT: INTEGER) return INTEGER is
    begin
      if LEFT < RIGHT then return LEFT;
      else return RIGHT;
      end if;
    end MIN;
    function TO_STRING ( a: std_logic_vector) return string is
      variable b : string (1 to a'length) := (others => NUL);
      variable stri : integer := 1; 
      begin
          for i in a'range loop
              b(stri) := std_logic'image(a((i)))(2);
          stri := stri+1;
          end loop;
      return b;
    end TO_STRING; 

    function TO_I(ARG: in STD_LOGIC_VECTOR) return NATURAL IS     
    begin     
      return TO_INTEGER(UNSIGNED(ARG));    
    end TO_I; 
    
    function TO_SLV(ARG: in UNSIGNED) return STD_LOGIC_VECTOR IS     
    begin     
      return STD_LOGIC_VECTOR(ARG);    
    end TO_SLV;
    
    function TO_SLV(ARG: in SIGNED) return STD_LOGIC_VECTOR IS     
    begin     
      return STD_LOGIC_VECTOR(ARG);    
    end TO_SLV;   
      
      
end utils_pkg;
