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
    assign cache_hit = cache_line_hit[0] |cache_line_hit[1]|cache_line_hit[2]|cache_line_hit[3]|cache_line_hit[4]|cache_line_hit[5]|cache_line_hit[6]|cache_line_hit[7];
    // assign hit_seq =  {hit_seq_v[0]|hit_seq_v[1]|hit_seq_v[2]|hit_seq_v[3]};
    
    // assign cache_hit = | cache_line_hit;
    reg [3:0] lru_fsm_state;

    reg cache_hit_pre;
    reg [clogb2(CACHE_DEPTH-1)-1:0] hit_seq_pre;
    wire [clogb2(CACHE_DEPTH-1)-1:0] hit_seq_de_swap;
    assign hit_seq_de_swap = (hit_seq_de_swap_pre == hit_seq_pre)? 0:0|
                            (hit_seq_de_swap_pre < hit_seq_pre)? hit_seq_pre:0|
                            (hit_seq_de_swap_pre > hit_seq_pre)? (hit_seq_pre+1):0;

    reg [clogb2(CACHE_DEPTH-1)-1:0] hit_seq_de_swap_pre;

    reg [TAGS_WIDTH-1:0] tags_pre;

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
        if(~rstn) begin
            cache_hit_pre<=0;
            hit_seq_pre<=0;
            // hit_seq_de_swap<=0;
            hit_seq_de_swap_pre<=0;
        end
        else begin
            if(fontend_addr_stream.tvalid & fontend_addr_stream.tready)begin
                cache_hit_pre<=cache_hit;
                hit_seq_pre<=hit_seq;
                hit_seq_de_swap_pre <= hit_seq_de_swap;
                tags_pre <= fontend_addr_stream.tdata;
                end
        end
    end
    logic cahce_font_valid_pre;
    always @(posedge clk) begin
        cahce_font_valid_pre <= fontend_addr_stream.tvalid & fontend_addr_stream.tready;
    end
    // form and back;
    always @(*) begin
        fontend_data_stream.tvalid = 
                (fontend_data_stream.tready & cahce_font_valid_pre & lru_fsm_state == 0) | 
                (fontend_data_stream.tready & lru_fsm_state == 2);
        fontend_data_stream.tdata = (lru_fsm_state == 0? cache_data[seq_mapping[hit_seq_de_swap]] : 0)|
                                    (lru_fsm_state == 2? cache_data[seq_mapping[CACHE_DEPTH-1]] : 0);
    end

    // swap
    logic [TAGS_WIDTH-1:0] new_cache_tags [CACHE_DEPTH-1:0];
    logic [clogb2(CACHE_DEPTH-1)-1:0]  new_seq_mapping [CACHE_DEPTH-1:0];

    logic [TAGS_WIDTH-1:0] req_tags_buffer;
    always_comb begin
        backend_data_stream.tready=1;
    end
    logic [4:0] data_ptr;

    always @(posedge clk) begin
        if(~rstn)begin
            lru_fsm_state<=0;
            data_ptr <=0;

            backend_addr_stream.tvalid<=0;
            backend_addr_stream.tdata<=0;
            fontend_addr_stream.tready<=1;
            for(int i = 0;i<CACHE_DEPTH;i++)begin
                seq_mapping[i] <= i;
            end

            for(int i = 0;i<CACHE_DEPTH;i++)begin
                cache_tags[i]<= {TAGS_WIDTH{1'b0}} |32'hdeadc0de;
            end
             
        end
        else begin
            if(lru_fsm_state ==0)begin
                backend_addr_stream.tvalid<=0;
                backend_addr_stream.tdata<=0;
                if(~cache_hit & fontend_addr_stream.tvalid & fontend_addr_stream.tready)begin
                    //进入 置换状态
                    lru_fsm_state<=1;
                    data_ptr<=0;
                    fontend_addr_stream.tready<=0;
                end
                else if(cache_hit & fontend_addr_stream.tvalid & fontend_addr_stream.tready)begin
                    // 连续命中
                    lru_fsm_state<=0;

                end
                if(cache_hit_pre!=0 &fontend_addr_stream.tvalid & fontend_addr_stream.tready)begin
                    swap_cacheline(new_cache_tags,cache_tags,hit_seq_de_swap);
                    cache_tags<=new_cache_tags;
                    swap_seq_mapping(new_seq_mapping,seq_mapping,hit_seq_de_swap);
                    seq_mapping<=new_seq_mapping;
                    
                end
            end 
            if(lru_fsm_state == 1)begin //发起请求，等待返回

                backend_addr_stream.tvalid<=1;
                backend_addr_stream.tdata<=tags_pre;
                req_tags_buffer <= tags_pre;

                if(backend_addr_stream.tready & backend_addr_stream.tvalid)begin
                    backend_addr_stream.tvalid<=0;
                    backend_addr_stream.tdata<=0;
                end
                if(backend_data_stream.tvalid & backend_data_stream.tready)begin
                    data_ptr<=data_ptr+1;
                    if(data_ptr==(CACHE_SIZE/DATA_PORT_SIZE)-1)begin
                        lru_fsm_state <= 2;
                    end
                    cache_tags[CACHE_DEPTH-1] <= req_tags_buffer;
                    cache_data[seq_mapping[CACHE_DEPTH-1]] <= req_tags_buffer;
                    // cache_data[seq_mapping[CACHE_DEPTH-1]] <= {cache_data[seq_mapping[CACHE_DEPTH-1]][CACHE_SIZE-DATA_PORT_SIZE-1:0] , backend_data_stream.tdata};
                end
            end
            if(lru_fsm_state ==2)begin //置换
                fontend_addr_stream.tready<=1;
                swap_cacheline(new_cache_tags,cache_tags,CACHE_DEPTH-1);
                cache_tags<=new_cache_tags;
                swap_seq_mapping(new_seq_mapping,seq_mapping,CACHE_DEPTH-1);
                seq_mapping<=new_seq_mapping;
                
                lru_fsm_state<=0;

            end
            
        end
    end
endmodule