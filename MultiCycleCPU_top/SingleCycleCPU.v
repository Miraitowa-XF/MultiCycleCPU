`timescale 1ns / 1ps

module multiCycleCPU(
    input CLK, Reset,
    output [4:0] rs, rt,
    output wire [5:0] OpCode,
    output wire [31:0] Out1, Out2, curPC, nextPC, Result, DBData, Instruction
 );
     wire [2:0] ALUOp;
     wire [5:0] func;
     wire [2:0] state;
     wire [31:0] Extout, DMOut;
     wire [15:0] Immediate;
     wire [4:0] rd;
     wire [4:0] sa;
     wire [31:0] JumpPC;
     wire zero, sign, PCWre, ALUSrcA, ALUSrcB, DBDataSrc, RegWre, IRWre, WrRegDSrc;
     wire InsMemRW, RD, WR, ExtSel;
     wire [1:0] RegDst;
     wire [1:0] PCSrc;
     wire [3:0] PC4;
     wire [31:0] PC_add_4,drPC_add_4;
     wire [31:0] drOut1,drOut2;
     wire [31:0] DAddr;
     wire [31:0] DB,drDB;
     
     ChangeState ST(OpCode,func,Reset,CLK,state);
     ControlUnit CU(state,OpCode,func,zero,sign,IRWre,PCWre,ALUSrcA,ALUSrcB,DBDataSrc,WrRegDSrc,InsMemRW,RD,WR,ExtSel,RegDst,PCSrc,ALUOp,RegWre);
     PC pc(CLK,Reset,PCWre,PCSrc,Immediate,Out1,JumpPC,curPC,nextPC,PC_add_4,PC4);
     InstructionMemory IM(curPC,InsMemRW,Instruction);
     IR ir(CLK,IRWre,Instruction,PC4,OpCode,func,rs,rt,rd,Immediate,sa,JumpPC);
     RegisterFile RF(CLK,WrRegDSrc,drPC_add_4,RegDst,RegWre,rs,rt,rd,drDB,Out1,Out2,DBData);
     DR pcadd(CLK,PC_add_4,drPC_add_4);
     DR Adr(CLK,Out1,drOut1);
     DR Bdr(CLK,Out2,drOut2);
     ALU alu(drOut1,drOut2,Extout,sa,ALUOp,ALUSrcA,ALUSrcB,zero,Result,sign);
     DR aluOutDr(CLK,Result,DAddr);
     DataMemory DM(DAddr,drOut2,RD,WR,DMOut);
     mux2to1 db(Result,DMOut,DBDataSrc,DB);
     DR dbdr(CLK,DB,drDB);
     SignZeroExtend SZE(Immediate, ExtSel, Extout);
 endmodule

