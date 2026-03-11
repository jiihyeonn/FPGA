`timescale 1ns / 1ps

module gatetest(
    input wire a, // 변수이름 앞에 wire 생략하면 default로 wire임 (선이라는거)
    input b,      // 아무 언급 안하면 1 bit로 인식
    output [4:0] led // led[0]~led[4]
    ); // 조합회로(메모리 없는 단순 논리회로)

    assign led[0] = a & b; // assign: 연속 할당문, AND
    assign led[1] = a | b; // OR
    assign led[2] = ~(a & b); // NAND
    assign led[3] = ~(a | b); // NOR
    assign led[4] = a ^ b; // XOR

endmodule
