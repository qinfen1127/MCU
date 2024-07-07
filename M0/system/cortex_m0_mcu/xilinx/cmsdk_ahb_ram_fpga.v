//-----------------------------------------------------------------------------
// The confidential and proprietary information contained in this file may
// only be used by a person authorised under and to the extent permitted
// by a subsisting licensing agreement from ARM Limited.
//
//            (C) COPYRIGHT 2010-2013 ARM Limited.
//                ALL RIGHTS RESERVED
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from ARM Limited.
//
//      SVN Information
//
//      Checked In          : $Date: 2013-04-10 15:27:13 +0100 (Wed, 10 Apr 2013) $
//
//      Revision            : $Revision: 243506 $
//
//      Release Information : Cortex-M System Design Kit-r1p0-00rel0
//
//-----------------------------------------------------------------------------
//-----------------------------------------------------------------------------
// Abstract : Simple AHB RAM behavioral model
//-----------------------------------------------------------------------------
module cmsdk_ahb_ram_fpga #(
  parameter AW       = 16,// Address width
  parameter filename = "none",
  parameter WS_N     = 0, // First access wait state
  parameter WS_S     = 0) // Subsequent access wait state
 (
  input  wire          HCLK,    // Clock
  input  wire          HRESETn, // Reset
  input  wire          HSEL,    // Device select
  input  wire [AW-1:0] HADDR,   // Address
  input  wire [1:0]    HTRANS,  // Transfer control
  input  wire [2:0]    HSIZE,   // Transfer size
  input  wire          HWRITE,  // Write control
  input  wire [31:0]   HWDATA,  // Write data
  input  wire          HREADY,  // Transfer phase done
  output wire          HREADYOUT, // Device ready
  output wire [31:0]   HRDATA,  // Read data output
  output wire          HRESP);   // Device response (always OKAY)

  // Internal signals
  wire          read_valid;     // Address phase read valid
  wire          write_valid;    // Address phase write valid
  reg           read_enable;    // Data phase read enable
  reg           write_enable;   // Data phase write enable
  reg    [3:0]  reg_byte_lane;  // Data phase byte lane
  reg    [3:0]  next_byte_lane; // Next state of reg_byte_lane

  reg [AW-1:0]  word_addr;      // Word aligned address
  wire [AW-1:0] nxt_word_addr;  // Word aligned address

  // Wait state control
  wire  [31:0]  nxt_waitstate_cnt;
  reg   [31:0]  reg_waitstate_cnt;
  wire          sequential_access;


  /************************************************************************
      read & write enable
  ************************************************************************/
  assign read_valid  = HSEL & HREADY & HTRANS[1] & (~HWRITE);
  assign write_valid = HSEL & HREADY & HTRANS[1] & HWRITE;

  /************************************************************************
      read & write for each byte
      next_byte_lane is the byte selection signal
      HSIZE=0 :  8bit
      HSIZE=1 : 16bit
      default : 32bit
  ************************************************************************/
  always @(read_valid or write_valid or HADDR or HSIZE)
  begin
  if (read_valid | write_valid)
    begin
    case (HSIZE)
      0 : // Byte
        begin
        case (HADDR[1:0])
          0: next_byte_lane = 4'b0001; // Byte 0
          1: next_byte_lane = 4'b0010; // Byte 1
          2: next_byte_lane = 4'b0100; // Byte 2
          3: next_byte_lane = 4'b1000; // Byte 3
          default:next_byte_lane = 4'b0000; // Address not valid
        endcase
        end
      1 : // Halfword
        begin
        if (HADDR[1])
          next_byte_lane = 4'b1100; // Upper halfword
        else
          next_byte_lane = 4'b0011; // Lower halfword
        end
      default : // Word
        next_byte_lane = 4'b1111; // Whole word
    endcase
    end
  else
    next_byte_lane = 4'b0000; // Not reading
  end

  /************************************************************************
      reg_byte_lane  :  byte selection delay
      read_enable    :  read signal delay
      write_enable   :  write signal delay
      word_addr      :  word address delay
  ************************************************************************/
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      begin
      reg_byte_lane <= 4'b0000;
      read_enable   <= 1'b0;
      write_enable  <= 1'b0;
      word_addr     <= {AW{1'b0}};
      end
    else if (HREADY)
      begin
      reg_byte_lane <= next_byte_lane;
      read_enable   <= read_valid;
      write_enable  <= write_valid;
      word_addr     <= nxt_word_addr;
      end
  end

  assign nxt_word_addr = {HADDR[AW-1:2], 2'b00};

  /************************************************************************
      Initialize ROM
      Start of main code
  ************************************************************************/

wire		ram_ena ;
wire [3:0]	byte_wt	;
wire [7:0]  rdata_out_0;    // Read Data Output byte#0
wire [7:0]  rdata_out_1;    // Read Data Output byte#1
wire [7:0]  rdata_out_2;    // Read Data Output byte#2
wire [7:0]  rdata_out_3;    // Read Data Output byte#3

assign		ram_ena  	=  write_enable | read_enable      ;
assign  	byte_wt[0]  =  write_enable & reg_byte_lane[3] ;
assign  	byte_wt[1]  =  write_enable & reg_byte_lane[2] ;
assign  	byte_wt[2]  =  write_enable & reg_byte_lane[1] ;
assign  	byte_wt[3]  =  write_enable & reg_byte_lane[0] ;

assign HRDATA    = read_enable ? {rdata_out_0, rdata_out_1, rdata_out_2,rdata_out_3} : 32'b0 ;

fpga_spram #(/*autoinstparam*/
	     // Parameters
	     .ADDR_WIDTH		(AW-2),
             .filename                  (filename),
	     .DATA_WIDTH		(32),
	     .BYTE_WIDTH		(8))
u_fpga_spram(
/*autoinst*/
	     // Outputs
	     .douta			({rdata_out_3,rdata_out_2,rdata_out_1,rdata_out_0}),
	     // Inputs
	     .clka			(HCLK),
	     .rsta_n		(HRESETn),
	     .ena			(ram_ena),
	     .addra			(word_addr[AW-1:2]),
	     .wea			(byte_wt),
	     .dina			({HWDATA[7:0],HWDATA[15:8],HWDATA[23:16],HWDATA[31:24]}));


  /************************************************************************
      write operation
  ************************************************************************/
  // Wait state control
    //  Wait state generate treat access as sequential if
    //  HTRANS = 2'b11, or access address is in the same word,
    //  or if the access is in the next word
  assign sequential_access = (HTRANS==2'b11) |
                            (HADDR[AW-1:2] == word_addr[AW-1:2]) |
                            (HADDR[AW-1:2] == (word_addr[AW-1:2]+1));
  assign nxt_waitstate_cnt = (read_valid|write_valid) ?
                             ((sequential_access) ? WS_S : WS_N) :
                             ((reg_waitstate_cnt!=0) ? (reg_waitstate_cnt - 1) : 0);
    // Register wait state counter
  always @(posedge HCLK or negedge HRESETn)
  begin
    if (~HRESETn)
      reg_waitstate_cnt <= 0;
    else
      reg_waitstate_cnt <= nxt_waitstate_cnt;
  end

  // Connect to top level
  assign HREADYOUT = (reg_waitstate_cnt==0) ? 1'b1 : 1'b0;
  assign HRESP     = 1'b0; // Always response with OKAY
  // Read data output

endmodule
