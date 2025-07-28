`timescale 1ns/100ps

module DataBusController_tb;

//databus stuff
wire [15:0] db;
reg [15:0] db_driver;
assign db = db_driver;
//inputs
reg [15:0] ALU;
reg [15:0] Rx_data;
reg db_dir;
//output
wire [15:0] Rd_data;

reg clk;
always #1 clk = ~clk;

initial begin
	#0
	clk <= 1'b0;
	
	// send alu to rd_data
	// The ability to direct ALU output to the register array;
	@(posedge clk);
	ALU <= 16'ha120;
	db_dir <= 1'b0;
	
	// send rx to db
	@(posedge clk);
	Rx_data <= 16'h1234;
	db_driver <= 16'bZ;
	
	// send db to rd_data
	@(posedge clk);
	db_dir <= 1'b1;
	db_driver <= 16'haaaa;

	@(posedge clk);
	$stop;
end

DataBusController dut(
	.db(db),
	.ALU(ALU),
	.Rx_data(Rx_data),
	.db_dir(db_dir),
	.Rd_data(Rd_data)
	);

endmodule