module InstructionCache(
	input [15:0] address,
	output reg [15:0] instruction
);

	always @(*) begin
		case(address)
			16'd0: instruction = 16'b0011000000000010;
			16'd1: instruction = 16'b1110000000000000;
			
			default: instruction = 16'b1111111111111111; //NOP
		endcase
	end

endmodule