module Fifo_DeMux #
(   parameter DATA_IN_WIDTH = 256,
    parameter DATA_OUT_WIDTH = 64, 
    parameter DEPTH = 4,
    parameter MIN_THER = 1,
    parameter MAX_THER = 12)
  (input clk,          // 时钟输入
   input rst,          // 复位输入
   input wr_en,        // 写使能信号
   input rd_en,        // 读使能信号
   input [DATA_IN_WIDTH-1:0] data_in,   // 写入数据输入
   output [DATA_OUT_WIDTH-1:0] data_out,  // 读出数据输出
   output empty,   // FIFO空标志输出
   output full,     // FIFO满标志输出
   output needdata,
   output noneeddata,
   output wire [DEPTH:0] fill_level
  );
    wire [DATA_IN_WIDTH-1:0] fifo_data_out;
    wire fifo_rd_en;
    wire fifo_empty;
  Fifo # (
    .DATA_WIDTH(DATA_IN_WIDTH),
    .DEPTH(DEPTH),
    .MIN_THER(MIN_THER),
    .MAX_THER(MAX_THER)
  )Fifo(
    .clk(clk),
    .rst(rst),
    .wr_en(wr_en),
    .rd_en(fifo_rd_en),
    .data_in(data_in),
    .data_out(fifo_data_out),
    .empty(fifo_empty),
    .full(full),
    .needdata(needdata),
    .noneeddata(noneeddata),
    .fill_level(fill_level)
  );
  assign fifo_rd_en = Data_DeMux_s_ready & ~fifo_empty;
  assign empty = Data_DeMux_s_ready;
  wire Data_DeMux_m_ready;
  assign Data_DeMux_m_ready = rd_en;
  Data_DeMux #(
    .SLAVE_WIDTH(DATA_IN_WIDTH),
    .MASTER_WIDTH(DATA_OUT_WIDTH)
  )Data_DeMux(
    .clk(clk),
    .rstn(~rst),
    .s_data(fifo_data_out),
    .s_ready(Data_DeMux_s_ready),
    .s_valid(fifo_rd_en),

    .m_data(data_out),
    .m_ready(Data_DeMux_m_ready),
    .m_valid()
  ); 

    
endmodule