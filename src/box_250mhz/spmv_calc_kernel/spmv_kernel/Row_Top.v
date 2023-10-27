module Row_Top#(
    parameter  COLINDEX_BASE_ADDR_1	= 48'h800000000,
    parameter  XVal_BASE_ADDR_1	= 48'h810000000,

    parameter  COLINDEX_BASE_ADDR_2	= 48'h820000000,
    parameter  XVal_BASE_ADDR_2	= 48'h830000000,

    parameter  COLINDEX_BASE_ADDR_3	= 48'h840000000,
    parameter  XVal_BASE_ADDR_3	= 48'h850000000,

    parameter  COLINDEX_BASE_ADDR_4	= 48'h860000000,
    parameter  XVal_BASE_ADDR_4	= 48'h870000000,

    parameter  Val_BASE_ADDR	= 48'h70000000,

    parameter Read_NNZ_ADDR_BASE = 48'h60000000,

    parameter Yi_Base_ADDR = 48'h50000000
)
(
    input wire clk,
    input wire rstn,
    input wire [1:0] Ctrl_sig_Val,
    input wire [1:0] Ctrl_sig_Xi,
    input wire [1:0] Ctrl_sig_Yi,
    input wire [31:0] Row_Num,
    
    input wire [31:0] NNZ_Num,

    input wire Calc_Begin,
    output wire Calc_End,


    output wire [3-1 : 0] m_axi_NNZ_arid,
    (*mark_debug = "true"*)
    output wire [48-1 : 0] m_axi_NNZ_araddr,
    output wire [7 : 0] m_axi_NNZ_arlen,
    output wire [2 : 0] m_axi_NNZ_arsize,
    output wire [1 : 0] m_axi_NNZ_arburst,
    output wire  m_axi_NNZ_arlock,
    output wire [3 : 0] m_axi_NNZ_arcache,
    output wire [2 : 0] m_axi_NNZ_arprot,
    output wire [3 : 0] m_axi_NNZ_arqos,
    (*mark_debug = "true"*)
    output wire  m_axi_NNZ_arvalid,
    (*mark_debug = "true"*)
    input wire  m_axi_NNZ_arready,
    input wire [3-1 : 0] m_axi_NNZ_rid,
    (*mark_debug = "true"*)
    input wire [32-1 : 0] m_axi_NNZ_rdata,
    input wire [1 : 0] m_axi_NNZ_rresp,
    (*mark_debug = "true"*)
    input wire  m_axi_NNZ_rlast,
    (*mark_debug = "true"*)
    input wire  m_axi_NNZ_rvalid,
    (*mark_debug = "true"*)
    output wire  m_axi_NNZ_rready,

    
    //colIndex Buffer
    
    output wire [1-1 : 0]   Kernel1_m_axi_colIndex_arid,
    (*mark_debug = "true"*)
    output wire [48-1 : 0]  Kernel1_m_axi_colIndex_araddr,
    output wire [7 : 0]     Kernel1_m_axi_colIndex_arlen,
    output wire [2 : 0]     Kernel1_m_axi_colIndex_arsize,
    output wire [1 : 0]     Kernel1_m_axi_colIndex_arburst,
    output wire             Kernel1_m_axi_colIndex_arlock,
    output wire [3 : 0]     Kernel1_m_axi_colIndex_arcache,
    output wire [2 : 0]     Kernel1_m_axi_colIndex_arprot,
    output wire [3 : 0]     Kernel1_m_axi_colIndex_arqos,
    (*mark_debug = "true"*)
    output wire             Kernel1_m_axi_colIndex_arvalid,
    (*mark_debug = "true"*)
    input wire              Kernel1_m_axi_colIndex_arready,
    input wire [1-1 : 0]    Kernel1_m_axi_colIndex_rid,
    input wire [32-1 : 0]   Kernel1_m_axi_colIndex_rdata,
    input wire [1 : 0]      Kernel1_m_axi_colIndex_rresp,
    (*mark_debug = "true"*)
    input wire              Kernel1_m_axi_colIndex_rlast,
    (*mark_debug = "true"*)
    input wire              Kernel1_m_axi_colIndex_rvalid,
    (*mark_debug = "true"*)
    output wire             Kernel1_m_axi_colIndex_rready,

//Xi Buffer
    output wire [1-1 : 0]   Kernel1_m_axi_Xi_arid,
    (*mark_debug = "true"*)
    output wire [48-1 : 0]  Kernel1_m_axi_Xi_araddr,
    output wire [7 : 0]     Kernel1_m_axi_Xi_arlen,
    output wire [2 : 0]     Kernel1_m_axi_Xi_arsize,
    output wire [1 : 0]     Kernel1_m_axi_Xi_arburst,
    output wire             Kernel1_m_axi_Xi_arlock,
    output wire [3 : 0]     Kernel1_m_axi_Xi_arcache,
    output wire [2 : 0]     Kernel1_m_axi_Xi_arprot,
    output wire [3 : 0]     Kernel1_m_axi_Xi_arqos,
    (*mark_debug = "true"*)
    output wire             Kernel1_m_axi_Xi_arvalid,
    (*mark_debug = "true"*)
    input wire              Kernel1_m_axi_Xi_arready,
    input wire [1-1 : 0]    Kernel1_m_axi_Xi_rid,
    input  wire [64-1 : 0]  Kernel1_m_axi_Xi_rdata,
    input wire [1 : 0]      Kernel1_m_axi_Xi_rresp,
    (*mark_debug = "true"*)
    input wire              Kernel1_m_axi_Xi_rlast,
    (*mark_debug = "true"*)
    input wire              Kernel1_m_axi_Xi_rvalid,
    (*mark_debug = "true"*)
    output wire             Kernel1_m_axi_Xi_rready,

   //colIndex Buffer
    output wire [1-1 : 0]   Kernel2_m_axi_colIndex_arid,
    output wire [48-1 : 0]  Kernel2_m_axi_colIndex_araddr,
    output wire [7 : 0]     Kernel2_m_axi_colIndex_arlen,
    output wire [2 : 0]     Kernel2_m_axi_colIndex_arsize,
    output wire [1 : 0]     Kernel2_m_axi_colIndex_arburst,
    output wire             Kernel2_m_axi_colIndex_arlock,
    output wire [3 : 0]     Kernel2_m_axi_colIndex_arcache,
    output wire [2 : 0]     Kernel2_m_axi_colIndex_arprot,
    output wire [3 : 0]     Kernel2_m_axi_colIndex_arqos,
    output wire             Kernel2_m_axi_colIndex_arvalid,
    input wire              Kernel2_m_axi_colIndex_arready,
    input wire [1-1 : 0]    Kernel2_m_axi_colIndex_rid,
    input wire [32-1 : 0]   Kernel2_m_axi_colIndex_rdata,
    input wire [1 : 0]      Kernel2_m_axi_colIndex_rresp,
    input wire              Kernel2_m_axi_colIndex_rlast,
    input wire              Kernel2_m_axi_colIndex_rvalid,
    output wire             Kernel2_m_axi_colIndex_rready,

//Xi Buffer
    output wire [1-1 : 0]   Kernel2_m_axi_Xi_arid,
    output wire [48-1 : 0]  Kernel2_m_axi_Xi_araddr,
    output wire [7 : 0]     Kernel2_m_axi_Xi_arlen,
    output wire [2 : 0]     Kernel2_m_axi_Xi_arsize,
    output wire [1 : 0]     Kernel2_m_axi_Xi_arburst,
    output wire             Kernel2_m_axi_Xi_arlock,
    output wire [3 : 0]     Kernel2_m_axi_Xi_arcache,
    output wire [2 : 0]     Kernel2_m_axi_Xi_arprot,
    output wire [3 : 0]     Kernel2_m_axi_Xi_arqos,
    output wire             Kernel2_m_axi_Xi_arvalid,
    input wire              Kernel2_m_axi_Xi_arready,
    input wire [1-1 : 0]    Kernel2_m_axi_Xi_rid,
    input  wire [64-1 : 0]  Kernel2_m_axi_Xi_rdata,
    input wire [1 : 0]      Kernel2_m_axi_Xi_rresp,
    input wire              Kernel2_m_axi_Xi_rlast,
    input wire              Kernel2_m_axi_Xi_rvalid,
    output wire             Kernel2_m_axi_Xi_rready,

   //colIndex Buffer
    output wire [1-1 : 0]   Kernel3_m_axi_colIndex_arid,
    output wire [48-1 : 0]  Kernel3_m_axi_colIndex_araddr,
    output wire [7 : 0]     Kernel3_m_axi_colIndex_arlen,
    output wire [2 : 0]     Kernel3_m_axi_colIndex_arsize,
    output wire [1 : 0]     Kernel3_m_axi_colIndex_arburst,
    output wire             Kernel3_m_axi_colIndex_arlock,
    output wire [3 : 0]     Kernel3_m_axi_colIndex_arcache,
    output wire [2 : 0]     Kernel3_m_axi_colIndex_arprot,
    output wire [3 : 0]     Kernel3_m_axi_colIndex_arqos,
    output wire             Kernel3_m_axi_colIndex_arvalid,
    input wire              Kernel3_m_axi_colIndex_arready,
    input wire [1-1 : 0]    Kernel3_m_axi_colIndex_rid,
    input wire [32-1 : 0]   Kernel3_m_axi_colIndex_rdata,
    input wire [1 : 0]      Kernel3_m_axi_colIndex_rresp,
    input wire              Kernel3_m_axi_colIndex_rlast,
    input wire              Kernel3_m_axi_colIndex_rvalid,
    output wire             Kernel3_m_axi_colIndex_rready,

//Xi Buffer
    output wire [1-1 : 0]   Kernel3_m_axi_Xi_arid,
    output wire [48-1 : 0]  Kernel3_m_axi_Xi_araddr,
    output wire [7 : 0]     Kernel3_m_axi_Xi_arlen,
    output wire [2 : 0]     Kernel3_m_axi_Xi_arsize,
    output wire [1 : 0]     Kernel3_m_axi_Xi_arburst,
    output wire             Kernel3_m_axi_Xi_arlock,
    output wire [3 : 0]     Kernel3_m_axi_Xi_arcache,
    output wire [2 : 0]     Kernel3_m_axi_Xi_arprot,
    output wire [3 : 0]     Kernel3_m_axi_Xi_arqos,
    output wire             Kernel3_m_axi_Xi_arvalid,
    input wire              Kernel3_m_axi_Xi_arready,
    input wire [1-1 : 0]    Kernel3_m_axi_Xi_rid,
    input  wire [64-1 : 0]  Kernel3_m_axi_Xi_rdata,
    input wire [1 : 0]      Kernel3_m_axi_Xi_rresp,
    input wire              Kernel3_m_axi_Xi_rlast,
    input wire              Kernel3_m_axi_Xi_rvalid,
    output wire             Kernel3_m_axi_Xi_rready,

    //colIndex Buffer
    output wire [1-1 : 0]   Kernel4_m_axi_colIndex_arid,
    output wire [48-1 : 0]  Kernel4_m_axi_colIndex_araddr,
    output wire [7 : 0]     Kernel4_m_axi_colIndex_arlen,
    output wire [2 : 0]     Kernel4_m_axi_colIndex_arsize,
    output wire [1 : 0]     Kernel4_m_axi_colIndex_arburst,
    output wire             Kernel4_m_axi_colIndex_arlock,
    output wire [3 : 0]     Kernel4_m_axi_colIndex_arcache,
    output wire [2 : 0]     Kernel4_m_axi_colIndex_arprot,
    output wire [3 : 0]     Kernel4_m_axi_colIndex_arqos,
    output wire             Kernel4_m_axi_colIndex_arvalid,
    input wire              Kernel4_m_axi_colIndex_arready,
    input wire [1-1 : 0]    Kernel4_m_axi_colIndex_rid,
    input wire [32-1 : 0]   Kernel4_m_axi_colIndex_rdata,
    input wire [1 : 0]      Kernel4_m_axi_colIndex_rresp,
    input wire              Kernel4_m_axi_colIndex_rlast,
    input wire              Kernel4_m_axi_colIndex_rvalid,
    output wire             Kernel4_m_axi_colIndex_rready,

//Xi Buffer
    output wire [1-1 : 0]   Kernel4_m_axi_Xi_arid,
    output wire [48-1 : 0]  Kernel4_m_axi_Xi_araddr,
    output wire [7 : 0]     Kernel4_m_axi_Xi_arlen,
    output wire [2 : 0]     Kernel4_m_axi_Xi_arsize,
    output wire [1 : 0]     Kernel4_m_axi_Xi_arburst,
    output wire             Kernel4_m_axi_Xi_arlock,
    output wire [3 : 0]     Kernel4_m_axi_Xi_arcache,
    output wire [2 : 0]     Kernel4_m_axi_Xi_arprot,
    output wire [3 : 0]     Kernel4_m_axi_Xi_arqos,
    output wire             Kernel4_m_axi_Xi_arvalid,
    input wire              Kernel4_m_axi_Xi_arready,
    input wire [1-1 : 0]    Kernel4_m_axi_Xi_rid,
    input  wire [64-1 : 0]  Kernel4_m_axi_Xi_rdata,
    input wire [1 : 0]      Kernel4_m_axi_Xi_rresp,
    input wire              Kernel4_m_axi_Xi_rlast,
    input wire              Kernel4_m_axi_Xi_rvalid,
    output wire             Kernel4_m_axi_Xi_rready,


    output wire [3-1 : 0] m_axi_Val_arid,
    output wire [48-1 : 0] m_axi_Val_araddr,
    output wire [7 : 0] m_axi_Val_arlen,
    output wire [2 : 0] m_axi_Val_arsize,
    output wire [1 : 0] m_axi_Val_arburst,
    output wire  m_axi_Val_arlock,
    output wire [3 : 0] m_axi_Val_arcache,
    output wire [2 : 0] m_axi_Val_arprot,
    output wire [3 : 0] m_axi_Val_arqos,
    output wire  m_axi_Val_arvalid,
    input wire  m_axi_Val_arready,
    input wire [3-1 : 0] m_axi_Val_rid,
    input wire [64-1 : 0] m_axi_Val_rdata,
    input wire [1 : 0] m_axi_Val_rresp,
    input wire  m_axi_Val_rlast,
    input wire  m_axi_Val_rvalid,
    //HXZ
    output wire  m_axi_Val_rready,
    
    output wire [3-1 : 0] m_axi_Yi_awid,
    output wire [48-1 : 0] m_axi_Yi_awaddr,
    output wire [7 : 0] m_axi_Yi_awlen,
    output wire [2 : 0] m_axi_Yi_awsize,
    output wire [1 : 0] m_axi_Yi_awburst,
    output wire  m_axi_Yi_awlock,
    output wire [3 : 0] m_axi_Yi_awcache,
    output wire [2 : 0] m_axi_Yi_awprot,
    output wire [3 : 0] m_axi_Yi_awqos,
    (*mark_debug = "true"*)
    output wire  m_axi_Yi_awvalid,
    (*mark_debug = "true"*)
    input wire  m_axi_Yi_awready,
    output wire [64-1 : 0] m_axi_Yi_wdata,
    output wire [64/8-1 : 0] m_axi_Yi_wstrb,
    output wire  m_axi_Yi_wlast,
    (*mark_debug = "true"*)
    output wire  m_axi_Yi_wvalid,
    (*mark_debug = "true"*)
    input wire  m_axi_Yi_wready,
    input wire [3-1 : 0] m_axi_Yi_bid,
    input wire [1 : 0] m_axi_Yi_bresp,
    (*mark_debug = "true"*)
    input wire  m_axi_Yi_bvalid,
    output wire  m_axi_Yi_bready
);
    wire [63:0] Row_Kernel_1_output_data;
    wire [63:0] Row_Kernel_2_output_data;
    wire [63:0] Row_Kernel_3_output_data;
    wire [63:0] Row_Kernel_4_output_data;
    
    wire [31:0] Row_Kernel_1_S_AXIS_TIMES_tdata;
    wire [31:0] Row_Kernel_2_S_AXIS_TIMES_tdata;
    wire [31:0] Row_Kernel_3_S_AXIS_TIMES_tdata;
    wire [31:0] Row_Kernel_4_S_AXIS_TIMES_tdata;
    
    wire [63:0] Row_Kernel_1_Radix_Converter_Val_input_data;
    wire [63:0] Row_Kernel_2_Radix_Converter_Val_input_data;
    wire [63:0] Row_Kernel_3_Radix_Converter_Val_input_data;
    wire [63:0] Row_Kernel_4_Radix_Converter_Val_input_data;
    

    reg Kernel_Begin_1=0;
    reg Kernel_Begin_2=0;
    reg Kernel_Begin_3=0;
    reg Kernel_Begin_4=0;

    reg [3:0] Ctrl_State=0;
    reg [3:0] Read_NNZ_State=0;
    (*mark_debug = "true"*)
    reg [31:0] Wb_ROW_Num;
    assign Calc_End = Ctrl_State == 3 & Wb_ROW_Num !=0;
    reg NNZ_Read_Begin =0;

    Row_Kernel #(
        .COLINDEX_BASE_ADDR(COLINDEX_BASE_ADDR_1),
        .XVal_BASE_ADDR(XVal_BASE_ADDR_1)
    )Row_Kernel_1(
    .rstn(rstn & Ctrl_State ==2),
    .clk(clk),

    //Config
    .Ctrl_sig_Val({0,Ctrl_sig_Val}),
    .Ctrl_sig_Xi({0,Ctrl_sig_Xi}),
    .Ctrl_sig_Yi({0,Ctrl_sig_Yi}),

    .Read_Begin(Kernel_Begin_1),
    .Read_Length(NNZ_Num),

    //Row NNZ
    .S_AXIS_TIMES_tdata(Row_Kernel_1_S_AXIS_TIMES_tdata),
    .S_AXIS_TIMES_tready(Row_Kernel_1_S_AXIS_TIMES_tready),
    .S_AXIS_TIMES_tvalid(Row_Kernel_1_S_AXIS_TIMES_tvalid),

    //ValueBus
    .Radix_Converter_Val_input_valid(Row_Kernel_1_Radix_Converter_Val_input_valid & Row_Kernel_1_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_ready(Row_Kernel_1_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_data(Row_Kernel_1_Radix_Converter_Val_input_data),
    //output
    .output_valid(Row_Kernel_1_output_valid),
    .output_ready(~Yi_fifo_1_full),
    .output_data(Row_Kernel_1_output_data),

    //colIndex Buffer
    .m_axi_colIndex_arid(Kernel1_m_axi_colIndex_arid),
    .m_axi_colIndex_araddr(Kernel1_m_axi_colIndex_araddr),
    .m_axi_colIndex_arlen(Kernel1_m_axi_colIndex_arlen),
    .m_axi_colIndex_arsize(Kernel1_m_axi_colIndex_arsize),
    .m_axi_colIndex_arburst(Kernel1_m_axi_colIndex_arburst),
    .m_axi_colIndex_arlock(Kernel1_m_axi_colIndex_arlock),
    .m_axi_colIndex_arcache(Kernel1_m_axi_colIndex_arcache),
    .m_axi_colIndex_arprot(Kernel1_m_axi_colIndex_arprot),
    .m_axi_colIndex_arqos(Kernel1_m_axi_colIndex_arqos),
    .m_axi_colIndex_arvalid(Kernel1_m_axi_colIndex_arvalid),
    .m_axi_colIndex_arready(Kernel1_m_axi_colIndex_arready),
    .m_axi_colIndex_rid(Kernel1_m_axi_colIndex_rid),
    .m_axi_colIndex_rdata(Kernel1_m_axi_colIndex_rdata),
    .m_axi_colIndex_rresp(Kernel1_m_axi_colIndex_rresp),
    .m_axi_colIndex_rlast(Kernel1_m_axi_colIndex_rlast),
    .m_axi_colIndex_rvalid(Kernel1_m_axi_colIndex_rvalid),
    .m_axi_colIndex_rready(Kernel1_m_axi_colIndex_rready),

//Xi Buffer
    .m_axi_Xi_arid(Kernel1_m_axi_Xi_arid),
    .m_axi_Xi_araddr(Kernel1_m_axi_Xi_araddr),
    .m_axi_Xi_arlen(Kernel1_m_axi_Xi_arlen),
    .m_axi_Xi_arsize(Kernel1_m_axi_Xi_arsize),
    .m_axi_Xi_arburst(Kernel1_m_axi_Xi_arburst),
    .m_axi_Xi_arlock(Kernel1_m_axi_Xi_arlock),
    .m_axi_Xi_arcache(Kernel1_m_axi_Xi_arcache),
    .m_axi_Xi_arprot(Kernel1_m_axi_Xi_arprot),
    .m_axi_Xi_arqos(Kernel1_m_axi_Xi_arqos),
    .m_axi_Xi_arvalid(Kernel1_m_axi_Xi_arvalid),
    .m_axi_Xi_arready(Kernel1_m_axi_Xi_arready),
    .m_axi_Xi_rid(Kernel1_m_axi_Xi_rid),
    .m_axi_Xi_rdata(Kernel1_m_axi_Xi_rdata),
    .m_axi_Xi_rresp(Kernel1_m_axi_Xi_rresp),
    .m_axi_Xi_rlast(Kernel1_m_axi_Xi_rlast),
    .m_axi_Xi_rvalid(Kernel1_m_axi_Xi_rvalid),
    .m_axi_Xi_rready(Kernel1_m_axi_Xi_rready)

    );
    Row_Kernel #(
        .COLINDEX_BASE_ADDR(COLINDEX_BASE_ADDR_2),
        .XVal_BASE_ADDR(XVal_BASE_ADDR_2)
    )Row_Kernel_2(
    .rstn(rstn & Ctrl_State ==2),
    .clk(clk),

    //Config
    .Ctrl_sig_Val({0,Ctrl_sig_Val}),
    .Ctrl_sig_Xi({0,Ctrl_sig_Xi}),
    .Ctrl_sig_Yi({0,Ctrl_sig_Yi}),

    .Read_Begin(Kernel_Begin_2),
    .Read_Length(NNZ_Num),

    //Row NNZ
    .S_AXIS_TIMES_tdata(Row_Kernel_2_S_AXIS_TIMES_tdata),
    .S_AXIS_TIMES_tready(Row_Kernel_2_S_AXIS_TIMES_tready),
    .S_AXIS_TIMES_tvalid(Row_Kernel_2_S_AXIS_TIMES_tvalid),

    //ValueBus
    .Radix_Converter_Val_input_valid(Row_Kernel_2_Radix_Converter_Val_input_valid & Row_Kernel_2_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_ready(Row_Kernel_2_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_data(Row_Kernel_2_Radix_Converter_Val_input_data),


    //output
    .output_valid(Row_Kernel_2_output_valid),
    .output_ready(~Yi_fifo_2_full),
    .output_data(Row_Kernel_2_output_data),

    //colIndex Buffer
    .m_axi_colIndex_arid(Kernel2_m_axi_colIndex_arid),
    .m_axi_colIndex_araddr(Kernel2_m_axi_colIndex_araddr),
    .m_axi_colIndex_arlen(Kernel2_m_axi_colIndex_arlen),
    .m_axi_colIndex_arsize(Kernel2_m_axi_colIndex_arsize),
    .m_axi_colIndex_arburst(Kernel2_m_axi_colIndex_arburst),
    .m_axi_colIndex_arlock(Kernel2_m_axi_colIndex_arlock),
    .m_axi_colIndex_arcache(Kernel2_m_axi_colIndex_arcache),
    .m_axi_colIndex_arprot(Kernel2_m_axi_colIndex_arprot),
    .m_axi_colIndex_arqos(Kernel2_m_axi_colIndex_arqos),
    .m_axi_colIndex_arvalid(Kernel2_m_axi_colIndex_arvalid),
    .m_axi_colIndex_arready(Kernel2_m_axi_colIndex_arready),
    .m_axi_colIndex_rid(Kernel2_m_axi_colIndex_rid),
    .m_axi_colIndex_rdata(Kernel2_m_axi_colIndex_rdata),
    .m_axi_colIndex_rresp(Kernel2_m_axi_colIndex_rresp),
    .m_axi_colIndex_rlast(Kernel2_m_axi_colIndex_rlast),
    .m_axi_colIndex_rvalid(Kernel2_m_axi_colIndex_rvalid),
    .m_axi_colIndex_rready(Kernel2_m_axi_colIndex_rready),

//Xi Buffer
    .m_axi_Xi_arid(Kernel2_m_axi_Xi_arid),
    .m_axi_Xi_araddr(Kernel2_m_axi_Xi_araddr),
    .m_axi_Xi_arlen(Kernel2_m_axi_Xi_arlen),
    .m_axi_Xi_arsize(Kernel2_m_axi_Xi_arsize),
    .m_axi_Xi_arburst(Kernel2_m_axi_Xi_arburst),
    .m_axi_Xi_arlock(Kernel2_m_axi_Xi_arlock),
    .m_axi_Xi_arcache(Kernel2_m_axi_Xi_arcache),
    .m_axi_Xi_arprot(Kernel2_m_axi_Xi_arprot),
    .m_axi_Xi_arqos(Kernel2_m_axi_Xi_arqos),
    .m_axi_Xi_arvalid(Kernel2_m_axi_Xi_arvalid),
    .m_axi_Xi_arready(Kernel2_m_axi_Xi_arready),
    .m_axi_Xi_rid(Kernel2_m_axi_Xi_rid),
    .m_axi_Xi_rdata(Kernel2_m_axi_Xi_rdata),
    .m_axi_Xi_rresp(Kernel2_m_axi_Xi_rresp),
    .m_axi_Xi_rlast(Kernel2_m_axi_Xi_rlast),
    .m_axi_Xi_rvalid(Kernel2_m_axi_Xi_rvalid),
    .m_axi_Xi_rready(Kernel2_m_axi_Xi_rready)

    );
    Row_Kernel #(
        .COLINDEX_BASE_ADDR(COLINDEX_BASE_ADDR_3),
        .XVal_BASE_ADDR(XVal_BASE_ADDR_3)
    )Row_Kernel_3(
    .rstn(rstn & Ctrl_State ==2),
    .clk(clk),

    //Config
    .Ctrl_sig_Val({0,Ctrl_sig_Val}),
    .Ctrl_sig_Xi({0,Ctrl_sig_Xi}),
    .Ctrl_sig_Yi({0,Ctrl_sig_Yi}),

    .Read_Begin(Kernel_Begin_3),
    .Read_Length(NNZ_Num),

    //Row NNZ
    .S_AXIS_TIMES_tdata(Row_Kernel_3_S_AXIS_TIMES_tdata),
    .S_AXIS_TIMES_tready(Row_Kernel_3_S_AXIS_TIMES_tready),
    .S_AXIS_TIMES_tvalid(Row_Kernel_3_S_AXIS_TIMES_tvalid),

    //ValueBus
    .Radix_Converter_Val_input_valid(Row_Kernel_3_Radix_Converter_Val_input_valid & Row_Kernel_3_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_ready(Row_Kernel_3_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_data(Row_Kernel_3_Radix_Converter_Val_input_data),


    //output
    .output_valid(Row_Kernel_3_output_valid),
    .output_ready(~Yi_fifo_3_full),
    .output_data(Row_Kernel_3_output_data),

    //colIndex Buffer
    .m_axi_colIndex_arid(Kernel3_m_axi_colIndex_arid),
    .m_axi_colIndex_araddr(Kernel3_m_axi_colIndex_araddr),
    .m_axi_colIndex_arlen(Kernel3_m_axi_colIndex_arlen),
    .m_axi_colIndex_arsize(Kernel3_m_axi_colIndex_arsize),
    .m_axi_colIndex_arburst(Kernel3_m_axi_colIndex_arburst),
    .m_axi_colIndex_arlock(Kernel3_m_axi_colIndex_arlock),
    .m_axi_colIndex_arcache(Kernel3_m_axi_colIndex_arcache),
    .m_axi_colIndex_arprot(Kernel3_m_axi_colIndex_arprot),
    .m_axi_colIndex_arqos(Kernel3_m_axi_colIndex_arqos),
    .m_axi_colIndex_arvalid(Kernel3_m_axi_colIndex_arvalid),
    .m_axi_colIndex_arready(Kernel3_m_axi_colIndex_arready),
    .m_axi_colIndex_rid(Kernel3_m_axi_colIndex_rid),
    .m_axi_colIndex_rdata(Kernel3_m_axi_colIndex_rdata),
    .m_axi_colIndex_rresp(Kernel3_m_axi_colIndex_rresp),
    .m_axi_colIndex_rlast(Kernel3_m_axi_colIndex_rlast),
    .m_axi_colIndex_rvalid(Kernel3_m_axi_colIndex_rvalid),
    .m_axi_colIndex_rready(Kernel3_m_axi_colIndex_rready),

//Xi Buffer
    .m_axi_Xi_arid(Kernel3_m_axi_Xi_arid),
    .m_axi_Xi_araddr(Kernel3_m_axi_Xi_araddr),
    .m_axi_Xi_arlen(Kernel3_m_axi_Xi_arlen),
    .m_axi_Xi_arsize(Kernel3_m_axi_Xi_arsize),
    .m_axi_Xi_arburst(Kernel3_m_axi_Xi_arburst),
    .m_axi_Xi_arlock(Kernel3_m_axi_Xi_arlock),
    .m_axi_Xi_arcache(Kernel3_m_axi_Xi_arcache),
    .m_axi_Xi_arprot(Kernel3_m_axi_Xi_arprot),
    .m_axi_Xi_arqos(Kernel3_m_axi_Xi_arqos),
    .m_axi_Xi_arvalid(Kernel3_m_axi_Xi_arvalid),
    .m_axi_Xi_arready(Kernel3_m_axi_Xi_arready),
    .m_axi_Xi_rid(Kernel3_m_axi_Xi_rid),
    .m_axi_Xi_rdata(Kernel3_m_axi_Xi_rdata),
    .m_axi_Xi_rresp(Kernel3_m_axi_Xi_rresp),
    .m_axi_Xi_rlast(Kernel3_m_axi_Xi_rlast),
    .m_axi_Xi_rvalid(Kernel3_m_axi_Xi_rvalid),
    .m_axi_Xi_rready(Kernel3_m_axi_Xi_rready)

    );
    Row_Kernel #(
        .COLINDEX_BASE_ADDR(COLINDEX_BASE_ADDR_4),
        .XVal_BASE_ADDR(XVal_BASE_ADDR_4)
    )Row_Kernel_4(
    .rstn(rstn & Ctrl_State ==2),
    .clk(clk),

    //Config
    .Ctrl_sig_Val({0,Ctrl_sig_Val}),
    .Ctrl_sig_Xi({0,Ctrl_sig_Xi}),
    .Ctrl_sig_Yi({0,Ctrl_sig_Yi}),

    .Read_Begin(Kernel_Begin_4),
    .Read_Length(NNZ_Num),

    //Row NNZ
    .S_AXIS_TIMES_tdata(Row_Kernel_4_S_AXIS_TIMES_tdata),
    .S_AXIS_TIMES_tready(Row_Kernel_4_S_AXIS_TIMES_tready),
    .S_AXIS_TIMES_tvalid(Row_Kernel_4_S_AXIS_TIMES_tvalid),

    //ValueBus
    .Radix_Converter_Val_input_valid(Row_Kernel_4_Radix_Converter_Val_input_valid  & Row_Kernel_3_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_ready(Row_Kernel_4_Radix_Converter_Val_input_ready),
    .Radix_Converter_Val_input_data(Row_Kernel_4_Radix_Converter_Val_input_data),

    //output
    .output_valid(Row_Kernel_4_output_valid),
    .output_ready(~Yi_fifo_4_full),
    .output_data(Row_Kernel_4_output_data),    

    //colIndex Buffer
    .m_axi_colIndex_arid(Kernel4_m_axi_colIndex_arid),
    .m_axi_colIndex_araddr(Kernel4_m_axi_colIndex_araddr),
    .m_axi_colIndex_arlen(Kernel4_m_axi_colIndex_arlen),
    .m_axi_colIndex_arsize(Kernel4_m_axi_colIndex_arsize),
    .m_axi_colIndex_arburst(Kernel4_m_axi_colIndex_arburst),
    .m_axi_colIndex_arlock(Kernel4_m_axi_colIndex_arlock),
    .m_axi_colIndex_arcache(Kernel4_m_axi_colIndex_arcache),
    .m_axi_colIndex_arprot(Kernel4_m_axi_colIndex_arprot),
    .m_axi_colIndex_arqos(Kernel4_m_axi_colIndex_arqos),
    .m_axi_colIndex_arvalid(Kernel4_m_axi_colIndex_arvalid),
    .m_axi_colIndex_arready(Kernel4_m_axi_colIndex_arready),
    .m_axi_colIndex_rid(Kernel4_m_axi_colIndex_rid),
    .m_axi_colIndex_rdata(Kernel4_m_axi_colIndex_rdata),
    .m_axi_colIndex_rresp(Kernel4_m_axi_colIndex_rresp),
    .m_axi_colIndex_rlast(Kernel4_m_axi_colIndex_rlast),
    .m_axi_colIndex_rvalid(Kernel4_m_axi_colIndex_rvalid),
    .m_axi_colIndex_rready(Kernel4_m_axi_colIndex_rready),

//Xi Buffer
    .m_axi_Xi_arid(Kernel4_m_axi_Xi_arid),
    .m_axi_Xi_araddr(Kernel4_m_axi_Xi_araddr),
    .m_axi_Xi_arlen(Kernel4_m_axi_Xi_arlen),
    .m_axi_Xi_arsize(Kernel4_m_axi_Xi_arsize),
    .m_axi_Xi_arburst(Kernel4_m_axi_Xi_arburst),
    .m_axi_Xi_arlock(Kernel4_m_axi_Xi_arlock),
    .m_axi_Xi_arcache(Kernel4_m_axi_Xi_arcache),
    .m_axi_Xi_arprot(Kernel4_m_axi_Xi_arprot),
    .m_axi_Xi_arqos(Kernel4_m_axi_Xi_arqos),
    .m_axi_Xi_arvalid(Kernel4_m_axi_Xi_arvalid),
    .m_axi_Xi_arready(Kernel4_m_axi_Xi_arready),
    .m_axi_Xi_rid(Kernel4_m_axi_Xi_rid),
    .m_axi_Xi_rdata(Kernel4_m_axi_Xi_rdata),
    .m_axi_Xi_rresp(Kernel4_m_axi_Xi_rresp),
    .m_axi_Xi_rlast(Kernel4_m_axi_Xi_rlast),
    .m_axi_Xi_rvalid(Kernel4_m_axi_Xi_rvalid),
    .m_axi_Xi_rready(Kernel4_m_axi_Xi_rready)

    );
    reg [31:0] Read_NNZ_ADDR = 0;
    axi_master_r_single #(
        .C_M_AXI_DATA_WIDTH(32),
        .C_M_AXI_TARGET_SLAVE_BASE_ADDR(0)
    ) axi_master_r_single_Row_NNZ(
        .m_axi_init_axi_read(NNZ_Read_Begin),
        .m_axi_r_done(),
        .m_axi_aclk(clk),
        .m_axi_aresetn(rstn),

        .m_axi_arid(m_axi_NNZ_arid),
        .m_axi_araddr(m_axi_NNZ_araddr),
        .m_axi_arlen(m_axi_NNZ_arlen),
        .m_axi_arsize(m_axi_NNZ_arsize),
        .m_axi_arburst(m_axi_NNZ_arburst),
        .m_axi_arlock(m_axi_NNZ_arlock),
        .m_axi_arcache(m_axi_NNZ_arcache),
        .m_axi_arprot(m_axi_NNZ_arprot),
        .m_axi_arqos(m_axi_NNZ_arqos),
        .m_axi_arvalid(m_axi_NNZ_arvalid),
        .m_axi_arready(m_axi_NNZ_arready),
        .m_axi_rid(m_axi_NNZ_rid),
        .m_axi_rdata(m_axi_NNZ_rdata),
        .m_axi_rresp(m_axi_NNZ_rresp),
        .m_axi_rlast(m_axi_NNZ_rlast),
        .m_axi_rvalid(m_axi_NNZ_rvalid),
        .m_axi_rready(m_axi_NNZ_rready),

        .read_length(1),
        .read_base_addr(Read_NNZ_ADDR)
    );
    reg [3:0] Fifo_wait_for_data=0;
    
    Fifo NNZ_fifo_1(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Fifo_wait_for_data ==1 & m_axi_NNZ_rvalid),        
        .rd_en(Row_Kernel_1_S_AXIS_TIMES_tready & Ctrl_State ==2),        
        //HXZ
        `ifdef __synthesis__
        .data_in(m_axi_NNZ_rdata),
        `else  
        .data_in(15),
        `endif 
        .data_out(Row_Kernel_1_S_AXIS_TIMES_tdata),  
        .empty(NNZ_fifo_1_empty),   
        .full(NNZ_fifo_1_full)     
    );
    Fifo NNZ_fifo_2(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Fifo_wait_for_data ==2 & m_axi_NNZ_rvalid),        
        .rd_en(Row_Kernel_2_S_AXIS_TIMES_tready & Ctrl_State ==2),        
        //HXZ
        `ifdef __synthesis__
        .data_in(m_axi_NNZ_rdata),
        `else  
        .data_in(15),
        `endif   
        .data_out(Row_Kernel_2_S_AXIS_TIMES_tdata),  
        .empty(NNZ_fifo_2_empty),   
        .full(NNZ_fifo_2_full)     
    );
    Fifo NNZ_fifo_3(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Fifo_wait_for_data ==3 & m_axi_NNZ_rvalid),        
        .rd_en(Row_Kernel_3_S_AXIS_TIMES_tready & Ctrl_State ==2),        
        //HXZ
        `ifdef __synthesis__
        .data_in(m_axi_NNZ_rdata),
        `else  
        .data_in(15),
        `endif   
        .data_out(Row_Kernel_3_S_AXIS_TIMES_tdata),  
        .empty(NNZ_fifo_3_empty),   
        .full(NNZ_fifo_3_full)     
    );
    Fifo NNZ_fifo_4(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Fifo_wait_for_data ==4 & m_axi_NNZ_rvalid),        
        .rd_en(Row_Kernel_4_S_AXIS_TIMES_tready & Ctrl_State ==2),        
        //HXZ
        `ifdef __synthesis__
        .data_in(m_axi_NNZ_rdata),
        `else  
        .data_in(15),
        `endif 
        .data_out(Row_Kernel_4_S_AXIS_TIMES_tdata),  
        .empty(NNZ_fifo_4_empty),   
        .full(NNZ_fifo_4_full)     
    );
    wire [3:0] NNZ_Fifo_Ready;
    assign NNZ_Fifo_Ready = ((Ctrl_sig_Val ==0)?
                        (
                        NNZ_fifo_1_empty?1:
                        NNZ_fifo_2_empty?2:
                        NNZ_fifo_3_empty?3:
                        NNZ_fifo_4_empty?4:
                        (
                        ~NNZ_fifo_1_full?1:
                        ~NNZ_fifo_2_full?2:
                        ~NNZ_fifo_3_full?3:
                        ~NNZ_fifo_4_full?4:
                        0)
                        ):0)|
                        ((Ctrl_sig_Val ==1)?
                        (
                        NNZ_fifo_1_empty?1:
                        NNZ_fifo_2_empty?2:
                        (
                        ~NNZ_fifo_1_full?1:
                        ~NNZ_fifo_2_full?2:
                        0)
                        ):0)|
                        ((Ctrl_sig_Val ==2)?
                        (
                        NNZ_fifo_1_empty?1:
                        (
                        ~NNZ_fifo_1_full?1:
                        0)
                        ):0);




    reg Val_Read_Begin = 0;


    
    always @(posedge clk ) begin
        if(Ctrl_State==1 & NNZ_Fifo_Ready==0)begin
            if(Ctrl_sig_Val == 2)begin
                Kernel_Begin_1 <=1;
            end
            if(Ctrl_sig_Val == 1)begin
                Kernel_Begin_1 <=1;
                Kernel_Begin_2 <=1;
            end
            if(Ctrl_sig_Val == 0)begin
                Kernel_Begin_1 <=1;
                Kernel_Begin_2 <=1;
                Kernel_Begin_3 <=1;
                Kernel_Begin_4 <=1;
            end
            Val_Read_Begin <=1;
        end
        else begin
            Val_Read_Begin <=0;
            Kernel_Begin_1<=0;
            Kernel_Begin_2<=0;
            Kernel_Begin_3<=0;
            Kernel_Begin_4<=0;
        end
    end
    wire [31:0] Wb_ROW_Num_total;
    assign Wb_ROW_Num_total =   Row_Num;
    always @(posedge clk ) begin
        if(~rstn)begin
            Wb_ROW_Num<=0;
        end
        if(m_axi_Yi_awvalid & m_axi_Yi_awready )begin
             Wb_ROW_Num<=Wb_ROW_Num +1;
        end 
        else if(Ctrl_State == 0 & Calc_Begin) begin
            Wb_ROW_Num <=0;
        end 
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            Ctrl_State<=0;
        end
        if(Ctrl_State ==0)begin //等待开始计算的信号开始
            if(Calc_Begin)begin
                Ctrl_State <=1;
            end
            else begin
                Ctrl_State <=0;
            end
        end
        if(Ctrl_State == 1)begin//计算开始，首先填满Fifo
            if(NNZ_Fifo_Ready==0)begin
                Ctrl_State <=2;



            end
            else begin
                Ctrl_State<=1;
            end
        end
        if(Ctrl_State == 2)begin //正在计算1000
            if(Wb_ROW_Num >= Wb_ROW_Num_total)begin
                Ctrl_State <=3;
            end
        end
        if(Ctrl_State ==3)begin
            Ctrl_State<=3;
        end

    end

    reg [31:0] NNZ_ADDR_DEMUX [3:0];
    always @(posedge clk ) begin
        if(~rstn | Ctrl_State ==0)begin
            Read_NNZ_State <=0;
            Fifo_wait_for_data<=0;
            NNZ_Read_Begin<=0;
//            for(integer  i=0;i< 8;i = i+1)begin
//                NNZ_ADDR_DEMUX[i] <=0;
//            end
            NNZ_ADDR_DEMUX[0] <=0;
            NNZ_ADDR_DEMUX[1] <=0;
            NNZ_ADDR_DEMUX[2] <=0;
            NNZ_ADDR_DEMUX[3] <=0;
            
        end
        else begin
            if(Read_NNZ_State ==0)begin
                if(NNZ_Fifo_Ready !=0)begin
                    Fifo_wait_for_data<=NNZ_Fifo_Ready;
                    Read_NNZ_ADDR <= 48'h1000000 * (NNZ_Fifo_Ready -1)+ NNZ_ADDR_DEMUX[NNZ_Fifo_Ready -1] + Read_NNZ_ADDR_BASE;

                    NNZ_ADDR_DEMUX[NNZ_Fifo_Ready -1] <= NNZ_ADDR_DEMUX[NNZ_Fifo_Ready -1] +4;
                    
                    NNZ_Read_Begin <=1;

                    Read_NNZ_State<=1;
                end
            end

            if(Read_NNZ_State==1)begin
                NNZ_Read_Begin <=0;
                if(m_axi_NNZ_rvalid)begin
                    Read_NNZ_State<=0;
                end
            end
        end

    end
    assign Row_Kernel_1_S_AXIS_TIMES_tvalid = Row_Kernel_1_S_AXIS_TIMES_tready;
    assign Row_Kernel_2_S_AXIS_TIMES_tvalid = Row_Kernel_2_S_AXIS_TIMES_tready;
    assign Row_Kernel_3_S_AXIS_TIMES_tvalid = Row_Kernel_3_S_AXIS_TIMES_tready;
    assign Row_Kernel_4_S_AXIS_TIMES_tvalid = Row_Kernel_4_S_AXIS_TIMES_tready;
    
    // wire m_axi_Val_rready_self;
    reg Fifo_Val_wr_en_ctrl;
    wire m_axi_Val_arvalid_self;

            axi_master_r #(
        .C_M_AXI_DATA_WIDTH(64),
        .C_M_AXI_TARGET_SLAVE_BASE_ADDR(Val_BASE_ADDR),
        .C_M_AXI_BURST_LEN(16)
    ) axi_master_r_Val(
    .m_axi_init_axi_read(Val_Read_Begin),
    .m_axi_r_done(),
    .m_axi_aclk(clk),
    .m_axi_aresetn(rstn),
    .m_axi_arid(m_axi_Val_arid),
    .m_axi_araddr(m_axi_Val_araddr),
    .m_axi_arlen(m_axi_Val_arlen),
    .m_axi_arsize(m_axi_Val_arsize),
    .m_axi_arburst(m_axi_Val_arburst),
    .m_axi_arlock(m_axi_Val_arlock),
    .m_axi_arcache(m_axi_Val_arcache),
    .m_axi_arprot(m_axi_Val_arprot),
    .m_axi_arqos(m_axi_Val_arqos),
    .m_axi_arvalid(m_axi_Val_arvalid),
    .m_axi_arready(m_axi_Val_arready),
    .m_axi_rid(m_axi_Val_rid),
    .m_axi_rdata(m_axi_Val_rdata),
    .m_axi_rresp(m_axi_Val_rresp),
    .m_axi_rlast(m_axi_Val_rlast),
    .m_axi_rvalid(m_axi_Val_rvalid),
    .m_axi_rready(m_axi_Val_rready_self),

    .read_length(NNZ_Num / 16),
    .read_ctrl(Fifo_Val_wr_en_ctrl),
    .read_base_addr(0)
    );
    // reg Val_Valid_Pre;
    wire Fifo_Val_needdata;
    wire Fifo_Val_noneeddata;
    // always @(posedge clk ) begin
    //     Val_Valid_Pre <= m_axi_Val_rvalid;
    // end
    wire [63:0] Fifo_Val_data_out;
    Fifo #(
        .DATA_WIDTH(64),
        .DEPTH(32),
        .MIN_THER(4),
        .MAX_THER(16)
    ) Fifo_Val(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(m_axi_Val_rready & m_axi_Val_rvalid),        
        .rd_en(Fifo_Val_rd_en),        
        .data_in(m_axi_Val_rdata),   
        .data_out(Fifo_Val_data_out),  
        .empty(Fifo_Val_empty),   
        .full(Fifo_Val_full),
        .needdata(Fifo_Val_needdata),
        .noneeddata(Fifo_Val_noneeddata)
    );

    assign m_axi_Val_rready = m_axi_Val_rready_self & ~Fifo_Val_full;
    // assign m_axi_Val_rready = m_axi_Val_rready_self & (
    //     (Ctrl_sig_Val ==2) ?Row_Kernel_1_Radix_Converter_Val_input_ready :0 |
    //     (Ctrl_sig_Val ==1) ?(Row_Kernel_1_Radix_Converter_Val_input_ready & 
    //                         Row_Kernel_2_Radix_Converter_Val_input_ready):0 |
    //     (Ctrl_sig_Val ==0) ?(Row_Kernel_1_Radix_Converter_Val_input_ready 
    //                         & Row_Kernel_2_Radix_Converter_Val_input_ready 
    //                         & Row_Kernel_3_Radix_Converter_Val_input_ready 
    //                         & Row_Kernel_4_Radix_Converter_Val_input_ready):0
    // );
    reg [2:0] Val_read_Status = 0;


    // assign m_axi_Val_arvalid = m_axi_Val_arvalid_self & Fifo_Val_wr_en_ctrl;
    always @(posedge clk ) begin
        if(~rstn)begin
            Val_read_Status <=0;
            Fifo_Val_wr_en_ctrl<=1;
        end
        else begin
            if(Val_read_Status==0)begin
                if(Fifo_Val_noneeddata)begin
                    Fifo_Val_wr_en_ctrl<=0;
                    Val_read_Status<= 1;
                end

            end
            if(Val_read_Status==1)begin
                if(Fifo_Val_needdata)begin
                    Fifo_Val_wr_en_ctrl<=1;
                    Val_read_Status<= 0;
                end
            end
        end
        
    end
    wire Fifo_Val_rd_ready;
    assign Fifo_Val_rd_ready = (Ctrl_sig_Val ==2) ? Row_Kernel_1_Radix_Converter_Val_input_ready: 0 |
                            (Ctrl_sig_Val ==1) ?    Row_Kernel_1_Radix_Converter_Val_input_ready & 
                                                    Row_Kernel_2_Radix_Converter_Val_input_ready: 0 |
                            (Ctrl_sig_Val ==0) ?    Row_Kernel_1_Radix_Converter_Val_input_ready & 
                                                    Row_Kernel_2_Radix_Converter_Val_input_ready &
                                                    Row_Kernel_3_Radix_Converter_Val_input_ready &
                                                    Row_Kernel_4_Radix_Converter_Val_input_ready: 0 ;
    assign Fifo_Val_rd_en = Fifo_Val_rd_ready & ~Fifo_Val_empty;

    assign Row_Kernel_1_Radix_Converter_Val_input_data = 
                                                            (Ctrl_sig_Val ==2) ?Fifo_Val_data_out[63:0] : 0 |
                                                            (Ctrl_sig_Val ==1) ?Fifo_Val_data_out[31:0] : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_data_out[15:0] : 0 ;
    assign Row_Kernel_2_Radix_Converter_Val_input_data = 
                                                            (Ctrl_sig_Val ==2) ?0 : 0 |
                                                            (Ctrl_sig_Val ==1) ?Fifo_Val_data_out[63:32] : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_data_out[31:16] : 0 ;
    assign Row_Kernel_3_Radix_Converter_Val_input_data = 
                                                            (Ctrl_sig_Val ==2) ?0 : 0 |
                                                            (Ctrl_sig_Val ==1) ?0 : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_data_out[47:32] : 0 ;
    assign Row_Kernel_4_Radix_Converter_Val_input_data = 
                                                            (Ctrl_sig_Val ==2) ?0 : 0 |
                                                            (Ctrl_sig_Val ==1) ?0 : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_data_out[63:48] : 0 ;


    assign Row_Kernel_1_Radix_Converter_Val_input_valid =   
                                                            (Ctrl_sig_Val ==2) ?Fifo_Val_rd_en : 0 |
                                                            (Ctrl_sig_Val ==1) ?Fifo_Val_rd_en : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_rd_en : 0 ;
    assign Row_Kernel_2_Radix_Converter_Val_input_valid = 
                                                            (Ctrl_sig_Val ==2) ?0 : 0 |
                                                            (Ctrl_sig_Val ==1) ?Fifo_Val_rd_en : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_rd_en : 0 ;
    assign Row_Kernel_3_Radix_Converter_Val_input_valid = 
                                                            (Ctrl_sig_Val ==2) ?0 : 0 |
                                                            (Ctrl_sig_Val ==1) ?0 : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_rd_en : 0 ;
    assign Row_Kernel_4_Radix_Converter_Val_input_valid = 
                                                            (Ctrl_sig_Val ==2) ?0 : 0 |
                                                            (Ctrl_sig_Val ==1) ?0 : 0 |
                                                            (Ctrl_sig_Val ==0) ?Fifo_Val_rd_en : 0 ;


    

    // TODO 针对Yi的输出配置，将所有的Yi输出数据对齐到64bit后再写入fifo，保证写回的利用率。  
    wire [63:0] Yi_fifo_1_data_out;
    wire [63:0] Yi_fifo_2_data_out;
    wire [63:0] Yi_fifo_3_data_out;
    wire [63:0] Yi_fifo_4_data_out;

    Fifo #(
        .DATA_WIDTH(64)
    ) Yi_fifo_1(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Row_Kernel_1_output_valid& (Ctrl_sig_Val == 0 | Ctrl_sig_Val == 1 | Ctrl_sig_Val == 2)),        
        .rd_en(Yi_fifo_1_rd_en),        
        .data_in(Row_Kernel_1_output_data),   
        .data_out(Yi_fifo_1_data_out),  
        .empty(Yi_fifo_1_empty),   
        .full(Yi_fifo_1_full)     
    );


    Fifo #(
        .DATA_WIDTH(64)
    ) Yi_fifo_2(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Row_Kernel_2_output_valid & (Ctrl_sig_Val == 0 | Ctrl_sig_Val == 1)),        
        .rd_en(Yi_fifo_2_rd_en),        
        .data_in(Row_Kernel_2_output_data),   
        .data_out(Yi_fifo_2_data_out),  
        .empty(Yi_fifo_2_empty),   
        .full(Yi_fifo_2_full)     
    );


    Fifo #(
        .DATA_WIDTH(64)
    ) Yi_fifo_3(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Row_Kernel_3_output_valid & Ctrl_sig_Val == 0),        
        .rd_en(Yi_fifo_3_rd_en),        
        .data_in(Row_Kernel_3_output_data),   
        .data_out(Yi_fifo_3_data_out),  
        .empty(Yi_fifo_3_empty),   
        .full(Yi_fifo_3_full)     
    );


    Fifo #(
        .DATA_WIDTH(64)
    ) Yi_fifo_4(
        .clk(clk),          
        .rst(~rstn),          
        .wr_en(Row_Kernel_4_output_valid & Ctrl_sig_Val == 0),        
        .rd_en(Yi_fifo_4_rd_en),        
        .data_in(Row_Kernel_4_output_data),   
        .data_out(Yi_fifo_4_data_out),  
        .empty(Yi_fifo_4_empty),   
        .full(Yi_fifo_4_full)     
    );


    wire [63:0] Yi_Data;
    reg  [63:0] Yi_Data_Tx;
    reg [47:0] write_addr = 48'hffffffffffff;
    axi_master_w_single #(
        .C_M_AXI_TARGET_SLAVE_BASE_ADDR(Yi_Base_ADDR),
        .C_M_AXI_DATA_WIDTH(64)
    )
    axi_master_w_single_Yi(
        .m_axi_init_axi_write(axi_master_w_single_Yi_m_axi_init_axi_write),
        .write_data(Yi_Data_Tx),
        .m_axi_w_done(m_axi_w_done),
        .m_axi_aclk(clk),
        .m_axi_aresetn(rstn),

		.m_axi_awid(m_axi_Yi_awid),
		.m_axi_awaddr(m_axi_Yi_awaddr),
        .m_axi_awlen(m_axi_Yi_awlen),
        .m_axi_awsize(m_axi_Yi_awsize),
        .m_axi_awburst(m_axi_Yi_awburst),
        .m_axi_awlock(m_axi_Yi_awlock),
        .m_axi_awcache(m_axi_Yi_awcache),
        .m_axi_awprot(m_axi_Yi_awprot),
        .m_axi_awqos(m_axi_Yi_awqos),
        .m_axi_awvalid(m_axi_Yi_awvalid),
        .m_axi_awready(m_axi_Yi_awready),
        .m_axi_wdata(m_axi_Yi_wdata),
        .m_axi_wstrb(m_axi_Yi_wstrb),
        .m_axi_wlast(m_axi_Yi_wlast),
        .m_axi_wvalid(m_axi_Yi_wvalid),
        .m_axi_wready(m_axi_Yi_wready),
        .m_axi_bid(m_axi_Yi_bid),
        .m_axi_bresp(m_axi_Yi_bresp),
        .m_axi_bvalid(m_axi_Yi_bvalid),
        .m_axi_bready(m_axi_Yi_bready),

        // .write_length(1),

        .write_base_addr(write_addr)
    );
    (*mark_debug = "true"*)
    reg [47:0] write_addr_demux[3:0];

    
    
    reg write_begin = 0;
    reg [2:0] write_state = 0;

    assign axi_master_w_single_Yi_m_axi_init_axi_write = write_begin;
    // assign axi_master_w_single_Yi_write_base_addr = write_addr;
    
    (*mark_debug = "true"*)
    wire [2:0] Yi_Fifo_ready;

    assign Yi_Fifo_ready = 
                            Yi_fifo_1_full?1:
                            Yi_fifo_2_full?2:
                            Yi_fifo_3_full?3:
                            Yi_fifo_4_full?4:

                            ~Yi_fifo_1_empty?1:
                            ~Yi_fifo_2_empty?2:
                            ~Yi_fifo_3_empty?3:
                            ~Yi_fifo_4_empty?4:
                            0;

    assign Yi_Data =    
                        (Yi_Fifo_ready == 1) ? Yi_fifo_1_data_out : 64'h0|
                        (Yi_Fifo_ready == 2) ? Yi_fifo_2_data_out : 64'h0|
                        (Yi_Fifo_ready == 3) ? Yi_fifo_3_data_out : 64'h0|
                        (Yi_Fifo_ready == 4) ? Yi_fifo_4_data_out : 64'h0;
    reg [2:0] Yi_Fifo_Wb;
    assign Yi_fifo_1_rd_en = Yi_Fifo_Wb == 1 & m_axi_Yi_wvalid & m_axi_Yi_wready;
    assign Yi_fifo_2_rd_en = Yi_Fifo_Wb == 2 & m_axi_Yi_wvalid & m_axi_Yi_wready;
    assign Yi_fifo_3_rd_en = Yi_Fifo_Wb == 3 & m_axi_Yi_wvalid & m_axi_Yi_wready;
    assign Yi_fifo_4_rd_en = Yi_Fifo_Wb == 4 & m_axi_Yi_wvalid & m_axi_Yi_wready;
    // assign ;
    
    always @(posedge clk ) begin
        if(!rstn)begin
            write_begin<=0;
        end
        else begin
            if(write_state==0)begin
                if(Yi_Fifo_ready !=0)begin
                    write_begin <=1;
                end
                else begin
                    write_begin<=0;
                end
            end
            else begin
                write_begin<=0;
            end
        end
        
    end


    always @(posedge clk ) begin
        if(~rstn)begin
            write_state <=0;
            write_addr <= 32'hffffffff;
            write_addr_demux[0]<=0;
            write_addr_demux[1]<=47'h1000000;
            write_addr_demux[2]<=47'h2000000;
            write_addr_demux[3]<=47'h3000000;

        end
        else begin
            if(write_state ==0)begin
                if(Yi_Fifo_ready!=0)begin
                    write_state<=1;
                    write_addr <= write_addr_demux[Yi_Fifo_ready -1];
                    write_addr_demux[Yi_Fifo_ready -1]<=write_addr_demux[Yi_Fifo_ready -1]+8;
                    Yi_Data_Tx<=Yi_Data;
                    Yi_Fifo_Wb <= Yi_Fifo_ready;
                end
            end
            if(write_state == 1)begin
                if(m_axi_Yi_bvalid)begin
                    write_state <=0;
                end
            end
        end
    end


endmodule