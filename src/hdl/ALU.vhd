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
--+----------------------------------------------------------------------------
--|
--| ALU OPCODES:
--|
--|     
--|
--|
--|
--|
--+----------------------------------------------------------------------------
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;


entity ALU is
    port (  i_op    : in STD_LOGIC_VECTOR (2 downto 0);
            i_A     : in STD_LOGIC_VECTOR (7 downto 0);
            i_B     : in STD_LOGIC_VECTOR (7 downto 0);
            o_result: out STD_LOGIC_VECTOR (7 downto 0);
            o_flags  : out STD_LOGIC_VECTOR (3 downto 0) -- N C Z V
    );
end ALU;

architecture behavioral of ALU is 
    -- declare components
    component alu_or is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               o_or : out STD_LOGIC_VECTOR (7 downto 0));
    end component alu_or;
    component alu_and is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               o_and : out STD_LOGIC_VECTOR (7 downto 0));
    end component alu_and;
    component alu_ls is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               o_ls : out STD_LOGIC_VECTOR (7 downto 0));
    end component alu_ls;
    component alu_rs is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               o_rs : out STD_LOGIC_VECTOR (7 downto 0));
    end component alu_rs;
    component add_sub is
        Port ( i_A : in STD_LOGIC_VECTOR (7 downto 0);
               i_B : in STD_LOGIC_VECTOR (7 downto 0);
               i_alu_ctrl : in STD_LOGIC;
               o_result : out STD_LOGIC_VECTOR (7 downto 0);
               o_carry : out STD_LOGIC;
               o_overflow : out STD_LOGIC;
               o_negative : out STD_LOGIC;
               o_zero : out STD_LOGIC);
    end component add_sub;
  
	-- declare signals
    signal w_or, w_and, w_rs, w_ls, w_sum, w_mux1, w_result : STD_LOGIC_VECTOR (7 downto 0) := "00000000";
    -- signal w_flags : STD_LOGIC_VECTOR (3 downto 0) := "0000";
  
begin
    -- COMPONENTS ---------------------------------------
    -- OR --
    alu_or_inst : alu_or
    port map (  i_A => i_A,
                i_B => i_B,
                o_or => w_or
    );
    -- AND --
    alu_and_inst : alu_and
    port map (  i_A => i_A,
                i_B => i_B,
                o_and => w_and
    );
    -- Lshift --
    alu_ls_inst : alu_ls
    port map (  i_A => i_A,
                i_B => i_B,
                o_ls => w_ls
    );
    -- Rshift --
    alu_rs_inst : alu_rs
    port map (  i_A => i_A,
                i_B => i_B,
                o_rs => w_rs
    );
    -- ADD/SUB --
    alu_add_sub_inst : add_sub
    port map (  i_A => i_A,
                i_B => i_B,
                i_alu_ctrl(0) => i_op(0),
                i_alu_ctrl(1) => i_op(2),
                o_result => w_sum,
                o_carry => o_flags(1),
                o_overflow => o_flags(0),
                o_negative => o_flags(3),
                o_zero => o_flags(2)
    );
    
	-- CONCURRENT STATEMENTS ----------------------------
    -- MUX 1 --
    w_mux1 <=    w_or when i_op(1 downto 0) = "00" else
                 w_and when i_op(1 downto 0) = "01" else
                 w_rs when i_op(1 downto 0) = "10" else
                 w_ls when i_op(1 downto 0) = "11" else
                 "00000000";
    
    
    -- MUX 2 --
    o_result <=  w_mux1 when i_op(2) = '0' else
                 w_sum when i_op(2) = '1' else
                 "00000000";
	
	
	
end behavioral;
