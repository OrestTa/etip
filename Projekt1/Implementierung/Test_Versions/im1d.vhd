 ----
 -- This file is part of etip-ss11-g07.
 --
 -- Copyright (C) 2011 Lukas Märdian <lukasmaerdian@gmail.com>
 -- Copyright (C) 2011 M. S.
 -- Copyright (C) 2011 Orest Tarasiuk <orest.tarasiuk@tum.de>
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
-- USE ieee.std_logic_unsigned.all;

ENTITY BINBCD IS

PORT(
	clk : IN std_logic;
    bin_input : IN std_logic_vector (16 DOWNTO 0);
    einer, zehner, hunderter, tausender, zehntausender : OUT std_logic_vector (3 DOWNTO 0);
    overflow : OUT std_logic
);

END BINBCD; 



ARCHITECTURE DoubleDabbleV3 OF BINBCD IS

SIGNAL overflw : std_logic := '1';
	
	
BEGIN
	
	PROCESS(clk)
	
	VARIABLE int_input : integer := 0;
	
	BEGIN
		IF (rising_edge(clk)) THEN
		
		
			int_input := to_integer(unsigned(bin_input));
			IF (int_input <= 99999) THEN
				overflow <= '0';
				overflw <= '0';
			ELSE
				overflow <= '1';
				overflw <= '1';
				einer <= "0000";
				zehner <= "0000";
				hunderter <= "0000";
				tausender <= "0000";
				zehntausender <= "0000";
			END IF;
			
			
		END IF;
	END PROCESS;
	
	
	PROCESS(clk)
	
	VARIABLE vector: std_logic_vector(36 DOWNTO 0) := "00000000000000000000" & bin_input;
	
	BEGIN
		IF (rising_edge(clk)) AND (overflw = '0') THEN
			
			
			FOR i IN 0 TO 17 LOOP
				-- Prüfen, ob größergleich 5; falls ja, dann 3 addieren für:
				-- Zehntausender
				IF (vector(35 DOWNTO 33) = "101") OR (vector(35 DOWNTO 33) = "110") OR (vector(35 DOWNTO 33) = "111") OR (vector(36) = '1') THEN
					vector(36 DOWNTO 33) := std_logic_vector(unsigned(vector(36 DOWNTO 33)) + "0011");
				END IF;
				-- Tausender
				IF (vector(31 DOWNTO 29) = "101") OR (vector(31 DOWNTO 29) = "110") OR (vector(31 DOWNTO 29) = "111") OR (vector(32) = '1') THEN
					vector(32 DOWNTO 29) := std_logic_vector(unsigned(vector(32 DOWNTO 29)) + "0011");
				END IF;
				-- Hunderter
				IF (vector(27 DOWNTO 25) = "101") OR (vector(27 DOWNTO 25) = "110") OR (vector(27 DOWNTO 25) = "111") OR (vector(28) = '1') THEN
					vector(28 DOWNTO 25) := std_logic_vector(unsigned(vector(28 DOWNTO 25)) + "0011");
				END IF;
				-- Zehner
				IF (vector(23 DOWNTO 21) = "101") OR (vector(23 DOWNTO 21) = "110") OR (vector(23 DOWNTO 21) = "111") OR (vector(24) = '1') THEN
					vector(24 DOWNTO 21) := std_logic_vector(unsigned(vector(24 DOWNTO 21)) + "0011");
				END IF;
				-- Einer
				IF (vector(19 DOWNTO 17) = "101") OR (vector(19 DOWNTO 17) = "110") OR (vector(19 DOWNTO 17) = "111") OR (vector(20) = '1') THEN
					vector(20 DOWNTO 17) := std_logic_vector(unsigned(vector(20 DOWNTO 17)) + "0011");
				END IF;
				
				-- Shiften:
				vector := vector(35 DOWNTO 0) & '0';
				
				
			END LOOP;
			
			-- Ergebnisse in die jeweiligen Stellen schreiben
			zehntausender <= vector(36 DOWNTO 33);
			tausender <= vector(32 DOWNTO 29);
			hunderter <= vector(28 DOWNTO 25);
			zehner <= vector(24 DOWNTO 21);
			einer <= vector(20 DOWNTO 17);
			
			
		END IF;
	END PROCESS;
			
END DoubleDabbleV3;
