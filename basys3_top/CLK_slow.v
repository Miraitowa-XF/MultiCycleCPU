`timescale 1ns / 1ps

module CLK_slow(
    input clk,
    input reset,
    output reg clk_sys
    );
    parameter limit = 100000; 
    integer counter;
    always @(posedge clk or negedge reset)
        if(!reset)
            counter <= 32'b0;
        else
            begin
                counter <= counter + 1'b1;
                if(counter == limit)
                    begin
                        counter <= 32'b0;
                        clk_sys <= ~clk_sys;
                    end
            end
endmodule