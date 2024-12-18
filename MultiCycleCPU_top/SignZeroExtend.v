`timescale 1ns / 1ps

module SignZeroExtend(
    //根据数据通路定义输?和输出
    input wire [15:0] Immediate,
    input ExtSel,
    output wire [31:0] Out
);
 //后16位存储?即数
    assign Out[15:0] = Immediate[15:0];
 //前16位根据?即数进?补1或补0的操作
    assign Out[31:16] = ExtSel == 1 ? {16{Immediate[15]}} : 16'b0;
endmodule
