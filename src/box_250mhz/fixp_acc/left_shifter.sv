module left_shifter #(
    parameter SHIHT_WIDTH = 128

) (
    input clk,
    input rstn,

    stream.slave data_shift_stream,
    stream.master data_out
);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end     
    endfunction
    
    wire [clogb2(SHIHT_WIDTH-1)-1:0]input_shift_len;
    wire [(SHIHT_WIDTH-1):0]input_shift_data;
    
    assign input_shift_len = data_shift_stream.tdata[clogb2(SHIHT_WIDTH-1)-1:0];
    assign input_shift_data = data_shift_stream.tdata[clogb2(SHIHT_WIDTH-1)+:SHIHT_WIDTH];

    logic [clogb2(SHIHT_WIDTH-1)-1:0] pipeline_len [clogb2(SHIHT_WIDTH-1):0];//
    logic [SHIHT_WIDTH-1:0] pipeline_data [clogb2(SHIHT_WIDTH-1):0]; 
    logic [clogb2(SHIHT_WIDTH-1):0] pipeline_valid;

    assign data_shift_stream.tready = data_out.tready;
    assign data_out.tvalid = pipeline_valid[clogb2(SHIHT_WIDTH-1)];
    assign data_out.tdata = pipeline_data[clogb2(SHIHT_WIDTH-1)];
    

    always @(posedge clk) begin
        // if(data_shift_stream.tvalid & data_shift_stream.tready)begin
            pipeline_valid[0] = data_shift_stream.tvalid& data_shift_stream.tready;
            pipeline_len[0] = input_shift_len;
            pipeline_data[0] = input_shift_data;    
        // end
    end
    generate for (genvar i = 1; i < clogb2(SHIHT_WIDTH-1)+1; i++) begin
        always @(posedge clk) begin
            if(data_out.tready)begin
                pipeline_valid[i] <= pipeline_valid[i-1];
                pipeline_len[i]<=pipeline_len[i-1];
                if(pipeline_valid[i-1])begin
                    if(pipeline_len[i-1][i-1])begin
                        pipeline_data[i]<=pipeline_data[i-1] << (1<<(i-1));
                    end
                    else begin
                        pipeline_data[i]<=pipeline_data[i-1];
                    end
                end    
            end
            
        end
    end    
    endgenerate
endmodule