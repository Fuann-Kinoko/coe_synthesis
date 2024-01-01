module mycpu_top(
    input clk,
    input resetn,  //low active
    input [5:0] ext_int, //我们设计的mycpu_top暂未使用，这里仅仅是用于soc_lite_top调用mycpu_top时使用
    //cpu inst sram
    output        inst_sram_en   ,
    output [3 :0] inst_sram_wen  ,
    output [31:0] inst_sram_addr ,
    output [31:0] inst_sram_wdata,
    input  [31:0] inst_sram_rdata,
    //cpu data sram
    output        data_sram_en   ,
    output [3 :0] data_sram_wen  ,
    output [31:0] data_sram_addr ,
    output [31:0] data_sram_wdata,
    input  [31:0] data_sram_rdata,
    //debug
    output [31:0] debug_wb_pc,
    output [3:0] debug_wb_rf_wen,
    output [4:0] debug_wb_rf_wnum,
    output [31:0] debug_wb_rf_wdata
);

// 一个例子
	wire [31:0] pc;
	wire [31:0] instr;
	wire [3:0] memwrite;
	wire [31:0] aluout, writedata, readdata,data_sram_enM;
    wire [31:0] pcW;
    wire [3:0] regwriteW;
    wire [4:0] writeregW;
    wire [31:0] resultW;
    mips mips(
        .clk(clk),
        .rst(~resetn),
        //instr
        // .inst_en(inst_en),
        .pcF(pc),                    //pcF
        .instrF(instr),              //instrF
        //data
        // .data_en(data_en),
        .memwriteEN(memwrite),
        .aluoutM(aluout),
        .writedataM(writedata),
        .readdataM(readdata),
        .data_sram_enM(data_sram_enM),
        .pcW(pcW),
        .regwriteW(regwriteW),
        .writeregW(writeregW),
        .resultW(resultW)
    );

    assign inst_sram_en = 1'b1;     //如果有inst_en，就用inst_en
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc;
    assign inst_sram_wdata = 32'b0;
    assign instr = inst_sram_rdata;

    assign data_sram_en = data_sram_enM;     //如果有data_en，就用data_en
    // 读入时，就算是只读半字，也需要读入整个word（即memwrite的四位都为0），然后再根据类型选择要读的有哪些部分
    assign data_sram_wen = memwrite;
    assign data_sram_addr = aluout;
    assign data_sram_wdata = writedata;
    assign readdata = data_sram_rdata;

    assign debug_wb_pc = pcW;
    assign debug_wb_rf_wen = regwriteW;
    assign debug_wb_rf_wnum = writeregW;
    assign debug_wb_rf_wdata = regwriteW;
    //ascii
    instdec instdec(
        .instr(instr)
    );

endmodule