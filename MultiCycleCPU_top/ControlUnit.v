`timescale 1ns / 1ps
module ControlUnit(
    //根据数据通路图定义输入和输出
    input [2:0] state,
    input [5:0] OpCode,
    input [5:0] func,
    input zero,
    input sign,
    
    output reg IRWre,   //IR指令寄存器的写使能信号，0：不更改；1：接受来自指令寄存器的指令
    output reg PCWre,
    output reg ALUSrcA, 
    output reg ALUSrcB,
    output reg DBDataSrc,  //0：数据来自ALU运算结果； 1：来自DMOut
    output reg WrRegDSrc, //0：写入寄存器的值来自PC+4； 1：来自ALU结果或者DMOut
    output reg InsMemRW,
    output reg RD,
    output reg WR,
    output reg ExtSel,   //0：零扩展； 1：符号扩展
    output reg [1:0] RegDst, //要写的寄存器的地址
    output reg [1:0] PCSrc,  //决定下一条PC如何改变
    output reg [2:0] ALUOp,   //决定运算功能
    output reg RegWre
);
    //设置常量
    parameter [2:0] IF = 3'b000,
    ID = 3'b001, EXE1 = 3'b110,
    EXE2 = 3'b101, EXE3 = 3'b010,
    WB1 = 3'b111, WB2 = 3'b100,
    MEM = 3'b011;    
    
    //每次状态改变时，信号发生改变
    always @(state) begin
        DBDataSrc = (OpCode == 6'b100011) ? 1 : 0; //lw
        WrRegDSrc = (OpCode == 6'b000011) ? 0 : 1; //jal
        ExtSel=(OpCode==6'b001100||OpCode==6'b001110||OpCode==6'b001101)?0:1; //andi,xori,ori
        PCSrc[1]=((OpCode==6'b000000&&func==6'b001000)||OpCode==6'b000010||OpCode==6'b000011)?1:0; //jr,j,jal
        PCSrc[0]=((OpCode==6'b000100&&zero==1)||(OpCode==6'b000101&&zero==0)||(OpCode==6'b000001&&sign==1)||OpCode==6'b000010||OpCode==6'b000011)?1:0; //beq(zero=1)、bne(zero=0)、bltz(sign=1)、j、jal
        RegDst[1]=((OpCode==6'b000000&&func==6'b100000)||(OpCode==6'b000000&&func==6'b100010)||(OpCode==6'b000000&&func==6'b100100)||(OpCode==6'b000000&&func==6'b101010)||(OpCode==6'b000000&&func==6'b000000))?1:0; //add,sub,and,slt,sll
        RegDst[0]=((OpCode==6'b000000&&func==6'b100000)||(OpCode==6'b000000&&func==6'b100010)||(OpCode==6'b000000&&func==6'b100100)||(OpCode==6'b000000&&func==6'b101010)||(OpCode==6'b000000&&func==6'b000000)||OpCode==6'b000011)?0:1; //add,sub,and,slt,sll,jal
        
        //EXE
        if(state==EXE1||state==EXE2||state==EXE3)begin
            ALUSrcA=(OpCode==6'b000000&&func==6'b000000)?1:0; //sll
            ALUSrcB=(OpCode==6'b001001||OpCode==6'b001100||OpCode==6'b001101||OpCode==6'b001110||OpCode==6'b001010||OpCode==6'b101011||OpCode==6'b100011)?1:0;  //addiu,andi,ori,xori,slti,sw,lw
            ALUOp[2]=(OpCode==6'b001100||(OpCode==6'b000000&&func==6'b100100)||OpCode==6'b001010||OpCode==6'b001110||(OpCode==6'b000000&&func==6'b101010))?1:0;
            ALUOp[1]=(OpCode == 6'b001101 || OpCode == 6'b001010 || (OpCode == 6'b000000 && func == 6'b100101) || (OpCode == 6'b000000 && func == 6'b000000)||OpCode==6'b001110||(OpCode==6'b000000&&func==6'b101010)) ? 1 : 0;
            ALUOp[0]=((OpCode == 6'b000000 && func == 6'b100010) || OpCode == 6'b001101 || (OpCode == 6'b000000 && func == 6'b100101) || OpCode == 6'b000001 || OpCode == 6'b000101 || OpCode == 6'b000100 ||OpCode==6'b001110 ) ? 1 : 0;
        end
        
        //TF
        if(state==IF)begin
            if(OpCode!=6'b111111)
                PCWre=1;
            else PCWre=0;
        end
        else begin
            PCWre=0;
        end
        
        //ID
        InsMemRW=1;
        if(state==ID)
            IRWre=1;
        else IRWre=0;
        
        //MEM
        if(state==MEM)begin
            RD=(OpCode==6'b100011)?1:0;  //lw
            WR=(OpCode==6'b101011)?1:0;  //sw
        end
        else begin
            RD=0;
            WR=0;
        end
        
        //WB
        if(state==WB1||state==WB2)
            RegWre=(OpCode==6'b000100||OpCode==6'b000101||OpCode==6'b000001||OpCode==6'b000010||OpCode==6'b101011||(OpCode==6'b000000&&func==6'b001000)||OpCode==6'b111111)?0:1; //beq,bne,bltz,j,sw,jr,halt
        else if (OpCode==6'b000011 && state==IF)   //允许jal指令在ID阶段写寄存器，而我的state是在时钟下降沿才改变，所以为了防止$31写入错误，所以在它的下一个stats（IF状态）才让RegWre改变（这里我判断状态为IF才更改信号，是我经过不断调试改出来的，可能更好的实现能让它更加规范的实现）
            RegWre=1;
        else RegWre=0; 
            
    end
    
endmodule

//单周期CPU控制信号的确定参考：
    //根据opcode和func定义控制信号为1或0
//    assign PCWre = (OpCode == 6'b111111) ? 0 : 1;
//    assign ALUSrcA = (OpCode == 6'b000000 && func == 6'b000000) ? 1 : 0;
//    assign ALUSrcB = (OpCode == 6'b001001 || OpCode == 6'b001100 || OpCode == 6'b001101 || OpCode == 6'b001010 || OpCode == 6'b101011 || OpCode == 6'b100011) ? 1 : 0;
//    assign DBDataSrc = (OpCode == 6'b100011) ? 1 : 0;
//    assign RegWre = (OpCode == 6'b101011 || OpCode == 6'b000100 || OpCode == 6'b000101 || OpCode == 6'b000110 ||OpCode == 6'b000010) ? 0 : 1;
//    assign InsMemRW = 1;
//    assign RD = (OpCode == 6'b100011) ? 1 : 0;
//    assign WR = (OpCode == 6'b101011) ? 1 : 0;
//    assign ExtSel = (OpCode == 6'b001100 || OpCode == 6'b001101) ? 0 : 1;
//    assign RegDst = (OpCode == 6'b001001 || OpCode == 6'b001100 || OpCode == 6'b001101 || OpCode == 6'b001010 || OpCode == 6'b100011) ? 0 : 1;
//    assign PCSrc[0] = ((OpCode == 6'b000100 && zero == 1) || (OpCode == 6'b000101 && zero == 0) || (OpCode == 6'b000110 && sign == 1)) ? 1 : 0;
//    assign PCSrc[1] = (OpCode == 6'b000010) ? 1 : 0;
//    assign ALUOp[2] = (OpCode == 6'b001100 || (OpCode == 6'b000000 && func == 6'b100100) || OpCode == 6'b001010) ? 1 : 0;
//    assign ALUOp[1] = (OpCode == 6'b001101 || OpCode == 6'b001010 || (OpCode == 6'b000000 && func == 6'b100101) || (OpCode == 6'b000000 && func == 6'b000000)) ? 1 : 0;
//    assign ALUOp[0] = ((OpCode == 6'b000000 && func == 6'b100010) || OpCode == 6'b001101 || (OpCode == 6'b000000 && func == 6'b100101) || OpCode == 6'b000100 || OpCode == 6'b000101 || OpCode == 6'b000110 ) ? 1 : 0;
