//////////////////////////////////////////////////////////////////////
////                                                              ////
////  WISHBONE Clock and Reset Generator                          ////
////                                                              ////
////  This file is part of the WISHBONE prefetch memory block:    ////
////  http://www.opencores.org/cvsweb.shtml/wb_prefetch_spram/    ////
////                                                              ////
////  Description                                                 ////
////  Clock and reset generator.                                  ////
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

module wb_clkrst(
	// Clk & Rst Interface
	clk_o, rst_o
);

//
// Clock and Reset Interface
//
output		clk_o;
output		rst_o;

//
// Internal registers
//
reg		clk_o;
reg		rst_o;

initial begin
	clk_o = 0;
	rst_o = 0;
	#1;
	rst_o = 1;
	#`Trst;
	rst_o = 0;
end

//
// Clock generator
//
always clk_o = #`Thper ~clk_o;

endmodule
