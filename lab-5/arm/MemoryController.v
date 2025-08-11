module MemoryController(
	inout [15:0] db, //databus
	input [15:0] address,
	input [15:0] DO, // data coming from mem
	input db_dir,
	output WE, // writeEnable
	output [15:0] DI, // going into memory
	output [15:0] addr
);
	assign addr = address;
	assign WE = db_dir;
	assign DI = (db_dir == 1'b0) ? db : 16'bZ;
	assign db = (db_dir == 1'b1) ? DO : 16'bZ;
endmodule