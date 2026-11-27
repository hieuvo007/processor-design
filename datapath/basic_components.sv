`timescale 1ns/1ps
// D Flip-Flop co Reset bat dong bo tich cuc muc thap
module dff_rstn (
    input  logic clk,
    input  logic resetn,
    input  logic d,
    output logic q
);
    always_ff @(posedge clk or negedge resetn) begin
        if (!resetn) q <= 1'b0;
        else         q <= d;
    end
endmodule

// MUX 2-sang-1 1-bit bang cong logic: y = sel ? b : a
module mux2to1 (
    input  logic a,    // chon khi sel = 0
    input  logic b,    // chon khi sel = 1
    input  logic sel,
    output logic y
);
    logic n_sel, w0, w1;
    not u_not  (n_sel, sel);
    and u_and0 (w0, a, n_sel);
    and u_and1 (w1, b, sel);
    or  u_or   (y, w0, w1);
endmodule

// Bo cong toan phan 1-bit
module full_adder (
    input  logic a, b, cin,
    output logic sum, cout
);
    logic s1, c1, c2;
    xor u_x1 (s1,  a,  b);
    xor u_x2 (sum, s1, cin);
    and u_a1 (c1,  a,  b);
    and u_a2 (c2,  s1, cin);
    or  u_o1 (cout, c1, c2);
endmodule

// D Flip-Flop co Enable = mux2to1 (en=1 nap d, en=0 giu q) + dff_rstn
module dff_en (
    input  logic clk,
    input  logic resetn,
    input  logic en,
    input  logic d,
    output logic q
);
    logic d_mux;
    mux2to1  u_hold (.a(q), .b(d), .sel(en), .y(d_mux));
    dff_rstn u_ff   (.clk(clk), .resetn(resetn), .d(d_mux), .q(q));
endmodule

// Thanh ghi N-bit co Enable (Rin) ghep tu N dff_en
module regn #(parameter int N = 9) (
    input  logic [N-1:0] R,
    input  logic         Rin,
    input  logic         Clock,
    input  logic         Resetn,
    output logic [N-1:0] Q
);
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : REG_BIT
            dff_en u_ff (.clk(Clock), .resetn(Resetn), .en(Rin), .d(R[i]), .q(Q[i]));
        end
    endgenerate
endmodule

// Bo cong N-bit ripple-carry (chuoi full_adder)
module adder_nbit #(parameter int N = 9) (
    input  logic [N-1:0] A, B,
    input  logic         Cin,
    output logic [N-1:0] Sum,
    output logic         Cout
);
    logic [N:0] C;
    assign C[0] = Cin;
    assign Cout = C[N];

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : FA_CHAIN
            full_adder u_fa (.a(A[i]), .b(B[i]), .cin(C[i]), .sum(Sum[i]), .cout(C[i+1]));
        end
    endgenerate
endmodule

// Bo cong/tru 9-bit: AddSub = 0 -> A + B ; AddSub = 1 -> A - B (= A + ~B + 1)
module addsub_9bit (
    input  logic [8:0] A, B,
    input  logic       AddSub,
    output logic [8:0] Sum
);
    logic [8:0] B_xor;
    logic       cout_nc;

    genvar i;
    generate
        for (i = 0; i < 9; i++) begin : B_XOR
            xor u_bx (B_xor[i], B[i], AddSub);
        end
    endgenerate

    adder_nbit #(.N(9)) u_adder (
        .A(A), .B(B_xor), .Cin(AddSub), .Sum(Sum), .Cout(cout_nc)
    );
endmodule

// Bo chon Bus 10-sang-1 rong 9-bit (one-hot AND-OR)
// Rout[i]=1 -> Ri len bus; Gout=1 -> G len bus; DINout=1 -> DIN len bus
module mux_10to1_9bit (
    input  logic [8:0] R0, R1, R2, R3, R4, R5, R6, R7, G, DIN,
    input  logic [7:0] Rout,
    input  logic       Gout,
    input  logic       DINout,
    output logic [8:0] BusWires
);
    genvar b;
    generate
        for (b = 0; b < 9; b++) begin : BUS_BIT
            logic [9:0] t;
            and u_t0 (t[0], R0[b],  Rout[0]);
            and u_t1 (t[1], R1[b],  Rout[1]);
            and u_t2 (t[2], R2[b],  Rout[2]);
            and u_t3 (t[3], R3[b],  Rout[3]);
            and u_t4 (t[4], R4[b],  Rout[4]);
            and u_t5 (t[5], R5[b],  Rout[5]);
            and u_t6 (t[6], R6[b],  Rout[6]);
            and u_t7 (t[7], R7[b],  Rout[7]);
            and u_t8 (t[8], G[b],   Gout);
            and u_t9 (t[9], DIN[b], DINout);

            or  u_or (BusWires[b], t[0], t[1], t[2], t[3], t[4],
                                   t[5], t[6], t[7], t[8], t[9]);
        end
    endgenerate
endmodule
