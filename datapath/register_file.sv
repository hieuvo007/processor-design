`timescale 1ns/1ps
module register_file (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic [8:0] WriteData,        // BusWires
    input  logic [7:0] Rin,
    input  logic       incr_PC,
    output logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7
);
    regn #(.N(9)) reg_0 (.R(WriteData), .Rin(Rin[0]), .Clock(Clock), .Resetn(Resetn), .Q(R0));
    regn #(.N(9)) reg_1 (.R(WriteData), .Rin(Rin[1]), .Clock(Clock), .Resetn(Resetn), .Q(R1));
    regn #(.N(9)) reg_2 (.R(WriteData), .Rin(Rin[2]), .Clock(Clock), .Resetn(Resetn), .Q(R2));
    regn #(.N(9)) reg_3 (.R(WriteData), .Rin(Rin[3]), .Clock(Clock), .Resetn(Resetn), .Q(R3));
    regn #(.N(9)) reg_4 (.R(WriteData), .Rin(Rin[4]), .Clock(Clock), .Resetn(Resetn), .Q(R4));
    regn #(.N(9)) reg_5 (.R(WriteData), .Rin(Rin[5]), .Clock(Clock), .Resetn(Resetn), .Q(R5));
    regn #(.N(9)) reg_6 (.R(WriteData), .Rin(Rin[6]), .Clock(Clock), .Resetn(Resetn), .Q(R6));

    pc_reg9 reg_7_pc (
        .Clock    (Clock),
        .Resetn   (Resetn),
        .incr_PC  (incr_PC),
        .R7in     (Rin[7]),
        .BusWires (WriteData),
        .R7       (R7)
    );
endmodule
module pc_reg9 (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic       incr_PC,
    input  logic       R7in,
    input  logic [8:0] BusWires,
    output logic [8:0] R7
);
    logic [8:0] pc_inc, pc_d;
    logic       cout_nc, en_pc;

    // pc_inc = R7 + 0 + Cin(1) = R7 + 1
    adder_nbit #(.N(9)) u_inc (
        .A(R7), .B(9'd0), .Cin(1'b1), .Sum(pc_inc), .Cout(cout_nc)
    );

    // R7in = 1 -> lay Bus (nap song song), R7in = 0 -> lay PC + 1
    genvar i;
    generate
        for (i = 0; i < 9; i++) begin : LOAD_MUX
            mux2to1 u_m (.a(pc_inc[i]), .b(BusWires[i]), .sel(R7in), .y(pc_d[i]));
        end
    endgenerate

    or u_en (en_pc, R7in, incr_PC);

    regn #(.N(9)) u_pc (.R(pc_d), .Rin(en_pc), .Clock(Clock), .Resetn(Resetn), .Q(R7));
endmodule
