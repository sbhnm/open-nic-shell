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
    output [3 : 0] m_axi_bram_arlen,
    output [2 : 0] m_axi_bram_arsize,
    output m_axi_bram_arvalid,
    output [47 : 0] m_axi_bram_awaddr,
    output [1 : 0] m_axi_bram_awburst,
    output [3 : 0] m_axi_bram_awlen,
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
    wire [511 : 0] axi_crossbar_wdata;
    wire [63 : 0] axi_crossbar_wstrb;
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
    wire [511 : 0] axi_crossbar_rdata;
    wire [3 : 0] axi_crossbar_rresp;
    wire [1 : 0] axi_crossbar_rlast;
    wire [1 : 0] axi_crossbar_rvalid;
    wire [1 : 0] axi_crossbar_rready;
    

    wire [47 : 0] axi_w256_awaddr;
    wire [7 : 0] axi_w256_awlen;
    wire [2 : 0] axi_w256_awsize;
    wire [1 : 0] axi_w256_awburst;
    wire [0 : 0] axi_w256_awlock;
    wire [3 : 0] axi_w256_awcache;
    wire [2 : 0] axi_w256_awprot;
    wire [3 : 0] axi_w256_awqos;
    wire [0 : 0] axi_w256_awvalid;
    wire [0 : 0] axi_w256_awready;
    wire [255 : 0] axi_w256_wdata;
    wire [31 : 0] axi_w256_wstrb;
    wire [0 : 0] axi_w256_wlast;
    wire [0 : 0] axi_w256_wvalid;
    wire [0 : 0] axi_w256_wready;
    wire [1 : 0] axi_w256_bresp;
    wire [0 : 0] axi_w256_bvalid;
    wire [0 : 0] axi_w256_bready;
    wire [47 : 0] axi_w256_araddr;
    wire [7 : 0] axi_w256_arlen;
    wire [2 : 0] axi_w256_arsize;
    wire [1 : 0] axi_w256_arburst;
    wire [0 : 0] axi_w256_arlock;
    wire [3 : 0] axi_w256_arcache;
    wire [2 : 0] axi_w256_arprot;
    wire [3 : 0] axi_w256_arqos;
    wire [0 : 0] axi_w256_arvalid;
    wire [0 : 0] axi_w256_arready;
    wire [255 : 0] axi_w256_rdata;
    wire [1 : 0] axi_w256_rresp;
    wire [0 : 0] axi_w256_rlast;
    wire [0 : 0] axi_w256_rvalid;
    wire [0 : 0] axi_w256_rready;
    
    assign m_axi_hbm_araddr =axi_crossbar_araddr[`getvec(48,0)];
    assign m_axi_hbm_arburst = axi_crossbar_arburst[`getvec(2,0)];
    assign m_axi_hbm_arlen = axi_crossbar_arlen[`getvec(8,0)];
    assign m_axi_hbm_arsize = axi_crossbar_arsize[`getvec(3,0)];
    assign m_axi_hbm_arvalid = axi_crossbar_arvalid[`getvec(1,0)];
    assign m_axi_hbm_awaddr  = axi_crossbar_awaddr[`getvec(48,0)];
    assign m_axi_hbm_awburst = axi_crossbar_awburst[`getvec(2,0)];
    assign m_axi_hbm_awlen = axi_crossbar_awlen[`getvec(8,0)];
    assign m_axi_hbm_awsize = axi_crossbar_awsize[`getvec(3,0)];
    assign m_axi_hbm_awvalid = axi_crossbar_awvalid[`getvec(1,0)];
    assign m_axi_hbm_rready = axi_crossbar_rready[`getvec(1,0)];
    assign m_axi_hbm_bready = axi_crossbar_bready[`getvec(1,0)];
    assign m_axi_hbm_wdata = axi_crossbar_wdata[`getvec(256,0)];
    assign m_axi_hbm_wlast = axi_crossbar_wlast[`getvec(1,0)];
    assign  m_axi_hbm_wstrb = axi_crossbar_wstrb[`getvec(32,0)];
    assign m_axi_hbm_wvalid = axi_crossbar_wvalid[`getvec(1,0)];
    
  
    assign axi_crossbar_awready[`getvec(1,0)] = m_axi_hbm_awready;        
    assign axi_crossbar_wready[`getvec(1,0)] = m_axi_hbm_wready;      
    assign axi_crossbar_bresp[`getvec(2,0)] = m_axi_hbm_bresp;        
    assign axi_crossbar_bvalid[`getvec(1,0)] = m_axi_hbm_bvalid;         
    assign axi_crossbar_arready[`getvec(1,0)] = m_axi_hbm_arready;    
    assign axi_crossbar_rdata[`getvec(256,0)] = m_axi_hbm_rdata;        
    assign axi_crossbar_rresp[`getvec(2,0)] = m_axi_hbm_rresp;        
    assign axi_crossbar_rlast[`getvec(1,0)] = m_axi_hbm_rlast;        
    assign axi_crossbar_rvalid[`getvec(1,0)] = m_axi_hbm_rvalid;      


    axi_Xi_Width_Converter axi_Xi_Width_Converter (
    .s_axi_aclk(pcie_aclk),          // input wire s_axi_aclk
    .s_axi_aresetn(pcie_aresetn),    // input wire s_axi_aresetn

    .s_axi_awaddr(axi_crossbar_awaddr[`getvec(48,1)]),      // output wire [95 : 0] s_axi_awaddr
    .s_axi_awlen(axi_crossbar_awlen[`getvec(8,1)]),        // output wire [15 : 0] s_axi_awlen
    .s_axi_awsize(axi_crossbar_awsize[`getvec(3,1)]),      // output wire [5 : 0] s_axi_awsize
    .s_axi_awburst(axi_crossbar_awburst[`getvec(2,1)]),    // output wire [3 : 0] s_axi_awburst
    .s_axi_awlock(axi_crossbar_awlock[`getvec(1,1)]),      // output wire [1 : 0] s_axi_awlock
    .s_axi_awcache(axi_crossbar_awcache[`getvec(4,1)]),    // output wire [7 : 0] s_axi_awcache
    .s_axi_awprot(axi_crossbar_awprot[`getvec(3,1)]),      // output wire [5 : 0] s_axi_awprot
    .s_axi_awregion(axi_crossbar_awregion[`getvec(4,1)]),  // output wire [7 : 0] s_axi_awregion
    .s_axi_awqos(axi_crossbar_awqos[`getvec(4,1)]),        // output wire [7 : 0] s_axi_awqos
    .s_axi_awvalid(axi_crossbar_awvalid[`getvec(1,1)]),    // output wire [1 : 0] s_axi_awvalid
    .s_axi_awready(axi_crossbar_awready[`getvec(1,1)]),    // input wire [1 : 0] s_axi_awready
    .s_axi_wdata(axi_crossbar_wdata[`getvec(256,1)]),        // output wire [511 : 0] s_axi_wdata
    .s_axi_wstrb(axi_crossbar_wstrb[`getvec(32,1)]),        // output wire [63 : 0] s_axi_wstrb
    .s_axi_wlast(axi_crossbar_wlast[`getvec(1,1)]),        // output wire [1 : 0] s_axi_wlast
    .s_axi_wvalid(axi_crossbar_wvalid[`getvec(1,1)]),      // output wire [1 : 0] s_axi_wvalid
    .s_axi_wready(axi_crossbar_wready[`getvec(1,1)]),      // input wire [1 : 0] s_axi_wready
    .s_axi_bresp(axi_crossbar_bresp[`getvec(2,1)]),        // input wire [3 : 0] s_axi_bresp
    .s_axi_bvalid(axi_crossbar_bvalid[`getvec(1,1)]),      // input wire [1 : 0] s_axi_bvalid
    .s_axi_bready(axi_crossbar_bready[`getvec(1,1)]),      // output wire [1 : 0] s_axi_bready
    .s_axi_araddr(axi_crossbar_araddr[`getvec(48,1)]),      // output wire [95 : 0] s_axi_araddr
    .s_axi_arlen(axi_crossbar_arlen[`getvec(8,1)]),        // output wire [15 : 0] s_axi_arlen
    .s_axi_arsize(axi_crossbar_arsize[`getvec(3,1)]),      // output wire [5 : 0] s_axi_arsize
    .s_axi_arburst(axi_crossbar_arburst[`getvec(2,1)]),    // output wire [3 : 0] s_axi_arburst
    .s_axi_arlock(axi_crossbar_arlock[`getvec(1,1)]),      // output wire [1 : 0] s_axi_arlock
    .s_axi_arcache(axi_crossbar_arcache[`getvec(4,1)]),    // output wire [7 : 0] s_axi_arcache
    .s_axi_arprot(axi_crossbar_arprot[`getvec(3,1)]),      // output wire [5 : 0] s_axi_arprot
    .s_axi_arregion(axi_crossbar_arregion[`getvec(4,1)]),  // output wire [7 : 0] s_axi_arregion
    .s_axi_arqos(axi_crossbar_arqos[`getvec(4,1)]),        // output wire [7 : 0] s_axi_arqos
    .s_axi_arvalid(axi_crossbar_arvalid[`getvec(1,1)]),    // output wire [1 : 0] s_axi_arvalid
    .s_axi_arready(axi_crossbar_arready[`getvec(1,1)]),    // input wire [1 : 0] s_axi_arready
    .s_axi_rdata(axi_crossbar_rdata[`getvec(256,1)]),        // input wire [511 : 0] s_axi_rdata
    .s_axi_rresp(axi_crossbar_rresp[`getvec(2,1)]),        // input wire [3 : 0] s_axi_rresp
    .s_axi_rlast(axi_crossbar_rlast[`getvec(1,1)]),        // input wire [1 : 0] s_axi_rlast
    .s_axi_rvalid(axi_crossbar_rvalid[`getvec(1,1)]),      // input wire [1 : 0] s_axi_rvalid
    .s_axi_rready(axi_crossbar_rready[`getvec(1,1)]),

    .m_axi_awaddr(m_axi_bram_awaddr),      // output wire [47 : 0] m_axi_awaddr
    .m_axi_awlen(m_axi_bram_awlen),        // output wire [7 : 0] m_axi_awlen
    .m_axi_awsize(m_axi_bram_awsize),      // output wire [2 : 0] m_axi_awsize
    .m_axi_awburst(m_axi_bram_awburst),    // output wire [1 : 0] m_axi_awburst
    .m_axi_awlock(m_axi_bram_awlock),      // output wire [0 : 0] m_axi_awlock
    .m_axi_awcache(m_axi_bram_awcache),    // output wire [3 : 0] m_axi_awcache
    .m_axi_awprot(m_axi_bram_awprot),      // output wire [2 : 0] m_axi_awprot
    .m_axi_awregion(m_axi_bram_awregion),  // output wire [3 : 0] m_axi_awregion
    .m_axi_awqos(m_axi_bram_awqos),        // output wire [3 : 0] m_axi_awqos
    .m_axi_awvalid(m_axi_bram_awvalid),    // output wire m_axi_awvalid
    .m_axi_awready(m_axi_bram_awready),    // input wire m_axi_awready
    .m_axi_wdata(m_axi_bram_wdata),        // output wire [63 : 0] m_axi_wdata
    .m_axi_wstrb(m_axi_bram_wstrb),        // output wire [7 : 0] m_axi_wstrb
    .m_axi_wlast(m_axi_bram_wlast),        // output wire m_axi_wlast
    .m_axi_wvalid(m_axi_bram_wvalid),      // output wire m_axi_wvalid
    .m_axi_wready(m_axi_bram_wready),      // input wire m_axi_wready
    .m_axi_bresp(m_axi_bram_bresp),        // input wire [1 : 0] m_axi_bresp
    .m_axi_bvalid(m_axi_bram_bvalid),      // input wire m_axi_bvalid
    .m_axi_bready(m_axi_bram_bready),      // output wire m_axi_bready
    .m_axi_araddr(m_axi_bram_araddr),      // output wire [47 : 0] m_axi_araddr
    .m_axi_arlen(m_axi_bram_arlen),        // output wire [7 : 0] m_axi_arlen
    .m_axi_arsize(m_axi_bram_arsize),      // output wire [2 : 0] m_axi_arsize
    .m_axi_arburst(m_axi_bram_arburst),    // output wire [1 : 0] m_axi_arburst
    .m_axi_arlock(m_axi_bram_arlock),      // output wire [0 : 0] m_axi_arlock
    .m_axi_arcache(m_axi_bram_arcache),    // output wire [3 : 0] m_axi_arcache
    .m_axi_arprot(m_axi_bram_arprot),      // output wire [2 : 0] m_axi_arprot
    .m_axi_arregion(m_axi_bram_arregion),  // output wire [3 : 0] m_axi_arregion
    .m_axi_arqos(m_axi_bram_arqos),        // output wire [3 : 0] m_axi_arqos
    .m_axi_arvalid(m_axi_bram_arvalid),    // output wire m_axi_arvalid
    .m_axi_arready(m_axi_bram_arready),    // input wire m_axi_arready
    .m_axi_rdata(m_axi_bram_rdata),        // input wire [63 : 0] m_axi_rdata
    .m_axi_rresp(m_axi_bram_rresp),        // input wire [1 : 0] m_axi_rresp
    .m_axi_rlast(m_axi_bram_rlast),        // input wire m_axi_rlast
    .m_axi_rvalid(m_axi_bram_rvalid),      // input wire m_axi_rvalid
    .m_axi_rready(m_axi_bram_rready)      // output wire m_axi_rready
);

    

   axi_hbm_bram_crossbar axi_hbm_bram_crossbar (
    .aclk(pcie_aclk),                      // input wire aclk
    .aresetn(pcie_aresetn),                // input wire aresetn

    .s_axi_awaddr(axi_w256_awaddr),      // input wire [47 : 0] s_axi_awaddr
    .s_axi_awlen(axi_w256_awlen),        // input wire [7 : 0] s_axi_awlen
    .s_axi_awsize(axi_w256_awsize),      // input wire [2 : 0] s_axi_awsize
    .s_axi_awburst(axi_w256_awburst),    // input wire [1 : 0] s_axi_awburst
    .s_axi_awlock(axi_w256_awlock),      // input wire [0 : 0] s_axi_awlock
    .s_axi_awcache(axi_w256_awcache),    // input wire [3 : 0] s_axi_awcache
    .s_axi_awprot(axi_w256_awprot),      // input wire [2 : 0] s_axi_awprot
    .s_axi_awqos(axi_w256_awqos),        // input wire [3 : 0] s_axi_awqos
    .s_axi_awvalid(axi_w256_awvalid),    // input wire [0 : 0] s_axi_awvalid
    .s_axi_awready(axi_w256_awready),    // output wire [0 : 0] s_axi_awready
    .s_axi_wdata(axi_w256_wdata),        // input wire [255 : 0] s_axi_wdata
    .s_axi_wstrb(axi_w256_wstrb),        // input wire [31 : 0] s_axi_wstrb
    .s_axi_wlast(axi_w256_wlast),        // input wire [0 : 0] s_axi_wlast
    .s_axi_wvalid(axi_w256_wvalid),      // input wire [0 : 0] s_axi_wvalid
    .s_axi_wready(axi_w256_wready),      // output wire [0 : 0] s_axi_wready
    .s_axi_bresp(axi_w256_bresp),        // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid(axi_w256_bvalid),      // output wire [0 : 0] s_axi_bvalid
    .s_axi_bready(axi_w256_bready),      // input wire [0 : 0] s_axi_bready
    .s_axi_araddr(axi_w256_araddr),      // input wire [47 : 0] s_axi_araddr
    .s_axi_arlen(axi_w256_arlen),        // input wire [7 : 0] s_axi_arlen
    .s_axi_arsize(axi_w256_arsize),      // input wire [2 : 0] s_axi_arsize
    .s_axi_arburst(axi_w256_arburst),    // input wire [1 : 0] s_axi_arburst
    .s_axi_arlock(axi_w256_arlock),      // input wire [0 : 0] s_axi_arlock
    .s_axi_arcache(axi_w256_arcache),    // input wire [3 : 0] s_axi_arcache
    .s_axi_arprot(axi_w256_arprot),      // input wire [2 : 0] s_axi_arprot
    .s_axi_arqos(axi_w256_arqos),        // input wire [3 : 0] s_axi_arqos
    .s_axi_arvalid(axi_w256_arvalid),    // input wire [0 : 0] s_axi_arvalid
    .s_axi_arready(axi_w256_arready),    // output wire [0 : 0] s_axi_arready
    .s_axi_rdata(axi_w256_rdata),        // output wire [255 : 0] s_axi_rdata
    .s_axi_rresp(axi_w256_rresp),        // output wire [1 : 0] s_axi_rresp
    .s_axi_rlast(axi_w256_rlast),        // output wire [0 : 0] s_axi_rlast
    .s_axi_rvalid(axi_w256_rvalid),      // output wire [0 : 0] s_axi_rvalid
    .s_axi_rready(axi_w256_rready),      // input wire [0 : 0] s_axi_rready

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

    .s_axi_awaddr(s_axi_pcie_awaddr),      // output wire [95 : 0] s_axi_awaddr
    .s_axi_awlen(s_axi_pcie_awlen),        // output wire [15 : 0] s_axi_awlen
    .s_axi_awsize(s_axi_pcie_awsize),      // output wire [5 : 0] s_axi_awsize
    .s_axi_awburst(s_axi_pcie_awburst),    // output wire [3 : 0] s_axi_awburst
    .s_axi_awlock(s_axi_pcie_awlock),      // output wire [1 : 0] s_axi_awlock
    .s_axi_awcache(s_axi_pcie_awcache),    // output wire [7 : 0] s_axi_awcache
    .s_axi_awprot(s_axi_pcie_awprot),      // output wire [5 : 0] s_axi_awprot
    .s_axi_awregion(s_axi_pcie_awregion),  // output wire [7 : 0] s_axi_awregion
    .s_axi_awqos(s_axi_pcie_awqos),        // output wire [7 : 0] s_axi_awqos
    .s_axi_awvalid(s_axi_pcie_awvalid),    // output wire [1 : 0] s_axi_awvalid
    .s_axi_awready(s_axi_pcie_awready),    // input wire [1 : 0] s_axi_awready
    .s_axi_wdata(s_axi_pcie_wdata),        // output wire [511 : 0] s_axi_wdata
    .s_axi_wstrb(s_axi_pcie_wstrb),        // output wire [63 : 0] s_axi_wstrb
    .s_axi_wlast(s_axi_pcie_wlast),        // output wire [1 : 0] s_axi_wlast
    .s_axi_wvalid(s_axi_pcie_wvalid),      // output wire [1 : 0] s_axi_wvalid
    .s_axi_wready(s_axi_pcie_wready),      // input wire [1 : 0] s_axi_wready
    .s_axi_bresp(s_axi_pcie_bresp),        // input wire [3 : 0] s_axi_bresp
    .s_axi_bvalid(s_axi_pcie_bvalid),      // input wire [1 : 0] s_axi_bvalid
    .s_axi_bready(s_axi_pcie_bready),      // output wire [1 : 0] s_axi_bready
    .s_axi_araddr(s_axi_pcie_araddr),      // output wire [95 : 0] s_axi_araddr
    .s_axi_arlen(s_axi_pcie_arlen),        // output wire [15 : 0] s_axi_arlen
    .s_axi_arsize(s_axi_pcie_arsize),      // output wire [5 : 0] s_axi_arsize
    .s_axi_arburst(s_axi_pcie_arburst),    // output wire [3 : 0] s_axi_arburst
    .s_axi_arlock(s_axi_pcie_arlock),      // output wire [1 : 0] s_axi_arlock
    .s_axi_arcache(s_axi_pcie_arcache),    // output wire [7 : 0] s_axi_arcache
    .s_axi_arprot(s_axi_pcie_arprot),      // output wire [5 : 0] s_axi_arprot
    .s_axi_arregion(s_axi_pcie_arregion),  // output wire [7 : 0] s_axi_arregion
    .s_axi_arqos(s_axi_pcie_arqos),        // output wire [7 : 0] s_axi_arqos
    .s_axi_arvalid(s_axi_pcie_arvalid),    // output wire [1 : 0] s_axi_arvalid
    .s_axi_arready(s_axi_pcie_arready),    // input wire [1 : 0] s_axi_arready
    .s_axi_rdata(s_axi_pcie_rdata),        // input wire [511 : 0] s_axi_rdata
    .s_axi_rresp(s_axi_pcie_rresp),        // input wire [3 : 0] s_axi_rresp
    .s_axi_rlast(s_axi_pcie_rlast),        // input wire [1 : 0] s_axi_rlast
    .s_axi_rvalid(s_axi_pcie_rvalid),      // input wire [1 : 0] s_axi_rvalid
    .s_axi_rready(s_axi_pcie_rready),      // output wire [1 : 0] s_axi_rready

    .m_axi_awaddr(axi_w256_awaddr[`getvec(48,0)]),      // output wire [95 : 0] m_axi_awaddr
    .m_axi_awlen(axi_w256_awlen[`getvec(8,0)]),        // output wire [15 : 0] m_axi_awlen
    .m_axi_awsize(axi_w256_awsize[`getvec(3,0)]),      // output wire [5 : 0] m_axi_awsize
    .m_axi_awburst(axi_w256_awburst[`getvec(2,0)]),    // output wire [3 : 0] m_axi_awburst
    .m_axi_awlock(axi_w256_awlock[`getvec(1,0)]),      // output wire [1 : 0] m_axi_awlock
    .m_axi_awcache(axi_w256_awcache[`getvec(4,0)]),    // output wire [7 : 0] m_axi_awcache
    .m_axi_awprot(axi_w256_awprot[`getvec(3,0)]),      // output wire [5 : 0] m_axi_awprot
//    .m_axi_awregion(axi_w256_awregion[`getvec(4,0)]),  // output wire [7 : 0] m_axi_awregion
    .m_axi_awqos(axi_w256_awqos[`getvec(4,0)]),        // output wire [7 : 0] m_axi_awqos
    .m_axi_awvalid(axi_w256_awvalid[`getvec(1,0)]),    // output wire [1 : 0] m_axi_awvalid
    .m_axi_awready(axi_w256_awready[`getvec(1,0)]),    // input wire [1 : 0] m_axi_awready
    .m_axi_wdata(axi_w256_wdata[`getvec(256,0)]),        // output wire [511 : 0] m_axi_wdata
    .m_axi_wstrb(axi_w256_wstrb[`getvec(32,0)]),        // output wire [63 : 0] m_axi_wstrb
    .m_axi_wlast(axi_w256_wlast[`getvec(1,0)]),        // output wire [1 : 0] m_axi_wlast
    .m_axi_wvalid(axi_w256_wvalid[`getvec(1,0)]),      // output wire [1 : 0] m_axi_wvalid
    .m_axi_wready(axi_w256_wready[`getvec(1,0)]),      // input wire [1 : 0] m_axi_wready
    .m_axi_bresp(axi_w256_bresp[`getvec(2,0)]),        // input wire [3 : 0] m_axi_bresp
    .m_axi_bvalid(axi_w256_bvalid[`getvec(1,0)]),      // input wire [1 : 0] m_axi_bvalid
    .m_axi_bready(axi_w256_bready[`getvec(1,0)]),      // output wire [1 : 0] m_axi_bready
    .m_axi_araddr(axi_w256_araddr[`getvec(48,0)]),      // output wire [95 : 0] m_axi_araddr
    .m_axi_arlen(axi_w256_arlen[`getvec(8,0)]),        // output wire [15 : 0] m_axi_arlen
    .m_axi_arsize(axi_w256_arsize[`getvec(3,0)]),      // output wire [5 : 0] m_axi_arsize
    .m_axi_arburst(axi_w256_arburst[`getvec(2,0)]),    // output wire [3 : 0] m_axi_arburst
    .m_axi_arlock(axi_w256_arlock[`getvec(1,0)]),      // output wire [1 : 0] m_axi_arlock
    .m_axi_arcache(axi_w256_arcache[`getvec(4,0)]),    // output wire [7 : 0] m_axi_arcache
    .m_axi_arprot(axi_w256_arprot[`getvec(3,0)]),      // output wire [5 : 0] m_axi_arprot
//    .m_axi_arregion(axi_w256_arregion[`getvec(4,0)]),  // output wire [7 : 0] m_axi_arregion
    .m_axi_arqos(axi_w256_arqos[`getvec(4,0)]),        // output wire [7 : 0] m_axi_arqos
    .m_axi_arvalid(axi_w256_arvalid[`getvec(1,0)]),    // output wire [1 : 0] m_axi_arvalid
    .m_axi_arready(axi_w256_arready[`getvec(1,0)]),    // input wire [1 : 0] m_axi_arready
    .m_axi_rdata(axi_w256_rdata[`getvec(256,0)]),        // input wire [511 : 0] m_axi_rdata
    .m_axi_rresp(axi_w256_rresp[`getvec(2,0)]),        // input wire [3 : 0] m_axi_rresp
    .m_axi_rlast(axi_w256_rlast[`getvec(1,0)]),        // input wire [1 : 0] m_axi_rlast
    .m_axi_rvalid(axi_w256_rvalid[`getvec(1,0)]),      // input wire [1 : 0] m_axi_rvalid
    .m_axi_rready(axi_w256_rready[`getvec(1,0)])  
    );
    
endmodule