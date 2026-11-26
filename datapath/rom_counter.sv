`timescale 1ns/1ps
// Counter 5-bit dem len (Resetn muc 0, ho tro enable va load song song uu tien)
module counter_5bit (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic       enable,
    input  logic       load,
    input  logic [4:0] d_in,
    output logic [4:0] q
);
    logic [4:0] q_inc;
    logic [5:0] c;
    logic [4:0] d_next;
    logic       en_cnt;

    assign c[0] = 1'b1;
    genvar i;
    generate
        for (i = 0; i < 5; i++) begin : gen_cnt5
            assign q_inc[i] = q[i] ^ c[i];
            assign c[i+1]   = q[i] & c[i];
        end
    endgenerate

    assign d_next = load ? d_in : q_inc;
    assign en_cnt = enable | load;

    reg_nbit #(.N(5)) u_cnt_reg (
        .Clock  (Clock),
        .Resetn (Resetn),
        .en     (en_cnt),
        .d      (d_next),
        .q      (q)
    );
endmodule

// Bo giai ma 5-sang-32 thuan cong logic: sel[i] = 1 khi addr == i
module dec5_32 (
    input  logic [4:0]  addr,
    output logic [31:0] sel
);
    logic [4:0] n_addr;
    assign n_addr = ~addr;

    genvar i;
    generate
        for (i = 0; i < 32; i++) begin : gen_dec
            localparam logic [4:0] IDX = i[4:0];
            assign sel[i] = (IDX[0] ? addr[0] : n_addr[0]) &
                            (IDX[1] ? addr[1] : n_addr[1]) &
                            (IDX[2] ? addr[2] : n_addr[2]) &
                            (IDX[3] ? addr[3] : n_addr[3]) &
                            (IDX[4] ? addr[4] : n_addr[4]);
        end
    endgenerate
endmodule

// ROM 32x9 thuan cau truc (dung dec5_32 + mang cong AND/OR)
module rom_32x9 (
    input  logic [4:0] addr,
    output logic [8:0] data_out
);
    localparam logic [8:0] ROM_DATA [0:31] = '{
        9'b001001000, // 00: mvi R1, #1
        9'b000000001, // 01: #1
        9'b001010000, // 02: mvi R2, #0
        9'b000000000, // 03: #0
        9'b001011000, // 04: mvi R3, #010000000 (dia chi LEDs)
        9'b010000000, // 05: #010000000
        9'b101010011, // 06: st R2, [R3]
        9'b010010001, // 07: add R2, R1
        9'b001011000, // 08: mvi R3, #111111111
        9'b111111111, // 09: #111111111
        9'b000101111, // 0A: mv R5, R7
        9'b001100000, // 0B: mvi R4, #111111111
        9'b111111111, // 0C: #111111111
        9'b000000111, // 0D: mv R0, R7
        9'b011100001, // 0E: sub R4, R1
        9'b110111000, // 0F: mvnz R7, R0
        9'b011011001, // 10: sub R3, R1
        9'b110111101, // 11: mvnz R7, R5
        9'b001111000, // 12: mvi R7, #04
        9'b000000100, // 13: #04
        9'b000000000, 9'b000000000, 9'b000000000, 9'b000000000,
        9'b000000000, 9'b000000000, 9'b000000000, 9'b000000000,
        9'b000000000, 9'b000000000, 9'b000000000, 9'b000000000
    };

    logic [31:0] word_sel;

    dec5_32 u_dec (
        .addr (addr),
        .sel  (word_sel)
    );

    genvar b, w;
    generate
        for (b = 0; b < 9; b++) begin : gen_rom_bits
            logic [31:0] bit_terms;
            for (w = 0; w < 32; w++) begin : gen_rom_words
                assign bit_terms[w] = word_sel[w] & ROM_DATA[w][b];
            end
            assign data_out[b] = |bit_terms;
        end
    endgenerate
endmodule

// Khoi ghep Counter 5-bit va ROM 32x9
module mem_counter_top (
    input  logic       Clock,
    input  logic       Resetn,
    input  logic       enable,
    input  logic       load,
    input  logic [4:0] d_in,
    output logic [4:0] addr_out,
    output logic [8:0] data_out
);
    counter_5bit u_cnt (
        .Clock  (Clock),
        .Resetn (Resetn),
        .enable (enable),
        .load   (load),
        .d_in   (d_in),
        .q      (addr_out)
    );

    rom_32x9 u_rom (
        .addr     (addr_out),
        .data_out (data_out)
    );
endmodule
