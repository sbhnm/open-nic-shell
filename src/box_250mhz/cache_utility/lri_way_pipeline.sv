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
    reg [3:0] lru_fsm_state;



    task swap_seq_mapping(
        output logic [clogb2(CACHE_DEPTH-1)-1:0]  new_seq_mapping [CACHE_DEPTH-1:0],
        input logic [clogb2(CACHE_DEPTH-1)-1:0]  pre_seq_mapping [CACHE_DEPTH-1:0],
        input logic [clogb2(CACHE_DEPTH-1)-1:0] hit_seq
    );
        for(int i =  0 ; i < CACHE_DEPTH;i++)begin
           new_seq_mapping[i] = pre_seq_mapping[i];
        end
        for(int i = 0;i < hit_seq;i++) begin
            new_seq_mapping[i+1] = pre_seq_mapping[i];
        end
        new_seq_mapping[0] = pre_seq_mapping[hit_seq];
    endtask


    task swap_cacheline(
        output logic [TAGS_WIDTH-1:0] new_cache_tags [CACHE_DEPTH-1:0],
        input logic [TAGS_WIDTH-1:0] pre_cache_tags [CACHE_DEPTH-1:0],
        input logic [clogb2(CACHE_DEPTH-1)-1:0] hit_seq
        );
        
        for(int i = 0;i < hit_seq;i++) begin
            new_cache_tags[i+1] = pre_cache_tags[i];
        end
        new_cache_tags[0] = pre_cache_tags[hit_seq];
       
    endtask



    

    always @(posedge clk) begin
        if(~rstn)begin
            lru_fsm_state<=0;
        end
        else begin
            if(lru_fsm_state ==0)begin
                if(~cache_hit)begin
                //进入 置换状态
                    lru_fsm_state<=1;
                end
                else if(cache_hit)begin
                    // 连续命中
                    lru_fsm_state<=0;
                end    
            end 
            
        end
    end
endmodule