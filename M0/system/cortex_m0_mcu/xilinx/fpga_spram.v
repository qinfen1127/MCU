//======================================================================
// Created by     : hr_li
// Filename       : xpm_memory_spram.v
// Created On     : 2018-09-20
// Last Modified  : 2019-02-19
//
// Description: xpm_memory_spram
//
// Version        Modified by        Date           Description
// 1              hr_li              2018-09-20     original
//
//======================================================================

module fpga_spram #(
parameter filename="none",
parameter  ADDR_WIDTH  = 6    ,
parameter  DATA_WIDTH  = 32   ,
parameter  BYTE_WIDTH  = 8
)
   (/*autoarg*/
   // Outputs
   douta,
   // Inputs
   clka, rsta_n, ena, addra, wea, dina
   );

//----------------------------------------------------------------------------------------------------------
//  parameter define
//----------------------------------------------------------------------------------------------------------
localparam READ_LATEN  = 0    ;
localparam WEA_SIZE    = DATA_WIDTH/BYTE_WIDTH    ;
localparam MEMORY_SIZE = 2**ADDR_WIDTH*DATA_WIDTH ;

//----------------------------------------------------------------------------------------------------------
//  input & output
//----------------------------------------------------------------------------------------------------------
input                                   clka   ;
input                                   rsta_n ;
input                                   ena    ;
input        [ADDR_WIDTH-1:0]           addra  ;
input        [WEA_SIZE-1  :0]           wea    ;
input        [DATA_WIDTH-1:0]           dina   ;

output       [DATA_WIDTH-1:0]           douta  ;

//----------------------------------------------------------------------------------------------------------
//  xpm_memory_spram instance
//----------------------------------------------------------------------------------------------------------
   xpm_memory_spram #(
      .ADDR_WIDTH_A         (ADDR_WIDTH     ), // DECIMAL
      .AUTO_SLEEP_TIME      (0              ), // DECIMAL
      .BYTE_WRITE_WIDTH_A   (BYTE_WIDTH     ), // DECIMAL
      .ECC_MODE             ("no_ecc"       ), // String
      .MEMORY_INIT_FILE     (filename       ), // String
      .MEMORY_INIT_PARAM    ("0"            ), // String
      .MEMORY_OPTIMIZATION  ("true"         ), // String
      .MEMORY_PRIMITIVE     ("auto"         ), // String
      .MEMORY_SIZE          (MEMORY_SIZE    ), // DECIMAL
      .MESSAGE_CONTROL      (0              ), // DECIMAL
      .READ_DATA_WIDTH_A    (DATA_WIDTH     ), // DECIMAL
      .READ_LATENCY_A       (READ_LATEN     ), // DECIMAL
      .READ_RESET_VALUE_A   ("0"            ), // String
      .USE_MEM_INIT         (1              ), // DECIMAL
      .WAKEUP_TIME          ("disable_sleep"), // String
      .WRITE_DATA_WIDTH_A   (DATA_WIDTH     ), // DECIMAL
      .WRITE_MODE_A         ("write_first"  )  // String
   )
   xpm_memory_spram_inst (
      .dbiterra        (       ),// 1-bit output: Status signal to indicate double bit error occurrence
                                 // on the data output of port A.

      .douta           (douta  ),// READ_DATA_WIDTH_A-bit output: Data output for port A read operations.
      .sbiterra        (       ),// 1-bit output: Status signal to indicate single bit error occurrence
                                 // on the data output of port A.

      .addra           (addra  ),// ADDR_WIDTH_A-bit input: Address for port A write and read operations.
      .clka            (clka   ),// 1-bit input: Clock signal for port A.
      .dina            (dina   ),// WRITE_DATA_WIDTH_A-bit input: Data input for port A write operations.
      .ena             (ena    ),// 1-bit input: Memory enable signal for port A. Must be high on clock
                                 // cycles when read or write operations are initiated. Pipelined
                                 // internally.

      .injectdbiterra  (1'b0   ),// 1-bit input: Controls double bit error injection on input data when
                                 // ECC enabled (Error injection capability is not available in
                                 // "decode_only" mode).

      .injectsbiterra  (1'b0   ),// 1-bit input: Controls single bit error injection on input data when
                                 // ECC enabled (Error injection capability is not available in
                                 // "decode_only" mode).

      .regcea          (1'b1   ),// 1-bit input: Clock Enable for the last register stage on the output
                                 // data path.

      .rsta            (!rsta_n),// 1-bit input: Reset signal for the final port A output register stage.
                                 // Synchronously resets output port douta to the value specified by
                                 // parameter READ_RESET_VALUE_A.

      .sleep           (1'b0   ),// 1-bit input: sleep signal to enable the dynamic power saving feature.
      .wea             (wea    ) // WRITE_DATA_WIDTH_A-bit input: Write enable vector for port A input
                                 // data port dina. 1 bit wide when word-wide writes are used. In
                                 // byte-wide write configurations, each bit controls the writing one
                                 // byte of dina to address addra. For example, to synchronously write
                                 // only bits [15-8] of dina when WRITE_DATA_WIDTH_A is 32, wea would be
                                 // 4'b0010.
   );

endmodule

