
ARCHITECTURE behaviour OF bram IS
constant memTypeLength : INTEGER := 2 ** ADDR - 1;
TYPE MemType IS ARRAY(0 TO memTypeLength) OF STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0);
impure FUNCTION InitRamFromFile (ARG : IN STRING) RETURN MemType IS
    -- FILE RamFile : text IS IN ARG;
    file RamFile: text;
    variable fstatus       :file_open_status;
    VARIABLE RamFileLine : line;
    VARIABLE RAM : MemType;
BEGIN
    file_open(fstatus, RamFile, ARG, read_mode);
    FOR I IN MemType'RANGE LOOP
        readline (RamFile, RamFileLine);
        hread (RamFileLine, RAM(I)
        );
    END LOOP; 
    file_close(RamFile);
    RETURN RAM;
END InitRamFromFile;
SIGNAL mem : MemType := InitRamFromFile(RamFileName);
SIGNAL do : STD_LOGIC_VECTOR(DATA - 1 DOWNTO 0) := (OTHERS => '0');
BEGIN
process (clk)
begin
  if EDGE = RISING then
    case MODE is
      when READ_FIRST => if rising_edge(clk) then
                           do <= mem(to_i(adr));
                           if we = '1' then
                             mem(to_i(adr)) <= din;
                           end if;
                         end if;
      when WRITE_FIRST=> if rising_edge(clk) then
                           if we = '1' then
                             mem(to_i(adr)) <= din;
                             do <= din;
                           else
                             do <= mem(to_i(adr));
                          end if;
                        end if;
     when NO_CHANGE  => if rising_edge(clk) then
                           if we = '1' then
                             mem(to_i(adr)) <= din;
                           else
                             do <= mem(to_i(adr));
                          end if;
                        end if;
    end case;
  else
    case MODE is
      when READ_FIRST => if falling_edge(clk) then
                           do <= mem(to_i(adr));
                           if we = '1' then
                             mem(to_i(adr)) <= din;
                           end if;
                         end if;
      when WRITE_FIRST=> if falling_edge(clk) then
                           if we = '1' then
                             mem(to_i(adr)) <= din;
                             do <= din;
                           else
                             do <= mem(to_i(adr));
                          end if;
                        end if;
     when NO_CHANGE  => if falling_edge(clk) then
                           if we = '1' then
                             mem(to_i(adr)) <= din;
                           else
                             do <= mem(to_i(adr));
                          end if;
                        end if;
    end case;
  end if;
end process;
--do <= mem(to_i(adr));
dout <= do;
END behaviour;