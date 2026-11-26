`timescale 1ns/1ps
// Flip-flop D 1-bit co Resetn (tich cuc muc 0) va Enable
module dff_en (
    input  logic Clock,
    input  logic Resetn,
    input  logic en,
    input  logic d,
    output logic q
);
    logic d_next;
    assign d_next = en ? d : q;

    always_ff @(posedge Clock or negedge Resetn) begin
        if (!Resetn)
            q <= 1'b0;
        else
            q <= d_next;
    end
endmodule

// Thanh ghi N-bit ghep cau truc tu N flip-flop D co Enable
module reg_nbit #(
    parameter int N = 9
) (
    input  logic         Clock,
    input  logic         Resetn,
    input  logic         en,
    input  logic [N-1:0] d,
    output logic [N-1:0] q
);
    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_dff
            dff_en u_dff (
                .Clock  (Clock),
                .Resetn (Resetn),
                .en     (en),
                .d      (d[i]),
                .q      (q[i])
            );
        end
    endgenerate
endmodule

// Bo giai ma 3-sang-8 thuan cong logic theo chuan [7:0]: Y[i] = 1 khi W == i
module dec3to8 (
    input  logic [2:0] W,
    input  logic       En,
    output logic [7:0] Y
);
    logic [2:0] nW;
    assign nW = ~W;

    assign Y[0] = En & nW[2] & nW[1] & nW[0];
    assign Y[1] = En & nW[2] & nW[1] &  W[0];
    assign Y[2] = En & nW[2] &  W[1] & nW[0];
    assign Y[3] = En & nW[2] &  W[1] &  W[0];
    assign Y[4] = En &  W[2] & nW[1] & nW[0];
    assign Y[5] = En &  W[2] & nW[1] &  W[0];
    assign Y[6] = En &  W[2] &  W[1] & nW[0];
    assign Y[7] = En &  W[2] &  W[1] &  W[0];
endmodule

// Bo cong toan phan 1-bit thuan cong logic
module full_adder (
    input  logic a,
    input  logic b,
    input  logic cin,
    output logic sum,
    output logic cout
);
    logic axb;
    assign axb  = a ^ b;
    assign sum  = axb ^ cin;
    assign cout = (a & b) | (axb & cin);
endmodule

// Bo Cong/Tru N-bit: AddSub = 0 -> A + B; AddSub = 1 -> A - B
module addsub_nbit #(
    parameter int N = 9
) (
    input  logic [N-1:0] A,
    input  logic [N-1:0] B,
    input  logic         AddSub,
    output logic [N-1:0] Result
);
    logic [N-1:0] b_mod;
    logic [N:0]   carry;

    assign carry[0] = AddSub;

    genvar i;
    generate
        for (i = 0; i < N; i++) begin : gen_fa
            assign b_mod[i] = B[i] ^ AddSub;
            full_adder u_fa (
                .a    (A[i]),
                .b    (b_mod[i]),
                .cin  (carry[i]),
                .sum  (Result[i]),
                .cout (carry[i+1])
            );
        end
    endgenerate
endmodule

// Bo MUX 10:1 dua du lieu len BusWires[N-1:0]
// Quy uoc nhat quan: Rout[i] <-> Ri (Rout[0] chon R0 ... Rout[7] chon R7)
module mux10_1 #(
    parameter int N = 9
) (
    input  logic [N-1:0] R0, R1, R2, R3, R4, R5, R6, R7,
    input  logic [N-1:0] G,
    input  logic [N-1:0] DIN,
    input  logic [7:0]   Rout,
    input  logic         Gout,
    input  logic         DINout,
    output logic [N-1:0] BusWires
);
    genvar b;
    generate
        for (b = 0; b < N; b++) begin : gen_mux
            logic [9:0] sel_line;
            assign sel_line[0] = R0[b]  & Rout[0];
            assign sel_line[1] = R1[b]  & Rout[1];
            assign sel_line[2] = R2[b]  & Rout[2];
            assign sel_line[3] = R3[b]  & Rout[3];
            assign sel_line[4] = R4[b]  & Rout[4];
            assign sel_line[5] = R5[b]  & Rout[5];
            assign sel_line[6] = R6[b]  & Rout[6];
            assign sel_line[7] = R7[b]  & Rout[7];
            assign sel_line[8] = G[b]   & Gout;
            assign sel_line[9] = DIN[b] & DINout;

            assign BusWires[b] = |sel_line;
        end
    endgenerate
endmodule

// Bo dem Program Counter 9-bit (dung cho thanh ghi R7 trong Lab 5):
// Resetn = 0 -> ve 0; L (Rin[7]) = 1 -> nap song song (uu tien); E (incr_PC) = 1 -> tang +1
module pc_counter_9bit (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic       E,        // incr_PC
    input  logic       L,        // Rin[7]
    input  logic [8:0] d_load,
    output logic [8:0] q
);
    logic [8:0] q_inc;
    logic [9:0] c;
    logic [8:0] d_next;
    logic       en_pc;

    // Mach cong +1 thuan cau truc
    assign c[0] = 1'b1;
    genvar i;
    generate
        for (i = 0; i < 9; i++) begin : gen_inc
            assign q_inc[i] = q[i] ^ c[i];
            assign c[i+1]   = q[i] & c[i];
        end
    endgenerate

    // Uu tien nap song song khi Rin[7]=1, nguoc lai tang +1 khi incr_PC=1
    assign d_next = L ? d_load : q_inc;
    assign en_pc  = L | E;

    reg_nbit #(.N(9)) u_pc_reg (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (en_pc),
        .d      (d_next),
        .q      (q)
    );
endmodule
