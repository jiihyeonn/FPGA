`timescale 1ns / 1ps

module top(
    input clk,
    input reset,
    input [2:0] btn,
    input [7:0] sw,
    input RsRx, // UART rx
    output RsTx, // UART tx
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led,
    output uartTx, // JB1 for 오실로스코프
    output uartRx  // JB2 for 오실로스코프
    );

    wire [2:0] w_debounced_btn;
    wire [7:0] w_rx_data;
    wire w_rx_done;
    wire [13:0] w_seg_data;

    btn_debounce u_btn_debounce(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .debounced_btn(w_debounced_btn)
    );

    uart_controller u_uart_controller(
        .clk(clk),
        .reset(reset),
        .rx(RsRx),
        .tx(RsTx),
        .send_data(sw), 
        .rx_data(w_rx_data), 
        .rx_done(w_rx_done)
    );

    control_tower u_control_tower(
        .clk(clk),
        .reset(reset),
        .btn(w_debounced_btn),
        .sw(8'h30),
        .rx_data(w_rx_data),
        .rx_done(w_rx_done),
        .seg_data(w_seg_data),
        .led(led)
    );

    assign uartTx = RsTx; // 오실로스코프 측정 단자
    assign uartRx = RsRx;
endmodule
