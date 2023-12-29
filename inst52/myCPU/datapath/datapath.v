`include "../utils/defines2.vh"
`timescale 1ns / 1ps

module datapath(
	input clk,rst,
	//fetch stage
	input [31:0] instrF,
	output [31:0] pcF,
	//decode stage
	input pcsrcD,branchD,
	input jumpD,jalD,jrD,
	output reg validBranchConditionD,
	output [4:0] rsD,rtD,rdD,
	output [5:0] opD,functD,
	//execute stage
	input memtoregE,
	input alusrcE,regdstE,
	input regwriteE,
	input [4:0] alucontrolE,
	input balE, jalE, jrE,
    input hilotoregE, hilosrcE,
    input mulOrdivE,mdIsSignE,mdToHiloE,
	input [3:0] memwriteE,
	output flushE,stallE,
	//mem stage
	input memtoregM,
	input regwriteM,
    input hilowriteM,hilotoregM,hilosrcM,
	input [31:0] readdataM,
    input regToHilo_hiM,regToHilo_loM,mdToHiloM,
	input [3:0] memReadWidthM,
	input memLoadIsSignM,
	output [31:0] aluoutM,writedataExtendedM,
	output [3:0] memwrite_filterdM,
	//writeback stage
	input memtoregW,
	input regwriteW,
    input hilotoregW
);

    //测试数据，暂时用于代表乘法结果与除法结果
    wire [31:0] mulResult_hiE,mulResult_loE;//乘法结果
    wire [31:0] divResult_hiE,divResult_loE;//除法结果
	//fetch stage
	wire stallF;
	wire [31:0] pc_plus4F;

	//decode stage
	wire [31:0] pc_afterjumpD,pc_afterbranchD,pc_branch_offsetD;
	wire [31:0] pc_plus4D, pc_plus8D, instrD;
	wire forwardaD,forwardbD;
	wire jrstall_READ;
	wire stallD;
	wire [31:0] signimmD,signimm_slD;
	wire [31:0] srcaD,srca2D,srcbD,srcb2D,srca3D,srcb3D;
    wire [4:0] saD;
    wire [31:0] HID,LOD;

	//execute stage
	wire [1:0] forwardaE,forwardbE;
	wire [4:0] rsE,rtE,rdE;
	wire [4:0] writeregE;
	wire [31:0] pc_plus4E, pc_plus8E;
	wire [31:0] signimmE;
	wire [31:0] srcaE,srca2E,srcbE,srcb2E,srcb3E;
	wire [31:0] aluoutE;
    wire [4:0] saE;
    wire [31:0] HIE,HI2E,LOE,LO2E;
    wire forwardHIE,forwardLOE;
    wire [31:0] mdResult_hiE,mdResult_loE;
    //除法完成需要36个周期，因此在除法完成前，如若没有强行中断除法运算的特殊情况发生，流水线必须stall
    //以下是一个简单的状态机，针对的是进行除法运算
    wire div_readyE;
    reg start_divE,stall_divE;
    always @(*)begin
        case({mdToHiloE,mulOrdivE})
            2'b10:begin
                if(div_readyE == 1'b0) begin start_divE = 1'b1;stall_divE = 1'b1; end
                else if(div_readyE == 1'b1 ) begin start_divE = 1'b0;stall_divE = 1'b0; end
            end
            default: begin start_divE = 1'b0;stall_divE = 1'b0; end
        endcase
    end

	//mem stage
	wire [4:0] writeregM;
    wire [31:0] srcaM;
    wire [31:0] HIM,HI2M,LOM,LO2M;
    wire [31:0] hilooutM;
    wire [31:0] mdResult_hiM,mdResult_loM;
	wire [31:0] writedataM;
	wire [3:0] memwriteM;

	//writeback stage
	wire [4:0] writeregW;
	wire [31:0] aluoutW,readdataW,resultW,hilooutW;
	wire [31:0] result_filterdW;
	wire [3:0] memReadWidthW;
	wire memLoadIsSignW;



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
	mux2 forwardJR(srca2D,readdataM,jrstall_READ, srca3D);
	assign srcb3D = srcb2D;
	// 其实只有srca有可能是jr前推的结果，才会有srca3D，但为了整齐将srcb3D也写上了

	// [decode]
	assign opD = instrD[31:26];
	assign functD = instrD[5:0];
	assign rsD = instrD[25:21];
	assign rtD = instrD[20:16];
	assign rdD = instrD[15:11];
    assign saD = instrD[10:6];
	// 提前在decode判断branch
	// 根据指令不同，判断是否valid的格式也不同

	always @(*) begin
		case(opD)
			`BEQ: validBranchConditionD = (srca3D == srcb3D);
			`BNE: validBranchConditionD = (srca3D != srcb3D);
			`BGTZ: validBranchConditionD = (~srca3D[31]) & (srca3D != 32'd0);
			`BLEZ: validBranchConditionD = (srca3D[31]);
			`BG_EXT_INST: begin // BG_EXT_INST = 000001, contains: BGEZ,BLTZ,BGEZAL,BLTZAL,
				case(rtD)
					`BGEZ: validBranchConditionD = (~srca3D[31]);
					`BLTZ: validBranchConditionD = (srca3D[31]) | (srca3D == 32'd0);
					`BGEZAL: validBranchConditionD = (~srca3D[31]);
					`BLTZAL: validBranchConditionD = (srca3D[31]);
					default: validBranchConditionD = 1'b0;
				endcase
			end
		endcase
	end

	// [decode -> execute]
	// 暂存
	flopenrc r1E(clk,rst,~stallE,flushE,srcaD,srcaE);
	flopenrc r2E(clk,rst,~stallE,flushE,srcbD,srcbE);
	flopenrc r3E(clk,rst,~stallE,flushE,signimmD,signimmE);
	flopenrc #(5) r4E(clk,rst,~stallE,flushE,rsD,rsE); // 如果只有暂存，rsD没必要推过去，但rsE对hazard前推有用
	flopenrc #(5) r5E(clk,rst,~stallE,flushE,rtD,rtE);
	flopenrc #(5) r6E(clk,rst,~stallE,flushE,rdD,rdE);
    flopenrc #(5) r7E(clk,rst,~stallE,flushE,saD,saE);
	flopenrc #(32) r8E(clk,rst,~stallE,flushE,pc_plus8D,pc_plus8E);
    flopenrc r9E(clk,rst,~stallE,flushE,HID,HIE);
    flopenrc r10E(clk,rst,~stallE,flushE,LOD,LOE);
	// 前推
	mux3 forwardaemux(srcaE,result_filterdW,aluoutM,forwardaE,srca2E);
	mux3 forwardbemux(srcbE,result_filterdW,aluoutM,forwardbE,srcb2E);
    mux2 forwardHIEmux(HIE,HI2M,forwardHIE,HI2E);
    mux2 forwardLOEmux(LOE,LO2M,forwardLOE,LO2E);

	// [execute -> mem]
	// 暂存
	flopr r1M(clk,rst,srcb2E,writedataM);
	flopr r2M(clk,rst,aluoutE,aluoutM);
	flopr #(5) r3M(clk,rst,writeregE,writeregM);
    flopr r5M(clk,rst,srca2E,srcaM);
    flopr r6M(clk,rst,HI2E,HIM);
    flopr r7M(clk,rst,LO2E,LOM);
    flopr r8M(clk,rst,mdResult_hiE,mdResult_hiM);
    flopr r9M(clk,rst,mdResult_loE,mdResult_loM);
	flopr #(4) r10M(clk,rst,memwriteE,memwriteM);
    // 更新hilo_reg前，确定HI、LO
    mux3 mux_HI2M(HIM,mdResult_hiM,srcaM,{regToHilo_hiM,mdToHiloM},HI2M);
    mux3 mux_LO2M(LOM,mdResult_loM,srcaM,{regToHilo_loM,mdToHiloM},LO2M);

	// [mem -> writeBack]
	// 暂存
	flopr r1W(clk,rst,aluoutM,aluoutW);
	flopr r2W(clk,rst,readdataM,readdataW);
	flopr #(5) r3W(clk,rst,writeregM,writeregW);
    flopr r4W(clk,rst,hilooutM,hilooutW);
	flopr #(4) r5W(clk,rst,memReadWidthM,memReadWidthW);
	flopr #(1) r6W(clk,rst,memLoadIsSignM,memLoadIsSignW);


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
		.jrD(jrD),
		.forwardaD(forwardaD),
		.forwardbD(forwardbD),
		.stallD(stallD),
		.jrstall_READ(jrstall_READ),
		//execute stage
		.rsE(rsE),
		.rtE(rtE),
		.writeregE(writeregE),
		.regwriteE(regwriteE),
		.memtoregE(memtoregE),
        .hilotoregE(hilotoregE),
        .hilosrcE(hilosrcE),
        .stall_divE(stall_divE),
		.forwardaE(forwardaE),
		.forwardbE(forwardbE),
		.flushE(flushE),
        .forwardHIE(forwardHIE),
        .forwardLOE(forwardLOE),
        .stallE(stallE),
		//mem stage
		.writeregM(writeregM),
		.regwriteM(regwriteM),
		.memtoregM(memtoregM),
        .hilowriteM(hilowriteM),
        .regToHilo_hiM(regToHilo_hiM),
        .regToHilo_loM(regToHilo_loM),
        .mdToHiloM(mdToHiloM),
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

	wire [31:0] pc_next_addr;

	// [Fetch] PC 模块
	flopenr pcreg(clk,rst,~stallF,pc_next_addr,pcF);
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

	// [Decode] 【特殊情况】如果是BAL或者JAL的操作，pc+8的内容要写入31号寄存器，需要将pc+8传到后面的EXE阶段
	//					  如果是JALR的操作，pc+8的内容要写入rd号寄存器
	adder adder_plus8(pc_plus4D,32'd4,pc_plus8D);

	// [Decode] 判断是否执行jump
	mux2 mux_PCJump(
		pc_afterbranchD,
		{pc_plus4D[31:28],instrD[25:0],2'b00},
		jumpD,
		pc_afterjumpD
	);

	// [Decode] 【特殊情况】如果是JR或者JALR，那么无条件跳转的值为寄存器rs中的值
	wire [31:0] pc_jr = srca2D;
	// assign pc_next_addr = pc_afterjumpD;
	mux2 mux_is_jr(pc_afterjumpD,pc_jr,jrD,pc_next_addr);


    // ====================================
    // Data部分
    // ====================================


	wire [4:0] writereg_tempE; // 存储通过regdst得到的寄存器号，但有可能被BAL、JAL、JALR覆盖
	wire is_al_instruction;
	// [Execute] 决定 write register 是 rt 还是 rd
	mux2 #(5) mux_regdst(rtE,rdE,regdstE,writereg_tempE);
	// [Execute] 【特殊情况】如果是BAL或者JAL的操作，那么会被强制写回31号寄存器
	//					   但如果是JALR的操作，那么不会覆盖，而是用rd写入
	assign is_al_instruction = (balE | jalE) & (~(jrE & jalE));
	mux2 #(5) mux_regdst_al(writereg_tempE, 5'd31, is_al_instruction, writeregE);
    // [Execute] 决定使用乘法结果-mulResult还是除法结果-divResult
    mux2 mux_mdresult_hi(divResult_hiE,mulResult_hiE,mulOrdivE,mdResult_hiE);
    mux2 mux_mdresult_lo(divResult_loE,mulResult_loE,mulOrdivE,mdResult_loE);


	wire [31:0] aluout_tempE; // 存储从ALU出来的结果，但有可能被BAL或JAL覆盖
    // [Execute] 针对寄存器堆，进行操作
	regfile register(clk,rst,regwriteW,rsD,rtD,writeregW,result_filterdW,srcaD,srcbD);
    // [Execute] 判断ALU收到的srcB是RD2还是SignImm
	mux2 mux_ALUsrc(srcb2E,signimmE,alusrcE,srcb3E);
    // [Execute] ALU运算，控制冒险提前判断了branch，不再需要zero
	alu alu(srca2E,srcb3E,saE,alucontrolE,aluout_tempE);
	// [Execute] 【特殊情况】如果是BAL或者JAL的操作，pc+8的内容要写入31号寄存器，需要将pc+8作为aluout的结果
	//					   如果是JALR的操作，同样要写入pc+8
	mux2 mux_ALUout(aluout_tempE, pc_plus8E, (balE | jalE), aluoutE);
    // [Execute] 乘法运算
    mul mul(srca2E,srcb3E,mdIsSignE,mulResult_hiE,mulResult_loE);
    // [Execute] 除法运算
    div div(clk,rst,mdIsSignE,srca2E,srcb3E,start_divE,flushE,{divResult_hiE,divResult_loE},div_readyE);

    // [Memory] 写hilo_reg
    hilo_reg hilo(clk,rst,hilowriteM,HI2M,LO2M,HID,LOD);
    // [Memory] 决定 write rd是 HI,还是LO
    mux2 mux_rddst(LO2M,HI2M,hilosrcM,hilooutM);
	// [Memory] 在向内存写入之前，需要将写入数据扩展成32位
	memwrite_extend memwrite_extend(writedataM, memwriteM, writedataExtendedM);
	// [Memory] 在向内存写入之前，如果是SW指令还需要进行写入地址的选择
	memwrite_filter memwrite_filter(aluoutM,memwriteM,memwrite_filterdM);

    // [WriteBack] 判断写回寄存器堆的是：从ALU出来的结果（可能被BAL、JAL或JALR覆盖） or 从数据存储器读取的data or HI/LO寄存器的数据
	// mux2 mux_regwriteData(aluoutW,readdataW,memtoregW,resultW);
    mux3 mux_regwriteData(aluoutW,readdataW,hilooutW,{hilotoregW,memtoregW},resultW);

	// [WriteBack] 对于从内存中读出的数据，如果是Load指令（尤其是LH,LB），需要进行数据选择以及扩展
	// 传出来的result_load_filterd即是LW/LH/lB最终的写回数据
	// 当然，如果不是LW/LH/LB指令，那么传出来的东西不变
	memload_filter #(32) memload_filter(aluoutW,resultW,memReadWidthW,memLoadIsSignW,result_filterdW);
endmodule
