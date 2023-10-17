`include "/home/hxz/Documents/mix_precision_RTL/RTL/rtl/hash_table_pkg.sv"
import hash_table::*;

module Cache_Bank #(
    parameter integer NUM_LUT_BANK = 16,
    parameter integer C_M_AXI_ID_WIDTH	= 1,
    parameter integer C_M_AXI_ADDR_WIDTH	= 48,
    parameter integer C_M_AXI_DATA_WIDTH	= 64,
    parameter integer C_M_AXI_BURST_LEN = 1,
    parameter integer HIT_ADDR = 0,
    parameter integer HASH_NUM = 160

) (
    input wire clk,
    input wire rstn,

    output wire Req_ready,
    input wire Req_valid,
    input wire [31:0] Req_Addr,

    input wire Post_ready,
    output wire Post_valid,
    output wire [63:0] Post_Data,
    output wire  Post_Success,


    output wire [C_M_AXI_ID_WIDTH-1 : 0] m_cache_axi_arid,
    output reg [C_M_AXI_ADDR_WIDTH-1 : 0] m_cache_axi_araddr,
    output wire [7 : 0] m_cache_axi_arlen,
    output wire [2 : 0] m_cache_axi_arsize,
    output wire [1 : 0] m_cache_axi_arburst,
    output wire  m_cache_axi_arlock,
    output wire [3 : 0] m_cache_axi_arcache,
    output wire [2 : 0] m_cache_axi_arprot,
    output wire [3 : 0] m_cache_axi_arqos,
    output reg  m_cache_axi_arvalid,
    input wire  m_cache_axi_arready,
    input wire [C_M_AXI_ID_WIDTH-1 : 0] m_cache_axi_rid,
    input wire [C_M_AXI_DATA_WIDTH-1 : 0] m_cache_axi_rdata,
    input wire [1 : 0] m_cache_axi_rresp,
    input wire  m_cache_axi_rlast,
    input wire  m_cache_axi_rvalid,
    output wire  m_cache_axi_rready
);

function integer clogb2 (input integer bit_depth);              
begin                                                           
for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
end                                                           
endfunction 

assign Req_ready = state == 2;

    axi_master_r #(
        .C_M_AXI_TARGET_SLAVE_BASE_ADDR(0),
        .C_M_AXI_DATA_WIDTH(64),
        .C_M_AXI_BURST_LEN(16)
    ) axi_master_r_Data(
    .m_axi_init_axi_read(read_begin),
    .m_axi_r_done(read_done),
    .m_axi_aclk(clk),
    .m_axi_aresetn(rstn),
    .m_axi_arid(m_cache_axi_arid),
    .m_axi_araddr(m_cache_axi_araddr),
    .m_axi_arlen(m_cache_axi_arlen),
    .m_axi_arsize(m_cache_axi_arsize),
    .m_axi_arburst(m_cache_axi_arburst),
    .m_axi_arlock(m_cache_axi_arlock),
    .m_axi_arcache(m_cache_axi_arcache),
    .m_axi_arprot(m_cache_axi_arprot),
    .m_axi_arqos(m_cache_axi_arqos),
    .m_axi_arvalid(m_cache_axi_arvalid),
    .m_axi_arready(m_cache_axi_arready),
    .m_axi_rid(m_cache_axi_rid),
    .m_axi_rdata(m_cache_axi_rdata),
    .m_axi_rresp(m_cache_axi_rresp),
    .m_axi_rlast(m_cache_axi_rlast),
    .m_axi_rvalid(m_cache_axi_rvalid),
    // .m_axi_rready(m_cache_axi_rready),
    .m_axi_rready(),
    .read_length(HASH_NUM / 16),
    .read_base_addr(HIT_ADDR)
    );

    reg ht_cmd_in_valid;
    ht_cmd_if  ht_cmd_in(clk);
    ht_res_if  ht_res_out(clk);




    always_comb begin 
        if(state == 1)begin
            ht_cmd_in.cmd.key = get_addr;
            ht_cmd_in.cmd.value = get_data;
            ht_cmd_in.cmd.opcode = OP_INSERT;
        end
        else if(state == 2)begin
            ht_cmd_in.cmd.opcode = OP_SEARCH;
            ht_cmd_in.cmd.key = Req_Addr;
        end
        else begin
            
        end
    end

    assign ht_cmd_in.valid =    (state == 1) ? ht_cmd_in_valid:0|
                                (state == 3) ? ht_cmd_in.ready & Req_valid:0;
    assign Post_Data = ht_res_out.result.found_value;
    assign Post_valid = ht_res_out.valid;
    assign ht_res_out.valid = Post_ready;
    assign Post_Success = ht_res_out.result.rescode == SEARCH_FOUND;

    logic add_data_sig;
    logic [31:0] get_addr;
    logic [63:0] get_data;
    assign m_axi_rready = ht_cmd_in.ready;
    always_ff @( posedge clk) begin
        if(~rstn)begin
            add_data_sig<=0;
        end
        else if(m_cache_axi_rvalid & m_cache_axi_rready)begin
            add_data_sig <= ~add_data_sig;
        end
    end

    always_ff @( posedge clk ) begin
        if(m_cache_axi_rvalid & m_cache_axi_rready & ~add_data_sig)begin
            get_addr <= m_cache_axi_rdata;
        end      
        else if(m_cache_axi_rvalid & m_cache_axi_rready & add_data_sig)begin
            get_data <= m_cache_axi_rdata;
        end
    end

    always_ff @( posedge clk ) begin
        if(state == 1)begin
            if(m_cache_axi_rvalid & m_cache_axi_rready & add_data_sig & ht_cmd_in.ready)begin
                ht_cmd_in_valid<=1;
            end
            else begin
                ht_cmd_in_valid<=0;
            end    
        end
    end
    logic [2:0] state = 0;
    logic read_begin;
    logic read_done;

    always_ff @( posedge clk ) begin
        if(~rstn)begin
           state<=0;
           read_begin <=0; 
        end
        else begin
            if(state<=0)begin
                read_begin<=1;
                state<=1;
            end
            else if(state==1)begin
                read_begin<=0;
                if(read_done)begin
                    state<=2;
                end
            end
        end
    end
    hash_table_top hash_table_top(
        .clk_i(clk),
        .rst_i(rstn),

        .ht_cmd_in(ht_cmd_in),
        .ht_res_out(ht_res_out)
    );

    
endmodule