`timescale 1ns / 1ps

module half_adder(a,b,sum,carry_out);
     input a,b;
     output sum, carry_out;

     assign sum = a ^ b;
     assign carry_out = a & b;

endmodule
