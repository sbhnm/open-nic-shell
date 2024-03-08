`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/31 18:12:00
// Design Name: 
// Module Name: sim_Multi_Kernel
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


module sim_lru #(
    parameter int CONF_NUM_KERNEL = 32'h1
)(
    
    );
    reg rstn;
    reg clk =0;
    reg [31:0] clkcnt=0;
    always #1 clk = ~clk;
    always @(posedge clk) begin
        clkcnt<=clkcnt+1;
    end

    initial begin
        rstn <=1;
        #200
        rstn <=0;

        #200
        rstn <=1;
      
    end



    lru_way lru_way(
        .clk(clk),
        .rstn(rstn)
    );
endmodule