`timescale 1ns/1ps
module tb_rom_counter;
    logic       Clock;
    logic       Resetn;
    logic       enable;
    logic       load;
    logic [4:0] d_in;
    logic [4:0] addr_out;
    logic [8:0] data_out;

    int err_cnt = 0;

    mem_counter_top dut (
        .Clock    (Clock),
        .Resetn   (Resetn),
        .enable   (enable),
        .load     (load),
        .d_in     (d_in),
        .addr_out (addr_out),
        .data_out (data_out)
    );

    initial begin
        Clock = 1'b0;
        forever #10 Clock = ~Clock;
    end

    initial begin
        enable = 1'b0;
        load   = 1'b0;
        d_in   = 5'd0;
        Resetn = 1'b0;
        #25;
        Resetn = 1'b1;
        @(posedge Clock); #2;

        // 1. Kiem tra dia chi 00 sau reset
        assert (addr_out === 5'h00 && data_out === 9'b001001000)
            $display("[PASS] ROM[00] = %b (mvi R1, #1)", data_out);
        else begin
            $error("[FAIL] ROM[00] sai: addr=%h, data=%b", addr_out, data_out);
            err_cnt++;
        end

        // 2. Dem len dia chi 01 -> 06
        enable = 1'b1;
        repeat (6) @(posedge Clock); #2;
        assert (addr_out === 5'h06 && data_out === 9'b101010011)
            $display("[PASS] ROM[06] = %b (st R2, [R3])", data_out);
        else begin
            $error("[FAIL] ROM[06] sai: addr=%h, data=%b", addr_out, data_out);
            err_cnt++;
        end

        // 3. Test uu tien load song song (load=1 cung luc enable=1) nhay toi 0F
        load = 1'b1;
        d_in = 5'h0F;
        @(posedge Clock); #2;
        assert (addr_out === 5'h0F && data_out === 9'b110111000)
            $display("[PASS] Load uu tien -> ROM[0F] = %b (mvnz R7, R0)", data_out);
        else begin
            $error("[FAIL] Load uu tien sai: addr=%h, data=%b", addr_out, data_out);
            err_cnt++;
        end

        load   = 1'b0;
        enable = 1'b0;
        #20;
        if (err_cnt == 0)
            $display("=== TAT CA TESTCASE ROM & COUNTER DEU PASS (0 LOI) ===");
        else
            $display("=== CO %0d LOI TRONG ROM & COUNTER ===", err_cnt);
        $stop;
    end
endmodule
