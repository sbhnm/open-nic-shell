// 对cache添加pipeline 支持
module lru_way_pipeline #(
    parameter integer TAGS_WIDTH = 48,

    parameter integer CACHE_SIZE=512,

    parameter integer DATA_PORT_SIZE=512,

    parameter integer CACHE_DEPTH=8

) (
    input wire clk,
    input wire rstn,

    
    stream.slave   fontend_addr_stream,
    stream.master   fontend_data_stream,
    stream.master   backend_addr_stream,
    stream.slave   backend_data_stream

);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction


    logic [CACHE_SIZE-1:0] cache_data [CACHE_DEPTH-1:0];

    logic [TAGS_WIDTH-1:0] cache_tags [CACHE_DEPTH-1:0];

    logic [clogb2(CACHE_DEPTH-1)-1:0]  seq_mapping [CACHE_DEPTH-1:0]; //管理从cache_tags存储器映射到哪个

    
 
    wire cache_hit;

    wire [clogb2(CACHE_DEPTH-1)-1:0] hit_seq;
    wire [clogb2(CACHE_DEPTH-1)-1:0] hit_seq_v [CACHE_DEPTH-1:0];
    wire [CACHE_DEPTH-1:0] cache_line_hit;
     generate for(genvar i = 0;i<CACHE_DEPTH;i++)begin
        assign cache_line_hit[i] = cache_tags[i] == fontend_addr_stream.tdata;

        assign hit_seq_v[i] = (cache_tags[i] == fontend_addr_stream.tdata) ? i :0;
        end
        
     endgenerate
    assign hit_seq =  {hit_seq_v[0]|hit_seq_v[1]|hit_seq_v[2]|hit_seq_v[3]|hit_seq_v[4]|hit_seq_v[5]|hit_seq_v[6]|hit_seq_v[7]};
    assign cache_hit = | cache_line_hit;
    wire Hit_Fifo_full;
    wire Hit_Fifo_empty;
    wire Hit_Fifo_read;
    assign fontend_addr_stream.tready = ~Hit_Fifo_full;
    wire [clogb2(CACHE_DEPTH-1):0] Hit_Fifo_data_out;
    // 一级流水，形成是否命中
    Fifo #(
        .DATA_WIDTH(clogb2(CACHE_DEPTH-1)-1 +1),
        .DEPTH(4)
    ) Hit_Fifo(
        .clk(clk),
        .rst(!rstn),
        .wr_en(fontend_addr_stream.tvalid & fontend_addr_stream.tready ),
        .data_in({cache_hit,hit_seq}),
        .full(Hit_Fifo_full),
        .data_out(Hit_Fifo_data_out),
        .empty(Hit_Fifo_empty),
        .rd_en(!Hit_Fifo_empty& ),
    );
    // 二级流水，阻塞未命中 
    // 当遇到未命中的Tag时，首先进行读取，
    // 读取完成后，应当进行前递

    //

    
    reg [3:0] cache_fsm_status;
    always@(posedge clk)begin
        if(~rstn)begin
            cache_fsm_status<=0;
        end
        else begin
            if(cache_fsm_status==0)begin
                if(!Hit_Fifo_empty)begin
                    if()begin
                    end



                end
            end
        end
    end
endmodule