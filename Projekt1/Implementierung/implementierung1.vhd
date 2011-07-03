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

SIGNAL overflw : std_logic := '1';                                          -- "overflw" is high per default
                                                                            -- as the port "overflow" is OUT and cannot be read,
                                                                            -- we will work with the signal "overflw"
SIGNAL drei: unsigned(3 DOWNTO 0) := "0011";
SIGNAL counter: unsigned(4 DOWNTO 0) := "00000";                            -- in order to break after 17 cycles
SIGNAL linput: std_logic_vector(16 DOWNTO 0) := bin_input;                  -- v. s.
SIGNAL leiner: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lzehner: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lhunderter: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL ltausender: std_logic_vector(3 DOWNTO 0) := "0000";
SIGNAL lzehntausender: std_logic_vector(3 DOWNTO 0) := "0000";

BEGIN

    PROCESS(clk)
    BEGIN

        IF (clk'EVENT) AND (clk = '1') AND (counter <= 17) AND (unsigned(bin_input) <= 99999) THEN
                                                                            -- if rising edge and if input within domain
            lzehntausender <= lzehntausender(2 DOWNTO 0)&ltausender(3);     -- shift left all BCD-vectors
            ltausender <= ltausender(2 DOWNTO 0)&lhunderter(3);
            lhunderter <= lhunderter(2 DOWNTO 0)&lzehner(3);
            lzehner <= lzehner(2 DOWNTO 0)&leiner(3);
            leiner <= leiner(2 DOWNTO 0)&linput(16);
            linput <= linput(15 DOWNTO 0)&'0';                              -- and the input vector
            counter <= counter+1;                                           -- 17 times
        END IF;

        IF (clk'EVENT) AND (clk = '0') AND (counter <= 17) THEN             -- if falling edge
        IF (unsigned(bin_input) <= 99999) THEN                              -- if input within domain
            overflw <= '0';                                                 -- set "overflw" to 0
            IF (unsigned(leiner) >= 5) THEN                                 -- check which BCD vectors' values are equal to or bigger than 5
                leiner <= std_logic_vector(unsigned(leiner)+drei);          -- and thus need adding 3; adjust them accordingly
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
                                                                            -- update the output ports with the BCD vector signals
            einer <= leiner;
            zehner <= lzehner;
            hunderter <= lhunderter;
            tausender <= ltausender;
            zehntausender <= lzehntausender;
        ELSE                                                                -- if the input is too large
            einer <= "0000";                                                -- set the output to 0
            zehner <= "0000";                                               -- (the OF bit is 1 per default)
            hunderter <= "0000";
            tausender <= "0000";
            zehntausender <= "0000";
        END IF;
        END IF;

    END PROCESS;

    overflow <= overflw;                                                    -- update the port "overflow" with our internal signal "overflw"

END DoubleDabbleV3;
