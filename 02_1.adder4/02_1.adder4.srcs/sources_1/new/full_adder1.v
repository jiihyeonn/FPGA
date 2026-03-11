`timescale 1ns / 1ps

module full_adder1(
    input wire a, b, cin,
    output sum, cout
    );

    wire w_sum1, w_sum2, w_cout1, w_cout2;

    half_adder u1_half_adder(
        .a(a),
        .b(b),
        .sum(w_sum1),
        .cout(w_cout1)
    );

    half_adder u2_half_adder(
        .a(w_sum1),
        .b(cin),
        .sum(w_sum2),
        .cout(w_cout2)
    );
    assign sum = w_sum2;
    assign cout = w_cout1 | w_cout2;

endmodule