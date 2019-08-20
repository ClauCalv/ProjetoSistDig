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
	
	conversor : -- Conversor de Inteiros para Vetores
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
		WAIT UNTIL RISING_EDGE(randomClock) ; -- Detecção de clock
		FOR j IN 0 TO 3 LOOP
			assigned(j) := (-1) ; -- Atribuição de um comando para cada player
		END LOOP ;
		FOR i IN 0 TO 3 LOOP
			UNIFORM( seed1, seed2, rand ) ; -- Geração de um valor aleatório
			commands(i) <= integer(floor(rand * 14.0)) ; -- Atribuição do valor aleatório ao comando
			success := FALSE ; -- Set do sucesso na operação
			WHILE (NOT success) LOOP -- Laço enquanto o a operação não for bem sucedida
				UNIFORM( seed1, seed2, rand ) ; -- Geração de um valor aleatório
				randomExibit := integer(floor(rand * 4.0)) ; -- Atribuição do valor aleatório ao jogador
				success := TRUE ; -- Set do sucesso na operação
				FOR j IN 0 TO 3 LOOP 
					IF assigned(i) = randomExibit -- Condição onde o jogador escolhido para atribuição já tenha um comando atribuido
					THEN success := FALSE ; -- Set do sucesso na operação
					END IF ;
				END LOOP ;
				IF success -- Condição onde a operação de escolha foi bem sucedida
				THEN
					assigned(i)   := randomExibit ; -- Atribuição do jogador escolhido aos já escolhidos
					exhibitors(i) <= randomExibit ; -- Atribuição do jogador escolhido
				END IF ;
			END LOOP ;
		END LOOP ;
	END PROCESS ;
					
END behavioral ;
					
					
					
					
					
					
					
					
					
					