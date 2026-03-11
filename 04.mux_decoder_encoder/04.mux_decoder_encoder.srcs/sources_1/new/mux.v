//`timescale 1ns / 1ps

// module mux2_1(
//     input a, // 첫번째 입력
//     input b,
//     input sel,
//     output out // 출력
//     );

//     assign out = (sel == 1) ? a : b;

// endmodule

// `timescale 1ns / 1ps

// module mux2_1(
//     input a, 
//     input b,
//     input sel,
//     output out 
//     );

//     reg r_out;

//     // always @(sel or a, b) begin // ,아니면 or 써도됨
//     //     if (sel) r_out = a;
//     //     else r_out = b;
//     // end

//     always @(*) begin // ,아니면 or 써도됨
//         case (sel)
//             1'b1: r_out = a;
//             1'b0: r_out = b;
//         endcase
//     end
//     assign out = r_out;

// endmodule

`timescale 1ns / 1ps

module mux2_1(
    input [3:0] a, 
    input [3:0] b,
    input  sel,
    output [3:0] out 
    );

    reg [3:0] r_out;

    always @(*) begin // ,아니면 or 써도됨
        case (sel)
            1'b1: r_out = a;
            1'b0: r_out = b;
        endcase
    end
    assign out = r_out;

endmodule