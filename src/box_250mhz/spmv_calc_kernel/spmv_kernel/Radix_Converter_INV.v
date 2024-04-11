
module Radix_Converter_INV(
    clk,
    rstn,
    Ctrl_sig,
    input_valid,
    input_ready,
    input_data,
    
    output_double_valid,
    output_double_ready,
    output_double_data,

    output_single_valid,
    output_single_ready,
    output_single_data,

    output_half_valid,
    output_half_ready,
    output_half_data

    );
    input wire clk;
    input wire rstn;
    input wire [1:0]Ctrl_sig;
    input wire input_valid;
    output wire input_ready;
    input wire [63:0] input_data;
    
    output wire output_double_valid;
    input wire output_double_ready;
    output wire [63:0] output_double_data;

    output wire output_single_valid;
    input wire output_single_ready;
    output wire [31:0] output_single_data;

    output wire output_half_valid;
    input wire output_half_ready;
    output wire [15:0] output_half_data;


    wire Fix2Double_res_ready;

    wire Double2Single_res_ready;

    wire Single2Half_res_ready;

    wire Double2Single_in_ready;
    
    assign Fix2Double_res_ready =   (Ctrl_sig==2 & output_double_ready)|
                                    (Ctrl_sig==1 & Double2Single_in_ready)|
                                    (Ctrl_sig==0 & Double2Single_in_ready);

    assign Double2Single_res_ready =(Ctrl_sig==2 & 0)|
                                    (Ctrl_sig==1 & output_single_ready)|
                                    (Ctrl_sig==0 & Single2Half_in_ready);

    assign Single2Half_res_ready =  (Ctrl_sig==2 & 0)|
                                    (Ctrl_sig==1 & 0)|
                                    (Ctrl_sig==0 & output_half_ready);

    
    // Fix2Double Fix2Double (
    // .aclk(clk),                                  // input wire aclk
    // .s_axis_a_tvalid(input_valid),            // input wire s_axis_a_tvalid
    // .s_axis_a_tready(input_ready),            // output wire s_axis_a_tready
    // .s_axis_a_tdata(input_data),              // input wire [63 : 0] s_axis_a_tdata
    // .m_axis_result_tvalid(output_double_valid),  // output wire m_axis_result_tvalid
    // .m_axis_result_tready(Fix2Double_res_ready),  // input wire m_axis_result_tready
    // .m_axis_result_tdata(output_double_data)    // output wire [63 : 0] m_axis_result_tdata
    // );
    assign output_double_valid = input_valid;
    assign input_ready = Fix2Double_res_ready;
    assign output_double_data = input_data;
    
    Double2Single Double2Single (
    .aclk(clk),                                  // input wire aclk
    .s_axis_a_tvalid(output_double_valid&(Ctrl_sig==0|Ctrl_sig==1)),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(Double2Single_in_ready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(output_double_data),              // input wire [63 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(output_single_valid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(Double2Single_res_ready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(output_single_data)    // output wire [31 : 0] m_axis_result_tdata
    );

    Single2Half Single2Half (
    .aclk(clk),                                  // input wire aclk
    .s_axis_a_tvalid(output_single_valid&(Ctrl_sig==0)),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(Single2Half_in_ready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(output_single_data),              // input wire [63 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(output_half_valid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(Single2Half_res_ready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(output_half_data)    // output wire [31 : 0] m_axis_result_tdata
    );

endmodule