//Col Xi 直接接到hbm上
//Val 接 cross bar 后在拉出来
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

    output [CONF_NUM_KERNEL*4*48-1 : 0] m_axi_ColXi_araddr,
    output [CONF_NUM_KERNEL*4*2-1 : 0] m_axi_ColXi_arburst,
    output [CONF_NUM_KERNEL*4*8-1 : 0] m_axi_ColXi_arlen,
    output [CONF_NUM_KERNEL*4*3-1 : 0] m_axi_ColXi_arsize,
    output [CONF_NUM_KERNEL*4*1-1 : 0]m_axi_ColXi_arvalid,
    output [CONF_NUM_KERNEL*4*48-1 : 0] m_axi_ColXi_awaddr,
    output [CONF_NUM_KERNEL*4*2-1 : 0] m_axi_ColXi_awburst,
    output [CONF_NUM_KERNEL*4*8-1 : 0] m_axi_ColXi_awlen,
    output [CONF_NUM_KERNEL*4*3-1 : 0] m_axi_ColXi_awsize,
    output [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_awvalid,
    output [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_rready,
    output [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_bready,
    output [CONF_NUM_KERNEL*4*256-1 : 0] m_axi_ColXi_wdata,
    output [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_wlast,
    output [CONF_NUM_KERNEL*4*32-1 : 0] m_axi_ColXi_wstrb,
    output [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_wvalid,
    input [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_arready,
    input [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_awready,
    input [CONF_NUM_KERNEL*4*256-1 : 0] m_axi_ColXi_rdata,
    input [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_rlast,
    input [CONF_NUM_KERNEL*4*2-1 : 0] m_axi_ColXi_rresp,
    input [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_rvalid,
    input [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_wready,
    input [CONF_NUM_KERNEL*4*2-1 : 0] m_axi_ColXi_bresp,
    input [CONF_NUM_KERNEL*4*1-1 : 0] m_axi_ColXi_bvalid,

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

    input clk,
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
    spmv_system_config spmv_system_config #(
        .CONF_NUM_KERNEL(CONF_NUM_KERNEL)
    )(
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

        .aclk(rstn)
    );
     generate for (genvar i = 0; i < CONF_NUM_KERNEL; i++) begin
        spmv_calc_kernel spmv_calc_kernel #(

        )(
            .clk(clk),
            .rstn(rstn),
            .config_wire(config_wire[`getvec(32*3,i)]),

            .m_axi_ColXi_araddr(m_axi_ColXi_araddr[`getvec(48*4,i)]),
            .m_axi_ColXi_arburst(m_axi_ColXi_arburst[`getvec(2*4,i)]),
            .m_axi_ColXi_arlen(m_axi_ColXi_arlen[`getvec(8*4,i)]),
            .m_axi_ColXi_arsize(m_axi_ColXi_arsize[`getvec(3*4,i)]),
            .m_axi_ColXi_arvalid(m_axi_ColXi_arvalid[`getvec(1*4,i)]),
            .m_axi_ColXi_awaddr(m_axi_ColXi_awaddr[`getvec(48*4,i)]),
            .m_axi_ColXi_awburst(m_axi_ColXi_awburst[`getvec(2*4,i)]),
            .m_axi_ColXi_awlen(m_axi_ColXi_awlen[`getvec(8*4,i)]),
            .m_axi_ColXi_awsize(m_axi_ColXi_awsize[`getvec(3*4,i)]),
            .m_axi_ColXi_awvalid(m_axi_ColXi_awvalid[`getvec(1*4,i)]),
            .m_axi_ColXi_rready(m_axi_ColXi_rready[`getvec(1*4,i)]),
            .m_axi_ColXi_bready(m_axi_ColXi_bready[`getvec(1*4,i)]),
            .m_axi_ColXi_wdata(m_axi_ColXi_wdata[`getvec(256*4,i)]),
            .m_axi_ColXi_wlast(m_axi_ColXi_wlast[`getvec(1*4,i)]),
            .m_axi_ColXi_wstrb(m_axi_ColXi_wstrb[`getvec(32*4,i)]),
            .m_axi_ColXi_wvalid(m_axi_ColXi_wvalid[`getvec(1*4,i)]),
            .m_axi_ColXi_arready(m_axi_ColXi_arready[`getvec(1*4,i)]),
            .m_axi_ColXi_awready(m_axi_ColXi_awready[`getvec(1*4,i)]),
            .m_axi_ColXi_rdata(m_axi_ColXi_rdata[`getvec(256*4,i)]),
            .m_axi_ColXi_rlast(m_axi_ColXi_rlast[`getvec(1*4,i)]),
            .m_axi_ColXi_rresp(m_axi_ColXi_rresp[`getvec(2*4,i)]),
            .m_axi_ColXi_rvalid(m_axi_ColXi_rvalid[`getvec(1*4,i)]),
            .m_axi_ColXi_wready(m_axi_ColXi_wready[`getvec(1*4,i)]),
            .m_axi_ColXi_bresp(m_axi_ColXi_bresp[`getvec(2*4,i)]),
            .m_axi_ColXi_bvalid(m_axi_ColXi_bvalid[`getvec(1*4,i)]),


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
            .m_axi_Val_bvalid(axi_Val_bvalid[`getvec(1,i)])

        );
     end
     endgenerate
endmodule