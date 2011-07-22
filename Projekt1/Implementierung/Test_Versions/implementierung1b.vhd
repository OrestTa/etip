 ----
 -- This file is part of etip-ss11-g07.
 --
 -- Copyright (C) 2011 Lukas Märdian <lukasmaerdian@gmail.com>
 -- Copyright (C) 2011 M. S.
 -- Copyright (C) 2011 Orest Tarasiuk <orest@mytum.de>
 --
 -- This program is free software; you can redistribute it and/or modify
 -- it under the terms of the GNU General Public License as published by
 -- the Free Software Foundation; either version 3 of the License, or
 -- (at your option) any later version.
 --
 -- This program is distributed in the hope that it will be useful,
 -- but WITHOUT ANY WARRANTY; without even the implied warranty of
 -- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 -- GNU General Public License for more details.
 --
 -- You should have received a copy of the GNU General Public License
 -- along with this program. If not, see <http://www.gnu.org/licenses/>.
 ----

LIBRARY ieee;
USE ieee.numeric_std.all;
USE ieee.std_logic_1164.all;

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
