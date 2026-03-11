`timescale 1ns / 1ps

// 100MHz / 10 -> 10MHz 주파수 만들기
// 10MHz는 100MHz의 10% 조절 해상도를 가질 수 있는 최대 주파수
// 0~9 까지 총 10번의 클럭 셈
module pwm_duty_control(
    input clk,
    input reset,
    input duty_inc,
    input duty_dec,
    output [3:0] DUTY_CYCLE, // FND 출력 표시 0~9
    output PWM_OUT,
    output PWM_OUT_LED
    );
    
    reg [3:0] r_DUTY_CYCLE = 4'd5;
    reg [3:0] r_counter_PWM;
    
    // edge 검출 register
    reg r_prev_duty_inc;
    reg r_prev_duty_dec;

    wire w_duty_inc = (duty_inc && !r_prev_duty_inc); // rising edge 검출
    wire w_duty_dec = (duty_dec && !r_prev_duty_dec);

    // 1. duty cycle 제어 btU, btnD
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_DUTY_CYCLE  <= 4'd5; // 50% duty
        end
        else begin
            r_prev_duty_inc <= duty_inc;
            r_prev_duty_dec <= duty_dec;

            if (w_duty_inc && r_DUTY_CYCLE < 4'd9)
                r_DUTY_CYCLE <= r_DUTY_CYCLE + 1;
            if (w_duty_dec && r_DUTY_CYCLE > 4'd1)
                r_DUTY_CYCLE <= r_DUTY_CYCLE - 1;
        end
    end

    // 2. 10MHz PWM 신호 생성(0~9)
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_counter_PWM <= 0;
        end
        else begin
            if (r_counter_PWM >= 4'd9)
                r_counter_PWM <= 0;
            else
                r_counter_PWM <= r_counter_PWM + 1;
        end
    end

    assign PWM_OUT = (r_counter_PWM < r_DUTY_CYCLE) ? 1'b1 : 1'b0;
    assign PWM_OUT_LED = PWM_OUT;
    assign DUTY_CYCLE = r_DUTY_CYCLE;

endmodule
