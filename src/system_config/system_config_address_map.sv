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
// System address map (through PCI-e BAR2 4MB)
//
// --------------------------------------------------
//   BaseAddr  |  HighAddr |  Module
// --------------------------------------------------
//    0x00000  |  0x00FFF  |  System configuration
// --------------------------------------------------
//    0x01000  |  0x05FFF  |  QDMA subsystem
// --------------------------------------------------
//    0x08000  |  0x0AFFF  |  CMAC subsystem #0
// --------------------------------------------------
//    0x0B000  |  0x0BFFF  |  Packet adapter #0
// --------------------------------------------------
//    0x0C000  |  0x0EFFF  |  CMAC subsystem #1
// --------------------------------------------------
//    0x0F000  |  0x0FFFF  |  Packet adapter #1
// --------------------------------------------------
//    0x10000  |  0x11FFF  |  Sysmon block
// --------------------------------------------------
//   0x100000  |  0x1FFFFF |  Box0 @ 250MHz
// --------------------------------------------------
//   0x200000  |  0x2FFFFF |  Box1 @ 322MHz
// --------------------------------------------------

`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
module system_config_address_map #(
  parameter int NUM_CMAC_PORT = 1
) (
  input                         s_axil_awvalid,
  input                  [31:0] s_axil_awaddr,
  output                        s_axil_awready,
  input                         s_axil_wvalid,
  input                  [31:0] s_axil_wdata,
  output                        s_axil_wready,
  output                        s_axil_bvalid,
  output                  [1:0] s_axil_bresp,
  input                         s_axil_bready,
  input                         s_axil_arvalid,
  input                  [31:0] s_axil_araddr,
  output                        s_axil_arready,
  output                        s_axil_rvalid,
  output                 [31:0] s_axil_rdata,
  output                  [1:0] s_axil_rresp,
  input                         s_axil_rready,

  output                        m_axil_scfg_awvalid,
  output                 [31:0] m_axil_scfg_awaddr,
  input                         m_axil_scfg_awready,
  output                        m_axil_scfg_wvalid,
  output                 [31:0] m_axil_scfg_wdata,
  input                         m_axil_scfg_wready,
  input                         m_axil_scfg_bvalid,
  input                   [1:0] m_axil_scfg_bresp,
  output                        m_axil_scfg_bready,
  output                        m_axil_scfg_arvalid,
  output                 [31:0] m_axil_scfg_araddr,
  input                         m_axil_scfg_arready,
  input                         m_axil_scfg_rvalid,
  input                  [31:0] m_axil_scfg_rdata,
  input                   [1:0] m_axil_scfg_rresp,
  output                        m_axil_scfg_rready,

  output                        m_axil_qdma_awvalid,
  output                 [31:0] m_axil_qdma_awaddr,
  input                         m_axil_qdma_awready,
  output                        m_axil_qdma_wvalid,
  output                 [31:0] m_axil_qdma_wdata,
  input                         m_axil_qdma_wready,
  input                         m_axil_qdma_bvalid,
  input                   [1:0] m_axil_qdma_bresp,
  output                        m_axil_qdma_bready,
  output                        m_axil_qdma_arvalid,
  output                 [31:0] m_axil_qdma_araddr,
  input                         m_axil_qdma_arready,
  input                         m_axil_qdma_rvalid,
  input                  [31:0] m_axil_qdma_rdata,
  input                   [1:0] m_axil_qdma_rresp,
  output                        m_axil_qdma_rready,

  output                        m_axil_box0_awvalid,
  output                 [31:0] m_axil_box0_awaddr,
  input                         m_axil_box0_awready,
  output                        m_axil_box0_wvalid,
  output                 [31:0] m_axil_box0_wdata,
  input                         m_axil_box0_wready,
  input                         m_axil_box0_bvalid,
  input                   [1:0] m_axil_box0_bresp,
  output                        m_axil_box0_bready,
  output                        m_axil_box0_arvalid,
  output                 [31:0] m_axil_box0_araddr,
  input                         m_axil_box0_arready,
  input                         m_axil_box0_rvalid,
  input                  [31:0] m_axil_box0_rdata,
  input                   [1:0] m_axil_box0_rresp,
  output                        m_axil_box0_rready,

  output                        m_axil_smon_awvalid,
  output                 [31:0] m_axil_smon_awaddr,
  input                         m_axil_smon_awready,
  output                        m_axil_smon_wvalid,
  output                 [31:0] m_axil_smon_wdata,
  input                         m_axil_smon_wready,
  input                         m_axil_smon_bvalid,
  input                   [1:0] m_axil_smon_bresp,
  output                        m_axil_smon_bready,
  output                        m_axil_smon_arvalid,
  output                 [31:0] m_axil_smon_araddr,
  input                         m_axil_smon_arready,
  input                         m_axil_smon_rvalid,
  input                  [31:0] m_axil_smon_rdata,
  input                   [1:0] m_axil_smon_rresp,
  output                        m_axil_smon_rready,

  input                         aclk,
  input                         aresetn
);

  localparam C_NUM_SLAVES  = 4;

  localparam C_SCFG_INDEX  = 0;
  localparam C_QDMA_INDEX  = 1;

  localparam C_SMON_INDEX  = 2;
  localparam C_BOX0_INDEX  = 3;

  localparam C_SCFG_BASE_ADDR  = 32'h0;
  localparam C_QDMA_BASE_ADDR  = 32'h01000;
  localparam C_SMON_BASE_ADDR  = 32'h10000;  // 14 bits
  localparam C_BOX0_BASE_ADDR  = 32'h100000; // 20 bits

  wire                [31:0] axil_scfg_awaddr;
  wire                [31:0] axil_scfg_araddr;
  wire                [31:0] axil_qdma_awaddr;
  wire                [31:0] axil_qdma_araddr;

  wire                [31:0] axil_box1_awaddr;
  wire                [31:0] axil_box1_araddr;
  wire                [31:0] axil_box0_awaddr;
  wire                [31:0] axil_box0_araddr;
  wire                [31:0] axil_smon_awaddr;
  wire                [31:0] axil_smon_araddr;

  wire  [1*C_NUM_SLAVES-1:0] axil_awvalid;
  wire [32*C_NUM_SLAVES-1:0] axil_awaddr;
  wire  [1*C_NUM_SLAVES-1:0] axil_awready;
  wire  [1*C_NUM_SLAVES-1:0] axil_wvalid;
  wire [32*C_NUM_SLAVES-1:0] axil_wdata;
  wire  [1*C_NUM_SLAVES-1:0] axil_wready;
  wire  [1*C_NUM_SLAVES-1:0] axil_bvalid;
  wire  [2*C_NUM_SLAVES-1:0] axil_bresp;
  wire  [1*C_NUM_SLAVES-1:0] axil_bready;
  wire  [1*C_NUM_SLAVES-1:0] axil_arvalid;
  wire [32*C_NUM_SLAVES-1:0] axil_araddr;
  wire  [1*C_NUM_SLAVES-1:0] axil_arready;
  wire  [1*C_NUM_SLAVES-1:0] axil_rvalid;
  wire [32*C_NUM_SLAVES-1:0] axil_rdata;
  wire  [2*C_NUM_SLAVES-1:0] axil_rresp;
  wire  [1*C_NUM_SLAVES-1:0] axil_rready;

  // Adjust AXI-Lite address so that each slave can assume a base address of 0x0
  assign axil_scfg_awaddr                      = axil_awaddr[`getvec(32, C_SCFG_INDEX)] - C_SCFG_BASE_ADDR;
  assign axil_scfg_araddr                      = axil_araddr[`getvec(32, C_SCFG_INDEX)] - C_SCFG_BASE_ADDR;
  assign axil_qdma_awaddr                      = axil_awaddr[`getvec(32, C_QDMA_INDEX)] - C_QDMA_BASE_ADDR;
  assign axil_qdma_araddr                      = axil_araddr[`getvec(32, C_QDMA_INDEX)] - C_QDMA_BASE_ADDR;
 
  assign axil_smon_awddr                       = axil_awaddr[`getvec(32, C_SMON_INDEX)]  - C_SMON_BASE_ADDR;
  assign axil_smon_araddr                      = axil_araddr[`getvec(32, C_SMON_INDEX)] - C_SMON_BASE_ADDR;
  assign axil_box0_awaddr                      = axil_awaddr[`getvec(32, C_BOX0_INDEX)] - C_BOX0_BASE_ADDR;
  assign axil_box0_araddr                      = axil_araddr[`getvec(32, C_BOX0_INDEX)] - C_BOX0_BASE_ADDR;

  assign m_axil_scfg_awvalid                   = axil_awvalid[C_SCFG_INDEX];
  assign m_axil_scfg_awaddr                    = axil_scfg_awaddr;
  assign axil_awready[C_SCFG_INDEX]            = m_axil_scfg_awready;
  assign m_axil_scfg_wvalid                    = axil_wvalid[C_SCFG_INDEX];
  assign m_axil_scfg_wdata                     = axil_wdata[`getvec(32, C_SCFG_INDEX)];
  assign axil_wready[C_SCFG_INDEX]             = m_axil_scfg_wready;
  assign axil_bvalid[C_SCFG_INDEX]             = m_axil_scfg_bvalid;
  assign axil_bresp[`getvec(2, C_SCFG_INDEX)]  = m_axil_scfg_bresp;
  assign m_axil_scfg_bready                    = axil_bready[C_SCFG_INDEX];
  assign m_axil_scfg_arvalid                   = axil_arvalid[C_SCFG_INDEX];
  assign m_axil_scfg_araddr                    = axil_scfg_araddr;
  assign axil_arready[C_SCFG_INDEX]            = m_axil_scfg_arready;
  assign axil_rvalid[C_SCFG_INDEX]             = m_axil_scfg_rvalid;
  assign axil_rdata[`getvec(32, C_SCFG_INDEX)] = m_axil_scfg_rdata;
  assign axil_rresp[`getvec(2, C_SCFG_INDEX)]  = m_axil_scfg_rresp;
  assign m_axil_scfg_rready                    = axil_rready[C_SCFG_INDEX];

  assign m_axil_qdma_awvalid                   = axil_awvalid[C_QDMA_INDEX];
  assign m_axil_qdma_awaddr                    = axil_qdma_awaddr;
  assign axil_awready[C_QDMA_INDEX]            = m_axil_qdma_awready;
  assign m_axil_qdma_wvalid                    = axil_wvalid[C_QDMA_INDEX];
  assign m_axil_qdma_wdata                     = axil_wdata[`getvec(32, C_QDMA_INDEX)];
  assign axil_wready[C_QDMA_INDEX]             = m_axil_qdma_wready;
  assign axil_bvalid[C_QDMA_INDEX]             = m_axil_qdma_bvalid;
  assign axil_bresp[`getvec(2, C_QDMA_INDEX)]  = m_axil_qdma_bresp;
  assign m_axil_qdma_bready                    = axil_bready[C_QDMA_INDEX];
  assign m_axil_qdma_arvalid                   = axil_arvalid[C_QDMA_INDEX];
  assign m_axil_qdma_araddr                    = axil_qdma_araddr;
  assign axil_arready[C_QDMA_INDEX]            = m_axil_qdma_arready;
  assign axil_rvalid[C_QDMA_INDEX]             = m_axil_qdma_rvalid;
  assign axil_rdata[`getvec(32, C_QDMA_INDEX)] = m_axil_qdma_rdata;
  assign axil_rresp[`getvec(2, C_QDMA_INDEX)]  = m_axil_qdma_rresp;
  assign m_axil_qdma_rready                    = axil_rready[C_QDMA_INDEX];

  
  assign m_axil_box0_awvalid                   = axil_awvalid[C_BOX0_INDEX];
  assign m_axil_box0_awaddr                    = axil_box0_awaddr;
  assign axil_awready[C_BOX0_INDEX]            = m_axil_box0_awready;
  assign m_axil_box0_wvalid                    = axil_wvalid[C_BOX0_INDEX];
  assign m_axil_box0_wdata                     = axil_wdata[`getvec(32, C_BOX0_INDEX)];
  assign axil_wready[C_BOX0_INDEX]             = m_axil_box0_wready;
  assign axil_bvalid[C_BOX0_INDEX]             = m_axil_box0_bvalid;
  assign axil_bresp[`getvec(2, C_BOX0_INDEX)]  = m_axil_box0_bresp;
  assign m_axil_box0_bready                    = axil_bready[C_BOX0_INDEX];
  assign m_axil_box0_arvalid                   = axil_arvalid[C_BOX0_INDEX];
  assign m_axil_box0_araddr                    = axil_box0_araddr;
  assign axil_arready[C_BOX0_INDEX]            = m_axil_box0_arready;
  assign axil_rvalid[C_BOX0_INDEX]             = m_axil_box0_rvalid;
  assign axil_rdata[`getvec(32, C_BOX0_INDEX)] = m_axil_box0_rdata;
  assign axil_rresp[`getvec(2, C_BOX0_INDEX)]  = m_axil_box0_rresp;
  assign m_axil_box0_rready                    = axil_rready[C_BOX0_INDEX];

  assign m_axil_smon_awvalid                   = axil_awvalid[C_SMON_INDEX];
  assign m_axil_smon_awaddr                    = axil_smon_awaddr;
  assign axil_awready[C_SMON_INDEX]            = m_axil_smon_awready;
  assign m_axil_smon_wvalid                    = axil_wvalid[C_SMON_INDEX];
  assign m_axil_smon_wdata                     = axil_wdata[`getvec(32, C_SMON_INDEX)];
  assign axil_wready[C_SMON_INDEX]             = m_axil_smon_wready;
  assign axil_bvalid[C_SMON_INDEX]             = m_axil_smon_bvalid;
  assign axil_bresp[`getvec(2, C_SMON_INDEX)]  = m_axil_smon_bresp;
  assign m_axil_smon_bready                    = axil_bready[C_SMON_INDEX];
  assign m_axil_smon_arvalid                   = axil_arvalid[C_SMON_INDEX];
  assign m_axil_smon_araddr                    = axil_smon_araddr;
  assign axil_arready[C_SMON_INDEX]            = m_axil_smon_arready;
  assign axil_rvalid[C_SMON_INDEX]             = m_axil_smon_rvalid;
  assign axil_rdata[`getvec(32, C_SMON_INDEX)] = m_axil_smon_rdata;
  assign axil_rresp[`getvec(2, C_SMON_INDEX)]  = m_axil_smon_rresp;
  assign m_axil_smon_rready                    = axil_rready[C_SMON_INDEX];

  system_config_axi_crossbar xbar_inst (
    .s_axi_awaddr  (s_axil_awaddr),
    .s_axi_awprot  (0),
    .s_axi_awvalid (s_axil_awvalid),
    .s_axi_awready (s_axil_awready),
    .s_axi_wdata   (s_axil_wdata),
    .s_axi_wstrb   (4'hF),
    .s_axi_wvalid  (s_axil_wvalid),
    .s_axi_wready  (s_axil_wready),
    .s_axi_bresp   (s_axil_bresp),
    .s_axi_bvalid  (s_axil_bvalid),
    .s_axi_bready  (s_axil_bready),
    .s_axi_araddr  (s_axil_araddr),
    .s_axi_arprot  (0),
    .s_axi_arvalid (s_axil_arvalid),
    .s_axi_arready (s_axil_arready),
    .s_axi_rdata   (s_axil_rdata),
    .s_axi_rresp   (s_axil_rresp),
    .s_axi_rvalid  (s_axil_rvalid),
    .s_axi_rready  (s_axil_rready),

    .m_axi_awaddr  (axil_awaddr),
    .m_axi_awprot  (),
    .m_axi_awvalid (axil_awvalid),
    .m_axi_awready (axil_awready),
    .m_axi_wdata   (axil_wdata),
    .m_axi_wstrb   (),
    .m_axi_wvalid  (axil_wvalid),
    .m_axi_wready  (axil_wready),
    .m_axi_bresp   (axil_bresp),
    .m_axi_bvalid  (axil_bvalid),
    .m_axi_bready  (axil_bready),
    .m_axi_araddr  (axil_araddr),
    .m_axi_arprot  (),
    .m_axi_arvalid (axil_arvalid),
    .m_axi_arready (axil_arready),
    .m_axi_rdata   (axil_rdata),
    .m_axi_rresp   (axil_rresp),
    .m_axi_rvalid  (axil_rvalid),
    .m_axi_rready  (axil_rready),

    .aclk          (aclk),
    .aresetn       (aresetn)
  );

endmodule: system_config_address_map
