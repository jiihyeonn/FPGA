`timescale 1ns / 1ps

module tb_fsm_pattern();
    // input
    reg clk;
    reg reset;
    reg in;
    // output
    wire out;

    // test할 모듈 instance화
    fsm_pattern u_fsm_pattern(
    .clk(clk),
    .reset(reset),
    .in(in),
    .out(out)
    );

    // 2. clk 생성(100MHz : 1주기 10ns (High : 5ns, Low : 5ns))
    always #5 clk = ~clk;

    // // 값이 변하면 값을 출력
    initial begin
        $monitor("time=%t state=%b, in=%b, out=%b", $time, u_fsm_pattern.current_state, in, out);
    end

    // 3. test scenario 작성
    initial begin
        clk=0;
        reset=1;
        in=0;
        // reset 해제
        #100 reset=0;
        //  #1_test pattern 1010111 10ns(1주기 마다 1bit씩 날림)
        @(posedge clk); in=1;
        @(posedge clk); in=0;
        @(posedge clk); in=1;
        @(posedge clk); in=0;
        @(posedge clk); in=1;
        @(posedge clk); in=1;
        // S6->S1 : 여기서 out=1
        @(posedge clk); in=1;

        // #2 011 입력시 S1으로 오는지
        @(posedge clk); in=0; // S1->S2(10)
        @(posedge clk); in=1; // S2->S4 (101)
        @(posedge clk); in=1; // S3->S4 (1이 들어오면 S1으로 감)

        // #3 010111 out=1이 되며 S1으로 오는지
        @(posedge clk); in=0; // S1->S2 (10)
        @(posedge clk); in=1; // S2->S3 (101)
        @(posedge clk); in=0; // S3->S4 (1010) 
        @(posedge clk); in=1; // S4->S5 (10101)
        @(posedge clk); in=1; // S5->S6 (101011)
        @(posedge clk); in=1; // S6->S1 (1010111 검출)
        #100;
        $display("==== simulation finished ====");
        $finish;
    end

endmodule
