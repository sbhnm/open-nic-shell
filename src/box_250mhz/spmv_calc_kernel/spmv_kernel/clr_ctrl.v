`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/12 20:39:21
// Design Name: 
// Module Name: clr_ctrl
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


module clr_ctrl(
    times_valid,
    times_data,
    times_ready,
    vaild_sig,
    disable_all,
    clr,
    clk,
    rstn
    
    );
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_TIMES TVALID" *)
    input wire times_valid;
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_TIMES TDATA" *)
    input wire [31:0] times_data;
    (* X_INTERFACE_INFO = "xilinx.com:interface:axis:1.0 S_AXIS_TIMES TREADY" *)
    output wire times_ready;
    input wire vaild_sig;
    output wire clr;
    input wire clk;
    input wire rstn;
    (*mark_debug = "true"*)
    output wire disable_all;
    

    assign disable_all = nowtime[32] == 1;
    (*mark_debug = "true"*)
    reg [32:0] nowtime = 0;
    assign     times_ready = nowtime==0 | nowtime[32] == 1;
    assign     clr = (nowtime ==0  &rstn);
    always @(posedge clk) begin
        if(~rstn) begin
            nowtime<=33'h1ffffffff;
        end
        else begin
            if(times_valid&vaild_sig)begin
                nowtime<={1'b0,times_data}-1;
            end
            else if(vaild_sig)begin
                nowtime <= nowtime-1;
            end
            else if(times_valid)begin
                nowtime<=times_data;
            end
            else begin
                nowtime<=nowtime;
            end
        end
    end
endmodule
