`timescale 1ns / 1ps

module tb_add6_sub6();
    reg [11:0] r_sw; 
    reg r_sel;      
    wire w_carry_out;   
    wire [5:0] w_sum;   
    
    reg [5:0] r_a;
    reg [5:0] r_b;

    always @(*) begin
        r_sw = {r_b, r_a};
    end

    add6_sub6 u_dut (
        .sw(r_sw),
        .sel(r_sel),
        .carry_out(w_carry_out),
        .sum(w_sum)
    );

    initial begin
       r_a = 0; r_b = 0; r_sel = 1;
       #10; r_a = 10; r_b = 20;
       #10; r_a = 40; r_b = 30;
       #10; r_sel = 0;
       #10; r_a = 25; r_b = 10;
       #10; r_a = 15; r_b = 15;        
       #10; r_a = 10; r_b = 20;
       #10; $finish;
    end

endmodule