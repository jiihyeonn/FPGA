`timescale 1ns / 1ps

module tb_encoder();
    reg [3:0] r_d;
    wire [1:0] w_a;
    // 검증 할 모듈 인스턴스화
    encoder u_encoder(
    .d(r_d),
    .a(w_a)
    );
    // test scenario 작성
    initial begin
        // 초기값 설정
        r_d=4'b0000;
        #10; r_d=4'b1000;
        #10; r_d=4'b0100;
        #10; r_d=4'b0010;
        #10; r_d=4'b0001;
        #10; $finish;
    end
    
endmodule