`timescale 1ns / 1ps

module adder8(
    input [7:0]a, 
    input [7:0]b,
    input cin,
    output [7:0]sum, 
    output cout
    );

    wire w_cout0, w_cout1, w_out2, w_out3, w_out4, w_out5, w_out6;

    full_adder1 FA0(
        .a(a[0]),
        .b(b[0]),
        .cin(1'b0),
        .sum(sum[0]),
        .cout(w_cout0)
    );

    full_adder1 FA1(
        .a(a[1]),
        .b(b[1]),
        .cin(w_cout0),
        .sum(sum[1]),
        .cout(w_cout1)
    );

    full_adder1 FA2(
        .a(a[2]),
        .b(b[2]),
        .cin(w_cout1),
        .sum(sum[2]),
        .cout(w_cout2)
    );

    full_adder1 FA3(
        .a(a[3]),
        .b(b[3]),
        .cin(w_cout2),
        .sum(sum[3]),
        .cout(w_cout3)
    );
    full_adder1 FA4(
        .a(a[4]),
        .b(b[4]),
        .cin(w_cout3),
        .sum(sum[4]),
        .cout(w_cout4)
    );
    full_adder1 FA5(
        .a(a[5]),
        .b(b[5]),
        .cin(w_cout4),
        .sum(sum[5]),
        .cout(w_cout5)
    );
    full_adder1 FA6(
        .a(a[6]),
        .b(b[6]),
        .cin(w_cout5),
        .sum(sum[6]),
        .cout(w_cout6)
    );
    full_adder1 FA7(
        .a(a[7]),
        .b(b[7]),
        .cin(w_cout6),
        .sum(sum[7]),
        .cout(cout)
    );

endmodule
