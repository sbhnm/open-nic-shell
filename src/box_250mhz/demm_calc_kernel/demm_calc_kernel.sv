module demm_calc_kernel #(
    parameter integer ISSUE_NUM = 4,
    parameter integer B_BASE_ADDR = 0,
    parameter integer A_BASE_ADDR = 32'h1000_0000,
    
    
) (
    input wire calc_begin,
    output wire calc_end,


    input wire [32-1:0] M_num,
    input wire [32-1:0] N_num,
    input wire [32-1:0] K_num,
    
    input wire clk,
    input wire rstn,

    axi4.master m_axi_A,
    axi4.master m_axi_B,
    axi4.master m_axi_Out
    
);
    reg [32-1:0] now_mat_row_A;
    reg [32-1:0] now_mat_row_B;
    reg [32-1:0] now_mat_col;



    always @(posedge clk) begin
        if(~rstn)begin
            now_mat_row_A<=0;
            now_mat_row_B<=0;
            now_mat_col<=0;
        end
        else begin
            if()
        end

    end
        
    dma_k_issue #(
        .ISSUE_NUM(ISSUE_NUM)
    )dma_k_issue_A(
        .clk(clk),
        .rstn(rstn),

    );
    dma_k_issue #(
        .ISSUE_NUM(ISSUE_NUM)
    )dma_k_issue_B(
        .clk(clk),
        .rstn(rstn),
        .in_per_issue_num(M_num * K_num),
        .in_legal_lenth(M_num * K_num * 2),
        .in_base_addr(B_BASE_ADDR),
        
    );

    generate for(genvar i = 0;i<ISSUE_NUM;i++)begin
        demm_kernel demm_kernel(
            .clk(clk),
            .rstn(rstn),
            .times_num(M_num / ISSUE_NUM),

        );
    end
    endgenerate
    

    



endmodule