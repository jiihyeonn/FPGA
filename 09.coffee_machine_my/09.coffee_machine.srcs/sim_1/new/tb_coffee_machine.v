`timescale 1ns / 1ps

module tb_coffee_machine();

    reg clk, reset, coin;
    reg coffee_btn;
    reg coin_return_btn;
    reg coffee_out;

    wire [15:0] coin_val;
    wire seg_en;
    wire coffee_make;
    wire coin_return;

    coffee_machine u_coffee_machine(
        .clk            (clk),
        .reset          (reset),
        .coin           (coin),
        .coffee_btn     (coffee_btn),
        .coin_return_btn(coin_return_btn),
        .coffee_out     (coffee_out),
        .coin_val       (coin_val),
        .seg_en         (seg_en),
        .coffee_make    (coffee_make),
        .coin_return    (coin_return)
    );

    // 동전 투입 task : clk에 동기화
    task insert_coin;
        begin
            @(posedge clk);
            #1 coin = 1;    // setup time 확보
            repeat(3) @(posedge clk);    // 3 clk 동안 유지
            #1 coin = 0;
            repeat(10) @(posedge clk);    // 대기 시간 확보
        end
    endtask

    // 100MHz clock 생성
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        // 초기 신호 unknown 방지
        clk = 0;
        reset = 1;
        coin = 0;
        coin_return_btn = 0;
        coffee_btn = 0;
        coffee_out = 0;

        //--- 정상적인 reset seq
        #100;   // 100ns 동안 reset 유지
        @(negedge clk)  // 클락이 하강에지 일때 리셋 해제 (글리치 방지)
        reset = 0;
        $display("time : %t reset release... IDLE state: ", $time);
        #50;

        // scenario : 300원 투입 (IDLE -> COIN_IN -> READY)
        $display("time : %t coin insert... ", $time);
        repeat(3) insert_coin();

        #20;
        if(coin_val >= 300)
            $display("time : %t current READY... coin_val: %d", $time, coin_val);
        else
            $display("time : %t error... coin_val: %d", $time, coin_val);
        
        // coffee_btn 누름 (READY -> COFFEE -> READY)
        @(posedge clk);
        #1 coffee_btn = 1;
        @(posedge clk);
        #1 coffee_btn = 0;
        $display("time : %t coffee_btn pressed...", $time);

        // 커피 만드는 작업 완료될 때까지 대기
        wait(coffee_make == 1);
        $display("time : %t coffee maked...", $time);
        #200; // 제조 지연 시간 

        // -- 커피 제조 완료 신호 입력
        @(posedge clk);
        #1 coffee_out = 1;
        @(posedge clk);
        #1 coffee_out = 0;
        $display("time : %t coffee _out sensor detected goto READY...", $time);
        #50;

        // -- 동전 반환 (READY --> COIN_OUT --> IDLE)
        $display("time : %t coin return coin_val : %d ...", $time, coin_val);
        @(posedge clk);
        #1 coin_return_btn = 1;
        @(posedge clk);
        #1 coin_return_btn = 0;

        wait(coin_return_btn == 1);
        $display("time : %t coin_return_btn == 1...", $time);
        #100;
        if (coin_val == 0)
            $display("time : %t return coin_val : %d goto IDLE...", $time, coin_val);

        #300;
        $display("Simulation Success Finished.....", $time);
        $finish;

    end

endmodule
