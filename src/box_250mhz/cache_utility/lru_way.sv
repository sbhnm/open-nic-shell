`include "interface.vh"
// interface my_interface #(parameter DATA_WIDTH = 8);
//     // 数据信号
//     logic [DATA_WIDTH-1:0] data;
//     // 控制信号
//     logic enable, reset;

//     // 时钟信号
//     logic clk;

//     // 方法声明
//     task send_data(input logic [DATA_WIDTH-1:0] data);
//         // 在此添加发送数据的逻辑
//     endtask

//     task receive_data(output logic [DATA_WIDTH-1:0] received_data);
//         // 在此添加接收数据的逻辑
//     endtask

//     // 其他信号或方法
// endinterface

module lru_way #
(
    parameter integer TAGS_WIDTH = 48,
    
    parameter integer DATA_WIDTH=64,

    parameter integer CACHE_SIZE=512,

    parameter integer CACHE_DEPTH=8

    
)(
    input wire clk,
    input wire rstn
);
    
    stream #(TAGS_WIDTH)  fontend_addr_stream();
    stream #(DATA_WIDTH)  fontend_data_stream();
    stream #(TAGS_WIDTH)  backend_addr_stream();
    stream #(CACHE_DEPTH)  backend_data_stream();


    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction

    task swap_seq_mapping(
        output logic [clogb2(CACHE_DEPTH-1)-1:0]  new_seq_mapping [CACHE_DEPTH-1:0],
        input logic [clogb2(CACHE_DEPTH-1)-1:0]  pre_seq_mapping [CACHE_DEPTH-1:0],
        input logic [clogb2(CACHE_DEPTH-1)-1:0] hit_seq
    );
        for(int i = 0;i < hit_seq;i++) begin
            new_seq_mapping[i+1] = pre_seq_mapping[i];
        end
        new_seq_mapping[0] = pre_seq_mapping[hit_seq];
        for(int i =  CACHE_DEPTH-1 ; i >=  hit_seq+1;i--)begin
           new_seq_mapping[i] = pre_seq_mapping[i];
        end
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
       for(int i =  CACHE_DEPTH-1 ; i >=  hit_seq+1;i--)begin
           new_cache_tags[i] = pre_cache_tags[i];
       end
    endtask





    logic [CACHE_SIZE-1:0] cache_data [CACHE_DEPTH-1:0];

    logic [TAGS_WIDTH-1:0] cache_tags [CACHE_DEPTH-1:0];

    logic [clogb2(CACHE_DEPTH-1)-1:0]  seq_mapping [CACHE_DEPTH-1:0]; //管理从cache_tags存储器映射到哪个

    
 
    logic cache_hit;

    logic [clogb2(CACHE_DEPTH-1)-1:0] hit_seq;
    logic [CACHE_DEPTH-1:0] cache_line_hit;
     generate for(genvar i = 0;i<CACHE_DEPTH;i++)begin
        always_comb begin 
                cache_line_hit[i] = cache_tags[i] == fontend_addr_stream.tdata;
                if(cache_tags[i] == fontend_addr_stream.tdata) begin
                    hit_seq = i;
                end
            end
            
        end
     endgenerate
    assign cache_hit = | cache_line_hit;


    logic [TAGS_WIDTH-1:0] new_cache_tags [CACHE_DEPTH-1:0];

    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
            for(int i = 0;i<CACHE_DEPTH;i++)begin
                cache_tags[i]<= {TAGS_WIDTH{1'b0}} |32'hdeadc0de;
            end
        end
        else if(fontend_addr_stream.tvalid & fontend_addr_stream.tready) begin
            if(cache_hit) begin
                swap_cacheline(new_cache_tags,cache_tags,hit_seq);
                cache_tags<=new_cache_tags;
            end
            else if(~cache_hit)begin
                
            end
        end
        
    end
    logic [clogb2(CACHE_DEPTH-1)-1:0]  new_seq_mapping [CACHE_DEPTH-1:0];
    always @(posedge clk or negedge rstn) begin
        if(!rstn)begin
        end
        else if(fontend_addr_stream.tvalid & fontend_addr_stream.tready) begin
            if(cache_hit) begin
                swap_seq_mapping(new_seq_mapping,seq_mapping,hit_seq);
                seq_mapping<=new_seq_mapping;
            end
            else if(~cache_hit)begin
                

            end
        end
    end
endmodule