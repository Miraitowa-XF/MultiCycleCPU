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
    reg [4:0] writeReg; // Ҫд�ļĴ����˿�
    always @(*) begin
        case (RegDst)
            2'b01: writeReg = rt;
            2'b10: writeReg = rd;
            2'b00: writeReg = 5'b11111; // jal ָ��д�� $31
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

    // ALUM2Reg Ϊ 0 ʱ��ʹ������ ALU �������Ϊ 1 ʱ��ʹ���������ݴ洢����DM�������
    assign writeData = WrRegDSrc ? drDB : PC_add_4;

    // ��ʼ���Ĵ���
    reg [31:0] register[0:31];
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1) 
            register[i] = 32'b0; // ʹ��������ֵ��ʼ��
    end

    // �������Ĵ����仯���仯
    always @(*) begin
        Data1 = register[rs];
        Data2 = register[rt];
    end
    
    always @(CLK) begin
        if (CLK==0 && RegWre && (writeReg != 5'b00000)&&(writeReg!=5'b11111)) // ����д��Ĵ��� 0
                register[writeReg] <= writeData;                        //$31��д��������������
        else if(CLK==1 && RegWre && WrRegDSrc==0 && (writeReg != 5'b00000))  //jalָ��ʱ��PC_add_4д��$31�Ĵ���
                register[writeReg] <= writeData;
    end
    
    
    
//    // ��ʱ���½���д��Ĵ���
//    always @(negedge CLK) begin
//        if (RegWre && (writeReg != 5'b00000)&&(writeReg!=5'b11111)) // ����д��Ĵ��� 0
//            register[writeReg] <= writeData;                        //$31��д��������������
//    end
    
//    //jalָ��ʱ��PC_add_4д��$31�Ĵ���
//    always @(posedge CLK)begin
//            if(RegWre && WrRegDSrc==0 && (writeReg != 5'b00000))
//                register[writeReg] <= writeData;
//    end    
endmodule

