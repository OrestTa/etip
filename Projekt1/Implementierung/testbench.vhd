 ----
 -- This file is part of etip-ss11-g07.
 --
 -- Copyright (C) 2011 Lukas Märdian <lukasmaerdian@gmail.com>
 -- Copyright (C) 2011 M. S.
<<<<<<< HEAD
 -- Copyright (C) 2011 Orest Tarasiuk <orest.tarasiuk@tum.de>
=======
 -- Copyright (C) 2011 Orest Tarasiuk <orest@mytum.de>
>>>>>>> 6fedb0363ec5a4d71a7250336c06b8d195fb2baa
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

LIBRARY IEEE;
USE IEEE.numeric_std.all;
USE IEEE.std_logic_1164.all;

ENTITY testbench IS
END ENTITY;

ARCHITECTURE BINBCD_test OF testbench IS
    SIGNAL clk: std_logic := '0';
    SIGNAL bin_input: std_logic_vector(16 DOWNTO 0) := "00000001101000100";     -- 00836
--  SIGNAL bin_input: std_logic_vector(16 DOWNTO 0) := "11000011010011111";     -- 99999
--  SIGNAL bin_input: std_logic_vector(16 DOWNTO 0) := "11000011010100000";     -- 100000 (too large)
--  SIGNAL bin_input: std_logic_vector(16 DOWNTO 0) := "11111111111111111";     -- 131072 (too large)
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
 -- loop through 200 clock cycles, lasting 0.1 s each -> 20 s
 -- the result should be available after ca 1.7 s
        FOR i IN 0 TO 199 LOOP
            clk <= '0';
            WAIT FOR 50 ms;
            clk <= '1';
            WAIT FOR 50 ms;
        END LOOP;
    END PROCESS;

END ARCHITECTURE;
