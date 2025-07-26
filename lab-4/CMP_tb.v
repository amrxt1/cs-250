`timescale 1ns/100ps

module CMP_tb;
    reg clk_sig;
    reg [15:0] rn;
    reg [15:0] rm;
    reg [3:0] cond;
    reg e;
    wire [15:0] sub;
    wire z;
    wire n;
    wire c;

    always begin
        #1 clk_sig = ~clk_sig;
    end

    CMP dut(
        .rn_data(rn),
        .rm_data(rm),
        .cond(cond),
        .e(e),
        .clk(clk_sig),
        .s(sub),
        .c(c),
        .z(z),
        .n(n)
    );

    initial begin
        rn <= 16'h0000;
        rm <= 16'h0000;
        cond <= 4'b0000;
        e <= 1'b0;
        clk_sig <= 1'b0;

		  @(posedge clk_sig);
        rn <= 16'h0004;
		  rm <= 16'h0004;

		  @(posedge clk_sig);
        rn <= 16'h0009;
		  rm <= 16'h0008;

		  @(posedge clk_sig);
        rn <= 16'h0006;
		  rm <= 16'h0007;

        #5 $stop;
    end

endmodule
