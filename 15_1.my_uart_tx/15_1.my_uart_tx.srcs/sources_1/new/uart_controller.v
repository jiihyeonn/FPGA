`timescale 1ns / 1ps

module uart_controller(
    input clk,
    input reset,
    input rx,
    input btnL,
    //input [7:0] send_data,
    output [7:0] rx_data,
    output rx_done,
    output tx // 얘네는 걍 wire
    );

    reg ff1, ff2, btn_prev;
    wire w_start_trigger;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            ff1 <= 0;
            ff2 <= 0;
            btn_prev <= 0;
        end
        else begin
            ff1 <= btnL;
            ff2 <= ff1;
            btn_prev <= ff2;
        end
    end

    assign w_start_trigger = ff2 & ~btn_prev;

    // wire w_tick_1Hz;
    wire w_tx_busy, w_tx_done, w_tx_start;
    wire [7:0] w_tx_data;

    // tick_generator # (.INPUT_FREQUENCY(100_000_000), .TICK_Hz(1)) u_tick_generator(
    //     .clk(clk),
    //     .reset(reset),
    //     .tick(w_tick_1Hz)
    // );

    data_sender u_data_sender(
        .clk(clk),
        .reset(reset),
        .start_trigger(w_start_trigger),
        //.send_data(send_data),
        .tx_busy(w_tx_busy),
        .tx_done(w_tx_done),
        .tx_data(w_tx_data),
        .tx_start(w_tx_start)
    );

    uart_tx #(.BPS(9600)) u_uart_tx(
        .clk(clk),
        .reset(reset),
        .tx_data(w_tx_data),
        .tx_start(w_tx_start),
        .tx(tx),
        .tx_busy(w_tx_busy),
        .tx_done(w_tx_done)
    );



endmodule
