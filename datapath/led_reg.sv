module led_register (
    input  logic       clk,
    input  logic       we,
    input  logic [8:0] din,
    output logic [8:0] leds
);
    always_ff @(posedge clk) begin
        if (we) begin
            leds <= din;
        end
    end
endmodule
