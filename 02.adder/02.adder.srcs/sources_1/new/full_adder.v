`timescale 1ns / 1ps

module full_adder(
    input wire a, b, cin,
    output sum, carry_out
    );

    wire w_sum1, w_sum2, w_carry_out1, w_carry_out2;

    half_adder u1_half_adder(
        .a(a),
        .b(b),
        .sum(w_sum1),
        .carry_out(w_carry_out1)
    );

    half_adder u2_half_adder(
        .a(w_sum1),
        .b(cin),
        .sum(w_sum2),
        .carry_out(w_carry_out2)
    );
    assign sum = w_sum2;
    assign carry_out = w_carry_out1 | w_carry_out2;

endmodule
