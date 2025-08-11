module ALU(
	input [3:0] OpcodeB,
	input [15:0] Immediate,
	input [1:0] Mode,
	input [15:0] Rn_data,
	input [15:0] Rm_data,
	
	input useAU,
	
	output [15:0] Rd_data
);

	wire [15:0] lu_out, au_out;
	
	LU lu(
	.OpcodeB(OpcodeB),
	.Rn_data(Rn_data),
	.Rm_data(Rm_data),
	
	.Rd_data(lu_out)
	);
	
	AU au(
	.OpcodeB(OpcodeB[2:0]),
	.Rn_data(Rn_data),
	.Rm_data(Rm_data),
	.Immediate(Immediate),
	.Mode(Mode),
	.Rd_data(au_out)
	);
	
	assign Rd_data = (useAU) ? au_out : lu_out;

endmodule