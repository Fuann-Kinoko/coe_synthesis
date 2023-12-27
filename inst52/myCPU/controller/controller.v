`timescale 1ns / 1ps


module controller(
	input clk,rst,

	//decode stage
	input [4:0] rsD,rtD,
	input [5:0] opD,functD,validBranchConditionD,
	output pcsrcD,branchD,jumpD,jalD,jrD,

	//execute stage
	input flushE,
	output memtoregE,alusrcE,
	output balE,jalE,jrE,
	output regdstE,regwriteE,
	output [4:0] alucontrolE,


	//mem stage
	output memtoregM,memwriteM,regwriteM,

	//write back stage
	output memtoregW,regwriteW

);

	//decode stage
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire balD;
	wire[4:0] alucontrolD;
	//execute stage
	wire memwriteE;

	// 用不到的，就继续传

	// [decode -> execute]
	assign pcsrcD = branchD & validBranchConditionD;
	// 注意，这里存在flush可能性
	floprc #(13) regE(
		clk, rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,balD,jalD,jrD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,balE,jalE,jrE}
	);

	// [execute -> mem]
	flopr #(3) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE},
		{memtoregM,memwriteM,regwriteM}
	);

	// [mem -> writeBack]
	flopr #(2) regW(
		clk,rst,
		{memtoregM,regwriteM},
		{memtoregW,regwriteW}
	);

	// =============================================================
	// 以下代码全部为实验3内原功能的代码，区别在于增加了不同阶段的划分
	// =============================================================


	maindec control_maindec(
		.op(opD),
		.rs(rsD),
		.rt(rtD),
		.rd(rdD),
		.funct(functD),
		//input
        .regwrite(regwriteD),
        .regdst(regdstD),
        .alusrc(alusrcD),
        .branch(branchD),
		.bal(balD),
		.jal(jalD),
		.jr(jrD),
        .memWrite(memwriteD),
        .memToReg(memtoregD),
        .jump(jumpD)
        //output
	);

	aludec control_aludec(
		.op(opD),
        .funct(functD),
        //input
        .aluctrl(alucontrolD)
        //output
    );


endmodule
