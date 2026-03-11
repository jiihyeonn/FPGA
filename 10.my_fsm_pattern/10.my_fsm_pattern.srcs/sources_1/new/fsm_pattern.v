`timescale 1ns / 1ps

module fsm_pattern(
    input wire clk,
    input wire reset,
    input wire din_bit,
    output reg detect_out
    );

    // 상태 정의
    parameter start = 3'b000, st1 = 3'b001, st2 = 3'b010, st3 = 3'b011, st4 = 3'b100;     
    
    reg [2:0] current_state = start;
    reg [2:0] next_state;


    // 1. Next state logic (조합 회로)
    always @(*) begin
        case (current_state)
            start : next_state = (din_bit) ? start : st1; 
            st1 : next_state = (din_bit) ? st2 : st1;
            st2 : next_state = (din_bit) ? st3 : st1;
            st3 : next_state = (din_bit) ? start : st4;
            st4 : next_state = (din_bit) ? st2 : st1;
            default: next_state = start; // latch 방지 위해 
        endcase
    end

 
    // 2. state register (순차 회로)
    always @(posedge clk, posedge reset) begin
        if(reset)
           current_state <= start;
        else current_state <= next_state;
    end

    // 3. output logic (조합 회로)
    always @(*) begin
        detect_out = 1'b0; // 기본값 설정 : latch 방지(이전상태 계속 유지하는거 방지)

        case (current_state)
            st3: begin
                if(din_bit == 1'b0) detect_out = 1'b1; // 0110을 만났으니 out = 1
                else detect_out =  1'b0;
            end 
            default: detect_out = 1'b0;
        endcase
    end

endmodule
