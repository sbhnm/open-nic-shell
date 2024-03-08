#`include "system_ifc.vh"
module lru#(
    parameter LUR_DEPTH = 16,
    parameter CACHE_WAY = 4,
    parameter CACHE_SIZE = 512,

    parameter ADDR_WIDTH = 48,
    
    parameter FONTEND_DATA_WIDTH=64,
    parameter FONTEND_ID_WIDTH=1,

    parameter BACKEND_DATA_WIDTH=512,
    parameter BACKEND_ID_WIDTH=1
    
    )
(
    axi_4.slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(FONTEND_DATA_WIDTH),
        .ID_WIDTH(FONTEND_ID_WIDTH),
    ) 
    axi_fontend(),
    axi_4.slave #(
        .ADDR_WIDTH(ADDR_WIDTH),
        .DATA_WIDTH(BACKEND_DATA_WIDTH),
        .ID_WIDTH(BACKEND_ID_WIDTH),
    ) 
    axi_backend(),

);
    function integer clogb2 (input integer bit_depth);              
  	begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
      bit_depth = bit_depth >> 1;                                 
    end                                                           
  	endfunction

    localparam offset_bit_width = clogb2(CACHE_SIZE-1);
    localparam way_bit_width = clogb2(CACHE_WAY-1);
    localparam tags_bit_width = ADDR_WIDTH - offset_bit_width - way_bit_width;

    wire [offset_bit_width-1:0] req_addr_offset;
    wire [way_bit_width-1:0] req_addr_way;
    wire [tags_bit_width-1:0] req_addr_tags;


    assign 
    
    axi_fontend req_addr_offset = axi_fontend.ARADDR[0+:offset_bit_width];
    axi_fontend req_addr_way = axi_fontend.ARADDR[offset_bit_width+:way_bit_width];
    axi_fontend req_addr_tags = axi_fontend.ARADDR[offset_bit_width+way_bit_width+:tags_bit_width];

    
    
    


    

     
endmodule