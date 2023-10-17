// localparam DATA_WIDTH = 32;

module mul_fp32#(
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
floating_point_1 mul_inst (
  .aclk(clk),                                  // input wire aclk
  .s_axis_a_tvalid(input_vaild),            // input wire s_axis_a_tvalid
  .s_axis_a_tready(a_ready),            // output wire s_axis_a_tready
  .s_axis_a_tdata(a),              // input wire [31 : 0] s_axis_a_tdata
  .s_axis_b_tvalid(input_vaild),            // input wire s_axis_b_tvalid
  .s_axis_b_tready(b_ready),            // output wire s_axis_b_tready
  .s_axis_b_tdata(b),              // input wire [31 : 0] s_axis_b_tdata
  .m_axis_result_tvalid(output_vaild),  // output wire m_axis_result_tvalid
  .m_axis_result_tready(output_ready),  // input wire m_axis_result_tready
  .m_axis_result_tdata(c)    // output wire [31 : 0] m_axis_result_tdata
  // .m_axis_result_tdata()    // output wire [31 : 0] m_axis_result_tdata
  
);
  // assign c = a * b;
endmodule