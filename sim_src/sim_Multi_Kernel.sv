`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2023/07/31 18:12:00
// Design Name: 
// Module Name: sim_Multi_Kernel
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sim_Multi_Kernel #(
    parameter int CONF_NUM_KERNEL = 32'h4
)(
    
    );
    reg rstn;
    reg clk =0;
    reg [31:0] clkcnt=0;
    always #1 clk = ~clk;
    always @(posedge clk) begin
        clkcnt<=clkcnt+1;
    end

    reg                          s_axil_awvalid;
    reg                   [31:0] s_axil_awaddr;
    wire                         s_axil_awready;
    reg                          s_axil_wvalid;
    reg                   [31:0] s_axil_wdata;
    wire                         s_axil_wready;
    wire                         s_axil_bvalid;
    wire                   [1:0] s_axil_bresp;
    reg                          s_axil_bready;

    reg                          s_axil_arvalid;
    reg                   [31:0] s_axil_araddr;
    wire                         s_axil_arready;
    wire                         s_axil_rvalid;
    wire                  [31:0] s_axil_rdata;
    wire                   [1:0] s_axil_rresp;
    reg                          s_axil_rready;


  wire [(CONF_NUM_KERNEL*4+1)*48-1 : 0] axi_hbm_araddr;
  wire [(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_hbm_arburst;
  wire [(CONF_NUM_KERNEL*4+1)*8-1 : 0] axi_hbm_arlen;
  wire [(CONF_NUM_KERNEL*4+1)*3-1 : 0] axi_hbm_arsize;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0]axi_hbm_arvalid;
  wire [(CONF_NUM_KERNEL*4+1)*48-1 : 0] axi_hbm_awaddr;
  wire [(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_hbm_awburst;
  wire [(CONF_NUM_KERNEL*4+1)*8-1 : 0] axi_hbm_awlen;
  wire [(CONF_NUM_KERNEL*4+1)*3-1 : 0] axi_hbm_awsize;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_awvalid;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_rready;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_bready;
  wire [(CONF_NUM_KERNEL*4+1)*256-1 : 0] axi_hbm_wdata;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_wlast;
  wire [(CONF_NUM_KERNEL*4+1)*32-1 : 0] axi_hbm_wstrb;
  wire [(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_wvalid;
  wire[(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_arready;
  wire[(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_awready;
  wire[(CONF_NUM_KERNEL*4+1)*256-1 : 0] axi_hbm_rdata;
  wire[(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_rlast;
  wire[(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_hbm_rresp;
  wire[(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_rvalid;
  wire[(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_wready;
  wire[(CONF_NUM_KERNEL*4+1)*2-1 : 0] axi_hbm_bresp;
  wire[(CONF_NUM_KERNEL*4+1)*1-1 : 0] axi_hbm_bvalid;

    initial begin
        rstn <=0;
        s_axil_bready<=1;
        s_axil_wvalid<=0;
        s_axil_awvalid <= 0;

        #20
        rstn <=1;
        #1000
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 0;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'hffffffff;
        #2
        s_axil_wvalid<=0;
        #20
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 4;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'hffffffff;
        #2
        s_axil_wvalid<=0;
        #20
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 8;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'hffffffff;
        #2
        s_axil_wvalid<=0;
        #20
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 12;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'hffffffff;
        #2
        s_axil_wvalid<=0;

    end

    generate
        for(genvar i = 0;i<CONF_NUM_KERNEL*4+1 ;i = i+1)begin
            sim_blk_ram sim_blk_ram (
            .s_aclk(clk),                // input wire s_aclk
            .s_aresetn(rstn),          // input wire s_aresetn


                .s_axi_araddr(axi_hbm_araddr[i*48 +: 48]),
                .s_axi_arburst(axi_hbm_arburst[i*2 +: 2]),
                .s_axi_arlen(axi_hbm_arlen[i*8 +: 8]),
                .s_axi_arsize(axi_hbm_arsize[i*3 +: 3]),
                .s_axi_arvalid(axi_hbm_arvalid[i*1 +: 1]),
                .s_axi_awaddr(axi_hbm_awaddr[i*48 +: 48]),
                .s_axi_awburst(axi_hbm_awburst[i*2 +: 2]),
                .s_axi_awlen(axi_hbm_awlen[i*8 +: 8]),
                .s_axi_awsize(axi_hbm_awsize[i*3 +: 3]),
                .s_axi_awvalid(axi_hbm_awvalid[i*1 +: 1]),
                .s_axi_rready(axi_hbm_rready[i*1 +: 1]),
                .s_axi_bready(axi_hbm_bready[i*1 +: 1]),
                .s_axi_wdata(axi_hbm_wdata[i*256 +: 256]),
                .s_axi_wlast(axi_hbm_wlast[i*1 +: 1]),
                .s_axi_wstrb(axi_hbm_wstrb[i*32 +: 32]),
                .s_axi_wvalid(axi_hbm_wvalid[i*1 +: 1]),
                .s_axi_arready(axi_hbm_arready[i*1 +: 1]),
                .s_axi_awready(axi_hbm_awready[i*1 +: 1]),
                .s_axi_rdata(axi_hbm_rdata[i*256 +: 256]),
                .s_axi_rlast(axi_hbm_rlast[i*1 +: 1]),
                .s_axi_rresp(axi_hbm_rresp[i*2 +: 2]),
                .s_axi_rvalid(axi_hbm_rvalid[i*1 +: 1]),
                .s_axi_wready(axi_hbm_wready[i*1 +: 1]),
                .s_axi_bresp(axi_hbm_bresp[i*2 +: 2]),
                .s_axi_bvalid(axi_hbm_bvalid[i*1 +: 1])
            );
        end
    endgenerate


    spmv_calc_top spmv_calc_top(
        .clk(clk),
        .rstn(rstn),

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

         .m_axi_ColXi_araddr(axi_hbm_araddr[4*CONF_NUM_KERNEL*48-1:0]),
        .m_axi_ColXi_arburst(axi_hbm_arburst[4*CONF_NUM_KERNEL*2-1:0]),
        .m_axi_ColXi_arlen(axi_hbm_arlen[4*CONF_NUM_KERNEL*8-1:0]),
        .m_axi_ColXi_arsize(axi_hbm_arsize[4*CONF_NUM_KERNEL*3-1:0]),
        .m_axi_ColXi_arvalid(axi_hbm_arvalid[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_awaddr(axi_hbm_awaddr[4*CONF_NUM_KERNEL*48-1:0]),
        .m_axi_ColXi_awburst(axi_hbm_awburst[4*CONF_NUM_KERNEL*2-1:0]),
        .m_axi_ColXi_awlen(axi_hbm_awlen[4*CONF_NUM_KERNEL*8-1:0]),
        .m_axi_ColXi_awsize(axi_hbm_awsize[4*CONF_NUM_KERNEL*3-1:0]),
        .m_axi_ColXi_awvalid(axi_hbm_awvalid[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_rready(axi_hbm_rready[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_bready(axi_hbm_bready[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_wdata(axi_hbm_wdata[4*CONF_NUM_KERNEL*256-1:0]),
        .m_axi_ColXi_wlast(axi_hbm_wlast[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_wstrb(axi_hbm_wstrb[4*CONF_NUM_KERNEL*32-1:0]),
        .m_axi_ColXi_wvalid(axi_hbm_wvalid[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_arready(axi_hbm_arready[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_awready(axi_hbm_awready[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_rdata(axi_hbm_rdata[4*CONF_NUM_KERNEL*256-1:0]),
        .m_axi_ColXi_rlast(axi_hbm_rlast[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_rresp(axi_hbm_rresp[4*CONF_NUM_KERNEL*2-1:0]),
        .m_axi_ColXi_rvalid(axi_hbm_rvalid[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_wready(axi_hbm_wready[4*CONF_NUM_KERNEL*1-1:0]),
        .m_axi_ColXi_bresp(axi_hbm_bresp[4*CONF_NUM_KERNEL*2-1:0]),
        .m_axi_ColXi_bvalid(axi_hbm_bvalid[4*CONF_NUM_KERNEL*1-1:0]),

        .m_axi_hbm_Val_araddr(axi_hbm_araddr[(4*CONF_NUM_KERNEL)*48 +: 48]),
        .m_axi_hbm_Val_arburst(axi_hbm_arburst[(4*CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_arlen(axi_hbm_arlen[(4*CONF_NUM_KERNEL)*8 +: 8]),
        .m_axi_hbm_Val_arsize(axi_hbm_arsize[(4*CONF_NUM_KERNEL)*3 +: 3]),
        .m_axi_hbm_Val_arvalid(axi_hbm_arvalid[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_awaddr(axi_hbm_awaddr[(4*CONF_NUM_KERNEL)*48 +: 48]),
        .m_axi_hbm_Val_awburst(axi_hbm_awburst[(4*CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_awlen(axi_hbm_awlen[(4*CONF_NUM_KERNEL)*8 +: 8]),
        .m_axi_hbm_Val_awsize(axi_hbm_awsize[(4*CONF_NUM_KERNEL)*3 +: 3]),
        .m_axi_hbm_Val_awvalid(axi_hbm_awvalid[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rready(axi_hbm_rready[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_bready(axi_hbm_bready[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wdata(axi_hbm_wdata[(4*CONF_NUM_KERNEL)*256 +: 256]),
        .m_axi_hbm_Val_wlast(axi_hbm_wlast[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wstrb(axi_hbm_wstrb[(4*CONF_NUM_KERNEL)*32 +: 32]),
        .m_axi_hbm_Val_wvalid(axi_hbm_wvalid[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_arready(axi_hbm_arready[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_awready(axi_hbm_awready[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rdata(axi_hbm_rdata[(4*CONF_NUM_KERNEL)*256 +: 256]),
        .m_axi_hbm_Val_rlast(axi_hbm_rlast[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rresp(axi_hbm_rresp[(4*CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_rvalid(axi_hbm_rvalid[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wready(axi_hbm_wready[(4*CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_bresp(axi_hbm_bresp[(4*CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_bvalid(axi_hbm_bvalid[(4*CONF_NUM_KERNEL)*1 +: 1])

    );


endmodule
