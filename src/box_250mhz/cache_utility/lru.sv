//#`include "system_ifc.vh"
module lru#(
    parameter LRU_DEPTH = 16,
    parameter CACHE_SIZE = 512,

    parameter ADDR_WIDTH = 48,
    
    parameter FONTEND_DATA_WIDTH=64,
    parameter FONTEND_ID_WIDTH=1,

    parameter BACKEND_DATA_WIDTH=512,
    parameter BACKEND_ID_WIDTH=1
    
    )
(
    input wire clk,
    input wire rstn,

    axi4.slave axi_fondend_req,
    axi4.master axi_backend_req
);

    parameter int TAGS_WIDTH = ADDR_WIDTH - clogb2(CACHE_SIZE/8-1);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end   
    endfunction
    
    // 前端，直接连线

    always_comb begin
        fontend_addr_stream.tvalid = axi_fondend_req.ARVALID;
        fontend_addr_stream.tdata = axi_fondend_req.ARADDR[TAGS_WIDTH-1:0];
        axi_fondend_req.ARREADY = fontend_addr_stream.tready;

        axi_fondend_req.RVALID = fontend_data_stream.tvalid;
        axi_fondend_req.RDATA = fontend_data_stream.tdata;
        fontend_data_stream.tready= axi_fondend_req.RREADY;
    end
    always @(negedge rstn) begin
        axi_backend_req.ARLEN = (CACHE_SIZE/BACKEND_DATA_WIDTH) -1;
        axi_backend_req.ARID = 0;
        axi_backend_req.ARSIZE=clogb2((BACKEND_DATA_WIDTH/8)-1);
        axi_backend_req.ARBURST= 2'b01;
        axi_backend_req.ARLOCK= 1'b0;
        axi_backend_req.ARCACHE= 4'b0010;
        axi_backend_req.ARPROT= 3'h0;
        axi_backend_req.ARQOS= 4'h0;

    end
    always_comb begin
        axi_backend_req.ARVALID = backend_addr_stream.tvalid;
        axi_backend_req.ARADDR = backend_addr_stream.tdata <<(ADDR_WIDTH-TAGS_WIDTH);
        backend_addr_stream.tready = axi_backend_req.ARREADY;

        backend_data_stream.tvalid = axi_backend_req.RVALID;
        backend_data_stream.tdata = axi_backend_req.RDATA;
        axi_backend_req.RREADY = backend_data_stream.tready;
    end    

    always_comb begin
    end
    stream #(ADDR_WIDTH)  fontend_addr_stream();
    stream #(FONTEND_DATA_WIDTH)  fontend_data_stream();
    
    // 后端，促发传输支持
    stream #(ADDR_WIDTH)  backend_addr_stream();
    stream #(BACKEND_DATA_WIDTH)  backend_data_stream();

    lru_way_pipeline #(
        .CACHE_DEPTH(LRU_DEPTH),
        .CACHE_SIZE(CACHE_SIZE),
        .TAGS_WIDTH(TAGS_WIDTH),
        .DATA_PORT_SIZE(BACKEND_DATA_WIDTH)
    )  lru_way_inst (
        .clk(clk),
        .rstn(rstn),
        .fontend_addr_stream(fontend_addr_stream),
        .fontend_data_stream(fontend_data_stream),
        .backend_addr_stream(backend_addr_stream),
        .backend_data_stream(backend_data_stream)
    );
     
endmodule