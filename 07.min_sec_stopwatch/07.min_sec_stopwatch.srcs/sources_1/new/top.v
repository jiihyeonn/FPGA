`timescale 1ns / 1ps

module top(
    input clk,
    input [2:0] btn,    // btnL, btnC, btnR
    output [7:0] seg,
    output [3:0] an
);
    wire [2:0] w_debounced_btn;
    wire [13:0] seg_data;
    wire w_tick;

    tick_gen u_tick_gen(
        .clk    (clk),
        .tick   (w_tick)
    );

    btn_debouncer u_btn_debouncer(
        .tick           (w_tick),
        .btn            (btn),
        .debounced_btn  (w_debounced_btn)
    );

    control_tower u_control_tower(
        .tick       (w_tick),
        .btn        (w_debounced_btn),
        .seg_data   (seg_data)
    );

    fnd_controller u_fnd_controller(
        .tick   (w_tick),
        .in_data(seg_data),
        .an     (an),
        .seg    (seg)
    );

endmodule
