LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY btnListener_sp IS
	PORT ( clock_50MHz : IN STD_LOGIC ;
			 buttons   : IN STD_LOGIC_VECTOR (13 DOWNTO 0) ; -- interface
			 buttonTag : OUT INTEGER RANGE 0 TO 15 ) ; -- playerController
END btnListener_sp;

ARCHITECTURE behavioral OF btnListener_sp IS
	SIGNAL switches : STD_LOGIC_VECTOR (9 DOWNTO 0) ;
	SIGNAL realButtons : STD_LOGIC_VECTOR (13 DOWNTO 10) ;
	SIGNAL reset : STD_LOGIC ;
BEGIN
	
	listener :
	PROCESS (switches, realButtons, clock_50MHz) 
	BEGIN
		buttonTag <= 14;
		FOR i IN 0 TO 13 LOOP 
			IF 
				(i < 10 AND switches(i) = '1')
				OR (i >= 10 AND realButtons(i) = '1') -- Detecção de ação realizada nos switches ou nos botões
			THEN buttonTag <= i ; -- Atribução da identificação do switch ou botão acionado
			END IF ;
		END LOOP ;
		IF (reset = '1') -- Caso onde os 4 botões são acionados, situação para iniciar o jogo
		THEN buttonTag <= 15 ;
		END IF ;
	END PROCESS ;
	
	listenSwitches :
	PROCESS (buttons, clock_50MHz)
		VARIABLE lastSwitches : STD_LOGIC_VECTOR (9 DOWNTO 0) ;
	BEGIN
		FOR i IN 0 TO 9 LOOP 
			IF buttons(i) /= lastSwitches(i) -- Detecção de ação realizada nos switches ou nos botões
			THEN switches(i) <= '1' ;
			ELSE switches(i) <= '0' ;
			END IF ;
			lastSwitches(i) := buttons(i) ;
		END LOOP ;
	END PROCESS ;
	
	listenButtons :
	PROCESS (buttons, clock_50MHz)
		VARIABLE lastButtons : STD_LOGIC_VECTOR (13 DOWNTO 10) ;
	BEGIN
		reset <= '0';
		FOR i IN 10 TO 13 LOOP
			IF lastButtons = "0000" AND buttons(i) /= lastButtons(i)
			THEN reset <= '1' ;
			ELSIF buttons(i) /= lastButtons(i) AND lastButtons(i) = '1' -- Detecção de ação realizada nos switches ou nos botões
			THEN realButtons(i) <= '1' ; -- Atribução da identificação do switch ou botão acionado
			ELSE realButtons(i) <= '0' ;
			END IF ;
		END LOOP ;
	END PROCESS ;
	
END behavioral ;