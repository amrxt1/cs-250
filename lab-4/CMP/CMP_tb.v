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
        clk_sig <= 1'b0;
        e <= 1'b1;
        
        // EQ
        rn <= 16'h0005; rm <= 16'h0005; cond <= 4'b0000;
        @(posedge clk_sig);
        
        // NE
        rn <= 16'h0005; rm <= 16'h0003; cond <= 4'b0001;
        @(posedge clk_sig);
        
        // CS
        rn <= 16'h0008; rm <= 16'h0005; cond <= 4'b0010;
        @(posedge clk_sig);
        
        // CC
        rn <= 16'h0003; rm <= 16'h0008; cond <= 4'b0011;
        @(posedge clk_sig);
        
        // MI
        rn <= 16'h0003; rm <= 16'h0008; cond <= 4'b0100;
        @(posedge clk_sig);
        
        // PL
        rn <= 16'h0008; rm <= 16'h0003; cond <= 4'b0101;
        @(posedge clk_sig);
        
        // VS
        rn <= 16'h7FFF; rm <= 16'h8000; cond <= 4'b0110;
        @(posedge clk_sig);
        
        // VC
        rn <= 16'h0005; rm <= 16'h0003; cond <= 4'b0111;
        @(posedge clk_sig);
        
        // HI
        rn <= 16'h0008; rm <= 16'h0005; cond <= 4'b1000;
        @(posedge clk_sig);
        
        // LS
        rn <= 16'h0005; rm <= 16'h0005; cond <= 4'b1001;
        @(posedge clk_sig);
        
        // GE
        rn <= 16'h0008; rm <= 16'h0005; cond <= 4'b1010;
        @(posedge clk_sig);
        
        // LT
        rn <= 16'h0003; rm <= 16'h0008; cond <= 4'b1011;
        @(posedge clk_sig);
        
        // GT
        rn <= 16'h0008; rm <= 16'h0005; cond <= 4'b1100;
        @(posedge clk_sig);
        
        // LE
        rn <= 16'h0005; rm <= 16'h0008; cond <= 4'b1101;
        @(posedge clk_sig);
        
        // AL
        rn <= 16'h0000; rm <= 16'hFFFF; cond <= 4'b1110;
        @(posedge clk_sig);
        
        // NV
        rn <= 16'h0005; rm <= 16'h0005; cond <= 4'b1111;
        @(posedge clk_sig);
        
        // test e=0
        e <= 1'b0;
        rn <= 16'h1234; rm <= 16'h5678; cond <= 4'b0000;
        @(posedge clk_sig);
        
        $stop;
    end
endmodule