LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.math_real.all;
USE ieee.numeric_std.all;

ENTITY hostController_sp IS
	PORT ( commandTag   : OUT INTEGER RANGE 0 TO 15 ; --playerController
			 isPlayingH   : IN STD_LOGIC ;	-- playerController
			 clock_200mHz : IN STD_LOGIC ) ; -- clockController
END hostController_sp;

ARCHITECTURE behavioral OF hostController_sp IS
	SIGNAL wasPlaying : STD_LOGIC ;
BEGIN
	
	-- RANDOM GENERATOR AT https://books.google.com.br/books?id=fyvnBwAAQBAJ&pg=PA47&lpg=PA47&dq=vhdl+random+number+generator+with+rem&source=bl&ots=R3dT2sGyqP&sig=ACfU3U12EmbU9gjBgR1u8pCYgN-7ZCn7ag&hl=pt-BR&sa=X&ved=2ahUKEwiJ9NGrn5nkAhXOEbkGHT-2B9kQ6AEwAnoECAYQAQ#v=onepage&q=vhdl%20random%20number%20generator%20with%20rem&f=false
	randomGen :
	PROCESS (isPlayingH, clock_200mHz)
		VARIABLE seed 			: INTEGER := 17654;
		VARIABLE multiplier 	: INTEGER := 25173;
		VARIABLE increment	: INTEGER := 13849;
		VARIABLE modulus 		: INTEGER := 65536;
	BEGIN
		IF isPlayingH = '0' AND wasPlaying = '1'
		THEN commandTag <= 15 ;
		ELSIF isPlayingH = '0' AND wasPlaying = '0'
		THEN commandTag <= 14 ;
		ELSIF RISING_EDGE(clock_200mHz)  -- Detecção de clock
		THEN
			seed := (multiplier * seed + increment) mod modulus ; -- Geração de um valor aleatório
			commandTag <= seed mod 14 ; -- Atribuição do valor aleatório ao comando
		END IF ;
		wasPlaying <= isPlayingH ;
	END PROCESS ;
					
END behavioral ;
					
					
					
					
					
					
					
					
					
					
