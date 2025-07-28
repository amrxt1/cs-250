`timescale 1ns/100ps

module RegArray_tb;
reg [2:0] rn;
reg [2:0] rm;
reg [2:0] rd;
reg [15:0] rd_data;

wire [15:0] rn_data;
wire [15:0] rm_data;

reg clk;
reg reset;

RegArray dut(
	.Rn(rn),
	.Rm(rm),
	.Rd(rd),
	.Rd_data(rd_data),
	.Rn_data(rn_data),
	.Rm_data(rm_data),
	.clk(clk),
	.Reset(reset)
);

always #1 clk <= ~clk;

initial begin
	#0
	clk <= 1'b0;
	reset <= 1'b1;
	rd_data <= 16'h0001;
	rn <= 3'b000;
	rm <= 3'b001;

	@(posedge clk);
	reset<= 1'b0;
	rd <= 3'b000;

	@(posedge clk);
	rd <= 3'b001;
	rd_data <= 16'h0002;

	@(posedge clk);
	rd <= 3'b010;

	@(posedge clk);
	$stop;
end

endmodule
