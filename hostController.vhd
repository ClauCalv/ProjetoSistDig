LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.math_real.all;
USE ieee.numeric_std.all;

ENTITY hostController IS
	PORT ( commandsConv   : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) ; --host_comm
			 exhibitorsConv : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) ;	--host_comm
			 randomClock  : IN STD_LOGIC ) ; -- clockController
END hostController;

ARCHITECTURE behavioral OF hostController IS
	TYPE INT_ARRAY IS ARRAY (INTEGER RANGE <>) OF INTEGER ;
	SIGNAL commands   : INT_ARRAY (3 DOWNTO 0) ; --host_comm
	SIGNAL exhibitors : INT_ARRAY (3 DOWNTO 0) ;	--host_comm
BEGIN
	
	conversor :
	FOR i IN 0 TO 3 GENERATE
		commandsConv(((i*4)+3) DOWNTO (i*4)) <= std_logic_vector(to_unsigned(commands(i),4)) ;
		exhibitorsConv(((i*2)+3) DOWNTO (i*2)) <= std_logic_vector(to_unsigned(commands(i),2)) ;
	END GENERATE ;

	randomGen :
	PROCESS
		VARIABLE seed1, seed2 : POSITIVE;
		VARIABLE rand         : REAL ;
		VARIABLE success		 : BOOLEAN ;
		VARIABLE randomExibit : INTEGER ;
		VARIABLE assigned		 : INT_ARRAY (3 DOWNTO 0) ;
	BEGIN
		WAIT UNTIL RISING_EDGE(randomClock) ;
		FOR j IN 0 TO 3 LOOP
			assigned(j) := (-1) ;
		END LOOP ;
		FOR i IN 0 TO 3 LOOP
			UNIFORM( seed1, seed2, rand ) ;
			commands(i) <= integer(floor(rand * 14.0)) ;
			success := FALSE ;
			WHILE (NOT success) LOOP
				UNIFORM( seed1, seed2, rand ) ;
				randomExibit := integer(floor(rand * 4.0)) ;
				success := TRUE ;
				FOR j IN 0 TO 3 LOOP
					IF assigned(i) = randomExibit
					THEN success := FALSE ;
					END IF ;
				END LOOP ;
				IF success
				THEN
					assigned(i)   := randomExibit ;
					exhibitors(i) <= randomExibit ;
				END IF ;
			END LOOP ;
		END LOOP ;
	END PROCESS ;
					
END behavioral ;
					
					
					
					
					
					
					
					
					
					