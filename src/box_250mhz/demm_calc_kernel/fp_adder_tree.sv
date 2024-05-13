module fp_adder_tree #(
    
    parameter DATA_WIDTH = 16,
    parameter DATA_SIZE = 16

    ) (
    input wire clk,
    input wire rstn,
    stream.slave din_s[DATA_SIZE],
    stream.master dout_s

);
    generate 
        if(DATA_SIZE == 1)begin
        // assign dout_s.tvalid = din_s[0].tvalid;
        // assign dout_s.tdata = din_s[0].tdata;
        // assign din_s[0].tready = dout_s.tready;

            half_adder half_adder (
                .aclk(clk),         
                .aresetn(rstn),                           // input wire aclk
                .s_axis_a_tvalid(din_s[0].tvalid),            // input wire s_axis_a_tvalid
                .s_axis_a_tready(din_s[0].tready),            // output wire s_axis_a_tready
                .s_axis_a_tdata(din_s[0].tdata),              // input wire [15 : 0] s_axis_a_tdata
                .s_axis_b_tvalid(din_s[0].tvalid),            // input wire s_axis_b_tvalid
                .s_axis_b_tready(),            // output wire s_axis_b_tready
                .s_axis_b_tdata(0),              // input wire [15 : 0] s_axis_b_tdata
                .m_axis_result_tvalid(dout_s.tvalid ),  // output wire m_axis_result_tvalid
                .m_axis_result_tready(dout_s.tready),  // input wire m_axis_result_tready
                .m_axis_result_tdata(dout_s.tdata)    // output wire [15 : 0] m_axis_result_tdata
                );
        end
        else if(DATA_SIZE==2)begin
            half_adder half_adder (
                .aclk(clk),         
                .aresetn(rstn),                           // input wire aclk
                .s_axis_a_tvalid(din_s[0].tvalid),            // input wire s_axis_a_tvalid
                .s_axis_a_tready(din_s[0].tready),            // output wire s_axis_a_tready
                .s_axis_a_tdata(din_s[0].tdata),              // input wire [15 : 0] s_axis_a_tdata
                .s_axis_b_tvalid(din_s[1].tvalid),            // input wire s_axis_b_tvalid
                .s_axis_b_tready(din_s[1].tready),            // output wire s_axis_b_tready
                .s_axis_b_tdata(din_s[1].tdata),              // input wire [15 : 0] s_axis_b_tdata
                .m_axis_result_tvalid(dout_s.tvalid ),  // output wire m_axis_result_tvalid
                .m_axis_result_tready(dout_s.tready),  // input wire m_axis_result_tready
                .m_axis_result_tdata(dout_s.tdata)    // output wire [15 : 0] m_axis_result_tdata
                );
        end
        else begin
            stream #(DATA_WIDTH) stream_L[DATA_SIZE /2]();
            stream #(DATA_WIDTH) stream_L_Out();
            
            for(genvar ii = 0; ii < DATA_SIZE /2; ii = ii + 1) begin
                assign stream_L[ii].tvalid = din_s[ii].tvalid;
                assign stream_L[ii].tdata= din_s[ii].tdata;
                assign din_s[ii].tready =stream_L[ii].tready;
                
            end


            stream #(DATA_WIDTH) stream_R[DATA_SIZE - DATA_SIZE /2]();
            stream #(DATA_WIDTH) stream_R_Out();
            
            for(genvar ii = 0; ii < DATA_SIZE - DATA_SIZE /2; ii = ii + 1) begin
                assign stream_R[ii].tvalid = din_s[DATA_SIZE /2+ii].tvalid;
                assign stream_R[ii].tdata= din_s[DATA_SIZE /2+ii].tdata;
                assign din_s[DATA_SIZE /2 + ii].tready =stream_R[ii].tready;
            end

            fp_adder_tree #(
                .DATA_SIZE(DATA_SIZE /2),
                .DATA_WIDTH(DATA_WIDTH)
                ) fp_adder_tree_L(
                    .clk(clk),
                    .rstn(rstn),
                    .din_s(stream_L),
                    .dout_s(stream_L_Out)
                );
            fp_adder_tree #(
                .DATA_SIZE(DATA_SIZE - DATA_SIZE /2),
                .DATA_WIDTH(DATA_WIDTH)
                ) fp_adder_tree_R(
                    .clk(clk),
                    .rstn(rstn),
                    .din_s(stream_R),
                    .dout_s(stream_R_Out)
                );
            half_adder half_adder (
                .aclk(clk),         
                .aresetn(rstn),                           // input wire aclk
                .s_axis_a_tvalid(stream_L_Out.tvalid),            // input wire s_axis_a_tvalid
                .s_axis_a_tready(stream_L_Out.tready),            // output wire s_axis_a_tready
                .s_axis_a_tdata(stream_L_Out.tdata),              // input wire [15 : 0] s_axis_a_tdata
                .s_axis_b_tvalid(stream_R_Out.tvalid),            // input wire s_axis_b_tvalid
                .s_axis_b_tready(stream_R_Out.tready),            // output wire s_axis_b_tready
                .s_axis_b_tdata(stream_R_Out.tdata),              // input wire [15 : 0] s_axis_b_tdata
                .m_axis_result_tvalid(dout_s.tvalid ),  // output wire m_axis_result_tvalid
                .m_axis_result_tready(dout_s.tready),  // input wire m_axis_result_tready
                .m_axis_result_tdata(dout_s.tdata)    // output wire [15 : 0] m_axis_result_tdata
                );
        end
    endgenerate
endmodule