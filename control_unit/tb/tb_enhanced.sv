`timescale 1ns/1ps
module tb_enhanced #(parameter WITH_FPU=0);
    reg Clock=0, Resetn=1, Run=0, G_zero=0;
    reg [8:0] IR=0;
    wire IR_in,DIN_out,A_in,G_in,AddSub,ADDR_in,DOUT_in,W_D,incr_PC,Done;
    wire AF_in,GF_in,AddSubF;
    wire [(WITH_FPU ? 2 : 1)-1:0] G_out;
    wire [7:0] R_in,R_out;
    if (WITH_FPU) begin : lab06
        control_unit_lab06 dut(.*);
    end else begin : lab05
        assign {AF_in,GF_in,AddSubF}=0;
        control_unit_lab05 dut(.*);
    end

    // Each flag is one physical enable. Check all controls, including inactive ones.
    localparam IR_EN=1, DIN_EN=2, A_EN=4, G_EN=8, SUB=16, ADDR_EN=32,
               DOUT_EN=64, WRITE=128, INC=256, DONE=512, AF_EN=1024, GF_EN=2048;
    wire [12:0] flags={AddSubF,GF_in,AF_in,Done,incr_PC,W_D,DOUT_in,
                       ADDR_in,AddSub,G_in,A_in,DIN_out,IR_in};
    task tick;
        begin #4; Clock=1; #1; Clock=0; #5; end
    endtask
    task check(input [12:0] expected, input [7:0] rin,rout, input [1:0] gout);
        begin
            #1;
            if (flags!==expected || R_in!==rin || R_out!==rout || G_out!==gout)
                $fatal(1,"IR=%h flags=%h/%h Rin=%h/%h Rout=%h/%h Gout=%h/%h",
                       IR,flags,expected,R_in,rin,R_out,rout,G_out,gout);
            tick;
        end
    endtask
    task fetch(input [2:0] op,rx,ry);
        begin
            Run=1; check(ADDR_EN,0,8'h80,0);
            Run=0; check(INC,0,0,0);
            check(IR_EN,0,0,0);
            // Stand in for the instruction register immediately after its load edge.
            IR={op,rx,ry};
        end
    endtask
    initial begin
        if (WITH_FPU) $dumpfile("control_unit/build/lab06.vcd");
        else $dumpfile("control_unit/build/lab05.vcd");
        $dumpvars(0,tb_enhanced);
        #1; Resetn=0; tick; Resetn=1;
        check(0,0,0,0);
        fetch(0,2,5); check(DONE,8'h04,8'h20,0); // mv
        fetch(1,7,0); check(ADDR_EN,0,8'h80,0); check(INC,0,0,0);
        check(DIN_EN|DONE,8'h80,0,0); // mvi into PC
        for(integer opcode=2;opcode<=3;opcode++) begin
            fetch(opcode,2,5); check(A_EN,0,8'h04,0);
            check(G_EN | ((opcode==3) ? SUB : 0),0,8'h20,0);
            check(DONE,8'h04,0,WITH_FPU ? 2 : 1);
        end
        fetch(4,2,5); check(ADDR_EN,0,8'h20,0); check(0,0,0,0);
        check(DIN_EN|DONE,8'h04,0,0);
        fetch(5,2,5); check(ADDR_EN,0,8'h20,0);
        check(DOUT_EN|WRITE,0,8'h04,0); check(DONE,0,0,0);
        G_zero=0; fetch(6,7,5); check(DONE,8'h80,8'h20,0);
        G_zero=1; fetch(6,7,5); check(DONE,0,0,0);
        fetch(7,2,5);
        if(WITH_FPU) begin
            check(AF_EN,0,8'h04,0); check(GF_EN,0,8'h20,0);
            check(DONE,8'h04,0,1);
        end else check(DONE,0,0,0);
        check(0,0,0,0); // paused at instruction boundary
        $display("PASS control_unit WITH_FPU=%0d",WITH_FPU); $finish;
    end
endmodule
