`timescale 1ns / 1ps

module btn_debounce(
   input reset,
   input tick,          // 1ms 기준 틱
   input [2:0] btn,     // 물리적 버튼 입력
   output [2:0] debounced_btn // 노이즈가 제거된 버튼 출력
);
// 각 버튼별로 디바운서 적용
   debouncer U_btnL ( 
    .reset(reset), 
    .tick(tick), 
    .noisy_btn(btn[0]), 
    .clean_btn(debounced_btn[0])
   );
   debouncer U_btnC (
    .reset(reset), 
    .tick(tick), 
    .noisy_btn(btn[1]), 
    .clean_btn(debounced_btn[1])
   );
   debouncer U_btnR (
    .reset(reset), 
    .tick(tick), 
    .noisy_btn(btn[2]), 
    .clean_btn(debounced_btn[2])
   );
endmodule

module debouncer (
  input reset,
  input tick,
  input noisy_btn,
  output reg clean_btn
);
reg [3:0] count;
reg btn_state;

always @(posedge tick or posedge reset) begin
    if (reset) begin
        count <= 0;
        btn_state <= 0;
        clean_btn <= 0;
    end else if (tick) begin
        if (noisy_btn == btn_state) begin // 상태가 유지되면 카운트 초기화
            count <= 0;
        end else begin
            count <= count + 1;
            if (count >= 10) begin // 10ms (10 tick) 동안 동일한 상태가 유지되면
                btn_state <= noisy_btn; // 안정된 상태로 인정하고 값 갱신
                clean_btn <= noisy_btn;
                count <= 0;
            end
        end
    end
end
endmodule