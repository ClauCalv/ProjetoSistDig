LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY clockController_sp IS
	PORT (clkIN_50MHz  : IN STD_LOGIC ; -- interface
	      clock_50MHz  : OUT STD_LOGIC; -- displayController, playerController, serial_comm, host_comm
	      clock_2Hz   : OUT STD_LOGIC; -- playerController
	      clock_200mHz : OUT STD_LOGIC); -- hostController
END clockController_sp;

ARCHITECTURE behavioral OF clockController_sp IS
CONSTANT lim_2Hz 		: INTEGER := 25E6-1; -- Limite de ciclos de 50Mhz para 2Hz
CONSTANT lim_0_2Hz 	: INTEGER := 25E7-1; -- Limite de ciclos de 50Mhz para 0.2Hz
SIGNAL counter_2Hz 	: INTEGER RANGE 0 TO lim_2Hz := 0; -- Contador de ciclos do clock de 0.5s (2Hz)
SIGNAL counter_0_2Hz : INTEGER RANGE 0 TO lim_0_2Hz := 0; -- Contador de ciclos do clock de 5s (0.2Hz)

BEGIN
	
	clock_50MHz <= clkIN_50MHz ;

	clockDivider_0_2Hz : -- Divisor de clock de 0.5s
	PROCESS(clkIN_50MHz)
	BEGIN
		IF(RISING_EDGE(clkIN_50MHz)) THEN -- Detecção de clock 50Mhz
			IF(counter_2Hz = lim_2Hz) THEN -- Condição onde o contador atinge o limite de ciclos
				clock_200mHz <= '1'; -- Alteração do valor do clock de 0.5s
				counter_2Hz <= 0 ; -- Reset do contador
			ELSE
				clock_200mHz <= '0' ;
				counter_2Hz <= counter_2Hz + 1 ; -- Aumento do contador em 1
			END IF;
		END IF;
	END PROCESS;

	clockDivider_2Hz : -- Divisor de clock de 5s
	PROCESS(clkIN_50MHz)
	BEGIN
		IF(RISING_EDGE(clkIN_50MHz)) THEN -- Detecção de clock 50Mhz
			IF(counter_0_2Hz = lim_0_2Hz) THEN -- Condição onde o contador atinge o limite de ciclos
				clock_2Hz <= '1'; -- Alteração do valor do clock de 5s
				counter_0_2Hz <= 0; -- Reset do contador
			ELSE
				clock_2Hz <= '0';
				counter_0_2Hz <= counter_0_2Hz + 1; -- Aumento do contador em 1
			END IF;
		END IF;
	END PROCESS;
	
END behavioral;
