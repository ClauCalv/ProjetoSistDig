LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY btnListener IS
	PORT ( buttons   : IN STD_LOGIC_VECTOR (13 DOWNTO 0) ; -- interface
			 buttonTag : OUT INTEGER RANGE 0 TO 15 ) ; -- playerController
END btnListener;

ARCHITECTURE behavioral OF btnListener IS
BEGIN
	
	listener :
	PROCESS (buttons)
	BEGIN
		FOR i IN 0 TO 13 LOOP
			IF (i < 10 AND buttons(i)'EVENT) OR (i >= 10 AND buttons(i)'EVENT AND buttons(i) = '1')
			THEN buttonTag <= i ;
			END IF ;
		END LOOP ;
		IF (buttons (13 DOWNTO 10) = "0000")
		THEN buttonTag <= 15 ;
		END IF ;
	END PROCESS ;
	
END behavioral ;