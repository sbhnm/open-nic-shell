module first_bit_checker #(
    parameter FIXP_WIDTH = 192, //需要检查的长度
    parameter CHECK_WIDTH = 16 // 单次检查的长度
) (
    input clk,
    input rstn,

    stream.slave fixp_in_stream,
    stream.master fixp_out_stream
);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction

    localparam PP_CYC = FIXP_WIDTH/CHECK_WIDTH;
    reg [clogb2(FIXP_WIDTH-1)-1:0] pp_bit_info [PP_CYC:0];
    reg pp_bit_info_find [PP_CYC:0];
    reg [FIXP_WIDTH-1:0] pp_data_info [PP_CYC:0];

    reg  pp_data_valid [PP_CYC:0];

    logic [clogb2(CHECK_WIDTH-1)-1:0] bits_pos[PP_CYC:0];
    logic  bits_pos_find[PP_CYC:0];


    always @(posedge clk) begin
        if(~rstn)begin
            pp_data_valid[0]<=0;
            pp_bit_info_find[0]<=0;
        end
        else begin
            
            pp_data_valid[0]<=fixp_in_stream.tvalid & fixp_in_stream.tready;
            pp_bit_info_find[0]<=0;
            pp_bit_info[0]<=0;
            pp_data_info[0]<=fixp_in_stream.tdata;
        
        end
    end
    generate
    
    for (genvar i = 1; i <= PP_CYC; i++) begin
        get_chk_first_bit #(16) get_chk_first_bit(
            .chk_bits(pp_data_info[i-1][CHECK_WIDTH*(PP_CYC -i)+:CHECK_WIDTH]),
            .bits_pos(bits_pos[i]),
            .bits_pos_find(bits_pos_find[i])
        );

        always @(posedge clk) begin
            if(~rstn)begin
                pp_data_valid[i]<=0;
                pp_bit_info_find[i]<=0;        
            end
            else begin
                if(fixp_out_stream.tready)begin
                    pp_data_valid[i] <= pp_data_valid[i-1];
                    pp_data_info[i] <= pp_data_info[i-1];
                    pp_bit_info_find[i]<=pp_bit_info_find[i-1];
                    if(pp_data_valid[i-1])begin
                        if(pp_bit_info_find[i-1]==0)begin
                            // get_chk_first_bit(pp_data_info[CHECK_WIDTH*(PP_CYC -1-i):+CHECK_WIDTH],bits_pos[i],bits_pos_find[i])
                            pp_bit_info[i] <= bits_pos[i] + CHECK_WIDTH*(i-1);
                            pp_bit_info_find[i] <=bits_pos_find[i];
                        end
                        else begin
                            pp_bit_info[i]<=pp_bit_info[i-1];
                            pp_bit_info_find[i]<=pp_bit_info_find[i-1];
                        end
                    end
                
                end
            end
        end
    end
    endgenerate
    assign fixp_in_stream.tready =  fixp_out_stream.tready;
    assign fixp_out_stream.tvalid = pp_data_valid[PP_CYC];
    assign fixp_out_stream.tdata = {pp_data_info[PP_CYC],pp_bit_info[PP_CYC],pp_bit_info_find[PP_CYC]};
    
endmodule