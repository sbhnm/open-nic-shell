module Row_Kernel#(
    parameter  COLINDEX_BASE_ADDR	= 32'h40000000,
    parameter  XVal_BASE_ADDR	= 32'h40000000
)
(

    input wire rstn,
    input wire clk,

//Config
    input wire [2:0] Ctrl_sig_Val,
    input wire [2:0] Ctrl_sig_Xi,
    input wire [2:0] Ctrl_sig_Yi,

    input wire Read_Begin,
    input wire [31:0] Read_Length,

//Row NNZ
    input wire [32-1:0] S_AXIS_TIMES_tdata,
    output wire S_AXIS_TIMES_tready,
    input wire S_AXIS_TIMES_tvalid,

//ValueBus
    (*mark_debug = "true"*)
    input Radix_Converter_Val_input_valid,
    (*mark_debug = "true"*)
    output Radix_Converter_Val_input_ready,
    (*mark_debug = "true"*)
    input [64-1:0] Radix_Converter_Val_input_data,

    (*mark_debug = "true"*)
    output wire             output_valid,
    (*mark_debug = "true"*)
    input  wire             output_ready,
    output wire [63:0]      output_data,

//colIndex Buffer
    output wire [1-1 : 0] m_axi_colIndex_arid,
    output wire [48-1 : 0] m_axi_colIndex_araddr,
    output wire [7 : 0] m_axi_colIndex_arlen,
    output wire [2 : 0] m_axi_colIndex_arsize,
    output wire [1 : 0] m_axi_colIndex_arburst,
    output wire  m_axi_colIndex_arlock,
    output wire [3 : 0] m_axi_colIndex_arcache,
    output wire [2 : 0] m_axi_colIndex_arprot,
    output wire [3 : 0] m_axi_colIndex_arqos,
    output wire  m_axi_colIndex_arvalid,
    input wire  m_axi_colIndex_arready,
    input wire [1-1 : 0] m_axi_colIndex_rid,
    input wire [32-1 : 0] m_axi_colIndex_rdata,
    input wire [1 : 0] m_axi_colIndex_rresp,
    input wire  m_axi_colIndex_rlast,
    input wire  m_axi_colIndex_rvalid,
    output wire  m_axi_colIndex_rready,

//Xi Buffer
    output wire [1-1 : 0] m_axi_Xi_arid,
    output wire [48-1 : 0] m_axi_Xi_araddr,
    output wire [7 : 0] m_axi_Xi_arlen,
    output wire [2 : 0] m_axi_Xi_arsize,
    output wire [1 : 0] m_axi_Xi_arburst,
    output wire  m_axi_Xi_arlock,
    output wire [3 : 0] m_axi_Xi_arcache,
    output wire [2 : 0] m_axi_Xi_arprot,
    output wire [3 : 0] m_axi_Xi_arqos,
    output wire  m_axi_Xi_arvalid,
    input wire  m_axi_Xi_arready,
    input wire [1-1 : 0] m_axi_Xi_rid,
    input  wire [64-1 : 0] m_axi_Xi_rdata,
    input wire [1 : 0] m_axi_Xi_rresp,
    input wire  m_axi_Xi_rlast,
    input wire  m_axi_Xi_rvalid,
    output wire  m_axi_Xi_rready

);



//Double
    wire             output_double_valid;
    wire             output_double_ready;
    wire [63:0]      output_double_data;
//Single
    wire             output_single_valid;
    wire             output_single_ready;
    wire [63:0]      output_single_data;
//Half
    wire             output_half_valid;
    wire             output_half_ready;
    wire [63:0]      output_half_data;

    (*mark_debug = "true"*)
    wire Radix_Converter_Xi_output_valid;
    (*mark_debug = "true"*)
    wire Radix_Converter_Xi_output_ready;
    (*mark_debug = "true"*)
    wire [63:0] Radix_Converter_Xi_output_data;
    (*mark_debug = "true"*)
    wire Radix_Converter_Val_output_valid;
    (*mark_debug = "true"*)
    wire Radix_Converter_Val_output_ready;
    (*mark_debug = "true"*)
    wire [63:0] Radix_Converter_Val_output_data;
    (*mark_debug = "true"*)
    wire [63:0] Radix_Converter_INV_Yi_input_data;
    (*mark_debug = "true"*)
    wire Radix_Converter_INV_Yi_input_ready;
    (*mark_debug = "true"*)
    wire Radix_Converter_INV_Yi_input_valid;

    wire [63:0] Fifo_Xi_data_out;
    wire Fifo_Xi_rd_en;

    vector_dot vector_dot_inst (
        .M_AXIS_OUT_tdata(Radix_Converter_INV_Yi_input_data),
        .M_AXIS_OUT_tready(Radix_Converter_INV_Yi_input_ready),
        .M_AXIS_OUT_tvalid(Radix_Converter_INV_Yi_input_valid),

        .S_AXIS_A_tdata(Radix_Converter_Xi_output_data),
        .S_AXIS_A_tready(Radix_Converter_Xi_output_ready),
        .S_AXIS_A_tvalid(Radix_Converter_Xi_output_valid & Radix_Converter_Xi_output_ready),

        .S_AXIS_B_tdata(Radix_Converter_Val_output_data),
        .S_AXIS_B_tready(Radix_Converter_Val_output_ready),
        .S_AXIS_B_tvalid(Radix_Converter_Val_output_valid & Radix_Converter_Val_output_ready),

        .S_AXIS_TIMES_tdata(S_AXIS_TIMES_tdata),
        .S_AXIS_TIMES_tready(S_AXIS_TIMES_tready),
        .S_AXIS_TIMES_tvalid(S_AXIS_TIMES_tvalid),

        .clk(clk),
        .rstn(rstn)
    );
    Radix_Converter Radix_Converter_Val(
        .clk(clk),
        .rstn(rstn),
        .Ctrl_sig(Ctrl_sig_Val),
        .input_valid(Radix_Converter_Val_input_valid),
        .input_ready(Radix_Converter_Val_input_ready),
        .input_data(Radix_Converter_Val_input_data),
        .output_valid(Radix_Converter_Val_output_valid),
        .output_ready(Radix_Converter_Val_output_ready),
        // .output_ready(1),
        .output_data(Radix_Converter_Val_output_data)
    );
    (*mark_debug = "true"*)
    wire Xi_valid;
    (*mark_debug = "true"*)
    wire Xi_ready;
    (*mark_debug = "true"*)
    wire [63:0] Xi_data;
    Radix_Converter Radix_Converter_Xi(
        .clk(clk),
        .rstn(rstn),
        .Ctrl_sig(Ctrl_sig_Xi),
        .input_valid(Fifo_Xi_rd_en),
        .input_ready(Xi_ready),
        .input_data(Fifo_Xi_data_out), 
        .output_valid(Radix_Converter_Xi_output_valid),
        .output_ready(Radix_Converter_Xi_output_ready),
        // .output_ready(1),
        .output_data(Radix_Converter_Xi_output_data)
    );
    Radix_Converter_INV Radix_Converter_INV_Yi (
        .clk(clk),
        .rstn(rstn),
        .Ctrl_sig(Ctrl_sig_Yi),
        .input_valid(Radix_Converter_INV_Yi_input_valid),
        .input_ready(Radix_Converter_INV_Yi_input_ready),
        .input_data(Radix_Converter_INV_Yi_input_data),

        .output_double_valid(output_double_valid),
        .output_double_ready(output_double_ready),
        .output_double_data(output_double_data),

        .output_single_valid(output_single_valid),
        .output_single_ready(output_single_ready),
        .output_single_data(output_single_data),

        .output_half_valid(output_half_valid),
        .output_half_ready(output_half_ready),
        .output_half_data(output_half_data)
    );


    wire Fifo_Xi_empty;
    reg [2:0] Xi_data_Cnt;

    Fifo#(
        .DATA_WIDTH(64)
    ) Fifo_Xi(
        .clk(clk),
        .rst(~rstn),
        .wr_en(Xi_valid),
        .data_in(Xi_data),
        .data_out(Fifo_Xi_data_out),
        .rd_en(Fifo_Xi_rd_en),
        .empty(Fifo_Xi_empty),
        .full(Fifo_Xi_full)
    );

    always @(posedge clk ) begin
        if(~rstn)begin
            Xi_data_Cnt <=2;
        end
        if(Fifo_Xi_rd_en)begin
            Xi_data_Cnt <=2;
        end
        else if(Xi_data_Cnt >0)begin
            Xi_data_Cnt<=Xi_data_Cnt-1;
        end
        else if(Xi_data_Cnt ==0)begin
            Xi_data_Cnt<=Xi_data_Cnt;
        end
    end
    assign Fifo_Xi_rd_en = Xi_ready & ~Fifo_Xi_empty & Xi_data_Cnt==0;
    Xi_Reader #(
        .COLINDEX_BASE_ADDR(COLINDEX_BASE_ADDR),
        .XVal_BASE_ADDR(XVal_BASE_ADDR)
    )Xi_Reader_inst (
        .Xi_ready(~Fifo_Xi_full),
        //HXZ
        // .Xi_ready(1),
        .Xi_valid(Xi_valid),
        .Xi_data(Xi_data),
        .Ctrl_sig_Xi(Ctrl_sig_Xi),
        .Ctrl_sig_Val(Ctrl_sig_Val),

        .Read_Begin(Read_Begin),
        .Read_Length(Read_Length),
        
        .clk(clk),
        .rstn(rstn),

        .m_axi_colIndex_arid(m_axi_colIndex_arid),
        .m_axi_colIndex_araddr(m_axi_colIndex_araddr),
        .m_axi_colIndex_arlen(m_axi_colIndex_arlen),
        .m_axi_colIndex_arsize(m_axi_colIndex_arsize),
        .m_axi_colIndex_arburst(m_axi_colIndex_arburst),
        .m_axi_colIndex_arlock(m_axi_colIndex_arlock),
        .m_axi_colIndex_arcache(m_axi_colIndex_arcache),
        .m_axi_colIndex_arprot(m_axi_colIndex_arprot),
        .m_axi_colIndex_arqos(m_axi_colIndex_arqos),
        .m_axi_colIndex_arvalid(m_axi_colIndex_arvalid),
        .m_axi_colIndex_arready(m_axi_colIndex_arready),
        .m_axi_colIndex_rid(m_axi_colIndex_rid),
        .m_axi_colIndex_rdata(m_axi_colIndex_rdata),
        .m_axi_colIndex_rresp(m_axi_colIndex_rresp),
        .m_axi_colIndex_rlast(m_axi_colIndex_rlast),
        .m_axi_colIndex_rvalid(m_axi_colIndex_rvalid),
        .m_axi_colIndex_rready(m_axi_colIndex_rready),

        .m_axi_Xi_arid(m_axi_Xi_arid),
        .m_axi_Xi_araddr(m_axi_Xi_araddr),
        .m_axi_Xi_arlen(m_axi_Xi_arlen),
        .m_axi_Xi_arsize(m_axi_Xi_arsize),
        .m_axi_Xi_arburst(m_axi_Xi_arburst),
        .m_axi_Xi_arlock(m_axi_Xi_arlock),
        .m_axi_Xi_arcache(m_axi_Xi_arcache),
        .m_axi_Xi_arprot(m_axi_Xi_arprot),
        .m_axi_Xi_arqos(m_axi_Xi_arqos),
        .m_axi_Xi_arvalid(m_axi_Xi_arvalid),
        .m_axi_Xi_arready(m_axi_Xi_arready),
        .m_axi_Xi_rid(m_axi_Xi_rid),
        .m_axi_Xi_rdata(m_axi_Xi_rdata),
        .m_axi_Xi_rresp(m_axi_Xi_rresp),
        .m_axi_Xi_rlast(m_axi_Xi_rlast),
        .m_axi_Xi_rvalid(m_axi_Xi_rvalid),
        .m_axi_Xi_rready(m_axi_Xi_rready)
    );

    wire [63:0] Data_Mux_input_data;

    assign Data_Mux_input_valid = 
                            (Ctrl_sig_Yi == 2)? output_double_valid :0|
                            (Ctrl_sig_Yi == 1)? output_single_valid :0|
                            (Ctrl_sig_Yi == 0)? output_half_valid :0;

    assign Data_Mux_input_data = 
                            (Ctrl_sig_Yi == 2)? output_double_data :0|
                            (Ctrl_sig_Yi == 1)? output_single_data :0|
                            (Ctrl_sig_Yi == 0)? output_half_data :0;

    assign output_half_ready = Data_Mux_input_ready;
    assign output_single_ready = Data_Mux_input_ready;
    assign output_double_ready = Data_Mux_input_ready;
 

    Data_Mux Data_Mux_inst(
        .clk(clk),
        .rstn(rstn),
        .Ctrl_sig_Yi(Ctrl_sig_Yi),
        .input_valid(Data_Mux_input_valid),
        .input_data(Data_Mux_input_data),
        .input_ready(Data_Mux_input_ready),
        .output_valid(output_valid),
        .output_data(output_data),
        .output_ready(output_ready)
    
    );
    
endmodule