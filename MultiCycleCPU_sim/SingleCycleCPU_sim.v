`timescale 1ns / 1ps

module multiCycleCPU_sim();
    //inputs
    reg CLK;
    reg Reset;
    //Outputs
    wire [31:0] curPC,nextPC;
    wire [4:0] rs, rt;
    wire [31:0] Out1, Out2;
    wire [31:0] Result,DBData;
    //instantiate the Unit Under Test
    multiCycleCPU uut(
        .CLK(CLK),
        .rs(rs),
        .rt(rt),
        .Out1(Out1),
        .Out2(Out2),
        .Reset(Reset),
        .DBData(DBData),
        .curPC(curPC),
        .nextPC(nextPC),
        .Result(Result)
    );
    
    initial begin 
        //record 
        $dumpfile("SCCPU.vcd");
        $dumpvars(0, multiCycleCPU_sim);
        //innitial inputs
        CLK = 0;
        Reset = 0;//刚开始设置PC为0
        #50;
        CLK = 1;
        #50;
        Reset = 1;
        //产生时钟信号
        forever #50 begin
            CLK = !CLK;
        end
    end
 endmodule
