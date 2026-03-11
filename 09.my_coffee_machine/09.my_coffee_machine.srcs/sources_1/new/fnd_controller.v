`timescale 1ns / 1ps

module fnd_controller(
    input tick,
    input reset, 
    input [13:0] in_data,
    input seg_en,
    input coffee_make,
    output reg coffee_out,  
    output [7:0] seg,
    output [3:0] an
);
    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    // --- 5초 애니메이션 타이머 ---
    reg [12:0] time_cnt; 
    reg [6:0] frame_cnt; 
    reg [3:0] r_anim_frame;
    
    always @(posedge tick or posedge reset) begin
        if (reset) begin
            time_cnt <= 0; frame_cnt <= 0; r_anim_frame <= 0;
            coffee_out <= 0;
        end else begin
            if (coffee_make) begin // 커피 제조중 일 때 
                if (time_cnt < 13'd5000) begin // 5000ms(5초) 동안 
                    time_cnt <= time_cnt + 1;
                    coffee_out <= 0;
                    
                    if (frame_cnt >= 7'd100) begin //100ms 마다 한칸씩 이동
                        frame_cnt <= 0;
                        r_anim_frame <= (r_anim_frame == 11) ? 0 : r_anim_frame + 1; // 프레임 순환
                    end else begin
                        frame_cnt <= frame_cnt + 1;
                    end
                end else begin
                    coffee_out <= 1; // 5초 도달 후 완료 신호 전송
                end
            end else begin
                time_cnt <= 0; frame_cnt <= 0; // 종료 시 초기화
                coffee_out <= 0; 
            end
        end
    end

    fnd_digit_select u_fnd_digit_select(
        .tick(tick), 
        .reset(reset), 
        .sel(w_sel));
    bin2bcd4digit u_bin2bcd4digit(
        .in_data(in_data), 
        .d1(w_d1), 
        .d10(w_d10), 
        .d100(w_d100), 
        .d1000(w_d1000));

    fnd_digit_display u_fnd_digit_display(
        .digit_sel(w_sel), 
        .d1(w_d1), 
        .d10(w_d10), 
        .d100(w_d100), 
        .d1000(w_d1000),
        .coffee_make(coffee_make), 
        .anim_frame(r_anim_frame), 
        .seg_en(seg_en),
        .an(an), 
        .seg(seg)
    );
endmodule

module fnd_digit_select(
    input tick, reset, 
    output reg [1:0] sel = 0);

    always @(posedge tick or posedge reset) begin
        if (reset) sel <= 0;
        else if (tick) sel <= sel + 1;
    end
endmodule

module bin2bcd4digit(
    input [13:0] in_data,
    output wire [3:0] d1, output wire [3:0] d10, output wire [3:0] d100, output wire [3:0] d1000
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
    input coffee_make, input [3:0] anim_frame, input seg_en,
    output reg [3:0] an, output reg [7:0] seg
);
    reg [3:0] bcd_data;
    always @(*) begin
        an = 4'b1111; seg = 8'b1111_1111; bcd_data = 0;

        if (seg_en) begin
            if (coffee_make) begin
                an = 4'b0000; 
                case(anim_frame) 
            4'd0:  begin an = 4'b0111; seg = 8'b1111_1110; end 
            4'd1:  begin an = 4'b1011; seg = 8'b1111_1110; end 
            4'd2:  begin an = 4'b1101; seg = 8'b1111_1110; end 
            4'd3:  begin an = 4'b1110; seg = 8'b1111_1110; end 
            4'd4:  begin an = 4'b1110; seg = 8'b1111_1101; end
            4'd5:  begin an = 4'b1110; seg = 8'b1111_1011; end 
            4'd6:  begin an = 4'b1110; seg = 8'b1111_0111; end 
            4'd7:  begin an = 4'b1101; seg = 8'b1111_0111; end 
            4'd8:  begin an = 4'b1011; seg = 8'b1111_0111; end 
            4'd9:  begin an = 4'b0111; seg = 8'b1111_0111; end 
            4'd10: begin an = 4'b0111; seg = 8'b1110_1111; end 
            4'd11: begin an = 4'b0111; seg = 8'b1101_1111; end 
            default: begin an = 4'b1111; seg = 8'b1111_1111; end 
        endcase
            end else begin
                case(digit_sel) 
                    2'b00: begin bcd_data = d1; an = 4'b1110; end
                    2'b01: begin bcd_data = d10; an = 4'b1101; end
                    2'b10: begin bcd_data = d100; an = 4'b1011; end
                    2'b11: begin bcd_data = d1000; an = 4'b0111; end
                endcase

                case(bcd_data)
                    4'd0: seg = 8'b11000000; 4'd1: seg = 8'b11111001;
                    4'd2: seg = 8'b10100100; 4'd3: seg = 8'b10110000;
                    4'd4: seg = 8'b10011001; 4'd5: seg = 8'b10010010;
                    4'd6: seg = 8'b10000010; 4'd7: seg = 8'b11111000;
                    4'd8: seg = 8'b10000000; 4'd9: seg = 8'b10010000;
                    default: seg = 8'b11111111;
                endcase
            end
        end
    end
endmodule