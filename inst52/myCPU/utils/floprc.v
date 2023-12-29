`timescale 1ns / 1ps

module floprc #(parameter WIDTH = 32)(
	input wire clk,rst,en,clear,
	input wire[WIDTH-1:0] d,
	output reg[WIDTH-1:0] q
    );

	always @(posedge clk,posedge rst) begin
		if(rst) 
			q <= 0;
		else if (clear)
			q <= 0;
		else  if (en)
			q <= d;
	end
endmodule
