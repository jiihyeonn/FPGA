`timescale 1ns / 1ps

module play_melody(
    input clk,
    input reset, //sw[15]
    input btnU, // 도 261.63 Hz
    input btnL, // 레 293.66 Hz
    input btnC, // 미 329.63 Hz
    input btnR, // 솔 392.00 Hz
    input btnD, // 라 440.00 Hz
    output buzzer
    );

    // input clk : 100MHz
    // output freq
    // (100MHz / 원하는 주파수) / 2 : duty 50%
    // => 원하는 주파수번?? 261Hz면 261번반복하면 원하는 소리 얻음
    localparam DO = 22'd191_112; // 50% duty 도 261.63 Hz
    localparam RE = 22'd170_265; // 50% duty 레 293.66 Hz
    localparam MI = 22'd151_685; // 50% duty 미 329.63 Hz
    localparam SOL = 22'd237_551; // 50% duty 솔 392.00 Hz
    localparam RA = 22'd113_636; // 50% duty 라 440.00 Hz

    reg [21:0] r_clk_cnt[4:0]; // 2차원 array 배열
    reg [4:0] r_buzzer_frequency;
    wire [4:0] btn_ary = {btnD, btnR,  btnC, btnL, btnU};

    integer i; // integer : signed 32bit(부호가 있는), reg [31:0] : usigned 32bits(부호 없는)

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            for(i = 0; i < 5; i = i+1) begin
                r_clk_cnt[i] <= 22'd0;
                r_buzzer_frequency[i] <= 1'b0; 
            end
        end
        else begin
            // 도 (btnU) 261.63 Hz 생성
            if (!btn_ary[0]) begin
                r_clk_cnt[0] <= 0;
                r_buzzer_frequency[0] <= 1'b0;
            end 
            else if (r_clk_cnt[0] >= DO - 1) begin
                r_clk_cnt[0] <= 0;
                r_buzzer_frequency[0] <= ~r_buzzer_frequency[0]; // 도의 50% duty 되면 반전 HIGH->LOW 
            end else r_clk_cnt[0] <= r_clk_cnt[0] + 1;
        
            // 레 (btnL) 293.66 Hz 생성
            if (!btn_ary[1]) begin
                r_clk_cnt[1] <= 0;
                r_buzzer_frequency[1] <= 1'b0;
            end 
            else if (r_clk_cnt[1] >= RE - 1) begin
                r_clk_cnt[1] <= 0;
                r_buzzer_frequency[1] <= ~r_buzzer_frequency[1];
            end else r_clk_cnt[1] <= r_clk_cnt[1] + 1;

            // 미 (btnC) 329.63 Hz 생성
            if (!btn_ary[2]) begin
                r_clk_cnt[2] <= 0;
                r_buzzer_frequency[2] <= 1'b0;
            end 
            else if (r_clk_cnt[2] >= MI - 1) begin
                r_clk_cnt[2] <= 0;
                r_buzzer_frequency[2] <= ~r_buzzer_frequency[2];
            end else r_clk_cnt[2] <= r_clk_cnt[2] + 1;

            // 솔 (btnR) 392.00 Hz 생성
            if (!btn_ary[3]) begin
                r_clk_cnt[3] <= 0;
                r_buzzer_frequency[3] <= 1'b0;
            end 
            else if (r_clk_cnt[3] >= SOL - 1) begin
                r_clk_cnt[3] <= 0;
                r_buzzer_frequency[3] <= ~r_buzzer_frequency[3];
            end else r_clk_cnt[3] <= r_clk_cnt[3] + 1;

            // 라 (btnD) 440.00 Hz 생성
            if (!btn_ary[4]) begin
                r_clk_cnt[4] <= 0;
                r_buzzer_frequency[4] <= 1'b0;
            end 
            else if (r_clk_cnt[4] >= RA - 1) begin
                r_clk_cnt[4] <= 0;
                r_buzzer_frequency[4] <= ~r_buzzer_frequency[4];
            end else r_clk_cnt[4] <= r_clk_cnt[4] + 1;
        end
    end
 
    // assign buzzer = r_buzzer_frequency[4] | r_buzzer_frequency[3] | r_buzzer_frequency[2] |
    //                 r_buzzer_frequency[1] | r_buzzer_frequency[0];
    // => 하나하나 OR

    assign buzzer = |r_buzzer_frequency;
    // Verilog 축약 OR 연산자 '|' 값 전체를 OR 해서 넣는거
    // 0(false) : 5개 비트 모두 0일때만 결과 0(아무 버튼도 누르지 X) 
    // 1(true)  : 5개의 비트 중 어느 하나라도 1이면 결과 1(하나 이상 음계 재생 상태)
endmodule
