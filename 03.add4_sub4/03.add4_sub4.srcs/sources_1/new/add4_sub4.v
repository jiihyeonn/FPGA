`timescale 1ns / 1ps

// 4bit + 4bit => carry, 4bit의 sum
module add6_sub6(
    input [11:0] sw,
    input sel, // 1: add, 0: sub
    output carry_out,
    output [5:0] sum
    );

   // assign {carry_out, sum[3:0]} = sw[3:0] + sw[7:4]; // 결합 연산자
   assign {carry_out, sum[5:0]} = sel ? sw[5:0] + sw[11:6] : 
                                  sw[5:0] + ~sw[11:6] + 6'b1;
endmodule
