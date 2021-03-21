library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity ProgramSequencer is
    port(
        instruction        :   in      std_logic_vector(23 downto 0);      --Instruction
        ASTAT       :   in      std_logic_vector(6 downto 0);       --Set to 0's
        Sel         :   in      std_logic;                          --Select for 2to1 Mux
        clk         :   in      std_logic;                          --Main clk
        Load        :   in      std_logic;                          --Load for Program Counter, set to always high
        reset       :   in      std_logic;                          --Reset for Program Counter
        En          :   in      std_logic;                          --Enable for TSB
        PMA         :   inout   std_logic_vector(13 downto 0);      --PMA Bus line
        IR_CC       :   in      std_logic_vector(3 downto 0);       --Instruction Register Condition Code
        stk_overflow :  out     std_logic;                          --Overflow signal
        stk_underflow : out     std_logic                           --Underflow signal
    );
end ProgramSequencer;

architecture behav of ProgramSequencer is

    component Condition_Logic is
        port (	cond_code	: IN std_logic_vector(3 downto 0);	-- condition code from the instruction
            loop_cond	: IN std_logic_vector(3 downto 0);	-- condition for the DO Util loop
            status		: IN std_logic_vector(6 downto 0);	-- data from register ASTAT
            CE		: IN std_logic;				-- CE condition for the DO Util Loop
            full_loop_signal       	: IN std_logic_vector(17 downto 0);	-- control signal to select which condition code to check
            cond		: OUT std_logic
            );
    end component;

    component Incrementer18bit is  
        port( 
            incrementer_input : IN std_logic_vector(17 downto 0)    --Input number to Incrementer
            enable : IN std_logic   --on/off switch for Incrementer
            incrementer_output : OUT std_logic_vector(17 downto 0)     --Output number (incrementer_input + 1) from Incrementer
        );
    end component;

    component LoopComparator_14Bit is  
        port(next_instruction : in std_logic_vector(13 downto 0);
            last_instruction : in std_logic_vector(13 downto 0);
            clk : in std_logic;
            loop_flag : out std_logic
        );
    end component;

    component Mux2to1_14bit is
		Port(sel : in std_logic;    --Selector bit
			input1 : in std_logic_vector(13 downto 0);  --Input signal 1
			input2 : in std_logic_vector(13 downto 0);  --Input signal 2
			output : out std_logic_vector(13 downto 0));    --Output signal
	end component;

    component Mux3to1_14bit is
		Port(sel : in std_logic_vector(1 downto 0);    --Selector bits
			input1 : in std_logic_vector(13 downto 0);  --Input signal 1
			input2 : in std_logic_vector(13 downto 0);  --Input signal 2
            input3 : in std_logic_vector(13 downto 0);  --Input signal 3
			output : out std_logic_vector(13 downto 0));    --Output signal
	end component;

    component next_address_Selector is 
        port(Inst		: IN std_logic_vector(23 downto 0);	-- 24 bits instruction
            cond		: IN std_logic ;	                -- condition code in the instruction
            LastInst	        : IN std_logic;				-- loop_end condition from the loop comparator
            rs		: IN std_logic;
            add_sel	        : OUT std_logic_vector(1 downto 0);
            Clk 		: IN std_logic
            );
    end component;

    component Register16 is
        Port(
            clk : in STD_LOGIC;
            load : in STD_LOGIC;    --Make sure this is hard coded to be 1
            reset : in STD_LOGIC;
            input : in STD_LOGIC_VECTOR(13 downto 0);
            output : out STD_LOGIC_VECTOR(13 downto 0));
      end component;

    component Stack14Bits is  
        generic(N:integer := 14;M:integer := 4);     -- The size of the stack can be changed
        port( push,pop,reset: IN std_logic;
            data_in: IN std_logic_vector(N-1 downto 0);         
            clk : In std_logic;       
            data_out: OUT std_logic_vector(N-1 downto 0);
            --index : OUT std_logic_vector(15 downto 0);	--Do not need this
            overflow,underflow: OUT std_logic   
        );
    end component;

    component Stack18Bits is  
        generic(N:integer := 18;M:integer := 4);     -- The size of the stack can be changed
        port( 
            --Inputs
            push,pop,reset: IN std_logic;
            data_in: IN std_logic_vector(N-1 downto 0);         
            clk : In std_logic;  
            --Outputs     
            data_out: OUT std_logic_vector(N-1 downto 0);
            --index : OUT std_logic_vector(15 downto 0);  --Do not need this
            overflow,underflow: OUT std_logic   
        );
        end component;

    component Stack_Controller is
        port (	clk : in std_logic;  --Main clock
                reset : in std_logic;    --Reset switch
                PMD : in std_logic_vector(23 downto 0);     --Instruction from PMD line
                pop_stacks : in std_logic;    --Loop condition tested
                push : out std_logic_vector(1 downto 0);    --Push signals for stacks
                pop : out std_logic_vector(1 downto 0);     --Pop signals for stacks
                rs : out std_logic_vector(1 downto 0);      --Reset signals for stacks
        end component;

    component TriStateBuffer_14Bit is
        Port(enable : in std_logic;    --Enable bit
            input : in std_logic_vector(13 downto 0);  --Input signal
            output : out std_logic_vector(13 downto 0));    --Output signal
        end component;

    begin
        signal sig1 : std_logic_vector(17 downto 0);                --Loop Stack output
        signal sig2 : std_logic;                                    --Condition Logic output
        signal sig3 : std_logic;                                    --Loop Comparator output
        signal sig4, sig5 : std_logic_vector(1 downto 0);     --Signals for pop, push, reset from StackController       --Took out reset for right now
        signal sig7, sig8 : std_logic_vector(13 downto 0);          --Wires for PC Stack
        signal sig9, sig10 : std_logic_vector(1 downto 0);          --Signals for overflow and underflow from PC and Loop Stack
        signal sig11 : std_logic_vector(13 downto 0);               --2to1Mux output
        signal sig12 : std_logic_vector(13 downto 0);               --PC Register output
        signal sig13 : std_logic_vector(1 downto 0);                --Selector bits for 3to1 MUX

        stk_underflow <= sig10(0) or sig10(1);
        stk_overflow <= sig9(0) or sig9(1);

        --Stack Controller
        StackController : Stack_Controller port map(clk, reset, instruction, (sig2 & sig3), sig4, sig5, sig6);

        --PC Stuff
        PCStack : Stack14Bits port map(sig4(0), sig5(0), reset, sig7, clk, sig8, sig9(0), sig10(0));
        PCRegister : Register16 port map(clk, '1', reset, sig11, sig12);
        PCIncrement : Incrementer18bit port map(sig12, '1', sig7);


        --Loop Stuff
        LoopStack : Stack18Bits port map(sig4(1), sig5(1), reset, instruction(17 downto 0), clk, sig1, sig9(1), sig10(1));
        LoopComparator : LoopComparator_14Bit port map(sig11, sig1(17 downto 4), clk, sig3);


        --Condition Logic
        ConditionLogic : Condition_Logic port map(IR_CC, sig1(3 downto 0), ASTAT, '0', sig1, sig2);


        --Next Address Source Select
        NextAddressSourceSelect : next_address_Selector port map(instruction, sig2, sig3, reset, sig13, clk);


        --MUXs
        NextAddressMUX : Mux3to1_14bit port map(sig13, sig8, sig7, "11111111111111", sig14);
        MUX2to1 : Mux2to1_14bit port map(Sel, PMA, sig14, sig11);


        --TriStateBuffer
        TSB : TriStateBuffer_14Bit port map(En, sig14, PMA);
    
    end behav;







