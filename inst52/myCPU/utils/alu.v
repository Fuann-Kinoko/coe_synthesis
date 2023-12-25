`include "./defines2.vh"
`timescale 1ns / 1ps

module alu(
    input [31:0]num1,
    input [31:0]num2,
    input [4:0]sa,
    input [4:0]op,
    output [31:0]result
    );
assign result = (op==`AND_CONTROL)  ?   (num1&num2):    // AND
                (op==`OR_CONTROL)   ?   (num1|num2):    // OR
                (op==`ADD_CONTROL)  ?   (num1+num2):    // ADD
                (op==`SUB_CONTROL)  ?   (num1-num2):    // SUB
                (op==`SLT_CONTROL)  ?   (num1<num2):    // SLT
                (op==`XOR_CONTROL)  ?   (num1^num2):    // XOR
                (op==`NOR_CONTROL)  ?   (~(num1|num2)): // NOR
                (op==`SLL_CONTROL)  ?   (num2<<sa):     //SLL
                (op==`SRL_CONTROL)  ?   (num2>>sa):     //SRL
                (op==`SRA_CONTROL)  ?   ({32{num2[31]}} << (6'd32 - {1'b0,sa})) | num2 >> sa: //SRA
                (op==`SLLV_CONTROL) ?   (num2<<num1[4:0]): //SLLV
                (op==`SRLV_CONTROL) ?   (num2>>num1[4:0]): //SRLV
                (op==`SRAV_CONTROL) ?   ({32{num2[31]}} << (6'd32 - {1'b0,num1[4:0]})) | num2 >> num1[4:0]: //SRAV
                32'hxxxx_xxxx;
endmodule
