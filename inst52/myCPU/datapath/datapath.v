`timescale 1ns / 1ps

module datapath(
	input clk,rst,
	//fetch stage
	input [31:0] instrF,
	output [31:0] pcF,
	//decode stage
	input pcsrcD,branchD,
	input jumpD,
	output equalD,
	output [5:0] opD,functD,
	//execute stage
	input memtoregE,
	input alusrcE,regdstE,
	input regwriteE,
	input [4:0] alucontrolE,
	output flushE,
	//mem stage
	input memtoregM,
	input regwriteM,
	input [31:0] readdataM,
	output [31:0] aluoutM,writedataM,
	//writeback stage
	input memtoregW,
	input regwriteW
);

	//fetch stage
	wire stallF;
	wire [31:0] pc_plus4F;

	//decode stage
	wire [31:0] pc_afterjumpD,pc_afterbranchD,pc_branch_offsetD;
	wire [31:0] pc_plus4D,instrD;
	wire forwardaD,forwardbD;
	wire [4:0] rsD,rtD,rdD;
	wire stallD;
	wire [31:0] signimmD,signimm_slD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D;

	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;

	//mem stage
	wire [4:0] writeregM;

	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW;



	// =======================================================================================
	// 			对流水线五个flip-flop的暂存，及其data/control hazard发生的改变
	// =======================================================================================

	// 有可能暂停的flip要带en
	// 有可能flush的flip要带clear

	// [fetch -> decode]
	// 暂存
	flopenr r1D(clk,rst,~stallD,pc_plus4F,pc_plus4D);
	flopenr r2D(clk,rst,~stallD,instrF,instrD);
	// 前推
	mux2 forwardamux(srcaD,aluoutM,forwardaD,srca2D);
	mux2 forwardbmux(srcbD,aluoutM,forwardbD,srcb2D);

	// [decode]
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
	// 提前在decode判断branch
	assign equalD = (srca2D == srcb2D)?1'b1:1'b0;

	// [decode -> execute]
	// 暂存
	floprc r1E(clk,rst,flushE,srcaD,srcaE);
	floprc r2E(clk,rst,flushE,srcbD,srcbE);
	floprc r3E(clk,rst,flushE,signimmD,signimmE);
	floprc #(5) r4E(clk,rst,flushE,rsD,rsE); // 如果只有暂存，rsD没必要推过去，但rsE对hazard前推有用
	floprc #(5) r5E(clk,rst,flushE,rtD,rtE);
	floprc #(5) r6E(clk,rst,flushE,rdD,rdE);
	// 前推
	mux3 forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);

	// [execute -> mem]
	// 暂存
	flopr r1M(clk,rst,srcb2E,writedataM);
	flopr r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);

	// [mem -> writeBack]
	// 暂存
	flopr r1W(clk,rst,aluoutM,aluoutW);
	flopr r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);


	// =============================
	// 			hazard模块
	// =============================
	hazard h(
		//fetch stage
		.stallF(stallF),
		//decode stage
		.rsD(rsD),
		.rtD(rtD),
		.branchD(branchD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		//execute stage
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.flushE(flushE),
		//mem stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
		//write back stage
		.writeregW(writeregW),
		.regwriteW(regwriteW)
	);


	// =============================================================
	// 以下代码全部为实验3内原功能的代码，区别在于增加了不同阶段的划分，以及更改
	// 了因阶段不同而改变的信号
	// =============================================================


	// ====================================
    // PC部分
    // PC -> PC+4 -> 判断branch
    //            -> 判断jump
    //            -> 更新PC
    // ====================================

	// [Fetch] PC 模块
	flopenr pcreg(clk,rst,~stallF,pc_afterjumpD,pcF);
	// [Fetch] PC + 4
	adder adder_plus4(pcF,32'd4,pc_plus4F);

	// [Decode] 数据扩展
	signext DataExtend(opD, instrD[15:0], signimmD);
	// [Decode] 左移两位
	sl2 immsh(signimmD,signimm_slD);
	// [Decode] 计算branch的地址
	adder adder_branch(signimm_slD,pc_plus4D,pc_branch_offsetD);
	// [Decode] 判断是否执行branch
	//			为了（部分）解决控制冒险，提前判断branch
	mux2 mux_PCSrc(pc_plus4F,pc_branch_offsetD,pcsrcD,pc_afterbranchD);
	// [Decode] 判断是否执行jump
	mux2 mux_PCJump(
		pc_afterbranchD,
		{pc_plus4D[31:28],instrD[25:0],2'b00},
		jumpD,
		pc_afterjumpD
	);


    // ====================================
    // Data部分
    // ====================================


	// [Execute] 决定 write register 是 rt 还是 rd
	mux2 #(5) mux_regdst(rtE,rdE,regdstE,writeregE);
    // [Execute] 针对寄存器堆，进行操作
	regfile register(clk,rst,regwriteW,rsD,rtD,writeregW,resultW,srcaD,srcbD);
    // [Execute] 判断ALU收到的srcB是RD2还是SignImm
	mux2 mux_ALUsrc(srcb2E,signimmE,alusrcE,srcb3E);
    // [Execute] ALU运算，控制冒险提前判断了branch，不再需要zero
	alu alu(srca2E,srcb3E,alucontrolE,aluoutE);

    // [WriteBack] 判断写回寄存器堆的是：ALU的计算结果 or 从数据存储器读取的data
	mux2 mux_regwriteData(aluoutW,readdataW,memtoregW,resultW);
endmodule
