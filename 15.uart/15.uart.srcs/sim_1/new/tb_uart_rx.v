`timescale 1ns / 1ps

module tb_uart_rx();
    reg clk;
    reg reset;
    reg rx;

    wire [7:0] data_out;
    wire rx_done;

    uart_rx #(.BPS(9600)) u_uart_rx(
        .clk(clk),
        .reset(reset),
        .rx(rx),
        .data_out(data_out),
        .rx_done(rx_done)
    );

    initial clk = 0;
    always #5 clk = ~clk;
    // clk 1주기 10ns (5ns : high, 5ns : low)

    localparam CLK_FREQUENCY = 100_000_000; // 100MHz
    localparam BIT_PER_CLK_NUMBER = CLK_FREQUENCY / 9600;// 1bit당 10ns의 clk가 몇개 필요 한가 : 10416개
    localparam CLK_PERIOD_10NS = 10; // 10ns
    localparam BAUD_PERIOD = BIT_PER_CLK_NUMBER * CLK_PERIOD_10NS;// Simulation wait 시간

    always @(posedge rx_done) begin
        $display("time : %t, data_out received %h ", $time, data_out);
    end

    // UART RX SIMULATOR
    // ASCII 'U'와 'u'를 uart_rx모듈의 rx로 전송 하는 기능을 구현
    initial begin
        #00 reset = 1; rx = 1; clk = 0; 
        #100;
        reset = 0;
        #200; // reset --> IDLE
        // ----- 'U' : 0x55 0101_0101 -----
        #BAUD_PERIOD rx = 0; // start bit LOW
        #BAUD_PERIOD rx = 1; // bit 0
        #BAUD_PERIOD rx = 0; // bit 1
        #BAUD_PERIOD rx = 1; // bit 2
        #BAUD_PERIOD rx = 0; // bit 3
        #BAUD_PERIOD rx = 1; // bit 4
        #BAUD_PERIOD rx = 0; // bit 5
        #BAUD_PERIOD rx = 1; // bit 6
        #BAUD_PERIOD rx = 0; // bit 7
        #BAUD_PERIOD rx = 1; // stop bit HIGH
        #10000000; // 1ms
        $display("UART RX test finish.....");
        $finish;
    end
endmodule
                             