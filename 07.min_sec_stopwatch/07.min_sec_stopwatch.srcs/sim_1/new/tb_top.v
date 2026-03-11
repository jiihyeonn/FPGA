`timescale 1ns / 1ps

module tb_top();
    reg clk;
    reg [2:0] btn;
    wire [7:0] seg;
    wire [3:0] an;

    top u_top(
        .clk(clk),
        .btn(btn),
        .seg(seg),
        .an(an)
    );

    // 3. 100MHz 클럭 생성 (10ns 주기)
    always #5 clk = ~clk;

    // 4. 버튼 누름 Task (Debounce가 10ms이므로 15ms 동안 눌러줌)
    task btn_press;
         input integer btn_index; // integer signed 32bit reg[31:0] 비트처럼 일일히 저장 안해도 
         begin
            $display("btn_press: %0d start", btn_index);

            // 1. make noise (0.55ms)
            btn[btn_index] = 1; #100000; // 0.1 ms High
            btn[btn_index] = 0; #200000; // 0.2 ms Low
            btn[btn_index] = 1; #150000; // 0.15 ms High
            btn[btn_index] = 0; #100000; // 0.1 ms Low
            // 2. 안정 구간 11ms 유지 --> 이 구간이 지나야 clean_btn이 1이 된다.
            btn[btn_index] = 1;
            #11000000; // 11ms 유지 --> 이 구간이 지나야 clean_btn이 1이 된다.
            // 3. btn을 뗀다(10ms 이상)
            btn[btn_index] = 0;
            #11000000;
            $display("btn_press btn:%0d FINISH", btn_index);
         end
    endtask

    // 5. 시뮬레이션 시나리오
    initial begin
        clk = 0;
        btn = 3'b000;
        
        $display("========================================");
        $display("        SIMULATION START");
        $display("========================================");
        
        // 시스템 안정화 및 FND 초기 출력 관찰
        #5000000; // 5ms 대기 

        $display("\n--- 1. Change Mode: CLOCK -> STOPWATCH ---");
        btn_press(0); // btn[0] 누름

        $display("\n--- 2. Stopwatch: START ---");
        btn_press(2); // btn[2] 누름
        
        #50000000; // 50ms 대기 (스탑워치 ms가 올라가는지 확인)

        $display("\n--- 3. Stopwatch: PAUSE ---");
        btn_press(2); // btn[2] 누름 (정지)
        
        #20000000; // 20ms 대기 (멈춰있는지 확인)

        $display("\n--- 4. Change Mode: STOPWATCH -> CLOCK ---");
        btn_press(0); // btn[0] 누름

        #10000000; // 10ms 대기

        $display("\n========================================");
        $display("        SIMULATION FINISHED");
        $display("========================================");
        $finish;
    end

endmodule