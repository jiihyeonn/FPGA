`timescale 1ns / 1ps

module fsm_pattern(
    input wire clk,
    input wire reset,
    input wire in,
    output reg out
    );

    // 상태 정의
    parameter S0 = 3'b000, S1 = 3'b001, S2 = 3'b010, S3 = 3'b011, 
              S4 = 3'b100, S5 = 3'b101, S6 = 3'b110;     //3'd1, 3'd2 이렇게 decimal로 표현해도돼 
    
    reg [2:0] current_state = S0;
    reg [2:0] next_state;

    // ----------------------------------------------------
    // 1. Next state logic (조합 회로)
    //    현재의 상태와 입력을 보고 어디로 다음에 어디로 갈지 결정
    // (current_state)(in)         (next_state)
    // ----------------------------------------------------
    always @(*) begin
        case (current_state)
            S0 : next_state = (in) ? S1 : S0; 
            S1 : next_state = (in) ? S1 : S2;
            S2 : next_state = (in) ? S3 : S0;
            S3 : next_state = (in) ? S1 : S4;
            S4 : next_state = (in) ? S5 : S0;
            S5 : next_state = (in) ? S6 : S0;
            S6 : next_state = (in) ? S1 : S0;
            default: next_state = S0; // latch 방지 위해 
        endcase
    end

    // ----------------------------------------------------
    // 2. state register (순차 회로)
    //    현재 상태를 update 하는 회로(D F/F)
    //    클럭의 상승에지에 맞춰 상태 천이 
    // ----------------------------------------------------
    always @(posedge clk, posedge reset) begin
        if(reset)
           current_state <= S0;
        else current_state <= next_state;
    end

    // --------------------------------------------------------------------------
    // 3. output logic (조합 회로)
    //    Melay Machine : 현재 상태 + 입력에 따라 출력 결정 회로
    //    만약 Moor Machine이면 입력 조건 없이 현재 상태(current_state만으로 출력 결정)
    // --------------------------------------------------------------------------
    always @(*) begin
        out = 1'b0; // 기본값 설정 : latch 방지(이전상태 계속 유지하는거 방지)

        case (current_state)
            S6: begin
                if(in == 1'b1) out = 1'b1; // 1010111을 만났으니 LED ON
                else out =  1'b0;
            end 
            default: out = 1'b0;
        endcase
    end

endmodule
