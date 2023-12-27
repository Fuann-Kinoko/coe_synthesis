`timescale 1ns / 1ps

module mips(
	input clk,rst,
	input [31:0] instrF,
	input [31:0] readdataM,
	output [31:0] pcF,
	output memwriteM,
	output [31:0] aluoutM,writedataM
);

	wire [5:0] opD,rsD,rtD,functD;
	wire regdstE,alusrcE,branchD,jalD,pcsrcD,memtoregE,memtoregM,memtoregW;
	wire balE,jalE,regwriteE,regwriteM,regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,validBranchConditionD;

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
		.jumpD(jumpD),
		//[execute stage]
		//				==input==
		.flushE(flushE),
			//output
		.memtoregE(memtoregE), 		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE), 	.balE(balE),
		.jalE(jalE),
		//[mem stage]
		//				==input==
		//				==output=
		.memtoregM(memtoregM),		.memwriteM(memwriteM),
		.regwriteM(regwriteM),
		//[writeBack stage]
		//				==input==
		//				==output=
		.memtoregW(memtoregW),		.regwriteW(regwriteW)
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
		//				==output=
		.flushE(flushE),
		//[mem stage]
		//				==input==
		.memtoregM(memtoregM), 		.regwriteM(regwriteM),
		.readdataM(readdataM),
		//				==output=
		.aluoutM(aluoutM),			.writedataM(writedataM),
		//[writeBack stage]
		//				==input==
		.memtoregW(memtoregW), 		.regwriteW(regwriteW)
		//				==output=
	);

endmodule
