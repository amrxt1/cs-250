module InstructionFetch(
	input clk,
	// address to fetch from cache/mem
	input [15:0] PC,
	// address sent to cache
	output [15:0] address,
	// data recieved from cache/mem
	input [15:0] din,
	// data sent to instructionDecoder
	output reg [15:0] instruction
);
	assign address = PC;
	always @(posedge clk) begin
		instruction <= din;
	end
	
endmodule