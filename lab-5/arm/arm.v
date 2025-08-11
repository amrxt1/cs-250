module arm(	
	input [1:0] KEY,
	output [9:0] LEDR,
	input CLOCK_50,
	output [6:0] HEX0, HEX1, HEX2, HEX3, HEX4, HEX5
);

	wire UseImm, RegWrite, UseAU, MemWrite, MemRead, dbDirection, makeCMP, b_instr, b_taken;
	wire [2:0] Rn, Rm, Rx, Rd, Mode;
	wire [3:0] ALUop, cond;
	
	wire [15:0] Rn_data, Rm_data, Rx_data, Rd_data, Immediate, pc, aluOut, dataBus, branchTo, instr;
	
	// clk
	reg [25:0] counter;
//	reg clk;
	assign clk = ~KEY[0];
//	
//	always @(posedge CLOCK_50) begin
//		if (counter == 26'd25_000_000) begin  // 1Hz clock
//			counter <= 0;
//			clk <= ~clk;
//		end else begin
//			counter <= counter + 1;
//		end
//	end
	
	
	wire [15:0] instr_addr, instr_din;
	//Instruction Cache (temporary)
	InstructionCache ic(
		.address(instr_addr),
		.instruction(instr_din)
	);
	//Fetching
	InstructionFetch ifetch(
		.clk(clk),
		.PC(pc),
		.address(instr_addr),
		.din(instr_din),
		.instruction(instr)
	);

	// Decoding
	InstructionDecoder id(
		//inputs
			.instruction(instr),
	
		//outputs
			.Rn(Rn),
			.Rm(Rm),
			.Rx(Rx),
			.Rd(Rd),
		//imm-extended
			.Immediate(Immediate),
		//conditional stuff
			.cond(),
		//control signals
			.RegEnable(RegWrite),
			.UseImm(UseImm),
			.UseAU(UseAU),
			.ALUop(ALUop),
			.Mode(Mode),
			.MemWrite(MemWrite),
			.db_dir(dbDirection),
			.cond(cond),
			.makeCMP(makeCMP),
			.branch(b_instr)
	);
	
	//Execution
	ALU alu(
	.OpcodeB(ALUop),
	.Rn_data(Rn_data),
	.Rm_data(Rm_data),
	.Immediate(Immediate),
	.Mode(Mode),
	.useAU(UseAU),
	.Rd_data(aluOut)
	);
	
	// switch bw regular rd_data and a new PC value
	wire [15:0] rd_in;
	assign rd_in = (b_instr) ? branchTo : Rd_data;
	RegArray regArr(
	//read data
	.Rn(Rn),
	.Rn_data(Rn_data),
	.Rm(Rm),
	.Rm_data(Rm_data),
	.Rx(Rx),
	.Rx_data(Rx_data),
	
	.PC(pc),
	
	
	//write data
	.Rd(Rd),
	.Rd_data(rd_in),
	
	//etc
	.Rw(RegWrite), // Register Write
	.clk(clk),
	.Reset(~KEY[1])
	);
	
	MemoryController mem_ctrl(
		.address(aluOut),
		.db(dataBus),
		.DO(16'hFF01),
		.db_dir(dbDirection)
		// assign DI to memoryModule
		// assign WE to memoryModule
	);
	DataBusController db_ctrl(
		.ALU(aluOut),
		.db(dataBus),
		.Rd_data(Rd_data),
		.Rx_data(Rx_data),
		.db_dir(dbDirection)
	);
	
	CMP cmp(
		.Rn_data(Rn_data),
		.Rm_data(Rm_data),
		.Immediate(Immediate),
		.cond(cond),
		.e(makeCMP),
		.clk(clk),
		
		.F(b_taken)
	);
	
	Branch bq(
		.branch_taken(b_taken),
		.Immediate(Immediate),
		.PC(pc),
		
		.newPC(branchTo)
	);
	// always display PC
	HexDecoder h0(.bin(pc[3:0]), .seg(HEX0));
	HexDecoder h1(.bin(pc[7:4]), .seg(HEX1));
	HexDecoder h2(.bin(pc[11:8]), .seg(HEX2));
	HexDecoder h3(.bin(pc[15:12]), .seg(HEX3));
	// display first 4 bits of rd (rd or newPC)
	HexDecoder h4(.bin(rd_in[3:0]), .seg(HEX4));
	HexDecoder h5(.bin(rd_in[7:4]), .seg(HEX5));

endmodule