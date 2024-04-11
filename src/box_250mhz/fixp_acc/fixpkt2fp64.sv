module fixpkt2fp64 #(
    parameter  PRE_REG_WIDTH = 128,
    parameter DEPTH = 32,
    parameter PRE_REG_STEP = 64
) (
    input clk,
    input rstn,
    stream.slave ptk_in_stream,
    stream.master fp64_out_stream
);
    localparam EXPO_BIAS = PRE_REG_STEP;
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction
    wire [PRE_REG_WIDTH-1:0] data_lmb;
    wire [PRE_REG_WIDTH-1:0] data_msb;
    
    wire [clogb2(DEPTH-1)-1 :0] expo_cs;
    wire [11:0] data_expo;
    
    assign expo_cs = ptk_in_stream.tdata[clogb2(DEPTH-1)-1:0];
    assign data_lmb = ptk_in_stream.tdata[clogb2(DEPTH-1)+:PRE_REG_WIDTH];
    assign data_msb = ptk_in_stream.tdata[clogb2(DEPTH-1)+PRE_REG_WIDTH+:PRE_REG_WIDTH];
    

    assign data_expo = expo_cs * PRE_REG_STEP -EXPO_BIAS;
    wire [PRE_REG_STEP + PRE_REG_WIDTH-1:0] data_frac;
    assign data_frac = expo_cs ==0? data_lmb : ({64'h0,data_lmb} + {data_msb,64'h0});//how to normlize？
    
    stream # (PRE_REG_STEP + PRE_REG_WIDTH) fixp_in_stream();
    
    assign fixp_in_stream.tvalid = ptk_in_stream.tvalid;
    assign fixp_in_stream.tdata = data_frac;
    assign ptk_in_stream.tready = fixp_in_stream.tready;

    
    stream # (192 +clogb2(192-1)) shift_data_stream();
    stream # (192 +clogb2(192-1) +1) fixp_out_stream();
    stream #(192)  shifter_data_out();

    assign shift_data_stream.tvalid = fixp_out_stream.tvalid;
    assign shift_data_stream.tdata = fixp_out_stream.tdata[1+:192 +clogb2(192-1)];
    assign fixp_out_stream.tready = shift_data_stream.tready;
    
    first_bit_checker first_bit_checker(
        .clk(clk),
        .rstn(rstn),
        .fixp_in_stream(fixp_in_stream),
        .fixp_out_stream(fixp_out_stream)
    );
    
    wire [clogb2(192-1)-1:0] fifo_shift_len_dout;
    wire [12-1:0] fifo_expo_bias_dout;
    
    Fifo #(
        .DATA_WIDTH(clogb2(192-1)),
        .DEPTH(16)
    ) fifo_shift_len(
        .clk(clk),
        .rst(~rstn),
        .wr_en(shift_data_stream.tready & shift_data_stream.tvalid),
        .data_in(fixp_out_stream.tdata[1+:clogb2(192-1)]),
        .data_out(fifo_shift_len_dout),
        .rd_en(shifter_data_out.tvalid & shifter_data_out.tready)
    ); 
    Fifo #(
        .DATA_WIDTH(12),
        .DEPTH(32)
    ) fifo_expo_bias(
        .clk(clk),
        .rst(~rstn),
        .wr_en(fixp_in_stream.tready & fixp_in_stream.tvalid),
        .data_in(data_expo),
        .data_out(fifo_expo_bias_dout),
        .rd_en(shifter_data_out.tvalid & shifter_data_out.tready)
    ); 

    left_shifter #(
        .SHIHT_WIDTH(PRE_REG_STEP + PRE_REG_WIDTH)
    )left_shifter
    (
        .clk(clk),
        .rstn(rstn),
        .data_shift_stream(shift_data_stream),
        .data_out(shifter_data_out)
    );
    assign fp64_out_stream.tvalid = shifter_data_out.tvalid;
    // assign fp64_out_stream.tdata = {1'b0,shifter_data_out.tdata[139:190],(fifo_expo_bias_dout - fifo_shift_len_dout)}; //sgin frac expo
    assign fp64_out_stream.tdata[63] = 0; //sgin frac expo
    assign fp64_out_stream.tdata[62:11] = shifter_data_out.tdata[190:139]; //sgin frac expo
    assign fp64_out_stream.tdata[10:0] = fifo_expo_bias_dout - fifo_shift_len_dout; //sgin frac expo
    
    
    assign shifter_data_out.tready = fp64_out_stream.tready;


endmodule