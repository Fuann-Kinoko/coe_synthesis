`timescale 1ns / 1ps

module hilo_reg(
    input wire clk,rst,we3,
    input wire wa3,
    input wire [31:0] wd3,
    output wire [31:0] hi,lo
);
   reg [31:0] rf[1:0];//rf[1]-HI、rf[0]-LO
   always @(negedge clk) begin
    if(rst) begin
        rf[1] <= 0;
        rf[0] <= 0;
    end else if(we3) begin
        rf[wa3] <= wd3;
    end
   end
   assign hi = rf[1];
   assign lo = rf[0];
endmodule