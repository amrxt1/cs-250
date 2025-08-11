module InstructionDecoder(
	//inputs
	input [15:0] instruction,
	
	//outputs
	output reg [2:0] Rn,
	output reg [2:0] Rm,
	output reg [2:0] Rx,
	output reg [2:0] Rd,
	
	//imm-extended
	output reg [15:0] Immediate,
	
	//conditional stuff
	output reg [3:0] cond,
	
	output reg UseAU,
	output reg [3:0] ALUop,
	output reg [1:0] Mode,
	
	//control signals
	output reg RegEnable,
	output reg UseImm,
	output reg makeCMP,
	output reg MemRead,
	output reg MemWrite,
	output reg db_dir,
	output reg branch
);

	//deciding what to do
	always @(*) begin
	// Default assignments
		Rn = 3'b000;
		Rm = 3'b000;
		Rx = 3'b000;
		Rd = 3'b000;
		Immediate = 16'b0000000000000000;
		cond = 4'b0000;
		UseAU = 1'b0;
		ALUop = 4'b0000;
		Mode = 2'b00;
		RegEnable = 1'b0;
		UseImm = 1'b0;
		makeCMP = 1'b0;
		MemRead = 1'b0;
		MemWrite = 1'b0;
		db_dir = 1'b0;
		branch = 1'b0;

	casez(instruction[15:10])
		// MOV <Rd>, <Rm>
			6'b000000: begin
				RegEnable = 1'b1;
				Rm = instruction[5:3];
				Rd = instruction[2:0];
				UseAU = 1'b1;
				ALUop = 4'b0000;
				db_dir = 1'b0;
			end
		// Addition/ Subtraction
			6'b00011?: begin
				UseAU = 1'b0;
				ALUop = 4'b0011;
				case(instruction[15:9])
					// ADDS <Rd>, <Rn>, <Rm>
					// SUBS <Rd>, <Rn>, <Rm>
					7'b0001100, 7'b0001101: begin
						RegEnable = 1'b1;
						db_dir = 1'b0;
						Rd = instruction[2:0];
						Rn = instruction[5:3];
						Rm = instruction[8:6];
						Mode = instruction[9] ? 2'b01 : 2'b00;
					end
					// ADDS <Rd>, <Rn>, #<imm3>
					// SUBS <Rd>, <Rn>, #<imm3>
					7'b0001110, 7'b0001111: begin
						UseImm = 1'b1;
						RegEnable = 1'b1;
						Rd = instruction[2:0];
						Rn = instruction[5:3];
						Immediate = {13'b0, instruction[8:6]};
						Mode = instruction[9] ? 2'b11 : 2'b10;
					end
				endcase
			end
			
		// MOVS <Rd>, #<imm8>
			6'b00100?: begin
				UseImm = 1'b1;
				RegEnable = 1'b1;
				Rd = instruction[10:8];
				Immediate = {8'b0, instruction[7:0]};
				
				ALUop = 4'b0100;
				UseAU = 1'b1;
			end
		
		// CMP <Rn>, #<imm8>
			6'b00101?: begin
				RegEnable = 1'b0;
				
				Rn = instruction[10:8];
				UseImm = 1'b1;
				Immediate = {8'b0, instruction[7:0]};
				
				makeCMP = 1'b1;
			end
			
		// ADDS <Rdn>, #<imm8> 
			6'b00110?: begin
				ALUop = 4'b0110;
				
				UseAU = 1'b1;
				UseImm = 1'b1;
				RegEnable = 1'b1;
				// Rdn = Rn = Rd
				Rd = instruction[10:8];
				Rn = instruction[10:8];
				Immediate = {8'b0, instruction[7:0]};
			end
		// SUBS <Rdn>, #<imm8> 
			6'b00111?: begin
				ALUop = 4'b0111;
				
				UseAU = 1'b1;
				UseImm = 1'b1;
				RegEnable = 1'b1;
				// Rdn = Rn = Rd
				Rd = instruction[10:8];
				Rn = instruction[10:8];
				Immediate = {8'b0, instruction[7:0]};
			end
		
		// Logical OPS
			6'b010000: begin
				UseAU = 1'b0;
				case(instruction[9:6])
					// ANDS <Rdn>, <Rm>
					4'b0000: begin
						RegEnable = 1'b1;
						Rd = instruction[2:0];
						Rn = instruction[2:0];
						Rm = instruction[5:3];
						ALUop = 4'b0000;
					end
					// EORS <Rdn>, <Rm>
					4'b0001: begin
						RegEnable = 1'b1;
						Rd = instruction[2:0];						
						Rm = instruction[5:3];
						Rn = instruction[2:0];
						ALUop = 4'b0001;
					end
					// CMP <Rn>, <Rm>
					4'b1010: begin
						RegEnable = 1'b0;
						Rm = instruction[5:3];
						Rn = instruction[2:0];
						makeCMP = 1'b1;
					end
					// ORRS <Rdn>, <Rm>
					4'b1100: begin
						RegEnable = 1'b1;
						Rm = instruction[5:3];
						Rd = instruction[2:0];						
						Rn = instruction[2:0];
						ALUop = 4'b1100;
					end
					//MVNS <Rd>, <Rm>
					4'b1111: begin
						RegEnable = 1'b1;
						Rm = instruction[5:3];
						Rd = instruction[2:0];
						ALUop = 4'b1111;
					end
					// don't care
					default: begin
						RegEnable = 1'b0;
					end
				endcase
			end
			
		// Memory Load (PC with offset)
			6'b01001?: begin
				// LDR <Rt>, #<Imm8>
				// Rt_data <= MEM<PC+Immediate>
				//where data goes
				RegEnable = 1'b1;
				Rd = instruction[10:8];
				//where to get data
				MemRead = 1'b1; //from memory
				//at imm+pc[r7 or rn=7]
				UseImm = 1'b1;
				Immediate = { 8'b0, instruction[7:0]};//maybe signextend we'll see
				Rn = 3'b111;//use add rn+imm8 from alu
				UseAU = 1'b1;
				ALUop = 4'b0110;
				//aluOut is Imm+PC now which goes into address@emctrl
				//it also goes into dbctrl so we set db_dir to high
				db_dir = 1'b1;
				//now Rd_data <= db and db is DO which is dataOut from Memory
			end
			
		// Memory Load/ Store
			6'b0101??: begin
				case(instruction[11:9]) // using case incase more ops are needed
					// STR <Rt>, [<Rn>, <Rm>] 
					3'b000: begin
						// need MEM<Rn + Rm> <= <Rt>
						Rm = instruction[8:6];
						Rn = instruction[5:3];
						// add them. 
						ALUop = 4'b0011;
						Mode = 2'b00;
						UseAU = 1'b1;
						//rd_data sent to memCtrl and RegArray(ignored cause RW is low)
						db_dir = 1'b0;
						// when db_dir is 0, rx is sent to db which is set to DI 
						Rx = instruction[2:0];
						// rd_data is also set to ALUout so regenable is set to 0
						RegEnable = 1'b0;
						MemWrite = 1'b1;
					end
					// LDR <Rt>, [<Rn>, <Rm>]
					3'b100: begin
						// need <Rt> <= MEM<Rn + Rm>
						// enable writing and set Rd/Rt
						RegEnable = 1'b1;
						Rd = instruction[2:0];
						//calculate address
						Rm = instruction[8:6];
						Rn = instruction[5:3];
						//sum it; this is send to mem_ctrl addr
						ALUop = 4'b0011;
						Mode = 2'b00;
						UseAU = 1'b1;
						//when db_dir is high, db is driven by mem_ctrl
						//also, Rd_data <= db when db_dir is high
						db_dir = 1'b1;
						MemRead = 1'b1;
					end
				endcase
			end
			6'b0110??: begin
				// LDR <Rt>, [<Rn>, #<imm5>]
				if(instruction[11]) begin
					// need Rt <= MEM<Rn + Imm>
					// enable writing and set Rd/Rt
					RegEnable = 1'b1;
					Rd = instruction[2:0];
					Rn = instruction[5:3];
					Immediate = {11'b0, instruction[10:6]};
					//calculate address
					//sum Imm and Rn; this is send to mem_ctrl addr
					ALUop = 4'b0110;
					UseAU = 1'b1;
					//when db_dir is high, db is driven by mem_ctrl
					//also, Rd_data <= db when db_dir is high
					db_dir = 1'b1;
					MemRead = 1'b1;
				end
				// STR <Rt>, [<Rn>, #<imm5>]
				else begin
					// need MEM<Rn + #Imm5> <= <Rt>
					Rn = instruction[5:3];
					Immediate = {11'b0, instruction[10:6]};
					// add them. 
					ALUop = 4'b0110;
					UseAU = 1'b1;
					//rd_data sent to memCtrl and RegArray(ignored cause RW is low)
					db_dir = 1'b0;
					// when db_dir is 0, rx is sent to db which is set to DI 
					Rx = instruction[2:0]; // Rx <= Rt
					// rd_data is also set to ALUout so regenable is set to 0
					RegEnable = 1'b0;
					MemWrite = 1'b1;
				end
			end
			
		// Conditional Branching
			6'b1101??: begin
				// get condition label and imm5 from istr
				cond = instruction[11:8];
				Immediate = {8'b0, instruction[10:6]};
				// Write to PC
				Rd = 3'b111;
				branch = 1'b1; // uses data from Branch module
				RegEnable = 1'b1;
			end
			
		// UnConditional Branching
			6'b11100?: begin
				// Imm11 to jump to
				Immediate = {5'b0, instruction[10:0]};
				// Write to PC
				Rd = 3'b111;
				branch = 1'b1;
				cond = 4'b1110; //cond for B.ALways
				RegEnable = 1'b1;
			end
		
		endcase
	end

endmodule