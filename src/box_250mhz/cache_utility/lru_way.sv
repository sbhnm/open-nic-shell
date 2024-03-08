module lru_way #
(
    parameter integer TAGS_WIDTH,
    parameter integer DATA_WIDTH,
    parameter integer CACHE_SIZE,

    
    
)(
    input wire clk,
    input wire rstn,

    input wire [TAGS_WIDTH-1:0] cache_tags,

    output wire [DATA_WIDTH-1:0] cache_data,



);
    
endmodule