`timescale 1ns / 1ps

module uart_controller(
    input clk,
    input reset,
    input rx,
    input [7:0] hum_int,
    input [7:0] tem_int,
    output [7:0] rx_data,
    output rx_done,
    output tx 
    );

    wire w_tick_1Hz;
    wire w_tx_busy, w_tx_done, w_tx_start;
    wire [7:0] w_tx_data;

    tick_generator # (.INPUT_FREQUENCY(100_000_000), .TICK_Hz(1)) u_tick_generator(
        .clk(clk),
        .reset(reset),
        .tick(w_tick_1Hz)
    );

    data_sender u_data_sender(
        .clk(clk),
        .reset(reset),
        .start_trigger(w_tick_1Hz),
        .hum_int(hum_int),
        .tem_int(tem_int),
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

    uart_rx #(.BPS(9600)) u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(rx_data),
        .rx_done(rx_done)
    );

endmodule

`timescale 1ns / 1ps

module tick_generator # (
    parameter INPUT_FREQUENCY = 100_000_000, // 100MHz
    parameter TICK_Hz = 1000)  
    (
    input clk,
    input reset,
    output reg tick
    );

    parameter TICK_COUNT = INPUT_FREQUENCY / TICK_Hz; // 100_000

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter = 0;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tick <= 0;
            r_tick_counter <= 0;
        end
        else begin
            if(r_tick_counter == TICK_COUNT-1)begin
                r_tick_counter <= 0;
                tick <= 1'b1;
            end
            else begin
                r_tick_counter <= r_tick_counter + 1;
                tick <= 1'b0;
            end
        end
        
    end
endmodule
