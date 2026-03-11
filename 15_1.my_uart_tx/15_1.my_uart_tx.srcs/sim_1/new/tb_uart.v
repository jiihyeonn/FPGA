`timescale 1ns / 1ps

module tb_uart();
    reg clk;
    reg reset;
    reg btn;
    reg [7:0] sw;
    reg RsRx; 

    wire RsTx; 
    wire [7:0] seg;
    wire [3:0] an;
    wire [15:0] led;
    wire uartTx;
    wire uartRx;

    top #(.BPS(10_000_000), .DEBOUNCE_LIMIT(20'd999_999))u_top(
        .clk(clk),
        .reset(reset),
        .btn(btn),
        .sw(sw),
        .RsRx(RsRx),
        .RsTx(RsTx),
        .seg(seg),
        .an(an),
        .led(led),
        .uartTx(uartTx), 
        .uartRx(uartRx) 
    );

    task btn_press;
         input integer btn;
         begin
            // 1. make noise (0.55ms)
            btn = 1; #100; // 0.1 ms High
            btn = 0; #200; // 0.2 ms Low
            btn = 1; #150; // 0.15 ms High
            btn = 0; #100; // 0.1 ms Low
            // 2. 안정 구간 11ms 유지 --> 이 구간이 지나야 clean_btn이 1이 된다.
            btn = 1;
            #1100; // 11ms 유지 --> 이 구간이 지나야 clean_btn이 1이 된다.
            // 3. btn을 뗀다(10ms 이상)
            #1100;
         end
    endtask
   
   always #5 clk = ~clk; 

   initial begin
        clk = 0;
        reset = 1;
        btn = 3'b000;
        sw = 8'h00;

      #100;
        reset = 0;
      #100;
      
      $display(" btn[0] start");
       sw = 8'h50;
       btn_press(0);
      //  #20 btn = 1;  
      //  #50 btn = 0;  
       #5000;         

       sw = 8'h4A;
       btn_press(0);
      //  #20 btn = 1;
      //  #50 btn = 0;
       #5000;

      $display(" btn[0] finished");
       sw = 8'h48;
       btn_press(0);
      //  #20 btn = 1;
      //  #50 btn = 0;
       #5000;

       $finish; 
end
endmodule

