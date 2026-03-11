`timescale 1ns / 1ps

module tb_adder8();
    reg [7:0]r_a;
    reg [7:0]r_b;
    reg r_cin;
    wire [7:0]w_sum;
    wire w_cout;
        
    adder8 u_adder8(
    .a(r_a), .b(r_b), .cin(r_cin) , .sum(w_sum), .cout(w_cout)
    );

    initial begin
        #00 r_a=8'b00000000; r_b=8'b00000000; r_cin=0;
        #10 r_a=8'b00000001; r_b=8'b00000001;
        #10 r_a=8'b00000010; r_b=8'b00000010;
        #10 r_a=8'b00000011; r_b=8'b00000011;
        #10 r_a=8'b00000100; r_b=8'b00000100;
        #10 r_a=8'b00000101; r_b=8'b00000101;
        #10 r_a=8'b00000110; r_b=8'b00000110;
        #10 r_a=8'b00000111; r_b=8'b00000111;
        #10 r_a=8'b00001000; r_b=8'b00001000;
        #10 $finish;
    end

endmodule
