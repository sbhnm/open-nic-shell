// 数据存储层次如下：
// Xi 聚合,每个核心分配四端口
// 所有ColIndex 聚合，与Xi端口共用端口
// 端口名 ColXi
// NNZ Val Yi 共用端口 
// 端口名 MatWB
// 这个模块用于描述单个计算核心的硬件结构。
`include "pcie_spmv_macros.vh"
`timescale 1ns/1ps
module spmv_calc_kernel #(

) (
    output [1*48-1 : 0] m_axi_Col_araddr,
    output [1*2-1 : 0] m_axi_Col_arburst,
    output [1*8-1 : 0] m_axi_Col_arlen,
    output [1*3-1 : 0] m_axi_Col_arsize,
    output [1*1-1 : 0]m_axi_Col_arvalid,
    output [1*48-1 : 0] m_axi_Col_awaddr,
    output [1*2-1 : 0] m_axi_Col_awburst,
    output [1*8-1 : 0] m_axi_Col_awlen,
    output [1*3-1 : 0] m_axi_Col_awsize,
    output [1*1-1 : 0] m_axi_Col_awvalid,
    output [1*1-1 : 0] m_axi_Col_rready,
    output [1*1-1 : 0] m_axi_Col_bready,
    output [1*256-1 : 0] m_axi_Col_wdata,
    output [1*1-1 : 0] m_axi_Col_wlast,
    output [1*32-1 : 0] m_axi_Col_wstrb,
    output [1*1-1 : 0] m_axi_Col_wvalid,
    input [1*1-1 : 0] m_axi_Col_arready,
    input [1*1-1 : 0] m_axi_Col_awready,
    input [1*256-1 : 0] m_axi_Col_rdata,
    input [1*1-1 : 0] m_axi_Col_rlast,
    input [1*2-1 : 0] m_axi_Col_rresp,
    input [1*1-1 : 0] m_axi_Col_rvalid,
    input [1*1-1 : 0] m_axi_Col_wready,
    input [1*2-1 : 0] m_axi_Col_bresp,
    input [1*1-1 : 0] m_axi_Col_bvalid,

    input [1*48-1 : 0] s_axi_Xi_bram_araddr,
    input [1*2-1 : 0] s_axi_Xi_bram_arburst,
    input [1*8-1 : 0] s_axi_Xi_bram_arlen,
    input [1*3-1 : 0] s_axi_Xi_bram_arsize,
    input [1*1-1 : 0]s_axi_Xi_bram_arvalid,
    input [1*48-1 : 0] s_axi_Xi_bram_awaddr,
    input [1*2-1 : 0] s_axi_Xi_bram_awburst,
    input [1*8-1 : 0] s_axi_Xi_bram_awlen,
    input [1*3-1 : 0] s_axi_Xi_bram_awsize,
    input [1*1-1 : 0] s_axi_Xi_bram_awvalid,
    input [1*1-1 : 0] s_axi_Xi_bram_rready,
    input [1*1-1 : 0] s_axi_Xi_bram_bready,
    input [1*64-1 : 0] s_axi_Xi_bram_wdata,
    input [1*1-1 : 0] s_axi_Xi_bram_wlast,
    input [1*8-1 : 0] s_axi_Xi_bram_wstrb,
    input [1*1-1 : 0] s_axi_Xi_bram_wvalid,
    output [1*1-1 : 0] s_axi_Xi_bram_arready,
    output [1*1-1 : 0] s_axi_Xi_bram_awready,
    output [1*64-1 : 0] s_axi_Xi_bram_rdata,
    output [1*1-1 : 0] s_axi_Xi_bram_rlast,
    output [1*2-1 : 0] s_axi_Xi_bram_rresp,
    output [1*1-1 : 0] s_axi_Xi_bram_rvalid,
    output [1*1-1 : 0] s_axi_Xi_bram_wready,
    output [1*2-1 : 0] s_axi_Xi_bram_bresp,
    output [1*1-1 : 0] s_axi_Xi_bram_bvalid,
    input [3:0] s_axi_Xi_bram_awcache,
    input [2:0] s_axi_Xi_bram_awprot,
    input [3:0] s_axi_Xi_bram_awqos,
    input [0:0] s_axi_Xi_bram_awlock,
    input [3:0] s_axi_Xi_bram_arcache,
    input [2:0] s_axi_Xi_bram_arprot,
    input [3:0] s_axi_Xi_bram_arqos,
    input [0:0] s_axi_Xi_bram_arlock,
    
    

    output [47 : 0] m_axi_Val_araddr,
    output [1 : 0] m_axi_Val_arburst,
    output [7 : 0] m_axi_Val_arlen,
    output [2 : 0] m_axi_Val_arsize,
    output m_axi_Val_arvalid,
    output [47 : 0] m_axi_Val_awaddr,
    output [1 : 0] m_axi_Val_awburst,
    output [7 : 0] m_axi_Val_awlen,
    output [2 : 0] m_axi_Val_awsize,
    output m_axi_Val_awvalid,
    output m_axi_Val_rready,
    output m_axi_Val_bready,
    output [255 : 0] m_axi_Val_wdata,
    output m_axi_Val_wlast,
    output [31 : 0] m_axi_Val_wstrb,
    output m_axi_Val_wvalid,
    input m_axi_Val_arready,
    input m_axi_Val_awready,
    input [255 : 0] m_axi_Val_rdata,
    input m_axi_Val_rlast,
    input [1 : 0] m_axi_Val_rresp,
    input m_axi_Val_rvalid,
    input m_axi_Val_wready,
    input [1:0] m_axi_Val_bresp,
    input m_axi_Val_bvalid,

    input [32*3-1:0] config_wire,
    output [32*3-1:0] status_wire,


    input clk,
    input rstn

);
    wire [3:0] axi_Xi_Width_arregion;
    wire [4*1-1 : 0]        axi_Col_arid;
    wire [4*48-1 : 0]       axi_Col_araddr;
    wire [4*8-1 : 0]        axi_Col_arlen;
    wire [4*6-1 : 0]        axi_Col_arsize;
    wire [4*2-1 : 0]        axi_Col_arburst;
    wire [4*1-1:0]          axi_Col_arlock;
    wire [4*4-1 : 0]        axi_Col_arcache;
    wire [4*3-1 : 0]        axi_Col_arprot;
    wire [4*4-1 : 0]        axi_Col_arqos;
    wire [4*1-1:0]          axi_Col_arvalid;
    wire [4*1-1:0]          axi_Col_arready;
    wire [4*1-1 : 0]        axi_Col_rid;
    wire [4*256-1 : 0]       axi_Col_rdata;
    wire [4*2-1 : 0]        axi_Col_rresp;
    wire [4*1-1:0]          axi_Col_rlast;
    wire [4*1-1:0]          axi_Col_rvalid;
    wire [4*1-1:0]          axi_Col_rready;

    
    wire [4*1-1 : 0]        axi_demux_Col_arid;
    wire [4*48-1 : 0]       axi_demux_Col_araddr;
    wire [4*8-1 : 0]        axi_demux_Col_arlen;
    wire [4*3-1 : 0]        axi_demux_Col_arsize;
    wire [4*2-1 : 0]        axi_demux_Col_arburst;
    wire [4*1-1:0]          axi_demux_Col_arlock;
    wire [4*4-1 : 0]        axi_demux_Col_arcache;
    wire [4*3-1 : 0]        axi_demux_Col_arprot;
    wire [4*4-1 : 0]        axi_demux_Col_arqos;
    wire [4*1-1:0]          axi_demux_Col_arvalid;
    wire [4*1-1:0]          axi_demux_Col_arready;
    wire [4*1-1 : 0]        axi_demux_Col_rid;
    wire [4*32-1 : 0]       axi_demux_Col_rdata;
    wire [4*2-1 : 0]        axi_demux_Col_rresp;
    wire [4*1-1:0]          axi_demux_Col_rlast;
    wire [4*1-1:0]          axi_demux_Col_rvalid;
    wire [4*1-1:0]          axi_demux_Col_rready;

    wire [4*48-1 : 0] axi_Xi_bram_araddr;
    wire [4*2-1 : 0] axi_Xi_bram_arburst;
    wire [4*8-1 : 0] axi_Xi_bram_arlen;
    wire [4*3-1 : 0] axi_Xi_bram_arsize;
    wire [4*1-1 : 0]axi_Xi_bram_arvalid;
    wire [4*48-1 : 0] axi_Xi_bram_awaddr;
    wire [4*2-1 : 0] axi_Xi_bram_awburst;
    wire [4*8-1 : 0] axi_Xi_bram_awlen;
    wire [4*3-1 : 0] axi_Xi_bram_awsize;
    wire [4*1-1 : 0] axi_Xi_bram_awvalid;
    wire [4*1-1 : 0] axi_Xi_bram_rready;
    wire [4*1-1 : 0] axi_Xi_bram_bready;
    wire [4*64-1 : 0] axi_Xi_bram_wdata;
    wire [4*1-1 : 0] axi_Xi_bram_wlast;
    wire [4*8-1 : 0] axi_Xi_bram_wstrb;
    wire [4*1-1 : 0] axi_Xi_bram_wvalid;
    wire  [4*1-1 : 0] axi_Xi_bram_arready;
    wire  [4*1-1 : 0] axi_Xi_bram_awready;
    wire  [4*64-1 : 0] axi_Xi_bram_rdata;
    wire  [4*1-1 : 0] axi_Xi_bram_rlast;
    wire  [4*2-1 : 0] axi_Xi_bram_rresp;
    wire  [4*1-1 : 0] axi_Xi_bram_rvalid;
    wire  [4*1-1 : 0] axi_Xi_bram_wready;
    wire  [4*2-1 : 0] axi_Xi_bram_bresp;
    wire  [4*1-1 : 0] axi_Xi_bram_bvalid;


    wire [4*1-1 : 0]        axi_bl_ker_arid;
    wire [4*48-1 : 0]       axi_bl_ker_araddr;
    wire [4*8-1 : 0]        axi_bl_ker_arlen;
    wire [4*3-1 : 0]        axi_bl_ker_arsize;
    wire [4*2-1 : 0]        axi_bl_ker_arburst;
    wire [4*1-1:0]          axi_bl_ker_arlock;
    wire [4*4-1 : 0]        axi_bl_ker_arcache;
    wire [4*3-1 : 0]        axi_bl_ker_arprot;
    wire [4*4-1 : 0]        axi_bl_ker_arqos;
    wire [4*1-1:0]          axi_bl_ker_arvalid;
    wire [4*1-1:0]          axi_bl_ker_arready;
    wire [4*1-1 : 0]        axi_bl_ker_rid;
    wire [4*64-1 : 0]       axi_bl_ker_rdata;
    wire [4*2-1 : 0]        axi_bl_ker_rresp;
    wire [4*1-1:0]          axi_bl_ker_rlast;
    wire [4*1-1:0]          axi_bl_ker_rvalid;
    wire [4*1-1:0]          axi_bl_ker_rready;

    wire [3*2-1 : 0]        axi_NNZWB_arid;
    wire [3*48-1 : 0]       axi_NNZWB_araddr;
    wire [3*8-1 : 0]        axi_NNZWB_arlen;
    wire [3*3-1 : 0]        axi_NNZWB_arsize;
    wire [3*2-1 : 0]        axi_NNZWB_arburst;
    wire [3*1-1:0]          axi_NNZWB_arlock;
    wire [3*4-1 : 0]        axi_NNZWB_arcache;
    wire [3*3-1 : 0]        axi_NNZWB_arprot;
    wire [3*4-1 : 0]        axi_NNZWB_arqos;
    wire [3*1-1:0]          axi_NNZWB_arvalid;
    wire [3*1-1:0]          axi_NNZWB_arready;
    wire [3*2-1 : 0]        axi_NNZWB_rid;
    wire [3*256-1 : 0]       axi_NNZWB_rdata;
    wire [3*2-1 : 0]        axi_NNZWB_rresp;
    wire [3*1-1:0]          axi_NNZWB_rlast;
    wire [3*1-1:0]          axi_NNZWB_rvalid;
    wire [3*1-1:0]          axi_NNZWB_rready;

    wire [8*48-1:0] axi_Switch_awaddr;
    wire [8*8-1:0] axi_Switch_awlen;
    wire [8*1-1:0] axi_Switch_awvalid;
    wire [8*1-1:0] axi_Switch_awready;
    wire [8*64-1:0] axi_Switch_wdata;
    wire [8*8-1:0] axi_Switch_wstrb;
    wire [8*1-1:0] axi_Switch_wlast;
    wire [8*1-1:0] axi_Switch_wvalid;
    wire [8*1-1:0] axi_Switch_wready;
    wire [8*2-1:0] axi_Switch_bresp;
    wire [8*1-1:0] axi_Switch_bvalid;
    wire [8*1-1:0] axi_Switch_bready;

    wire [8*48-1:0] axi_Switch_araddr;
    wire [8*8-1:0] axi_Switch_arlen;
    wire [8*1-1:0] axi_Switch_arvalid;
    wire [8*1-1:0] axi_Switch_arready;
    wire [8*64-1:0] axi_Switch_rdata;
    wire [8*2-1:0] axi_Switch_rresp;
    wire [8*1-1:0] axi_Switch_rlast;
    wire [8*1-1:0] axi_Switch_rvalid;
    wire [8*1-1:0] axi_Switch_rready;

    wire [8*48-1:0] axi_Xi_awaddr;
    wire [8*8-1:0] axi_Xi_awlen;
    wire [8*1-1:0] axi_Xi_awvalid;
    wire [8*1-1:0] axi_Xi_awready;
    wire [8*64-1:0] axi_Xi_wdata;
    wire [8*8-1:0] axi_Xi_wstrb;
    wire [8*1-1:0] axi_Xi_wlast;
    wire [8*1-1:0] axi_Xi_wvalid;
    wire [8*1-1:0] axi_Xi_wready;
    wire [8*1-1:0] axi_Xi_bresp;
    wire [8*1-1:0] axi_Xi_bvalid;
    wire [8*1-1:0] axi_Xi_bready;

    wire [8*48-1:0] axi_Xi_araddr;
    wire [8*8-1:0] axi_Xi_arlen;
    wire [8*1-1:0] axi_Xi_arvalid;
    wire [8*1-1:0] axi_Xi_arready;
    wire [8*64-1:0] axi_Xi_rdata;
    wire [8*1-1:0] axi_Xi_rresp;
    wire [8*1-1:0] axi_Xi_rlast;
    wire [8*1-1:0] axi_Xi_rvalid;
    wire [8*1-1:0] axi_Xi_rready;

    wire [3*2-1 : 0] axi_Yi_awid;
    wire [3*48-1 : 0] axi_Yi_awaddr;
    wire [3*8-1 : 0] axi_Yi_awlen;
    wire [3*3-1 : 0] axi_Yi_awsize;
    wire [3*2-1 : 0] axi_Yi_awburst;
    wire [3*1-1 : 0] axi_Yi_awlock;
    wire [3*4-1 : 0] axi_Yi_awcache;
    wire [3*3-1 : 0] axi_Yi_awprot;
    wire [3*4-1 : 0] axi_Yi_awqos;
    wire [3*1-1 : 0] axi_Yi_awvalid;
    wire [3*1-1 : 0] axi_Yi_awready;
    wire [3*256-1 : 0] axi_Yi_wdata;
    wire [3*32-1 : 0] axi_Yi_wstrb;
    wire [3*1-1 : 0] axi_Yi_wlast;
    wire [3*1-1 : 0] axi_Yi_wvalid;
    wire [3*1-1 : 0] axi_Yi_wready;
    wire [3*2-1 : 0] axi_Yi_bid;
    wire [3*2-1 : 0] axi_Yi_bresp;
    wire [3*1-1 : 0] axi_Yi_bvalid;
    wire [3*1-1 : 0] axi_Yi_bready;

    assign axi_Xi_Width_arregion = 4'b1111;
    wire Calc_End;
    Timer Timer(
        .clk(clk),
        .rstn(rstn),
        .Time_Use(status_wire[63:0]),
        .begin_sig(config_wire[0]),
        .end_sig(Calc_End)
    );
    Row_Top #()Row_Top
    (
        .clk(clk),
        .rstn( rstn),
        .Ctrl_sig_Val(config_wire[2:1]),
        .Ctrl_sig_Xi(config_wire[4:3]),
        .Ctrl_sig_Yi(config_wire[6:5]),
        .Row_Num(config_wire[`getvec(32,1)]),

        .NNZ_Num(config_wire[`getvec(32,2)]),

        .Calc_Begin(config_wire[0]),
        .Calc_End(Calc_End),


        .m_axi_NNZ_arid(axi_NNZWB_arid[`getvec(2,0)]),
        .m_axi_NNZ_araddr(axi_NNZWB_araddr[`getvec(48,0)]),
        .m_axi_NNZ_arlen(axi_NNZWB_arlen[`getvec(8,0)]),
        .m_axi_NNZ_arsize(axi_NNZWB_arsize[`getvec(3,0)]),
        .m_axi_NNZ_arburst(axi_NNZWB_arburst[`getvec(2,0)]),
        .m_axi_NNZ_arlock(axi_NNZWB_arlock[`getvec(1,0)]),
        .m_axi_NNZ_arcache(axi_NNZWB_arcache[`getvec(4,0)]),
        .m_axi_NNZ_arprot(axi_NNZWB_arprot[`getvec(3,0)]),
        .m_axi_NNZ_arqos(axi_NNZWB_arqos[`getvec(4,0)]),
        .m_axi_NNZ_arvalid(axi_NNZWB_arvalid[`getvec(1,0)]),
        .m_axi_NNZ_arready(axi_NNZWB_arready[`getvec(1,0)]),
        .m_axi_NNZ_rid(axi_NNZWB_rid[`getvec(2,0)]),
        .m_axi_NNZ_rdata(axi_NNZWB_rdata[`getvec(256,0)]),
        .m_axi_NNZ_rresp(axi_NNZWB_rresp[`getvec(2,0)]),
        .m_axi_NNZ_rlast(axi_NNZWB_rlast[`getvec(1,0)]),
        .m_axi_NNZ_rvalid(axi_NNZWB_rvalid[`getvec(1,0)]),
        .m_axi_NNZ_rready(axi_NNZWB_rready[`getvec(1,0)]),


        //colIndex Buffer
        .Kernel1_m_axi_colIndex_arid(axi_demux_Col_arid[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_araddr(axi_demux_Col_araddr[`getvec(48,0)]),
        .Kernel1_m_axi_colIndex_arlen(axi_demux_Col_arlen[`getvec(8,0)]),
        .Kernel1_m_axi_colIndex_arsize(axi_demux_Col_arsize[`getvec(3,0)]),
        .Kernel1_m_axi_colIndex_arburst(axi_demux_Col_arburst[`getvec(2,0)]),
        .Kernel1_m_axi_colIndex_arlock(axi_demux_Col_arlock[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_arcache(axi_demux_Col_arcache[`getvec(4,0)]),
        .Kernel1_m_axi_colIndex_arprot(axi_demux_Col_arprot[`getvec(3,0)]),
        .Kernel1_m_axi_colIndex_arqos(axi_demux_Col_arqos[`getvec(4,0)]),
        .Kernel1_m_axi_colIndex_arvalid(axi_demux_Col_arvalid[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_arready(axi_demux_Col_arready[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_rid(axi_demux_Col_rid[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_rdata(axi_demux_Col_rdata[`getvec(32,0)]),
        .Kernel1_m_axi_colIndex_rresp(axi_demux_Col_rresp[`getvec(2,0)]),
        .Kernel1_m_axi_colIndex_rlast(axi_demux_Col_rlast[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_rvalid(axi_demux_Col_rvalid[`getvec(1,0)]),
        .Kernel1_m_axi_colIndex_rready(axi_demux_Col_rready[`getvec(1,0)]),

        //Xi Buffer
        .Kernel1_m_axi_Xi_arid(axi_bl_ker_arid[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_araddr(axi_bl_ker_araddr[`getvec(48,0)]),
        .Kernel1_m_axi_Xi_arlen(axi_bl_ker_arlen[`getvec(8,0)]),
        .Kernel1_m_axi_Xi_arsize(axi_bl_ker_arsize[`getvec(3,0)]),
        .Kernel1_m_axi_Xi_arburst(axi_bl_ker_arburst[`getvec(2,0)]),
        .Kernel1_m_axi_Xi_arlock(axi_bl_ker_arlock[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_arcache(axi_bl_ker_arcache[`getvec(4,0)]),
        .Kernel1_m_axi_Xi_arprot(axi_bl_ker_arprot[`getvec(3,0)]),
        .Kernel1_m_axi_Xi_arqos(axi_bl_ker_arqos[`getvec(4,0)]),
        .Kernel1_m_axi_Xi_arvalid(axi_bl_ker_arvalid[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_arready(axi_bl_ker_arready[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_rid(axi_bl_ker_rid[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_rdata(axi_bl_ker_rdata[`getvec(64,0)]),
        .Kernel1_m_axi_Xi_rresp(axi_bl_ker_rresp[`getvec(2,0)]),
        .Kernel1_m_axi_Xi_rlast(axi_bl_ker_rlast[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_rvalid(axi_bl_ker_rvalid[`getvec(1,0)]),
        .Kernel1_m_axi_Xi_rready(axi_bl_ker_rready[`getvec(1,0)]),

        //colIndex Buffer
        .Kernel2_m_axi_colIndex_arid(axi_demux_Col_arid[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_araddr(axi_demux_Col_araddr[`getvec(48,1)]),
        .Kernel2_m_axi_colIndex_arlen(axi_demux_Col_arlen[`getvec(8,1)]),
        .Kernel2_m_axi_colIndex_arsize(axi_demux_Col_arsize[`getvec(3,1)]),
        .Kernel2_m_axi_colIndex_arburst(axi_demux_Col_arburst[`getvec(2,1)]),
        .Kernel2_m_axi_colIndex_arlock(axi_demux_Col_arlock[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_arcache(axi_demux_Col_arcache[`getvec(4,1)]),
        .Kernel2_m_axi_colIndex_arprot(axi_demux_Col_arprot[`getvec(3,1)]),
        .Kernel2_m_axi_colIndex_arqos(axi_demux_Col_arqos[`getvec(4,1)]),
        .Kernel2_m_axi_colIndex_arvalid(axi_demux_Col_arvalid[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_arready(axi_demux_Col_arready[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_rid(axi_demux_Col_rid[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_rdata(axi_demux_Col_rdata[`getvec(32,1)]),
        .Kernel2_m_axi_colIndex_rresp(axi_demux_Col_rresp[`getvec(2,1)]),
        .Kernel2_m_axi_colIndex_rlast(axi_demux_Col_rlast[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_rvalid(axi_demux_Col_rvalid[`getvec(1,1)]),
        .Kernel2_m_axi_colIndex_rready(axi_demux_Col_rready[`getvec(1,1)]),

        //Xi Buffer
        .Kernel2_m_axi_Xi_arid(axi_bl_ker_arid[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_araddr(axi_bl_ker_araddr[`getvec(48,1)]),
        .Kernel2_m_axi_Xi_arlen(axi_bl_ker_arlen[`getvec(8,1)]),
        .Kernel2_m_axi_Xi_arsize(axi_bl_ker_arsize[`getvec(3,1)]),
        .Kernel2_m_axi_Xi_arburst(axi_bl_ker_arburst[`getvec(2,1)]),
        .Kernel2_m_axi_Xi_arlock(axi_bl_ker_arlock[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_arcache(axi_bl_ker_arcache[`getvec(4,1)]),
        .Kernel2_m_axi_Xi_arprot(axi_bl_ker_arprot[`getvec(3,1)]),
        .Kernel2_m_axi_Xi_arqos(axi_bl_ker_arqos[`getvec(4,1)]),
        .Kernel2_m_axi_Xi_arvalid(axi_bl_ker_arvalid[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_arready(axi_bl_ker_arready[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_rid(axi_bl_ker_rid[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_rdata(axi_bl_ker_rdata[`getvec(64,1)]),
        .Kernel2_m_axi_Xi_rresp(axi_bl_ker_rresp[`getvec(2,1)]),
        .Kernel2_m_axi_Xi_rlast(axi_bl_ker_rlast[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_rvalid(axi_bl_ker_rvalid[`getvec(1,1)]),
        .Kernel2_m_axi_Xi_rready(axi_bl_ker_rready[`getvec(1,1)]),

        //colIndex Buffer
        .Kernel3_m_axi_colIndex_arid(axi_demux_Col_arid[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_araddr(axi_demux_Col_araddr[`getvec(48,2)]),
        .Kernel3_m_axi_colIndex_arlen(axi_demux_Col_arlen[`getvec(8,2)]),
        .Kernel3_m_axi_colIndex_arsize(axi_demux_Col_arsize[`getvec(3,2)]),
        .Kernel3_m_axi_colIndex_arburst(axi_demux_Col_arburst[`getvec(2,2)]),
        .Kernel3_m_axi_colIndex_arlock(axi_demux_Col_arlock[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_arcache(axi_demux_Col_arcache[`getvec(4,2)]),
        .Kernel3_m_axi_colIndex_arprot(axi_demux_Col_arprot[`getvec(3,2)]),
        .Kernel3_m_axi_colIndex_arqos(axi_demux_Col_arqos[`getvec(4,2)]),
        .Kernel3_m_axi_colIndex_arvalid(axi_demux_Col_arvalid[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_arready(axi_demux_Col_arready[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_rid(axi_demux_Col_rid[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_rdata(axi_demux_Col_rdata[`getvec(32,2)]),
        .Kernel3_m_axi_colIndex_rresp(axi_demux_Col_rresp[`getvec(2,2)]),
        .Kernel3_m_axi_colIndex_rlast(axi_demux_Col_rlast[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_rvalid(axi_demux_Col_rvalid[`getvec(1,2)]),
        .Kernel3_m_axi_colIndex_rready(axi_demux_Col_rready[`getvec(1,2)]),

        //Xi Buffer
        .Kernel3_m_axi_Xi_arid(axi_bl_ker_arid[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_araddr(axi_bl_ker_araddr[`getvec(48,2)]),
        .Kernel3_m_axi_Xi_arlen(axi_bl_ker_arlen[`getvec(8,2)]),
        .Kernel3_m_axi_Xi_arsize(axi_bl_ker_arsize[`getvec(3,2)]),
        .Kernel3_m_axi_Xi_arburst(axi_bl_ker_arburst[`getvec(2,2)]),
        .Kernel3_m_axi_Xi_arlock(axi_bl_ker_arlock[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_arcache(axi_bl_ker_arcache[`getvec(4,2)]),
        .Kernel3_m_axi_Xi_arprot(axi_bl_ker_arprot[`getvec(3,2)]),
        .Kernel3_m_axi_Xi_arqos(axi_bl_ker_arqos[`getvec(4,2)]),
        .Kernel3_m_axi_Xi_arvalid(axi_bl_ker_arvalid[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_arready(axi_bl_ker_arready[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_rid(axi_bl_ker_rid[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_rdata(axi_bl_ker_rdata[`getvec(64,2)]),
        .Kernel3_m_axi_Xi_rresp(axi_bl_ker_rresp[`getvec(2,2)]),
        .Kernel3_m_axi_Xi_rlast(axi_bl_ker_rlast[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_rvalid(axi_bl_ker_rvalid[`getvec(1,2)]),
        .Kernel3_m_axi_Xi_rready(axi_bl_ker_rready[`getvec(1,2)]),

        //colIndex Buffer
        .Kernel4_m_axi_colIndex_arid(axi_demux_Col_arid[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_araddr(axi_demux_Col_araddr[`getvec(48,3)]),
        .Kernel4_m_axi_colIndex_arlen(axi_demux_Col_arlen[`getvec(8,3)]),
        .Kernel4_m_axi_colIndex_arsize(axi_demux_Col_arsize[`getvec(3,3)]),
        .Kernel4_m_axi_colIndex_arburst(axi_demux_Col_arburst[`getvec(2,3)]),
        .Kernel4_m_axi_colIndex_arlock(axi_demux_Col_arlock[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_arcache(axi_demux_Col_arcache[`getvec(4,3)]),
        .Kernel4_m_axi_colIndex_arprot(axi_demux_Col_arprot[`getvec(3,3)]),
        .Kernel4_m_axi_colIndex_arqos(axi_demux_Col_arqos[`getvec(4,3)]),
        .Kernel4_m_axi_colIndex_arvalid(axi_demux_Col_arvalid[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_arready(axi_demux_Col_arready[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_rid(axi_demux_Col_rid[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_rdata(axi_demux_Col_rdata[`getvec(32,3)]),
        .Kernel4_m_axi_colIndex_rresp(axi_demux_Col_rresp[`getvec(2,3)]),
        .Kernel4_m_axi_colIndex_rlast(axi_demux_Col_rlast[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_rvalid(axi_demux_Col_rvalid[`getvec(1,3)]),
        .Kernel4_m_axi_colIndex_rready(axi_demux_Col_rready[`getvec(1,3)]),

        //Xi Buffer
        .Kernel4_m_axi_Xi_arid(axi_bl_ker_arid[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_araddr(axi_bl_ker_araddr[`getvec(48,3)]),
        .Kernel4_m_axi_Xi_arlen(axi_bl_ker_arlen[`getvec(8,3)]),
        .Kernel4_m_axi_Xi_arsize(axi_bl_ker_arsize[`getvec(3,3)]),
        .Kernel4_m_axi_Xi_arburst(axi_bl_ker_arburst[`getvec(2,3)]),
        .Kernel4_m_axi_Xi_arlock(axi_bl_ker_arlock[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_arcache(axi_bl_ker_arcache[`getvec(4,3)]),
        .Kernel4_m_axi_Xi_arprot(axi_bl_ker_arprot[`getvec(3,3)]),
        .Kernel4_m_axi_Xi_arqos(axi_bl_ker_arqos[`getvec(4,3)]),
        .Kernel4_m_axi_Xi_arvalid(axi_bl_ker_arvalid[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_arready(axi_bl_ker_arready[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_rid(axi_bl_ker_rid[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_rdata(axi_bl_ker_rdata[`getvec(64,3)]),
        .Kernel4_m_axi_Xi_rresp(axi_bl_ker_rresp[`getvec(2,3)]),
        .Kernel4_m_axi_Xi_rlast(axi_bl_ker_rlast[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_rvalid(axi_bl_ker_rvalid[`getvec(1,3)]),
        .Kernel4_m_axi_Xi_rready(axi_bl_ker_rready[`getvec(1,3)]),

        .m_axi_Val_arid(axi_NNZWB_arid[`getvec(2,1)]),
        .m_axi_Val_araddr(axi_NNZWB_araddr[`getvec(48,1)]),
        .m_axi_Val_arlen(axi_NNZWB_arlen[`getvec(8,1)]),
        .m_axi_Val_arsize(axi_NNZWB_arsize[`getvec(3,1)]),
        .m_axi_Val_arburst(axi_NNZWB_arburst[`getvec(2,1)]),
        .m_axi_Val_arlock(axi_NNZWB_arlock[`getvec(1,1)]),
        .m_axi_Val_arcache(axi_NNZWB_arcache[`getvec(4,1)]),
        .m_axi_Val_arprot(axi_NNZWB_arprot[`getvec(3,1)]),
        .m_axi_Val_arqos(axi_NNZWB_arqos[`getvec(4,1)]),
        .m_axi_Val_arvalid(axi_NNZWB_arvalid[`getvec(1,1)]),
        .m_axi_Val_arready(axi_NNZWB_arready[`getvec(1,1)]),
        .m_axi_Val_rid(axi_NNZWB_rid[`getvec(2,1)]),
        .m_axi_Val_rdata(axi_NNZWB_rdata[`getvec(256,1)]),
        .m_axi_Val_rresp(axi_NNZWB_rresp[`getvec(2,1)]),
        .m_axi_Val_rlast(axi_NNZWB_rlast[`getvec(1,1)]),
        .m_axi_Val_rvalid(axi_NNZWB_rvalid[`getvec(1,1)]),
        .m_axi_Val_rready(axi_NNZWB_rready[`getvec(1,1)]),

        .m_axi_Yi_awid(axi_Yi_awid[`getvec(2,2)]),
        .m_axi_Yi_awaddr(axi_Yi_awaddr[`getvec(48,2)]),
        .m_axi_Yi_awlen(axi_Yi_awlen[`getvec(8,2)]),
        .m_axi_Yi_awsize(axi_Yi_awsize[`getvec(3,2)]),
        .m_axi_Yi_awburst(axi_Yi_awburst[`getvec(2,2)]),
        .m_axi_Yi_awlock(axi_Yi_awlock[`getvec(1,2)]),
        .m_axi_Yi_awcache(axi_Yi_awcache[`getvec(4,2)]),
        .m_axi_Yi_awprot(axi_Yi_awprot[`getvec(3,2)]),
        .m_axi_Yi_awqos(axi_Yi_awqos[`getvec(4,2)]),
        .m_axi_Yi_awvalid(axi_Yi_awvalid[`getvec(1,2)]),
        .m_axi_Yi_awready(axi_Yi_awready[`getvec(1,2)]),
        .m_axi_Yi_wdata(axi_Yi_wdata[`getvec(256,2)]),
        .m_axi_Yi_wstrb(axi_Yi_wstrb[`getvec(32,2)]),
        .m_axi_Yi_wlast(axi_Yi_wlast[`getvec(1,2)]),
        .m_axi_Yi_wvalid(axi_Yi_wvalid[`getvec(1,2)]),
        .m_axi_Yi_wready(axi_Yi_wready[`getvec(1,2)]),
        .m_axi_Yi_bid(axi_Yi_bid[`getvec(2,2)]),
        .m_axi_Yi_bresp(axi_Yi_bresp[`getvec(2,2)]),
        .m_axi_Yi_bvalid(axi_Yi_bvalid[`getvec(1,2)]),
        .m_axi_Yi_bready(axi_Yi_bready[`getvec(1,2)])

    );

    //连线
    Load_Balancer Load_Balancer(
        .clk(clk),
        .rstn(rstn),

        .Config_Port(config_wire[2:1]), 

        .s00_axi_arid(axi_bl_ker_arid[`getvec(1,0)]),
        .s00_axi_araddr(axi_bl_ker_araddr[`getvec(48,0)]),
        .s00_axi_arlen(axi_bl_ker_arlen[`getvec(8,0)]),
        .s00_axi_arsize(axi_bl_ker_arsize[`getvec(3,0)]),
        .s00_axi_arburst(axi_bl_ker_arburst[`getvec(2,0)]),
        .s00_axi_arlock(axi_bl_ker_arlock[`getvec(1,0)]),
        .s00_axi_arcache(axi_bl_ker_arcache[`getvec(4,0)]),
        .s00_axi_arprot(axi_bl_ker_arprot[`getvec(3,0)]),
        .s00_axi_arqos(axi_bl_ker_arqos[`getvec(4,0)]),
        .s00_axi_arvalid(axi_bl_ker_arvalid[`getvec(1,0)]),
        .s00_axi_arready(axi_bl_ker_arready[`getvec(1,0)]),
        .s00_axi_rid(axi_bl_ker_rid[`getvec(1,0)]),
        .s00_axi_rdata(axi_bl_ker_rdata[`getvec(64,0)]),
        .s00_axi_rresp(axi_bl_ker_rresp[`getvec(2,0)]),
        .s00_axi_rlast(axi_bl_ker_rlast[`getvec(1,0)]),
        .s00_axi_rvalid(axi_bl_ker_rvalid[`getvec(1,0)]),
        .s00_axi_rready(axi_bl_ker_rready[`getvec(1,0)]),

        .s01_axi_arid(axi_bl_ker_arid[`getvec(1,1)]),
        .s01_axi_araddr(axi_bl_ker_araddr[`getvec(48,1)]),
        .s01_axi_arlen(axi_bl_ker_arlen[`getvec(8,1)]),
        .s01_axi_arsize(axi_bl_ker_arsize[`getvec(3,1)]),
        .s01_axi_arburst(axi_bl_ker_arburst[`getvec(2,1)]),
        .s01_axi_arlock(axi_bl_ker_arlock[`getvec(1,1)]),
        .s01_axi_arcache(axi_bl_ker_arcache[`getvec(4,1)]),
        .s01_axi_arprot(axi_bl_ker_arprot[`getvec(3,1)]),
        .s01_axi_arqos(axi_bl_ker_arqos[`getvec(4,1)]),
        .s01_axi_arvalid(axi_bl_ker_arvalid[`getvec(1,1)]),
        .s01_axi_arready(axi_bl_ker_arready[`getvec(1,1)]),
        .s01_axi_rid(axi_bl_ker_rid[`getvec(1,1)]),
        .s01_axi_rdata(axi_bl_ker_rdata[`getvec(64,1)]),
        .s01_axi_rresp(axi_bl_ker_rresp[`getvec(2,1)]),
        .s01_axi_rlast(axi_bl_ker_rlast[`getvec(1,1)]),
        .s01_axi_rvalid(axi_bl_ker_rvalid[`getvec(1,1)]),
        .s01_axi_rready(axi_bl_ker_rready[`getvec(1,1)]),

        .s02_axi_arid(axi_bl_ker_arid[`getvec(1,2)]),
        .s02_axi_araddr(axi_bl_ker_araddr[`getvec(48,2)]),
        .s02_axi_arlen(axi_bl_ker_arlen[`getvec(8,2)]),
        .s02_axi_arsize(axi_bl_ker_arsize[`getvec(3,2)]),
        .s02_axi_arburst(axi_bl_ker_arburst[`getvec(2,2)]),
        .s02_axi_arlock(axi_bl_ker_arlock[`getvec(1,2)]),
        .s02_axi_arcache(axi_bl_ker_arcache[`getvec(4,2)]),
        .s02_axi_arprot(axi_bl_ker_arprot[`getvec(3,2)]),
        .s02_axi_arqos(axi_bl_ker_arqos[`getvec(4,2)]),
        .s02_axi_arvalid(axi_bl_ker_arvalid[`getvec(1,2)]),
        .s02_axi_arready(axi_bl_ker_arready[`getvec(1,2)]),
        .s02_axi_rid(axi_bl_ker_rid[`getvec(1,2)]),
        .s02_axi_rdata(axi_bl_ker_rdata[`getvec(64,2)]),
        .s02_axi_rresp(axi_bl_ker_rresp[`getvec(2,2)]),
        .s02_axi_rlast(axi_bl_ker_rlast[`getvec(1,2)]),
        .s02_axi_rvalid(axi_bl_ker_rvalid[`getvec(1,2)]),
        .s02_axi_rready(axi_bl_ker_rready[`getvec(1,2)]),

        .s03_axi_arid(axi_bl_ker_arid[`getvec(1,3)]),
        .s03_axi_araddr(axi_bl_ker_araddr[`getvec(48,3)]),
        .s03_axi_arlen(axi_bl_ker_arlen[`getvec(8,3)]),
        .s03_axi_arsize(axi_bl_ker_arsize[`getvec(3,3)]),
        .s03_axi_arburst(axi_bl_ker_arburst[`getvec(2,3)]),
        .s03_axi_arlock(axi_bl_ker_arlock[`getvec(1,3)]),
        .s03_axi_arcache(axi_bl_ker_arcache[`getvec(4,3)]),
        .s03_axi_arprot(axi_bl_ker_arprot[`getvec(3,3)]),
        .s03_axi_arqos(axi_bl_ker_arqos[`getvec(4,3)]),
        .s03_axi_arvalid(axi_bl_ker_arvalid[`getvec(1,3)]),
        .s03_axi_arready(axi_bl_ker_arready[`getvec(1,3)]),
        .s03_axi_rid(axi_bl_ker_rid[`getvec(1,3)]),
        .s03_axi_rdata(axi_bl_ker_rdata[`getvec(64,3)]),
        .s03_axi_rresp(axi_bl_ker_rresp[`getvec(2,3)]),
        .s03_axi_rlast(axi_bl_ker_rlast[`getvec(1,3)]),
        .s03_axi_rvalid(axi_bl_ker_rvalid[`getvec(1,3)]),
        .s03_axi_rready(axi_bl_ker_rready[`getvec(1,3)]),


        
        .m00_axi_araddr(axi_Switch_araddr[`getvec(48,2*0+1)]),
        .m00_axi_arlen(axi_Switch_arlen[`getvec(8,2*0+1)]),
        .m00_axi_arvalid(axi_Switch_arvalid[`getvec(1,2*0+1)]),
        .m00_axi_arready(axi_Switch_arready[`getvec(1,2*0+1)]),
        .m00_axi_rdata(axi_Switch_rdata[`getvec(64,2*0+1)]),
        .m00_axi_rresp(axi_Switch_rresp[`getvec(2,2*0+1)]),
        .m00_axi_rlast(axi_Switch_rlast[`getvec(1,2*0+1)]),
        .m00_axi_rvalid(axi_Switch_rvalid[`getvec(1,2*0+1)]),
        .m00_axi_rready(axi_Switch_rready[`getvec(1,2*0+1)]),

        .m01_axi_araddr(axi_Switch_araddr[`getvec(48,2*1+1)]),
        .m01_axi_arlen(axi_Switch_arlen[`getvec(8,2*1+1)]),
        .m01_axi_arvalid(axi_Switch_arvalid[`getvec(1,2*1+1)]),
        .m01_axi_arready(axi_Switch_arready[`getvec(1,2*1+1)]),
        .m01_axi_rdata(axi_Switch_rdata[`getvec(64,2*1+1)]),
        .m01_axi_rresp(axi_Switch_rresp[`getvec(2,2*1+1)]),
        .m01_axi_rlast(axi_Switch_rlast[`getvec(1,2*1+1)]),
        .m01_axi_rvalid(axi_Switch_rvalid[`getvec(1,2*1+1)]),
        .m01_axi_rready(axi_Switch_rready[`getvec(1,2*1+1)]),

        .m02_axi_araddr(axi_Switch_araddr[`getvec(48,2*2+1)]),
        .m02_axi_arlen(axi_Switch_arlen[`getvec(8,2*2+1)]),
        .m02_axi_arvalid(axi_Switch_arvalid[`getvec(1,2*2+1)]),
        .m02_axi_arready(axi_Switch_arready[`getvec(1,2*2+1)]),
        .m02_axi_rdata(axi_Switch_rdata[`getvec(64,2*2+1)]),
        .m02_axi_rresp(axi_Switch_rresp[`getvec(2,2*2+1)]),
        .m02_axi_rlast(axi_Switch_rlast[`getvec(1,2*2+1)]),
        .m02_axi_rvalid(axi_Switch_rvalid[`getvec(1,2*2+1)]),
        .m02_axi_rready(axi_Switch_rready[`getvec(1,2*2+1)]),
        
        .m03_axi_araddr(axi_Switch_araddr[`getvec(48,2*3+1)]),
        .m03_axi_arlen(axi_Switch_arlen[`getvec(8,2*3+1)]),
        .m03_axi_arvalid(axi_Switch_arvalid[`getvec(1,2*3+1)]),
        .m03_axi_arready(axi_Switch_arready[`getvec(1,2*3+1)]),
        .m03_axi_rdata(axi_Switch_rdata[`getvec(64,2*3+1)]),
        .m03_axi_rresp(axi_Switch_rresp[`getvec(2,2*3+1)]),
        .m03_axi_rlast(axi_Switch_rlast[`getvec(1,2*3+1)]),
        .m03_axi_rvalid(axi_Switch_rvalid[`getvec(1,2*3+1)]),
        .m03_axi_rready(axi_Switch_rready[`getvec(1,2*3+1)]),

        .Load_Balancer_ready()
    );

    generate for (genvar i = 0; i < 4; i++) begin
        axi_demux_r #(    
            .C_M_AXI_BURST_LEN(8),
            .C_M_AXI_ID_WIDTH(1),
            .C_M_AXI_ADDR_WIDTH(48),
            .C_S_AXI_DATA_WIDTH(32),
            .C_M_AXI_DATA_WIDTH(256)
        )axi_demux_r_inst(
        .clk(clk),
        .rstn(rstn),


        .m_axi_arid(axi_Col_arid[`getvec(1,i)]),          // input wire [1 : 0] m_axi_arid
        .m_axi_araddr(axi_Col_araddr[`getvec(48,i)]),      // input wire [65 : 0] m_axi_araddr
        .m_axi_arlen(axi_Col_arlen[`getvec(8,i)]),        // input wire [15 : 0] m_axi_arlen
        .m_axi_arsize(axi_Col_arsize[`getvec(6,i)]),      // input wire [5 : 0] m_axi_arsize
        .m_axi_arburst(axi_Col_arburst[`getvec(2,i)]),    // input wire [3 : 0] m_axi_arburst
        .m_axi_arlock(axi_Col_arlock[`getvec(1,i)]),      // input wire [1 : 0] m_axi_arlock
        .m_axi_arcache(axi_Col_arcache[`getvec(4,i)]),    // input wire [7 : 0] m_axi_arcache
        .m_axi_arprot(axi_Col_arprot[`getvec(3,i)]),      // input wire [5 : 0] m_axi_arprot
        .m_axi_arqos(axi_Col_arqos[`getvec(4,i)]),        // input wire [7 : 0] m_axi_arqos
        .m_axi_arvalid(axi_Col_arvalid[`getvec(1,i)]),    // input wire [1 : 0] m_axi_arvalid
        .m_axi_arready(axi_Col_arready[`getvec(1,i)]),    // output wire [1 : 0] m_axi_arready
        .m_axi_rid(axi_Col_rid[`getvec(1,i)]),            // output wire [1 : 0] m_axi_rid
        .m_axi_rdata(axi_Col_rdata[`getvec(256,i)]),        // output wire [511 : 0] m_axi_rdata
        .m_axi_rresp(axi_Col_rresp[`getvec(2,i)]),        // output wire [3 : 0] m_axi_rresp
        .m_axi_rlast(axi_Col_rlast[`getvec(1,i)]),        // output wire [1 : 0] m_axi_rlast
        .m_axi_rvalid(axi_Col_rvalid[`getvec(1,i)]),      // output wire [1 : 0] m_axi_rvalid
        .m_axi_rready(axi_Col_rready[`getvec(1,i)]),      // input wire [1 : 0] m_axi_rready



 //TODO 连线 axi demux 连线
        .s_axi_arid(axi_demux_Col_arid[`getvec(1,i)]),
        .s_axi_araddr(axi_demux_Col_araddr[`getvec(48,i)]),
        .s_axi_arlen(axi_demux_Col_arlen[`getvec(8,i)]),
        .s_axi_arsize(axi_demux_Col_arsize[`getvec(3,i)]),
        .s_axi_arburst(axi_demux_Col_arburst[`getvec(2,i)]),
        .s_axi_arlock(axi_demux_Col_arlock[`getvec(1,i)]),
        .s_axi_arcache(axi_demux_Col_arcache[`getvec(4,i)]),
        .s_axi_arprot(axi_demux_Col_arprot[`getvec(3,i)]),
        .s_axi_arqos(axi_demux_Col_arqos[`getvec(4,i)]),
        .s_axi_arvalid(axi_demux_Col_arvalid[`getvec(1,i)]),
        .s_axi_arready(axi_demux_Col_arready[`getvec(1,i)]),
        .s_axi_rid(axi_demux_Col_rid[`getvec(1,i)]),
        .s_axi_rdata(axi_demux_Col_rdata[`getvec(32,i)]),
        .s_axi_rresp(axi_demux_Col_rresp[`getvec(2,i)]),
        .s_axi_rlast(axi_demux_Col_rlast[`getvec(1,i)]),
        .s_axi_rvalid(axi_demux_Col_rvalid[`getvec(1,i)]),
        .s_axi_rready(axi_demux_Col_rready[`getvec(1,i)])
        );

    //改成 写Xi

        assign axi_Switch_araddr[`getvec(48,2*i)] = axi_Xi_bram_araddr[`getvec(48,i)];
//        assign axi_Switch_arburst[`getvec(2,2*i)] = axi_Xi_bram_arburst[`getvec(2,i)];
        assign axi_Switch_arlen[`getvec(8,2*i)] = axi_Xi_bram_arlen[`getvec(8,i)];
//        assign axi_Switch_arsize[`getvec(3,2*i)] = axi_Xi_bram_arsize[`getvec(3,i)];
        assign axi_Switch_arvalid[`getvec(1,2*i)] = axi_Xi_bram_arvalid[`getvec(1,i)];
        assign axi_Switch_awaddr[`getvec(48,2*i)] = axi_Xi_bram_awaddr[`getvec(48,i)];
//        assign axi_Switch_awburst[`getvec(2,2*i)] = axi_Xi_bram_awburst[`getvec(2,i)];
        assign axi_Switch_awlen[`getvec(8,2*i)] = axi_Xi_bram_awlen[`getvec(8,i)];
//        assign axi_Switch_awsize[`getvec(3,2*i)] = axi_Xi_bram_awsize[`getvec(3,i)];
        assign axi_Switch_awvalid[`getvec(1,2*i)] = axi_Xi_bram_awvalid[`getvec(1,i)];
        assign axi_Switch_rready[`getvec(1,2*i)] = axi_Xi_bram_rready[`getvec(1,i)];
        assign axi_Switch_bready[`getvec(1,2*i)] = axi_Xi_bram_bready[`getvec(1,i)];
        assign axi_Switch_wdata[`getvec(64,2*i)] = axi_Xi_bram_wdata[`getvec(64,i)];
        assign axi_Switch_wlast[`getvec(1,2*i)] = axi_Xi_bram_wlast[`getvec(1,i)];
        assign axi_Switch_wstrb[`getvec(8,2*i)] = axi_Xi_bram_wstrb[`getvec(8,i)];
        assign axi_Switch_wvalid[`getvec(1,2*i)] = axi_Xi_bram_wvalid[`getvec(1,i)];
        

        assign axi_Xi_bram_arready[`getvec(1,i)]=axi_Switch_arready[`getvec(1,2*i)];
        assign axi_Xi_bram_awready[`getvec(1,i)]=axi_Switch_awready[`getvec(1,2*i)];
        assign axi_Xi_bram_rdata[`getvec(64,i)]=axi_Switch_rdata[`getvec(64,2*i)];
        assign axi_Xi_bram_rlast[`getvec(1,i)]=axi_Switch_rlast[`getvec(1,2*i)];
        assign axi_Xi_bram_rresp[`getvec(2,i)]=axi_Switch_rresp[`getvec(2,2*i)];
        assign axi_Xi_bram_rvalid[`getvec(1,i)]=axi_Switch_rvalid[`getvec(1,2*i)];
        assign axi_Xi_bram_wready[`getvec(1,i)]=axi_Switch_wready[`getvec(1,2*i)];
        assign axi_Xi_bram_bresp[`getvec(2,i)]=axi_Switch_bresp[`getvec(2,2*i)];
        assign axi_Xi_bram_bvalid[`getvec(1,i)]=axi_Switch_bvalid[`getvec(1,2*i)];

        axi_switch #(
            .ADDR_WIDTH(48)
        )axi_switch (
            .s_aclk(clk),
            .s_aresetn(rstn),
            .CS(config_wire[8+:4]),

            .s_axi_awaddr(axi_Switch_awaddr[`getvec(48*2,i)]),
            .s_axi_awlen(axi_Switch_awlen[`getvec(8*2,i)]),
            .s_axi_awvalid(axi_Switch_awvalid[`getvec(1*2,i)]),
            .s_axi_awready(axi_Switch_awready[`getvec(1*2,i)]),
            .s_axi_wdata(axi_Switch_wdata[`getvec(64*2,i)]),
            .s_axi_wstrb(axi_Switch_wstrb[`getvec(8*2,i)]),
            .s_axi_wlast(axi_Switch_wlast[`getvec(1*2,i)]),
            .s_axi_wvalid(axi_Switch_wvalid[`getvec(1*2,i)]),
            .s_axi_wready(axi_Switch_wready[`getvec(1*2,i)]),
            .s_axi_bresp(axi_Switch_bresp[`getvec(2*2,i)]),
            .s_axi_bvalid(axi_Switch_bvalid[`getvec(1*2,i)]),
            .s_axi_bready(axi_Switch_bready[`getvec(1*2,i)]),
            .s_axi_araddr(axi_Switch_araddr[`getvec(48*2,i)]),
            .s_axi_arlen(axi_Switch_arlen[`getvec(8*2,i)]),
            .s_axi_arvalid(axi_Switch_arvalid[`getvec(1*2,i)]),
            .s_axi_arready(axi_Switch_arready[`getvec(1*2,i)]),
            .s_axi_rdata(axi_Switch_rdata[`getvec(64*2,i)]),
            .s_axi_rresp(axi_Switch_rresp[`getvec(2*2,i)]),
            .s_axi_rlast(axi_Switch_rlast[`getvec(1*2,i)]),
            .s_axi_rvalid(axi_Switch_rvalid[`getvec(1*2,i)]),
            .s_axi_rready(axi_Switch_rready[`getvec(1*2,i)]),

            .m_axi_awaddr(axi_Xi_awaddr[`getvec(48,i)]),    // input wire [31 : 0] s_axi_awaddr
            .m_axi_awlen(axi_Xi_awlen[`getvec(8,i)]),      // input wire [7 : 0] s_axi_awlen
            .m_axi_awvalid(axi_Xi_awvalid[`getvec(1,i)]),  // input wire s_axi_awvalid
            .m_axi_awready(axi_Xi_awready[`getvec(1,i)]),  // output wire s_axi_awready
            .m_axi_wdata(axi_Xi_wdata[`getvec(64,i)]),      // input wire [63 : 0] s_axi_wdata
            .m_axi_wstrb(axi_Xi_wstrb[`getvec(8,i)]),      // input wire [7 : 0] s_axi_wstrb
            .m_axi_wlast(axi_Xi_wlast[`getvec(1,i)]),      // input wire s_axi_wlast
            .m_axi_wvalid(axi_Xi_wvalid[`getvec(1,i)]),    // input wire s_axi_wvalid
            .m_axi_wready(axi_Xi_wready[`getvec(1,i)]),    // output wire s_axi_wready
            .m_axi_bresp(axi_Xi_bresp[`getvec(2,i)]),      // output wire [1 : 0] s_axi_bresp
            .m_axi_bvalid(axi_Xi_bvalid[`getvec(1,i)]),    // output wire s_axi_bvalid
            .m_axi_bready(axi_Xi_bready[`getvec(1,i)]),    // input wire s_axi_bready
            .m_axi_araddr(axi_Xi_araddr[`getvec(48,i)]),      // input wire [65 : 0] s_axi_araddr
            .m_axi_arlen(axi_Xi_arlen[`getvec(8,i)]),        // input wire [15 : 0] s_axi_arlen
            .m_axi_arvalid(axi_Xi_arvalid[`getvec(1,i)]),    // input wire [1 : 0] s_axi_arvalid
            .m_axi_arready(axi_Xi_arready[`getvec(1,i)]),    // output wire [1 : 0] s_axi_arready
            .m_axi_rdata(axi_Xi_rdata[`getvec(64,i)]),        // output wire [511 : 0] s_axi_rdata
            .m_axi_rresp(axi_Xi_rresp[`getvec(2,i)]),        // output wire [3 : 0] s_axi_rresp
            .m_axi_rlast(axi_Xi_rlast[`getvec(1,i)]),        // output wire [1 : 0] s_axi_rlast
            .m_axi_rvalid(axi_Xi_rvalid[`getvec(1,i)]),      // output wire [1 : 0] s_axi_rvalid
            .m_axi_rready(axi_Xi_rready[`getvec(1,i)])      // input wire [1 : 0] s_axi_rready,
        );
        Xi_Blk_Ram Xi_Blk_Ram (
        .rsta_busy(rsta_busy),          // output wire rsta_busy
        .rstb_busy(rstb_busy),          // output wire rstb_busy
        .s_aclk(clk),                // input wire s_aclk
        .s_aresetn(rstn),          // input wire s_aresetn
        
        .s_axi_awaddr(axi_Xi_awaddr[`getvec(48,i)]),    // input wire [31 : 0] s_axi_awaddr
        .s_axi_awlen(axi_Xi_awlen[`getvec(8,i)]),      // input wire [7 : 0] s_axi_awlen
        .s_axi_awvalid(axi_Xi_awvalid[`getvec(1,i)]),  // input wire s_axi_awvalid
        .s_axi_awready(axi_Xi_awready[`getvec(1,i)]),  // output wire s_axi_awready
        .s_axi_wdata(axi_Xi_wdata[`getvec(64,i)]),      // input wire [63 : 0] s_axi_wdata
        .s_axi_wstrb(axi_Xi_wstrb[`getvec(8,i)]),      // input wire [7 : 0] s_axi_wstrb
        .s_axi_wlast(axi_Xi_wlast[`getvec(1,i)]),      // input wire s_axi_wlast
        .s_axi_wvalid(axi_Xi_wvalid[`getvec(1,i)]),    // input wire s_axi_wvalid
        .s_axi_wready(axi_Xi_wready[`getvec(1,i)]),    // output wire s_axi_wready
        .s_axi_bresp(axi_Xi_bresp[`getvec(2,i)]),      // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid(axi_Xi_bvalid[`getvec(1,i)]),    // output wire s_axi_bvalid
        .s_axi_bready(axi_Xi_bready[`getvec(1,i)]),    // input wire s_axi_bready
        .s_axi_araddr(axi_Xi_araddr[`getvec(48,i)]),      // input wire [65 : 0] s_axi_araddr
        .s_axi_arlen(axi_Xi_arlen[`getvec(8,i)]),        // input wire [15 : 0] s_axi_arlen
        .s_axi_arvalid(axi_Xi_arvalid[`getvec(1,i)]),    // input wire [1 : 0] s_axi_arvalid
        .s_axi_arready(axi_Xi_arready[`getvec(1,i)]),    // output wire [1 : 0] s_axi_arready
        .s_axi_rdata(axi_Xi_rdata[`getvec(64,i)]),        // output wire [511 : 0] s_axi_rdata
        .s_axi_rresp(axi_Xi_rresp[`getvec(2,i)]),        // output wire [3 : 0] s_axi_rresp
        .s_axi_rlast(axi_Xi_rlast[`getvec(1,i)]),        // output wire [1 : 0] s_axi_rlast
        .s_axi_rvalid(axi_Xi_rvalid[`getvec(1,i)]),      // output wire [1 : 0] s_axi_rvalid
        .s_axi_rready(axi_Xi_rready[`getvec(1,i)])      // input wire [1 : 0] s_axi_rready,
        );




  end
  endgenerate
    // TODO 聚合 Col 
        axi_colxi_crossbar axi_colxi_crossbar (
        .aclk(clk),                      // input wire aclk
        .aresetn(rstn),                // input wire aresetn

        .s_axi_awid(2'b01),          // input wire [1 : 0] s_axi_awid
        .s_axi_awaddr(0),      // input wire [95 : 0] s_axi_awaddr
        .s_axi_awlen(0),        // input wire [15 : 0] s_axi_awlen
        .s_axi_awsize(0),      // input wire [5 : 0] s_axi_awsize
        .s_axi_awburst(0),    // input wire [3 : 0] s_axi_awburst
        .s_axi_awlock(0),      // input wire [1 : 0] s_axi_awlock
        .s_axi_awcache(0),    // input wire [7 : 0] s_axi_awcache
        .s_axi_awprot(0),      // input wire [5 : 0] s_axi_awprot
        .s_axi_awqos(0),        // input wire [7 : 0] s_axi_awqos
        .s_axi_awvalid(0),    // input wire [1 : 0] s_axi_awvalid
        .s_axi_wdata(0),        // input wire [511 : 0] s_axi_wdata
        .s_axi_wstrb(0),        // input wire [63 : 0] s_axi_wstrb
        .s_axi_wlast(0),        // input wire [1 : 0] s_axi_wlast
        .s_axi_wvalid(0),      // input wire [1 : 0] s_axi_wvalid
        .s_axi_bready(0),      // input wire [1 : 0] s_axi_bready

        .s_axi_arid(2'b01),          // input wire [1 : 0] s_axi_arid
        .s_axi_araddr(axi_Col_araddr),      // input wire [65 : 0] s_axi_araddr
        .s_axi_arlen(axi_Col_arlen),        // input wire [15 : 0] s_axi_arlen
        .s_axi_arsize(axi_Col_arsize),      // input wire [5 : 0] s_axi_arsize
        .s_axi_arburst(axi_Col_arburst),    // input wire [3 : 0] s_axi_arburst
        .s_axi_arlock(axi_Col_arlock),      // input wire [1 : 0] s_axi_arlock
        .s_axi_arcache(axi_Col_arcache),    // input wire [7 : 0] s_axi_arcache
        .s_axi_arprot(axi_Col_arprot),      // input wire [5 : 0] s_axi_arprot
        .s_axi_arqos(axi_Col_arqos),        // input wire [7 : 0] s_axi_arqos
        .s_axi_arvalid(axi_Col_arvalid),    // input wire [1 : 0] s_axi_arvalid
        .s_axi_arready(axi_Col_arready),    // output wire [1 : 0] s_axi_arready
        .s_axi_rid(axi_Col_rid),            // output wire [1 : 0] s_axi_rid
        .s_axi_rdata(axi_Col_rdata),        // output wire [511 : 0] s_axi_rdata
        .s_axi_rresp(axi_Col_rresp),        // output wire [3 : 0] s_axi_rresp
        .s_axi_rlast(axi_Col_rlast),        // output wire [1 : 0] s_axi_rlast
        .s_axi_rvalid(axi_Col_rvalid),      // output wire [1 : 0] s_axi_rvalid
        .s_axi_rready(axi_Col_rready),      // input wire [1 : 0] s_axi_rready,



        .m_axi_awaddr(m_axi_Col_awaddr),      // output wire [32 : 0] m_axi_awaddr
        .m_axi_awlen(m_axi_Col_awlen),        // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize(m_axi_Col_awsize),      // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst(m_axi_Col_awburst),    // output wire [1 : 0] m_axi_awburst
        .m_axi_awvalid(m_axi_Col_awvalid),    // output wire [0 : 0] m_axi_awvalid
        .m_axi_awready(m_axi_Col_awready),    // input wire [0 : 0] m_axi_awready
        .m_axi_wdata(m_axi_Col_wdata),        // output wire [255 : 0] m_axi_wdata
        .m_axi_wstrb(m_axi_Col_wstrb),        // output wire [31 : 0] m_axi_wstrb
        .m_axi_wlast(m_axi_Col_wlast),        // output wire [0 : 0] m_axi_wlast
        .m_axi_wvalid(m_axi_Col_wvalid),      // output wire [0 : 0] m_axi_wvalid
        .m_axi_wready(m_axi_Col_wready),      // input wire [0 : 0] m_axi_wready
        .m_axi_bresp(m_axi_Col_bresp),        // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid(m_axi_Col_bvalid),      // input wire [0 : 0] m_axi_bvalid
        .m_axi_bready(m_axi_Col_bready),      // output wire [0 : 0] m_axi_bready
        .m_axi_araddr(m_axi_Col_araddr),      // output wire [32 : 0] m_axi_araddr
        .m_axi_arlen(m_axi_Col_arlen),        // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize(m_axi_Col_arsize),      // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst(m_axi_Col_arburst),    // output wire [1 : 0] m_axi_arburst
        .m_axi_arvalid(m_axi_Col_arvalid),    // output wire [0 : 0] m_axi_arvalid
        .m_axi_arready(m_axi_Col_arready),    // input wire [0 : 0] m_axi_arready
        .m_axi_rdata(m_axi_Col_rdata),        // input wire [255 : 0] m_axi_rdata
        .m_axi_rresp(m_axi_Col_rresp),        // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast(m_axi_Col_rlast),        // input wire [0 : 0] m_axi_rlast
        .m_axi_rvalid(m_axi_Col_rvalid),      // input wire [0 : 0] m_axi_rvalid
        .m_axi_rready(m_axi_Col_rready)      // output wire [0 : 0] m_axi_rready

        // .m_axi_bid(1'b0),
        // .m_axi_rid(1'b0)
    );

    generate
        for(genvar i = 0;i<3;i++)begin
            if(i<2)begin
                assign axi_Yi_awid[`getvec(2,i)] = 0;
                assign axi_Yi_awaddr[`getvec(48,i)] = 0;
                assign axi_Yi_awlen[`getvec(8,i)] = 0;
                assign axi_Yi_awsize[`getvec(3,i)] = 0;
                assign axi_Yi_awburst[`getvec(2,i)] = 0;
                assign axi_Yi_awlock[`getvec(1,i)] = 0;
                assign axi_Yi_awcache[`getvec(4,i)] = 0;
                assign axi_Yi_awprot[`getvec(3,i)] = 0;
                assign axi_Yi_awqos[`getvec(4,i)] = 0;
                assign axi_Yi_awvalid[`getvec(1,i)] = 0;
                assign axi_Yi_wdata[`getvec(256,i)] = 0;
                assign axi_Yi_wstrb[`getvec(32,i)] = 0;
                assign axi_Yi_wlast[`getvec(1,i)] = 0;
                assign axi_Yi_wvalid[`getvec(1,i)] = 0;
                assign axi_Yi_bready[`getvec(1,i)] = 0;
            end
        end
    endgenerate
    generate
        for(genvar i = 0;i<3;i++)begin
            if(i>=2) begin
                assign axi_NNZWB_arid[`getvec(2,i)]=0;          // input wire [5 : 0] s_axi_arid
                assign axi_NNZWB_araddr[`getvec(48,i)]=0;      // input wire [98 : 0] s_axi_araddr
                assign axi_NNZWB_arlen[`getvec(8,i)]=0;        // input wire [23 : 0] s_axi_arlen
                assign axi_NNZWB_arsize[`getvec(3,i)]=0;      // input wire [8 : 0] s_axi_arsize
                assign axi_NNZWB_arburst[`getvec(2,i)]=0;    // input wire [5 : 0] s_axi_arburst
                assign axi_NNZWB_arlock[`getvec(1,i)]=0;      // input wire [2 : 0] s_axi_arlock
                assign axi_NNZWB_arcache[`getvec(4,i)]=0;    // input wire [11 : 0] s_axi_arcache
                assign axi_NNZWB_arprot[`getvec(3,i)]=0;      // input wire [8 : 0] s_axi_arprot
                assign axi_NNZWB_arqos[`getvec(4,i)]=0;        // input wire [11 : 0] s_axi_arqos
                assign axi_NNZWB_arvalid[`getvec(1,i)]=0;    // input wire [2 : 0] s_axi_arvalid
                assign axi_NNZWB_rready[`getvec(1,i)]=0;      // input wire [2 : 0] s_axi_rready

            end

        end
    endgenerate

    wire [1:0]  m_axi_Val_bid;
    wire [1:0]  m_axi_Val_rid;
    assign m_axi_Val_bid=0;
    assign m_axi_Val_rid=0;




    axi_bram_crossbar axi_bram_crossbar (
        .aclk(clk),                      // input wire aclk
        .aresetn(rstn),                // input wire aresetn
        
        .s_axi_awaddr(s_axi_Xi_bram_awaddr),      // input wire [47 : 0] s_axi_awaddr
        .s_axi_awlen(s_axi_Xi_bram_awlen),        // input wire [7 : 0] s_axi_awlen
        .s_axi_awsize(s_axi_Xi_bram_awsize),      // input wire [2 : 0] s_axi_awsize
        .s_axi_awburst(s_axi_Xi_bram_awburst),    // input wire [1 : 0] s_axi_awburst
        .s_axi_awvalid(s_axi_Xi_bram_awvalid),    // input wire [0 : 0] s_axi_awvalid
        .s_axi_awready(s_axi_Xi_bram_awready),    // output wire [0 : 0] s_axi_awready
        .s_axi_wdata(s_axi_Xi_bram_wdata),        // input wire [63 : 0] s_axi_wdata
        .s_axi_wstrb(s_axi_Xi_bram_wstrb),        // input wire [7 : 0] s_axi_wstrb
        .s_axi_wlast(s_axi_Xi_bram_wlast),        // input wire [0 : 0] s_axi_wlast
        .s_axi_wvalid(s_axi_Xi_bram_wvalid),      // input wire [0 : 0] s_axi_wvalid
        .s_axi_wready(s_axi_Xi_bram_wready),      // output wire [0 : 0] s_axi_wready
        .s_axi_bresp(s_axi_Xi_bram_bresp),        // output wire [1 : 0] s_axi_bresp
        .s_axi_bvalid(s_axi_Xi_bram_bvalid),      // output wire [0 : 0] s_axi_bvalid
        .s_axi_bready(s_axi_Xi_bram_bready),      // input wire [0 : 0] s_axi_bready
        .s_axi_araddr(s_axi_Xi_bram_araddr),      // input wire [47 : 0] s_axi_araddr
        .s_axi_arlen(s_axi_Xi_bram_arlen),        // input wire [7 : 0] s_axi_arlen
        .s_axi_arsize(s_axi_Xi_bram_arsize),      // input wire [2 : 0] s_axi_arsize
        .s_axi_arburst(s_axi_Xi_bram_arburst),    // input wire [1 : 0] s_axi_arburst
        .s_axi_arvalid(s_axi_Xi_bram_arvalid),    // input wire [0 : 0] s_axi_arvalid
        .s_axi_arready(s_axi_Xi_bram_arready),    // output wire [0 : 0] s_axi_arready
        .s_axi_rdata(s_axi_Xi_bram_rdata),        // output wire [63 : 0] s_axi_rdata
        .s_axi_rresp(s_axi_Xi_bram_rresp),        // output wire [1 : 0] s_axi_rresp
        .s_axi_rlast(s_axi_Xi_bram_rlast),        // output wire [0 : 0] s_axi_rlast
        .s_axi_rvalid(s_axi_Xi_bram_rvalid),      // output wire [0 : 0] s_axi_rvalid
        .s_axi_rready(s_axi_Xi_bram_rready),      // input wire [0 : 0] s_axi_rready
        
        .s_axi_awcache(s_axi_Xi_bram_awcache),
        .s_axi_awprot(s_axi_Xi_bram_awprot),
        .s_axi_awqos(s_axi_Xi_bram_awqos),
        .s_axi_awlock(s_axi_Xi_bram_awlock),
        .s_axi_arcache(s_axi_Xi_bram_arcache),
        .s_axi_arprot(s_axi_Xi_bram_arprot),
        .s_axi_arqos(s_axi_Xi_bram_arqos),
        .s_axi_arlock(s_axi_Xi_bram_arlock),

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


    axi_matwb_crossbar axi_matwb_crossbar (
        .aclk(clk),                      // input wire aclk
        .aresetn(rstn),                // input wire aresetn

        .s_axi_awid(axi_Yi_awid),          // input wire [5 : 0] s_axi_awid
        .s_axi_awaddr(axi_Yi_awaddr),      // input wire [98 : 0] s_axi_awaddr
        .s_axi_awlen(axi_Yi_awlen),        // input wire [23 : 0] s_axi_awlen
        .s_axi_awsize(axi_Yi_awsize),      // input wire [8 : 0] s_axi_awsize
        .s_axi_awburst(axi_Yi_awburst),    // input wire [5 : 0] s_axi_awburst
        .s_axi_awlock(axi_Yi_awlock),      // input wire [2 : 0] s_axi_awlock
        .s_axi_awcache(axi_Yi_awcache),    // input wire [11 : 0] s_axi_awcache
        .s_axi_awprot(axi_Yi_awprot),      // input wire [8 : 0] s_axi_awprot
        .s_axi_awqos(axi_Yi_awqos),        // input wire [11 : 0] s_axi_awqos
        .s_axi_awvalid(axi_Yi_awvalid),    // input wire [2 : 0] s_axi_awvalid
        .s_axi_awready(axi_Yi_awready),    // output wire [2 : 0] s_axi_awready
        .s_axi_wdata(axi_Yi_wdata),        // input wire [767 : 0] s_axi_wdata
        .s_axi_wstrb(axi_Yi_wstrb),        // input wire [95 : 0] s_axi_wstrb
        .s_axi_wlast(axi_Yi_wlast),        // input wire [2 : 0] s_axi_wlast
        .s_axi_wvalid(axi_Yi_wvalid),      // input wire [2 : 0] s_axi_wvalid
        .s_axi_wready(axi_Yi_wready),      // output wire [2 : 0] s_axi_wready
        .s_axi_bid(axi_Yi_bid),            // output wire [5 : 0] s_axi_bid
        .s_axi_bresp(axi_Yi_bresp),        // output wire [5 : 0] s_axi_bresp
        .s_axi_bvalid(axi_Yi_bvalid),      // output wire [2 : 0] s_axi_bvalid
        .s_axi_bready(axi_Yi_bready),      // input wire [2 : 0] s_axi_bready

        .s_axi_arid(axi_NNZWB_arid),          // input wire [5 : 0] s_axi_arid
        .s_axi_araddr(axi_NNZWB_araddr),      // input wire [98 : 0] s_axi_araddr
        .s_axi_arlen(axi_NNZWB_arlen),        // input wire [23 : 0] s_axi_arlen
        .s_axi_arsize(axi_NNZWB_arsize),      // input wire [8 : 0] s_axi_arsize
        .s_axi_arburst(axi_NNZWB_arburst),    // input wire [5 : 0] s_axi_arburst
        .s_axi_arlock(axi_NNZWB_arlock),      // input wire [2 : 0] s_axi_arlock
        .s_axi_arcache(axi_NNZWB_arcache),    // input wire [11 : 0] s_axi_arcache
        .s_axi_arprot(axi_NNZWB_arprot),      // input wire [8 : 0] s_axi_arprot
        .s_axi_arqos(axi_NNZWB_arqos),        // input wire [11 : 0] s_axi_arqos
        .s_axi_arvalid(axi_NNZWB_arvalid),    // input wire [2 : 0] s_axi_arvalid
        .s_axi_arready(axi_NNZWB_arready),    // output wire [2 : 0] s_axi_arready
        .s_axi_rid(axi_NNZWB_rid),            // output wire [5 : 0] s_axi_rid
        .s_axi_rdata(axi_NNZWB_rdata),        // output wire [767 : 0] s_axi_rdata
        .s_axi_rresp(axi_NNZWB_rresp),        // output wire [5 : 0] s_axi_rresp
        .s_axi_rlast(axi_NNZWB_rlast),        // output wire [2 : 0] s_axi_rlast
        .s_axi_rvalid(axi_NNZWB_rvalid),      // output wire [2 : 0] s_axi_rvalid
        .s_axi_rready(axi_NNZWB_rready),      // input wire [2 : 0] s_axi_rready


        .m_axi_awaddr(m_axi_Val_awaddr),      // output wire [32 : 0] m_axi_awaddr
        .m_axi_awlen(m_axi_Val_awlen),        // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize(m_axi_Val_awsize),      // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst(m_axi_Val_awburst),    // output wire [1 : 0] m_axi_awburst
        .m_axi_awvalid(m_axi_Val_awvalid),    // output wire [0 : 0] m_axi_awvalid
        .m_axi_awready(m_axi_Val_awready),    // input wire [0 : 0] m_axi_awready
        .m_axi_wdata(m_axi_Val_wdata),        // output wire [255 : 0] m_axi_wdata
        .m_axi_wstrb(m_axi_Val_wstrb),        // output wire [31 : 0] m_axi_wstrb
        .m_axi_wlast(m_axi_Val_wlast),        // output wire [0 : 0] m_axi_wlast
        .m_axi_wvalid(m_axi_Val_wvalid),      // output wire [0 : 0] m_axi_wvalid
        .m_axi_wready(m_axi_Val_wready),      // input wire [0 : 0] m_axi_wready
        .m_axi_bresp(m_axi_Val_bresp),        // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid(m_axi_Val_bvalid),      // input wire [0 : 0] m_axi_bvalid
        .m_axi_bready(m_axi_Val_bready),      // output wire [0 : 0] m_axi_bready
        .m_axi_araddr(m_axi_Val_araddr),      // output wire [32 : 0] m_axi_araddr
        .m_axi_arlen(m_axi_Val_arlen),        // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize(m_axi_Val_arsize),      // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst(m_axi_Val_arburst),    // output wire [1 : 0] m_axi_arburst
        .m_axi_arvalid(m_axi_Val_arvalid),    // output wire [0 : 0] m_axi_arvalid
        .m_axi_arready(m_axi_Val_arready),    // input wire [0 : 0] m_axi_arready
        .m_axi_rdata(m_axi_Val_rdata),        // input wire [255 : 0] m_axi_rdata
        .m_axi_rresp(m_axi_Val_rresp),        // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast(m_axi_Val_rlast),        // input wire [0 : 0] m_axi_rlast
        .m_axi_rvalid(m_axi_Val_rvalid),      // input wire [0 : 0] m_axi_rvalid
        .m_axi_rready(m_axi_Val_rready)      // output wire [0 : 0] m_axi_rready


        // .m_axi_bid(m_axi_Val_bid),
        // .m_axi_rid(m_axi_Val_rid)
);

endmodule