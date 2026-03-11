`timescale 1ns / 1ps

module control_tower(
    input clk,
    input reset,
    input btnL,
    input [7:0] hum_int,
    input [7:0] tem_int,
    input [7:0] rtc_sec,
    input [7:0] rtc_min,

    output reg [13:0] fnd_data
);

    reg r_display_mode = 1'b0; // 0: 온습도 화면, 1: 시간 화면
    reg r_prev = 1'b0;

    // BCD -> Binary
    wire [7:0] rtc_min_bin = (rtc_min[7:4] * 10) + rtc_min[3:0];
    wire [7:0] rtc_sec_bin = (rtc_sec[7:4] * 10) + rtc_sec[3:0];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_display_mode <= 1'b0;
            r_prev <= 1'b0;
        end else begin
            if (btnL == 1'b1 && r_prev == 1'b0) begin
                r_display_mode <= ~r_display_mode;
            end
            r_prev <= btnL;
        end
    end

    always @(*) begin
        if (r_display_mode == 1'b0) begin
            fnd_data = (tem_int * 100) + hum_int;
        end else begin
            fnd_data = (rtc_min_bin * 100) + rtc_sec_bin;
        end
    end

endmodule