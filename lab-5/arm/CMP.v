module CMP(
	input [15:0] Rn_data,
	input [15:0] Rm_data,
	input [15:0] Immediate,
	input [3:0] cond,
	input e,
	input clk,
	output reg F
	);
	reg z, n, c;
	//value fixing V to 1'b0
	wire v;
	assign v = 1'b0;
	
	wire [16:0] s; // wire for subtraction output
	assign s = {1'b0,Rn_data} - {1'b0, Rm_data}; // appending a 1'b0 to get the resulting overflow bit; used to check the C flag

	always @(posedge clk) begin
		if (e) begin
			z <= ~(|s[15:0]);
			n <= s[15];
			// could also use Verilog's syntax for this
			// c <= (rn_data >= rm_data) ? 1'b1 : 1'b0;  
			c <= ~s[16];
		end
	end
	
	always @(*) begin
		case(cond)
			4'b0000: F <= (z==1'b1) ? 1'b1 : 1'b0; //EQual
			4'b0001: F <= (z!=1'b1) ? 1'b1 : 1'b0; //NEqual
			4'b0010: F <= (c==1'b1) ? 1'b1 : 1'b0; //Unsigned greater or equal
			4'b0011: F <= (c==1'b0) ? 1'b1 : 1'b0; //Unsigned Lesser
			4'b0100: F <= (n==1'b1) ? 1'b1 : 1'b0; //Negative
			4'b0101: F <= (n==1'b0) ? 1'b1 : 1'b0; //Non-Negative
			4'b0110: F <= (v==1'b1) ? 1'b1 : 1'b0; //Overflow
			4'b0111: F <= (v==1'b0) ? 1'b1 : 1'b0; //No Overflow
			4'b1000: F <= (c & ~z) ? 1'b1 : 1'b0;  //Unsigned greater than
			4'b1001: F <= (~c | z) ? 1'b1 : 1'b0;  //Unsigned lesser or equal
			4'b1010: F <= ((n & v) | (~n & ~v)) ? 1'b1 : 1'b0; //Greater or Equal
			4'b1011: F <= (n ^ v) ? 1'b1 : 1'b0;   //Less than
			4'b1100: F <= (~z & ((n & v) | (~n & ~v))) ? 1'b1 : 1'b0; //Greater than
			4'b1101: F <= ((z) | (n ^ v)) ? 1'b1 : 1'b0; //less than
			4'b1110: F <= 1'b1; //BALways
			4'b1111: F <= 1'b0; //BNVer
			//
			default: F <= 1'b0;
		endcase
	end

endmodule
