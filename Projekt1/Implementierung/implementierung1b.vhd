LIBRARY ieee;
USE ieee.numeric_std.all;

ENTITY BINBCD IS

PORT(
    bin_input : IN std_logic_vector (16 DOWNTO 0);
    einer, zehner, hunderter, tausender, zehntausender : OUT std_logic_vector (3 DOWNTO 0);
    overflow : OUT std_logic
);

END BINBCD; 



ARCHITECTURE DoubleDabbleV2 OF BINBCD IS

	signal int_input : integer := 0;
	signal vector : std_logic_vector (36 DOWNTO 0);
	signal i : integer := 0;
	signal int_bcd_seg : integer := 0;
	
BEGIN
	
	
	int_input <= to_integer(unsigned(bin_input));
	
	IF (int_input <= 99999) THEN
	
		vector <= "00000000000000000000" & bin_input;
		
		FOR i IN 0 TO 15 LOOP
			vector sll 1;
			-- WENN MÖGLICH sollte folgender Block bis zum nächsten Kommentar noch mit einer FOR-Schleife, o. ä. zusammengefasst werden:
			int_bcd_seg <= to_integer(unsigned(vector(3 DOWNTO 0)));
			IF (int_bcd_seg >= 5) THEN
				int_bcd_seg <= int_bcd_seg + 3;
			END IF;
			vector(3 DOWNTO 0) <= std_logic_vector(to_unsigned(int_bcd_seg));
			
			int_bcd_seg <= to_integer(unsigned(vector(7 DOWNTO 4)));
			IF (int_bcd_seg >= 5) THEN
				int_bcd_seg <= int_bcd_seg + 3;
			END IF;
			vector(7 DOWNTO 4) <= std_logic_vector(to_unsigned(int_bcd_seg));
			
			int_bcd_seg <= to_integer(unsigned(vector(11 DOWNTO 8)));
			IF (int_bcd_seg >= 5) THEN
				int_bcd_seg <= int_bcd_seg + 3;
			END IF;
			vector(11 DOWNTO 8) <= std_logic_vector(to_unsigned(int_bcd_seg));
			
			int_bcd_seg <= to_integer(unsigned(vector(15 DOWNTO 12)));
			IF (int_bcd_seg >= 5) THEN
				int_bcd_seg <= int_bcd_seg + 3;
			END IF;
			vector(15 DOWNTO 12) <= std_logic_vector(to_unsigned(int_bcd_seg));
			
			int_bcd_seg <= to_integer(unsigned(vector(19 DOWNTO 16)));
			IF (int_bcd_seg >= 5) THEN
				int_bcd_seg <= int_bcd_seg + 3;
			END IF;
			vector(19 DOWNTO 16) <= std_logic_vector(to_unsigned(int_bcd_seg));
			-- Block Ende
		END LOOP;
		vector sll 1;
		
		zehntausender <= vector(3 DOWNTO 0);
		tausender <= vector(7 DOWNTO 4);
		hunderter <= vector(11 DOWNTO 8);
		zehner <= vector(15 DOWNTO 12);
		einer <= vector(19 DOWNTO 16);
		
	ELSE
	
		overflow <= '1';
	
	END IF;
	
	
END DoubleDabbleV2;






-- http://www.mikrocontroller.net/topic/90462