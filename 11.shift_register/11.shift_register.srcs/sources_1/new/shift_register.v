`timescale 1ns / 1ps
// 1010111
module shift_register(
    input clk,
    input reset,
    input in, // 1bit씩 들어옴
    output out
    );

    reg [6:0] sr7;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            // out <= 1'b0; => wire 여서 초기화 할 필요 x
            sr7 <= 7'b0000000;
        end
        else 
            sr7 <= {sr7[5:0], in}; // shift register
    end

    assign out = (sr7 == 7'b1010111) ? 1 : 0;

endmodule