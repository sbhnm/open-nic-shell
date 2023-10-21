module vector_dot #(
    
) (
    input clk,
    input rstn,

    output [255:0] M_AXIS_OUT_tdata,
    input M_AXIS_OUT_tready,
    output M_AXIS_OUT_tvalid,

    input [63:0] S_AXIS_A_tdata,
    output S_AXIS_A_tready,
    input S_AXIS_A_tvalid,
    
    input [63:0] S_AXIS_B_tdata,
    output S_AXIS_B_tready,
    input S_AXIS_B_tvalid,
    
    input [31:0] S_AXIS_TIMES_tdata,
    output S_AXIS_TIMES_tready,
    input S_AXIS_TIMES_tvalid

);
    wire [63:0] axis_mul_res_tdata;
    wire axis_mul_res_tvalid;
    wire axis_mul_res_tready;

    wire [255:0] axis_conv_fix_tdata;
    wire axis_conv_fix_tvalid;
    wire axis_conv_fix_tready;

    wire [63:0] axis_acc_tdata;
    wire axis_acc_tvalid;
    wire axis_acc_tready;
    wire clr;

    DoubleMul DoubleMul (
    .aclk(clk),                                  // input wire aclk
    .s_axis_a_tvalid(S_AXIS_A_tvalid),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(S_AXIS_A_tready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(S_AXIS_A_tdata),              // input wire [31 : 0] s_axis_a_tdata
    .s_axis_b_tvalid(S_AXIS_B_tvalid),            // input wire s_axis_b_tvalid
    .s_axis_b_tready(S_AXIS_B_tready),            // output wire s_axis_b_tready
    .s_axis_b_tdata(S_AXIS_B_tdata),              // input wire [31 : 0] s_axis_b_tdata
    .m_axis_result_tvalid(axis_mul_res_tvalid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(axis_mul_res_tready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(axis_mul_res_tdata)    // output wire [31 : 0] m_axis_result_tdata
    );
    Double2Fix Double2Fix (
    .aclk(clk),                                  // input wire aclk
    .s_axis_a_tvalid(axis_mul_res_tvalid),            // input wire s_axis_a_tvalid
    .s_axis_a_tready(axis_mul_res_tready),            // output wire s_axis_a_tready
    .s_axis_a_tdata(axis_mul_res_tdata),              // input wire [63 : 0] s_axis_a_tdata
    .m_axis_result_tvalid(axis_conv_fix_tvalid),  // output wire m_axis_result_tvalid
    .m_axis_result_tready(axis_conv_fix_tready),  // input wire m_axis_result_tready
    .m_axis_result_tdata(axis_conv_fix_tdata)    // output wire [63 : 0] m_axis_result_tdata
    );
    clr_ctrl clr_ctrl(
        .times_valid(S_AXIS_TIMES_tvalid),
        .times_data(S_AXIS_TIMES_tdata),
        .times_ready(S_AXIS_TIMES_tready),
        .vaild_sig(axis_conv_fix_tvalid & axis_conv_fix_tready),
        .disable_all(),
        .clr(clr),
        .clk(clk),
        .rstn(rstn)
    );
    assign axis_conv_fix_tready = ~clr;
    
    Accumlator Accumlator (
    // .B(axis_conv_fix_tdata),        // input wire [63 : 0] B
    .B(1),
    .CLK(clk),    // input wire CLK
    .CE(axis_conv_fix_tvalid & axis_conv_fix_tready),      // input wire CE
    .SCLR(clr),  // input wire SCLR
    .Q(axis_acc_tdata)        // output wire [255 : 0] Q
    );
    assign axis_acc_tvalid = clr;
    // assign axis_acc_tdata
    fix_data_fifo fix_data_fifo (
    .s_axis_aresetn(rstn),  // input wire s_axis_aresetn
    .s_axis_aclk(clk),        // input wire s_axis_aclk
    .s_axis_tvalid(axis_acc_tvalid),    // input wire s_axis_tvalid
    .s_axis_tready(axis_acc_tready),    // output wire s_axis_tready
    .s_axis_tdata(axis_acc_tdata),      // input wire [63 : 0] s_axis_tdata
    .m_axis_tvalid(M_AXIS_OUT_tvalid),    // output wire m_axis_tvalid
    .m_axis_tready(M_AXIS_OUT_tready),    // input wire m_axis_tready
    .m_axis_tdata(M_AXIS_OUT_tdata)      // output wire [63 : 0] m_axis_tdata
    );

endmodule