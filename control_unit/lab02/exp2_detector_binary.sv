module detector_binary(input wire clk, reset_n, w, output reg [3:0] y, output wire z);
    localparam A=0,B=1,C=2,D=3,E=4,F=5,G=6,H=7,I=8;
    reg [3:0] next_y;
    always @* case(y)
        A: next_y=w ? F : B;
        B: next_y=w ? F : C;
        C: next_y=w ? F : D;
        D,E: next_y=w ? F : E;
        F: next_y=w ? G : B;
        G: next_y=w ? H : B;
        H,I: next_y=w ? I : B;
        default: next_y=A;
    endcase
    always @(posedge clk) if (!reset_n) y<=A; else y<=next_y;
    assign z = (y==E || y==I);
endmodule
