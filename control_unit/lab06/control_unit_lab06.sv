module control_unit_lab06(
    input wire Clock,Resetn,Run, input wire [8:0] IR, input wire G_zero,
    output reg IR_in,DIN_out,A_in,G_in,AddSub,ADDR_in,DOUT_in,W_D,incr_PC,Done,
    output reg AF_in,GF_in,AddSubF, output reg [1:0] G_out, output reg [7:0] R_in,R_out
);
    localparam FETCH_ADDR=0, FETCH_WAIT=1, FETCH_IR=2, EXEC=3, ALU_CALC=4,
               ALU_WRITE=5, READ_WAIT=6, READ_WRITE=7, STORE_DATA=8, STORE_COMMIT=9;
    localparam MV=0,MVI=1,ADD=2,SUB=3,LD=4,ST=5,MVNZ=6,ADDF=7;
    reg [3:0] state,next_state;
    wire [2:0] opcode=IR[8:6];
    wire [7:0] rx=8'b1<<IR[5:3], ry=8'b1<<IR[2:0];
    always @(posedge Clock or negedge Resetn)
        if (!Resetn) state<=FETCH_ADDR; else state<=next_state;
    always @* begin
        R_in=0; R_out=0; G_out=0;
        {IR_in,DIN_out,A_in,G_in,AddSub,ADDR_in,DOUT_in,W_D,incr_PC,Done}=0;
        {AF_in,GF_in,AddSubF}=0;
        next_state=FETCH_ADDR;
        case(state)
            FETCH_ADDR: if (Run) begin
                R_out=8'h80; ADDR_in=1; next_state=FETCH_WAIT;
            end
            FETCH_WAIT: begin incr_PC=1; next_state=FETCH_IR; end
            FETCH_IR: begin IR_in=1; next_state=EXEC; end
            EXEC: case(opcode)
                MV,MVNZ: begin
                    if (opcode==MV || !G_zero) begin R_out=ry; R_in=rx; end
                    Done=1;
                end
                MVI: begin R_out=8'h80; ADDR_in=1; next_state=READ_WAIT; end
                ADD,SUB: begin R_out=rx; A_in=1; next_state=ALU_CALC; end
                LD,ST: begin
                    R_out=ry; ADDR_in=1;
                    next_state=(opcode==LD) ? READ_WAIT : STORE_DATA;
                end
                ADDF: begin
                    R_out=rx; AF_in=1; next_state=ALU_CALC;
                end
            endcase
            ALU_CALC: begin
                R_out=ry;
                if (opcode==ADDF) GF_in=1;
                else begin AddSub=(opcode==SUB); G_in=1; end
                next_state=ALU_WRITE;
            end
            ALU_WRITE: begin
                G_out=(opcode==ADDF) ? 2'b01 : 2'b10; R_in=rx; Done=1;
            end
            READ_WAIT: begin incr_PC=(opcode==MVI); next_state=READ_WRITE; end
            READ_WRITE: begin DIN_out=1; R_in=rx; Done=1; end
            STORE_DATA: begin R_out=rx; DOUT_in=1; W_D=1; next_state=STORE_COMMIT; end
            STORE_COMMIT: Done=1; // RAM samples registered W, ADDR and DOUT on this edge.
            default: next_state=FETCH_ADDR;
        endcase
    end
endmodule
