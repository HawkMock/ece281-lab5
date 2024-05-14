----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2024 07:39:48 PM
-- Design Name: 
-- Module Name: alu_rs - alu_rs_arch
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity alu_rs is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
       i_B : in STD_LOGIC_VECTOR (7 downto 0);
       o_rs : out STD_LOGIC_VECTOR (7 downto 0));
end alu_rs;

architecture alu_rs_arch of alu_rs is

begin
    o_rs <= std_logic_vector(shift_right(unsigned(i_A), to_integer(unsigned(i_B(2 downto 0)))));

end alu_rs_arch;
