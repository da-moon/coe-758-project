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
       -- converts a std_logic_vector into a hex string.
   function TO_HEX_STRING(slv: std_logic_vector) return string is
    variable hexlen: integer;
    variable longslv : std_logic_vector(67 downto 0):=(others => '0');
    variable hex : string(1 to 16);
    variable fourbit : std_logic_vector(3 downto 0);
 begin
    hexlen:=(slv'left+1)/4;
    if (slv'left+1) mod 4/=0 then
       hexlen := hexlen + 1;
    end if;
    longslv(slv'left downto 0) := slv;
    for i in (hexlen-1) downto 0 loop
        fourbit:=longslv(((i*4)+3) downto (i*4));
        case fourbit is
             when "0000" => hex(hexlen-I):='0';
             when "0001" => hex(hexlen-I):='1';
             when "0010" => hex(hexlen-I):='2';
             when "0011" => hex(hexlen-I):='3';
             when "0100" => hex(hexlen-I):='4';
             when "0101" => hex(hexlen-I):='5';
             when "0110" => hex(hexlen-I):='6';
             when "0111" => hex(hexlen-I):='7';
             when "1000" => hex(hexlen-I):='8';
             when "1001" => hex(hexlen-I):='9';
             when "1010" => hex(hexlen-I):='A';
             when "1011" => hex(hexlen-I):='B';
             when "1100" => hex(hexlen-I):='C';
             when "1101" => hex(hexlen-I):='D';
             when "1110" => hex(hexlen-I):='E';
             when "1111" => hex(hexlen-I):='F';
             when "ZZZZ" => hex(hexlen-I):='z';
             when "UUUU" => hex(hexlen-I):='u';
             when "XXXX" => hex(hexlen-I):='x';
             when others => hex(hexlen-I):='?';
        end case;
    end loop;
    return hex(1 to hexlen);
 end function TO_HEX_STRING;

 function TO_HEX_STRING(slv: unsigned) return string is
 begin
    return TO_HEX_STRING(std_logic_vector(slv));
 end function TO_HEX_STRING;
 function CEIL_LOG_2(ARG : in INTEGER) return INTEGER IS
 begin
   return INTEGER(CEIL(LOG2(REAL(ARG))));
 end CEIL_LOG_2;
 	-- -----------------------------------------------------------------------------------------------------------
  function MODIFY_VECTOR(
    index_in : in INTEGER; 
    vector : in STD_LOGIC_VECTOR; 
    value_in : in STD_LOGIC
    ) return STD_LOGIC_VECTOR is
  variable v : STD_LOGIC_VECTOR(vector'RANGE) := (others=>'0');
  begin
    v := vector;
    v(index_in) := value_in;
    return v;
  end MODIFY_VECTOR;    
 	-- -----------------------------------------------------------------------------------------------------------  
	function GET_RANDOM(rand : in REAL) return INTEGER is
		variable irand : INTEGER;
	begin
		irand := INTEGER((rand * 100.0 - 0.5) + 50.0);
		return irand;
	end; 
end utils_pkg;
