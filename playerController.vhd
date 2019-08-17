LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY playerController IS
	PORT ( buttonTag   : IN INTEGER RANGE 0 TO 15 ; --btnListener
			 commandTag  : IN INTEGER RANGE 0 TO 15 ; --serial_comm
			 timeClock   : IN STD_LOGIC ; -- clockController
			 systemClock : IN STD_LOGIC ; -- clockController
			 quit        : OUT STD_LOGIC ; -- serial_comm
			 loseLife    : INOUT STD_LOGIC ; -- serial_comm
			 loseLifeL	 : OUT STD_LOGIC ; -- lightController
			 lifeAmount  : INOUT INTEGER RANGE 0 TO 7 ; -- lightController
			 timeAmount  : INOUT INTEGER RANGE 0 TO 9 ) ; -- lightController
END playerController;

-- 0 to 9   => switches
-- 10 to 13 => buttons
-- 14       => no communications
-- 15       => gameReset

ARCHITECTURE behavioral OF playerController IS
	SIGNAL lastCommandTag                                           : INTEGER RANGE 0 TO 15 ;
	SIGNAL clearTime, clearLife, llT, llB, llQ, isPlaying, resetTag : STD_LOGIC ;
BEGIN
	
	commandListener :
	PROCESS (commandTag, resetTag, systemClock)
	BEGIN
		IF (resetTag = '1')
		THEN lastCommandTag <= 14 ;
		ELSIF (isPlaying = '1')
		THEN
			IF (commandTag < 14)
			THEN
				clearTime <= '1' ;
				lastCommandTag <= commandTag ;
			ELSIF (commandTag = 15)
			THEN
				isPlaying <= '0' ;
				clearLife <= '1' ;
				clearTime <= '1' ;
				lastCommandTag <= 14 ;
			ELSE
				clearTime <= '0' ;
				clearLife <= '0' ;
			END IF ;
		ELSIF (commandTag = 15)
		THEN
			clearLife <= '1' ;
			clearTime <= '1' ;
			isPlaying <= '1' ;
			lastCommandTag <= 14 ;
		END IF ;
	END PROCESS ;
	
	timeController :
	PROCESS (timeClock, clearTime, systemClock)
	BEGIN
		loseLifeL <= loseLife;
		llT <= '0';
		IF (clearTime = '1')
		THEN timeAmount <= 9 ;
		ELSIF (RISING_EDGE(timeClock))
		THEN
			IF (timeAmount > 0)
			THEN timeAmount <= timeAmount - 1 ;
			ELSE
				timeAmount <= 9 ;
				llT <= '1' ;
			END IF ;
		END IF;
	END PROCESS ;

	buttonController :
	PROCESS (buttonTag, systemClock) 
	BEGIN
		llQ <= '0' ;
		resetTag <= '0' ;
		llB <= '0' ;
		IF (buttonTag = 15)
		THEN llQ <= '1' ;
		ELSIF (buttonTag = lastCommandTag)
		THEN resetTag <= '1' ;
		ELSE llB <= '1';
		END IF ;
	END PROCESS ;
	
	lifeController :
	PROCESS (loseLife, lifeAmount, clearLife, llT, llB, llQ, systemClock)
	BEGIN
		quit <= '0' ;
		IF (loseLife = '1')
		THEN
			loseLife <= '0' ;
			lifeAmount <= lifeAmount - 1;
		ELSIF (llT = '1' OR llB = '1')
		THEN
			loseLife <= '1' ;
		END IF ;
		
		IF (clearLife = '1')
		THEN lifeAmount <= 7;
		ELSIF (lifeAmount = 0 OR llq = '1')
		THEN quit <= '1' ;
		END IF ;
	END PROCESS ;
		
END behavioral ;		
		
		
		
		
		
		
		
		
		
		
		
		
	
	