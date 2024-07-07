create_clock -period 20 -name clk_fpga -waveform {0.000 10.000} [get_ports fpga_clk_in]
create_clock -period 250 -name clk_sw  -waveform {0.000 125.000} [get_ports SWCLKTCK]
