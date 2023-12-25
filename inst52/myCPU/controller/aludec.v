`timescale 1ns / 1ps

module aludec(
    input [1:0] aluop,
    input [5:0] funct,
    output reg [2:0] aluctrl
    );

    // 照表填
    always@(*)begin
        case(aluop)
            2'b00:aluctrl = 3'b010;               //lw、sw
            2'b01:aluctrl = 3'b110;               //beq
            2'b10:begin                          
                case(funct)
                    6'b10_0000:aluctrl = 3'b010;  //add
                    6'b10_0010:aluctrl = 3'b110;  //sub
                    6'b10_0100:aluctrl = 3'b000;  //and
                    6'b10_0101:aluctrl = 3'b001;  //or
                    6'b10_1010:aluctrl = 3'b111;  //slt
                endcase
            end
            default:aluctrl = 3'd0;
        endcase
    end
endmodule
