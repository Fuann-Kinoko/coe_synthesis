`timescale 1ns / 1ps

module mips(
	input clk,rst,
	input [31:0] instrF,
	input [31:0] readdataM,
	output [31:0] pcF,
	// TODO: hilowrite和hilosrc好像不涉及与mem或者inst ram交互？那么到时候把它移到wire中，不要作为mips模块的输出
	output memwriteM,hilowriteM,hilosrcM,
	output [31:0] aluoutM,writedataM
);

	wire [5:0] opD,functD;
	wire [4:0] rsD,rtD;
	wire regdstE,alusrcE,branchD,jalD,jrD,pcsrcD,memtoregE,memtoregM,memtoregW;
	wire balE,jalE,jrE,regwriteE,regwriteM,regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,validBranchConditionD;
    wire regToHilo_hiE,regToHilo_loE,mdToHiloE,mulOrdivE,isSignE;
    wire regToHilo_hiM,regToHilo_loM,mdToHiloM;
    wire hilotoregE;
    wire hilotoregM,hilotoregW;
    wire hilosrcE;

	controller c(
		.clk(clk), .rst(rst),
		//[fetch stage]
		//				==input==
		//				==output=
		//[decode stage]
		//				==input==
		.opD(opD), 					.rsD(rsD),
		.rtD(rtD), 					.functD(functD),
		.validBranchConditionD(validBranchConditionD),
		//				==output=
		.pcsrcD(pcsrcD),			.branchD(branchD),
		.jumpD(jumpD),				.jalD(jalD),
		.jrD(jrD),
		//[execute stage]
		//				==input==
		.flushE(flushE),            .stallE(stallE),
			//output
		.memtoregE(memtoregE), 		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE), 	.balE(balE),
		.jalE(jalE),				.jrE(jrE),
        .regToHilo_hiE(regToHilo_hiE),
        .regToHilo_loE(regToHilo_loE),
        .mdToHiloE(mdToHiloE),      .mulOrdivE(mulOrdivE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
        .isSignE(isSignE),
		//[mem stage]
		//				==input==
		//				==output=
		.memtoregM(memtoregM),		.memwriteM(memwriteM),
        .regToHilo_hiM(regToHilo_hiM),
        .regToHilo_loM(regToHilo_loM),
        .mdToHiloM(mdToHiloM),
		.regwriteM(regwriteM),
        .hilotoregM(hilotoregM),    .hilowriteM(hilowriteM),
        .hilosrcM(hilosrcM),
		//[writeBack stage]
		//				==input==
		//				==output=
		.memtoregW(memtoregW),		.regwriteW(regwriteW),
        .hilotoregW(hilotoregW)
	);

	datapath dp(
		.clk(clk),	.rst(rst),
		//[fetch stage]
		//				==input==
		.instrF(instrF),
		//				==output=
		.pcF(pcF),
		//[decode stage]
		//				==input==
		.pcsrcD(pcsrcD),			.branchD(branchD),
		.jumpD(jumpD),				.jalD(jalD),
		.jrD(jrD),					.jrE(jrE),
		//				==output=
		.validBranchConditionD(validBranchConditionD), 			.opD(opD),
		.rsD(rsD),				.rtD(rtD),
		.functD(functD),
		//[execute stage]
		//				==input==
		.memtoregE(memtoregE),		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE), 	.balE(balE),
		.jalE(jalE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
        .mulOrdivE(mulOrdivE),
        .isSignE(isSignE),          .mdToHiloE(mdToHiloE),
		//				==output=
		.flushE(flushE),            .stallE(stallE),
		//[mem stage]
		//				==input==
		.memtoregM(memtoregM), 		.regwriteM(regwriteM),
		.readdataM(readdataM),
        .hilowriteM(hilowriteM),
        .hilotoregM(hilotoregM),    .hilosrcM(hilosrcM),
        .regToHilo_hiM(regToHilo_hiM),
        .regToHilo_loM(regToHilo_loM),
        .mdToHiloM(mdToHiloM),
		//				==output=
		.aluoutM(aluoutM),			.writedataM(writedataM),
		//[writeBack stage]
		//				==input==
		.memtoregW(memtoregW), 		.regwriteW(regwriteW),
        .hilotoregW(hilotoregW)
		//				==output=
	);

endmodule
