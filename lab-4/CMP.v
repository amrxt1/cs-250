module CMP(
	input [15:0] rn_data,
	input [15:0] rm_data,
	input [3:0] cond,
	input e,
	input clk,
	output F,
	output [15:0] s,
	output reg n,c,z
);
	//skipping flag V
	wire v;
	assign v = 1'b0;

	// synthesized as 2's complement && cin-high
	assign s = rn_data - rm_data;

	always @(posedge clk) begin
		if (e) begin
			z <= ~(|s);
			n <= s[15];
			c <= s[15];
		end
	end

endmodule
