module AU(
	input [2:0] OpcodeB,
	input [16:0] Immediate,
	input [1:0] Mode,
	input [15:0] Rn_data,
	input [15:0] Rm_data,
	
	output reg [15:0] Rd_data
);

	always @(*) begin
		case(OpcodeB)
			//MOV <Rd>, <Rn>
			3'b000: Rd_data = Rm_data;
		
			// Add-Sub
			3'b011: begin
				case(Mode)
					// Addition with Rd
					2'b00: Rd_data = Rn_data + Rm_data;
					// Subtraction with Rd
					2'b01: Rd_data = Rn_data - Rm_data;
					// Addition Imm
					2'b10: Rd_data = Rn_data + Immediate;
					// Subtraction Imm
					2'b11: Rd_data = Rn_data - Immediate;
				endcase
			end
			//MOV Rd <= Imm
			3'b100: Rd_data = Immediate;
			//Add Rd <= Rn + Imm
			3'b110: Rd_data = Rn_data + Immediate;
			//Sub Rd <= Rn + Imm
			3'b111: Rd_data = Rn_data - Immediate;
			
			default: Rd_data = 16'b0;
		endcase
	end

endmodule