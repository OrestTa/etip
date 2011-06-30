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

SIGNAL overflw : std_logic := '1';
SIGNAL drei: unsigned(3 DOWNTO 0) := "0011";
SIGNAL counter: unsigned(4 DOWNTO 0) := "00000";
SIGNAL linput: std_logic_vector(16 DOWNTO 0) := bin_input;
SIGNAL leiner: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lzehner: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lhunderter: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL ltausender: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lzehntausender: std_logic_vector(3 DOWNTO 0) := "0000";

BEGIN

    PROCESS(clk)
    BEGIN
        IF (clk'EVENT) AND (clk = '1') AND (counter <= 17) THEN
            lzehntausender <= lzehntausender(2 DOWNTO 0)&ltausender(3);
            ltausender <= ltausender(2 DOWNTO 0)&lhunderter(3);
            lhunderter <= lhunderter(2 DOWNTO 0)&lzehner(3);
            lzehner <= lzehner(2 DOWNTO 0)&leiner(3);
            leiner <= leiner(2 DOWNTO 0)&linput(16);
            linput <= linput(15 DOWNTO 0)&'0';
            counter <= counter+1;
        END IF;
        IF (clk'EVENT) AND (clk = '0') AND (counter <= 17) THEN
        IF (unsigned(bin_input) <= 99999) THEN
            overflw <= '0';
            -- Einer
            IF (unsigned(leiner) >= 5) THEN
                leiner <= std_logic_vector(unsigned(leiner)+drei);
            END IF;
            IF (unsigned(lzehner) >= 5) THEN
                lzehner <= std_logic_vector(unsigned(lzehner)+drei);
            END IF;
            IF (unsigned(lhunderter) >= 5) THEN
                lhunderter <= std_logic_vector(unsigned(lhunderter)+drei);
            END IF;
            IF (unsigned(ltausender) >= 5) THEN
                ltausender <= std_logic_vector(unsigned(ltausender)+drei);
            END IF;
            IF (unsigned(lzehntausender) >= 5) THEN
                lzehntausender <= std_logic_vector(unsigned(lzehntausender)+drei);
            END IF;
            einer <= leiner;
            zehner <= lzehner;
            hunderter <= lhunderter;
            tausender <= ltausender;
            zehntausender <= lzehntausender;
        ELSE
            overflw <= '1';
            einer <= "0000";
            zehner <= "0000";
            hunderter <= "0000";
            tausender <= "0000";
            zehntausender <= "0000";
        END IF;
        END IF;
    END PROCESS;

    overflow <= overflw;

END DoubleDabbleV3;
