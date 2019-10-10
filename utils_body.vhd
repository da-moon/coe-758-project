
package body utils is
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
end utils;