`timescale 1ns / 1ps

module data_sender(
    input clk,
    input reset,
    input btnL,
    input start_trigger,
   // input [7:0] send_data, // 1 byte
    input tx_busy,
    input tx_done,
    output reg [7:0] tx_data,
    output reg tx_start
    );

    reg [1:0] state;

    always @(posedge clk, posedge reset) begin
        if (reset) begin
            tx_start <= 0;
            tx_data  <= 8'h50;
            state <= 0;
        end
        else begin
            tx_start <= 0;

            if (start_trigger && !tx_busy) begin
                tx_start <= 1;

                case(state)
                    2'd0: begin
                      tx_data <= 8'h50; // P
                      state   <= 2'd1;
                    end
                    2'd1: begin
                      tx_data <= 8'h4A; // J
                      state   <= 2'd2;
                    end
                    2'd2: begin
                      tx_data <= 8'h48; // H
                      state   <= 2'd0;
                end
                default: state <= 2'd0;
                endcase
            end
        end
    end



endmodule
