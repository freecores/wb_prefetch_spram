//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Test Bench Definitions                                      ////
////                                                              ////
////  This file is part of the WISHBONE prefetch memory block:    ////
////  http://www.opencores.org/cvsweb.shtml/wb_prefetch_spram/    ////
////                                                              ////
////  Description                                                 ////
////  Test bench definitions.                                     ////
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
// Revision 1.2  2001/07/30 05:38:02  lampret
// Adding empty directories required by HDL coding guidelines
//
//

//
// Half of clock period
//
`define Thper 5

//
// Reset time
//
`define Trst (`Thper*2+1)

//
// Number of words in RAM
//
`define RAM_ADDRWIDTH 12
`define RAM_WORDS (2<<`RAM_ADDRWIDTH)

//
// RAM data width 
//
`define RAM_DATAWIDTH 32

//
// Define to get VCD output
//
`define VCD_DUMP
