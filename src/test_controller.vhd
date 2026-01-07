library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity test_controller is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        start_test : in STD_LOGIC;
        test_done : out STD_LOGIC;
        toggle_rate_setting : out integer range 0 to 32;
        scan_enable : out STD_LOGIC;
        pattern_count : out STD_LOGIC_VECTOR(15 downto 0)
    );
end test_controller;

architecture Behavioral of test_controller is
    type test_state_type is (IDLE, SCAN_SHIFT, TEST_RUN, COMPLETE);
    signal current_state : test_state_type := IDLE;
    
    signal pattern_counter : unsigned(15 downto 0) := (others => '0');
    signal shift_counter : unsigned(4 downto 0) := (others => '0');
    constant TOTAL_PATTERNS : integer := 100;
    constant SCAN_LENGTH : integer := 6;
    
begin
    
    test_control_process : process(clk, reset)
    begin
        if reset = '1' then
            current_state <= IDLE;
            pattern_counter <= (others => '0');
            shift_counter <= (others => '0');
            test_done <= '0';
            scan_enable <= '0';
            toggle_rate_setting <= 16;
            
        elsif rising_edge(clk) then
            case current_state is
                when IDLE =>
                    test_done <= '0';
                    pattern_counter <= (others => '0');
                    scan_enable <= '0';
                    if start_test = '1' then
                        current_state <= SCAN_SHIFT;
                        scan_enable <= '1';
                        shift_counter <= (others => '0');
                    end if;
                    
                when SCAN_SHIFT =>
                    if shift_counter < SCAN_LENGTH - 1 then
                        shift_counter <= shift_counter + 1;
                    else
                        current_state <= TEST_RUN;
                        scan_enable <= '0';
                        shift_counter <= (others => '0');
                    end if;
                    
                when TEST_RUN =>
                    pattern_counter <= pattern_counter + 1;
                    
                    if pattern_counter < 25 then
                        toggle_rate_setting <= 32;
                    elsif pattern_counter < 50 then
                        toggle_rate_setting <= 16;
                    elsif pattern_counter < 75 then
                        toggle_rate_setting <= 8;
                    else
                        toggle_rate_setting <= 4;
                    end if;
                    
                    if pattern_counter >= TOTAL_PATTERNS - 1 then
                        current_state <= COMPLETE;
                        test_done <= '1';
                    else
                        current_state <= SCAN_SHIFT;
                        scan_enable <= '1';
                        shift_counter <= (others => '0');
                    end if;
                    
                when COMPLETE =>
                    test_done <= '1';
                    if start_test = '0' then
                        current_state <= IDLE;
                        test_done <= '0';
                    end if;
                    
            end case;
        end if;
    end process;
    
    pattern_count <= std_logic_vector(pattern_counter);

end Behavioral;