module dma_k_issue #(
    parameter integer ISSUE_NUM = 4,

    parameter integer INPUT_DATA_WIDTH = 64,

    parameter integer OUT_DATA_WIDTH = 16,

    parameter integer BURST_LEN = 16
    
) (
    input wire clk,
    input wire rstn,
    

    input wire [31:0] in_per_issue_num, // 单发射次数
    input wire [31:0] in_legal_lenth, //数组合法长度 Byte
    input wire [31:0] in_base_addr, // 数组基地址
    
    output wire req_ready,
    input wire req_valid,
    
    axi4.master axi_data_in,


    stream.master data_issue[ISSUE_NUM]
);
    
    reg [31:0] buffer_legal_length;
    reg [31:0] buffer_per_issue_num;
    wire [31:0] buffer_base_addr;
    
    assign buffer_legal_issue = buffer_legal_length / ((OUT_DATA_WIDTH/8) * ISSUE_NUM);



    assign now_issue_num;
    wire Fifo_Val_needdata;

    reg [2:0] fsm_state;
    reg [2:0] read_state;
 
    assign req_ready =  fsm_state==0;

    always @(posedge clk) begin
        if(~rstn)begin
            fsm_state<=0;
        end
        else begin
            if(fsm_state ==0)begin
                if(req_ready & req_valid)begin
                    buffer_legal_length<=in_legal_lenth;
                    buffer_base_addr <= in_base_addr;
                    axi_data_in.araddr <= in_base_addr;
                    buffer_per_issue_num <= in_per_issue_num;
                    fsm_state<=1;
                    read_state<=0;
                end    
            end
            else if(fsm_state == 1)begin
                if(read_state == 0)begin
                    if(now_issue_num > buffer_per_issue_num)begin
                        fsm_state<=0;
                    end
                    else if(~axi_data_in.arvalid & Fifo_Val_needdata)begin
                        axi_data_in.arvalid <= 1;
                        read_state <=1;
                    end    
                end
                else if(read_state ==1)begin

                    if(axi_data_in.arvalid & axi_data_in.arready)begin
                        axi_data_in.arvalid <=0;
                    end
                    if(axi_data_in.rvalid & axi_data_in.rready & axi_data_in.rlast )begin
                        read_state <=0;
                        axi_data_in.araddr<=axi_data_in.araddr + BURST_LEN * INPUT_DATA_WIDTH /8;
                    end
                end
                
            end

        end
    end


    wire data_issue_valid;
    wire data_issue_ready;



    wire [OUT_DATA_WIDTH * ISSUE_NUM -1:0] data_de_mux;

    wire [ISSUE_NUM-1:0] issus_ready_vec;

    wire [3:0] legal_issue;
    assign legal_issue = (buffer_legal_length / (OUT_DATA_WIDTH/8)) % ISSUE_NUM;

    assign data_issue_ready = & issus_ready_vec;

    generate for(genvar i = 0;i<ISSUE_NUM;i++)begin
        assign data_issue[i].tdata = (now_issue_num<buffer_legal_issue) ? data_de_mux[`getvec(OUT_DATA_WIDTH,i)]:0|
                                    (now_issue_num==buffer_legal_issue & (i < legal_issue) ) ? data_de_mux[`getvec(OUT_DATA_WIDTH,i)]:0|
                                    0;
    assign data_issue[i].tvalid = (now_issue_num<buffer_legal_issue) ? data_issue_valid:0|
                                    (now_issue_num==buffer_legal_issue & (i < legal_issue) ) ? data_issue_valid:0|
                                    0;
        assign issus_ready_vec[i] = data_issue[i].tready; 
    end
    endgenerate
    always @(posedge clk) begin
        if(~rstn)begin
            now_issue_num <= 0;
        end
        else begin
            if(fsm_state == 0)begin
                now_issue_num <=0;
            end
            if(data_issue_valid & data_issue_ready & fsm_state==1)begin
                now_issue_num<=now_issue_num+1;
            end
        end
    end


    wire Fifo_empty;
    wire Fifo_full;
    
    assign data_issue_valid = ~Fifo_empty & fsm_state==1;
    assign axi_data_in.rready = ~Fifo_full;
    Fifo #(
        .DATA_WIDTH(OUT_DATA_WIDTH*ISSUE_NUM),
        .DEPTH(32),
        .MIN_THER(8),
        .MAX_THER(15),
    ) Fifo(
        .clk(clk),
        .rst(~rstn | fsm_state == 0),
        .wr_en(axi_data_in.rvalid & axi_data_in.rready),
        .rd_en(data_issue_ready & data_issue_valid),
        .empty(Fifo_empty),
        .data_in(axi_data_in.rdata),
        .data_out(data_de_mux),
        .full(Fifo_full),
        .needdata(Fifo_Val_needdata),
        
    );
    
endmodule