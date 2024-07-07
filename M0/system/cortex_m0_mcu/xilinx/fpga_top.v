//======================================================================
// Created by     : hr_li
// Filename       : fpga_top.v
// Created On     : 2020-05-19
// Last Modified  : 2020-05-19
//
// Description: 
//
// Version        Modified by        Date           Description
// 1              hr_li              2020-05-19     original
//
//======================================================================

module fpga_top (/*autoarg*/
   // Inouts
   SWDIOTMS,P0,P1,
   // Inputs
   fpga_rst_in, fpga_clk_in, SWCLKTCK
   );

/*autoinput*/
// Beginning of automatic inputs (from unused autoinst inputs)
input			SWCLKTCK;		// To u_cmsdk_mcu of cmsdk_mcu.v
input			fpga_clk_in;		// To u_fpga_clk_rst of fpga_clk_rst.v
input			fpga_rst_in;		// To u_fpga_clk_rst of fpga_clk_rst.v
// End of automatics

/*autooutput*/
// Beginning of automatic outputs (from unused autoinst outputs)

// End of automatics

/*autoinout*/
// Beginning of automatic inouts (from unused autoinst inouts)
inout			SWDIOTMS;		// To/From u_cmsdk_mcu of cmsdk_mcu.v
inout   [15:0]        P0;
inout   [15:0]        P1;
// End of automatics

/*autowire*/
// Beginning of automatic wires (for undeclared instantiated-module outputs)

// End of automatics


//--------------------------------------------------------------------------------------------
//  instance fpga_clk_rst
//--------------------------------------------------------------------------------------------
/*fpga_clk_rst auto_template "u_\([a-z]+[0-9]+\)" (
	.\(.*\)						(\1[]),
);*/
fpga_clk_rst  u_fpga_clk_rst (/*autoinst*/
			      // Outputs
			      .fpga_clk_out	(fpga_clk_out),	 // Templated
			      .fpga_rst_out	(fpga_rst_out),	 // Templated
			      // Inputs
			      .fpga_clk_in	(fpga_clk_in),	 // Templated
			      .fpga_rst_in	(fpga_rst_in));	 // Templated

//--------------------------------------------------------------------------------------------
//  instance cmsdk_mcu
//--------------------------------------------------------------------------------------------
/*cmsdk_mcu auto_template "u_\([a-z]+[0-9]+\)" (
	.XTAL1						(fpga_clk_out),
	.NRST						(fpga_rst_out),
	.\(.*\)						(\1[]),
);*/
cmsdk_mcu  u_cmsdk_mcu (/*autoinst*/
			// Outputs
			.XTAL2		(),		 // Templated
			.TDO		(),			 // Templated
			// Inouts
			.P0		(P0),		 // Templated
			.P1		(P1),		 // Templated
			.SWDIOTMS	(SWDIOTMS),		 // Templated
			// Inputs
			.XTAL1		(fpga_clk_out),		 // Templated
			.NRST		(fpga_rst_out),		 // Templated
			.nTRST		(0),		 // Templated
			.TDI		(0),			 // Templated
			.SWCLKTCK	(SWCLKTCK));		 // Templated

endmodule

// Local Variables:
// verilog-library-directories:("/fhome/icdata/hr_li/Music/M0_test/design/xilinx/xcku115" "/fhome/icdata/hr_li/Music/M0_test/design/verilog/mcu_top")
// verilog-auto-inst-param-value:t
// verilog-auto-output-ignore-regexp:"^.*_nc.*\|^.*pst.*"
// verilog-auto-input-ignore-regexp:"^.*nc.*\|^.*pst.*"
// End:

