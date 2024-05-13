module demm_calc_kernel #(
    parameter integer ISSUE_NUM = 4,
    parameter integer B_BASE_ADDR = 0,
    parameter integer A_BASE_ADDR = 32'h1000_0000,
    parameter integer Out_BASE_ADDR = 32'h2000_0000
    
    
) (
    input wire clk,
    input wire rstn,
    
    input wire calc_begin,
    output wire calc_end,


    input wire [32-1:0] M_num,
    input wire [32-1:0] N_num,
    input wire [32-1:0] K_num,
    


    axi4.master m_axi_A,
    axi4.master m_axi_B,
    axi4.master m_axi_Out
    
);
    reg [32-1:0] now_mat_row_A;
    reg [32-1:0] now_mat_row_B;
    // reg [32-1:0] now_mat_col;
    reg [32-1:0] A_ctrl_addr;
    reg [2:0] fsm_state;
    wire issue_B_req_ready;
    reg issue_B_req_valid;
    wire issue_A_req_ready;
    reg issue_A_req_valid;
    assign calc_end = fsm_state ==4;
    stream #( 16) A_issue_stream[ISSUE_NUM]();
    stream #( 16) B_issue_stream[ISSUE_NUM]();
    stream #( 16) Out_issue_stream[ISSUE_NUM]();
    stream #( 16) Out_stream();
    
    always @(posedge clk) begin
        if(~rstn)begin
            fsm_state<=0;
            issue_A_req_valid<=0;
            issue_B_req_valid<=0;
            
        end
        else begin
            if(fsm_state == 0)begin
                if(calc_begin)begin
                        fsm_state<=1;
                        now_mat_row_A<=0;
                        now_mat_row_B<=0;
                        A_ctrl_addr<=0;
                    end
                end
            if(fsm_state ==1)begin
                    if(issue_A_req_ready&~issue_A_req_valid)begin
                        issue_A_req_valid<=1;
                    end
                    else if(issue_A_req_valid & issue_A_req_ready)begin
                        issue_A_req_valid <=0;
                    end
                    if(issue_B_req_ready&~issue_B_req_valid)begin
                        issue_B_req_valid<=1;
                    end
                    else if(issue_B_req_valid & issue_B_req_ready)begin
                        issue_B_req_valid <=0;
                    end
                    if(~issue_A_req_ready & ~issue_B_req_valid) begin
                        fsm_state <=2;
                    end
                    
                end
                if(fsm_state == 2)begin
                    if(issue_A_req_ready&~issue_A_req_valid)begin
                        issue_A_req_valid<=1;
                    end
                    else if(issue_A_req_valid & issue_A_req_ready)begin
                        issue_A_req_valid <=0;
                    end
                    if(issue_B_req_ready&~issue_B_req_valid)begin
                        now_mat_row_A <= now_mat_row_A +1;
                        if(now_mat_row_A == N_num)begin
                            fsm_state <=3;
                        end
                        else begin
                            issue_B_req_valid<=1;    
                        end
                    end
                    else if(issue_B_req_valid & issue_B_req_ready)begin
                        issue_B_req_valid <=0;
                        A_ctrl_addr <= A_ctrl_addr  + M_num *2;
                        
                    end
                if(fsm_state == 3)begin
                    if(1)begin
                        fsm_state <=4;    
                    end
                end
                if(fsm_state == 4)begin
                    fsm_state <= 0;
                end
            end

        end

    end
        
    dma_k_issue #(
        .ISSUE_NUM(ISSUE_NUM)
    )dma_k_issue_A(
        .clk(clk),
        .rstn(rstn),
        .in_per_issue_num(M_num/ISSUE_NUM),
        .in_legal_lenth(M_num *2),
        .in_base_addr(A_BASE_ADDR + A_ctrl_addr),

        .req_ready(issue_A_req_ready),
        .req_valid(issue_A_req_valid),

        .axi_data_in(m_axi_A),
        .data_issue(A_issue_stream)
    );
    dma_k_issue #(
        .ISSUE_NUM(ISSUE_NUM)
    )dma_k_issue_B(
        .clk(clk),
        .rstn(rstn),
        .in_per_issue_num(M_num * K_num / ISSUE_NUM),
        .in_legal_lenth(M_num * K_num * 2),
        .in_base_addr(B_BASE_ADDR),

        .req_ready(issue_B_req_ready),
        .req_valid(issue_B_req_valid),
        
        .axi_data_in(m_axi_B),
        .data_issue(B_issue_stream)
    );

    generate for(genvar i = 0;i<ISSUE_NUM;i++)begin
        demm_kernel demm_kernel(
            .clk(clk),
            .rstn(rstn),
            .times_num(M_num / ISSUE_NUM),
            .axis_fp16_A_val(A_issue_stream[i]),
            .axis_fp16_B_val(B_issue_stream[i]),
            .axis_fp16_out_val(Out_issue_stream[i])
        );
        // assign Out_issue_stream[i].tready = 1;
    end
    endgenerate
    

    
    fp_adder_tree #(
        .DATA_SIZE(ISSUE_NUM)
    )
     fp_adder_tree(
        .clk(clk),
        .rstn(rstn),
        .din_s(Out_issue_stream),
        .dout_s(Out_stream)
     );

    // assign Out_stream.tready =  1;
    //TODO axi_wb
endmodule