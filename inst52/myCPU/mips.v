`timescale 1ns / 1ps

module mips(
	input clk,rst,
	input [31:0] instrF,
	input [31:0] readdataM,
	output [31:0] pcF,
	output memwriteM,hilowriteM,hilosrcM,
	output [31:0] aluoutM,writedataM
);

	wire [5:0] opD,functD;
	wire [4:0] rsD,rtD;
	wire regdstE,alusrcE,branchD,jalD,jrD,pcsrcD,memtoregE,memtoregM,memtoregW;
	wire balE,jalE,jrE,regwriteE,regwriteM,regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,validBranchConditionD;
    wire hilodstE;
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
		.flushE(flushE),
			//output
		.memtoregE(memtoregE), 		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE), 	.balE(balE),
		.jalE(jalE),				.jrE(jrE),
        .hilodstE(hilodstE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
		//[mem stage]
		//				==input==
		//				==output=
		.memtoregM(memtoregM),		.memwriteM(memwriteM),
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
        .hilodstE(hilodstE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
		//				==output=
		.flushE(flushE),
		//[mem stage]
		//				==input==
		.memtoregM(memtoregM), 		.regwriteM(regwriteM),
		.readdataM(readdataM),
        .hilowriteM(hilowriteM),
        .hilotoregM(hilotoregM),    .hilosrcM(hilosrcM),
		//				==output=
		.aluoutM(aluoutM),			.writedataM(writedataM),
		//[writeBack stage]
		//				==input==
		.memtoregW(memtoregW), 		.regwriteW(regwriteW),
        .hilotoregW(hilotoregW)
		//				==output=
	);

endmodule
