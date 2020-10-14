----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2020 09:49:14 AM
-- Design Name: 
-- Module Name: FIRFilter_tb - Behavioral
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

entity FIRFilter_tb is
--  Port ( );
end FIRFilter_tb;

architecture Behavioral of FIRFilter_tb is

    signal test_clk, test_rst : std_logic;
    signal test_sig_in, test_shift_out : std_logic_vector(7 downto 0);
    signal test_sig_out : std_logic_vector(19 downto 0);

begin

    test_filter: entity work.FIRFilter
    generic map (
        LENGTH      => 15, -- number of taps
        WIDTH       => 8, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 4,  -- extra bits may be required if sum of taps causes overflow
        SIGNED_MATH => TRUE
    )
    port map (
        CLK         => test_clk,
        EN          => '1',
        RST         => test_rst,
        COEF_IN     =>  x"02" &
                        x"09" &
                        x"13" &
                        x"20" &
                        x"2C" &
                        x"36" &
                        x"3D" &
                        x"40" &
                        x"3D" &
                        x"36" &
                        x"2C" &
                        x"20" &
                        x"13" &
                        x"09" &
                        x"02" ,
                        
        SHIFT_IN    => test_sig_in,

        SHIFT_OUT   => test_shift_out,
        PAR_OUT     => open,
        MULT_OUT    => open,
        SUM_OUT     => test_sig_out
    );


    process
    begin

        -- initial
        test_rst <= '1';

        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;


        for a in -5 to 5 loop

            for b in 0 to 10 loop
            
                test_sig_in <= std_logic_vector(to_signed(b*a*2, 8));
    
              -- clock edge
              wait for 2ns;
              test_clk <= '1';
              wait for 2ns;
              test_clk <= '0';
    
            end loop;
            for b in 10 downto 0 loop
            
                test_sig_in <= std_logic_vector(to_signed(b*a*2, 8));
    
              -- clock edge
              wait for 2ns;
              test_clk <= '1';
              wait for 2ns;
              test_clk <= '0';
    
            end loop;
            
            for b in 0 to 10 loop
            
                test_sig_in <= std_logic_vector(to_signed(0, 8));
    
              -- clock edge
              wait for 2ns;
              test_clk <= '1';
              wait for 2ns;
              test_clk <= '0';
    
            end loop;

        end loop;

        for a in 0 to 255 loop
        
            test_sig_in <= (others=>'0');

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;
