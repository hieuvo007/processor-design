`timescale 1ns/1ps
module datapath (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic [8:0] DIN,
    input  logic       IRin,
    input  logic [7:0] Rin,
    input  logic [7:0] Rout,
    input  logic       DINout,
    input  logic       Ain,
    input  logic       Gin,
    input  logic       Gout,
    input  logic       AddSub,
    input  logic       incr_PC,
    input  logic       ADDR_in,
    input  logic       DOUT_in,
    input  logic       W_D,
    output logic [8:0] IR,
    output logic [8:0] BusWires,
    output logic [8:0] ADDR,
    output logic [8:0] DOUT,
    output logic       W,
    output logic       G_zero
);
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
    logic [8:0] A, G, Sum;

    // Register file 
    register_file u_regfile (
        .Clock     (Clock),
        .Resetn    (Resetn),
        .WriteData (BusWires),
        .Rin       (Rin),
        .incr_PC   (incr_PC),
        .R0(R0), .R1(R1), .R2(R2), .R3(R3),
        .R4(R4), .R5(R5), .R6(R6), .R7(R7)
    );

    // Thanh ghi lenh IR 
    regn #(.N(9)) reg_IR (.R(DIN), .Rin(IRin), .Clock(Clock), .Resetn(Resetn), .Q(IR));

    // MUX 10:1 
    mux_10to1_9bit u_mux_bus (
        .R0(R0), .R1(R1), .R2(R2), .R3(R3),
        .R4(R4), .R5(R5), .R6(R6), .R7(R7),
        .G(G), .DIN(DIN),
        .Rout(Rout), .Gout(Gout), .DINout(DINout),
        .BusWires(BusWires)
    );

    // Thanh ghi A
    regn #(.N(9)) reg_A (.R(BusWires), .Rin(Ain), .Clock(Clock), .Resetn(Resetn), .Q(A));

    // addsub
    addsub_9bit u_addsub (.A(A), .B(BusWires), .AddSub(AddSub), .Sum(Sum));

    // Thanh ghi G
    regn #(.N(9)) reg_G (.R(Sum), .Rin(Gin), .Clock(Clock), .Resetn(Resetn), .Q(G));

    // G_zero = 1 khi G = 0 (NOR 9 ngo vao) -> dung cho lenh mvnz
    nor u_gzero (G_zero, G[0], G[1], G[2], G[3], G[4], G[5], G[6], G[7], G[8]);

    // Thanh ghi ADDR
    regn #(.N(9)) reg_ADDR (.R(BusWires), .Rin(ADDR_in), .Clock(Clock), .Resetn(Resetn), .Q(ADDR));

    // Thanh ghi DOUT
    regn #(.N(9)) reg_DOUT (.R(BusWires), .Rin(DOUT_in), .Clock(Clock), .Resetn(Resetn), .Q(DOUT));

    // Flip-flop W
    dff_rstn reg_W (.clk(Clock), .resetn(Resetn), .d(W_D), .q(W));
endmodule
