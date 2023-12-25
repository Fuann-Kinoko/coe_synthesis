`include "../utils/defines2.vh"
`timescale 1ns / 1ps

module aludec(
    input [5:0] op,
    input [5:0] funct,
    output reg [2:0] aluctrl
    );

// 3'b000 -> (num1&num2): // AND
// 3'b001 -> (num1|num2): // OR
// 3'b010 -> (num1+num2): // ADD
// 3'b110 -> (num1-num2): // SUB
// 3'b111 -> (num1<num2): // SLT

    always @(*) begin
        case(op)
            `R_TYPE: case(funct)
                `ADD: aluctrl = 3'b010;
                `SUB: aluctrl = 3'b110;
                `AND: aluctrl = 3'b000;
                `OR:  aluctrl = 3'b001;
                `SLT: aluctrl = 3'b111;
            endcase
            `LW, `SW, `ADDI, `J: aluctrl = 3'b010;
            `BEQ: aluctrl = 3'b010;
            default: aluctrl = 3'b000;
        endcase
    end

    // // 照表填
    // always@(*)begin
    //     case(aluop)
    //         2'b00:aluctrl = 3'b010;               //lw、sw, the aluctrl refers to ADD ALU
    //         2'b01:aluctrl = 3'b110;               //beq, the aluctrl refers to SUB ALU
    //         2'b10:begin // different situations
    //             case(funct)
    //                 6'b10_0000:aluctrl = 3'b010;  //add
    //                 6'b10_0010:aluctrl = 3'b110;  //sub
    //                 6'b10_0100:aluctrl = 3'b000;  //and
    //                 6'b10_0101:aluctrl = 3'b001;  //or
    //                 6'b10_1010:aluctrl = 3'b111;  //slt
    //             endcase
    //         end
    //         default:aluctrl = 3'd0;
    //     endcase
    // end
endmodule
