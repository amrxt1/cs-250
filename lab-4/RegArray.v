module RegArray(
	//read data
	input [2:0] Rn,
	input [2:0] Rm,
	output [15:0] Rn_data,
	output [15:0] Rm_data,

	//write data
	input [2:0] Rd,
	input [15:0] Rd_data,

	//etc
	input clk,
	input Reset
);
	// registers
	reg [15:0] registers [7:0];

	assign Rn_data = registers[Rn];
	assign Rm_data = registers[Rm];

	always @(posedge clk) begin
		if (Reset) begin
			registers[3'b000] <= 16'h0000;
			registers[3'b001] <= 16'h0000;
			registers[3'b010] <= 16'h0000;
			registers[3'b011] <= 16'h0000;
			registers[3'b100] <= 16'h0000;
			registers[3'b101] <= 16'h0000;
			registers[3'b110] <= 16'h0000;
			registers[3'b111] <= 16'h0000;
		end
		else begin
			registers[Rd] <= Rd_data;
		end
	end

endmodule
