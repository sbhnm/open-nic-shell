`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
// 负责矩阵乘法的参数写入
module spmv_vector_loader #(
    parameter int CONF_BASE_ADDR = 32'h0,
    parameter int CONF_HBM_LOADER_MODE_OFFSET = 32'h00,
    parameter int CONF_HBM_BASE_ADDR_OFFSET = 32'h08,
    parameter int CONF_HBM_NOW_ADDR_OFFSET = 32'h08,

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

    input aclk,
    input aresetn
);
    
    reg [63:0] config_hbm_base_addr;
    reg [63:0] config_hbm_now_addr;
    reg [31:0] config_mode_reg;
    wire loader_mode;
    assign loader_mode = config_mode_reg[0];
    wire rw_mode;
    assign rw_mode =  config_mode_reg[1];
    wire                reg_en;
    wire                reg_we;
    wire         [31:0] reg_addr;
    wire         [31:0] reg_din;
    reg          [31:0] reg_dout;
    axi_lite_register #(
    .CLOCKING_MODE ("common_clock"),
    .ADDR_W        (32),
    .DATA_W        (32)
  ) axil_reg_inst (
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

    .reg_en         (reg_en),
    .reg_we         (reg_we),
    .reg_addr       (reg_addr),
    .reg_din        (reg_din),
    .reg_dout       (reg_dout),

    .axil_aclk      (aclk),
    .axil_aresetn   (aresetn),
    .reg_clk        (aclk),
    .reg_rstn       (aresetn)
  );

    // 控制寄存器逻辑
    always @(posedge clk ) begin
        if(~rstn)begin
            reg_dout<=32'h0;
        end
        else if(reg_en&&~reg_we)begin
            case (reg_addr[3:0])
                (CONF_HBM_LOADER_MODE_OFFSET): reg_dout<= config_mode_reg;
                (CONF_HBM_BASE_ADDR_OFFSET): reg_dout<= config_hbm_base_addr[`getvec(32, 0)];
                (CONF_HBM_BASE_ADDR_OFFSET+32'h04): reg_dout<= config_hbm_base_addr[`getvec(32, 1)];
                (CONF_HBM_NOW_ADDR_OFFSET): reg_dout<= config_hbm_now_addr[`getvec(32, 0)];
                (CONF_HBM_NOW_ADDR_OFFSET+32'h04): reg_dout<= config_hbm_now_addr[`getvec(32, 1)];
                default: reg_dout <= 32'hDEADADDE;
            endcase
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            config_mode_reg<=32'h0;
        end
        else if(reg_en && reg_we && reg_addr[3:0] == CONF_HBM_LOADER_MODE_OFFSET)begin
            config_mode_reg <= reg_din;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            config_hbm_base_addr<=32'h0;
        end
        else if(reg_en && reg_we)begin
            case (reg_addr[3:0])
                (CONF_HBM_BASE_ADDR_OFFSET) : config_hbm_base_addr[`getvec(32, 0)] <=reg_din;
                (CONF_HBM_BASE_ADDR_OFFSET+32'h04) : config_hbm_base_addr[`getvec(32, 1)] <=reg_din;
                default: config_hbm_base_addr<=config_hbm_base_addr;
            endcase
        end
    end


    always @(posedge clk ) begin
        if(~rstn)begin
            config_hbm_now_addr<=0;
        end
        else if()begin//waddr 在传输时步进 ，优先处理步进请求
            
        end
        else if(reg_en && reg_we)begin
            case (reg_addr[3:0])
                (CONF_HBM_BASE_ADDR_OFFSET) : config_hbm_now_addr[`getvec(32, 0)] <=reg_din;
                (CONF_HBM_BASE_ADDR_OFFSET+32'h04) : config_hbm_now_addr[`getvec(32, 1)] <=reg_din;
                default: config_hbm_now_addr<= config_hbm_now_addr;
            endcase
        end

    end

    
endmodule