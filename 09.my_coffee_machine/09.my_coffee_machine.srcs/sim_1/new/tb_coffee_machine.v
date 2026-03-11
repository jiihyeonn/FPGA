`timescale 1ns / 1ps


module tb_coffee_machine();
    // input 
    reg clk;    // 100MHz
    reg reset;  // reset btn ( active high)
    reg [2:0] btn;
    // reg coin;   // 동전 투입 ( 100원 단위)
    // reg return_coin_btn;  // 동전 반환 버튼
    // reg coffee_btn;
    // reg coffee_out;   // 커피 배출 완료 센서 신호

    // ouput
    wire [7:0] seg;
    wire [3:0] an; 
    // wire[15:0]  coin_val;   // 현재 금약 표시
    // wire seg_en;   // FND 활성화 신호
    // wire coffee_make;  // 커피 제조 시작 신호
    // wire coin_return;   // 동전 반환 동작 신호 

    // 모듈 인스턴스화
    // coffee_machine u_coffee_machine(
    //     .clk(clk),    // 100MHz
    //     .reset(reset),  // reset btn ( active high)
    //     .coin(coin),   // 동전 투입 ( 100원 단위)
    //     .return_coin_btn(return_coin_btn),  // 동전 반환 버튼
    //     .coffee_btn(coffee_btn),
    //     .coffee_out(coffee_out),   // 커피 배출 완료 센서 신호
    //     .coin_val(coin_val),   // 현재 금약 표시
    //     .seg_en(seg_en),   // FND 활성화 신호
    //     .coffee_make(coffee_make),  // 커피 제조 시작 신호
    //     .coin_return(coin_return)   // 동전 반환 동작 신호 
    // );

    top u_top(
        .clk(clk),          // 100MHz 기본 클럭
        .reset(reset),        // sw[15] 
        .btn(btn),    // btn[0]: coin 투입, btn[1]: 동전 반환 버튼, btn[2]: 커피선택 버튼
        .seg(seg),   // FND
        .an(an)     // FND 자릿수 선택 (Active Low)
    );

    // 동전 투입 task : clk 에 동기화 시키자
    task insert_coin;
        begin
            @(posedge clk);
            #1 btn[0]=1;   // setup time 확보 
            repeat(3) @(posedge clk);  // 3 clk 동안 유지 
            #1 btn[0]=0;
            repeat(10) @(posedge clk); // 대기 시간 
        end 
    endtask 
    // 100MHz clock 생성 
    initial clk =0;
    always #5 clk = ~clk;

    initial begin
        // 1. 초기 신호 unkwon(x) 방지 
        clk=0;
        reset=1;
        btn = 0;
        // coin=0;
        // return_coin_btn=0;
        // coffee_btn=0;
        // coffee_out=0;
        //---2. 정상적인 reset seq 
        #100;   // 100ns 동안 reset 유지
        @(negedge clk)   // 클럭이 하강 에지 일때 리셋 해제 (글리치 방치)
        reset=0;
        $display("time : %t reset release... IDLE state: ", $time);
        #50;

        // 3. scenario : 300원 투입 (IDLE -> COIN_IN --> READY) 
        $display("time : %t coin insert ...", $time);
        insert_coin();  // 100원
        insert_coin();
        insert_coin(); 

        // READY 확인
        #20;
        if (coin_val >= 300)
            $display("time : %t current READY coin_val: %d...", $time, coin_val); 
        else   
             $display("time : %t error coin_val: %d...", $time, coin_val);   
        // 4. coffee_btn 누른다. READY --> COFFEE --> READY
        @(posedge clk);
        #1 btn[2]=1;   
        @(posedge clk);   
        #1 btn[2]=0;
        $display("time : %t coffee_btn pressed...", $time); 
        // 커피를 만드는 작업 이 완료 될떄 까지 대기
        wait(coffee_make==1);  
        $display("time : %t coffee maked ...", $time);
        #200;  // 제조 시연 시간 
        
        //-- 커피를 제조 완료 신호를 입력 
        @(posedge clk);
        #1 coffee_out=1;   
        @(posedge clk);   
        #1 coffee_out=0;   
        $display("time : %t coffee_out sensor detected goto READY  ...", $time);   
        #50;

        //-- 5. 동전 반환 (REAY --> COIN_OUT --> IDLE)
        $display("time : %t coin return coin_val: %d  ...", $time, coin_val);  
        @(posedge clk);
        #1 return_coin_btn=1;   
        @(posedge clk);   
        #1 return_coin_btn=0; 

        wait(return_coin_btn == 1);
        $display("time : %treturn_coin_btn == 1  ...", $time); 
        #100;
        if (coin_val == 0)  
            $display("time : %t return coin_val:%d goto IDLE  ...", $time, coin_val); 

        #300;
         $display("Simuation Succss Finished.....", $time);  
         $finish;                     
    end 
endmodule
