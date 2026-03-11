`timescale 1ns / 1ps

module control_tower(
    input tick,
    input [2:0] btn,
    output [13:0] seg_data
);
    
    // mode define
    parameter MIN_SEC = 2'b01;
    parameter STOP_WATCH = 2'b10;
    parameter IDLE = 2'b11;

    parameter IDLE_SEG = 14'b11111111111111;    // IDLE임을 전하기 위한 상수

    reg [1:0] r_mode = MIN_SEC;
    reg isPaused = 0;
    reg isReset = 0;
    reg [2:0] r_prev_btn = 0;

    reg [12:0] idle_time = 0;

    reg [9:0] clk_ms = 0;
    reg [5:0] clk_sec = 0; // 0~59초
    reg [5:0] clk_min = 0; // 0~59분

    reg [3:0] sw_tick_count = 0;
    reg [6:0] sw_ms = 0; // 00~99 (10ms)
    reg [5:0] sw_sec = 0; //0~99초

    // mode check
    always @(posedge tick) begin
        if(btn[0] && !r_prev_btn[0]) begin
            if(r_mode == MIN_SEC) begin
                r_mode <= STOP_WATCH;
                isPaused <= 1;
                isReset <= 1;
            end else begin
                r_mode <= MIN_SEC;
                isPaused <= 0;
                isReset <= 0;
            end
        end else if(btn[1] && !r_prev_btn[1] && r_mode == STOP_WATCH) begin
            isPaused <= 1;
            isReset <= 1;
        end else if(btn[2] && !r_prev_btn[2] && r_mode == STOP_WATCH) begin
            isPaused <= ~isPaused;
            isReset <= 0;
        end

        if(isPaused) begin
            if(idle_time == 4999) begin
                idle_time <= 0;
                r_mode <= IDLE;
            end else begin
                idle_time <= idle_time + 1;
            end
        end else begin
            idle_time <= 0;
        end

        r_prev_btn <= btn;
    end

    // MIN_SEC CLOCK
    always @(posedge tick) begin
        if(clk_ms == 999) begin
            clk_ms <= 0;
            if(clk_sec == 59) begin
                clk_sec <= 0;
                clk_min <= clk_min + 1;
            end else begin
                clk_sec <= clk_sec + 1;
            end
        end else begin
            clk_ms <= clk_ms + 1;
        end
    end

// STOP_WATCH
    always @(posedge tick or posedge isReset) begin
        if (isReset) begin
            sw_tick_count <= 0;
            sw_ms <= 0;
            sw_sec <= 0;
        end else if (r_mode == STOP_WATCH) begin
            if (!isPaused) begin
                if (sw_tick_count == 9) begin
                    sw_tick_count <= 0;
                    if (sw_ms == 99) begin
                        sw_ms <= 0;
                        if (sw_sec == 99) begin
                            sw_sec <= 0;
                        end else begin
                            sw_sec <= sw_sec + 1;
                        end
                    end else begin
                        sw_ms <= sw_ms + 1;
                    end
                end else begin
                    sw_tick_count <= sw_tick_count + 1;
                end
            end
        end
    end

    assign seg_data = (r_mode == IDLE) ? IDLE_SEG : 
            (r_mode == MIN_SEC) ? (clk_min * 100 + clk_sec) : (sw_sec * 100 + sw_ms);
    

endmodule
