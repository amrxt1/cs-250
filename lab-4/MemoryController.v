module MemoryController(
	inout [15:0] db, //databus
	input [15:0] DO,
	output WE,
	output [15:0] DI,
	input db_dir
);

	assign WE = db_dir;
	assign DI = (db_dir == 1'b0) ? db : 16'bZ;
	assign db = (db_dir == 1'b1) ? DO : 16'bZ;
endmodule