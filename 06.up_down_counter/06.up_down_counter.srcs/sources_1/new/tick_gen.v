`timescale 1ns / 1ps

module tick_gen(
    input clk,
    input reset,
    output reg led
);

    reg [$clog2(50_000_000):0] r_500ms_counter = 0;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_500ms_counter <= 0;
            led <= 0;
        end else begin
            if (r_500ms_counter >= 50_000_000-1) begin
                r_500ms_counter <= 0;
                led <= ~led;
            end else begin
                r_500ms_counter <= r_500ms_counter + 1;
            end
        end
    end

endmodule
