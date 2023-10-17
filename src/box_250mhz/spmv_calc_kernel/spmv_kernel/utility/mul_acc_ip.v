// `timescale 1 ps / 1 ps

module mul_acc_ip
   (
    M_AXIS_RESULT_0_tdata,
    M_AXIS_RESULT_0_tlast,
    M_AXIS_RESULT_0_tvalid,
    S_AXIS_A_0_tdata,
    S_AXIS_A_0_tready,
    S_AXIS_A_0_tvalid,
    S_AXIS_B_0_tdata,
    S_AXIS_B_0_tready,
    S_AXIS_B_0_tvalid,
    aclk_0,
    aresetn_0);


    output wire [31:0] M_AXIS_RESULT_0_tdata;
    output wire M_AXIS_RESULT_0_tlast;
    output wire M_AXIS_RESULT_0_tvalid;
    output wire S_AXIS_A_0_tready;
    input wire S_AXIS_A_0_tvalid;

    input wire [31:0] S_AXIS_A_0_tdata;

    output wire S_AXIS_B_0_tready;
    input wire S_AXIS_B_0_tvalid;
    
    input wire [31:0] S_AXIS_B_0_tdata;


    input wire aclk_0;
    input wire aresetn_0;

    wire [31:0]S_AXIS_A_0_1_TDATA;
    wire S_AXIS_A_0_1_TREADY;
    wire S_AXIS_A_0_1_TVALID;
    wire [31:0]S_AXIS_B_0_1_TDATA;
    wire S_AXIS_B_0_1_TREADY;
    wire S_AXIS_B_0_1_TVALID;
    wire aclk_0_1;
    wire aresetn_0_1;
    wire [31:0]floating_point_0_M_AXIS_RESULT_TDATA;
    wire floating_point_0_M_AXIS_RESULT_TREADY;
    wire floating_point_0_M_AXIS_RESULT_TVALID;
    wire [31:0]floating_point_1_M_AXIS_RESULT_TDATA;
    wire floating_point_1_M_AXIS_RESULT_TLAST;
    wire floating_point_1_M_AXIS_RESULT_TVALID;

    
    assign M_AXIS_RESULT_0_tdata[31:0] = floating_point_1_M_AXIS_RESULT_TDATA;
    assign M_AXIS_RESULT_0_tlast = floating_point_1_M_AXIS_RESULT_TLAST;
    assign M_AXIS_RESULT_0_tvalid = floating_point_1_M_AXIS_RESULT_TVALID;
    assign S_AXIS_A_0_1_TDATA = S_AXIS_A_0_tdata[31:0];
    assign S_AXIS_A_0_1_TVALID = S_AXIS_A_0_tvalid;
    assign S_AXIS_A_0_tready = S_AXIS_A_0_1_TREADY;
    assign S_AXIS_B_0_1_TDATA = S_AXIS_B_0_tdata[31:0];
    assign S_AXIS_B_0_1_TVALID = S_AXIS_B_0_tvalid;
    assign S_AXIS_B_0_tready = S_AXIS_B_0_1_TREADY;
    assign aclk_0_1 = aclk_0;
    assign aresetn_0_1 = aresetn_0;


    floating_point_0 floating_point_0
        (.aclk(aclk_0_1),
            .m_axis_result_tdata(floating_point_0_M_AXIS_RESULT_TDATA),
            .m_axis_result_tready(floating_point_0_M_AXIS_RESULT_TREADY),
            .m_axis_result_tvalid(floating_point_0_M_AXIS_RESULT_TVALID),
            .s_axis_a_tdata(S_AXIS_A_0_1_TDATA),
            .s_axis_a_tready(S_AXIS_A_0_1_TREADY),
            .s_axis_a_tvalid(S_AXIS_A_0_1_TVALID),
            .s_axis_b_tdata(S_AXIS_B_0_1_TDATA),
            .s_axis_b_tready(S_AXIS_B_0_1_TREADY),
            .s_axis_b_tvalid(S_AXIS_B_0_1_TVALID));
    floating_point_1 floating_point_1
        (.aclk(aclk_0_1),
            .aresetn(aresetn_0_1),
            .m_axis_result_tdata(floating_point_1_M_AXIS_RESULT_TDATA),
            .m_axis_result_tlast(floating_point_1_M_AXIS_RESULT_TLAST),
            .m_axis_result_tvalid(floating_point_1_M_AXIS_RESULT_TVALID),
            .s_axis_a_tdata(floating_point_0_M_AXIS_RESULT_TDATA),
            .s_axis_a_tlast(1'b0),
            .s_axis_a_tready(floating_point_0_M_AXIS_RESULT_TREADY),
            .s_axis_a_tvalid(floating_point_0_M_AXIS_RESULT_TVALID));
endmodule