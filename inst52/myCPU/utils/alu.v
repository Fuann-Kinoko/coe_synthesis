`timescale 1ns / 1ps

module alu(
    input [31:0]num1,
    input [31:0]num2,
    input [2:0]op,
    output [31:0]result
    );
assign result = (op==3'b000)?(num1&num2):
                (op==3'b001)?(num1|num2):
                (op==3'b010)?(num1+num2):
                (op==3'b110)?(num1-num2):
                (op==3'b111)?(num1<num2):
                32'hxxxx_xxxx;
endmodule
