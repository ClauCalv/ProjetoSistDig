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
	
	commandListener : -- Recebedor dos comando a serem executados pelo jogador
	PROCESS (commandTag, resetTag, systemClock)
	BEGIN
		IF (resetTag = '1') -- Condição onde o comando é resetado
		THEN lastCommandTag <= 14 ; -- Set do ultimo comando para um valor em que nada ocorre
		ELSIF (isPlaying = '1') -- Condição onde o jogador está jogando
		THEN
			IF (commandTag < 14) -- Condição onde a placa recebe um comando a ser executado
			THEN
				clearTime <= '1' ; -- Reset da contagem regressiva
				lastCommandTag <= commandTag ; -- Atribuição do comando recebido ao último comando recebido
			ELSIF (commandTag = 15) -- Condição onde o jogo é resetado por outro jogador
			THEN
				isPlaying <= '0' ; -- Set do jogador para "não jogando"
				clearLife <= '1' ; -- Reset da contagem regressiva
				clearTime <= '1' ; -- Reset das vidas
				lastCommandTag <= 14 ; -- Set do ultimo comando para um valor em que nada ocorre
			ELSE
				clearTime <= '0' ; -- Set da contagem regressiva
				clearLife <= '0' ; -- Set das vidas
			END IF ;
		ELSIF (commandTag = 15) -- Condição onde o jogo é resetado equanto o jogo não foi iniciado
		THEN
			clearLife <= '1' ; -- Reset das vidas
			clearTime <= '1' ; -- Reset da contagem regressiva
			isPlaying <= '1' ; -- Set do jogo, jogo é iniciado
			lastCommandTag <= 14 ; -- Set do ultimo comando para um valor em que nada ocorre
		END IF ;
	END PROCESS ;
	
	timeController : -- Controlador da contagem regressiva
	PROCESS (timeClock, clearTime, systemClock)
	BEGIN
		loseLifeL <= loseLife; -- Set de perda de vida para iluminação
		llT <= '0'; -- Set de perda de vida por tempo (Não perdeu)
		IF (clearTime = '1') -- Condição onde a contagem regressiva está ativa
		THEN timeAmount <= 9 ; -- Atribuição do valor inicial da contagem regressiva
		ELSIF (RISING_EDGE(timeClock)) -- Detecção de clock de 0.5s (2 Hz)
		THEN
			IF (timeAmount > 0) -- Condição onde a contagem regressiva ainda não chegou a zero
			THEN timeAmount <= timeAmount - 1 ; -- Dimininuição do tempo em 1
			ELSE
				timeAmount <= 9 ; -- Resset do tempo da contagem regressiva
				llT <= '1' ; -- Set de perda de vida por tempo (Perdeu)
			END IF;
		END IF ;
	END PROCESS ;

	buttonController : -- Controlador dos botões e switches
	PROCESS (buttonTag, systemClock) 
	BEGIN
		llQ <= '0' ; -- Set do reset do jogo
		resetTag <= '0' ; -- Set do reset do comando
		llB <= '0' ; -- Set de perda de vida por comando
		IF (buttonTag = 15) -- Condição onde o jogo foi resetado
		THEN llQ <= '1' ; -- Set do reset do jogo
		ELSIF (buttonTag = lastCommandTag) -- Condição onde o jogador executa corretamente comando
		THEN resetTag <= '1' ; -- Set do reset do comando
		ELSE llB <= '1'; -- Set de perda de vida por comando
		END IF ;
	END PROCESS ;
	
	lifeController : -- Controlador de vidas
	PROCESS (loseLife, lifeAmount, clearLife, llT, llB, llQ, systemClock)
	BEGIN
		quit <= '0' ; -- Set de perda do jogo
		IF (loseLife = '1') -- Condição onde houve perda de vida
		THEN
			loseLife <= '0' ; -- Set de perda de vida
			lifeAmount <= lifeAmount - 1; -- Redução da quantidade de vidas em 1
		ELSIF (llT = '1' OR llB = '1') -- Condição onde houve perda de vida por comando ou por tempo
		THEN
			loseLife <= '1' ; -- Set de perda de vida
		END IF ;
		
		IF (clearLife = '1') -- Condição de reset de vidas
		THEN lifeAmount <= 7; -- Set da quantidade de vidas inicial
		ELSIF (lifeAmount = 0 OR llQ = '1') -- Condição onde as vidas se acabaram ou caso o jogo tenha sido reiniciado
		THEN quit <= '1' ; -- Set de perda do jogo
		END IF ;
	END PROCESS ;
		
END behavioral ;		
		
		
		
		
		
		
		
		
		
		
		
		
	
	