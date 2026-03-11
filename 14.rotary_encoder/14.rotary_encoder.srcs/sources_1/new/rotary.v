`timescale 1ns / 1ps

module rotary(
    input clk,
    input reset,
    input clean_s1,
    input clean_s2,
    input clean_key,
    output [15:0] led
    );

    reg [1:0] r_direction = 2'b00; // 시계 방향 : 01, 반시계 방향: 10
    reg [1:0] r_prev_state = 2'b00;
    reg [1:0] r_current_state = 2'b00;
    reg [1:0] r_step = 2'b00;
    reg [7:0] r_counter = 8'h00;

    // s1, s2 처리
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_direction <= 2'b00;
            r_prev_state <= 2'b00;
            r_current_state <= 2'b00;
            r_step <= 2'b00;
            r_counter <= 8'h00;
        end
        else begin
            r_prev_state <= r_current_state;
            r_current_state <= {clean_s1, clean_s2};
            case ({r_prev_state, r_current_state}) // 현재 값 가지고 동시실행 r_prev : 10, r_current : 11
                4'b0010, 4'b1011, 4'b1101, 4'b0100 : begin // CW : 00 -> 10 -> 11 -> 01 -> 00
                    if(r_counter < 8'hFF && r_step == 2'b11) // overflow
                    r_counter <= r_counter + 1;
                    r_step <= r_step + 1;
                    r_direction <= 2'd01; // CW indicator
                end
                4'b0001, 4'b0111, 4'b1110, 4'b1000 : begin // CCW : 00 -> 01 -> 11 -> 10 -> 00
                    if (r_counter > 8'h00 && r_step == 2'b11) // under flow
                        r_counter <= r_counter - 1;
                        r_step <= r_step + 1;
                        r_direction <= 2'b10; // 반시계 방향 표시
                end
                // default: begin
                //     r_direction <= 2'b00; // 상태 변화가 없을때는 지시등을 off
                // end
            endcase
        end
    end

    reg r_led_toggle = 1'b0;
    reg r_prev_key = 1'b0;

    // key 처리 : led 토글
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_led_toggle = 1'b0;
            r_prev_key = 1'b0;
        end
        else begin
            r_prev_key <= clean_key;
            if (!r_prev_key && clean_key) begin
                r_led_toggle <= ~r_led_toggle;
            end
        end
    end

    assign led[15:14] = r_direction;
    assign led[13] = r_led_toggle;
    assign led[12:8] =5'b00000; // 안쓰는 led : off
    assign led[7:0] = r_counter;

endmodule
