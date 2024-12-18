`timescale 1ns / 1ps

module DataMemory(
    input wire [31:0] DAddr,  //地址输入
    input wire [31:0] DataIn, //输入要写的数据   
    input RD,             //为1时把数据存储器中的数据存储器中的数据读出；为0，输出高阻态。
    input WR,              //为1时把输入的数据读到数据存储器中；为0，无操作。
    output reg [31:0] DataOut
 );
 reg [7:0] Memory [0:127];//存储器
wire [31:0] address;
 //因为一条指令由四个存储单元存储所以要乘以4
 assign address = (DAddr << 2);
 //读出
 always @(RD) begin
      if(RD==1) begin
          DataOut[7:0] = RD ? Memory[address + 3] : 8'bz;//z为高阻态
          DataOut[15:8] = RD ? Memory[address + 2] : 8'bz;
          DataOut[23:16] = RD ? Memory[address + 1] : 8'bz;
          DataOut[31:24] = RD ? Memory[address] : 8'bz;
      end
  end
  
 //写入
 always @ (WR or DAddr or DataIn) begin
     if(WR==1) begin
         Memory[address] <= DataIn[31:24];
         Memory[address + 1] <= DataIn[23:16];
         Memory[address + 2] <= DataIn[15:8];
         Memory[address + 3] <= DataIn[7:0];
     end
  end
endmodule
