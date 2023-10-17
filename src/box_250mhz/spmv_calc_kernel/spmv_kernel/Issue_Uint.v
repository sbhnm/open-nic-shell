module Issue_Uint #(
    parameter integer C_M_AXI_DATA_WIDTH = 64
) (
    input wire  clk,
    input wire  rstn,
    (*mark_debug = "true"*)   
    input  wire m_axi_arvalid,
    (*mark_debug = "true"*)   
    input wire m_axi_arready,
    input  wire m_axi_rvalid,
    input wire m_axi_rready,
    input wire [C_M_AXI_DATA_WIDTH-1:0] m_axi_rdata,
    
    output wire Issue_BUSY,
    output wire Issue_IDLE,
    input wire Fifo_Post_Read,
    output wire [3+3 + C_M_AXI_DATA_WIDTH -1 :0 ]Fifo_Post_Read_data,
    output wire Fifo_Post_empty,
    output wire Fifo_Post_full,
    input wire [2:0] Req_Fifo_ServeNum,
    input wire [2:0] Req_Seq
);
    reg [1:0] Issue_cold;
    (*mark_debug = "true"*)    
    reg [1:0] AR_CNT;

    assign Issue_IDLE = AR_CNT==0 & Issue_cold == 0 & m_axi_arready;

    assign Issue_BUSY = AR_CNT==2 | Issue_cold != 0 | ~m_axi_arready;


    always @(posedge clk ) begin
        if(~rstn)begin
            Issue_cold<=0;
        end
        else if(m_axi_arvalid & m_axi_arready)begin
            Issue_cold <=3;
        end
        else begin
            Issue_cold <= Issue_cold ==0 ? 0 : Issue_cold -1;
        end
    end

    always @(posedge clk ) begin
        if(~rstn)begin
            AR_CNT<=0;
        end
        else if(~(m_axi_arvalid&m_axi_arready) & (m_axi_rvalid&m_axi_rready) )begin
            AR_CNT<=AR_CNT -1;
        end
        else if((m_axi_arvalid&m_axi_arready) & ~(m_axi_rvalid&m_axi_rready) )begin
            AR_CNT<=AR_CNT +1;
        end
    end
    (*mark_debug = "true"*) 
    wire [5:0] Fifo_AXI_Issue_data_out;
    Fifo #(
        .DATA_WIDTH(3+3)
    )Fifo_AXI_Issue(
        .clk(clk),
        .rst(~rstn),
        .wr_en(m_axi_arvalid&m_axi_arready),
        .data_in({Req_Fifo_ServeNum,Req_Seq}),
        .rd_en(m_axi_rvalid&m_axi_rready),
        .data_out(Fifo_AXI_Issue_data_out)
    );

    Fifo #(
        .DATA_WIDTH(3+3 + C_M_AXI_DATA_WIDTH),
        .DEPTH(8)
    ) Fifo_AXI_Post(
        .clk(clk),
        .rst(~rstn),
        .wr_en(m_axi_rvalid&m_axi_rready),
        .data_in({m_axi_rdata,Fifo_AXI_Issue_data_out}),
        .rd_en(Fifo_Post_Read),
        .data_out(Fifo_Post_Read_data),
        .full(Fifo_Post_full),
        .empty(Fifo_Post_empty)
    );

endmodule