LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY clockController IS
	PORT (clock_50MHz : IN STD_LOGIC;
			clock_0_5s 	: INOUT STD_LOGIC;
			clock_5s 	: INOUT STD_LOGIC);
END clockController;

ARCHITECTURE behavioral OF clockController IS
CONSTANT lim_2Hz 		: INTEGER := 25E6-1; -- Limite de ciclos de 50Mhz para 2Hz
CONSTANT lim_0_2Hz 	: INTEGER := 25E7-1; -- Limite de ciclos de 50Mhz para 0.2Hz
SIGNAL counter_2Hz 	: INTEGER RANGE 0 TO lim_2Hz := 0; -- Contador de ciclos do clock de 0.5s (2Hz)
SIGNAL counter_0_2Hz : INTEGER RANGE 0 TO lim_0_2Hz := 0; -- Contador de ciclos do clock de 5s (0.2Hz)

BEGIN

	clockDivider_0_2Hz : -- Divisor de clock de 0.5s
	PROCESS(clock_50MHz)
	BEGIN
		IF(RISING_EDGE(clock_50MHz)) THEN -- Detecção de clock 50Mhz
			IF(counter_2Hz = lim_2Hz) THEN -- Condição onde o contador atinge o limite de ciclos
				clock_0_5s <= NOT(clock_0_5s); -- Alteração do valor do clock de 0.5s
				counter_2Hz <= 0; -- Reset do contador
			ELSE
				counter_2Hz <= counter_2Hz + 1; -- Aumento do contador em 1
			END IF;
		END IF;
	END PROCESS;

	clockDivider_2Hz : -- Divisor de clock de 5s
	PROCESS(clock_50MHz)
	BEGIN
		IF(RISING_EDGE(clock_50MHz)) THEN -- Detecção de clock 50Mhz
			IF(counter_0_2Hz = lim_0_2Hz) THEN -- Condição onde o contador atinge o limite de ciclos
				clock_5s <= NOT(clock_5s); -- Alteração do valor do clock de 5s
				counter_0_2Hz <= 0; -- Reset do contador
			ELSE
				counter_0_2Hz <= counter_0_2Hz + 1; -- Aumento do contador em 1
			END IF;
		END IF;
	END PROCESS;
	
END behavioral;