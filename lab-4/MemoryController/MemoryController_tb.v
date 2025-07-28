`timescale 1ns/100ps

module MemoryController_tb;
//databus stuff
wire [15:0] db;
//reg to "drive" db signal
reg [15:0] db_driver;
assign db = db_driver;

//rest of the signals
reg [15:0] DO;
reg db_dir;

wire WE;
wire [15:0] DI;

//clk to drive the tb
reg clk;
always #1 clk <= ~clk;

MemoryController dut(
	.db(db),
	.DO(DO),
	.WE(WE),
	.DI(DI),
	.db_dir(db_dir)
	);

initial begin
    #0
	 clk <= 1'b0;
    db_driver = 16'bZ;    
    db_dir <= 1'b0;
	 DO <= 16'h5555;
	 
	 @(posedge clk);
	 db_driver = 16'hF000; 
    
    @(posedge clk);
	 db_driver <= 16'hZ;
    db_dir <= 1'b1;      
    
    @(posedge clk);
    $stop;
end
endmodule