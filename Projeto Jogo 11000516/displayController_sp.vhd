LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.numeric_std.all;

ENTITY displayController_sp IS
	PORT ( commandTag	  : IN INTEGER RANGE 0 TO 15; -- serial_comm
	       clock_50MHz 	  : IN STD_LOGIC; -- clock controller
	       seg7_3 		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- interface
	       seg7_2 		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- interface
	       seg7_1 		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0); -- interface
	       seg7_0 		  : OUT STD_LOGIC_VECTOR(6 DOWNTO 0)); -- interface
END displayController_sp;

ARCHITECTURE behavioral OF displayController_sp IS
CONSTANT button  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0000011"; -- Símbolo b codificado para 7 segmentos
CONSTANT switch  : STD_LOGIC_VECTOR(6 DOWNTO 0) := "0010010"; -- Símbolo s codificado para 7 segmentos
CONSTANT blank   : STD_LOGIC_VECTOR(6 DOWNTO 0) := "1111111"; -- Codifiação para o display apagado

	FUNCTION bcd_to_seg7 (bcd : STD_LOGIC_VECTOR(3 DOWNTO 0)) RETURN STD_LOGIC_VECTOR IS -- Conversor de BCD para Display 7 segmentos
		VARIABLE seg7 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	BEGIN
		seg7(0) := NOT((bcd(3)) OR (bcd(1)) OR ((bcd(2)) AND (bcd(0))) OR ((NOT bcd(2)) AND (NOT bcd(0))));
		seg7(1) := NOT((NOT bcd(2)) OR ((NOT bcd(1)) AND (NOT bcd(0))) OR ((bcd(1)) AND (bcd(0))));
		seg7(2) := NOT((bcd(2)) OR (NOT bcd(1)) OR (bcd(0)));
		seg7(3) := NOT(((NOT bcd(2)) AND (NOT bcd(0))) OR ((bcd(1)) AND (NOT bcd(0))) OR ((bcd(2)) AND (NOT bcd(1)) AND (bcd(0))) OR ((NOT bcd(2)) AND (bcd(1))) OR (bcd(3)));
		seg7(4) := NOT(((NOT bcd(2)) AND (NOT bcd(0))) OR ((bcd(1)) AND (NOT bcd(0))));
		seg7(5) := NOT((bcd(3)) OR ((NOT bcd(1)) AND (NOT bcd(0))) OR ((bcd(2)) AND (NOT bcd(1))) OR ((bcd(2)) AND (NOT bcd(0))));
		seg7(6) := NOT((bcd(3)) OR ((bcd(2)) AND (NOT bcd(1))) OR ((NOT bcd(2)) AND (bcd(1))) OR ((bcd(1)) AND (NOT bcd(0))));
		RETURN seg7;
	END bcd_to_seg7;

	FUNCTION int_to_seg7 (int : INTEGER) RETURN STD_LOGIC_VECTOR IS -- Conversor de inteiro para Display 7 segmentos
		VARIABLE bin  : STD_LOGIC_VECTOR(3 DOWNTO 0);
		VARIABLE seg7 : STD_LOGIC_VECTOR(6 DOWNTO 0);
	BEGIN
		bin := STD_LOGIC_VECTOR(TO_UNSIGNED(int,4)); -- Conversão de inteiro para binário
		seg7 := bcd_to_seg7(bin);
		RETURN seg7;
	END int_to_seg7;

BEGIN

	display:
	PROCESS (clock_50MHz)
	BEGIN
		IF (RISING_EDGE(clock_50MHz)) THEN
			seg7_0 <= int_to_seg7(commandTag); -- Atribuição do comando ao display 0
			seg7_2 <= blank; -- Atribuição do blank ao display 2 
			seg7_3 <= blank; -- Atribuição do jogador ao display 3
			IF(commandTag < 10) THEN
				seg7_1 <= button; -- Atribuição do botão ao display 1
			ELSIF(commandTag < 14) THEN
				seg7_1 <= switch; -- Atribuição do switch ao display 1
			END IF;
		END IF;
	END PROCESS;

END behavioral;
