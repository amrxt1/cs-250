`timescale 1ns/100ps

module CMP_tb;
    reg clk_sig;
    reg [15:0] rn;
    reg [15:0] rm;
    reg [3:0] cond;
    reg e;
    wire f;

    always begin
        #1 clk_sig = ~clk_sig;
    end

    CMP dut(
        .Rn_data(rn),
        .Rm_data(rm),
        .cond(cond),
        .e(e),
        .clk(clk_sig),
		  .F(f)
    );

    initial begin
        rn <= 16'h0000;
        rm <= 16'h0000;
        cond <= 4'bXXXX;
        e <= 1'b1;
        clk_sig <= 1'b0;

		  @(posedge clk_sig);
		  cond <= 4'b0001;
        rn <= 16'h0004;
		  rm <= 16'h0004;

		  @(posedge clk_sig);
        rn <= 16'h0009;
		  rm <= 16'h0008;

		  @(posedge clk_sig);
        rn <= 16'h0006;
		  rm <= 16'h0007;

		  @(posedge clk_sig);
        rn <= 16'h7FFF;
        rm <= 16'h8000;

		  @(posedge clk_sig);
		  rn <= 16'hFFFF;
		  rm <= 16'h0001;

		  @(posedge clk_sig);
		  rn <= 16'h8000;
  		  rm <= 16'h7FFF;

		  @(posedge clk_sig);
		  rn <= 16'hFFFE;
		  rm <= 16'hFFFF;

		  #5 $stop;
    end

endmodule
