//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE Prefetch Single-Port RAM Top Level Test Bench      ////
////                                                              ////
////  This file is part of the WISHBONE prefetch memory block:    ////
////  http://www.opencores.org/cvsweb.shtml/wb_prefetch_spram/    ////
////                                                              ////
////  Description                                                 ////
////  Top level test bench.                                       ////
////                                                              ////
////  To Do:                                                      ////
////   Nothing                                                    ////
////                                                              ////
////  Author(s):                                                  ////
////      - Damjan Lampret, lampret@opencores.org                 ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2000 Authors and OPENCORES.ORG                 ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
//
// CVS Revision History
//
// $Log: not supported by cvs2svn $
//

`include "timescale.v"

module tb_top;

//
// Width of address and data buses
//
parameter aw = `RAM_ADDRWIDTH;
parameter dw = 16;

//
// Internal wires
//
wire			clk;
wire			rst;
wire			cyc;
wire	[aw-1:0]	adr;
wire	[dw-1:0]	dat_prefetch;
wire	[dw-1:0]	dat_bfm;
wire	[3:0]		sel;
wire			we;
wire			stb;
wire			ack;
wire			err;

//
// WISHBONE Prefetch single-port SRAM block
//
wb_prefetch_spram #(aw, dw) wb_prefetch_spram(
	// WISHBONE Interface
	.clk_i(clk),
	.rst_i(rst),
	.cyc_i(cyc),
	.adr_i(adr),
	.dat_i(dat_prefetch),
	.sel_i(sel),
	.we_i(we),
	.stb_i(stb),
	.dat_o(dat_bfm),
	.ack_o(ack),
	.err_o(err)
);

//
// WISHBONE Bus Functional Model
//
wb_master #(aw, dw) wb_master(
	// WISHBONE Interface
	.CLK_I(clk),
	.RST_I(rst),
	.TAG_I(4'b0000),
	.TAG_O(),
	.CYC_O(cyc),
	.ADR_O(adr),
	.DAT_O(dat_prefetch),
	.SEL_O(sel),
	.WE_O(we),
	.STB_O(stb),
	.DAT_I(dat_bfm),
	.ACK_I(ack),
	.ERR_I(err),
	.RTY_I(1'b0)
);

//
// WISHBONE Clock & Reset Generator
//
wb_clkrst wb_clkrst(
	// Clk & Rst Interface
	.clk_o(clk),
	.rst_o(rst)
);

endmodule
