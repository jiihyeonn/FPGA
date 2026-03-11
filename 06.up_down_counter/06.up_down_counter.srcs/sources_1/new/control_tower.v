`timescale 1ns / 1ps

module control_tower(
    input clk,
    input reset, // sw[15]
    input [2:0] btn, // btn[0] : btnL, btn[1] : btnC, btn[2] : btnR
    input [7:0] sw,
    output [13:0] seg_data // 999까지 표현해야해서 14비트
   // output reg [15:0] led
    );
    // mode define
    parameter UP_COUNTER = 3'b01;
    parameter DOWN_COUNTER = 3'b10;
    parameter SLIDE_SW_READ = 3'b11;

    reg r_prev_btnL = 0;
    reg [2:0] r_mode = 3'b000;
    reg [19:0] r_counter; // 10ms를 재기 위한 counter: 10ns x 1_000_000
    reg [13:0] r_ms10_counter; // 10ms가 될때마다 1증가, 9999될때까지

    // mode check module
    always @(posedge clk, posedge reset) begin
        if (reset) begin
            r_mode <= 0; // clear 시켜주는거야
            r_prev_btnL <= 0;
        end
        else begin
            if (btn[0] && !r_prev_btnL)
              r_mode = (r_mode == SLIDE_SW_READ) ? UP_COUNTER : r_mode + 1;
        end
        r_prev_btnL <= btn[0];
    end
    // up counter
    always @(posedge clk, posedge reset)begin
        if (reset) begin
            r_counter <= 0;
            r_ms10_counter <= 0;
        end
        else if(r_mode == UP_COUNTER) begin // 1. add logic
            if (r_counter == 20'd1_000_000-1) begin // 10ms
                r_counter <= 0;
                if (r_ms10_counter >= 9999) // 9999 도달시 0
                    r_ms10_counter <= 0;
                else r_ms10_counter <= r_ms10_counter + 1;
                    //led [13:0] <= r_ms10_counter; // led 출력
            end
            else begin
                r_counter <= r_counter + 1;
            end
        end
        else if(r_mode == DOWN_COUNTER) begin // 2. sub logic
            if (r_counter == 20'd1_000_000-1) begin // 10ms
                r_counter <= 0;
                if (r_ms10_counter == 0) // 0 도달시 9999
                    r_ms10_counter <= 9999;
                else r_ms10_counter <= r_ms10_counter - 1;
                    //led [13:0] <= r_ms10_counter; // led 출력
            end
            else begin
                r_counter <= r_counter + 1;
            end
        end
        else begin // 3. SLIDE_SW_READ or IDLE mode
            r_counter <= 0;
            r_ms10_counter <= 0;            
        end
    end

    // -- led mode display --
    //always @(r_mode) begin // r_mode가 변경 될때 실행
        //case (r_mode)
            //UP_COUNTER: begin 
              //  led[15:14] = UP_COUNTER;
           // end
           // DOWN_COUNTER: begin
           //     led[15:14] = DOWN_COUNTER;
           // end
           // SLIDE_SW_READ:begin
           //     led[15:14] = SLIDE_SW_READ;
            //end
            //default:
             //   led[15:14] = 3'b00;
       // endcase
   // end

    // seg data 출력
    assign seg_data = (r_mode == UP_COUNTER) ? r_ms10_counter : 
                      (r_mode == DOWN_COUNTER) ? r_ms10_counter : sw;    
endmodule
