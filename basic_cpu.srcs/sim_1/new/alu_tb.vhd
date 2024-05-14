-- Test Bench Written by ChatGPT

LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;

ENTITY alu_tb IS
END alu_tb;

ARCHITECTURE behavior OF alu_tb IS 

    -- Component Declaration for the Unit Under Test (UUT)
    COMPONENT ALU
    PORT(
         i_op    : IN  std_logic_vector(2 downto 0);
         i_A     : IN  std_logic_vector(7 downto 0);
         i_B     : IN  std_logic_vector(7 downto 0);
         o_result: OUT std_logic_vector(7 downto 0);
         o_flags : OUT std_logic_vector(3 downto 0)
        );
    END COMPONENT;
    
    --Inputs
    signal i_op    : std_logic_vector(2 downto 0) := (others => '0');
    signal i_A     : std_logic_vector(7 downto 0) := (others => '0');
    signal i_B     : std_logic_vector(7 downto 0) := (others => '0');

    --Outputs
    signal o_result: std_logic_vector(7 downto 0);
    signal o_flags : std_logic_vector(3 downto 0);

BEGIN

    -- Instantiate the Unit Under Test (UUT)
    uut: ALU PORT MAP (
          i_op => i_op,
          i_A => i_A,
          i_B => i_B,
          o_result => o_result,
          o_flags => o_flags
        );

    -- Stimulus process
    stim_proc: process
    begin        
        -- Test Case 1: OR Operation
        i_op <= "000"; i_A <= "10101010"; i_B <= "01010101"; wait for 100 ns;
        i_op <= "000"; i_A <= "11110000"; i_B <= "00001111"; wait for 100 ns;
        
        -- Test Case 2: AND Operation
        i_op <= "001"; i_A <= "10101010"; i_B <= "01010101"; wait for 100 ns;
        i_op <= "001"; i_A <= "11110000"; i_B <= "00001111"; wait for 100 ns;
        
        -- Test Case 3: Right Shift
        i_op <= "010"; i_A <= "10101010"; i_B <= "00000001"; wait for 100 ns;
        i_op <= "010"; i_A <= "11110000"; i_B <= "00000010"; wait for 100 ns;
        
        -- Test Case 4: Left Shift
        i_op <= "011"; i_A <= "10101010"; i_B <= "00000001"; wait for 100 ns;
        i_op <= "011"; i_A <= "11110000"; i_B <= "00000010"; wait for 100 ns;
        
        -- Test Case 5: Addition
        i_op <= "100"; i_A <= "00000001"; i_B <= "00000001"; wait for 100 ns;
        i_op <= "100"; i_A <= "00001111"; i_B <= "00000001"; wait for 100 ns;
        
        -- Test Case 6: Subtraction
        i_op <= "101"; i_A <= "00010000"; i_B <= "00000001"; wait for 100 ns;
        i_op <= "101"; i_A <= "00100000"; i_B <= "00000010"; wait for 100 ns;

        -- Test Case 7: Add with Carry (Simulated)
        i_op <= "110"; i_A <= "11111111"; i_B <= "00000001"; wait for 100 ns;
        i_op <= "110"; i_A <= "01111111"; i_B <= "00000001"; wait for 100 ns;

        -- Test Case 8: Subtract with Borrow (Simulated)
        i_op <= "111"; i_A <= "00000010"; i_B <= "00000011"; wait for 100 ns;
        i_op <= "111"; i_A <= "00000100"; i_B <= "00000001"; wait for 100 ns;

        -- Complete Testing
        wait;
    END PROCESS;

END behavior;
