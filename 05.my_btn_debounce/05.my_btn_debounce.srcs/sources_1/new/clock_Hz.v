`timescale 1ns / 1ps

module clock_80Hz(
    input i_clk, //100MHz
    input i_reset, // reset switch
    output reg o_clk // 80Hz 출력
    );
    // reg [23:0] r_counter=0; // 1,250,000sec : 10ns x 1,250,000 = 12.5ms
    //                                        0.00000001 x 1000000 = 10 ms
    reg[$clog2(1,000,000)-1:0] r_counter=0; 

    always @(posedge i_clk, posedge i_reset) begin 
        if (i_reset) begin // 비동기 reset 0 --> 1
          r_counter <= 0;
          o_clk <= 0;
        end
        else begin
            if(r_counter == (1_000_000/2)-1) begin // 80Hz 1주기 10ms : 
                r_counter <= 0;
                o_clk <= ~o_clk; 
            end
            else begin
                r_counter <= r_counter + 1;
            end
        end
    end
endmodule
