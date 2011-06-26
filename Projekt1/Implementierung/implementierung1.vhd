library ieee;
use ieee.numeric_std.all;

ENTITY BINBCD IS

PORT(
    bin_input : IN std_logic_vector (16 DOWNTO 0);
    einer, zehner, hunderter, tausender, zehntausender : OUT std_logic_vector (3 DOWNTO 0);
    overflow : OUT std_logic
);

END BINBCD; 



ARCHITECTURE v1 OF BINBCD IS

	signal const : std_logic_vector (16 DOWNTO 0) := "11000011010011111";
	signal vector : std_logic_vector (36 DOWNTO 0) := "0000000000000000000000000000000000000";
	signal i : integer := 0;
	
BEGIN
	
	overflow <= '0'
	
	FOR i IN 0 TO 16 LOOP
		IF (bin_input(i) = '1') AND (const(i) = '0') THEN
			overflow <= '1';
			EXIT
		END IF
	END LOOP
	
	
	IF (overflow = "0") THEN
	
		FOR i IN 0 TO 16
			vector(i+20) <= bin_input(i);
		END LOOP
		
		FOR i IN 0 TO 15 LOOP
			vector sll 1;
			-- Hierhin muss noch:
			-- -Prüfen, ob vector(0to3), oder vector(4to7), oder vector(8to11), oder vector(12to15), oder vector(16to19) >= 5 sind
			-- -Zu den jeweiligen Abschnitten von vector 3 addieren.
		END LOOP
		vector sll 1;
		
		FOR i IN 0 TO 3
			zehntausender(i) <= vector(i);
			tausender(i) <= vector(i+4);
			hunderter(i) <= vector(i+8);
			zehner(i) <= vector(i+12);
			einer(i) <= vector(i+16);
		END LOOP
		
	END IF
	
	
END v1



ARCHITECTURE v2 OF BINBCD IS

	signal int_input : integer := 0;
	signal vector : std_logic_vector (36 DOWNTO 0);
	signal i : integer := 0;
	
BEGIN
	
	
	int_input <= to_integer(unsigned(bin_input));
	
	IF (int_input <= 99999) THEN
	
		vector <= "00000000000000000000" & bin_input;
		
		FOR i IN 0 TO 15 LOOP
			vector sll 1;
			-- Hierhin muss noch:
			-- -Prüfen, ob vector(0to3), oder vector(4to7), oder vector(8to11), oder vector(12to15), oder vector(16to19) >= 5 sind
			-- -Zu den jeweiligen Abschnitten von vector 3 addieren.
		END LOOP
		vector sll 1;
		
		zehntausender <= vector(3 DOWNTO 0);
		tausender <= vector(7 DOWNTO 4);
		hunderter <= vector(11 DOWNTO 8);
		zehner <= vector(15 DOWNTO 12);
		einer <= vector(19 DOWNTO 16);
		
	ELSE
	
		overflow <= '1'
	
	END IF
	
	
END v2






-- http://www.mikrocontroller.net/topic/90462