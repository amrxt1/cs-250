module Branch(
	input branch_taken,
	input [15:0] Immediate,
	input [15:0] PC,
	
	output [15:0] newPC
);

	assign newPC = branch_taken ? Immediate : (PC + 16'd1);
	
endmodule