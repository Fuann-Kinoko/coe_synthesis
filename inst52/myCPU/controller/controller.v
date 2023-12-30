`timescale 1ns / 1ps


module controller(
	input clk,rst,

	//decode stage
	input [4:0] rsD,rtD,rdD,
	input [5:0] opD,functD,
	input validBranchConditionD,
	output pcsrcD,branchD,jumpD,jalD,jrD,
    output invalidD,

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
	output [3:0] memwriteE,
    output isWritecp0E,
    output [4:0] writecp0AddrE,readcp0AddrE,
    output cp0ToRegE,
    output branchE,jumpE,jalrE,


	//mem stage
	output memtoregM,regwriteM,hilowriteM,regToHilo_hiM,regToHilo_loM,mdToHiloM,hilotoregM,hilosrcM,isWritecp0M,cp0ToRegM,branchM,jumpM,jalM,jrM,jalrM,
	output [3:0] memReadWidthM,
	output memLoadIsSignM,
    output [4:0] writecp0AddrM,

	//write back stage
	output memtoregW,regwriteW,hilotoregW,cp0ToRegW
);

	//decode stage
	wire [3:0] memwriteD, memReadWidthD;
	wire memLoadIsSignD;
	wire memtoregD,alusrcD,regdstD,regwriteD;
	wire regToHilo_hiD,regToHilo_loD,mdToHiloD,mulOrdivD,hilowriteD,hilotoregD,hilosrcD,mdIsSignD,isWritecp0D,cp0ToRegD,jalrD;
	wire balD;
	wire[4:0] alucontrolD,writecp0AddrD,readcp0AddrD;
	//execute stage
	wire [3:0] memReadWidthE;
	wire memLoadIsSignE;
	wire hilowriteE;

	// 用不到的，就继续传

	// [decode -> execute]
	assign pcsrcD = branchD & validBranchConditionD;
	// 注意，这里存在flush可能性
	flopenrc #(44) regE(
		clk, rst,
        ~stallE,
		flushE,
		{memtoregD,memwriteD,memReadWidthD,// 9 bit
		alusrcD,regdstD,regwriteD,alucontrolD,// 17bit
		balD,jalD,jrD,regToHilo_hiD,regToHilo_loD,mdToHiloD,//23bit
		mulOrdivD,hilowriteD,hilotoregD,hilosrcD,mdIsSignD,memLoadIsSignD,isWritecp0D,writecp0AddrD,readcp0AddrD,cp0ToRegD,jalrD,branchD,jumpD},//44bit

		{memtoregE,memwriteE,memReadWidthE,
		alusrcE,regdstE,regwriteE,alucontrolE,
		balE,jalE,jrE,regToHilo_hiE,regToHilo_loE,mdToHiloE,
		mulOrdivE,hilowriteE,hilotoregE,hilosrcE,mdIsSignE,memLoadIsSignE,isWritecp0E,writecp0AddrE,readcp0AddrE,cp0ToRegE,jalrE,branchE,jumpE}
	);

	// [execute -> mem]
	flopr #(25) regM(
		clk,rst,
		{memtoregE,memReadWidthE,//5bit
		regwriteE,regToHilo_hiE,regToHilo_loE,mdToHiloE,hilowriteE,hilotoregE,//11bit
		hilosrcE,memLoadIsSignE,isWritecp0E,writecp0AddrE,cp0ToRegE,branchE,jumpE,jalE,jrE,jalrE},//25bit

		{memtoregM,memReadWidthM,
		regwriteM,regToHilo_hiM,regToHilo_loM,mdToHiloM,hilowriteM,hilotoregM,
		hilosrcM,memLoadIsSignM,isWritecp0M,writecp0AddrM,cp0ToRegM,branchM,jumpM,jalM,jrM,jalrM}
	);

	// [mem -> writeBack]
	flopr #(4) regW(
		clk,rst,
		{memtoregM,regwriteM,hilotoregM,cp0ToRegM},
		{memtoregW,regwriteW,hilotoregW,cp0ToRegW}
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
		.memReadWidth(memReadWidthD),
		.memLoadIsSign(memLoadIsSignD),
        .memToReg(memtoregD),
        .jump(jumpD),
        .hilowrite(hilowriteD),
        .regToHilo_hi(regToHilo_hiD),
        .regToHilo_lo(regToHilo_loD),
        .mdToHilo(mdToHiloD),
        .mulOrdiv(mulOrdivD),
        .hiloToReg(hilotoregD),
        .hilosrc(hilosrcD),
        .mdIsSign(mdIsSignD),
        .isWritecp0(isWritecp0D),
        .writecp0Addr(writecp0AddrD),
        .readcp0Addr(readcp0AddrD),
        .cp0ToReg(cp0ToRegD),
        .invalid(invalidD),
        .jalr(jalrD)
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
