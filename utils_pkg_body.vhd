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
    -- function IMAGE(L: std_logic) return String is
    --   variable bit_image: String(1 to 1) ;
    --   begin
    --   bit_image(1) :=std_logic'image(L);
    --   return bit_image;
    --   end function IMAGE;
      
      
end utils_pkg;
