`timescale 1ns / 1ps

module fnd_control(
    input clk,
    input reset, 
    input [3:0] DUTY_CYCLE,
    input [1:0] motor_direction,
    output [7:0] seg,
    output [3:0] an
    );

    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    // 1초 깜빡임을 위한 카운터 및 상태 레지스터 (100MHz 기준)
    reg [26:0] r_1s_counter = 0;
    reg r_blink = 0; // 1: ON, 0: OFF

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_1s_counter <= 0;
            r_blink <= 0;
        end
        else begin
            if (r_1s_counter == 100_000_000 - 1) begin // 1초
                r_1s_counter <= 0;
                r_blink <= ~r_blink;         // 1초마다 상태 반전
            end
            else begin
                r_1s_counter <= r_1s_counter + 1;
            end
        end
    end

    reg [3:0] r_d1000;

    always @(*) begin
        if (r_blink == 1'b0) begin
            r_d1000 = 4'hF; // 깜빡임 OFF 상태일 때는 빈 화면
        end
        else begin
            if (motor_direction == 2'b01)      r_d1000 = 4'hA; // 정방향 'F'
            else if (motor_direction == 2'b10) r_d1000 = 4'hB; // 역방향 'b'
            else                                  r_d1000 = 4'hF; // 정지 시 빈 화면
        end
    end
    assign w_d1000 = r_d1000;

    assign w_d1 = DUTY_CYCLE; // 1의 자리만 duty cyclce 값
    assign w_d10 = 4'd0; // 10의 자리는 0 출력
    assign w_d100 = 4'd0; // 100의 자리는 0 출력

    fnd_digit_select u_fnd_digit_select(
    .clk(clk),
    .reset(reset),
    .sel(w_sel)
    );

    fnd_digit_display u_fnd_digit_display(
    .digit_sel(w_sel),
    .d1(w_d1),
    .d10(w_d10),
    .d100(w_d100),
    .d1000(w_d1000),
    .an(an),
    .seg(seg)
    );

endmodule

//---------------------------------------------------
// 1ms마다 fnd를 display하기 위해서 1자리씩 선택하는 logic
// 4ms까지는 잔상 효과가 있다. 그 이상의 시간 지연을 주면 깜박임 현상 발생 주의 요함
//---------------------------------------------------
module fnd_digit_select(
    input clk,
    input reset, // sw[15]
    output reg [1:0] sel // 00 01 10 11 : 1ms마다 바뀐다
    );
    reg [$clog2(100_000):0] r_1ms_counter = 0;
    
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_1ms_counter <= 0;
            sel <= 0;
        end 
        else begin
            if (r_1ms_counter == 100_000-1) begin //1ms
                r_1ms_counter <= 0;
                sel <= sel + 1;
            end
            else begin
                r_1ms_counter <= r_1ms_counter + 1;
            end
        end
    end
endmodule

module fnd_digit_display(
    input [1:0] digit_sel,
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,
    output reg [3:0] an,
    output reg [7:0] seg
    );
    reg [3:0] bcd_data;

    always @(*) begin // digit_sel값이 바뀔 때는 언제나 실행
        case(digit_sel)
             2'b00:begin
                bcd_data = d1;
                an = 4'b1110;
             end
             2'b01:begin
                bcd_data = d10;
                an = 4'b1101;
             end
             2'b10:begin
                bcd_data = d100;
                an = 4'b1011;
             end
             2'b11:begin
                bcd_data = d1000;
                an = 4'b0111;
             end
            default: begin
                bcd_data = 4'b0000;
                an = 4'b1111;
            end
        endcase
    end

    always @(bcd_data) begin
        case (bcd_data)
            4'd0: seg = 8'b11000000; // 0
            4'd1: seg = 8'b11111001; // 1
            4'd2: seg = 8'b10100100; // 2
            4'd3: seg = 8'b10110000; // 3
            4'd4: seg = 8'b10011001; // 4
            4'd5: seg = 8'b10010010; // 5
            4'd6: seg = 8'b10000010; // 6
            4'd7: seg = 8'b11111000; // 7
            4'd8: seg = 8'b10000000; // 8
            4'd9: seg = 8'b10010000; // 9

            4'hA: seg = 8'b10001110; // f
            4'hB: seg = 8'b10000011; // b
            4'hF: seg = 8'b11111111; // off

            default: seg = 8'b11111111; // all off

        endcase
    end

endmodule