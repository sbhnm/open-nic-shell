`include "pcie_spmv_macros.vh"
`timescale 1ns/1ps
//负责X vec 的写入和 Y Vec的读出
module spmv_vector_loader #(
) (
    output s_axi_pcie_awready,
    output s_axi_pcie_wready,
    output [3 : 0] s_axi_pcie_bid,
    output [1 : 0] s_axi_pcie_bresp,
    output s_axi_pcie_bvalid,
    output s_axi_pcie_arready,
    output [3 : 0] s_axi_pcie_rid,
    output [511 : 0] s_axi_pcie_rdata,
    output [1 : 0] s_axi_pcie_rresp,
    output s_axi_pcie_rlast,
    output s_axi_pcie_rvalid,
    input [3 : 0] s_axi_pcie_awid,
    input [63 : 0] s_axi_pcie_awaddr,
    input [31 : 0] s_axi_pcie_awuser,
    input [7 : 0] s_axi_pcie_awlen,
    input [2 : 0] s_axi_pcie_awsize,
    input [1 : 0] s_axi_pcie_awburst,
    input [2 : 0] s_axi_pcie_awprot,
    input s_axi_pcie_awvalid,
    input s_axi_pcie_awlock,
    input [3 : 0] s_axi_pcie_awcache,
    input [511 : 0] s_axi_pcie_wdata,
    input [63 : 0] s_axi_pcie_wuser,
    input [63 : 0] s_axi_pcie_wstrb,
    input s_axi_pcie_awregion,
    input s_axi_pcie_awqos,
    input s_axi_pcie_wlast,
    input s_axi_pcie_wvalid,
    input s_axi_pcie_bready,
    input [3 : 0] s_axi_pcie_arid,
    input [63 : 0] s_axi_pcie_araddr,
    input [31 : 0] s_axi_pcie_aruser,
    input s_axi_pcie_arregion,
    input s_axi_pcie_arqos,
    input [7 : 0] s_axi_pcie_arlen,
    input [2 : 0] s_axi_pcie_arsize,
    input [1 : 0] s_axi_pcie_arburst,
    input [2 : 0] s_axi_pcie_arprot,
    input s_axi_pcie_arvalid,
    input s_axi_pcie_arlock,
    input [3 : 0] s_axi_pcie_arcache,
    input s_axi_pcie_rready,



    output [47 : 0] m_axi_hbm_araddr,
    output [1 : 0] m_axi_hbm_arburst,
    output [3 : 0] m_axi_hbm_arlen,
    output [2 : 0] m_axi_hbm_arsize,
    output m_axi_hbm_arvalid,
    output [47 : 0] m_axi_hbm_awaddr,
    output [1 : 0] m_axi_hbm_awburst,
    output [3 : 0] m_axi_hbm_awlen,
    output [2 : 0] m_axi_hbm_awsize,
    output m_axi_hbm_awvalid,
    output m_axi_hbm_rready,
    output m_axi_hbm_bready,
    output [255 : 0] m_axi_hbm_wdata,
    output m_axi_hbm_wlast,
    output [31 : 0] m_axi_hbm_wstrb,
    output m_axi_hbm_wvalid,
    
    input m_axi_hbm_arready,
    input m_axi_hbm_awready,
    input [255 : 0] m_axi_hbm_rdata,
    input m_axi_hbm_rlast,
    input [1 : 0] m_axi_hbm_rresp,
    input m_axi_hbm_rvalid,
    input m_axi_hbm_wready,
    input m_axi_hbm_bvalid,
    input [1 : 0] m_axi_hbm_bresp,


    output [47 : 0] m_axi_bram_araddr,
    output [1 : 0] m_axi_bram_arburst,
    output [7 : 0] m_axi_bram_arlen,
    output [2 : 0] m_axi_bram_arsize,
    output m_axi_bram_arvalid,
    output [47 : 0] m_axi_bram_awaddr,
    output [1 : 0] m_axi_bram_awburst,
    output [7 : 0] m_axi_bram_awlen,
    output [2 : 0] m_axi_bram_awsize,
    output m_axi_bram_awvalid,
    output m_axi_bram_rready,
    output m_axi_bram_bready,
    output [63 : 0] m_axi_bram_wdata,
    output m_axi_bram_wlast,
    output [7 : 0] m_axi_bram_wstrb,
    output m_axi_bram_wvalid,
    input m_axi_bram_arready,
    input m_axi_bram_awready,
    input [63 : 0] m_axi_bram_rdata,
    input m_axi_bram_rlast,
    input [1 : 0] m_axi_bram_rresp,
    input m_axi_bram_rvalid,
    input m_axi_bram_wready,
    input m_axi_bram_bvalid,
    input [1 : 0] m_axi_bram_bresp,

    input pcie_aclk,
    input pcie_aresetn

);
    // 连接 pcie - hbm data convertor

    wire [95 : 0] axi_crossbar_awaddr;
    wire [15 : 0] axi_crossbar_awlen;
    wire [5 : 0] axi_crossbar_awsize;
    wire [3 : 0] axi_crossbar_awburst;
    wire [1 : 0] axi_crossbar_awlock;
    wire [7 : 0] axi_crossbar_awcache;
    wire [5 : 0] axi_crossbar_awprot;
    wire [7 : 0] axi_crossbar_awregion;
    wire [7 : 0] axi_crossbar_awqos;
    wire [1 : 0] axi_crossbar_awvalid;
    wire [1 : 0] axi_crossbar_awready;
    wire [1023 : 0] axi_crossbar_wdata;
    wire [127 : 0] axi_crossbar_wstrb;
    wire [1 : 0] axi_crossbar_wlast;
    wire [1 : 0] axi_crossbar_wvalid;
    wire [1 : 0] axi_crossbar_wready;
    wire [3 : 0] axi_crossbar_bresp;
    wire [1 : 0] axi_crossbar_bvalid;
    wire [1 : 0] axi_crossbar_bready;
    wire [95 : 0] axi_crossbar_araddr;
    wire [15 : 0] axi_crossbar_arlen;
    wire [5 : 0] axi_crossbar_arsize;
    wire [3 : 0] axi_crossbar_arburst;
    wire [1 : 0] axi_crossbar_arlock;
    wire [7 : 0] axi_crossbar_arcache;
    wire [5 : 0] axi_crossbar_arprot;
    wire [7 : 0] axi_crossbar_arregion;
    wire [7 : 0] axi_crossbar_arqos;
    wire [1 : 0] axi_crossbar_arvalid;
    wire [1 : 0] axi_crossbar_arready;
    wire [1023 : 0] axi_crossbar_rdata;
    wire [3 : 0] axi_crossbar_rresp;
    wire [1 : 0] axi_crossbar_rlast;
    wire [1 : 0] axi_crossbar_rvalid;
    wire [1 : 0] axi_crossbar_rready;
    
    axi_bram_converter axi_bram_converter (
    .INTERCONNECT_ACLK(pcie_aclk),        // input wire INTERCONNECT_ACLK
    .INTERCONNECT_ARESETN(pcie_aresetn),  // input wire INTERCONNECT_ARESETN
    // .S00_AXI_ARESET_OUT_N(S00_AXI_ARESET_OUT_N),  // output wire S00_AXI_ARESET_OUT_N
    .S00_AXI_ACLK(pcie_aclk),                  // input wire S00_AXI_ACLK
    .S00_AXI_AWID(0),                  // input wire [0 : 0] S00_AXI_AWID
    .S00_AXI_AWADDR(axi_crossbar_awaddr[`getvec(48,1)]),              // input wire [47 : 0] S00_AXI_AWADDR
    .S00_AXI_AWLEN(axi_crossbar_awlen[`getvec(8,1)]),                // input wire [7 : 0] S00_AXI_AWLEN
    .S00_AXI_AWSIZE(axi_crossbar_awsize[`getvec(3,1)]),              // input wire [2 : 0] S00_AXI_AWSIZE
    .S00_AXI_AWBURST(axi_crossbar_awburst[`getvec(2,1)]),            // input wire [1 : 0] S00_AXI_AWBURST
    .S00_AXI_AWLOCK(axi_crossbar_awlock[`getvec(1,1)]),              // input wire S00_AXI_AWLOCK
    .S00_AXI_AWCACHE(axi_crossbar_awcache[`getvec(4,1)]),            // input wire [3 : 0] S00_AXI_AWCACHE
    .S00_AXI_AWPROT(axi_crossbar_awprot[`getvec(3,1)]),              // input wire [2 : 0] S00_AXI_AWPROT
    .S00_AXI_AWQOS(axi_crossbar_awqos[`getvec(4,1)]),                // input wire [3 : 0] S00_AXI_AWQOS
    .S00_AXI_AWVALID(axi_crossbar_awvalid[`getvec(1,1)]),            // input wire S00_AXI_AWVALID
    .S00_AXI_AWREADY(axi_crossbar_awready[`getvec(1,1)]),            // output wire S00_AXI_AWREADY
    .S00_AXI_WDATA(axi_crossbar_wdata[`getvec(512,1)]),                // input wire [255 : 0] S00_AXI_WDATA
    .S00_AXI_WSTRB(axi_crossbar_wstrb[`getvec(64,1)]),                // input wire [31 : 0] S00_AXI_WSTRB
    .S00_AXI_WLAST(axi_crossbar_wlast[`getvec(1,1)]),                // input wire S00_AXI_WLAST
    .S00_AXI_WVALID(axi_crossbar_wvalid[`getvec(1,1)]),              // input wire S00_AXI_WVALID
    .S00_AXI_WREADY(axi_crossbar_wready[`getvec(1,1)]),              // output wire S00_AXI_WREADY
    .S00_AXI_BID(),                    // output wire [0 : 0] S00_AXI_BID
    .S00_AXI_BRESP(axi_crossbar_bresp[`getvec(2,1)]),                // output wire [1 : 0] S00_AXI_BRESP
    .S00_AXI_BVALID(axi_crossbar_bvalid[`getvec(1,1)]),              // output wire S00_AXI_BVALID
    .S00_AXI_BREADY(axi_crossbar_bready[`getvec(1,1)]),              // input wire S00_AXI_BREADY
    .S00_AXI_ARID(0),                  // input wire [0 : 0] S00_AXI_ARID
    .S00_AXI_ARADDR(axi_crossbar_araddr[`getvec(48,1)]),              // input wire [47 : 0] S00_AXI_ARADDR
    .S00_AXI_ARLEN(axi_crossbar_arlen[`getvec(8,1)]),                // input wire [7 : 0] S00_AXI_ARLEN
    .S00_AXI_ARSIZE(axi_crossbar_arsize[`getvec(3,1)]),              // input wire [2 : 0] S00_AXI_ARSIZE
    .S00_AXI_ARBURST(axi_crossbar_arburst[`getvec(2,1)]),            // input wire [1 : 0] S00_AXI_ARBURST
    .S00_AXI_ARLOCK(axi_crossbar_arlock[`getvec(1,1)]),              // input wire S00_AXI_ARLOCK
    .S00_AXI_ARCACHE(axi_crossbar_arcache[`getvec(4,1)]),            // input wire [3 : 0] S00_AXI_ARCACHE
    .S00_AXI_ARPROT(axi_crossbar_arprot[`getvec(3,1)]),              // input wire [2 : 0] S00_AXI_ARPROT
    .S00_AXI_ARQOS(axi_crossbar_arqos[`getvec(4,1)]),                // input wire [3 : 0] S00_AXI_ARQOS
    .S00_AXI_ARVALID(axi_crossbar_arvalid[`getvec(1,1)]),            // input wire S00_AXI_ARVALID
    .S00_AXI_ARREADY(axi_crossbar_arready[`getvec(1,1)]),            // output wire S00_AXI_ARREADY
    .S00_AXI_RID(),                    // output wire [0 : 0] S00_AXI_RID
    .S00_AXI_RDATA(axi_crossbar_rdata[`getvec(512,1)]),                // output wire [255 : 0] S00_AXI_RDATA
    .S00_AXI_RRESP(axi_crossbar_rresp[`getvec(2,1)]),                // output wire [1 : 0] S00_AXI_RRESP
    .S00_AXI_RLAST(axi_crossbar_rlast[`getvec(1,1)]),                // output wire S00_AXI_RLAST
    .S00_AXI_RVALID(axi_crossbar_rvalid[`getvec(1,1)]),              // output wire S00_AXI_RVALID
    .S00_AXI_RREADY(axi_crossbar_rready[`getvec(1,1)]),              // input wire S00_AXI_RREADY
    
    .M00_AXI_ARESET_OUT_N(),  // output wire M00_AXI_ARESET_OUT_N
    .M00_AXI_ACLK(pcie_aclk),                  // input wire M00_AXI_ACLK
    .M00_AXI_AWID(),                  // output wire [3 : 0] M00_AXI_AWID
    .M00_AXI_AWADDR(m_axi_bram_awaddr),              // output wire [47 : 0] M00_AXI_AWADDR
    .M00_AXI_AWLEN(m_axi_bram_awlen),                // output wire [7 : 0] M00_AXI_AWLEN
    .M00_AXI_AWSIZE(m_axi_bram_awsize),              // output wire [2 : 0] M00_AXI_AWSIZE
    .M00_AXI_AWBURST(m_axi_bram_awburst),            // output wire [1 : 0] M00_AXI_AWBURST
    .M00_AXI_AWLOCK(m_axi_bram_awlock),              // output wire M00_AXI_AWLOCK
    .M00_AXI_AWCACHE(m_axi_bram_awcache),            // output wire [3 : 0] M00_AXI_AWCACHE
    .M00_AXI_AWPROT(m_axi_bram_awprot),              // output wire [2 : 0] M00_AXI_AWPROT
    .M00_AXI_AWQOS(m_axi_bram_awqos),                // output wire [3 : 0] M00_AXI_AWQOS
    .M00_AXI_AWVALID(m_axi_bram_awvalid),            // output wire M00_AXI_AWVALID
    .M00_AXI_AWREADY(m_axi_bram_awready),            // input wire M00_AXI_AWREADY
    .M00_AXI_WDATA(m_axi_bram_wdata),                // output wire [63 : 0] M00_AXI_WDATA
    .M00_AXI_WSTRB(m_axi_bram_wstrb),                // output wire [7 : 0] M00_AXI_WSTRB
    .M00_AXI_WLAST(m_axi_bram_wlast),                // output wire M00_AXI_WLAST
    .M00_AXI_WVALID(m_axi_bram_wvalid),              // output wire M00_AXI_WVALID
    .M00_AXI_WREADY(m_axi_bram_wready),              // input wire M00_AXI_WREADY
    .M00_AXI_BID(0),                    // input wire [3 : 0] M00_AXI_BID
    .M00_AXI_BRESP(m_axi_bram_bresp),                // input wire [1 : 0] M00_AXI_BRESP
    .M00_AXI_BVALID(m_axi_bram_bvalid),              // input wire M00_AXI_BVALID
    .M00_AXI_BREADY(m_axi_bram_bready),              // output wire M00_AXI_BREADY
    .M00_AXI_ARID(),                  // output wire [3 : 0] M00_AXI_ARID
    .M00_AXI_ARADDR(m_axi_bram_araddr),              // output wire [47 : 0] M00_AXI_ARADDR
    .M00_AXI_ARLEN(m_axi_bram_arlen),                // output wire [7 : 0] M00_AXI_ARLEN
    .M00_AXI_ARSIZE(m_axi_bram_arsize),              // output wire [2 : 0] M00_AXI_ARSIZE
    .M00_AXI_ARBURST(m_axi_bram_arburst),            // output wire [1 : 0] M00_AXI_ARBURST
    .M00_AXI_ARLOCK(m_axi_bram_arlock),              // output wire M00_AXI_ARLOCK
    .M00_AXI_ARCACHE(m_axi_bram_arcache),            // output wire [3 : 0] M00_AXI_ARCACHE
    .M00_AXI_ARPROT(m_axi_bram_arprot),              // output wire [2 : 0] M00_AXI_ARPROT
    .M00_AXI_ARQOS(m_axi_bram_arqos),                // output wire [3 : 0] M00_AXI_ARQOS
    .M00_AXI_ARVALID(m_axi_bram_arvalid),            // output wire M00_AXI_ARVALID
    .M00_AXI_ARREADY(m_axi_bram_arready),            // input wire M00_AXI_ARREADY
    .M00_AXI_RID(0),                    // input wire [3 : 0] M00_AXI_RID
    .M00_AXI_RDATA(m_axi_bram_rdata),                // input wire [63 : 0] M00_AXI_RDATA
    .M00_AXI_RRESP(m_axi_bram_rresp),                // input wire [1 : 0] M00_AXI_RRESP
    .M00_AXI_RLAST(m_axi_bram_rlast),                // input wire M00_AXI_RLAST
    .M00_AXI_RVALID(m_axi_bram_rvalid),              // input wire M00_AXI_RVALID
    .M00_AXI_RREADY(m_axi_bram_rready)              // output wire M00_AXI_RREADY
);
    

    axi_hbm_bram_crossbar axi_hbm_bram_crossbar (
    .aclk(pcie_aclk),                      // input wire aclk
    .aresetn(pcie_aresetn),                // input wire aresetn
    .s_axi_awaddr(s_axi_pcie_awaddr),      // input wire [47 : 0] s_axi_awaddr
    .s_axi_awlen(s_axi_pcie_awlen),        // input wire [7 : 0] s_axi_awlen
    .s_axi_awsize(s_axi_pcie_awsize),      // input wire [2 : 0] s_axi_awsize
    .s_axi_awburst(s_axi_pcie_awburst),    // input wire [1 : 0] s_axi_awburst
    .s_axi_awlock(s_axi_pcie_awlock),      // input wire [0 : 0] s_axi_awlock
    .s_axi_awcache(s_axi_pcie_awcache),    // input wire [3 : 0] s_axi_awcache
    .s_axi_awprot(s_axi_pcie_awprot),      // input wire [2 : 0] s_axi_awprot
    .s_axi_awqos(s_axi_pcie_awqos),        // input wire [3 : 0] s_axi_awqos
    .s_axi_awvalid(s_axi_pcie_awvalid),    // input wire [0 : 0] s_axi_awvalid
    .s_axi_awready(s_axi_pcie_awready),    // output wire [0 : 0] s_axi_awready
    .s_axi_wdata(s_axi_pcie_wdata),        // input wire [255 : 0] s_axi_wdata
    .s_axi_wstrb(s_axi_pcie_wstrb),        // input wire [31 : 0] s_axi_wstrb
    .s_axi_wlast(s_axi_pcie_wlast),        // input wire [0 : 0] s_axi_wlast
    .s_axi_wvalid(s_axi_pcie_wvalid),      // input wire [0 : 0] s_axi_wvalid
    .s_axi_wready(s_axi_pcie_wready),      // output wire [0 : 0] s_axi_wready
    .s_axi_bresp(s_axi_pcie_bresp),        // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid(s_axi_pcie_bvalid),      // output wire [0 : 0] s_axi_bvalid
    .s_axi_bready(s_axi_pcie_bready),      // input wire [0 : 0] s_axi_bready
    .s_axi_araddr(s_axi_pcie_araddr),      // input wire [47 : 0] s_axi_araddr
    .s_axi_arlen(s_axi_pcie_arlen),        // input wire [7 : 0] s_axi_arlen
    .s_axi_arsize(s_axi_pcie_arsize),      // input wire [2 : 0] s_axi_arsize
    .s_axi_arburst(s_axi_pcie_arburst),    // input wire [1 : 0] s_axi_arburst
    .s_axi_arlock(s_axi_pcie_arlock),      // input wire [0 : 0] s_axi_arlock
    .s_axi_arcache(s_axi_pcie_arcache),    // input wire [3 : 0] s_axi_arcache
    .s_axi_arprot(s_axi_pcie_arprot),      // input wire [2 : 0] s_axi_arprot
    .s_axi_arqos(s_axi_pcie_arqos),        // input wire [3 : 0] s_axi_arqos
    .s_axi_arvalid(s_axi_pcie_arvalid),    // input wire [0 : 0] s_axi_arvalid
    .s_axi_arready(s_axi_pcie_arready),    // output wire [0 : 0] s_axi_arready
    .s_axi_rdata(s_axi_pcie_rdata),        // output wire [255 : 0] s_axi_rdata
    .s_axi_rresp(s_axi_pcie_rresp),        // output wire [1 : 0] s_axi_rresp
    .s_axi_rlast(s_axi_pcie_rlast),        // output wire [0 : 0] s_axi_rlast
    .s_axi_rvalid(s_axi_pcie_rvalid),      // output wire [0 : 0] s_axi_rvalid
    .s_axi_rready(s_axi_pcie_rready),      // input wire [0 : 0] s_axi_rready

    .m_axi_awaddr(axi_crossbar_awaddr),      // output wire [95 : 0] m_axi_awaddr
    .m_axi_awlen(axi_crossbar_awlen),        // output wire [15 : 0] m_axi_awlen
    .m_axi_awsize(axi_crossbar_awsize),      // output wire [5 : 0] m_axi_awsize
    .m_axi_awburst(axi_crossbar_awburst),    // output wire [3 : 0] m_axi_awburst
    .m_axi_awlock(axi_crossbar_awlock),      // output wire [1 : 0] m_axi_awlock
    .m_axi_awcache(axi_crossbar_awcache),    // output wire [7 : 0] m_axi_awcache
    .m_axi_awprot(axi_crossbar_awprot),      // output wire [5 : 0] m_axi_awprot
    .m_axi_awregion(axi_crossbar_awregion),  // output wire [7 : 0] m_axi_awregion
    .m_axi_awqos(axi_crossbar_awqos),        // output wire [7 : 0] m_axi_awqos
    .m_axi_awvalid(axi_crossbar_awvalid),    // output wire [1 : 0] m_axi_awvalid
    .m_axi_awready(axi_crossbar_awready),    // input wire [1 : 0] m_axi_awready
    .m_axi_wdata(axi_crossbar_wdata),        // output wire [511 : 0] m_axi_wdata
    .m_axi_wstrb(axi_crossbar_wstrb),        // output wire [63 : 0] m_axi_wstrb
    .m_axi_wlast(axi_crossbar_wlast),        // output wire [1 : 0] m_axi_wlast
    .m_axi_wvalid(axi_crossbar_wvalid),      // output wire [1 : 0] m_axi_wvalid
    .m_axi_wready(axi_crossbar_wready),      // input wire [1 : 0] m_axi_wready
    .m_axi_bresp(axi_crossbar_bresp),        // input wire [3 : 0] m_axi_bresp
    .m_axi_bvalid(axi_crossbar_bvalid),      // input wire [1 : 0] m_axi_bvalid
    .m_axi_bready(axi_crossbar_bready),      // output wire [1 : 0] m_axi_bready
    .m_axi_araddr(axi_crossbar_araddr),      // output wire [95 : 0] m_axi_araddr
    .m_axi_arlen(axi_crossbar_arlen),        // output wire [15 : 0] m_axi_arlen
    .m_axi_arsize(axi_crossbar_arsize),      // output wire [5 : 0] m_axi_arsize
    .m_axi_arburst(axi_crossbar_arburst),    // output wire [3 : 0] m_axi_arburst
    .m_axi_arlock(axi_crossbar_arlock),      // output wire [1 : 0] m_axi_arlock
    .m_axi_arcache(axi_crossbar_arcache),    // output wire [7 : 0] m_axi_arcache
    .m_axi_arprot(axi_crossbar_arprot),      // output wire [5 : 0] m_axi_arprot
    .m_axi_arregion(axi_crossbar_arregion),  // output wire [7 : 0] m_axi_arregion
    .m_axi_arqos(axi_crossbar_arqos),        // output wire [7 : 0] m_axi_arqos
    .m_axi_arvalid(axi_crossbar_arvalid),    // output wire [1 : 0] m_axi_arvalid
    .m_axi_arready(axi_crossbar_arready),    // input wire [1 : 0] m_axi_arready
    .m_axi_rdata(axi_crossbar_rdata),        // input wire [511 : 0] m_axi_rdata
    .m_axi_rresp(axi_crossbar_rresp),        // input wire [3 : 0] m_axi_rresp
    .m_axi_rlast(axi_crossbar_rlast),        // input wire [1 : 0] m_axi_rlast
    .m_axi_rvalid(axi_crossbar_rvalid),      // input wire [1 : 0] m_axi_rvalid
    .m_axi_rready(axi_crossbar_rready)      // output wire [1 : 0] m_axi_rready    
    );

    pcie_hbm_converter pcie_hbm_converter (
    .s_axi_aclk(pcie_aclk),          // input wire s_axi_aclk
    .s_axi_aresetn(pcie_aresetn),    // input wire s_axi_aresetn

    .s_axi_awaddr(axi_crossbar_awaddr[`getvec(48,0)]),      // output wire [95 : 0] s_axi_awaddr
    .s_axi_awlen(axi_crossbar_awlen[`getvec(8,0)]),        // output wire [15 : 0] s_axi_awlen
    .s_axi_awsize(axi_crossbar_awsize[`getvec(3,0)]),      // output wire [5 : 0] s_axi_awsize
    .s_axi_awburst(axi_crossbar_awburst[`getvec(2,0)]),    // output wire [3 : 0] s_axi_awburst
    .s_axi_awlock(axi_crossbar_awlock[`getvec(1,0)]),      // output wire [1 : 0] s_axi_awlock
    .s_axi_awcache(axi_crossbar_awcache[`getvec(4,0)]),    // output wire [7 : 0] s_axi_awcache
    .s_axi_awprot(axi_crossbar_awprot[`getvec(3,0)]),      // output wire [5 : 0] s_axi_awprot
    // .s_axi_awregion(axi_crossbar_awregion[`getvec(8,0)]),  // output wire [7 : 0] s_axi_awregion
    .s_axi_awqos(axi_crossbar_awqos[`getvec(4,0)]),        // output wire [7 : 0] s_axi_awqos
    .s_axi_awvalid(axi_crossbar_awvalid[`getvec(1,0)]),    // output wire [1 : 0] s_axi_awvalid
    .s_axi_awready(axi_crossbar_awready[`getvec(1,0)]),    // input wire [1 : 0] s_axi_awready
    .s_axi_wdata(axi_crossbar_wdata[`getvec(512,0)]),        // output wire [511 : 0] s_axi_wdata
    .s_axi_wstrb(axi_crossbar_wstrb[`getvec(64,0)]),        // output wire [63 : 0] s_axi_wstrb
    .s_axi_wlast(axi_crossbar_wlast[`getvec(1,0)]),        // output wire [1 : 0] s_axi_wlast
    .s_axi_wvalid(axi_crossbar_wvalid[`getvec(1,0)]),      // output wire [1 : 0] s_axi_wvalid
    .s_axi_wready(axi_crossbar_wready[`getvec(1,0)]),      // input wire [1 : 0] s_axi_wready
    .s_axi_bresp(axi_crossbar_bresp[`getvec(2,0)]),        // input wire [3 : 0] s_axi_bresp
    .s_axi_bvalid(axi_crossbar_bvalid[`getvec(1,0)]),      // input wire [1 : 0] s_axi_bvalid
    .s_axi_bready(axi_crossbar_bready[`getvec(1,0)]),      // output wire [1 : 0] s_axi_bready
    .s_axi_araddr(axi_crossbar_araddr[`getvec(48,0)]),      // output wire [95 : 0] s_axi_araddr
    .s_axi_arlen(axi_crossbar_arlen[`getvec(8,0)]),        // output wire [15 : 0] s_axi_arlen
    .s_axi_arsize(axi_crossbar_arsize[`getvec(3,0)]),      // output wire [5 : 0] s_axi_arsize
    .s_axi_arburst(axi_crossbar_arburst[`getvec(2,0)]),    // output wire [3 : 0] s_axi_arburst
    .s_axi_arlock(axi_crossbar_arlock[`getvec(1,0)]),      // output wire [1 : 0] s_axi_arlock
    .s_axi_arcache(axi_crossbar_arcache[`getvec(4,0)]),    // output wire [7 : 0] s_axi_arcache
    .s_axi_arprot(axi_crossbar_arprot[`getvec(3,0)]),      // output wire [5 : 0] s_axi_arprot
    // .s_axi_arregion(axi_crossbar_arregion[`getvec(8,0)]),  // output wire [7 : 0] s_axi_arregion
    .s_axi_arqos(axi_crossbar_arqos[`getvec(4,0)]),        // output wire [7 : 0] s_axi_arqos
    .s_axi_arvalid(axi_crossbar_arvalid[`getvec(1,0)]),    // output wire [1 : 0] s_axi_arvalid
    .s_axi_arready(axi_crossbar_arready[`getvec(1,0)]),    // input wire [1 : 0] s_axi_arready
    .s_axi_rdata(axi_crossbar_rdata[`getvec(512,0)]),        // input wire [511 : 0] s_axi_rdata
    .s_axi_rresp(axi_crossbar_rresp[`getvec(2,0)]),        // input wire [3 : 0] s_axi_rresp
    .s_axi_rlast(axi_crossbar_rlast[`getvec(1,0)]),        // input wire [1 : 0] s_axi_rlast
    .s_axi_rvalid(axi_crossbar_rvalid[`getvec(1,0)]),      // input wire [1 : 0] s_axi_rvalid
    .s_axi_rready(axi_crossbar_rready[`getvec(1,0)]),      // output wire [1 : 0] s_axi_rready

    .m_axi_awaddr(m_axi_hbm_awaddr),      // output wire [95 : 0] m_axi_awaddr
    .m_axi_awlen(m_axi_hbm_awlen),        // output wire [15 : 0] m_axi_awlen
    .m_axi_awsize(m_axi_hbm_awsize),      // output wire [5 : 0] m_axi_awsize
    .m_axi_awburst(m_axi_hbm_awburst),    // output wire [3 : 0] m_axi_awburst
    .m_axi_awlock(m_axi_hbm_awlock),      // output wire [1 : 0] m_axi_awlock
    .m_axi_awcache(m_axi_hbm_awcache),    // output wire [7 : 0] m_axi_awcache
    .m_axi_awprot(m_axi_hbm_awprot),      // output wire [5 : 0] m_axi_awprot
//    .m_axi_awregion(m_axi_hbm_awregion),  // output wire [7 : 0] m_axi_awregion
    .m_axi_awqos(m_axi_hbm_awqos),        // output wire [7 : 0] m_axi_awqos
    .m_axi_awvalid(m_axi_hbm_awvalid),    // output wire [1 : 0] m_axi_awvalid
    .m_axi_awready(m_axi_hbm_awready),    // input wire [1 : 0] m_axi_awready
    .m_axi_wdata(m_axi_hbm_wdata),        // output wire [511 : 0] m_axi_wdata
    .m_axi_wstrb(m_axi_hbm_wstrb),        // output wire [63 : 0] m_axi_wstrb
    .m_axi_wlast(m_axi_hbm_wlast),        // output wire [1 : 0] m_axi_wlast
    .m_axi_wvalid(m_axi_hbm_wvalid),      // output wire [1 : 0] m_axi_wvalid
    .m_axi_wready(m_axi_hbm_wready),      // input wire [1 : 0] m_axi_wready
    .m_axi_bresp(m_axi_hbm_bresp),        // input wire [3 : 0] m_axi_bresp
    .m_axi_bvalid(m_axi_hbm_bvalid),      // input wire [1 : 0] m_axi_bvalid
    .m_axi_bready(m_axi_hbm_bready),      // output wire [1 : 0] m_axi_bready
    .m_axi_araddr(m_axi_hbm_araddr),      // output wire [95 : 0] m_axi_araddr
    .m_axi_arlen(m_axi_hbm_arlen),        // output wire [15 : 0] m_axi_arlen
    .m_axi_arsize(m_axi_hbm_arsize),      // output wire [5 : 0] m_axi_arsize
    .m_axi_arburst(m_axi_hbm_arburst),    // output wire [3 : 0] m_axi_arburst
    .m_axi_arlock(m_axi_hbm_arlock),      // output wire [1 : 0] m_axi_arlock
    .m_axi_arcache(m_axi_hbm_arcache),    // output wire [7 : 0] m_axi_arcache
    .m_axi_arprot(m_axi_hbm_arprot),      // output wire [5 : 0] m_axi_arprot
//    .m_axi_arregion(m_axi_hbm_arregion),  // output wire [7 : 0] m_axi_arregion
    .m_axi_arqos(m_axi_hbm_arqos),        // output wire [7 : 0] m_axi_arqos
    .m_axi_arvalid(m_axi_hbm_arvalid),    // output wire [1 : 0] m_axi_arvalid
    .m_axi_arready(m_axi_hbm_arready),    // input wire [1 : 0] m_axi_arready
    .m_axi_rdata(m_axi_hbm_rdata),        // input wire [511 : 0] m_axi_rdata
    .m_axi_rresp(m_axi_hbm_rresp),        // input wire [3 : 0] m_axi_rresp
    .m_axi_rlast(m_axi_hbm_rlast),        // input wire [1 : 0] m_axi_rlast
    .m_axi_rvalid(m_axi_hbm_rvalid),      // input wire [1 : 0] m_axi_rvalid
    .m_axi_rready(m_axi_hbm_rready)  
    );

endmodule