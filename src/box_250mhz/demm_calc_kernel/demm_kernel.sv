module demm_kernel (
    input wire clk,
    input wire rstn,
    
    input wire [32-1:0] times_num,

    stream.slave  axis_fp16_A_val,
    stream.slave  axis_fp16_B_val,
    stream.master  axis_fp16_out_val
);



    stream #(64)  axis_fp64_A_val();

    stream #(64)  axis_fp64_B_val();
    stream #(64)  axis_fp64_out_val();

    Radix_Converter Radix_Converter_A(
        .clk(clk),
        .rstn(rstn),
        .Ctrl_sig(0),

        .input_valid(axis_fp16_A_val.tvalid),
        .input_ready(axis_fp16_A_val.tready),
        .input_data(axis_fp16_A_val.tdata),

        .output_valid(axis_fp64_A_val.tvalid),
        .output_ready(axis_fp64_A_val.tready),
        .output_data(axis_fp64_A_val.tdata)

    );
    Radix_Converter Radix_Converter_B(
        .clk(clk),
        .rstn(rstn),
        .Ctrl_sig(0),

        .input_valid(axis_fp16_B_val.tvalid),
        .input_ready(axis_fp16_B_val.tready),
        .input_data(axis_fp16_B_val.tdata),

        .output_valid(axis_fp64_B_val.tvalid),
        .output_ready(axis_fp64_B_val.tready),
        .output_data(axis_fp64_B_val.tdata)
        
    );
    vector_dot vector_dot(
        .clk(clk),
        .rstn(rstn),

        .S_AXIS_TIMES_tdata(times_num),
        .S_AXIS_TIMES_tready(),
        .S_AXIS_TIMES_tvalid(1),


        .M_AXIS_OUT_tdata(axis_fp64_out_val.tdata),
        .M_AXIS_OUT_tready(axis_fp64_out_val.tready),
        .M_AXIS_OUT_tvalid(axis_fp64_out_val.tvalid),
        
        `ifdef __synthesis__
        .S_AXIS_A_tdata(axis_fp64_A_val.tdata),
        `else
        .S_AXIS_A_tdata(0),
        `endif
        .S_AXIS_A_tready(axis_fp64_A_val.tready),
        .S_AXIS_A_tvalid(axis_fp64_A_val.tready & axis_fp64_A_val.tvalid),

        `ifdef __synthesis__
        .S_AXIS_B_tdata(axis_fp64_B_val.tdata),
        `else
        .S_AXIS_B_tdata(0),
        `endif
        .S_AXIS_B_tready(axis_fp64_B_val.tready),
        .S_AXIS_B_tvalid(axis_fp64_B_val.tready & axis_fp64_B_val.tvalid)

    );
endmodule