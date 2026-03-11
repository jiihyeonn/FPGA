`timescale 1ns / 1ps

module play_melody(
    input clk,
    input reset, //sw[15]
    input btnMY, // 외부 버튼 , 1KHz -> 2KHz -> 3KHz -> 4KHz
    input btnR, // 261 -> 329 -> 392 -> 554 -> no beep
    output buzzer
    );

    localparam ms70 = 23'd7_000_000; 
 
    // input clk : 100MHz
    // output freq
    // (100MHz / 원하는 주파수) / 2 : duty 50%
    // => 원하는 주파수번?? 261Hz면 261번반복하면 원하는 소리 얻음
    localparam MY_1 = 22'd50_000; // 50% duty 1. 1kHz
    localparam MY_2 = 22'd25_000; // 50% duty 2. 2kHz
    localparam MY_3 = 22'd16_667; // 50% duty 3. 3kHz
    localparam MY_4 = 22'd12_500; // 50% duty 4. 4kHz

    localparam R_1 = 22'd191_571; // 50% duty 1. 261 Hz
    localparam R_2 = 22'd151_976; // 50% duty 2. 329 Hz
    localparam R_3 = 22'd127_551; // 50% duty 3. 392 Hz
    localparam R_4 = 22'd90_253;  // 50% duty 4. 554 Hz

    // reg [21:0] r_clk_cnt[1:0]; // 2차원 array 배열
    // reg [1:0] r_buzzer_frequency;
    wire [1:0] btn_ary = {btnR, btnMY};

    reg [2:0] btnMY_step;         // 0: Off, 1~4: Play step
    reg [22:0] ms70_timer;       // 70ms 타이머
    reg [21:0] clk_cnt;     // 주파수 생성용 카운터
    reg MY_buzzer;             // MY 버튼 부저 출력

    // 현재 단계(step)에 따른 목표 주파수 할당
    reg [21:0] step;

    always @(*) begin
        case(btnMY_step)
            1: step = MY_1;
            2: step = MY_2;
            3: step = MY_3;
            4: step = MY_4;
            default: step = MY_1;
        endcase
    end

    // 70ms 시퀀스 진행 로직 및 부저 출력
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            btnMY_step <= 0;
            ms70_timer <= 0;
            clk_cnt <= 0;
            MY_buzzer <= 0;
        end else begin
            // 버튼이 눌리면 시퀀스 1단계 시작
            if (btn_ary[0] && btnMY_step == 0) begin
                btnMY_step <= 1;
                ms70_timer <= 0;
                clk_cnt <= 0;
            end 
            // 시퀀스가 진행 중일 때 (Step 1~4)
            else if (btnMY_step > 0) begin
                // 70ms 타이머 체크
                if (ms70_timer >= ms70 - 1) begin
                    ms70_timer <= 0;
                    if (btnMY_step == 4) 
                        btnMY_step <= 0; // 4단계 끝나면 Off
                    else btnMY_step <= btnMY_step + 1;    // 다음 단계로 이동
                end else begin
                    ms70_timer <= ms70_timer + 1;
                end

                // 주파수 생성
                if (clk_cnt >= step - 1) begin
                    clk_cnt <= 0;
                    MY_buzzer <= ~MY_buzzer;
                end else begin
                    clk_cnt <= clk_cnt + 1;
                end
            end else begin
                MY_buzzer <= 0; // 대기 상태일 때는 소리 끄기
            end
        end
    end


    // btnR 시퀀스 제어 (261 -> 329 -> 392 -> 554)
    reg [2:0] btnR_step;
    reg R_buzzer;
    reg [22:0] R_ms70_timer;       // 70ms 타이머
    reg [21:0] R_clk_cnt;     // 주파수 생성용 카운터

    reg [21:0] step_R;

    always @(*) begin
        case(btnR_step)
            1: step_R = R_1;
            2: step_R = R_2;
            3: step_R = R_3;
            4: step_R = R_4;
            default: step_R = R_1;
        endcase
    end

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            btnR_step <= 0;
            R_ms70_timer <= 0;
            R_clk_cnt <= 0;
            R_buzzer <= 0;
        end else begin
            if (btn_ary[1] && btnR_step == 0) begin
                btnR_step <= 1;
                R_ms70_timer <= 0;
                R_clk_cnt <= 0;
            end 
            else if (btnR_step > 0) begin
                if (R_ms70_timer >= ms70- 1) begin
                    R_ms70_timer <= 0;
                    if (btnR_step == 4) btnR_step <= 0;
                    else btnR_step <= btnR_step + 1;
                end else begin
                    R_ms70_timer <= R_ms70_timer + 1;
                end

                if (R_clk_cnt >= step_R - 1) begin
                    R_clk_cnt <= 0;
                    R_buzzer <= ~R_buzzer;
                end else begin
                    R_clk_cnt <= R_clk_cnt + 1;
                end
            end else begin
                R_buzzer <= 0;
            end
        end
    end

    // 최종 부저 출력 (L버튼 소리 또는 R버튼 소리)
    assign buzzer = MY_buzzer | R_buzzer;

endmodule