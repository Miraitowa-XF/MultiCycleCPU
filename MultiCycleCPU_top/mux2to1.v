`timescale 1ns / 1ps

module mux2to1(
    input [31:0] ALUResult,
    input [31:0] DMOut,
    input DBDataSrc,
    output [31:0] DB
    );
    assign DB = (DBDataSrc == 0)? ALUResult : DMOut;
endmodule
