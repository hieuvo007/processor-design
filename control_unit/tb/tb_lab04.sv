`timescale 1ns/1ps
module tb_lab04;
    reg Clock=0, Resetn=1, Run=0;
    reg [8:0] IR=0;
    wire IR_in,DIN_out,A_in,G_in,AddSub,G_out,Done;
    wire [7:0] R_in,R_out;
    control_unit_lab04 dut(.*);
    wire [6:0] enables={Done,G_out,AddSub,G_in,A_in,DIN_out,IR_in};
    localparam IR_EN=1, DIN_EN=2, A_EN=4, G_EN=8, SUB=16, G_BUS=32, DONE=64;

    task tick;
        begin #4; Clock=1; #1; Clock=0; #5; end
    endtask
    task check(input [6:0] expected,input [7:0] rin,rout);
        begin
            #1;
            if (enables!==expected || R_in!==rin || R_out!==rout)
                $fatal(1,"state=%0d IR=%h enables=%b Rin=%h Rout=%h",dut.state,IR,enables,R_in,R_out);
            tick;
        end
    endtask
    task fetch(input [2:0] op,rx,ry);
        begin
            Run=1; check(IR_EN,0,0);
            IR={op,rx,ry}; Run=0;
        end
    endtask
    initial begin
        $dumpfile("control_unit/build/lab04.vcd"); $dumpvars(0,tb_lab04);
        #1; Resetn=0; tick; Resetn=1;
        check(IR_EN,0,0);
        fetch(0,1,7); check(DONE,8'h02,8'h80);
        fetch(1,4,0); check(DIN_EN|DONE,8'h10,0);
        for(integer op=2;op<=3;op++) begin
            fetch(op,2,5); check(A_EN,0,8'h04);
            check(G_EN | ((op==3) ? SUB : 0),0,8'h20);
            check(G_BUS|DONE,8'h04,0);
        end
        check(IR_EN,0,0);
        $display("PASS lab4: T0..T3, mv, mvi, add, sub"); $finish;
    end
endmodule
