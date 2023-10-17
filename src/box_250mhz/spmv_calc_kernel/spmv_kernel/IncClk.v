`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2022/12/20 15:59:02
// Design Name: 
// Module Name: IncClk
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module IncClk(
    input clk,
    input [31:0] factor,
    output clk_o
    );
    
    
    reg [31:0]inc;
    
    reg clk_r;
    
    assign clk_o = clk_r;
    
    initial begin
        inc = 0;
        clk_r = 0;
    end
    
    always@(posedge clk)begin 
        if(inc > factor)begin
            inc <= 0;
            clk_r <= ~clk_r;        
        end
        else begin 
            inc <= inc+1;
        end
    end
endmodule
