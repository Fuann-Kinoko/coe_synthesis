`include "./defines2.vh"
`timescale 1ns / 1ps

module alu(
    input [31:0]num1,
    input [31:0]num2,
    input [4:0]sa,
    input [4:0]op,
    output reg [31:0]result
    );

    reg [32:0] temp; // 多了一位用于检验溢出
    reg exception;

    always @(*) begin
        case(op)
            // 算术
            `ADD_CONTROL: begin
                result = num1 + num2;
                temp = {num1[31],num1} + {num2[31],num2};
                exception = (temp[32]!=temp[31]);
            end
            `SUB_CONTROL: begin
                result = num1 - num2;
                temp = {num1[31],num1} - {num2[31],num2};
                exception = (temp[32]!=temp[31]);
            end
            `SLT_CONTROL: result = ($signed(num1) < $signed(num2)) ? 1'b1 : 1'b0;
            `SLTU_CONTROL: result = (num1 < num2) ? 1'b1 : 1'b0;
            // 逻辑
            `AND_CONTROL: result = num1 & num2;
            `OR_CONTROL: result = num1 | num2;
            `XOR_CONTROL: result = num1 ^ num2;
            `NOR_CONTROL: result = ~(num1 | num2);
            // 位移
            `SLL_CONTROL: result = num2 << sa;
            `SRL_CONTROL: result = num2 >> sa;
            `SRA_CONTROL: result = $signed(num2) >>> sa;
            `SLLV_CONTROL: result = num2 << num1[4:0];
            `SRLV_CONTROL: result = num2 >> num1[4:0];
            `SRAV_CONTROL: result = $signed(num2) >>> num1[4:0];
            // ...
            default: result = 32'hxxxx_xxxx;
        endcase
    end
// assign result =
//                 // 算术运算
//                 (op==`ADD_CONTROL)  ?   (num1+num2):    // ADD
//                 (op==`SUB_CONTROL)  ?   (num1-num2):    // SUB
//                 (op==`SLT_CONTROL)  ?   (num1<num2):    // SLT
//                 // 逻辑运算
//                 (op==`AND_CONTROL)  ?   (num1&num2):    // AND
//                 (op==`OR_CONTROL)   ?   (num1|num2):    // OR
//                 (op==`XOR_CONTROL)  ?   (num1^num2):    // XOR
//                 (op==`NOR_CONTROL)  ?   (~(num1|num2)): // NOR
//                 // 位移运算
//                 (op==`SLL_CONTROL)  ?   (num2<<sa):     //SLL
//                 (op==`SRL_CONTROL)  ?   (num2>>sa):     //SRL
//                 (op==`SRA_CONTROL)  ?   ({32{num2[31]}} << (6'd32 - {1'b0,sa})) | num2 >> sa: //SRA
//                 (op==`SLLV_CONTROL) ?   (num2<<num1[4:0]): //SLLV
//                 (op==`SRLV_CONTROL) ?   (num2>>num1[4:0]): //SRLV
//                 (op==`SRAV_CONTROL) ?   ({32{num2[31]}} << (6'd32 - {1'b0,num1[4:0]})) | num2 >> num1[4:0]: //SRAV
//                 32'hxxxx_xxxx;
endmodule
