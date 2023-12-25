`include "./defines2.vh"
`timescale 1ns / 1ps

module alu(
    input [31:0]num1,
    input [31:0]num2,
    input [4:0]op,
    output [31:0]result
    );
assign result = (op==`AND_CONTROL)?(num1&num2): // AND hhhh
                (op==`OR_CONTROL)?(num1|num2): // OR
                (op==`ADD_CONTROL)?(num1+num2): // ADD
                (op==`SUB_CONTROL)?(num1-num2): // SUB
                (op==`SLT_CONTROL)?(num1<num2): // SLT
                32'hxxxx_xxxx;
endmodule
