module shift_acc #(
    
) (
    input wire clk,
    input wire rstn,

    stream.slave data_shift_stream,

    input wire [7:0] input_acc_cs,
    input wire input_sign,

    input wire clr_valid,
    output wire clr_ready,
    output wire add_valid,
    
    stream.master res_pkt_stream

);
//对数据位移后，送入累加器


    localparam  ACC_DEPTH = 32;
    localparam PRE_REG_WIDTH =128;
    localparam PRE_REG_STEP = 64;
    wire [8:0] fifo_cs_dout; 
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end                 

    endfunction
    stream #(PRE_REG_WIDTH)  shifted_data();
    stream #(PRE_REG_WIDTH + clogb2(ACC_DEPTH-1))add_pkt_stream();


    stream #(PRE_REG_WIDTH + clogb2(ACC_DEPTH-1))add_pkt_stream_buffer();//在ready为0时，保持前一个周期的值

    // stream #(2*PRE_REG_WIDTH + clogb2(ACC_DEPTH-1)) res_pkt_stream;
    assign add_pkt_stream.tvalid = shifted_data.tvalid;
    
    assign add_pkt_stream.tdata = {fifo_cs_dout[1+:8],shifted_data.tdata[PRE_REG_WIDTH-1:0]};
    
    assign shifted_data.tready = add_pkt_stream.tready;
    wire input_sign_buf;
    Fifo #(
        .DATA_WIDTH(8 +1),
        .DEPTH(16)
    ) fifo_cs(
        .clk(clk),
        .rst(~rstn),
        .wr_en(data_shift_stream.tready & data_shift_stream.tvalid),
        .data_in({input_acc_cs , input_sign}),
        .data_out(fifo_cs_dout),
        .rd_en(shifted_data.tvalid & shifted_data.tready)
    ); 


    reg [PRE_REG_WIDTH + clogb2(ACC_DEPTH-1):0] input_data_buffer;
    
    assign add_pkt_stream_buffer.tdata = add_pkt_stream.tready ? add_pkt_stream.tdata : input_data_buffer[1+:PRE_REG_WIDTH + clogb2(ACC_DEPTH-1)];
    assign input_sign_buf = add_pkt_stream.tready ? fifo_cs_dout[0] : input_data_buffer[0];
    assign add_pkt_stream_buffer.tvalid = add_pkt_stream.tvalid;
    assign add_pkt_stream.tready = add_pkt_stream_buffer.tready;
    
    always @(posedge clk) begin
        if(shifted_data.tvalid & shifted_data.tready)
            input_data_buffer <= {add_pkt_stream.tdata,fifo_cs_dout[0]};
    end

    left_shifter #()
    left_shifter
    (
        .clk(clk),
        .rstn(rstn),
        .data_shift_stream(data_shift_stream),
        .data_out(shifted_data)
    );
    acc_kern_cache #(
        .DEPTH(ACC_DEPTH),
        .PRE_REG_WIDTH(PRE_REG_WIDTH),
        .PRE_REG_STEP(PRE_REG_STEP)
    )acc_kern
    (
        .clk(clk),
        .rstn(rstn),
        .clr_ready(clr_ready),
        .clr_valid(clr_valid),
        .add_valid(add_valid),
        .input_sign(input_sign_buf),
        .add_pkt_stream(add_pkt_stream_buffer),
        .res_pkt_stream(res_pkt_stream)
    );


endmodule