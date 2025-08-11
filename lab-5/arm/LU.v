module LU(
	input [3:0] OpcodeB,
	input [15:0] Rn_data,
	input [15:0] Rm_data,
	
	output reg [15:0] Rd_data
);

	always @(*) begin
		casez(OpcodeB)
			4'b0000: Rd_data = Rn_data & Rm_data;
			4'b0001: Rd_data = Rn_data ^ Rm_data;
			4'b1100: Rd_data = Rn_data | Rm_data;
			4'b1111: Rd_data = ~Rn_data;
			default: Rd_data = 16'b0;
		endcase
	end
	
endmodule