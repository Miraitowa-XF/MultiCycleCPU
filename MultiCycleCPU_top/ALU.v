`timescale 1ns / 1ps

module ALU(
        input [31:0] ReadData1,
        input [31:0] ReadData2,
        input [31:0] Ext,
        input [4:0] Sa,
        input [2:0] ALUop,
        input ALUSrcA, ALUSrcB,
        output zero, 
        output reg [31:0] Result,
        output sign
    );
    wire [31:0] InA;
    wire [31:0] InB;
    assign InA = ALUSrcA ? {{27{1'b0}}, Sa} : ReadData1;
    assign InB = ALUSrcB ? Ext : ReadData2;
    assign zero = (Result == 0) ? 1 : 0;
    assign sign = ($signed(Result) < 0) ? 1 : 0;   //bltz指令的成真赋值
    always @(ALUop or InA or InB) begin
        case(ALUop) 
            3'b000 : 
                Result = InA + InB;
            3'b001:
                Result = InA - InB;
            3'b010:
                Result = InB << InA;
            3'b011:
                Result = InA | InB;
            3'b100:
                Result = InA & InB;
            3'b101:
                Result = (InA < InB) ? 1 : 0;
            3'b110: 
                Result = (((InA < InB) && (InA[31] == InB[31])) || 
                    ((InA[31] == 1) && (InB[31] == 0))) ? 1 : 0;
            3'b111:
                Result = InA ^ InB;
            default:
                Result = 32'h0000;
        endcase
    end
 endmodule
 