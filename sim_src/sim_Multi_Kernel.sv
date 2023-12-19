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
    parameter [31:0] BUILD_TIMESTAMP = 32'h01010000,
    parameter int    MIN_PKT_LEN     = 64,
    parameter int    MAX_PKT_LEN     = 1518,
    parameter int    USE_PHYS_FUNC   = 1,
    parameter int    NUM_PHYS_FUNC   = 1,
    parameter int    NUM_QUEUE       = 512,
    parameter int    NUM_CMAC_PORT   = 1,
    parameter int CONF_NUM_KERNEL = 32'h1

)(
    
    );
    reg rstn;
    reg axis_aclk =0;
    reg axil_aclk =0;
    
    reg [31:0] clkcnt=0;
    always #1 axis_aclk = ~axis_aclk;
    always #2 axil_aclk = ~axil_aclk;
    
    always @(posedge axis_aclk) begin
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


//   wire [(CONF_NUM_KERNEL+1)*48-1 : 0] axi_hbm_araddr;
//   wire [(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_arburst;
//   wire [(CONF_NUM_KERNEL+1)*8-1 : 0] axi_hbm_arlen;
//   wire [(CONF_NUM_KERNEL+1)*3-1 : 0] axi_hbm_arsize;
//   wire [(CONF_NUM_KERNEL+1)*1-1 : 0]axi_hbm_arvalid;
//   wire [(CONF_NUM_KERNEL+1)*48-1 : 0] axi_hbm_awaddr;
//   wire [(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_awburst;
//   wire [(CONF_NUM_KERNEL+1)*8-1 : 0] axi_hbm_awlen;
//   wire [(CONF_NUM_KERNEL+1)*3-1 : 0] axi_hbm_awsize;
//   wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_awvalid;
//   wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_rready;
//   wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_bready;
//   wire [(CONF_NUM_KERNEL+1)*256-1 : 0] axi_hbm_wdata;
//   wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_wlast;
//   wire [(CONF_NUM_KERNEL+1)*32-1 : 0] axi_hbm_wstrb;
//   wire [(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_wvalid;
//   wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_arready;
//   wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_awready;
//   wire[(CONF_NUM_KERNEL+1)*256-1 : 0] axi_hbm_rdata;
//   wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_rlast;
//   wire[(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_rresp;
//   wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_rvalid;
//   wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_wready;
//   wire[(CONF_NUM_KERNEL+1)*2-1 : 0] axi_hbm_bresp;
//   wire[(CONF_NUM_KERNEL+1)*1-1 : 0] axi_hbm_bvalid;
//     initial begin
//         rstn <=0;
//         #200
//         rstn<=1;
//     end



    // initial begin
    //     rstn <=0;
    //     s_axil_bready<=1;
    //     s_axil_wvalid<=0;
    //     s_axil_awvalid <= 0;
    //     #20
    //     rstn <=1;
    //     #200
    //     #20
    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 0;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'h100;
    //     #2
    //     s_axil_wvalid<=0;

    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 4;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'h0080;
    //     #2
    //     s_axil_wvalid<=0;
    //     #20
        
    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 8;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'haa00;
    //     #2
    //     s_axil_wvalid<=0;
    //     #20
    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 0;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'h12b;
    //     #2
    //     s_axil_wvalid<=0;
    //     #20
    //     #4000

    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 0;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'b110101010; //reset
    //     #2
    //     s_axil_wvalid<=0;
    //     #20

    //     #200
        
    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 0;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'b100101011;
    //     #2
    //     s_axil_wvalid<=0;
    //     #20

    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 4;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'h0080;
    //     #2
    //     s_axil_wvalid<=0;
    //     #20
        
    //     s_axil_awvalid <= 1;
    //     s_axil_awaddr <= 8;
    //     #2
    //     s_axil_awvalid<=0;
    //     s_axil_wvalid<=1;
    //     s_axil_wdata<=32'haa000;
    //     #2
    //     s_axil_wvalid<=0;
    //     // #20
        
    // end

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
    reg [1*48-1 : 0] s_axi_Xi_araddr = 0;
    reg [1*2-1 : 0] s_axi_Xi_arburst= 0;
    reg [1*8-1 : 0] s_axi_Xi_arlen= 0;
    reg [1*3-1 : 0] s_axi_Xi_arsize= 0;
    reg [1*1-1 : 0]s_axi_Xi_arvalid= 0;
    reg [1*48-1 : 0] s_axi_Xi_awaddr= 0;
    reg [1*2-1 : 0] s_axi_Xi_awburst= 1;
    reg [1*8-1 : 0] s_axi_Xi_awlen= 0;
    reg [1*3-1 : 0] s_axi_Xi_awsize= 0;
    reg [1*1-1 : 0] s_axi_Xi_awvalid= 0;
    reg [1*1-1 : 0] s_axi_Xi_rready= 0;
    reg [1*1-1 : 0] s_axi_Xi_bready= 0;
    reg [1*64-1 : 0] s_axi_Xi_wdata= 0;
    reg [1*1-1 : 0] s_axi_Xi_wlast= 0;
    reg [1*8-1 : 0] s_axi_Xi_wstrb= 8'hff;
    reg [1*1-1 : 0] s_axi_Xi_wvalid= 0;

    wire [1*1-1 : 0] s_axi_Xi_arready;
    wire [1*1-1 : 0] s_axi_Xi_awready;
    wire [1*64-1 : 0] s_axi_Xi_rdata;
    wire [1*1-1 : 0] s_axi_Xi_rlast;
    wire [1*2-1 : 0] s_axi_Xi_rresp;
    wire [1*1-1 : 0] s_axi_Xi_rvalid;
    wire [1*1-1 : 0] s_axi_Xi_wready;
    wire [1*2-1 : 0] s_axi_Xi_bresp;
    wire [1*1-1 : 0] s_axi_Xi_bvalid;

    reg [2:0] write_status = 0;
    initial begin
        s_axi_Xi_awlen<=8'hf;
        s_axi_Xi_awaddr<=0;

    end
    always @(posedge clk) begin
        if(clkcnt == 200)begin
            s_axi_Xi_awvalid <=1;
        end
        else if(s_axi_Xi_awready)begin
            s_axi_Xi_awvalid<=0;
            write_status<=1;
        end
    end
    
    always @(posedge clk) begin
        if(clkcnt == 200)begin
            s_axi_Xi_wvalid <=1;
            s_axi_Xi_bready<=1;
        end
    end

      box_250mhz #(
    .MIN_PKT_LEN   (MIN_PKT_LEN),
    .MAX_PKT_LEN   (MAX_PKT_LEN),
    .USE_PHYS_FUNC (USE_PHYS_FUNC),
    .NUM_PHYS_FUNC (NUM_PHYS_FUNC),
    .NUM_CMAC_PORT (NUM_CMAC_PORT),
    .CONF_NUM_KERNEL(CONF_NUM_KERNEL)
  ) box_250mhz_inst (
    // .s_axil_awvalid                   (axil_box0_awvalid),
    // .s_axil_awaddr                    (axil_box0_awaddr),
    // .s_axil_awready                   (axil_box0_awready),
    // .s_axil_wvalid                    (axil_box0_wvalid),
    // .s_axil_wdata                     (axil_box0_wdata),
    // .s_axil_wready                    (axil_box0_wready),
    // .s_axil_bvalid                    (axil_box0_bvalid),
    // .s_axil_bresp                     (axil_box0_bresp),
    // .s_axil_bready                    (axil_box0_bready),
    // .s_axil_arvalid                   (axil_box0_arvalid),
    // .s_axil_araddr                    (axil_box0_araddr),
    // .s_axil_arready                   (axil_box0_arready),
    // .s_axil_rvalid                    (axil_box0_rvalid),
    // .s_axil_rdata                     (axil_box0_rdata),
    // .s_axil_rresp                     (axil_box0_rresp),
    // .s_axil_rready                    (axil_box0_rready),


    // .m_axi_ker_araddr(axi_box_araddr),
    // .m_axi_ker_arburst(axi_box_arburst),
    // .m_axi_ker_arlen(axi_box_arlen),
    // .m_axi_ker_arsize(axi_box_arsize),
    // .m_axi_ker_arvalid(axi_box_arvalid),
    // .m_axi_ker_awaddr(axi_box_awaddr),
    // .m_axi_ker_awburst(axi_box_awburst),
    // .m_axi_ker_awlen(axi_box_awlen),
    // .m_axi_ker_awsize(axi_box_awsize),
    // .m_axi_ker_awvalid(axi_box_awvalid),
    // .m_axi_ker_rready(axi_box_rready),
    // .m_axi_ker_bready(axi_box_bready),
    // .m_axi_ker_wdata(axi_box_wdata),
    // .m_axi_ker_wlast(axi_box_wlast),
    // .m_axi_ker_wstrb(axi_box_wstrb),
    // .m_axi_ker_wvalid(axi_box_wvalid),
    // .m_axi_ker_arready(axi_box_arready),
    // .m_axi_ker_awready(axi_box_awready),
    // .m_axi_ker_rdata(axi_box_rdata),
    // .m_axi_ker_rlast(axi_box_rlast),
    // .m_axi_ker_rresp(axi_box_rresp),
    // .m_axi_ker_rvalid(axi_box_rvalid),
    // .m_axi_ker_wready(axi_box_wready),
    // .m_axi_ker_bresp(axi_box_bresp),
    // .m_axi_ker_bvalid(axi_box_bvalid),

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


    // .s_axis_qdma_h2c_tvalid           (axis_qdma_h2c_tvalid),
    // .s_axis_qdma_h2c_tdata            (axis_qdma_h2c_tdata),
    // .s_axis_qdma_h2c_tkeep            (axis_qdma_h2c_tkeep),
    // .s_axis_qdma_h2c_tlast            (axis_qdma_h2c_tlast),
    // .s_axis_qdma_h2c_tuser_size       (axis_qdma_h2c_tuser_size),
    // .s_axis_qdma_h2c_tuser_src        (axis_qdma_h2c_tuser_src),
    // .s_axis_qdma_h2c_tuser_dst        (axis_qdma_h2c_tuser_dst),
    // .s_axis_qdma_h2c_tready           (axis_qdma_h2c_tready),

    // .m_axis_qdma_c2h_tvalid           (axis_qdma_c2h_tvalid),
    // .m_axis_qdma_c2h_tdata            (axis_qdma_c2h_tdata),
    // .m_axis_qdma_c2h_tkeep            (axis_qdma_c2h_tkeep),
    // .m_axis_qdma_c2h_tlast            (axis_qdma_c2h_tlast),
    // .m_axis_qdma_c2h_tuser_size       (axis_qdma_c2h_tuser_size),
    // .m_axis_qdma_c2h_tuser_src        (axis_qdma_c2h_tuser_src),
    // .m_axis_qdma_c2h_tuser_dst        (axis_qdma_c2h_tuser_dst),
    // .m_axis_qdma_c2h_tready           (axis_qdma_c2h_tready),


    .mod_rstn                         (user_250mhz_rstn),
    .mod_rst_done                     (user_250mhz_rst_done),

    .box_rstn                         (box_250mhz_rstn),
    .box_rst_done                     (box_250mhz_rst_done),

    .axil_aclk                        (axil_aclk),
    .axis_aclk                        (axis_aclk)
  );


endmodule
