`timescale 1ns / 1ps

module tb_decoder();
    // 입력: reg 출력: wire
    reg [1:0] r_a;
    wire [3:0] w_led;

    // 검증 할 모듈 인스턴스화
    decoder u_decoder(
    .a(r_a),
    .led(w_led)
    );

    // test scenario 작성
    initial begin
        // 초기값 설정
        r_a=2'b00;
        #10; r_a=2'b01;
        #10; r_a=2'b10;
        #10; r_a=2'b11;
        #10; $finish;
    end

endmodule
