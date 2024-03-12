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
    parameter int CONF_NUM_KERNEL = 32'h1
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

    axi4 #(
        .ADDR_WIDTH(48),
        .DATA_WIDTH(256),
        .ID_WIDTH(1)) axi_Xi[CONF_NUM_KERNEL]();

  wire [(CONF_NUM_KERNEL+1)*48-1 : 0] axi_hbm_araddr;
  wire [(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_arburst;
  wire [(CONF_NUM_KERNEL+1)*8-1 : 0] axi_hbm_arlen;
  wire [(CONF_NUM_KERNEL+1)*3-1 : 0] axi_hbm_arsize;
  wire [(CONF_NUM_KERNEL+1)*1-1 : 0]axi_hbm_arvalid;
  wire [(CONF_NUM_KERNEL+1)*48-1 : 0] axi_hbm_awaddr;
  wire [(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_awburst;
  wire [(CONF_NUM_KERNEL+1)*8-1 : 0] axi_hbm_awlen;
  wire [(CONF_NUM_KERNEL+1)*3-1 : 0] axi_hbm_awsize;
  wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_awvalid;
  wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_rready;
  wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_bready;
  wire [(CONF_NUM_KERNEL+1)*256-1 : 0] axi_hbm_wdata;
  wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_wlast;
  wire [(CONF_NUM_KERNEL+1)*32-1 : 0] axi_hbm_wstrb;
  wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_wvalid;
  wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_arready;
  wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_awready;
  wire[(CONF_NUM_KERNEL+1)*256-1 : 0] axi_hbm_rdata;
  wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_rlast;
  wire[(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_rresp;
  wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_rvalid;
  wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_wready;
  wire[(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_bresp;
  wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_bvalid;

    initial begin
        rstn <=0;
        s_axil_bready<=1;
        s_axil_wvalid<=0;
        s_axil_awvalid <= 0;
        #20
        rstn <=1;
        #1000
        #20
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 0;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'h100;
        #2
        s_axil_wvalid<=0;

        s_axil_awvalid <= 1;
        s_axil_awaddr <= 4;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'h0080;
        #2
        s_axil_wvalid<=0;
        #20
        
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 8;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'haa00;
        #2
        s_axil_wvalid<=0;
        #20
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 0;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'h12b;
        #2
        s_axil_wvalid<=0;
        #20
        #4000

        s_axil_awvalid <= 1;
        s_axil_awaddr <= 0;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'b110101010; //reset
        #2
        s_axil_wvalid<=0;
        #20

        #200
        
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 0;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'b100101011;
        #2
        s_axil_wvalid<=0;
        #20

        s_axil_awvalid <= 1;
        s_axil_awaddr <= 4;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'h0080;
        #2
        s_axil_wvalid<=0;
        #20
        
        s_axil_awvalid <= 1;
        s_axil_awaddr <= 8;
        #2
        s_axil_awvalid<=0;
        s_axil_wvalid<=1;
        s_axil_wdata<=32'haa000;
        #2
        s_axil_wvalid<=0;
        // #20
        
    end

    generate
        for(genvar i = 0;i<CONF_NUM_KERNEL +1 ;i = i+1)begin
            sim_blk_ram sim_blk_ram (
            .s_aclk(clk),                // input wire s_aclk
            .s_aresetn(rstn),          // input wire s_aresetn

            .s_axi_arid(0),
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


    spmv_calc_top #(
        .CONF_NUM_KERNEL(CONF_NUM_KERNEL)
    )
        spmv_calc_top(
        .axil_clk(clk),
        .axis_clk(clk),
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

         .m_axi_Col_araddr(axi_hbm_araddr[CONF_NUM_KERNEL*48-1:0]),
        .m_axi_Col_arburst(axi_hbm_arburst[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_arlen(axi_hbm_arlen[CONF_NUM_KERNEL*8-1:0]),
        .m_axi_Col_arsize(axi_hbm_arsize[CONF_NUM_KERNEL*3-1:0]),
        .m_axi_Col_arvalid(axi_hbm_arvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_awaddr(axi_hbm_awaddr[CONF_NUM_KERNEL*48-1:0]),
        .m_axi_Col_awburst(axi_hbm_awburst[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_awlen(axi_hbm_awlen[CONF_NUM_KERNEL*8-1:0]),
        .m_axi_Col_awsize(axi_hbm_awsize[CONF_NUM_KERNEL*3-1:0]),
        .m_axi_Col_awvalid(axi_hbm_awvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_rready(axi_hbm_rready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_bready(axi_hbm_bready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_wdata(axi_hbm_wdata[CONF_NUM_KERNEL*256-1:0]),
        .m_axi_Col_wlast(axi_hbm_wlast[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_wstrb(axi_hbm_wstrb[CONF_NUM_KERNEL*32-1:0]),
        .m_axi_Col_wvalid(axi_hbm_wvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_arready(axi_hbm_arready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_awready(axi_hbm_awready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_rdata(axi_hbm_rdata[CONF_NUM_KERNEL*256-1:0]),
        .m_axi_Col_rlast(axi_hbm_rlast[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_rresp(axi_hbm_rresp[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_rvalid(axi_hbm_rvalid[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_wready(axi_hbm_wready[CONF_NUM_KERNEL*1-1:0]),
        .m_axi_Col_bresp(axi_hbm_bresp[CONF_NUM_KERNEL*2-1:0]),
        .m_axi_Col_bvalid(axi_hbm_bvalid[CONF_NUM_KERNEL*1-1:0]),

        .m_axi_hbm_Val_araddr(axi_hbm_araddr[(CONF_NUM_KERNEL)*48 +: 48]),
        .m_axi_hbm_Val_arburst(axi_hbm_arburst[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_arlen(axi_hbm_arlen[(CONF_NUM_KERNEL)*8 +: 8]),
        .m_axi_hbm_Val_arsize(axi_hbm_arsize[(CONF_NUM_KERNEL)*3 +: 3]),
        .m_axi_hbm_Val_arvalid(axi_hbm_arvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_awaddr(axi_hbm_awaddr[(CONF_NUM_KERNEL)*48 +: 48]),
        .m_axi_hbm_Val_awburst(axi_hbm_awburst[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_awlen(axi_hbm_awlen[(CONF_NUM_KERNEL)*8 +: 8]),
        .m_axi_hbm_Val_awsize(axi_hbm_awsize[(CONF_NUM_KERNEL)*3 +: 3]),
        .m_axi_hbm_Val_awvalid(axi_hbm_awvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rready(axi_hbm_rready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_bready(axi_hbm_bready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wdata(axi_hbm_wdata[(CONF_NUM_KERNEL)*256 +: 256]),
        .m_axi_hbm_Val_wlast(axi_hbm_wlast[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wstrb(axi_hbm_wstrb[(CONF_NUM_KERNEL)*32 +: 32]),
        .m_axi_hbm_Val_wvalid(axi_hbm_wvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_arready(axi_hbm_arready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_awready(axi_hbm_awready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rdata(axi_hbm_rdata[(CONF_NUM_KERNEL)*256 +: 256]),
        .m_axi_hbm_Val_rlast(axi_hbm_rlast[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_rresp(axi_hbm_rresp[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_rvalid(axi_hbm_rvalid[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_wready(axi_hbm_wready[(CONF_NUM_KERNEL)*1 +: 1]),
        .m_axi_hbm_Val_bresp(axi_hbm_bresp[(CONF_NUM_KERNEL)*2 +: 2]),
        .m_axi_hbm_Val_bvalid(axi_hbm_bvalid[(CONF_NUM_KERNEL)*1 +: 1]),

        .m_axi_Xi(axi_Xi)

    );

    // lru_way lru_way();
endmodule
