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
`timescale 1ns/1ps
module box_250mhz #(
  parameter int MIN_PKT_LEN   = 64,
  parameter int MAX_PKT_LEN   = 1518,
  parameter int USE_PHYS_FUNC = 1,
  parameter int NUM_PHYS_FUNC = 1,
  parameter int NUM_CMAC_PORT = 1,
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



  output [(CONF_NUM_KERNEL*4+1)*48-1 : 0] m_axi_ker_araddr,
  output [(CONF_NUM_KERNEL*4+1)*2-1 : 0] m_axi_ker_arburst,
  output [(CONF_NUM_KERNEL*4+1)*8-1 : 0] m_axi_ker_arlen,
  output [(CONF_NUM_KERNEL*4+1)*3-1 : 0] m_axi_ker_arsize,
  output [(CONF_NUM_KERNEL*4+1)*1-1 : 0]m_axi_ker_arvalid,
  output [(CONF_NUM_KERNEL*4+1)*48-1 : 0] m_axi_ker_awaddr,
  output [(CONF_NUM_KERNEL*4+1)*2-1 : 0] m_axi_ker_awburst,
  output [(CONF_NUM_KERNEL*4+1)*8-1 : 0] m_axi_ker_awlen,
  output [(CONF_NUM_KERNEL*4+1)*3-1 : 0] m_axi_ker_awsize,
  output [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_awvalid,
  output [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_rready,
  output [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_bready,
  output [(CONF_NUM_KERNEL*4+1)*256-1 : 0] m_axi_ker_wdata,
  output [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_wlast,
  output [(CONF_NUM_KERNEL*4+1)*32-1 : 0] m_axi_ker_wstrb,
  output [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_wvalid,
  input [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_arready,
  input [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_awready,
  input [(CONF_NUM_KERNEL*4+1)*256-1 : 0] m_axi_ker_rdata,
  input [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_rlast,
  input [(CONF_NUM_KERNEL*4+1)*2-1 : 0] m_axi_ker_rresp,
  input [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_rvalid,
  input [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_wready,
  input [(CONF_NUM_KERNEL*4+1)*2-1 : 0] m_axi_ker_bresp,
  input [(CONF_NUM_KERNEL*4+1)*1-1 : 0] m_axi_ker_bvalid,

  
  input      [NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tvalid,
  
  input  [512*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tdata,
  
  input   [64*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tkeep,
  
  input      [NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tlast,
  
  input   [16*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tuser_size,
  
  input   [16*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tuser_src,
  
  input   [16*NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tuser_dst,
  
  output     [NUM_PHYS_FUNC-1:0] s_axis_qdma_h2c_tready,

  output     [NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tvalid,
  output [512*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tdata,
  output  [64*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tkeep,
  output     [NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tlast,
  output  [16*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tuser_size,
  output  [16*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tuser_src,
  output  [16*NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tuser_dst,
  input      [NUM_PHYS_FUNC-1:0] m_axis_qdma_c2h_tready,


  input                   [15:0] mod_rstn,
  output                  [15:0] mod_rst_done,

  input                          box_rstn,
  output                         box_rst_done,

  input                          axil_aclk,
  input                          axis_aclk
);

  wire internal_box_rstn;

  generic_reset #(
    .NUM_INPUT_CLK  (1),
    .RESET_DURATION (100)
  ) reset_inst (
    .mod_rstn     (box_rstn),
    .mod_rst_done (box_rst_done),
    .clk          (axil_aclk),
    .rstn         (internal_box_rstn)
  );

    // Terminate H2C and C2H interfaces of the box
    assign s_axis_qdma_h2c_tready     = {NUM_PHYS_FUNC{1'b1}};

    assign m_axis_qdma_c2h_tvalid     = 0;
    assign m_axis_qdma_c2h_tdata      = 0;
    assign m_axis_qdma_c2h_tkeep      = 0;
    assign m_axis_qdma_c2h_tlast      = 0;
    assign m_axis_qdma_c2h_tuser_size = 0;
    assign m_axis_qdma_c2h_tuser_src  = 0;
    assign m_axis_qdma_c2h_tuser_dst  = 0;
    axi4 #(48,256,1) axi_Xi[CONF_NUM_KERNEL];
    spmv_calc_top #(
      .CONF_NUM_KERNEL(CONF_NUM_KERNEL)
    )spmv_calc_top(

        .axil_clk(axil_aclk),
        .axis_clk(axis_aclk),
        .rstn(box_rstn),

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

        .m_axi_Col_araddr(m_axi_ker_araddr[CONF_NUM_KERNEL*48-1:0]),
        .m_axi_Col_arburst(m_axi_ker_arburst[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_arlen(m_axi_ker_arlen[CONF_NUM_KERNEL*8-1:0]),
        .m_axi_Col_arsize(m_axi_ker_arsize[CONF_NUM_KERNEL*3-1:0]),
        .m_axi_Col_arvalid(m_axi_ker_arvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_awaddr(m_axi_ker_awaddr[CONF_NUM_KERNEL*48-1:0]),
        .m_axi_Col_awburst(m_axi_ker_awburst[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_awlen(m_axi_ker_awlen[CONF_NUM_KERNEL*8-1:0]),
        .m_axi_Col_awsize(m_axi_ker_awsize[CONF_NUM_KERNEL*3-1:0]),
        .m_axi_Col_awvalid(m_axi_ker_awvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_rready(m_axi_ker_rready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_bready(m_axi_ker_bready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_wdata(m_axi_ker_wdata[CONF_NUM_KERNEL*256-1:0]),
        .m_axi_Col_wlast(m_axi_ker_wlast[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_wstrb(m_axi_ker_wstrb[CONF_NUM_KERNEL*32-1:0]),
        .m_axi_Col_wvalid(m_axi_ker_wvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_arready(m_axi_ker_arready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_awready(m_axi_ker_awready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_rdata(m_axi_ker_rdata[CONF_NUM_KERNEL*256-1:0]),
        .m_axi_Col_rlast(m_axi_ker_rlast[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_rresp(m_axi_ker_rresp[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_rvalid(m_axi_ker_rvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_wready(m_axi_ker_wready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_bresp(m_axi_ker_bresp[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_bvalid(m_axi_ker_bvalid[CONF_NUM_KERNEL*1-1:0]),

        .m_axi_hbm_Val_araddr(m_axi_ker_araddr[(CONF_NUM_KERNEL)*48 +: 48]),
        .m_axi_hbm_Val_arburst(m_axi_ker_arburst[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_arlen(m_axi_ker_arlen[(CONF_NUM_KERNEL)*8 +: 8]),
        .m_axi_hbm_Val_arsize(m_axi_ker_arsize[(CONF_NUM_KERNEL)*3 +: 3]),
        .m_axi_hbm_Val_arvalid(m_axi_ker_arvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_awaddr(m_axi_ker_awaddr[(CONF_NUM_KERNEL)*48 +: 48]),
        .m_axi_hbm_Val_awburst(m_axi_ker_awburst[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_awlen(m_axi_ker_awlen[(CONF_NUM_KERNEL)*8 +: 8]),
        .m_axi_hbm_Val_awsize(m_axi_ker_awsize[(CONF_NUM_KERNEL)*3 +: 3]),
        .m_axi_hbm_Val_awvalid(m_axi_ker_awvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rready(m_axi_ker_rready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_bready(m_axi_ker_bready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wdata(m_axi_ker_wdata[(CONF_NUM_KERNEL)*256 +: 256]),
        .m_axi_hbm_Val_wlast(m_axi_ker_wlast[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wstrb(m_axi_ker_wstrb[(CONF_NUM_KERNEL)*32 +: 32]),
        .m_axi_hbm_Val_wvalid(m_axi_ker_wvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_arready(m_axi_ker_arready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_awready(m_axi_ker_awready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rdata(m_axi_ker_rdata[(CONF_NUM_KERNEL)*256 +: 256]),
        .m_axi_hbm_Val_rlast(m_axi_ker_rlast[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rresp(m_axi_ker_rresp[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_rvalid(m_axi_ker_rvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wready(m_axi_ker_wready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_bresp(m_axi_ker_bresp[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_bvalid(m_axi_ker_bvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        // TODO
        .m_axi_Xi(axi_Xi)
    );
    


endmodule: box_250mhz
