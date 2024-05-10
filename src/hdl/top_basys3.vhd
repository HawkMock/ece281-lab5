--+----------------------------------------------------------------------------
--|
--| NAMING CONVENSIONS :
--|
--|    xb_<port name>           = off-chip bidirectional port ( _pads file )
--|    xi_<port name>           = off-chip input port         ( _pads file )
--|    xo_<port name>           = off-chip output port        ( _pads file )
--|    b_<port name>            = on-chip bidirectional port
--|    i_<port name>            = on-chip input port
--|    o_<port name>            = on-chip output port
--|    c_<signal name>          = combinatorial signal
--|    f_<signal name>          = synchronous signal
--|    ff_<signal name>         = pipeline stage (ff_, fff_, etc.)
--|    <signal name>_n          = active low signal
--|    w_<signal name>          = top level wiring signal
--|    g_<generic name>         = generic
--|    k_<constant name>        = constant
--|    v_<variable name>        = variable
--|    sm_<state machine type>  = state machine type definition
--|    s_<signal name>          = state name
--|
--|    Documentation statement: Talked extensively with C3C Culp about the theory behind writing our ALUs. C/Culp helped me determine my equation for overflow.
--|    Copy and pasted John Castello's shift statement from the Teams into my alu_ls and alu_rs.
--|    Used ChatGPT extensively for Q&A and for limited code generation: https://chat.openai.com/share/af8eb33c-5f9d-4f52-84a6-0393642cc32c
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity top_basys3 is
    port (  -- INPUTS --
            clk     :   in std_logic; -- native 100MHz FPGA clock
            sw      :   in std_logic_vector(15 downto 0);
            btnU    :   in std_logic; -- master_reset
            btnC    :   in std_logic; -- advance CPU cycle
            
            -- OUTPUTS --
            led :   out std_logic_vector(15 downto 0);
            -- 7-segment display segments (active-low cathodes)
            seg :   out std_logic_vector(6 downto 0);
            -- 7-segment display active-low enables (anodes)
            an  :   out std_logic_vector(3 downto 0)
    );
end top_basys3;

architecture top_basys3_arch of top_basys3 is 
	--\ COMPONENTS \--
	component controller_fsm is
	   Port ( i_reset : in STD_LOGIC;
               i_adv : in STD_LOGIC;
               o_cycle : out STD_LOGIC_VECTOR (3 downto 0));
	end component controller_fsm;
	
    component sevenSegDecoder is
        Port ( i_D : in STD_LOGIC_VECTOR (3 downto 0);
               o_S : out STD_LOGIC_VECTOR (6 downto 0));
    end component sevenSegDecoder;
    
    component clock_divider is
        generic ( constant k_DIV : natural := 2    ); -- How many clk cycles until slow clock toggles
                                                   -- Effectively, you divide the clk double this 
                                                   -- number (e.g., k_DIV := 2 --> clock divider of 4)
        port (     i_clk    : in std_logic;
                i_reset  : in std_logic;           -- asynchronous
                o_clk    : out std_logic           -- divided (slow) clock
        );
    end component clock_divider;
    
    component twoscomp_decimal is
        port (
            i_binary: in std_logic_vector(7 downto 0);
            o_negative: out std_logic_vector(3 downto 0);
            o_hundreds: out std_logic_vector(3 downto 0);
            o_tens: out std_logic_vector(3 downto 0);
            o_ones: out std_logic_vector(3 downto 0)
        );
    end component twoscomp_decimal;
    
    component TDM4 is 
    generic ( constant k_WIDTH : natural  := 4); -- bits in input and output
        Port ( i_clk        : in  STD_LOGIC;
               i_reset        : in  STD_LOGIC; -- asynchronous
               i_D3         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D2         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D1         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               i_D0         : in  STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_data        : out STD_LOGIC_VECTOR (k_WIDTH - 1 downto 0);
               o_sel        : out STD_LOGIC_VECTOR (3 downto 0)    -- selected data line (one-cold)
        );
    end component TDM4;
    
    component ALU is
        port (  i_op    : in STD_LOGIC_VECTOR (2 downto 0);
                i_A     : in STD_LOGIC_VECTOR (7 downto 0);
                i_B     : in STD_LOGIC_VECTOR (7 downto 0);
                o_result: out STD_LOGIC_VECTOR (7 downto 0);
                o_flags  : out STD_LOGIC_VECTOR (3 downto 0) -- N C Z V
        );
    end component ALU;
    
    component alu_register is
        Port ( i_in : in STD_LOGIC_VECTOR (7 downto 0);
               i_clk : in STD_LOGIC;
               o_out : out STD_LOGIC_VECTOR (7 downto 0));
    end component alu_register;
    
	--\ SIGNALS \--
    signal w_A, w_B, w_result, w_bin: STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    signal w_cycle, w_sign, w_hund, w_tens, w_ones, w_data, w_flags: STD_LOGIC_VECTOR (3 downto 0) := "0000";
    signal w_clk : STD_LOGIC := '0';
    
begin
	-- PORT MAPS ----------------------------------------
	controller_fsm_inst : controller_fsm
    Port map (  i_reset => btnU,
                i_adv => btnC,
                o_cycle => w_cycle
    );
    
    sevenSegDecoder_inst : sevenSegDecoder
        Port map (  i_D => w_data,
                    o_S => seg
    );
    
    clock_divider_inst : clock_divider
        generic map ( k_DIV => 125000 )
        Port map (  i_clk => clk,
                    i_reset => btnU,
                    o_clk => w_clk
    );
    
    twoscomp_decimal_inst : twoscomp_decimal
        Port map (  i_binary => w_bin,
                    o_negative => w_sign,
                    o_hundreds => w_hund,
                    o_tens => w_tens,
                    o_ones => w_ones
    );
    
    TDM4_inst : TDM4
        generic map ( k_WIDTH => 4 ) -- replace X with actual width if needed
        Port map (  i_clk => w_clk,
                    i_reset => btnU,
                    i_D3 => w_sign,
                    i_D2 => w_hund,
                    i_D1 => w_tens,
                    i_D0 => w_ones,
                    o_data => w_data,
                    o_sel => an
    );
    
    ALU_inst : ALU
        Port map (  i_op => sw(2 downto 0),
                    i_A => w_A,
                    i_B => w_B,
                    o_result => w_result,
                    o_flags => w_flags
    );
    
    alu_register_instA : alu_register
        Port map (  i_in => sw(7 downto 0),
                    i_clk => w_cycle(2),
                    o_out => w_A
    );
    
    alu_register_instB : alu_register
        Port map (  i_in => sw(7 downto 0),
                    i_clk => w_cycle(1),
                    o_out => w_B
    );
	
	-- CONCURRENT STATEMENTS ----------------------------
	-- MUX --
	w_bin <=   sw(7 downto 0) when w_cycle = "1000" else
	           sw(7 downto 0) when w_cycle = "0100" else
	           w_result when w_cycle = "0010" else x"00";
	
	-- LEDs --
	led(3 downto 0) <= w_cycle;
	led(11 downto 4) <= x"00";
	led(15 downto 12) <= w_flags when (sw(2) = '1') and (w_cycle = "0010") else "0000";
	-- Display flags when in display mode and add/sub
	
end top_basys3_arch;
