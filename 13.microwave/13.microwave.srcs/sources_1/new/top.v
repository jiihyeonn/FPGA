`timescale 1ns / 1ps

module top(
    input clk,
    input reset, //sw[15]
    input btnU, // 전자레인지 on/off
    input btnL, // 10초씩 증가
    input btnC, // 전자레인지 open/close
    input btnR, // 30초씩 증가
    input btnD, // 취소
    output led, // 전자레인지 on/off 켜지고 꺼지고
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