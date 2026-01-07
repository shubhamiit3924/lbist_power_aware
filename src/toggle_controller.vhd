library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity toggle_controller is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        lfsr_pattern : in STD_LOGIC_VECTOR (31 downto 0);
        current_pattern : in STD_LOGIC_VECTOR (31 downto 0);
        toggle_rate : in integer range 0 to 32;  -- Number of toggles desired
        new_pattern : out STD_LOGIC_VECTOR (31 downto 0);
        actual_toggles : out integer range 0 to 32
    );
end toggle_controller;

architecture Behavioral of toggle_controller is
    
    -- Function to count number of '1's in a vector
    function count_ones(vec : STD_LOGIC_VECTOR) return integer is
        variable count : integer := 0;
    begin
        for i in vec'range loop
            if vec(i) = '1' then
                count := count + 1;
            end if;
        end loop;
        return count;
    end function count_ones;
    
    -- SIMPLIFIED and RELIABLE function for toggle selection
    function select_n_toggles_simple(potential_toggles : STD_LOGIC_VECTOR; 
                                    n : integer) return STD_LOGIC_VECTOR is
        variable result : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
        variable count : integer := 0;
    begin
        -- Phase 1: Select first N natural toggle positions
        for i in 0 to 31 loop
            if potential_toggles(i) = '1' and count < n then
                result(i) := '1';
                count := count + 1;
            end if;
        end loop;
        
        -- Phase 2: If needed, force additional toggles from LSB to MSB
        if count < n then
            for i in 0 to 31 loop
                if result(i) = '0' and count < n then
                    result(i) := '1';
                    count := count + 1;
                end if;
            end loop;
        end if;
        
        return result;
    end function select_n_toggles_simple;
    
    signal toggle_mask : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
begin
    
    -- Toggle Control Process
    process(clk, reset)
        variable potential_toggles : STD_LOGIC_VECTOR(31 downto 0);
    begin
        if reset = '1' then
            toggle_mask <= (others => '0');
            new_pattern <= current_pattern;
            actual_toggles <= 0;
            
        elsif rising_edge(clk) then
            if enable = '1' then
                -- Step 1: Find positions that would change with LFSR pattern
                potential_toggles := lfsr_pattern xor current_pattern;
                
                -- Step 2: Generate toggle mask with exact toggle_count
                if toggle_rate = 0 then
                    toggle_mask <= (others => '0');  -- No toggles
                elsif toggle_rate = 32 then
                    toggle_mask <= (others => '1');  -- All toggles
                else
                    toggle_mask <= select_n_toggles_simple(potential_toggles, toggle_rate);
                end if;
                
                -- Step 3: Apply toggle mask to generate new pattern
                new_pattern <= current_pattern xor toggle_mask;
                
                -- Step 4: Report actual number of toggles
                actual_toggles <= count_ones(toggle_mask);
                
            else
                -- When disabled, pass through current pattern unchanged
                new_pattern <= current_pattern;
                actual_toggles <= 0;
            end if;
        end if;
    end process;

end Behavioral;