`include "pcie_spmv_macros.vh"
`timescale 1ns/1ps
//负责X vec 的写入和 Y Vec的读出
module spmv_vector_loader #(
) (
    output [0 : 0] s_axi_pcie_awready,
    output [0 : 0] s_axi_pcie_wready,
    output [3 : 0] s_axi_pcie_bid,
    output [1 : 0] s_axi_pcie_bresp,
    output [0 : 0] s_axi_pcie_bvalid,
    output [0 : 0] s_axi_pcie_arready,
    output [3 : 0] s_axi_pcie_rid,
    output [511 : 0] s_axi_pcie_rdata,
    output [1 : 0] s_axi_pcie_rresp,
    output [0 : 0] s_axi_pcie_rlast,
    output [0 : 0] s_axi_pcie_rvalid,
    input [3 : 0] s_axi_pcie_awid,
    input [63 : 0] s_axi_pcie_awaddr,
    input [31 : 0] s_axi_pcie_awuser,
    input [7 : 0] s_axi_pcie_awlen,
    input [2 : 0] s_axi_pcie_awsize,
    input [1 : 0] s_axi_pcie_awburst,
    input [2 : 0] s_axi_pcie_awprot,
    input [0 : 0] s_axi_pcie_awvalid,
    input [0 : 0] s_axi_pcie_awlock,
    input [3 : 0] s_axi_pcie_awcache,
    input [511 : 0] s_axi_pcie_wdata,
    input [63 : 0] s_axi_pcie_wuser,
    input [63 : 0] s_axi_pcie_wstrb,
    input [0 : 0] s_axi_pcie_awregion,
    input [0 : 0] s_axi_pcie_awqos,
    input [0 : 0] s_axi_pcie_wlast,
    input [0 : 0] s_axi_pcie_wvalid,
    input [0 : 0] s_axi_pcie_bready,
    input [3 : 0] s_axi_pcie_arid,
    input [63 : 0] s_axi_pcie_araddr,
    input [31 : 0] s_axi_pcie_aruser,
    input [0 : 0] s_axi_pcie_arregion,
    input [0 : 0] s_axi_pcie_arqos,
    input [7 : 0] s_axi_pcie_arlen,
    input [2 : 0] s_axi_pcie_arsize,
    input [1 : 0] s_axi_pcie_arburst,
    input [2 : 0] s_axi_pcie_arprot,
    input [0 : 0] s_axi_pcie_arvalid,
    input [0 : 0] s_axi_pcie_arlock,
    input [3 : 0] s_axi_pcie_arcache,
    input [0 : 0] s_axi_pcie_rready,



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


    input pcie_aclk,
    input pcie_aresetn

);
    // 连接 pcie - hbm data convertor

    pcie_hbm_converter pcie_hbm_converter (
    .s_axi_aclk(pcie_aclk),          // input wire s_axi_aclk
    .s_axi_aresetn(pcie_aresetn),    // input wire s_axi_aresetn

    .s_axi_awaddr(s_axi_pcie_awaddr[`getvec(48,0)]),      // output wire [95 : 0] s_axi_awaddr
    .s_axi_awlen(s_axi_pcie_awlen[`getvec(8,0)]),        // output wire [15 : 0] s_axi_awlen
    .s_axi_awsize(s_axi_pcie_awsize[`getvec(3,0)]),      // output wire [5 : 0] s_axi_awsize
    .s_axi_awburst(s_axi_pcie_awburst[`getvec(2,0)]),    // output wire [3 : 0] s_axi_awburst
    .s_axi_awlock(s_axi_pcie_awlock[`getvec(1,0)]),      // output wire [1 : 0] s_axi_awlock
    .s_axi_awcache(s_axi_pcie_awcache[`getvec(4,0)]),    // output wire [7 : 0] s_axi_awcache
    .s_axi_awprot(s_axi_pcie_awprot[`getvec(3,0)]),      // output wire [5 : 0] s_axi_awprot
    // .s_axi_awregion(s_axi_pcie_awregion[`getvec(8,0)]),  // output wire [7 : 0] s_axi_awregion
    .s_axi_awqos(s_axi_pcie_awqos[`getvec(1,0)]),        // output wire [7 : 0] s_axi_awqos
    .s_axi_awvalid(s_axi_pcie_awvalid[`getvec(1,0)]),    // output wire [1 : 0] s_axi_awvalid
    .s_axi_awready(s_axi_pcie_awready[`getvec(1,0)]),    // input wire [1 : 0] s_axi_awready
    .s_axi_wdata(s_axi_pcie_wdata[`getvec(512,0)]),        // output wire [511 : 0] s_axi_wdata
    .s_axi_wstrb(s_axi_pcie_wstrb[`getvec(64,0)]),        // output wire [63 : 0] s_axi_wstrb
    .s_axi_wlast(s_axi_pcie_wlast[`getvec(1,0)]),        // output wire [1 : 0] s_axi_wlast
    .s_axi_wvalid(s_axi_pcie_wvalid[`getvec(1,0)]),      // output wire [1 : 0] s_axi_wvalid
    .s_axi_wready(s_axi_pcie_wready[`getvec(1,0)]),      // input wire [1 : 0] s_axi_wready
    .s_axi_bresp(s_axi_pcie_bresp[`getvec(2,0)]),        // input wire [3 : 0] s_axi_bresp
    .s_axi_bvalid(s_axi_pcie_bvalid[`getvec(1,0)]),      // input wire [1 : 0] s_axi_bvalid
    .s_axi_bready(s_axi_pcie_bready[`getvec(1,0)]),      // output wire [1 : 0] s_axi_bready
    .s_axi_araddr(s_axi_pcie_araddr[`getvec(48,0)]),      // output wire [95 : 0] s_axi_araddr
    .s_axi_arlen(s_axi_pcie_arlen[`getvec(8,0)]),        // output wire [15 : 0] s_axi_arlen
    .s_axi_arsize(s_axi_pcie_arsize[`getvec(3,0)]),      // output wire [5 : 0] s_axi_arsize
    .s_axi_arburst(s_axi_pcie_arburst[`getvec(2,0)]),    // output wire [3 : 0] s_axi_arburst
    .s_axi_arlock(s_axi_pcie_arlock[`getvec(1,0)]),      // output wire [1 : 0] s_axi_arlock
    .s_axi_arcache(s_axi_pcie_arcache[`getvec(4,0)]),    // output wire [7 : 0] s_axi_arcache
    .s_axi_arprot(s_axi_pcie_arprot[`getvec(3,0)]),      // output wire [5 : 0] s_axi_arprot
    // .s_axi_arregion(s_axi_pcie_arregion[`getvec(8,0)]),  // output wire [7 : 0] s_axi_arregion
    .s_axi_arqos(s_axi_pcie_arqos[`getvec(1,0)]),        // output wire [7 : 0] s_axi_arqos
    .s_axi_arvalid(s_axi_pcie_arvalid[`getvec(1,0)]),    // output wire [1 : 0] s_axi_arvalid
    .s_axi_arready(s_axi_pcie_arready[`getvec(1,0)]),    // input wire [1 : 0] s_axi_arready
    .s_axi_rdata(s_axi_pcie_rdata[`getvec(512,0)]),        // input wire [511 : 0] s_axi_rdata
    .s_axi_rresp(s_axi_pcie_rresp[`getvec(2,0)]),        // input wire [3 : 0] s_axi_rresp
    .s_axi_rlast(s_axi_pcie_rlast[`getvec(1,0)]),        // input wire [1 : 0] s_axi_rlast
    .s_axi_rvalid(s_axi_pcie_rvalid[`getvec(1,0)]),      // input wire [1 : 0] s_axi_rvalid
    .s_axi_rready(s_axi_pcie_rready[`getvec(1,0)]),      // output wire [1 : 0] s_axi_rready

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