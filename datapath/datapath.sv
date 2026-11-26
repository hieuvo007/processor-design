`timescale 1ns/1ps
module register_file (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic [8:0] WriteData,
    input  logic [7:0] Rin,
    input  logic       incr_PC,
    output logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7
);
    reg_nbit #(.N(9)) reg_0 (.Clock(Clock), .Resetn(Resetn), .en(Rin[0]), .d(WriteData), .q(R0));
    reg_nbit #(.N(9)) reg_1 (.Clock(Clock), .Resetn(Resetn), .en(Rin[1]), .d(WriteData), .q(R1));
    reg_nbit #(.N(9)) reg_2 (.Clock(Clock), .Resetn(Resetn), .en(Rin[2]), .d(WriteData), .q(R2));
    reg_nbit #(.N(9)) reg_3 (.Clock(Clock), .Resetn(Resetn), .en(Rin[3]), .d(WriteData), .q(R3));
    reg_nbit #(.N(9)) reg_4 (.Clock(Clock), .Resetn(Resetn), .en(Rin[4]), .d(WriteData), .q(R4));
    reg_nbit #(.N(9)) reg_5 (.Clock(Clock), .Resetn(Resetn), .en(Rin[5]), .d(WriteData), .q(R5));
    reg_nbit #(.N(9)) reg_6 (.Clock(Clock), .Resetn(Resetn), .en(Rin[6]), .d(WriteData), .q(R6));

    // Thanh ghi R7 dong vai tro Program Counter 9-bit
    pc_counter_9bit reg_7_pc (
        .Clock  (Clock),
        .Resetn (Resetn),
        .E      (incr_PC),
        .L      (Rin[7]),
        .d_load (WriteData),
        .q      (R7)
    );
endmodule


module datapath (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic [8:0] DIN,
    input  logic [7:0] Rin,
    input  logic [7:0] Rout,
    input  logic       Ain,
    input  logic       Gin,
    input  logic       Gout,
    input  logic       DINout,
    input  logic       IRin,
    input  logic       AddSub,
    output logic [8:0] IR,
    output logic [8:0] BusWires,
    input  logic       incr_PC,
    input  logic       ADDR_in,
    input  logic       DOUT_in,
    input  logic       W_D,
    output logic [8:0] ADDR,
    output logic [8:0] DOUT,
    output logic       W,
    output logic       G_zero
);
    logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7;
    logic [8:0] A, G, Result;

    // 1. Register File (R0..R6 + PC R7)
    register_file u_regfile (
        .Clock     (Clock),
        .Resetn    (Resetn),
        .WriteData (BusWires),
        .Rin       (Rin),
        .incr_PC   (incr_PC),
        .R0        (R0),
        .R1        (R1),
        .R2        (R2),
        .R3        (R3),
        .R4        (R4),
        .R5        (R5),
        .R6        (R6),
        .R7        (R7)
    );

    //Thanh ghi lenh IR
    reg_nbit #(.N(9)) u_IR (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (IRin),
        .d      (DIN),
        .q      (IR)
    );

    //MUX 10:1 dua du lieu len BusWires
    mux10_1 #(.N(9)) u_mux (
        .R0       (R0),
        .R1       (R1),
        .R2       (R2),
        .R3       (R3),
        .R4       (R4),
        .R5       (R5),
        .R6       (R6),
        .R7       (R7),
        .G        (G),
        .DIN      (DIN),
        .Rout     (Rout),
        .Gout     (Gout),
        .DINout   (DINout),
        .BusWires (BusWires)
    );

    //Thanh ghi A
    reg_nbit #(.N(9)) u_reg_A (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (Ain),
        .d      (BusWires),
        .q      (A)
    );

    //Bo cong/tru ADD/SUB
    addsub_nbit #(.N(9)) u_addsub (
        .A      (A),
        .B      (BusWires),
        .AddSub (AddSub),
        .Result (Result)
    );

    //Thanh ghi G + co G_zero 
    reg_nbit #(.N(9)) u_reg_G (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (Gin),
        .d      (Result),
        .q      (G)
    );
    assign G_zero = ~(|G);

    //Thanh ghi ADDR (9-bit)
    reg_nbit #(.N(9)) u_reg_ADDR (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (ADDR_in),
        .d      (BusWires),
        .q      (ADDR)
    );

    //Thanh ghi DOUT (9-bit)
    reg_nbit #(.N(9)) u_reg_DOUT (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (DOUT_in),
        .d      (BusWires),
        .q      (DOUT)
    );

    //Flip-flop W (
    dff_en u_reg_W (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (1'b1),
        .d      (W_D),
        .q      (W)
    );
endmodule
