`timescale 10ns/100ps

module LU_tb;

reg [15:0] rn_data;
reg [15:0] rm_data;
wire [15:0] rd_data;
reg opB0;
reg opB1;
reg opB2;
reg opB3;

LU dut (
    .opB0(opB0),
    .opB1(opB1),
    .opB2(opB2),
    .opB3(opB3),
    .rn_data(rn_data),
    .rm_data(rm_data),
    .rd_data(rd_data)
);

initial begin
   rn_data = 16'b0000000000001100;
   rm_data = 16'b0000000000001010;
	opB0 = 1'b0;
	opB1 = 1'b0;
	opB2 = 1'b0;
	opB3 = 1'b0;
	
	#5
	opB0 = 1'b1;
	opB1 = 1'b0;
	opB2 = 1'b0;
	opB3 = 1'b0;
	#5
	opB0 = 1'b0;
	opB1 = 1'b0;
	opB2 = 1'b1;
	opB3 = 1'b1;
	#5
	opB0 = 1'b1;
	opB1 = 1'b1;
	opB2 = 1'b1;
	opB3 = 1'b1;
	#5
	$stop;
end

endmodule