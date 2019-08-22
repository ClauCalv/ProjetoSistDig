LIBRARY ieee;
USE ieee.std_logic_1164.all;

ENTITY serial_comm IS
	PORT ( clock_20MHz   : IN STD_LOGIC ; -- clockController
			 comm_clkHost  : IN STD_LOGIC ; -- interface
			 comm_fromHost : IN STD_LOGIC ; -- interface
			 comm_toHost   : OUT STD_LOGIC ; -- interface
			 commandTag    : OUT INTEGER RANGE 0 TO 15 ; -- playerController
			 quit				: IN STD_LOGIC ; -- playerController
			 loseLife		: INOUT STD_LOGIC ; -- playerController
			 commandTagEx	: OUT INTEGER RANGE 0 TO 15 ; -- displayController
			 exhibitorTag	: OUT INTEGER RANGE 0 TO 3 ) ; -- displayController
END serial_comm ;

ARCHITECTURE states OF serial_comm IS
	TYPE commState IS (protocolS, messageS, idleS);
	SIGNAL state_toHost, state_fromHost : commState;
	CONSTANT protocol_init : STD_LOGIC_VECTOR (3 DOWNTO 0) := "1100";
	CONSTANT protocol_end  : STD_LOGIC_VECTOR (3 DOWNTO 0) := "0011";
	SIGNAL messageFinished : STD_LOGIC ;
	SIGNAL message : STD_LOGIC_VECTOR (11 DOWNTO 0)
BEGIN

	listenHost :
	PROCESS
		VARIABLE received : STD_LOGIC_VECTOR (11 DOWNTO 0) ;
		VARIABLE indexReceived : INTEGER RANGE 0 TO 11 ;
		CONSTANT clearReceived : STD_LOGIC_VECTOR (11 DOWNTO 0) := "00000000000"
	BEGIN
		WAIT UNTIL RISING_EDGE(comm_clkHost) ;
		messageFinished <= '0' ;
		CASE state_fromHost IS
		WHEN idleS =>
			IF comm_fromHost = '1'
			THEN
				received(0) := '1' ;
				state_fromHost <= protocolS;
				indexReceived := 0 ;
			ELSE
				received <= clearReceived;
			END IF
		WHEN protocolS =>
			IF received (3 DOWNTO 0) = protocol_init
			THEN
				received(0) := comm_fromHost ;
				state_fromHost <= messageS;
				indexReceived := 0 ;
			ELSIF received (3 DOWNTO 0) = protocol_end
			THEN
				received := clearReceived ;
				state_fromHost <= idleS;
				indexReceived := 0 ;
			ELSIF 
					(indexReceived = 1 AND received(0) /= received (1))
				OR (indexReceived = 2 AND received (1) = received (2))
				OR (indexReceived = 3 AND received (2) /= received (3))
			THEN
				received <= clearReceived;
				indexReceived := 0 ;
				state_fromHost <= idleS;
			ELSE
				indexReceived := indexReceived + 1 ;
				received (indexReceived) := comm_fromHost ;
			END IF ;
		WHEN messageS => 
			IF received (0) = 1 OR indexReceived = 11
			THEN
				message <= received ;
				messageFinished <= '1' ;
				indexReceived := 0 ;
				received := clearReceived ;
				state_fromHost <= protocolS ;
			ELSE
				indexReceived := indexReceived + 1 ;
				received (indexReceived) := comm_fromHost ;
			END IF ;
		END CASE ;
	END PROCESS ;
					
	readMessage :
	PROCESS
	BEGIN
		WAIT UNTIL RISING_EDGE(clock_20MHz) ;
		IF messageFinished = '1'
		THEN
			IF message(0) = '1'
			THEN loseLife <= '1' ;
			ELSE
				commandTag <= to_integer(unsigned(message(4 DOWNTO 1)));
				exhibitorTag <= to_integer(unsigned(message(6 DOWNTO 5)));
				commandTagEx <= to_integer(unsigned(message(10 DOWNTO 7)));
			END IF
		ELSE
			commandTag <= 14
		END IF ;
	END PROCESS ;
	
	writeHost :
	PROCESS
		VARIABLE toWrite : STD_LOGIC_VECTOR (1 DOWNTO 0) ;
		VARIABLE indexToWrite : INTEGER RANGE 0 TO 4 ;
		VARIABLE nextProtocol : STD_LOGIC_VECTOR (3 DOWNTO 0) ;
	BEGIN
		WAIT UNTIL RISING_EDGE(comm_clkHost) ;
		CASE state_toHost IS
		WHEN idleS =>
			toWrite <= loseLife & quit
			IF toWrite /= "00"
			THEN
				state_toHost <= protocolS;
				nextProtocol := protocol_init;
				indexToWrite := 0 ;
			END IF
		WHEN protocolS =>
			IF indexToWrite < 4 
			THEN
				comm_toHost <= nextProtocol(indexToWrite) ;
				indexToWrite := indexToWrite + 1 ;
			ELSIF nextProtocol = protocol_init
			THEN comm_toHost <= toWrite(0) ;
			ELSE
				comm_toHost <= 0 ;
				state_toHost <= idleS ;
			END IF ;
		WHEN messageS => 
			comm_toHost <= toWrite(1);
			nextProtocol <= protocol_end;
			indexToWrite <= 0;
		END CASE ;
	END PROCESS ;
		
END ARCHITECTURE ;
		
		
		
		
		
	
	
	
