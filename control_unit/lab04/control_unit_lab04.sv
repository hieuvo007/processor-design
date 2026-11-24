module control_unit_lab04(input wire Clock, Resetn, Run, input wire [8:0] IR,
    output reg IR_in, DIN_out, A_in, G_in, AddSub, G_out, Done,
    output reg [7:0] R_in, R_out);
    localparam T0=0,T1=1,T2=2,T3=3;
    reg [1:0] state,next_state;
    wire [2:0] opcode=IR[8:6];
    wire [7:0] rx=8'b1<<IR[5:3], ry=8'b1<<IR[2:0];
    always @(posedge Clock or negedge Resetn)
        if (!Resetn) state<=T0; else state<=next_state;
    always @* begin
        {IR_in,DIN_out,A_in,G_in,AddSub,G_out,Done}=0;
        R_in=0; R_out=0; next_state=T0;
        case(state)
            T0: begin IR_in=1; if (Run) next_state=T1; end
            T1: case(opcode)
                0: begin R_out=ry; R_in=rx; Done=1; end
                1: begin DIN_out=1; R_in=rx; Done=1; end
                2,3: begin R_out=rx; A_in=1; next_state=T2; end
                default: Done=1;
            endcase
            T2: begin R_out=ry; AddSub=(opcode==3); G_in=1; next_state=T3; end
            T3: begin G_out=1; R_in=rx; Done=1; end
        endcase
    end
endmodule
