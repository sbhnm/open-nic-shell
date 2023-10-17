module Fifo #(parameter DATA_WIDTH = 32, parameter DEPTH = 4,parameter MIN_THER = 1,parameter MAX_THER = 12)
  (input clk,          // 时钟输入
   input rst,          // 复位输入
   input wr_en,        // 写使能信号
   input rd_en,        // 读使能信号
   input [DATA_WIDTH-1:0] data_in,   // 写入数据输入
   output wire [DATA_WIDTH-1:0] data_out,  // 读出数据输出
   output reg empty,   // FIFO空标志输出
   output reg full,     // FIFO满标志输出
   output reg needdata,
   output reg noneeddata,
   output wire [DEPTH:0] fill_level
  );
  function integer clogb2 (input integer bit_depth);              
  begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
    end                                                           
  endfunction     
  // 定义FIFO的存储数组
  reg [DATA_WIDTH-1:0] fifo_array [DEPTH-1:0];
  reg [31:0] wr_ptr; // 写指针
  reg [31:0] rd_ptr; // 读指针
  
  assign data_out = fifo_array[rd_ptr[clogb2(DEPTH-1)-1:0]];
  // 初始化指针和状态
  initial begin
    wr_ptr = 0;
    rd_ptr = 0;
    empty = 1;
    full = 0;
  end
  // wire [31:0] test;
  // assign test =clogb2(DEPTH-1)-1;
  // 写指针逻辑
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      wr_ptr <= 0;
    end else if (wr_en && ~full) begin
      wr_ptr <= wr_ptr + 1;
    end
  end

  // 读指针逻辑
  always @(posedge clk or posedge rst) begin
    if (rst) begin
      rd_ptr <= 0;
    end else if (rd_en && ~empty) begin
      rd_ptr <= rd_ptr + 1;
    end
  end

  // FIFO满和空的状态逻辑
  assign fill_level = wr_ptr - rd_ptr;
  always @* begin
    empty = (fill_level == 0);
    full = (fill_level == DEPTH);
    needdata =  (fill_level < MIN_THER);
    noneeddata = (fill_level > MAX_THER);

  end

  // 写入数据
  always @(posedge clk) begin
    if (wr_en && ~full) begin
      fifo_array[wr_ptr[clogb2(DEPTH-1)-1:0]] <= data_in;
    end
  end

  // 读取数据
//  always @(posedge clk) begin
//    // if (rd_en && ~empty) begin
//      data_out <= fifo_array[rd_ptr];
//    // end
//  end

endmodule
