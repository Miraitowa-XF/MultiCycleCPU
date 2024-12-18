`timescale 1ns / 1ps

module RegisterFile(
    input CLK, WrRegDSrc,
    input [31:0] PC_add_4,
    input [1:0] RegDst,
    input RegWre,
    input [4:0] rs, rt, rd,
    input [31:0] drDB,
    output reg [31:0] Data1, Data2,
    output [31:0] writeData
);
    reg [4:0] writeReg; // 要写的寄存器端口
    always @(*) begin
        case (RegDst)
            2'b01: writeReg = rt;
            2'b10: writeReg = rd;
            2'b00: writeReg = 5'b11111; // jal 指令写入 $31
            default: writeReg = 5'b00000;
        endcase
    end
//    always @(*)begin
//        if(RegDst==2'b01)
//            writeReg=rt;
//        else if(RegDst==2'b10)
//            writeReg=rd;
//        else if(RegDst==2'b00)
//            writeReg=5'b11111;
//    end
    //assign writeReg = RegDst ? rd : rt;

    // ALUM2Reg 为 0 时，使用来自 ALU 的输出；为 1 时，使用来自数据存储器（DM）的输出
    assign writeData = WrRegDSrc ? drDB : PC_add_4;

    // 初始化寄存器
    reg [31:0] register[0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) 
            register[i] = 32'b0; // 使用阻塞赋值初始化
    end

    // 输出：随寄存器变化而变化
    always @(*) begin
        Data1 = register[rs];
        Data2 = register[rt];
    end
    
    always @(CLK) begin
        if (CLK==0 && RegWre && (writeReg != 5'b00000)&&(writeReg!=5'b11111)) // 避免写入寄存器 0
                register[writeReg] <= writeData;                        //$31的写入由下面代码完成
        else if(CLK==1 && RegWre && WrRegDSrc==0 && (writeReg != 5'b00000))  //jal指令时把PC_add_4写入$31寄存器
                register[writeReg] <= writeData;
    end
    
    
    
//    // 在时钟下降沿写入寄存器
//    always @(negedge CLK) begin
//        if (RegWre && (writeReg != 5'b00000)&&(writeReg!=5'b11111)) // 避免写入寄存器 0
//            register[writeReg] <= writeData;                        //$31的写入由下面代码完成
//    end
    
//    //jal指令时把PC_add_4写入$31寄存器
//    always @(posedge CLK)begin
//            if(RegWre && WrRegDSrc==0 && (writeReg != 5'b00000))
//                register[writeReg] <= writeData;
//    end    
endmodule

