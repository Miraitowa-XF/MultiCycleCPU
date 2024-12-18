`timescale 1ns / 1ps

module PC(
    input CLK, Reset, PCWre,
    input [1:0] PCSrc, 
    input signed [15:0] Immediate,   //从指令中取出符号拓展而来
    input [31:0] dataFromRs,
    input [31:0] JumpPC,//跳转地址
    output reg signed [31:0] Address,
    output reg [31:0] nextPC,
    output [31:0] PC_add_4,
    output [3:0] PC4
 );
 always @(*) begin
     if(PCSrc==2'b11)  //j,jal
         nextPC = JumpPC;
     else if(PCSrc==2'b01)  //beq,bne,bltz
         nextPC = Address + 4 + (Immediate << 2);
     else if(PCSrc==2'b10)  //jr
         nextPC = dataFromRs;
     else nextPC = Address+4;
 end
 
 assign PC_add_4 = Address + 4;
 //assign nextPC = (PCSrc[0]) ? Address + 4 + (Immediate << 2) : ((PCSrc[1]) ?  JumpPC : Address + 4);
 assign PC4 = Address[31:28];
 //当clock下降沿到来或Reset下降沿到来时，对地址进行改变或者置零
always @(posedge CLK or negedge Reset) begin     
    if(Reset == 0)
        Address = 0;
    else if(PCWre) begin//PCWre为1时才允许更改地址
        if(PCSrc==2'b11)  //j,jal
            Address <= JumpPC;
        else if(PCSrc==2'b01)  //beq,bne,bltz
            Address <= Address + 4 + (Immediate << 2);
        else if(PCSrc==2'b10)  //jr
            Address <= dataFromRs;
        else Address = Address+4; 
    end
 end
 endmodule


//        if(PCSrc[0])
//            Address = Address + 4 + (Immediate << 2);//跳转
//        else if(PCSrc[1])
//            Address = JumpPC;
//        else
//            Address = Address + 4;//顺序执行下一条指令