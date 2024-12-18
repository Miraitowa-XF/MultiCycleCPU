`timescale 1ns / 1ps

module basys3(
    input clk,      //时钟信号
    input [1:0] SW, //选择输出信号
    input Reset, //重置按钮
    input Button, //运行按钮
    output [3:0] AN, //数码管选择信号
    output [7:0] Out //数码管输入信号
    );
    
    wire [31:0] curPC;     //当前的PC
    wire [31:0] DBData;    //DB总线
    wire [31:0] Instruction; //当前地址的指令
    wire [4:0] regRs;     //寄存器组rs寄存器的地址
    wire [4:0] regRt;    //寄存器组rt寄存器的地址
    wire [5:0] Opcode;    //指令的OP码
    wire [31:0] Out1, Out2; //Out1为rs寄存器中的值；Out2为rt寄存器中的值
    wire [31:0] Result;   //ALU运算后得到的结果
    wire myCLK;          //消抖后的信号
    wire clk_sys;        //分频后的信号
    wire [3:0] store;    //记录当前要显示位的值
    wire [31:0] nextPC;  //下一条PC
    
    multiCycleCPU my_mulCPU(myCLK, Reset, regRs, regRt, Opcode, Out1, Out2, curPC, nextPC, Result, DBData, Instruction);  //CPU 
    CLK_slow cd(clk,Reset,clk_sys);   //分频
    Keyboard_CLK my_key(clk_sys, Reset, Button, myCLK);  //消抖
    counter my_ct(clk, Reset, AN);    //计数
    Display_7SegLED led(store, Out);  //显示
    change my_cg(myCLK, Reset, AN, SW, Result, curPC, nextPC, DBData, Out1, Out2, Instruction, store);    //取值
endmodule
