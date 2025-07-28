`timescale 1ns/100ps

module RegArray_tb;
reg [2:0] rn;
reg [2:0] rm;
reg [2:0] rx;

reg [2:0] rd;
reg [15:0] rd_data;

wire [15:0] rn_data;
wire [15:0] rm_data;
wire [15:0] rx_data;

wire [15:0] PC;

reg clk;
reg reset;
reg Rw;

RegArray dut(
	.Rn(rn),
	.Rm(rm),
	.Rd(rd),
	.Rx(rx),
	.Rn_data(rn_data),
	.Rm_data(rm_data),
	.Rd_data(rd_data),
	.Rx_data(rx_data),
	.PC(PC),
	.clk(clk),
	.Reset(reset),
	.Rw(Rw)
);

always #1 clk <= ~clk;

initial begin
	#0
	clk <= 1'b0;
	reset <= 1'b1;
	rd_data <= 16'h0001;
	rn <= 3'b000;//r0
	rm <= 3'b001;//r1
	rx <= 3'b011;//r2
	Rw <= 1'b1;
	
	// write #1 to r0
	@(posedge clk);
	reset<= 1'b0;
	rd <= 3'b000;
	
	// write #2 to r1
	@(posedge clk);
	rd <= 3'b001;
	rd_data <= 16'h0002;
	
	// check reset
	@(posedge clk);
	reset <= 1'b1;
	// disable reset
	@(posedge clk);
	reset <= 1'b0; 
	
	// try writing with Rw low
	@(posedge clk);
	Rw <= 1'b0;
	rd_data <= 16'hffff;
	
	// try re-enabling Rw
	@(posedge clk);
	Rw <= 1'b1;
	
	// write to PC
	@(posedge clk);
	rd <= 3'b111;
	rd_data <= 16'hfff0;
	
	// check for proper PC update
	@(posedge clk);
	rd <= 3'b000;
	rd_data <= 16'b0;
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	
	// check writes to other reg(s)
	@(posedge clk);
	//read r2, r3, r4
	rn <= 3'b010;
	rm <= 3'b011;
	rx <= 3'b100;
	// write data
	rd_data <= 16'h00ff;
	rd <= 3'b010; // r2
	@(posedge clk);
	rd <= 3'b011; // r3
	@(posedge clk);
	rd <= 3'b100; // r4
	@(posedge clk);
	// switch reading
	rn <= 3'b101;
	rm <= 3'b110;
	//continue writing
	rd <= 3'b101; // r5
	@(posedge clk);
	rd <= 3'b110; // r6, r7 is alr tested above
	
	// observe
	@(posedge clk);
	@(posedge clk);
	@(posedge clk);
	$stop;
end

endmodule