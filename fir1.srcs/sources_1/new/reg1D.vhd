----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/23/2020 08:32:04 AM
-- Design Name: 
-- Module Name: register - Behavioral
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


-- copied from https://vhdlwhiz.com/shift-register/

entity reg1D is
  generic (
    length : integer
  );
  port (
    clk : in std_logic;
    rst : in std_logic;
    
    shift_en : in std_logic := '0';
    par_en : in std_logic := '0';
 
    shift_in : in std_logic := '0';
    par_in : in std_logic_vector(length-1 downto 0) := (others=>'0');
    
    default_state : in std_logic_vector(length-1 downto 0) := (others=>'0');
    shift_out : out std_logic;
    par_out : out std_logic_vector(length-1 downto 0)
  );
end;


architecture Behavioral of reg1D is

    signal reg_state : std_logic_vector(length-1 downto 0);

begin

    shift_out <= reg_state(reg_state'high);
    par_out <= reg_state;
    
    process (clk) begin
        if rising_edge(clk) then
            if (rst = '1') then
                reg_state <= default_state;
            elsif (shift_en = '1') then
                reg_state <= reg_state(length-2 downto 0) & shift_in;
            elsif (par_en = '1') then
                reg_state <= par_in;
            end if;
        end if;
    end process;

end Behavioral;
