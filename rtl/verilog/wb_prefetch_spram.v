//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE Prefetch Single-Port RAM                           ////
////                                                              ////
////  This file is part of the WISHBONE prefetch memory block:    ////
////  http://www.opencores.org/cvsweb.shtml/wb_prefetch_spram/    ////
////                                                              ////
////  Description                                                 ////
////  WISHBONE prefetching single-port RAM.                       ////
////  This block uses special prefetching technique to reduce     ////
////  latency and increase bandwidth when reading internal        ////
////  single-port synchronous memory with sequential bursts.      ////
////  Compared to asynchronous memories this block uses           ////
////  synchronous memory and thus meets timing much easier.       ////
////  Compared to reading sync memory w/o prefetching this block  ////
////  has the same clock->q data output timing as w/o prefetch.   ////
////                                                              ////
////  Latency/bandwidth for 4-beat WISHBONE read block transfer:  ////
////  - async memory: 4 clock cycles                              ////
////  - sync memory w/o prefetching: 8 clock cycles               ////
////  - sync memory w/ prefetching: 4+1 clock cycles              ////
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

//
// Bits in address that are incremented in a burst.
//
// Example for default of 1:0 can be:
// 2,3,0,1
//
`define BURST_BITS 1:0
`define FIXED_LOW_BIT 2

//
// Define this to check for strict 32-bit access
//
`define STRICT_32BIT_ACCESS

module wb_prefetch_spram(
	// WISHBONE Interface
	clk_i, rst_i, cyc_i, adr_i, dat_i, sel_i, we_i, stb_i,
	dat_o, ack_o, err_o
);

//
// Default width of address and data buses
//
parameter aw = 12;
parameter dw = 32;

//
// WISHBONE Interface
//
input			clk_i;	// Clock
input			rst_i;	// Reset
input			cyc_i;	// cycle valid input
input 	[aw-1:0]	adr_i;	// address bus inputs
input	[dw-1:0]	dat_i;	// input data bus
input	[3:0]		sel_i;	// byte select inputs
input			we_i;	// indicates write transfer
input			stb_i;	// strobe input
output	[dw-1:0]	dat_o;	// output data bus
output			ack_o;	// normal termination
output			err_o;	// termination w/ error

//
// Internal wires and registers
//
wire	[aw-1:0]	predicted_addr;	// Predicted address
wire	[aw-1:0]	ram_addr;	// Address used to address RAM block
wire			correct_data;	// Current RAM output data is valid
reg	[aw-1:0]	last_addr;	// Saved ram_addr
wire			valid_cycle;	// Valid WISHBONE cycle

//
// Combinatorial logic
//

//
// If STRICT_32BIT_ACCESS is defined, assert err_o when access is
// not completely 32-bit.
//
`ifdef STRICT_32BIT_ACCESS
assign err_o = valid_cycle & (sel_i != 4'b1111);
`else
assign err_o = 1'b0;
`endif

//
// Valid WSIHBONE cycles when both cyc_i and stb_i are assrted
//
assign valid_cycle = cyc_i & stb_i;

//
// Generate prefetch address by using address from the last RAM access and
// incrementing burst part of the address
//
assign predicted_addr = { last_addr[aw-1:`FIXED_LOW_BIT], last_addr[`BURST_BITS] + 1'b1 };

//
// Address RAM with WISHBONE address if last RAM access was mispredicted
// or if current WISHBONE access is write
//
assign ram_addr = (~correct_data | we_i) ? adr_i : predicted_addr;

//
// RAM's current output data is the same as data request by WISHBONE master
//
assign correct_data = (adr_i == last_addr);
assign ack_o = correct_data & valid_cycle;

//
// Address used to address RAM at the last WISHBONE read beat
//
always @(posedge clk_i or posedge rst_i)
	if (rst_i)
		last_addr <= #1 {aw{1'b0}};
	else if (valid_cycle)
		last_addr <= #1 ram_addr;

//
// Instantiation of single-port synchronous RAM
//
generic_spram #(aw, dw) spram (
	.clk(clk_i),
	.rst(rst_i),
	.addr(ram_addr),
	.di(dat_i),
	.ce(valid_cycle),
	.we(we_i),
	.oe(valid_cycle),
	.do(dat_o)
);

endmodule
