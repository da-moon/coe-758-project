PACKAGE BODY cache_pkg IS
FUNCTION GET_TAG(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
VARIABLE tag : STD_LOGIC_VECTOR(7 DOWNTO 0) := (OTHERS => '0');
BEGIN
tag := ARG(15 DOWNTO 8);
RETURN tag;
END;
-- -----------------------------------------------------------------------------------------------------------

FUNCTION GET_INDEX(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
VARIABLE index : STD_LOGIC_VECTOR(2 DOWNTO 0) := (OTHERS => '0');
BEGIN
index := ARG(7 DOWNTO 5);
RETURN index;
END;
-- -----------------------------------------------------------------------------------------------------------
FUNCTION GET_OFFSET(ARG : IN STD_LOGIC_VECTOR) RETURN STD_LOGIC_VECTOR IS
VARIABLE offset : STD_LOGIC_VECTOR(4 DOWNTO 0) := (OTHERS => '0');
BEGIN
offset := ARG(4 DOWNTO 0);
RETURN offset;
END;
END cache_pkg;
