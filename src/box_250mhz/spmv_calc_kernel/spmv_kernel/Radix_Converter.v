`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/19 10:15:35
// Design Name: 
// Module Name: Radix_Converter
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


module Radix_Converter(
    clk,
    rstn,
    Ctrl_sig,
    input_valid,
    input_ready,
    input_data,
    
    output_valid,
    output_ready,
    output_data
    );
    input wire clk;
    input wire rstn;
    input wire input_valid;
    output wire input_ready;
    input wire [63:0] input_data;
    input wire [1:0]Ctrl_sig;

    output wire output_valid;
    input wire output_ready;
    output wire [63:0] output_data;


    wire half2single_res_valid;
    wire half2single_res_ready;
    wire [31:0] half2single_res_data;

    wire half2single_in_ready;
    wire single2double_res_valid;
    wire single2double_res_ready;
    wire [63:0] single2double_res_data;

    wire half2single_in_valid;

    // wire half2single_in_valid;

    wire single2double_in_valid;
    wire single2double_in_ready;
    wire [31:0] single2double_in_data;
    // wire [15:0] half2single_in_data;

    assign half2single_in_valid =   (Ctrl_sig==0 & input_valid)|
                                    (Ctrl_sig==1 & 0)|
                                    (Ctrl_sig==2 & 0);

    assign input_ready =    (Ctrl_sig==0 & half2single_in_ready)|
                            (Ctrl_sig==1 & single2double_in_ready)|
                            (Ctrl_sig==2 & output_ready);

    assign output_valid =   (Ctrl_sig==0 & single2double_res_valid)|
                            (Ctrl_sig==1 & single2double_res_valid)|
                            (Ctrl_sig==2 & input_valid);

    assign output_data =(Ctrl_sig==0?  single2double_res_data:0)|
                        (Ctrl_sig==1?  single2double_res_data:0)|
                        (Ctrl_sig==2?  input_data:0);
    
    assign single2double_in_valid = (Ctrl_sig==0 & half2single_res_valid)|
                                    (Ctrl_sig==1 & input_valid)|
                                    (Ctrl_sig==2 & 0);
    assign single2double_in_data = (Ctrl_sig==0 ? half2single_res_data:0)|
                                    (Ctrl_sig==1? input_data[31:0]:0)|
                                    (Ctrl_sig==2 ? 0:0);
    assign half2single_res_ready = (Ctrl_sig==0 & single2double_in_ready)|
                                    (Ctrl_sig==1 & 0)|
                                    (Ctrl_sig==2 & 0);

    assign single2double_res_ready = (Ctrl_sig==0 & output_ready)|
                                    (Ctrl_sig==1 & output_ready)|
                                    (Ctrl_sig==2 & 0);


    half2single half2single (
    .aclk(clk),
    .aresetn(rstn),                                  // input wire aclk
    .s_axis_a_tvalid(half2single_in_valid),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(half2single_in_ready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(input_data[15:0]),              // input wire [15 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(half2single_res_valid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(half2single_res_ready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(half2single_res_data)    // output wire [31 : 0] m_axis_result_tdata
    );

    single2double single2double (
    .aclk(clk),                                  // input wire aclk\
    .aresetn(rstn),
    .s_axis_a_tvalid(single2double_in_valid),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(single2double_in_ready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(single2double_in_data),              // input wire [31 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(single2double_res_valid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(single2double_res_ready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(single2double_res_data)    // output wire [63 : 0] m_axis_result_tdata
    );

endmodule
