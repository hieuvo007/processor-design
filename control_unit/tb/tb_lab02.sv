`timescale 1ns/1ps
module tb_lab02;
    reg clk=0,reset_n=1,w=0,start=0;
    reg [2:0] letter=0;
    wire [8:0] y,ym;
    wire [3:0] yb,ones,zeros;
    wire z1,zm,zb,zs,dot,dash,busy;
    detector_onehot normal(clk,reset_n,w,y,z1);
    detector_onehot #(1) modified(clk,reset_n,w,ym,zm);
    detector_binary binary_fsm(clk,reset_n,w,yb,zb);
    detector_shift shifts(clk,reset_n,w,ones,zeros,zs);
    morse #(2) encoder(clk,reset_n,start,letter,dot,dash,busy);
    task tick; begin #4; clk=1; #1; clk=0; #5; end endtask
    integer run_length,expected_state,n;
    reg previous, expected_z;
    reg [3:0] expected_bits [0:7];
    integer lengths [0:7];
    initial begin
        $dumpfile("control_unit/build/lab02.vcd"); $dumpvars(0,tb_lab02);
        // Entire 8-sample input space, including overlaps and switching runs.
        for(integer vec=0;vec<256;vec++) begin
            reset_n=0; tick; reset_n=1; run_length=0; previous=0;
            if (y!==1 || ym!==0 || yb!==0 || zs!==0) $fatal(1,"reset");
            for(integer j=0;j<8;j++) begin
                w=(vec>>j)&1;
                if (!run_length || w!=previous) run_length=1; else run_length++;
                previous=w; expected_z=(run_length>=4);
                n=(run_length<4) ? run_length : 4;
                expected_state=w ? 4+n : n;
                tick;
                if ({z1,zm,zb,zs}!=={4{expected_z}} || y!==(9'd1<<expected_state)
                    || ym!==(y^9'd1) || yb!==expected_state[3:0]) $fatal(1,"vec=%d j=%d",vec,j);
            end
        end
        expected_bits[0]=2; expected_bits[1]=1; expected_bits[2]=5; expected_bits[3]=1;
        expected_bits[4]=0; expected_bits[5]=4; expected_bits[6]=3; expected_bits[7]=0;
        lengths[0]=2; lengths[1]=4; lengths[2]=4; lengths[3]=3;
        lengths[4]=1; lengths[5]=4; lengths[6]=3; lengths[7]=4;
        for(integer k=0;k<8;k++) begin
            letter=k; start=1; tick; start=0;
            for(integer j=0;j<lengths[k];j++) begin
                repeat(2) begin
                    if ({dash,dot} !== (expected_bits[k][j] ? 2'b10 : 2'b01)) $fatal(1,"symbol");
                    tick;
                end
                if(j+1<lengths[k]) repeat(2) begin
                    if (!busy || dot || dash) $fatal(1,"gap");
                    tick;
                end
            end
            if (busy || dot || dash) $fatal(1,"end of letter");
        end
        $display("PASS lab2: both one-hot codes, binary, two shifts, Morse A-H"); $finish;
    end
endmodule
