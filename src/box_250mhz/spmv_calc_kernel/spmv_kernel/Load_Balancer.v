//本模块的作用是将端口的SPMV Xi请求聚合起来，再按照DDR的端口负载进行转发，以此改善Xi的读写，预计会对Double 产生4x加速比，对Float产生2x加速比。
module Load_Balancer #(
    parameter integer C_M_AXI_ID_WIDTH	= 1,
    parameter integer C_M_AXI_ADDR_WIDTH	= 48,
    parameter integer C_M_AXI_DATA_WIDTH	= 64,
    parameter integer C_M_AXI_BURST_LEN = 1
) (

    input wire  clk,
    input wire  rstn,

    input wire [1:0] Config_Port, 

    input wire [C_M_AXI_ID_WIDTH-1 : 0] s00_axi_arid,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s00_axi_araddr,
    input wire [7 : 0] s00_axi_arlen,
    input wire [2 : 0] s00_axi_arsize,
    input wire [1 : 0] s00_axi_arburst,
    input wire  s00_axi_arlock,
    input wire [3 : 0] s00_axi_arcache,
    input wire [2 : 0] s00_axi_arprot,
    input wire [3 : 0] s00_axi_arqos,
    input wire  s00_axi_arvalid,
    output wire  s00_axi_arready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] s00_axi_rid,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] s00_axi_rdata,
    output wire [1 : 0] s00_axi_rresp,
    output wire  s00_axi_rlast,
    output reg  s00_axi_rvalid,
    input wire  s00_axi_rready,

    input wire [C_M_AXI_ID_WIDTH-1 : 0] s01_axi_arid,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s01_axi_araddr,
    input wire [7 : 0] s01_axi_arlen,
    input wire [2 : 0] s01_axi_arsize,
    input wire [1 : 0] s01_axi_arburst,
    input wire  s01_axi_arlock,
    input wire [3 : 0] s01_axi_arcache,
    input wire [2 : 0] s01_axi_arprot,
    input wire [3 : 0] s01_axi_arqos,
    input wire  s01_axi_arvalid,
    output wire  s01_axi_arready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] s01_axi_rid,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] s01_axi_rdata,
    output wire [1 : 0] s01_axi_rresp,
    output wire  s01_axi_rlast,
    output reg  s01_axi_rvalid,
    input wire  s01_axi_rready,
    
    input wire [C_M_AXI_ID_WIDTH-1 : 0] s02_axi_arid,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s02_axi_araddr,
    input wire [7 : 0] s02_axi_arlen,
    input wire [2 : 0] s02_axi_arsize,
    input wire [1 : 0] s02_axi_arburst,
    input wire  s02_axi_arlock,
    input wire [3 : 0] s02_axi_arcache,
    input wire [2 : 0] s02_axi_arprot,
    input wire [3 : 0] s02_axi_arqos,
    input wire  s02_axi_arvalid,
    output wire  s02_axi_arready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] s02_axi_rid,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] s02_axi_rdata,
    output wire [1 : 0] s02_axi_rresp,
    output wire  s02_axi_rlast,
    output reg  s02_axi_rvalid,
    input wire  s02_axi_rready,
    
    input wire [C_M_AXI_ID_WIDTH-1 : 0] s03_axi_arid,
    input wire [C_M_AXI_ADDR_WIDTH-1 : 0] s03_axi_araddr,
    input wire [7 : 0] s03_axi_arlen,
    input wire [2 : 0] s03_axi_arsize,
    input wire [1 : 0] s03_axi_arburst,
    input wire  s03_axi_arlock,
    input wire [3 : 0] s03_axi_arcache,
    input wire [2 : 0] s03_axi_arprot,
    input wire [3 : 0] s03_axi_arqos,
    input wire  s03_axi_arvalid,
    output wire  s03_axi_arready,
    output wire [C_M_AXI_ID_WIDTH-1 : 0] s03_axi_rid,
    output wire [C_M_AXI_DATA_WIDTH-1 : 0] s03_axi_rdata,
    output wire [1 : 0] s03_axi_rresp,
    output wire  s03_axi_rlast,
    output reg  s03_axi_rvalid,
    input wire  s03_axi_rready,


    output wire [C_M_AXI_ID_WIDTH-1 : 0] m00_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m00_axi_araddr,
    output wire [7 : 0] m00_axi_arlen,
    output wire [2 : 0] m00_axi_arsize,
    output wire [1 : 0] m00_axi_arburst,
    output wire  m00_axi_arlock,
    output wire [3 : 0] m00_axi_arcache,
    output wire [2 : 0] m00_axi_arprot,
    output wire [3 : 0] m00_axi_arqos,
    output wire  m00_axi_arvalid,
    input wire  m00_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m00_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] m00_axi_rdata,
    input wire [1 : 0] m00_axi_rresp,
    input wire  m00_axi_rlast,
    input wire  m00_axi_rvalid,
    output wire  m00_axi_rready,

    output wire [C_M_AXI_ID_WIDTH-1 : 0] m01_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m01_axi_araddr,
    output wire [7 : 0] m01_axi_arlen,
    output wire [2 : 0] m01_axi_arsize,
    output wire [1 : 0] m01_axi_arburst,
    output wire  m01_axi_arlock,
    output wire [3 : 0] m01_axi_arcache,
    output wire [2 : 0] m01_axi_arprot,
    output wire [3 : 0] m01_axi_arqos,
    output wire  m01_axi_arvalid,
    input wire  m01_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m01_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] m01_axi_rdata,
    input wire [1 : 0] m01_axi_rresp,
    input wire  m01_axi_rlast,
    input wire  m01_axi_rvalid,
    output wire  m01_axi_rready,
    
    output wire [C_M_AXI_ID_WIDTH-1 : 0] m02_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m02_axi_araddr,
    output wire [7 : 0] m02_axi_arlen,
    output wire [2 : 0] m02_axi_arsize,
    output wire [1 : 0] m02_axi_arburst,
    output wire  m02_axi_arlock,
    output wire [3 : 0] m02_axi_arcache,
    output wire [2 : 0] m02_axi_arprot,
    output wire [3 : 0] m02_axi_arqos,
    output wire  m02_axi_arvalid,
    input wire  m02_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m02_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] m02_axi_rdata,
    input wire [1 : 0] m02_axi_rresp,
    input wire  m02_axi_rlast,
    input wire  m02_axi_rvalid,
    output wire  m02_axi_rready,
    
    output wire [C_M_AXI_ID_WIDTH-1 : 0] m03_axi_arid,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0] m03_axi_araddr,
    output wire [7 : 0] m03_axi_arlen,
    output wire [2 : 0] m03_axi_arsize,
    output wire [1 : 0] m03_axi_arburst,
    output wire  m03_axi_arlock,
    output wire [3 : 0] m03_axi_arcache,
    output wire [2 : 0] m03_axi_arprot,
    output wire [3 : 0] m03_axi_arqos,
    output wire  m03_axi_arvalid,
    input wire  m03_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m03_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] m03_axi_rdata,
    input wire [1 : 0] m03_axi_rresp,
    input wire  m03_axi_rlast,
    input wire  m03_axi_rvalid,
    output wire  m03_axi_rready,


    // output wire [C_M_AXI_ID_WIDTH-1 : 0] m_cache_axi_arid,
    // output reg [C_M_AXI_ADDR_WIDTH-1 : 0] m_cache_axi_araddr,
    // output wire [7 : 0] m_cache_axi_arlen,
    // output wire [2 : 0] m_cache_axi_arsize,
    // output wire [1 : 0] m_cache_axi_arburst,
    // output wire  m_cache_axi_arlock,
    // output wire [3 : 0] m_cache_axi_arcache,
    // output wire [2 : 0] m_cache_axi_arprot,
    // output wire [3 : 0] m_cache_axi_arqos,
    // output reg  m_cache_axi_arvalid,
    // input wire  m_cache_axi_arready,
    // input wire [C_M_AXI_ID_WIDTH-1 : 0] m_cache_axi_rid,
    // input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_cache_axi_rdata,
    // input wire [1 : 0] m_cache_axi_rresp,
    // input wire  m_cache_axi_rlast,
    // input wire  m_cache_axi_rvalid,
    // output wire  m_cache_axi_rready,




    output wire Load_Balancer_ready

);
    assign Load_Balancer_ready = 0;
	function integer clogb2 (input integer bit_depth);              
  	begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
    end                                                           
  	endfunction 
    
	assign m00_axi_arlen = C_M_AXI_BURST_LEN -1;
	assign m00_axi_arid = 0;
	assign m00_axi_arsize	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign m00_axi_arburst	= 2'b01;
	assign m00_axi_arlock = 1'b0;
	assign m00_axi_arcache	= 4'b0010;
	assign m00_axi_arprot	= 3'h0;
	assign m00_axi_arqos	= 4'h0;
    
    assign m01_axi_arlen = C_M_AXI_BURST_LEN -1;
	assign m01_axi_arid = 0;
	assign m01_axi_arsize	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign m01_axi_arburst	= 2'b01;
	assign m01_axi_arlock = 1'b0;
	assign m01_axi_arcache	= 4'b0010;
	assign m01_axi_arprot	= 3'h0;
	assign m01_axi_arqos	= 4'h0;
    
    assign m02_axi_arlen = C_M_AXI_BURST_LEN -1;
	assign m02_axi_arid = 0;
	assign m02_axi_arsize	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign m02_axi_arburst	= 2'b01;
	assign m02_axi_arlock = 1'b0;
	assign m02_axi_arcache	= 4'b0010;
	assign m02_axi_arprot	= 3'h0;
	assign m02_axi_arqos	= 4'h0;
    
    assign m03_axi_arlen = C_M_AXI_BURST_LEN -1;
	assign m03_axi_arid = 0;
	assign m03_axi_arsize	= clogb2((C_M_AXI_DATA_WIDTH/8)-1);
	assign m03_axi_arburst	= 2'b01;
	assign m03_axi_arlock = 1'b0;
	assign m03_axi_arcache	= 4'b0010;
	assign m03_axi_arprot	= 3'h0;
	assign m03_axi_arqos	= 4'h0;

    assign s00_axi_rid = 0;
	assign s00_axi_rresp = 0;
	assign s00_axi_rlast = s00_axi_rvalid;
    
    assign s01_axi_rid = 0;
	assign s01_axi_rresp = 0;
	assign s01_axi_rlast = s01_axi_rvalid;
    
    assign s02_axi_rid = 0;
	assign s02_axi_rresp = 0;
	assign s02_axi_rlast = s02_axi_rvalid;
    
    assign s03_axi_rid = 0;
	assign s03_axi_rresp = 0;
	assign s03_axi_rlast = s03_axi_rvalid;


    assign m00_axi_arprot = 0;
    assign m01_axi_arprot = 0;
    assign m02_axi_arprot = 0;
    assign m03_axi_arprot = 0;

    //接收已经arvalid的端口请求（尚未分配）发送端口//数据：48位地址

    assign s00_axi_arready = ~Fifo_AXI_Req_1_full;
    assign s01_axi_arready = ~Fifo_AXI_Req_2_full;
    assign s02_axi_arready = ~Fifo_AXI_Req_3_full;
    assign s03_axi_arready = ~Fifo_AXI_Req_4_full;



    wire [3+3+C_M_AXI_DATA_WIDTH-1:0] Issue_Uint_1_Fifo_Post_Read_data;
    wire [3+3+C_M_AXI_DATA_WIDTH-1:0] Issue_Uint_2_Fifo_Post_Read_data;
    wire [3+3+C_M_AXI_DATA_WIDTH-1:0] Issue_Uint_3_Fifo_Post_Read_data;
    wire [3+3+C_M_AXI_DATA_WIDTH-1:0] Issue_Uint_4_Fifo_Post_Read_data;
    
    (*mark_debug = "true"*) 
    reg [2:0] Req_Seq_1;
    (*mark_debug = "true"*) 
    reg [2:0] Req_Seq_2;
    (*mark_debug = "true"*) 
    reg [2:0] Req_Seq_3;
    (*mark_debug = "true"*) 
    reg [2:0] Req_Seq_4;

    wire [C_M_AXI_ADDR_WIDTH + 3-1:0] Fifo_AXI_Req_1_data_out;
    
    // Cache_Bank Cache_Bank(
    //     .clk(clk),
    //     .rstn(rstn),


    //     .Req_ready(LUT_Array_Req_ready),
    //     .Req_valid(LUT_Array_Req_valid),
    //     .Req_Addr(LUT_Array_Req_Addr),

    //     .Post_ready(LUT_Array_Post_ready),
    //     .Post_valid(LUT_Array_Post_valid),
    //     .Post_Data(LUT_Array_Post_Data),
    //     .Post_Success(LUT_Array_Post_Success),

    //     .m_cache_axi_arid(m_cache_axi_arid),
    //     .m_cache_axi_araddr(m_cache_axi_araddr),
    //     .m_cache_axi_arlen(m_cache_axi_arlen),
    //     .m_cache_axi_arsize(m_cache_axi_arsize),
    //     .m_cache_axi_arburst(m_cache_axi_arburst),
    //     .m_cache_axi_arlock(m_cache_axi_arlock),
    //     .m_cache_axi_arcache(m_cache_axi_arcache),
    //     .m_cache_axi_arprot(m_cache_axi_arprot),
    //     .m_cache_axi_arqos(m_cache_axi_arqos),
    //     .m_cache_axi_arvalid(m_cache_axi_arvalid),
    //     .m_cache_axi_arready(m_cache_axi_arready),
    //     .m_cache_axi_rid(m_cache_axi_rid),
    //     .m_cache_axi_rdata(m_cache_axi_rdata),
    //     .m_cache_axi_rresp(m_cache_axi_rresp),
    //     .m_cache_axi_rlast(m_cache_axi_rlast),
    //     .m_cache_axi_rvalid(m_cache_axi_rvalid),
    //     .m_cache_axi_rready(m_cache_axi_rready)
    // );

    Fifo #(
        .DATA_WIDTH(C_M_AXI_ADDR_WIDTH + 3),
        .DEPTH(8)
    ) Fifo_AXI_Req_1(
        .clk(clk),
        .rst(~rstn),
        .wr_en(s00_axi_arvalid & s00_axi_arready),
        .data_in({s00_axi_araddr,Req_Seq_1}),
        .data_out(Fifo_AXI_Req_1_data_out),
        .rd_en(Fifo_AXI_Req_1_rd_en),
        .empty(Fifo_AXI_Req_1_empty),
        .full(Fifo_AXI_Req_1_full)
    ); 
    

    wire [C_M_AXI_ADDR_WIDTH + 3-1:0] Fifo_AXI_Req_2_data_out;
    Fifo #(
        .DATA_WIDTH(C_M_AXI_ADDR_WIDTH + 3),
        .DEPTH(8)
    ) Fifo_AXI_Req_2(
        .clk(clk),
        .rst(~rstn),
        .wr_en(s01_axi_arvalid & s01_axi_arready),
        .data_in({s01_axi_araddr,Req_Seq_2}),
        .data_out(Fifo_AXI_Req_2_data_out),
        .rd_en(Fifo_AXI_Req_2_rd_en),
        .empty(Fifo_AXI_Req_2_empty),
        .full(Fifo_AXI_Req_2_full)
    ); 

    wire [C_M_AXI_ADDR_WIDTH + 3-1:0] Fifo_AXI_Req_3_data_out;
    Fifo #(
        .DATA_WIDTH(C_M_AXI_ADDR_WIDTH + 3),
        .DEPTH(8)
    ) Fifo_AXI_Req_3(
        .clk(clk),
        .rst(~rstn),
        .wr_en(s02_axi_arvalid & s02_axi_arready),
        .data_in({s02_axi_araddr,Req_Seq_3}),
        .data_out(Fifo_AXI_Req_3_data_out),
        .rd_en(Fifo_AXI_Req_3_rd_en),
        .empty(Fifo_AXI_Req_3_empty),
        .full(Fifo_AXI_Req_3_full)
    ); 

    wire [C_M_AXI_ADDR_WIDTH + 3-1:0] Fifo_AXI_Req_4_data_out;
    Fifo #(
        .DATA_WIDTH(C_M_AXI_ADDR_WIDTH + 3),
        .DEPTH(8)
    ) Fifo_AXI_Req_4(
        .clk(clk),
        .rst(~rstn),
        .wr_en(s03_axi_arvalid & s03_axi_arready),
        .data_in({s03_axi_araddr,Req_Seq_4}),
        .data_out(Fifo_AXI_Req_4_data_out),
        .rd_en(Fifo_AXI_Req_4_rd_en),
        .empty(Fifo_AXI_Req_4_empty),
        .full(Fifo_AXI_Req_4_full)
    ); 



    (*mark_debug = "true"*)
    wire [2:0] Req_Fifo_ServeNum;


    //Load_Balance
    (*mark_debug = "true"*)
    reg [31:0] Serve_Req_1_Num;
    (*mark_debug = "true"*)
    reg [31:0] Serve_Req_2_Num;
    (*mark_debug = "true"*)
    reg [31:0] Serve_Req_3_Num;
    (*mark_debug = "true"*)
    reg [31:0] Serve_Req_4_Num;
    
    wire [31:0] min_Req_Seq_Num;
    wire [31:0] min_Req_Seq_Num_1;
    wire [31:0] min_Req_Seq_Num_2;
    (*mark_debug = "true"*)
    wire [2:0] min_Req_Seq;
    // assign min_Req_Seq_Num_1 = (Serve_Req_1_Num < Serve_Req_2_Num)?(Serve_Req_1_Num):(Serve_Req_2_Num);
    // assign min_Req_Seq_Num_2 = (Serve_Req_3_Num < Serve_Req_4_Num)?(Serve_Req_3_Num):(Serve_Req_4_Num);
    // assign min_Req_Seq_Num_3 = (min_Req_Seq_Num_1 < min_Req_Seq_Num_2)?(min_Req_Seq_Num_1):(min_Req_Seq_Num_2);


    // assign min_Req_Seq_Num =    (Config_Port == 2) ? (Serve_Req_1_Num) : 0|
    //                             (Config_Port == 1) ? (min_Req_Seq_Num_1) : 0|
    //                             (Config_Port == 0) ? (min_Req_Seq_Num_3) : 0;

    (*mark_debug = "true"*)   
    reg [2:0] Wb_Seq_1;
    (*mark_debug = "true"*)  
    reg [2:0] Wb_Seq_2;
    (*mark_debug = "true"*)  
    reg [2:0] Wb_Seq_3;
    (*mark_debug = "true"*)  
    reg [2:0] Wb_Seq_4;

    (*mark_debug = "true"*)
    wire [2:0] Issue_Available;
    
    assign Issue_Available = 
                            Issue_1_IDLE ? 1 :
                            Issue_2_IDLE ? 2 :
                            Issue_3_IDLE ? 3 :
                            Issue_4_IDLE ? 4 :

                            ~Issue_1_BUSY ? 1:
                            ~Issue_2_BUSY ? 2:
                            ~Issue_3_BUSY ? 3:
                            ~Issue_4_BUSY ? 4:
                            0;

    
    (*mark_debug = "true"*)
    wire Tx_En;
    
    assign Tx_En = Req_Fifo_ServeNum !=0 & Issue_Available!=0;

    assign min_Req_Seq =    (Config_Port == 2) ? (1) : 0 |
                            (Config_Port == 1) ? (
                                                     Serve_Req_1_Num < Serve_Req_2_Num ? 1:2
                                                    ) : 0 |
                            (Config_Port == 0) ? (
                                                    (Serve_Req_1_Num < Serve_Req_2_Num & 
                                                    Serve_Req_1_Num < Serve_Req_3_Num &
                                                    Serve_Req_1_Num < Serve_Req_4_Num) ? 1 :0 |
                                                    (Serve_Req_2_Num < Serve_Req_1_Num & 
                                                    Serve_Req_2_Num < Serve_Req_3_Num &
                                                    Serve_Req_2_Num < Serve_Req_4_Num) ? 1 :0 |
                                                    (Serve_Req_3_Num < Serve_Req_1_Num & 
                                                    Serve_Req_3_Num < Serve_Req_2_Num &
                                                    Serve_Req_3_Num < Serve_Req_4_Num) ? 1 :0 |
                                                    (Serve_Req_4_Num < Serve_Req_1_Num & 
                                                    Serve_Req_4_Num < Serve_Req_2_Num &
                                                    Serve_Req_4_Num < Serve_Req_3_Num) ? 1 :0
                            ) : 0;



    always @(posedge clk ) begin
        if(~rstn)begin
            Serve_Req_1_Num<=0;
        end
        else if(Req_Fifo_ServeNum == 1 & m00_axi_arvalid & m00_axi_arready)begin
            Serve_Req_1_Num<=Serve_Req_1_Num+1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Serve_Req_2_Num<=0;
        end
        else if(Req_Fifo_ServeNum == 2 & m01_axi_arvalid & m01_axi_arready)begin
            Serve_Req_2_Num<=Serve_Req_2_Num+1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Serve_Req_3_Num<=0;
        end
        else if(Req_Fifo_ServeNum == 3 & m02_axi_arvalid & m02_axi_arready)begin
            Serve_Req_3_Num<=Serve_Req_3_Num+1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Serve_Req_4_Num<=0;
        end
        else if(Req_Fifo_ServeNum == 4 & m03_axi_arvalid & m03_axi_arready)begin
            Serve_Req_4_Num<=Serve_Req_4_Num+1;
        end
    end
    // wire [2:0] Fifo_Available;
    // assign  Fifo_Available = 
    //                             Fifo_AXI_Req_1_full?1:
    //                             Fifo_AXI_Req_2_full?2:
    //                             Fifo_AXI_Req_3_full?3:
    //                             Fifo_AXI_Req_4_full?4:

    //                             ~Fifo_AXI_Req_1_empty?1:
    //                             ~Fifo_AXI_Req_2_empty?2:
    //                             ~Fifo_AXI_Req_3_empty?3:
    //                             ~Fifo_AXI_Req_4_empty?4:
    //                             0;
    //每周期只服务一个队列。
    
    assign Req_Fifo_ServeNum = (
                                (min_Req_Seq == 1 & ~Fifo_AXI_Req_1_empty)?1:0|
                                (min_Req_Seq == 2 & ~Fifo_AXI_Req_2_empty)?2:0|
                                (min_Req_Seq == 3 & ~Fifo_AXI_Req_3_empty)?3:0|
                                (min_Req_Seq == 4 & ~Fifo_AXI_Req_4_empty)?4:0
                            );
                            

    (*mark_debug = "true"*)
    wire [C_M_AXI_ADDR_WIDTH-1:0] Tx_ADDR;
    (*mark_debug = "true"*)
    wire [2:0] Tx_Seq;
    assign Tx_Seq =     Req_Fifo_ServeNum == 1 ? Fifo_AXI_Req_1_data_out[2:0] : 0|
                        Req_Fifo_ServeNum == 2 ? Fifo_AXI_Req_2_data_out[2:0] : 0|
                        Req_Fifo_ServeNum == 3 ? Fifo_AXI_Req_3_data_out[2:0] : 0|
                        Req_Fifo_ServeNum == 4 ? Fifo_AXI_Req_4_data_out[2:0] : 0;   

    assign Tx_ADDR =    Req_Fifo_ServeNum == 1 ? Fifo_AXI_Req_1_data_out[C_M_AXI_ADDR_WIDTH +3 -1 :3] : 0|
                        Req_Fifo_ServeNum == 2 ? Fifo_AXI_Req_2_data_out[C_M_AXI_ADDR_WIDTH +3 -1 :3] : 0|
                        Req_Fifo_ServeNum == 3 ? Fifo_AXI_Req_3_data_out[C_M_AXI_ADDR_WIDTH +3 -1 :3] : 0|
                        Req_Fifo_ServeNum == 4 ? Fifo_AXI_Req_4_data_out[C_M_AXI_ADDR_WIDTH +3 -1 :3] : 0;

    assign m00_axi_araddr = Issue_Available==1 ? Tx_ADDR :0;
    assign m01_axi_araddr = Issue_Available==2 ? Tx_ADDR :0;
    assign m02_axi_araddr = Issue_Available==3 ? Tx_ADDR :0;
    assign m03_axi_araddr = Issue_Available==4 ? Tx_ADDR :0;

    assign m00_axi_arvalid = Tx_En & Issue_Available==1;
    assign m01_axi_arvalid = Tx_En & Issue_Available==2;
    assign m02_axi_arvalid = Tx_En & Issue_Available==3;
    assign m03_axi_arvalid = Tx_En & Issue_Available==4;

    assign m00_axi_rready = 1;
    assign m01_axi_rready = 1;
    assign m02_axi_rready = 1;
    assign m03_axi_rready = 1;

    assign Fifo_AXI_Req_1_rd_en = Issue_Available != 0 & Req_Fifo_ServeNum == 1 & Tx_En & m00_axi_arready;
    assign Fifo_AXI_Req_2_rd_en = Issue_Available != 0 & Req_Fifo_ServeNum == 2 & Tx_En & m01_axi_arready;
    assign Fifo_AXI_Req_3_rd_en = Issue_Available != 0 & Req_Fifo_ServeNum == 3 & Tx_En & m02_axi_arready;
    assign Fifo_AXI_Req_4_rd_en = Issue_Available != 0 & Req_Fifo_ServeNum == 4 & Tx_En & m03_axi_arready;


    // 已经从Req队列中取出，并在分配的发射端口中完成发射，但尚未返回的请求，数据：请求端口号，请求端口的在途序列。 这个队列不会满，因为收到AR_CNT控制



    // 完成并返回数据的请求 ，数据：请求端口号 请求端口的在途序列，数据。 
    //issue 和 Post 是保序的。

    Issue_Uint  Issue_Uint_1(
        .clk(clk),
        .rstn(rstn),
        .m_axi_arvalid(m00_axi_arvalid&m00_axi_arready),
        .m_axi_arready(m00_axi_arready),
        .m_axi_rvalid(m00_axi_rvalid),
        .m_axi_rready(m00_axi_rready),
        .m_axi_rdata(m00_axi_rdata),
        
        .Issue_BUSY(Issue_1_BUSY),
        .Issue_IDLE(Issue_1_IDLE),
        .Fifo_Post_Read(Issue_Uint_1_Fifo_Post_Read),
        .Fifo_Post_Read_data(Issue_Uint_1_Fifo_Post_Read_data),
        .Fifo_Post_empty(Issue_Uint_1_Fifo_Post_empty),
        .Fifo_Post_full(Issue_Uint_1_Fifo_Post_full),
        .Req_Fifo_ServeNum(Req_Fifo_ServeNum),
        .Req_Seq(Tx_Seq)
    );
    Issue_Uint  Issue_Uint_2(
        .clk(clk),
        .rstn(rstn),
        .m_axi_arvalid(m01_axi_arvalid&m01_axi_arready),
        .m_axi_arready(m01_axi_arready),
        .m_axi_rvalid(m01_axi_rvalid),
        .m_axi_rready(m01_axi_rready),
        .m_axi_rdata(m01_axi_rdata),
        
        .Issue_BUSY(Issue_2_BUSY),
        .Issue_IDLE(Issue_2_IDLE),
        .Fifo_Post_Read(Issue_Uint_2_Fifo_Post_Read),
        .Fifo_Post_Read_data(Issue_Uint_2_Fifo_Post_Read_data),
        .Fifo_Post_empty(Issue_Uint_2_Fifo_Post_empty),
        .Fifo_Post_full(Issue_Uint_2_Fifo_Post_full),
        .Req_Fifo_ServeNum(Req_Fifo_ServeNum),
        .Req_Seq(Tx_Seq)
    );
    Issue_Uint  Issue_Uint_3(
        .clk(clk),
        .rstn(rstn),
        .m_axi_arvalid(m02_axi_arvalid&m02_axi_arready),
        .m_axi_arready(m02_axi_arready),
        .m_axi_rvalid(m02_axi_rvalid),
        .m_axi_rready(m02_axi_rready),
        .m_axi_rdata(m02_axi_rdata),
        
        .Issue_BUSY(Issue_3_BUSY),
        .Issue_IDLE(Issue_3_IDLE),
        .Fifo_Post_Read(Issue_Uint_3_Fifo_Post_Read),
        .Fifo_Post_Read_data(Issue_Uint_3_Fifo_Post_Read_data),
        .Fifo_Post_empty(Issue_Uint_3_Fifo_Post_empty),
        .Fifo_Post_full(Issue_Uint_3_Fifo_Post_full),
        .Req_Fifo_ServeNum(Req_Fifo_ServeNum),
        .Req_Seq(Tx_Seq)
    );
    Issue_Uint  Issue_Uint_4(
        .clk(clk),
        .rstn(rstn),
        .m_axi_arvalid(m03_axi_arvalid&m03_axi_arready),
        .m_axi_arready(m03_axi_arready),
        .m_axi_rvalid(m03_axi_rvalid),
        .m_axi_rready(m03_axi_rready),
        .m_axi_rdata(m03_axi_rdata),
        
        .Issue_BUSY(Issue_4_BUSY),
        .Issue_IDLE(Issue_4_IDLE),
        .Fifo_Post_Read(Issue_Uint_4_Fifo_Post_Read),
        .Fifo_Post_Read_data(Issue_Uint_4_Fifo_Post_Read_data),
        .Fifo_Post_empty(Issue_Uint_4_Fifo_Post_empty),
        .Fifo_Post_full(Issue_Uint_4_Fifo_Post_full),
        .Req_Fifo_ServeNum(Req_Fifo_ServeNum),
        .Req_Seq(Tx_Seq)
    );

    wire [2:0] Post_Fifo_ServeNum;


    assign Post_Fifo_ServeNum = 
                                Issue_Uint_1_Fifo_Post_full ? 1:
                                Issue_Uint_2_Fifo_Post_full ? 2:
                                Issue_Uint_3_Fifo_Post_full ? 3:
                                Issue_Uint_4_Fifo_Post_full ? 4:

                                ~Issue_Uint_1_Fifo_Post_empty ? 1:
                                ~Issue_Uint_2_Fifo_Post_empty ? 2:
                                ~Issue_Uint_3_Fifo_Post_empty ? 3:
                                ~Issue_Uint_4_Fifo_Post_empty ? 4:
                                0;

    wire [C_M_AXI_DATA_WIDTH+6-1:0] Fifo_Data;



    assign Issue_Uint_1_Fifo_Post_Read = Post_Fifo_ServeNum == 1;
    assign Issue_Uint_2_Fifo_Post_Read = Post_Fifo_ServeNum == 2;
    assign Issue_Uint_3_Fifo_Post_Read = Post_Fifo_ServeNum == 3;
    assign Issue_Uint_4_Fifo_Post_Read = Post_Fifo_ServeNum == 4;

    assign Fifo_Data =  Post_Fifo_ServeNum == 1? Issue_Uint_1_Fifo_Post_Read_data:0|
                        Post_Fifo_ServeNum == 2? Issue_Uint_2_Fifo_Post_Read_data:0|
                        Post_Fifo_ServeNum == 3? Issue_Uint_3_Fifo_Post_Read_data:0|
                        Post_Fifo_ServeNum == 4? Issue_Uint_4_Fifo_Post_Read_data:0;
    
    wire [C_M_AXI_DATA_WIDTH-1:0] rData_Get; //数据
    assign rData_Get = Fifo_Data[C_M_AXI_DATA_WIDTH + 6 -1:6];


    wire [3-1:0] rSeq_Get; //字节序
    assign rSeq_Get = Fifo_Data[2:0];

    wire [3-1:0] rPort_Get; //请求端口
    assign rPort_Get = Fifo_Data[5:3];


    //请求端口的在途序列分配。每发射一个请求后，序列指+1 0->7->0....
    reg [64-1:0] rData_1 [7:0]; 
    (*mark_debug = "true"*)   
    reg [7:0]    rData_1ValidMap;

    reg [64-1:0] rData_2 [7:0];
    (*mark_debug = "true"*)   
    reg [7:0]    rData_2ValidMap;
    
    reg [64-1:0] rData_3 [7:0];
    (*mark_debug = "true"*)
    reg [7:0]    rData_3ValidMap;
    
    reg [64-1:0] rData_4 [7:0];
    (*mark_debug = "true"*)   
    reg [7:0]    rData_4ValidMap;


    reg [2:0] Wb_Cold_1;
    reg [2:0] Wb_Cold_2;
    reg [2:0] Wb_Cold_3;
    reg [2:0] Wb_Cold_4;

    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Cold_1<=3;
        end
        else if(s00_axi_rvalid & s00_axi_rready)begin
            Wb_Cold_1<=3;
        end
        else begin
            Wb_Cold_1 <= Wb_Cold_1==0 ? 0:Wb_Cold_1 - 1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Cold_2<=3;
        end
        else if(s01_axi_rvalid & s01_axi_rready)begin
            Wb_Cold_2<=3;
        end
        else begin
            Wb_Cold_2 <= Wb_Cold_2==0 ? 0:Wb_Cold_2 - 1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Cold_3<=3;
        end
        else if(s02_axi_rvalid & s02_axi_rready)begin
            Wb_Cold_3<=3;
        end
        else begin
            Wb_Cold_3 <= Wb_Cold_3==0 ? 0:Wb_Cold_3 - 1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Cold_4<=3;
        end
        else if(s03_axi_rvalid & s03_axi_rready)begin
            Wb_Cold_4<=3;
        end
        else begin
            Wb_Cold_4 <= Wb_Cold_4==0 ? 0:Wb_Cold_4 - 1;
        end
    end

    always @(posedge clk ) begin
        if(Post_Fifo_ServeNum!=0)begin
            if(rPort_Get == 1)begin
                rData_1[rSeq_Get]<= rData_Get;

                rData_1ValidMap[rSeq_Get]<=1;
            end
            else if(rPort_Get == 2)begin
                rData_2[rSeq_Get]<= rData_Get;

                rData_2ValidMap[rSeq_Get]<=1;
            end
            else if(rPort_Get == 3)begin
                rData_3[rSeq_Get]<= rData_Get;

                rData_3ValidMap[rSeq_Get]<=1;
            end
            else if(rPort_Get == 4)begin
                rData_4[rSeq_Get]<= rData_Get;
                
                rData_4ValidMap[rSeq_Get]<=1;
            end
        end
        if(rPort_Get !=1 & rData_1ValidMap[Wb_Seq_1] & Wb_Cold_1==0 & s00_axi_rready)begin
            rData_1ValidMap[Wb_Seq_1] <=0;
            s00_axi_rvalid<=1;
        end
        else begin
            s00_axi_rvalid<=0;
        end


        if(rPort_Get !=2 & rData_2ValidMap[Wb_Seq_2] & Wb_Cold_2==0 & s01_axi_rready)begin
            rData_2ValidMap[Wb_Seq_2] <=0;
            s01_axi_rvalid<=1;
        end
        else begin
            s01_axi_rvalid<=0;
        end
        
        if(rPort_Get !=3 & rData_3ValidMap[Wb_Seq_3] & Wb_Cold_3==0 & s02_axi_rready)begin
            rData_3ValidMap[Wb_Seq_3] <=0;
            s02_axi_rvalid<=1;
        end
        else begin
            s02_axi_rvalid<=0;
        end
        if(rPort_Get !=4 & rData_4ValidMap[Wb_Seq_4] & Wb_Cold_4==0 & s03_axi_rready)begin
            rData_4ValidMap[Wb_Seq_4] <=0;
            s03_axi_rvalid<=1;
        end
        else begin
            s03_axi_rvalid<=0;
        end
    end


    assign s00_axi_rdata = rData_1[Wb_Seq_1];
    assign s01_axi_rdata = rData_2[Wb_Seq_2];
    assign s02_axi_rdata = rData_3[Wb_Seq_3];
    assign s03_axi_rdata = rData_4[Wb_Seq_4];



    always @(posedge clk ) begin
        if(~rstn)begin
            Req_Seq_1 <=0;
        end
        else if (s00_axi_arvalid & s00_axi_arready)begin
            Req_Seq_1<=Req_Seq_1+1;
        end
    end    
    always @(posedge clk ) begin
        if(~rstn)begin
            Req_Seq_2 <=0;
        end
        else if (s01_axi_arvalid & s01_axi_arready)begin
            Req_Seq_2<=Req_Seq_2+1;
        end
    end
    always @(posedge clk ) begin
        if(~rstn)begin
            Req_Seq_3 <=0;
        end
        else if (s02_axi_arvalid & s02_axi_arready)begin
            Req_Seq_3<=Req_Seq_3+1;
        end
    end
    always @(posedge clk ) begin
        if(~rstn)begin
            Req_Seq_4 <=0;
        end
        else if (s03_axi_arvalid & s03_axi_arready)begin
            Req_Seq_4<=Req_Seq_4+1;
        end
    end




    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Seq_1 <=0;
        end
        else if (s00_axi_rvalid & s00_axi_rready)begin
            Wb_Seq_1<=Wb_Seq_1+1;
        end
    end    
    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Seq_2 <=0;
        end
        else if (s01_axi_rvalid & s01_axi_rready)begin
            Wb_Seq_2<=Wb_Seq_2+1;
        end
    end
    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Seq_3 <=0;
        end
        else if (s02_axi_rvalid & s02_axi_rready)begin
            Wb_Seq_3<=Wb_Seq_3+1;
        end
    end
    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_Seq_4 <=0;
        end
        else if (s03_axi_rvalid & s03_axi_rready)begin
            Wb_Seq_4<=Wb_Seq_4+1;
        end
    end



    // Wb_Seq ,检查自己所在对应位数据是否有效，有效则写回
    //写回一次，序列+1



    //从一个队列取出Post的请求后，检查： 1. 是否是本端口数据 是，则直接写入rData，并更新ValidMap

    
endmodule