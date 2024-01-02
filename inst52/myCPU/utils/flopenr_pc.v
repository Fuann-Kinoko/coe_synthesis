
`timescale 1ns / 1ps


module flopenr_pc #(parameter WIDTH = 32)(
	input clk,rst,en,flushF,
	input [WIDTH-1:0] d,
	input [WIDTH-1:0] newpcM,
	output reg [WIDTH-1:0] q
    );
	always @(posedge clk) begin
		if(rst)
			q <= 32'hbfc00000;
		else if(flushF)
			q <= newpcM;
		else if(en)
			q <= d;
	end
endmodule
