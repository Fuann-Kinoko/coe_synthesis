`include "../utils/defines2.vh"
`timescale 1ns / 1ps

module maindec(
    input [5:0] op,
    output reg regwrite,
    output reg regdst,
    output reg alusrc,
    output reg branch,
    output reg memWrite,
    output reg memToReg,
    output reg jump
    );

    // regwrite
    always @(*) begin
        case(op)
            `R_TYPE, `LW, `ADDI, `ANDI: regwrite = 1'b1;
            default: regwrite = 1'b0;
        endcase
    end
    // regdst
    always @(*) begin
        case(op)
            `R_TYPE: regdst = 1'b1;
            default: regdst = 1'b0;
        endcase
    end
    // alusrc
    always @(*) begin
        case(op)
            `SW, `LW, `ADDI, `ANDI: alusrc = 1'b1;
            default: alusrc = 1'b0;
        endcase
    end
    // branch
    always @(*) begin
        case(op)
            `BEQ: branch = 1'b1;
            default: branch = 1'b0;
        endcase
    end
    // memWrite
    always @(*) begin
        case(op)
            `SW: memWrite = 1'b1;
            default: memWrite = 1'b0;
        endcase
    end
    // memToReg
    always @(*) begin
        case(op)
            `LW: memToReg = 1'b1;
            default: memToReg = 1'b0;
        endcase
    end
    // jump
    always @(*) begin
        case(op)
            `J: jump = 1'b1;
            default: jump = 1'b0;
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
