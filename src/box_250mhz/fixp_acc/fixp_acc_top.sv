module fixp_acc_top #(
    parameter SHIHT_WIDTH = 128,
    parameter ACC_DEPTH = 32
    
) (
    input clk,
    input rstn,

    input wire clr_valid,
    output wire clr_ready,
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

    assign input_expo = fp64_stream.tdata[10:0];
    assign input_frac = {1'b1,fp64_stream.tdata[11+:52]};
    assign input_sign = fp64_stream.tdata[63];

    wire [7:0] input_acc_cs;
    wire [clogb2(SHIHT_WIDTH-1)-1:0] shift_len;
    assign input_acc_cs = (input_expo < (64-53)) ? 0: ((input_expo +53) / 64 -1);

    wire [15:0] exp_base;
    assign exp_base = input_acc_cs * 64;
    assign shift_len = input_expo-exp_base;

    
    stream #(clogb2(SHIHT_WIDTH-1) + SHIHT_WIDTH)  shift_data_stream_p();
    
    stream #(2*SHIHT_WIDTH + clogb2(ACC_DEPTH-1))  res_pkt_stream_p();

    // assign shift_data_stream_p.tdata = input_sign ? {1,(~input_frac+1),shift_len}:{0,input_frac,shift_len};
    
    assign shift_data_stream_p.tdata =  {0,input_frac,shift_len};

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