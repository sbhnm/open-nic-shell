//多个master，通过选择线选择slave与那个master互联
//为什么不用 crossbar 可能对随机读写造成延迟

`include "pcie_spmv_macros.vh"
`include "system_ifc.vh"
`timescale 1ns/1ps
module axi_switch #(
    parameter  NUM_SLAVE =2,
    parameter  ADDR_WIDTH =32,
    parameter  DATA_WIDTH =64

) (
    input wire s_aclk,
    input wire s_aresetn,
    input wire [3:0] CS,

    input wire [ADDR_WIDTH *NUM_SLAVE -1: 0] s_axi_awaddr,
    input wire [8* NUM_SLAVE-1: 0] s_axi_awlen,
    input wire [NUM_SLAVE-1:0]  s_axi_awvalid,
    output reg [NUM_SLAVE-1:0] s_axi_awready,
    input wire [DATA_WIDTH*NUM_SLAVE-1 : 0] s_axi_wdata,
    input wire [DATA_WIDTH*NUM_SLAVE/8-1 : 0] s_axi_wstrb,
    input wire [NUM_SLAVE-1:0] s_axi_wlast,
    input wire [NUM_SLAVE-1:0] s_axi_wvalid,
    output reg [NUM_SLAVE-1:0] s_axi_wready,
    output reg [2*NUM_SLAVE-1 : 0] s_axi_bresp,
    output reg [NUM_SLAVE-1:0] s_axi_bvalid,
    input wire [NUM_SLAVE-1:0] s_axi_bready,
    input wire [ADDR_WIDTH * NUM_SLAVE -1 : 0] s_axi_araddr,
    input wire [8*NUM_SLAVE-1 : 0] s_axi_arlen,
    input wire [NUM_SLAVE-1:0] s_axi_arvalid,
    output reg [NUM_SLAVE-1:0] s_axi_arready,
    output reg [DATA_WIDTH * NUM_SLAVE -1: 0] s_axi_rdata,
    output reg [2*NUM_SLAVE-1 : 0] s_axi_rresp,
    output reg [NUM_SLAVE-1:0] s_axi_rlast,
    output reg [NUM_SLAVE-1:0] s_axi_rvalid,
    input wire [NUM_SLAVE-1:0] s_axi_rready,

    output reg [ADDR_WIDTH *1 -1: 0] m_axi_awaddr,
    output reg [8* 1-1: 0] m_axi_awlen,
    output reg [1-1:0]  m_axi_awvalid,
    input wire [1-1:0] m_axi_awready,
    output reg [DATA_WIDTH*1-1 : 0] m_axi_wdata,
    output reg [DATA_WIDTH*1/8-1 : 0] m_axi_wstrb,
    output reg [1-1:0] m_axi_wlast,
    output reg [1-1:0] m_axi_wvalid,
    input wire [1-1:0] m_axi_wready,
    input wire [2*1-1 : 0] m_axi_bresp,
    input wire [1-1:0] m_axi_bvalid,
    output reg [1-1:0] m_axi_bready,
    output reg [ADDR_WIDTH * 1 -1 : 0] m_axi_araddr,
    output reg [8*1-1 : 0] m_axi_arlen,
    output reg [1-1:0] m_axi_arvalid,
    input wire [1-1:0] m_axi_arready,
    input wire [DATA_WIDTH * 1 -1: 0] m_axi_rdata,
    input wire [2*1-1 : 0] m_axi_rresp,
    input wire [1-1:0] m_axi_rlast,
    input wire [1-1:0] m_axi_rvalid,
    output reg [1-1:0] m_axi_rready



);

integer i;
wire [3:0] CSD;
assign CSD = 1;
generate
always @* begin
    for (i = 0; i < NUM_SLAVE; i = i + 1) begin
        if (CS == i) begin
        // if (CSD == i) begin
            m_axi_awaddr= s_axi_awaddr[`getvec(ADDR_WIDTH,i)];
            m_axi_awlen=s_axi_awlen[`getvec(8,i)];
            m_axi_awvalid=s_axi_awvalid[`getvec(1,i)];
            m_axi_wdata=s_axi_wdata[`getvec(DATA_WIDTH,i)];
            m_axi_wstrb=s_axi_wstrb[`getvec(DATA_WIDTH/8,i)];
            m_axi_wlast=s_axi_wlast[`getvec(1,i)];
            m_axi_wvalid=s_axi_wvalid[`getvec(1,i)];
            m_axi_bready=s_axi_bready[`getvec(1,i)];
            m_axi_araddr=s_axi_araddr[`getvec(ADDR_WIDTH,i)];
            m_axi_arlen=s_axi_arlen[`getvec(8,i)];
            m_axi_arvalid=s_axi_arvalid[`getvec(1,i)];
            m_axi_rready=s_axi_rready[`getvec(1,i)];
        end
    end
end
endgenerate
generate

always @* begin

    for (i = 0; i < NUM_SLAVE; i = i + 1) begin
        if (CS == i) begin
        // if (CSD == i) begin
            s_axi_awready[`getvec(1,i)]=m_axi_awready;
            s_axi_wready[`getvec(1,i)]=m_axi_wready;
            s_axi_bresp[`getvec(2,i)]=m_axi_bresp;
            s_axi_bvalid[`getvec(1,i)]=m_axi_bvalid;
            s_axi_arready[`getvec(1,i)]=m_axi_arready;
            s_axi_rdata[`getvec(DATA_WIDTH,i)]=m_axi_rdata;
            s_axi_rresp[`getvec(2,i)]=m_axi_rresp;
            s_axi_rlast[`getvec(1,i)]=m_axi_rlast;
            s_axi_rvalid[`getvec(1,i)]=m_axi_rvalid;
        end
        else begin
            s_axi_awready[`getvec(1,i)]=0;
            s_axi_wready[`getvec(1,i)]=0;
            s_axi_bresp[`getvec(2,i)]=0;
            s_axi_bvalid[`getvec(1,i)]=0;
            s_axi_arready[`getvec(1,i)]=0;
            s_axi_rdata[`getvec(DATA_WIDTH,i)]=0;
            s_axi_rresp[`getvec(2,i)]=0;
            s_axi_rlast[`getvec(1,i)]=0;
            s_axi_rvalid[`getvec(1,i)]=0;
        end
    end
end
endgenerate
endmodule