`timescale 1ns / 1ps

module tb_fsm_pattern();
    reg clk;
    reg reset;
    reg din_bit;
    wire detect_out;

    // test할 모듈 instance화
    fsm_pattern u_fsm_pattern(
    .clk(clk),
    .reset(reset),
    .din_bit(din_bit),
    .detect_out(detect_out)
    );

    // 2. clk 생성(100MHz : 1주기 10ns (High : 5ns, Low : 5ns))
    always #5 clk = ~clk;

    // // 값이 변하면 값을 출력
    initial begin
        $monitor("time=%t state=%b, in=%b, out=%b", $time, u_fsm_pattern.current_state, din_bit, detect_out);
    end

    // 3. test scenario 작성
    initial begin
        clk=0;
        reset=1;
        din_bit=0;
        // reset 해제
        #100 reset=0;
        //  #1_test pattern 1010111 10ns(1주기 마다 1bit씩 날림)
        @(posedge clk); din_bit=0;
        @(posedge clk); din_bit=1;
        @(posedge clk); din_bit=1;
        // st3->st4 : 여기서 out=1
        @(posedge clk); din_bit=0;

        // #2 1110 입력시 start으로 오는지
        @(posedge clk); din_bit=1; // st1->st2 (01)
        @(posedge clk); din_bit=1; // st2->st3 (011)
        @(posedge clk); din_bit=1; // st3->start(0111)
        @(posedge clk); din_bit=0; // start->st1(01110)

        // #3 0110 out=1이 되며 st4으로 오는지
        @(posedge clk); din_bit=1; // st1->st2 (01)
        @(posedge clk); din_bit=1; // st2->st3 (011)
        @(posedge clk); din_bit=0; // st3-> st4 (0110) 
        #100;
        $display("==== simulation finished ====");
        $finish;
    end

endmodule
