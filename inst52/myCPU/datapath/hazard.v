`timescale 1ns / 1ps

module hazard(
	//fetch stage
	output stallF,

	//decode stage
	input [4:0] rsD,rtD,
	input branchD,jrD,
	output forwardaD,forwardbD,
	output stallD,
	output jrstall_READ,

	//execute stage
	input [4:0] rsE,rtE,
	input [4:0] writeregE,
	input regwriteE,
	input memtoregE,
    input hilotoregE,hilosrcE,
    input stall_divE,
	output [1:0] forwardaE,forwardbE,
	output flushE,
    output forwardHIE,forwardLOE,
    output stallE,

	//mem stage
	input [4:0] writeregM,
	input regwriteM,
	input memtoregM,
    input hilowriteM,
    input regToHilo_hiM,regToHilo_loM,mdToHiloM,

	//write back stage
	input [4:0] writeregW,
	input regwriteW
);

	wire lwstallD,branchstallD,jrstall_WRITE;


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
    assign forwardHIE = ((hilotoregE) & (hilosrcE & (regToHilo_hiM | mdToHiloM)) & (hilowriteM)) ? 1'b1 : 1'b0;
    assign forwardLOE = ((hilotoregE) & (!hilosrcE & (regToHilo_loM | mdToHiloM)) & (hilowriteM)) ? 1'b1 : 1'b0;

	// 			-> 暂停
	// 假设当前指令是lw，下一条指令刚好需要lw写入的寄存器。当下一条指令执行至EXE阶段时，当前指令
	// 才到MEM阶段，而直至WB阶段才能从内存拿到写入寄存器的值。因而，无奈之举便是暂停下一条指令
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
	// branch指令，如BEQ，需要在DECODE查看rt和rs寄存器。如果是上上一条指令有冒险，可以从MEM阶段前推过来
	// 但如果是上一条指令有冒险，当前指令在D阶段，上一条刚在EXE阶段，得不到Aluout，不能前推，因此要暂停当前指令
	// 判断条件：当前为branch & 上一条确实要写入寄存器，但没来得及 & E/M 目前的寄存器号与上一条的M/W阶段寄存器号对的上
	// branchstallD 可以涵盖：BEQ，BNE，BGEZ，BGTZ，BLEZ，BLTZ
	// 因为在DATAPATH设计中，writeregE可能被覆盖为31号，所以对于BGEZAL和BLTZAL也不用多写判断了
	assign branchstallD = 	(branchD & regwriteE & (writeregE == rsD | writeregE == rtD)) |
							(branchD & memtoregM & (writeregM == rsD | writeregM == rtD));

	// 同理，对于JR和JALR，因为它们要在DECODE阶段读rs的值，因此也要判断暂停DECODE阶段
	assign jrstall_READ = jrD & memtoregM & (writeregE == rsD);


	// 对JR指令不会产生，而是对JALR，因为其会将当前PC+8写回rd寄存器，
	// 因此可能产生RAW冒险，需要先暂停
	assign jrstall_WRITE = jrD && regwriteE && (writeregE == rsD);


	// [汇总后产生的stall信号]

	assign stallD = lwstallD | branchstallD | jrstall_READ | jrstall_WRITE | stall_divE;
	assign stallF = lwstallD | branchstallD | jrstall_READ | jrstall_WRITE | stall_divE;
	assign flushE = lwstallD | branchstallD | jrstall_READ;
    assign stallE = stall_divE;

endmodule
