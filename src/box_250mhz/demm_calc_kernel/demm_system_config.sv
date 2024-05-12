`include "pcie_spmv_macros.vh"
`timescale 1ns/1ps
// 负责矩阵乘法的参数写入
module demm_system_config #(
    parameter int CTRL_OFFSET = 32'h00,
    parameter int M_OFFSET = 32'h04,
    parameter int N_OFFSET = 32'h08,
    parameter int K_OFFSET = 32'h08,
    
    parameter int CNT_LSB_OFFSET = 32'h0c,
    parameter int CNT_MSB_OFFSET = 32'h10

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



    output reg [32-1:0] ctrl_reg,
    output reg [32-1:0] M_num,
    output reg [32-1:0] N_num,
    output reg [32-1:0] K_num,

    input   [32*2-1:0] status_wire,


    input aclk,
    input aresetn
);
    wire                reg_en;
    wire                reg_we;
    wire         [9:0] reg_addr;
    wire         [31:0] reg_din;
    reg          [31:0] reg_dout;
    axi_lite_register #(
    .CLOCKING_MODE ("common_clock"),
    .ADDR_W        (10),
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


    // reg [32-1:0] ctrl_reg;
    // reg [32-1:0] M_num;
    // reg [32-1:0] N_num;
    // reg [32-1:0] K_num;
    

    wire [64-1:0] cnt_data;



    // assign config_wire[`getvec(32,0)] = ctrl_reg;
    // assign config_wire[`getvec(32,1)] = M_num;
    // assign config_wire[`getvec(32,2)] = N_num;
    // assign config_wire[`getvec(32,3)] = K_num;
    

    assign cnt_data[`getvec(64,0)] = status_wire[`getvec(64,0)];


    always @(posedge aclk ) begin
        if(~aresetn)begin
            reg_dout<=32'h0;
        end
        else if(reg_en&&~reg_we)begin
            if(reg_en&&~reg_we)begin
                case (reg_addr)
                    CTRL_OFFSET: begin
                        reg_dout<= ctrl_reg;
                    end
                    M_OFFSET:begin
                        reg_dout<= M_num;
                    end
                    N_OFFSET:begin
                        reg_dout<= N_num;
                    end
                    K_OFFSET:begin
                        reg_dout<= K_num;
                    end
                    
                    CNT_LSB_OFFSET:begin
                        reg_dout<=cnt_data[`getvec(32,0)];
                    end
                    CNT_MSB_OFFSET:begin
                        reg_dout<=cnt_data[`getvec(32,1)];
                    end
                    default:begin
                        reg_dout<= 32'hdeadbeef;
                    end 
                endcase    
            end  
        end
    end
    always @(posedge aclk ) begin
        if(~aresetn)begin
            ctrl_reg<=0;
            M_num<=0;
            N_num<=0;
            K_num<=0;
        end
        else if(reg_en&&reg_we)begin
            case (reg_addr)
                CTRL_OFFSET: begin
                    ctrl_reg<= reg_din;
                end
                M_OFFSET:begin
                    M_num<= reg_din;
                end
                N_OFFSET:begin
                    N_num<= reg_din;
                end
                K_OFFSET:begin
                    K_num<= reg_din;
                end
                default:begin
                    
                end 
            endcase
        end
    end
        
endmodule