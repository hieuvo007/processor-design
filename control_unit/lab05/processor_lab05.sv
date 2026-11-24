module processor_lab05(
    input wire [8:0] DIN, input wire Resetn,Clock,Run,
    output wire Done,W, output wire [8:0] BusWires,ADDR,DOUT
);
    wire [8:0] IR;
    wire G_zero,IR_in,DIN_out,A_in,G_in,AddSub,ADDR_in,DOUT_in,W_D,incr_PC;
    wire [7:0] R_in,R_out;
    wire G_out;
    control_unit_lab05 cu(
        .Clock(Clock), .Resetn(Resetn), .Run(Run),
        .IR(IR), .G_zero(G_zero), .IR_in(IR_in),
        .DIN_out(DIN_out), .A_in(A_in), .G_in(G_in),
        .AddSub(AddSub), .ADDR_in(ADDR_in), .DOUT_in(DOUT_in),
        .W_D(W_D), .incr_PC(incr_PC), .Done(Done),
        .G_out(G_out), .R_in(R_in), .R_out(R_out)
    );
    // Match the external module name and ports to the team datapath.
    datapath dp(
        .Clock(Clock), .Resetn(Resetn), .DIN(DIN),
        .IR_in(IR_in), .DIN_out(DIN_out), .A_in(A_in),
        .G_in(G_in), .AddSub(AddSub), .ADDR_in(ADDR_in),
        .DOUT_in(DOUT_in), .W_D(W_D), .incr_PC(incr_PC),
        .G_out(G_out), .R_in(R_in), .R_out(R_out),
        .IR(IR), .BusWires(BusWires), .ADDR(ADDR),
        .DOUT(DOUT), .G_zero(G_zero), .W(W)
    );
endmodule
