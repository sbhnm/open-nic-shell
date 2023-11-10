//Col Xi 直接接到hbm上
//Val 接 cross bar 后在拉出来
//该模块描述了参数配置模块，并实例化了多个计算核心。并对数据传输总线进行了整理。
module spmv_calc_top #(
    parameter int CONF_NUM_KERNEL = 32'h4
) (
    (*mark_debug = "true"*)
    input                          s_axil_awvalid,
    (*mark_debug = "true"*)
    input                   [31:0] s_axil_awaddr,
    (*mark_debug = "true"*)
    output                         s_axil_awready,
    (*mark_debug = "true"*)
    input                          s_axil_wvalid,
    (*mark_debug = "true"*)
    input                   [31:0] s_axil_wdata,
    (*mark_debug = "true"*)
    output                         s_axil_wready,

    output                         s_axil_bvalid,
    output                   [1:0] s_axil_bresp,
    input                          s_axil_bready,
    input                          s_axil_arvalid,
    input                   [31:0] s_axil_araddr,
    output                         s_axil_arready,
    output                         s_axil_rvalid,
    output                  [31:0] s_axil_rdata,
    output                   [1:0] s_axil_rresp,
    input                          s_axil_rready,

    output [CONF_NUM_KERNEL*48-1 : 0] m_axi_Col_araddr,
    output [CONF_NUM_KERNEL*2-1 : 0] m_axi_Col_arburst,
    output [CONF_NUM_KERNEL*8-1 : 0] m_axi_Col_arlen,
    output [CONF_NUM_KERNEL*3-1 : 0] m_axi_Col_arsize,
    output [CONF_NUM_KERNEL*1-1 : 0]m_axi_Col_arvalid,
    output [CONF_NUM_KERNEL*48-1 : 0] m_axi_Col_awaddr,
    output [CONF_NUM_KERNEL*2-1 : 0] m_axi_Col_awburst,
    output [CONF_NUM_KERNEL*8-1 : 0] m_axi_Col_awlen,
    output [CONF_NUM_KERNEL*3-1 : 0] m_axi_Col_awsize,
    output [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_awvalid,
    output [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_rready,
    output [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_bready,
    output [CONF_NUM_KERNEL*256-1 : 0] m_axi_Col_wdata,
    output [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_wlast,
    output [CONF_NUM_KERNEL*32-1 : 0] m_axi_Col_wstrb,
    output [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_wvalid,
    input [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_arready,
    input [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_awready,
    input [CONF_NUM_KERNEL*256-1 : 0] m_axi_Col_rdata,
    input [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_rlast,
    input [CONF_NUM_KERNEL*2-1 : 0] m_axi_Col_rresp,
    input [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_rvalid,
    input [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_wready,
    input [CONF_NUM_KERNEL*2-1 : 0] m_axi_Col_bresp,
    input [CONF_NUM_KERNEL*1-1 : 0] m_axi_Col_bvalid,

    input [1*48-1 : 0] s_axi_Xi_araddr,
    input [1*2-1 : 0] s_axi_Xi_arburst,
    input [1*8-1 : 0] s_axi_Xi_arlen,
    input [1*3-1 : 0] s_axi_Xi_arsize,
    input [1*1-1 : 0]s_axi_Xi_arvalid,
    input [1*48-1 : 0] s_axi_Xi_awaddr,
    input [1*2-1 : 0] s_axi_Xi_awburst,
    input [1*8-1 : 0] s_axi_Xi_awlen,
    input [1*3-1 : 0] s_axi_Xi_awsize,
    input [1*1-1 : 0] s_axi_Xi_awvalid,
    input [1*1-1 : 0] s_axi_Xi_rready,
    input [1*1-1 : 0] s_axi_Xi_bready,
    input [1*64-1 : 0] s_axi_Xi_wdata,
    input [1*1-1 : 0] s_axi_Xi_wlast,
    input [1*8-1 : 0] s_axi_Xi_wstrb,
    input [1*1-1 : 0] s_axi_Xi_wvalid,
    output [1*1-1 : 0] s_axi_Xi_arready,
    output [1*1-1 : 0] s_axi_Xi_awready,
    output [1*64-1 : 0] s_axi_Xi_rdata,
    output [1*1-1 : 0] s_axi_Xi_rlast,
    output [1*2-1 : 0] s_axi_Xi_rresp,
    output [1*1-1 : 0] s_axi_Xi_rvalid,
    output [1*1-1 : 0] s_axi_Xi_wready,
    output [1*2-1 : 0] s_axi_Xi_bresp,
    output [1*1-1 : 0] s_axi_Xi_bvalid,

    (*mark_debug = "true"*)
    output [47 : 0]                 m_axi_hbm_Val_araddr,
    output [1 : 0]                  m_axi_hbm_Val_arburst,
    output [7 : 0]                  m_axi_hbm_Val_arlen,
    output [2 : 0]                  m_axi_hbm_Val_arsize,
    (*mark_debug = "true"*)
    output                          m_axi_hbm_Val_arvalid,
    output [47 : 0]                 m_axi_hbm_Val_awaddr,
    output [1 : 0]                  m_axi_hbm_Val_awburst,
    output [7 : 0]                  m_axi_hbm_Val_awlen,
    output [2 : 0]                  m_axi_hbm_Val_awsize,
    output                          m_axi_hbm_Val_awvalid,
    (*mark_debug = "true"*)
    output                          m_axi_hbm_Val_rready,
    output                          m_axi_hbm_Val_bready,
    output [255 : 0]                m_axi_hbm_Val_wdata,
    output                          m_axi_hbm_Val_wlast,
    output [31 : 0]                 m_axi_hbm_Val_wstrb,
    output                          m_axi_hbm_Val_wvalid,
    (*mark_debug = "true"*)
    input                           m_axi_hbm_Val_arready,
    input                           m_axi_hbm_Val_awready,
    input [255 : 0]                 m_axi_hbm_Val_rdata,
    input                           m_axi_hbm_Val_rlast,
    input [1 : 0]                   m_axi_hbm_Val_rresp,
    (*mark_debug = "true"*)
    input                           m_axi_hbm_Val_rvalid,
    input                           m_axi_hbm_Val_wready,
    input [1:0]                     m_axi_hbm_Val_bresp,
    input                           m_axi_hbm_Val_bvalid,

    input axil_clk,
    input axis_clk,

    input rstn
);
    wire [32*3*CONF_NUM_KERNEL-1:0] config_wire;
    
    wire [CONF_NUM_KERNEL*48-1 : 0] axi_Val_araddr;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Val_arburst;
    wire [CONF_NUM_KERNEL*8-1 : 0] axi_Val_arlen;
    wire [CONF_NUM_KERNEL*3-1 : 0] axi_Val_arsize;
    wire [CONF_NUM_KERNEL*1-1 : 0]axi_Val_arvalid;
    wire [CONF_NUM_KERNEL*48-1 : 0] axi_Val_awaddr;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Val_awburst;
    wire [CONF_NUM_KERNEL*8-1 : 0] axi_Val_awlen;
    wire [CONF_NUM_KERNEL*3-1 : 0] axi_Val_awsize;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_awvalid;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_rready;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_bready;
    wire [CONF_NUM_KERNEL*256-1 : 0] axi_Val_wdata;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_wlast;
    wire [CONF_NUM_KERNEL*32-1 : 0] axi_Val_wstrb;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_wvalid;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_arready;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_awready;
    wire [CONF_NUM_KERNEL*256-1 : 0] axi_Val_rdata;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_rlast;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Val_rresp;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_rvalid;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_wready;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Val_bresp;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Val_bvalid;
    //TODO 实例化cross bar，将所有的Val 连接起来


    wire [CONF_NUM_KERNEL*48-1 : 0] axi_Xi_bram_araddr;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Xi_bram_arburst;
    wire [CONF_NUM_KERNEL*8-1 : 0] axi_Xi_bram_arlen;
    wire [CONF_NUM_KERNEL*3-1 : 0] axi_Xi_bram_arsize;
    wire [CONF_NUM_KERNEL*1-1 : 0]axi_Xi_bram_arvalid;
    wire [CONF_NUM_KERNEL*48-1 : 0] axi_Xi_bram_awaddr;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Xi_bram_awburst;
    wire [CONF_NUM_KERNEL*8-1 : 0] axi_Xi_bram_awlen;
    wire [CONF_NUM_KERNEL*3-1 : 0] axi_Xi_bram_awsize;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_awvalid;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_rready;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_bready;
    wire [CONF_NUM_KERNEL*64-1 : 0] axi_Xi_bram_wdata;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_wlast;
    wire [CONF_NUM_KERNEL*8-1 : 0] axi_Xi_bram_wstrb;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_wvalid;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_arready;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_awready;
    wire [CONF_NUM_KERNEL*64-1 : 0] axi_Xi_bram_rdata;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_rlast;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Xi_bram_rresp;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_rvalid;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_wready;
    wire [CONF_NUM_KERNEL*2-1 : 0] axi_Xi_bram_bresp;
    wire [CONF_NUM_KERNEL*1-1 : 0] axi_Xi_bram_bvalid;

    axi_hbm_val_crossbar axi_hbm_val_crossbar (
    .aclk(axis_clk),                      // input wire aclk
    .aresetn(rstn),                // input wire aresetn

    .s_axi_arid(0),
    .s_axi_awid(0),
    .s_axi_araddr(axi_Val_araddr),
    .s_axi_arburst(axi_Val_arburst),
    .s_axi_arlen(axi_Val_arlen),
    .s_axi_arsize(axi_Val_arsize),
    .s_axi_arvalid(axi_Val_arvalid),
    .s_axi_awaddr(axi_Val_awaddr),
    .s_axi_awburst(axi_Val_awburst),
    .s_axi_awlen(axi_Val_awlen),
    .s_axi_awsize(axi_Val_awsize),
    .s_axi_awvalid(axi_Val_awvalid),
    .s_axi_rready(axi_Val_rready),
    .s_axi_bready(axi_Val_bready),
    .s_axi_wdata(axi_Val_wdata),
    .s_axi_wlast(axi_Val_wlast),
    .s_axi_wstrb(axi_Val_wstrb),
    .s_axi_wvalid(axi_Val_wvalid),
    .s_axi_arready(axi_Val_arready),
    .s_axi_awready(axi_Val_awready),
    .s_axi_rdata(axi_Val_rdata),
    .s_axi_rlast(axi_Val_rlast),
    .s_axi_rresp(axi_Val_rresp),
    .s_axi_rvalid(axi_Val_rvalid),
    .s_axi_wready(axi_Val_wready),
    .s_axi_bresp(axi_Val_bresp),
    .s_axi_bvalid(axi_Val_bvalid),
    .s_axi_arcache({4'b0010,4'b0010,4'b0010,4'b0010}),
    .s_axi_arlock(0),
    .s_axi_arprot(0),
    .s_axi_arqos(0),

    .s_axi_awcache({4'b0010,4'b0010,4'b0010,4'b0010}),
    .s_axi_awlock(0),
    .s_axi_awprot(0),
    .s_axi_awqos(0),

    // .m_axi_rid(0),
    // .m_axi_bid(0),
    .m_axi_araddr(m_axi_hbm_Val_araddr),
    .m_axi_arburst(m_axi_hbm_Val_arburst),
    .m_axi_arlen(m_axi_hbm_Val_arlen),
    .m_axi_arsize(m_axi_hbm_Val_arsize),
    .m_axi_arvalid(m_axi_hbm_Val_arvalid),
    .m_axi_awaddr(m_axi_hbm_Val_awaddr),
    .m_axi_awburst(m_axi_hbm_Val_awburst),
    .m_axi_awlen(m_axi_hbm_Val_awlen),
    .m_axi_awsize(m_axi_hbm_Val_awsize),
    .m_axi_awvalid(m_axi_hbm_Val_awvalid),
    .m_axi_rready(m_axi_hbm_Val_rready),
    .m_axi_bready(m_axi_hbm_Val_bready),
    .m_axi_wdata(m_axi_hbm_Val_wdata),
    .m_axi_wlast(m_axi_hbm_Val_wlast),
    .m_axi_wstrb(m_axi_hbm_Val_wstrb),
    .m_axi_wvalid(m_axi_hbm_Val_wvalid),
    .m_axi_arready(m_axi_hbm_Val_arready),
    .m_axi_awready(m_axi_hbm_Val_awready),
    .m_axi_rdata(m_axi_hbm_Val_rdata),
    .m_axi_rlast(m_axi_hbm_Val_rlast),
    .m_axi_rresp(m_axi_hbm_Val_rresp),
    .m_axi_rvalid(m_axi_hbm_Val_rvalid),
    .m_axi_wready(m_axi_hbm_Val_wready),
    .m_axi_bresp(m_axi_hbm_Val_bresp),
    .m_axi_bvalid(m_axi_hbm_Val_bvalid)
);
    // initial begin
    //     axi_Val_arvalid<=0;
    //     #1500
    //     axi_Val_arvalid<=1;
    //     #500;
    //     axi_Val_arvalid<=0;
    // end

    axi_kernelXi_crossbar axi_kernelXi_crossbar (
        .aclk(axis_clk),                      // input wire aclk
        .aresetn(rstn),                // input wire aresetn
        .s_axi_awaddr(s_axi_Xi_awaddr),      // input wire [47 : 0] s_axi_awaddr
        .s_axi_awlen(s_axi_Xi_awlen),        // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize(s_axi_Xi_awsize),      // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst(s_axi_Xi_awburst),    // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid(s_axi_Xi_awvalid),    // input wire [0 : 0] s_axi_awvalid
        .s_axi_awready(s_axi_Xi_awready),    // output wire [0 : 0] s_axi_awready
        .s_axi_wdata(s_axi_Xi_wdata),        // input wire [63 : 0] s_axi_wdata
        .s_axi_wstrb(s_axi_Xi_wstrb),        // input wire [7 : 0] s_axi_wstrb
        .s_axi_wlast(s_axi_Xi_wlast),        // input wire [0 : 0] s_axi_wlast
        .s_axi_wvalid(s_axi_Xi_wvalid),      // input wire [0 : 0] s_axi_wvalid
        .s_axi_wready(s_axi_Xi_wready),      // output wire [0 : 0] s_axi_wready
        .s_axi_bresp(s_axi_Xi_bresp),        // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid(s_axi_Xi_bvalid),      // output wire [0 : 0] s_axi_bvalid
        .s_axi_bready(s_axi_Xi_bready),      // input wire [0 : 0] s_axi_bready
        .s_axi_araddr(s_axi_Xi_araddr),      // input wire [47 : 0] s_axi_araddr
        .s_axi_arlen(s_axi_Xi_arlen),        // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize(s_axi_Xi_arsize),      // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst(s_axi_Xi_arburst),    // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid(s_axi_Xi_arvalid),    // input wire [0 : 0] s_axi_arvalid
        .s_axi_arready(s_axi_Xi_arready),    // output wire [0 : 0] s_axi_arready
        .s_axi_rdata(s_axi_Xi_rdata),        // output wire [63 : 0] s_axi_rdata
        .s_axi_rresp(s_axi_Xi_rresp),        // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast(s_axi_Xi_rlast),        // output wire [0 : 0] s_axi_rlast
        .s_axi_rvalid(s_axi_Xi_rvalid),      // output wire [0 : 0] s_axi_rvalid
        .s_axi_rready(s_axi_Xi_rready),      // input wire [0 : 0] s_axi_rready

        .m_axi_awaddr(axi_Xi_bram_awaddr),      // output wire [191 : 0] m_axi_awaddr
        .m_axi_awlen(axi_Xi_bram_awlen),        // output wire [31 : 0] m_axi_awlen
        .m_axi_awsize(axi_Xi_bram_awsize),      // output wire [11 : 0] m_axi_awsize
        .m_axi_awburst(axi_Xi_bram_awburst),    // output wire [7 : 0] m_axi_awburst
        .m_axi_awvalid(axi_Xi_bram_awvalid),    // output wire [3 : 0] m_axi_awvalid
        .m_axi_awready(axi_Xi_bram_awready),    // input wire [3 : 0] m_axi_awready
        .m_axi_wdata(axi_Xi_bram_wdata),        // output wire [255 : 0] m_axi_wdata
        .m_axi_wstrb(axi_Xi_bram_wstrb),        // output wire [31 : 0] m_axi_wstrb
        .m_axi_wlast(axi_Xi_bram_wlast),        // output wire [3 : 0] m_axi_wlast
        .m_axi_wvalid(axi_Xi_bram_wvalid),      // output wire [3 : 0] m_axi_wvalid
        .m_axi_wready(axi_Xi_bram_wready),      // input wire [3 : 0] m_axi_wready
        .m_axi_bresp(axi_Xi_bram_bresp),        // input wire [7 : 0] m_axi_bresp
        .m_axi_bvalid(axi_Xi_bram_bvalid),      // input wire [3 : 0] m_axi_bvalid
        .m_axi_bready(axi_Xi_bram_bready),      // output wire [3 : 0] m_axi_bready
        .m_axi_araddr(axi_Xi_bram_araddr),      // output wire [191 : 0] m_axi_araddr
        .m_axi_arlen(axi_Xi_bram_arlen),        // output wire [31 : 0] m_axi_arlen
        .m_axi_arsize(axi_Xi_bram_arsize),      // output wire [11 : 0] m_axi_arsize
        .m_axi_arburst(axi_Xi_bram_arburst),    // output wire [7 : 0] m_axi_arburst
        .m_axi_arvalid(axi_Xi_bram_arvalid),    // output wire [3 : 0] m_axi_arvalid
        .m_axi_arready(axi_Xi_bram_arready),    // input wire [3 : 0] m_axi_arready
        .m_axi_rdata(axi_Xi_bram_rdata),        // input wire [255 : 0] m_axi_rdata
        .m_axi_rresp(axi_Xi_bram_rresp),        // input wire [7 : 0] m_axi_rresp
        .m_axi_rlast(axi_Xi_bram_rlast),        // input wire [3 : 0] m_axi_rlast
        .m_axi_rvalid(axi_Xi_bram_rvalid),      // input wire [3 : 0] m_axi_rvalid
        .m_axi_rready(axi_Xi_bram_rready)      // output wire [3 : 0] m_axi_rready
    );


    spmv_system_config  #(
        .CONF_NUM_KERNEL(CONF_NUM_KERNEL)
    )
    spmv_system_config(
        .s_axil_awvalid (s_axil_awvalid),
        .s_axil_awaddr  (s_axil_awaddr),
        .s_axil_awready (s_axil_awready),
        .s_axil_wvalid  (s_axil_wvalid),
        .s_axil_wdata   (s_axil_wdata),
        .s_axil_wready  (s_axil_wready),
        .s_axil_bvalid  (s_axil_bvalid),
        .s_axil_bresp   (s_axil_bresp),
        .s_axil_bready  (s_axil_bready),
        .s_axil_arvalid (s_axil_arvalid),
        .s_axil_araddr  (s_axil_araddr),
        .s_axil_arready (s_axil_arready),
        .s_axil_rvalid  (s_axil_rvalid),
        .s_axil_rdata   (s_axil_rdata),
        .s_axil_rresp   (s_axil_rresp),
        .s_axil_rready  (s_axil_rready),

        .config_wire(config_wire),

        .aclk(axil_clk),
        .aresetn(rstn)
    );
     generate for (genvar i = 0; i < CONF_NUM_KERNEL; i++) begin
        spmv_calc_kernel #(

        )spmv_calc_kernel (
            .clk(axis_clk),
            .rstn(rstn && ~(config_wire[32*3 *i + 7]) ),
            .config_wire(config_wire[`getvec(32*3,i)]),

            .m_axi_Col_araddr(m_axi_Col_araddr[`getvec(48,i)]),
            .m_axi_Col_arburst(m_axi_Col_arburst[`getvec(2,i)]),
            .m_axi_Col_arlen(m_axi_Col_arlen[`getvec(8,i)]),
            .m_axi_Col_arsize(m_axi_Col_arsize[`getvec(3,i)]),
            .m_axi_Col_arvalid(m_axi_Col_arvalid[`getvec(1,i)]),
            .m_axi_Col_awaddr(m_axi_Col_awaddr[`getvec(48,i)]),
            .m_axi_Col_awburst(m_axi_Col_awburst[`getvec(2,i)]),
            .m_axi_Col_awlen(m_axi_Col_awlen[`getvec(8,i)]),
            .m_axi_Col_awsize(m_axi_Col_awsize[`getvec(3,i)]),
            .m_axi_Col_awvalid(m_axi_Col_awvalid[`getvec(1,i)]),
            .m_axi_Col_rready(m_axi_Col_rready[`getvec(1,i)]),
            .m_axi_Col_bready(m_axi_Col_bready[`getvec(1,i)]),
            .m_axi_Col_wdata(m_axi_Col_wdata[`getvec(256,i)]),
            .m_axi_Col_wlast(m_axi_Col_wlast[`getvec(1,i)]),
            .m_axi_Col_wstrb(m_axi_Col_wstrb[`getvec(32,i)]),
            .m_axi_Col_wvalid(m_axi_Col_wvalid[`getvec(1,i)]),
            .m_axi_Col_arready(m_axi_Col_arready[`getvec(1,i)]),
            .m_axi_Col_awready(m_axi_Col_awready[`getvec(1,i)]),
            .m_axi_Col_rdata(m_axi_Col_rdata[`getvec(256,i)]),
            // .m_axi_Col_rdata(m_axi_Col_rdata[`getvec(256,i)]),
            .m_axi_Col_rlast(m_axi_Col_rlast[`getvec(1,i)]),
            .m_axi_Col_rresp(m_axi_Col_rresp[`getvec(2,i)]),
            .m_axi_Col_rvalid(m_axi_Col_rvalid[`getvec(1,i)]),
            .m_axi_Col_wready(m_axi_Col_wready[`getvec(1,i)]),
            .m_axi_Col_bresp(m_axi_Col_bresp[`getvec(2,i)]),
            .m_axi_Col_bvalid(m_axi_Col_bvalid[`getvec(1,i)]),


            .m_axi_Val_araddr(axi_Val_araddr[`getvec(48,i)]),
            .m_axi_Val_arburst(axi_Val_arburst[`getvec(2,i)]),
            .m_axi_Val_arlen(axi_Val_arlen[`getvec(8,i)]),
            .m_axi_Val_arsize(axi_Val_arsize[`getvec(3,i)]),
            .m_axi_Val_arvalid(axi_Val_arvalid[`getvec(1,i)]),
            .m_axi_Val_awaddr(axi_Val_awaddr[`getvec(48,i)]),
            .m_axi_Val_awburst(axi_Val_awburst[`getvec(2,i)]),
            .m_axi_Val_awlen(axi_Val_awlen[`getvec(8,i)]),
            .m_axi_Val_awsize(axi_Val_awsize[`getvec(3,i)]),
            .m_axi_Val_awvalid(axi_Val_awvalid[`getvec(1,i)]),
            .m_axi_Val_rready(axi_Val_rready[`getvec(1,i)]),
            .m_axi_Val_bready(axi_Val_bready[`getvec(1,i)]),
            .m_axi_Val_wdata(axi_Val_wdata[`getvec(256,i)]),
            .m_axi_Val_wlast(axi_Val_wlast[`getvec(1,i)]),
            .m_axi_Val_wstrb(axi_Val_wstrb[`getvec(32,i)]),
            .m_axi_Val_wvalid(axi_Val_wvalid[`getvec(1,i)]),
            .m_axi_Val_arready(axi_Val_arready[`getvec(1,i)]),
            .m_axi_Val_awready(axi_Val_awready[`getvec(1,i)]),
            .m_axi_Val_rdata(axi_Val_rdata[`getvec(256,i)]),
            .m_axi_Val_rlast(axi_Val_rlast[`getvec(1,i)]),
            .m_axi_Val_rresp(axi_Val_rresp[`getvec(2,i)]),
            .m_axi_Val_rvalid(axi_Val_rvalid[`getvec(1,i)]),
            .m_axi_Val_wready(axi_Val_wready[`getvec(1,i)]),
            .m_axi_Val_bresp(axi_Val_bresp[`getvec(2,i)]),
            .m_axi_Val_bvalid(axi_Val_bvalid[`getvec(1,i)]),

            .s_axi_Xi_bram_araddr(axi_Xi_bram_araddr[`getvec(48,i)]),
            .s_axi_Xi_bram_arburst(axi_Xi_bram_arburst[`getvec(2,i)]),
            .s_axi_Xi_bram_arlen(axi_Xi_bram_arlen[`getvec(8,i)]),
            .s_axi_Xi_bram_arsize(axi_Xi_bram_arsize[`getvec(3,i)]),
            .s_axi_Xi_bram_arvalid(axi_Xi_bram_arvalid[`getvec(1,i)]),
            .s_axi_Xi_bram_awaddr(axi_Xi_bram_awaddr[`getvec(48,i)]),
            .s_axi_Xi_bram_awburst(axi_Xi_bram_awburst[`getvec(2,i)]),
            .s_axi_Xi_bram_awlen(axi_Xi_bram_awlen[`getvec(8,i)]),
            .s_axi_Xi_bram_awsize(axi_Xi_bram_awsize[`getvec(3,i)]),
            .s_axi_Xi_bram_awvalid(axi_Xi_bram_awvalid[`getvec(1,i)]),
            .s_axi_Xi_bram_rready(axi_Xi_bram_rready[`getvec(1,i)]),
            .s_axi_Xi_bram_bready(axi_Xi_bram_bready[`getvec(1,i)]),
            .s_axi_Xi_bram_wdata(axi_Xi_bram_wdata[`getvec(64,i)]),
            .s_axi_Xi_bram_wlast(axi_Xi_bram_wlast[`getvec(1,i)]),
            .s_axi_Xi_bram_wstrb(axi_Xi_bram_wstrb[`getvec(8,i)]),
            .s_axi_Xi_bram_wvalid(axi_Xi_bram_wvalid[`getvec(1,i)]),
            .s_axi_Xi_bram_arready(axi_Xi_bram_arready[`getvec(1,i)]),
            .s_axi_Xi_bram_awready(axi_Xi_bram_awready[`getvec(1,i)]),
            .s_axi_Xi_bram_rdata(axi_Xi_bram_rdata[`getvec(64,i)]),
            .s_axi_Xi_bram_rlast(axi_Xi_bram_rlast[`getvec(1,i)]),
            .s_axi_Xi_bram_rresp(axi_Xi_bram_rresp[`getvec(2,i)]),
            .s_axi_Xi_bram_rvalid(axi_Xi_bram_rvalid[`getvec(1,i)]),
            .s_axi_Xi_bram_wready(axi_Xi_bram_wready[`getvec(1,i)]),
            .s_axi_Xi_bram_bresp(axi_Xi_bram_bresp[`getvec(2,i)]),
            .s_axi_Xi_bram_bvalid(axi_Xi_bram_bvalid[`getvec(1,i)])

        );
     end
     endgenerate
endmodule