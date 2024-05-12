`include "system_ifc.vh"
module Xi_Reader_s#(
    parameter  COLINDEX_BASE_ADDR	= 32'h40000000,
    parameter  XVal_BASE_ADDR	= 32'h40000000
)(
    Xi_ready,
    Xi_valid,
    Xi_data,
    Ctrl_sig_Xi,
    Ctrl_sig_Val,
    Read_Begin,
    Read_Length,
    clk,
    rstn,

    m_axi_colIndex_arid,
    m_axi_colIndex_araddr,
    m_axi_colIndex_arlen,
    m_axi_colIndex_arsize,
    m_axi_colIndex_arburst,
    m_axi_colIndex_arlock,
    m_axi_colIndex_arcache,
    m_axi_colIndex_arprot,
    m_axi_colIndex_arqos,
    m_axi_colIndex_arvalid,
    m_axi_colIndex_arready,
    m_axi_colIndex_rid,
    m_axi_colIndex_rdata,
    m_axi_colIndex_rresp,
    m_axi_colIndex_rlast,
    m_axi_colIndex_rvalid,
    m_axi_colIndex_rready,

    m_axi_Xi_arid,
    m_axi_Xi_araddr,
    m_axi_Xi_arlen,
    m_axi_Xi_arsize,
    m_axi_Xi_arburst,
    m_axi_Xi_arlock,
    m_axi_Xi_arcache,
    m_axi_Xi_arprot,
    m_axi_Xi_arqos,
    m_axi_Xi_arvalid,
    m_axi_Xi_arready,
    m_axi_Xi_rid,
    m_axi_Xi_rdata,
    m_axi_Xi_rresp,
    m_axi_Xi_rlast,
    m_axi_Xi_rvalid,
    m_axi_Xi_rready

);

    input wire [1:0] Ctrl_sig_Xi;
    input wire [1:0] Ctrl_sig_Val;

    input wire Xi_ready;
    output wire Xi_valid;
    output wire [63:0] Xi_data;

    input wire clk;
    input wire rstn;
    input wire Read_Begin;
    input wire [31:0] Read_Length;



    output wire [1-1 : 0] m_axi_colIndex_arid;
    output reg [48-1 : 0] m_axi_colIndex_araddr;
    output wire [7 : 0] m_axi_colIndex_arlen;
    output wire [2 : 0] m_axi_colIndex_arsize;
    output wire [1 : 0] m_axi_colIndex_arburst;
    output wire  m_axi_colIndex_arlock;
    output wire [3 : 0] m_axi_colIndex_arcache;
    output wire [2 : 0] m_axi_colIndex_arprot;
    output wire [3 : 0] m_axi_colIndex_arqos;
    //`DEBUG
    
    output wire  m_axi_colIndex_arvalid;
    //`DEBUG
    
    input wire  m_axi_colIndex_arready;
    input wire [1-1 : 0] m_axi_colIndex_rid;
    //`DEBUG
    
    input wire [32-1 : 0] m_axi_colIndex_rdata;
    input wire [1 : 0] m_axi_colIndex_rresp;
    input wire  m_axi_colIndex_rlast;
    //`DEBUG
    
    input wire  m_axi_colIndex_rvalid;
    //`DEBUG
    
    output wire  m_axi_colIndex_rready;
    wire  colIndex_rready;


    output wire [1-1 : 0] m_axi_Xi_arid;
    //`DEBUG
    
    output wire [48-1 : 0] m_axi_Xi_araddr;
    output wire [7 : 0] m_axi_Xi_arlen;
    output wire [2 : 0] m_axi_Xi_arsize;
    output wire [1 : 0] m_axi_Xi_arburst;
    output wire  m_axi_Xi_arlock;
    output wire [3 : 0] m_axi_Xi_arcache;
    output wire [2 : 0] m_axi_Xi_arprot;
    output wire [3 : 0] m_axi_Xi_arqos;
    //`DEBUG
    
    output wire  m_axi_Xi_arvalid;
    //`DEBUG
    
    input wire  m_axi_Xi_arready;
    input wire [1-1 : 0] m_axi_Xi_rid;
    //`DEBUG
    
    input  wire [64-1 : 0] m_axi_Xi_rdata;
    input wire [1 : 0] m_axi_Xi_rresp;
    input wire  m_axi_Xi_rlast;
    //`DEBUG
    
    input wire  m_axi_Xi_rvalid;
    //`DEBUG
    
    output wire  m_axi_Xi_rready;

    wire [31:0] col_idx_fifo_o;

    wire [1:0] Xi_Cast;
    


    assign m_axi_Xi_araddr =   XVal_BASE_ADDR +  ((Ctrl_sig_Xi ==2 ? ({(col_idx_fifo_o <<3)&32'b1111_1111_1111_1111_1111_1111_1111_1000}):0)|
                                (Ctrl_sig_Xi ==1 ? ({(col_idx_fifo_o <<2)&32'b1111_1111_1111_1111_1111_1111_1111_1000}):0)|
                                (Ctrl_sig_Xi ==0 ? ({(col_idx_fifo_o <<1)&32'b1111_1111_1111_1111_1111_1111_1111_1000}):0));
    wire [3:0] Fifo_Col_ctrl;
    wire [3:0] Fifo_Xi_ctrl;
    assign m_axi_colIndex_rready = ~Fifo_Col_ctrl[3];
    assign m_axi_colIndex_arvalid = ~Fifo_Col_ctrl[3] & m_axi_colIndex_arready & work ; 
    // assign m_axi_colIndex_arvalid = ~Fifo_Col_ctrl[3]& work;
//    assign m_axi_colIndex_arvalid =work;
    // assign m_axi_colIndex_arvalid =1;
    assign Fifo_Col_ctrl[1] = m_axi_colIndex_rvalid & m_axi_colIndex_rready; 
    assign Fifo_Col_ctrl[0] = m_axi_Xi_arvalid & m_axi_Xi_arready;

    always @(posedge clk ) begin
        if(~rstn)begin
            m_axi_colIndex_araddr <=COLINDEX_BASE_ADDR;
        end
        else begin
            if(m_axi_colIndex_arvalid & m_axi_colIndex_arready)begin
                m_axi_colIndex_araddr<=m_axi_colIndex_araddr+4;
            end
        end
    end
    
    reg work;
    reg [31:0] NNZ_Calc;
    always @(posedge clk ) begin
        if(~rstn)begin
            work <=0;
        end
        else if(NNZ_Calc > Read_Length) begin
            work <=0;
        end
        else if(Read_Begin)begin
            work <=1;
        end

    end
    always @(posedge clk ) begin
        if(~rstn)begin
            NNZ_Calc <=0;
        end
        else begin
            if(m_axi_colIndex_arvalid & m_axi_colIndex_arready)begin
                NNZ_Calc<=NNZ_Calc +1;
            end
        end
    end

    Fifo #(
        .DATA_WIDTH(32),
        .DEPTH(4)
    )Fifo_Col(
        .clk(clk),
        .rst(~rstn),
        .data_in(m_axi_colIndex_rdata),
        .data_out(col_idx_fifo_o),
        .rd_en(Fifo_Col_ctrl[0]),
        .wr_en(Fifo_Col_ctrl[1]),
        .empty(Fifo_Col_ctrl[2]),
        .full(Fifo_Col_ctrl[3])

    );

    Fifo #(
        .DATA_WIDTH(2),
        .DEPTH(8)
    ) Fifo_Cast(
        .clk(clk),
        .rst(~rstn),
        .data_in(col_idx_fifo_o[1:0]),
        .data_out(Xi_Cast),
        .wr_en(Fifo_Col_ctrl[0]),
        .rd_en(Fifo_Xi_ctrl[1])
    );

    assign m_axi_Xi_arvalid = Xi_ready & ~Fifo_Col_ctrl[2] & m_axi_Xi_arready; //后端需要数据才读，
    //不能设为存储队列不满就读。 会导致已经发送的数据顶满滑动窗口
    assign m_axi_Xi_rready = ~Fifo_Xi_ctrl[3];

    assign Fifo_Xi_ctrl[1] = m_axi_Xi_rready & m_axi_Xi_rvalid;
    assign Fifo_Xi_ctrl[0] = Xi_ready & ~Fifo_Xi_ctrl[2];
    assign Xi_valid = Fifo_Xi_ctrl[0];

    wire [63:0] Fifo_Xi_Data_in;
    assign Fifo_Xi_Data_in =(Ctrl_sig_Xi ==2 ? m_axi_Xi_rdata:0)|
                    (Ctrl_sig_Xi ==1 ? (Xi_Cast[0] ==0? m_axi_Xi_rdata[31:0] : m_axi_Xi_rdata[63:32]):0)|
                    (Ctrl_sig_Xi ==0 ? (   
                                    Xi_Cast[1:0] ==0 ? m_axi_Xi_rdata[15:0]:0|
                                    Xi_Cast[1:0] ==1 ? m_axi_Xi_rdata[31:16]:0|
                                    Xi_Cast[1:0] ==2 ? m_axi_Xi_rdata[47:32]:0|
                                    Xi_Cast[1:0] ==3 ? m_axi_Xi_rdata[63:48]:0
                                     ):0);
    // wire [4:0] Xi_Depth;
    Fifo #(
        .DATA_WIDTH(64),
        .DEPTH(16)
    )Fifo_Xi(
        .clk(clk),
        .rst(~rstn),
        .data_in(Fifo_Xi_Data_in),
        .data_out(Xi_data),
        .rd_en(Fifo_Xi_ctrl[0]),
        .wr_en(Fifo_Xi_ctrl[1]),
        .empty(Fifo_Xi_ctrl[2]),
        .full(Fifo_Xi_ctrl[3])
        // .fill_level(Xi_Depth)
    );

endmodule