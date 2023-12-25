`timescale 1ns / 1ps

module signext(
    input [15:0] a,
    output [31:0] a_ext
    );
    // 符号扩展
    assign a_ext={ {16{a[15]}} ,a}; 
endmodule