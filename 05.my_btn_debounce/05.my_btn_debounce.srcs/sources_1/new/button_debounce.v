`timescale 1ns / 1ps

module button_debounce(
    input i_clk,
    input i_reset,
    input i_btn,
    output o_clean_btn
    );
    
    wire w_o_clk;
    wire w_Q1, w_Q2,w_Q2_bar;

    clock_80Hz u_clock_80Hz (
    .i_clk(i_clk), 
    .i_reset(i_reset), 
    .o_clk(w_o_clk) 
    );

    assign w_Q2_bar = ~w_Q2;
    assign o_clean_btn = w_Q1 & w_Q2_bar;

endmodule
