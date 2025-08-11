`timescale 1ns/100ps
module InstructionDecoder_tb();

	reg clk;
	reg [15:0] instruction;

	wire [2:0] Rn;
	wire [2:0] Rm;
	wire [2:0] Rx;
	wire [2:0] Rd;
	wire [15:0] Immediate;
	wire [3:0] cond;
	wire UseAU;
	wire [3:0] ALUop;
	wire [1:0] Mode;
	wire RegEnable;
	wire UseImm;
	wire makeCMP;
	wire MemRead;
	wire MemWrite;
	wire db_dir;
	wire branch;

	InstructionDecoder uut (
	.instruction(instruction),
	.Rn(Rn),
	.Rm(Rm),
	.Rx(Rx),
	.Rd(Rd),
	.Immediate(Immediate),
	.cond(cond),
	.UseAU(UseAU),
	.ALUop(ALUop),
	.Mode(Mode),
	.RegEnable(RegEnable),
	.UseImm(UseImm),
	.makeCMP(makeCMP),
	.MemRead(MemRead),
	.MemWrite(MemWrite),
	.db_dir(db_dir),
	.branch(branch)
	);

	always #1 clk = ~clk;

   initial begin
        #0
        clk = 1'b0;
		  
		  //Reg/Imm Arithemic OPS
        @(posedge clk);
		  // MOV <Rd>, <Rm>
        // Reg[Rd=1] <= Reg[Rm=0]
		  instruction = 16'b0000000000000001; 
        @(posedge clk);
		  // ADDS <Rd>, <Rn>, <Rm>
        // Reg[Rd=2] <= Reg[Rn=1] + Reg[Rm=6]
		  instruction = 16'b0001100110001010; 
        @(posedge clk);
		  // SUBS <Rd>, <Rn>, <Rm>
        // Reg[Rd=2] <= Reg[Rn=1] - Reg[Rm=6]
		  instruction = 16'b0001101110001010; 
		  // NOP
		  @(posedge clk);
		  instruction = 16'b1111111111111111; 
		  @(posedge clk);
		  // ADDS <Rd>, <Rn>, #<Imm3>
        // Reg[Rd=2] <= Reg[Rn=1] + #7
		  instruction = 16'b0001110111001010; 
        @(posedge clk);
		  // SUBS <Rd>, <Rn>, #<Imm3>
        // Reg[Rd=2] <= Reg[Rn=1] - #7
		  instruction = 16'b0001111111001010; 
        @(posedge clk);
		  // MOV <Rd>, #<Imm8>
        // Reg[Rd=0] <= #5
		  instruction = 16'b0010000000000101; 
        @(posedge clk);
		  // CMP <Rn>, #<Imm8>
        // COMPare Reg[Rn=4] and #1
		  instruction = 16'b0010110000000001; 
        @(posedge clk);
		  // ADDS <Rdn>, #<Imm8>
        // Reg[Rd=2] <= Reg[Rd=2] + #7
		  instruction = 16'b0011001000000111; 
        @(posedge clk);
		  // SUBS <Rdn>, #<Imm8>
        // Reg[Rd=0] <= Reg[Rd=0] - #7
		  instruction = 16'b0011100000000111;
        
		  @(posedge clk);
		  // NOP
		  instruction = 16'b1111111111111111;
		  
		  //Logical OPS REG
		  
		  @(posedge clk);
		  // AND R5 <= R5 and R6
		  instruction = 16'b0100000000110101;
        
		  @(posedge clk);
		  // EORS R2 <= R2 xor R5
		  instruction = 16'b0100000001101010;
		  
        @(posedge clk);
		  // CMP Rn=5, Rm=3
		  instruction = 16'b0100001010011101;
        
		  @(posedge clk);
		  // ORRS Rdn2 <= R2 or R1
		  instruction = 16'b0100001100001010;
        
		  @(posedge clk);
		  // MVNS Rd3 <= not Rm2
		  instruction = 16'b0100001111010011;
        
		  @(posedge clk);
		  // NOP
		  instruction = 16'b1111111111111111;
		  
		  // LDR <Rt>, MEM<PC_data + Imm>
		  @(posedge clk);
		  // R6 <= MEM< R7 + #15 >
		  instruction = 16'b0100111000001111;
		  
		  // STR <Rt>, [<Rn>, <Rm>]
		  @(posedge clk);
		  // MEM< R2 + R3 > <= R1
		  instruction = 16'b0101000011010001;
		  
		  // LDR <Rt>, [<Rn>, <Rm>]
		  @(posedge clk);
		  // R6 <= MEM< R1 + R2 >
		  instruction = 16'b0101100010001110;
		  
		  // STR <Rt>, [<Rn>, #<Imm5>]
		  @(posedge clk);
		  // MEM< R2 + #8 > <= R1
		  instruction = 16'b0110001000010001;
		  
		  // LDR <Rt>, [<Rn>, #<Imm5>]
		  @(posedge clk);
		  // R6 <= MEM< R1 + #7 >
		  instruction = 16'b0110100111001110;
		  
		  @(posedge clk);
		  // NOP
		  instruction = 16'b1111111111111111;

		  // MOV <Rd>, #<Imm8>
        // Reg[Rd=0] <= #5
        @(posedge clk);
		  instruction = 16'b0010000000000101; 
		  
		  // CMP <Rn>, #<Imm8>
        // COMPare Reg[Rn=0] and #5
		  @(posedge clk);
		  instruction = 16'b0010100000000101; 
        
		  // B.<NE> #11
		  @(posedge clk);
		  // PC/R7 <= #11
		  instruction = 16'b1101000100001011;
		  
		  // B.<EQ> #11
		  @(posedge clk);
		  // PC/R7 <= #11
		  instruction = 16'b1101000000001011;
		  
		  // B.AL #2
		  @(posedge clk);
		  // R6 <= MEM< R1 + #7 >
		  instruction = 16'b1110000000000010;
		  
		  
        @(posedge clk);
        $stop;
    end

endmodule