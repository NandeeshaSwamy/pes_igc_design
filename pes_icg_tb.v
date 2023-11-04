`timescale 1ns / 1ps

module pes_icg_tb();
    reg in, clk, d0, d1;
    wire q0, q1;
    
    pes_icg uut (.in(in), .clk(clk), .d0(d0), .d1(d1), .q0(q0), .q1(q1));
    initial 
    begin
    $dumpfile("pes_icg_tb.vcd");
	$dumpvars(0,pes_icg_tb);
	// Initialize Inputs
    in = 0;
    d0 = 0;
    d1 = 0;
    clk = 0;
    //en=0;
    
    
	#3000 $finish;
	end
	
	always #20 in<=~in;
	//always #5 en<=~en;
	always #40 d0<=~d0;
	always #50 d1<=~d1;
	always #30 clk=~clk;
	
endmodule
