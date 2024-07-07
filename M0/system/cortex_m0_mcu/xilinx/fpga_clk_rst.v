//======================================================================
// Created by     : hr_li
// Filename       : fpga_clk_rst.v
// Created On     : 2018-09-20
// Last Modified  : 2019-02-19
//
// Description: fpga_clk_rst
//
// Version        Modified by        Date           Description
// 1              hr_li              2018-09-20     original
//
//======================================================================

module fpga_clk_rst(
	fpga_clk_in    ,               //50MHz
	fpga_rst_in    ,               //high valid
	
	fpga_clk_out   ,               //20MHz
	fpga_rst_out                   //low valid
);

//-------------------------------------------------------------------------------------------------------------------------------------
//  input & output
//-------------------------------------------------------------------------------------------------------------------------------------
input		fpga_clk_in       ;
input		fpga_rst_in       ;

output		fpga_clk_out      ;
output		fpga_rst_out      ;

//-------------------------------------------------------------------------------------------------------------------------------------
//  wire define
//-------------------------------------------------------------------------------------------------------------------------------------
wire		pll_fdbc_out      ;
wire        pll_fdbc_in       ;
wire        fpga_clk_in_buf   ;
wire        pll1_clkout0      ;

//-------------------------------------------------------------------------------------------------------------------------------------
//  reg define
//-------------------------------------------------------------------------------------------------------------------------------------
reg         reset1            ;
reg         reset2            ;
reg         reset3            ;

//-------------------------------------------------------------------------------------------------------------------------------------
//  rstn generate
//-------------------------------------------------------------------------------------------------------------------------------------
assign  fpga_rst_out = reset3 ;

always@(posedge fpga_clk_out or negedge fpga_rst_in) begin
    if(!fpga_rst_in) begin
        reset1 <= 1'b0;
        reset2 <= 1'b0;
        reset3 <= 1'b0;
    end
    else begin
        reset1 <= 1'b1;
        reset2 <= reset1;
        reset3 <= reset2;
    end
end

//-------------------------------------------------------------------------------------------------------------------------------------
//  buf insert
//-------------------------------------------------------------------------------------------------------------------------------------
BUFG buf_fdbc  (.I (pll_fdbc_out     ) ,.O (pll_fdbc_in      )  ) ;
BUFG buf_in    (.I (fpga_clk_in      ) ,.O (fpga_clk_in_buf  )  ) ;
BUFG buf_out   (.I (pll1_clkout0     ) ,.O (fpga_clk_out     )  ) ;

//-------------------------------------------------------------------------------------------------------------------------------------
//  MMCME2_ADV instance
//-------------------------------------------------------------------------------------------------------------------------------------

MMCME2_ADV #(
   .BANDWIDTH            ( "OPTIMIZED"   ) , // Jitter programming( HIGH, LOW, OPTIMIZED          )
   .CLKFBOUT_MULT_F      ( 20            ) , // Multiply value for all CLKOUT( 2.000-64.000          )
   .CLKFBOUT_PHASE       ( 0.0           ) , // Phase offset in degrees of CLKFB( -360.000-360.000      )
   .CLKIN1_PERIOD        ( 20            ) , // CLKIN_PERIOD: Input clock period in ns units, ps resolution( i.e. 33.333 is 30 MHz ) .//50MHz
   .CLKIN2_PERIOD        ( 0.0           ) ,
   .CLKOUT0_DIVIDE_F     ( 20            ) , // Divide amount for CLKOUT0( 1.000-128.000         )
   .CLKOUT0_DUTY_CYCLE   ( 0.5           ) , // CLKOUT0_DUTY_CYCLE - CLKOUT6_DUTY_CYCLE: Duty cycle for CLKOUT outputs( 0.001-0.999           ) .
   .CLKOUT1_DUTY_CYCLE   ( 0.5           ) ,
   .CLKOUT2_DUTY_CYCLE   ( 0.5           ) ,
   .CLKOUT3_DUTY_CYCLE   ( 0.5           ) ,
   .CLKOUT4_DUTY_CYCLE   ( 0.5           ) ,
   .CLKOUT5_DUTY_CYCLE   ( 0.5           ) ,
   .CLKOUT6_DUTY_CYCLE   ( 0.5           ) ,
   .CLKOUT0_PHASE        ( 0.0           ) , // CLKOUT0_PHASE - CLKOUT6_PHASE: Phase offset for CLKOUT outputs( -360.000-360.000      ) .
   .CLKOUT1_PHASE        ( 0.0           ) ,
   .CLKOUT2_PHASE        ( 0.0           ) ,
   .CLKOUT3_PHASE        ( 0.0           ) ,
   .CLKOUT4_PHASE        ( 0.0           ) ,
   .CLKOUT5_PHASE        ( 0.0           ) ,
   .CLKOUT6_PHASE        ( 0.0           ) ,
   .CLKOUT1_DIVIDE       ( 20            ) , // CLKOUT1_DIVIDE - CLKOUT6_DIVIDE: Divide amount for CLKOUT( 1-128               )
   .CLKOUT2_DIVIDE       ( 6             ) ,
   .CLKOUT3_DIVIDE       ( 3             ) ,
   .CLKOUT4_CASCADE      ( "FALSE"       ) ,
   .CLKOUT4_DIVIDE       ( 32            ) ,
   .CLKOUT5_DIVIDE       ( 54            ) ,
   .CLKOUT6_DIVIDE       ( 108           ) ,
   .COMPENSATION         ( "ZHOLD"        ) , // AUTO, BUF_IN, EXTERNAL, INTERNAL, ZHOLD
   .DIVCLK_DIVIDE        ( 1             ) , // Master division value( 1-106               )
   .REF_JITTER1          ( 0.010         ) , // REF_JITTER: Reference input jitter in UI( 0.000-0.999           ) .
   .REF_JITTER2          ( 0.010         ) ,
   .STARTUP_WAIT         ( "FALSE"       ) , // Delays DONE until MMCM is locked( FALSE, TRUE               )
   .SS_EN                ( "FALSE"       ) , // Spread Spectrum: Spread Spectrum Attributes Enables spread spectrum( FALSE, TRUE               )
   .SS_MODE              ( "CENTER_HIGH" ) , // CENTER_HIGH, CENTER_LOW, DOWN_HIGH, DOWN_LOW
   .SS_MOD_PERIOD        ( 10000         ) , // Spread spectrum modulation period( ns                      ) ( 4000-40000 )
   .CLKFBOUT_USE_FINE_PS ( "FALSE"       ) , // USE_FINE_PS: Fine phase shift enable( TRUE/FALSE                )
   .CLKOUT0_USE_FINE_PS  ( "FALSE"       ) ,
   .CLKOUT1_USE_FINE_PS  ( "FALSE"       ) ,
   .CLKOUT2_USE_FINE_PS  ( "FALSE"       ) ,
   .CLKOUT3_USE_FINE_PS  ( "FALSE"       ) ,
   .CLKOUT4_USE_FINE_PS  ( "FALSE"       ) ,
   .CLKOUT5_USE_FINE_PS  ( "FALSE"       ) ,
   .CLKOUT6_USE_FINE_PS  ( "FALSE"       )
)
U_PLL1(
   .CLKOUT0      ( pll1_clkout0      ) , // Clock Outputs outputs: User configurable clock outputs // 1-bit output: CLKOUT0
   .CLKOUT0B     (                   ) , // 1-bit output: Inverted CLKOUT0
   .CLKOUT1      (                   ) , // 1-bit output: Primary clock
   .CLKOUT1B     (                   ) , // 1-bit output: Inverted CLKOUT1
   .CLKOUT2      (                   ) , // 1-bit output: CLKOUT2
   .CLKOUT2B     (                   ) , // 1-bit output: Inverted CLKOUT2
   .CLKOUT3      (                   ) , // 1-bit output: CLKOUT3
   .CLKOUT3B     (                   ) , // 1-bit output: Inverted CLKOUT3
   .CLKOUT4      (                   ) , // 1-bit output: CLKOUT4
   .CLKOUT5      (                   ) , // 1-bit output: CLKOUT5
   .CLKOUT6      (                   ) , // 1-bit output: CLKOUT6
   .DO           (                   ) , // DRP Ports outputs: Dynamic reconfiguration ports                                        // 16-bit output: DRP data
   .DRDY         (                   ) , // 1-bit output: DRP ready
   .PSDONE       (                   ) , // Dynamic Phase Shift Ports outputs: Ports used for dynamic phase shifting of the outputs // 1-bit output: Phase shift done
   .CLKFBOUT     ( pll_fdbc_out      ) , // Feedback outputs: Clock feedback ports                                                  // 1-bit output: Feedback clock
   .CLKFBOUTB    (                   ) , // 1-bit output: Inverted CLKFBOUT
   .CLKFBSTOPPED (                   ) , // 1-bit output: Feedback clock stopped
   .CLKINSTOPPED (                   ) , // 1-bit output: Input clock stopped
   .LOCKED       ( pll1_locked       ) , // 1-bit output: LOCK
   .CLKIN1       ( fpga_clk_in_buf   ) , // Clock Inputs inputs: Clock inputs 1-bit input: Primary clock
   .CLKIN2       ( 1'b0              ) , // 1-bit input: Secondary clock
   .CLKINSEL     ( 1'b1              ) , // Control Ports inputs: MMCM control ports 1-bit input: Clock select, High=CLKIN1 Low=CLKIN2
   .PWRDWN       ( 1'b0              ) , // 1-bit input: Power-down
   .RST          ( ~fpga_rst_in      ) , // 1-bit input: Reset
   .DADDR        ( 7'b0              ) , // DRP Ports inputs: Dynamic reconfiguration ports                                         // 7-bit input: DRP address
   .DCLK         ( 1'b0              ) , // 1-bit input: DRP clock
   .DEN          ( 1'b0              ) , // 1-bit input: DRP enable
   .DI           ( 16'b0             ) , // 16-bit input: DRP data
   .DWE          ( 1'b0              ) , // 1-bit input: DRP write enable
   .PSCLK        ( 1'b0              ) , // Dynamic Phase Shift Ports inputs: Ports used for dynamic phase shifting of the outputs  // 1-bit input: Phase shift clock
   .PSEN         ( 1'b0              ) , // 1-bit input: Phase shift enable
   .PSINCDEC     ( 1'b0              ) , // 1-bit input: Phase shift increment/decrement
   .CLKFBIN      ( pll_fdbc_in       )   // Feedback inputs: Clock feedback ports                                                   // 1-bit input: Feedback clock
);

endmodule

