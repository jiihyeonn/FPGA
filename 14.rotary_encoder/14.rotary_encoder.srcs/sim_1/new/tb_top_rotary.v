`timescale 1ns / 1ps

// sim 속도를 높이기 위해서 DEBOUNCE LIMIT -> 2us로 수정
module tb_top_rotary();
    reg clk;
    reg reset; // sw15
    reg s1;
    reg s2;
    reg key;
    wire [15:0] led;

    top_rotary u_top_rotary(
        .clk(clk),
        .reset(reset),
        .s1(s1),
        .s2(s2),
        .key(key),
        .led(led)
    );

    // 100MHz clock 생성
    always #5 clk = ~clk;

    // 일괄적으로 50ns x 3 noise 만듬
    task make_btn_noise(input integer sw); // 0 : s1, 1 : s2
        begin
            repeat(3) begin
                if(sw == 0) s1 = ~s1; // s1
                else if(sw == 1) s2 = ~s2;
                else key = ~key;
                #50; // 채터링 간격은 50ns
            end
        end
    endtask

    initial begin
        // 초기화
        clk = 0; reset = 0; s1 = 0; s2 = 0; key = 0;
        #100;
        reset=0;
        #100;
        // CW 00 -> 10 --> 11 --> 01 --> 00
        $display("Forward TEST start.....");

        make_btn_noise(0); s1 = 1; #3000; // 200ns 즉 200cycle(10us x 200 = 2000ns) 
                                            // : noise 보다 긴 3000ns 대기
        make_btn_noise(1); s2 = 1; #3000; // 200ns 즉 200cycle(10us x 200 = 2000ns) 
                                            // : noise 보다 긴 3000ns 대기
        s1 = 0; #3000; 
        s2 = 0; #3000;

        // CCW : 00 --> 01 --> 11 --> 10 --> 00
        $display("Backward TEST start.....");

        s2 = 1; #3000;
        make_btn_noise(0); s1 = 1; #3000;
        s2 = 0; #3000;
        s1 = 0; #3000;

        // KEY btn toggle test
        $display("KEY BTN TEST start.....");

        make_btn_noise(2); key = 1; #3000; // rising edge detect
        key = 0; #3000;

        $display("Simulation Finished.....");
        $finish;
    end
    
    // 모니터링 출력
    initial begin
        $monitor("time = %t, r_counter : %h, direction : %d, r_led_toggle : %b"
                 , $time, led[7:0], led[15:14], led[13]);
    end

endmodule
