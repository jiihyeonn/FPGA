`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    inout dht11_data,
    // output trig,
    // input echo,
    // input [2:0] btn,
    output ds1302_ce,
    output ds1302_sclk, 
    inout ds1302_data, 

    input btnL,
    input RsRx,
    output RsTx,
    output [7:0] seg,
    output [3:0] an
    );

    wire [7:0] w_hum_int, w_hum_dec, w_tem_int, w_tem_dec, w_check_sum;
    wire [7:0] w_rtc_sec, w_rtc_min;
    wire w_btn_debouncer;
    wire [13:0] w_fnd_in_data;

    btn_debouncer #(.DEBOUNCE_LIMIT(20'd999_999)) u_btn_debouncer(
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnL),
        .clean_btn(w_btn_debouncer)
    );

    control_tower u_control_tower(
        .clk(clk),
        .reset(reset),
        .btnL(w_btn_debouncer), 
        .hum_int(w_hum_int),
        .tem_int(w_tem_int),
        .rtc_sec(w_rtc_sec),
        .rtc_min(w_rtc_min),
        .fnd_data(w_fnd_in_data) 
    );

    dht_controller u_dht_controller(
        .clk(clk),
        .reset(reset),
        .dht11_data(dht11_data),
        .hum_int(w_hum_int),
        .hum_dec(w_hum_dec),
        .tem_int(w_tem_int),
        .tem_dec(w_tem_dec),
        .check_sum(w_check_sum)
    );

    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset),
        .rx(RsRx),
        .hum_int(w_hum_int),
        .tem_int(w_tem_int),
        .rx_data(),
        .rx_done(),
        .tx(RsTx) 
    );

    fnd_controller u_fnd_controller(
        .clk(clk),
        .reset(reset), 
        .in_data(w_fnd_in_data),
        .seg(seg),
        .an(an)
    );

    ds1302_controller u_ds1302(
        .clk(clk),
        .reset(reset),
        .ce(ds1302_ce),
        .sclk(ds1302_sclk),
        .ds1302_data(ds1302_data),
        .o_sec(w_rtc_sec),
        .o_min(w_rtc_min)
    );


endmodule