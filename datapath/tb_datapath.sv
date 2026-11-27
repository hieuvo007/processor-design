`timescale 1ns/1ps

// ============================================================================
// tb_datapath.sv - Testbench tu kiem tra cho datapath Lab 5
// Kiem tra: reset, R7 (PC) tang / nap song song / uu tien nap, ADDR chot PC cu,
//           IR, nap R1/R2 tu DIN, chuoi lenh st (ADDR/DOUT/W), cong/tru + G_zero,
//           Gout, mv R7 ra bus, giu gia tri khi khong enable, reset bat dong bo.
// Thu tu bien dich: basic_components.sv, program_counter.sv, datapath.sv, tb_datapath.sv
// ============================================================================
module tb_datapath;
    logic       Clock;
    logic       Resetn;
    logic [8:0] DIN;
    logic       IRin;
    logic [7:0] Rin;
    logic [7:0] Rout;
    logic       DINout, Ain, Gin, Gout, AddSub;
    logic       incr_PC, ADDR_in, DOUT_in, W_D;

    logic [8:0] IR, BusWires, ADDR, DOUT;
    logic       W, G_zero;

    integer errors = 0;
    integer checks = 0;

    datapath dut (
        .Clock    (Clock),
        .Resetn   (Resetn),
        .DIN      (DIN),
        .IRin     (IRin),
        .Rin      (Rin),
        .Rout     (Rout),
        .DINout   (DINout),
        .Ain      (Ain),
        .Gin      (Gin),
        .Gout     (Gout),
        .AddSub   (AddSub),
        .incr_PC  (incr_PC),
        .ADDR_in  (ADDR_in),
        .DOUT_in  (DOUT_in),
        .W_D      (W_D),
        .IR       (IR),
        .BusWires (BusWires),
        .ADDR     (ADDR),
        .DOUT     (DOUT),
        .W        (W),
        .G_zero   (G_zero)
    );

    // Clock 50 MHz (chu ky 20 ns)
    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock;
    end

    // Tat ca tin hieu dieu khien ve 0
    task automatic clear_ctrl();
        begin
            DIN     = 9'd0;
            IRin    = 1'b0;
            Rin     = 8'b0;
            Rout    = 8'b0;
            DINout  = 1'b0;
            Ain     = 1'b0;
            Gin     = 1'b0;
            Gout    = 1'b0;
            AddSub  = 1'b0;
            incr_PC = 1'b0;
            ADDR_in = 1'b0;
            DOUT_in = 1'b0;
            W_D     = 1'b0;
        end
    endtask

    // Cho 1 canh len cua clock roi doi 2 ns de gia tri on dinh
    task automatic tick();
        begin
            @(posedge Clock);
            #2;
        end
    endtask

    // So sanh gia tri 9 bit
    task automatic chk9(input string name, input logic [8:0] got, input logic [8:0] expv);
        begin
            checks++;
            if (got !== expv) begin
                errors++;
                $display("[FAIL] t=%0t  %-34s got=%03h (%0d)  expected=%03h (%0d)",
                         $time, name, got, got, expv, expv);
            end else begin
                $display("[ OK ] t=%0t  %-34s = %03h", $time, name, got);
            end
        end
    endtask

    // So sanh gia tri 1 bit
    task automatic chk1(input string name, input logic got, input logic expv);
        begin
            checks++;
            if (got !== expv) begin
                errors++;
                $display("[FAIL] t=%0t  %-34s got=%b  expected=%b", $time, name, got, expv);
            end else begin
                $display("[ OK ] t=%0t  %-34s = %b", $time, name, got);
            end
        end
    endtask

    initial begin
        // ------------------------------------------------------------------
        // 0. RESET
        // ------------------------------------------------------------------
        clear_ctrl();
        Resetn = 1'b0;
        #25;
        Resetn = 1'b1;
        tick();
        chk9("reset: R7 (PC)",  dut.R7, 9'd0);
        chk9("reset: IR",       IR,     9'd0);
        chk9("reset: ADDR",     ADDR,   9'd0);
        chk9("reset: DOUT",     DOUT,   9'd0);
        chk1("reset: W",        W,      1'b0);
        chk1("reset: G_zero (G=0)", G_zero, 1'b1);

        // ------------------------------------------------------------------
        // 1. PC tang +1 va ADDR chot PC cu (PC = 0 -> 1 -> 2)
        // ------------------------------------------------------------------
        clear_ctrl();
        Rout[7] = 1'b1; ADDR_in = 1'b1; incr_PC = 1'b1;
        #1 chk9("bus khi Rout[7]=1 (PC=0)", BusWires, 9'd0);
        tick();
        chk9("fetch 1: ADDR = PC cu (0)", ADDR,   9'd0);
        chk9("fetch 1: R7 = 1",           dut.R7, 9'd1);

        clear_ctrl();
        Rout[7] = 1'b1; ADDR_in = 1'b1; incr_PC = 1'b1;
        #1 chk9("bus khi Rout[7]=1 (PC=1)", BusWires, 9'd1);
        tick();
        chk9("fetch 2: ADDR = PC cu (1)", ADDR,   9'd1);
        chk9("fetch 2: R7 = 2",           dut.R7, 9'd2);

        // ------------------------------------------------------------------
        // 2. IR nap tu DIN (lenh mvi R1, ma 001001000)
        // ------------------------------------------------------------------
        clear_ctrl();
        DIN = 9'b001001000; IRin = 1'b1;
        tick();
        chk9("IR = DIN (mvi R1)", IR, 9'b001001000);

        // IR khong nap khi IRin = 0
        clear_ctrl();
        DIN = 9'h1FF;
        tick();
        chk9("IR giu khi IRin=0", IR, 9'b001001000);

        // ------------------------------------------------------------------
        // 3. Nap R1 = 5, R2 = 9'b010000000 (dia chi LED) qua DINout
        // ------------------------------------------------------------------
        clear_ctrl();
        DIN = 9'd5; DINout = 1'b1; Rin[1] = 1'b1;
        #1 chk9("bus khi DINout=1", BusWires, 9'd5);
        tick();
        chk9("R1 = 5", dut.R1, 9'd5);

        clear_ctrl();
        DIN = 9'b010000000; DINout = 1'b1; Rin[2] = 1'b1;
        tick();
        chk9("R2 = 010000000", dut.R2, 9'b010000000);

        // Khong chon nguon nao -> bus = 0
        clear_ctrl();
        DIN = 9'h1FF;
        #1 chk9("bus khi khong chon nguon", BusWires, 9'd0);

        // ------------------------------------------------------------------
        // 4. Chuoi lenh st R1,[R2]: ADDR <- R2 ; DOUT <- R1, W_D = 1 ; W len 1 chu ky
        // ------------------------------------------------------------------
        clear_ctrl();
        Rout[2] = 1'b1; ADDR_in = 1'b1;
        tick();
        chk9("st: ADDR = R2", ADDR, 9'b010000000);
        chk1("st: W = 0 truoc khi ghi", W, 1'b0);

        clear_ctrl();
        Rout[1] = 1'b1; DOUT_in = 1'b1; W_D = 1'b1;
        tick();
        chk9("st: DOUT = R1 (5)", DOUT, 9'd5);
        chk1("st: W = 1 (tre 1 chu ky)", W, 1'b1);
        chk9("st: ADDR van giu",  ADDR, 9'b010000000);

        clear_ctrl();
        tick();
        chk1("st: W ve 0 sau 1 chu ky", W, 1'b0);
        chk9("st: DOUT giu gia tri",    DOUT, 9'd5);

        // ------------------------------------------------------------------
        // 5. Cong / tru va G_zero (A = R1 = 5)
        // ------------------------------------------------------------------
        clear_ctrl();
        Rout[1] = 1'b1; Ain = 1'b1;
        tick();
        chk9("A = R1 (5)", dut.A, 9'd5);

        clear_ctrl();
        Rout[1] = 1'b1; Gin = 1'b1; AddSub = 1'b0;      // 5 + 5
        tick();
        chk9("add: G = 5 + 5",     dut.G, 9'd10);
        chk1("G_zero = 0 (G = 10)", G_zero, 1'b0);

        clear_ctrl();
        Rout[1] = 1'b1; Gin = 1'b1; AddSub = 1'b1;      // 5 - 5
        tick();
        chk9("sub: G = 5 - 5",     dut.G, 9'd0);
        chk1("G_zero = 1 (G = 0)", G_zero, 1'b1);

        // R3 = 3 ; A = R3 ; G = 3 - 5 = -2 (bu 2, 9 bit = 1FE)
        clear_ctrl();
        DIN = 9'd3; DINout = 1'b1; Rin[3] = 1'b1;
        tick();
        clear_ctrl();
        Rout[3] = 1'b1; Ain = 1'b1;
        tick();
        clear_ctrl();
        Rout[1] = 1'b1; Gin = 1'b1; AddSub = 1'b1;
        tick();
        chk9("sub am: G = 3 - 5 = 1FE", dut.G, 9'h1FE);
        chk1("G_zero = 0 (G = -2)",     G_zero, 1'b0);

        // G khong doi khi Gin = 0
        clear_ctrl();
        Rout[1] = 1'b1; AddSub = 1'b0;
        tick();
        chk9("G giu khi Gin=0", dut.G, 9'h1FE);

        // Gout: dua G ra bus roi nap vao R4
        clear_ctrl();
        Gout = 1'b1; Rin[4] = 1'b1;
        #1 chk9("bus khi Gout=1", BusWires, 9'h1FE);
        tick();
        chk9("R4 = G", dut.R4, 9'h1FE);

        // ------------------------------------------------------------------
        // 6. PC: nap song song, uu tien nap hon dem, R7 ra bus, tang tiep, giu gia tri
        // ------------------------------------------------------------------
        clear_ctrl();
        DIN = 9'd4; DINout = 1'b1; Rin[7] = 1'b1; incr_PC = 1'b1;   // nap + dem cung luc
        tick();
        chk9("PC nap 4, khong tang (uu tien nap)", dut.R7, 9'd4);

        clear_ctrl();
        Rout[7] = 1'b1; Rin[5] = 1'b1;                              // mv R5, R7
        #1 chk9("bus = PC (4)", BusWires, 9'd4);
        tick();
        chk9("mv R5,R7: R5 = 4", dut.R5, 9'd4);
        chk9("R7 giu khi khong enable", dut.R7, 9'd4);

        clear_ctrl();
        Rout[7] = 1'b1; ADDR_in = 1'b1; incr_PC = 1'b1;             // ADDR chot PC cu = 4
        tick();
        chk9("ADDR chot PC cu (4)", ADDR,   9'd4);
        chk9("R7 = 5",              dut.R7, 9'd5);

        clear_ctrl();
        incr_PC = 1'b1;
        tick();
        chk9("incr_PC: R7 = 6", dut.R7, 9'd6);

        clear_ctrl();
        tick(); tick();
        chk9("R7 giu = 6 sau 2 chu ky", dut.R7, 9'd6);

        // mvi R7,#Loop: nap R7 = 4 tu DIN (khong incr_PC)
        clear_ctrl();
        DIN = 9'd4; DINout = 1'b1; Rin[7] = 1'b1;
        tick();
        chk9("mvi R7: R7 = 4", dut.R7, 9'd4);

        // ------------------------------------------------------------------
        // 7. Reset bat dong bo giua chu ky: moi thanh ghi ve 0
        // ------------------------------------------------------------------
        clear_ctrl();
        #3;
        Resetn = 1'b0;
        #1;
        chk9("async reset: R7",   dut.R7, 9'd0);
        chk9("async reset: R1",   dut.R1, 9'd0);
        chk9("async reset: ADDR", ADDR,   9'd0);
        chk9("async reset: DOUT", DOUT,   9'd0);
        chk9("async reset: IR",   IR,     9'd0);
        chk1("async reset: G_zero", G_zero, 1'b1);
        #20;
        Resetn = 1'b1;
        tick();

        // ------------------------------------------------------------------
        // Ket qua
        // ------------------------------------------------------------------
        $display("==================================================");
        if (errors == 0) $display(" TAT CA %0d KIEM TRA DEU DAT", checks);
        else             $display(" CO %0d / %0d KIEM TRA SAI", errors, checks);
        $display("==================================================");
        $stop;
    end
endmodule
