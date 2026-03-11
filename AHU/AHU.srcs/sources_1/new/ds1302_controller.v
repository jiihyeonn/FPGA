`timescale 1ns / 1ps

module ds1302_controller(
    input clk,
    input reset,
    output reg ce,
    output reg sclk,
    inout ds1302_data,
    output reg [7:0] o_sec,
    output reg [7:0] o_min
    );

    // I/O 양방향 핀 제어 로직 (DHT11과 동일한 원리)
    reg r_io_dir; // 1: Output(전송), 0: Input(수신)
    reg r_io_out;
    wire w_io_in = ds1302_data;
    assign ds1302_data = (r_io_dir) ? r_io_out : 1'bz;

    // 100MHz -> 1MHz (1us) Tick 생성 (안전하게 1MHz로 동작)
    reg [6:0] tick_cnt;
    reg tick;
    always @(posedge clk, posedge reset) begin
        if(reset) begin
            tick_cnt <= 0;
            tick <= 0;
        end else begin
            if(tick_cnt >= 99) begin // 100번 카운트
                tick_cnt <= 0;
                tick <= 1;
            end else begin
                tick_cnt <= tick_cnt + 1;
                tick <= 0;
            end
        end
    end

    // FSM 상태 정의
    localparam IDLE      = 0;
    localparam CE_HIGH   = 1;
    localparam SEND_CMD  = 2;
    localparam READ_DATA = 3;
    localparam CE_LOW    = 4;

    reg [2:0] state;
    reg [5:0] bit_cnt;   // 비트 인덱스 (0~7)
    reg [7:0] cmd_reg;   // 보낼 명령어 (0x81 초, 0x83 분 등)
    reg [7:0] data_reg;  // 읽어온 데이터 저장용
    reg read_target;     // 0: 초 읽기, 1: 분 읽기
    reg sclk_state;      // 내부 SCLK 상태 토글용

    always @(posedge clk, posedge reset) begin
        if(reset) begin
            state <= IDLE;
            ce <= 0;
            sclk <= 0;
            r_io_dir <= 1;
            r_io_out <= 0;
            o_sec <= 0;
            o_min <= 0;
            bit_cnt <= 0;
            read_target <= 0;
            sclk_state <= 0;
        end 
        else if (tick) begin
            case(state)
                IDLE: begin
                    ce <= 0;
                    sclk <= 0;
                    bit_cnt <= 0;
                    r_io_dir <= 1; // 기본은 출력 모드
                    // 번갈아 가면서 초/분을 읽기 위한 타겟 설정
                    if (read_target == 0) cmd_reg <= 8'h81; // 0x81: Read Seconds 
                    else                  cmd_reg <= 8'h83; // 0x83: Read Minutes 
                    state <= CE_HIGH;
                end

                CE_HIGH: begin
                    ce <= 1; // CE 핀 HIGH 
                    state <= SEND_CMD;
                    sclk_state <= 0;
                end

                // 8비트 명령어 전송 (LSB First)
                SEND_CMD: begin
                    if (sclk_state == 0) begin
                        r_io_out <= cmd_reg[bit_cnt]; // 데이터 먼저 올리고
                        sclk <= 0;
                        sclk_state <= 1;
                    end else begin
                        sclk <= 1; // 클럭 상승 엣지 (이때 DS1302가 데이터 가져감) 
                        sclk_state <= 0;
                        if (bit_cnt == 7) begin
                            bit_cnt <= 0;
                            state <= READ_DATA;
                            r_io_dir <= 0; // I/O를 입력(읽기) 모드로 전환
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                // 8비트 데이터 수신 (LSB First)
                READ_DATA: begin
                    if (sclk_state == 0) begin
                        sclk <= 0; // 클럭 하강 엣지(데이터 내보냄)
                    end else begin
                        data_reg[bit_cnt] <= w_io_in; // 데이터 읽기
                        sclk <= 1;
                        sclk_state <= 0;
                        if (bit_cnt == 7) begin
                            state <= CE_LOW;
                        end else begin
                            bit_cnt <= bit_cnt + 1;
                        end
                    end
                end

                CE_LOW: begin
                    ce <= 0; // 통신 종료 
                    sclk <= 0;
                    // 읽어온 데이터를 목적지에 맞게 저장
                    if (read_target == 0) o_sec <= data_reg;
                    else                  o_min <= data_reg;
                    
                    read_target <= ~read_target; 
                    state <= IDLE;
                end

                default: begin
                    state <= IDLE;
                end
            endcase
        end
    end
endmodule
