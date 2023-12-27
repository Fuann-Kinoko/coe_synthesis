`include "../utils/defines2.vh"
`include "../utils/control_signal_define.vh"
`timescale 1ns / 1ps
`define INST_SET_BRANCH `BEQ, `BNE, `BGTZ, `BLEZ, `BG_EXT_INST
`define INST_SET_IMMEDIATE `ADDI, `ANDI, `LUI, `ORI, `XORI, `ADDIU, `SLTI, `SLTIU

module maindec(
    input [5:0] op,
    input [5:0] rs,
    input [5:0] rt,
    output reg regwrite,
    output reg regdst,
    output reg alusrc,
    output reg branch,
    output reg bal,
    output reg memWrite,
    output reg memToReg,
    output reg jump
    );

    // regwrite
    always @(*) begin
        case(op)
            `R_TYPE, `LW,
            `INST_SET_IMMEDIATE: regwrite = `regwrite_ON;
            `INST_SET_BRANCH: begin
                case(rt)
                    `BGEZAL, `BLTZAL: regwrite = `regwrite_ON;
                    default: regwrite = `regwrite_OFF;
                endcase
            end
            default: regwrite = `regwrite_OFF;
        endcase
    end
    // regdst
    always @(*) begin
        case(op)
            `R_TYPE: regdst = `regdst_RD;
            default: regdst = `regdst_RT;
        endcase
    end
    // alusrc
    always @(*) begin
        case(op)
            `SW, `LW,
            `INST_SET_IMMEDIATE: alusrc = `alusrc_IMM;
            default: alusrc = `alusrc_RD;
        endcase
    end
    // branch & bal
    always @(*) begin
        case(op)
            `INST_SET_BRANCH: begin
                branch = `branch_ON;
                bal = (rt == `BGEZAL || rt == `BLTZAL) ? `bal_ON : `bal_OFF;
            end
            default: begin
                branch = `branch_OFF;
                bal = `bal_OFF;
            end
        endcase
    end
    // memWrite
    always @(*) begin
        case(op)
            `SW: memWrite = `memWrite_ON;
            default: memWrite = `memWrite_OFF;
        endcase
    end
    // memToReg
    always @(*) begin
        case(op)
            `LW: memToReg = `memToReg_MEM;
            default: memToReg = `memToReg_ALU;
        endcase
    end
    // jump
    always @(*) begin
        case(op)
            `J: jump = `jump_ON;
            default: jump = `jump_OFF;
        endcase
    end

    // //顺序按表5
    // always@(*)begin
    //     case(op)
    //         6'b000000:begin     //R-type
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b1100000;
    //             aluop=2'b10;
    //         end
    //         6'b100011:begin     //lw
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b1010010;
    //             aluop=2'b00;
    //         end
    //         6'b101011:begin     //sw
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b0010100;
    //             aluop=2'b00;
    //         end
    //         6'b000100:begin     //beq
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b0001000;
    //             aluop=2'b01;
    //         end
    //         6'b001000:begin     //I-type
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b1010000;
    //             aluop=2'b00;
    //         end
    //         6'b000010:begin     //jump
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b0000001;
    //             aluop=2'b00;
    //         end
    //         default:begin
    //             {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'd0;
    //             aluop=2'b00;
    //         end
    //     endcase
    // end
endmodule
