`timescale 1ns / 1ps // 1.999 ns
// 100MHz => 10 ns
module tb_gatetest();
    reg i_a; // a란 변수는 1bit 자리 저장 memory
    reg i_b;
    wire [4:0] o_led; // led[0]~led[4] t_test test[10];

    // named port mapping 방식
    gatetest u_gatetest( // u_gatetest라는 이름으로 인스턴스를 생성 한다.
    .a(i_a), .b(i_b), .led(o_led) 
        );

        // a b
        // 0 0
        // 0 1
        // 1 0
        // 1 1
        initial begin
            #00 i_a=1'b0; i_b=1'b0;
            #20 i_a=1'b0; i_b=1'b1;
            #20 i_a=1'b1; i_b=1'b0;
            #20 i_a=1'b1; i_b=1'b1;
            #20 $stop;
        end

endmodule
