----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 05/06/2024 11:30:06 PM
-- Design Name: 
-- Module Name: controller_fsm - controller_fsm_arch
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

entity controller_fsm is
    Port ( i_reset : in STD_LOGIC;
           i_adv : in STD_LOGIC;
           o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
end controller_fsm;

architecture controller_fsm_arch of controller_fsm is

    type s_state is (s_loadA, s_loadB, s_operate, s_clear);
    signal f_Q, f_Q_next: s_state := s_loadA;

begin
    
    adv_proc : process(i_adv, i_reset)
    begin
        if rising_edge(i_adv) then
            f_Q <= f_Q_next;
        end if;
    end process adv_proc;

    f_Q_next <= s_loadA when f_Q = s_clear else
                s_loadB when f_Q = s_loadA else
                s_operate when f_Q = s_loadB else
                s_clear;
    
    with f_Q select
        o_cycle <=
            "1000" when s_loadA,
            "0100" when s_loadB,
            "0010" when s_operate,
            "0001" when others;
            
end controller_fsm_arch;
