`timescale 1ns / 1ps

module maindec(
    input [5:0] op,
    output reg regwrite,    
    output reg regdst,      
    output reg alusrc,      
    output reg branch,      
    output reg memWrite,    
    output reg memToReg,    
    output reg jump,        
    //pcsrc被忽略掉了
    output reg [1:0] aluop
    );
    //顺序按表5
    always@(*)begin
        case(op)
            6'b000000:begin     //R-type
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b1100000;  
                aluop=2'b10;
            end
            6'b100011:begin     //lw
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b1010010;
                aluop=2'b00;
            end
            6'b101011:begin     //sw
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b0010100;
                aluop=2'b00;
            end
            6'b000100:begin     //beq
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b0001000;
                aluop=2'b01;
            end
            6'b001000:begin     //I-type
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b1010000;
                aluop=2'b00;
            end
            6'b000010:begin     //jump
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'b0000001;
                aluop=2'b00;
            end
            default:begin
                {regwrite,regdst,alusrc,branch,memWrite,memToReg,jump}=7'd0;
                aluop=2'b00;
            end
        endcase
    end
endmodule
