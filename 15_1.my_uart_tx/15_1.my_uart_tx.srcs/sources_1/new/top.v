`timescale 1ns / 1ps

module top # (parameter BPS = 9600, parameter DEBOUNCE_LIMIT = 20'd999_999)(
    input clk,
    input reset,
    // input [2:0] btn,
    input btn,
    input [7:0] sw,
    input RsRx, // UART rx
    output RsTx, // UART tx
    output [7:0] seg,
    output [3:0] an,
    output [15:0] led,
    output uartTx, // JB1 for 오실로스코프
    output uartRx  // JB2 for 오실로스코프
    );

    // wire [2:0] w_debounced_btn;
    wire w_debounced_btn;

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
        .btnL(w_debounced_btn), // btnL
        //.send_data(8'h30), // btnL 누르면 PJH 차례로 출력 
        .rx_data(), 
        .rx_done(),
        .tx(RsTx)
    );

    assign uartTx = RsTx; // 오실로스코프 측정 단자
    assign uartRx = RsRx;
endmodule
