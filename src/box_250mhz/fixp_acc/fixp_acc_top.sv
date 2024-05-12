module fixp_acc_top #(
    parameter SHIHT_WIDTH = 128,
    parameter ACC_DEPTH = 32
    
) (
    input clk,
    input rstn,

    input wire clr_valid,
    output wire clr_ready,
    output wire add_valid,
    stream.slave fp64_stream,
    stream.master fp64_sum_stream
    

);
    function integer clogb2 (input integer bit_depth);              
    begin                                                           
    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
    bit_depth = bit_depth >> 1;                                 
    end     
    endfunction
    wire        input_sign;
    wire [52:0] input_frac;
    wire [10:0] input_expo;

    assign input_expo = fp64_stream.tdata[52+:11];
    
    
    assign input_frac = fp64_stream.tdata == 0 ? 0:{1'b1,fp64_stream.tdata[0+:52]};


    assign input_sign = fp64_stream.tdata[63];
    //assign input_sign =0;
    
    
    wire [7:0] input_acc_cs;
    wire [clogb2(SHIHT_WIDTH-1)-1:0] shift_len;
    wire [clogb2(SHIHT_WIDTH-1)-1:0] shift_bias;
    assign shift_bias =  32'h40;
    // reg [clogb2(SHIHT_WIDTH-1)-1:0] shift_len_buf;
    reg [7:0] input_acc_cs_buf;
    assign input_acc_cs =  fp64_stream.tdata != 0 ?((input_expo +1) / 64) :input_acc_cs_buf;

    wire [15:0] exp_base;
    assign exp_base = input_acc_cs * 64;
    assign shift_len = input_expo+1 - exp_base;
    always @(posedge clk ) begin
        if(~rstn)begin
            input_acc_cs_buf <= 0;
        end
        else if(fp64_stream.tdata != 0)begin
            input_acc_cs_buf <=input_acc_cs;
        end
        
    end
    
    stream #(clogb2(SHIHT_WIDTH-1) + SHIHT_WIDTH)  shift_data_stream_p();
    
    stream #(2*SHIHT_WIDTH + clogb2(ACC_DEPTH-1) +1)  res_pkt_stream_p();

    wire [SHIHT_WIDTH-1:0] ff_ff;
    generate for (genvar i = 0; i < SHIHT_WIDTH; i++) begin
        assign ff_ff[i] = 1;
    end
    endgenerate

    assign shift_data_stream_p.tdata = input_sign ? {ff_ff,(~input_frac+1),shift_len}:{0,input_frac,shift_len};
    
    // assign shift_data_stream_p.tdata =  {0,input_frac,shift_len};

    assign shift_data_stream_p.tvalid = fp64_stream.tvalid;
    assign fp64_stream.tready = shift_data_stream_p.tready;

    

    shift_acc #()shift_acc_p(
        .clk(clk),
        .rstn(rstn),
        .data_shift_stream(shift_data_stream_p),
        .input_acc_cs(input_acc_cs),
        .input_sign(input_sign),
        .clr_valid(clr_valid),
        .clr_ready(clr_ready),
        .add_valid(add_valid),
        .res_pkt_stream(res_pkt_stream_p)
    );   



    fixpkt2fp64 #()fixpkt2fp64_p(
        .clk(clk),
        .rstn(rstn),
        .ptk_in_stream(res_pkt_stream_p),
        .fp64_out_stream(fp64_sum_stream)
    ); 
    // stream #(clogb2(SHIHT_WIDTH-1) + SHIHT_WIDTH)  shift_data_stream_n();

     
    
endmodule