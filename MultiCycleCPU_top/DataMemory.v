`timescale 1ns / 1ps

module DataMemory(
    input wire [31:0] DAddr,  //��ַ����
    input wire [31:0] DataIn, //����Ҫд������   
    input RD,             //Ϊ1ʱ�����ݴ洢���е����ݴ洢���е����ݶ�����Ϊ0���������̬��
    input WR,              //Ϊ1ʱ����������ݶ������ݴ洢���У�Ϊ0���޲�����
    output reg [31:0] DataOut
 );
 reg [7:0] Memory [0:127];//�洢��
wire [31:0] address;
 //��Ϊһ��ָ�����ĸ��洢��Ԫ�洢����Ҫ����4
 assign address = (DAddr << 2);
 //����
 always @(RD) begin
      if(RD==1) begin
          DataOut[7:0] = RD ? Memory[address + 3] : 8'bz;//zΪ����̬
          DataOut[15:8] = RD ? Memory[address + 2] : 8'bz;
          DataOut[23:16] = RD ? Memory[address + 1] : 8'bz;
          DataOut[31:24] = RD ? Memory[address] : 8'bz;
      end
  end
  
 //д��
 always @ (WR or DAddr or DataIn) begin
     if(WR==1) begin
         Memory[address] <= DataIn[31:24];
         Memory[address + 1] <= DataIn[23:16];
         Memory[address + 2] <= DataIn[15:8];
         Memory[address + 3] <= DataIn[7:0];
     end
  end
endmodule
