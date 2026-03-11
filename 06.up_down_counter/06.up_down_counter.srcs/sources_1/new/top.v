`timescale 1ns / 1ps

module top(
    input clk,
    input reset, // sw[15]
    input [2:0] btn, // btn[0] : btnL, btn[1] : btnC, btn[2] : btnR
    input [7:0] sw,
    output [7:0] seg,
    output [3:0] an,
    output led
        );

    wire [2:0] w_debounce_btn;
    wire [13:0] w_seg_date; // max 999
    wire w_tick;

    btn_debounce u_btn_debounce(
    .clk(clk),
    .reset(reset),
    .btn(btn),  
    .debounced_btn(w_debounce_btn)
    );

    control_tower u_control_tower(
    .clk(clk),
    .reset(reset),
    .btn(w_debounce_btn),
    .sw(sw),
    .seg_data(w_seg_date)
    //.led(led)
    );

    fnd_controller u_fnd_controller(
    .clk(clk),
    .reset(reset),
    .tick(w_tick),
    .in_data(w_seg_date),
    .seg(seg),
    .an(an)
    );

    tick_gen u_tick_gen(
    .clk(clk),
    .reset(reset),
    .led(led)
    );

    tick_generator u_tick_generator(
    .clk(clk),
    .reset(reset),
    .tick(w_tick)
    );

endmodule
