# 스마트 공조기 프로젝트

1.구현: 스마트 공조기

2.사용부품: (1) basys3
(2) DHT11(온.습도센서) : Maker 자체 protocol
(3) DS1302(RTC) : Maker 자체 protocol
(4) DC-motor, DC-motor드라이버

(5) 로터리 엔코더+

(6) 서보모터,

(7) piezo-buzzer

- -------------------<2단계>--------------------------

(8) 초음파 센서

1. 공조기 기본 Requirement

1초 start trigger 신호를 받으면(1초에 1회씩) 아래의 정보를 comport master로 출력이 되도록 구현한다.

(1) DHT11(온.습도센서) 기능
DHT11(온.습도센서)의 Spec을 velilog로 구현 하여 온도.습도 값 FND와 UART출력

(2) DS1302(RTC) 기능

- 시각 Display : FND, UART
- 시각 보정 기능 :  setrtcyymmddhhmmss

예) 2026년 03월 06일 09시13분30초 로 보정시 🡪 setrtc260306091330 를 comport에서 입력
(2) 알람. 경보 기능 :

- 알람 기능: 스마트폰의 알람 시계와 같이 일정 시각 이 되면 부저음 울림, 해제 기능
- 경보 기능: 장애 및 이상 상황 발생시 경보음 발생 및 해제 기능
(3) FAN.부저 자동제어
- 온도에 따라 FAN의 세기가 자동으로 제어 (pwm제어) 달리 동작.
- 온도 조절 (SW 조절+BTN 조작)
1. 기 구현된 기능 통합

(1) 분.초 시계 (2) 전자레인지

ds1302 모드일때 
스위치 0번 on 시: 알람 모드 설정 시간:분 설정 00:00 ~ 24:00 
로터리 인코더는 정방향 s1, 역방향 s2, key

알람 모드들어가자마자 s1, s2로 시간을 바꿀 수 있고 key 한번 누르면 분바뀌는 걸로 가고 
key를 한번더 누르면 알람 설정 → 알람 설정했을때 led0번 켜짐

그리고 다시 스위치 0번 off 시키면 ds1302 일반 시계모드로 돌아오고 알람이 울리기 전까지 led0번 유지하고 알람이 울려 부저가 울리게 되면 led꺼짐 

여기에 부저음 해제는 스위치 0번 on으로 알람 모드로 들어가서 로터리인코더의 key를 한번 더 눌러주면 꺼짐

[4조_AHU_박준모_박지현.pdf](4%EC%A1%B0_AHU_%EB%B0%95%EC%A4%80%EB%AA%A8_%EB%B0%95%EC%A7%80%ED%98%84.pdf)

[https://www.notion.so](https://www.notion.so)

```verilog
`timescale 1ns / 1ps

module top(
    input clk,
    input reset, // sw15
    inout dht11_data,

    output ds1302_ce,
    output ds1302_sclk, 
    inout ds1302_data, 
    
    input s1,
    input s2,
    input key,

    input sw,
    input btnL,
    input RsRx,
    output RsTx,
    output led,
    output buzzer,
    output [7:0] seg,
    output [3:0] an
);

    wire [7:0] w_hum_int, w_hum_dec, w_tem_int, w_tem_dec;
    wire [7:0] w_rtc_sec, w_rtc_min, w_rtc_hour, w_rtc_date, w_rtc_month, w_rtc_year;
    wire [7:0] w_alarm_hour, w_alarm_min;

    wire w_cw_tick, w_ccw_tick, w_key_tick;

    wire w_tick_1Hz, w_ds1302_busy;
    wire w_ds1302_write_req, w_set_time_done;
    wire [13:0] w_fnd_in_data;
    wire [47:0] w_time_data;

    wire w_clean_btnL, w_clean_s1, w_clean_s2, w_clean_key;

    btn_debounce u_btn_debounce(
        .clk            (clk),
        .reset          (reset),
        .btn            ({btnL, s1, s2, key}),
        .debounced_btn  ({w_clean_btnL, w_clean_s1, w_clean_s2, w_clean_key})
    );

    tick_gen #(
        .INPUT_FREQ (100_000_000),
        .TICK_Hz    (1)
    ) u_tick_gen(
        .clk    (clk),
        .reset  (reset),
        .tick   (w_tick_1Hz)
    );

    control_tower u_control_tower(
        .clk                    (clk),
        .reset                  (reset),
        .btnL                   (w_clean_btnL),

        .hum_int                (w_hum_int),
        .hum_dec                (w_hum_dec),
        .tem_int                (w_tem_int),
        .tem_dec                (w_tem_dec),
        .rtc_sec                (w_rtc_sec),
        .rtc_min                (w_rtc_min),
        .rtc_hour               (w_rtc_hour),
        .rtc_date               (w_rtc_date),
        .rtc_month              (w_rtc_month),
        .rtc_year               (w_rtc_year),

        .sw0                    (sw),
        .alarm_hour             (w_alarm_hour), 
        .alarm_min              (w_alarm_min), 
        .fnd_data               (w_fnd_in_data)
    );

    dht_controller u_dht_controller(
        .clk            (clk),
        .reset          (reset),
        .start_trigger  (w_tick_1Hz),
        .dht11_data     (dht11_data),

        .hum_int        (w_hum_int),
        .hum_dec        (w_hum_dec),
        .tem_int        (w_tem_int),
        .tem_dec        (w_tem_dec)
    );

    ds1302_controller u_ds1302(
        .clk            (clk),
        .reset          (reset),
        .start_trigger  (w_tick_1Hz),
        .write_request  (w_ds1302_write_req),
        .set_time_done  (w_set_time_done),
        .busy           (w_ds1302_busy),

        .i_sec          (w_time_data[7:0]),
        .i_min          (w_time_data[15:8]),
        .i_hour         (w_time_data[23:16]),
        .i_date         (w_time_data[31:24]),
        .i_month        (w_time_data[39:32]),
        .i_year         (w_time_data[47:40]),

        .ce             (ds1302_ce),
        .sclk           (ds1302_sclk),
        .ds1302_data    (ds1302_data),

        .o_sec          (w_rtc_sec),
        .o_min          (w_rtc_min),
        .o_hour         (w_rtc_hour),
        .o_date         (w_rtc_date),
        .o_month        (w_rtc_month),
        .o_year         (w_rtc_year)
    );

    uart_controller u_uart_controller(
        .clk                (clk),
        .reset              (reset),
        .start_trigger      (w_tick_1Hz),
        .set_time_done      (w_set_time_done),
        .ds1302_busy        (w_ds1302_busy),

        .hum_int            (w_hum_int),
        .hum_dec            (w_hum_dec),
        .tem_int            (w_tem_int),
        .tem_dec            (w_tem_dec),

        .rtc_sec            (w_rtc_sec),
        .rtc_min            (w_rtc_min),
        .rtc_hour           (w_rtc_hour),
        .rtc_date           (w_rtc_date),
        .rtc_month          (w_rtc_month),
        .rtc_year           (w_rtc_year),

        .time_data          (w_time_data),
        .set_time_trigger   (w_ds1302_write_req),
        .rx                 (RsRx),
        .tx                 (RsTx)
    );

    fnd_controller u_fnd_controller(
        .clk        (clk),
        .reset      (reset), 
        .in_data    (w_fnd_in_data),
        .seg        (seg),
        .an         (an)
    );

    rotary u_rotary(
        .clk        (clk),
        .reset      (reset),
        .clean_s1   (w_clean_s1),
        .clean_s2   (w_clean_s2), 
        .clean_key  (w_clean_key),
        .cw_tick    (w_cw_tick),
        .ccw_tick   (w_ccw_tick),
        .key_tick   (w_key_tick)
    );

    alarm_controller u_alarm_controller(
        .clk            (clk),
        .reset          (reset),
        .sw0            (sw),
        .cw_tick        (w_cw_tick),
        .ccw_tick       (w_ccw_tick),
        .key_tick       (w_key_tick),

        .current_hour   (w_rtc_hour),
        .current_min    (w_rtc_min),
        .current_sec    (w_rtc_sec),
        .alarm_hour     (w_alarm_hour),
        .alarm_min      (w_alarm_min),

        .led0           (led),  
        .buzzer         (buzzer)
    );

endmodule
```

```verilog
`timescale 1ns / 1ps

module btn_debounce(
    input clk,
    input reset,
    input [3:0] btn,   // 각각 btnL, s1, s2, key 노이즈 있는 값
    output [3:0] debounced_btn // 노이즈 제거된 값
);
    debouncer U_debouncer_btnL (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[0]),
        .clean_btn(debounced_btn[0])
    );

    debouncer U_debouncer_s1 (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[1]),
        .clean_btn(debounced_btn[1])
    );

    debouncer U_debouncer_s2 (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[2]),
        .clean_btn(debounced_btn[2])
    );

    debouncer U_debouncer_key (
        .clk(clk),
        .reset(reset),
        .noisy_btn(btn[3]),
        .clean_btn(debounced_btn[3])
    );

endmodule

`timescale 1ns / 1ps

module debouncer #(parameter DEBOUNCE_LIMIT = 20'd999_999) (
    input      clk,
    input      reset,
    input      noisy_btn,  // raw noisy button input
    output reg clean_btn
);
    reg [19:0] count; // 1,000,000 표현 위해 20비트 count 레지스터
    reg btn_state=0; // 버튼 상태 레지스터(동기화?)

    always @(posedge clk or posedge reset) begin // clk 또는 reset이 상승엣지일때 
        if (reset) begin   // active-high reset
            count <= 0;
            btn_state <= 0;
            clean_btn <= 0;
        end 
        else if (noisy_btn == btn_state) begin  // 버튼 상태가 이전과 동일할 경우 (안정됨)
            count <= 0; 
        end 
        else begin
            if (count < DEBOUNCE_LIMIT)  // 버튼 상태가 바뀌었지만 아직 안정되지 않은 경우
                count <= count + 1;
            else begin  // 상태가 충분히 오랫동안 유지됨(10ms)
                btn_state <= noisy_btn;
                clean_btn <= noisy_btn;
                count <= 0;  // 리셋하면 다음 변경을 다시 감지할 수 있음
            end
        end
    end
endmodule
```

```verilog
`timescale 1ns / 1ps

module tick_gen #(
    parameter INPUT_FREQ = 100_000_000,
    parameter TICK_Hz = 1000
) (
    input clk,
    input reset,
    output reg tick
);
    parameter TICK_COUNT = INPUT_FREQ / TICK_Hz;

    reg [$clog2(TICK_COUNT)-1:0] r_tick_counter = 0;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tick <= 0;
            r_tick_counter <= 0;
        end else begin
            if(r_tick_counter == TICK_COUNT - 1) begin
                r_tick_counter <= 0;
                tick <= 1'b1;
            end else begin
                r_tick_counter <= r_tick_counter + 1;
                tick <= 1'b0;
            end
        end
    end

endmodule
```

```verilog
`timescale 1ns / 1ps

module control_tower(
    input clk,
    input reset,
    input btnL,

    input [7:0] hum_int,
    input [7:0] hum_dec,
    input [7:0] tem_int,
    input [7:0] tem_dec,

    input [7:0] rtc_sec,
    input [7:0] rtc_min,
    input [7:0] rtc_hour,
    input [7:0] rtc_date,
    input [7:0] rtc_month,
    input [7:0] rtc_year,

    input sw0,
    input [7:0] alarm_hour, 
    input [7:0] alarm_min, 

    output reg [13:0] fnd_data
);

    reg r_display_mode; // 0: 온습도 화면, 1: 시간 화면
    reg r_prev;

    // 모드 전환
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_display_mode <= 1'b0;
            r_prev <= 1'b0;
        end else begin
            if (btnL == 1'b1 && r_prev == 1'b0) begin
                r_display_mode <= ~r_display_mode;
            end
            r_prev <= btnL;
        end
    end

    always @(*) begin
        if (r_display_mode == 1'b0) begin
            //  온습도 모드
            fnd_data = (tem_int * 100) + hum_int;
        end else begin
            // 시계 모드
            if (sw0 == 1'b1) begin
                // 알람 설정 모드 - sw on 
                fnd_data = (alarm_hour * 100) + alarm_min;
            end else begin
                // 일반 시계 모드 - sw off
                fnd_data = (rtc_hour * 100) + rtc_min; 
            end
        end
    end

endmodule
```

→ 온습도 소수부분이나 시간설정에서 hour, min 제외하고는 굳이 input 선언안해도됐을 것 같다

```verilog
`timescale 1ns / 1ps

module dht_controller(
    input clk,
    input reset,
    input start_trigger,
    inout dht11_data,

    output [7:0] hum_int,
    output [7:0] hum_dec,
    output [7:0] tem_int,
    output [7:0] tem_dec
);
    wire w_io_mode, w_o_data, w_i_data;

    dht11 u_dht11(
        .io_mode    (w_io_mode),
        .o_data     (w_o_data),
        .i_data     (w_i_data),
        .dht11_data (dht11_data)
    );

    dht11_main_logic u_dht11_main_logic(
        .clk            (clk),
        .reset          (reset),
        .start_trigger  (start_trigger),
        .i_data         (w_i_data),
        .o_data         (w_o_data),
        .io_mode        (w_io_mode),
        .hum_int        (hum_int),
        .hum_dec        (hum_dec),
        .tem_int        (tem_int),
        .tem_dec        (tem_dec)
    );

endmodule

module dht11_main_logic(
    input clk,
    input reset,
    input start_trigger,
    input i_data,
    output reg o_data,
    output reg io_mode,
    output reg [7:0] hum_int,
    output reg [7:0] hum_dec,
    output reg [7:0] tem_int,
    output reg [7:0] tem_dec
);
    localparam IDLE                 = 4'd0;
    localparam START_LOW            = 4'd1;
    localparam START_PULL_UP        = 4'd2;
    localparam WAIT_LOW_HIGH        = 4'd3;
    localparam WAIT_BIT_LOW         = 4'd4;
    localparam CHECK_HIGH_DURATION  = 4'd5;
    localparam STORE_BIT            = 4'd6;
    localparam CHECK_DATA           = 4'd7;

    localparam TIME_18mS            = 1_800_000;
    localparam TIME_30uS            = 3_000;
    localparam TIME_160uS           = 16_000;
    localparam TIME_BIT_THRESHOLD   = 5_000;

    reg [21:0] counter;

    reg [3:0] state;
    reg i_data_ff1, i_data_ff2;
    reg low_high;

    reg [15:0] high_time_cnt;   // 데이터 high 시간 감지할 counter
    reg [39:0] data;
    reg [5:0] data_bit_cnt; // 데이터 bit counter
    reg recieved_bit;

    // 2단 FF
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            i_data_ff1 <= 1;    // 기본 i_data는 idle 상태에서 1
            i_data_ff2 <= 1;
        end else begin
            i_data_ff1 <= i_data;
            i_data_ff2 <= i_data_ff1;
        end
    end

    // FSM
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            io_mode <= 1;   // input mode
            o_data <= 1;    // pull_down 18ms를 제외하면 항상 1
            
            counter <= 0;

            high_time_cnt <= 0;
            data <= 0;
            data_bit_cnt <= 0;
            low_high <= 0;

            hum_int <= 0;
            hum_dec <= 0;
            tem_int <= 0;
            tem_dec <= 0;
        end else begin
            case(state)
                IDLE: begin
                    io_mode <= 1;
                    o_data <= 1;
                    high_time_cnt <= 0;
                    data <= 0;
                    data_bit_cnt <= 0;
                    low_high <= 0;
                    counter <= 0;

                    if(start_trigger) begin
                        state <= START_LOW;
                    end
                end

                // 18ms start signal low
                START_LOW: begin
                    io_mode <= 0;   // output mode
                    o_data <= 0;    // pull down 동작

                    if(counter >= TIME_18mS - 1) begin
                        counter <= 0;
                        state <= START_PULL_UP;
                    end else begin
                        counter <= counter + 1;
                    end
                end

                // 30us start signal high
                START_PULL_UP: begin
                    o_data <= 1;

                    if(counter >= TIME_30uS - 1) begin
                        counter <= 0;
                        state <= WAIT_LOW_HIGH;
                    end else begin
                        counter <= counter + 1;
                    end
                end
                
                WAIT_LOW_HIGH: begin
                    io_mode <= 1;   // input mode
                    
                    // rise, fall edge를 기다림
                    if(i_data_ff1 && !i_data_ff2) begin
                        low_high <= 1;
                    end else if(low_high && !i_data_ff1 && i_data_ff2) begin
                        low_high <= 0;
                        state <= WAIT_BIT_LOW;
                    end
                    // 응답 기다림 80us low, 80us high  오류 검출 필요
                    // if(counter >= TIME_160uS - 1) begin
                    //     counter <= 0;
                    //     state <= WAIT_BIT_LOW;
                    // end else begin
                    //     counter <= counter + 1;
                    // end
                end

                // data 전송 과정에서 high가 들어오기를 기다림
                WAIT_BIT_LOW: begin
                    if(i_data_ff1 && !i_data_ff2) begin // 상승엣지를 만나면 state 변경
                        state <= CHECK_HIGH_DURATION;
                    end
                end

                // high 시간 측정
                CHECK_HIGH_DURATION: begin
                    if(!i_data_ff1 && i_data_ff2) begin // 하강엣지일때
                        // 50us를 기준으로 1, 0 확인
                        if(high_time_cnt >= TIME_BIT_THRESHOLD) begin
                            recieved_bit <= 1;
                        end else begin
                            recieved_bit <= 0;
                        end
                        state <= STORE_BIT;
                    end else begin
                        if(high_time_cnt < 16'hffff) begin  // 하강엣지 안들어오는 경우 방지
                            high_time_cnt <= high_time_cnt + 1;
                        end
                    end
                end

                // data에 bit 저장
                STORE_BIT: begin
                    high_time_cnt <= 0;
                    data <= {data[38:0], recieved_bit}; // shift 시켜가며 밀기

                    if(data_bit_cnt >= 39) begin
                        state <= CHECK_DATA;
                    end else begin
                        data_bit_cnt <= data_bit_cnt + 1;
                        state <= WAIT_BIT_LOW;
                    end
                end

                // check sum error 탐지
                CHECK_DATA : begin
                    if ((data[39:32] + data[31:24] +
                         data[23:16] + data[15:8]) == data[7:0]) begin
                        tem_int <= data[39:32];
                        tem_dec <= data[31:24];
                        hum_int <= data[23:16];
                        hum_dec <= data[15:8];
                    end else begin
                        // error 처리 필요
                        hum_int <= 0;
                        hum_dec <= 0;
                        tem_int <= 0;
                        tem_dec <= 0;
                    end
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

module dht11(
    input io_mode,
    input o_data,
    output i_data,
    inout dht11_data
);
    assign dht11_data = io_mode ? 1'bz : o_data;
    assign i_data = dht11_data;
endmodule
```

```verilog
`timescale 1ns / 1ps

module ds1302_controller(
    input clk,
    input reset,
    input start_trigger,
    input write_request,
    input [7:0] i_sec,
    input [7:0] i_min,
    input [7:0] i_hour,
    input [7:0] i_date,
    input [7:0] i_month,
    input [7:0] i_year,
    output ce,
    output sclk,
    inout ds1302_data,

    output reg set_time_done,
    output reg busy,
    output reg [7:0] o_sec,
    output reg [7:0] o_min,
    output reg [7:0] o_hour,
    output reg [7:0] o_date,
    output reg [7:0] o_month,
    output reg [7:0] o_year
);
    wire w_io_mode, w_o_data, w_i_data, w_done;

    localparam IDLE           = 4'd0;
    localparam WP_OFF         = 4'd1;
    localparam WRITE_DATA     = 4'd2;
    localparam WP_ON          = 4'd3;
    localparam READ_DATA      = 4'd4;

    localparam READ_SEC     = 8'h81;
    localparam READ_MIN     = 8'h83;
    localparam READ_HOUR    = 8'h85;
    localparam READ_DATE    = 8'h87;
    localparam READ_MONTH   = 8'h89;
    localparam READ_YEAR    = 8'h8D;

    localparam WRITE_SEC    = 8'h80;
    localparam WRITE_MIN    = 8'h82;
    localparam WRITE_HOUR   = 8'h84;
    localparam WRITE_DATE   = 8'h86;
    localparam WRITE_MONTH  = 8'h88;
    localparam WRITE_YEAR   = 8'h8C;
    localparam WRITE_WP     = 8'h8E;

    reg [2:0] state;
    reg rw;   // busy는 output reg로 뽑기 가능, rw:0 -> write, 1 -> read
    reg start;
    reg [7:0] wr_data;
    wire [7:0] rd_data;
    reg [7:0] cmd;

    function [7:0] from_bcd;
        input [7:0] val;
        begin
            from_bcd = ((val[7:4] * 10) + val[3:0]);
        end
    endfunction

    ds1302_logic u_ds1302_logic(
        .clk            (clk),
        .reset          (reset),
        .start          (start),
        .i_data         (w_i_data),
        .rw             (rw),
        .cmd            (cmd),
        .wr_data        (wr_data),
        .rd_data        (rd_data),
        .ce             (ce),
        .sclk           (sclk),
        .io_mode        (w_io_mode),
        .o_data         (w_o_data),
        .done           (w_done)
    );

    ds1302 u_ds1302(
        .io_mode        (w_io_mode),
        .o_data         (w_o_data),
        .i_data         (w_i_data),
        .ds1302_data    (ds1302_data)
    );

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            start <= 0;
            rw <= 0;
            busy <= 0;
            cmd <= 8'h00;
            wr_data <= 8'h00;
        end else begin
            start <= 0;
            set_time_done <= 0;

            case(state)
                IDLE: begin
                    busy <= 0;
                    if(write_request) begin
                        busy <= 1;
                        rw <= 0;
                        cmd <= WRITE_WP;
                        wr_data <= 8'h00;
                        start <= 1;
                        state <= WP_OFF;
                    end else if(start_trigger) begin
                        busy <= 1;
                        rw <= 1;
                        cmd <= READ_SEC;
                        start <= 1;
                        state <= READ_DATA;
                    end
                end

                WP_OFF: begin
                    if(w_done) begin
                        cmd <= WRITE_SEC;
                        wr_data <= i_sec & 8'h7F;
                        start <= 1;
                        state <= WRITE_DATA;
                    end
                end

                WRITE_DATA: begin
                    if(w_done) begin
                        case(cmd)
                            WRITE_SEC: begin
                                cmd <= WRITE_MIN;
                                wr_data <= i_min;
                            end
                            WRITE_MIN: begin
                                cmd <= WRITE_HOUR;
                                wr_data <= i_hour;
                            end
                            WRITE_HOUR: begin
                                cmd <= WRITE_DATE;
                                wr_data <= i_date;
                            end
                            WRITE_DATE: begin
                                cmd <= WRITE_MONTH;
                                wr_data <= i_month;
                            end
                            WRITE_MONTH: begin
                                cmd <= WRITE_YEAR;
                                wr_data <= i_year;
                            end
                            WRITE_YEAR: begin
                                cmd <= WRITE_WP;
                                wr_data <= 8'h80;
                                state <= WP_ON;
                            end
                        endcase
                        start <= 1;
                    end
                end

                WP_ON: begin
                    if(w_done) begin
                        set_time_done <= 1;
                        state <= IDLE;
                    end
                end

                READ_DATA: begin
                    if(w_done) begin
                        case(cmd)
                            READ_SEC: begin
                                cmd <= READ_MIN;
                                o_sec <= from_bcd(rd_data & 8'h7F);
                                start <= 1;
                            end
                            READ_MIN: begin
                                cmd <= READ_HOUR;
                                o_min <= from_bcd(rd_data & 8'h7F);
                                start <= 1;
                            end
                            READ_HOUR: begin
                                cmd <= READ_DATE;
                                o_hour <= from_bcd(rd_data & 8'h3F);
                                start <= 1;
                            end
                            READ_DATE: begin
                                cmd <= READ_MONTH;
                                o_date <= from_bcd(rd_data & 8'h3F);
                                start <= 1;
                            end
                            READ_MONTH: begin
                                cmd <= READ_YEAR;
                                o_month <= from_bcd(rd_data & 8'h1F);
                                start <= 1;
                            end
                            READ_YEAR: begin
                                o_year <= from_bcd(rd_data);
                                state <= IDLE;
                            end
                        endcase
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
```

```verilog
module ds1302_logic(
    input clk,
    input reset,
    input start,
    input i_data,
    input rw,
    input [7:0] cmd,
    input [7:0] wr_data,
    output reg [7:0] rd_data,

    output reg ce,
    output reg sclk,
    output reg io_mode, // 1: input, 0: output
    output reg o_data,
    output reg done
);
    localparam IDLE         = 4'd0;
    localparam CE_HIGH      = 4'd1;
    localparam SEND_CMD     = 4'd2;
    localparam RW_DATA      = 4'd3;
    localparam CE_LOW       = 4'd4;

    localparam DIVIDER      = 50;

    reg [2:0] state;
    reg [7:0] shifter;
    reg [7:0] rd_shifter;
    reg [3:0] bit_cnt;  // bit 수
    reg [21:0] counter;
    
    // FSM
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            rd_data <= 8'h00;
            shifter <= 8'h00;
            rd_shifter <= 8'h00;
            done <= 0;
            ce <= 0;
            sclk <= 0;
            io_mode <= 0;
            o_data <= 0;
            bit_cnt <= 0;
            counter <= 0;
        end else begin
            done <= 0;
            case(state)
                IDLE: begin
                    ce <= 0;
                    sclk <= 0;
                    bit_cnt <= 0;
                    io_mode <= 1;   // 기본 input mode
                    o_data <= 0;

                    if(start) begin
                        shifter <= cmd;
                        rd_shifter <= 8'h00;
                        state <= CE_HIGH;
                    end
                end

                CE_HIGH: begin
                    ce <= 1;    // ce를 high (start)
                    io_mode <= 0;   // 출력모드로
                    o_data <= cmd[0];
                    state <= SEND_CMD;
                end

                SEND_CMD: begin
                    if(counter >= DIVIDER - 1) begin
                        counter <= 0;
                        sclk <= ~sclk;
                        if(sclk) begin // 하강엣지
                            shifter <= {1'b0, shifter[7:1]};

                            if(bit_cnt >= 7) begin
                                bit_cnt <= 0;
                                if(rw) begin
                                    io_mode <= 1;   // 입력모드로
                                    rd_shifter <= 8'h00;
                                end else begin
                                    shifter <= wr_data;
                                    io_mode <= 0;
                                    o_data <= wr_data[0];
                                end
                                state <= RW_DATA;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                                o_data <= shifter[1];
                            end
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end

                RW_DATA: begin
                    if(counter >= DIVIDER - 1) begin
                        counter <= 0;
                        sclk <= ~sclk;
                        if(sclk) begin    // sclk 하강엣지마다 데이터 읽기 or o_data 값 바꿈
                            if(rw) begin
                                rd_shifter <= {i_data, rd_shifter[7:1]};
                            end else begin
                                shifter <= {1'b0, shifter[7:1]};
                                o_data <= shifter[1];
                            end

                            if(bit_cnt >= 7) begin
                                if(rw)
                                    rd_data <= {i_data, rd_shifter[7:1]};
                                state <= CE_LOW;
                            end else begin
                                bit_cnt <= bit_cnt + 1;
                            end
                        end
                    end else begin
                        counter <= counter + 1;
                    end
                end

                CE_LOW: begin
                    ce <= 0;
                    io_mode <= 1;
                    done <= 1;
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end

endmodule

module ds1302(
    input io_mode,
    input o_data,
    output i_data,
    inout ds1302_data
);
    assign ds1302_data = io_mode ? 1'bz : o_data;
    assign i_data = ds1302_data;
endmodule
```

```verilog
`timescale 1ns / 1ps

module rotary(
    input clk,
    input reset,
    input clean_s1,
    input clean_s2,
    input clean_key,
    
    output reg cw_tick,
    output reg ccw_tick,
    output reg key_tick
);

    reg [1:0] r_prev_state, r_current_state;
    
    reg r_prev_key;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_prev_state <= 2'b11;
            r_current_state <= 2'b11;
            r_prev_key <= 1'b0;
            cw_tick <= 1'b0;
            ccw_tick <= 1'b0;
            key_tick <= 1'b0;
        end else begin
            // 펄스는 1클럭만 유지하고 바로 끔
            cw_tick <= 1'b0;
            ccw_tick <= 1'b0;
            key_tick <= 1'b0;

            // 로터리 회전 감지 (상태 변화 분석)
            r_prev_state <= r_current_state;
            r_current_state <= {clean_s1, clean_s2};

            case ({r_prev_state, r_current_state})
                // 시계 방향
                4'b1101, 4'b0100, 4'b0010, 4'b1011 : cw_tick <= 1'b1;
                // 반시계 방향
                4'b1110, 4'b1000, 4'b0001, 4'b0111 : ccw_tick <= 1'b1;
            endcase

            // key 클릭 감지
            r_prev_key <= clean_key;
            if (!r_prev_key && clean_key) begin
                key_tick <= 1'b1;
            end
        end
    end
endmodule
```

```verilog
`timescale 1ns / 1ps

module alarm_controller(
    input clk,
    input reset,
    input sw0, 
    
    input cw_tick,
    input ccw_tick,
    input key_tick,
    
    // ds1302 시간
    input [7:0] current_hour,
    input [7:0] current_min,
    input [7:0] current_sec,
    
    // 알람 설정 시간
    output reg [7:0] alarm_hour,
    output reg [7:0] alarm_min,

    output reg led0,      
    output reg buzzer 
);

    localparam SET_HOUR = 2'd0;
    localparam SET_MIN  = 2'd1;
    localparam SET_DONE = 2'd2; 

    reg [1:0] set_state; // 위에 3개 상태
    reg is_armed; // 알람 울리는지 기억 플래그 (1: 알람 울리기 저장)
    reg r_alarm_ring; // 알람 울리는중: 1, 알람 안울림 : 0

    localparam DO = 22'd191_112; 
    localparam TIME_500MS = 26'd50_000_000; 
    
    reg [21:0] tone_cnt;
    reg [25:0] pattern_cnt;
    reg beep_en; 

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            tone_cnt <= 0; pattern_cnt <= 0; beep_en <= 0; buzzer <= 0;
        end else begin
            if (r_alarm_ring) begin
                if (pattern_cnt >= TIME_500MS - 1) begin
                    pattern_cnt <= 0; beep_en <= ~beep_en;
                end else pattern_cnt <= pattern_cnt + 1;
                
                if (beep_en) begin
                    if (tone_cnt >= DO - 1) begin
                        tone_cnt <= 0; buzzer <= ~buzzer; 
                    end else tone_cnt <= tone_cnt + 1;
                end else buzzer <= 0; 
            end else begin
                pattern_cnt <= 0; tone_cnt <= 0; beep_en <= 0; buzzer <= 0;
            end
        end
    end

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            alarm_hour <= 8'd0;
            alarm_min <= 8'd0;
            set_state <= SET_HOUR;
            is_armed <= 1'b0;
            led0 <= 1'b0;
            r_alarm_ring <= 1'b0;
        end else begin
            if (is_armed && !r_alarm_ring) begin
                if (sw0 && key_tick) begin
                    is_armed <= 1'b0;
                    led0 <= 1'b0;
                    set_state <= SET_HOUR;
                end
                
                else if ((current_hour == alarm_hour) && (current_min == alarm_min) && (current_sec == 8'd0)) begin
                        r_alarm_ring <= 1'b1; 
                        led0 <= 1'b0;
                        is_armed <= 1'b0; 
                end
            end
            
            // 알람이 울리고 있을 때
            else if (r_alarm_ring) begin
                // 부저가 울릴 때 sw 상태와 관계없이 로터리 key 누르면 해제
                if (key_tick) begin
                    r_alarm_ring <= 1'b0;
                    is_armed <= 1'b0;
                    led0 <= 1'b0;
                    set_state <= SET_HOUR; 
                end
            end
            
            // 알람 세팅 모드
            else begin
                if (sw0) begin
                    case (set_state)
                        SET_HOUR: begin
                            if (cw_tick)  alarm_hour <= (alarm_hour == 23) ? 0 : alarm_hour + 1; // 정방향은 증가
                            if (ccw_tick) alarm_hour <= (alarm_hour == 0) ? 23 : alarm_hour - 1; // 역방향은 감소
                            if (key_tick) set_state <= SET_MIN;
                        end
                        
                        SET_MIN: begin
                            if (cw_tick)  alarm_min <= (alarm_min == 59) ? 0 : alarm_min + 1;
                            if (ccw_tick) alarm_min <= (alarm_min == 0) ? 59 : alarm_min - 1;
                            if (key_tick) begin
                                set_state <= SET_DONE; 
                                is_armed <= 1'b1; 
                                led0 <= 1'b1;
                            end
                        end
                        
                        SET_DONE: begin
                        end
                    endcase
                end else begin
                    // 스위치가 내렸을때 다시 시간 세팅으로 돌아감
                    set_state <= SET_HOUR; 
                end
            end
        end
    end
endmodule
```

```verilog
`timescale 1ns / 1ps

module fnd_controller(
    input clk,
    input reset,
    input [13:0] in_data,
    output [3:0] an,
    output [7:0] seg
);
    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    fnd_digit_select u_fnd_digit_select(
        .clk   (clk),
        .reset (reset),
        .sel   (w_sel)
    );

    bin2bdc4digit u_bin2bdc4digit(
        .in_data    (in_data),
        .d1         (w_d1),
        .d10        (w_d10),
        .d100       (w_d100),
        .d1000      (w_d1000)
    );

    fnd_digit_display u_fnd_digit_display(
        .digit_sel  (w_sel),
        .d1         (w_d1),
        .d10        (w_d10),
        .d100       (w_d100),
        .d1000      (w_d1000),
        .an         (an),
        .seg        (seg)
    );

endmodule

module fnd_digit_select(
    input clk,
    input reset,
    output reg [1:0] sel    // 00 01 10 11 : 1ms마다 바뀜
);
    reg[$clog2(100_000):0] r_1ms_counter = 0;

    always @(posedge reset, posedge clk) begin
        if(reset) begin
            r_1ms_counter <= 0;
            sel <= 0;
        end else begin
            if(r_1ms_counter == 100_000 - 1) begin
                r_1ms_counter <= 0;
                sel <= sel + 1;
            end else begin
                r_1ms_counter <= r_1ms_counter + 1;
            end
        end
    end
endmodule

module bin2bdc4digit(
    input [13:0] in_data,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);
    assign d1 = in_data % 10;
    assign d10 = (in_data / 10) % 10;
    assign d100 = (in_data / 100) % 10;
    assign d1000 = (in_data / 1000) % 10;
endmodule

module fnd_digit_display(
    input [1:0] digit_sel,
    input [3:0] d1,
    input [3:0] d10,
    input [3:0] d100,
    input [3:0] d1000,
    output reg [3:0] an,
    output reg [7:0] seg
);
    reg [3:0] bcd_data;
    reg dot;    // 분.초를 위한 dot

    always @(digit_sel) begin
        case(digit_sel) 
            2'b00: begin
                dot = 0;
                bcd_data = d1;
                an = 4'b1110;
            end
            2'b01: begin
                dot = 0;
                bcd_data = d10;
                an = 4'b1101;
            end
            2'b10: begin
                dot = 1;
                bcd_data = d100;
                an = 4'b1011;
            end
            2'b11: begin
                dot = 0;
                bcd_data = d1000;
                an = 4'b0111;
            end
            default: begin
                dot = 0;
                bcd_data = 0;
                an = 4'b1111;
            end
        endcase
    end

    always @(bcd_data) begin
        case(bcd_data)
            4'd0: seg = 8'b11000000;
            4'd1: seg = 8'b11111001;
            4'd2: seg = 8'b10100100;
            4'd3: seg = 8'b10110000;
            4'd4: seg = 8'b10011001;
            4'd5: seg = 8'b10010010;
            4'd6: seg = 8'b10000010;
            4'd7: seg = 8'b11111000;
            4'd8: seg = 8'b10000000;
            4'd9: seg = 8'b10010000;
            default: seg = 8'b11111111;
        endcase

        if(dot) begin
            seg[7] = 0;
        end
    end
endmodule
```

```verilog
`timescale 1ns / 1ps

module uart_controller(
    input clk,
    input reset,
    input start_trigger,
    input set_time_done,
    input ds1302_busy,

    input [7:0] hum_int,
    input [7:0] hum_dec,
    input [7:0] tem_int,
    input [7:0] tem_dec,

    input [7:0] rtc_sec,
    input [7:0] rtc_min,
    input [7:0] rtc_hour,
    input [7:0] rtc_date,
    input [7:0] rtc_month,
    input [7:0] rtc_year,

    input rx,
    output tx,
    output [47:0] time_data,
    output set_time_trigger
);
    wire w_tx_start, w_tx_busy, w_tx_done;
    wire w_rx_done;
    wire [7:0] w_rx_data;
    wire [7:0] w_tx_data;

    data_sender u_data_sender(
        .clk            (clk),
        .reset          (reset),
        .start_trigger  (start_trigger),

        .hum_int        (hum_int),
        .hum_dec        (hum_dec),
        .tem_int        (tem_int),
        .tem_dec        (tem_dec),

        .rtc_sec        (rtc_sec),
        .rtc_min        (rtc_min),
        .rtc_hour       (rtc_hour),
        .rtc_date       (rtc_date),
        .rtc_month      (rtc_month),
        .rtc_year       (rtc_year),

        .tx_busy        (w_tx_busy),
        .tx_done        (w_tx_done),
        .tx_data        (w_tx_data),
        .tx_start       (w_tx_start)
    );

    data_receiver u_data_receiver(
        .clk                (clk),
        .reset              (reset),
        .rx_done            (w_rx_done),
        .rx_data            (w_rx_data),
        .set_time_done      (set_time_done),
        .set_time_trigger   (set_time_trigger),
        .ds1302_busy        (ds1302_busy),
        .time_data          (time_data)
    );

    uart_tx #(
        .BPS(9600)
    ) u_uart_tx(
        .clk        (clk),
        .reset      (reset),
        .tx_data    (w_tx_data),
        .tx_start   (w_tx_start),
        .tx         (tx),
        .tx_done    (w_tx_done),
        .tx_busy    (w_tx_busy)
    );

    uart_rx #(
        .BPS(9600)
    ) u_uart_rx(
        .clk        (clk),
        .reset      (reset),
        .rx         (rx),
        .data_out   (w_rx_data),
        .rx_done    (w_rx_done)
    );

endmodule

```

```verilog
`timescale 1ns / 1ps

module data_sender(
    input clk,
    input reset,
    input start_trigger,

    input [7:0] hum_int,
    input [7:0] hum_dec,
    input [7:0] tem_int,
    input [7:0] tem_dec,    

    input [7:0] rtc_sec,
    input [7:0] rtc_min,
    input [7:0] rtc_hour,
    input [7:0] rtc_date,
    input [7:0] rtc_month,
    input [7:0] rtc_year,

    input tx_busy,
    input tx_done,
    output reg [7:0] tx_data,
    output reg tx_start
);
    function [7:0] to_ascii_10;
        input [7:0] val;
        begin
            to_ascii_10 = (val / 10) % 10 + 8'h30;
        end
    endfunction

    function [7:0] to_ascii_1;
        input [7:0] val;
        begin
            to_ascii_1 = val % 10 + 8'h30;
        end
    endfunction

    // 숫자 -> ASCII 문자로 변환
    wire [7:0] hum_10       = to_ascii_10(hum_int);
    wire [7:0] hum_1        = to_ascii_1(hum_int);
    wire [7:0] hum_10_dec   = to_ascii_10(hum_dec);
    wire [7:0] hum_1_dec    = to_ascii_1(hum_dec);
    wire [7:0] tem_10       = to_ascii_10(tem_int);
    wire [7:0] tem_1        = to_ascii_1(tem_int);
    wire [7:0] tem_10_dec   = to_ascii_10(tem_dec);
    wire [7:0] tem_1_dec    = to_ascii_1(tem_dec);

    wire [7:0] year_10      = to_ascii_10(rtc_year);
    wire [7:0] year_1       = to_ascii_1(rtc_year);
    wire [7:0] month_10     = to_ascii_10(rtc_month);
    wire [7:0] month_1      = to_ascii_1(rtc_month);
    wire [7:0] date_10      = to_ascii_10(rtc_date);
    wire [7:0] date_1       = to_ascii_1(rtc_date);
    wire [7:0] hour_10      = to_ascii_10(rtc_hour);
    wire [7:0] hour_1       = to_ascii_1(rtc_hour);
    wire [7:0] min_10       = to_ascii_10(rtc_min);
    wire [7:0] min_1        = to_ascii_1(rtc_min);
    wire [7:0] sec_10       = to_ascii_10(rtc_sec);
    wire [7:0] sec_1        = to_ascii_1(rtc_sec);

    localparam IDLE = 2'b00;
    localparam SEND = 2'b01;
    localparam WAIT = 2'b10;

    reg [1:0] state;
    reg [4:0] byte_cnt;     // byte 개수
    reg print_mode;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            tx_start <= 1'b0;
            tx_data <= 8'd0;
            byte_cnt <= 5'd0;
            print_mode <= 0;
        end else begin
            case (state)
                IDLE: begin
                    tx_start <= 1'b0;
                    byte_cnt <= 5'd0;
                    print_mode <= 0;
                    if (start_trigger) begin
                        state <= SEND;
                    end
                end
                
                SEND: begin
                    if (!tx_busy) begin
                        tx_start <= 1'b1;
                        if(!print_mode) begin
                            case(byte_cnt)
                                5'd0:  tx_data <= 8'h32; // 2
                                5'd1:  tx_data <= 8'h30; // 0
                                5'd2:  tx_data <= year_10; 
                                5'd3:  tx_data <= year_1;
                                5'd4:  tx_data <= 8'h2E; // .
                                5'd5:  tx_data <= month_10;
                                5'd6:  tx_data <= month_1;
                                5'd7:  tx_data <= 8'h2E; // .
                                5'd8:  tx_data <= date_10;
                                5'd9:  tx_data <= date_1;
                                5'd10:  tx_data <= 8'h2E; // .
                                5'd11:  tx_data <= hour_10;
                                5'd12:  tx_data <= hour_1;
                                5'd13:  tx_data <= 8'h2E; // .
                                5'd14:  tx_data <= min_10;
                                5'd15:  tx_data <= min_1;
                                5'd16:  tx_data <= 8'h2E; // .
                                5'd17:  tx_data <= sec_10;
                                5'd18:  tx_data <= sec_1;
                                5'd19:  tx_data <= 8'h0A;  // LF
                                default: tx_data <= 8'h00;
                            endcase
                        end else begin
                            case(byte_cnt)
                                5'd0:  tx_data <= 8'h54; // T
                                5'd1:  tx_data <= 8'h3A; // :
                                5'd2:  tx_data <= tem_10; 
                                5'd3:  tx_data <= tem_1;
                                5'd4:  tx_data <= 8'h2E; // .
                                5'd5:  tx_data <= tem_10_dec;
                                5'd6:  tx_data <= tem_1_dec;
                                5'd7:  tx_data <= 8'h0A; // \n
                                5'd8:  tx_data <= 8'h48; // H
                                5'd9:  tx_data <= 8'h3A; // :
                                5'd10:  tx_data <= hum_10; 
                                5'd11:  tx_data <= hum_1; 
                                5'd12:  tx_data <= 8'h2E; // .
                                5'd13:  tx_data <= hum_10_dec;
                                5'd14:  tx_data <= hum_1_dec;
                                5'd15: tx_data <= 8'h0A;    // \n
                                default: tx_data <= 8'h00;
                            endcase
                        end
                        
                        state <= WAIT;
                    end
                end
                
                WAIT: begin
                    tx_start <= 1'b0; // 1클럭 High 유지 -> Low
                    if (tx_done) begin
                        if (byte_cnt == (print_mode ? 5'd15 : 5'd19)) begin
                            if(print_mode) begin
                                state <= IDLE;
                            end else begin
                                print_mode <= 1;
                                byte_cnt <= 5'd0;
                                state <= SEND;
                            end
                        end else begin
                            byte_cnt <= byte_cnt + 1;
                            state <= SEND; // 다음 글자 전송
                        end
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
endmodule
```

```verilog
`timescale 1ns / 1ps

module data_receiver(
    input clk,
    input reset,
    input rx_done,
    input [7:0] rx_data,
    input set_time_done,
    input ds1302_busy,
    output reg set_time_trigger,
    output reg [47:0] time_data
);
    function [3:0] to_num;
        input [7:0] ascii;
        begin
            to_num = ascii - 8'h30;
        end
    endfunction

    localparam TIME_OUT_DURATION = 1_000_000; // 10ms timeout duration
    reg busy;
    reg [7:0] c_queue [15:0][19:0];
    reg [3:0] rear, front;
    reg [4:0] byte_cnt;
    integer i, j;
    reg [$clog2(TIME_OUT_DURATION)-1:0] time_out_cnt;

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            for(i=0;i<16;i=i+1) begin
                for(j=0;j<20;j=j+1) begin
                    c_queue[i][j] <= 0;
                end
            end
            rear <= 0;
            front <= 0;
            byte_cnt <= 0;
            busy <= 0;
            set_time_trigger <= 0;
            time_data <= 48'd0;
            time_out_cnt <= 0;
        end else begin
            set_time_trigger <= 0;
            if(rx_done) begin
                if(rx_data == 8'h0A) begin  // 개행문자를 기준으로 cicler queue에 저장
                    front <= (front == 4'd15) ? 0 : front + 1;  // front 증가
                    if(front == rear-1) rear <= rear + 1;
                    byte_cnt <= 0;
                end else if(rx_data != 8'h0D) begin
                    byte_cnt <= byte_cnt + 1;
                    c_queue[front][byte_cnt] <= rx_data;    // front 위치에 byte 저장
                end
            end

            if(!busy) begin
                if(rear != front && !ds1302_busy) begin // set time 데이터가 있다는 뜻
                    if({c_queue[rear][0],
                    c_queue[rear][1],
                    c_queue[rear][2],
                    c_queue[rear][3],
                    c_queue[rear][4],
                    c_queue[rear][5]} == "setrtc") begin
                        for(i=0;i<12;i=i+1) begin
                            time_data[4*(11-i) +: 4] <= to_num(c_queue[rear][i+6]);
                        end
                        set_time_trigger <= 1;
                        busy <= 1;
                    end
                end
            end else begin
                if(time_out_cnt >= TIME_OUT_DURATION) begin
                    time_out_cnt <= 0;
                    busy <= 0;
                    time_data <= 48'd0;
                    // time out error
                end else begin
                    if(set_time_done) begin
                        if(rear != front) begin
                            rear <= rear + 1;   // set한 데이터는 삭제
                        end
                        time_out_cnt <= 0;
                        busy <= 0;
                        time_data <= 48'd0;
                    end else begin
                        time_out_cnt <= time_out_cnt + 1;
                    end
                end
            end
        end
    end
endmodule

```

```verilog
`timescale 1ns / 1ps

module uart_tx #(
    parameter BPS = 9600
) (
    input clk,
    input reset,
    input [7:0] tx_data,
    input tx_start,
    output reg tx,
    output reg tx_done,
    output reg tx_busy
);
    parameter S_IDLE = 2'b00;
    parameter S_START_BIT = 2'b01;
    parameter S_DATA_8BITS = 2'b10;
    parameter S_STOP_BIT = 2'b11;
    parameter DIVIDER_CNT = 100_000_000 / BPS;

    reg [1:0] r_state;      // state transition
    reg [3:0] r_bit_cnt;    // 전송 bit count
    reg [7:0] r_data;       // 전송할 1 byte
    reg [15:0] r_baud_cnt;  // 10416ns
    reg r_baud_tick;        // 10416ns 마다 1 tick 발생

    // 10416ns 마다 1 tick 발생 --> r_baud_tick
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_baud_tick <= 0;
            r_baud_cnt <= 0;
        end else begin
            if(r_baud_cnt >= DIVIDER_CNT - 1) begin
                r_baud_cnt <= 0;
                r_baud_tick <= 1;
            end else begin
                r_baud_cnt <= r_baud_cnt + 1;
                r_baud_tick <= 0;
            end
        end
    end

    // tick 발생시마다 
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_state <= S_IDLE;
            r_bit_cnt <= 0;
            r_data <= 0;
            tx_done <= 0;
            tx_busy <= 0;
            tx <= 1;    // IDLE: HIGH
        end else begin
            case(r_state)
            S_IDLE: begin
                tx_done <= 0;
                if(tx_start) begin
                    r_state <= S_START_BIT;
                    r_data <= tx_data;
                    tx_busy <= 1;
                    r_bit_cnt <= 0;
                end
            end

            S_START_BIT: begin
                if(r_baud_tick) begin
                    tx <= 0;    // start bit
                    r_state <= S_DATA_8BITS;
                end
            end

            S_DATA_8BITS: begin
                if(r_baud_tick) begin
                    tx <= r_data[r_bit_cnt];
                    if(r_bit_cnt == 4'd7) begin
                        r_state <= S_STOP_BIT;
                    end else begin
                        r_bit_cnt <= r_bit_cnt + 1;
                    end
                end
            end

            S_STOP_BIT: begin
                if(r_baud_tick) begin
                    tx <= 1;    // stop bit
                    tx_done <= 1;   // 1 byte 전송 완료
                    tx_busy <= 0;
                    r_state <= S_IDLE;
                end
            end

            default: r_state <= S_IDLE;
            endcase
        end
    end
endmodule

```

```verilog
`timescale 1ns / 1ps

module uart_rx #(
    parameter BPS = 9600
) (
    input clk,
    input reset,
    input rx,
    output reg [7:0] data_out,
    output reg rx_done
);
    parameter S_IDLE = 2'b00;
    parameter S_START_BIT = 2'b01;
    parameter S_DATA_8BITS = 2'b10;
    parameter S_STOP_BIT = 2'b11;

    // 9600 * 16 = 153_600
    // 100_000_000 Hz / 153_000 = 651ns ( 651ns 주기로 sampling )
    parameter DIVIDER_CNT = 100_000_000 / (BPS * 16);

    reg [1:0] r_state;          // state S_IDLE --> S_STOP_BIT
    reg [3:0] r_bit_cnt;        // r_data에 저장할 index값
    reg [7:0] r_data;           // rx 포트로부터 들어온 bit를 담을 그릇
    reg [15:0] r_baud_cnt;      // 651ns sampling count
    reg r_baud_tick;            // 651ns마다 tick 발생
    reg [3:0] r_baud_tick_cnt;  // 16개 oversampling count

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_baud_tick <= 0;
            r_baud_cnt <= 0;
        end else begin
            if(r_baud_cnt >= DIVIDER_CNT - 1) begin
                r_baud_cnt <= 0;
                r_baud_tick <= 1;
            end else begin
                r_baud_cnt <= r_baud_cnt + 1;
                r_baud_tick <= 0;
            end
        end
    end

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            r_state <= S_IDLE;
            r_bit_cnt <= 0;
            r_data <= 0;
            rx_done <= 0;
            r_baud_tick_cnt <= 0;
            data_out <= 0;
        end else begin
            case(r_state)
            S_IDLE: begin
                rx_done <= 0;
                r_data <= 0;
                if(!rx) begin
                    r_baud_tick_cnt <= 0;
                    r_state <= S_START_BIT;
                end
            end

            S_START_BIT: begin
                if(r_baud_tick) begin
                    r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                    if(r_baud_tick_cnt >= 7) begin
                        r_state <= S_DATA_8BITS;
                        r_bit_cnt <= 0;
                        r_baud_tick_cnt <= 0;
                    end
                end
            end

            S_DATA_8BITS: begin
                if(r_baud_tick) begin
                    r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                    if(r_baud_tick_cnt >= 15) begin
                        r_data[r_bit_cnt] = rx;
                        r_baud_tick_cnt <= 0;
                        if(r_bit_cnt == 7) begin
                            r_state <= S_STOP_BIT;
                        end else begin
                            r_bit_cnt <= r_bit_cnt + 1;
                        end
                    end
                end
            end

            S_STOP_BIT: begin
                if(r_baud_tick) begin
                    r_baud_tick_cnt <= r_baud_tick_cnt + 1;
                    if(r_baud_tick_cnt >= 15) begin
                        r_state <= S_IDLE;
                        data_out <= r_data;
                        rx_done <= 1;
                    end
                end
            end

            default: r_state <= S_IDLE;
            endcase
        end
    end
endmodule

```

![image.png](image.png)

![block diagram](image%201.png)

block diagram

![dht11 FSM](image%202.png)

dht11 FSM

![ds1302 controller](image%203.png)

ds1302 controller

![ds1302 logic 모듈](image%204.png)

ds1302 logic 모듈

![image.png](image%205.png)

![setrtc260310131800-> 26년 3월 10일 13시 18분 00초 시간 보정](image%206.png)

setrtc260310131800-> 26년 3월 10일 13시 18분 00초 시간 보정

![image.png](image%207.png)

![image.png](image%208.png)

<시뮬레이션 결과>

![image.png](image%209.png)

![image.png](image%2010.png)

![image.png](image%2011.png)