//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Test Tasks for WISHBONE Prefetching Single-Port RAM         ////
////                                                              ////
////  This file is part of the WISHBONE prefetch memory block:    ////
////  http://www.opencores.org/cvsweb.shtml/wb_prefetch_spram/    ////
////                                                              ////
////  Description                                                 ////
////  First half of the RAM is initialized with random data       ////
////  and then it is copied to second half of the RAM. During     ////
////  copy random delays are inserted.                            ////
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

`include "timescale.v"

module tb_tasks;

integer			errors;

//
// Tests description
//
task describe_test;
begin
	$display;
	$display(" Verification of the WISHBONE Prefetch Single-Port Synchronous RAM");
	$display;
	$display(" Abbrev:");
	$display(" w    single write transfer");
	$display(" r    single read transfer");
	$display(" Brr  block read transfer with two reads");
	$display(" Bww  block write transfer with two writes");
	$display(" .    inserted clock cycle delay");
	$display;
	$display(" I. One half of the RAM is preinitialized with random data. RAM is ");
	$display(" written using WISHBONE single writes.");
	$display;
	$display(" II. After that main part of the test is performed. Preinitialized ");
	$display(" half of the RAM is read with randomly long WISHBONE block reads. ");
	$display(" Between each beat of a block read zero or random number of clock ");
	$display(" cycles are inserted.");
	$display(" Each block of data is then written into second half of the RAM. ");
	$display(" Data is written using WISHBONE block writes with randomly inserted ");
	$display(" clock cycle delays between two writes.");
	$display(" ");
	$display(" III. To verify correct operation of prefetch logic, both halfs of ");
	$display(" prefetching RAM are compared. To pass the test they must match.");
	$display(" ");
	$display(" Total RAM size: %d words by 32 bits", `RAM_WORDS);
end
endtask

//
// Init 1st half of RAM
//
task init_1sthalf;
reg	[31:0]		addr;
reg	[31:0]		data;
begin
	$display;
	$display("I. Initializing 1st half of the RAM: ");
	for (addr = 0; addr < `RAM_WORDS/2; addr = addr + 1) begin
		$write("w");
//		data = $random;
		data = addr;
		tb_top.wb_master.wr(addr, data, 4'b1111);
	end
	$display(" Done.");
end
endtask

//
// Copy 1st half of RAM into 2nd half
//
task copy_1stto2ndhalf;
reg	[31:0]		saddr;
reg	[31:0]		daddr;
reg	[31:0]		data [63:0];
reg	[3:0]		rndnum;
reg	[1:0]		delay;
reg			end_flag;
reg	[2:0]		beats;
reg	[2:0]		current_beat;
integer			start_time;
integer			end_time;
begin
	$display;
	$display("II. Copying 1st half of the RAM into 2nd half:");
	daddr = `RAM_WORDS/2;
	start_time = $time;
	for (saddr = 0; saddr < `RAM_WORDS/2; saddr = saddr) begin
		beats = $random;
		if (!beats)
			beats = 1;

		//
		// Block read from first half of RAM. Beats are spaced with random delays.
		//
		$write("B");
		for (current_beat = beats; current_beat; current_beat = current_beat - 1) begin
			$write("r");
			if (current_beat == 1)
				end_flag = 1;
			else
				end_flag = 0;
			rndnum = $random;
			if (rndnum == 0)
				delay = $random;
			else
				delay = 0;
			while (delay)
				@(posedge tb_top.clk) begin
					delay = delay - 1;
					$write(".");
				end
			tb_top.wb_master.blkrd(saddr, end_flag, data[current_beat]);
			saddr = saddr + 1;
		end

		//
		// Block write into second half of RAM. Beats are spaced with random delays.
		//
		$write("B");
		for (current_beat = beats; current_beat; current_beat = current_beat - 1) begin
			$write("w");
			if (current_beat == 1)
				end_flag = 1;
			else
				end_flag = 0;
			rndnum = $random;
			if (rndnum == 0)
				delay = $random;
			else
				delay = 0;
			while (delay)
				@(posedge tb_top.clk) begin
					delay = delay - 1;
					$write(".");
				end
			if (daddr < `RAM_WORDS) begin
				tb_top.wb_master.blkwr(daddr, data[current_beat], 4'b1111, end_flag);
				daddr = daddr + 1;
			end
		end
	end
	$display(" Done.");
	end_time = $time;
	$display;
	$display(" Clock cycles to complete copy: %d", (end_time - start_time) / (`Thper*2));
end
endtask


//
// Read and write same addresses in first half (to check for bug reported by Avi)
//
task read_write_1sthalf;
reg	[31:0]		saddr;
reg	[31:0]		daddr;
reg	[31:0]		data [63:0];
reg	[3:0]		rndnum;
reg	[1:0]		delay;
reg	[2:0]		beats;
integer			start_time;
integer			end_time;
begin
	$display;
	$display("III. Reading and writing same locations in the first half");
	start_time = $time;
	for (saddr = 0; saddr < `RAM_WORDS/2; saddr = saddr) begin

		//
		// Read and write same locations. Beats are spaced with random delays.
		//
		rndnum = $random;
		if (rndnum == 0)
			delay = $random;
		else
			delay = 0;
		while (delay)
			@(posedge tb_top.clk) begin
				delay = delay - 1;
				$write(".");
			end
		$write("r");
		tb_top.wb_master.rd(saddr, data[1]);
		daddr = saddr;
		$write("w");
		tb_top.wb_master.wr(daddr, data[1], 4'b1111);
		$write("r");
		tb_top.wb_master.rd(saddr, data[2]);
		if (data[1] != data[2]) begin
			$write("Read/Write/Read sequence performing accesses ");
			$write("to address %h failed. First read %h != second read %h", saddr, data[1], data[2]);
			errors = errors + 1;
		end
		saddr = saddr + 1;
	end

	$display(" Done.");
	end_time = $time;
	$display;
	$display(" Clock cycles to complete copy: %d", (end_time - start_time) / (`Thper*2));
end
endtask

//
// Compare 1st half and 2nd half of the RAM and return result of the comparison
//
task comp_1stand2ndhalf;
reg	[31:0]		saddr;
reg	[31:0]		sdata;
reg	[31:0]		daddr;
reg	[31:0]		ddata;
begin
	$display;
	$display("III. Comparing 1st half and 2nd half of the RAM.");
	for (saddr = 0; saddr < `RAM_WORDS/2; saddr = saddr + 1) begin
		daddr = saddr + `RAM_WORDS/2;
		tb_top.wb_master.rd(saddr, sdata);
		tb_top.wb_master.rd(daddr, ddata);
		if (sdata != ddata) begin
			$write("Locations %h and %h are different. ", saddr, daddr);
			$display("First data %h and second data %h.", sdata, ddata);
			errors = errors + 1;
		end
	end
	$display;
	if (!errors)
		$display("  Test Passed");
	else
		$display("  ERRORS: %d", errors);
	$display;
end
endtask

//
// Run the test
//
initial begin
`ifdef VCD_DUMP
	$dumpfile("../out/dump.vcd");
	$dumpvars(0);
`endif
	#`Trst;
	describe_test;
	init_1sthalf;
	errors = 0;
	copy_1stto2ndhalf;
	read_write_1sthalf;
	comp_1stand2ndhalf;
	$finish;
end

endmodule

