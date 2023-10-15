`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
//负责X vec 的写入和 Y Vec的读出
module spmv_vector_loader #(
    parameter int CONF_BASE_ADDR = 32'h0,
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
    input s_axi_pcie_wlast,
    input s_axi_pcie_wvalid,
    input s_axi_pcie_bready,
    input [3 : 0] s_axi_pcie_arid,
    input [63 : 0] s_axi_pcie_araddr,
    input [31 : 0] s_axi_pcie_aruser,
    input [7 : 0] s_axi_pcie_arlen,
    input [2 : 0] s_axi_pcie_arsize,
    input [1 : 0] s_axi_pcie_arburst,
    input [2 : 0] s_axi_pcie_arprot,
    input s_axi_pcie_arvalid,
    input s_axi_pcie_arlock,
    input [3 : 0] s_axi_pcie_arcache,
    input s_axi_pcie_rready,

    output [32 : 0] m_axi_hbm_araddr,
    output [1 : 0] m_axi_hbm_arburst,
    output [5 : 0] m_axi_hbm_arid,
    output [3 : 0] m_axi_hbm_arlen,
    output [2 : 0] m_axi_hbm_arsize,
    output m_axi_hbm_arvalid,
    output [32 : 0] m_axi_hbm_awaddr,
    output [1 : 0] m_axi_hbm_awburst,
    output [5 : 0] m_axi_hbm_awid,
    output [3 : 0] m_axi_hbm_awlen,
    output [2 : 0] m_axi_hbm_awsize,
    output m_axi_hbm_awvalid,
    output m_axi_hbm_rready,
    output m_axi_hbm_bready,
    output [255 : 0] m_axi_hbm_wdata,
    output m_axi_hbm_wlast,
    output [31 : 0] m_axi_hbm_wstrb,
    output [31 : 0] m_axi_hbm_wdata_parity,
    output m_axi_hbm_wvalid,
    input m_axi_hbm_arready,
    input m_axi_hbm_awready,
    input [31 : 0] m_axi_hbm_rdata_parity,
    input [255 : 0] m_axi_hbm_rdata,
    input [5 : 0] m_axi_hbm_rid,
    input m_axi_hbm_rlast,
    input [1 : 0] m_axi_hbm_rresp,
    input m_axi_hbm_rvalid,
    input m_axi_hbm_wready,
    input [5 : 0] m_axi_hbm_bid,

    input pcie_aclk,
    input pcie_aresetn,

);
    // 连接 pcie - hbm data convertor
    
    pcie_hbm_converter pcie_hbm_converter (
    .s_axi_aclk(s_axi_aclk),          // input wire s_axi_aclk
    .s_axi_aresetn(s_axi_aresetn),    // input wire s_axi_aresetn
    .s_axi_awaddr(s_axi_awaddr),      // input wire [63 : 0] s_axi_awaddr
    .s_axi_awlen(s_axi_awlen),        // input wire [7 : 0] s_axi_awlen
    .s_axi_awsize(s_axi_awsize),      // input wire [2 : 0] s_axi_awsize
    .s_axi_awburst(s_axi_awburst),    // input wire [1 : 0] s_axi_awburst
    .s_axi_awlock(s_axi_awlock),      // input wire [0 : 0] s_axi_awlock
    .s_axi_awcache(s_axi_awcache),    // input wire [3 : 0] s_axi_awcache
    .s_axi_awprot(s_axi_awprot),      // input wire [2 : 0] s_axi_awprot
    .s_axi_awregion(s_axi_awregion),  // input wire [3 : 0] s_axi_awregion
    .s_axi_awqos(s_axi_awqos),        // input wire [3 : 0] s_axi_awqos
    .s_axi_awvalid(s_axi_awvalid),    // input wire s_axi_awvalid
    .s_axi_awready(s_axi_awready),    // output wire s_axi_awready
    .s_axi_wdata(s_axi_wdata),        // input wire [511 : 0] s_axi_wdata
    .s_axi_wstrb(s_axi_wstrb),        // input wire [63 : 0] s_axi_wstrb
    .s_axi_wlast(s_axi_wlast),        // input wire s_axi_wlast
    .s_axi_wvalid(s_axi_wvalid),      // input wire s_axi_wvalid
    .s_axi_wready(s_axi_wready),      // output wire s_axi_wready
    .s_axi_bresp(s_axi_bresp),        // output wire [1 : 0] s_axi_bresp
    .s_axi_bvalid(s_axi_bvalid),      // output wire s_axi_bvalid
    .s_axi_bready(s_axi_bready),      // input wire s_axi_bready
    .s_axi_araddr(s_axi_araddr),      // input wire [63 : 0] s_axi_araddr
    .s_axi_arlen(s_axi_arlen),        // input wire [7 : 0] s_axi_arlen
    .s_axi_arsize(s_axi_arsize),      // input wire [2 : 0] s_axi_arsize
    .s_axi_arburst(s_axi_arburst),    // input wire [1 : 0] s_axi_arburst
    .s_axi_arlock(s_axi_arlock),      // input wire [0 : 0] s_axi_arlock
    .s_axi_arcache(s_axi_arcache),    // input wire [3 : 0] s_axi_arcache
    .s_axi_arprot(s_axi_arprot),      // input wire [2 : 0] s_axi_arprot
    .s_axi_arregion(s_axi_arregion),  // input wire [3 : 0] s_axi_arregion
    .s_axi_arqos(s_axi_arqos),        // input wire [3 : 0] s_axi_arqos
    .s_axi_arvalid(s_axi_arvalid),    // input wire s_axi_arvalid
    .s_axi_arready(s_axi_arready),    // output wire s_axi_arready
    .s_axi_rdata(s_axi_rdata),        // output wire [511 : 0] s_axi_rdata
    .s_axi_rresp(s_axi_rresp),        // output wire [1 : 0] s_axi_rresp
    .s_axi_rlast(s_axi_rlast),        // output wire s_axi_rlast
    .s_axi_rvalid(s_axi_rvalid),      // output wire s_axi_rvalid
    .s_axi_rready(s_axi_rready),      // input wire s_axi_rready

    .m_axi_awaddr(m_axi_awaddr),      // output wire [63 : 0] m_axi_awaddr
    .m_axi_awlen(m_axi_awlen),        // output wire [7 : 0] m_axi_awlen
    .m_axi_awsize(m_axi_awsize),      // output wire [2 : 0] m_axi_awsize
    .m_axi_awburst(m_axi_awburst),    // output wire [1 : 0] m_axi_awburst
    .m_axi_awlock(m_axi_awlock),      // output wire [0 : 0] m_axi_awlock
    .m_axi_awcache(m_axi_awcache),    // output wire [3 : 0] m_axi_awcache
    .m_axi_awprot(m_axi_awprot),      // output wire [2 : 0] m_axi_awprot
    .m_axi_awregion(m_axi_awregion),  // output wire [3 : 0] m_axi_awregion
    .m_axi_awqos(m_axi_awqos),        // output wire [3 : 0] m_axi_awqos
    .m_axi_awvalid(m_axi_awvalid),    // output wire m_axi_awvalid
    .m_axi_awready(m_axi_awready),    // input wire m_axi_awready
    .m_axi_wdata(m_axi_wdata),        // output wire [255 : 0] m_axi_wdata
    .m_axi_wstrb(m_axi_wstrb),        // output wire [31 : 0] m_axi_wstrb
    .m_axi_wlast(m_axi_wlast),        // output wire m_axi_wlast
    .m_axi_wvalid(m_axi_wvalid),      // output wire m_axi_wvalid
    .m_axi_wready(m_axi_wready),      // input wire m_axi_wready
    .m_axi_bresp(m_axi_bresp),        // input wire [1 : 0] m_axi_bresp
    .m_axi_bvalid(m_axi_bvalid),      // input wire m_axi_bvalid
    .m_axi_bready(m_axi_bready),      // output wire m_axi_bready
    .m_axi_araddr(m_axi_araddr),      // output wire [63 : 0] m_axi_araddr
    .m_axi_arlen(m_axi_arlen),        // output wire [7 : 0] m_axi_arlen
    .m_axi_arsize(m_axi_arsize),      // output wire [2 : 0] m_axi_arsize
    .m_axi_arburst(m_axi_arburst),    // output wire [1 : 0] m_axi_arburst
    .m_axi_arlock(m_axi_arlock),      // output wire [0 : 0] m_axi_arlock
    .m_axi_arcache(m_axi_arcache),    // output wire [3 : 0] m_axi_arcache
    .m_axi_arprot(m_axi_arprot),      // output wire [2 : 0] m_axi_arprot
    .m_axi_arregion(m_axi_arregion),  // output wire [3 : 0] m_axi_arregion
    .m_axi_arqos(m_axi_arqos),        // output wire [3 : 0] m_axi_arqos
    .m_axi_arvalid(m_axi_arvalid),    // output wire m_axi_arvalid
    .m_axi_arready(m_axi_arready),    // input wire m_axi_arready
    .m_axi_rdata(m_axi_rdata),        // input wire [255 : 0] m_axi_rdata
    .m_axi_rresp(m_axi_rresp),        // input wire [1 : 0] m_axi_rresp
    .m_axi_rlast(m_axi_rlast),        // input wire m_axi_rlast
    .m_axi_rvalid(m_axi_rvalid),      // input wire m_axi_rvalid
    .m_axi_rready(m_axi_rready)      // output wire m_axi_rready    
    );
endmodule