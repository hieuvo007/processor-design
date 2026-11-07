module sync_sram (
    input  logic       clk,
    input  logic       en,
    input  logic       we,
    input  logic [6:0] addr,
    input  logic [8:0] din,
    output logic [8:0] dout
);
    logic [8:0] mem [0:127];

    always_ff @(posedge clk) begin
        if (en) begin
            if (we) begin
                mem[addr] <= din;
            end else begin
                dout <= mem[addr];
            end
        end
    end
endmodule
