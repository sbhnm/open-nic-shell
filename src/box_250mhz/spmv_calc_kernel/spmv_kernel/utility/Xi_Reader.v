module Xi_Reader#(
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
    output wire [48-1 : 0] m_axi_colIndex_araddr;
    output wire [7 : 0] m_axi_colIndex_arlen;
    output wire [2 : 0] m_axi_colIndex_arsize;
    output wire [1 : 0] m_axi_colIndex_arburst;
    output wire  m_axi_colIndex_arlock;
    output wire [3 : 0] m_axi_colIndex_arcache;
    output wire [2 : 0] m_axi_colIndex_arprot;
    output wire [3 : 0] m_axi_colIndex_arqos;
    output wire  m_axi_colIndex_arvalid;
    input wire  m_axi_colIndex_arready;
    input wire [1-1 : 0] m_axi_colIndex_rid;
    input wire [32-1 : 0] m_axi_colIndex_rdata;
    input wire [1 : 0] m_axi_colIndex_rresp;
    input wire  m_axi_colIndex_rlast;
    input wire  m_axi_colIndex_rvalid;
    output wire  m_axi_colIndex_rready;
    wire  colIndex_rready;


    output wire [1-1 : 0] m_axi_Xi_arid;
    output wire [48-1 : 0] m_axi_Xi_araddr;
    output wire [7 : 0] m_axi_Xi_arlen;
    output wire [2 : 0] m_axi_Xi_arsize;
    output wire [1 : 0] m_axi_Xi_arburst;
    output wire  m_axi_Xi_arlock;
    output wire [3 : 0] m_axi_Xi_arcache;
    output wire [2 : 0] m_axi_Xi_arprot;
    output wire [3 : 0] m_axi_Xi_arqos;
    output wire  m_axi_Xi_arvalid;
    input wire  m_axi_Xi_arready;
    input wire [1-1 : 0] m_axi_Xi_rid;
    input  wire [64-1 : 0] m_axi_Xi_rdata;
    input wire [1 : 0] m_axi_Xi_rresp;
    input wire  m_axi_Xi_rlast;
    input wire  m_axi_Xi_rvalid;
    output wire  m_axi_Xi_rready;

    wire m_axi_Xi_rready_device;

    reg Read_colIndex_Begin;
    reg [31:0] colIndex_read_addr;
    reg [31:0] Read_Times_CNT;

    always @(posedge clk ) begin
        if(~rstn)begin
            Read_Times_CNT <=0;
        end
        if(m_axi_Xi_rvalid)begin
            Read_Times_CNT <= Read_Times_CNT +1;
        end
    end
axi_master_r_single #(
        .C_M_AXI_TARGET_SLAVE_BASE_ADDR(COLINDEX_BASE_ADDR),
        .C_M_AXI_BURST_LEN(1)
    ) axi_master_r_colIndex(
            .m_axi_init_axi_read(Read_colIndex_Begin & (Read_Times_CNT < Read_Length)),
            .m_axi_r_done(),
            .m_axi_aclk(clk),
            .m_axi_aresetn(rstn),
            .m_axi_arid(m_axi_colIndex_arid),
            .m_axi_araddr(m_axi_colIndex_araddr),
            .m_axi_arlen(m_axi_colIndex_arlen),
            .m_axi_arsize(m_axi_colIndex_arsize),
            .m_axi_arburst(m_axi_colIndex_arburst),
            .m_axi_arlock(m_axi_colIndex_arlock),
            .m_axi_arcache(m_axi_colIndex_arcache),
            .m_axi_arprot(m_axi_colIndex_arprot),
            .m_axi_arqos(m_axi_colIndex_arqos),
            .m_axi_arvalid(m_axi_colIndex_arvalid),
            .m_axi_arready(m_axi_colIndex_arready),
            .m_axi_rid(m_axi_colIndex_rid),
            .m_axi_rdata(m_axi_colIndex_rdata),
            .m_axi_rresp(m_axi_colIndex_rresp),
            .m_axi_rlast(m_axi_colIndex_rlast),
            .m_axi_rvalid(m_axi_colIndex_rvalid),
            .m_axi_rready(colIndex_rready),

            .read_length(Read_Length),

            .read_base_addr(colIndex_read_addr)
    );

    reg [2:0] read_status;
    // wire  Double_Valid = (Col_Valid);
    // reg Double_Valid_reg;
   
    // always @(posedge clk ) begin
    //     Double_Valid_reg<= Double_Valid;
    // end
    // assign Xi_valid = m_axi_Xi_rvalid;
    assign m_axi_Xi_rready = Xi_ready& m_axi_Xi_rready_device;
    //  assign m_axi_Xi_rready = m_axi_Xi_rready_device;
    // assign Xi_data = m_axi_Xi_rdata;


    assign Xi_data =(Ctrl_sig_Xi ==2 ? m_axi_Xi_rdata:0)|
                    (Ctrl_sig_Xi ==1 ? (m_axi_colIndex_rdata[0] ==0? m_axi_Xi_rdata[31:0] : m_axi_Xi_rdata[63:32]):0)|
                    (Ctrl_sig_Xi ==0 ? (   
                                    m_axi_colIndex_rdata[1:0] ==0 ? m_axi_Xi_rdata[15:0]:0|
                                    m_axi_colIndex_rdata[1:0] ==1 ? m_axi_Xi_rdata[31:16]:0|
                                    m_axi_colIndex_rdata[1:0] ==2 ? m_axi_Xi_rdata[47:32]:0|
                                    m_axi_colIndex_rdata[1:0] ==3 ? m_axi_Xi_rdata[63:48]:0
                                     ):0);
    reg Read_Xi_Begin=0;
    reg [31:0] Read_Xi_ADDR=0;
    reg Xi_rstn=1;
        
    reg [31:0] Xi_Cnt;
    assign m_axi_colIndex_rready = colIndex_rready;

    assign Xi_valid = m_axi_Xi_rvalid;


    always @(posedge clk ) begin
        if(~rstn)begin
            Xi_Cnt<=0;
        end
        else if(m_axi_Xi_arvalid&(m_axi_Xi_rvalid & m_axi_Xi_rready))begin
            Xi_Cnt <= Xi_Cnt;
        end
        else if(m_axi_Xi_arvalid & ~(m_axi_Xi_rvalid & m_axi_Xi_rready))begin
            Xi_Cnt <= Xi_Cnt +1;
        end
        else if(~m_axi_Xi_arvalid & (m_axi_Xi_rvalid & m_axi_Xi_rready))begin
            Xi_Cnt <= Xi_Cnt -1;
        end
    end
    wire [4:0] Xi_Cnt_Max;
    assign Xi_Cnt_Max = Ctrl_sig_Val == 0 ? 2:0|
                        Ctrl_sig_Val == 1 ? 4:0|
                        Ctrl_sig_Val == 2 ? 8:0;

    always @(posedge clk) begin
        if(~rstn)begin
            read_status <=3;
            Read_Xi_Begin<=0;
            Read_Xi_ADDR<=0;
            Xi_rstn<=0;
            colIndex_read_addr<=0;
            Read_colIndex_Begin<=0;
        end
        else begin
            if(read_status==0)begin //wait coldata
                Xi_rstn<=1;
                Read_colIndex_Begin <=0;
                if(m_axi_colIndex_rvalid & colIndex_rready)begin
                    read_status<=4;
                end
            end

            if(read_status ==4)begin
                // if( Xi_Cnt < Xi_Cnt_Max & Xi_ready)begin
                if(Xi_ready & m_axi_Xi_arready)begin
                    colIndex_read_addr <= colIndex_read_addr + 4;
                    read_status<=1;
                    Read_Xi_Begin <=1;


                    Read_Xi_ADDR <=     (Ctrl_sig_Xi ==2 ? ({(m_axi_colIndex_rdata <<3)&32'b1111_1111_1111_1111_1111_1111_1111_1000}):0)|
                                        (Ctrl_sig_Xi ==1 ? ({(m_axi_colIndex_rdata <<2)&32'b1111_1111_1111_1111_1111_1111_1111_1000}):0)|
                                        (Ctrl_sig_Xi ==0 ? ({(m_axi_colIndex_rdata <<1)&32'b1111_1111_1111_1111_1111_1111_1111_1000}):0);

                end
                else begin
                    read_status<=4;
                end

            end
            if(read_status==1)begin
                
                // if(m_axi_Xi_rvalid)begin
                // if(Xi_Cnt < Xi_Cnt_Max)begin
                if(Xi_ready & m_axi_Xi_arready)begin

                    Read_Xi_Begin<=0;
                    Xi_rstn<=0;
                    read_status<=0;
                    Read_colIndex_Begin <=1;

                end
                else begin
                    Read_Xi_Begin<=0;
                end
            end

            if(read_status ==3)begin
                if(Read_Begin)begin
                    read_status <=0;
                    Read_colIndex_Begin <=1;
                end
            end
        end
    end
    //TODO outstanding 特性会将数据连续连两个周期内读入，造成后续处理部件拥塞，添加fifo以解决该问题。
    axi_master_r_single #(
        .C_M_AXI_DATA_WIDTH(64),    
        .C_M_AXI_BURST_LEN(1),
        .C_M_AXI_TARGET_SLAVE_BASE_ADDR(XVal_BASE_ADDR)
    ) axi_master_r_Xi(
        .m_axi_init_axi_read(Read_Xi_Begin),
        .m_axi_r_done(),
        .m_axi_aclk(clk),
        .m_axi_aresetn(Xi_rstn),
        .m_axi_arid(m_axi_Xi_arid),
        .m_axi_araddr(m_axi_Xi_araddr),
        .m_axi_arlen(m_axi_Xi_arlen),
        .m_axi_arsize(m_axi_Xi_arsize),
        .m_axi_arburst(m_axi_Xi_arburst),
        .m_axi_arlock(m_axi_Xi_arlock),
        .m_axi_arcache(m_axi_Xi_arcache),
        .m_axi_arprot(m_axi_Xi_arprot),
        .m_axi_arqos(m_axi_Xi_arqos),
        .m_axi_arvalid(m_axi_Xi_arvalid),
        .m_axi_arready(m_axi_Xi_arready),
        .m_axi_rid(m_axi_Xi_rid),
        .m_axi_rdata(m_axi_Xi_rdata),
        .m_axi_rresp(m_axi_Xi_rresp),
        .m_axi_rlast(m_axi_Xi_rlast),
        .m_axi_rvalid(m_axi_Xi_rvalid),
        .m_axi_rready(m_axi_Xi_rready_device),
        .read_length(1),
        .read_base_addr(Read_Xi_ADDR)
    );

endmodule