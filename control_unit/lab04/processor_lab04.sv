module processor_lab04(input wire [8:0] DIN, input wire Resetn,Clock,Run,
    output wire Done, output wire [8:0] BusWires);
    wire [8:0] IR;
    wire [7:0] R_in,R_out;
    wire IR_in,DIN_out,A_in,G_in,AddSub,G_out;
    control_unit_lab04 cu(
        .Clock(Clock), .Resetn(Resetn), .Run(Run),
        .IR(IR), .IR_in(IR_in), .DIN_out(DIN_out),
        .A_in(A_in), .G_in(G_in), .AddSub(AddSub),
        .G_out(G_out), .Done(Done), .R_in(R_in),
        .R_out(R_out)
    );
    datapath_lab04 dp(
        .Clock(Clock), .Resetn(Resetn), .DIN(DIN), .IR(IR),
        .IR_in(IR_in), .R_in(R_in), .R_out(R_out), .DIN_out(DIN_out),
        .A_in(A_in), .G_in(G_in), .AddSub(AddSub), .G_out(G_out),
        .BusWires(BusWires)
    );
endmodule
