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
	wire regdstE,alusrcE,pcsrcD,memtoregE,memtoregM,memtoregW;
	wire regwriteE,regwriteM,regwriteW;
	wire [4:0] alucontrolE;
	wire flushE,equalD;
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
		.opD(opD), 					.functD(functD),
		.equalD(equalD),
		//				==output=
		.pcsrcD(pcsrcD),			.branchD(branchD),
		.jumpD(jumpD),
		//[execute stage]
		//				==input==
		.flushE(flushE),
			//output
		.memtoregE(memtoregE), 		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE),
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
		.jumpD(jumpD),
		//				==output=
		.equalD(equalD), 			.opD(opD),
		.functD(functD),
		//[execute stage]
		//				==input==
		.memtoregE(memtoregE),		.alusrcE(alusrcE),
		.regdstE(regdstE), 			.regwriteE(regwriteE),
		.alucontrolE(alucontrolE),
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
