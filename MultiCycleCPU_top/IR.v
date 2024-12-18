`timescale 1ns / 1ps

module IR(
    input clk,
    input IRWre,
    input [31:0] instruction,
    input PC4,
    
    output reg[5:0] OpCode,
    output reg[5:0] func,
    output reg[4:0] rs,rt,rd,
    output reg[15:0] Immediate,
    output reg[4:0] sa,
    output reg[31:0] JumpPC
    );
    
    always @(posedge clk) begin
        if(IRWre==1) begin
            OpCode=instruction[31:26];
            func=(instruction[31:26]==6'b000000)?instruction[5:0]:6'bxxxxxx;
            rs=instruction[25:21];
            rt=instruction[20:16];
            rd=instruction[15:11];
            Immediate=instruction[15:0];
            sa=instruction[10:6];
            JumpPC={{PC4},{instruction[25:0]},{2'b00}};
        end
    end
endmodule
