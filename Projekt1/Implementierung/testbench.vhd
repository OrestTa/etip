LIBRARY IEEE;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_1164.all;

ENTITY testbench IS
END ENTITY;

ARCHITECTURE BINBCD_test OF testbench IS
    SIGNAL clk: std_logic := '0';
    SIGNAL bin_input: std_logic_vector(16 DOWNTO 0) := "00000001101000100";
--  SIGNAL bin_input: std_logic_vector(16 DOWNTO 0) := "11000011010100000";
    SIGNAL einer, zehner, hunderter, tausender, zehntausender: std_logic_vector(3 DOWNTO 0);
    SIGNAL overflow: std_logic;

    COMPONENT BINBCD IS
        PORT(
            clk: IN std_logic;
            bin_input: IN std_logic_vector(16 DOWNTO 0);
            einer, zehner, hunderter, tausender, zehntausender: OUT std_logic_vector(3 DOWNTO 0);
            overflow: OUT std_logic
        );
    END COMPONENT;

BEGIN
    testbench: BINBCD PORT MAP(
        clk => clk,
        bin_input => bin_input,
        einer => einer,
        zehner => zehner,
        hunderter => hunderter,
        tausender => tausender,
        zehntausender => zehntausender,
        overflow => overflow
    );

    PROCESS
    BEGIN
--      loop through 100 clock cycles, 1s each
        FOR i IN 0 TO 169 LOOP
            clk <= '0';
            WAIT FOR 50 ms;
            clk <= '1';
            WAIT FOR 50 ms;
        END LOOP;
    END PROCESS;

END ARCHITECTURE;
