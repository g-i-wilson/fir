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

entity LOMixerBaseband_tb is
--  Port ( );
end LOMixerBaseband_tb;

architecture Behavioral of LOMixerBaseband_tb is

    signal test_clk, test_rst, test_PM_event, test_PM_sq, test_sq_wave : std_logic;
    signal test_PM_sig : std_logic_vector(7 downto 0);
    signal test_I_out, test_Q_out  : std_logic_vector(11 downto 0);
    signal test_angle, test_angle_slope  : std_logic_vector(7 downto 0);
    signal test_fir_out, test_angle_filtered, test_angle_slope_filtered : std_logic_vector(16 downto 0);
    signal test_PM_phase_event : std_logic_vector(1 downto 0);
    signal test_PM_period : std_logic_vector(3 downto 0);

begin

    PM_freq : entity work.SquareWaveGenerator
    generic map (
        WIDTH       => 12
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        ON_PERIOD       => x"03F", -- period-1
        OFF_PERIOD      => x"03F", -- period-1
        INIT_ON_PERIOD  => x"03F", -- period-1
        INIT_OFF_PERIOD => x"03F", -- period-1
        EDGE_EVENT      => test_PM_phase_event(0),
        SQUARE_WAVE     => test_PM_phase_event(1)
    );
    
    process(test_PM_phase_event)
    begin
        case test_PM_phase_event is
            when "10" => test_PM_period <= x"5";
            when "11" => test_PM_period <= x"1";
            when others => test_PM_period <= x"3";
        end case;
    end process;

    PM_carrier_freq : entity work.SquareWaveGenerator
    generic map (
        WIDTH       => 4
    )
    port map (
        CLK             => test_clk,
        EN              => '1',
        RST             => test_rst,
        ON_PERIOD       => test_PM_period,
        OFF_PERIOD      => test_PM_period,
        INIT_ON_PERIOD  => test_PM_period,
        INIT_OFF_PERIOD => test_PM_period,
        SQUARE_WAVE     => test_sq_wave
    );

    test_PM_sig <= (not test_sq_wave) & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave & test_sq_wave;

    PM_filter: entity work.FIRFilter
    generic map (
        LENGTH      => 15, -- number of taps
        WIDTH       => 8, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 1,  -- extra bits may be required if sum of taps causes overflow
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

        SHIFT_IN    => test_PM_sig,

        SHIFT_OUT   => open,
        PAR_OUT     => open,
        MULT_OUT    => open,
        SUM_OUT     => test_fir_out
    );

    I: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => 17, -- signal input path width
            SIG_OUT_WIDTH       => 12, -- signal output path width
            PHASE_90_DEG_LAG    => false
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            EN                  => '1',
            SIG_IN              => test_fir_out,

            SIG_OUT             => test_I_out
        );

    Q: entity work.LOMixerBaseband
        generic map (
            SIG_IN_WIDTH        => 17, -- signal input path width
            SIG_OUT_WIDTH       => 12, -- signal output path width
            PHASE_90_DEG_LAG    => true
        )
        port map (
            CLK                 => test_clk,
            RST                 => test_rst,
            EN                  => '1',
            SIG_IN              => test_fir_out,

            SIG_OUT             => test_Q_out
        );


    phase_angle: entity work.Angle4Bit
        port map (
            CLK         => test_clk,
            EN          => '1',
            RST         => test_rst,
    
            X_IN        => test_I_out(3 downto 0),
            Y_IN        => test_Q_out(3 downto 0),
    
            A_OUT       => test_angle,
            DIFF_OUT    => test_angle_slope
        );

    phase_angle_filter: entity work.FIRFilter
    generic map (
        LENGTH      => 15, -- number of taps
        WIDTH       => 8, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 1,  -- extra bits may be required if sum of taps causes overflow
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

        SHIFT_IN    => test_angle,

        SHIFT_OUT   => open,
        PAR_OUT     => open,
        MULT_OUT    => open,
        SUM_OUT     => test_angle_filtered
    );

    phase_angle_slope_filter: entity work.FIRFilter
    generic map (
        LENGTH      => 15, -- number of taps
        WIDTH       => 8, -- width of coef and signal path (x2 after multiplication)
        PADDING     => 1,  -- extra bits may be required if sum of taps causes overflow
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

        SHIFT_IN    => test_angle_slope,

        SHIFT_OUT   => open,
        PAR_OUT     => open,
        MULT_OUT    => open,
        SUM_OUT     => test_angle_slope_filtered
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

        test_rst <= '0';

        wait for 2ns;
        test_clk <= '1';
        wait for 2ns;
        test_clk <= '0';
        wait for 2ns;

        for a in 0 to 4095 loop

          -- clock edge
          wait for 2ns;
          test_clk <= '1';
          wait for 2ns;
          test_clk <= '0';

        end loop;

    end process;


end Behavioral;
