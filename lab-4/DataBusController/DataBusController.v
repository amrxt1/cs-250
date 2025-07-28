module DataBusController(
	inout [15:0] db,
	input [15:0] ALU,
	input [15:0] Rx_data,
	input db_dir,
	
	output [15:0] Rd_data
	);
	
	assign db = (db_dir == 0) ? Rx_data : 16'hZ;
	assign Rd_data = (db_dir == 0) ? ALU : db;
	
endmodule