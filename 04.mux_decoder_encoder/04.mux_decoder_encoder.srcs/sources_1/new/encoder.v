`timescale 1ns / 1ps

module encoder(
    input [3:0] d,
    output [1:0] a
    );

    reg [1:0] r_a;

    always @(*) begin // ,아니면 or 써도됨
        if (d[3] == 1'b1)  r_a = 2'b11;
        else if (d[2] == 1'b1)  r_a = 2'b10;
        else if (d[1] == 1'b1)  r_a = 2'b01;
        else r_a = 2'b00;
    end
    assign a = r_a;

endmodule
