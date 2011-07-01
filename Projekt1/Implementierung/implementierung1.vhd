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

SIGNAL overflw : std_logic := '1';									-- overflw standardmaessig auf 1
																	-- Da der Port "overflow" im Prozess nicht ausgelesen werden kann,
																	-- wird intern mit einem Signal "overflw" gearbeitet.
SIGNAL drei: unsigned(3 DOWNTO 0) := "0011";
SIGNAL counter: unsigned(4 DOWNTO 0) := "00000";					-- um nach 17 Durchläufen abzubrechen
SIGNAL linput: std_logic_vector(16 DOWNTO 0) := bin_input;
SIGNAL leiner: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lzehner: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lhunderter: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL ltausender: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lzehntausender: std_logic_vector(3 DOWNTO 0) := "0000";

BEGIN

    PROCESS(clk)
    BEGIN
        IF (clk'EVENT) AND (clk = '1') AND (counter <= 17) AND (unsigned(bin_input) <= 99999) THEN
																			-- Bei steigender Taktflanke, falls die Eingabe nicht zu gross ist,
            lzehntausender <= lzehntausender(2 DOWNTO 0)&ltausender(3);		-- shifte alle BCD-Vektoren einmal nach links...
            ltausender <= ltausender(2 DOWNTO 0)&lhunderter(3);
            lhunderter <= lhunderter(2 DOWNTO 0)&lzehner(3);
            lzehner <= lzehner(2 DOWNTO 0)&leiner(3);
            leiner <= leiner(2 DOWNTO 0)&linput(16);
            linput <= linput(15 DOWNTO 0)&'0';								-- ...und zum Schluss auch den Eingabevektor.
            counter <= counter+1;
        END IF;
        IF (clk'EVENT) AND (clk = '0') AND (counter <= 17) THEN				-- Bei fallender Taktflanke,
        IF (unsigned(bin_input) <= 99999) THEN								-- falls die Eingabe nicht zu gross ist,
            overflw <= '0';													-- setze "overflw" auf 0,
            IF (unsigned(leiner) >= 5) THEN									-- prüfe jeweils für den BCD-Vektor der Einer
                leiner <= std_logic_vector(unsigned(leiner)+drei);
            END IF;
            IF (unsigned(lzehner) >= 5) THEN								-- Zehner
                lzehner <= std_logic_vector(unsigned(lzehner)+drei);
            END IF;
            IF (unsigned(lhunderter) >= 5) THEN								-- Hunderter
                lhunderter <= std_logic_vector(unsigned(lhunderter)+drei);
            END IF;
            IF (unsigned(ltausender) >= 5) THEN								-- Tausender
                ltausender <= std_logic_vector(unsigned(ltausender)+drei);
            END IF;
            IF (unsigned(lzehntausender) >= 5) THEN							-- und Zehntausender, ob er >= 5 ist
                lzehntausender <= std_logic_vector(unsigned(lzehntausender)+drei);	-- und addiere für diesen Fall drei.
            END IF;
														-- Aktualisiere die Ausgabeports mit den Inhalten der BCD-Vektoren.
            einer <= leiner;
            zehner <= lzehner;
            hunderter <= lhunderter;
            tausender <= ltausender;
            zehntausender <= lzehntausender;
        ELSE											-- Falls die Eingabe zu gross ist,
            einer <= "0000";							-- setze alle Ausgabeports auf 0.
            zehner <= "0000";
            hunderter <= "0000";
            tausender <= "0000";
            zehntausender <= "0000";
        END IF;
        END IF;
    END PROCESS;

    overflow <= overflw;								-- Uebertrage den Inhalt des internen Signals "overflw"
														-- auf den Ausgabeport "overflow".
END DoubleDabbleV3;
