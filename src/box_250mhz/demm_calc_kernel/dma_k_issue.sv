`include "pcie_spmv_macros.vh"
`include "system_ifc.vh"
module dma_k_issue #(
    parameter integer ISSUE_NUM = 4,

    parameter integer INPUT_DATA_WIDTH = 64,

    parameter integer OUT_DATA_WIDTH = 16,

    parameter integer BURST_LEN = 32
    
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
	function integer clogb2 (input integer bit_depth);              
  	begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
    end                                                           
  	endfunction 
    always @(negedge rstn) begin
        // axi_data_in.ARLEN = BURST_LEN -1;
        axi_data_in.ARID = 0;
        axi_data_in.ARSIZE=clogb2((INPUT_DATA_WIDTH/8)-1);
        axi_data_in.ARBURST= 2'b01;
        axi_data_in.ARLOCK= 1'b0;
        axi_data_in.ARCACHE= 4'b0010;
        axi_data_in.ARPROT= 3'h0;
        axi_data_in.ARQOS= 4'h0;

    end
    reg [31:0] total_burst_len;
    reg [31:0] buffer_legal_length;
    reg [31:0] buffer_per_issue_num;
    reg [31:0] buffer_base_addr;
    wire [31:0] buffer_legal_issue;
    assign buffer_legal_issue = buffer_legal_length / ((OUT_DATA_WIDTH/8) * ISSUE_NUM);

    reg [31:0] now_issue_num;

//    assign now_issue_num;
    wire Fifo_Val_needdata;

    reg [2:0] fsm_state;
    reg [2:0] read_state;
 
    assign req_ready =  fsm_state==0;

    always @(posedge clk) begin
        if(~rstn)begin
            fsm_state<=0;
            axi_data_in.ARVALID <=0;
            axi_data_in.ARLEN<=0;
        end
        else begin
            if(fsm_state ==0)begin
                if(req_ready & req_valid)begin
                    buffer_legal_length<=in_legal_lenth;
                    buffer_base_addr <= in_base_addr;
                    axi_data_in.ARADDR <= in_base_addr;
                    buffer_per_issue_num <= in_per_issue_num;
                    total_burst_len <= 0;
                    fsm_state<=1;
                    read_state<=0;
                end    
            end
            else if(fsm_state == 1)begin
                if(read_state == 0)begin
                    if(buffer_legal_issue == total_burst_len)begin
                        fsm_state<=2;
                    end
                    else if(~axi_data_in.ARVALID & Fifo_Val_needdata)begin
                        axi_data_in.ARVALID <= 1;

                        axi_data_in.ARLEN <= (buffer_legal_issue - total_burst_len)<BURST_LEN?(buffer_legal_issue - total_burst_len)-1:(BURST_LEN-1);
                        total_burst_len<=total_burst_len + ((buffer_legal_issue - total_burst_len)<BURST_LEN?(buffer_legal_issue - total_burst_len):BURST_LEN);
                        // axi_data_in.ARLEN<= (buffer_legal_length - total_burst_len)>BURST_LEN?BURST_LEN-1:(buffer_legal_length - total_burst_len)-1;
                        read_state <=1;
                    end    
                end
                else if(read_state ==1)begin

                    if(axi_data_in.ARVALID & axi_data_in.ARREADY)begin
                        axi_data_in.ARVALID <=0;
                    end
                    if(axi_data_in.RVALID & axi_data_in.RREADY & axi_data_in.RLAST )begin
                        read_state <=0;
                        axi_data_in.ARADDR<=axi_data_in.ARADDR + (axi_data_in.ARLEN + 1) * INPUT_DATA_WIDTH /8;
                    end
                end
                
            end
            else if(fsm_state==2)begin
                
                if(now_issue_num == buffer_per_issue_num)begin
                    fsm_state<=0;
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
            if(data_issue_valid & data_issue_ready & (fsm_state==1|fsm_state==2))begin
                now_issue_num<=now_issue_num+1;
            end
        end
    end


    wire Fifo_empty;
    wire Fifo_full;
    
    assign data_issue_valid = ~Fifo_empty & (fsm_state==1|fsm_state==2);
    assign axi_data_in.RREADY = ~Fifo_full;
    Fifo #(
        .DATA_WIDTH(OUT_DATA_WIDTH*ISSUE_NUM),
        .DEPTH(BURST_LEN*2),
        .MIN_THER(BURST_LEN/2),
        .MAX_THER(BURST_LEN*3/2)
    ) Fifo(
        .clk(clk),
        .rst(~rstn | fsm_state == 0),
        .wr_en(axi_data_in.RVALID & axi_data_in.RREADY),
        .rd_en(data_issue_ready & data_issue_valid),
        .empty(Fifo_empty),
        .data_in(axi_data_in.RDATA),
        .data_out(data_de_mux),
        .full(Fifo_full),
        .needdata(Fifo_Val_needdata)
        
    );
    
endmodule