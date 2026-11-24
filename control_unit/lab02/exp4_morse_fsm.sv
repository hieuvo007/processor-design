module morse_rom(input wire [2:0] letter, output reg [3:0] pattern, output reg [2:0] length);
    // First symbol is bit 0. Dot=0, dash=1.
    always_comb case(letter)
        0: {length,pattern}={3'd2,4'b0010}; // A .-
        1: {length,pattern}={3'd4,4'b0001}; // B -...
        2: {length,pattern}={3'd4,4'b0101}; // C -.-.
        3: {length,pattern}={3'd3,4'b0001}; // D -..
        4: {length,pattern}={3'd1,4'b0000}; // E .
        5: {length,pattern}={3'd4,4'b0100}; // F ..-.
        6: {length,pattern}={3'd3,4'b0011}; // G --.
        default: {length,pattern}={3'd4,4'b0000}; // H ....
    endcase
endmodule

module morse #(parameter HALF_CYCLES=25_000_000)(input wire clk, reset_n, start,
    input wire [2:0] letter, output wire dot, dash, busy);
    localparam IDLE=0, LIGHT=1, GAP=2;
    localparam CW=(HALF_CYCLES<=1) ? 1 : $clog2(HALF_CYCLES);
    reg [1:0] state;
    reg [CW-1:0] count;
    wire [3:0] pattern;
    wire [2:0] length;
    reg [3:0] symbols;
    reg [2:0] left;
    morse_rom table_abch(letter,pattern,length);
    assign busy = state != IDLE;
    assign dot = state == LIGHT && !symbols[0];
    assign dash = state == LIGHT && symbols[0];
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state<=IDLE; count<=0; symbols<=0; left<=0;
        end else case(state)
            IDLE: if(start) begin
                state<=LIGHT; symbols<=pattern; left<=length; count<=0;
            end
            LIGHT,GAP: if (count==HALF_CYCLES-1) begin
                count<=0;
                if (state==GAP) state<=LIGHT;
                else if (left==1) state<=IDLE;
                else begin
                    state<=GAP; left<=left-1'b1; symbols<=symbols>>1;
                end
            end else count<=count+1'b1;
            default: state<=IDLE;
        endcase
    end
endmodule
