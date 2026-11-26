`timescale 1ns/1ps
// ============================================================================
// Testbench tu kiem tra (Self-Checking) cho Datapath nang cap Lab 5
// Bao gom:
//  1. Reset he thong (R7=0, G=0 -> G_zero=1)
//  2. Fetch step: Rout[7]=1, ADDR_in=1, incr_PC=1 (ADDR chot PC cu, R7 tang +1)
//  3. Nap song song PC: Rin[7]=1 (co che mvi R7 / mvnz R7)
//  4. Doc PC len bus: Rout[7]=1 -> Rin[5]=1 (co che mv R5, R7)
//  5. Uu tien PC: Rin[7]=1 cung luc incr_PC=1 -> phai nap song song, khong tang
//  6. Thao tac ghi ngoai vi st R1, [R2]: chot ADDR, DOUT va xung W 1 chu ky
//  7. Chuyen trang thai G_zero: 1 -> 0 (khi G=10) -> 1 (khi G=0)
// ============================================================================
module tb_datapath_lab5;
    logic       Clock;
    logic       Resetn;
    logic [8:0] DIN;
    logic [7:0] Rin;
    logic [7:0] Rout;
    logic       Ain;
    logic       Gin;
    logic       Gout;
    logic       DINout;
    logic       IRin;
    logic       AddSub;
    logic       incr_PC;
    logic       ADDR_in;
    logic       DOUT_in;
    logic       W_D;

    logic [8:0] IR;
    logic [8:0] BusWires;
    logic [8:0] ADDR;
    logic [8:0] DOUT;
    logic       W;
    logic       G_zero;

    int err_cnt = 0;

    // Goi dung ten module Datapath (chu D hoa)
    Datapath dut (
        .Clock    (Clock),
        .Resetn   (Resetn),
        .DIN      (DIN),
        .Rin      (Rin),
        .Rout     (Rout),
        .Ain      (Ain),
        .Gin      (Gin),
        .Gout     (Gout),
        .DINout   (DINout),
        .IRin     (IRin),
        .AddSub   (AddSub),
        .IR       (IR),
        .BusWires (BusWires),
        .incr_PC  (incr_PC),
        .ADDR_in  (ADDR_in),
        .DOUT_in  (DOUT_in),
        .W_D      (W_D),
        .ADDR     (ADDR),
        .DOUT     (DOUT),
        .W        (W),
        .G_zero   (G_zero)
    );

    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock;
    end

    task automatic clear_ctrl();
        begin
            DIN     = 9'd0;
            Rin     = 8'b0000_0000;
            Rout    = 8'b0000_0000;
            Ain     = 1'b0;
            Gin     = 1'b0;
            Gout    = 1'b0;
            DINout  = 1'b0;
            IRin    = 1'b0;
            AddSub  = 1'b0;
            incr_PC = 1'b0;
            ADDR_in = 1'b0;
            DOUT_in = 1'b0;
            W_D     = 1'b0;
        end
    endtask

    initial begin
        // --------------------------------------------------------------------
        // 1. Reset he thong (R7 PC = 0, G = 0 -> G_zero = 1)
        // --------------------------------------------------------------------
        clear_ctrl();
        Resetn = 1'b0;
        #25;
        Resetn = 1'b1;
        @(posedge Clock); #2;

        assert (dut.u_regfile.R7 === 9'd0 && G_zero === 1'b1 && W === 1'b0)
            $display("[PASS] 1. Reset thanh cong: R7=%0d, G_zero=%b, W=%b", dut.u_regfile.R7, G_zero, W);
        else begin
            $error("[FAIL] 1. Reset sai: R7=%0d, G_zero=%b, W=%b", dut.u_regfile.R7, G_zero, W);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // 2. Fetch step: Rout[7]=1, ADDR_in=1, incr_PC=1
        //    ADDR phai chot PC cu (0), sau do R7 tang len 1
        // --------------------------------------------------------------------
        clear_ctrl();
        Rout[7] = 1'b1;
        ADDR_in = 1'b1;
        incr_PC = 1'b1;
        @(posedge Clock); #2;

        assert (ADDR === 9'd0 && dut.u_regfile.R7 === 9'd1)
            $display("[PASS] 2. Fetch PC=0 -> ADDR=%0d, R7 tang len %0d", ADDR, dut.u_regfile.R7);
        else begin
            $error("[FAIL] 2. Fetch sai: ADDR=%0d (ky vong 0), R7=%0d (ky vong 1)", ADDR, dut.u_regfile.R7);
            err_cnt++;
        end

        // Tang PC them 1 lan nua (R7 -> 2) va chot ma lenh vao IR
        clear_ctrl();
        DIN     = 9'b001001000; // mvi R1, #1
        IRin    = 1'b1;
        incr_PC = 1'b1;
        @(posedge Clock); #2;

        assert (IR === 9'b001001000 && dut.u_regfile.R7 === 9'd2)
            $display("[PASS] 2b. Chot IR=%b, R7 tang len %0d", IR, dut.u_regfile.R7);
        else begin
            $error("[FAIL] 2b. Chot IR/PC sai: IR=%b, R7=%0d", IR, dut.u_regfile.R7);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // 3. Test nap song song PC: Rin[7]=1 (mvi R7, #4 / mvnz R7, Rx)
        // --------------------------------------------------------------------
        clear_ctrl();
        DIN    = 9'd4;
        DINout = 1'b1;
        Rin[7] = 1'b1;
        @(posedge Clock); #2;

        assert (dut.u_regfile.R7 === 9'd4)
            $display("[PASS] 3. Nap song song PC (Rin[7]=1): R7=%0d", dut.u_regfile.R7);
        else begin
            $error("[FAIL] 3. Nap song song PC sai: R7=%0d (ky vong 4)", dut.u_regfile.R7);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // 4. Test doc PC len bus va luu vao R5: Rout[7]=1, Rin[5]=1 (mv R5, R7)
        // --------------------------------------------------------------------
        clear_ctrl();
        Rout[7] = 1'b1;
        Rin[5]  = 1'b1;
        #1; // Kiem tra BusWires to hop truoc xung clock
        assert (BusWires === 9'd4)
            else begin
                $error("[FAIL] 4a. Rout[7]=1 nhung BusWires=%0d (ky vong 4)", BusWires);
                err_cnt++;
            end
        @(posedge Clock); #2;

        assert (dut.u_regfile.R5 === 9'd4)
            $display("[PASS] 4. Doc PC len bus (mv R5, R7): R5=%0d", dut.u_regfile.R5);
        else begin
            $error("[FAIL] 4. mv R5, R7 sai: R5=%0d (ky vong 4)", dut.u_regfile.R5);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // 5. Test uu tien PC: Rin[7]=1 cung luc incr_PC=1 -> phai nap (20), khong tang (5)
        // --------------------------------------------------------------------
        clear_ctrl();
        DIN     = 9'd20;
        DINout  = 1'b1;
        Rin[7]  = 1'b1;
        incr_PC = 1'b1;
        @(posedge Clock); #2;

        assert (dut.u_regfile.R7 === 9'd20)
            $display("[PASS] 5. Uu tien Rin[7]=1 hon incr_PC=1: R7=%0d", dut.u_regfile.R7);
        else begin
            $error("[FAIL] 5. Uu tien PC sai: R7=%0d (ky vong 20, khong phai 5)", dut.u_regfile.R7);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // 6. Nap R1 = 5, R2 = 9'b010000000 (dia chi LEDs) va mo phong st R1, [R2]
        // --------------------------------------------------------------------
        clear_ctrl();
        DIN    = 9'd5;
        DINout = 1'b1;
        Rin[1] = 1'b1;
        @(posedge Clock); #2;

        clear_ctrl();
        DIN    = 9'b010000000;
        DINout = 1'b1;
        Rin[2] = 1'b1;
        @(posedge Clock); #2;

        assert (dut.u_regfile.R1 === 9'd5 && dut.u_regfile.R2 === 9'b010000000)
            $display("[PASS] 6a. Nap thanh ghi: R1=%0d, R2=%b", dut.u_regfile.R1, dut.u_regfile.R2);
        else begin
            $error("[FAIL] 6a. Nap R1/R2 sai: R1=%0d, R2=%b", dut.u_regfile.R1, dut.u_regfile.R2);
            err_cnt++;
        end

        // Buoc 1 cua st: chot ADDR = R2
        clear_ctrl();
        Rout[2] = 1'b1;
        ADDR_in = 1'b1;
        @(posedge Clock); #2;

        // Buoc 2 cua st: chot DOUT = R1 va bat W_D = 1
        clear_ctrl();
        Rout[1] = 1'b1;
        DOUT_in = 1'b1;
        W_D     = 1'b1;
        @(posedge Clock); #2;

        assert (ADDR === 9'b010000000 && DOUT === 9'd5 && W === 1'b1)
            $display("[PASS] 6b. Ghi ngoai vi (st): ADDR=%b, DOUT=%0d, W=%b", ADDR, DOUT, W);
        else begin
            $error("[FAIL] 6b. Ghi ngoai vi sai: ADDR=%b, DOUT=%0d, W=%b", ADDR, DOUT, W);
            err_cnt++;
        end

        // Ha W_D = 0 o buoc tiep theo de W tro ve 0 (chi xung 1 chu ky)
        clear_ctrl();
        @(posedge Clock); #2;
        assert (W === 1'b0)
            $display("[PASS] 6c. Ha W_D=0 -> W tro ve %b", W);
        else begin
            $error("[FAIL] 6c. W khong ha ve 0: W=%b", W);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // 7. Test chuyen trang thai co G_zero:
        //    - Nap A = 5, cong them 5 -> G = 10 -> G_zero chuyen 1 -> 0
        //    - Tru di 5 (A=5, Bus=5, AddSub=1) -> G = 0 -> G_zero chuyen 0 -> 1
        // --------------------------------------------------------------------
        clear_ctrl();
        Rout[1] = 1'b1;
        Ain     = 1'b1; // A = 5
        @(posedge Clock); #2;

        clear_ctrl();
        Rout[1] = 1'b1;
        Gin     = 1'b1;
        AddSub  = 1'b0; // G = 5 + 5 = 10
        @(posedge Clock); #2;

        assert (dut.u_reg_G.q === 9'd10 && G_zero === 1'b0)
            $display("[PASS] 7a. G = 10 != 0 -> G_zero chuyen 1 -> %b", G_zero);
        else begin
            $error("[FAIL] 7a. G_zero sai khi G!=0: G=%0d, G_zero=%b", dut.u_reg_G.q, G_zero);
            err_cnt++;
        end

        clear_ctrl();
        Rout[1] = 1'b1;
        Gin     = 1'b1;
        AddSub  = 1'b1; // G = 5 - 5 = 0
        @(posedge Clock); #2;

        assert (dut.u_reg_G.q === 9'd0 && G_zero === 1'b1)
            $display("[PASS] 7b. G = 0 -> G_zero chuyen 0 -> %b", G_zero);
        else begin
            $error("[FAIL] 7b. G_zero sai khi G=0: G=%0d, G_zero=%b", dut.u_reg_G.q, G_zero);
            err_cnt++;
        end

        // --------------------------------------------------------------------
        // Tong ket ket qua mo phong
        // --------------------------------------------------------------------
        clear_ctrl();
        #20;
        if (err_cnt == 0)
            $display("=== TAT CA TESTCASE DATAPATH LAB 5 DEU PASS (0 LOI) ===");
        else
            $display("=== CO %0d LOI TRONG QUA TRINH MO PHONG ===", err_cnt);

        $stop;
    end
endmodule
