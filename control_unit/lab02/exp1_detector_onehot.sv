module detector_onehot #(parameter MODIFIED=0)(input wire clk, reset_n, w,
    output wire [8:0] y, output wire z);
    // In Table 2 only bit zero has inverted meaning.
    wire a_state = y[0] ^ (MODIFIED != 0);
    wire [8:0] next_y;
    assign next_y[0] = MODIFIED != 0;
    assign next_y[1] = ~w & (a_state | (|y[8:5]));
    assign next_y[2] = ~w & y[1];
    assign next_y[3] = ~w & y[2];
    assign next_y[4] = ~w & (y[3] | y[4]);
    assign next_y[5] = w & (a_state | (|y[4:1]));
    assign next_y[6] = w & y[5];
    assign next_y[7] = w & y[6];
    assign next_y[8] = w & (y[7] | y[8]);
    for (genvar i=0; i<9; i++) begin : bit_ff
        detector_ff #(.RESET_BIT(i==0 && MODIFIED==0)) ff(clk,reset_n,next_y[i],y[i]);
    end
    assign z = y[4] | y[8];
endmodule


module detector_ff #(parameter RESET_BIT=0)(input wire clk,reset_n,d, output reg q);
    always @(posedge clk)
        if (!reset_n) q<=RESET_BIT;
        else q<=d;
endmodule
