// `timescale 1ns / 1ps

// module top(
// input clk,          // 100MHz 기본 클럭
// input reset,        // sw[15] 
// input [2:0] btn,    // btn[0]: coin 투입, btn[1]: 동전 반환 버튼, btn[2]: 커피선택 버튼
// output [7:0] seg,   // FND
// output [3:0] an     // FND 자릿수 선택 (Active Low)
// );
//     // 내부 모듈 간 연결을 위한 와이어 선언
//     wire w_tick;                 // 1ms마다 발생하는 동기화 틱 신호
//     wire [2:0] w_debounced_btn;  // 노이즈가 제거된 깔끔한 버튼 신호

//     wire w_coffee_out;       // 커피 배출 완료 센서 신호
//     wire [15:0] w_coin_val; // 현재 금액 표시
//     wire w_seg_en;      // FND 활성화 신호
//     wire w_coffee_make; // 커피 제조 시작 신호
//     wire w_coin_return;  // 동전 반환 동작 신호

// // 1. 1ms Tick 생성기 인스턴스화
// tick_generator u_tick_gen(
//     .clk(clk),
//     .reset(reset),
//     .tick(w_tick)
// );

// // 2. 버튼 디바운스 인스턴스화
// btn_debounce u_btn_debounce(
//     .reset(reset),
//     .tick(w_tick),
//     .btn(btn),
//     .debounced_btn(w_debounced_btn)
// );

// // 3. coffee machine 인스턴스화
// coffee_machine u_coffee_machine(
//     .tick(w_tick),
//     .reset(reset), 
//     .coin(w_debounced_btn[0]),
//     .coffee_btn(w_debounced_btn[2]),
//     .coin_return_btn(w_debounced_btn[1]),
//     .coffee_out(w_coffee_out),       // 커피 배출 완료 센서 신호
//     .coin_val(w_coin_val), // 현재 금액 표시
//     .seg_en(w_seg_en),      // FND 활성화 신호
//     .coffee_make(w_coffee_make), // 커피 제조 시작 신호
//     .coin_return(w_coin_return)  // 동전 반환 동작 신호
// );

// // fnd_controller u_fnd_controller(
// //     .tick(w_tick),
// //     .reset(reset), 
// //     .in_data(w_coin_val),
// //     .seg(seg),
// //     .an(an)
// // );

//  fnd_controller u_fnd_controller(
//     .tick(w_tick),
//     .reset(reset), 
//     .in_data(w_coin_val),
//     .seg_en(w_seg_en),
//     .coffee_make(w_coffee_make),
//     .coffee_out(w_coffee_out), 
//     .seg(seg),
//     .an(an)
//     );

// endmodule

`timescale 1ns / 1ps

module top(
    input clk,          
    input reset,        
    input [2:0] btn,    
    output [7:0] seg,   
    output [3:0] an     
);
    wire w_tick;                 
    wire [2:0] w_debounced_btn;  

    wire w_coffee_out;       
    wire [13:0] w_coin_val;  
    wire w_seg_en;           
    wire w_coffee_make;

    tick_generator u_tick_gen(
        .clk(clk),
        .reset(reset),
        .tick(w_tick)
    );

    btn_debounce u_btn_debounce(
        .reset(reset),
        .tick(w_tick),
        .btn(btn),
        .debounced_btn(w_debounced_btn)
    );

    coffee_machine u_coffee_machine(
        .tick(w_tick), 
        .reset(reset), 
        .coin(w_debounced_btn[0]),
        .coin_return_btn(w_debounced_btn[1]),
        .coffee_btn(w_debounced_btn[2]),
        .coffee_out(w_coffee_out), 
        .coin_val(w_coin_val),
        .seg_en(w_seg_en),
        .coffee_make(w_coffee_make)  
    );

    fnd_controller u_fnd_controller(
        .tick(w_tick), 
        .reset(reset), 
        .in_data(w_coin_val),
        .seg_en(w_seg_en),
        .coffee_make(w_coffee_make),
        .coffee_out(w_coffee_out),
        .seg(seg),
        .an(an)
    );
endmodule