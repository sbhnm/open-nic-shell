`include "open_nic_shell_macros.vh"
`timescale 1ns/1ps
// 负责矩阵乘法的参数写入
module spmv_system_config #(
    parameter int CONF_NUM_KERNEL = 32'h4,
    parameter int CTRL_OFFSET = 32'h00,
    parameter int ROW_OFFSET = 32'h04,
    parameter int NNZ_OFFSET = 32'h08,

    parameter int PER_ADDR_SPACE = 32'd12

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

    output [32*3*CONF_NUM_KERNEL-1:0] config_wire,

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


    reg [32*CONF_NUM_KERNEL-1:0] ctrl_reg;
    reg [32*CONF_NUM_KERNEL-1:0] row_num;
    reg [32*CONF_NUM_KERNEL-1:0] nnz_num;



  generate for (genvar i = 0; i < CONF_NUM_KERNEL; i++) begin
    
    assign config_wire[`getvec(32,3*i)] = ctrl_reg[`getvec(32,i)];
    assign config_wire[`getvec(32,3*i+1)] = row_num[`getvec(32,i)];
    assign config_wire[`getvec(32,3*i+2)] = nnz_num[`getvec(32,i)];

  end
  endgenerate

    always @(posedge aclk ) begin
        if(~aresetn)begin
            reg_dout<=32'h0;
        end
        else if(reg_en&&~reg_we)begin
            if(reg_en&&~reg_we)begin
                if(reg_addr>= 0 *PER_ADDR_SPACE && reg_addr < CONF_NUM_KERNEL *PER_ADDR_SPACE)begin
                    for (int i = 0; i < CONF_NUM_KERNEL; i++) begin
                        if(reg_addr>= i *PER_ADDR_SPACE && reg_addr < i *PER_ADDR_SPACE +PER_ADDR_SPACE)begin //在地址范围内
                            case (reg_addr - i *12)
                                CTRL_OFFSET: begin
                                    reg_dout<= ctrl_reg[`getvec(32,i)];
                                end
                                ROW_OFFSET:begin
                                    reg_dout<= row_num[`getvec(32,i)];
                                end
                                NNZ_OFFSET:begin
                                    reg_dout<= nnz_num[`getvec(32,i)];
                                end
                                default:begin
                                    reg_dout<= 32'hdeadbeef;
                                end 
                            endcase
                        end
                    end
                end
                else begin
                    reg_dout<=32'hdeadbeef;
                end
                
            end  
        end
    end
    always @(posedge clk ) begin
        if(~aresetn)begin
            ctrl_reg<=0;
            row_num<=0;
            nnz_num<=0;
        end
        else if(reg_en&&reg_we)begin
            if(reg_addr>= 0 *PER_ADDR_SPACE && reg_addr < CONF_NUM_KERNEL *PER_ADDR_SPACE)begin
                    for (int i = 0; i < CONF_NUM_KERNEL; i++) begin
                        if(reg_addr>= i *PER_ADDR_SPACE && reg_addr < i *PER_ADDR_SPACE +PER_ADDR_SPACE)begin //在地址范围内
                            case (reg_addr - i *12)
                                CTRL_OFFSET: begin
                                    ctrl_reg[`getvec(32,i)]<= reg_din;
                                end
                                ROW_OFFSET:begin
                                    row_num[`getvec(32,i)]<= reg_din;
                                end
                                NNZ_OFFSET:begin
                                    nnz_num[`getvec(32,i)]<= reg_din;
                                end
                                default:begin
                                    
                                end 
                            endcase
                        end
                    end
                end
        end
    end
endmodule