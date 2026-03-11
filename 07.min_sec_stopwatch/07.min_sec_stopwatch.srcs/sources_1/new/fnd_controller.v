`timescale 1ns / 1ps

module fnd_controller(
    input tick,
    input [13:0] in_data,
    output [3:0] an,
    output [7:0] seg
);
    wire [1:0] w_sel;
    wire [3:0] w_d1, w_d10, w_d100, w_d1000;

    fnd_digit_select u_fnd_digit_select(
        .tick   (tick),
        .sel    (w_sel)
    );

    bin2bdc4digit u_bin2bdc4digit(
        .in_data(in_data),
        .tick   (tick),
        .d1     (w_d1),
        .d10    (w_d10),
        .d100   (w_d100),
        .d1000  (w_d1000)
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
    input tick,
    output reg [1:0] sel = 0    // 00 01 10 11 : 1ms마다 바뀜
);
    always @(posedge tick) begin
        sel <= sel + 1;
    end
endmodule


module bin2bdc4digit(
    input [13:0] in_data,
    input tick,
    output [3:0] d1,
    output [3:0] d10,
    output [3:0] d100,
    output [3:0] d1000
);
    parameter IDLE_SEG = 14'b11111111111111;
    parameter NONE = 4'd15;

    reg [6:0] tick_count;
    reg [3:0] circle_count;

    reg [3:0] circle_d1;
    reg [3:0] circle_d10;
    reg [3:0] circle_d100;
    reg [3:0] circle_d1000;

    always @(posedge tick) begin
        if(tick_count == 99) begin
            tick_count <= 0;
            if(circle_count == 9) begin
                circle_count <= 0;
            end else begin
                circle_count <= circle_count + 1;
            end
        end else begin
            tick_count <= tick_count + 1;
        end
    end

    always @(circle_count) begin
        case(circle_count)
            4'd0: begin
                circle_d1000 <= 4'd10;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= NONE;
            end 
            4'd1: begin
                circle_d1000 <= NONE;
                circle_d100 <= 4'd10;
                circle_d10 <= NONE;
                circle_d1 <= NONE;
            end 
            4'd2: begin
                circle_d1000 <= NONE;
                circle_d100 <= NONE;
                circle_d10 <= 4'd10;
                circle_d1 <= NONE;
            end 
            4'd3: begin
                circle_d1000 <= NONE;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= 4'd10;
            end 
            4'd4: begin
                circle_d1000 <= NONE;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= 4'd11;
            end 
            4'd5: begin
                circle_d1000 <= NONE;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= 4'd12;
            end 
            4'd6: begin
                circle_d1000 <= NONE;
                circle_d100 <= NONE;
                circle_d10 <= 4'd12;
                circle_d1 <= NONE;
            end 
            4'd7: begin
                circle_d1000 <= NONE;
                circle_d100 <= 4'd12;
                circle_d10 <= NONE;
                circle_d1 <= NONE;
            end 
            4'd8: begin
                circle_d1000 <= 4'd12;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= NONE;
            end 
            4'd9: begin
                circle_d1000 <= 4'd13;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= NONE;
            end
            default: begin
                circle_d1000 <= NONE;
                circle_d100 <= NONE;
                circle_d10 <= NONE;
                circle_d1 <= NONE;
            end
        endcase
    end

    assign d1 = (in_data == IDLE_SEG) ? circle_d1 : in_data % 10;
    assign d10 = (in_data == IDLE_SEG) ? circle_d10 : (in_data / 10) % 10;
    assign d100 = (in_data == IDLE_SEG) ? circle_d100 : (in_data / 100) % 10;
    assign d1000 = (in_data == IDLE_SEG) ? circle_d1000 : (in_data / 1000) % 10;
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
    reg dot;

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
            4'd10: seg = 8'b11111110;
            4'd11: seg = 8'b11111001;
            4'd12: seg = 8'b11110111;
            4'd13: seg = 8'b11001111;
            default: seg = 8'b11111111;
        endcase

        if(dot && bcd_data <= 4'd9) begin
            seg[7] = 0;
        end
    end
endmodule