// localparam DATA_WIDTH = 32;

module add_fp32#(
parameter integer DATA_WIDTH	= 32
)(
    a,
    b,
    input_vaild,
    input_ready,
    output_vaild,
    output_ready,
    c,
    clk
);

    input wire[DATA_WIDTH-1:0] a;
    
    input wire[DATA_WIDTH-1:0] b;
    input wire  input_vaild;
    output wire input_ready;

    output wire output_vaild;
    input wire  output_ready;

    output wire[DATA_WIDTH-1:0] c;

    input wire clk;
    
    wire a_ready;
    wire b_ready;
    assign input_ready = a_ready & b_ready;
    
    floating_point_0 add_inst(
  .aclk(clk),
  .s_axis_a_tvalid(input_vaild),
  .s_axis_a_tready(a_ready),
  .s_axis_a_tdata(a),
  .s_axis_b_tvalid(input_vaild),
  .s_axis_b_tready(b_ready),
  .s_axis_b_tdata(b),
  .m_axis_result_tvalid(output_vaild),
  .m_axis_result_tready(output_ready),
  .m_axis_result_tdata(c)
  // .m_axis_result_tdata()
);
// assign c= a +b;
endmodule