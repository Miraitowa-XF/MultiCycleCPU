`timescale 1ns / 1ps

module ChangeState(
    input [5:0] opCode,func,
    input Reset,
    input clk,
    output reg[2:0] new_state
    );
    //设置各个状态的常量
    parameter [2:0] IF = 3'b000,
    ID = 3'b001, EXE1 = 3'b110,
    EXE2 = 3'b101, EXE3 = 3'b010,
    WB1 = 3'b111, WB2 = 3'b100,
    MEM = 3'b011;
    initial begin
        new_state = IF;
    end
    
    //时钟下降沿刷新状态
    always @(negedge clk or negedge Reset) begin
        if ( Reset == 0 ) begin
            new_state = IF;
        end
        else begin
            case (new_state)
                IF: new_state <= ID;
                ID: begin
                    if ( opCode == 6'b000100 || opCode == 6'b000101 || opCode == 6'b000001)//beq,bne,bltz
                        new_state <= EXE2;
                    else if ( opCode == 6'b101011 || opCode == 6'b100011)//sw,lw
                        new_state <= EXE3;
                    else if ( opCode == 6'b000010 || opCode == 6'b000011 || opCode == 6'b000000 && func == 6'b001000 || opCode == 6'b111111)//j,jal,jr,halt
                        new_state <= IF;
                    else 
                        new_state <= EXE1;
                end
                EXE1: new_state <= WB1;
                EXE2: new_state <= IF;
                EXE3: new_state <= MEM;
                WB1: new_state <= IF;
                WB2: new_state <= IF;
                MEM: begin
                    if ( opCode == 6'b101011) //sw
                        new_state <= IF;
                    else 
                        new_state <= WB2;
                end
            endcase
        end
    end 
endmodule
