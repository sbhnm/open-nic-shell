module Xi_Reader#(
    parameter  COLINDEX_BASE_ADDR	= 32'h40000000,
    parameter  XVal_BASE_ADDR	= 32'h40000000
)(
    Xi_ready,
    Xi_valid,
    Xi_data,
    Ctrl_sig,
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
    input wire [1:0] Ctrl_sig;
    input wire Xi_ready;
    output wire Xi_valid;
    output wire [63:0] Xi_data;

    input wire clk;
    input wire rstn;
    input wire Read_Begin;
    input wire [31:0] Read_Length;



    output wire [1-1 : 0] m_axi_colIndex_arid;
    output wire [32-1 : 0] m_axi_colIndex_araddr;
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
    output wire [32-1 : 0] m_axi_Xi_araddr;
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
    input  wire [32-1 : 0] m_axi_Xi_rdata;
    input wire [1 : 0] m_axi_Xi_rresp;
    input wire  m_axi_Xi_rlast;
    input wire  m_axi_Xi_rvalid;
    output wire  m_axi_Xi_rready;

    wire m_axi_Xi_rready_device;
axi_master_r #(
        .C_M_TARGET_SLAVE_BASE_ADDR(0)
    ) axi_master_r_colIndex(
            .m_axi_init_axi_read(Read_Begin),
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

            .read_base_addr(COLINDEX_BASE_ADDR)
    );

    reg [2:0] read_status;
    // wire  Double_Valid = (Col_Valid);
    // reg Double_Valid_reg;
    assign Xi_valid = Ctrl_sig !=2 ? m_axi_Xi_rvalid:Col_Valid==2;
    // always @(posedge clk ) begin
    //     Double_Valid_reg<= Double_Valid;
    // end
    // assign Xi_valid = m_axi_Xi_rvalid;
    assign m_axi_Xi_rready = Xi_ready& m_axi_Xi_rready_device;
    // assign Xi_data = m_axi_Xi_rdata;



    reg [31:0] double_high;
    assign Xi_data =(Ctrl_sig ==2 ? ({double_high,m_axi_Xi_rdata}):0)|
                    (Ctrl_sig ==1 ? m_axi_Xi_rdata:0)|
                    (Ctrl_sig ==0 ? (m_axi_colIndex_rdata[0]? m_axi_Xi_rdata[31:16]:m_axi_Xi_rdata[15:0] ):0);
    reg Read_Xi_Begin=0;
    reg [31:0] Read_Xi_ADDR=0;
    reg Xi_rstn=1;
    assign m_axi_colIndex_rready = read_status==0 &colIndex_rready;

    reg [1:0] Col_Valid = 0;
    always @(posedge clk) begin
        if (!rstn) begin
            Col_Valid <=0;
        end
        else begin
            if(Col_Valid==2)begin
                Col_Valid<=0;
            end
            else if(m_axi_Xi_rvalid)begin
                Col_Valid<= Col_Valid+1;
            end
        end
        
    end


    always @(posedge clk) begin
        if(~rstn)begin
            read_status <=0;
            Read_Xi_Begin<=0;
            Read_Xi_ADDR<=0;
            Xi_rstn<=0;
        end
        if(read_status==0)begin //wait coldata
            Xi_rstn<=1;
            if(m_axi_colIndex_rvalid&colIndex_rready)begin
                read_status<=1;
                Read_Xi_Begin <=1;


                Read_Xi_ADDR <=     (Ctrl_sig ==2 ? (m_axi_colIndex_rdata <<3):0)|
                                    (Ctrl_sig ==1 ? (m_axi_colIndex_rdata <<2):0)|
                                    (Ctrl_sig ==0 ? (m_axi_colIndex_rdata <<1):0);

                // Read_Xi_ADDR <=     m_axi_colIndex_rdata <<1;
            end
            else begin
                read_status<=0;
            end
        end
        if(read_status==1)begin
            
            if(Ctrl_sig != 2 && m_axi_Xi_rvalid)begin
                Read_Xi_Begin<=0;
                Xi_rstn<=0;
                read_status<=0;
            end
            else if(Ctrl_sig == 2 && m_axi_Xi_rvalid)begin
                Xi_rstn<=0;
                read_status<=2;
                double_high<= m_axi_Xi_rdata;
                Read_Xi_Begin<=1;
                Read_Xi_ADDR<=Read_Xi_ADDR+4;
            end
            else begin
                Read_Xi_Begin<=0;
            end
        end

        if(read_status==2)begin
            Read_Xi_Begin<=0;
            if(m_axi_Xi_rvalid)begin
                Xi_rstn<=0;
                read_status<=0;
            end
        end
    end

    axi_master_r_single #(
        .C_M_AXI_DATA_WIDTH(32),    
        .C_M_AXI_BURST_LEN(1),
        .C_M_TARGET_SLAVE_BASE_ADDR(XVal_BASE_ADDR)
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