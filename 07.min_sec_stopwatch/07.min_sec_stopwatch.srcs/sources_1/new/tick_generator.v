`timescale 1ns / 1ps

module tick_gen(
    input clk,
    output reg tick
);
    parameter INPUT_FREQUENCY = 100_000_000;
    parameter TICK_Hz = 1000;
    parameter TICK_COUNT = INPUT_FREQUENCY / TICK_Hz;

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter = 0;

    always @(posedge clk) begin
        if(r_tick_counter == TICK_COUNT - 1) begin
            r_tick_counter <= 0;
            tick <= 1'b1;
        end else begin
            r_tick_counter <= r_tick_counter + 1;
            tick <= 1'b0;
        end
    end

endmodule
