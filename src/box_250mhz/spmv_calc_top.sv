//Col Xi 直接接到hbm上
//Val 接 cross bar 后在拉出来
//该模块描述了参数配置模块，并实例化了多个计算核心。并对数据传输总线进行了整理。
module spmv_calc_top #(
    parameter int CONF_NUM_KERNEL = 32'h4
) (
    
    input                          s_axil_awvalid,
    
    input                   [31:0] s_axil_awaddr,
    
    output                         s_axil_awready,
    
    input                          s_axil_wvalid,
    
    input                   [31:0] s_axil_wdata,
    
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




    
    output [47 : 0]                 m_axi_hbm_Val_araddr,
    output [1 : 0]                  m_axi_hbm_Val_arburst,
    output [7 : 0]                  m_axi_hbm_Val_arlen,
    output [2 : 0]                  m_axi_hbm_Val_arsize,
    
    output                          m_axi_hbm_Val_arvalid,
    output [47 : 0]                 m_axi_hbm_Val_awaddr,
    output [1 : 0]                  m_axi_hbm_Val_awburst,
    output [7 : 0]                  m_axi_hbm_Val_awlen,
    output [2 : 0]                  m_axi_hbm_Val_awsize,
    output                          m_axi_hbm_Val_awvalid,
    
    output                          m_axi_hbm_Val_rready,
    output                          m_axi_hbm_Val_bready,
    output [255 : 0]                m_axi_hbm_Val_wdata,
    output                          m_axi_hbm_Val_wlast,
    output [31 : 0]                 m_axi_hbm_Val_wstrb,
    output                          m_axi_hbm_Val_wvalid,
    
    input                           m_axi_hbm_Val_arready,
    input                           m_axi_hbm_Val_awready,
    input [255 : 0]                 m_axi_hbm_Val_rdata,
    input                           m_axi_hbm_Val_rlast,
    input [1 : 0]                   m_axi_hbm_Val_rresp,
    
    input                           m_axi_hbm_Val_rvalid,
    input                           m_axi_hbm_Val_wready,
    input [1:0]                     m_axi_hbm_Val_bresp,
    input                           m_axi_hbm_Val_bvalid,

    input axil_clk,
    input axis_clk,

    
    axi4.master m_axi_Xi[CONF_NUM_KERNEL-1:0],
    input rstn
);
    
    wire [32*3*CONF_NUM_KERNEL-1:0] config_wire;
    wire [32*3*CONF_NUM_KERNEL-1:0] status_wire;
    
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

generate
    
    if (CONF_NUM_KERNEL >1)begin
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
    end
    else if (CONF_NUM_KERNEL == 1) begin
        assign                   m_axi_hbm_Val_araddr =  axi_Val_araddr;
        assign                   m_axi_hbm_Val_arburst = axi_Val_arburst;
        assign                   m_axi_hbm_Val_arlen = axi_Val_arlen;
        assign                   m_axi_hbm_Val_arsize = axi_Val_arsize;
        assign                   m_axi_hbm_Val_arvalid = axi_Val_arvalid;
        assign                   m_axi_hbm_Val_awaddr = axi_Val_awaddr;
        assign                   m_axi_hbm_Val_awburst = axi_Val_awburst;
        assign                   m_axi_hbm_Val_awlen = axi_Val_awlen;
        assign                   m_axi_hbm_Val_awsize = axi_Val_awsize;
        assign                   m_axi_hbm_Val_awvalid = axi_Val_awvalid;
        assign                   m_axi_hbm_Val_rready = axi_Val_rready;
        assign                   m_axi_hbm_Val_bready = axi_Val_bready;
        assign                   m_axi_hbm_Val_wdata = axi_Val_wdata;
        assign                   m_axi_hbm_Val_wlast = axi_Val_wlast;
        assign                   m_axi_hbm_Val_wstrb = axi_Val_wstrb;
        assign                   m_axi_hbm_Val_wvalid = axi_Val_wvalid;


        assign                    axi_Val_arready = m_axi_hbm_Val_arready ;
        assign                    axi_Val_awready = m_axi_hbm_Val_awready ;
        assign                    axi_Val_rdata = m_axi_hbm_Val_rdata ;
        assign                    axi_Val_rlast = m_axi_hbm_Val_rlast ;
        assign                    axi_Val_rresp = m_axi_hbm_Val_rresp ;
        assign                    axi_Val_rvalid = m_axi_hbm_Val_rvalid ;
        assign                    axi_Val_wready = m_axi_hbm_Val_wready ;
        assign                    axi_Val_bresp = m_axi_hbm_Val_bresp ;
        assign                    axi_Val_bvalid = m_axi_hbm_Val_bvalid ;
    end
    
endgenerate





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
        .status_wire(status_wire),

        .aclk(axil_clk),
        .aresetn(rstn)
    );
     generate for (genvar i = 0; i < CONF_NUM_KERNEL; i++) begin
        axi4 #(48,256,1) axi_Xi[4]();
        axi_colxi_crossbar axi_Xi_crossbar (
        .aclk(clk),                      // input wire aclk
        .aresetn(rstn),                // input wire aresetn

        .s_axi_awid( {axi_Xi[0].AWID,axi_Xi[1].AWID,axi_Xi[2].AWID,axi_Xi[3].AWID} ),
        .s_axi_awaddr( {axi_Xi[0].AWADDR,axi_Xi[1].AWADDR,axi_Xi[2].AWADDR,axi_Xi[3].AWADDR} ),
        .s_axi_awlen( {axi_Xi[0].AWLEN,axi_Xi[1].AWLEN,axi_Xi[2].AWLEN,axi_Xi[3].AWLEN} ),
        .s_axi_awsize( {axi_Xi[0].AWSIZE,axi_Xi[1].AWSIZE,axi_Xi[2].AWSIZE,axi_Xi[3].AWSIZE} ),
        .s_axi_awburst( {axi_Xi[0].AWBURST,axi_Xi[1].AWBURST,axi_Xi[2].AWBURST,axi_Xi[3].AWBURST} ),
        .s_axi_awlock( {axi_Xi[0].AWLOCK,axi_Xi[1].AWLOCK,axi_Xi[2].AWLOCK,axi_Xi[3].AWLOCK} ),
        .s_axi_awcache( {axi_Xi[0].AWCACHE,axi_Xi[1].AWCACHE,axi_Xi[2].AWCACHE,axi_Xi[3].AWCACHE} ),
        .s_axi_awprot( {axi_Xi[0].AWPROT,axi_Xi[1].AWPROT,axi_Xi[2].AWPROT,axi_Xi[3].AWPROT} ),
        .s_axi_awqos( {axi_Xi[0].AWQOS,axi_Xi[1].AWQOS,axi_Xi[2].AWQOS,axi_Xi[3].AWQOS} ),
        .s_axi_awvalid( {axi_Xi[0].AWVALID,axi_Xi[1].AWVALID,axi_Xi[2].AWVALID,axi_Xi[3].AWVALID} ),
        .s_axi_awready( {axi_Xi[0].AWREADY,axi_Xi[1].AWREADY,axi_Xi[2].AWREADY,axi_Xi[3].AWREADY} ),
        .s_axi_wdata( {axi_Xi[0].WDATA,axi_Xi[1].WDATA,axi_Xi[2].WDATA,axi_Xi[3].WDATA} ),
        .s_axi_wstrb( {axi_Xi[0].WSTRB,axi_Xi[1].WSTRB,axi_Xi[2].WSTRB,axi_Xi[3].WSTRB} ),
        .s_axi_wlast( {axi_Xi[0].WLAST,axi_Xi[1].WLAST,axi_Xi[2].WLAST,axi_Xi[3].WLAST} ),
        .s_axi_wvalid( {axi_Xi[0].WVALID,axi_Xi[1].WVALID,axi_Xi[2].WVALID,axi_Xi[3].WVALID} ),
        .s_axi_wready( {axi_Xi[0].WREADY,axi_Xi[1].WREADY,axi_Xi[2].WREADY,axi_Xi[3].WREADY} ),
        .s_axi_bid( {axi_Xi[0].BID,axi_Xi[1].BID,axi_Xi[2].BID,axi_Xi[3].BID} ),
        .s_axi_bresp( {axi_Xi[0].BRESP,axi_Xi[1].BRESP,axi_Xi[2].BRESP,axi_Xi[3].BRESP} ),
        .s_axi_bvalid( {axi_Xi[0].BVALID,axi_Xi[1].BVALID,axi_Xi[2].BVALID,axi_Xi[3].BVALID} ),
        .s_axi_bready( {axi_Xi[0].BREADY,axi_Xi[1].BREADY,axi_Xi[2].BREADY,axi_Xi[3].BREADY} ),
        .s_axi_arid( {axi_Xi[0].ARID,axi_Xi[1].ARID,axi_Xi[2].ARID,axi_Xi[3].ARID} ),
        .s_axi_araddr( {axi_Xi[0].ARADDR,axi_Xi[1].ARADDR,axi_Xi[2].ARADDR,axi_Xi[3].ARADDR} ),
        .s_axi_arlen( {axi_Xi[0].ARLEN,axi_Xi[1].ARLEN,axi_Xi[2].ARLEN,axi_Xi[3].ARLEN} ),
        .s_axi_arsize( {axi_Xi[0].ARSIZE,axi_Xi[1].ARSIZE,axi_Xi[2].ARSIZE,axi_Xi[3].ARSIZE} ),
        .s_axi_arburst( {axi_Xi[0].ARBURST,axi_Xi[1].ARBURST,axi_Xi[2].ARBURST,axi_Xi[3].ARBURST} ),
        .s_axi_arlock( {axi_Xi[0].ARLOCK,axi_Xi[1].ARLOCK,axi_Xi[2].ARLOCK,axi_Xi[3].ARLOCK} ),
        .s_axi_arcache( {axi_Xi[0].ARCACHE,axi_Xi[1].ARCACHE,axi_Xi[2].ARCACHE,axi_Xi[3].ARCACHE} ),
        .s_axi_arprot( {axi_Xi[0].ARPROT,axi_Xi[1].ARPROT,axi_Xi[2].ARPROT,axi_Xi[3].ARPROT} ),
        .s_axi_arqos( {axi_Xi[0].ARQOS,axi_Xi[1].ARQOS,axi_Xi[2].ARQOS,axi_Xi[3].ARQOS} ),
        .s_axi_arvalid( {axi_Xi[0].ARVALID,axi_Xi[1].ARVALID,axi_Xi[2].ARVALID,axi_Xi[3].ARVALID} ),
        .s_axi_arready( {axi_Xi[0].ARREADY,axi_Xi[1].ARREADY,axi_Xi[2].ARREADY,axi_Xi[3].ARREADY} ),
        .s_axi_rid( {axi_Xi[0].RID,axi_Xi[1].RID,axi_Xi[2].RID,axi_Xi[3].RID} ),
        .s_axi_rdata( {axi_Xi[0].RDATA,axi_Xi[1].RDATA,axi_Xi[2].RDATA,axi_Xi[3].RDATA} ),
        .s_axi_rresp( {axi_Xi[0].RRESP,axi_Xi[1].RRESP,axi_Xi[2].RRESP,axi_Xi[3].RRESP} ),
        .s_axi_rlast( {axi_Xi[0].RLAST,axi_Xi[1].RLAST,axi_Xi[2].RLAST,axi_Xi[3].RLAST} ),
        .s_axi_rvalid( {axi_Xi[0].RVALID,axi_Xi[1].RVALID,axi_Xi[2].RVALID,axi_Xi[3].RVALID} ),
        .s_axi_rready( {axi_Xi[0].RREADY,axi_Xi[1].RREADY,axi_Xi[2].RREADY,axi_Xi[3].RREADY} ),

        .m_axi_awaddr(m_axi_Xi[i].AWADDR),
        .m_axi_awlen(m_axi_Xi[i].AWLEN),
        .m_axi_awsize(m_axi_Xi[i].AWSIZE),
        .m_axi_awburst(m_axi_Xi[i].AWBURST),
        .m_axi_awlock(m_axi_Xi[i].AWLOCK),
        .m_axi_awcache(m_axi_Xi[i].AWCACHE),
        .m_axi_awprot(m_axi_Xi[i].AWPROT),
        .m_axi_awregion(m_axi_Xi[i].AWREGION),
        .m_axi_awqos(m_axi_Xi[i].AWQOS),
        .m_axi_awvalid(m_axi_Xi[i].AWVALID),
        .m_axi_awready(m_axi_Xi[i].AWREADY),
        .m_axi_wdata(m_axi_Xi[i].WDATA),
        .m_axi_wstrb(m_axi_Xi[i].WSTRB),
        .m_axi_wlast(m_axi_Xi[i].WLAST),
        .m_axi_wvalid(m_axi_Xi[i].WVALID),
        .m_axi_wready(m_axi_Xi[i].WREADY),
        .m_axi_bresp(m_axi_Xi[i].BRESP),
        .m_axi_bvalid(m_axi_Xi[i].BVALID),
        .m_axi_bready(m_axi_Xi[i].BREADY),
        .m_axi_araddr(m_axi_Xi[i].ARADDR),
        .m_axi_arlen(m_axi_Xi[i].ARLEN),
        .m_axi_arsize(m_axi_Xi[i].ARSIZE),
        .m_axi_arburst(m_axi_Xi[i].ARBURST),
        .m_axi_arlock(m_axi_Xi[i].ARLOCK),
        .m_axi_arcache(m_axi_Xi[i].ARCACHE),
        .m_axi_arprot(m_axi_Xi[i].ARPROT),
        .m_axi_arregion(m_axi_Xi[i].ARREGION),
        .m_axi_arqos(m_axi_Xi[i].ARQOS),
        .m_axi_arvalid(m_axi_Xi[i].ARVALID),
        .m_axi_arready(m_axi_Xi[i].ARREADY),
        .m_axi_rdata(m_axi_Xi[i].RDATA),
        .m_axi_rresp(m_axi_Xi[i].RRESP),
        .m_axi_rlast(m_axi_Xi[i].RLAST),
        .m_axi_rvalid(m_axi_Xi[i].RVALID),
        .m_axi_rready(m_axi_Xi[i].RREADY)
        );

        spmv_calc_kernel #(
            .COLINDEX_BASE_ADDR_1(i * 48'h10000000 + 48'h02000000),
            .COLINDEX_BASE_ADDR_2(i * 48'h10000000 + 48'h03000000),
            .COLINDEX_BASE_ADDR_3(i * 48'h10000000 + 48'h04000000),
            .COLINDEX_BASE_ADDR_4(i * 48'h10000000 + 48'h05000000),

            .Read_NNZ_ADDR_BASE(i * 48'h10000000 + 0),
            .Read_NNZ_ADDR_GAP(48'h01000000 / 4),
            .Yi_Base_ADDR(i * 48'h10000000 + 48'h01000000),
            .Yi_Base_ADDR_GAP(48'h01000000 / 4),

            .Val_BASE_ADDR(i * 48'h10000000 + 48'h06000000)
            
        )spmv_calc_kernel (
            .clk(axis_clk),
            .rstn(rstn && ~(config_wire[32*3 *i + 7]) ),
            .config_wire(config_wire[`getvec(32*3,i)]),
            .status_wire(status_wire[`getvec(32*3,i)]),
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
            .axi_backend_req(axi_Xi)
        );
     end
     endgenerate
endmodule