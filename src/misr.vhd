library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity misr is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        data_in : in STD_LOGIC_VECTOR (31 downto 0);
        signature : out STD_LOGIC_VECTOR (31 downto 0)
    );
end misr;

architecture Behavioral of misr is
    signal misr_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal feedback : STD_LOGIC;
    
begin
    feedback <= misr_reg(31) xor misr_reg(27) xor misr_reg(26) xor misr_reg(0);
    
    process(clk, reset)
    begin
        if reset = '1' then
            misr_reg <= (others => '0');
        elsif rising_edge(clk) then
            if enable = '1' then
                -- CORRECTED: Single assignment with shift + XOR
                misr_reg <= (misr_reg(30 downto 0) & feedback) xor data_in;
            end if;
        end if;
    end process;
    
    signature <= misr_reg;

end Behavioral;