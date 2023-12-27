`include "../utils/defines2.vh"
`timescale 1ns / 1ps
`define INST_SET_BRANCH `BEQ, `BNE, `BGTZ, `BLEZ, `BG_EXT_INST
`define USELESS_CONTROL `AND_CONTROL

module aludec(
    input [5:0] op,
    input [5:0] funct,
    output reg [4:0] aluctrl
    );

    always @(*) begin
        case(op)
            `R_TYPE: case(funct)
                // 算术运算
                `ADD: aluctrl = `ADD_CONTROL;
                `ADDU: aluctrl = `ADD_CONTROL;
                `SUB: aluctrl = `SUB_CONTROL;
                `SUBU: aluctrl = `SUB_CONTROL;
                `SLT: aluctrl = `SLT_CONTROL;
                `SLTU: aluctrl = `SLTU_CONTROL;
                // 逻辑运算
                `AND: aluctrl = `AND_CONTROL;
                `OR:  aluctrl = `OR_CONTROL;
                `XOR: aluctrl = `XOR_CONTROL;
                `NOR: aluctrl = `NOR_CONTROL;
                // 位移运算
                `SLL: aluctrl = `SLL_CONTROL;
                `SRL: aluctrl = `SRL_CONTROL;
                `SRA: aluctrl = `SRA_CONTROL;
                `SLLV: aluctrl = `SLLV_CONTROL;
                `SRLV: aluctrl = `SRLV_CONTROL;
                `SRAV: aluctrl = `SRAV_CONTROL;
            endcase
            `LW, `SW: aluctrl = `ADD_CONTROL;
            `J: aluctrl = `ADD_CONTROL;
            `INST_SET_BRANCH: aluctrl = `ADD_CONTROL;
            `LUI: aluctrl = `OR_CONTROL;
            `ORI: aluctrl = `OR_CONTROL;
            `XORI: aluctrl = `XOR_CONTROL;
            `ANDI: aluctrl = `AND_CONTROL;
            `ADDI, `ADDIU: aluctrl = `ADD_CONTROL;
            `SLTI, `SLTIU: aluctrl = `SLT_CONTROL;
            default: aluctrl = `AND_CONTROL;
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
