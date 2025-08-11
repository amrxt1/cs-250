`timescale 1ns/100ps
module ALU_tb();
//inputs
reg [3:0] OpcodeB;
reg [15:0] Immediate;
reg [1:0] Mode;
reg [15:0] Rn_data;
reg [15:0] Rm_data;
reg useAU;

//etc
reg clk;
always #1 clk = ~clk;

//output
wire [15:0] Rd_data;

ALU dut
(
	.OpcodeB(OpcodeB),	
	.Immediate(Immediate),
	.Mode(Mode),	
	.Rn_data(Rn_data),
	.Rm_data(Rm_data),
	.useAU(useAU),
	.Rd_data(Rd_data) 
);


initial begin
	#0
	useAU = 1'b1;
	clk = 1'b0;
	
	
	@(posedge clk);
	Rn_data = 16'h0005;
	Rm_data = 16'h0004;
	Immediate = 16'h0001;
	
	//Addition
	@(posedge clk);
	OpcodeB = 4'b0011;
	Mode = 2'b00;
	//Subtraction
	@(posedge clk);
	Mode = 2'b01;
	//Add Imm3
	@(posedge clk);
	Mode = 2'b10;
	//Sub Imm3
	@(posedge clk);
	Mode = 2'b11;
	//Mov Rd <= imm8
	@(posedge clk);
	OpcodeB = 4'b0100;
	//Add imm8
	@(posedge clk);
	OpcodeB = 4'b0110;
	//Sub imm8
	@(posedge clk);
	OpcodeB = 4'b0111;
	
	//LU stuff
	//AND
	@(posedge clk);
	Mode = 2'b00;
	useAU = 1'b0;
	OpcodeB = 4'b0000;
	//XOR
	@(posedge clk);
	OpcodeB = 4'b0001;
	//OR
	@(posedge clk);
	OpcodeB = 4'b1100;
	//NOT
	@(posedge clk);
	Rn_data = 16'h0000;
	OpcodeB = 4'b1111;
	//stop
	@(posedge clk);
	$stop;

end

endmodule