module RegArray(
	//read data
	input [2:0] Rn,
	input [2:0] Rm,
	input [2:0] Rx,
	output [15:0] Rn_data,
	output [15:0] Rm_data,
	output [15:0] Rx_data,
	
	//write data
	input [2:0] Rd,
	input [15:0] Rd_data,
	
	//PC
	output [15:0] PC,
	
	//etc
	input Rw, // Register Write
	input clk,
	input Reset
);
	// registers
	reg [15:0] registers [7:0];
	
	assign Rn_data = registers[Rn];
	assign Rm_data = registers[Rm];
	assign Rx_data = registers[Rx];
	assign PC = registers[3'b111]; // PC is always reg7
	
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
		else if (Rw == 1'b1) begin
			if(Rd == 3'b111) begin
				registers[3'b111] <= Rd_data;
			end
			else begin
				registers[Rd] <= Rd_data;
				registers[3'b111] <= registers[3'b111] + 1;
			end
		end
	end

endmodule