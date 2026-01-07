library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lbist_top is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        start_test : in STD_LOGIC;
        test_complete : out STD_LOGIC;
        final_signature : out STD_LOGIC_VECTOR(31 downto 0);
        pattern_count_out : out STD_LOGIC_VECTOR(15 downto 0);
        current_toggles : out integer range 0 to 32
    );
end lbist_top;

architecture Structural of lbist_top is
    component lfsr
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            seed : in STD_LOGIC_VECTOR (31 downto 0);
            lfsr_out : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
    
    component toggle_controller
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            lfsr_pattern : in STD_LOGIC_VECTOR (31 downto 0);
            current_pattern : in STD_LOGIC_VECTOR (31 downto 0);
            toggle_rate : in integer range 0 to 32;
            new_pattern : out STD_LOGIC_VECTOR (31 downto 0);
            actual_toggles : out integer range 0 to 32
        );
    end component;
    
    component mips32_simple
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            scan_enable : in STD_LOGIC;
            scan_in : in STD_LOGIC_VECTOR (31 downto 0);
            scan_out : out STD_LOGIC_VECTOR (31 downto 0);
            pc_value : out STD_LOGIC_VECTOR (31 downto 0);
            alu_result : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
    
    component misr
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            enable : in STD_LOGIC;
            data_in : in STD_LOGIC_VECTOR (31 downto 0);
            signature : out STD_LOGIC_VECTOR (31 downto 0)
        );
    end component;
    
    component test_controller
        Port ( 
            clk : in STD_LOGIC;
            reset : in STD_LOGIC;
            start_test : in STD_LOGIC;
            test_done : out STD_LOGIC;
            toggle_rate_setting : out integer range 0 to 32;
            scan_enable : out STD_LOGIC;
            pattern_count : out STD_LOGIC_VECTOR(15 downto 0)
        );
    end component;
    
    signal lfsr_out : STD_LOGIC_VECTOR(31 downto 0);
    signal toggle_controlled_pattern : STD_LOGIC_VECTOR(31 downto 0);
    signal scan_chain_out : STD_LOGIC_VECTOR(31 downto 0);
    signal misr_signature : STD_LOGIC_VECTOR(31 downto 0);
    signal scan_enable_sig : STD_LOGIC;
    signal test_controller_toggle_rate : integer range 0 to 32;
    signal pattern_count_sig : STD_LOGIC_VECTOR(15 downto 0);
    signal test_done_sig : STD_LOGIC;
    signal actual_toggles_sig : integer range 0 to 32;
    
    signal current_pattern_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal misr_enable : STD_LOGIC;
    
begin
    -- MISR only enabled when pattern count > 0 (after first complete scan)
    misr_enable <= '1' when (scan_enable_sig = '1' and unsigned(pattern_count_sig) > 0) else '0';
    
    lfsr_inst: lfsr 
        port map (
            clk => clk,
            reset => reset,
            enable => scan_enable_sig,
            seed => x"00000001",
            lfsr_out => lfsr_out
        );
    
    toggle_controller_inst: toggle_controller
        port map (
            clk => clk,
            reset => reset,
            enable => scan_enable_sig,
            lfsr_pattern => lfsr_out,
            current_pattern => current_pattern_reg,
            toggle_rate => test_controller_toggle_rate,
            new_pattern => toggle_controlled_pattern,
            actual_toggles => actual_toggles_sig
        );
    
    mips32_inst: mips32_simple
        port map (
            clk => clk,
            reset => reset,
            scan_enable => scan_enable_sig,
            scan_in => toggle_controlled_pattern,
            scan_out => scan_chain_out,
            pc_value => open,
            alu_result => open
        );
    
    misr_inst: misr
        port map (
            clk => clk,
            reset => reset,
            enable => misr_enable,
            data_in => scan_chain_out,
            signature => misr_signature
        );
    
    test_controller_inst: test_controller
        port map (
            clk => clk,
            reset => reset,
            start_test => start_test,
            test_done => test_done_sig,
            toggle_rate_setting => test_controller_toggle_rate,
            scan_enable => scan_enable_sig,
            pattern_count => pattern_count_sig
        );
    
    process(clk, reset)
    begin
        if reset = '1' then
            current_pattern_reg <= (others => '0');
        elsif rising_edge(clk) then
            if scan_enable_sig = '1' then
                current_pattern_reg <= toggle_controlled_pattern;
            end if;
        end if;
    end process;
    
    test_complete <= test_done_sig;
    final_signature <= misr_signature;
    pattern_count_out <= pattern_count_sig;
    current_toggles <= actual_toggles_sig;

end Structural;
