module ppcache_s #(
    parameter integer DATA_WIDTH	= 32,
    parameter integer DATA_DEPTH	= 1024,
    parameter integer ADDR_WIDTH    = 10
) (
    //input line
    select_vaild,
    select,

    input_ready,
    input_vaild,
    input_data,

    output_ready,
    output_vaild,
    output_data,
    clk,
    rstn
);
    input wire clk;
    input wire rstn;

    input wire select_vaild;
    input wire select;
    
    output wire input_ready;
    input wire input_vaild;
    input wire[DATA_WIDTH-1:0] input_data;

    input wire output_ready;
    output reg output_vaild;
    output wire[DATA_WIDTH-1:0] output_data;

    reg area_en;
    reg[ADDR_WIDTH:0] wpos[1:0];
    

    reg [DATA_WIDTH-1:0] data [DATA_DEPTH-1:0][1:0];

    assign input_ready = wpos[1-area_en] < DATA_DEPTH;

    assign output_data = data[wpos[area_en]][area_en];


    always @(posedge clk or negedge rstn) begin
        if(select_vaild)begin
            wpos[0]<=0;
            wpos[1]<=0;
            area_en<=select;
        end
        if (input_vaild) begin
            data[wpos[1-area_en]][1-area_en] <= input_data;
        end
        output_vaild <= output_ready;
        if(output_ready)begin
            wpos[area_en] <= wpos[area_en] +1;
        end

    end


endmodule