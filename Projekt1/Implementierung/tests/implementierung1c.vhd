LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;

ENTITY BINBCD IS

PORT(
	clk : IN std_logic;
    bin_input : IN std_logic_vector (16 DOWNTO 0);
    einer, zehner, hunderter, tausender, zehntausender : OUT std_logic_vector (3 DOWNTO 0);
    overflow : OUT std_logic
);

END BINBCD; 



ARCHITECTURE DoubleDabbleV3 OF BINBCD IS

	SIGNAL int_input : integer := 0;
	
	
BEGIN
	
	
	int_input <= to_integer(unsigned(bin_input));
	IF (int_input <= 99999) THEN
		overflow := '0';
	ELSE
		overflow := '1';
		einer := "0000";
		zehner := "0000";
		hunderter := "0000";
		tausender := "0000";
		zehntausender := "0000";
	END IF;
	
	
	PROCESS(clk)
	
	VARIABLE vector: std_logic_vector(36 DOWNTO 0) := "00000000000000000000" & bin_input;
	VARIABLE int_bcd_seg : integer := 0;
	
	BEGIN
		IF (rising_edge(clk)) AND (overflow = '0') THEN
			
			
			FOR i IN 0 TO 17 LOOP
				-- Prüfen, ob größergleich 5; falls ja, dann 3 addieren für:
				-- Zehntausender
				int_bcd_seg <= to_integer(unsigned(vector(3 DOWNTO 0)));
				IF (int_bcd_seg >= 5) THEN
					vector(3 DOWNTO 0) <= std_logic_vector(to_unsigned(int_bcd_seg + 3));
				END IF;
				-- Tausender
				int_bcd_seg <= to_integer(unsigned(vector(7 DOWNTO 4)));
				IF (int_bcd_seg >= 5) THEN
					vector(7 DOWNTO 4) <= std_logic_vector(to_unsigned(int_bcd_seg + 3));
				END IF;
				-- Hunderter
				int_bcd_seg <= to_integer(unsigned(vector(11 DOWNTO 8)));
				IF (int_bcd_seg >= 5) THEN
					vector(11 DOWNTO 8) <= std_logic_vector(to_unsigned(int_bcd_seg + 3));
				END IF;
				-- Zehner
				int_bcd_seg <= to_integer(unsigned(vector(15 DOWNTO 12)));
				IF (int_bcd_seg >= 5) THEN
					vector(15 DOWNTO 12) <= std_logic_vector(to_unsigned(int_bcd_seg + 3));
				END IF;
				-- Einer
				int_bcd_seg <= to_integer(unsigned(vector(19 DOWNTO 16)));
				IF (int_bcd_seg >= 5) THEN
					vector(19 DOWNTO 16) <= std_logic_vector(to_unsigned(int_bcd_seg + 3));
				END IF;
				
				-- Shiften:
				vector := vector(35 DOWNTO 0) & '0';
				
				
			END LOOP;
			
			-- Ergebnisse in die jeweiligen Stellen schreiben
			zehntausender <= vector(3 DOWNTO 0);
			tausender <= vector(7 DOWNTO 4);
			hunderter <= vector(11 DOWNTO 8);
			zehner <= vector(15 DOWNTO 12);
			einer <= vector(19 DOWNTO 16);
			
			
		END IF;
		
	END PROCESS;
			
END DoubleDabbleV3;
