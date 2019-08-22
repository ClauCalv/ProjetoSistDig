LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY host_comm IS
	PORT ( clock_20MHz      : IN STD_LOGIC ; -- clockController
			 clock_200mHz	: IN STD_LOGIC ; -- clockController
			 comm_fromPlayers : IN STD_LOGIC_VECTOR (3 DOWNTO 0) ; -- interface
			 comm_toPlayers   : OUT STD_LOGIC_VECTOR (3 DOWNTO 0) ; -- interface
			 comm_clkHost	   : OUT STD_LOGIC ; -- interface
			 commandsConv     : OUT STD_LOGIC_VECTOR (15 DOWNTO 0) ; -- hostController
			 exhibitorsConv   : OUT STD_LOGIC_VECTOR (7 DOWNTO 0) ; -- hostController
END host_comm ;

ARCHITECTURE states OF host_comm IS
	TYPE commState IS (protocolS, messageS, idleS);
	SIGNAL state_toPlayers, state_fromPlayers : ARRAY (3 DOWNTO 0) OF commState;
	CONSTANT protocol_init : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	CONSTANT protocol_end  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	SIGNAL messageFinished : STD_LOGIC_VECTOR (3 DOWNTO 0) ;
	SIGNAL message : ARRAY (3 DOWNTO 0) OF (STD_LOGIC_VECTOR (3 DOWNTO 0));
	SIGNAL writeLoseLife, writeLoseGame : STD_LOGIC ;
	SIGNAL playerLost : INTEGER RANGE 0 TO 3 ;
	
	TYPE INT_ARRAY IS ARRAY (INTEGER RANGE <>) OF INTEGER ;
	SIGNAL commandTags   : INT_ARRAY (3 DOWNTO 0) ;
	SIGNAL exhibitorTags : INT_ARRAY (3 DOWNTO 0) ;
	SIGNAL commandTagExs : INT_ARRAY (3 DOWNTO 0) ;
BEGIN

	conversor : -- Conversor dos Vetores para Inteiros
	FOR i IN 0 TO 3 GENERATE
		commandTags(i) <= to_integer(unsigned(commandsConv((i*4)+3) DOWNTO (i*4)))
		exhibitorTags(i) <= to_integer(unsigned(exhibitorsConv((i*2)+1) DOWNTO (i*2)))
		commandTagExs(i) <= commandTags( exhibitorTags(i) );
	END GENERATE ;
	
	listenPlayers :
	PROCESS
		VARIABLE received : ARRAY (3 DOWNTO 0) OF (STD_LOGIC_VECTOR (3 DOWNTO 0));
		VARIABLE indexReceived : ARRAY (3 DOWNTO 0) OF (INTEGER RANGE 0 TO 3) ;
		CONSTANT clearReceived : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0000"
	BEGIN
		WAIT UNTIL RISING_EDGE(clock_20MHz) ;
		comm_clkHost <= clock_20MHz ;
		FOR i IN 0 TO 3 LOOP
			messageFinished(i) <= '0' ;
			CASE state_fromPlayers(i) IS
			WHEN idleS =>
					IF comm_fromPlayers(i) = '1'
					THEN
						received(i)(0) := '1' ;
						state_fromPlayers(i) <= protocolS;
						indexReceived(i) := 0 ;
					ELSE
						received(i) <= clearReceived;
					END IF
				END LOOP
			WHEN protocolS =>
				IF received(i)(3 DOWNTO 0) = protocol_init
				THEN
					received(i)(0) := comm_fromPlayers(i) ;
					state_fromPlayers(i) <= messageS;
					indexReceived(i) := 0 ;
				ELSIF received(i)(3 DOWNTO 0) = protocol_end
				THEN
					received(i) := clearReceived ;
					state_fromPlayers(i) <= idleS;
					indexReceived(i) := 0 ;
				ELSIF 
						(indexReceived(i) = 1 AND received(i)(0) /= received(i)(1))
					OR (indexReceived(i) = 2 AND received(i)(1)  = received(i)(2))
					OR (indexReceived(i) = 3 AND received(i)(2) /= received(i)(3))
				THEN
					received(i) := clearReceived;
					indexReceived(i) := 0 ;
					state_fromPlayers(i) <= idleS;
				ELSE
					indexReceived(i) := indexReceived(i) + 1 ;
					received(i)(indexReceived) := comm_fromPlayers(i) ;
				END IF ;
			WHEN messageS => 
				IF indexReceived(i) = 2
				THEN
					message(i) <= received(i) ;
					messageFinished(i) <= '1' ;
					indexReceived(i) := 0 ;
					received(i) := clearReceived ;
					state_fromPlayers(i) <= protocolS ;
				ELSE
					indexReceived(i) := indexReceived(i) + 1 ;
					received(i)(indexReceived) := comm_fromPlayers(i) ;
				END IF ;
			END CASE ;
		END LOOP ;
	END PROCESS ;
					
	readMessage :
	PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clock_20MHz) ;
		writeLoseGame <= 0 ;
		writeLoseLife <= 0 ;
		FOR i IN 0 TO 3 LOOP
			IF messageFinished(i) = '1'
			THEN
				IF message(i)(0) = '1'
				THEN 
					writeLoseLife <= '1' ;
					playerLost <= i ;
				END IF ;
				IF message(i)(1) = '1'
				THEN writeLoseGame <= '1' ;
				END IF
			ELSE
				commandTag <= 14
			END IF ;
		END LOOP ;
	END PROCESS ;
	
	writeHost :
	PROCESS
		VARIABLE toWrite : ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (10 DOWNTO 0) ;
		VARIABLE indexToWrite : ARRAY (3 DOWNTO 0) OF INTEGER RANGE 0 TO 10 ;
		VARIABLE nextProtocol : ARRAY (3 DOWNTO 0) OF STD_LOGIC_VECTOR (3 DOWNTO 0) ;
	BEGIN
		WAIT UNTIL RISING_EDGE(comm_clkHost) ;
		FOR i IN 0 TO 3 LOOP
			CASE state_toPlayers(i) IS
			WHEN idleS =>
				IF clock_200mHz = '1'
				THEN toWrite(i) = commandTagExs(i) & exhibitorTags(i) & commandTags(i) & 0 ;
				ELSIF writeLoseGame = '1'
				THEN toWrite(i) = commandTagExs(i) & exhibitorTags(i) & "1111_0" ;
				ELSIF writeLoseLife = '1'
				THEN toWrite(i) = commandTagExs(i) & exhibitorTags(i) & "0000_1" ;
				ELSE toWrite(i) = commandTagExs(i) & exhibitorTags(i) & "1110_0" ;
				END IF;
				IF toWrite(i)(4 DOWNTO 0) /= "1110_0"
				THEN
					state_toPlayers(i) <= protocolS;
					nextProtocol(i) := protocol_init;
					indexToWrite(i) := 0 ;
				END IF
			WHEN protocolS =>
				IF indexToWrite(i) < 4 
				THEN
					comm_toPlayers(i) <= nextProtocol(i)(indexToWrite) ;
					indexToWrite(i) := indexToWrite(i) + 1 ;
				ELSIF nextProtocol(i) = protocol_init
				THEN 
					comm_toPlayers(i) <= toWrite(i)(0) ;
					state_toPlayers(i) <= messageS ;
				ELSE
					comm_toPlayers(i) <= 0 ;
					state_toPlayers(i) <= idleS ;
					indexToWrite(i) := 1
				END IF ;
			WHEN messageS => 
				IF indexToWrite(i) < 11
				THEN
					comm_ToPlayers(i) <= toWrite(i)(indexToWrite);
					indexToWrite(i) := indexToWrite(i) + 1 ;
				ELSE
					comm_toPlayers(i) <= protocol_end(1);
					nextProtocol := protocol_end;
					indexToWrite := 1;
			END CASE ;
		END LOOP;
	END PROCESS ;
		
END ARCHITECTURE ;
