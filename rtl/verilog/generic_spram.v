//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Generic Single-Port Synchronous RAM                         ////
////                                                              ////
////  This file is part of memory library available from          ////
////  http://www.opencores.org/cvsweb.shtml/generic_memories/     ////
////                                                              ////
////  Description                                                 ////
////  This block is a wrapper with common single-port             ////
////  synchronous memory interface for different                  ////
////  types of ASIC and FPGA RAMs. Beside universal memory        ////
////  interface it also provides behavioral model of generic      ////
////  single-port synchronous RAM.                                ////
////  It should be used in all OPENCORES designs that want to be  ////
////  portable accross different target technologies and          ////
////  independent of target memory.                               ////
////                                                              ////
////  Supported ASIC RAMs are:                                    ////
////  - Artisan Single-Port Sync RAM                              ////
////  - Avant! Two-Port Sync RAM (*)                              ////
////  - Virage Single-Port Sync RAM                               ////
////  - Virtual Silicon Single-Port Sync RAM                      ////
////                                                              ////
////  Supported FPGA RAMs are:                                    ////
////  - Xilinx Virtex RAMB4_S16                                   ////
////                                                              ////
////  To Do:                                                      ////
////   - xilinx rams need external tri-state logic                ////
////   - fix avant! two-port ram                                  ////
////   - add additional RAMs (Altera etc)                         ////
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
// Revision 1.2  2001/07/30 05:38:02  lampret
// Adding empty directories required by HDL coding guidelines
//
//

`include "timescale.v"

module generic_spram(
	// Generic synchronous single-port RAM interface
	clk, rst, ce, we, oe, addr, di, do
);

//
// Default address and data buses width
//
parameter aw = 13;
parameter dw = 32;

//
// Generic synchronous single-port RAM interface
//
input			clk;	// Clock
input			rst;	// Reset
input			ce;	// Chip enable input
input			we;	// Write enable input
input			oe;	// Output enable input
input 	[aw-1:0]	addr;	// address bus inputs
input	[dw-1:0]	di;	// input data bus
output	[dw-1:0]	do;	// output data bus

//
// Internal wires and registers
//


`ifdef ARTISAN_SSP

//
// Instantiation of ASIC memory:
//
// Artisan Synchronous Single-Port RAM (ra1sh)
//
art_hssp_8192x32 #(dw, 2<<aw, aw) artisan_ssp(
	.CLK(clk),
	.CEN(~ce),
	.WEN(~we),
	.A(addr),
	.D(di),
	.OEN(~oe),
	.Q(do)
);

`else

`ifdef AVANT_ATP

//
// Instantiation of ASIC memory:
//
// Avant! Asynchronous Two-Port RAM
//
avant_atp avant_atp(
	.web(~we),
	.reb(),
	.oeb(~oe),
	.rcsb(),
	.wcsb(),
	.ra(addr),
	.wa(addr),
	.di(di),
	.do(do)
);

`else

`ifdef VIRAGE_SSP

//
// Instantiation of ASIC memory:
//
// Virage Synchronous 1-port R/W RAM
//
virage_ssp virage_ssp(
	.clk(clk),
	.adr(addr),
	.d(di),
	.we(we),
	.oe(oe),
	.me(ce),
	.q(do)
);

`else

`ifdef VIRTUALSILICON_SSP

//
// Instantiation of ASIC memory:
//
// Virtual Silicon Single-Port Synchronous SRAM
//
virtualsilicon_ssp #(2<<aw, aw-1, dw-1) virtualsilicon_ssp(
	.CK(clk),
	.ADR(addr),
	.DI(di),
	.WEN(~we),
	.CEN(~ce),
	.OEN(~oe),
	.DOUT(do)
);

`else

`ifdef XILINX_RAMB4_S16

//
// Instantiation of FPGA memory:
//
// Virtex/Spartan2
//
ramb4_s16 ramb4_s16(
	.clk(clk),
	.rst(rst),
	.addr(addr),
	.di(di),
	.en(ce),
	.we(we),
	.do(do)
);

`else

//
// Generic single-port synchronous RAM model
//

//
// Generic RAM's registers and wires
//
reg	[dw-1:0]	mem [(2<<aw)-1:0];	// RAM content
reg	[dw-1:0]	do_reg;			// RAM data output register

//
// Data output drivers
//
assign do = (oe) ? do_reg : {dw{1'bz}};

//
// RAM read and write
//
always @(posedge clk)
	if (ce && !we)
		do_reg <= #1 mem[addr];
	else if (ce && we)
		mem[addr] <= #1 di;

`endif	// !XILINX_RAMB4_S16
`endif	// !VIRTUALSILICON_SSP
`endif	// !VIRAGE_SSP
`endif  // !AVANT_ATP
`endif	// !ARTISAN_SSP

endmodule
