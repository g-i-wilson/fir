library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
library UNISIM;
use UNISIM.VComponents.all;

entity ADCQuadDemodSerial is
    generic (
        ADC_PERIOD_WIDTH        : positive := 8;
        CARRIER_PERIOD_WIDTH    : positive := 24
    );
    port (
        CLK                     : in std_logic;
        RST                     : in std_logic;

        ADC_PERIOD              : in std_logic_vector(ADC_PERIOD_WIDTH-1 downto 0);
        CARRIER_PERIOD          : in std_logic_vector(CARRIER_PERIOD_WIDTH-1 downto 0);
        UART_PERIOD             : in std_logic_vector(15 downto 0);

        CMP_IN                  : in std_logic;
        INV_OUT                 : out std_logic;

        TX                      : out std_logic
    );
end ADCQuadDemodSerial;


architecture Behavioral of ADCQuadDemodSerial is

  signal adc_out_sig        : std_logic;
  signal adc_sample_sig     : std_logic;
  signal qd_in_sample_sig   : std_logic;
  signal qd_out_sample_sig  : std_logic;
  signal filter_in_sig      : std_logic_vector(1 downto 0);
  signal filter_out_sig     : std_logic_vector(11 downto 0);
  signal phase_sig          : std_logic_vector(7 downto 0);
  signal phase_der_sig      : std_logic_vector(7 downto 0);
  signal phase_2der_sig     : std_logic_vector(7 downto 0);

begin

    ADC_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => ADC_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => '1',
        RST             => RST,
        PERIOD          => ADC_PERIOD, -- x"63" is 100MHz/1MHz-1 to hex
        INIT_PERIOD     => ADC_PERIOD,
        PULSE           => adc_sample_sig
    );

    carrier_x8_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => CARRIER_PERIOD_WIDTH
    )
    port map (
        CLK             => CLK,
        EN              => '1',
        RST             => RST,
        PERIOD          => CARRIER_PERIOD, -- x"1312CF" is 100MHz/80Hz-1 to hex
        INIT_PERIOD     => CARRIER_PERIOD,
        PULSE           => qd_in_sample_sig
    );

    qd_output_sample_rate : entity work.PulseGenerator
    generic map (
        WIDTH           => 4
    )
    port map (
        CLK             => CLK,
        EN              => qd_in_sample_sig,
        RST             => RST,
        PERIOD          => x"7",
        INIT_PERIOD     => x"7",
        PULSE           => qd_out_sample_sig
    );

    ADC: entity work.ADC1Bit
        port map (
            CLK                     => CLK,
            EN                      => adc_sample_sig,
            RST                     => RST,
            CMP_IN                  => CMP_IN,
            INV_OUT                 => INV_OUT,
            PDM_OUT                 => adc_out_sig
        );

    filter_in_sig <= (not adc_out_sig) & adc_out_sig; -- +1 for high, -1 for low

    LP_filter: entity work.FIRFilterLP63tap
        generic map (
            SIG_IN_WIDTH        => 2, -- signal input path width
            SIG_OUT_WIDTH       => 12 -- signal output path width
        )
        port map (
            CLK                 => CLK,
            RST                 => RST,
            EN_IN               => adc_sample_sig,
            EN_OUT              => qd_in_sample_sig,
            SIG_IN              => filter_in_sig,

            SIG_OUT             => filter_out_sig
        );

    QuadDemod: entity work.QuadratureDemodulator
        generic map (
            SIG_IN_WIDTH            => 12,
            SIG_OUT_WIDTH           => 8,
            IQ_AMP                  => 2
        )
        port map (
            CLK                     => CLK,
            RST                     => RST,
            EN_IN                   => qd_in_sample_sig, -- sample rate must be 8x frequency of interest
            EN_OUT                  => qd_out_sample_sig,
            SIG_IN                  => filter_out_sig,

            PHASE_FILTERED          => phase_sig,
            PHASE_DER_FILTERED      => phase_der_sig,
            PHASE_2DER              => phase_2der_sig
        );

    TX_module: entity work.SerialTx
        port map (
            -- inputs
            CLK                 => CLK,
            EN                  => '1',
            RST                 => RST,
            BIT_TIMER_PERIOD    => UART_PERIOD,
            VALID               => qd_out_sample_sig,
            DATA                => phase_sig,
            -- outputs
            READY               => open,
            TX                  => TX
        );

    ila0: entity work.ila_qd
        port map (
            CLK => CLK,
            probe0 => phase_sig,
            probe1 => phase_der_sig,
            probe2 => phase_2der_sig,
            probe3 => filter_out_sig
        );

end Behavioral;
