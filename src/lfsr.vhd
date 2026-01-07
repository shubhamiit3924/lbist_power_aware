library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity lfsr is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        enable : in STD_LOGIC;
        seed : in STD_LOGIC_VECTOR (31 downto 0);
        lfsr_out : out STD_LOGIC_VECTOR (31 downto 0)
    );
end lfsr;

architecture Behavioral of lfsr is
    signal lfsr_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal feedback : STD_LOGIC;
begin
    
    feedback <= lfsr_reg(31) xor lfsr_reg(21) xor lfsr_reg(1) xor lfsr_reg(0);
    
    process(clk, reset)
    begin
        if reset = '1' then
            if unsigned(seed) = 0 then
                lfsr_reg <= "00000000000000000000000000000001";
            else
                lfsr_reg <= seed;
            end if;
        elsif rising_edge(clk) then
            if enable = '1' then
                lfsr_reg <= lfsr_reg(30 downto 0) & feedback;
            end if;
        end if;
    end process;
    
    lfsr_out <= lfsr_reg;

end Behavioral;