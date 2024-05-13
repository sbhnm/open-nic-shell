module axi_blk_ram #(
    parameter integer ADDR_WIDTH = 48,
    
    parameter integer DATA_WIDTH=64


)(
    input wire clk,
    input wire rstn,

    axi4.slave axi_port
);
    Xi_Blk_Ram sim_blk_ram (
        .rsta_busy(rsta_busy),          // output wire rsta_busy
        .rstb_busy(rstb_busy),          // output wire rstb_busy
        .s_aclk(clk),                // input wire s_aclk
        .s_aresetn(rstn),          // input wire s_aresetn
        .s_axi_awaddr(axi_port.AWADDR),
        .s_axi_awlen(axi_port.AWLEN),
        .s_axi_awvalid(axi_port.AWVALID),
        .s_axi_awready(axi_port.AWREADY),
        .s_axi_wdata(axi_port.WDATA),
        .s_axi_wstrb(axi_port.WSTRB),
        .s_axi_wlast(axi_port.WLAST),
        .s_axi_wvalid(axi_port.WVALID),
        .s_axi_wready(axi_port.WREADY),
        .s_axi_bresp(axi_port.BRESP),
        .s_axi_bvalid(axi_port.BVALID),
        .s_axi_bready(axi_port.BREADY),
        .s_axi_araddr(axi_port.ARADDR),
        .s_axi_arlen(axi_port.ARLEN),
        .s_axi_arvalid(axi_port.ARVALID),
        .s_axi_arready(axi_port.ARREADY),
        .s_axi_rdata(axi_port.RDATA),
        .s_axi_rresp(axi_port.RRESP),
        .s_axi_rlast(axi_port.RLAST),
        .s_axi_rvalid(axi_port.RVALID),
        .s_axi_rready(axi_port.RREADY)
        );

endmodule