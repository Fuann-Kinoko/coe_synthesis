`timescale 1ns / 1ps

module hazard(
	//fetch stage
	output stallF,

	//decode stage
	input [4:0] rsD,rtD,
	input branchD,
	output forwardaD,forwardbD,
	output stallD,

	//execute stage
	input [4:0] rsE,rtE,
	input [4:0] writeregE,
	input regwriteE,
	input memtoregE,
    input hilotoregE,hilosrcE,
	output [1:0] forwardaE,forwardbE,
	output flushE,
    output forwardHIE,forwardLOE,

	//mem stage
	input [4:0] writeregM,
	input regwriteM,
	input memtoregM,
    input writehiloM,hilowriteM,

	//write back stage
	input [4:0] writeregW,
	input regwriteW
);

	wire lwstallD,branchstallD;

	
	// [数据冒险]
	// 			-> 前推
	// 读的不是$zero & M/W阶段的寄存器号与需要前推的E阶段寄存器号对的上 & 写使能开着，确实还没写入
	assign forwardaE = 	((rsE!=0) & (rsE == writeregM & regwriteM)) ? 2'b10:
						((rsE!=0) & (rsE == writeregW & regwriteW)) ? 2'b01:
						2'b00;
	assign forwardbE = 	((rtE!=0) & (rtE == writeregM & regwriteM)) ? 2'b10:
						((rtE!=0) & (rtE == writeregW & regwriteW)) ? 2'b01:
						2'b00;
    // 针对数据移动指令（MF、MT）的数据前推
    // E阶段需要读hilo_reg & M阶段hilo_reg需要写的寄存器号与需要前推的E阶段hilo_reg需要读的寄存器号相同 & M阶段hilo_reg的写使能有效
    assign forwardHIE = ((hilotoregE) & (hilosrcE == writehiloM) & (hilowriteM)) ? 1'b1 : 1'b0;
    assign forwardLOE = ((hilotoregE) & (hilosrcE == writehiloM) & (hilowriteM)) ? 1'b1 : 1'b0;      

	// 			-> 暂停
	assign lwstallD = memtoregE & (rtE == rsD | rtE == rtD);
	/*
	assign stallD = lwstallD;
	assign stallF = lwstallD;
	assign flushE = lwstallD;
	*/
	// 上面的三个被控制冒险中的新写法所覆盖


	// [控制冒险]
	// 			-> 前推
	assign forwardaD = (rsD != 0 & rsD == writeregM & regwriteM);
	assign forwardbD = (rtD != 0 & rtD == writeregM & regwriteM);
	// 			-> 暂停
	// 当前为branch & 上一条确实要写入 & E/M 目前的寄存器号与上一条的M/W阶段寄存器号对的上
	assign branchstallD = 	(branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) |
							(branchD & memtoregM & (writeregM == rsD | writeregM == rtD));
	assign stallD = lwstallD | branchstallD;
	assign stallF = lwstallD | branchstallD;
	assign flushE = lwstallD | branchstallD;

endmodule
