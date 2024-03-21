`include "interface.vh"


module lru_way #
(
    parameter integer TAGS_WIDTH = 48,

    parameter integer CACHE_SIZE=512,

    parameter integer DATA_PORT_SIZE=512,

    parameter integer CACHE_DEPTH=8


    
)(
    input wire clk,
    input wire rstn,

    stream.slave   fontend_addr_stream,
    stream.master   fontend_data_stream,
    stream.master   backend_addr_stream,
    stream.slave   backend_data_stream
);
    // always @(posedge rstn) begin
    //     fontend_addr_stream.tready=1;    
    // end
    

    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction
    always @(*) begin
        fontend_data_stream.tvalid = fontend_data_stream.tready & cache_hit;
        fontend_data_stream.tdata = cache_data[seq_mapping[0]];
    end
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


    logic [TAGS_WIDTH-1:0] req_tags_buffer;
    always_comb begin
        backend_data_stream.tready=1;
    end

    // task read_from_backend(
    //     logic [TAGS_WIDTH-1:0] req_tags
    // ); 
        
    //         wait(backend_addr_stream.tready);

    //         @(posedge clk);
    //         backend_addr_stream.tvalid=1;
    //         backend_addr_stream.tdata=req_tags;
    //         req_tags_buffer = req_tags;
            
    //         wait(~clk);
    //         backend_addr_stream.tvalid=0;
    //         backend_addr_stream.tdata=0;
            
    //         wait(backend_data_stream.tvalid);

    //         cache_tags[CACHE_DEPTH-1] = req_tags_buffer;
    //         cache_data[seq_mapping[CACHE_DEPTH-1]] = backend_data_stream.tdata;
            
    // endtask

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


    logic [TAGS_WIDTH-1:0] new_cache_tags [CACHE_DEPTH-1:0];
    logic [clogb2(CACHE_DEPTH-1)-1:0]  new_seq_mapping [CACHE_DEPTH-1:0];
    logic [2:0] cache_miss_fsm_status;
    logic [4:0] data_ptr;
    always @(posedge clk) begin
        if(!rstn)begin
            fontend_addr_stream.tready<=1;
            cache_miss_fsm_status = 0;
            data_ptr <=0;
            for(int i = 0;i<CACHE_DEPTH;i++)begin
                seq_mapping[i] <= i;
            end

            for(int i = 0;i<CACHE_DEPTH;i++)begin
                cache_tags[i]<= {TAGS_WIDTH{1'b0}} |32'hdeadc0de;
            end
        end
        
        else if(cache_miss_fsm_status == 0 & fontend_addr_stream.tvalid & fontend_addr_stream.tready) begin
            if(cache_hit) begin
                swap_cacheline(new_cache_tags,cache_tags,hit_seq);
                cache_tags<=new_cache_tags;
                swap_seq_mapping(new_seq_mapping,seq_mapping,hit_seq);
                seq_mapping<=new_seq_mapping;
                fontend_addr_stream.tready<=1;
            end
            if(~cache_hit)begin
                if(cache_miss_fsm_status == 0)begin
                    cache_miss_fsm_status <= 1;
                    fontend_addr_stream.tready<=0;
                end
            end
        end
        else if(cache_miss_fsm_status == 1)begin
            if(backend_fsm_status==2 & backend_data_stream.tvalid) begin
                data_ptr<=data_ptr+1;
                if(data_ptr==(CACHE_SIZE/DATA_PORT_SIZE)-1)begin
                    cache_miss_fsm_status <= 0;
                end
                fontend_addr_stream.tready<=1;
                cache_tags[CACHE_DEPTH-1] <= req_tags_buffer;
                cache_data[seq_mapping[CACHE_DEPTH-1]] <= {cache_data[seq_mapping[CACHE_DEPTH-1]][CACHE_SIZE-DATA_PORT_SIZE-1:0] , backend_data_stream.tdata};
                
                swap_cacheline(new_cache_tags,cache_tags,CACHE_DEPTH-1);
                cache_tags<=new_cache_tags;
                
                swap_seq_mapping(new_seq_mapping,seq_mapping,CACHE_DEPTH-1);
                seq_mapping<=new_seq_mapping;
            end
        end
        
    end
    logic [2:0] backend_fsm_status;
    always @(posedge clk) begin
        if(~rstn)begin
            backend_fsm_status <= 0;
            backend_addr_stream.tvalid<=0;
            backend_addr_stream.tdata<=0;
                
        end
        else begin
            if(backend_fsm_status == 0 )begin
                if(cache_miss_fsm_status ==1) begin
                    backend_addr_stream.tvalid<=1;
                    backend_addr_stream.tdata<=fontend_addr_stream.tdata;
                    req_tags_buffer <= fontend_addr_stream.tdata;
                    if(backend_addr_stream.tready & backend_addr_stream.tvalid)begin
                        backend_fsm_status <= 1;
                        backend_addr_stream.tvalid<=0;
                        backend_addr_stream.tdata<=0;
                    end
                    
                end
            end
            if(backend_fsm_status==1)begin
                backend_fsm_status <= 2;
            end
            if(backend_fsm_status==2) begin
                if(backend_data_stream.tvalid)begin
                    backend_fsm_status<= 0;
                end
            end 
            

        end
    end
    

endmodule