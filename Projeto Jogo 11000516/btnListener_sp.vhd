LIBRARY ieee;
USE ieee.std_logic_1164.all;
use IEEE.NUMERIC_STD.all;


ENTITY btnListener_sp IS
	PORT ( clock_50MHz : IN STD_LOGIC ;
			 buttons     : IN STD_LOGIC_VECTOR (13 DOWNTO 0) ; -- interface
			 buttonTag   : OUT INTEGER RANGE 0 TO 15 ) ; -- playerController
END btnListener_sp;

ARCHITECTURE behavioral OF btnListener_sp IS
	SIGNAL switches : STD_LOGIC_VECTOR (9 DOWNTO 0) ;
	SIGNAL realButtons : STD_LOGIC_VECTOR (13 DOWNTO 10) ;
	SIGNAL tmp : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000";
	SIGNAL reset : STD_LOGIC ;
BEGIN
	
	listener :
	PROCESS (switches, realButtons)
	BEGIN
		--IF (rising_edge(clock_50MHz)) then
		--buttonTag <= 14;
		IF (reset = '1') -- Caso onde os 4 botões são acionados, situação para iniciar o jogo
		THEN buttonTag <= 15 ;
		ELSIF ((to_integer(unsigned(tmp))) = 13) THEN
			buttonTag <= to_integer(unsigned(tmp)) + 2;
		ELSE
			buttonTag <= to_integer(unsigned(tmp));
		END IF ;		
		END PROCESS ;
	
	listenSwitches :
	PROCESS (buttons, clock_50MHz)
		VARIABLE lastSwitches : STD_LOGIC_VECTOR (9 DOWNTO 0) := "0000000000" ;
		VARIABLE lastButtons : STD_LOGIC_VECTOR (13 DOWNTO 10) := "0000";
	BEGIN
	IF (rising_edge(clock_50MHz)) then
			reset <= '0';
		FOR i IN 0 TO 9 LOOP 
			IF buttons(i) /= lastSwitches(i) -- Detecção de ação realizada nos switches ou nos botões
			THEN tmp<= std_logic_vector(to_unsigned(i, 4)); Ok <= '1'; 
			END IF ;
			lastSwitches(i) := buttons(i) ;
		END LOOP ;
		FOR i IN 10 TO 13 LOOP
			IF lastButtons = "0000" AND buttons(i) /= lastButtons(i)
			THEN reset <= '1' ; Ok <= '1';
			ELSIF buttons(i) /= lastButtons(i) AND lastButtons(i) = '1' -- Detecção de ação realizada nos switches ou nos botões
			THEN 	tmp <= std_logic_vector(to_unsigned(i, 4)); Ok <= '1';  -- Atribução da identificação do switch ou botão acionado
			END IF ;
			lastButtons(i) := buttons(i);
		END LOOP ;
		end if;
	END PROCESS ;
	
END behavioral ;