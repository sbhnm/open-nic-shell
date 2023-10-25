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
    output [4*48-1 : 0] m_axi_ColXi_araddr,
    output [4*2-1 : 0] m_axi_ColXi_arburst,
    output [4*8-1 : 0] m_axi_ColXi_arlen,
    output [4*3-1 : 0] m_axi_ColXi_arsize,
    output [4*1-1 : 0]m_axi_ColXi_arvalid,
    output [4*48-1 : 0] m_axi_ColXi_awaddr,
    output [4*2-1 : 0] m_axi_ColXi_awburst,
    output [4*8-1 : 0] m_axi_ColXi_awlen,
    output [4*3-1 : 0] m_axi_ColXi_awsize,
    output [4*1-1 : 0] m_axi_ColXi_awvalid,
    output [4*1-1 : 0] m_axi_ColXi_rready,
    output [4*1-1 : 0] m_axi_ColXi_bready,
    output [4*256-1 : 0] m_axi_ColXi_wdata,
    output [4*1-1 : 0] m_axi_ColXi_wlast,
    output [4*32-1 : 0] m_axi_ColXi_wstrb,
    output [4*1-1 : 0] m_axi_ColXi_wvalid,
    input [4*1-1 : 0] m_axi_ColXi_arready,
    input [4*1-1 : 0] m_axi_ColXi_awready,
    input [4*256-1 : 0] m_axi_ColXi_rdata,
    input [4*1-1 : 0] m_axi_ColXi_rlast,
    input [4*2-1 : 0] m_axi_ColXi_rresp,
    input [4*1-1 : 0] m_axi_ColXi_rvalid,
    input [4*1-1 : 0] m_axi_ColXi_wready,
    input [4*2-1 : 0] m_axi_ColXi_bresp,
    input [4*1-1 : 0] m_axi_ColXi_bvalid,


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

    input clk,
    input rstn

);
    wire [3:0] axi_Xi_Width_arregion;
    wire [8*1-1 : 0]        axi_Xi_Col_arid;
    wire [8*48-1 : 0]       axi_Xi_Col_araddr;
    wire [8*8-1 : 0]        axi_Xi_Col_arlen;
    wire [8*6-1 : 0]        axi_Xi_Col_arsize;
    wire [8*2-1 : 0]        axi_Xi_Col_arburst;
    wire [8*1-1:0]          axi_Xi_Col_arlock;
    wire [8*4-1 : 0]        axi_Xi_Col_arcache;
    wire [8*3-1 : 0]        axi_Xi_Col_arprot;
    wire [8*4-1 : 0]        axi_Xi_Col_arqos;
    wire [8*1-1:0]          axi_Xi_Col_arvalid;
    wire [8*1-1:0]          axi_Xi_Col_arready;
    wire [8*1-1 : 0]        axi_Xi_Col_rid;
    wire [8*256-1 : 0]       axi_Xi_Col_rdata;
    wire [8*2-1 : 0]        axi_Xi_Col_rresp;
    wire [8*1-1:0]          axi_Xi_Col_rlast;
    wire [8*1-1:0]          axi_Xi_Col_rvalid;
    wire [8*1-1:0]          axi_Xi_Col_rready;

    
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

    wire [4*1-1 : 0]        axi_bl_wc_arid;
    wire [4*48-1 : 0]       axi_bl_wc_araddr;
    wire [4*8-1 : 0]        axi_bl_wc_arlen;
    wire [4*6-1 : 0]        axi_bl_wc_arsize;
    wire [4*2-1 : 0]        axi_bl_wc_arburst;
    wire [4*1-1:0]          axi_bl_wc_arlock;
    wire [4*4-1 : 0]        axi_bl_wc_arcache;
    wire [4*3-1 : 0]        axi_bl_wc_arprot;
    wire [4*4-1 : 0]        axi_bl_wc_arqos;
    wire [4*1-1:0]          axi_bl_wc_arvalid;
    wire [4*1-1:0]          axi_bl_wc_arready;
    wire [4*1-1 : 0]        axi_bl_wc_rid;
    wire [4*64-1 : 0]       axi_bl_wc_rdata;
    wire [4*2-1 : 0]        axi_bl_wc_rresp;
    wire [4*1-1:0]          axi_bl_wc_rlast;
    wire [4*1-1:0]          axi_bl_wc_rvalid;
    wire [4*1-1:0]          axi_bl_wc_rready;

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
        .Calc_End(),


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


        
        .m00_axi_arid(axi_bl_wc_arid[`getvec(1,0)]),
        .m00_axi_araddr(axi_bl_wc_araddr[`getvec(48,0)]),
        .m00_axi_arlen(axi_bl_wc_arlen[`getvec(8,0)]),
        .m00_axi_arsize(axi_bl_wc_arsize[`getvec(6,0)]),
        .m00_axi_arburst(axi_bl_wc_arburst[`getvec(2,0)]),
        .m00_axi_arlock(axi_bl_wc_arlock[`getvec(1,0)]),
        .m00_axi_arcache(axi_bl_wc_arcache[`getvec(4,0)]),
        .m00_axi_arprot(axi_bl_wc_arprot[`getvec(3,0)]),
        .m00_axi_arqos(axi_bl_wc_arqos[`getvec(4,0)]),
        .m00_axi_arvalid(axi_bl_wc_arvalid[`getvec(1,0)]),
        .m00_axi_arready(axi_bl_wc_arready[`getvec(1,0)]),
        .m00_axi_rid(axi_bl_wc_rid[`getvec(1,0)]),
        .m00_axi_rdata(axi_bl_wc_rdata[`getvec(64,0)]),
        .m00_axi_rresp(axi_bl_wc_rresp[`getvec(2,0)]),
        .m00_axi_rlast(axi_bl_wc_rlast[`getvec(1,0)]),
        .m00_axi_rvalid(axi_bl_wc_rvalid[`getvec(1,0)]),
        .m00_axi_rready(axi_bl_wc_rready[`getvec(1,0)]),

        .m01_axi_arid(axi_bl_wc_arid[`getvec(1,1)]),
        .m01_axi_araddr(axi_bl_wc_araddr[`getvec(48,1)]),
        .m01_axi_arlen(axi_bl_wc_arlen[`getvec(8,1)]),
        .m01_axi_arsize(axi_bl_wc_arsize[`getvec(6,1)]),
        .m01_axi_arburst(axi_bl_wc_arburst[`getvec(2,1)]),
        .m01_axi_arlock(axi_bl_wc_arlock[`getvec(1,1)]),
        .m01_axi_arcache(axi_bl_wc_arcache[`getvec(4,1)]),
        .m01_axi_arprot(axi_bl_wc_arprot[`getvec(3,1)]),
        .m01_axi_arqos(axi_bl_wc_arqos[`getvec(4,1)]),
        .m01_axi_arvalid(axi_bl_wc_arvalid[`getvec(1,1)]),
        .m01_axi_arready(axi_bl_wc_arready[`getvec(1,1)]),
        .m01_axi_rid(axi_bl_wc_rid[`getvec(1,1)]),
        .m01_axi_rdata(axi_bl_wc_rdata[`getvec(64,1)]),
        .m01_axi_rresp(axi_bl_wc_rresp[`getvec(2,1)]),
        .m01_axi_rlast(axi_bl_wc_rlast[`getvec(1,1)]),
        .m01_axi_rvalid(axi_bl_wc_rvalid[`getvec(1,1)]),
        .m01_axi_rready(axi_bl_wc_rready[`getvec(1,1)]),

        .m02_axi_arid(axi_bl_wc_arid[`getvec(1,2)]),
        .m02_axi_araddr(axi_bl_wc_araddr[`getvec(48,2)]),
        .m02_axi_arlen(axi_bl_wc_arlen[`getvec(8,2)]),
        .m02_axi_arsize(axi_bl_wc_arsize[`getvec(6,2)]),
        .m02_axi_arburst(axi_bl_wc_arburst[`getvec(2,2)]),
        .m02_axi_arlock(axi_bl_wc_arlock[`getvec(1,2)]),
        .m02_axi_arcache(axi_bl_wc_arcache[`getvec(4,2)]),
        .m02_axi_arprot(axi_bl_wc_arprot[`getvec(3,2)]),
        .m02_axi_arqos(axi_bl_wc_arqos[`getvec(4,2)]),
        .m02_axi_arvalid(axi_bl_wc_arvalid[`getvec(1,2)]),
        .m02_axi_arready(axi_bl_wc_arready[`getvec(1,2)]),
        .m02_axi_rid(axi_bl_wc_rid[`getvec(1,2)]),
        .m02_axi_rdata(axi_bl_wc_rdata[`getvec(64,2)]),
        .m02_axi_rresp(axi_bl_wc_rresp[`getvec(2,2)]),
        .m02_axi_rlast(axi_bl_wc_rlast[`getvec(1,2)]),
        .m02_axi_rvalid(axi_bl_wc_rvalid[`getvec(1,2)]),
        .m02_axi_rready(axi_bl_wc_rready[`getvec(1,2)]),
        
        .m03_axi_arid(axi_bl_wc_arid[`getvec(1,3)]),
        .m03_axi_araddr(axi_bl_wc_araddr[`getvec(48,3)]),
        .m03_axi_arlen(axi_bl_wc_arlen[`getvec(8,3)]),
        .m03_axi_arsize(axi_bl_wc_arsize[`getvec(6,3)]),
        .m03_axi_arburst(axi_bl_wc_arburst[`getvec(2,3)]),
        .m03_axi_arlock(axi_bl_wc_arlock[`getvec(1,3)]),
        .m03_axi_arcache(axi_bl_wc_arcache[`getvec(4,3)]),
        .m03_axi_arprot(axi_bl_wc_arprot[`getvec(3,3)]),
        .m03_axi_arqos(axi_bl_wc_arqos[`getvec(4,3)]),
        .m03_axi_arvalid(axi_bl_wc_arvalid[`getvec(1,3)]),
        .m03_axi_arready(axi_bl_wc_arready[`getvec(1,3)]),
        .m03_axi_rid(axi_bl_wc_rid[`getvec(1,3)]),
        .m03_axi_rdata(axi_bl_wc_rdata[`getvec(64,3)]),
        .m03_axi_rresp(axi_bl_wc_rresp[`getvec(2,3)]),
        .m03_axi_rlast(axi_bl_wc_rlast[`getvec(1,3)]),
        .m03_axi_rvalid(axi_bl_wc_rvalid[`getvec(1,3)]),
        .m03_axi_rready(axi_bl_wc_rready[`getvec(1,3)]),

        .Load_Balancer_ready()
    );

    generate for (genvar i = 0; i < 4; i++) begin
        axi_demux_r #(    
            .C_M_AXI_BURST_LEN(2),
            .C_M_AXI_ID_WIDTH(1),
            .C_M_AXI_ADDR_WIDTH(48),
            .C_S_AXI_DATA_WIDTH(32),
            .C_M_AXI_DATA_WIDTH(256)
    )axi_demux_r(
        .clk(clk),
        .rstn(rstn),


        .m_axi_arid(axi_Xi_Col_arid[`getvec(1,2*i)]),          // input wire [1 : 0] m_axi_arid
        .m_axi_araddr(axi_Xi_Col_araddr[`getvec(48,2*i)]),      // input wire [65 : 0] m_axi_araddr
        .m_axi_arlen(axi_Xi_Col_arlen[`getvec(8,2*i)]),        // input wire [15 : 0] m_axi_arlen
        .m_axi_arsize(axi_Xi_Col_arsize[`getvec(6,2*i)]),      // input wire [5 : 0] m_axi_arsize
        .m_axi_arburst(axi_Xi_Col_arburst[`getvec(2,2*i)]),    // input wire [3 : 0] m_axi_arburst
        .m_axi_arlock(axi_Xi_Col_arlock[`getvec(1,2*i)]),      // input wire [1 : 0] m_axi_arlock
        .m_axi_arcache(axi_Xi_Col_arcache[`getvec(4,2*i)]),    // input wire [7 : 0] m_axi_arcache
        .m_axi_arprot(axi_Xi_Col_arprot[`getvec(3,2*i)]),      // input wire [5 : 0] m_axi_arprot
        .m_axi_arqos(axi_Xi_Col_arqos[`getvec(4,2*i)]),        // input wire [7 : 0] m_axi_arqos
        .m_axi_arvalid(axi_Xi_Col_arvalid[`getvec(1,2*i)]),    // input wire [1 : 0] m_axi_arvalid
        .m_axi_arready(axi_Xi_Col_arready[`getvec(1,2*i)]),    // output wire [1 : 0] m_axi_arready
        .m_axi_rid(axi_Xi_Col_rid[`getvec(1,2*i)]),            // output wire [1 : 0] m_axi_rid
        .m_axi_rdata(axi_Xi_Col_rdata[`getvec(256,2*i)]),        // output wire [511 : 0] m_axi_rdata
        .m_axi_rresp(axi_Xi_Col_rresp[`getvec(2,2*i)]),        // output wire [3 : 0] m_axi_rresp
        .m_axi_rlast(axi_Xi_Col_rlast[`getvec(1,2*i)]),        // output wire [1 : 0] m_axi_rlast
        .m_axi_rvalid(axi_Xi_Col_rvalid[`getvec(1,2*i)]),      // output wire [1 : 0] m_axi_rvalid
        .m_axi_rready(axi_Xi_Col_rready[`getvec(1,2*i)]),      // input wire [1 : 0] m_axi_rready



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


    axi_Xi_Width_Converter axi_Xi_Width_Converter (

        .s_axi_arregion(axi_Xi_Width_arregion),

        .s_axi_arid(axi_bl_wc_arid[`getvec(1,i)]),          // input wire [1 : 0] s_axi_arid
        .s_axi_araddr(axi_bl_wc_araddr[`getvec(48,i)]),      // input wire [65 : 0] s_axi_araddr
        .s_axi_arlen(axi_bl_wc_arlen[`getvec(8,i)]),        // input wire [15 : 0] s_axi_arlen
        .s_axi_arsize(axi_bl_wc_arsize[`getvec(6,i)]),      // input wire [5 : 0] s_axi_arsize
        .s_axi_arburst(axi_bl_wc_arburst[`getvec(2,i)]),    // input wire [3 : 0] s_axi_arburst
        .s_axi_arlock(axi_bl_wc_arlock[`getvec(1,i)]),      // input wire [1 : 0] s_axi_arlock
        .s_axi_arcache(axi_bl_wc_arcache[`getvec(4,i)]),    // input wire [7 : 0] s_axi_arcache
        .s_axi_arprot(axi_bl_wc_arprot[`getvec(3,i)]),      // input wire [5 : 0] s_axi_arprot
        .s_axi_arqos(axi_bl_wc_arqos[`getvec(4,i)]),        // input wire [7 : 0] s_axi_arqos
        .s_axi_arvalid(axi_bl_wc_arvalid[`getvec(1,i)]),    // input wire [1 : 0] s_axi_arvalid
        .s_axi_arready(axi_bl_wc_arready[`getvec(1,i)]),    // output wire [1 : 0] s_axi_arready
        .s_axi_rid(axi_bl_wc_rid[`getvec(1,i)]),            // output wire [1 : 0] s_axi_rid
        .s_axi_rdata(axi_bl_wc_rdata[`getvec(64,i)]),        // output wire [511 : 0] s_axi_rdata
        .s_axi_rresp(axi_bl_wc_rresp[`getvec(2,i)]),        // output wire [3 : 0] s_axi_rresp
        .s_axi_rlast(axi_bl_wc_rlast[`getvec(1,i)]),        // output wire [1 : 0] s_axi_rlast
        .s_axi_rvalid(axi_bl_wc_rvalid[`getvec(1,i)]),      // output wire [1 : 0] s_axi_rvalid
        .s_axi_rready(axi_bl_wc_rready[`getvec(1,i)]),      // input wire [1 : 0] s_axi_rready,

        // .m_axi_arid(axi_Xi_Col_arid[`getvec(1,2*i+1)]),          // input wire [1 : 0] m_axi_arid
        .m_axi_araddr(axi_Xi_Col_araddr[`getvec(48,2*i+1)]),      // input wire [65 : 0] m_axi_araddr
        .m_axi_arlen(axi_Xi_Col_arlen[`getvec(8,2*i+1)]),        // input wire [15 : 0] m_axi_arlen
        .m_axi_arsize(axi_Xi_Col_arsize[`getvec(6,2*i+1)]),      // input wire [5 : 0] m_axi_arsize
        .m_axi_arburst(axi_Xi_Col_arburst[`getvec(2,2*i+1)]),    // input wire [3 : 0] m_axi_arburst
        .m_axi_arlock(axi_Xi_Col_arlock[`getvec(1,2*i+1)]),      // input wire [1 : 0] m_axi_arlock
        .m_axi_arcache(axi_Xi_Col_arcache[`getvec(4,2*i+1)]),    // input wire [7 : 0] m_axi_arcache
        .m_axi_arprot(axi_Xi_Col_arprot[`getvec(3,2*i+1)]),      // input wire [5 : 0] m_axi_arprot
        .m_axi_arqos(axi_Xi_Col_arqos[`getvec(4,2*i+1)]),        // input wire [7 : 0] m_axi_arqos
        .m_axi_arvalid(axi_Xi_Col_arvalid[`getvec(1,2*i+1)]),    // input wire [1 : 0] m_axi_arvalid
        .m_axi_arready(axi_Xi_Col_arready[`getvec(1,2*i+1)]),    // output wire [1 : 0] m_axi_arready
        // .m_axi_rid(axi_Xi_Col_rid[`getvec(1,2*i+1)]),            // output wire [1 : 0] m_axi_rid
        .m_axi_rdata(axi_Xi_Col_rdata[`getvec(256,2*i+1)]),        // output wire [511 : 0] m_axi_rdata
        .m_axi_rresp(axi_Xi_Col_rresp[`getvec(2,2*i+1)]),        // output wire [3 : 0] m_axi_rresp
        .m_axi_rlast(axi_Xi_Col_rlast[`getvec(1,2*i+1)]),        // output wire [1 : 0] m_axi_rlast
        .m_axi_rvalid(axi_Xi_Col_rvalid[`getvec(1,2*i+1)]),      // output wire [1 : 0] m_axi_rvalid
        .m_axi_rready(axi_Xi_Col_rready[`getvec(1,2*i+1)]),      // input wire [1 : 0] m_axi_rready,

        .s_axi_aclk(clk),          // input wire s_axi_aclk
        .s_axi_aresetn(rstn)    // input wire s_axi_aresetn
        
        );
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
        .s_axi_araddr(axi_Xi_Col_araddr[`getvec(48*2,i)]),      // input wire [65 : 0] s_axi_araddr
        .s_axi_arlen(axi_Xi_Col_arlen[`getvec(8*2,i)]),        // input wire [15 : 0] s_axi_arlen
        .s_axi_arsize(axi_Xi_Col_arsize[`getvec(6*2,i)]),      // input wire [5 : 0] s_axi_arsize
        .s_axi_arburst(axi_Xi_Col_arburst[`getvec(2*2,i)]),    // input wire [3 : 0] s_axi_arburst
        .s_axi_arlock(axi_Xi_Col_arlock[`getvec(1*2,i)]),      // input wire [1 : 0] s_axi_arlock
        .s_axi_arcache(axi_Xi_Col_arcache[`getvec(4*2,i)]),    // input wire [7 : 0] s_axi_arcache
        .s_axi_arprot(axi_Xi_Col_arprot[`getvec(3*2,i)]),      // input wire [5 : 0] s_axi_arprot
        .s_axi_arqos(axi_Xi_Col_arqos[`getvec(4*2,i)]),        // input wire [7 : 0] s_axi_arqos
        .s_axi_arvalid(axi_Xi_Col_arvalid[`getvec(1*2,i)]),    // input wire [1 : 0] s_axi_arvalid
        .s_axi_arready(axi_Xi_Col_arready[`getvec(1*2,i)]),    // output wire [1 : 0] s_axi_arready
        .s_axi_rid(axi_Xi_Col_rid[`getvec(1*2,i)]),            // output wire [1 : 0] s_axi_rid
        .s_axi_rdata(axi_Xi_Col_rdata[`getvec(256*2,i)]),        // output wire [511 : 0] s_axi_rdata
        .s_axi_rresp(axi_Xi_Col_rresp[`getvec(2*2,i)]),        // output wire [3 : 0] s_axi_rresp
        .s_axi_rlast(axi_Xi_Col_rlast[`getvec(1*2,i)]),        // output wire [1 : 0] s_axi_rlast
        .s_axi_rvalid(axi_Xi_Col_rvalid[`getvec(1*2,i)]),      // output wire [1 : 0] s_axi_rvalid
        .s_axi_rready(axi_Xi_Col_rready[`getvec(1*2,i)]),      // input wire [1 : 0] s_axi_rready,



        .m_axi_awaddr(m_axi_ColXi_awaddr[`getvec(48,i)]),      // output wire [32 : 0] m_axi_awaddr
        .m_axi_awlen(m_axi_ColXi_awlen[`getvec(8,i)]),        // output wire [7 : 0] m_axi_awlen
        .m_axi_awsize(m_axi_ColXi_awsize[`getvec(3,i)]),      // output wire [2 : 0] m_axi_awsize
        .m_axi_awburst(m_axi_ColXi_awburst[`getvec(2,i)]),    // output wire [1 : 0] m_axi_awburst
        .m_axi_awvalid(m_axi_ColXi_awvalid[`getvec(1,i)]),    // output wire [0 : 0] m_axi_awvalid
        .m_axi_awready(m_axi_ColXi_awready[`getvec(1,i)]),    // input wire [0 : 0] m_axi_awready
        .m_axi_wdata(m_axi_ColXi_wdata[`getvec(256,i)]),        // output wire [255 : 0] m_axi_wdata
        .m_axi_wstrb(m_axi_ColXi_wstrb[`getvec(32,i)]),        // output wire [31 : 0] m_axi_wstrb
        .m_axi_wlast(m_axi_ColXi_wlast[`getvec(1,i)]),        // output wire [0 : 0] m_axi_wlast
        .m_axi_wvalid(m_axi_ColXi_wvalid[`getvec(1,i)]),      // output wire [0 : 0] m_axi_wvalid
        .m_axi_wready(m_axi_ColXi_wready[`getvec(1,i)]),      // input wire [0 : 0] m_axi_wready
        .m_axi_bresp(m_axi_ColXi_bresp[`getvec(2,i)]),        // input wire [1 : 0] m_axi_bresp
        .m_axi_bvalid(m_axi_ColXi_bvalid[`getvec(1,i)]),      // input wire [0 : 0] m_axi_bvalid
        .m_axi_bready(m_axi_ColXi_bready[`getvec(1,i)]),      // output wire [0 : 0] m_axi_bready
        .m_axi_araddr(m_axi_ColXi_araddr[`getvec(48,i)]),      // output wire [32 : 0] m_axi_araddr
        .m_axi_arlen(m_axi_ColXi_arlen[`getvec(8,i)]),        // output wire [7 : 0] m_axi_arlen
        .m_axi_arsize(m_axi_ColXi_arsize[`getvec(3,i)]),      // output wire [2 : 0] m_axi_arsize
        .m_axi_arburst(m_axi_ColXi_arburst[`getvec(2,i)]),    // output wire [1 : 0] m_axi_arburst
        .m_axi_arvalid(m_axi_ColXi_arvalid[`getvec(1,i)]),    // output wire [0 : 0] m_axi_arvalid
        .m_axi_arready(m_axi_ColXi_arready[`getvec(1,i)]),    // input wire [0 : 0] m_axi_arready
        .m_axi_rdata(m_axi_ColXi_rdata[`getvec(256,i)]),        // input wire [255 : 0] m_axi_rdata
        .m_axi_rresp(m_axi_ColXi_rresp[`getvec(2,i)]),        // input wire [1 : 0] m_axi_rresp
        .m_axi_rlast(m_axi_ColXi_rlast[`getvec(1,i)]),        // input wire [0 : 0] m_axi_rlast
        .m_axi_rvalid(m_axi_ColXi_rvalid[`getvec(1,i)]),      // input wire [0 : 0] m_axi_rvalid
        .m_axi_rready(m_axi_ColXi_rready[`getvec(1,i)])      // output wire [0 : 0] m_axi_rready

        // .m_axi_bid(1'b0),
        // .m_axi_rid(1'b0)
    );


  end
  endgenerate
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
            else begin
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