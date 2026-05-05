----------------------------------------------------------------------------------
-- Company: United States Air Force Academy
-- Engineer: Lt Col James Trimble
-- Create Date: 01/23/2025 08:31:50 AM
-- Module Name: doodle_digits - Behavioral
-- Description: This component takes in the row, col, and a 4-bit BCD and returns the pixel value from the corresponding digit's sprite
-- Documentation Statement: Adapted from original code by C2C Payton Nunn.
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity doodle_digits is
    port (
        clk      : in  std_logic;
        en       : in  std_logic;
        row_addr : in  unsigned(3 downto 0);  -- 0 to 15
        col_addr : in  unsigned(3 downto 0);  -- 0 to 15
        digit    : in  std_logic_vector(3 downto 0);  -- 4 bit digit (0 through 9) to display.  Defaults to 0 for A through F.
        pixel    : out std_logic_vector(3 downto 0)   -- 4 bit output (0-F)  Default color palette is grayscale where 0 = Black, E = white, and F = transparent
    );
end doodle_digits;

architecture Behavioral of doodle_digits is
    subtype pixel_type is std_logic_vector(3 downto 0);
    type row_type is array(15 downto 0) of pixel_type;
    type rom_type is array(15 downto 0) of row_type;
    
    constant zero : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"c", x"7", x"7", x"C", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"F", x"C", x"1", x"0", x"0", x"1", x"8", x"d", x"F", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"F", x"4", x"0", x"0", x"0", x"0", x"0", x"1", x"8", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"F", x"B", x"0", x"0", x"c", x"c", x"9", x"1", x"0", x"0", x"7", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"F", x"5", x"0", x"4", x"F", x"F", x"F", x"d", x"7", x"0", x"0", x"a", x"F", x"F"),
        5 =>  (x"F", x"F", x"d", x"0", x"0", x"a", x"F", x"F", x"F", x"F", x"F", x"4", x"0", x"2", x"F", x"F"),
        6 =>  (x"F", x"F", x"b", x"0", x"0", x"C", x"F", x"F", x"F", x"F", x"F", x"D", x"1", x"0", x"A", x"F"),
        7 =>  (x"F", x"F", x"A", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"6", x"0", x"7", x"F"),
        8 =>  (x"F", x"F", x"A", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"a", x"0", x"4", x"F"),
        9 =>  (x"F", x"F", x"b", x"0", x"1", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"4", x"F"),
        10 =>  (x"F", x"F", x"C", x"0", x"0", x"d", x"F", x"F", x"F", x"F", x"F", x"F", x"8", x"0", x"6", x"F"),
        11 =>  (x"F", x"F", x"F", x"2", x"0", x"a", x"F", x"F", x"F", x"F", x"F", x"F", x"3", x"0", x"8", x"F"),
        12 =>  (x"F", x"F", x"F", x"4", x"0", x"4", x"F", x"F", x"F", x"F", x"F", x"6", x"0", x"0", x"D", x"F"),
        13 =>  (x"F", x"F", x"F", x"B", x"0", x"0", x"7", x"e", x"F", x"d", x"6", x"0", x"0", x"7", x"F", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"5", x"0", x"0", x"1", x"4", x"0", x"0", x"0", x"6", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"d", x"6", x"0", x"0", x"0", x"0", x"1", x"8", x"F", x"F", x"F", x"F")
    );

    constant one : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"C", x"A", x"C", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"8", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"8", x"0", x"4", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"0", x"C", x"F", x"F", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"D", x"0", x"0", x"B", x"F", x"F", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"9", x"F", x"F", x"F", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"4", x"0", x"6", x"F", x"F", x"F", x"F", x"F", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"4", x"F", x"F", x"F", x"F", x"F", x"F"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"C", x"0", x"0", x"D", x"F", x"F", x"F", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"8", x"F", x"F", x"F", x"F", x"F"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"4", x"0", x"5", x"F", x"F", x"F", x"F", x"F"),
        13 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"3", x"F", x"F", x"F", x"F", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"B", x"0", x"2", x"F", x"F", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"8", x"B", x"F", x"F", x"F", x"F", x"F")
);

    constant two : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"C", x"7", x"5", x"5", x"7", x"B", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        2 =>  (x"C", x"7", x"0", x"0", x"0", x"0", x"0", x"0", x"3", x"C", x"F", x"F", x"F", x"F", x"F", x"F"),
        3 =>  (x"6", x"0", x"1", x"6", x"A", x"b", x"6", x"0", x"0", x"7", x"F", x"F", x"F", x"F", x"F", x"F"),
        4 =>  (x"c", x"B", x"d", x"F", x"F", x"F", x"F", x"6", x"0", x"3", x"F", x"F", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"4", x"F", x"F", x"F", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"a", x"0", x"0", x"9", x"F", x"F", x"F", x"F", x"F", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"F", x"C", x"2", x"0", x"2", x"C", x"F", x"F", x"F", x"F", x"F", x"F"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"5", x"0", x"0", x"b", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"7", x"0", x"0", x"7", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"7", x"0", x"0", x"4", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        12 =>  (x"F", x"F", x"8", x"0", x"0", x"4", x"C", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        13 =>  (x"F", x"9", x"0", x"0", x"0", x"6", x"5", x"5", x"6", x"7", x"7", x"8", x"8", x"A", x"D", x"F"),
        14 =>  (x"F", x"6", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"2", x"4", x"D", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F")
);


    constant three : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"F", x"F", x"B", x"3", x"0", x"0", x"0", x"0", x"3", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"F", x"7", x"0", x"0", x"3", x"8", x"7", x"0", x"0", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"F", x"7", x"0", x"1", x"9", x"F", x"F", x"4", x"0", x"2", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"C", x"0", x"4", x"D", x"F", x"F", x"9", x"0", x"0", x"7", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"C", x"c", x"F", x"F", x"F", x"c", x"0", x"0", x"4", x"F", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"a", x"1", x"0", x"1", x"c", x"F", x"F", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"0", x"0", x"0", x"0", x"1", x"6", x"C", x"F", x"F", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"a", x"8", x"8", x"4", x"0", x"0", x"3", x"C", x"F", x"F"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"a", x"0", x"0", x"8", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"5", x"0", x"2", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"5", x"0", x"0", x"F", x"F"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"5", x"0", x"0", x"5", x"F", x"F"),
        13 =>  (x"F", x"D", x"B", x"7", x"7", x"7", x"5", x"3", x"1", x"0", x"0", x"1", x"6", x"D", x"F", x"F"),
        14 =>  (x"F", x"D", x"4", x"0", x"0", x"0", x"0", x"0", x"1", x"4", x"9", x"C", x"F", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"C", x"8", x"8", x"A", x"c", x"C", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F")
);

    constant four : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"0", x"0", x"B", x"F", x"9", x"0", x"3", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"F", x"0", x"0", x"9", x"F", x"c", x"0", x"0", x"C", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"D", x"0", x"0", x"c", x"F", x"F", x"0", x"0", x"a", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"F", x"9", x"0", x"1", x"F", x"F", x"F", x"2", x"0", x"7", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"F", x"4", x"0", x"4", x"F", x"F", x"F", x"4", x"0", x"5", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"b", x"0", x"0", x"c", x"F", x"F", x"F", x"5", x"0", x"4", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"6", x"0", x"0", x"4", x"6", x"8", x"A", x"6", x"0", x"2", x"F", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"B", x"1", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"F", x"F", x"F", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"F", x"D", x"c", x"A", x"8", x"4", x"0", x"0", x"F", x"F", x"F", x"F"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"0", x"F", x"F", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"0", x"F", x"F", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"c", x"0", x"0", x"F", x"F", x"F", x"F"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"c", x"0", x"0", x"F", x"F", x"F", x"F"),
        13 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"1", x"0", x"F", x"F", x"F", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"b", x"8", x"F", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F")
);

    constant five : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"C", x"B", x"a", x"7", x"7", x"c", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"F", x"F", x"8", x"0", x"0", x"0", x"0", x"0", x"4", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"F", x"F", x"6", x"0", x"1", x"8", x"8", x"5", x"c", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"7", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"F", x"F", x"D", x"0", x"0", x"A", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"F", x"F", x"a", x"0", x"0", x"C", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"F", x"F", x"8", x"0", x"0", x"2", x"2", x"2", x"3", x"6", x"b", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"F", x"F", x"8", x"0", x"0", x"1", x"3", x"3", x"0", x"0", x"0", x"4", x"C", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"F", x"9", x"a", x"d", x"F", x"F", x"D", x"6", x"0", x"0", x"3", x"C"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"0", x"0", x"4"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"0"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"0"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"D", x"7", x"0", x"0", x"4"),
        13 =>  (x"F", x"F", x"F", x"9", x"3", x"8", x"A", x"A", x"8", x"7", x"4", x"0", x"0", x"0", x"4", x"C"),
        14 =>  (x"F", x"F", x"F", x"4", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"2", x"4", x"A", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"C", x"A", x"a", x"8", x"8", x"8", x"A", x"C", x"F", x"F", x"F", x"F", x"F")
);

    constant six : rom_type := (
        0 =>  (x"F", x"F", x"F", x"D", x"B", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"6", x"0", x"b", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"0", x"0", x"B", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"c", x"0", x"0", x"b", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"B", x"0", x"0", x"C", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"A", x"0", x"0", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"a", x"0", x"1", x"F", x"F", x"F", x"9", x"2", x"0", x"0", x"1", x"7", x"C", x"F"),
        7 =>  (x"F", x"F", x"8", x"0", x"2", x"F", x"F", x"8", x"0", x"0", x"3", x"6", x"0", x"0", x"6", x"F"),
        8 =>  (x"F", x"F", x"8", x"0", x"2", x"F", x"F", x"2", x"0", x"7", x"F", x"F", x"8", x"0", x"1", x"F"),
        9 =>  (x"F", x"F", x"a", x"0", x"0", x"F", x"C", x"0", x"0", x"c", x"F", x"F", x"c", x"0", x"0", x"F"),
        10 =>  (x"F", x"F", x"D", x"0", x"0", x"B", x"D", x"0", x"0", x"8", x"F", x"F", x"9", x"0", x"2", x"F"),
        11 =>  (x"F", x"F", x"F", x"2", x"0", x"4", x"e", x"4", x"0", x"1", x"c", x"C", x"2", x"0", x"7", x"F"),
        12 =>  (x"F", x"F", x"F", x"8", x"0", x"0", x"b", x"C", x"2", x"0", x"0", x"2", x"0", x"1", x"d", x"F"),
        13 =>  (x"F", x"F", x"F", x"C", x"2", x"0", x"2", x"b", x"e", x"7", x"0", x"0", x"1", x"a", x"F", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"B", x"1", x"0", x"0", x"3", x"0", x"0", x"3", x"C", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"B", x"8", x"8", x"8", x"8", x"8", x"B", x"F", x"F", x"F", x"F")
);

    constant seven : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"C", x"c", x"A", x"A", x"C", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"b", x"6", x"4", x"2", x"2", x"0", x"0", x"0", x"0", x"0", x"8", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"8", x"2", x"2", x"2", x"3", x"4", x"6", x"7", x"0", x"0", x"a", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"B", x"0", x"0", x"D", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"2", x"F", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"4", x"0", x"5", x"F", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"7", x"C", x"c", x"c", x"F", x"F"),
        7 =>  (x"F", x"F", x"F", x"F", x"b", x"9", x"7", x"5", x"0", x"0", x"0", x"0", x"0", x"4", x"F", x"F"),
        8 =>  (x"F", x"c", x"3", x"0", x"0", x"0", x"0", x"0", x"0", x"0", x"7", x"a", x"d", x"F", x"F", x"F"),
        9 =>  (x"F", x"A", x"3", x"7", x"8", x"A", x"c", x"9", x"0", x"0", x"F", x"F", x"F", x"F", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"8", x"0", x"0", x"F", x"F", x"F", x"F", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"8", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"3", x"F", x"F", x"F", x"F", x"F", x"F"),
        13 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"5", x"0", x"2", x"F", x"F", x"F", x"F", x"F", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"1", x"F", x"F", x"F", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"c", x"2", x"5", x"F", x"F", x"F", x"F", x"F", x"F")
);

    constant eight : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"e", x"e", x"c", x"8", x"6", x"3", x"5", x"7", x"8", x"c", x"7", x"8", x"F", x"F"),
        2 =>  (x"F", x"F", x"D", x"3", x"0", x"0", x"0", x"1", x"1", x"0", x"0", x"0", x"0", x"0", x"D", x"F"),
        3 =>  (x"F", x"F", x"B", x"0", x"0", x"8", x"D", x"F", x"C", x"2", x"0", x"0", x"0", x"A", x"F", x"F"),
        4 =>  (x"F", x"F", x"C", x"1", x"0", x"4", x"c", x"F", x"9", x"0", x"0", x"1", x"A", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"F", x"a", x"0", x"0", x"1", x"9", x"1", x"0", x"2", x"c", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"F", x"F", x"a", x"1", x"0", x"0", x"0", x"1", x"C", x"F", x"F", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"F", x"F", x"F", x"D", x"2", x"0", x"0", x"2", x"C", x"F", x"F", x"F", x"F", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"0", x"0", x"3", x"C", x"F", x"F", x"F", x"F"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"C", x"0", x"0", x"5", x"0", x"0", x"3", x"C", x"F", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"c", x"0", x"0", x"c", x"8", x"0", x"0", x"4", x"F", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"C", x"0", x"0", x"9", x"F", x"8", x"0", x"0", x"8", x"F", x"F"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"3", x"F", x"F", x"3", x"0", x"2", x"F", x"F"),
        13 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"a", x"0", x"0", x"6", x"C", x"8", x"0", x"0", x"D", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"9", x"0", x"0", x"1", x"1", x"0", x"1", x"D", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"c", x"6", x"2", x"2", x"3", x"a", x"e", x"F")
);

    constant nine : rom_type := (
        0 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F"),
        1 =>  (x"F", x"F", x"F", x"F", x"B", x"3", x"0", x"0", x"0", x"2", x"0", x"6", x"F", x"F", x"F", x"F"),
        2 =>  (x"F", x"F", x"F", x"9", x"0", x"0", x"5", x"8", x"0", x"2", x"0", x"5", x"F", x"F", x"F", x"F"),
        3 =>  (x"F", x"F", x"A", x"0", x"0", x"9", x"F", x"F", x"F", x"3", x"0", x"5", x"F", x"F", x"F", x"F"),
        4 =>  (x"F", x"F", x"6", x"0", x"7", x"F", x"F", x"F", x"B", x"0", x"0", x"5", x"F", x"F", x"F", x"F"),
        5 =>  (x"F", x"F", x"3", x"0", x"8", x"F", x"F", x"b", x"1", x"0", x"0", x"5", x"F", x"F", x"F", x"F"),
        6 =>  (x"F", x"F", x"5", x"0", x"2", x"9", x"6", x"0", x"0", x"1", x"0", x"4", x"F", x"F", x"F", x"F"),
        7 =>  (x"F", x"F", x"D", x"3", x"0", x"0", x"0", x"1", x"8", x"9", x"0", x"3", x"F", x"F", x"F", x"F"),
        8 =>  (x"F", x"F", x"F", x"F", x"c", x"c", x"c", x"F", x"F", x"A", x"0", x"2", x"F", x"F", x"F", x"F"),
        9 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"c", x"0", x"1", x"F", x"F", x"F", x"F"),
        10 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"0", x"0", x"F", x"F", x"F", x"F"),
        11 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"2", x"0", x"b", x"F", x"F", x"F"),
        12 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"3", x"0", x"a", x"F", x"F", x"F"),
        13 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"4", x"0", x"7", x"F", x"F", x"F"),
        14 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"7", x"0", x"5", x"F", x"F", x"F"),
        15 =>  (x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"F", x"A", x"2", x"8", x"F", x"F", x"F")
);


begin

    process(clk)
    begin
        if rising_edge(clk) then
            if en = '1' then
                if digit = x"1" then
                    pixel <= one(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"2" then 
                    pixel <= two(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"3" then 
                    pixel <= three(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"4" then 
                    pixel <= four(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"5" then 
                    pixel <= five(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"6" then 
                    pixel <= six(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"7" then 
                    pixel <= seven(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"8" then 
                    pixel <= eight(to_integer(row_addr))(15-to_integer(col_addr));
                elsif digit = x"9" then 
                    pixel <= nine(to_integer(row_addr))(15-to_integer(col_addr));
                else
                    pixel <= zero(to_integer(row_addr))(15-to_integer(col_addr));
                end if;
            end if;
        end if;
    end process;

end Behavioral;