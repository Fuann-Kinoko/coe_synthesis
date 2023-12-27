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
    input hilodstE,
    input hilotoregE,
	output flushE,
	//mem stage
	input memtoregM,
	input regwriteM,
    input hilowriteM,hilotoregM,hilosrcM,
	input [31:0] readdataM,
	output [31:0] aluoutM,writedataM,
	//writeback stage
	input memtoregW,
	input regwriteW,
    input hilotoregW
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
    wire [4:0] saD;
    wire [31:0] HID,LOD;

	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
    wire [4:0] saE;
    wire [31:0] HIE,LOE;
    wire writehiloE;

	//mem stage
	wire [4:0] writeregM;
    wire [31:0] srcaM;
    wire [31:0] HIM,LOM;
    wire [31:0] hilooutM;

	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW,hilooutW;



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
    assign saD = instrD[10:6];
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
    floprc #(5) r7E(clk,rst,flushE,saD,saE);
    floprc r8E(clk,rst,flushE,HID,HIE);
    floprc r9E(clk,rst,flushE,LOD,LOE);
	// 前推
	mux3 forwardaemux(srcaE,resultW,aluoutM,forwardaE,srca2E);
	mux3 forwardbemux(srcbE,resultW,aluoutM,forwardbE,srcb2E);

	// [execute -> mem]
	// 暂存
	flopr r1M(clk,rst,srcb2E,writedataM);
	flopr r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);
    flopr #(1) r4M(clk,rst,writehiloE,writehiloM);
    flopr r5M(clk,rst,srcaE,srcaM);
    flopr r6M(clk,rst,HIE,HIM);
    flopr r7M(clk,rst,LOE,LOM);

	// [mem -> writeBack]
	// 暂存
	flopr r1W(clk,rst,aluoutM,aluoutW);
	flopr r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
    flopr r4W(clk,rst,hilooutM,hilooutW);


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
	alu alu(srca2E,srcb3E,saE,alucontrolE,aluoutE);
    // [Execute] 决定 write hilo_reg 是 HI 还是 LO
    mux2 #(1) mux_hilodst(1'b0,1'b1,hilodstE,writehiloE);
    // 在Mem阶段写hilo_reg
    hilo_reg hilo(clk,rst,hilowriteM,writehiloM,srcaM,HID,LOD);
    // [Memory] 决定 write rd是 HI,还是LO
    mux2 mux_rddst(LOM,HIM,hilosrcM,hilooutM);

    // [WriteBack] 判断写回寄存器堆的是：ALU的计算结果 or 从数据存储器读取的data
	// mux2 mux_regwriteData(aluoutW,readdataW,memtoregW,resultW);
    mux3 mux_regwriteData(aluoutW,readataW,hilooutW,{hilotoregW,memtoregW},resultW);
endmodule
