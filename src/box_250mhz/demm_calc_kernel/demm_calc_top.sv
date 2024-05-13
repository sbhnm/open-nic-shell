
module demm_calc_top #(
    
) (
    input axil_clk,
    input axis_clk,
    
    input  rstn,

    

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


    axi4.master m_axi_data[2]
    
);
    wire [32-1:0] ctrl_reg;
    wire [32-1:0] M_num;
    wire [32-1:0] N_num;
    wire [32-1:0] K_num;

    demm_system_config  #(
        
    )
    demm_system_config(
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

        .ctrl_reg(ctrl_reg),
        .M_num(M_num),
        .N_num(N_num),
        .K_num(K_num),
        
        .status_wire(status_wire),

        .aclk(axil_clk),
        .aresetn(rstn)
    );

    demm_calc_kernel #()
    demm_calc_kernel(
        
    );

endmodule