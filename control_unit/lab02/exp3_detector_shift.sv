module shift4(input wire clk, reset_n, sample, output reg [3:0] q);
    always @(posedge clk)
        if (!reset_n) q<=0;
        else q<={q[2:0],sample};
endmodule

module detector_shift(input wire clk, reset_n, w, output wire [3:0] ones, zeros,
    output wire z);
    shift4 count_ones(clk,reset_n,w,ones);
    shift4 count_zeros(clk,reset_n,~w,zeros);
    assign z = (&ones) | (&zeros);
endmodule
