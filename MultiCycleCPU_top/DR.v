`timescale 1ns / 1ps

module DR(
    input clk,
    input [31:0] in,
    output reg [31:0] out
    );
    //ʱ��������ʱ�������ͳ�
    always @(posedge clk) begin
        out = in;
    end
endmodule
