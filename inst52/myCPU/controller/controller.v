`timescale 1ns / 1ps


module controller(
	input clk,rst,

	//decode stage
	input [4:0] rsD,rtD,rdD,
	input [5:0] opD,functD,
	input validBranchConditionD,
	output pcsrcD,branchD,jumpD,jalD,jrD,

	//execute stage
	input flushE,stallE,
	output memtoregE,alusrcE,
	output balE,jalE,jrE,
	output regdstE,regwriteE,
	output [4:0] alucontrolE,
    output regToHilo_hiE,regToHilo_loE,
    output mdToHiloE,
    output mulOrdivE,
    output hilotoregE,
    output hilosrcE,
    output mdIsSignE,


	//mem stage
	output memtoregM,memwriteM,regwriteM,hilowriteM,regToHilo_hiM,regToHilo_loM,mdToHiloM,hilotoregM,hilosrcM,

	//write back stage
	output memtoregW,regwriteW,hilotoregW

);

	//decode stage
	wire memtoregD,memwriteD,alusrcD,regdstD,regwriteD;
	wire regToHilo_hiD,regToHilo_loD,mdToHiloD,mulOrdivD,hilowriteD,hilotoregD,hilosrcD,mdIsSignD;
	wire balD;
	wire[4:0] alucontrolD;
	//execute stage
	wire memwriteE,hilowriteE;

	// 用不到的，就继续传

	// [decode -> execute]
	assign pcsrcD = branchD & validBranchConditionD;
	// 注意，这里存在flush可能性
	flopenrc #(21) regE(
		clk, rst,
        ~stallE,
		flushE,
		{memtoregD,memwriteD,alusrcD,regdstD,regwriteD,alucontrolD,balD,jalD,jrD,regToHilo_hiD,regToHilo_loD,mdToHiloD,mulOrdivD,hilowriteD,hilotoregD,hilosrcD,mdIsSignD},
		{memtoregE,memwriteE,alusrcE,regdstE,regwriteE,alucontrolE,balE,jalE,jrE,regToHilo_hiE,regToHilo_loE,mdToHiloE,mulOrdivE,hilowriteE,hilotoregE,hilosrcE,mdIsSignE}
	);

	// [execute -> mem]
	flopr #(9) regM(
		clk,rst,
		{memtoregE,memwriteE,regwriteE,regToHilo_hiE,regToHilo_loE,mdToHiloE,hilowriteE,hilotoregE,hilosrcE},
		{memtoregM,memwriteM,regwriteM,regToHilo_hiM,regToHilo_loM,mdToHiloM,hilowriteM,hilotoregM,hilosrcM}
	);

	// [mem -> writeBack]
	flopr #(3) regW(
		clk,rst,
		{memtoregM,regwriteM,hilotoregM},
		{memtoregW,regwriteW,hilotoregW}
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
        .jump(jumpD),
        .hilowrite(hilowriteD),
        .regToHilo_hi(regToHilo_hiD),
        .regToHilo_lo(regToHilo_loD),
        .mdToHilo(mdToHiloD),
        .mulOrdiv(mulOrdivD),
        .hiloToReg(hilotoregD),
        .hilosrc(hilosrcD),
        .mdIsSign(mdIsSignD)
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
