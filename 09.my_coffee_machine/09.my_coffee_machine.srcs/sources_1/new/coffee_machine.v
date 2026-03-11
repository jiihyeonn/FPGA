// `timescale 1ns / 1ps

// module coffee_machine(
//     input tick, reset, coin,
//     input coffee_btn,
//     input coin_return_btn,  // 동전 반환 버튼
//     input coffee_out,       // 커피 배출 완료 센서 신호
//     output reg [13:0] coin_val, // 현재 금액 표시
//     output reg seg_en,      // FND 활성화 신호
//     output reg coffee_make, // 커피 제조 시작 신호
//     output reg coin_return  // 동전 반환 동작 신호
// );

//     parameter IDLE = 3'd0,
//               COIN_IN = 3'd1,
//               READY = 3'd2,
//               COFFEE = 3'd3,
//               COIN_OUT = 3'd4;

//     parameter COFFEE_VAL = 300;  // coffee 가격
//     reg [2:0] r_current_state = IDLE;
//     reg [2:0] r_next_state;

//     // coin 투입 check logic
//     // edge detect
//     reg r_coin_reg;
//     wire w_coin_pulse;

//     always @(posedge tick, posedge reset) begin
//         if(reset) begin
//             r_coin_reg <= 0;
//         end else begin
//             r_coin_reg <= coin;
//         end
//     end

//     assign w_coin_pulse = (coin && !r_coin_reg);    // 상승 엣지 검출

//     always @(*) begin
//         r_next_state = r_current_state;
//         case(r_current_state)
//         IDLE: begin
//             if(w_coin_pulse) r_next_state = COIN_IN;
//         end
//         COIN_IN: begin
//             if(coin_return_btn) r_next_state = COIN_OUT;
//             else if(coin_val >= COFFEE_VAL) r_next_state = READY;
//         end
//         READY: begin
//             if(coin_return_btn || coin_val < COFFEE_VAL)
//                 r_next_state = COIN_OUT;
//             else if(coffee_btn)
//                 r_next_state = COFFEE;
//         end
//         COFFEE: begin
//             if(coffee_out) r_next_state = READY;
//         end
//         COIN_OUT: begin
//             if(coin_val == 0) r_next_state = IDLE;
//         end
//         default: begin
//             r_next_state = IDLE;
//         end
//         endcase
//     end

//     always @(posedge tick, posedge reset) begin
//         if(reset) begin
//             r_current_state <= IDLE;
//         end else begin
//             r_current_state <= r_next_state;
//         end
//     end

//     // 동전 add/sub logic 추가
//     always @(posedge tick, posedge reset) begin
//         if(reset) begin
//             coin_val <= 0;
//         end else begin
//             // edge 검출을 통해서 어떤 상태이든지 동전 투입시 가산하는 logic
//             if(w_coin_pulse && (r_current_state == IDLE 
//                     || r_current_state == COIN_IN 
//                     || r_current_state == READY)) begin
//                 coin_val <= coin_val + 16'd100;
//             end

//             // 커피 제조 완료시 차감
//             if(r_current_state == COFFEE && coffee_out) begin
//                 coin_val <= coin_val - COFFEE_VAL;
//             end

//             if(r_current_state == COIN_OUT) begin
//                 coin_val <= 0;
//             end
//         end
//     end

//     // output logic (조합 회로)
//     always @(*) begin
//         seg_en = 0;
//         coffee_make = 0;
//         coin_return = 0;
//         case(r_current_state)
//         IDLE: ;
//         COIN_IN: seg_en = 1;
//         READY: seg_en = 1;
//         COFFEE: begin
//             seg_en = 1;
//             coffee_make = 1;
//         end
//         COIN_OUT: begin
//             seg_en = 1;
//             coin_return = 1;
//         end
//         endcase
//         if (r_current_state == COFFEE) begin
//             coffee_make = 1; // COFFEE 상태일 때만 애니메이션 시작 신호 송출
//         end
//     end

// endmodule

`timescale 1ns / 1ps

module coffee_machine(
    input tick, reset, coin,
    input coin_return_btn,
    input coffee_btn,
    input coffee_out,  
    output reg [13:0] coin_val,
    output reg seg_en,
    output reg coffee_make
);

    parameter IDLE = 3'd0,
              COIN_IN = 3'd1,
              READY = 3'd2,
              COFFEE = 3'd3,
              COIN_OUT = 3'd4;

    parameter COFFEE_VAL = 300; 
    reg [2:0] r_current_state = IDLE;
    reg [2:0] r_next_state;

    // --- 버튼 엣지 ---
    reg r_coin_reg, r_coffee_reg, r_return_reg;
    wire w_coin_pulse, w_coffee_pulse, w_return_pulse;

    always @(posedge tick, posedge reset) begin
        if(reset) begin
            r_coin_reg <= 0; r_coffee_reg <= 0; r_return_reg <= 0;
        end else begin
            r_coin_reg <= coin;
            r_coffee_reg <= coffee_btn;
            r_return_reg <= coin_return_btn;
        end
    end

    assign w_coin_pulse = (coin && !r_coin_reg);    
    assign w_coffee_pulse = (coffee_btn && !r_coffee_reg);
    assign w_return_pulse = (coin_return_btn && !r_return_reg);


    always @(*) begin //다음 상태 결정
        r_next_state = r_current_state;
        case(r_current_state)
        IDLE: if(w_coin_pulse) r_next_state = COIN_IN; // 동전 넣으면 시작
        COIN_IN: begin
            if(w_return_pulse) r_next_state = COIN_OUT; // 반환 버튼
            else if(coin_val >= COFFEE_VAL) r_next_state = READY; // 300원 이상이면 준비
            else if(coin_val == 0) r_next_state = IDLE;
        end
        READY: begin
            if(w_return_pulse) r_next_state = COIN_OUT;
            else if(coin_val < COFFEE_VAL) r_next_state = COIN_IN; // 돈모자라면 투입 상태
            else if(w_coffee_pulse) r_next_state = COFFEE; // 커피 버튼 클릭
        end
        COFFEE: begin
            if(coffee_out) r_next_state = READY; // 5초 애니메이션 끝나면 READY 돌아감
        end
        COIN_OUT: r_next_state = IDLE; // 잔돈 반환 후 대기
        default: r_next_state = IDLE;
        endcase
    end

    always @(posedge tick, posedge reset) begin 
        if(reset) r_current_state <= IDLE;
        else r_current_state <= r_next_state;
    end

    always @(posedge tick, posedge reset) begin // 금액 계산 
        if(reset) begin
            coin_val <= 0;
        end else if (r_current_state == COIN_OUT) begin /
            coin_val <= 0; // 반환 버튼 누르면 0원
        end else begin
            coin_val <= coin_val 
                      + (w_coin_pulse ? 14'd100 : 0)  // 100원씩 추가
                      - ((r_current_state == COFFEE && coffee_out) ? COFFEE_VAL : 0); // 제조 완료시 300원 차감
        end
    end

    // --- 제어 신호 출력 ---
    always @(*) begin
        seg_en = 1; 
        coffee_make = 0;
        if (r_current_state == COFFEE) coffee_make = 1; // 상태가 COFFEE일 때 애니메이션 켬
    end
endmodule




