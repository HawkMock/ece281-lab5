----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/05/2024 12:10:01 PM
-- Design Name: 
-- Module Name: add_sub - Behavioral
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

entity add_sub is
    Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
           i_B : in STD_LOGIC_VECTOR (7 downto 0);
           i_alu_ctrl : in STD_LOGIC;
           o_result : out STD_LOGIC_VECTOR (7 downto 0);
           o_carry : out STD_LOGIC;
           o_overflow : out STD_LOGIC;
           o_negative : out STD_LOGIC;
           o_zero : out STD_LOGIC);
end add_sub;

architecture Behavioral of add_sub is

    component full_adder is
        port(
            i_Cin : in STD_LOGIC;
            i_A : in STD_LOGIC;
            i_B : in STD_LOGIC;
            o_sum : out STD_LOGIC;
            o_Cout : out STD_LOGIC
        );
    end component full_adder;
    
    signal f_B : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal w_Cout : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal w_result : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    
begin
    -- Ripple Adders --
    full_adder0_inst : full_adder
    port map (
        i_Cin   => i_alu_ctrl,
        i_A     => i_A(0),
        i_B     => f_B(0),
        o_sum   => w_result(0),
        o_Cout  => w_Cout(0)
    );
    full_adder1_inst : full_adder
    port map (
        i_Cin   => w_Cout(0),
        i_A     => i_A(1),
        i_B     => f_B(1),
        o_sum   => w_result(1),
        o_Cout  => w_Cout(1)
    );
    full_adder2_inst : full_adder
    port map (
        i_Cin   => w_Cout(1),
        i_A     => i_A(2),
        i_B     => f_B(2),
        o_sum   => w_result(2),
        o_Cout  => w_Cout(2)
    );
    full_adder3_inst : full_adder
    port map (
        i_Cin   => w_Cout(2),
        i_A     => i_A(3),
        i_B     => f_B(3),
        o_sum   => w_result(3),
        o_Cout  => w_Cout(3)
    );
    full_adder4_inst : full_adder
    port map (
        i_Cin   => w_Cout(3),
        i_A     => i_A(4),
        i_B     => f_B(4),
        o_sum   => w_result(4),
        o_Cout  => w_Cout(4)
    );
    full_adder5_inst : full_adder
    port map (
        i_Cin   => w_Cout(4),
        i_A     => i_A(5),
        i_B     => f_B(5),
        o_sum   => w_result(5),
        o_Cout  => w_Cout(5)
    );
    full_adder6_inst : full_adder
    port map (
        i_Cin   => w_Cout(5),
        i_A     => i_A(6),
        i_B     => f_B(6),
        o_sum   => w_result(6),
        o_Cout  => w_Cout(6)
    );
    full_adder7_inst : full_adder
    port map (
        i_Cin   => w_Cout(6),
        i_A     => i_A(7),
        i_B     => f_B(7),
        o_sum   => w_result(7),
        o_Cout  => w_Cout(7)
    );

    -- Flags and intermediate wires
    f_B <=  i_B when i_alu_ctrl = '0' else
            not(i_B) when i_alu_ctrl = '1' else
            "00000000";

    o_carry <=  '1' when w_Cout(7) = '1' else
                '0';
    o_overflow <= '1' when  (i_A(7) = f_B(7)) and (i_A(7) = not(w_result(7))) else
                  '0';
    o_negative <= w_result(7);
    o_zero <= '1' when w_result = "00000000" else '0';
    
    o_result <= w_result;

end Behavioral;
