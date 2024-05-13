`include "system_ifc.vh"
module vector_dot #(
    
) (
    input clk,
    input rstn,

     output [63:0] M_AXIS_OUT_tdata,
     input M_AXIS_OUT_tready,
     output M_AXIS_OUT_tvalid,
    //`DEBUG
    
     input [63:0] S_AXIS_A_tdata,
    //`DEBUG
    
     output S_AXIS_A_tready,
    //`DEBUG
    
     input S_AXIS_A_tvalid,
    //`DEBUG
    
     input [63:0] S_AXIS_B_tdata,
    //`DEBUG
    
     output S_AXIS_B_tready,
    //`DEBUG
    
     input S_AXIS_B_tvalid,
    //`DEBUG
    
     input [31:0] S_AXIS_TIMES_tdata,
    //`DEBUG
    
     output S_AXIS_TIMES_tready,
    //`DEBUG
    
     input S_AXIS_TIMES_tvalid

);
    //`DEBUG
    
    wire [63:0] axis_mul_res_tdata;
    //`DEBUG
    
    wire axis_mul_res_tvalid;
    //`DEBUG
    
    wire axis_mul_res_tready;

    // wire [63:0] axis_acc_tdata;
    // wire axis_acc_tvalid;
    // wire axis_acc_tready;
    wire clr_valid;
    wire clr_ready;
    wire add_valid;
    // wire clr;

    DoubleMul DoubleMul (
    .aclk(clk),
    .aresetn(rstn),                                  // input wire aclk
    .s_axis_a_tvalid(S_AXIS_A_tvalid),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(S_AXIS_A_tready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_AXIS_A_tdata),              // input wire [31 : 0] s_axis_a_tdata
    .s_axis_b_tvalid(S_AXIS_B_tvalid),            // input wire s_axis_b_tvalid
    .s_axis_b_tready(S_AXIS_B_tready),            // output wire s_axis_b_tready
    .s_axis_b_tdata(S_AXIS_B_tdata),              // input wire [31 : 0] s_axis_b_tdata
    .m_axis_result_tvalid(axis_mul_res_tvalid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(axis_mul_res_tready),  // input wire m_axis_result_tready
    // .m_axis_result_tready(1),
    .m_axis_result_tdata(axis_mul_res_tdata)    // output wire [31 : 0] m_axis_result_tdata
    );

    clr_ctrl clr_ctrl(
        .times_valid(S_AXIS_TIMES_tvalid),
        .times_data(S_AXIS_TIMES_tdata),
        .times_ready(S_AXIS_TIMES_tready),
        .vaild_sig(add_valid),
        .clr(clr_valid),
        .clk(clk),
        .rstn(rstn)
    );
    // assign axis_conv_fix_tready = ~clr;
    



    // floating_point_acc floating_point_acc (
    // .aclk(clk),                                  // input wire aclk
    // .s_axis_a_tvalid(axis_mul_res_tvalid),            // input wire s_axis_a_tvalid
    // .s_axis_a_tready(axis_mul_res_tready),            // output wire s_axis_a_tready
    // .s_axis_a_tdata(axis_mul_res_tdata),              // input wire [63 : 0] s_axis_a_tdata
    // .s_axis_a_tlast(s_axis_a_tlast),              // input wire s_axis_a_tlast
    // .m_axis_result_tvalid(M_AXIS_OUT_tvalid),  // output wire m_axis_result_tvalid
    // .m_axis_result_tready(M_AXIS_OUT_tready),  // input wire m_axis_result_tready
    // .m_axis_result_tdata(M_AXIS_OUT_tdata),    // output wire [63 : 0] m_axis_result_tdata
    // .m_axis_result_tlast()    // output wire m_axis_result_tlast
    // );


    
    
    stream #(64) fp64_stream();
    stream #(64) fp64_sum_stream();
    
    // always_comb begin
    assign     fp64_stream.tvalid = axis_mul_res_tvalid;
    
    
    assign     axis_mul_res_tready = fp64_stream.tready & ~clr_valid;
// `ifdef __synthesis__
    assign     fp64_stream.tdata = axis_mul_res_tdata;
// `else
//     assign     fp64_stream.tdata = 64'hbff0000000000000;
// `endif
    // end

    
    // always_comb begin
    assign     fp64_sum_stream.tready = M_AXIS_OUT_tready;
    assign     M_AXIS_OUT_tdata = fp64_sum_stream.tdata;
    assign     M_AXIS_OUT_tvalid = fp64_sum_stream.tvalid;
    // end
   
    
    fixp_acc_top #()fixp_acc_top (
        .clk(clk),
        .rstn(rstn),
        .clr_valid(clr_valid),
        .clr_ready(clr_ready),
        .add_valid(add_valid),
        .fp64_stream(fp64_stream),
        .fp64_sum_stream(fp64_sum_stream)
    );



    // reg clr_ff;
    // always @(posedge clk ) begin
    //     clr_ff<=clr;
    // end


endmodule