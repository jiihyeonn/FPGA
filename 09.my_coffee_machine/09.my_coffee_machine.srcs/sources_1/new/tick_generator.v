`timescale 1ns / 1ps

module tick_generator(
  input clk,      // 100MHz
  input reset,
  output reg tick // 1ms 주기로 1클럭 동안만 HIGH가 되는 신호
);
  parameter INPUT_FREQUENCY = 100_000_000; // 100MHz
  parameter TICK_Hz = 1000;                // 목표 주파수 1KHz (1ms)
  parameter TICK_COUNT = INPUT_FREQUENCY / TICK_Hz; // 100_000번 카운트 필요

  reg [$clog2(TICK_COUNT)-1:0] r_tick_counter = 0;

  always @(posedge clk or posedge reset) begin
      if(reset) begin
          tick <= 0;
          r_tick_counter <= 0;
      end
      else begin
          if(r_tick_counter == TICK_COUNT-1) begin
              r_tick_counter <= 0; // 카운터 초기화
              tick <= 1'b1;        // 1ms 도달 시 tick 발생
          end
          else begin
              r_tick_counter <= r_tick_counter + 1;
              tick <= 1'b0;        // 평소에는 0 유지
          end
      end
  end
endmodule

