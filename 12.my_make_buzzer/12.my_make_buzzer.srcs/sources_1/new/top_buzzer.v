`timescale 1ns / 1ps

module top_buzzer(
    input clk,
    input reset, //sw[15]
    input btnMY, // 외부 버튼 , 1KHz -> 2KHz -> 3KHz -> 4KHz
    input btnR, // 261 -> 329 -> 392 -> 554 -> no beep
    output buzzer
    );

    wire w_btnMY, w_btnR;

    debouncer u_btnMY_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnMY),
        .clean_btn(w_btnMY)
    );

    debouncer u_btnR_debouncer (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btnR),
        .clean_btn(w_btnR)
    );

    play_melody u_play_melody(
        .clk(clk),
        .reset(reset),
        .btnMY(w_btnMY),  
        .btnR(w_btnR),
        .buzzer(buzzer)
    );

endmodule
