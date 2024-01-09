// *************************************************************************
//
// Copyright 2020 Xilinx, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// *************************************************************************


// axi_demux_r 乒乓化 √
// 挂载定时器到总线上 √
// axi yi buffer 
`include "pcie_spmv_macros.vh"
`include "system_ifc.vh"
`timescale 1ns/1ps
module pcie_spmv #(
  parameter [31:0] BUILD_TIMESTAMP = 32'h01010000,
  parameter int    MIN_PKT_LEN     = 64,
  parameter int    MAX_PKT_LEN     = 1518,
  parameter int    USE_PHYS_FUNC   = 1,
  parameter int    NUM_PHYS_FUNC   = 1,
  parameter int    NUM_QUEUE       = 512,
  parameter int    NUM_CMAC_PORT   = 1,
  parameter int CONF_NUM_KERNEL = 32'h4
) (
 `ifdef __au280__
   output                         hbm_cattrip, // Fix the CATTRIP issue for AU280 custom flow
 `elsif __au50__
   output                         hbm_cattrip,
 `elsif __au55c__
   output                         hbm_cattrip,
 `endif

  input                   [15:0] pcie_rxp,
  input                   [15:0] pcie_rxn,
  output                  [15:0] pcie_txp,
  output                  [15:0] pcie_txn,
  input                          pcie_refclk_p, // 100Mhz
  input                          pcie_refclk_n,
  input                          pcie_rstn,

  input                          hbm_diff_clk_p, // 100Mhz
  input                          hbm_diff_clk_n
  
);

  // Parameter DRC
  initial begin
    if (MIN_PKT_LEN > 256 || MIN_PKT_LEN < 64) begin
      $fatal("[%m] Minimum packet length should be within the range [64, 256]");
    end
    if (MAX_PKT_LEN > 9600 || MAX_PKT_LEN < 256) begin
      $fatal("[%m] Maximum packet length should be within the range [256, 9600]");
    end
    if (USE_PHYS_FUNC) begin
      if (NUM_QUEUE > 2048 || NUM_QUEUE < 1) begin
        $fatal("[%m] Number of queues should be within the range [1, 2048]");
      end
      if ((NUM_QUEUE & (NUM_QUEUE - 1)) != 0) begin
        $fatal("[%m] Number of queues should be 2^n");
      end
      if (NUM_PHYS_FUNC > 4 || NUM_PHYS_FUNC < 1) begin
        $fatal("[%m] Number of physical functions should be within the range [1, 4]");
      end
    end
    if (NUM_CMAC_PORT > 2 || NUM_CMAC_PORT < 1) begin
      $fatal("[%m] Number of CMACs should be within the range [1, 2]");
    end
  end

  wire         powerup_rstn;
  wire         pcie_user_lnk_up;
  wire         pcie_phy_ready;

  // BAR2-mapped master AXI-Lite feeding into system configuration block
  wire         axil_pcie_awvalid;
  wire  [31:0] axil_pcie_awaddr;
  wire         axil_pcie_awready;
  wire         axil_pcie_wvalid;
  wire  [31:0] axil_pcie_wdata;
  wire         axil_pcie_wready;
  wire         axil_pcie_bvalid;
  wire   [1:0] axil_pcie_bresp;
  wire         axil_pcie_bready;
  wire         axil_pcie_arvalid;
  wire  [31:0] axil_pcie_araddr;
  wire         axil_pcie_arready;
  wire         axil_pcie_rvalid;
  wire  [31:0] axil_pcie_rdata;
  wire   [1:0] axil_pcie_rresp;
  wire         axil_pcie_rready;


`ifdef __au55c__
  assign pcie_rstn_int = pcie_rstn;
`else
  IBUF pcie_rstn_ibuf_inst (.I(pcie_rstn), .O(pcie_rstn_int));
`endif


 `ifdef __au280__
   // Fix the CATTRIP issue for AU280 custom flow
   //
   // This pin must be tied to 0; otherwise the board might be unrecoverable
   // after programming
   OBUF hbm_cattrip_obuf_inst (.I(1'b0), .O(hbm_cattrip));
 `elsif __au50__
   // Same for AU50
   OBUF hbm_cattrip_obuf_inst (.I(1'b0), .O(hbm_cattrip));
 `elsif __au55c__
   // Same for AU50
   OBUF hbm_cattrip_obuf_inst (.I(1'b0), .O(hbm_cattrip));
 `endif

`ifdef __zynq_family__
  zynq_usplus_ps zynq_usplus_ps_inst ();
`endif

  wire                         axil_qdma_awvalid;
  wire                  [31:0] axil_qdma_awaddr;
  wire                         axil_qdma_awready;
  wire                         axil_qdma_wvalid;
  wire                  [31:0] axil_qdma_wdata;
  wire                         axil_qdma_wready;
  wire                         axil_qdma_bvalid;
  wire                   [1:0] axil_qdma_bresp;
  wire                         axil_qdma_bready;
  wire                         axil_qdma_arvalid;
  wire                  [31:0] axil_qdma_araddr;
  wire                         axil_qdma_arready;
  wire                         axil_qdma_rvalid;
  wire                  [31:0] axil_qdma_rdata;
  wire                   [1:0] axil_qdma_rresp;
  wire                         axil_qdma_rready;

  wire                         axil_box0_awvalid;
  wire                  [31:0] axil_box0_awaddr;
  wire                         axil_box0_awready;
  wire                         axil_box0_wvalid;
  wire                  [31:0] axil_box0_wdata;
  wire                         axil_box0_wready;
  wire                         axil_box0_bvalid;
  wire                   [1:0] axil_box0_bresp;
  wire                         axil_box0_bready;
  wire                         axil_box0_arvalid;
  wire                  [31:0] axil_box0_araddr;
  wire                         axil_box0_arready;
  wire                         axil_box0_rvalid;
  wire                  [31:0] axil_box0_rdata;
  wire                   [1:0] axil_box0_rresp;
  wire                         axil_box0_rready;

  
   wire axi_pcie_hbm_awready;
   wire axi_pcie_hbm_wready;
   wire [3 : 0] axi_pcie_hbm_bid;
   wire [1 : 0] axi_pcie_hbm_bresp;
   wire axi_pcie_hbm_bvalid;
   wire axi_pcie_hbm_arready;
   wire [3 : 0] axi_pcie_hbm_rid;
   wire [511 : 0] axi_pcie_hbm_rdata;
   wire [1 : 0] axi_pcie_hbm_rresp;
   wire axi_pcie_hbm_rlast;
   wire axi_pcie_hbm_rvalid;
   wire [3 : 0] axi_pcie_hbm_awid;
   wire [63 : 0] axi_pcie_hbm_awaddr;
   wire [31 : 0] axi_pcie_hbm_awuser;
   wire [7 : 0] axi_pcie_hbm_awlen;
   wire [2 : 0] axi_pcie_hbm_awsize;
   wire [1 : 0] axi_pcie_hbm_awburst;
   wire [2 : 0] axi_pcie_hbm_awprot;
   wire axi_pcie_hbm_awvalid;
   wire axi_pcie_hbm_awlock;
   wire [3 : 0] axi_pcie_hbm_awcache;
   wire [511 : 0] axi_pcie_hbm_wdata;
   wire [63 : 0] axi_pcie_hbm_wuser;
   wire [63 : 0] axi_pcie_hbm_wstrb;
   wire axi_pcie_hbm_wlast;
   wire axi_pcie_hbm_wvalid;
   wire axi_pcie_hbm_bready;
   wire [3 : 0] axi_pcie_hbm_arid;
   wire [63 : 0] axi_pcie_hbm_araddr;
   wire [31 : 0] axi_pcie_hbm_aruser;
   wire [7 : 0] axi_pcie_hbm_arlen;
   wire [2 : 0] axi_pcie_hbm_arsize;
   wire [1 : 0] axi_pcie_hbm_arburst;
   wire [2 : 0] axi_pcie_hbm_arprot;
   wire axi_pcie_hbm_arvalid;
   wire axi_pcie_hbm_arlock;
   wire [3 : 0] axi_pcie_hbm_arcache;
   wire axi_pcie_hbm_rready;

  // QDMA subsystem interfaces to the box running at 250MHz
  
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tvalid;
  
  wire [512*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tdata;
  
  wire  [64*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tkeep;
  
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tlast;
  
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tuser_size;
  
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tuser_src;
  
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tuser_dst;
  
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_h2c_tready;

  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tvalid;
  wire [512*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tdata;
  wire  [64*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tkeep;
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tlast;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tuser_size;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tuser_src;
  wire  [16*NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tuser_dst;
  wire     [NUM_PHYS_FUNC-1:0] axis_qdma_c2h_tready;

  wire                  [31:0] shell_rstn;
  wire                  [31:0] shell_rst_done;
  wire                         qdma_rstn;
  wire                         qdma_rst_done;

  wire                  [31:0] user_rstn;
  wire                  [31:0] user_rst_done;
  wire                  [15:0] user_250mhz_rstn;
  wire                  [15:0] user_250mhz_rst_done;

  wire                         box_250mhz_rstn;
  wire                         box_250mhz_rst_done;

  wire                         axil_aclk;
  wire                         axis_aclk;


  wire [32*1-1:0] axi_hbm_aclk;
  wire [32*1-1:0] axi_hbm_areset_n;
  wire [32*33-1:0] axi_hbm_araddr;
  wire [32*2-1:0] axi_hbm_arburst;
  wire [32*6-1:0] axi_hbm_arid;
  wire [32*4-1:0] axi_hbm_arlen;
  wire [32*3-1:0] axi_hbm_arsize;
  wire [32*1-1:0] axi_hbm_arvalid;
  wire [32*33-1:0] axi_hbm_awaddr;
  wire [32*2-1:0] axi_hbm_awburst;
  wire [32*6-1:0] axi_hbm_awid;
  wire [32*4-1:0] axi_hbm_awlen;
  wire [32*3-1:0] axi_hbm_awsize;
  wire [32*1-1:0] axi_hbm_awvalid;
  wire [32*1-1:0] axi_hbm_rready;
  wire [32*1-1:0] axi_hbm_bready;
  wire [32*256-1:0] axi_hbm_wdata;
  wire [32*1-1:0] axi_hbm_wlast;
  wire [32*32-1:0] axi_hbm_wstrb;
  wire [32*32-1:0] axi_hbm_wdata_parity;
  wire [32*1-1:0] axi_hbm_wvalid;
  wire [32*1-1:0] axi_hbm_arready;
  wire [32*1-1:0] axi_hbm_awready;
  wire [32*32-1:0] axi_hbm_rdata_parity;
  wire [32*256-1:0] axi_hbm_rdata;
  wire [32*6-1:0] axi_hbm_rid;
  wire [32*1-1:0] axi_hbm_rlast;
  wire [32*2-1:0] axi_hbm_rresp;
  wire [32*1-1:0] axi_hbm_rvalid;
  wire [32*1-1:0] axi_hbm_wready;
  wire [32*6-1:0] axi_hbm_bid;
  wire [32*2-1:0] axi_hbm_bresp;
  wire [32*1-1:0] axi_hbm_bvalid;


  wire [4*1-1:0] axi_bram_aclk;
  wire [4*1-1:0] axi_bram_areset_n;
  wire [4*33-1:0] axi_bram_araddr;
  wire [4*2-1:0] axi_bram_arburst;
  wire [4*6-1:0] axi_bram_arid;
  wire [4*4-1:0] axi_bram_arlen;
  wire [4*3-1:0] axi_bram_arsize;
  wire [4*1-1:0] axi_bram_arvalid;
  wire [4*33-1:0] axi_bram_awaddr;
  wire [4*2-1:0] axi_bram_awburst;
  wire [4*6-1:0] axi_bram_awid;
  wire [4*4-1:0] axi_bram_awlen;
  wire [4*3-1:0] axi_bram_awsize;
  wire [4*1-1:0] axi_bram_awvalid;
  wire [4*1-1:0] axi_bram_rready;
  wire [4*1-1:0] axi_bram_bready;
  wire [4*256-1:0] axi_bram_wdata;
  wire [4*1-1:0] axi_bram_wlast;
  wire [4*32-1:0] axi_bram_wstrb;
  wire [4*32-1:0] axi_bram_wdata_parity;
  wire [4*1-1:0] axi_bram_wvalid;
  wire [4*1-1:0] axi_bram_arready;
  wire [4*1-1:0] axi_bram_awready;
  wire [4*32-1:0] axi_bram_rdata_parity;
  wire [4*256-1:0] axi_bram_rdata;
  wire [4*6-1:0] axi_bram_rid;
  wire [4*1-1:0] axi_bram_rlast;
  wire [4*2-1:0] axi_bram_rresp;
  wire [4*1-1:0] axi_bram_rvalid;
  wire [4*1-1:0] axi_bram_wready;
  wire [4*6-1:0] axi_bram_bid;
  wire [4*2-1:0] axi_bram_bresp;
  wire [4*1-1:0] axi_bram_bvalid;




  wire [(CONF_NUM_KERNEL*4+1)*48-1 : 0] axi_box_araddr;
  wire [(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_box_arburst;
  wire [(CONF_NUM_KERNEL*4+1)*8-1 : 0] axi_box_arlen;
  wire [(CONF_NUM_KERNEL*4+1)*3-1 : 0] axi_box_arsize;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0]axi_box_arvalid;
  wire [(CONF_NUM_KERNEL*4+1)*48-1 : 0] axi_box_awaddr;
  wire [(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_box_awburst;
  wire [(CONF_NUM_KERNEL*4+1)*8-1 : 0] axi_box_awlen;
  wire [(CONF_NUM_KERNEL*4+1)*3-1 : 0] axi_box_awsize;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_awvalid;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_rready;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_bready;
  wire [(CONF_NUM_KERNEL*4+1)*256-1 : 0] axi_box_wdata;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_wlast;
  wire [(CONF_NUM_KERNEL*4+1)*32-1 : 0] axi_box_wstrb;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_wvalid;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_arready;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_awready;
  wire [(CONF_NUM_KERNEL*4+1)*256-1 : 0] axi_box_rdata;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_rlast;
  wire [(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_box_rresp;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_rvalid;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_wready;
  wire [(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_box_bresp;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_box_bvalid;


  wire [48-1 : 0] axi_hbm_width_araddr;
  wire [2-1 : 0] axi_hbm_width_arburst;
  wire [8-1 : 0] axi_hbm_width_arlen;
  wire [3-1 : 0] axi_hbm_width_arsize;
  wire [1-1 : 0]axi_hbm_width_arvalid;
  wire [48-1 : 0] axi_hbm_width_awaddr;
  wire [2-1 : 0] axi_hbm_width_awburst;
  wire [8-1 : 0] axi_hbm_width_awlen;
  wire [3-1 : 0] axi_hbm_width_awsize;
  wire [1-1 : 0] axi_hbm_width_awvalid;
  wire [1-1 : 0] axi_hbm_width_rready;
  wire [1-1 : 0] axi_hbm_width_bready;
  wire [256-1 : 0] axi_hbm_width_wdata;
  wire [1-1 : 0] axi_hbm_width_wlast;
  wire [32-1 : 0] axi_hbm_width_wstrb;
  wire [1-1 : 0] axi_hbm_width_wvalid;
  wire [1-1 : 0] axi_hbm_width_arready;
  wire [1-1 : 0] axi_hbm_width_awready;
  wire [256-1 : 0] axi_hbm_width_rdata;
  wire [1-1 : 0] axi_hbm_width_rlast;
  wire [2-1 : 0] axi_hbm_width_rresp;
  wire [1-1 : 0] axi_hbm_width_rvalid;
  wire [1-1 : 0] axi_hbm_width_wready;
  wire [2-1 : 0] axi_hbm_width_bresp;
  wire [1-1 : 0] axi_hbm_width_bvalid;


  // Unused reset pairs must have their "reset_done" tied to 1

  // First 4-bit for QDMA subsystem
  assign qdma_rstn           = shell_rstn[0];
  assign shell_rst_done[0]   = qdma_rst_done;
  assign shell_rst_done[3:1] = 3'b111;

  // For each CMAC port, use the subsequent 4-bit: bit 0 for CMAC subsystem and
  // bit 1 for the corresponding adapter
  


  // The box running at 250MHz takes 16+1 user reset pairs, with the extra one
  // used by the box itself.  Similarly, the box running at 322MHz takes 8+1
  // pairs.  The mapping is as follows.
  //
  // | 31    | 30    | 29 ... 24 | 23 ... 16 | 15 ... 0 |
  // ----------------------------------------------------
  // | b@250 | b@322 | Reserved  | user@322  | user@250 |
  assign user_250mhz_rstn     = user_rstn[15:0];
  assign user_rst_done[15:0]  = user_250mhz_rst_done;

  assign box_250mhz_rstn      = user_rstn[31];
  assign user_rst_done[31]    = box_250mhz_rst_done;
  

  // Unused pairs must have their rst_done signals tied to 1
  assign user_rst_done[29:24] = {6{1'b1}};

  system_config #(
    .BUILD_TIMESTAMP (BUILD_TIMESTAMP),
    .NUM_CMAC_PORT   (NUM_CMAC_PORT)
  ) system_config_inst (
// `ifdef __synthesis__
    .s_axil_awvalid      (axil_pcie_awvalid),
    .s_axil_awaddr       (axil_pcie_awaddr),
    .s_axil_awready      (axil_pcie_awready),
    .s_axil_wvalid       (axil_pcie_wvalid),
    .s_axil_wdata        (axil_pcie_wdata),
    .s_axil_wready       (axil_pcie_wready),
    .s_axil_bvalid       (axil_pcie_bvalid),
    .s_axil_bresp        (axil_pcie_bresp),
    .s_axil_bready       (axil_pcie_bready),
    .s_axil_arvalid      (axil_pcie_arvalid),
    .s_axil_araddr       (axil_pcie_araddr),
    .s_axil_arready      (axil_pcie_arready),
    .s_axil_rvalid       (axil_pcie_rvalid),
    .s_axil_rdata        (axil_pcie_rdata),
    .s_axil_rresp        (axil_pcie_rresp),
    .s_axil_rready       (axil_pcie_rready),

    .m_axil_qdma_awvalid (axil_qdma_awvalid),
    .m_axil_qdma_awaddr  (axil_qdma_awaddr),
    .m_axil_qdma_awready (axil_qdma_awready),
    .m_axil_qdma_wvalid  (axil_qdma_wvalid),
    .m_axil_qdma_wdata   (axil_qdma_wdata),
    .m_axil_qdma_wready  (axil_qdma_wready),
    .m_axil_qdma_bvalid  (axil_qdma_bvalid),
    .m_axil_qdma_bresp   (axil_qdma_bresp),
    .m_axil_qdma_bready  (axil_qdma_bready),
    .m_axil_qdma_arvalid (axil_qdma_arvalid),
    .m_axil_qdma_araddr  (axil_qdma_araddr),
    .m_axil_qdma_arready (axil_qdma_arready),
    .m_axil_qdma_rvalid  (axil_qdma_rvalid),
    .m_axil_qdma_rdata   (axil_qdma_rdata),
    .m_axil_qdma_rresp   (axil_qdma_rresp),
    .m_axil_qdma_rready  (axil_qdma_rready),

    .m_axil_box0_awvalid (axil_box0_awvalid),
    .m_axil_box0_awaddr  (axil_box0_awaddr),
    .m_axil_box0_awready (axil_box0_awready),
    .m_axil_box0_wvalid  (axil_box0_wvalid),
    .m_axil_box0_wdata   (axil_box0_wdata),
    .m_axil_box0_wready  (axil_box0_wready),
    .m_axil_box0_bvalid  (axil_box0_bvalid),
    .m_axil_box0_bresp   (axil_box0_bresp),
    .m_axil_box0_bready  (axil_box0_bready),
    .m_axil_box0_arvalid (axil_box0_arvalid),
    .m_axil_box0_araddr  (axil_box0_araddr),
    .m_axil_box0_arready (axil_box0_arready),
    .m_axil_box0_rvalid  (axil_box0_rvalid),
    .m_axil_box0_rdata   (axil_box0_rdata),
    .m_axil_box0_rresp   (axil_box0_rresp),
    .m_axil_box0_rready  (axil_box0_rready),

    .shell_rstn          (shell_rstn),
    .shell_rst_done      (shell_rst_done),
    .user_rstn           (user_rstn),
    .user_rst_done       (user_rst_done),

    .aclk                (axil_aclk),
    .aresetn             (powerup_rstn)
  );

  qdma_subsystem #(
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .NUM_QUEUE     (NUM_QUEUE)
  ) qdma_subsystem_inst (
    .s_axil_awvalid                       (axil_qdma_awvalid),
    .s_axil_awaddr                        (axil_qdma_awaddr),
    .s_axil_awready                       (axil_qdma_awready),
    .s_axil_wvalid                        (axil_qdma_wvalid),
    .s_axil_wdata                         (axil_qdma_wdata),
    .s_axil_wready                        (axil_qdma_wready),
    .s_axil_bvalid                        (axil_qdma_bvalid),
    .s_axil_bresp                         (axil_qdma_bresp),
    .s_axil_bready                        (axil_qdma_bready),
    .s_axil_arvalid                       (axil_qdma_arvalid),
    .s_axil_araddr                        (axil_qdma_araddr),
    .s_axil_arready                       (axil_qdma_arready),
    .s_axil_rvalid                        (axil_qdma_rvalid),
    .s_axil_rdata                         (axil_qdma_rdata),
    .s_axil_rresp                         (axil_qdma_rresp),
    .s_axil_rready                        (axil_qdma_rready),


    .m_axi_awready(axi_pcie_hbm_awready),                                                // input wire m_axi_awready
    .m_axi_wready(axi_pcie_hbm_wready),                                                  // input wire m_axi_wready
    .m_axi_bid(axi_pcie_hbm_bid),                                                        // input wire [3 : 0] m_axi_bid
    .m_axi_bresp(axi_pcie_hbm_bresp),                                                    // input wire [1 : 0] m_axi_bresp
    .m_axi_bvalid(axi_pcie_hbm_bvalid),                                                  // input wire m_axi_bvalid
    .m_axi_arready(axi_pcie_hbm_arready),                                                // input wire m_axi_arready
    .m_axi_rid(axi_pcie_hbm_rid),                                                        // input wire [3 : 0] m_axi_rid
    .m_axi_rdata(axi_pcie_hbm_rdata),                                                    // input wire [511 : 0] m_axi_rdata
    .m_axi_rresp(axi_pcie_hbm_rresp),                                                    // input wire [1 : 0] m_axi_rresp
    .m_axi_rlast(axi_pcie_hbm_rlast),                                                    // input wire m_axi_rlast
    .m_axi_rvalid(axi_pcie_hbm_rvalid),                                                  // input wire m_axi_rvalid
    .m_axi_awid(axi_pcie_hbm_awid),                                                      // output wire [3 : 0] m_axi_awid
    .m_axi_awaddr(axi_pcie_hbm_awaddr),                                                  // output wire [63 : 0] m_axi_awaddr
    .m_axi_awuser(axi_pcie_hbm_awuser),                                                  // output wire [31 : 0] m_axi_awuser
    .m_axi_awlen(axi_pcie_hbm_awlen),                                                    // output wire [7 : 0] m_axi_awlen
    .m_axi_awsize(axi_pcie_hbm_awsize),                                                  // output wire [2 : 0] m_axi_awsize
    .m_axi_awburst(axi_pcie_hbm_awburst),                                                // output wire [1 : 0] m_axi_awburst
    .m_axi_awprot(axi_pcie_hbm_awprot),                                                  // output wire [2 : 0] m_axi_awprot
    .m_axi_awvalid(axi_pcie_hbm_awvalid),                                                // output wire m_axi_awvalid
    .m_axi_awlock(axi_pcie_hbm_awlock),                                                  // output wire m_axi_awlock
    .m_axi_awcache(axi_pcie_hbm_awcache),                                                // output wire [3 : 0] m_axi_awcache
    .m_axi_wdata(axi_pcie_hbm_wdata),                                                    // output wire [511 : 0] m_axi_wdata
    .m_axi_wuser(axi_pcie_hbm_wuser),                                                    // output wire [63 : 0] m_axi_wuser
    .m_axi_wstrb(axi_pcie_hbm_wstrb),                                                    // output wire [63 : 0] m_axi_wstrb
    .m_axi_wlast(axi_pcie_hbm_wlast),                                                    // output wire m_axi_wlast
    .m_axi_wvalid(axi_pcie_hbm_wvalid),                                                  // output wire m_axi_wvalid
    .m_axi_bready(axi_pcie_hbm_bready),                                                  // output wire m_axi_bready
    .m_axi_arid(axi_pcie_hbm_arid),                                                      // output wire [3 : 0] m_axi_arid
    .m_axi_araddr(axi_pcie_hbm_araddr),                                                  // output wire [63 : 0] m_axi_araddr
    .m_axi_aruser(axi_pcie_hbm_aruser),                                                  // output wire [31 : 0] m_axi_aruser
    .m_axi_arlen(axi_pcie_hbm_arlen),                                                    // output wire [7 : 0] m_axi_arlen
    .m_axi_arsize(axi_pcie_hbm_arsize),                                                  // output wire [2 : 0] m_axi_arsize
    .m_axi_arburst(axi_pcie_hbm_arburst),                                                // output wire [1 : 0] m_axi_arburst
    .m_axi_arprot(axi_pcie_hbm_arprot),                                                  // output wire [2 : 0] m_axi_arprot
    .m_axi_arvalid(axi_pcie_hbm_arvalid),                                                // output wire m_axi_arvalid
    .m_axi_arlock(axi_pcie_hbm_arlock),                                                  // output wire m_axi_arlock
    .m_axi_arcache(axi_pcie_hbm_arcache),                                                // output wire [3 : 0] m_axi_arcache
    .m_axi_rready(axi_pcie_hbm_rready),                                                  // output wire m_axi_rready


    .m_axis_h2c_tvalid                    (axis_qdma_h2c_tvalid),
    .m_axis_h2c_tdata                     (axis_qdma_h2c_tdata),
    .m_axis_h2c_tkeep                     (axis_qdma_h2c_tkeep),
    .m_axis_h2c_tlast                     (axis_qdma_h2c_tlast),
    .m_axis_h2c_tuser_size                (axis_qdma_h2c_tuser_size),
    .m_axis_h2c_tuser_src                 (axis_qdma_h2c_tuser_src),
    .m_axis_h2c_tuser_dst                 (axis_qdma_h2c_tuser_dst),
    .m_axis_h2c_tready                    (axis_qdma_h2c_tready),

    .s_axis_c2h_tvalid                    (axis_qdma_c2h_tvalid),
    .s_axis_c2h_tdata                     (axis_qdma_c2h_tdata),
    .s_axis_c2h_tkeep                     (axis_qdma_c2h_tkeep),
    .s_axis_c2h_tlast                     (axis_qdma_c2h_tlast),
    .s_axis_c2h_tuser_size                (axis_qdma_c2h_tuser_size),
    .s_axis_c2h_tuser_src                 (axis_qdma_c2h_tuser_src),
    .s_axis_c2h_tuser_dst                 (axis_qdma_c2h_tuser_dst),
    .s_axis_c2h_tready                    (axis_qdma_c2h_tready),

// `ifdef __synthesis__
    .pcie_rxp                             (pcie_rxp),
    .pcie_rxn                             (pcie_rxn),
    .pcie_txp                             (pcie_txp),
    .pcie_txn                             (pcie_txn),

    .m_axil_pcie_awvalid                  (axil_pcie_awvalid),
    .m_axil_pcie_awaddr                   (axil_pcie_awaddr),
    .m_axil_pcie_awready                  (axil_pcie_awready),
    .m_axil_pcie_wvalid                   (axil_pcie_wvalid),
    .m_axil_pcie_wdata                    (axil_pcie_wdata),
    .m_axil_pcie_wready                   (axil_pcie_wready),
    .m_axil_pcie_bvalid                   (axil_pcie_bvalid),
    .m_axil_pcie_bresp                    (axil_pcie_bresp),
    .m_axil_pcie_bready                   (axil_pcie_bready),
    .m_axil_pcie_arvalid                  (axil_pcie_arvalid),
    .m_axil_pcie_araddr                   (axil_pcie_araddr),
    .m_axil_pcie_arready                  (axil_pcie_arready),
    .m_axil_pcie_rvalid                   (axil_pcie_rvalid),
    .m_axil_pcie_rdata                    (axil_pcie_rdata),
    .m_axil_pcie_rresp                    (axil_pcie_rresp),
    .m_axil_pcie_rready                   (axil_pcie_rready),

    .pcie_refclk_p                        (pcie_refclk_p),
    .pcie_refclk_n                        (pcie_refclk_n),
    .pcie_rstn                            (pcie_rstn_int),
    .user_lnk_up                          (pcie_user_lnk_up),
    .phy_ready                            (pcie_phy_ready),
    .powerup_rstn                         (powerup_rstn),


    .mod_rstn                             (qdma_rstn),
    .mod_rst_done                         (qdma_rst_done),

    .axil_aclk                            (axil_aclk),
    .axis_aclk                            (axis_aclk)
  );

  wire [1*48-1 : 0] axi_Xi_araddr;
  wire [1*2-1 : 0] axi_Xi_arburst;
  wire [1*8-1 : 0] axi_Xi_arlen;
  wire [1*3-1 : 0] axi_Xi_arsize;
  wire [1*1-1 : 0]axi_Xi_arvalid;
  wire [1*48-1 : 0] axi_Xi_awaddr;
  wire [1*2-1 : 0] axi_Xi_awburst;
  wire [1*8-1 : 0] axi_Xi_awlen;
  wire [1*3-1 : 0] axi_Xi_awsize;
  wire [1*1-1 : 0] axi_Xi_awvalid;
  wire [1*1-1 : 0] axi_Xi_rready;
  wire [1*1-1 : 0] axi_Xi_bready;
  wire [1*64-1 : 0] axi_Xi_wdata;
  wire [1*1-1 : 0] axi_Xi_wlast;
  wire [1*8-1 : 0] axi_Xi_wstrb;
  wire [1*1-1 : 0] axi_Xi_wvalid;
  wire [1*1-1 : 0] axi_Xi_arready;
  wire [1*1-1 : 0] axi_Xi_awready;
  wire [1*64-1 : 0] axi_Xi_rdata;
  wire [1*1-1 : 0] axi_Xi_rlast;
  wire [1*2-1 : 0] axi_Xi_rresp;
  wire [1*1-1 : 0] axi_Xi_rvalid;
  wire [1*1-1 : 0] axi_Xi_wready;
  wire [1*2-1 : 0] axi_Xi_bresp;
  wire [1*1-1 : 0] axi_Xi_bvalid;

  spmv_vector_loader spmv_vector_loader(
    
    .s_axi_pcie_awready(axi_pcie_hbm_awready),
    .s_axi_pcie_wready(axi_pcie_hbm_wready),                                                  // input wire s_axi_pcie_wready
    .s_axi_pcie_bid(axi_pcie_hbm_bid),                                                        // input wire [3 : 0] s_axi_pcie_bid
    .s_axi_pcie_bresp(axi_pcie_hbm_bresp),                                                    // input wire [1 : 0] s_axi_pcie_bresp
    .s_axi_pcie_bvalid(axi_pcie_hbm_bvalid),                                                  // input wire s_axi_pcie_bvalid
    .s_axi_pcie_arready(axi_pcie_hbm_arready),                                                // input wire s_axi_pcie_arready
    .s_axi_pcie_rid(axi_pcie_hbm_rid),                                                        // input wire [3 : 0] s_axi_pcie_rid
    .s_axi_pcie_rdata(axi_pcie_hbm_rdata),                                                    // input wire [511 : 0] s_axi_pcie_rdata
    .s_axi_pcie_rresp(axi_pcie_hbm_rresp),                                                    // input wire [1 : 0] s_axi_pcie_rresp
    .s_axi_pcie_rlast(axi_pcie_hbm_rlast),                                                    // input wire s_axi_pcie_rlast
    .s_axi_pcie_rvalid(axi_pcie_hbm_rvalid),                                                  // input wire s_axi_pcie_rvalid
    .s_axi_pcie_awid(axi_pcie_hbm_awid),                                                      // output wire [3 : 0] s_axi_pcie_awid
    .s_axi_pcie_awaddr(axi_pcie_hbm_awaddr),                                                  // output wire [63 : 0] s_axi_pcie_awaddr
    .s_axi_pcie_awuser(axi_pcie_hbm_awuser),                                                  // output wire [31 : 0] s_axi_pcie_awuser
    .s_axi_pcie_awlen(axi_pcie_hbm_awlen),                                                    // output wire [7 : 0] s_axi_pcie_awlen
    .s_axi_pcie_awsize(axi_pcie_hbm_awsize),                                                  // output wire [2 : 0] s_axi_pcie_awsize
    .s_axi_pcie_awburst(axi_pcie_hbm_awburst),                                                // output wire [1 : 0] s_axi_pcie_awburst
    .s_axi_pcie_awprot(axi_pcie_hbm_awprot),                                                  // output wire [2 : 0] s_axi_pcie_awprot
    .s_axi_pcie_awvalid(axi_pcie_hbm_awvalid),                                                // output wire s_axi_pcie_awvalid
    .s_axi_pcie_awlock(axi_pcie_hbm_awlock),                                                  // output wire s_axi_pcie_awlock
    .s_axi_pcie_awcache(axi_pcie_hbm_awcache),                                                // output wire [3 : 0] s_axi_pcie_awcache
    .s_axi_pcie_wdata(axi_pcie_hbm_wdata),                                                    // output wire [511 : 0] s_axi_pcie_wdata
    .s_axi_pcie_wuser(axi_pcie_hbm_wuser),                                                    // output wire [63 : 0] s_axi_pcie_wuser
    .s_axi_pcie_wstrb(axi_pcie_hbm_wstrb),                                                    // output wire [63 : 0] s_axi_pcie_wstrb
    .s_axi_pcie_wlast(axi_pcie_hbm_wlast),                                                    // output wire s_axi_pcie_wlast
    .s_axi_pcie_wvalid(axi_pcie_hbm_wvalid),                                                  // output wire s_axi_pcie_wvalid
    .s_axi_pcie_bready(axi_pcie_hbm_bready),                                                  // output wire s_axi_pcie_bready
    .s_axi_pcie_arid(axi_pcie_hbm_arid),                                                      // output wire [3 : 0] s_axi_pcie_arid
    .s_axi_pcie_araddr(axi_pcie_hbm_araddr),                                                  // output wire [63 : 0] s_axi_pcie_araddr
    .s_axi_pcie_aruser(axi_pcie_hbm_aruser),                                                  // output wire [31 : 0] s_axi_pcie_aruser
    .s_axi_pcie_arlen(axi_pcie_hbm_arlen),                                                    // output wire [7 : 0] s_axi_pcie_arlen
    .s_axi_pcie_arsize(axi_pcie_hbm_arsize),                                                  // output wire [2 : 0] s_axi_pcie_arsize
    .s_axi_pcie_arburst(axi_pcie_hbm_arburst),                                                // output wire [1 : 0] s_axi_pcie_arburst
    .s_axi_pcie_arprot(axi_pcie_hbm_arprot),                                                  // output wire [2 : 0] s_axi_pcie_arprot
    .s_axi_pcie_arvalid(axi_pcie_hbm_arvalid),                                                // output wire s_axi_pcie_arvalid
    .s_axi_pcie_arlock(axi_pcie_hbm_arlock),                                                  // output wire s_axi_pcie_arlock
    .s_axi_pcie_arcache(axi_pcie_hbm_arcache),                                                // output wire [3 : 0] s_axi_pcie_arcache
    .s_axi_pcie_rready(axi_pcie_hbm_rready),                                                  // output wire s_axi_pcie_rready
    .s_axi_pcie_awregion(0),
    .s_axi_pcie_arregion(0),
    .s_axi_pcie_awqos(0),
    .s_axi_pcie_arqos(0),
    
    .m_axi_hbm_araddr(axi_hbm_width_araddr),
    .m_axi_hbm_arburst(axi_hbm_width_arburst),
    .m_axi_hbm_arlen(axi_hbm_width_arlen),
    .m_axi_hbm_arsize(axi_hbm_width_arsize),
    .m_axi_hbm_arvalid(axi_hbm_width_arvalid),
    .m_axi_hbm_awaddr(axi_hbm_width_awaddr),
    .m_axi_hbm_awburst(axi_hbm_width_awburst),
    .m_axi_hbm_awlen(axi_hbm_width_awlen),
    .m_axi_hbm_awsize(axi_hbm_width_awsize),
    .m_axi_hbm_awvalid(axi_hbm_width_awvalid),
    .m_axi_hbm_rready(axi_hbm_width_rready),
    .m_axi_hbm_bready(axi_hbm_width_bready),
    .m_axi_hbm_wdata(axi_hbm_width_wdata),
    .m_axi_hbm_wlast(axi_hbm_width_wlast),
    .m_axi_hbm_wstrb(axi_hbm_width_wstrb),
    .m_axi_hbm_wvalid(axi_hbm_width_wvalid),
    .m_axi_hbm_arready(axi_hbm_width_arready),
    .m_axi_hbm_awready(axi_hbm_width_awready),
    .m_axi_hbm_rdata(axi_hbm_width_rdata),
    .m_axi_hbm_rlast(axi_hbm_width_rlast),
    .m_axi_hbm_rresp(axi_hbm_width_rresp),
    .m_axi_hbm_rvalid(axi_hbm_width_rvalid),
    .m_axi_hbm_wready(axi_hbm_width_wready),
    .m_axi_hbm_bvalid(axi_hbm_width_bvalid),
    .m_axi_hbm_bresp(axi_hbm_width_bresp),


    .m_axi_bram_araddr(axi_Xi_araddr),
    .m_axi_bram_arburst(axi_Xi_arburst),
    .m_axi_bram_arlen(axi_Xi_arlen),
    .m_axi_bram_arsize(axi_Xi_arsize),
    .m_axi_bram_arvalid(axi_Xi_arvalid),
    .m_axi_bram_awaddr(axi_Xi_awaddr),
    .m_axi_bram_awburst(axi_Xi_awburst),
    .m_axi_bram_awlen(axi_Xi_awlen),
    .m_axi_bram_awsize(axi_Xi_awsize),
    .m_axi_bram_awvalid(axi_Xi_awvalid),
    .m_axi_bram_rready(axi_Xi_rready),
    .m_axi_bram_bready(axi_Xi_bready),
    .m_axi_bram_wdata(axi_Xi_wdata),
    .m_axi_bram_wlast(axi_Xi_wlast),
    .m_axi_bram_wstrb(axi_Xi_wstrb),
    .m_axi_bram_wvalid(axi_Xi_wvalid),
    .m_axi_bram_arready(axi_Xi_arready),
    .m_axi_bram_awready(axi_Xi_awready),
    .m_axi_bram_rdata(axi_Xi_rdata),
    .m_axi_bram_rlast(axi_Xi_rlast),
    .m_axi_bram_rresp(axi_Xi_rresp),
    .m_axi_bram_rvalid(axi_Xi_rvalid),
    .m_axi_bram_wready(axi_Xi_wready),
    .m_axi_bram_bvalid(axi_Xi_bvalid),
    .m_axi_bram_bresp(axi_Xi_bresp),

    .pcie_aclk(axis_aclk),
    .pcie_aresetn(box_250mhz_rstn)
  );

  generate for (genvar i = 0; i < 32; i++) 
    if (i == 31)begin // assign pcie rw
      
      assign axi_hbm_araddr[`getvec(33,i)] = axi_hbm_width_araddr;
      assign axi_hbm_arburst[`getvec(2,i)] = axi_hbm_width_arburst;
      assign axi_hbm_arlen[`getvec(4,i)] = axi_hbm_width_arlen;
      assign axi_hbm_arsize[`getvec(3,i)] = axi_hbm_width_arsize;
      assign axi_hbm_arvalid[`getvec(1,i)] = axi_hbm_width_arvalid;
      assign axi_hbm_awaddr[`getvec(33,i)] = axi_hbm_width_awaddr;
      assign axi_hbm_awburst[`getvec(2,i)] = axi_hbm_width_awburst;
      assign axi_hbm_awlen[`getvec(4,i)] = axi_hbm_width_awlen;
      assign axi_hbm_awsize[`getvec(3,i)] = axi_hbm_width_awsize;
      assign axi_hbm_awvalid[`getvec(1,i)] = axi_hbm_width_awvalid;
      assign axi_hbm_rready[`getvec(1,i)] = axi_hbm_width_rready;
      assign axi_hbm_bready[`getvec(1,i)] = axi_hbm_width_bready;
      assign axi_hbm_wdata[`getvec(256,i)] = axi_hbm_width_wdata;
      assign axi_hbm_wlast[`getvec(1,i)] = axi_hbm_width_wlast;
      assign axi_hbm_wstrb[`getvec(32,i)] = axi_hbm_width_wstrb;
      assign axi_hbm_wvalid[`getvec(1,i)] = axi_hbm_width_wvalid;
      assign axi_hbm_arready[`getvec(1,i)] = axi_hbm_width_arready;
      assign axi_hbm_awready[`getvec(1,i)] = axi_hbm_width_awready;
      assign axi_hbm_rdata[`getvec(256,i)] = axi_hbm_width_rdata;
      assign axi_hbm_rlast[`getvec(1,i)] = axi_hbm_width_rlast;
      assign axi_hbm_rresp[`getvec(2,i)] = axi_hbm_width_rresp;
      assign axi_hbm_rvalid[`getvec(1,i)] = axi_hbm_width_rvalid;
      assign axi_hbm_wready[`getvec(1,i)] = axi_hbm_width_wready;
      assign axi_hbm_bresp[`getvec(2,i)] = axi_hbm_width_bresp;
      assign axi_hbm_bvalid[`getvec(1,i)] = axi_hbm_width_bvalid;


    end
    // else if(i<4)begin

    //   assign axi_bram_araddr[`getvec(33,i)] = axi_box_araddr[`getvec(48,i)];
    //   assign axi_bram_arburst[`getvec(2,i)] = axi_box_arburst[`getvec(2,i)];
    //   assign axi_bram_arlen[`getvec(4,i)] = axi_box_arlen[`getvec(8,i)];
    //   assign axi_bram_arsize[`getvec(3,i)] = axi_box_arsize[`getvec(3,i)];
    //   assign axi_bram_arvalid[`getvec(1,i)] = axi_box_arvalid[`getvec(1,i)];
    //   assign axi_bram_awaddr[`getvec(33,i)] = axi_box_awaddr[`getvec(48,i)];
    //   assign axi_bram_awburst[`getvec(2,i)] = axi_box_awburst[`getvec(2,i)];
    //   assign axi_bram_awlen[`getvec(4,i)] = axi_box_awlen[`getvec(8,i)];
    //   assign axi_bram_awsize[`getvec(3,i)] = axi_box_awsize[`getvec(3,i)];
    //   assign axi_bram_awvalid[`getvec(1,i)] = axi_box_awvalid[`getvec(1,i)];
    //   assign axi_bram_rready[`getvec(1,i)] = axi_box_rready[`getvec(1,i)];
    //   assign axi_bram_bready[`getvec(1,i)] = axi_box_bready[`getvec(1,i)];
    //   assign axi_bram_wdata[`getvec(256,i)] = axi_box_wdata[`getvec(256,i)];
    //   assign axi_bram_wlast[`getvec(1,i)] = axi_box_wlast[`getvec(1,i)];
    //   assign axi_bram_wstrb[`getvec(32,i)] = axi_box_wstrb[`getvec(32,i)];
    //   assign axi_bram_wvalid[`getvec(1,i)] = axi_box_wvalid[`getvec(1,i)];
    //   assign axi_bram_arready[`getvec(1,i)] = axi_box_arready[`getvec(1,i)];
    //   assign axi_bram_awready[`getvec(1,i)] = axi_box_awready[`getvec(1,i)];
    //   assign axi_bram_rdata[`getvec(256,i)] = axi_box_rdata[`getvec(256,i)];
    //   assign axi_bram_rlast[`getvec(1,i)] = axi_box_rlast[`getvec(1,i)];
    //   assign axi_bram_rresp[`getvec(2,i)] = axi_box_rresp[`getvec(2,i)];
    //   assign axi_bram_rvalid[`getvec(1,i)] = axi_box_rvalid[`getvec(1,i)];
    //   assign axi_bram_wready[`getvec(1,i)] = axi_box_wready[`getvec(1,i)];
    //   assign axi_bram_bresp[`getvec(2,i)] = axi_box_bresp[`getvec(2,i)];
    //   assign axi_bram_bvalid[`getvec(1,i)] = axi_box_bvalid[`getvec(1,i)];

    //   assign axi_bram_arid[`getvec(6,i)] = 0;
    //   assign axi_bram_awid[`getvec(6,i)] = 0;
    //   assign axi_bram_wdata_parity[`getvec(32,i)] = 0;
      
    // end
    else if(i<CONF_NUM_KERNEL + 1)begin //assign Xi Kernel

      assign axi_hbm_araddr[`getvec(33,i)] = axi_box_araddr[`getvec(48,i)];
      assign axi_hbm_arburst[`getvec(2,i)] = axi_box_arburst[`getvec(2,i)];
      assign axi_hbm_arlen[`getvec(4,i)] = axi_box_arlen[`getvec(8,i)];
      assign axi_hbm_arsize[`getvec(3,i)] = axi_box_arsize[`getvec(3,i)];
      assign axi_hbm_arvalid[`getvec(1,i)] = axi_box_arvalid[`getvec(1,i)];
      assign axi_hbm_awaddr[`getvec(33,i)] = axi_box_awaddr[`getvec(48,i)];
      assign axi_hbm_awburst[`getvec(2,i)] = axi_box_awburst[`getvec(2,i)];
      assign axi_hbm_awlen[`getvec(4,i)] = axi_box_awlen[`getvec(8,i)];
      assign axi_hbm_awsize[`getvec(3,i)] = axi_box_awsize[`getvec(3,i)];
      assign axi_hbm_awvalid[`getvec(1,i)] = axi_box_awvalid[`getvec(1,i)];
      assign axi_hbm_rready[`getvec(1,i)] = axi_box_rready[`getvec(1,i)];
      assign axi_hbm_bready[`getvec(1,i)] = axi_box_bready[`getvec(1,i)];
      assign axi_hbm_wdata[`getvec(256,i)] = axi_box_wdata[`getvec(256,i)];
      assign axi_hbm_wlast[`getvec(1,i)] = axi_box_wlast[`getvec(1,i)];
      assign axi_hbm_wstrb[`getvec(32,i)] = axi_box_wstrb[`getvec(32,i)];
      assign axi_hbm_wvalid[`getvec(1,i)] = axi_box_wvalid[`getvec(1,i)];
      assign axi_hbm_arready[`getvec(1,i)] = axi_box_arready[`getvec(1,i)];
      assign axi_hbm_awready[`getvec(1,i)] = axi_box_awready[`getvec(1,i)];
      assign axi_hbm_rdata[`getvec(256,i)] = axi_box_rdata[`getvec(256,i)];
      assign axi_hbm_rlast[`getvec(1,i)] = axi_box_rlast[`getvec(1,i)];
      assign axi_hbm_rresp[`getvec(2,i)] = axi_box_rresp[`getvec(2,i)];
      assign axi_hbm_rvalid[`getvec(1,i)] = axi_box_rvalid[`getvec(1,i)];
      assign axi_hbm_wready[`getvec(1,i)] = axi_box_wready[`getvec(1,i)];
      assign axi_hbm_bresp[`getvec(2,i)] = axi_box_bresp[`getvec(2,i)];
      assign axi_hbm_bvalid[`getvec(1,i)] = axi_box_bvalid[`getvec(1,i)];

      assign axi_hbm_arid[`getvec(6,i)] = 0;
      assign axi_hbm_awid[`getvec(6,i)] = 0;
      assign axi_hbm_wdata_parity[`getvec(32,i)] = 0;

    end
    

  endgenerate

  generate for (genvar j = 0; j < 32; j++) begin
        assign axi_hbm_areset_n[`getvec(1,j)] = box_250mhz_rstn;
        assign axi_hbm_aclk[`getvec(1,j)] = axis_aclk;
    end
  endgenerate

  // generate for (genvar i = 0; i < 4; i++) begin
  //   sim_blk_ram sim_blk_ram (
  //           .s_aclk(axis_aclk),                // input wire s_aclk
  //           .s_aresetn(box_250mhz_rstn),          // input wire s_aresetn

  //           .s_axi_arid(0),
  //           .s_axi_araddr(axi_bram_araddr[i*33 +: 33]),
  //           .s_axi_arburst(axi_bram_arburst[i*2 +: 2]),
  //           .s_axi_arlen(axi_bram_arlen[i*4 +: 4]),
  //           .s_axi_arsize(axi_bram_arsize[i*3 +: 3]),
  //           .s_axi_arvalid(axi_bram_arvalid[i*1 +: 1]),
  //           .s_axi_awaddr(axi_bram_awaddr[i*33 +: 33]),
  //           .s_axi_awburst(axi_bram_awburst[i*2 +: 2]),
  //           .s_axi_awlen(axi_bram_awlen[i*4 +: 4]),
  //           .s_axi_awsize(axi_bram_awsize[i*3 +: 3]),
  //           .s_axi_awvalid(axi_bram_awvalid[i*1 +: 1]),
  //           .s_axi_rready(axi_bram_rready[i*1 +: 1]),
  //           .s_axi_bready(axi_bram_bready[i*1 +: 1]),
  //           .s_axi_wdata(axi_bram_wdata[i*256 +: 256]),
  //           .s_axi_wlast(axi_bram_wlast[i*1 +: 1]),
  //           .s_axi_wstrb(axi_bram_wstrb[i*32 +: 32]),
  //           .s_axi_wvalid(axi_bram_wvalid[i*1 +: 1]),
  //           .s_axi_arready(axi_bram_arready[i*1 +: 1]),
  //           .s_axi_awready(axi_bram_awready[i*1 +: 1]),
  //           .s_axi_rdata(axi_bram_rdata[i*256 +: 256]),
  //           .s_axi_rlast(axi_bram_rlast[i*1 +: 1]),
  //           .s_axi_rresp(axi_bram_rresp[i*2 +: 2]),
  //           .s_axi_rvalid(axi_bram_rvalid[i*1 +: 1]),
  //           .s_axi_wready(axi_bram_wready[i*1 +: 1]),
  //           .s_axi_bresp(axi_bram_bresp[i*2 +: 2]),
  //           .s_axi_bvalid(axi_bram_bvalid[i*1 +: 1])
  //           );
  // end
  // endgenerate

  hbm_ctrl hbm_ctrl(
    
    .AXI_ACLK(axi_hbm_aclk),
    .AXI_ARESET_N(axi_hbm_areset_n),
    .AXI_ARADDR(axi_hbm_araddr),
    .AXI_ARBURST(axi_hbm_arburst),
    .AXI_ARID(axi_hbm_arid),
    .AXI_ARLEN(axi_hbm_arlen),
    .AXI_ARSIZE(axi_hbm_arsize),
    .AXI_ARVALID(axi_hbm_arvalid),
    .AXI_AWADDR(axi_hbm_awaddr),
    .AXI_AWBURST(axi_hbm_awburst),
    .AXI_AWID(axi_hbm_awid),
    .AXI_AWLEN(axi_hbm_awlen),
    .AXI_AWSIZE(axi_hbm_awsize),
    .AXI_AWVALID(axi_hbm_awvalid),
    .AXI_RREADY(axi_hbm_rready),
    .AXI_BREADY(axi_hbm_bready),
    .AXI_WDATA(axi_hbm_wdata),
    .AXI_WLAST(axi_hbm_wlast),
    .AXI_WSTRB(axi_hbm_wstrb),
    .AXI_WDATA_PARITY(axi_hbm_wdata_parity),
    .AXI_WVALID(axi_hbm_wvalid),
    .AXI_ARREADY(axi_hbm_arready),
    .AXI_AWREADY(axi_hbm_awready),
    .AXI_RDATA_PARITY(axi_hbm_rdata_parity),
    .AXI_RDATA(axi_hbm_rdata),
    .AXI_RID(axi_hbm_rid),
    .AXI_RLAST(axi_hbm_rlast),
    .AXI_RRESP(axi_hbm_rresp),
    .AXI_RVALID(axi_hbm_rvalid),
    .AXI_WREADY(axi_hbm_wready),
    .AXI_BID(axi_hbm_bid),
    .AXI_BRESP(axi_hbm_bresp),
    .AXI_BVALID(axi_hbm_bvalid),

    .hbm_diff_clk_p(hbm_diff_clk_p),
    .hbm_diff_clk_n(hbm_diff_clk_n)
    // .axi_hbm_clk(axis_aclk)
  );

  box_250mhz #(
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .NUM_CMAC_PORT (NUM_CMAC_PORT),
    .CONF_NUM_KERNEL(CONF_NUM_KERNEL)
  ) box_250mhz_inst (
    .s_axil_awvalid                   (axil_box0_awvalid),
    .s_axil_awaddr                    (axil_box0_awaddr),
    .s_axil_awready                   (axil_box0_awready),
    .s_axil_wvalid                    (axil_box0_wvalid),
    .s_axil_wdata                     (axil_box0_wdata),
    .s_axil_wready                    (axil_box0_wready),
    .s_axil_bvalid                    (axil_box0_bvalid),
    .s_axil_bresp                     (axil_box0_bresp),
    .s_axil_bready                    (axil_box0_bready),
    .s_axil_arvalid                   (axil_box0_arvalid),
    .s_axil_araddr                    (axil_box0_araddr),
    .s_axil_arready                   (axil_box0_arready),
    .s_axil_rvalid                    (axil_box0_rvalid),
    .s_axil_rdata                     (axil_box0_rdata),
    .s_axil_rresp                     (axil_box0_rresp),
    .s_axil_rready                    (axil_box0_rready),


    .m_axi_ker_araddr(axi_box_araddr),
    .m_axi_ker_arburst(axi_box_arburst),
    .m_axi_ker_arlen(axi_box_arlen),
    .m_axi_ker_arsize(axi_box_arsize),
    .m_axi_ker_arvalid(axi_box_arvalid),
    .m_axi_ker_awaddr(axi_box_awaddr),
    .m_axi_ker_awburst(axi_box_awburst),
    .m_axi_ker_awlen(axi_box_awlen),
    .m_axi_ker_awsize(axi_box_awsize),
    .m_axi_ker_awvalid(axi_box_awvalid),
    .m_axi_ker_rready(axi_box_rready),
    .m_axi_ker_bready(axi_box_bready),
    .m_axi_ker_wdata(axi_box_wdata),
    .m_axi_ker_wlast(axi_box_wlast),
    .m_axi_ker_wstrb(axi_box_wstrb),
    .m_axi_ker_wvalid(axi_box_wvalid),
    .m_axi_ker_arready(axi_box_arready),
    .m_axi_ker_awready(axi_box_awready),
    .m_axi_ker_rdata(axi_box_rdata),
    .m_axi_ker_rlast(axi_box_rlast),
    .m_axi_ker_rresp(axi_box_rresp),
    .m_axi_ker_rvalid(axi_box_rvalid),
    .m_axi_ker_wready(axi_box_wready),
    .m_axi_ker_bresp(axi_box_bresp),
    .m_axi_ker_bvalid(axi_box_bvalid),

    .s_axi_Xi_awaddr(axi_Xi_awaddr& 48'h000F_FFFF_FFFF),      // input wire [47 : 0] s_axi_awaddr
    .s_axi_Xi_awlen(axi_Xi_awlen),        // input wire [7 : 0] s_axi_awlen
    .s_axi_Xi_awsize(axi_Xi_awsize),      // input wire [2 : 0] s_axi_awsize
    .s_axi_Xi_awburst(axi_Xi_awburst),    // input wire [1 : 0] s_axi_awburst
    .s_axi_Xi_awvalid(axi_Xi_awvalid),    // input wire [0 : 0] s_axi_awvalid
    .s_axi_Xi_awready(axi_Xi_awready),    // output wire [0 : 0] s_axi_awready
    .s_axi_Xi_wdata(axi_Xi_wdata),        // input wire [63 : 0] s_axi_wdata
    .s_axi_Xi_wstrb(axi_Xi_wstrb),        // input wire [7 : 0] s_axi_wstrb
    .s_axi_Xi_wlast(axi_Xi_wlast),        // input wire [0 : 0] s_axi_wlast
    .s_axi_Xi_wvalid(axi_Xi_wvalid),      // input wire [0 : 0] s_axi_wvalid
    .s_axi_Xi_wready(axi_Xi_wready),      // output wire [0 : 0] s_axi_wready
    .s_axi_Xi_bresp(axi_Xi_bresp),        // output wire [1 : 0] s_axi_bresp
    .s_axi_Xi_bvalid(axi_Xi_bvalid),      // output wire [0 : 0] s_axi_bvalid
    .s_axi_Xi_bready(axi_Xi_bready),      // input wire [0 : 0] s_axi_bready
    .s_axi_Xi_araddr(axi_Xi_araddr & 48'h000F_FFFF_FFFF),      // input wire [47 : 0] s_axi_araddr
    .s_axi_Xi_arlen(axi_Xi_arlen),        // input wire [7 : 0] s_axi_arlen
    .s_axi_Xi_arsize(axi_Xi_arsize),      // input wire [2 : 0] s_axi_arsize
    .s_axi_Xi_arburst(axi_Xi_arburst),    // input wire [1 : 0] s_axi_arburst
    .s_axi_Xi_arvalid(axi_Xi_arvalid),    // input wire [0 : 0] s_axi_arvalid
    .s_axi_Xi_arready(axi_Xi_arready),    // output wire [0 : 0] s_axi_arready
    .s_axi_Xi_rdata(axi_Xi_rdata),        // output wire [63 : 0] s_axi_rdata
    .s_axi_Xi_rresp(axi_Xi_rresp),        // output wire [1 : 0] s_axi_rresp
    .s_axi_Xi_rlast(axi_Xi_rlast),        // output wire [0 : 0] s_axi_rlast
    .s_axi_Xi_rvalid(axi_Xi_rvalid),      // output wire [0 : 0] s_axi_rvalid
    .s_axi_Xi_rready(axi_Xi_rready),      // input wire [0 : 0] s_axi_rready


    .s_axis_qdma_h2c_tvalid           (axis_qdma_h2c_tvalid),
    .s_axis_qdma_h2c_tdata            (axis_qdma_h2c_tdata),
    .s_axis_qdma_h2c_tkeep            (axis_qdma_h2c_tkeep),
    .s_axis_qdma_h2c_tlast            (axis_qdma_h2c_tlast),
    .s_axis_qdma_h2c_tuser_size       (axis_qdma_h2c_tuser_size),
    .s_axis_qdma_h2c_tuser_src        (axis_qdma_h2c_tuser_src),
    .s_axis_qdma_h2c_tuser_dst        (axis_qdma_h2c_tuser_dst),
    .s_axis_qdma_h2c_tready           (axis_qdma_h2c_tready),

    .m_axis_qdma_c2h_tvalid           (axis_qdma_c2h_tvalid),
    .m_axis_qdma_c2h_tdata            (axis_qdma_c2h_tdata),
    .m_axis_qdma_c2h_tkeep            (axis_qdma_c2h_tkeep),
    .m_axis_qdma_c2h_tlast            (axis_qdma_c2h_tlast),
    .m_axis_qdma_c2h_tuser_size       (axis_qdma_c2h_tuser_size),
    .m_axis_qdma_c2h_tuser_src        (axis_qdma_c2h_tuser_src),
    .m_axis_qdma_c2h_tuser_dst        (axis_qdma_c2h_tuser_dst),
    .m_axis_qdma_c2h_tready           (axis_qdma_c2h_tready),


    .mod_rstn                         (user_250mhz_rstn),
    .mod_rst_done                     (user_250mhz_rst_done),

    .box_rstn                         (box_250mhz_rstn),
    .box_rst_done                     (box_250mhz_rst_done),

    .axil_aclk                        (axil_aclk),
    .axis_aclk                        (axis_aclk)
  );

endmodule: pcie_spmv
// vivado -mode batch -source build.tcl -tclargs -board au50 -overwrite 1