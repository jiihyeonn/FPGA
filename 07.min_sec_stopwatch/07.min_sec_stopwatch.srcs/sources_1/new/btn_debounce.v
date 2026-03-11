module btn_debouncer(
    input tick,
    input [2:0] btn,   // 3개의 버튼 입력: btn[2:0] → 각각 btnL, btnC, btnR
    output [2:0] debounced_btn
);
    debouncer U_debouncer_btnL (
        .tick(tick),
        .noisy_btn(btn[0]),
        .clean_btn(debounced_btn[0])
    );

    debouncer U_debouncer_btnC (
        .tick(tick),
        .noisy_btn(btn[1]),
        .clean_btn(debounced_btn[1])
    );

    debouncer U_debouncer_btnR (
        .tick(tick),
        .noisy_btn(btn[2]),
        .clean_btn(debounced_btn[2])
    );

endmodule

module debouncer (
  input tick,
  input noisy_btn,
  output reg clean_btn = 0
);
    reg [3:0] count = 0;
    reg btn_state = 0;

    always @(posedge tick) begin
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
endmodule