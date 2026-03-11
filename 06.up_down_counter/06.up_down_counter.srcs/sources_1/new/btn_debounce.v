`timescale 1ns / 1ps

module btn_debounce(
    input clk,
    input reset,
    input [2:0] btn,   // 3개의 버튼 입력: btn[2:0] → 각각 btnL, btnC, btnR, 노이즈 있는 값
    output [2:0] debounced_btn // 노이즈 제거된 값
);
    debouncer U_debouncer_btnL (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[0]),
        .clean_btn(debounced_btn[0])
    );

    debouncer U_debouncer_btnC (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[1]),
        .clean_btn(debounced_btn[1])
    );

    debouncer U_debouncer_btnR (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[2]),
        .clean_btn(debounced_btn[2])
    );

 //   assign led = debounced_btn;   // button을 누를때 마다 led가 동작 되도록 한다.
endmodule
