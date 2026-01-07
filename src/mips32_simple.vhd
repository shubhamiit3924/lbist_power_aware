library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity mips32_simple is
    Port ( 
        clk : in STD_LOGIC;
        reset : in STD_LOGIC;
        scan_enable : in STD_LOGIC;
        scan_in : in STD_LOGIC_VECTOR (31 downto 0);
        scan_out : out STD_LOGIC_VECTOR (31 downto 0);
        pc_value : out STD_LOGIC_VECTOR (31 downto 0);
        alu_result : out STD_LOGIC_VECTOR (31 downto 0)
    );
end mips32_simple;

architecture Behavioral of mips32_simple is
    signal pc_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal instruction_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal reg_a : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal reg_b : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal alu_out_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    signal control_reg : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
    
    signal alu_a, alu_b : STD_LOGIC_VECTOR(31 downto 0);
    signal alu_op : STD_LOGIC_VECTOR(3 downto 0);
    signal next_pc : STD_LOGIC_VECTOR(31 downto 0);
    
begin
    
    process(clk, reset)
    begin
        if reset = '1' then
            pc_reg <= (others => '0');
            instruction_reg <= (others => '0');
            reg_a <= (others => '0');
            reg_b <= (others => '0');
            alu_out_reg <= (others => '0');
            control_reg <= (others => '0');
            
        elsif rising_edge(clk) then
            if scan_enable = '1' then
                -- Simple 32-bit scan chain
                pc_reg <= scan_in;
                instruction_reg <= pc_reg;
                reg_a <= instruction_reg;
                reg_b <= reg_a;
                alu_out_reg <= reg_b;
                control_reg <= alu_out_reg;
                
            else
                -- Normal operation
                pc_reg <= next_pc;
                instruction_reg <= pc_reg;
                reg_a <= pc_reg;
                reg_b <= instruction_reg;
                
                case alu_op is
                    when "0000" => alu_out_reg <= alu_a and alu_b;
                    when "0001" => alu_out_reg <= alu_a or alu_b;
                    when "0010" => alu_out_reg <= alu_a xor alu_b;
                    when "0011" => alu_out_reg <= std_logic_vector(unsigned(alu_a) + unsigned(alu_b));
                    when "0100" => alu_out_reg <= std_logic_vector(unsigned(alu_a) - unsigned(alu_b));
                    when others => alu_out_reg <= alu_a;
                end case;
                
                control_reg <= x"0000000" & alu_op;
            end if;
        end if;
    end process;
    
    alu_a <= reg_a;
    alu_b <= reg_b;
    alu_op <= instruction_reg(3 downto 0);
    next_pc <= std_logic_vector(unsigned(pc_reg) + 4);
    scan_out <= control_reg;
    pc_value <= pc_reg;
    alu_result <= alu_out_reg;

end Behavioral;