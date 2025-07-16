`timescale 1ns / 1ps

module timer_peripheral(
    input wire        rst,
    input wire        clk,
    input wire [31:0] addr,
    input wire        we,
    input wire [31:0] wdata,
    output reg [31:0] rdata
);

    // 内部寄存器
    reg [31:0] timer_counter;    // 主计时器计数器
    reg [31:0] div_counter;      // 分频计数器
    reg [31:0] div_factor;       // 分频系数寄存器
    
    // 分频信号
    wire div_tick;
    assign div_tick = (div_factor != 32'd0) && (div_counter >= div_factor - 1);
    
    // 分频计数器逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div_counter <= 32'd0;
        end else if (div_tick) begin
            div_counter <= 32'd0;
        end else begin
            div_counter <= div_counter + 32'd1;
        end
    end
    
    // 主计时器逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            timer_counter <= 32'd0;
        end else if (div_tick) begin
            timer_counter <= timer_counter + 32'd1;
        end
    end
    
    // 分频系数寄存器写入逻辑
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            div_factor <= 32'd50000000; // 默认分频系数，1秒@50MHz
        end else if (we && addr == 32'hFFFF_F024) begin
            div_factor <= wdata;
        end
    end
    
    // 读数据逻辑
    always @(*) begin
        case (addr)
            32'hFFFF_F020: rdata = timer_counter;  // 读取计时器值
            32'hFFFF_F024: rdata = div_factor;     // 读取分频系数
            default:       rdata = 32'h0000_0000;
        endcase
    end

endmodule
