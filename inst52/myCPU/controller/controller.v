`timescale 1ns / 1ps


module controller(
	input clk,rst,

	//decode stage
	input [5:0] opD,functD,equalD,
	output pcsrcD,branchD,jumpD,

	//execute stage
	input flushE,
	output memtoregE,alusrcE,
	output regdstE,regwriteE,
	output [2:0] alucontrolE,

	//mem stage
	output memtoregM,memwriteM,regwriteM,

	//write back stage
	output memtoregW,regwriteW

);

	//decode stage
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire[2:0] alucontrolD;
	//execute stage
	wire memwriteE;

	// 用不到的，就继续传

	// [decode -> execute]
	assign pcsrcD = branchD & equalD;
	// 注意，这里存在flush可能性
	floprc #(8) regE(
		clk, rst,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE}
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
		//input
        .regwrite(regwriteD),
        .regdst(regdstD),
        .alusrc(alusrcD),
        .branch(branchD),
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
