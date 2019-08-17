LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY lightController IS
	PORT ( redleds    : OUT STD_LOGIC_VECTOR (9 DOWNTO 0) ; -- interface
			 greenleds  : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) ; -- interface
			 lifeAmount : IN INTEGER RANGE 0 TO 7 ; -- playerController
			 timeAmount : IN INTEGER RANGE 0 TO 9 ; -- playerController
			 loseLifeL  : IN STD_LOGIC ) ; -- playerController
END lightController ;

ARCHITECTURE dataflow OF lightController IS
BEGIN

	timeLeds : 
	FOR i IN timeAmount'RANGE GENERATE
		redleds(i) <= '1' WHEN (timeAmount >= i OR loseLifeL = '1') ELSE '0' ;
	END GENERATE ;
		
	lifeLeds :
	FOR i IN lifeAmount'RANGE GENERATE
		greenleds(i) <= '1' WHEN (lifeAmount >= i OR loseLifeL = '1') ELSE '0' ;
	END GENERATE ;
	
END dataflow ;